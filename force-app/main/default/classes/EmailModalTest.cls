@IsTest
private class EmailModalTest {
    
    @IsTest
    static void enviarEmail(){
        List<String> lstEnderecosEmail = new List<String>{'teste@gmail.com'};

        Test.startTest();
            EmailModalController.enviarEmail(new List<String>(), lstEnderecosEmail, 'Teste sendo executado', 'Teste');
        Test.stopTest();
    }

    @IsTest
    static void enviarEmailErro(){
        try{
            EmailModalController.enviarEmail(new List<String>(), new List<String>(), 'Teste sendo executado', 'Teste');
        } catch(Exception ex){
            Assert.isTrue(ex.getMessage().contains('Script-thrown exception'));
        }
    }

}