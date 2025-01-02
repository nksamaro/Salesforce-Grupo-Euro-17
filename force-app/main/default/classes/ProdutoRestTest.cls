@isTest
private class ProdutoRestTest {
    @isTest
    static void criarProdutoTest() {
        // Crie um objeto LeadRecebido para teste
        List<NegociacaoSchema.Produto> produtoRequest = new List<NegociacaoSchema.Produto>{};

        List<NegociacaoSchema.Filial> filialRequest = new List<NegociacaoSchema.Filial>{};

        NegociacaoSchema.Filial teste1 = new NegociacaoSchema.Filial();
        NegociacaoSchema.Filial teste2 = new NegociacaoSchema.Filial();

        teste1.cnpj = '12345678901234';
        teste1.filial = 'teste';
        teste1.razaoSocial = 'teste';
        teste1.codigoEmpresa = '123';
        teste1.codigoFilial = '123';
        teste1.status = true;

        teste2.cnpj = '22345678901234';
        teste2.filial = 'teste';
        teste2.razaoSocial = 'teste';
        teste2.codigoEmpresa = '124';
        teste2.codigoFilial = '124';
        teste2.status = true;

        filialRequest.add(teste1);
        filialRequest.add(teste2);

        Set<Integer> filiaisSet = new Set<Integer>{124, 123};

        NegociacaoSchema.Produto prod1 = new NegociacaoSchema.Produto();
        NegociacaoSchema.Produto prod2 = new NegociacaoSchema.Produto();

        prod1.codigoProduto = '123';
        prod1.nomeProduto = 'teste';
        prod1.statusProduto = true;
        prod1.descricaoProduto = 'teste';
        prod1.filialProduto = '123';
        prod1.filiais = new List<NegociacaoSchema.Filial>();
        prod1.filiais.add(teste1);

        prod2.codigoProduto = '122';
        prod2.nomeProduto = 'teste2';
        prod2.statusProduto = true;
        prod2.descricaoProduto = 'teste';
        prod2.filialProduto = '123';
        prod2.filiais = new List<NegociacaoSchema.Filial>();
        prod2.filiais.add(teste2);

        produtoRequest.add(prod1);
        produtoRequest.add(prod2);
        
        NegociacaoSchema.ProdutoRequest produto = new NegociacaoSchema.ProdutoRequest();
        produto.produtos = produtoRequest;

        // Chame o método criarLead
        Test.startTest();
        RestSchema.RestMessageResponse response = ProdutoRest.criarProduto(produto); 
        Test.stopTest();

        System.assertEquals('OK', response.status);
        System.assertEquals('Produto criado com sucesso!', response.message);
    }

    @isTest
    static void criarFilialErroTest() {
        // Crie um objeto LeadRecebido para teste
        NegociacaoSchema.ProdutoRequest produto = new NegociacaoSchema.ProdutoRequest();
        // Chame o método criarLead
        Test.startTest();
        RestSchema.RestMessageResponse response = ProdutoRest.criarProduto(produto); 
        Test.stopTest();

        System.assertEquals('ERROR', response.status);
    }
}