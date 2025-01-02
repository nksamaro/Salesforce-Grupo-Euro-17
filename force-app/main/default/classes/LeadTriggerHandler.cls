public class LeadTriggerHandler  extends TriggerHandler{

    private CaptacaoClienteService service = new CaptacaoClienteService();
    private List<Lead> lstLeadsCelularFormat;
    private List<Lead> lstLeadsTelefoneFormat;

    public LeadTriggerHandler(){
        this.lstLeadsCelularFormat = Util.retornarListaFiltradaCampoBoolean(Trigger.new, 'CelularInternacional__c', false);
        this.lstLeadsTelefoneFormat = Util.retornarListaFiltradaCampoBoolean(Trigger.new, 'TelefoneInternacional__c', false);
    }

    public override void beforeInsert(){
        this.service.formatarDocumentoLead(Trigger.new);
        Bdrs.Phone.validateAndFormat(this.lstLeadsTelefoneFormat, Lead.Phone, false);
        Bdrs.Phone.validateAndFormat(this.lstLeadsCelularFormat, Lead.MobilePhone, true);
    }

    public override void beforeUpdate(){
        this.service.formatarDocumentoLead(Trigger.new);
        Bdrs.Phone.validateAndFormat(this.lstLeadsTelefoneFormat, Lead.Phone, false);
        Bdrs.Phone.validateAndFormat(this.lstLeadsCelularFormat, Lead.MobilePhone, true);
    }
}