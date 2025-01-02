public class ComissaoFactory {
    
    //Gera registro de comissão de uma oportunidade
    public Comissao__c gerarComissao(Opportunity oportunidade) {   
        Comissao__c comissao = new Comissao__c(
            Oportunidade__c = oportunidade.Id
        );
        
        return comissao;
    }

    //Gera ComissaoContext com os dados de Comissao e Oportunidade
    public ComissaoSchema.ComissaoContext gerarComissaoContext(Comissao__c comissaoObj, Opportunity oportunidade) {
        ComissaoSchema.ComissaoContext context = new ComissaoSchema.ComissaoContext();
        
        context.comissao = comissaoObj;
        context.conta = oportunidade.Account;
        context.unidadeNegocio = oportunidade.UnidadeNegocio__c;
        context.valorOportunidade = oportunidade.ValorOportunidade__c;
        context.tipoNegociacao = oportunidade.Type;
        context.timeRelacionamento = oportunidade.TimesRelacionamento__r;
        context.tipoComissao = null; //Deve ser encontrado dentro das regras de cada fluxo
        
        return context;
    }

    //Gera Comissionado
    public ComissaoSchema.Comissionado gerarComissionado(Id usuarioId, ItemComissionado__mdt metaComissionado) {
        ComissaoSchema.Comissionado comissionado = new ComissaoSchema.Comissionado();
        
        comissionado.funcao = metaComissionado.Funcao__c;
        comissionado.percentual = metaComissionado.Percentual__c;
        comissionado.usuarioId = usuarioId;
        
        return comissionado;
    }

    //Gera Comissionados através de Grupo publico ou Fila
    public List<ComissaoSchema.Comissionado> gerarComissionado(List<GroupMember> membrosGrupo, ItemComissionado__mdt metaComissionado, Boolean dividirPercentual) {
        List<ComissaoSchema.Comissionado> comissionados = new List<ComissaoSchema.Comissionado>();
        ComissaoSchema.Comissionado comissionado;
        Decimal percentual = metaComissionado.Percentual__c;

        if(dividirPercentual && membrosGrupo.size() > 0) {
            percentual = metaComissionado.Percentual__c / membrosGrupo.size();
        }

        for(GroupMember membro : membrosGrupo) {
            comissionado = new ComissaoSchema.Comissionado();
            comissionado.funcao = metaComissionado.Funcao__c;
            comissionado.percentual = percentual;
            comissionado.usuarioId = membro.UserOrGroupId;

            comissionados.add(comissionado);
        }
        
        return comissionados;
    }

    //Gera Comissionado__c através de ComissaoSchema.Comissionado
    public List<Comissionado__c> gerarComissionado(ComissaoSchema.ComissaoContext context, List<ComissaoSchema.Comissionado> comissionados) {
        List<Comissionado__c> comissionadosObj = new List<Comissionado__c>();

        for(ComissaoSchema.Comissionado comissionado : comissionados) {
            comissionadosObj.add(new Comissionado__c(
                Comissao__c = context.comissao.Id,
                Comissionado__c = comissionado.usuarioId,
                PercentualComissao__c = comissionado.percentual
            ));
        }
        
        return comissionadosObj;
    }

    //Gera Comissionado considerando apenas o time de relacionamento
    public ComissaoSchema.Comissionado gerarComissionado(TimeRelacionamento__c pessoaTimeRelacionamento) {
        ComissaoSchema.Comissionado comissionado = new ComissaoSchema.Comissionado();
        
        comissionado.funcao = pessoaTimeRelacionamento.Funcao__c;
        comissionado.percentual = pessoaTimeRelacionamento.DivisaoComissao__c;
        comissionado.usuarioId = pessoaTimeRelacionamento.NomeGerente__c;
        
        return comissionado;
    }

    //Gera Comissionado considerando o time de relacionamento e o valor do metadado
    public ComissaoSchema.Comissionado gerarComissionado(TimeRelacionamento__c pessoaTimeRelacionamento, List<ItemComissionado__mdt> itensComissionados, String funcao) {
        ComissaoSchema.Comissionado comissionado = new ComissaoSchema.Comissionado();

        for(ItemComissionado__mdt metaComissionado : itensComissionados) {
            if(funcao == metaComissionado.Funcao__c){
                comissionado.funcao = pessoaTimeRelacionamento.Funcao__c;
                comissionado.percentual = metaComissionado.Percentual__c;
                comissionado.usuarioId = pessoaTimeRelacionamento.NomeGerente__c;
            }
        }
 
        return comissionado;
    }

    //Gera Comissionados através da Hierarquia do usuário e Metadados
    public List<ComissaoSchema.Comissionado> gerarComissionado(Map<String, Id> hierarquiaGerente, List<ItemComissionado__mdt> itensComissionados, List<GroupMember> diretoria) {
        List<ComissaoSchema.Comissionado> comissionados = new List<ComissaoSchema.Comissionado>();
        ComissaoSchema.Comissionado comissionado;

        for(ItemComissionado__mdt metaComissionado : itensComissionados) {
            Id usuarioHierarquiaId = hierarquiaGerente.get(metaComissionado.Funcao__c);

            if(usuarioHierarquiaId != null && (metaComissionado.Funcao__c != 'Gerente de negócio' && metaComissionado.Funcao__c != 'Gerente de relacionamento principal')) {
                comissionado = new ComissaoSchema.Comissionado();
                comissionado.funcao = metaComissionado.Funcao__c;
                comissionado.percentual = metaComissionado.Percentual__c;
                comissionado.usuarioId = usuarioHierarquiaId;

                comissionados.add(comissionado);
            }

            if (metaComissionado.Funcao__c == 'Diretoria') {
                comissionados.addAll(this.gerarComissionado(diretoria, metaComissionado, true));
            }
        }
        
        return comissionados;
    }
}