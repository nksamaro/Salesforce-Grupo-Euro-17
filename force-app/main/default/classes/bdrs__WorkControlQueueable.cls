public class WorkControlQueueable implements Queueable {

	public static final Integer interval = 5;
	List<WorkControl__c> workControls = new List<WorkControl__c>();

	public WorkControlQueueable(List<WorkControl__c> workControls) {
		this.workControls = workControls;
	}

	public void execute(QueueableContext context) {
		for (WorkControl__c workControl : this.workControls) {
			WorkControlQueueable.execute(JSON.serialize(workControl));
		}
	}

	@future(callout=true) // TODO: Trocar por Queueable
	public static void execute(String workJSON) {
		executeSync(workJSON);
	}

	public static void executeSync(String workJSON) {
		WorkControl__c workControl = (WorkControl__c)JSON.deserialize(workJSON, WorkControl__c.class);

		Type t = Type.forName(workControl.Work__c);
		WorkRun workRunInstance = (WorkRun)t.NewInstance();

		String response = null;
		try {
			response = workRunInstance.process(workControl.Content__c);
			workRunInstance.processResponse(workControl.Content__c, response);

			workControl.Status__c = WorkControlConstants.Success;
			workControl.Attempts__c = workControl.Attempts__c + 1;
		}
		catch (WorkControlException e) {
			workControl.Exception__c = concatException(workControl, e.getMessage(), e.getStackTraceString());
			workControl.Attempts__c = workControl.Attempts__c + 1;
			workControl.Status__c = WorkControlConstants.Fail;
		}
		catch (Exception e) {
			workControl.Exception__c = concatException(workControl, e.getMessage(), e.getStackTraceString());
			workControl.Attempts__c = workControl.Attempts__c + 1;
			workControl.ScheduledTime__c = System.now().addMinutes(Integer.valueOf(interval*workControl.Attempts__c));

			if (workControl.Attempts__c >= 6) {
				workControl.Status__c = WorkControlConstants.Fail;
			}
			else {
				workControl.Status__c = WorkControlConstants.PendingReprocessing;
			}
		}
		finally {
			workControl.Response__c = response;
		}

		update workControl;
	}

	public static String concatException(WorkControl__c workControl, String message, String stackTraceString) {
		String pastExceptions = workControl.Exception__c == null ? '' : workControl.Exception__c;
		return String.format('{0}\r\n{1}\r\n{2}\r\n----------------\r\n', new List<String>{
			pastExceptions,
			message,
			stackTraceString}
		);
	}
}