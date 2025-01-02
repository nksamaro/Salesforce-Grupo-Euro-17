public with sharing class ParceiroRepository {
    
    public ParceiroSchema.ParceiroWorkRunResponse integrarParceiro(String request){
        ParceiroSchema.ParceiroWorkRunResponse parceiroResponse = new ParceiroSchema.ParceiroWorkRunResponse();
        ParceiroSchema.ParceiroWorkRunRequest parceiroSchema = (ParceiroSchema.ParceiroWorkRunRequest) JSON.deserialize(request, ParceiroSchema.ParceiroWorkRunRequest.class);
        Endpoint__mdt endpoint = [SELECT Id, CredencialNomeada__c FROM Endpoint__mdt WHERE DeveloperName =: 'Protheus'];
        Integracao__mdt integracao = [SELECT Id, Path__c FROM Integracao__mdt WHERE DeveloperName =: 'ProtheusInclusaoParceiro'];
        String apiUrl = 'callout:' + endpoint.CredencialNomeada__c + integracao.Path__c;

        String accessToken = 'Bearer ' + CustomAuthenticationService.getToken();
        String body = JSON.serialize(parceiroSchema.parceiroRequest);
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json', 'Authorization' => accessToken};

        HttpResponse response = Bdrs.Callout.executeHttpRequest(apiUrl, 'POST', headers, body, 15000);
        
        if(response.getStatusCode() == 201)
            parceiroResponse.sucesso = true;
        else{
            if(response.getBody()?.contains('AJUDA:JAGRAVADO'))
                parceiroResponse.sucesso = false;
            else{
                throw new HandledException(
                String.format('Http status: {0}\n | Erro: {1}', new List<String> {
                    String.valueOf(response.getStatusCode()),
                    response.getBody()})
                );
            }
        }
        
        parceiroResponse.response = response.getBody();
        
        return parceiroResponse;
    }
}