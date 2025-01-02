public class EmailAggregate {
    
    public void enviarEmail(List<Messaging.SingleEmailMessage> lstEmailMsg){
        try{
            Messaging.sendEmail(lstEmailMsg);
        } catch(Exception ex){
            throw new EmailAggregateException(ex.getMessage());
        }
    }

    public class EmailAggregateException extends Exception {}

}