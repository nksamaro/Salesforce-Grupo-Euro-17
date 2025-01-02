global interface WorkRun {
	String process(String content);
	String processResponse(String content, String responseContent);
}