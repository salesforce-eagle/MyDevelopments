/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-22-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
Public Class CTX_LicensingAssetFilterLogic {
    
    public static void filterAssetsForlicensing(
        Map<Id, Asset> 		newAssetMap,
        Map<Id, Asset>		oldAssetMap,
        Map<Id, Product2> 	productMap, 
        Boolean 			isUpdate,
        Set<Id>				parentAssetId
    ){
        
        Map<Id, Asset> 			assetDetailsMap 		= new Map<Id, Asset>([ SELECT Id, Account.Country_of_Origin__c FROM Asset WHERE Id IN :newAssetMap.keySet() ]);
        Map<Id, Asset>			filtredAssetMap			= new Map<Id, Asset>();
        Map<Id, Boolean>		assetUpsertBooleanMap	= new Map<Id, Boolean>();
        if(!isUpdate){	/**	Get Assets For Insert	**/
            for( Asset thisRec : newAssetMap.values() ){	/**	Iterate Over Assets to Filter the Valid Assets	**/
                
                /**	Automated License Creation are only applicable for Assets from Renewal Opportunity	**/
                /**	Non GST + Available Plan Tier Assets	**/
                if(thisRec.Create_License_on_Asset_Creation__c){
                    
                    if(productMap.keySet().size() > 0){
                        if(productMap.containsKey(thisRec.Product2Id)){
                            if( productMap.get(thisRec.Product2Id).Is_Applicable_for_Licensing__c ){
                                filtredAssetMap.put(thisRec.Id, thisRec);
                                assetUpsertBooleanMap.put(thisRec.Id, FALSE);
                            }
                        }
                    }
                    
                    /**	Existing GST Plan	**/
                    if( System.Label.Enable_Standard_Plan == 'YES' && thisRec.Asset_Product_Line__c == 'GST' ){
                        if(
                            thisRec.Platform__c == 'App.Clear' && 
                            thisRec.Is_License_Created__c && 
                            thisRec.License_ID__c == NULL
                        ){
                            filtredAssetMap.put(thisRec.Id, thisRec);
                            assetUpsertBooleanMap.put(thisRec.Id, FALSE);
                        }
                    }
                }
            }	/**	Iteration Over	**/
            
            /**	Call License Creation Block	**/
            if(filtredAssetMap.size() > 0){
                //Map<String, QuoteLineItem> qliMap = startDateEndDateValidation(filtredAssetMap.values());
                System.enqueueJob(new CTX_UpsertAssetLicense(filtredAssetMap, NULL, assetUpsertBooleanMap, parentAssetId));
            }
            
            
            
        } else{	/**	Get Assets For Update	**/
            
            List<String> getFieldSetFields 						= getDealClosureFields(System.Label.Update_License_Fieldset);
            List<String> getFieldSetFieldsGCC 					= getDealClosureFields(System.Label.Update_License_Fieldset_GCC);
            set<Id> accountIdsOfAssetToDeactivate 				= new set<Id>();
            Map<String,Id> licenseIdToDeactivateToAccountIdMap 	= new Map<String,Id>();
            Map<Id, Integer> assetIdToExtendedDaysMap 			= new Map<Id, Integer>();
            for(Asset thisRec : newAssetMap.values()){
                
                if((thisRec.Status != oldAssetMap.get(thisRec.Id).Status && (thisRec.Status == 'Churn' || thisRec.Status == 'Sales return')) ||
                  	thisRec.UsageEndDate != oldAssetMap.get(thisRec.Id).UsageEndDate && thisRec.UsageEndDate < System.today() 
                  ){	/**	Asset Deactivation Block	**/
                    if(thisRec.License_Id__c != NULL){
                        licenseIdToDeactivateToAccountIdMap.put(thisRec.License_Id__c, thisRec.AccountId);
                        accountIdsOfAssetToDeactivate.add(thisRec.AccountId);   
                    }
                } else {	/** License Updation Block	**/
                    if(thisRec.License_ID__c != NULL && thisRec.UsageEndDate >= System.today()){
                        
                        List<String> fieldSetFields = 
                            ( assetDetailsMap.get(thisRec.Id).Account.Country_of_Origin__c != NULL && assetDetailsMap.get(thisRec.Id).Account.Country_of_Origin__c != 'India' ) 
                            ? getFieldSetFieldsGCC : getFieldSetFields;
                        
                        for(String fieldName: fieldSetFields){
                            
                            if( 
                                newAssetMap.get(thisRec.Id).get(fieldName) != oldAssetMap.get(thisRec.Id).get(fieldName) ||
                                newAssetMap.get(thisRec.Id).Identity_Resource_Constraints__c !=  oldAssetMap.get(thisRec.Id).Identity_Resource_Constraints__c
                            ){
                                if(fieldName == 'Days_To_Extend__c'){
                                    Integer preveousDaysExtendValue = oldAssetMap.get(thisRec.Id).Days_To_Extend__c == NULL ? 0 : oldAssetMap.get(thisRec.Id).Days_To_Extend__c.IntValue();
                                    Integer newDaysExtendValue 		= thisRec.Days_to_Extend__c == NULL ? 0 : thisRec.Days_to_Extend__c.IntValue();
                                    assetIdToExtendedDaysMap.put(thisRec.Id, newDaysExtendValue);
                                } else {
                                    filtredAssetMap.put(thisRec.Id, thisRec);
                                    assetUpsertBooleanMap.put(thisRec.Id, TRUE);
                                }
                            }

                        }
                        
                    }
                    
                    
                }
            }
            
            if(filtredAssetMap.size() > 0){
                //Map<String, QuoteLineItem> qliMap = startDateEndDateValidation(filtredAssetMap.values());
                System.enqueueJob(new CTX_UpsertAssetLicense(filtredAssetMap, oldAssetMap, assetUpsertBooleanMap, parentAssetId));
            }
            
            if(licenseIdToDeactivateToAccountIdMap.keySet().size() > 0){
                deactivateLicense(licenseIdToDeactivateToAccountIdMap, accountIdsOfAssetToDeactivate, FALSE);
            }
            
            if(assetIdToExtendedDaysMap.keySet().size() > 0){
                //CTX_ExtendProductLicense.extendLicense(assetIdToExtendedDaysMap);
                CTX_ExtendProductLicense updateJob = new CTX_ExtendProductLicense(assetIdToExtendedDaysMap);
                // enqueue the job for processing
                ID jobID = System.enqueueJob(updateJob);
            }
        }
        
        
        
    }
    
    public static List<String> getDealClosureFields(String fieldSetName){
        
        List<String> 	updateOnFields	= new List<String>();
        Schema.FieldSet fieldSet 		= Schema.SObjectType.asset.fieldSets.getMap().get(fieldSetName);             
        
        if( !fieldSet.getFields().isEmpty() ){
            for(Schema.FieldSetMember thisRec : fieldSet.getFields()){
                updateOnFields.add( String.valueOf(thisRec.getSobjectfield()) );
            }
        }
        
        system.debug('updateOnFields: '+updateOnFields);
        return updateOnFields;
    }
    
    /*@future (callout=true)
    public static void deactivateLicense(set<Id> assetIdsToDeactivate){
        List<Asset> assetsToDeactivate = [ SELECT Id, License_Id__c, Status, Account.Country_of_Origin__c FROM Asset WHERE Id IN :assetIdsToDeactivate AND License_Id__c != NULL];
        for(Asset assetRec : assetsToDeactivate){
            if(assetRec.License_Id__c != NULL){
                String region = assetRec.Account?.Country_of_Origin__c != NULL ? assetRec.Account?.Country_of_Origin__c : 'INDIA';
                HttpResponse response = CTX_LicensingAPICalloutClass.deactivateLicenseCallout(assetRec.License_Id__c, region);
                
                if(response.getStatusCode() == 200){
                    
                }
            }
        }
        
        RecursiveTriggerHandler.isFirstTime = FALSE;
        update assetsToDeactivate;
    }*/
    
    @future (callout=true)
    public static void deactivateLicense(Map<String, Id> licenseIdToAccountIdMap, set<Id> accountIds, Boolean isDelete){
        Map<Id, Account> accountMap = new Map<Id,Account>([SELECT Id, Name, Country_of_Origin__c FROM Account WHERE Id IN : accountIds]);
        Map<String, Asset> assetMap = new Map<String, Asset>();
        if(!isDelete){
            for(Asset assetInst : [SELECT Id, License_Id__c FROM Asset WHERE License_Id__c IN : licenseIdToAccountIdMap.keySet() AND License_Id__c != NULL]){
                assetMap.put(assetInst.License_Id__c, assetInst);
            }
        }
        for(String licenseId : licenseIdToAccountIdMap.keySet()){
            String region = accountMap.get(licenseIdToAccountIdMap.get(licenseId)).Country_of_Origin__c != NULL ? accountMap.get(licenseIdToAccountIdMap.get(licenseId)).Country_of_Origin__c : 'INDIA';
            HttpResponse response = CTX_LicensingAPICalloutClass.deactivateLicenseCallout(licenseId, region);
            
            if(response.getStatusCode() == 200){
                if(!isDelete){
                    assetMap.get(licenseId).Force_Deactivate__c  	= TRUE;
                    assetMap.get(licenseId).License_Id__c 			= NULL;
                }
            }
        }
        
        if(assetMap.keySet().size()>0){
            RecursiveTriggerHandler.isFirstTime = FALSE;
            update assetMap.values();
        }
    }
    /*public static Map<String, QuoteLineItem> startDateEndDateValidation (List<Asset> newAssetList) {
        set<Id> quoteIds 	= new set<Id>();
        set<Id> productIds 	= new set<Id>();
        for(Asset assetInst : newAssetList){
            if(assetInst.BackEndQuote__c != NULL){
            	quoteIds.add(assetInst.BackEndQuote__c);   
            }
            
            if(assetInst.product2Id != NULL){
                productIds.add(assetInst.product2Id);
            }
        }
        
        Map<String, QuoteLineItem> qliMap = new Map<String, QuoteLineItem>();
        if(!quoteIds.isEmpty()){
            for(QuoteLineItem qli : [SELECT Id, Product2Id, Period_Start_Date__c, Period_End_Date__c, QuoteId FROM QuoteLineItem WHERE QuoteId IN : quoteIds AND Product2Id IN : productIds]){
                if(!qliMap.containsKey(qli.QuoteId + ':' + qli.Product2Id)){
                	qliMap.put(qli.QuoteId + ':' + qli.Product2Id, qli);   
                }
            }   
        }
        
        return qliMap;
    }*/
    
    
}