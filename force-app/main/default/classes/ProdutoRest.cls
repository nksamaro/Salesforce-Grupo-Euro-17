@RestResource(urlMapping='/produto/*')
global class ProdutoRest {
    private static NegociacaoService service = new NegociacaoService();

    @HttpPost
    global static RestSchema.RestMessageResponse criarProduto(NegociacaoSchema.ProdutoRequest produtoRequest){
        RestSchema.RestMessageResponse response;

        try{
            service.criarProduto(produtoRequest);
            response = new RestSchema.RestMessageResponse('Produto criado com sucesso!', RestSchema.RestStatus.OK);
            RestContext.response.statusCode = 200;
        }
        catch(Exception e){
            response = new RestSchema.RestMessageResponse(e.getMessage(), RestSchema.RestStatus.ERROR);
            RestContext.response.statusCode = 500;
        }

        return response;
    }
}