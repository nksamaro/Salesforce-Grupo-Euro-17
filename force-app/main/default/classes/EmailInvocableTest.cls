@IsTest
private class EmailInvocableTest {
    
    @IsTest
    static void enviarEmail(){
        EmailInvocable.Request request = new EmailInvocable.Request();
        List<EmailInvocable.Request> lstRequest = new List<EmailInvocable.Request>();
        request.assunto = 'Teste!';
        request.corpo = '<p> Este é apenas um <strong> teste </strong> </p> <p> Atenciosamente, </p> <p> Administrador do sistema </p>';
        request.lstDestinatarios = new List<String>{ 'teste0@gmail.com', 'teste1@gmail.com', 'teste2@gmail.com', 'teste3@gmail.com', 'teste4@gmail.com', 'teste5@gmail.com' };
        lstRequest.add(request);

        Test.startTest();
            EmailInvocable.enviarEmail(lstRequest);
        Test.stopTest();
    }

}