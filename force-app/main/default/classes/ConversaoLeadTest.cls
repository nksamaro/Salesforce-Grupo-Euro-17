@isTest
private class ConversaoLeadTest {
    @isTest
    static void converterTest() {
        RecordType rc = [Select Id From RecordType Where SobjectType = 'Lead' And DeveloperName = 'CaptacaoInvestimentos' Limit 1];

        Lead lead1 = new Lead(
            LastName = 'Silva',
            Documento__c = '243.360.310-29',
            RecordTypeId = rc.Id
        );

        insert lead1;

        Lead lead2 = new Lead(
            LastName = 'Silva Soarez',
            Documento__c = '243.360.310-29',
            RecordTypeId = rc.Id
        );

        insert lead2;

        List<CaptacaoClienteSchema.LeadConversionRequest> leadConversionRequest = new List<CaptacaoClienteSchema.LeadConversionRequest>();
        CaptacaoClienteSchema.LeadConversionRequest lr = new CaptacaoClienteSchema.LeadConversionRequest();
        Id contaConvertidaId = null;

        lr.leadId = lead1.Id;
        lr.documentoLead = lead1.Documento__c;
        lr.convertedStatus = 'Convertido';
        lr.nomeOportunidade = 'Minha Opp';
        leadConversionRequest.add(lr);

        //Teste criação de conta e oportunidade
        List<CaptacaoClienteSchema.LeadConversionResponse> resultado = ConversaoLead.converterLead(leadConversionRequest);
        contaConvertidaId = resultado.get(0).contaId;
        System.assert(contaConvertidaId != null);

        List<Opportunity> oportunidades = [Select Id From Opportunity Where AccountId =: contaConvertidaId];
        System.assertEquals(1, oportunidades.size());


        //Teste criação de nova oportundide apenas, para lead de conta já existente
        lr.leadId = lead2.Id;
        lr.documentoLead = lead2.Documento__c;
        lr.convertedStatus = 'Convertido';
        lr.nomeOportunidade = 'Minha Opp';
        leadConversionRequest.add(lr);

        resultado = ConversaoLead.converterLead(leadConversionRequest);
        contaConvertidaId = resultado.get(0).contaId;
        System.assert(contaConvertidaId != null);

        oportunidades = [Select Id From Opportunity Where AccountId =: contaConvertidaId];
        System.assertEquals(2, oportunidades.size());
    }
}