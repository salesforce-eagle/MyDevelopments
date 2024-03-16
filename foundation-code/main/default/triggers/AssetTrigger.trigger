trigger AssetTrigger on Asset (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    /**
    * @description This method is used to dispatch the records based on events
    * @author Lokesh Thathuru | 05/11/2020
    * @param AssetTriggerHandler() 
    * @param TriggerOperationType
    */
    if(RecursiveTriggerHandler.isFirstTime || RecursiveTriggerHandler.isFirstTimeRenewed ){
    String ObjAPIName = 'Asset';
    Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();

    if(cs.containsKey(ObjAPIName)){
        if(cs.get(ObjAPIName).isActive__c){
              TriggerDispatcher.run(new AssetTriggerHandler(), Trigger.OperationType);
        }
    }
    
    }
    
}