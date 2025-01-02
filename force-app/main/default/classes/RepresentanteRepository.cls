public with sharing class RepresentanteRepository {

    public List<Profile> buscarPerfilPeloNome(String nomePerfil){
        return[
            SELECT
                Id,
                Name
            FROM
                Profile
            WHERE
                Name =: nomePerfil
        ];
    }

    public List<User> buscarUsuarioPeloNome(Set<String> nomeUsuario){
        return[
            SELECT
                Id,
                Name
            FROM
                User
            WHERE
                Name IN: nomeUsuario
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
        ];
    }

    public Id buscarRecordType(String nomeDoRecordType) {
        RecordType Rt = [
            SELECT 
                Id 
            FROM 
                RecordType
            WHERE SObjectType = 'Case' AND DeveloperName = :nomeDoRecordType
            
        ];
        return Rt.Id;
    }


    public Id buscarFila(String nomeDaFila) {
        Group fila = [
            SELECT 
                Id,
                Name
            FROM 
                Group 
            WHERE Type = 'Queue' AND DeveloperName = :nomeDaFila
        ];
        return fila.Id;
    }

    public List<CodigoProtheus__c> buscarCodigosProtheusAtivos(Set<String> documentos, Id representanteRecTypeId) {
        return [
            SELECT 
                Id, 
                Ativo__c,
                Representante__r.Documento__c,
            	Codigo__c
            FROM 
                CodigoProtheus__c
            WHERE 
                Representante__r.Documento__c IN :documentos
            AND
                RecordTypeId = :representanteRecTypeId
            AND 
                Ativo__c = true
        ];     
    }

    /* public List<CodigoProtheus__c> buscarCodigosProtheusExistentes(Id representanteRecTypeId, Set<Id> setRepresentantesIds, Set<String> setIdsExternos){
        return[
            SELECT
                Id,
                Codigo__c
            FROM
                CodigoProtheus__c
            WHERE
                IdExterno__c NOT IN: setIdsExternos
            AND 
                Representante__c IN: setRepresentantesIds
            AND
                RecordTypeId =: representanteRecTypeId
        ];
    } */

}