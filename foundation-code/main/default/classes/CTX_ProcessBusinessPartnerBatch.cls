public class CTX_ProcessBusinessPartnerBatch implements Database.Batchable<Id>, Database.Stateful, Database.AllowsCallouts{
	Public List<Id> assetIds = new List<Id>();
    public CTX_ProcessBusinessPartnerBatch(List<Id> assetIds){
        this.assetIds = assetIds;
    }
    
    public Iterable<Id> start(Database.BatchableContext BC){
        
        /*Map<String,Id> gstinNumberTOGSTINRecMap = new Map<String,Id>();
        for(Additional_GSTIN__c gstin : [SELECT Id, Name FROM Additional_GSTIN__c WHERE Opportunity__c IN : new Set<Id>(assetIds) AND Name != NULL ORDER BY CreatedDate DESC]){
            if(!gstinNumberTOGSTINRecMap.containsKey(gstin.Name)){
                gstinNumberTOGSTINRecMap.put(gstin.Name, gstin.Id);
            }
        }
        
        if(gstinNumberTOGSTINRecMap.size() > 0){
            return gstinNumberTOGSTINRecMap.values();
        }
        
        return NULL;*/
		
        return assetIds;
    }
    
    public void execute(Database.BatchableContext BC, List<Id> scope){
        Map<Id,Additional_GSTIN__c> addGSTINMap = new Map<Id,Additional_GSTIN__c>([SELECT Id, Name FROM Additional_GSTIN__c WHERE Asset__c IN : new Set<Id>(scope)]);
        
        if(addGSTINMap.size() > 0){
        	CTX_UpsertBusinessPartner_SAP.processAdditionalGSTINs(addGSTINMap.keySet(), NULL);    
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
        CTX_UpsertSalesContract_SAP.processAssetsInserted(new Set<Id>(assetIds));
    }
}