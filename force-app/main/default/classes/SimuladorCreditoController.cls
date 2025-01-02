public class SimuladorCreditoController {

    private static EmailService emailService = new EmailService();
    private static FormalizacaoFactory factory = new FormalizacaoFactory();
    private static FormalizacaoRepository repository = new FormalizacaoRepository();
    private static FormalizacaoService service = new FormalizacaoService();

    @AuraEnabled
    public static FormalizacaoSchema.SimularParcelasResponse calcularSimulacao(String simulacaoRequestStr){
        try{
            FormalizacaoSchema.SimularParcelasLwcRequest requisicaoObj = (FormalizacaoSchema.SimularParcelasLwcRequest) JSON.deserialize(simulacaoRequestStr, FormalizacaoSchema.SimularParcelasLwcRequest.class);
            FormalizacaoSchema.SimularParcelasRequest schema = factory.construirObjSimularParcelasRequest(requisicaoObj);

            FormalizacaoSchema.SimularParcelasResponse objTO = repository.retornarDadosSimulacaoCreditoFlowFinanceAPI(schema);
            return objTO;
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }  
    }

    @AuraEnabled
    public static void enviarEmail(List<String> emailCcAddress, List<String> emailAddress, String htmlBody, String subject){
        try{
            emailService.enviarEmail(emailCcAddress, emailAddress, htmlBody, subject);
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String retornarEmailContaLead(Id recordId){
        try{
            return service.retornarEmailContaLead(recordId);
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static EmailTemplate retornarTemplateEmail(String simulacaoRequestStr, String simulacaoResponseStr){
        try{
            FormalizacaoSchema.SimularParcelasLwcRequest objRequest = (FormalizacaoSchema.SimularParcelasLwcRequest) JSON.deserialize(simulacaoRequestStr, FormalizacaoSchema.SimularParcelasLwcRequest.class);
            FormalizacaoSchema.SimularParcelasResponse objResponse = (FormalizacaoSchema.SimularParcelasResponse) JSON.deserialize(simulacaoResponseStr, FormalizacaoSchema.SimularParcelasResponse.class);

            EmailTemplate emailTemplate = service.retornarTemplateEmailSimulacaoCredito(objRequest, objResponse);
            return emailTemplate;
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<FormalizacaoSchema.PicklistField> retornarValoresPicklistSimulacao(){
        try{
            List<FormalizacaoSchema.PicklistField> listPicklistFields = service.retornarValoresPicklistSimulacao();
            return listPicklistFields;
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void salvarSimulacao(Id recordId, String simulacaoRequestStr, String simulacaoResponseStr){
        try{
            FormalizacaoSchema.SimularParcelasLwcRequest objRequest = (FormalizacaoSchema.SimularParcelasLwcRequest) JSON.deserialize(simulacaoRequestStr, FormalizacaoSchema.SimularParcelasLwcRequest.class);
            FormalizacaoSchema.SimularParcelasResponse objResponse = (FormalizacaoSchema.SimularParcelasResponse) JSON.deserialize(simulacaoResponseStr, FormalizacaoSchema.SimularParcelasResponse.class);

            service.salvarSimulacao(recordId, objRequest, objResponse);
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

}