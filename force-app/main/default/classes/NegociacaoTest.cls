@IsTest
private class NegociacaoTest {

    @TestSetup
    static void makeData(){
        User gerenciador = [SELECT Id FROM User WHERE IsActive = true AND ManagerId != null AND Profile.Name = 'Grupo Euro 17' LIMIT 1];
        User userAtual = new User(Funcao__c = 'Vice presidencia', Id = UserInfo.getUserId(), ManagerId = gerenciador.Id);

        update userAtual;
    }

    @IsTest
    static void testCriarFilial() {
        // Criar dados de teste
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

        NegociacaoSchema.FilialRequest filial = new NegociacaoSchema.FilialRequest();
        filial.filialFields = filialRequest;

        Test.startTest();
        NegociacaoService negocicao = new NegociacaoService();
        negocicao.criarFilial(filial);
        Test.stopTest();
        
        // Realizar asserções ou consultas para verificar os resultados
        List<Filial__c> filiaisCriadas = [SELECT Id, CNPJ__c FROM Filial__c WHERE CNPJ__c IN ('12.345.678/9012-34', '22.345.678/9012-34')];
        Assert.areEqual(2, filiaisCriadas.size());
    }

    @IsTest
    static void testCriarProduto() {
        // Criar dados de teste
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
        
        // Chamar o método de criação de produto
        Test.startTest();
        Negociacao negociacaoInstance = new Negociacao();
        NegociacaoService service = new NegociacaoService();
        negociacaoInstance.criarFilial(filialRequest);
        service.criarProduto(produto);
        Test.stopTest();
        
        // Realizar asserções ou consultas para verificar os resultados
        List<CodigoProtheus__C> codigosProtheusCriados = [SELECT Id, IdExterno__c FROM CodigoProtheus__C];
        Assert.areEqual(2, codigosProtheusCriados.size());
    }

    @IsTest
    static void aprovarEtapasGerenteGeral(){
        User usuarioAtual = new User(
            Funcao__c = 'Gerente geral',
            Id = UserInfo.getUserId()
        );

        update usuarioAtual;

        Account conta = new Account(
            Documento__c = '67634718076',
            FirstName = 'Maria',
            LastName = 'Teste',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaPessoal').getRecordTypeId()
        );
        insert conta;

        Product2 produto = new Product2(
            IsActive = true,
            Name = 'EURO PRIME SECURITIZADORA'
        );
        insert produto;

        Opportunity opp = new Opportunity(
            AccountId = conta.Id,
            CloseDate = System.today().addDays(1),
            Name = 'Maria Teste',
            PrazoOperacao__c = 84,
            Produto__c = produto.Id,
            Quantidade__c = 200,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Investimentos').getRecordTypeId(),
            StageName = 'Pendente',
            Taxa__c = 1.7,
            Type = 'Novo aporte',
            ValorOportunidade__c = 200000
        );
        insert opp;

        List<Approval.ProcessWorkitemRequest> lstApprovalReq = new List<Approval.ProcessWorkitemRequest>();
        List<ProcessInstanceWorkitem> listItensPendentes = new NegociacaoRepository().buscarItensPendentesAprovacao(new Set<Id> { opp.Id });

        for(ProcessInstanceWorkitem item : listItensPendentes){
            Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
            approvalReq.setWorkItemId(item.Id);
            approvalReq.setAction('Approve');
            approvalReq.setComments('Aprovado com sucesso.');
            lstApprovalReq.add(approvalReq);
        }

        Test.startTest();
            Approval.process(lstApprovalReq);
            String setOppIdsString = JSON.serialize(new Set<Id>{ opp.Id });
            String processResult = new AprovacaoProcessosWorkRun().process(setOppIdsString);
            String processResponse = new AprovacaoProcessosWorkRun().processResponse(setOppIdsString, processResult);
        Test.stopTest();

        List<ProcessInstanceStep> lstEtapasProcesso = [SELECT Id, Comments, CreatedDate, StepStatus FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId =: opp.Id AND StepStatus != 'Started' ORDER BY CreatedDate DESC];
        Opportunity oppAtualizada = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id LIMIT 1];

        Assert.areEqual('Etapas do Processo de aprovação atualizadas com sucesso.', processResponse);
        Assert.areEqual('Aprovado com sucesso.', lstEtapasProcesso[0].Comments);
        Assert.areEqual('Approved', lstEtapasProcesso[0].StepStatus);
        Assert.areEqual('Validando Taxa/Prazo', oppAtualizada.StageName);
    }

    @IsTest
    static void aprovarEtapasVicePresidencia(){
        Account conta = new Account(
            Documento__c = '67634718076',
            FirstName = 'Maria',
            LastName = 'Teste',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaPessoal').getRecordTypeId()
        );
        insert conta;

        Product2 produto = new Product2(
            IsActive = true,
            Name = 'EURO PRIME SECURITIZADORA'
        );
        insert produto;

        Opportunity opp = new Opportunity(
            AccountId = conta.Id,
            CloseDate = System.today().addDays(1),
            Name = 'Maria Teste',
            PrazoOperacao__c = 84,
            Produto__c = produto.Id,
            Quantidade__c = 200,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Investimentos').getRecordTypeId(),
            StageName = 'Pendente',
            Taxa__c = 1.7,
            Type = 'Novo aporte',
            ValorOportunidade__c = 200000
        );
        insert opp;

        List<ProcessInstanceWorkItem> listItensPendentes = new NegociacaoRepository().buscarItensPendentesAprovacao(new Set<Id> { opp.Id });

        Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
        approvalReq.setWorkItemId(listItensPendentes[0].Id);
        approvalReq.setAction('Approve');
        approvalReq.setComments('Aprovado com sucesso pela VP.');
        Approval.process(approvalReq);

        Test.startTest();
            String setOppIdsString = JSON.serialize(new Set<Id>{ opp.Id });
            String processResult = new AprovacaoProcessosWorkRun().process(setOppIdsString);
            String processResponse = new AprovacaoProcessosWorkRun().processResponse(setOppIdsString, processResult);
        Test.stopTest();

        List<ProcessInstanceStep> lstEtapasProcesso = [SELECT Id, Comments, CreatedDate, StepStatus FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId =: opp.Id AND StepStatus != 'Started' ORDER BY Id DESC];
        Opportunity oppAtualizada = [SELECT Id, StageName FROM Opportunity WHERE Id =: opp.Id LIMIT 1];

        Assert.areEqual('Etapas do Processo de aprovação atualizadas com sucesso.', processResponse);
        Assert.areEqual('Aprovado automaticamente pela VP.', lstEtapasProcesso[0].Comments);
        Assert.areEqual('Approved', lstEtapasProcesso[0].StepStatus);
        Assert.areEqual('Taxa/Prazo Aprovada', oppAtualizada.StageName);
    }

    @IsTest
    static void excecaoAprovarEtapasProcesso(){
        List<Approval.ProcessSubmitRequest> listApprovalSubmitRequest = new List<Approval.ProcessSubmitRequest>();
        List<Approval.ProcessWorkitemRequest> lstItensInvalidos = new List<Approval.ProcessWorkItemRequest>();
        Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
        request.setWorkItemId(UserInfo.getUserId());
        request.setAction('Approve');
        request.setComments('Aprovado automaticamente pela VP.');

        lstItensInvalidos.add(request);

        List<Opportunity> listOpportunity = new List<Opportunity>();
        List<Id> listOpportunityIdsInvalidos = new List<Id> { UserInfo.getUserId() };

        try{
            String result = new Negociacao().aprovarItensPendentes(lstItensInvalidos, listApprovalSubmitRequest, listOpportunityIdsInvalidos, listOpportunity);
        } catch(Exception e){
            Assert.isTrue(e.getMessage().contains('Erro ao avançar etapas do Processo de aprovação'));
        }
    }

}