public class AccountTriggerHandler  extends TriggerHandler{

    private CaptacaoClienteService service = new CaptacaoClienteService();
    private List<Account> lstContasCelularFormat;
    private List<Account> lstContasTelefoneFormat;

    public AccountTriggerHandler(){
        this.lstContasCelularFormat = Util.retornarListaFiltradaCampoBoolean(Trigger.new, 'CelularInternacional__c', false);
        this.lstContasTelefoneFormat = Util.retornarListaFiltradaCampoBoolean(Trigger.new, 'TelefoneInternacional__c', false);
    }

    public override void beforeInsert(){
        this.service.validarContasExistente(Trigger.new);
        this.service.formatarDocumentoConta(Trigger.new);
        Bdrs.Phone.validateAndFormat(this.lstContasTelefoneFormat, Account.Phone, false);
        Bdrs.Phone.validateAndFormat(this.lstContasCelularFormat, Account.Celular__c, true);
    }

    public override void beforeUpdate(){
        this.service.formatarDocumentoConta(Trigger.new);
        Bdrs.Phone.validateAndFormat(this.lstContasTelefoneFormat, Account.Phone, false);
        Bdrs.Phone.validateAndFormat(this.lstContasCelularFormat, Account.Celular__c, true);
    }

}