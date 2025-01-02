@isTest
private class FilialRestTest {
    @isTest
    static void criarFilialTest() {
        // Crie um objeto LeadRecebido para teste
        List<NegociacaoSchema.Filial> filialRequest = new List<NegociacaoSchema.Filial>{};
        NegociacaoSchema.Filial teste1 = new NegociacaoSchema.Filial();

        teste1.cnpj = '12345678901234';
        teste1.filial = 'teste';
        teste1.razaoSocial = 'teste';
        teste1.codigoEmpresa = '123';
        teste1.codigoFilial = '123';
        teste1.status = true;

        filialRequest.add(teste1);

        NegociacaoSchema.FilialRequest filial = new NegociacaoSchema.FilialRequest();
        filial.filialFields = filialRequest;

        // Chame o método criarLead
        Test.startTest();
        RestSchema.RestMessageResponse response = FilialRest.criarFilial(filial); 
        Test.stopTest();

        System.assertEquals('OK', response.status);
        System.assertEquals('Filial criada com sucesso!', response.message);
    }

    @isTest
    static void criarFilialErroTest() {
        // Crie um objeto LeadRecebido para teste
        NegociacaoSchema.FilialRequest filialRequest = new NegociacaoSchema.FilialRequest();
        // Chame o método criarLead
        Test.startTest();
        RestSchema.RestMessageResponse response = FilialRest.criarFilial(filialRequest); 
        Test.stopTest();

        System.assertEquals('ERROR', response.status);
    }
}