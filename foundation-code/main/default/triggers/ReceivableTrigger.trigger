trigger ReceivableTrigger on Receivables__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    if(RecursiveTriggerHandler.isFirstTimeOpportunity){
        String ObjAPIName = 'Receivables__c';
        Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();
        
        if(cs.containsKey(ObjAPIName)){
            if(cs.get(ObjAPIName).isActive__c){
                TriggerDispatcher.run(new ReceivableTriggerHandler(), trigger.OperationType);
            }
        }
    }
}