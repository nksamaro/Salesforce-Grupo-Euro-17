trigger WorkControlTrigger on WorkControl__c (after insert) {
	Map<String, WorkControlSettings__mdt> workSettings = WorkControlDAO.getInstance().getWorkSettings();

	Set<Id> workIds = new Set<Id>();
	for (WorkControl__c work : Trigger.new) {
		if (workSettings.get(work.Work__c)?.ExecutionType__c == WorkControlConstants.ImmediateCallout && work.Status__c == WorkControlConstants.Processing) {
			 workIds.add(work.Id);
		}
	}

	WorkControl.processWorks(workIds);
}