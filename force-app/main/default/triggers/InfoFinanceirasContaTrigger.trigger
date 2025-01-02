trigger InfoFinanceirasContaTrigger on InformcoesFinanceirasConta__c (before insert, before update) {
    new InfoFinanceirasContaTriggerHandler().run();
}