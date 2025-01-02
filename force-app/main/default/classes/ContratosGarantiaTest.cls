@IsTest
private class ContratosGarantiaTest {
    
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

        Opportunity opp = new Opportunity(
            AccountId = conta.Id,
            CloseDate = System.today().addDays(1),
            DataAporte__c = System.today(),
            DataFimContrato__c = System.today().addYears(7),
            Name = 'Teste Invest',
            Periodo__c = 'Mensal',
            PrazoOperacao__c = 84,
            Quantidade__c = 100,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Investimentos').getRecordTypeId(),
            StageName = 'Elaboração de Contrato',
            Taxa__c = 1.3,
            Type = 'Novo aporte',
            ValorOportunidade__c = 100000
        );
        insert opp;

        Contrato__c contrato = new Contrato__c(
            Conta__c = conta.Id,
            DataFimContrato__c = System.today().addYears(7),
            DataInicioContrato__c = System.today(),
            Oportunidade__c = opp.id,
            Periodo__c = 'Mensal',
            PrazoContrato__c = 84,
            RecordTypeId = Schema.SObjectType.Contrato__c.getRecordTypeInfosByDeveloperName().get('Investimentos').getRecordTypeId(),
            Serie__c = '13ª',
            Status__c = 'Aguardando elaboração',
            Taxa__c = 1.3,
            TipoContrato__c = 'Novo Aporte',
            ValorContrato__c = 100000
        );
        insert contrato;

        InformacoesFinanceirasOportunidade__c infoOpp = new InformacoesFinanceirasOportunidade__c(
            //Contrato__c = contrato.Id,
            Oportunidade__c = opp.Id,
            RecordTypeId = Schema.SObjectType.InformacoesFinanceirasOportunidade__c.getRecordTypeInfosByDeveloperName().get('Garantia').getRecordTypeId(),
            Utilizado__c = 10
        );
        insert infoOpp;
    }

    @IsTest
    static void retornarContratosGarantia(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Account.Documento__c = '271.156.200-08' LIMIT 1];
        List<InformacoesFinanceirasOportunidade__c> lstGarantias = ContratosGarantiaController.buscarContratosInvestimentos(opp.Id);

        Assert.areEqual(1, lstGarantias.size());
    }

}