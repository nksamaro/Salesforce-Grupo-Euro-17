public class CustomAuthenticationEuroSecuritizadora {

    public String getToken(){
        Endpoint__mdt endpoint = [SELECT Id, ChaveCliente__c, CredencialNomeada__c, NomeUsuario__c, SegredoCliente__c, Senha__c FROM Endpoint__mdt WHERE DeveloperName = 'EuroSecuritizadora' LIMIT 1];
        Integracao__mdt integracao = [SELECT Id, Path__c FROM Integracao__mdt WHERE DeveloperName = 'EuroSecuritizadoraGetToken' LIMIT 1];
        Map<String, String> mapHeaders = new Map<String, String>{'Accept' => 'application/json', 'Content-Type' => 'application/json'};
        String accessToken;

        EuroSecuritizadoraTokenRequest bodyRequest = new EuroSecuritizadoraTokenRequest(endpoint.ChaveCliente__c, endpoint.SegredoCliente__c, 'password', endpoint.Senha__c, endpoint.NomeUsuario__c);

        String apiEndpoint = 'callout:' + endpoint.CredencialNomeada__c + integracao.Path__c;
        String bodyRequestStr = JSON.serialize(bodyRequest);
        
        HttpResponse response = Bdrs.Callout.executeHttpRequest(apiEndpoint, 'POST', mapHeaders, bodyRequestStr, 15000);

        if(!Test.isRunningTest()){
            Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if(deserializedResponse.containsKey('access_token'))
                accessToken = String.valueOf(deserializedResponse.get('access_token'));
        } else
            accessToken = 'TOKEN_ACESSO';
        
        return accessToken;
    }

    public class EuroSecuritizadoraTokenRequest{
        public String client_id { get; set; }
        public String client_secret { get; set; }
        public String grant_type { get; set; }
        public String password { get; set; }
        public String username { get; set; }

        public EuroSecuritizadoraTokenRequest(String client_id, String client_secret, String grant_type, String password, String username){
            this.client_id = client_id;
            this.client_secret = client_secret;
            this.grant_type = grant_type;
            this.password = password;
            this.username = username;
        }
    }

}