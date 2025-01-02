public class EmailModalController {
    
    private static EmailService service = new EmailService();

    @AuraEnabled
    public static void enviarEmail(List<String> emailCcAddress, List<String> emailAddress, String htmlBody, String subject){
        try{
            service.enviarEmail(emailCcAddress, emailAddress, htmlBody, subject);
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

}