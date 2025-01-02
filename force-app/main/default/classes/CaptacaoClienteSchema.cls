global class CaptacaoClienteSchema {

    global class LeadRequest{
        public String nome;
        public String documento;
        public String email;
        public String telefone;
        public String celular;
        public String estadoCivil;
        public String comporRenda;
        public Decimal renda;
        public Decimal valorImovel;
        public Decimal valorFinanciamento;
        public Integer prazo;
        public String produtoInteresse;
        public String placa;
        public String restricao;
        public String originador;
        public String origem;
        public Id contaExistenteId;
    }

    public class LeadConversionRequest {
        @InvocableVariable(required=true)
        public Id leadId;

        @InvocableVariable(required=true)
        public String documentoLead;
        
        @InvocableVariable(required=true)
        public String convertedStatus;

        @InvocableVariable(required=true)
        public String nomeOportunidade;
    }

    public class LeadConversionResponse {
        @InvocableVariable(required=true)
        public Id contaId;

        @InvocableVariable(required=true)
        public Id oportunidadeId;
    }
}