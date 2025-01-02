trigger BeneficiarioTrigger on Beneficiario__c (before insert, before update) {
    new BeneficiarioTriggerHandler().run();
}