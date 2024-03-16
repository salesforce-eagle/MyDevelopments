public class CTX_BillingDetailsTriggerHandler implements TriggerInterface{
    
    
    public void beforeInsert(List<sObject> listofNewsObjectRecords){
        List<Billing_Details__c> 	 billingList 	= (List<Billing_Details__c>)listofNewsObjectRecords;
        Set<Id> assetIds = new 	Set<Id>();
        
        for(Billing_Details__c thisRec : billingList){
            assetIds.add(thisRec.Asset__c);
            
            if(
               thisRec.Risk_Comments_CSM__c  != NULL
              )
            {
                thisRec.Risk_Status_by_CSM_Date__c = System.Today();
            }
        }
        
        
        
        /* Map<Id,Asset> assetMap = new Map<Id,Asset>([SELECT Id, Price, AccountId 
FROM Asset
WHERE Id IN :assetIds]);

for(Billing_Details__c thisRec : billingList){
if(assetMap.containsKey(thisRec.Asset__c)){
thisRec.Price__c   = assetMap.get(thisRec.Asset__c).Price;
thisRec.Account__c = assetMap.get(thisRec.Asset__c).AccountId;
}
}
*/
        CTX_BillingDetailsTriggerHelper.fetchActionOwner((List<Billing_Details__c>) listofNewsObjectRecords);
    }
    
    public void afterInsert(List<sObject> listofNewsObjectRecords, Map<Id,sObject> mapofNewsObjectRecords){
        CTX_BillingDetailsConstants.isFirstTimeBilling = FALSE; 
        
    }
    
    public void beforeUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){
        Map<Id, Billing_Details__c> 	newBillingMap 								= (Map<Id, Billing_Details__c>)mapofNewsObjectRecords;
        Map<Id, Billing_Details__c> 	oldBillingMap 								= (Map<Id, Billing_Details__c>)mapofOldsObjectRecords; 
        Set<Id> assetIds = new 	Set<Id>();
        
        CTX_BillingDetailsTriggerHelper.fetchActionOwner(newBillingMap.values());
        
        for(Billing_Details__c thisRec : newBillingMap.values()){
            assetIds.add(thisRec.Asset__c);
        }
        
        Map<Id,Asset> assetMap = new Map<Id,Asset>([SELECT Id, Price
                                                    FROM Asset
                                                    WHERE Id IN :assetIds]);
        
        for(Billing_Details__c thisRec : newBillingMap.values()){
            thisRec.Price__c = assetMap.get(thisRec.Asset__c).Price;
        }
        
        
        for(Billing_Details__c thisRec : newBillingMap.values()){
            if(thisRec.Action_Owner_Collection__c != oldBillingMap.get(thisRec.Id).Action_Owner_Collection__c &&
               thisRec.Action_Owner_Collection__c != NULL){
                   // thisRec.OwnerId = thisRec.Action_Owner_Collection__c;
               }
            if(thisRec.Risk_Status_by_Account_Owner__c != oldBillingMap.get(thisRec.Id).Risk_Status_by_Account_Owner__c &&
               thisRec.Risk_Status_by_Account_Owner__c != NULL){
                   thisRec.Risk_Status_by_Account_Owner_Date__c = System.Today();
               }
            
            if(
                (
                    thisRec.Risk_Comments_CSM__c  != oldBillingMap.get(thisRec.Id).Risk_Comments_CSM__c && 
                    thisRec.Risk_Comments_CSM__c  != NULL
                )
            ){
                thisRec.Risk_Status_by_CSM_Date__c = System.Today();
            }
        }
    }
    
    public void afterUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){ 
        CTX_BillingDetailsConstants.isFirstTimeBilling = FALSE;
        
        Map<Id, Billing_Details__c> 	newBillingMap 								= (Map<Id, Billing_Details__c>)mapofNewsObjectRecords;
        Map<Id, Billing_Details__c> 	oldBillingMap 								= (Map<Id, Billing_Details__c>)mapofOldsObjectRecords;
        
        CTX_BillingDetailsTriggerHelper.postSupportRequired(newBillingMap, oldBillingMap);
        
        Map<Id, Billing_Details__c> getBillingDetails = new Map<Id, Billing_Details__c> ([SELECT Asset__r.Is_Auto_Renewal_Enabled__c, Asset__r.Price 
                                                                                          FROM Billing_Details__c 
                                                                                          WHERE Id IN :newBillingMap.keySet()]);
        
        for(Billing_Details__c thisRec : newBillingMap.values()){
            
            if(thisRec.Payment_Amount_Received__c  != oldBillingMap.get(thisRec.Id).Payment_Amount_Received__c  &&
               thisRec.Payment_Amount_Received__c  == getBillingDetails.get(thisRec.Id).Asset__r.Price &&
               getBillingDetails.get(thisRec.Id).Asset__r.Is_Auto_Renewal_Enabled__c )
            {
                CTX_AutoRenewActivateLicense.autoRenewActivateLicenseCallout(thisRec.Id);
            }
        }
        
    }
    
    public void beforeDelete(list<sObject> listofOldsObjectRecords,map<id,sObject> mapofOldsObjectRecords){}
    
    public void afterDelete(map<id,sObject> mapofOldsObjectRecords){
        
    }
    
    public void afterUndelete(list<sObject> listofNewsObjectRecords,map<id,sObject> mapofNewsObjectRecords){}
    
    
    
}