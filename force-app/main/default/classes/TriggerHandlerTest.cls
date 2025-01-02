@isTest
private class TriggerHandlerTest {
    @TestSetup
    static void populaObjetos(){
        //insere dados no objetos acima
    }

    @isTest
    static void triggerHandlerTest(){
        test.startTest();

        TriggerHandler controller = new TriggerHandler();
        controller.setTriggerContext('before insert', true);
        controller.run();
        controller.setTriggerContext('before update', true);
        controller.run();
        controller.setTriggerContext('before delete', true);
        controller.run();
        controller.setTriggerContext('after insert', true);
        controller.run();
        controller.setTriggerContext('after update', true);
        controller.run();
        controller.setTriggerContext('after delete', true);
        controller.run();
        controller.setTriggerContext('after undelete', true);
        controller.run();

        controller.clearMaxLoopCount();
        controller.setMaxLoopCount(5);
        TriggerHandler.bypass('test');
        TriggerHandler.clearBypass('test');
        TriggerHandler.isBypassed('test');
        TriggerHandler.clearAllBypasses();


        TriggerHandler.LoopCount abc = new TriggerHandler.LoopCount();

        
        integer test1 = abc.getMax();
        integer test2 = abc.getCount();
        Boolean test3 = abc.increment();
        Boolean test4 = abc.exceeded();
        

        test.stopTest();
    }
}