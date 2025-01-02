//Contém as regras de comissionamento da área de Investimentos

public class ComissaoInvestimentoCommand implements IFluxoComissao {
    private ComissaoRepository repository = new ComissaoRepository();
    private ComissaoFactory factory = new ComissaoFactory();
    private Comissao comissao = new Comissao();

    //Encontra o Tipo de Comissão de Investimentos
    public ComissaoSchema.TipoComissao definirTipoComissao(ComissaoSchema.ComissaoContext context) { 
        String funcaoGerenteRelacionamento = null;
        Boolean exGerente = false;
        ComissaoSchema.TipoComissao tipoComissao;
        Map<String, ComissaoSchema.TipoComissao> mapTipoComissaoExGerente = new Map<String, ComissaoSchema.TipoComissao> {
            'Ex gerente parceiro' => ComissaoSchema.TipoComissao.ExGerenteParceiro,
            'Ex gerente inativo' => ComissaoSchema.TipoComissao.ExGerenteInativo,
            'Ex gerente exceção' => ComissaoSchema.TipoComissao.ExGerenteExcecao
        };

        //Encontra pessoa do time de relacionamento
        for(TimeRelacionamento__c pessoaRelacionamento : context.timeRelacionamento) {
            if(String.isBlank(pessoaRelacionamento.Funcao__c)) {
                throw new ComissaoException('Usuário do time de relacionamento sem função cadastrada');
            }

            if(pessoaRelacionamento.Funcao__c.contains('Ex gerente')) {
                funcaoGerenteRelacionamento = pessoaRelacionamento.Funcao__c;
                exGerente = true;
                break;
            }
        }

        if(exGerente) {
            if(context.conta.AtivoInvestimentos__c == false && funcaoGerenteRelacionamento == 'Ex gerente inativo') {
                //Cliente Inativo de Ex gerente
                tipoComissao = ComissaoSchema.TipoComissao.ClienteInativo;
            }else{ 
                //Algum tipo de Ex gerente
                tipoComissao = mapTipoComissaoExGerente.get(funcaoGerenteRelacionamento);
            } 
        }else{ 
            //Fluxo padrãp de Investimentos
            tipoComissao = ComissaoSchema.TipoComissao.GerenteAtivo;
        } 

        return tipoComissao;
    }

    public List<Comissionado__c> encontrarComissionados(ComissaoSchema.ComissaoContext context) {
        List<Comissionado__c> comissionados = new List<Comissionado__c>();

        //Considera na busca Tipo de negociação apenas se for fluxo de Ex Gerente Inativo
        String tipoNegociacao = context.tipoComissao == ComissaoSchema.TipoComissao.ExGerenteInativo ? context.tipoNegociacao : null;
        List<ItemComissionado__mdt> itensComissionados = this.repository.buscarComissionadosMetadado(context.unidadeNegocio, context.tipoComissao.name(), tipoNegociacao);

        //Executa fluxo de acordo com o tipo de comissão
        switch on context.tipoComissao {
            when GerenteAtivo {
                comissionados = this.rateioComisaoGerenteAtivo(context, itensComissionados);
            }
            when else {
                comissionados = this.rateioComisaoExGerente(context, itensComissionados);
            }
         }

        return comissionados;
    }

    //Gera comissonamento para Gerentes Ativos e sua hierarquia
    private List<Comissionado__c> rateioComisaoGerenteAtivo(ComissaoSchema.ComissaoContext context, List<ItemComissionado__mdt> itensComissionados) { 
        List<ComissaoSchema.Comissionado> comissionados = new List<ComissaoSchema.Comissionado>();
        TimeRelacionamento__c proprietarioOpp;
        TimeRelacionamento__c relacionamentoConta;
        TimeRelacionamento__c indicadoComissao;
        List<GroupMember> diretoria = this.repository.buscarMembrosGrupo('Diretoria');
        
        //Identifica os membros cadastrados no time de relacionamento 
        for(TimeRelacionamento__c pessoaRelacionemento : context.timeRelacionamento) {
            if(pessoaRelacionemento.ProprietarioOpp__c) {
                proprietarioOpp = pessoaRelacionemento;
            }
            else if(pessoaRelacionemento.Principal__c) {
                relacionamentoConta = pessoaRelacionemento;
            }
            else if(pessoaRelacionemento.GerenteIndicado__c) {
                indicadoComissao = pessoaRelacionemento;
            }
        }

        //Encontra a Hierarquia do Gerente a Opp
        Map<String, Id> hierarquiaGerente = this.comissao.encontrarMembrosHierarquia(proprietarioOpp.NomeGerente__c);

        //Verifica se será executado sub-fluxo de Divisão de Comissionamento ou "Padrão"
        if(proprietarioOpp.DivisaoComissao__c != null) {
            //Para GN, GNI, e Indicado usar percentual do próprio Time de relacionamento
            comissionados.add(this.factory.gerarComissionado(proprietarioOpp));

            if(relacionamentoConta != null ) {
                comissionados.add(this.factory.gerarComissionado(relacionamentoConta));
            }

            if(indicadoComissao != null ) {
                comissionados.add(this.factory.gerarComissionado(indicadoComissao));
            }
        }else {
            //Para GN e GNI, usar percentual do cadastro de metadados
            comissionados.add(this.factory.gerarComissionado(proprietarioOpp, itensComissionados, 'Gerente de negócio'));

            if(relacionamentoConta != null ) {
                comissionados.add(this.factory.gerarComissionado(relacionamentoConta, itensComissionados, 'Gerente de relacionamento principal'));
            }
        }

        //Gera comissionamento para a Hierarquia do proprietário da Oportunidade
        comissionados.addAll(this.factory.gerarComissionado(hierarquiaGerente, itensComissionados, diretoria));

        //Gera parse para Sobject
        return this.factory.gerarComissionado(context, comissionados);
    }

    //Realiza rateio para caso de Ex gerentes
    private List<Comissionado__c> rateioComisaoExGerente(ComissaoSchema.ComissaoContext context, List<ItemComissionado__mdt> itensComissionados) { 
        List<ComissaoSchema.Comissionado> comissionados = new List<ComissaoSchema.Comissionado>();
        TimeRelacionamento__c exGerente;

        for(TimeRelacionamento__c pessoaTimRelacionamento : context.timeRelacionamento) {
            if(pessoaTimRelacionamento.Funcao__c.contains('Ex gerente')){
                exGerente = pessoaTimRelacionamento;
                break;
            }
        }
      
        for(ItemComissionado__mdt metaComissionado : itensComissionados) {
            if(metaComissionado.Funcao__c.contains('Ex gerente')) {
                comissionados.add(this.factory.gerarComissionado(exGerente.NomeGerente__c, metaComissionado));
            }
            else if (metaComissionado.Funcao__c == 'Célula de retenção') {
                comissionados.addAll(this.factory.gerarComissionado(this.repository.buscarMembrosGrupo('CelulaRetencao'), metaComissionado, true));
            }
            else if (metaComissionado.Funcao__c == 'Diretoria') {
                comissionados.addAll(this.factory.gerarComissionado(this.repository.buscarMembrosGrupo('Diretoria'), metaComissionado, true));
            }
        }

        //Gera parse para Sobject
        return this.factory.gerarComissionado(context, comissionados);
    }
}