trigger QuoteLineItemTrigger on QuoteLineItem (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    if(QuoteConstants.ISFIRSTTIMEQLI){
    String ObjAPIName = 'QuoteLineItem';
    Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();
    if(cs.containsKey(ObjAPIName)){
        if(cs.get(ObjAPIName).isActive__c){
            //QuoteLineItemTriggerHandler.productPriceCalculator(trigger.New,trigger.isInsert);
            TriggerDispatcher.run(new QuoteLineItemTriggerHandler(), Trigger.operationType);
        }
    }else{
        //QuoteLineItemTriggerHandler.productPriceCalculator(trigger.New,trigger.isInsert);
        TriggerDispatcher.run(new QuoteLineItemTriggerHandler(), Trigger.operationType);
    }
    }
}