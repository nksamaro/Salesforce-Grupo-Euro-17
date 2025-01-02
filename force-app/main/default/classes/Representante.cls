public class Representante {

    public List<Id> criarRepresentante(Map<String, User> mapDocumentoRepresentante){
        List<Id> novosRepresentantesIds = new List<Id>();
        try{
            Database.UpsertResult[] results =  Database.upsert(mapDocumentoRepresentante.values(), User.IdExterno__c, true);
            for(Database.UpsertResult result : results){
                if(result.isCreated()){
                    novosRepresentantesIds.add(result.getId());
                }
            }
        }catch (Exception ex){
            throw new RepresentanteException('Erro na criação do Representante: ' + ex.getMessage());
        }
        
        return novosRepresentantesIds;
    }
    @future
    public static void inserirCasos(String casosJson) {
        try {
            List<Case> casosParaInserir = (List<Case>) JSON.deserialize(casosJson, List<Case>.class);
            insert casosParaInserir;
        } catch (Exception e) {
            throw new RepresentanteException('Erro ao criar casos: ' + e.getMessage());
        }
    }

    @future
    public static void criarCodigoProtheus(String mapChaveCodProtheusString){
        try{
            Map<String, CodigoProtheus__c> mapChaveCodProtheus = (Map<String, CodigoProtheus__c>) JSON.deserialize(mapChaveCodProtheusString, Map<String, CodigoProtheus__c>.class);
            Database.upsert(mapChaveCodProtheus.values(), CodigoProtheus__c.IdExterno__c, true);
        }catch (Exception ex){
            throw new RepresentanteException('Erro na criação do Código do Protheus: ' + ex.getMessage());
        }
    }

    /* @future
    public static void inativarCodigosAnteriores(String lstCodProtheusAnterioresString){
        try{
            List<CodigoProtheus__c> lstCodProtheusAnteriores = (List<CodigoProtheus__c>) JSON.deserialize(lstCodProtheusAnterioresString,List<CodigoProtheus__c>.class);
            update lstCodProtheusAnteriores;
        } catch (Exception ex){
            throw new RepresentanteException('Erro na inativação de códigos anteriores: ' + ex.getMessage());
        }
    } */

    public class RepresentanteException extends Exception {}

}