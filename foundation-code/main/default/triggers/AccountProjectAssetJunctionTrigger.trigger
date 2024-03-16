trigger AccountProjectAssetJunctionTrigger on AccountProjectAssetJunction__c  (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
	/**
    * @description This method is used to dispatch the records based on events
    * @author Lokesh Thathuru | 07/12/2020
    * @param AccountProjectAssetJunctionTriggerHandler() 
    * @param TriggerOperationType
    */
    if(ProjectConstants.isFirstTimeApa){
        TriggerDispatcher.run(new APAJunctionTriggerHandler(), Trigger.OperationType);
    }

}