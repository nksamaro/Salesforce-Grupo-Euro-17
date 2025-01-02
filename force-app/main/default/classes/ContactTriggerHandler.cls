public with sharing class ContactTriggerHandler extends Bdrs.TriggerHandler{

    private List<Contact> lstContatosCelularFormat;
    private List<Contact> lstContatosTelefoneFormat;

    public ContactTriggerHandler(){
        this.lstContatosCelularFormat = Util.retornarListaFiltradaCampoBoolean(Trigger.new, 'CelularInternacional__c', false);
        this.lstContatosTelefoneFormat = Util.retornarListaFiltradaCampoBoolean(Trigger.new, 'TelefoneInternacional__c', false);
    }

    public override void beforeInsert(){
        Bdrs.Phone.validateAndFormat(this.lstContatosTelefoneFormat, Contact.Phone, false);
        Bdrs.Phone.validateAndFormat(this.lstContatosCelularFormat, Contact.MobilePhone, true);
    }

    public override void beforeUpdate(){
        Bdrs.Phone.validateAndFormat(this.lstContatosTelefoneFormat, Contact.Phone, false);
        Bdrs.Phone.validateAndFormat(this.lstContatosCelularFormat, Contact.MobilePhone, true);
    }

}