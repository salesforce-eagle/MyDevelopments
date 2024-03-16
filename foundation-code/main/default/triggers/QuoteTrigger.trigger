trigger QuoteTrigger on Quote (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    /**
    * @description This method is used to dispatch the records based on events
    * @author Lokesh Thathuru | 07/14/2020
    * @param QuoteTriggerHandler() 
    * @param TriggerOperationType
    */
    if(QuoteConstants.ISFIRSTTIMEQUOTE){
    String ObjAPIName = 'Quote';
    Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();
    if(cs.containsKey(ObjAPIName)){
        if(cs.get(ObjAPIName).isActive__c){
              TriggerDispatcher.run(new QuoteTriggerHandler(), Trigger.operationType);
        }
    }else{
        TriggerDispatcher.run(new QuoteTriggerHandler(), Trigger.operationType);
    }
    }
    
}