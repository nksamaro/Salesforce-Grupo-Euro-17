@IsTest
private class RepresentanteTest {
    @IsTest
    static void testCriarRepresentante() {

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
        RepresentanteService service = new RepresentanteService();
        service.criarRepresentantes(representante);
        Test.stopTest();

        List<User> representantesCriados = [SELECT Id, Name FROM User WHERE Name = 'Rapha'];
        List<CodigoProtheus__c> lstCodProtheus = [SELECT Id, Codigo__c, Representante__c FROM CodigoProtheus__c WHERE Codigo__c = 'testeCodigoProtheus'];

        Assert.areEqual(1, representantesCriados.size());
        Assert.areEqual(1, lstCodProtheus.size());
        Assert.areEqual(representantesCriados[0].Id, lstCodProtheus[0].Representante__c);
    }
    
}