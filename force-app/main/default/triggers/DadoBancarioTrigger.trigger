trigger DadoBancarioTrigger on DadoBancario__c (before insert, before update) {
    new DadoBancarioTriggerHandler().run();
}