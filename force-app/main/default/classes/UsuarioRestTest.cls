@isTest
private class UsuarioRestTest {
    @isTest
    static void criarUsuarioTest() {
        
        List<RepresentanteSchema.Representante> representanteRequest = new List<RepresentanteSchema.Representante>{};
        RepresentanteSchema.Representante teste1 = new RepresentanteSchema.Representante();
        List<NegociacaoSchema.Filial> filialRequest = new List<NegociacaoSchema.Filial>{};
        NegociacaoSchema.Filial teste2 = new NegociacaoSchema.Filial();

        teste2.cnpj = '22345678901234';
        teste2.filial = 'teste';
        teste2.razaoSocial = 'teste';
        teste2.codigoEmpresa = '123';
        teste2.codigoFilial = '123';
        teste2.status = true;

        filialRequest.add(teste2);

        teste1.nome = 'Rapha';
        teste1.documento = '12345678901234';
        teste1.email = 'raphael@teste.com';
        teste1.codigoProtheus = 'testeCodigoProtheus';
        teste1.status = true;
        teste1.gerenteResponsavel = 'teste';
        teste1.funcao = 'Gerente de negócio';
        teste1.filial = '123';
        teste1.unidadeNegocio = 'Investimentos';

        representanteRequest.add(teste1);

        RestRequest reqFilial = new RestRequest();
        RestResponse resFilial = new RestResponse();
        reqFilial.requestURI = '/services/apexrest/filial/criarFilial';
        reqFilial.httpMethod = 'POST';

        RestRequest reqRepresentante = new RestRequest();
        RestResponse resRepresentante = new RestResponse();
        reqRepresentante.requestURI = '/services/apexrest/representante/criarUsuario';
        reqRepresentante.httpMethod = 'POST';

        RepresentanteSchema.RepresentantesRequest representante = new RepresentanteSchema.RepresentantesRequest();
        representante.representantes = representanteRequest;

        NegociacaoSchema.FilialRequest filial = new NegociacaoSchema.FilialRequest();
        filial.filialFields = filialRequest;

        Test.startTest();
        RestContext.request = reqFilial;
        RestContext.response = resFilial;
        RestSchema.RestMessageResponse response = FilialRest.criarFilial(filial);

        RestContext.request = reqRepresentante;
        RestContext.response = resRepresentante;
        RestSchema.RestMessageResponse response2 = UsuarioRest.criarUsuario(representante); 
        Test.stopTest();

        System.assertEquals('OK', response2.status);
        System.assertEquals('Representante criado com sucesso!', response2.message);
    }

    @isTest
    static void criarRepresentanteErroTest() {
        RepresentanteSchema.RepresentantesRequest representanteRequest = new RepresentanteSchema.RepresentantesRequest();
        
        RestRequest reqRepresentante = new RestRequest();
        RestResponse resRepresentante = new RestResponse();
        reqRepresentante.requestURI = '/services/apexrest/representante/criarUsuario';
        reqRepresentante.httpMethod = 'POST';

        Test.startTest();
        RestContext.request = reqRepresentante;
        RestContext.response = resRepresentante;
        RestSchema.RestMessageResponse response = UsuarioRest.criarUsuario(representanteRequest); 
        Test.stopTest();

        System.assertEquals('ERROR', response.status);
    }
}