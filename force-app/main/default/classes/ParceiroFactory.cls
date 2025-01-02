public class ParceiroFactory {
    
    public CodigoProtheus__c buildCodigoProtheus(Account conta, Filial__c filial){
        String primeirosNumerosDocumento = Bdrs.Format.clearNumberFormatting(conta.Documento__c).substring(0,6);

        CodigoProtheus__c codigoProtheus = new CodigoProtheus__c();
        codigoProtheus.Ativo__c = true;
        codigoProtheus.Codigo__c = primeirosNumerosDocumento;
        codigoProtheus.Conta__c = conta.Id;
        codigoProtheus.Filial__c = filial.Id;
        codigoProtheus.IdExterno__c = filial.CodigoFilial__c + '|' + primeirosNumerosDocumento;
        codigoProtheus.RecordTypeId = Schema.SObjectType.CodigoProtheus__c.getRecordTypeInfosByDeveloperName().get('Parceiro').getRecordTypeId();

        return codigoProtheus;
    }

    public ParceiroSchema.Request buildParceiroRequest(Account conta, Filial__c filial){
        ParceiroSchema.Request parceiroRequest = new ParceiroSchema.Request();
        parceiroRequest.active = conta.StatusConta__c == 'Inativo' ? false : true;
        parceiroRequest.branchId = filial.CodigoFilial__c;
        parceiroRequest.code = Bdrs.Format.clearNumberFormatting(conta.Documento__c).substring(0,6);
        parceiroRequest.companyId = filial.CodigoEmpresa__c;
        parceiroRequest.companyInternalId = filial.CodigoEmpresa__c + filial.CodigoFilial__c;
        parceiroRequest.internalId = filial.CodigoFilial__c + parceiroRequest.code;
        parceiroRequest.name = Util.removerAcentosCaracteres(conta.Name.toUpperCase());
        parceiroRequest.shortName = !String.isBlank(conta.FirstName) ? Util.removerAcentosCaracteres(conta.FirstName.toUpperCase()) : Util.removerAcentosCaracteres(conta.Name.toUpperCase());

        ParceiroSchema.Address parceiroAddress = new ParceiroSchema.Address();
        ParceiroSchema.City parceiroCity = new ParceiroSchema.City();
        ParceiroSchema.Country parceiroCountry = new ParceiroSchema.Country();
        ParceiroSchema.State parceiroState = new ParceiroSchema.State();
        String codigoPostal = conta.BillingAddress?.getPostalCode() != null ? Bdrs.Format.clearNumberFormatting(conta.BillingAddress.getPostalCode()) : '';

        parceiroCity.cityId = conta.BillingAddress?.getCity() != null ? Util.removerAcentosCaracteres(conta.BillingAddress.getCity().toUpperCase()) : '';
        parceiroCountry.countryId = '105';
        parceiroState.stateId = conta.BillingAddress?.getState() != null ? conta.BillingAddress.getState().toUpperCase() : '';

        parceiroAddress.address = conta.BillingAddress?.getStreet() != null ? Util.removerAcentosCaracteres(conta.BillingAddress.getStreet().toUpperCase()) : '';
        parceiroAddress.address = parceiroAddress.address != null && conta.NumeroCobranca__c != null ? parceiroAddress.address + ', ' +  + ', ' + conta.NumeroCobranca__c : parceiroAddress.address;
        parceiroAddress.billingAddress =  true;
        parceiroAddress.city = parceiroCity;
        parceiroAddress.complement = conta.ComplementoCobranca__c != null ? Util.removerAcentosCaracteres(conta.ComplementoCobranca__c.toUpperCase()) : '';
        parceiroAddress.country = parceiroCountry;
        parceiroAddress.district = conta.BairroCobranca__c != null ? Util.removerAcentosCaracteres(conta.BairroCobranca__c.toUpperCase()) : '';
        parceiroAddress.mainAddress = true;
        parceiroAddress.shippingAddress = false;
        parceiroAddress.state = parceiroState;
        parceiroAddress.zipCode = codigoPostal;
        parceiroRequest.address = parceiroAddress;

        return parceiroRequest;
    }

}