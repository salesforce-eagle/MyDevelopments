/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-09-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class CTX_AdditionalGstinTriggerHandler implements TriggerInterface{
    
    
    public void beforeInsert(list<sObject> listofNewsObjectRecords){
        
        List<Additional_GSTIN__c> additionalGstnList = (List<Additional_GSTIN__c>)listofNewsObjectRecords;
        Set<Id> assetIds = new Set<Id>();
        Map<Id, List<Additional_GSTIN__c>> assetBillingMap = new Map<Id, List<Additional_GSTIN__c>>();
        Map<Id, String> assetCinMap = new Map<Id, String>();
        Map<Id, String> assetOpportunityIdMap = new Map<Id, String>();
        Map<String, String> billingPANCardCodeMap = new Map<String, String>();
        
        // GSTINValidationHelperForAdditionalGSTIN.validateGstinBaseOnReceivablePan(additionalGstnList);// added by Murali
        
        for(Additional_GSTIN__c thisRec : additionalGstnList){ 
            if(thisRec.Billing_PAN__c != NULL){
                if(thisRec.Billing_PAN__c.length() >= 15){
                    thisRec.Billing_PAN__c = thisRec.Billing_PAN__c?.substring(2,12);
                }
            }
            assetIds.add(thisRec.Asset__c);
            if(thisRec.Billing_PAN__c != NULL){
                billingPANCardCodeMap.put(thisRec.Billing_PAN__c, NULL);
            }
        }
        
        for(
            Additional_GSTIN__c thisRec : [ SELECT Id, Billing_PAN__c, BP_Card_Code__c 
                                           FROM Additional_GSTIN__c WHERE 
                                           Billing_PAN__c IN :billingPANCardCodeMap.keySet() AND
                                           BP_Card_Code__c != NULL ]
        ){
            billingPANCardCodeMap.put(thisRec.Billing_PAN__c, thisRec.BP_Card_Code__c);
        }
        
        
        for(Asset ast : [SELECT Id, Opportunity__c, Opportunity__r.CIN__c FROM Asset WHERE Id IN :assetIds]){
            assetCinMap.put(ast.Id, ast.Opportunity__r.CIN__c);
            assetOpportunityIdMap.put(ast.Id, ast.Opportunity__c);
        }
        
        for(Additional_GSTIN__c thisRec : additionalGstnList){
            if(assetCinMap.containsKey(thisRec.Asset__c) && thisRec.CIN__c == NULL){
                thisRec.CIN__c = assetCinMap.get(thisRec.Asset__c);
            }
            
            if(thisRec.Opportunity__c == NULL){
                thisRec.Opportunity__c = assetOpportunityIdMap.get(thisRec.Asset__c);
            }
            
            if( billingPANCardCodeMap.containsKey(thisRec.Billing_PAN__c) && billingPANCardCodeMap.get(thisRec.Billing_PAN__c) != NULL )
                thisRec.BP_Card_Code__c = billingPANCardCodeMap.get(thisRec.Billing_PAN__c);
        }
    }
    
    public void afterInsert(list<sObject> listofNewsObjectRecords,map<id,sObject> mapofNewObjectRecords){
        
        Map<Id, Additional_GSTIN__c> newMap 				= (Map<Id, Additional_GSTIN__c>)mapofNewObjectRecords;
        Map<Id, Additional_GSTIN__c> gstinCalloutEligible 	= new Map<Id, Additional_GSTIN__c>();
        Map<Id, Additional_GSTIN__c> updateBpRecordMap		= new Map<Id, Additional_GSTIN__c>();
        
        
        if(system.label.ActiveOrDeactivateGSTINValidation == 'true'){
            GSTINValidationHelperForAdditionalGSTIN.validateGstinBaseOnReceivablePan((List<Additional_GSTIN__c>)listofNewsObjectRecords);// added by Murali
        }
        for( Additional_GSTIN__c thisRec : newMap.values()){
            //if(thisRec.Asset__c != NULL){
            gstinCalloutEligible.put(thisRec.Id, thisRec);    
            //}
            /*if( !thisRec.GSTIN_Verification_Bypass__c ){
gstinCalloutEligible.put(thisRec.Id, thisRec);
} else{
updateBpRecordMap.put(thisRec.Id, thisRec);
}*/
        }
        
        
        if( AssetConstants.isRun ){
            CTX_FetchCompanyDetailsQueable thisJob = new CTX_FetchCompanyDetailsQueable(gstinCalloutEligible);
            System.enqueueJob(thisJob); 
        }
        
        
    }
    
    public void beforeUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){
        
        /** Added by Murali **
Map<Id,Additional_GSTIN__c> mapofNewGstinRecords = (Map<Id, Additional_GSTIN__c>)mapofNewsObjectRecords;
Map<Id,Additional_GSTIN__c> mapofoldGstinRecords = (Map<Id, Additional_GSTIN__c>)mapofOldsObjectRecords;
List<Additional_GSTIN__c> newGstin = new List<Additional_GSTIN__c>();
for(Additional_GSTIN__c gstin : mapofNewGstinRecords.values()){
system.debug('inside for in before new'+gstin.Name);
system.debug('inside for in before old'+mapofoldGstinRecords.get(gstin.id).Name);
if(gstin.Name!= mapofoldGstinRecords.get(gstin.id).Name){

newGstin.add(gstin);
}
system.debug('newGstin'+newGstin);
}

GSTINValidationHelperForAdditionalGSTIN.validateGstinBaseOnReceivablePan(newGstin);// added by Murali
/** End**/
    }
    
    public void afterUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){
        
        Map<Id, Additional_GSTIN__c> 			newBillingMap 					= (Map<Id, Additional_GSTIN__c>)mapofNewsObjectRecords;
        Map<Id, Additional_GSTIN__c> 			oldBillingMap 					= (Map<Id, Additional_GSTIN__c>)mapofOldsObjectRecords;
        Map<Id, Additional_GSTIN__c> 			billingIdMap 					= new Map<Id, Additional_GSTIN__c>();
        Map<Id, Additional_GSTIN__c> 			billingIdsToFetchCompanyInfo 	= new Map<Id, Additional_GSTIN__c>();
        
        
        /** Added by Murali **/
        Map<Id,Additional_GSTIN__c> mapofNewGstinRecords = (Map<Id, Additional_GSTIN__c>)mapofNewsObjectRecords;
        Map<Id,Additional_GSTIN__c> mapofoldGstinRecords = (Map<Id, Additional_GSTIN__c>)mapofOldsObjectRecords;
        List<Additional_GSTIN__c> newGstin = new List<Additional_GSTIN__c>();
        for(Additional_GSTIN__c gstin : mapofNewGstinRecords.values()){
            system.debug('inside for in before new'+gstin.Name);
            system.debug('inside for in before old'+mapofoldGstinRecords.get(gstin.id).Name);
            if(gstin.Name!= mapofoldGstinRecords.get(gstin.id).Name || gstin.TIN_Number__c!= mapofoldGstinRecords.get(gstin.id).TIN_Number__c){
                
                newGstin.add(gstin);
            }
            system.debug('newGstin'+newGstin);
        }
        
        if(system.label.ActiveOrDeactivateGSTINValidation == 'true'){
            GSTINValidationHelperForAdditionalGSTIN.validateGstinBaseOnReceivablePan(newGstin);// added by Murali
        }
        /** End**/
        
        
        for(Id key:newBillingMap.KeySet()){
            Additional_GSTIN__c billingNewInstance=(Additional_GSTIN__c)newBillingMap.get(key);
            Additional_GSTIN__c billingOldInstance=(Additional_GSTIN__c)oldBillingMap.get(key);
            
            if(billingNewInstance.Add_on_split__c != billingOldInstance.Add_on_split__c){
                billingIdMap.put(billingNewInstance.Id, billingNewInstance);
            }
            
            if(billingNewInstance.Name != billingOldInstance.Name){
                billingIdsToFetchCompanyInfo.put(billingNewInstance.Id, billingNewInstance);
            }           
            
        }
        
        if( billingIdsToFetchCompanyInfo.size() > 0 ){
            CTX_FetchCompanyDetailsQueable thisJob = new CTX_FetchCompanyDetailsQueable(billingIdsToFetchCompanyInfo);
            System.enqueueJob(thisJob);
        }
        
        If(!billingIdMap.isEmpty())
            CTX_AdditionalGstinTriggerHelper.validateTotalAddOn(billingIdMap);
    }
    
    public void beforeDelete(list<sObject> listofOldsObjectRecords,map<id,sObject> mapofOldsObjectRecords){}
    
    public void afterDelete(map<id,sObject> mapofOldsObjectRecords){
        
        
    }
    
    public void afterUndelete(list<sObject> listofNewsObjectRecords,map<id,sObject> mapofNewsObjectRecords){
        
    }
    
    
    
}