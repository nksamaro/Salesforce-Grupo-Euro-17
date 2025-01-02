@RestResource(urlMapping='/representante/*')
global class UsuarioRest {

    private static RepresentanteService service = new RepresentanteService();

    @HttpPost
    global static RestSchema.RestMessageResponse criarUsuario(RepresentanteSchema.RepresentantesRequest representanteRequest){
        RestSchema.RestMessageResponse response;

        try{
            service.criarRepresentantes(representanteRequest);
            response = new RestSchema.RestMessageResponse('Representante criado com sucesso!', RestSchema.RestStatus.OK);
            RestContext.response.statusCode = 200;
        }
        catch(Exception e){
            response = new RestSchema.RestMessageResponse(e.getMessage(), RestSchema.RestStatus.ERROR);
            RestContext.response.statusCode = 500;
        }

        return response;
    }
}