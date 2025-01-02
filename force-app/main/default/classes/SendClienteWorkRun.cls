global class SendClienteWorkRun implements Bdrs.WorkRun {

    global String process(String content) {		
		SendClienteWorkRunSchema.Response retorno = ClienteService.sendRequest(content);

		return JSON.serialize(retorno);
	}

	global String processResponse(String content, String responseContent){
		SendClienteWorkRunSchema.Request clienteSchema = (SendClienteWorkRunSchema.Request) JSON.deserialize(content, SendClienteWorkRunSchema.Request.class);
		clienteSchema.oportunidade.DataHoraIntegracaoProtheus__c = Datetime.now();
		clienteSchema.oportunidade.StatusProtheus__c = 'Reprocessada';
		update clienteSchema.oportunidade;
		
		upsert clienteSchema.codigoProtheus IdExterno__c; 
		return responseContent;
	}
}