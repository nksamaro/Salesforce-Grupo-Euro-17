@IsTest
private class FormalizacaoTest {
    
    /*@TestSetup
    static void makeData(){
        Account testAccount = new Account(
            FirstName = 'Test',
            LastName = 'Pessoa Física',
            BairroCobranca__c = 'Bairro X',
            BillingCity = 'São Paulo',
            BillingCountry = 'Brasil',
            BillingPostalCode = '12345-678',
            BillingState = 'SP',
            BillingStreet = 'Avenida X',
            Documento__c = '441.287.810-45', 
            NumeroCobranca__c = '100',
            TipoPessoa__c = 'Pessoa Física',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaPessoal').getRecordTypeId()
        );
        insert testAccount;

        Account bancoParceiro = new Account(
            BillingStreet = 'AV PAULISTA 2100',
            Documento__c = '92.523.470/0001-58',
            Name = 'BANCO PARCEIRO',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Empresa').getRecordTypeId(),
            StatusConta__c = 'Ativo',
            TipoPessoa__c = 'Pessoa jurídica'
        );
        insert bancoParceiro;

        InformcoesFinanceirasConta__c infoFinanceiraConta = new InformcoesFinanceirasConta__c(
            Agencia__c = '9090',
            Conta__c = '12345',
            ContaRelacionada__c = testAccount.Id,
            DV__c = '1',
            InstituicaoFinaneira__c = '001',
            Name = 'Test 001',
            RecordTypeId = Schema.SObjectType.InformcoesFinanceirasConta__c.getRecordTypeInfosByDeveloperName().get('DadoBancario').getRecordTypeId()
        );
        insert infoFinanceiraConta;

        Product2 testProduct = new Product2(Name = 'EURO SECURITIZADORA');
        insert testProduct;

        Product2 testProdutoFinanceiro = new Product2(Name = 'FINANCIAMENTO DE IMOVEIS');
        insert testProdutoFinanceiro;

        PricebookEntry pbEntry = new PricebookEntry(
            IsActive = true,
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 1000
        );
        insert pbEntry;

        PricebookEntry pbEntry2 = new PricebookEntry(
            IsActive = true,
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProdutoFinanceiro.Id,
            UnitPrice = 1000
        );
        insert pbEntry2;

        Filial__c filial = new Filial__c(
            CodigoEmpresa__c = '01',
            CodigoFilial__c = '01001' 
        );
        insert filial;

        List<CodigoProtheus__c> lstCodigosProtheus = new List<CodigoProtheus__c>();

        CodigoProtheus__c codigoProtheusCliente = new CodigoProtheus__c(
            Ativo__c = true,
            Codigo__c = 'TESTE 01',
            Conta__c = testAccount.Id,
            Filial__c = filial.Id,
            IdExterno__c = filial.CodigoFilial__c + '|' + 'TESTE 01',
            RecordTypeId = Schema.SObjectType.CodigoProtheus__c.getRecordTypeInfosByDeveloperName().get('Conta').getRecordTypeId()
        );
        lstCodigosProtheus.add(codigoProtheusCliente);

        CodigoProtheus__c codigoProtheusProduto = new CodigoProtheus__c(
            Ativo__c = true,
            Codigo__c = 'TESTE 02',
            Filial__c = filial.Id,
            IdExterno__c = filial.CodigoFilial__c + '|' + 'TESTE 02',
            RecordTypeId = Schema.SObjectType.CodigoProtheus__c.getRecordTypeInfosByDeveloperName().get('Produtos').getRecordTypeId(),
            Produto__c = testProduct.Id
        );
        lstCodigosProtheus.add(codigoProtheusProduto);

        CodigoProtheus__c codigoProtheusRepresentante = new CodigoProtheus__c(
            Ativo__c = true,
            Codigo__c = 'TESTE 03',
            Filial__c = filial.Id,
            IdExterno__c = filial.CodigoFilial__c + '|' + 'TESTE 03',
            RecordTypeId = Schema.SObjectType.CodigoProtheus__c.getRecordTypeInfosByDeveloperName().get('Representante').getRecordTypeId(),
            Representante__c = UserInfo.getUserId()
        );
        lstCodigosProtheus.add(codigoProtheusRepresentante);

        CodigoProtheus__c codigoProtheusProdutoFinanceiro = new CodigoProtheus__c(
            Ativo__c = true,
            Codigo__c = 'TESTE 04',
            Filial__c = filial.Id,
            IdExterno__c = filial.CodigoFilial__c + '|' + 'TESTE 04',
            RecordTypeId = Schema.SObjectType.CodigoProtheus__c.getRecordTypeInfosByDeveloperName().get('Produtos').getRecordTypeId(),
            Produto__c = testProdutoFinanceiro.Id
        );
        lstCodigosProtheus.add(codigoProtheusProdutoFinanceiro);

        CodigoProtheus__c codigoProtheusParceiro = new CodigoProtheus__c(
            Ativo__c = true,
            Codigo__c = 'TESTE 05',
            Conta__c = bancoParceiro.Id,
            Filial__c = filial.Id,
            IdExterno__c = filial.CodigoFilial__c + '|' + 'TESTE 05',
            RecordTypeId = Schema.SObjectType.CodigoProtheus__c.getRecordTypeInfosByDeveloperName().get('Parceiro').getRecordTypeId()
        );
        lstCodigosProtheus.add(codigoProtheusParceiro);

        insert lstCodigosProtheus;
    }

    @IsTest
    static void integrarOportunidadeProtheusInvestSucesso(){
        Account conta = [SELECT Id FROM Account WHERE Documento__c = '441.287.810-45' LIMIT 1];
        InformcoesFinanceirasConta__c infoFinanceiraConta = [SELECT Id FROM InformcoesFinanceirasConta__c WHERE ContaRelacionada__c =: conta.Id LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 WHERE Name = 'EURO SECURITIZADORA' LIMIT 1];

        Opportunity oportunidade = new Opportunity(
            Name = 'Oportunidade Investimentos', 
            StageName = 'Taxa/Prazo Aprovada',
            CloseDate = System.today(),
            DataAporte__c = System.today(),
            DataFimContrato__c = System.today().addMonths(12),
            AccountId = conta.Id,
            Periodo__c = 'Mensal',
            PrazoOperacao__c = 12,
            Produto__c = produto.Id,
            Quantidade__c = 150,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Investimentos').getRecordTypeId(),
            Taxa__c = 1.2,
            Type = 'Novo aporte',
            ValorOportunidade__c = 150000
        );
        insert oportunidade;

        InformacoesFinanceirasOportunidade__c infoFinanceiraOportunidade = new InformacoesFinanceirasOportunidade__c(
            InformacesFinanceirasConta__c = infoFinanceiraConta.Id,
            Oportunidade__c = oportunidade.Id,
            PercentualInvestimento__c = 20,
            RecordTypeId = Schema.SObjectType.InformacoesFinanceirasOportunidade__c.getRecordTypeInfosByDeveloperName().get('DadosBancarios').getRecordTypeId(),
            TipoConta__c = 'Conta corrente',
            TipoInformacao__c = 'Dado bancário',
            TipoTransacao__c = 'I/O'
        );
        insert infoFinanceiraOportunidade;

        Contrato__c contrato = new Contrato__c(
            Conta__c = conta.Id,
            Oportunidade__c = oportunidade.Id,
            RecordTypeId = Schema.SObjectType.Contrato__c.getRecordTypeInfosByDeveloperName().get('Investimentos').getRecordTypeId()
        );
        insert contrato;

        Test.startTest();
            oportunidade.StageName = 'Contrato assinado';
            update oportunidade;
        Test.stopTest();

        Bdrs.Callout.setTestResponse('{"PROPOSALCODE":"000100", "PROPOSALREVISION": "01", "msg":"Proposta Incluída com Sucesso!"}', 201, 'Created'); 
        String oportunidadeId = JSON.serialize(oportunidade.Id);
        String processResult = new ProtheusOportunidadeGanhaWorkRun().process(oportunidadeId);
        String processResponse = new ProtheusOportunidadeGanhaWorkRun().processResponse(oportunidadeId, processResult);

        Contrato__c contratoAtualizado = [SELECT Id, PropostaProtheus__c FROM Contrato__c WHERE Id =: contrato.Id LIMIT 1];
        Opportunity oportunidadeAtualizada = [SELECT Id, PropostaProtheus__c, StatusProtheus__c FROM Opportunity WHERE Id =: oportunidade.Id LIMIT 1];

        Assert.areEqual('000100', contratoAtualizado.PropostaProtheus__c);
        Assert.areEqual('000100', oportunidadeAtualizada.PropostaProtheus__c);
        Assert.areEqual('Integrada', oportunidadeAtualizada.StatusProtheus__c);
    }

    @IsTest
    static void integrarOportunidadeProtheusInvestErro(){
        Account conta = [SELECT Id FROM Account WHERE Documento__c = '441.287.810-45' LIMIT 1];
        InformcoesFinanceirasConta__c infoFinanceiraConta = [SELECT Id FROM InformcoesFinanceirasConta__c WHERE ContaRelacionada__c =: conta.Id LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 WHERE Name = 'EURO SECURITIZADORA' LIMIT 1];

        Opportunity oportunidade = new Opportunity(
            Name = 'Oportunidade Investimentos Erro', 
            StageName = 'Taxa/Prazo Aprovada',
            CloseDate = System.today(),
            DataAporte__c = System.today(),
            DataFimContrato__c = System.today().addMonths(12),
            AccountId = conta.Id,
            Periodo__c = 'Mensal',
            PrazoOperacao__c = 12,
            Produto__c = produto.Id,
            Quantidade__c = 150,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Investimentos').getRecordTypeId(),
            Taxa__c = 1.4,
            Type = 'Novo aporte',
            ValorOportunidade__c = 150000
        );
        insert oportunidade;

        InformacoesFinanceirasOportunidade__c infoFinanceiraOportunidade = new InformacoesFinanceirasOportunidade__c(
            InformacesFinanceirasConta__c = infoFinanceiraConta.Id,
            Oportunidade__c = oportunidade.Id,
            PercentualInvestimento__c = 20,
            RecordTypeId = Schema.SObjectType.InformacoesFinanceirasOportunidade__c.getRecordTypeInfosByDeveloperName().get('DadosBancarios').getRecordTypeId(),
            TipoConta__c = 'Conta poupança',
            TipoInformacao__c = 'Dado bancário',
            TipoTransacao__c = 'I/O'
        );
        insert infoFinanceiraOportunidade;

        Contrato__c contrato = new Contrato__c(
            Conta__c = conta.Id,
            Oportunidade__c = oportunidade.Id,
            RecordTypeId = Schema.SObjectType.Contrato__c.getRecordTypeInfosByDeveloperName().get('Investimentos').getRecordTypeId()
        );
        insert contrato;

        Test.startTest();
            oportunidade.StageName = 'Contrato assinado';
            update oportunidade;
        Test.stopTest();

        Bdrs.Callout.setTestResponse('{"errorCode":400,"errorMessage":"Erro --> Id do formulario de erro: [AD1MASTER] Id do campo de erro: [AD1_PROVEN] Id do erro: [REGNOIS ] Mensagem do erro: [ N�o existe registro relacionado a chave informada no alias AC1, ordena��o 1.]"}', 201, 'Created'); 

        try{
            String oportunidadeId = JSON.serialize(oportunidade.Id);
            String processResult = new ProtheusOportunidadeGanhaWorkRun().process(oportunidadeId);
            String processResponse = new ProtheusOportunidadeGanhaWorkRun().processResponse(oportunidadeId, processResult);
        } catch(Exception ex){
            Contrato__c contratoAtualizado = [SELECT Id, PropostaProtheus__c FROM Contrato__c WHERE Id =: contrato.Id LIMIT 1];
            Opportunity oportunidadeAtualizada = [SELECT Id, PropostaProtheus__c, StatusProtheus__c FROM Opportunity WHERE Id =: oportunidade.Id LIMIT 1];
    
            Assert.isTrue(ex.getMessage().contains('Id do formulario de erro:'));
            Assert.isNull(contratoAtualizado.PropostaProtheus__c);
            Assert.isNull(oportunidadeAtualizada.PropostaProtheus__c);
            Assert.areEqual('Em processamento', oportunidadeAtualizada.StatusProtheus__c);
        }
    }

    @IsTest
    static void integrarOportunidadeProtheusPrdFinanceirosSucesso(){
        Account bancoParceiro = [SELECT Id FROM Account WHERE Documento__c = '92.523.470/0001-58' LIMIT 1];
        Account conta = [SELECT Id FROM Account WHERE Documento__c = '441.287.810-45' LIMIT 1];
        InformcoesFinanceirasConta__c infoFinanceiraConta = [SELECT Id FROM InformcoesFinanceirasConta__c WHERE ContaRelacionada__c =: conta.Id LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 WHERE Name = 'FINANCIAMENTO DE IMOVEIS' LIMIT 1];

        Opportunity oportunidade = new Opportunity(
            Name = 'Oportunidade Prod Financeiros',
            Banco__c = bancoParceiro.Id,
            StageName = 'Aprovado',
            CloseDate = System.today(),
            AccountId = conta.Id,
            PrazoOperacao__c = 12,
            Produto__c = produto.Id,
            Quantidade__c = 150,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ProdutosFinanceiros').getRecordTypeId(),
            SituacaoImovel__c = 'Novo',
            Subtipo__c = 'Residencial',
            ValorBem__c = 100000,
            ValorFinanciamento__c = 80000
        );
        insert oportunidade;

        Quote cotacao = new Quote(
            BancoParceiro__c = bancoParceiro.Id,
            DataSimulacao__c = System.today(),
            Entrada__c = 20000,
            FGTS__c = 'Não',
            FormaPagamento__c = 'Boleto',
            IncluirITBIRegistro__c = 'Não',
            LTV__c = 80000,
            Name = 'Oportunidade Prod Financeiros',
            NProposta__c = '302030',
            OpportunityId = oportunidade.Id,
            SistemaAmortizacao__c = 'SAC',
            Status = 'Contratado',
            ValorAprovado__c = 80000,
            ValorBem__c = 100000
        );
        insert cotacao;

        InformacoesFinanceirasOportunidade__c infoFinanceiraOportunidade = new InformacoesFinanceirasOportunidade__c(
            InformacesFinanceirasConta__c = infoFinanceiraConta.Id,
            Oportunidade__c = oportunidade.Id,
            PercentualInvestimento__c = 20,
            RecordTypeId = Schema.SObjectType.InformacoesFinanceirasOportunidade__c.getRecordTypeInfosByDeveloperName().get('DadosBancarios').getRecordTypeId(),
            TipoConta__c = 'Conta corrente',
            TipoInformacao__c = 'Dado bancário',
            TipoTransacao__c = 'I/O'
        );
        insert infoFinanceiraOportunidade;

        Test.startTest();
            oportunidade.StageName = 'Contrato registrado';
            update oportunidade;
        Test.stopTest();

        Bdrs.Callout.setTestResponse('{"PROPOSALCODE":"000101", "PROPOSALREVISION": "01", "msg":"Proposta Incluída com Sucesso!"}', 201, 'Created'); 
        String oportunidadeId = JSON.serialize(oportunidade.Id);
        String processResult = new ProtheusOportunidadeGanhaWorkRun().process(oportunidadeId);
        String processResponse = new ProtheusOportunidadeGanhaWorkRun().processResponse(oportunidadeId, processResult);

        Opportunity oportunidadeAtualizada = [SELECT Id, PropostaProtheus__c, StatusProtheus__c FROM Opportunity WHERE Id =: oportunidade.Id LIMIT 1];

        Assert.areEqual('000101', oportunidadeAtualizada.PropostaProtheus__c);
        Assert.areEqual('Integrada', oportunidadeAtualizada.StatusProtheus__c);
    }

    @IsTest
    static void integrarOportunidadeProtheusPrdFinanceirosClienteInexistente(){
        Account testAccount = new Account(
            FirstName = 'Test',
            LastName = 'Pessoa Física Dois',
            BairroCobranca__c = 'Bairro Y',
            BillingCity = 'São Paulo',
            BillingCountry = 'Brasil',
            BillingPostalCode = '12345-678',
            BillingState = 'SP',
            BillingStreet = 'Avenida Y',
            Documento__c = '122.222.640-57', 
            NumeroCobranca__c = '100',
            TipoPessoa__c = 'Pessoa Física',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaPessoal').getRecordTypeId()
        );
        insert testAccount;

        Account bancoParceiro = [SELECT Id FROM Account WHERE Documento__c = '92.523.470/0001-58' LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 WHERE Name = 'FINANCIAMENTO DE IMOVEIS' LIMIT 1];

        Opportunity oportunidade = new Opportunity(
            Name = 'Oportunidade Prod Financeiros 2',
            Banco__c = bancoParceiro.Id,
            StageName = 'Aprovado',
            CloseDate = System.today(),
            AccountId = testAccount.Id,
            PrazoOperacao__c = 12,
            Produto__c = produto.Id,
            Quantidade__c = 150,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ProdutosFinanceiros').getRecordTypeId(),
            SituacaoImovel__c = 'Novo',
            Subtipo__c = 'Residencial',
            ValorBem__c = 100000,
            ValorFinanciamento__c = 80000
        );
        insert oportunidade;

        Quote cotacao = new Quote(
            BancoParceiro__c = bancoParceiro.Id,
            DataSimulacao__c = System.today(),
            Entrada__c = 20000,
            FGTS__c = 'Não',
            FormaPagamento__c = 'Boleto',
            IncluirITBIRegistro__c = 'Não',
            LTV__c = 80000,
            Name = 'Oportunidade Prod Financeiros 2',
            NProposta__c = '302030',
            OpportunityId = oportunidade.Id,
            SistemaAmortizacao__c = 'SAC',
            Status = 'Contratado',
            ValorAprovado__c = 80000,
            ValorBem__c = 100000
        );
        insert cotacao;

        Test.startTest();
            oportunidade.StageName = 'Contrato registrado';
            update oportunidade;
        Test.stopTest();

        String oportunidadeId = JSON.serialize(oportunidade.Id);
        String processResult = new ProtheusOportunidadeGanhaWorkRun().process(oportunidadeId);
        String processResponse = new ProtheusOportunidadeGanhaWorkRun().processResponse(oportunidadeId, processResult);

        Opportunity oportunidadeAtualizada = [SELECT Id, PropostaProtheus__c, StatusProtheus__c FROM Opportunity WHERE Id =: oportunidade.Id LIMIT 1];

        Assert.areEqual(null, oportunidadeAtualizada.PropostaProtheus__c);
        Assert.areEqual('Em reprocessamento', oportunidadeAtualizada.StatusProtheus__c);

        Account conta = [SELECT Id, Documento__c, RecordType.Name, Name, FirstName, BillingCountry, BillingState, BillingCity, BillingStreet, BillingPostalCode, BairroCobranca__c, NumeroCobranca__c, ComplementoCobranca__c FROM Account WHERE Id =: testAccount.Id];
        CodigoProtheus__c codigoProtheusRepresentante = new FormalizacaoRepository().buscarCodigoProtheusFilialRepresentanteId('01001', UserInfo.getUserId());

        SendClienteWorkRunSchema.Request sendClienteWorkRunObj = new SendClienteWorkRunSchema.Request();
        sendClienteWorkRunObj.clienteRequest = ClienteFactory.buildClienteRequest(conta, codigoProtheusRepresentante);
        sendClienteWorkRunObj.codigoProtheus = ClienteFactory.buildCodigoProtheus(conta, codigoProtheusRepresentante);
        sendClienteWorkRunObj.oportunidade = oportunidade;

        Bdrs.Callout.setTestResponse('{"sucesso":true,"response":"{\"companyId\":\"01\",\"branchId\":\"02 \",\"companyInternalId\":\"0102 98469721054 \",\"code\":\"98469721\",\"storeId\":\"054 \",\"shortName\":\"ÚRSULA \",\"name\":\"ÚRSULA OPERAÇÕES \",\"type\":1,\"entityType\":\"F\",\"registerSituation\":\"2\",\"strategicCustomerType\":\"F\",\"marketsegment\":{\"marketSegmentCode\":\" \",\"marketSegmentInternalId\":\"\",\"marketSegmentDescription\":\"\"},\"GovernmentalInformation\":[{\"id\":\" \",\"name\":\"INSCRICAO ESTADUAL\",\"scope\":\"INSCRICAO ESTADUAL\",\"expireOn\":\"INSCRICAO ESTADUAL\",\"issueOn\":\"INSCRICAO ESTADUAL\"},{\"id\":\" \",\"name\":\"INSCRICAO MUNICIPAL\",\"scope\":\"INSCRICAO MUNICIPAL\",\"expireOn\":\"INSCRICAO MUNICIPAL\",\"issueOn\":\"INSCRICAO MUNICIPAL\"},{\"id\":\"98469721054 \",\"name\":\"CPF|CNPJ\",\"scope\":\"CPF|CNPJ\",\"expireOn\":\"CPF|CNPJ\",\"issueOn\":\"CPF|CNPJ\"},{\"id\":\" \",\"name\":\"SUFRAMA\",\"scope\":\"SUFRAMA\",\"expireOn\":\"SUFRAMA\",\"issueOn\":\"SUFRAMA\"},{\"id\":\" \",\"name\":\"PASSAPORTE\",\"scope\":\"PASSAPORTE\",\"expireOn\":\"PASSAPORTE\",\"issueOn\":\"PASSAPORTE\"},{\"id\":\" \",\"name\":\"RG\",\"scope\":\"RG\",\"expireOn\":\"RG\",\"issueOn\":\"RG\"}],\"address\":{\"address\":\"AVENIDA LINS DE VASCONCELOS 200 \",\"number\":\"\",\"complement\":\" \",\"district\":\" \",\"zipCode\":\"01538000\",\"region\":\"\",\"poBox\":\"\",\"mainAddress\":true,\"shippingAddress\":false,\"billingAddress\":false,\"city\":{\"cityCode\":\" \",\"cityInternalId\":\" \",\"cityDescription\":\"SÃO PAULO \"},\"state\":{\"stateId\":\"SP\",\"stateInternalId\":\"SP\",\"stateDescription\":\"\"},\"country\":{\"countryCode\":\"105\",\"countryInternalId\":\"105\",\"countryDescription\":\"\"}},\"shippingAddress\":{\"address\":\" \",\"number\":\"\",\"complement\":\"\",\"district\":\" \",\"zipCode\":\" \",\"region\":\"\",\"poBox\":\"\",\"mainAddress\":false,\"shippingAddress\":true,\"billingAddress\":false,\"city\":{\"cityCode\":\"\",\"cityInternalId\":\"\",\"cityDescription\":\" \"},\"state\":{\"stateId\":\" \",\"stateInternalId\":\" \",\"stateDescription\":\"\"},\"country\":{\"countryCode\":\"\",\"countryInternalId\":\"\",\"countryDescription\":\"\"}},\"listOfCommunicationInformation\":[{\"type\":\"\",\"phoneNumber\":\" \",\"phoneExtension\":\"\",\"faxNumber\":\" \",\"faxNumberExtension\":\"\",\"homePage\":\" \",\"email\":\" \",\"diallingCode\":\" \",\"internationalDiallingCode\":\" \"}],\"listOfContacts\":[{\"ContactInformationCode\":\"\",\"ContactInformationInternalId\":\"\",\"ContactInformationTitle\":\"\",\"ContactInformationName\":\" \",\"ContactInformationDepartment\":\"\",\"CommunicationInformation\":{\"type\":\"\",\"phoneNumber\":\"\",\"phoneExtension\":\"\",\"faxNumber\":\"\",\"faxNumberExtension\":\"\",\"homePage\":\"\",\"email\":\"\",\"diallingCode\":\"\",\"internationalDiallingCode\":\"\"},\"ContactInformationAddress\":{\"address\":\"\",\"number\":\"\",\"complement\":\"\",\"district\":\"\",\"zipCode\":\"\",\"region\":\"\",\"poBox\":\"\",\"mainAddress\":false,\"shippingAddress\":false,\"billingAddress\":false,\"city\":{\"cityCode\":\"\",\"cityInternalId\":\"\",\"cityDescription\":\"\"},\"state\":{\"stateId\":\"\",\"stateInternalId\":\"\",\"stateDescription\":\"\"},\"country\":{\"countryCode\":\"\",\"countryInternalId\":\"\",\"countryDescription\":\"\"}}}],\"listOfBankingInformation\":[{\"bankCode\":\"\",\"bankInternalId\":\"\",\"bankName\":\"\",\"branchCode\":\"\",\"branchKey\":\"\",\"checkingAccountNumber\":\"\",\"checkingAccountNumberKey\":\"\",\"checkingAccountType\":\"\",\"mainAccount\":\"\",\"currencyAccount\":\"\"}],\"creditInformation\":{\"creditIndicator\":\"\",\"creditEvaluation\":\"\",\"shipmentCreditEvaluation\":\"\",\"creditLimit\":0,\"creditLimitCurrency\":2,\"creditLimitDate\":\" / / \",\"additionalCreditLimit\":0,\"additionalCreditLimitCurrency\":\"\",\"additionalCreditLimitDate\":\"\",\"latePeriods\":\"\",\"balanceOfCredit\":\"\"},\"vendorInformation\":{\"vendorClassification\":\"\",\"vendorTypeCode\":\" \",\"vendorTypeInternalId\":\"0102 \",\"vendorTypeDescription\":\"\"},\"fiscalInformation\":{\"Category\":\"\",\"IsRetentionAgent\":\"\",\"taxPayer\":{\"taxName\":\"\",\"isPayer\":\"\",\"mode\":\"\"}},\"billingInformation\":{\"billingCustomerCode\":\"\",\"billingCustomerInternalId\":\"\",\"address\":{\"address\":\" \",\"number\":\"\",\"complement\":\"\",\"district\":\" \",\"zipCode\":\" \",\"region\":\"\",\"poBox\":\"\",\"mainAddress\":false,\"shippingAddress\":false,\"billingAddress\":true,\"city\":{\"cityCode\":\" \",\"cityInternalId\":\" \",\"cityDescription\":\"\"},\"state\":{\"stateId\":\" \",\"stateInternalId\":\" \",\"stateDescription\":\"\"},\"country\":{\"countryCode\":\"\",\"countryInternalId\":\"\",\"countryDescription\":\"\"}}}}"}', 201, 'Created'); 
        String sendClienteWorkRunStr = JSON.serialize(sendClienteWorkRunObj);
        String processResultCliente = new SendClienteWorkRun().process(sendClienteWorkRunStr);
        String processResponseCliente = new SendClienteWorkRun().processResponse(sendClienteWorkRunStr, processResult);

        CodigoProtheus__c codigoProtheusCliente = [SELECT Id, Ativo__c FROM CodigoProtheus__c WHERE RecordType.Name = 'Conta' AND Conta__c =: testAccount.Id LIMIT 1];
        oportunidadeAtualizada = [SELECT Id, PropostaProtheus__c, StatusProtheus__c FROM Opportunity WHERE Id =: oportunidade.Id LIMIT 1];

        Assert.isTrue(codigoProtheusCliente.Ativo__c);
        Assert.areEqual(null, oportunidadeAtualizada.PropostaProtheus__c);
    }

    @IsTest
    static void integrarOportunidadeProtheusPrdFinanceirosParceiroInexistente(){
        Account bancoParceiro = new Account(
            BillingStreet = 'AV PAULISTA 2100',
            Documento__c = '10.602.088/0001-75',
            Name = 'BANCO PARCEIRO 2',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Empresa').getRecordTypeId(),
            StatusConta__c = 'Ativo',
            TipoPessoa__c = 'Pessoa jurídica'
        );
        insert bancoParceiro;

        Account conta = [SELECT Id FROM Account WHERE Documento__c = '441.287.810-45' LIMIT 1];
        InformcoesFinanceirasConta__c infoFinanceiraConta = [SELECT Id FROM InformcoesFinanceirasConta__c WHERE ContaRelacionada__c =: conta.Id LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 WHERE Name = 'FINANCIAMENTO DE IMOVEIS' LIMIT 1];

        Opportunity oportunidade = new Opportunity(
            Name = 'Oportunidade Prod Financeiros',
            Banco__c = bancoParceiro.Id,
            StageName = 'Aprovado',
            CloseDate = System.today(),
            AccountId = conta.Id,
            PrazoOperacao__c = 12,
            Produto__c = produto.Id,
            Quantidade__c = 150,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ProdutosFinanceiros').getRecordTypeId(),
            SituacaoImovel__c = 'Novo',
            Subtipo__c = 'Residencial',
            ValorBem__c = 100000,
            ValorFinanciamento__c = 80000
        );
        insert oportunidade;

        Quote cotacao = new Quote(
            BancoParceiro__c = bancoParceiro.Id,
            DataSimulacao__c = System.today(),
            Entrada__c = 20000,
            FGTS__c = 'Não',
            FormaPagamento__c = 'Boleto',
            IncluirITBIRegistro__c = 'Não',
            LTV__c = 80000,
            Name = 'Oportunidade Prod Financeiros',
            NProposta__c = '302030',
            OpportunityId = oportunidade.Id,
            SistemaAmortizacao__c = 'SAC',
            Status = 'Contratado',
            ValorAprovado__c = 80000,
            ValorBem__c = 100000
        );
        insert cotacao;

        InformacoesFinanceirasOportunidade__c infoFinanceiraOportunidade = new InformacoesFinanceirasOportunidade__c(
            InformacesFinanceirasConta__c = infoFinanceiraConta.Id,
            Oportunidade__c = oportunidade.Id,
            PercentualInvestimento__c = 20,
            RecordTypeId = Schema.SObjectType.InformacoesFinanceirasOportunidade__c.getRecordTypeInfosByDeveloperName().get('DadosBancarios').getRecordTypeId(),
            TipoConta__c = 'Conta corrente',
            TipoInformacao__c = 'Dado bancário',
            TipoTransacao__c = 'I/O'
        );
        insert infoFinanceiraOportunidade;

        TimeRelacionamento__c parceiro = new TimeRelacionamento__c(
            Conta__c = bancoParceiro.Id,
            Oportunidade__c = oportunidade.Id,
            RecordTypeId = Schema.SObjectType.TimeRelacionamento__c.getRecordTypeInfosByDeveloperName().get('Parceiro').getRecordTypeId()
        );
        insert parceiro;

        Test.startTest();
            oportunidade.StageName = 'Contrato registrado';
            update oportunidade;
        Test.stopTest();

        String oportunidadeId = JSON.serialize(oportunidade.Id);
        String processResult = new ProtheusOportunidadeGanhaWorkRun().process(oportunidadeId);
        String processResponse = new ProtheusOportunidadeGanhaWorkRun().processResponse(oportunidadeId, processResult);

        Opportunity oportunidadeAtualizada = [SELECT Id, PropostaProtheus__c, StatusProtheus__c FROM Opportunity WHERE Id =: oportunidade.Id LIMIT 1];

        Assert.areEqual(null, oportunidadeAtualizada.PropostaProtheus__c);
        Assert.areEqual('Em reprocessamento', oportunidadeAtualizada.StatusProtheus__c);

        bancoParceiro = [SELECT Id, Documento__c, Name, FirstName, BairroCobranca__c, BillingAddress, ComplementoCobranca__c, NumeroCobranca__c, OwnerId, StatusConta__c FROM Account WHERE Id =: bancoParceiro.Id];
        Filial__c filial = [SELECT Id, CodigoEmpresa__c, CodigoFilial__c FROM Filial__c WHERE CodigoFilial__c = '01001' LIMIT 1];

        ParceiroSchema.ParceiroWorkRunRequest parceiroSchema = new ParceiroSchema.ParceiroWorkRunRequest();
        parceiroSchema.codigoProtheus = new parceiroFactory().buildCodigoProtheus(bancoParceiro, filial);
        parceiroSchema.parceiroRequest = new parceiroFactory().buildParceiroRequest(bancoParceiro, filial);
        parceiroSchema.oportunidade = oportunidade;
    
        Bdrs.Callout.setTestResponse('{"sucesso":true,"response":"{\"companyId\":\"01\",\"branchID\":\"01001\",\"CompanyInternalId\":\"0101001\",\"code\":\"655498\",\"internalId\":\"01001655498\",\"name\":\"BANCO PARCEIRO \",\"shortName\":\"BANCO PARCEIRO \",\"active\":true,\"address\":{\"address\":\"null, null \",\"complement\":\"\",\"number\":\"\",\"district\":\" \",\"region\":\"\",\"zipCode\":\" \",\"poBox\":\"\",\"mainAddress\":true,\"shippingAddress\":true,\"billingAddress\":true,\"country\":{\"countryId\":\"105\",\"countryInternalId\":\"105\",\"countryDescription\":\"\"},\"state\":{\"stateId\":\" \",\"stateInternalId\":\" \",\"stateDescription\":\"\"},\"city\":{\"cityId\":\" \",\"cityInternalId\":\" \",\"cityDescription\":\"\"}},\"InfoCom\":{\"customerVendorInternalId\":\" \",\"salesChargeInterface\":\" \",\"indirectSeller\":\" \",\"indirectSellerInternalId\":\"\"}}"}', 201, 'Created'); 
        String parceiroSchemaStr = JSON.serialize(parceiroSchema);
        String processResultParceiro = new SendParceiroWorkRun().process(parceiroSchemaStr);
        String processResponseParceiro = new SendParceiroWorkRun().processResponse(parceiroSchemaStr, processResultParceiro);

        CodigoProtheus__c codigoProtheusParceiro = [SELECT Id, Ativo__c FROM CodigoProtheus__c WHERE RecordType.Name = 'Parceiro' AND Conta__c =: bancoParceiro.Id LIMIT 1];
        oportunidadeAtualizada = [SELECT Id, PropostaProtheus__c, StatusProtheus__c FROM Opportunity WHERE Id =: oportunidade.Id LIMIT 1];

        Assert.isTrue(codigoProtheusParceiro.Ativo__c);
        Assert.areEqual(null, oportunidadeAtualizada.PropostaProtheus__c);
    }*/

}