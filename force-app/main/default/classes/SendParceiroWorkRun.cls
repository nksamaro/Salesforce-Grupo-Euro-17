global class SendParceiroWorkRun implements Bdrs.WorkRun {

    global String process(String content){
		ParceiroSchema.ParceiroWorkRunResponse retorno = new ParceiroRepository().integrarParceiro(content);

		return JSON.serialize(retorno);
	}

	global String processResponse(String content, String responseContent){
		ParceiroSchema.ParceiroWorkRunRequest parceiroSchema = (ParceiroSchema.ParceiroWorkRunRequest) JSON.deserialize(content, ParceiroSchema.ParceiroWorkRunRequest.class);
		upsert parceiroSchema.codigoProtheus IdExterno__c;

		if(parceiroSchema.oportunidade != null){
			parceiroSchema.oportunidade.DataHoraIntegracaoProtheus__c = Datetime.now();
			parceiroSchema.oportunidade.StatusProtheus__c = 'Reprocessada';
			update parceiroSchema.oportunidade;
		}

		return responseContent;
	}

}