public with sharing class ClienteSchema {

    public String branchId;
    public String companyInternalId;
    public String code;
    public String storeId;
    public String shortName;
    public String name;
    public Integer type;
    public String entityType;
    public String registerSituation;
    public String strategicCustomerType;
	public MarketSegment marketsegment;
    public List<GovernmentalInformation> GovernmentalInformation;
    public Address address;
    public Address shippingAddress;
    public List<CommunicationInformation> listOfCommunicationInformation;
    public List<ContactInfo> listOfContacts;
    public List<BankingInformation> listOfBankingInformation;
    public CreditInformation creditInformation;
    public VendorInformation vendorInformation;
    public FiscalInformation fiscalInformation;
    public BillingInformation billingInformation;

    public ClienteSchema() {
        marketsegment = new MarketSegment();
        GovernmentalInformation = new List<GovernmentalInformation>();
        address = new Address();
        shippingAddress = new Address();
        listOfCommunicationInformation = new List<CommunicationInformation>();
        listOfContacts = new List<ContactInfo>();
        listOfBankingInformation = new List<BankingInformation>();
        creditInformation = new CreditInformation();
        vendorInformation = new VendorInformation();
        fiscalInformation = new FiscalInformation();
        billingInformation = new BillingInformation();
    }

    public class MarketSegment {
        public String marketSegmentCode;
        public String marketSegmentInternalId;
        public String marketSegmentDescription;

        public MarketSegment() {
            marketSegmentCode = '';
            marketSegmentInternalId = '';
            marketSegmentDescription = '';
        }
    }

    public class GovernmentalInformation {
        public String id;
        public String name;
        public String scope;
        public String expireOn;
        public String issueOn;

        public GovernmentalInformation() {
            id = '';
            name = '';
            scope = '';
            expireOn = '';
            issueOn = '';
        }
    }

    public class Address {
        public String address;
        public String complement;
        public String district;
        public String zipCode;
        public String region;
        public String poBox;
        public Boolean mainAddress;
        public Boolean shippingAddress;
        public Boolean billingAddress;
        public City city;
        public State state;
        public Country country;

        public Address() {
            address = '';
            complement = '';
            district = '';
            zipCode = '';
            region = '';
            poBox = '';
            mainAddress = false;
            shippingAddress = false;
            billingAddress = false;
            city = new City();
            state = new State();
            country = new Country();
        }
    }

	public class City {
		public String cityCode;
		public String cityInternalId;
		public String cityDescription;

		public City() {
			cityCode = '';
			cityInternalId = '';
			cityDescription = '';
		}
	}

	public class State {
		public String stateId;
		public String stateInternalId;
		public String stateDescription;

		public State() {
			stateId = '';
			stateInternalId = '';
			stateDescription = '';
		}
	}

	public class Country {
		public String countryCode;
		public String countryInternalId;
		public String countryDescription;

		public Country() {
			countryCode = '';
			countryInternalId = '';
			countryDescription = '';
		}
	}

    public class CommunicationInformation {
        public String type;
        public String phoneNumber;
        public String phoneExtension;
        public String faxNumber;
        public String faxNumberExtension;
        public String homePage;
        public String email;
        public String diallingCode;
        public String internationalDiallingCode;

        public CommunicationInformation() {
            type = '';
            phoneNumber = '';
            phoneExtension = '';
            faxNumber = '';
            faxNumberExtension = '';
            homePage = '';
            email = '';
            diallingCode = '';
            internationalDiallingCode = '';
        }
    }

    public class ContactInfo {
        public String ContactInformationCode;
        public String ContactInformationInternalId;
        public String ContactInformationTitle;
        public String ContactInformationName;
        public String ContactInformationDepartment;
        public CommunicationInformation CommunicationInformation;
        public Address ContactInformationAddress;

        public ContactInfo() {
            ContactInformationCode = '';
            ContactInformationInternalId = '';
            ContactInformationTitle = '';
            ContactInformationName = '';
            ContactInformationDepartment = '';
            CommunicationInformation = new CommunicationInformation();
            ContactInformationAddress = new Address();
        }
    }

    public class BankingInformation {
        public String bankCode;
        public String bankInternalId;
        public String bankName;
        public String branchCode;
        public String branchKey;
        public String checkingAccountNumber;
        public String checkingAccountNumberKey;
        public String checkingAccountType;
        public String mainAccount;
        public String currencyAccount;

        public BankingInformation() {
            bankCode = '';
            bankInternalId = '';
            bankName = '';
            branchCode = '';
            branchKey = '';
            checkingAccountNumber = '';
            checkingAccountNumberKey = '';
            checkingAccountType = '';
            mainAccount = '';
            currencyAccount = '';
        }
    }

    public class CreditInformation {
        public String creditIndicator;
        public String creditEvaluation;
        public String shipmentCreditEvaluation;
        public Integer creditLimit;
        public Integer creditLimitCurrency;
        public String creditLimitDate;
        public Integer additionalCreditLimit;
        public String additionalCreditLimitCurrency;
        public String additionalCreditLimitDate;
        public String latePeriods;
        public String balanceOfCredit;

        public CreditInformation() {
            creditIndicator = '';
            creditEvaluation = '';
            shipmentCreditEvaluation = '';
            creditLimitDate = '';
            additionalCreditLimitCurrency = '';
            additionalCreditLimitDate = '';
            latePeriods = '';
            balanceOfCredit = '';
        }
    }

    public class VendorInformation {
        public String vendorClassification;
        public String vendorTypeCode;
        public String vendorTypeInternalId;
        public String vendorTypeDescription;

        public VendorInformation() {
            vendorClassification = '';
            vendorTypeCode = '';
            vendorTypeInternalId = '';
            vendorTypeDescription = '';
        }
    }

    public class FiscalInformation {
        public String Category;
        public String IsRetentionAgent;
        public TaxPayer taxPayer;

        public FiscalInformation() {
            Category = '';
            IsRetentionAgent = '';
            taxPayer = new TaxPayer();
        }
    }

	public class TaxPayer {
		public String taxName;
		public String isPayer;
		public String mode;

		public TaxPayer() {
			taxName = '';
			isPayer = '';
			mode = '';
		}
	}

    public class BillingInformation {
        public String billingCustomerCode;
        public String billingCustomerInternalId;
        public Address address;

        public BillingInformation() {
            billingCustomerCode = '';
            billingCustomerInternalId = '';
            address = new Address();
        }
    }
}