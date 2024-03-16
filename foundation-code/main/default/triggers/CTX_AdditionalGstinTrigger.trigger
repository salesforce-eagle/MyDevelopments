trigger CTX_AdditionalGstinTrigger on Additional_GSTIN__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    if(AssetConstants.isFirstTimeAdditionalGstin){
        String ObjAPIName = 'Additional_GSTIN__c';
        Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();
    	System.debug('cs'+cs);
        if(cs.containsKey(ObjAPIName)){
            if(cs.get(ObjAPIName).isActive__c){
                TriggerDispatcher.run(new CTX_AdditionalGstinTriggerHandler(), Trigger.OperationType);
            }
        }
    }
}