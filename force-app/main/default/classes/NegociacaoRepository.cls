public class NegociacaoRepository {

    public List<ProcessInstanceStep> buscarEtapasMaisRecenteAprovadas(Set<Id> setObjIds) {
        return [
            SELECT 
                Id,
                ProcessInstance.CreatedById,
                ProcessInstance.Status,
                ProcessInstance.TargetObjectId,
                ProcessInstance.LastActor.Funcao__c,
                ProcessInstance.ProcessDefinition.DeveloperName,
                StepStatus
            FROM 
                ProcessInstanceStep 
            WHERE 
                ProcessInstance.TargetObjectId IN: setObjIds
            AND
                StepStatus IN ('Approved', 'Rejected')
            WITH
                SYSTEM_MODE
            ORDER BY
                ProcessInstance.LastModifiedDate ASC
        ];
    }

    public List<Filial__c> buscarFilialPorCodigo(Set<String> docFilial) {
        return [
            SELECT 
                Id,
                CodigoFilial__c
            FROM 
                Filial__c 
            WHERE 
                CodigoFilial__c IN: docFilial
            WITH
                USER_MODE
        ];
    }

    public List<User> buscarHierarquiaUsuariosPorSetId(Set<Id> setUserIds){
        return [
            SELECT
                Id,
                Name,
                Manager.Funcao__c,
                Manager.Manager.Funcao__c,
                Manager.Manager.Manager.Funcao__c,
                Manager.Manager.Manager.Manager.Funcao__c,
                Manager.Manager.Manager.Manager.Manager.Funcao__c,
                Manager.Manager.Manager.Manager.Manager.Manager.Funcao__c
            FROM
                User
            WHERE
                Id IN: setUserIds
        ];
    }

    public List<ProcessInstanceWorkItem> buscarItensPendentesAprovacao(Set<Id> setObjIds) {
        return [
            SELECT 
                Id,
                ProcessInstance.Status,
                ProcessInstance.TargetObjectId
            FROM 
                ProcessInstanceWorkItem 
            WHERE 
                ProcessInstance.TargetObjectId IN: setObjIds
            WITH
                SYSTEM_MODE
        ];
    }

    public List<Opportunity> buscarOportunidadesPorSetId(Set<Id> setOpportunityIds) {
        return [
            SELECT
                Id,
                OwnerId,
                StageName
            FROM
                Opportunity
            WHERE
                Id IN: setOpportunityIds
        ];
    }

    public List<User> buscarUsuariosPorSetId(Set<Id> setUserIds){
        return [
            SELECT 
                Id,
                Name,
                Funcao__c
            FROM 
                User
            WHERE
                Id IN: setUserIds
            WITH
                USER_MODE
        ];
    }

    public User buscarUsuarioPorId(Id userId){
        List<User> listUser = buscarUsuariosPorSetId(new Set<Id> { userId });
        return !listUser.isEmpty() ? listUser[0] : null;
    }

}