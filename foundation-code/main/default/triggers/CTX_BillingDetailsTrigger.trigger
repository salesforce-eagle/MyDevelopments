trigger CTX_BillingDetailsTrigger on Billing_Details__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    if( CTX_BillingDetailsConstants.isFirstTimeBilling ){
        String ObjAPIName = 'Billing_Details__c';
        Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();
        if(cs.containsKey(ObjAPIName)){
            if(cs.get(ObjAPIName).isActive__c){
                TriggerDispatcher.run(new CTX_BillingDetailsTriggerHandler(), Trigger.OperationType);
            }
        }
    }

}