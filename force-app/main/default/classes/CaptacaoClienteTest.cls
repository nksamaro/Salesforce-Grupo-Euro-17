@IsTest
private class CaptacaoClienteTest {

    @TestSetup
    static void makeData(){
        Id dadoBancarioRecTypeId = Schema.SObjectType.InformcoesFinanceirasConta__c.getRecordTypeInfosByDeveloperName().get('DadoBancario').getRecordTypeId();
        List<Account> listContas = new List<Account>();
        List<InformcoesFinanceirasConta__c> listInfoFinanceirasConta = new List<InformcoesFinanceirasConta__c>();
        
        Account account1 = new Account(Name = 'Conta 1', Documento__c = '24.080.114/0001-57');
        listContas.add(account1);

        Account account2 = new Account(Name = 'Conta 2', Documento__c = '933.458.940-09');
        listContas.add(account2);

        insert listContas;

        List<Account> listContasInseridas = [SELECT Id FROM Account ORDER BY Documento__c ASC];

        for(Integer i = 0; i < listContasInseridas.size(); i++){
            InformcoesFinanceirasConta__c infoFinanceira = new InformcoesFinanceirasConta__c(
                ContaRelacionada__c = listContasInseridas[i].Id,
                InstituicaoFinaneira__c = '001',
                Agencia__c = '000' + (i + 1),
                Conta__c = '3232' + (i + 1),
                DV__c = String.valueOf(i + 1),
                RecordTypeId = dadoBancarioRecTypeId
            );
            listInfoFinanceirasConta.add(infoFinanceira);
        }

        insert listInfoFinanceirasConta;

        Lead lead = new Lead(FirstName = 'Teste', LastName = 'Lead', Documento__c = '69741379072', LeadSource = 'Site Euro Securitizadora');
        insert lead;

        DadoBancario__c dadoBancario = new DadoBancario__c(Lead__c = lead.Id, InstituicaoFinanceira__c = '001', Agencia__c = '0001', Conta__c = '50500', DV__c = '1');
        insert dadoBancario;
    }

    @IsTest
    static void testVerificarContaExistente() {
        String mensagemErro = '';
        Account account1 = new Account(Name = 'Conta 1', Documento__c = '24.080.114/0001-57');
        Account account2 = new Account(Name = 'Conta 2', Documento__c = '933.458.940-09');

        try {
            //Teste criação de conta com o mesmo documento
            insert account1;
            insert account2;
            
        } catch (Exception ex) {
            mensagemErro = ex.getMessage();
        }

        Assert.isTrue(mensagemErro.contains('Cliente já existente na base'));
    }

    @IsTest
    public static void testFormatarDocumentoLead() {
        List<Lead> testLeads = new List<Lead>();

        Lead lead1 = new Lead();
        lead1.LastName = 'Test';
        lead1.Documento__c = '12345678901234';
        lead1.LeadSource = 'Outra Origem';
        testLeads.add(lead1);

        Lead lead2 = new Lead();
        lead2.LastName = 'Test';
        lead2.Documento__c = '12345678901';
        lead2.LeadSource = 'Site Euro Securitizadora';
        testLeads.add(lead2);

        Lead lead3 = new Lead();
        lead3.LastName = 'Test';
        lead3.Documento__c = '12312312332';
        lead3.LeadSource = 'Site Euro Securitizadora';
        testLeads.add(lead3);
        
        Lead lead4 = new Lead();
        lead4.LastName = 'Test';
        lead4.Documento__c = null;
        testLeads.add(lead4);

        Test.startTest();
        
        CaptacaoClienteService captacaoCliente = new CaptacaoClienteService();
        captacaoCliente.formatarDocumentoLead(testLeads);

        Assert.areEqual('12.345.678/9012-34', testLeads[0].Documento__c);
        Assert.areEqual('123.456.789-01', testLeads[1].Documento__c);
        Assert.areEqual('123.123.123-32', testLeads[2].Documento__c);
        
        Test.stopTest();
    }

    @IsTest
    static void verificarDadosBancariosExistentes(){
        Lead lead = [SELECT Id FROM Lead WHERE Documento__c = '697.413.790-72' LIMIT 1];
        
        DadoBancario__c dadoBancario = new DadoBancario__c(
            Lead__c = lead.Id,
            InstituicaoFinanceira__c = '001',
            Agencia__c = '0001',
            Conta__c = '50500',
            DV__c = '1'
        );

        try{
            insert dadoBancario;
        } catch(Exception ex){
            Assert.isTrue(ex.getMessage().contains('Já existe um registro de Dado bancário para este lead com as mesmas informações de instituição financeira, agência, conta e DV fornecidas.'));
        }
    }

    @IsTest
    static void verificarDadosBancariosMesmaTransacao(){
        Lead lead = [SELECT Id FROM Lead WHERE Documento__c = '697.413.790-72' LIMIT 1];
        List<DadoBancario__c> listDadosBancarios = new List<DadoBancario__c>();

        for(Integer i = 1; i < 3; i++){
            DadoBancario__c dadoBancario = new DadoBancario__c(
                Lead__c = lead.Id,
                InstituicaoFinanceira__c = '001',
                Agencia__c = '0001',
                Conta__c = '50500',
                DV__c = '2'
            );

            listDadosBancarios.add(dadoBancario);
        }

        try{
            insert listDadosBancarios;
        } catch(Exception ex){
            Assert.isTrue(ex.getMessage().contains('Já existe um registro de Dado bancário para este lead com as mesmas informações de instituição financeira, agência, conta e DV fornecidas nesta mesma transação.'));
        }
    }

    @IsTest
    static void verificarInformacoesFinanceirasExistentes(){
        Account conta = [SELECT Id FROM Account WHERE Documento__c = '24.080.114/0001-57' LIMIT 1];
        Id dadoBancarioRecTypeId = Schema.SObjectType.InformcoesFinanceirasConta__c.getRecordTypeInfosByDeveloperName().get('DadoBancario').getRecordTypeId();

        InformcoesFinanceirasConta__c infoFinanceira = new InformcoesFinanceirasConta__c(
            ContaRelacionada__c = conta.Id,
            InstituicaoFinaneira__c = '001',
            Agencia__c = '0001',
            Conta__c = '32321',
            DV__c = '1',
            RecordTypeId = dadoBancarioRecTypeId
        );

        try{
            insert infoFinanceira;
        } catch(Exception ex){
            Assert.isTrue(ex.getMessage().contains('Já existe um registro de Dado bancário para este cliente com as mesmas informações de instituição financeira, agência, conta e DV fornecidas.'));
        }
    }

    @IsTest
    static void verificarInformacoesFinanceirasMesmaTransacao(){
        Account conta = [SELECT Id FROM Account WHERE Documento__c = '933.458.940-09' LIMIT 1];
        Id dadoBancarioRecTypeId = Schema.SObjectType.InformcoesFinanceirasConta__c.getRecordTypeInfosByDeveloperName().get('DadoBancario').getRecordTypeId();
        List<InformcoesFinanceirasConta__c> listInfoFinanceirasConta = new List<InformcoesFinanceirasConta__c>();

        for(Integer i = 1; i < 3; i++){
            InformcoesFinanceirasConta__c infoFinanceira = new InformcoesFinanceirasConta__c(
                ContaRelacionada__c = conta.Id,
                InstituicaoFinaneira__c = '001',
                Agencia__c = '0002',
                Conta__c = '32322',
                DV__c = '3',
                RecordTypeId = dadoBancarioRecTypeId
            );

            listInfoFinanceirasConta.add(infoFinanceira);
        }

        try{
            insert listInfoFinanceirasConta;
        } catch(Exception ex){
            Assert.isTrue(ex.getMessage().contains('Já existe um registro de Dado bancário para este cliente com as mesmas informações de instituição financeira, agência, conta e DV fornecidas nesta mesma transação.'));
        }
    }

}