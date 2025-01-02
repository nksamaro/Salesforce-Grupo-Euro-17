global with sharing class WorkControlScheduled extends Bdrs.SchedulerBase {
	global WorkControlScheduled() {
		interval.minutes = 1;
		super.setInstance(this, false);
	}

	global override void execute(SchedulableContext sc) {
		super.process();
	}

	global override void executeBusiness() {
		WorkControl.processWorks();
	}
}