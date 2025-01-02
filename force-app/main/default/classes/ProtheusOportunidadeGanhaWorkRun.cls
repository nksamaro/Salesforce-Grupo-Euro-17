global class ProtheusOportunidadeGanhaWorkRun implements Bdrs.WorkRun {
    
    private FormalizacaoFactory factory = new FormalizacaoFactory();
    private FormalizacaoRepository repository = new FormalizacaoRepository();

    global String process(String content){
        Id oportunidadeId = (Id) JSON.deserialize(content, Id.class);
        Id idParceiroRelacionado;
        CodigoProtheus__c codigoProtheusConta;
        CodigoProtheus__c codigoProtheusParceiro;
        CodigoProtheus__c codigoProtheusProduto;
        CodigoProtheus__c codigoProtheusRepresentante;
        Map<Id, CodigoProtheus__c> mapIdComissionadoCodigoProtheus = new Map<Id, CodigoProtheus__c>();
        Map<Id, TimeRelacionamento__c> mapComissionados = new Map<Id, TimeRelacionamento__c>();
        Map<String, CodigoProtheus__c> mapCodigosProtheus = new Map<String, CodigoProtheus__c>();

        Opportunity oportunidade = this.repository.buscarDadosOportunidadeGanha(oportunidadeId);
        Quote cotacao = this.repository.buscarDadosCotacaoOportunidadeId(oportunidadeId);
        List<TimeRelacionamento__c>  lstTimeRelacionamento = this.repository.buscarTimesRelacionamentoOportunidadeId(oportunidadeId);

        for(TimeRelacionamento__c timeRelacionamento : lstTimeRelacionamento){
            if(timeRelacionamento.RecordType.Name == 'Parceiro')
                idParceiroRelacionado  = timeRelacionamento.Conta__c;
            else
                mapComissionados.put(timeRelacionamento.NomeGerente__c, timeRelacionamento);
        }

        List<CodigoProtheus__c> lstCodigosProtheus = this.repository.buscarCodigosProtheusOportunidadeGanha(idParceiroRelacionado, oportunidade.Produto__c);
        List<InformacoesFinanceirasOportunidade__c> listInformacoesFinanceirasOportunidade = oportunidade.InformacoesFinanceirasOportunidade__r;

        for(CodigoProtheus__c codigoProtheus : lstCodigosProtheus)
            mapCodigosProtheus.put(codigoProtheus.RecordType.Name, codigoProtheus);

        codigoProtheusParceiro = mapCodigosProtheus.get('Parceiro');
        codigoProtheusProduto = mapCodigosProtheus.get('Produtos');
        codigoProtheusConta = this.repository.buscarCodigoProtheusFilialContaId(codigoProtheusProduto.Filial__r.CodigoFilial__c, oportunidade.AccountId);
        codigoProtheusRepresentante = this.repository.buscarCodigoProtheusFilialRepresentanteId(codigoProtheusProduto.Filial__r.CodigoFilial__c, oportunidade.OwnerId);

        List<CodigoProtheus__c> lstCodigosProtheusComissionados = this.repository.buscarCodigosProtheusFiliaisRepresentantesIds(new Set<String> { codigoProtheusProduto.Filial__r.CodigoFilial__c }, mapComissionados.keySet());

        for(CodigoProtheus__c codigoProtheus : lstCodigosProtheusComissionados){
            for(TimeRelacionamento__c comissionado : mapComissionados.values()){
                if(comissionado.NomeGerente__c == codigoProtheus.Representante__c){
                    mapIdComissionadoCodigoProtheus.put(comissionado.Id, codigoProtheus);
                    break;
                }
            }
        }

        if(codigoProtheusRepresentante == null)
           return 'Oportunidade ' + oportunidadeId + ' não foi enviada devido à ausência de Código Protheus do representante relacionado. Consulte o time de T.I para inserção via Protheus.';
        else if(codigoProtheusConta == null){
            Account conta = [SELECT Id, Documento__c, RecordType.Name, Name, FirstName, BillingCountry, BillingState, BillingCity, BillingStreet, BillingPostalCode, BairroCobranca__c, ComplementoCobranca__c FROM Account WHERE Id =: oportunidade.AccountId];

            SendClienteWorkRunSchema.Request sendClienteWorkRunObj = new SendClienteWorkRunSchema.Request();
            sendClienteWorkRunObj.clienteRequest = ClienteFactory.buildClienteRequest(conta, codigoProtheusRepresentante);
            sendClienteWorkRunObj.codigoProtheus = ClienteFactory.buildCodigoProtheus(conta, codigoProtheusRepresentante);
            sendClienteWorkRunObj.oportunidade = oportunidade;

            Bdrs.WorkControl.createOutboundWork(SendClienteWorkRun.class, JSON.serialize(sendClienteWorkRunObj));
            Bdrs.WorkControl.save();

            return 'Oportunidade ' + oportunidadeId + ' não foi enviada devido à ausência de Código Protheus do cliente relacionado. Status: Fila de reprocessamento.';
        } else if(oportunidade.UnidadeNegocio__c == 'Produtos financeiros' && codigoProtheusParceiro == null && idParceiroRelacionado != null){
            IntegracaoClienteParceiroInvocable.Request invocableRequest = new IntegracaoClienteParceiroInvocable.Request();
            List<IntegracaoClienteParceiroInvocable.Request> lstInvocableRequest = new List<IntegracaoClienteParceiroInvocable.Request>();
            invocableRequest.idConta = idParceiroRelacionado;
            invocableRequest.oportunidade = oportunidade;

            lstInvocableRequest.add(invocableRequest);

            IntegracaoClienteParceiroInvocable.integrarClienteParceiroProtheus(lstInvocableRequest);

            return 'Oportunidade ' + oportunidadeId + ' não foi enviada devido à ausência de Código Protheus do parceiro relacionado. Status: Fila de reprocessamento.';
        } else{
            FormalizacaoSchema.ProtheusOportunidadeGanhaSalesforceRequest objSalesforceRequest = new FormalizacaoSchema.ProtheusOportunidadeGanhaSalesforceRequest(codigoProtheusConta, codigoProtheusRepresentante, listInformacoesFinanceirasOportunidade, mapIdComissionadoCodigoProtheus, mapComissionados, mapCodigosProtheus, oportunidade, cotacao);
            String objOppGanhaRequestStr = this.factory.construirObjProtheusOportunidadeGanhaRequest(objSalesforceRequest);
            System.debug(objOppGanhaRequestStr);
    
            FormalizacaoSchema.ProtheusIntegracaoOportunidadeGanhaResponse objOppGanhaResponse = this.repository.integrarOportunidadeGanhaProtheus(objOppGanhaRequestStr);
            return JSON.serialize(objOppGanhaResponse);
        }
   
    }

    global String processResponse(String content, String responseContent){
        Id oportunidadeId = (Id) JSON.deserialize(content, Id.class);
        Opportunity oportunidade = new Opportunity(Id = oportunidadeId);
        Contrato__c contrato = this.repository.buscarContratoRelacionadoOportunidadeId(oportunidadeId);

        if(responseContent.contains('Fila de reprocessamento')){
            oportunidade.DataHoraIntegracaoProtheus__c = Datetime.now();
            oportunidade.StatusProtheus__c = 'Em reprocessamento';
        } else if(!responseContent.contains('Consulte o time de T.I')){
            FormalizacaoSchema.ProtheusIntegracaoOportunidadeGanhaResponse objResponse = (FormalizacaoSchema.ProtheusIntegracaoOportunidadeGanhaResponse) JSON.deserialize(responseContent, FormalizacaoSchema.ProtheusIntegracaoOportunidadeGanhaResponse.class);

            if(objResponse.PROPOSALCODE != null){
                oportunidade.DataHoraIntegracaoProtheus__c = Datetime.now();
                oportunidade.PropostaProtheus__c = objResponse.PROPOSALCODE;
                oportunidade.StatusProtheus__c = 'Integrada';

                if(contrato != null)
                    contrato.PropostaProtheus__c = objResponse.PROPOSALCODE;
            }
        }
  
        update oportunidade;

        if(contrato != null)
            update contrato;

        return responseContent;
	}

}