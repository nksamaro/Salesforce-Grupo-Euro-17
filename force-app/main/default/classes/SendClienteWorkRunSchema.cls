public with sharing class SendClienteWorkRunSchema {

    public class Request{
        public ClienteSchema clienteRequest;
        public CodigoProtheus__c codigoProtheus;
        public Opportunity oportunidade;
    }

    public class Response{
        public Boolean sucesso;
        public String response;
    }

}