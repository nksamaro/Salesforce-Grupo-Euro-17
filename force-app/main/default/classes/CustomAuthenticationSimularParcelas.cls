public with sharing class CustomAuthenticationSimularParcelas {

    public static String getTokenParcelas() {
        String accessToken;
        Endpoint__mdt endpoint = [SELECT Id, ChaveCliente__c, CredencialNomeada__c, SegredoCliente__c FROM Endpoint__mdt WHERE DeveloperName =: 'SimularParcelasTokenHost'];
        Integracao__mdt integracao = [SELECT Id, Path__c FROM Integracao__mdt WHERE DeveloperName =: 'SimularParcelasTokenPath'];
        String tokenUrl = 'callout:' + endpoint.CredencialNomeada__c + integracao.Path__c;

        String body = 'grant_type=client_credentials';
        Blob credentials = Blob.valueOf(endpoint.ChaveCliente__c + ':' + endpoint.SegredoCliente__c);
        String credentialsStr = 'Basic ' + EncodingUtil.base64Encode(credentials);

        Map<String, String> headers = new Map<String, String>{'Accept' => 'application/json', 'Authorization' => credentialsStr, 'Content-Type' => 'application/x-www-form-urlencoded'};
        HttpResponse response = Bdrs.Callout.executeHttpRequest(tokenUrl, 'POST', headers, body, 15000);

        Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        if(deserializedResponse.containsKey('access_token'))
            accessToken = String.valueOf(deserializedResponse.get('access_token'));

        return accessToken;

    }
}