@isTest
private class CustomAuthenticationServiceTest {
    @isTest static void testGetToken() {
        String accessToken = null;
        Bdrs.Callout.setTestResponse('{"access_token": "tokenstring"}', 201, 'Created');        

        Test.startTest();
        accessToken = CustomAuthenticationService.getToken();
        Test.stopTest();

        System.assertNotEquals(null, accessToken, 'O token corresponde ao valor esperado');
    }
}