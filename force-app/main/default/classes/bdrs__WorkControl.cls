global with sharing class WorkControl {
	private enum WorkType {Inbound, Outbound}

	static List<WorkControl__c> worksToSave = new List<WorkControl__c>();
	static Map<String, WorkControlSettings__mdt> workSettings = WorkControlDAO.getInstance().getWorkSettings();

	global static void save() {
		List<WorkControl__c> worksToInsert = new List<WorkControl__c>();

		for (WorkControl__c workControl : worksToSave) {
			if (workControl.Id == null) {
				worksToInsert.add(workControl);
			}
		}

		insert worksToInsert;

		publishImmediateWorks(worksToInsert);
	}

	private static void publishImmediateWorks(List<WorkControl__c> worksToInsert) {
		List<WorkControlEvent__e> worksToDispatch = new List<WorkControlEvent__e>();
		for (WorkControl__c workControl : worksToInsert) {
			if (workSettings.get(workControl.Work__c)?.ExecutionType__c == WorkControlConstants.Immediate && workControl.Status__c == WorkControlConstants.Processing) {
				worksToDispatch.add(new WorkControlEvent__e(Content__c = JSON.serialize(workControl)));
			}
		}

		if (!worksToDispatch.isEmpty()) {
			List<Database.SaveResult> results = EventBus.publish(worksToDispatch);
			for (Database.SaveResult sr : results) {
				if (!sr.isSuccess()) {
					for (Database.Error err : sr.getErrors()) {
						throw new WorkControlException('Error publishing immediate WorkControl: ' + err.getMessage());
					}
				}
			}
		}
	}

	global static void createInboundWork(System.Type workClass, String content, Map<String, Object> customFields) {
		createWork(workClass, content, WorkType.Inbound, false, customFields);
	}
	global static void createInboundWork(System.Type workClass, String content) {
		createWork(workClass, content, WorkType.Inbound, false, null);
	}
	global static void createInboundWorkLog(System.Type workClass, String content, Map<String, Object> customFields) {
		createWork(workClass, content, WorkType.Inbound, true, customFields);
	}
	global static void createInboundWorkLog(System.Type workClass, String content) {
		createWork(workClass, content, WorkType.Inbound, true, null);
	}
	global static void createOutboundWork(System.Type workClass, String content, Map<String, Object> customFields) {
		createWork(workClass, content, WorkType.Outbound, false, customFields);
	}
	global static void createOutboundWork(System.Type workClass, String content) {
		createWork(workClass, content, WorkType.Outbound, false, null);
	}
	global static void createOutboundWorkLog(System.Type workClass, String content, Map<String, Object> customFields) {
		createWork(workClass, content, WorkType.Outbound, true, customFields);
	}
	global static void createOutboundWorkLog(System.Type workClass, String content) {
		createWork(workClass, content, WorkType.Outbound, true, null);
	}

	private static void createWork(System.Type workClass, String content, WorkType workType, Boolean logOnly, Map<String, Object> customFields) {
		WorkControl__c workControl = new WorkControl__c();
		workControl.RecordTypeId = Schema.SObjectType.WorkControl__c.getRecordTypeInfosByDeveloperName().get(String.valueOf(workType)).getRecordTypeId();
		workControl.Work__c = workClass.toString();
		workControl.Content__c = content;
		workControl.Attempts__c = 0;
		workControl.ScheduledTime__c = System.now();
		workControl.Priority__c = workSettings.get(workControl.Work__c)?.Priority__c == null ? 0 : workSettings.get(workControl.Work__c).Priority__c;
		fillCustomFields(workControl, customFields); // Dont move this line

		if (workControl.Status__c == null) {
			workControl.Status__c = setStatus(workControl, logOnly); // Dont move this line
		}

		worksToSave.add(workControl);
	}

	private static void fillCustomFields(WorkControl__c workControl,  Map<String, Object> customFields) {
		if (customFields != null) {
			for (String field : customFields.keySet()) {
				workControl.put(field, customFields.get(field));
			}
		}
	}

	private static String setStatus(WorkControl__c workControl, Boolean logOnly) {
		String status;
		Boolean immediateExecution = new Set<String> { WorkControlConstants.Immediate, WorkControlConstants.ImmediateCallout }.contains(workSettings.get(workControl.Work__c)?.ExecutionType__c);

		if (logOnly) {
			status = WorkControlConstants.Success;
		}
		else if (immediateExecution) {
			if (workControl.ScheduledTime__c <= System.now()) {
				status = WorkControlConstants.Processing;
			}
			else { // If user override the default value
				status = WorkControlConstants.Pending;
			}
		}
		else if (workSettings.get(workControl.Work__c)?.Enabled__c == false) {
			status = WorkControlConstants.Disabled;
		}
		else {
			status = WorkControlConstants.Pending;
		}
		return status;
	}

	global static void processWorks() {
		processWorks(null);
	}

	global static void processWorks(Set<Id> workIds) {
		List<WorkControl__c> worksToProcess = new List<WorkControl__c>();
		Boolean immediateCallout = workIds != null;

		if (checkProcessingWorksVolume()) {
			if (immediateCallout == true) {
				worksToProcess = WorkControlDAO.getInstance().getWorksToProcessByIds(workIds);
			}
			else {
				Integer recordsLimit = (Limits.getQueueableJobs()-Limits.getLimitQueueableJobs())*(Limits.getFutureCalls()-Limits.getLimitFutureCalls());
				recordsLimit = (recordsLimit > 2000) ? 2000 : recordsLimit; // If more than 2,000 unprocessed requests from a single organization are in the queue, any additional requests from the same organization will be delayed while the queue handles requests from other organizations.
				worksToProcess = WorkControlDAO.getInstance().getWorksToProcess(recordsLimit);
			}

			if (!worksToProcess.isEmpty()) {
				for (WorkControl__c workControl : worksToProcess) {
					workControl.Status__c = WorkControlConstants.Processing;
				}
				update worksToProcess;

				List<List<WorkControl__c>> workSubLists = Collection.splitToSubList(worksToProcess, Limits.getLimitFutureCalls());

				for (List<WorkControl__c> workList : workSubLists) {
					List<WorkControl__c> worksQueueable = new List<WorkControl__c>();

					for (WorkControl__c workControl : workList) {
						if (Test.isRunningTest()) {
							WorkControlQueueable.executeSync(JSON.serialize(workControl));
						}
						else if (worksToProcess.size() == 1) { // Saves apex async calls limit
							WorkControlQueueable.execute(JSON.serialize(workControl));
						}
						else {
							worksQueueable.add(workControl);
						}
					}

					if (!worksQueueable.isEmpty()) {
						System.enqueueJob(new WorkControlQueueable(worksQueueable));
					}
				}
			}
		}
		else {
			if (immediateCallout == true) {
				putWorksToWait(workIds);
			}
		}
	}

	private static void putWorksToWait(Set<Id> workIds) {
		List<WorkControl__c> worksToUpdate = new List<WorkControl__c>();
		for (Id workId : workIds) {
			worksToUpdate.add(new WorkControl__c(
				Id = workId,
				Status__c = WorkControlConstants.Pending)
			);
		}
		update worksToUpdate;
	}

	private static Boolean checkProcessingWorksVolume() {
		return WorkControlDAO.getInstance().countProcessingWorks() < 1000;
	}
}