public class SampleWorkRun implements WorkRun {
	public String process(String content) {

		String processedContent = null;
		if (content == 'sample-success-string-payload') {
			processedContent = content.reverse();
		}
		else if (content == 'sample-retry-string-payload') {
			Integer i = 1/0;
		}
		else if (content == 'sample-fail-string-payload') {
			try {
				Integer i = 1/0;
			}
			catch (Exception e) {
				throw new WorkControlException(e.getMessage());
			}
		}

		return processedContent;
	}

	public String processResponse(String content, String responseContent) {
		return responseContent;
	}
}