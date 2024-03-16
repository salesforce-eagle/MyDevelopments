public class CTX_SyncBP_SCToSAPController {
    public class CTX_SyncBP_SCToSAPControllerException extends Exception{}
    @auraEnabled
    public static List<Logger__c> syncDetails(Id recordId){
        try{
            Map<Id,Additional_GSTIN__c> addGSTINMap = new Map<Id,Additional_GSTIN__c>([SELECT Id, Name FROM Additional_GSTIN__c WHERE Opportunity__c =: recordId]);
            System.debug('$$$addGSTINMap: '+addGSTINMap);
            if(addGSTINMap.size() > 0){
                RecursiveTriggerHandler.runCreateLogger = FALSE;
                
                CTX_UpsertBusinessPartner_SAP.processAdditionalGSTINs(addGSTINMap.keySet(), NULL);
                if(CTX_UpsertBusinessPartner_SAP.updateSnag.size() > 0){
                    return CTX_UpsertBusinessPartner_SAP.updateSnag;
                } else {
                    List<Id> assetIds = new List<Id>();
                    for(Asset assInst : [ SELECT Id, Opportunity__c FROM Asset WHERE Opportunity__c =: recordId]){
                        assetIds.add(assInst.Id);   
                    }
                    if(!assetIds.isEmpty()){
                        CTX_UpsertSalesContract_SAP.processAssetsInserted(new Set<Id>(assetIds));
                        
                        if(CTX_UpsertSalesContract_SAP.updateSnag.size() > 0){
                            return CTX_UpsertSalesContract_SAP.updateSnag;
                        }
                    } else {
                        throw new CTX_SyncBP_SCToSAPControllerException('No Related Assets Found to this Opportunity To Sync Sales Contract Details.');
                    }
                }
                RecursiveTriggerHandler.runCreateLogger   = TRUE;
                return new List<Logger__c>();
            } else {
                throw new CTX_SyncBP_SCToSAPControllerException('No Related Additional GSTIN Records Found to this Opportunity');
            }     
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public class ErrorHandler {
        public Integer 	errorCount;
        public String 	errorMessage;
        public String 	errorType;
        public ErrorHandler(Integer errorCount, String errorMessage, String errorType){
			this.errorCount 	= errorCount;
			this.errorMessage 	= errorMessage;
            this.errorType 		= errorType;
        }
    }
}