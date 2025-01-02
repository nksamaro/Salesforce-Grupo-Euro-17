global class NegociacaoService {

    private Negociacao negociacao = new Negociacao();
    private NegociacaoFactory factory = new NegociacaoFactory();
    private NegociacaoRepository repository = new NegociacaoRepository();

    global void criarFilial(NegociacaoSchema.FilialRequest filialRequest) {
        List<NegociacaoSchema.Filial> filiais = filialRequest.filialFields;
        
        this.negociacao.criarFilial(filiais);
        
    }

    global void criarProduto(NegociacaoSchema.ProdutoRequest produtoRequest){
        List<NegociacaoSchema.Produto> products = produtoRequest.produtos;
        Set<String> codFilial = new Set<String>();

        for(NegociacaoSchema.Produto produto : products){
            List<NegociacaoSchema.Filial> filiais = produto.filiais;
            
            for(NegociacaoSchema.Filial filial : filiais){
                if(filial.codigoFilial != null) {
                    codFilial.add(filial.codigoFilial);
                }
            }
        }

        this.negociacao.criarProduto(products, codFilial);
    }

    public void aprovarItensPendentes(List<Opportunity> listOpportunityNew, Map<Id, Opportunity> mapOpportunityOld){
        List<ProcessInstanceStep> listEtapasAprovadas = new List<ProcessInstanceStep>();
        Map<Id, ProcessInstanceStep> mapOppIdEtapaProcesso = new Map<Id, ProcessInstanceStep>();
        Set<Id> setOppsAprovadasIds = new Set<Id>();
        Set<Id> setOppsAprovacaoValidasIds = new Set<Id>();
        User usuarioAtual = this.repository.buscarUsuarioPorId(UserInfo.getUserId());

        for(Opportunity oportunidade : listOpportunityNew){
            Opportunity oportunidadeOld = mapOpportunityOld.get(oportunidade.Id);

            if(oportunidade.DataHoraUltimaAprovacao__c != null && oportunidade.DataHoraUltimaAprovacao__c != oportunidadeOld.DataHoraUltimaAprovacao__c)
                setOppsAprovadasIds.add(oportunidade.Id);
        }

        if(!setOppsAprovadasIds.isEmpty()){
            listEtapasAprovadas = this.repository.buscarEtapasMaisRecenteAprovadas(setOppsAprovadasIds);

            for(ProcessInstanceStep etapa : listEtapasAprovadas)
                mapOppIdEtapaProcesso.put(etapa.ProcessInstance.TargetObjectId, etapa);

            for(Id idOportunidade : mapOppIdEtapaProcesso.keySet()){
                ProcessInstanceStep ultimaEtapa = mapOppIdEtapaProcesso.get(idOportunidade);

                if(ultimaEtapa.StepStatus == 'Rejected' || ultimaEtapa.StepStatus == 'Approved')
                    setOppsAprovacaoValidasIds.add(idOportunidade);
            }
    
            if(!setOppsAprovacaoValidasIds.isEmpty()){
                Bdrs.WorkControl.createOutboundWork(AprovacaoProcessosWorkRun.class, JSON.serialize(setOppsAprovacaoValidasIds), new Map<String, Object> {
                    'Priority__c' => 0 });
                Bdrs.WorkControl.save();
            }
        }
    }

}