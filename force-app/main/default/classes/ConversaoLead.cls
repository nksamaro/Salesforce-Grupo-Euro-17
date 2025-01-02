public with sharing class ConversaoLead {

    @InvocableMethod(label='Converter Lead')
    public static List<CaptacaoClienteSchema.LeadConversionResponse> converterLead(List<CaptacaoClienteSchema.LeadConversionRequest> leadConversionRequest) {
        CaptacaoClienteService service = new CaptacaoClienteService();
        CaptacaoClienteSchema.LeadConversionResponse resposta = service.converterLead(leadConversionRequest.get(0));

        return new List<CaptacaoClienteSchema.LeadConversionResponse>{resposta};
    }
}