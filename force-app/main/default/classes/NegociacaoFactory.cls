public with sharing class NegociacaoFactory {

    public List<Opportunity> atualizarDatasOportunidadesProcessoAprovacao(Map<Id, ProcessInstanceStep> mapOppIdEtapaProcesso){
        List<Opportunity> lstOportunidades = new List<Opportunity>();

        for(Id idOportunidade : mapOppIdEtapaProcesso.keySet()){
            ProcessInstanceStep ultimaEtapa = mapOppIdEtapaProcesso.get(idOportunidade);

            if((ultimaEtapa.StepStatus == 'Approved' && ultimaEtapa.ProcessInstance.LastActor.Funcao__c == 'Vice presidencia') || ultimaEtapa.StepStatus == 'Rejected'){
                Opportunity oportunidade = new Opportunity(
                    DataHoraUltimaAprovacao__c = null,
                    Id = idOportunidade,
                    StageName = ultimaEtapa.StepStatus == 'Rejected' ? 'Taxa/Prazo Reprovada' : 'Taxa/Prazo Aprovada'
                );

                lstOportunidades.add(oportunidade);
            }
        }

        return lstOportunidades;
    }

    public List<Filial__c> gerarObjetosFilial(List<NegociacaoSchema.Filial> filiaisRequest) {
        List<Filial__c> filiais = new List<Filial__c>();
        
        for (NegociacaoSchema.Filial filialRequest : filiaisRequest) {
            String documentoFormatado = Format.documento(filialRequest.cnpj);
            Filial__c filial = new Filial__c(
                CNPJ__C = documentoFormatado,
                CodigoEmpresa__c = filialRequest.codigoEmpresa,
                CodigoFilial__c = filialRequest.codigoFilial,
                Name = filialRequest.filial,
                RazaoSocial__c = filialRequest.razaoSocial,
                Status__c = filialRequest.status,
                IdExterno__c = Bdrs.Format.clearNumberFormatting(filialRequest.cnpj)
            );
            
            filiais.add(filial);
        }
        
        return filiais;
    }

    public List<Product2> gerarObjetoProduto(List<NegociacaoSchema.Produto> produtoRequest){
        List<Product2> produtos = new List<Product2>();

        for(NegociacaoSchema.Produto produtosRequest : produtoRequest){
            Product2 produto = new Product2(
                IsActive = produtosRequest.statusProduto,
                Description = produtosRequest.descricaoProduto,
                Name = produtosRequest.nomeProduto,
                IdExterno__c = produtosRequest.nomeProduto
            );
            produtos.add(produto);
        }

        return produtos;
    }

    public List<CodigoProtheus__c> gerarObjetosProdutosFilial(Map<String, Id> filialCodeToIdMap, Map<String, Id> produtoCodeToIdMap, List<NegociacaoSchema.Produto> produtosRequest) {
        List<CodigoProtheus__c> produtosFiliais = new List<CodigoProtheus__c>();
    
        for(NegociacaoSchema.Produto produtoRequest : produtosRequest){
            for(NegociacaoSchema.Filial filial : produtoRequest.filiais) {
                CodigoProtheus__c produtoFilial = new CodigoProtheus__c();
                produtoFilial.Filial__c = filialCodeToIdMap.get(String.ValueOf(filial.codigoFilial));
                produtoFilial.Produto__c = produtoCodeToIdMap.get(produtoRequest.nomeProduto);
                produtoFilial.Codigo__c = produtoRequest.codigoProduto;
                produtoFilial.IdExterno__c = filial.codigoFilial + ' + ' + produtoRequest.codigoProduto;
                produtoFilial.Ativo__c = produtoRequest.statusProduto;
                produtoFilial.RecordTypeId = Schema.SObjectType.CodigoProtheus__c.getRecordTypeInfosByDeveloperName().get('Produtos').getRecordTypeId();
                
                produtosFiliais.add(produtoFilial);
            }
        }
    
        return produtosFiliais;
    }

    public List<Approval.ProcessWorkitemRequest> gerarSolicitacoesAprovacao(List<ProcessInstanceWorkItem> listItensPendentes, Map<Id, ProcessInstanceStep> mapOppIdEtapaProcesso){
        List<Approval.ProcessWorkitemRequest> listApprovalRequest = new List<Approval.ProcessWorkitemRequest>();

        for(ProcessInstanceWorkItem item : listItensPendentes){
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            ProcessInstanceStep ultimaEtapa = mapOppIdEtapaProcesso.get(item.ProcessInstance.TargetObjectId);

            if(ultimaEtapa.StepStatus == 'Rejected' || (ultimaEtapa.StepStatus == 'Approved' && ultimaEtapa.ProcessInstance.LastActor.Funcao__c == 'Vice presidencia')){
                String actionAprovacao = ultimaEtapa.StepStatus == 'Rejected' ? 'Reject' : 'Approve';
                String mensagemAprovacao = ultimaEtapa.StepStatus == 'Rejected' ? 'Reprovado automaticamente.' : 'Aprovado automaticamente pela VP.';

                request.setWorkItemId(item.Id);
                request.setAction(actionAprovacao);
                request.setComments(mensagemAprovacao);
                listApprovalRequest.add(request);
            }
        }

        return listApprovalRequest;
    }

    public List<Approval.ProcessSubmitRequest> validarEnvioAprovacaoVP(Map<Id, Id> mapOppIdVicePresidencia, Map<Id, List<ProcessInstanceWorkitem>> mapOppIdItensPendentes, Map<Id, ProcessInstanceStep> mapOppIdEtapaProcesso){
        List<Approval.ProcessSubmitRequest> lstApprovalReq = new List<Approval.ProcessSubmitRequest>();

        for(Id oppId : mapOppIdEtapaProcesso.keySet()){
            List<ProcessInstanceWorkitem> lstItensPendentes = mapOppIdItensPendentes.get(oppId);
            ProcessInstanceStep ultimaEtapa = mapOppIdEtapaProcesso.get(oppId);

            if(lstItensPendentes == null && ultimaEtapa.StepStatus == 'Approved' && ultimaEtapa.ProcessInstance.LastActor.Funcao__c != 'Vice presidencia'){
                Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
                approvalReq.setObjectId(oppId);
                approvalReq.setProcessDefinitionNameOrId(ultimaEtapa.ProcessInstance.ProcessDefinition.DeveloperName);
                approvalReq.setNextApproverIds(new List<Id>{ mapOppIdVicePresidencia.get(oppId) });
                approvalReq.setSubmitterId(ultimaEtapa.ProcessInstance.CreatedById);

                lstApprovalReq.add(approvalReq);
            }
        }

        return lstApprovalReq;
    }

}