global with sharing class WorkControlMonitorScheduled extends Bdrs.SchedulerBase {
	global WorkControlMonitorScheduled() {
		interval.minutes = 5;
		super.setInstance(this, false);
	}

	global override void execute(SchedulableContext sc) {
		super.process();
	}

	global override void executeBusiness() {
		Datetime tempoLimite = System.now().addMinutes(-10);

		List<CronTrigger> lst = [
			SELECT
				Id,
				State,
				Starttime,
				Endtime,
				CreatedDate
			FROM
				CronTrigger
			WHERE
				CronJobDetailId IN (SELECT Id FROM CronJobDetail WHERE Name LIKE 'WorkControlScheduled%')
			AND State IN ('DELETED', 'WAITING')
			AND CreatedDate < :tempoLimite
		];

		if (lst.size() > 0) {
			new WorkControlScheduled().restart();
		}
	}
}