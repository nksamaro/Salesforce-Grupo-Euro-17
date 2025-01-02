public with sharing class IntegracaoClienteParceiroInvocable {
    
    private static ParceiroFactory parceiroFactory = new ParceiroFactory();

    // Define um método invocável
    @InvocableMethod(label='Integrar Cliente e Parceiro Protheus' description='Integra Cliente ou Parceiro no Protheus quando oportunidade ganha')
    public static void integrarClienteParceiroProtheus(List<Request> requests){
        Account conta = new Account();
        Filial__c filial = new Filial__c();
        List<CodigoProtheus__c> lstCodProtheus = new List<CodigoProtheus__c>();
        Set<Id> setFilialId = new Set<Id>();

        //Integração de parceiros
        if(!String.isBlank(requests[0].idConta)) {
            conta = [SELECT Id, Documento__c, Name, FirstName, BairroCobranca__c, BillingAddress, ComplementoCobranca__c, NumeroCobranca__c, OwnerId, StatusConta__c FROM Account WHERE Id =: requests[0].idConta];
            filial = [SELECT Id, CodigoEmpresa__c, CodigoFilial__c FROM Filial__c WHERE CodigoFilial__c = '01001' LIMIT 1];
            List<CodigoProtheus__c> codigosProtheus = filial != null ? [SELECT Id FROM CodigoProtheus__c WHERE RecordType.DeveloperName = 'Parceiro' AND Conta__c =: conta.Id AND Filial__c =: filial.Id] : new List<CodigoProtheus__c>();

            if(codigosProtheus.isEmpty() && filial != null){
                ParceiroSchema.ParceiroWorkRunRequest parceiroSchema = new ParceiroSchema.ParceiroWorkRunRequest();
                parceiroSchema.codigoProtheus = parceiroFactory.buildCodigoProtheus(conta, filial);
                parceiroSchema.parceiroRequest = parceiroFactory.buildParceiroRequest(conta, filial);
                parceiroSchema.oportunidade = requests[0].oportunidade;

                Bdrs.WorkControl.createOutboundWork(SendParceiroWorkRun.class, JSON.serialize(parceiroSchema));
                Bdrs.WorkControl.save();
            }
        }       
    }

    public class Request {
        @InvocableVariable(label='ID da Conta')
        public String idConta;

        @InvocableVariable(label='Oportunidade')
        public Opportunity oportunidade;
    }
}