@isTest
private class WorkControlTest {

	private static WorkControl__c getWorkControl() {
		return [SELECT Work__c, Status__c, Content__c, Response__c, Exception__c, Attempts__c, ScheduledTime__c FROM WorkControl__c];
	}

	private static List<WorkControl__c> getWorkControls() {
		return [SELECT Work__c, Status__c, Content__c, Response__c, Exception__c, Attempts__c, ScheduledTime__c FROM WorkControl__c];
	}

	@isTest
	static void processWorkSuccess() {
		String content = 'sample-success-string-payload';
		WorkControl.createOutboundWork(SampleWorkRun.class, content);
		WorkControl.save();

		WorkControl__c work = getWorkControl();

		String originalStatus = work.Status__c;

		Test.startTest();
		WorkControl.processWorks();
		Test.stopTest();

		work = getWorkControl();

		System.assertEquals(SampleWorkRun.class.toString(), work.Work__c);
		System.assertEquals(WorkControlConstants.Pending, originalStatus);
		System.assertEquals(WorkControlConstants.Success, work.Status__c);
		System.assertEquals(content, work.Content__c);
		System.assertEquals(content.reverse(), work.Response__c);
		System.assertEquals(1, work.Attempts__c);
	}

	@isTest
	static void processWorkRetry() {
		String content = 'sample-retry-string-payload';
		WorkControl.createOutboundWork(SampleWorkRun.class, content);
		WorkControl.save();

		WorkControl__c work = getWorkControl();

		String originalStatus = work.Status__c;

		Test.startTest();
		WorkControl.processWorks();
		Test.stopTest();

		work = getWorkControl();

		System.assertEquals(SampleWorkRun.class.toString(), work.Work__c);
		System.assertEquals(WorkControlConstants.Pending, originalStatus);
		System.assertEquals(WorkControlConstants.PendingReprocessing, work.Status__c);
		System.assertEquals(content, work.Content__c);
		System.assert(work.Exception__c.contains('Divide by 0'));
		System.assertEquals(1, work.Attempts__c);
		System.assert(work.ScheduledTime__c > System.now().addMinutes(1));
	}

	@isTest
	static void processWorkFail() {
		String content = 'sample-fail-string-payload';
		WorkControl.createOutboundWork(SampleWorkRun.class, content);
		WorkControl.save();

		WorkControl__c work = getWorkControl();

		String originalStatus = work.Status__c;

		Test.startTest();
		WorkControl.processWorks();
		Test.stopTest();

		work = getWorkControl();

		System.assertEquals(SampleWorkRun.class.toString(), work.Work__c);
		System.assertEquals(WorkControlConstants.Pending, originalStatus);
		System.assertEquals(WorkControlConstants.Fail, work.Status__c);
		System.assertEquals(content, work.Content__c);
		System.assert(work.Exception__c.contains('Divide by 0'));
		System.assertEquals(1, work.Attempts__c);
	}

	@isTest
	static void processWorkLogOnly() {
		String content = 'sample-log-only-string-payload';
		WorkControl.createInboundWorkLog(SampleWorkRun.class, content);
		WorkControl.save();

		WorkControl__c work = getWorkControl();

		String originalStatus = work.Status__c;

		Test.startTest();
		WorkControl.processWorks();
		Test.stopTest();

		work = getWorkControl();

		System.assertEquals(SampleWorkRun.class.toString(), work.Work__c);
		System.assertEquals(WorkControlConstants.Success, originalStatus);
		System.assertEquals(WorkControlConstants.Success, work.Status__c);
		System.assertEquals(content, work.Content__c);
		System.assertEquals(0, work.Attempts__c);
		System.assertEquals(null, work.Response__c);
	}

	@isTest
	static void processWorkScheduled() {
		String content = 'sample-success-string-payload';
		Map<String, Object> customFields = new Map<String, Object>();
		DateTime futureDate = System.now().addMinutes(30);
		customFields.put('ScheduledTime__c', futureDate);
		WorkControl.createOutboundWork(SampleWorkRun.class, content, customFields);
		WorkControl.save();

		WorkControl__c work = getWorkControl();

		String originalStatus = work.Status__c;

		Test.startTest();
		WorkControl.processWorks();
		Test.stopTest();

		work = getWorkControl();

		System.assertEquals(SampleWorkRun.class.toString(), work.Work__c);
		System.assertEquals(WorkControlConstants.Pending, originalStatus);
		System.assertEquals(WorkControlConstants.Pending, work.Status__c);
		System.assertEquals(futureDate, work.ScheduledTime__c);
		System.assertEquals(content, work.Content__c);
		System.assertEquals(null, work.Response__c);
		System.assertEquals(0, work.Attempts__c);
	}

	@isTest
	static void processImmediateWorkSuccess() {
		String content = 'sample-success-string-payload';
		WorkControl.createOutboundWork(SampleImmediateWorkRun.class, content);
		WorkControl.save();

		WorkControl__c work = getWorkControl();

		String originalStatus = work.Status__c;

		Test.startTest();
		Test.getEventBus().deliver();
		Test.stopTest();

		work = getWorkControl();

		System.assertEquals(SampleImmediateWorkRun.class.toString(), work.Work__c);
		System.assertEquals(WorkControlConstants.Processing, originalStatus);
		System.assertEquals(WorkControlConstants.Success, work.Status__c);
		System.assertEquals(content, work.Content__c);
		System.assertEquals(content.reverse(), work.Response__c);
		System.assertEquals(1, work.Attempts__c);
	}

	@isTest
	static void processImmediateWorkDelayed() {
		Datetime tomorrow = System.now().addDays(1);
		String content = 'sample-success-string-payload';
		WorkControl.createOutboundWork(SampleImmediateWorkRun.class, content, new Map<String, Datetime> { 'ScheduledTime__c' => tomorrow});
		WorkControl.save();

		WorkControl__c work = getWorkControl();

		Test.startTest();
		Test.getEventBus().deliver();
		Test.stopTest();

		work = getWorkControl();

		System.assertEquals(SampleImmediateWorkRun.class.toString(), work.Work__c);
		System.assertEquals(WorkControlConstants.Pending, work.Status__c);
		System.assertEquals(content, work.Content__c);
	}

	@isTest
	static void processImmediateWorkRetry() {
		String content = 'sample-retry-string-payload';
		WorkControl.createOutboundWork(SampleImmediateWorkRun.class, content);
		WorkControl.save();

		WorkControl__c work = getWorkControl();

		String originalStatus = work.Status__c;

		Test.startTest();
		Test.getEventBus().deliver();
		Test.stopTest();

		work = getWorkControl();

		System.assertEquals(SampleImmediateWorkRun.class.toString(), work.Work__c);
		System.assertEquals(WorkControlConstants.Processing, originalStatus);
		System.assertEquals(WorkControlConstants.PendingReprocessing, work.Status__c);
		System.assertEquals(content, work.Content__c);
		System.assert(work.Exception__c.contains('Divide by 0'));
		System.assertEquals(1, work.Attempts__c);
		System.assert(work.ScheduledTime__c > System.now().addMinutes(1));
	}

	@isTest
	static void processImmediateWorkFail() {
		String content = 'sample-fail-string-payload';
		WorkControl.createOutboundWork(SampleImmediateWorkRun.class, content);
		WorkControl.save();

		WorkControl__c work = getWorkControl();

		String originalStatus = work.Status__c;

		Test.startTest();
		Test.getEventBus().deliver();
		Test.stopTest();

		work = getWorkControl();

		System.assertEquals(SampleImmediateWorkRun.class.toString(), work.Work__c);
		System.assertEquals(WorkControlConstants.Processing, originalStatus);
		System.assertEquals(WorkControlConstants.Fail, work.Status__c);
		System.assertEquals(content, work.Content__c);
		System.assert(work.Exception__c.contains('Divide by 0'));
		System.assertEquals(1, work.Attempts__c);
	}

	@isTest
	static void deleteWorkControlLogs() {
		String content = 'sample-payload';
		WorkControl.createOutboundWork(SampleImmediateWorkRun.class, content, new Map<String, Object> {'Status__c' => 'Success'});
		WorkControl.createOutboundWork(SampleImmediateWorkRun.class, content, new Map<String, Object> {'Status__c' => 'Success'});
		WorkControl.createOutboundWork(SampleImmediateWorkRun.class, content, new Map<String, Object> {'Status__c' => 'Fail'});
		WorkControl.createOutboundWork(SampleImmediateWorkRun.class, content, new Map<String, Object> {'Status__c' => 'Fail'});
		WorkControl.save();

		Integer sizeBefore = getWorkControls().size();

		Test.startTest();

		Database.executeBatch(new DeleteWorkControlLogsBatch(0));

		Test.stopTest();

		Integer sizeAfter = getWorkControls().size();

		System.assertEquals(4, sizeBefore);
		System.assertEquals(2, sizeAfter);
	}
}