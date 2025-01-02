public with sharing class DadoBancarioTriggerHandler extends TriggerHandler {

    private CaptacaoClienteService captacaoService = new CaptacaoClienteService();

    private List<DadoBancario__c> listDadosBancarios;

    public DadoBancarioTriggerHandler(){
        this.listDadosBancarios = (List<DadoBancario__c>) Trigger.new;
    }

    public override void beforeInsert(){
        this.captacaoService.validarDadosBancariosExistentes(this.listDadosBancarios);
    }

    public override void beforeUpdate(){
        this.captacaoService.validarDadosBancariosExistentes(this.listDadosBancarios);
    }

}