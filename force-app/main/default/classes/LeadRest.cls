@RestResource(urlMapping='/lead/*')
global class LeadRest {
    private static CaptacaoClienteService service = new CaptacaoClienteService();

    @HttpPost
    global static RestSchema.RestMessageResponse criarLead(CaptacaoClienteSchema.LeadRequest leadRequest){
        RestSchema.RestMessageResponse response;

        try{
            service.criarLead(leadRequest);
            response = new RestSchema.RestMessageResponse('Lead criado com sucesso!', RestSchema.RestStatus.OK);
            RestContext.response.statusCode = 200;
        }
        catch(Exception e){
            response = new RestSchema.RestMessageResponse(e.getMessage(), RestSchema.RestStatus.ERROR);
            RestContext.response.statusCode = 500;
        }

        return response;
    }
}