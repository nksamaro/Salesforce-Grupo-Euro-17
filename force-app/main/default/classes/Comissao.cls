public class Comissao {
    private ComissaoRepository repository = new ComissaoRepository();
    private ComissaoFactory factory = new ComissaoFactory();
    
    //Retornas apenas as oportunidades fechadas e ganhas
    public List<Opportunity> retornarOportunidadesGanhas(List<Opportunity> oportunidades, Map<Id, Opportunity> mapOpportunityOld) {
        List<Opportunity> oportunidadesGanhas = new List<Opportunity>();

        for(Opportunity opp : oportunidades) {
            Opportunity oportunidadeOld = mapOpportunityOld.get(opp.Id);
            String faseFechadaGanha = opp.UnidadeNegocio__c == 'Produtos financeiros' ? 'Contrato registrado' : 'Contrato assinado';
        
            if(oportunidadeOld.StageName != opp.StageName && opp.StageName == faseFechadaGanha) {
                oportunidadesGanhas.add(opp);
            }
        }

        return oportunidadesGanhas;
    }

    //Retorna qual fluxo de comissão deverá ser executado
    public IFluxoComissao encontrarFluxoComissao(ComissaoSchema.ComissaoContext context) {
        //TODO: REVISAR SE OS NOMES DOS DEPARTAMENTOS SERAO ESSES MESMO

        Map<String, IFluxoComissao> mapFluxos = new  Map<String, IFluxoComissao>{
            'Operações estruturadas' => null,
            'Investimentos' => new ComissaoInvestimentoCommand(),
            'Produtos financeiros' => new ComissaoProdFinanceirosCommand()
        };

        return mapFluxos.get(context.unidadeNegocio);
    }

    //De acordo com os parametros de oportunidade, gera objeto de context
    public ComissaoSchema.ComissaoContext retornarComissaoContext(Comissao__c comissaoObj, Opportunity oportunidade) {
        //Busca oporturnidade e todos os dados necessários
        oportunidade = this.repository.buscarDetalhesOportunidade(new Set<Id> {oportunidade.Id}).get(0);

        ComissaoSchema.ComissaoContext context = this.factory.gerarComissaoContext(comissaoObj, oportunidade);

        return context;
    }

    //Retorna membros da hierarquia do usuário passado por parametro
    //TODO: FUTURAMENTE CRIAR ESTE MAP DE FORMA RECURSIVA, PREVENINDO MUDANCAS NA ESTRUTURA
    public Map<String, Id> encontrarMembrosHierarquia(Id usuarioId) {
        Map<String, Id> hierarquiaGerente = new Map<String, Id>();
        User gerente = this.repository.buscarHierarquiaUsuario(usuarioId).get(0);

        //GG
        hierarquiaGerente.put(gerente.Manager.Funcao__c, gerente.ManagerId);

        //Superindente
        hierarquiaGerente.put(gerente.Manager.Manager.Funcao__c, gerente.Manager.ManagerId);

        //Diretor
        hierarquiaGerente.put(gerente.Manager.Manager.Manager.Funcao__c, gerente.Manager.Manager.ManagerId);

        //VP
        hierarquiaGerente.put(gerente.Manager.Manager.Manager.Manager.Funcao__c, gerente.Manager.Manager.Manager.ManagerId);

        return hierarquiaGerente;
    }
}