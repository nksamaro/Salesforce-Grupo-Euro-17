public class WorkControlDAO {
	private static final WorkControlDAO instance = new WorkControlDAO();
	public static WorkControlDAO getInstance() {
		return instance;
	}

	private WorkControlDAO() { }

	public List<WorkControl__c> getWorksToProcessByIds(Set<Id> ids) {
		return [
			SELECT
				Work__c,
				Content__c,
				Attempts__c,
				Exception__c,
				ScheduledTime__c
			FROM
				WorkControl__c
			WHERE
				Id IN :ids
			ORDER BY
				Priority__c ASC,
				ScheduledTime__c ASC
		];
	}

	public List<WorkControl__c> getWorksToProcess(Integer maxRecords) {
		List<String> status = new List<String> { WorkControlConstants.Pending, WorkControlConstants.PendingReprocessing };

		return [
			SELECT
				Work__c,
				Content__c,
				Attempts__c,
				Exception__c,
				ScheduledTime__c
			FROM
				WorkControl__c
			WHERE
				Status__c IN :status
			AND ScheduledTime__c <= :System.now()
			ORDER BY
				Priority__c ASC,
				ScheduledTime__c ASC
			LIMIT :maxRecords
		];
	}

	public Integer countProcessingWorks() {
		return [
			SELECT
				COUNT()
			FROM
				WorkControl__c
			WHERE
				Status__c = :WorkControlConstants.Processing
		];
	}

	public Map<String, WorkControlSettings__mdt> getWorkSettings() {
		Map<String, WorkControlSettings__mdt> mapWorkSettings = new Map<String, WorkControlSettings__mdt>();
		Collection.loadMap(mapWorkSettings, 'bdrs__Work__c', WorkControlSettings__mdt.getall().values());
		return mapWorkSettings;
	}
}