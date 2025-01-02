trigger RendaComplementarTrigger on RendaComplementar__c (before insert, before update) {
    new RendaComplementarTriggerHandler().run();
}