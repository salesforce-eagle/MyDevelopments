trigger UpsellTrigger on Upsell_Top_up__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    if(UpsellConstants.isFirstTimeUpsell){
        String ObjAPIName = 'Upsell_Top_up__c';
        Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();
        if(cs.containsKey(ObjAPIName)){
            if(cs.get(ObjAPIName).isActive__c){
                TriggerDispatcher.run(new UpsellTriggerHandler(), Trigger.OperationType);
            }
        }
    }
}