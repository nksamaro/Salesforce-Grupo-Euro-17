public class ExtratoInvestimentosController {
    
    private static FormalizacaoRepository repository = new FormalizacaoRepository();
    private static FormalizacaoService service = new FormalizacaoService();

    @AuraEnabled
    public static List<FormalizacaoSchema.EuroSecutizadoraContratoResponse> retornarContratosCliente(String cpf){
        try{
            Boolean permissaoExtrato = FeatureManagement.checkPermission('ExtratoConsolidado');

            if(!permissaoExtrato)
                throw new Formalizacao.FormalizacaoException('Você não possui permissão para acessar os extratos consolidados de investimentos.');
            else{
                List<FormalizacaoSchema.EuroSecutizadoraContratoResponse> lstContratosCliente = repository.retornarContratosEuroSecuritizadoraAPI(cpf);
                return lstContratosCliente;
            }
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static EmailTemplate retornarTemplateEmail(String numeroContrato, String urlDownloadContrato){
        try{
            EmailTemplate emailTemplate = service.retornarTemplateEmailExtrato(numeroContrato, urlDownloadContrato);
            return emailTemplate;
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String retornarUrlDownloadContrato(String cpf, String idContrato){
        try{
            String urlDownload = repository.retornarUrlDownloadEuroSecuritizadoraAPI(cpf, idContrato);
            return urlDownload;
        } catch (Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

}