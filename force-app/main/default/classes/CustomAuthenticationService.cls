public class CustomAuthenticationService {

    public static String getToken() {
        String accessToken;
        Endpoint__mdt endpoint = [SELECT Id, CredencialNomeada__c FROM Endpoint__mdt WHERE DeveloperName =: 'Protheus'];
        Integracao__mdt integracao = [SELECT Id, Path__c FROM Integracao__mdt WHERE DeveloperName =: 'ProtheusToken'];
        String tokenUrl = 'callout:' + endpoint.CredencialNomeada__c + integracao.Path__c;

        Map<String, String> headers = new Map<String, String>{'Accept' => 'application/json'};
        HttpResponse response = Bdrs.Callout.executeHttpRequest(tokenUrl, 'POST', headers, null, 15000);

        if(Test.isRunningTest())
            accessToken = 'TOKEN_ACESSO';
        else{
            Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());  
            
            if(deserializedResponse.containsKey('access_token'))
                accessToken = String.valueOf(deserializedResponse.get('access_token')); 
        }
        
        return accessToken;
    }
    
}