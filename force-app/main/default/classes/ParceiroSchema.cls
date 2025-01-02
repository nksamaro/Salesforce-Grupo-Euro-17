public class ParceiroSchema {

    public class Request{
        public Boolean active;
        public Address address;
        public String branchId;
        public String code;
        public String companyId;
        public String companyInternalId;
        public String internalId;
        public String name;
        public String shortName;
    }

    public class Address{
        public String address;
        public Boolean billingAddress;
        public City city;
        public String complement;
        public Country country;
        public String district;
        public Boolean mainAddress;
        public Boolean shippingAddress;
        public State state;
        public String zipCode;
    }

    public class City{
        public String cityId;
    }

    public class Country{
        public String countryId;
    }

    public class State{
        public String stateId;
    }

    public class ParceiroWorkRunRequest{
        public Request parceiroRequest;
        public CodigoProtheus__c codigoProtheus;
        public Opportunity oportunidade;
    }

    public class ParceiroWorkRunResponse{
        public Boolean sucesso;
        public String response;
    }

}