public class ApprovalControll {
    
    @InvocableMethod(label='Bloquear registro' description='Realiza bloqueio de registro' category= 'Projeto__c' callout=true)
    public static List<RetornoBloqueioRegistro> bloquearRegistro(List<RequestBloqueioRegistro> registrosBlock) {
        List<RetornoBloqueioRegistro> retorno = new List<RetornoBloqueioRegistro>();
        String mensagem = '';
        
        try {
            RequestBloqueioRegistro registro = registrosBlock.get(0);
            Id idRegistro = registro.registroId;
            Boolean bloquear = registro.bloquear;

            if(bloquear) {
                Approval.lock(idRegistro);
                mensagem = 'Registro ' + idRegistro + 'bloqueado com sucesso!';
            }else {
                Approval.unlock(idRegistro);   
                mensagem = 'Registro ' + idRegistro + 'desbloqueado com sucesso!';
            }
        } catch (Exception ex) {
            mensagem = 'Erro bloquear/desbloquear registro ' + ex.getMessage();
        }

        RetornoBloqueioRegistro retornoBlock = new RetornoBloqueioRegistro();
        retornoBlock.mensagem = mensagem;
        retorno.add(retornoBlock);
    
        return retorno;
    }

    public class RequestBloqueioRegistro {
        @InvocableVariable(label='registroId' required=true)
        public Id registroId;

        @InvocableVariable(label='bloquear' required=true)
        public Boolean bloquear;
    }

    public class RetornoBloqueioRegistro {
        @InvocableVariable(label='mensagem' required=true)
        public String mensagem;
    }
}