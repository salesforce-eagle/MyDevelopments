/**
* @File Name          : LeadTrigger.trigger
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 02-01-2024
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    27/5/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
trigger LeadTrigger on Lead (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    /**
* @description This method is used to dispatch the records based on events
* @author Lokesh Thathuru | 05/27/2020
* @param LeadTriggerHandler()
* @param TriggerOperationType
*/
    
    if(AccountConstants.isFirstTimeAccount){
        String ObjAPIName = 'Lead';
        Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();
        
        if(cs.containsKey(ObjAPIName)){
            if(cs.get(ObjAPIName).isActive__c){
                TriggerDispatcher.run(new LeadTriggerHandler(), trigger.OperationType);
            }
        }
    }
    
}



