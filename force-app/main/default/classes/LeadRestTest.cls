@isTest
private class LeadRestTest {
    @isTest
    static void criarLeadExistenteTest() {
        insert new Product2(
            Name = 'Capital de giro'
        );
        
        // Crie um objeto LeadRecebido para teste
        CaptacaoClienteSchema.LeadRequest leadRequest = new CaptacaoClienteSchema.LeadRequest();
        leadRequest.nome = 'John Doe';
        leadRequest.documento = '41.883.507/0001-18';
        leadRequest.email = 'john.doe@example.com';
        leadRequest.telefone = '(11) 4730-1008';
        leadRequest.origem = 'Site Euro Securitizadora';
        leadRequest.produtoInteresse = 'Antecipação de recebíveis';

        // Chame o método criarLead
        Test.startTest();
        RestSchema.RestMessageResponse response = LeadRest.criarLead(leadRequest); 
        Test.stopTest();

        System.assertEquals('OK', response.status);
        System.assertEquals('Lead criado com sucesso!', response.message);
    }

    @isTest
    static void criarLeadErroTest() {
        // Crie um objeto LeadRecebido para teste
        CaptacaoClienteSchema.LeadRequest leadRequest = new CaptacaoClienteSchema.LeadRequest();
        // Chame o método criarLead
        Test.startTest();
        RestSchema.RestMessageResponse response = LeadRest.criarLead(leadRequest); 
        Test.stopTest();

        System.assertEquals('ERROR', response.status);
    }

    @isTest
    static void criarLeadOportunidadeTest() {
        // Crie uma conta existente para teste
        Account existingAccount = new Account(Name = 'Existing Account', Documento__c = '41883507000118');
        insert existingAccount;

        // Crie lead de conta já existente
        CaptacaoClienteSchema.LeadRequest leadRequest = new CaptacaoClienteSchema.LeadRequest();
        leadRequest.nome = 'John Doe';
        leadRequest.documento = '41.883.507/0001-18';
        leadRequest.email = 'john.doe@example.com';
        leadRequest.telefone = '(11) 4730-1008';
        leadRequest.origem = 'Site Euro Securitizadora';

        // Chame o método criarLead
        Test.startTest();
        RestSchema.RestMessageResponse response = LeadRest.criarLead(leadRequest); 
        Test.stopTest();

        System.assertEquals('OK', response.status);
        System.assertEquals('Lead criado com sucesso!', response.message);

        //Testa criação da oportunidade
        Opportunity oportunidade = [Select Id, LeadSource From Opportunity Where AccountId =: existingAccount.Id Limit 1];
        System.assertEquals('Site Euro Securitizadora', oportunidade.LeadSource);
    }

    @isTest
    static void criacaoLeadProdutosFinanceirosTest() {
        //Inserir produto
        insert new Product2(
            Name = 'FINANCIAMENTO DE VEICULOS'
        );

        // Crie um objeto LeadRecebido para teste
        CaptacaoClienteSchema.LeadRequest leadRequest = new CaptacaoClienteSchema.LeadRequest();
        leadRequest.nome = 'Fulano Test';
        leadRequest.documento = '80142118044';
        leadRequest.email = 'israel.lage@platformbuilders.com.br';
        leadRequest.telefone = '1140404040';
        leadRequest.celular = '11940404040';
        leadRequest.estadoCivil = 'Casado(a)';
        leadRequest.comporRenda = 'Sim';
        leadRequest.renda = 1000;
        leadRequest.valorImovel = 100000;
        leadRequest.valorFinanciamento = 80000;
        leadRequest.prazo = 13;
        leadRequest.placa = 'BXP2022';
        leadRequest.restricao = 'Não';
        leadRequest.originador = 'Google';
        leadRequest.origem = 'Site Euro 17 Crédito';
        leadRequest.produtoInteresse = 'Financiamento de veículo';

        // Chame o método criarLead
        Test.startTest();
        RestSchema.RestMessageResponse response = LeadRest.criarLead(leadRequest); 
        Test.stopTest();

        Lead lead = [SELECT Id FROM Lead WHERE Name = 'Fulano Test' LIMIT 1];
        RendaComplementar__c renda = [SELECT Id FROM RendaComplementar__c WHERE Lead__c =:lead.Id LIMIT 1];

        System.assertEquals('OK', response.status, 'Retorno OK para sucesso');
        System.assertNotEquals(null, lead, 'Lead não deve ser nulo');
        System.assertNotEquals(null, renda, 'RendaComplementar__c não deve ser nulo');
    }

    @isTest
    static void verificaLeadEProdutoExistenteProdutosFinanceirosTest() {
        //Inserir produto
        insert new Product2(
            Name = 'FINANCIAMENTO DE VEICULOS'
        );

        // Crie um objeto LeadRecebido para teste
        CaptacaoClienteSchema.LeadRequest leadRequest = new CaptacaoClienteSchema.LeadRequest();
        leadRequest.nome = 'Fulano Test';
        leadRequest.documento = '80142118044';
        leadRequest.email = 'israel.lage@platformbuilders.com.br';
        leadRequest.telefone = '1140404040';
        leadRequest.celular = '11940404040';
        leadRequest.estadoCivil = 'Casado(a)';
        leadRequest.comporRenda = 'Sim';
        leadRequest.renda = 1000;
        leadRequest.valorImovel = 100000;
        leadRequest.valorFinanciamento = 80000;
        leadRequest.prazo = 13;
        leadRequest.placa = 'BXP2022';
        leadRequest.restricao = 'Não';
        leadRequest.originador = 'Google';
        leadRequest.origem = 'Site Euro 17 Crédito';
        leadRequest.produtoInteresse = 'Financiamento de veículo';

        // Chame o método criarLead
        Test.startTest();
        RestSchema.RestMessageResponse response = LeadRest.criarLead(leadRequest);
        RestSchema.RestMessageResponse responseSegundaRequest = LeadRest.criarLead(leadRequest);
        Test.stopTest();

        System.assertEquals('ERROR', responseSegundaRequest.status, 'Retorno ERROR para o status');
        System.assertEquals('Existe uma solicitação em andamento para o produto solicitado. Em breve retornaremos o contato.', responseSegundaRequest.message, 'Deve retornar mensagem informando solicitação em andamento');
    }
}