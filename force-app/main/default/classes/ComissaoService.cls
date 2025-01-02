public class ComissaoService {
    private Comissao comissao = new Comissao();
    private ComissaoFactory factory = new ComissaoFactory();
    
    public void criarComissao(List<Opportunity> oportunidades, Map<Id, Opportunity> mapOpportunityOld) {
        //Separa apenas as oportunidades fechadas e ganhas
        List<Opportunity> oportunidadesGanhas = this.comissao.retornarOportunidadesGanhas(oportunidades, mapOpportunityOld);
        List<Comissao__c> comissoes = new List<Comissao__c>();
        Map<Id, Opportunity> mapOportunidade = new Map<Id, Opportunity>();

        for(Opportunity oportunidade : oportunidadesGanhas){
            comissoes.add(this.factory.gerarComissao(oportunidade));
            mapOportunidade.put(oportunidade.Id, oportunidade);
        }

        if(!comissoes.isEmpty()) {
            //Criar comissão das oportunidades ganhas
            insert comissoes;

            //Gera filas para processar os comissionados
            this.criarFilasComissionados(comissoes, mapOportunidade);
        }
    }

    //Enfilera as comissoes para serem gerados os seus repectivos comissionados
    private void criarFilasComissionados(List<Comissao__c> comissoes, Map<Id, Opportunity> mapOportunidade) { 
        //Importante: ainda que considera bulk, pelo processo as oportunidades não serão fechadas por lote. Caso passem a ser, as filas precisam ser encadeadas de forma recursiva
        for(Comissao__c comissao : comissoes) {
            System.enqueueJob(new ProcessamentoComissionadosQueueable(comissao, mapOportunidade.get(comissao.Oportunidade__c)));
        }
    }
}