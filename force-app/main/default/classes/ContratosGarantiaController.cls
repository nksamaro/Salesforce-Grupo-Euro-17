public class ContratosGarantiaController {
    
    private static FormalizacaoRepository repository = new FormalizacaoRepository();

    @AuraEnabled
    public static List<InformacoesFinanceirasOportunidade__c> buscarContratosInvestimentos(Id idOportunidade){
        return repository.buscarContratosInvestimentosPorId(idOportunidade);
    }

}