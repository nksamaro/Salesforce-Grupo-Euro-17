public class EmailQueueable implements Queueable {

    private EmailService service = new EmailService();
    private List<String> emailAddress;
    private List<String> emailCcAddress;
    private String htmlBody;
    private String subject;

    public EmailQueueable(List<String> emailCcAddress, List<String> emailAddress, String htmlBody, String subject){
        this.emailCcAddress = emailCcAddress;
        this.emailAddress = emailAddress;
        this.htmlBody = htmlBody;
        this.subject = subject;
    }

    public void execute(QueueableContext context){
        try{
            this.service.enviarEmail(this.emailCcAddress, this.emailAddress, this.htmlBody, this.subject);
        } catch(Exception ex){
            throw new EmailAggregate.EmailAggregateException(ex.getMessage());
        }
    }

}