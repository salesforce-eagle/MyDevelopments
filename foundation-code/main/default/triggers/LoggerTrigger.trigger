trigger LoggerTrigger on Logger__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {

    
    String ObjAPIName = 'Logger__c';
    Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();

    if(cs.containsKey(ObjAPIName)){
        if(cs.get(ObjAPIName).isActive__c){
              TriggerDispatcher.run(new LoggerTriggerHandler(), trigger.OperationType);
        }
    }
}