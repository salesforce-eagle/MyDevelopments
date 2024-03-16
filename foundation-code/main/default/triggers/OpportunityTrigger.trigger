/**
 * @File Name          : Opportunity.trigger
 * @Description        : 
 * @Author             : 
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0                          Initial Version
**/
trigger OpportunityTrigger on Opportunity (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    /**
    * @description This method is used to dispatch the records based on events
    * @author 
    * @param 
    * @param 
*/
    if(RecursiveTriggerHandler.isFirstTimeOpportunity){
    String ObjAPIName = 'Opportunity';
    Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();

    if(cs.containsKey(ObjAPIName)){
        if(cs.get(ObjAPIName).isActive__c){
     TriggerDispatcher.run(new OpportunityTriggerHandler(), trigger.OperationType);
        }
    }
    }
}