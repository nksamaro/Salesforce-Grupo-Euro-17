public class Negociacao {

    private NegociacaoFactory factory = new NegociacaoFactory();
    private NegociacaoRepository repository = new NegociacaoRepository();

    public void criarFilial(List<NegociacaoSchema.Filial> filialRequest) {
        try{

            List<Filial__c> novaFilial = this.factory.gerarObjetosFilial(filialRequest);

            upsert novaFilial IdExterno__c;

        }catch (Exception ex){
            throw new NegociacaoException('Erro na criação da filial: ' + ex.getMessage());
        }
    }

    public void criarProduto(List<NegociacaoSchema.Produto> produtoRequest, Set<String> filiaisSet){
        List<CodigoProtheus__c> verificarFiliais = new List<CodigoProtheus__c>();
        List<CodigoProtheus__c> produtoFiliais = new List<CodigoProtheus__c>();

        try{
            List<Filial__c> filiaisRelacionadas = this.repository.buscarFilialPorCodigo(filiaisSet);

            Map<String, Id> filialCodeToIdMap = new Map<String, Id>();
            for(Filial__c filial : filiaisRelacionadas) {
                filialCodeToIdMap.put(filial.CodigoFilial__c, filial.Id);
            }

            Set<String> filiaisNaoEncontradas = new Set<String>();
            for (String codigoFilial : filiaisSet) {
                if (!filialCodeToIdMap.containsKey(codigoFilial)) {
                    filiaisNaoEncontradas.add(codigoFilial);
                }
            }

            if(filiaisSet.size() == 0 || filiaisNaoEncontradas.size() > 0) {
                throw new NegociacaoException('Filiais não encontradas: ' + String.join(new List<String>(filiaisNaoEncontradas), ', '));
            }

            List<Product2> novoProdutos = this.factory.gerarObjetoProduto(produtoRequest);
            upsert novoProdutos IdExterno__c;
            
            Map<String, Id> produtoCodeToIdMap = new Map<String, Id>();
            for(Product2 produto : novoProdutos) {
                produtoCodeToIdMap.put(produto.Name, produto.Id);
            }
            produtoFiliais = this.factory.gerarObjetosProdutosFilial(filialCodeToIdMap, produtoCodeToIdMap, produtoRequest);

            for(CodigoProtheus__c produtoFilial : produtoFiliais){
                if(produtoFilial.Filial__c != null){
                    verificarFiliais.add(produtoFilial);
                }
            }

            upsert verificarFiliais IdExterno__c;
        } catch (Exception ex){
            throw new NegociacaoException('Erro na criação do produto: ' + ex.getMessage());
        }
    }

    public String aprovarItensPendentes(List<Approval.ProcessWorkitemRequest> listItensPendentes, List<Approval.ProcessSubmitRequest> listApprovalSubmitRequest, List<Id> listOpportunityIds, List<Opportunity> listOportunidades){
        try{
            TriggerHandler.byPass('OpportunityTriggerHandler');
                Approval.process(listItensPendentes);
                Approval.unlock(listOpportunityIds);
                update listOportunidades;
            TriggerHandler.clearByPass('OpportunityTriggerHandler');

            if(!listApprovalSubmitRequest.isEmpty())
                Approval.process(listApprovalSubmitRequest);

            return 'Etapas do Processo de aprovação atualizadas com sucesso.';
        } catch (Exception e){
            throw new NegociacaoException('Erro ao avançar etapas do Processo de aprovação: ' + e.getMessage());
        }
    }

    public class NegociacaoException extends Exception {}

}