public with sharing class ClienteService {

    public static SendClienteWorkRunSchema.Response sendRequest(String clienteServiceRequest) {
        SendClienteWorkRunSchema.Request sendClienteWorkRunReqObj = (SendClienteWorkRunSchema.Request) System.JSON.deserialize(clienteServiceRequest, SendClienteWorkRunSchema.Request.class);
        SendClienteWorkRunSchema.Response sendClienteWorkRunResObj = new SendClienteWorkRunSchema.Response();

        Endpoint__mdt endpoint = [SELECT Id, CredencialNomeada__c FROM Endpoint__mdt WHERE DeveloperName =: 'Protheus'];
        Integracao__mdt integracao = [SELECT Id, Path__c FROM Integracao__mdt WHERE DeveloperName =: 'ProtheusInclusaoCliente'];
        String apiUrl = 'callout:' + endpoint.CredencialNomeada__c + integracao.Path__c;
        String accessToken = 'Bearer ' + CustomAuthenticationService.getToken();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json', 'Authorization' => accessToken};

        HttpResponse response = Bdrs.Callout.executeHttpRequest(apiUrl, 'POST', headers, JSON.serialize(sendClienteWorkRunReqObj.clienteRequest), 15000);

        if(response.getStatusCode() == 201)
            sendClienteWorkRunResObj.sucesso = true;
        else {
            if(response.getBody()?.contains('pode haver mais de um registro de'))
                sendClienteWorkRunResObj.sucesso = false;
            else{
                throw new HandledException(
                    String.format('Http status: {0}\n | Erro: {1}', new List<String> {
                        String.valueOf(response.getStatusCode()),
                        response.getBody()})
                );
            }
        }

        sendClienteWorkRunResObj.response = response.getBody();

        return sendClienteWorkRunResObj;
    }
}