global with sharing class DeleteWorkControlLogsScheduled extends Bdrs.SchedulerBase {
	global DeleteWorkControlLogsScheduled() {
		interval.fixedMinute = 30;
		interval.fixedHours = new List<Integer> {00};

		super.setInstance(this, false);
	}

	global override void execute(SchedulableContext sc) {
		super.process();
	}

	global override void executeBusiness() {
		Database.executeBatch(new DeleteWorkControlLogsBatch(0));
	}
}