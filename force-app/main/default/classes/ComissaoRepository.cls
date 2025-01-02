public class ComissaoRepository {
    public List<ItemComissionado__mdt> buscarComissionadosMetadado(String unidadeNegocio, String tipoComissao, String tipoNegociacao) {
        Comissionamento__mdt comissionamento = [
            SELECT 
                Id 
            FROM 
                Comissionamento__mdt 
            WHERE 
                UnidadeNegocio__c = :unidadeNegocio 
            AND TipoComissao__c = :tipoComissao 
            AND TipoNegociacao__c = :tipoNegociacao
        ].get(0);

        return [
            SELECT 
                Funcao__c,
                Percentual__c
            FROM 
                ItemComissionado__mdt
            WHERE
                Comissionamento__c = :comissionamento.Id
        ];
    }

    public List<Opportunity> buscarDetalhesOportunidade(Set<Id> oportunidadesIds) {
        return [
            SELECT 
                Id,
                ValorOportunidade__c,
                UnidadeNegocio__c,
                Type,
                Account.AtivoInvestimentos__c,
                Account.AtivoOperacesEstruturadas__c,
                Account.AtivoProdutosFinanceiros__c,
                (
                    SELECT 
                        Id,
                        Funcao__c,
                        NomeGerente__c,
                        DivisaoComissao__c,
                        Principal__c, //Também recebe comissao. Gerente da Conta  
                        ProprietarioOpp__c, //Proprietário da Oportunidade. A Hierarquia do proprietário que recebe
                        GerenteIndicado__c //Indicação de qualquer pessoa para receber comissão
                    FROM 
                        TimesRelacionamento__r
                )
            FROM 
                Opportunity
            WHERE
                Id IN :oportunidadesIds
        ];
    }

    public List<GroupMember> buscarMembrosGrupo(String grupoDeloperName) { 
        return [
            SELECT 
                Id, 
                UserOrGroupId 
            FROM 
                GroupMember 
            WHERE  
                Group.DeveloperName =: grupoDeloperName
        ];   
    } 
    
    public List<User> buscarHierarquiaUsuario(Id usuarioId) { 
        return [
            SELECT 
                Id, 
                Funcao__c,
                ManagerId, //GG
                Manager.Funcao__c, //Funcao GG
                Manager.ManagerId, //Superindente
                Manager.Manager.Funcao__c, //Funcao Superindente
                Manager.Manager.ManagerId, //Diretor
                Manager.Manager.Manager.Funcao__c, //Fucao Diretor
                Manager.Manager.Manager.ManagerId, //VP
                Manager.Manager.Manager.Manager.Funcao__c //Funcao VP
            FROM 
                User 
            WHERE  
                Id =: usuarioId
        ];   
    } 
}