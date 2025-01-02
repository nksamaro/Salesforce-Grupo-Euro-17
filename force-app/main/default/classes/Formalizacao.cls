public class Formalizacao {

    public void salvarSimulacaoCredito(SimulacaoCredito__c simulacaoCredito){
        try {
            insert simulacaoCredito;
        } catch (Exception ex) {
            throw new FormalizacaoException(ex.getMessage());
        }
    }

    public void salvarSimulacoesParcela(List<SimulacaoParcela__c> listSimulacaoParcela){
        try {
            insert listSimulacaoParcela;
        } catch (Exception ex) {
            throw new FormalizacaoException(ex.getMessage());
        }
    }

    public class FormalizacaoException extends Exception {}

}