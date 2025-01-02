public class ProcessamentoComissionadosQueueable implements Queueable {
    private Comissao__c comissaoObj;
    private Opportunity oportunidade;
    private Comissao comissao = new Comissao();

    public ProcessamentoComissionadosQueueable(Comissao__c comissaoObj, Opportunity oportunidade) {
        this.comissaoObj = comissaoObj;
        this.oportunidade = oportunidade;
    }

    public void execute(QueueableContext context) { 
        try {
            //Gera objeto context de Comissao, e acordo com os parametros de oportunidade
            ComissaoSchema.ComissaoContext comissaoContext = this.comissao.retornarComissaoContext(comissaoObj, oportunidade);

            //Encontra qual fluxo de comissão deve ser executado
            IFluxoComissao fluxoComissao = this.comissao.encontrarFluxoComissao(comissaoContext);

            //Encontra o tipo exato da comissão de acordo com as regra estabelecidas por cada BU
            comissaoContext.tipoComissao = fluxoComissao.definirTipoComissao(comissaoContext);

            //Gera comissionados e realiza rateio de acordo com as regras do fluxo
            List<Comissionado__c> comissionados = fluxoComissao.encontrarComissionados(comissaoContext);
            if(comissionados != null)
                insert comissionados;
            
        } catch (Exception ex) {
            String mensagemErro = ex.getMessage() + ' - ' + ex.getStackTraceString();
            throw new ComissaoException(mensagemErro);
        }
    }
}