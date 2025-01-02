public with sharing class BeneficiarioTriggerHandler extends Bdrs.TriggerHandler {
    
    private List<Beneficiario__c> lstBeneficiariosTelefoneFormat;

    public BeneficiarioTriggerHandler(){
        this.lstBeneficiariosTelefoneFormat = Util.retornarListaFiltradaCampoBoolean(Trigger.new, 'TelefoneInternacional__c', false);
    }

    public override void beforeInsert(){
        Bdrs.Phone.validateAndFormat(this.lstBeneficiariosTelefoneFormat, Beneficiario__c.Telefone__c, false);
    }

    public override void beforeUpdate(){
        Bdrs.Phone.validateAndFormat(this.lstBeneficiariosTelefoneFormat, Beneficiario__c.Telefone__c, false);
    }

}