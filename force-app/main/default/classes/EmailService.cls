public class EmailService {
    
    private EmailAggregate emailAggregate = new EmailAggregate();
    private EmailFactory factory = new EmailFactory();

    public void enviarEmail(List<String> emailCcAddress, List<String> emailAddress, String htmlBody, String subject){
        List<Messaging.SingleEmailMessage> lstEmailMsg = this.factory.construirObjLstEmailMessage(emailCcAddress, emailAddress, htmlBody, subject);
        this.emailAggregate.enviarEmail(lstEmailMsg);
    }

}