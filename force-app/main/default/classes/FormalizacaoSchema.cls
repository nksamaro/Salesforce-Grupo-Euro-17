public class FormalizacaoSchema {

    public class EuroSecutizadoraContratoResponse{
        @AuraEnabled public Integer id { get; set; }
        @AuraEnabled public String contractNumber { get; set; }
        @AuraEnabled public String amount { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String premium { get; set; }
        @AuraEnabled public Date start_date { get; set; }
        @AuraEnabled public Date end_date { get; set; }
        @AuraEnabled public Integer days { get; set; }
        @AuraEnabled public String final_amount { get; set; }
        @AuraEnabled public EuroSecuritizadoraContratoStatus status { get; set; }
        @AuraEnabled public String downloadUrl { get; set; }
    }

    public class EuroSecuritizadoraContratoStatus{
        @AuraEnabled public String descricao { get; set; }
    }

    public class ProtheusOportunidadeGanhaSalesforceRequest{
        public CodigoProtheus__c codigoProtheusConta { get; set; }
        public CodigoProtheus__c codigoProtheusRepresentante { get; set; }
        public List<InformacoesFinanceirasOportunidade__c> lstInfosFinanceirasOportunidade { get; set; }
        public Map<Id, CodigoProtheus__c> mapIdComissionadosCodigoProtheus { get; set; }
        public Map<Id, TimeRelacionamento__c> mapComissionados { get; set; }
        public Map<String, CodigoProtheus__c> mapCodigosProtheus { get; set; }
        public Opportunity oportunidade { get; set; }
        public Quote cotacao { get; set; }

        public ProtheusOportunidadeGanhaSalesforceRequest(CodigoProtheus__c codigoProtheusConta, CodigoProtheus__c codigoProtheusRepresentante, List<InformacoesFinanceirasOportunidade__c> lstInfosFinanceirasOportunidade, Map<Id, CodigoProtheus__c> mapIdComissionadosCodigoProtheus, Map<Id, TimeRelacionamento__c> mapComissionados, Map<String, CodigoProtheus__c> mapCodigosProtheus, Opportunity oportunidade, Quote cotacao){
            this.codigoProtheusConta = codigoProtheusConta;
            this.codigoProtheusRepresentante = codigoProtheusRepresentante;
            this.lstInfosFinanceirasOportunidade = lstInfosFinanceirasOportunidade;
            this.mapIdComissionadosCodigoProtheus = mapIdComissionadosCodigoProtheus;
            this.mapComissionados = mapComissionados;
            this.mapCodigosProtheus = mapCodigosProtheus;
            this.oportunidade = oportunidade;
            this.cotacao = cotacao;
        }
    }

    public abstract class ProtheusOportunidadeGanhaRequest{
        public String COMPANYID { get; set; }
        public String BRANCHID { get; set; }
        public String PROPOSALTYPE { get; set; }
        public String DESCRIPTION { get; set; }
        public String CUSTOMERCODE { get; set; }
        public String CUSTOMERSTORE { get; set; }
        public String VENDORCODE { get; set; }
        public String VENDORPROCESS { get; set; }
        public String STAGE { get; set; }
        public String DATEX { get; set; }
        public String TIMEX { get; set; }
        public String USER { get; set; }
        public String INITIALDATE { get; set; }
        public String FINALDATE { get; set; }
        public String COIN { get; set; }
        public String FCS { get; set; }
        public String PRIORITY { get; set; }
        public String PRODUCT { get; set; }
        public List<Comissao> COMISSION { get; set; }
    }

    public class ProtheusOportunidadeGanhaInvestimentosRequest extends ProtheusOportunidadeGanhaRequest{
        public String APPORT { get; set; }
        public String FEES { get; set; }
        public String INVESTMENTTIME { get; set; }
        public String INVESTMENTSTARTDATE { get; set; }
        public String INVESTMENTFINALDATE { get; set; }
        public String INVESTMENTRETURN { get; set; }
        public String MODALITY { get; set; }
        public String NUMBEROFINSTALLMENTS { get; set; }
        public String SERIE { get; set; }
        public List<ContaBancaria> BANKACCOUNTS { get; set; }
        public List<Debenturista> DEBENTUREOLDERS { get; set; }
    }

    public class ProtheusOportunidadeGanhaProdFinanceirosRequest extends ProtheusOportunidadeGanhaRequest{
        public String BANKCODECLIENT { get; set; }
        public String BANKCODESTORE { get; set; }
        public String BUDGET { get; set; }
        public String PARTNER { get; set; }
        public String PERCENT { get; set; }
        public String PROPOSALBANK { get; set; }
    }

    public class Comissao{
        public String VENDORCODE { get; set; }
        public Integer PERCENT { get; set; }
    }

    public class ContaBancaria{
        public String BANKCODECLIENT { get; set; }
        public String BANKCODESTORE { get; set; }
        public String BANKCODE { get; set; }
        public String ACCOUNTTYPE { get; set; }
        public String BANKAGENCY { get; set; }
        public String BANKACCOUNT { get; set; }
        public String CUSTOMERCODEOWNER { get; set; }
        public String CUSTOMERSTOREOWNER { get; set; }
        public String PARTICIPATIONINVESTIMENT { get; set; }
        public String ACCOUNTMOVETYPE { get; set; }
    }

    public class Debenturista{
        public String CUSTOMERCODE { get; set; }
        public String CUSTOMERSTORE { get; set; }
        public String NAMECUSTOMER { get; set; }
        public String FEDERALIDCUSTOMER { get; set; }
        public String ADDRESS { get; set; }
        public String NUMBERX { get; set; }
        public String COMPLEMENT { get; set; }
        public String DISTRICT { get; set; }
        public String ZIPCODE { get; set; }
        public String CITY { get; set; }
        public String STATE { get; set; }
        public String HOMEPHONE { get; set; }
        public String COMMERCIALPHONE { get; set; }
        public String MOVELPHONE { get; set; }
        public String MARITALSTATUS { get; set; }
        public String SSNIDCUSTOMER { get; set; }
        public String ISSUERSSNID { get; set; }
        public String BIRTHDATE { get; set; }
        public String NATIONALITY { get; set; }
    }

    public class ProtheusIntegracaoOportunidadeGanhaResponse{
        public String PROPOSALCODE { get; set; }
        public String msg { get; set; }
    }

    public class PicklistField{
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public Map<String, String> mapLabelValue { get; set; }
    }

    public class SimularParcelasRequest{
        public Double requestedAmount { get; set; }
        public Double interestRate { get; set; }
        public Double tacAmount { get; set; }
        public Double financeFee { get; set; }
        public String iofType { get; set; }
        public Double numPayments { get; set; }
        public Date firstPaymentDate { get; set; }
        public Date disbursementDate { get; set; }
        public String scheduleType { get; set; }
        public String carencia { get; set; }
    }

    public class SimularParcelasLwcRequest{
        public Double valorSolicitado { get; set; }
        public Double taxaJuros { get; set; }
        public Double taxaCadastro { get; set; }
        public Double outrosCustos { get; set; }
        public String tipoIOF { get; set; }
        public Double prazo { get; set; }
        public Date dataPrimeiroPagamento { get; set; }
        public Date dataLiberacao { get; set; }
        public String periodicidade { get; set; }
        public String carencia { get; set; }
    }
    
    public class SimularParcelasResponse{
        @AuraEnabled public Double total_processing_cost;
        @AuraEnabled public Double annual_interest_rate;
        @AuraEnabled public Double annual_effective_interest_rate;
        @AuraEnabled public Double monthly_effective_interest_rate;
        @AuraEnabled public Double iof_amount;
        @AuraEnabled public Double finance_fee;
        @AuraEnabled public Double interest_rate;
        @AuraEnabled public Double tac_amount;
        @AuraEnabled public Double total_amount_owed;
        @AuraEnabled public Double financed_amount;
        @AuraEnabled public Double iof_daily_rate;
        @AuraEnabled public Double iof_base_rate;
        @AuraEnabled public Double requested_amount;
        @AuraEnabled public Double payment_amount;
        @AuraEnabled public Double disbursement_amount;
        @AuraEnabled public Integer num_periods;
        @AuraEnabled public Date first_payment_date;
        @AuraEnabled public Date issue_date;
        @AuraEnabled public Date disbursement_date;
        @AuraEnabled public String created_at;
        @AuraEnabled public List<Schedule> schedule;
        @AuraEnabled public String schedule_type;
        @AuraEnabled public String amortization_type;
        @AuraEnabled public String interest_compounding_type;
        @AuraEnabled public Boolean financed_iof;
        @AuraEnabled public Date last_payment_date;
    }

    public class Schedule {
        @AuraEnabled public Double payment;
        @AuraEnabled public Double iof;
        @AuraEnabled public Double balance;
        @AuraEnabled public Double interest;
        @AuraEnabled public Double principal;
        @AuraEnabled public Integer period;
        @AuraEnabled public Integer running_day;
        @AuraEnabled public Date payment_date;
    }

}