public class OpportunityTriggerHandler extends TriggerHandler {

    private ComissaoService comissaoService = new ComissaoService();
    private FormalizacaoService formalizacaoService = new FormalizacaoService();
    private NegociacaoService negociacaoService = new NegociacaoService();

    private List<Opportunity> listOpportunityNew;
    private Map<Id, Opportunity> mapOpportunityOld;

    public OpportunityTriggerHandler(){
        this.listOpportunityNew = (List<Opportunity>) Trigger.new;
        this.mapOpportunityOld = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    public override void afterUpdate(){
        this.comissaoService.criarComissao(this.listOpportunityNew, this.mapOpportunityOld);
        this.formalizacaoService.integrarOportunidadeGanhaProtheus(this.listOpportunityNew, this.mapOpportunityOld);
        this.negociacaoService.aprovarItensPendentes(this.listOpportunityNew, this.mapOpportunityOld);
    }
}