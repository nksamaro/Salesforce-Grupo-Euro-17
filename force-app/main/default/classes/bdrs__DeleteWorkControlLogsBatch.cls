global class DeleteWorkControlLogsBatch implements Database.Batchable<sObject>, Database.Stateful {
	private Integer queryIndex;
	private List<String> listaQueries;

	public static void startProcess(Integer index) {
		System.Debug('>>>> index = ((' + index + '))');
		Database.executeBatch(new DeleteWorkControlLogsBatch(index));
	}

	global DeleteWorkControlLogsBatch(Integer index) {
		listaQueries = loadQueryList();
		queryIndex = index;
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(listaQueries.get(queryIndex));
	}

	global void execute(Database.BatchableContext bc, List<sObject> workControls) {
		if (!workControls.isEmpty()) {
			delete workControls;
		}
	}

	global void finish(Database.BatchableContext bc) {
		queryIndex++;
		if (queryIndex < listaQueries.size()) {
			DeleteWorkControlLogsBatch.startProcess(queryIndex);
		}
	}

	private List<String> loadQueryList() {
		List<WorkControlSettings__mdt> workSettings = WorkControlSettings__mdt.getall().values();
		List<String> queries = new List<String>();

		for (WorkControlSettings__mdt item : workSettings) {
			if (item.DaysToKeepSuccessLogs__c != null) {
				queries.add(mountQuery(item.Work__c, WorkControlConstants.Success, Integer.valueOf(item.DaysToKeepSuccessLogs__c)));
			}

			if (item.DaysToKeepFailedLogs__c != null) {
				queries.add(mountQuery(item.Work__c, WorkControlConstants.Fail, Integer.valueOf(item.DaysToKeepFailedLogs__c)));
			}
		}

		return queries;
	}

	private String mountQuery(String work, String status, Integer daysToKeep) {
		String query = 'SELECT Id FROM WorkControl__c WHERE Work__c = \'\'{0}\'\' AND Status__c = \'\'{1}\'\' AND CreatedDate <= {2}';

		Datetime dateLimit = System.now().addDays(-daysToKeep);

		query = String.format(query, new List<String> {
			work,
			status,
			dateLimit.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
		});

		System.Debug('>>>> query = ((' + query + '))');

		return query;
	}
}