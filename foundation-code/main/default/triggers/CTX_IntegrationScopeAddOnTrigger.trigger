trigger CTX_IntegrationScopeAddOnTrigger on Integration_Scope_Add_On__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    
    Map<String, TriggerActivationOrDeactivation__c> triggerActivitySetting = TriggerActivationOrDeactivation__c.getAll();
    
    system.debug('TriggerActivitySetting: '+triggerActivitySetting);
    if(triggerActivitySetting.containsKey('Integration_Scope_Add_On__c')){
        
        system.debug('In Contains TriggerActivitySetting: '+triggerActivitySetting);
        if(triggerActivitySetting.get('Integration_Scope_Add_On__c').isActive__c){
            TriggerDispatcher.run(new CTX_IntegrationScopeAddOnTriggerHandler(), trigger.OperationType);
        }
    }
}