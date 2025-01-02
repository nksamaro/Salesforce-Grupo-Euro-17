global class AprovacaoProcessosWorkRun implements Bdrs.WorkRun {
   
    private Map<Id, Id> mapOppIdHierarquiaAdicional = new Map<Id, Id>();
    private Negociacao negociacao = new Negociacao();
    private NegociacaoFactory factory = new NegociacaoFactory();
    private NegociacaoRepository repository = new NegociacaoRepository();

    global String process(String content){
        Integer soqlQueries = 0;
        List<Approval.ProcessSubmitRequest> listApprovalSubmitRequest = new List<Approval.ProcessSubmitRequest>();
        List<Approval.ProcessWorkitemRequest> listApprovalRequest = new List<Approval.ProcessWorkitemRequest>();
        List<Id> listOpportunityIds = new List<Id>();
        List<Opportunity> listOportunidades = new List<Opportunity>();
        List<Opportunity> listOportunidadesDataAprovacao = new List<Opportunity>();
        List<ProcessInstanceStep> listEtapasAprovadas = new List<ProcessInstanceStep>();
        List<ProcessInstanceWorkitem> listItensPendentes = new List<ProcessInstanceWorkitem>();
        List<User> listHierarquiaUser = new List<User>();
        Map<Id, List<ProcessInstanceWorkitem>> mapOppIdItensPendentes = new Map<Id, List<ProcessInstanceWorkitem>>();
        Map<Id, ProcessInstanceStep> mapOppIdEtapaProcesso = new Map<Id, ProcessInstanceStep>();
        Map<Id, Id> mapOppIdProprietario = new Map<Id, Id>();
        Map<Id, Id> mapOppIdVicePresidencia = new Map<Id, Id>();
        Set<Id> setOpportunityIds = (Set<Id>) JSON.deserialize(content, Set<Id>.class);

        listOportunidades = this.repository.buscarOportunidadesPorSetId(setOpportunityIds);
        listEtapasAprovadas = this.repository.buscarEtapasMaisRecenteAprovadas(setOpportunityIds);
		listItensPendentes = this.repository.buscarItensPendentesAprovacao(setOpportunityIds);

        for(Opportunity opp : listOportunidades)
            mapOppIdProprietario.put(opp.Id, opp.OwnerId);

        for(ProcessInstanceStep etapa : listEtapasAprovadas)
            mapOppIdEtapaProcesso.put(etapa.ProcessInstance.TargetObjectId, etapa);

        for(ProcessInstanceWorkitem itemPendente : listItensPendentes){
            if(mapOppIdItensPendentes.get(itemPendente.ProcessInstance.TargetObjectId) != null)
                mapOppIdItensPendentes.get(itemPendente.ProcessInstance.TargetObjectId).add(itemPendente);
            else
                mapOppIdItensPendentes.put(itemPendente.ProcessInstance.TargetObjectId, new List<ProcessInstanceWorkitem>{ itemPendente });
        }

        listHierarquiaUser = this.repository.buscarHierarquiaUsuariosPorSetId(new Set<Id>( mapOppIdProprietario.values()) );

        for(Opportunity opp : listOportunidades)
            buscarVicePresidencia(opp.Id, opp.OwnerId, listHierarquiaUser, mapOppIdVicePresidencia);

        while(!this.mapOppIdHierarquiaAdicional.values().isEmpty() && soqlQueries < 50){
            listHierarquiaUser = this.repository.buscarHierarquiaUsuariosPorSetId(new Set<Id>( this.mapOppIdHierarquiaAdicional.values()) );

            for(Id oppId : this.mapOppIdHierarquiaAdicional.keySet())
                buscarVicePresidencia(oppId, this.mapOppIdHierarquiaAdicional.get(oppId), listHierarquiaUser, mapOppIdVicePresidencia);

            soqlQueries++;
        }

        listApprovalRequest = this.factory.gerarSolicitacoesAprovacao(listItensPendentes, mapOppIdEtapaProcesso);
        listOportunidadesDataAprovacao = this.factory.atualizarDatasOportunidadesProcessoAprovacao(mapOppIdEtapaProcesso);
        listApprovalSubmitRequest = this.factory.validarEnvioAprovacaoVP(mapOppIdVicePresidencia, mapOppIdItensPendentes, mapOppIdEtapaProcesso);

        for(Opportunity opp : listOportunidadesDataAprovacao)
            listOpportunityIds.add(opp.Id);

        String aprovacaoResult = this.negociacao.aprovarItensPendentes(listApprovalRequest, listApprovalSubmitRequest, listOpportunityIds, listOportunidadesDataAprovacao);

		return aprovacaoResult;
	}

	global String processResponse(String content, String responseContent){
		return responseContent;
	}

    private void buscarVicePresidencia(Id oppId, Id proprietarioId, List<User> listHierarquiaUser, Map<Id, Id> mapOppIdVicePresidencia){
        for(User user : listHierarquiaUser){
            if(user.Id == proprietarioId){
                Integer contHierarquia = 0;
                User usuarioLoop = user.Manager;

                while(usuarioLoop != null){
                    if(!String.isBlank(usuarioLoop.Funcao__c) && usuarioLoop.Funcao__c.contains('Vice presidencia'))
                        mapOppIdVicePresidencia.put(oppId, usuarioLoop.Id);

                    contHierarquia++;

                    //Caso tenham sido encontrados 6 gerentes acima adiciona gerente final para pesquisa adicional
                    if(contHierarquia == 6){
                        this.mapOppIdHierarquiaAdicional.put(oppId, usuarioLoop.Id);
                        usuarioLoop = null;
                    } else{
                        if(this.mapOppIdHierarquiaAdicional.get(oppId) != null)
                            this.mapOppIdHierarquiaAdicional.remove(oppId);

                        usuarioLoop = usuarioLoop.Manager;
                    }
                }

                break;
            }
        }
    }

}