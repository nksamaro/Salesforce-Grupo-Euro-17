public with sharing class RendaComplementarTriggerHandler extends Bdrs.TriggerHandler{
    
    private List<RendaComplementar__c> lstRendaComplementarCelularFormat;
    private List<RendaComplementar__c> lstRendaComplementarTelefoneFormat;    

    public RendaComplementarTriggerHandler(){
        this.lstRendaComplementarCelularFormat = Util.retornarListaFiltradaCampoBoolean(Trigger.new, 'CelularInternacional__c', false);
        this.lstRendaComplementarTelefoneFormat = Util.retornarListaFiltradaCampoBoolean(Trigger.new, 'TelefoneInternacional__c', false);
    }

    public override void beforeInsert(){
        Bdrs.Phone.validateAndFormat(this.lstRendaComplementarTelefoneFormat, RendaComplementar__c.Telefone__c, false);
        Bdrs.Phone.validateAndFormat(this.lstRendaComplementarCelularFormat, RendaComplementar__c.Celular__c, true);
    }

    public override void beforeUpdate(){
        Bdrs.Phone.validateAndFormat(this.lstRendaComplementarTelefoneFormat, RendaComplementar__c.Telefone__c, false);
        Bdrs.Phone.validateAndFormat(this.lstRendaComplementarCelularFormat, RendaComplementar__c.Celular__c, true);
    }

}