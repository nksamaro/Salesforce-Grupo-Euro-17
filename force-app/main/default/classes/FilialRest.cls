@RestResource(urlMapping='/filial/*')
global class FilialRest {
    private static NegociacaoService service = new NegociacaoService();

    @HttpPost
    global static RestSchema.RestMessageResponse criarFilial(NegociacaoSchema.FilialRequest filialRequest){
        RestSchema.RestMessageResponse response;

        try{
            service.criarFilial(filialRequest);
            response = new RestSchema.RestMessageResponse('Filial criada com sucesso!', RestSchema.RestStatus.OK);
            RestContext.response.statusCode = 200;
        }
        catch(Exception e){
            response = new RestSchema.RestMessageResponse(e.getMessage(), RestSchema.RestStatus.ERROR);
            RestContext.response.statusCode = 500;
        }

        return response;
    }
}