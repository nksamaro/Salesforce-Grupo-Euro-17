public class EmailInvocable {
    
    @InvocableMethod(label = 'Enviar e-mail' description = 'Ação a ser utilizada nos fluxos necessários para envio de e-mail para mais de 5 destinatários')
    public static void enviarEmail(List<Request> lstRequest){
        for(Request request : lstRequest){
            if(!request.lstDestinatarios.isEmpty()){
                Map<Long, List<String>> mapIndiceLstDestinatarios = new Map<Long, List<String>>();

                //Número 150 é o limite máximo de endereços de e-mail mapeados para envio da Messaging.SingleEmailMessage
                for(Integer i = 0; i < request.lstDestinatarios.size(); i++){
                    Decimal divisaoResult = i/150;
                    Long indiceAtual = divisaoResult.round(RoundingMode.DOWN);
                    String enderecoAtual = request.lstDestinatarios[i];
    
                    if(!String.isBlank(enderecoAtual)){
                        if(mapIndiceLstDestinatarios.get(indiceAtual) == null)
                            mapIndiceLstDestinatarios.put(indiceAtual, new List<String>{enderecoAtual});
                        else
                            mapIndiceLstDestinatarios.get(indiceAtual).add(enderecoAtual);
                    }
                }
    
                for(Long indice : mapIndiceLstDestinatarios.keySet()){
                    List<String> lstDestinatarios = mapIndiceLstDestinatarios.get(indice);
                    System.enqueueJob(new EmailQueueable(new List<String>(), lstDestinatarios, request.corpo, request.assunto));
                }
            }
        }
    }

    public class Request {
        @InvocableVariable(label='Assunto do e-mail')
        public String assunto;

        @InvocableVariable(label='Corpo do e-mail')
        public String corpo;

        @InvocableVariable(label='Lista de destinatários')
        public List<String> lstDestinatarios;
    }

}