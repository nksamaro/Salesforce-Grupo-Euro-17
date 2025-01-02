@IsTest
private class SimuladorCreditoTest {

    @TestSetup
    static void makeData(){
        Account conta = new Account(
            Documento__c = '27115620008',
            Email__c = 'conta@teste.com',
            FirstName = 'Conta',
            LastName = 'Teste',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ContaPessoal').getRecordTypeId(),
            TipoPessoa__c = 'Pessoa Física'
        );
        insert conta;

        Lead lead = new Lead(
            Documento__c = '24595241020',
            Email = 'lead@teste.com',
            FirstName = 'Lead',
            LastName = 'Teste',
            LeadSource = 'Site Euro Securitizadora'
        );
        insert lead;
    }

    @IsTest
    static void retornarValoresPicklistSimulacao(){
        Test.startTest();
            List<FormalizacaoSchema.PicklistField> lstPicklistValues = SimuladorCreditoController.retornarValoresPicklistSimulacao();
        Test.stopTest();

        Assert.areEqual(2, lstPicklistValues.size());
    }

    @IsTest
    static void simularParcelasEnvioEmailConta(){
        FormalizacaoSchema.SimularParcelasLwcRequest simulacaoLwcRequest = retornarLwcRequest();
        Account conta = [SELECT Id FROM Account WHERE LastName = 'Teste' LIMIT 1];
        String emailConta = SimuladorCreditoController.retornarEmailContaLead(conta.Id);
        String responseBody = retornarResponseSucesso();
        String simulacaoStringRequest = JSON.serialize(simulacaoLwcRequest);

        List<String> lstEnderecosEmail = new List<String>{emailConta};

        Test.startTest();
            Bdrs.Callout.setTestResponse(responseBody, 200, 'OK'); 
            FormalizacaoSchema.SimularParcelasResponse response = SimuladorCreditoController.calcularSimulacao(simulacaoStringRequest);
            
            String simulacaoStringResponse = JSON.serialize(response);
            EmailTemplate emailTemplate = SimuladorCreditoController.retornarTemplateEmail(simulacaoStringRequest, simulacaoStringResponse);
            SimuladorCreditoController.enviarEmail(new List<String>(), lstEnderecosEmail, emailTemplate.HtmlValue, emailTemplate.Subject);
        Test.stopTest();

        Assert.areEqual(simulacaoLwcRequest.valorSolicitado, response.requested_amount);
        Assert.isTrue(emailTemplate.HtmlValue.contains('Prezado(a)'));
        Assert.isTrue(emailTemplate.Subject.contains('Simulação'));
    }

    @IsTest
    static void simularParcelasEnvioEmailLead(){
        FormalizacaoSchema.SimularParcelasLwcRequest simulacaoLwcRequest = retornarLwcRequest();
        Lead lead = [SELECT Id FROM Lead WHERE LastName = 'Teste' LIMIT 1];
        String emailLead = SimuladorCreditoController.retornarEmailContaLead(lead.Id);
        String responseBody = retornarResponseSucesso();
        String simulacaoStringRequest = JSON.serialize(simulacaoLwcRequest);

        List<String> lstEnderecosEmail = new List<String>{emailLead};

        Test.startTest();
            Bdrs.Callout.setTestResponse(responseBody, 200, 'OK'); 
            FormalizacaoSchema.SimularParcelasResponse response = SimuladorCreditoController.calcularSimulacao(simulacaoStringRequest);
            
            String simulacaoStringResponse = JSON.serialize(response);
            EmailTemplate emailTemplate = SimuladorCreditoController.retornarTemplateEmail(simulacaoStringRequest, simulacaoStringResponse);
            SimuladorCreditoController.enviarEmail(new List<String>(), lstEnderecosEmail, emailTemplate.HtmlValue, emailTemplate.Subject);
        Test.stopTest();

        Assert.areEqual(simulacaoLwcRequest.valorSolicitado, response.requested_amount);
        Assert.isTrue(emailTemplate.HtmlValue.contains('Prezado(a)'));
        Assert.isTrue(emailTemplate.Subject.contains('Simulação'));
    }

    @IsTest
    static void simularParcelasSalvarRegistro(){
        FormalizacaoSchema.SimularParcelasLwcRequest simulacaoLwcRequest = retornarLwcRequest();
        Account conta = [SELECT Id FROM Account WHERE LastName = 'Teste' LIMIT 1];
        String simulacaoStringRequest = JSON.serialize(simulacaoLwcRequest);
        String responseBody = retornarResponseSucesso();

        Test.startTest();
            Bdrs.Callout.setTestResponse(responseBody, 200, 'OK'); 
            FormalizacaoSchema.SimularParcelasResponse response = SimuladorCreditoController.calcularSimulacao(simulacaoStringRequest);
            
            String stringResponse = JSON.serialize(response);
            SimuladorCreditoController.salvarSimulacao(conta.Id, simulacaoStringRequest, stringResponse);
        Test.stopTest();

        SimulacaoCredito__c simulacaoCredito = [SELECT Id, CET__c, Conta__c, SaldoTotal__c, ValorLiberado__c, ValorParcela__c, ValorSolicitado__c FROM SimulacaoCredito__c LIMIT 1];
        List<SimulacaoParcela__c> lstSimulacaoParcela = [SELECT Id, ValorVencimento__c FROM SimulacaoParcela__c WHERE SimulacaoCredito__c =: simulacaoCredito.Id];

        Assert.areEqual(simulacaoCredito.CET__c, response.monthly_effective_interest_rate * 100);
        Assert.areEqual(simulacaoCredito.Conta__c, conta.Id);
        Assert.areEqual(simulacaoCredito.SaldoTotal__c, response.total_amount_owed);
        Assert.areEqual(simulacaoCredito.ValorParcela__c, response.payment_amount);
        Assert.areEqual(simulacaoCredito.ValorSolicitado__c, response.requested_amount);
        Assert.areEqual(5, lstSimulacaoParcela.size());
        Assert.areEqual(simulacaoCredito.ValorParcela__c, lstSimulacaoParcela[0].ValorVencimento__c);
    }

    @IsTest
    static void simularParcelasSalvarRegistroErro(){
        FormalizacaoSchema.SimularParcelasLwcRequest simulacaoLwcRequest = retornarLwcRequest();
        Account conta = [SELECT Id FROM Account WHERE LastName = 'Teste' LIMIT 1];
        String simulacaoStringRequest = JSON.serialize(simulacaoLwcRequest);
        String responseBody = retornarResponseSucesso();

        try{
            Test.startTest();
                Bdrs.Callout.setTestResponse(responseBody, 200, 'OK'); 
                FormalizacaoSchema.SimularParcelasResponse response = SimuladorCreditoController.calcularSimulacao(simulacaoStringRequest);
                
                String stringResponse = JSON.serialize(response);
                simulacaoStringRequest = simulacaoStringRequest.replace('MONTHLY', 'YEARLY');
                SimuladorCreditoController.salvarSimulacao(conta.Id, simulacaoStringRequest, stringResponse);
            Test.stopTest();
        } catch(Exception ex){
            Assert.isTrue(ex.getMessage().contains('Script-thrown exception'));
        }
    }

    @IsTest
    static void simularParcelasErro(){
        FormalizacaoSchema.SimularParcelasLwcRequest simulacaoLwcRequest = retornarLwcRequest();
        simulacaoLwcRequest.valorSolicitado = null;

        String simulacaoStringRequest = JSON.serialize(simulacaoLwcRequest);
        String responseBody = retornarResponseErro();

        Test.startTest();
            Bdrs.Callout.setTestResponse(responseBody, 400, 'Bad Request');
        Test.stopTest();

        try{
            FormalizacaoSchema.SimularParcelasResponse response = SimuladorCreditoController.calcularSimulacao(simulacaoStringRequest);
        } catch(Exception ex){
            System.debug(ex);
            Assert.isTrue(ex.getMessage().contains('Script-thrown exception'));
        }
    }

    private static FormalizacaoSchema.SimularParcelasLwcRequest retornarLwcRequest(){
        FormalizacaoSchema.SimularParcelasLwcRequest simulacaoLwcRequest = new FormalizacaoSchema.SimularParcelasLwcRequest();
        simulacaoLwcRequest.valorSolicitado = 30000;
        simulacaoLwcRequest.taxaJuros = 0.01;
        simulacaoLwcRequest.taxaCadastro = 0;
        simulacaoLwcRequest.outrosCustos = 0;
        simulacaoLwcRequest.tipoIOF = 'BUSINESS_SIMPLE';
        simulacaoLwcRequest.prazo = 5;
        simulacaoLwcRequest.dataPrimeiroPagamento = System.today().addDays(1);
        simulacaoLwcRequest.dataLiberacao = System.today().addDays(1);
        simulacaoLwcRequest.periodicidade = 'MONTHLY';
        simulacaoLwcRequest.carencia = '123';

        return simulacaoLwcRequest;
    }

    private static String retornarResponseErro(){
        String body = '';
        body += '{';
        body += '   "message": "Constraint violation error: requested_amount must not be null"';
        body += '}';

        return body;
    }

    private static String retornarResponseSucesso(){
        String body = '';
        body += '{';
        body += '   "total_processing_cost": 139.27,';
        body += '   "annual_interest_rate": 0.126825,';
        body += '   "annual_effective_interest_rate": 0.161325,';
        body += '   "monthly_effective_interest_rate": 0.012541,';
        body += '   "iof_amount": 139.27,';
        body += '   "finance_fee": 0,';
        body += '   "interest_rate": 0.01,';
        body += '   "tac_amount": 0,';
        body += '   "total_amount_owed": 30741.95,';
        body += '   "financed_amount": 30139.27,';
        body += '   "iof_daily_rate": 0.0000137,';
        body += '   "iof_base_rate": 0.0038,';
        body += '   "requested_amount": 30000,';
        body += '   "payment_amount": 6148.39,';
        body += '   "disbursement_amount": 30000,';
        body += '   "num_periods": 5,';
        body += '   "first_payment_date": "2024-02-03",';
        body += '   "issue_date": "2024-02-01",';
        body += '   "disbursement_date": "2024-02-03",';
        body += '   "created_at": "2024-02-01T20:08:37.219919Z",';
        body += '   "schedule": [';
        body += '       {';
        body += '           "payment": 6148.39,';
        body += '           "iof": 0.00,';
        body += '           "balance": 23990.88,';
        body += '           "interest": 0.00,';
        body += '           "principal": 6148.39,';
        body += '           "period": 1,';
        body += '           "running_day": 0,';
        body += '           "payment_date": "2024-02-03"';
        body += '       },';
        body += '       {';
        body += '           "payment": 6148.39,';
        body += '           "iof": 7.03,';
        body += '           "balance": 18074.36,';
        body += '           "interest": 231.87,';
        body += '           "principal": 5916.52,';
        body += '           "period": 2,';
        body += '           "running_day": 29,';
        body += '           "payment_date": "2024-03-03"';
        body += '       },';
        body += '       {';
        body += '           "payment": 6148.39,';
        body += '           "iof": 14.66,';
        body += '           "balance": 12112.76,';
        body += '           "interest": 186.80,';
        body += '           "principal": 5961.59,';
        body += '           "period": 3,';
        body += '           "running_day": 60,';
        body += '           "payment_date": "2024-04-03"';
        body += '       },';
        body += '       {';
        body += '           "payment": 6148.39,';
        body += '           "iof": 22.24,';
        body += '           "balance": 6085.50,';
        body += '           "interest": 121.13,';
        body += '           "principal": 6027.27,';
        body += '           "period": 4,';
        body += '           "running_day": 90,';
        body += '           "payment_date": "2024-05-03"';
        body += '       },';
        body += '       {';
        body += '           "payment": 6148.39,';
        body += '           "iof": 30.19,';
        body += '           "balance": 0.00,';
        body += '           "interest": 62.89,';
        body += '           "principal": 6085.50,';
        body += '           "period": 5,';
        body += '           "running_day": 121,';
        body += '           "payment_date": "2024-06-03"';
        body += '       }';
        body += '   ],';
        body += '   "schedule_type": "MONTHLY",';
        body += '   "borrower_type": null,';
        body += '   "amortization_type": "PRICE",';
        body += '   "interest_compounding_type": "COMPOUND",';
        body += '   "financed_iof": true,';
        body += '   "last_payment_date": "2024-06-03"';
        body += '}';

        return body;
    }

}