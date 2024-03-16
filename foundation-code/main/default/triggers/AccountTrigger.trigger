trigger AccountTrigger on Account (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    if(AccountConstants.isFirstTimeAccount){
    String ObjAPIName = 'Account';
    Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();

    if(cs.containsKey(ObjAPIName)){
        if(cs.get(ObjAPIName).isActive__c){
    TriggerDispatcher.run(new AccountTriggerHandler(), Trigger.OperationType);
        }
    }
        }
}