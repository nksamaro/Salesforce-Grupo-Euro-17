public with sharing class InfoFinanceirasContaTriggerHandler extends Bdrs.TriggerHandler{
    
    private CaptacaoClienteService captacaoService = new CaptacaoClienteService();

    private List<InformcoesFinanceirasConta__c> listInfoFinanceirasConta;
    private List<InformcoesFinanceirasConta__c> listInfoFinanceirasContaCelularFormat;
    private List<InformcoesFinanceirasConta__c> listInfoFinanceirasContaTelefoneFormat;

    public InfoFinanceirasContaTriggerHandler(){
        this.listInfoFinanceirasConta = (List<InformcoesFinanceirasConta__c>) Trigger.new;
        this.listInfoFinanceirasContaCelularFormat = Util.retornarListaFiltradaCampoBoolean(Trigger.new, 'CelularInternacional__c', false);
        this.listInfoFinanceirasContaTelefoneFormat = Util.retornarListaFiltradaCampoBoolean(Trigger.new, 'TelefoneInternacional__c', false);
    }

    public override void beforeInsert(){
        Bdrs.Phone.validateAndFormat(this.listInfoFinanceirasContaTelefoneFormat, InformcoesFinanceirasConta__c.Telefone__c, false);
        Bdrs.Phone.validateAndFormat(this.listInfoFinanceirasContaCelularFormat, InformcoesFinanceirasConta__c.Celular__c, true);
        this.captacaoService.validarInfoFinanceirasContaExistentes(this.listInfoFinanceirasConta);
    }

    public override void beforeUpdate(){
        Bdrs.Phone.validateAndFormat(this.listInfoFinanceirasContaTelefoneFormat, InformcoesFinanceirasConta__c.Telefone__c, false);
        Bdrs.Phone.validateAndFormat(this.listInfoFinanceirasContaCelularFormat, InformcoesFinanceirasConta__c.Celular__c, true);
        this.captacaoService.validarInfoFinanceirasContaExistentes(this.listInfoFinanceirasConta);
    }

}