public without sharing class FormalizacaoService {
    
    private Formalizacao formalizacao = new Formalizacao();
    private FormalizacaoFactory factory = new FormalizacaoFactory();
    private FormalizacaoRepository repository = new FormalizacaoRepository();

    public void integrarOportunidadeGanhaProtheus(List<Opportunity> listOpportunityNew, Map<Id, Opportunity> mapOpportunityOld){
        Integer countDML = 0;
        List<Opportunity> listOportunidadesAtualizadas = new List<Opportunity>();
        Set<String> setUnidadesNegocioProtheus = new Set<String>{ 'Investimentos', 'Produtos financeiros', 'Produtos financeiros - Veículos' };

        for(Opportunity oportunidade : listOpportunityNew){
            Opportunity oportunidadeOld = mapOpportunityOld.get(oportunidade.Id);

            if(countDML < 51){
                if(setUnidadesNegocioProtheus.contains(oportunidade.UnidadeNegocio__c) && (oportunidade.IsWon && oportunidade.StageName != oportunidadeOld.StageName) || (oportunidade.StatusProtheus__c == 'Reprocessada' && oportunidade.DataHoraIntegracaoProtheus__c != oportunidadeOld.DataHoraIntegracaoProtheus__c)){
                    Bdrs.WorkControl.createOutboundWork(ProtheusOportunidadeGanhaWorkRun.class, JSON.serialize(oportunidade.Id), new Map<String, Object> {
                        'Priority__c' => 0 });
                    Bdrs.WorkControl.save();

                    Opportunity oportunidadeAtualizada = new Opportunity(Id = oportunidade.Id, StatusProtheus__c = 'Em processamento');
                    listOportunidadesAtualizadas.add(oportunidadeAtualizada);
                    countDML++;
                }
            } else
                break;

            update listOportunidadesAtualizadas;
        }
    }

    public String retornarEmailContaLead(Id recordId){
        Id accountId = recordId?.getSObjectType().getDescribe().getName() == 'Account' ? recordId : null;
        Id leadId = accountId == null ? recordId : null;
        String enderecoEmail;

        if(accountId != null)
            enderecoEmail = this.repository.buscarContaPorId(accountId).Email__c;
        else if(leadId != null)
            enderecoEmail = this.repository.buscarLeadPorId(leadId).Email;

        return enderecoEmail;    
    }

    public EmailTemplate retornarTemplateEmailExtrato(String numeroContrato, String urlDownloadContrato){
        EmailTemplate template = this.repository.buscarTemplateEmailPorNome('Extrato')[0];
        String userName = UserInfo.getName();
        this.factory.construirObjHtmlBody(template, numeroContrato, urlDownloadContrato, userName);

        return template;
    }

    public EmailTemplate retornarTemplateEmailSimulacaoCredito(FormalizacaoSchema.SimularParcelasLwcRequest objRequest, FormalizacaoSchema.SimularParcelasResponse objResponse){
        EmailTemplate template = this.repository.buscarTemplateEmailPorNome('Simulação de crédito')[0];
        String userName = UserInfo.getName();
        this.factory.construirObjHtmlBody(template, objRequest, objResponse, userName);

        return template;
    }

    public List<FormalizacaoSchema.PicklistField> retornarValoresPicklistSimulacao(){
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get('SimulacaoCredito__c').getDescribe();
        DescribeFieldResult periodicidadeResult = objResult.fields.getMap().get('Periodicidade__c').getDescribe();
        DescribeFieldResult tipoIOFResult = objResult.fields.getMap().get('TipoIOF__c').getDescribe();
        List<Schema.PicklistEntry> lstPeriodicidadePicklistEntry = periodicidadeResult.getPicklistValues();
        List<Schema.PicklistEntry> lstTipoIOFPicklistEntry = tipoIOFResult.getPicklistValues();

        return this.factory.construirObjPicklistSimulacao(lstPeriodicidadePicklistEntry, lstTipoIOFPicklistEntry);
    }

    public void salvarSimulacao(Id recordId, FormalizacaoSchema.SimularParcelasLwcRequest objRequest, FormalizacaoSchema.SimularParcelasResponse objResponse){
        Id accountId = recordId?.getSObjectType().getDescribe().getName() == 'Account' ? recordId : null;
        Id leadId = accountId == null ? recordId : null;
    
        SimulacaoCredito__c simulacaoCredito = this.factory.construirObjSimulacaoCredito(accountId, leadId, objRequest, objResponse);
        this.formalizacao.salvarSimulacaoCredito(simulacaoCredito);

        List<SimulacaoParcela__c> lstSimulacaoParcela = this.factory.construirObjSimulacaoParcela(simulacaoCredito.Id, objResponse);
        this.formalizacao.salvarSimulacoesParcela(lstSimulacaoParcela);
    }

}