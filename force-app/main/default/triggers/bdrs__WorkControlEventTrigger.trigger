trigger WorkControlEventTrigger on WorkControlEvent__e (after insert) {
	List<WorkControlEvent__e> works = (List<WorkControlEvent__e>)Trigger.new;
	for (WorkControlEvent__e work : works) {
		WorkControlQueueable.executeSync(work.Content__c);
		EventBus.TriggerContext.currentContext().setResumeCheckpoint(work.ReplayId);
		// break;
	}
}