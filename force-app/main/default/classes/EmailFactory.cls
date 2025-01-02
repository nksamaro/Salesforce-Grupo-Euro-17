public class EmailFactory {

    public List<Messaging.SingleEmailMessage> construirObjLstEmailMessage(List<String> emailCcAddress, List<String> emailAddress, String htmlBody, String subject){
        List<Messaging.SingleEmailMessage> lstEmailMsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        emailMsg.setCcAddresses(emailCcAddress);
        emailMsg.setHtmlBody(htmlBody);
        emailMsg.setSubject(subject);
        emailMsg.setToAddresses(emailAddress);

        lstEmailMsg.add(emailMsg);
        return lstEmailMsg;
    }

}