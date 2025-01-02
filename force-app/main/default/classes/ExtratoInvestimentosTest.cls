@IsTest
private class ExtratoInvestimentosTest {
    
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
    }

    @IsTest
    static void retornarContratosEmailSucesso(){
        Account conta = [SELECT Id, Documento__c FROM Account WHERE LastName = 'Teste' LIMIT 1];
        String cpfFormat = conta.Documento__c.replace('.', '').replace('-', '');
        String responseBody = retornarResponseListContratosSucesso();

        Test.startTest();
            Bdrs.Callout.setTestResponse(responseBody, 200, 'OK'); 
            List<FormalizacaoSchema.EuroSecutizadoraContratoResponse> lstContratosCliente = ExtratoInvestimentosController.retornarContratosCliente(cpfFormat);
        Test.stopTest();

        Assert.areEqual(1, lstContratosCliente.size());
        Assert.areEqual(12345, lstContratosCliente[0].id);
        Assert.areEqual(200, lstContratosCliente[0].days);
    }

    @IsTest
    static void retornarContratosEmailErro(){
        Account conta = [SELECT Id, Documento__c FROM Account WHERE LastName = 'Teste' LIMIT 1];
        String cpfFormat = conta.Documento__c.replace('.', '').replace('-', '');

        try{
            Test.startTest();
                Bdrs.Callout.setTestResponse(null, 404, 'Not found'); 
                List<FormalizacaoSchema.EuroSecutizadoraContratoResponse> lstContratosCliente = ExtratoInvestimentosController.retornarContratosCliente(cpfFormat);
            Test.stopTest();
        } catch(Exception ex){
            System.debug(ex.getMessage());
            Assert.isTrue(ex.getMessage().contains('Script-thrown exception'));
        }
    }

    @IsTest
    static void retornarTemplateEmailContrato(){
        Test.startTest();
            EmailTemplate emailTemplate = ExtratoInvestimentosController.retornarTemplateEmail('12345', 'https://download.com.br');
        Test.stopTest();

        Assert.areEqual('Extrato consolidado', emailTemplate.Subject);
        Assert.isTrue(emailTemplate.HtmlValue.contains('12345'));
        Assert.isTrue(emailTemplate.HtmlValue.contains('https://download.com.br'));
    }

    @IsTest
    static void retornarUrlDownloadSucesso(){
        Account conta = [SELECT Id, Documento__c FROM Account WHERE LastName = 'Teste' LIMIT 1];
        String cpfFormat = conta.Documento__c.replace('.', '').replace('-', '');
        String responseBody = retornarResponseUrlDownloadSucesso();

        Test.startTest();
            Bdrs.Callout.setTestResponse(responseBody, 200, 'OK'); 
            String urlDownload = ExtratoInvestimentosController.retornarUrlDownloadContrato(cpfFormat, '12345');
        Test.stopTest();

        Assert.areEqual('https://download.com.br', urlDownload);
    }

    @IsTest
    static void retornarUrlDownloadErro(){
        Account conta = [SELECT Id, Documento__c FROM Account WHERE LastName = 'Teste' LIMIT 1];
        String cpfFormat = conta.Documento__c.replace('.', '').replace('-', '');

        try{
            Test.startTest();
                Bdrs.Callout.setTestResponse(null, 404, 'OK'); 
                String urlDownload = ExtratoInvestimentosController.retornarUrlDownloadContrato(cpfFormat, '123456');
            Test.stopTest();
        } catch(Exception ex){
            System.debug(ex.getMessage());
            Assert.isTrue(ex.getMessage().contains('Script-thrown exception'));
        }
    }

    private static String retornarResponseListContratosSucesso(){
        String body = '';
        body += '[';
        body += '   {';
        body += '       "id": 12345,';
        body += '       "user_id": 3980,';
        body += '       "number": "25-2023",';
        body += '       "amount": "90000.00",';
        body += '       "type": "Bruto",';
        body += '       "premium": "0.015",';
        body += '       "start_date": "2023-02-13",';
        body += '       "end_date": "2023-09-01",';
        body += '       "days": 200,';
        body += '       "final_amount": "65008.83",';
        body += '       "observation": "Final",';
        body += '       "created_at": "2023-11-28",';
        body += '       "updated_at": "2023-11-28",';
        body += '       "rendimento": 0,';
        body += '       "dias_adicionais": 0,';
        body += '       "contract_id": null,';
        body += '       "contract_status_id": 4,';
        body += '       "gerente_id": null,';
        body += '       "modality": "Final",';
        body += '       "resgate": 65008.825979998,';
        body += '       "status": {';
        body += '           "id": 4,';
        body += '           "descricao": "Liquidado"';
        body += '       },';
        body += '       "withdraws": [';
        body += '           {';
        body += '               "id": 38999,';
        body += '               "contract_id": 14321,';
        body += '               "installments": "1/1",';
        body += '               "installment_date": "2023-09-01",';
        body += '               "yield": "6261.0324699876",';
        body += '               "deadline": "200",';
        body += '               "aliquot": "0.2",';
        body += '               "tax_reduction": "1252.2064939221",';
        body += '               "final_amount": "5008.8259757331",';
        body += '               "payment_status": null,';
        body += '               "created_at": "2023-11-28T13:16:28.000000Z",';
        body += '               "updated_at": "2024-01-26T19:56:31.000000Z",';
        body += '               "resgate": "65008.82597766"';
        body += '           }';
        body += '       ],';
        body += '       "renovacoes": []';
        body += '   }';
        body += ']';

        return body;
    }

    private static String retornarResponseUrlDownloadSucesso(){
        String body = '';
        body += '{';
        body += '   "url": "https://download.com.br"';
        body += '}';

        return body;
    }

}