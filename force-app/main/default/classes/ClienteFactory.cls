public with sharing class ClienteFactory {
    
    public static ClienteSchema buildClienteRequest(Account conta, CodigoProtheus__c representanteProtheus){
        ClienteSchema cliente = new ClienteSchema();
        ClienteSchema.MarketSegment marketSegment = new ClienteSchema.MarketSegment();
        ClienteSchema.GovernmentalInformation governmentalInformation = new ClienteSchema.GovernmentalInformation();
        ClienteSchema.Address address = new ClienteSchema.Address();

        String numerosDocumento = Bdrs.Format.clearNumberFormatting(conta.Documento__c);
        String primeirosNumerosDocumento = numerosDocumento.substring(0, 8);
        String companyInternalId = '01' + representanteProtheus.Filial__r.CodigoEmpresa__c + '   ';
        String documento = conta.RecordType.Name == 'Empresa' ? primeirosNumerosDocumento + '0001' : primeirosNumerosDocumento;
        companyInternalId += documento;        

        cliente.branchId = representanteProtheus.Filial__r.CodigoEmpresa__c + '   ';
        cliente.companyInternalId = companyInternalId;
        cliente.code = primeirosNumerosDocumento;
        cliente.storeId = conta.RecordType.Name == 'Empresa' ? '0001' : numerosDocumento.substring(numerosDocumento.length()-3);
        cliente.shortName = conta.FirstName != null ? Util.removerAcentosCaracteres(conta.FirstName.toUpperCase()) : Util.removerAcentosCaracteres(conta.Name.toUpperCase());
        cliente.name = Util.removerAcentosCaracteres(conta.Name.toUpperCase());
        cliente.type = 1;
        cliente.entityType = conta.RecordType.Name == 'Empresa' ? 'J' : 'F';
        cliente.registerSituation = '2';
        cliente.strategicCustomerType = 'F';
        
        governmentalInformation.id = numerosDocumento;
        governmentalInformation.name = conta.RecordType.Name == 'Empresa' ? 'CNPJ' : 'CPF';

        address.billingAddress = true;
        address.mainAddress = true;
        address.country.countryDescription = conta.BillingCountry?.toUpperCase();
        address.state.stateId = conta.BillingState?.toUpperCase();
        address.state.stateDescription = conta.BillingState?.toUpperCase();
        address.city.cityDescription = Util.removerAcentosCaracteres(conta.BillingCity?.toUpperCase());
        address.address = Util.removerAcentosCaracteres(conta.BillingStreet?.toUpperCase());
        address.zipCode = Bdrs.Format.clearNumberFormatting(conta.BillingPostalCode);
        address.district = Util.removerAcentosCaracteres(conta.BairroCobranca__c);
        address.complement = conta.ComplementoCobranca__c != null ? Util.removerAcentosCaracteres(conta.ComplementoCobranca__c.toUpperCase()) : '';

        cliente.GovernmentalInformation.add(governmentalInformation);
        cliente.address = address;

        return cliente;
    }

    public static CodigoProtheus__c buildCodigoProtheus(Account conta, CodigoProtheus__c representanteProtheus){
        String numerosDocumento = Bdrs.Format.clearNumberFormatting(conta.Documento__c);
        String primeirosNumerosDocumento = numerosDocumento.substring(0, 8);

        CodigoProtheus__c novoCodigoProtheus = new CodigoProtheus__c();
        novoCodigoProtheus.RecordTypeId = Schema.SObjectType.CodigoProtheus__c.getRecordTypeInfosByDeveloperName().get('Conta').getRecordTypeId();
        novoCodigoProtheus.Codigo__c = primeirosNumerosDocumento;
        novoCodigoProtheus.Empresa__c = representanteProtheus.Filial__r.CodigoEmpresa__c;
        novoCodigoProtheus.Filial__c = representanteProtheus.Filial__c;
        novoCodigoProtheus.Conta__c = conta.Id;
        novoCodigoProtheus.Ativo__c = true;
        novoCodigoProtheus.IdExterno__c = representanteProtheus.Filial__r.CodigoEmpresa__c + ' + ' + primeirosNumerosDocumento;

        return novoCodigoProtheus;
    }
}