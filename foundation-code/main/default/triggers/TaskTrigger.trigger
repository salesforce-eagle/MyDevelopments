trigger TaskTrigger on Task (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
String ObjAPIName = 'Task';
    Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();

    if(cs.containsKey(ObjAPIName)){
        if(cs.get(ObjAPIName).isActive__c && caseconstants.taskTrigger){
              TriggerDispatcher.run(new TaskTriggerHandler(), Trigger.OperationType);
        }
    }
}