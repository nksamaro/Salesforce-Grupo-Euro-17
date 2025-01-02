@IsTest
private class IntegracaoClienteParceiroInvocableTest {

    @TestSetup
    static void makeData(){
        // Setup test data
        Account testAccount = new Account(
            FirstName = 'Test',
            LastName = 'Pessoa Física',
            Documento__c = '441.287.810-45', 
            TipoPessoa__c = 'Pessoa Física',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaPessoal').getRecordTypeId()
        );
        insert testAccount;

        Product2 testProduct = new Product2(Name = 'Euro Prime Securitizadora');
        insert testProduct;

        PricebookEntry pbEntry = new PricebookEntry(
            IsActive = true,
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 1000
        );
        insert pbEntry;

        Filial__c filial = new Filial__c(
            CodigoEmpresa__c = '01',
            CodigoFilial__c = '01001' 
        );
        insert filial;

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Grupo Euro 17'];

        User testOwner = new User(
            FirstName = 'Test',
            LastName = 'Account',
            UserName = 'username@grupoeuro17.dev',
            Email = 'username@grupoeuro17.com',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            Alias = 'username',
            ProfileId = testProfile.Id,
            Documento__c = '94327064009'
        );
        insert testOwner;

        CodigoProtheus__c codigoProtheus = new CodigoProtheus__c(
            Ativo__c = true,
            Codigo__c = 'TESTE 01',
            Filial__c = filial.Id,
            IdExterno__c = filial.CodigoFilial__c + '|' + 'TESTE 01',
            RecordTypeId = Schema.SObjectType.CodigoProtheus__c.getRecordTypeInfosByDeveloperName().get('Produtos').getRecordTypeId(),
            Produto__c = testProduct.Id
        );
        insert codigoProtheus;
    }

    @IsTest
    static void testIntegrarParceiroProtheus(){
        Account testAccount = [SELECT Id FROM Account WHERE Documento__c = '441.287.810-45' LIMIT 1];
        
        IntegracaoClienteParceiroInvocable.Request requestObj = new IntegracaoClienteParceiroInvocable.Request();
        requestObj.idConta = testAccount.Id;
        
        Test.startTest();
        IntegracaoClienteParceiroInvocable.integrarClienteParceiroProtheus(new List<IntegracaoClienteParceiroInvocable.Request>{requestObj});
        Bdrs.Callout.setTestResponse('{"access_token": "tokenstring"}', 201, 'Created'); 
        Bdrs.WorkControl.processWorks();
        Test.stopTest();
        
        List<CodigoProtheus__c> createdCodes = [SELECT Id, Codigo__c, RecordType.Name FROM CodigoProtheus__c WHERE Conta__c =: testAccount.Id];
        Assert.areEqual(1, createdCodes.size(), 'Expected a new WorkControl__c record');
        Assert.areEqual('441287', createdCodes[0].Codigo__c);
        Assert.areEqual('Parceiro', createdCodes[0].RecordType.Name);
    }

}