trigger ProjectTrigger on Project__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {

	/**
    * @description This method is used to dispatch the records based on events
    * @author Lokesh Thathuru | 07/12/2020
    * @param ProjectTriggerHandler() 
    * @param TriggerOperationType
    */
    
    if(ProjectConstants.isFirstTimeProject){
        String ObjAPIName = 'Project';
        Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();
        
        if(cs.containsKey(ObjAPIName) && ProjectConstants.isFirstTimeProject){
            if(cs.get(ObjAPIName).isActive__c){
                TriggerDispatcher.run(new ProjectTriggerHandler(), Trigger.OperationType);
            }
        }
    }
}