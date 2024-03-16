trigger ContactTrigger on Contact (before insert,after insert,before update,after update,before delete,after delete,after undelete) {

    if(CaseConstants.isFirstTimeCase){
        
        String ObjAPIName = 'Contact';
        Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();
        
        if(cs.containsKey(ObjAPIName)){
            if(cs.get(ObjAPIName).isActive__c){
                TriggerDispatcher.run(new ContactTriggerHandler(), Trigger.OperationType);
            }
        }
        
    }
    
    
    
}