/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-14-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class AssetTriggerHandler IMPLEMENTS TriggerInterface{
    
    public void beforeInsert(List<Sobject> listofNewSobjects){
        CTX_IntegrationEscalationHelper.updateAccountARRTypeDetails((List<Asset>) listofNewSobjects);
        //	CTX_AssetEmailTriggersConditions.populateCSMDetailsForAsset( (List<Asset>) listofNewSobjects, NULL);
        
        Map<String, String> 			assetFieldMap 					= new Map<String, String>{
            'Multi_year__c' 		=> 'IsCompetitorProduct',
                'JSON_Store__c' 	=> 'Description', 
                'Billing_Method__c' => 'DigitalAssetStatus', 
                'Is_Test_Asset__c' 	=> 'IsInternal', 
                'License_ID__c' 	=> 'ExternalIdentifier'
                };
                    List<Id> 			ParentIdList 					= 	new List<id>();
        List<Asset> 					listofAssets 					= 	(List<Asset>)listofNewSobjects;
        Set<Id> 						opporId 						= 	new Set<Id>();
        Set<Id> 						prodId 		    				= 	new Set<Id>();
        Set<Id> 						renOpporId 						= 	new Set<Id>();
        //Set<Id> 						opporIdForPOC 					= 	new Set<Id>();
        Map<String, Set<String>>		num_MandatoryFieldMap_NonZero 	= new Map<String, Set<String>>();
        Map<String, Set<String>>		txt_MandatoryFieldMap_NonZero 	= new Map<String, Set<String>>();
        Map<String, Set<String>>		num_MandatoryFieldMap_WithZero 	= new Map<String, Set<String>>();
        String 							type                            ='Asset';
        Map<String, Schema.SObjectType> schemaMap 						= Schema.getGlobalDescribe();
        Schema.SObjectType 				quoteSchema            			= schemaMap.get(type);
        Map<String, Schema.SObjectField>fieldMap 						= quoteSchema.getDescribe().fields.getMap();
        String							errorMessage_Non_Zero			= ' Enter non-zero/non-null values for the following fields: ';
        String							errorMessage_Zero_Allowed		= ' Enter values for the following fields: ';
        Set<Id>							accountIdSet 					= new Set<Id>();
        Set<Id>							accountIdsTestAsset 			= new Set<Id>();
        Map<Id, Account>				accountsMap			 			= new Map<Id, Account>();
        Set<Id>							opportunityIds 					= new Set<Id>();
        
        for(Asset thisAsset : listofAssets){
            
            accountsMap.put(thisAsset.AccountId, NULL);
            
            if(thisAsset.Opportunity__c != NULL){
                opportunityIds.add(thisAsset.Opportunity__c);
            }
            
            if( thisAsset.product2Id != NULL )
                prodId.add(thisAsset.product2Id);
            
            if(thisAsset.Is_Test_Asset__c){
                accountIdsTestAsset.add(thisAsset.AccountId);
                
            }
            
            
            /**	Get Data of Old Fields to New Fields : START	**/
            for( String thisSTR : assetFieldMap.keySet() ){
                if( thisAsset.get(thisSTR) != NULL ){
                    thisAsset.put( assetFieldMap.get(thisSTR), thisAsset.get(thisSTR) );
                }
            }
            /**	Get Data of Old Fields to New Fields : END		**/
            
            thisAsset.StatusReason = thisAsset.Status != NULL ? thisAsset.Status : NULL;
        }  
        
        
        Map<Id, Product2> prodMap = new Map<Id, Product2>(//1
            [ SELECT Id, Name, Product2.Corrected_Module_for_metering__c, Product_Category__c, Product_Line__c 
             FROM product2 WHERE 
             Id IN :prodId ] );
        Map<String, Asset> accountIdExistingAsset = new Map<String, Asset>();
        /**	Make Licensing Changes : START	**/
        /*if(accountIdSet.size() > 0){

for(
Asset thisRec : [ SELECT Id, AccountId, Product_Line__c 
FROM Asset WHERE 
AccountId IN :accountIdSet AND 
( NOT Status IN ('Future', 'Churn', 'Sales return') ) 
ORDER BY UsageEndDate DESC ]
){
String tempString = thisRec.AccountId + thisRec.Product_Line__c;

if(accountIdExistingAsset.containsKey(tempString)){
//accountIdExistingAsset.get(thisRec.AccountId).add(thisRec);
} else{
accountIdExistingAsset.put(tempString, thisRec);
}
}
}*/
        
        /** Added By Niraj for New Asset Parent Tagging Flow **/
        Map<Id,Opportunity> oppMap;
        if(!opportunityIds.isEmpty()){//2
            oppMap = new Map<Id,Opportunity>([SELECT Id, bus_poc__c, RecordTypeId, RecordType.Name, ClearTax_Billing_Entity__c FROM Opportunity WHERE Id IN :opportunityIds]);
            
            CTX_AssetParrentTagging.assetsParentTagging(listofAssets, prodMap, oppMap);
        }
        
        /** Added By Niraj for New Asset Parent Tagging Flow **/
        
        Map<Id,Account> accountMap = new Map<Id, Account>();
        
        if(accountsMap.size() > 0){
            
            for( 
                Account thisRec : [ SELECT Id, Name, Onboarding_Owner__c FROM Account WHERE Id IN : accountsMap.keySet() ]
            ){
                if( accountIdsTestAsset.contains(thisRec.Id) ){
                    accountMap.put(thisRec.Id, thisRec);
                }
                
                accountsMap.put(thisRec.Id, thisRec);
            }
        }
        system.debug('accountsMap: '+accountsMap);
        /**	Make Licensing Changes : END	**/
        
        
        
        for(Asset assetInstance : listofAssets){
            
            /** Exclude End Date on Weekends - NIRAJ 
DateTime endDate = (DateTime)assetInstance.UsageEndDate;
String dayOfWeek = endDate.format('u');
if(dayOfWeek == '6' || dayOfWeek == '7'){
assetInstance.UsageEndDate = assetInstance.UsageEndDate?.addDays(8-Integer.valueOf(dayOfWeek));
}
Exclude End Date on Weekends - NIRAJ **/
            
            if(assetInstance.Is_Test_Asset__c){
                assetInstance.Name = 'DEMO : ' + accountMap?.get(assetInstance.AccountId)?.Name + ' | ' + prodMap?.get(assetInstance.Product2Id)?.Name;
            }
            
            assetInstance.Asset_CSM__c = accountsMap?.get(assetInstance.AccountId).Onboarding_Owner__c;
            system.debug('assetInstance.Asset_CSM__c: '+assetInstance.Asset_CSM__c);
            
            
            /** Commented By Niraj for New Asset Parent Tagging Flow
if(assetInstance.RecordTypeId != AssetConstants.ASSET_INTEGRATION_RECORDTYPEID && assetInstance.ParentId != NULL ){
String tempString = assetInstance.AccountId + assetInstance.Product_Line__c;
if(accountIdExistingAsset.size() > 0 && accountIdExistingAsset.containsKey(tempString)){
assetInstance.ParentId = accountIdExistingAsset.get(tempString)?.Id;
}
}
Commented By Niraj for New Asset Parent Tagging Flow **/
            
            
            if(assetInstance.opportunity__c != NULL && oppMap.ContainsKey(assetInstance?.opportunity__c) && oppMap.get(assetInstance.opportunity__c)?.Bus_POC__c != null){
                //assetInstance.Primary_POC__c = oppMap.get(assetInstance.opportunity__c).Bus_POC__c;
            }
        }
        
        /**	BIBHU : THIS WILL MOVE TO USAGE DETAILS OBJECT : START	**/
        for(//4
            Mandatory_PM__c thisRec : [ SELECT Mandatory_Num_API_Name_Asset__c , Name, Mandatory_Text_API_Name_Asset__c , Mandatory_Num_API_Name_0_Allowed_Asset__c 
                                       FROM Mandatory_PM__c ] 
        ){
            
            if(thisRec.Mandatory_Num_API_Name_Asset__c  != NULL)
                num_MandatoryFieldMap_NonZero.put(thisRec.Name, new Set<String>(thisRec.Mandatory_Num_API_Name_Asset__c.split(',')));
            
            if(thisRec.Mandatory_Text_API_Name_Asset__c != NULL)
                txt_MandatoryFieldMap_NonZero.put(thisRec.Name, new Set<String>(thisRec.Mandatory_Text_API_Name_Asset__c.split(',')));
            
            if(thisRec.Mandatory_Num_API_Name_0_Allowed_Asset__c  != NULL)
                num_MandatoryFieldMap_WithZero.put(thisRec.Name, new Set<String>(thisRec.Mandatory_Num_API_Name_0_Allowed_Asset__c .split(',')));
            
        }
        /**	BIBHU : THIS WILL MOVE TO USAGE DETAILS OBJECT : END	**/
        
        /**	RecordType values assignments	**/
        Id			licenseAssetRecordTypeId
            = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(AssetConstants.RECORD_TYPE_NAME_LICENCED_ASSET).getRecordTypeId();
        for ( //5
            Asset assIns : [ SELECT Id, ParentId,Parent_Asset_2__r.Id ,Parent_Asset_3__r.Id ,Parent_Asset_4__r.Id  FROM Asset WHERE 
                            (ParentId != '' OR Parent_Asset_2__r.Id != '' OR Parent_Asset_3__r.id != '' OR Parent_Asset_4__r.Id != '')  limit 50000] 
        ){
            if(assIns.parentId != NULL)
                ParentIdList.add(assIns.parentId);
            if(assIns.Parent_Asset_2__r.Id != NULL)
                ParentIdList.add(assIns.Parent_Asset_2__r.Id);
            if(assIns.Parent_Asset_3__r.Id != NULL)
                ParentIdList.add(assIns.Parent_Asset_3__r.Id);
            if(assIns.Parent_Asset_4__r.Id != NULL)
                ParentIdList.add(assIns.Parent_Asset_4__r.Id);
        }
        
        for(Asset aIns : listofAssets){
            
            /*if(aIns.License_no_of_irns_per_year__c == NULL){

Decimal b2b = (aIns.License_B2B_SalesInvoice_per_year__c == NULL) ? 0 : aIns.License_B2B_SalesInvoice_per_year__c;
Decimal inv = (aIns.License_no_of_total_Sales_Invoices__c  == NULL) ? 0 : aIns.License_no_of_total_Sales_Invoices__c;

if(b2b > inv)
aIns.License_no_of_irns_per_year__c = b2b;
else
aIns.License_no_of_irns_per_year__c = inv;  

}*/
            
            If( aIns.opportunity__c != NULL )
                opporId.add(aIns.opportunity__c);
            
            if( aIns.Renewal_Opportunity__c != NULL )
                renOpporId.add(aIns.renewal_opportunity__c);
            
            
            
            /*
if(assetMap.get(assetInstance.id).Opportunity__r.Bus_POC__c != null){
Primary_POC__c = assetMap.get(assetInstance.Id).Opportunity__r.bus_poc__c
}
*/
        }
        ///// BIBHU
        
        
        
        
        
        
        
        
        
        
        Map<Id,Opportunity> oppList 	//6
            =	new Map<Id,Opportunity>([ SELECT Id, RecordTypeId, RecordType.Name, CloseDate, ClearTax_Billing_Entity__c,
                                         Billing_F__c, Billing_Frequency__c, Billing_Frequency_for_Integration_Prods__c, 
                                         Legal_Entity_Name_Of_The_Client__c, Billing_Address__c, Shipping_Address__c, 
                                         Place_of_Supply__c, Payment_Method__c, Payment_Term__c, Billing_Method__c,
                                         Bus_POC__c
                                         FROM Opportunity WHERE Id IN :opporId ]);
        Map<Id,Opportunity>	renOppList 	//7
            =	new Map<Id,Opportunity>([ SELECT Id, RecordTypeId, RecordType.Name, CloseDate, ClearTax_Billing_Entity__c
                                         FROM Opportunity WHERE Id IN :renOpporId ]);
        
        for( Asset assIns : (List<asset>)listofNewSobjects ){
            //Added by kartikeya for ID record types
            /** if(assIns.Product2.Product_category__c == ProductConstants.PRODUCT_CATEGORY_INTEGRATION && assIns.Product2.Product_Line__c.equals('Invoice Discounting')){
assIns.RecordTypeId = AssetConstants.ASSET_INTEGRATIONID_RECORDTYPEID;
}
else if(assIns.Product2.Product_Line__c.equals('Invoice Discounting') && (assIns.Product2.Product_Category__c.equals('SaaS') || assIns.Product2.Product_Category__c.equals('Transactional'))){
assIns.RecordTypeId = AssetConstants.ASSET_LICENSEID_RECORDTYPEID;
}**/
            
            if(oppList.containsKey(assIns.Opportunity__c)){
                //assIns.Primary_POC__c = oppList.get(assIns.Opportunity__c).Bus_POC__c;
            }
            
            /**	BIBHU : THIS WILL MOVE TO KAM DETAILS OBJECT : START	**/
            if(prodMap.keySet().contains(assIns.Product2Id) && prodMap.get(assIns.Product2Id).Product_Category__c == 'MS'){
                assIns.MS_Asset__c = TRUE;
                assIns.MS_Contribution__c = 100;
                assIns.MS_Absolute_contribution__c = assIns.Price;
            }/**	BIBHU : THIS WILL MOVE TO KAM DETAILS OBJECT : END	**/
            
            
            
            /**	BIBHU : THIS WILL MOVE TO USAGE DETAILS OBJECT : START	**/
            Boolean 	isError_Zero 		= FALSE;
            Boolean 	isError_Non_Zero 	= FALSE;
            Set<String> mandatory_NonZero 	= new Set<String>();
            Set<String> mandatory_WithZero 	= new Set<String>();
            if( 
                num_MandatoryFieldMap_NonZero.size() > 0			&&
                num_MandatoryFieldMap_NonZero.containsKey(prodMap.get(assIns.product2Id)?.Corrected_Module_for_metering__c)
            ){
                mandatory_NonZero.addAll(num_MandatoryFieldMap_NonZero.get(prodMap.get(assIns.product2Id)?.Corrected_Module_for_metering__c));
            }
            
            if( 
                txt_MandatoryFieldMap_NonZero.size() > 0			&&
                txt_MandatoryFieldMap_NonZero.containsKey(prodMap.get(assIns.product2Id)?.Corrected_Module_for_metering__c)
            ){
                mandatory_NonZero.addAll(txt_MandatoryFieldMap_NonZero.get(prodMap.get(assIns.product2Id)?.Corrected_Module_for_metering__c));
            }
            
            if( 
                num_MandatoryFieldMap_WithZero.size() > 0			&&
                num_MandatoryFieldMap_WithZero.containsKey(prodMap.get(assIns.product2Id)?.Corrected_Module_for_metering__c)
            ){
                mandatory_WithZero.addAll(num_MandatoryFieldMap_WithZero.get(prodMap.get(assIns.product2Id)?.Corrected_Module_for_metering__c));
            }
            /**	Non Zero or Null Value Check	**/
            for(String thisSTR : mandatory_NonZero){
                if(assIns.get(thisSTR) == NULL || assIns.get(thisSTR) == 0 ){
                    String fieldLabel = fieldMap.get(thisSTR).getDescribe().getLabel();
                    errorMessage_Non_Zero += (fieldLabel+' ,');
                    isError_Non_Zero = TRUE;
                } 
            }
            
            /**	Zero allowed Value Check	**/
            for(String thisSTR : mandatory_WithZero){
                if( assIns.get(thisSTR) == NULL  ){
                    String fieldLabel = fieldMap.get(thisSTR).getDescribe().getLabel();
                    errorMessage_Zero_Allowed += (fieldLabel+' ,');
                    isError_Zero = TRUE;
                } 
            }
            
            /**	Remove End	**/
            errorMessage_Non_Zero 		= errorMessage_Non_Zero.removeEnd(' ,');
            errorMessage_Zero_Allowed 	= errorMessage_Zero_Allowed.removeEnd(' ,');
            
            /**	Error Condition Check	**/
            if( isError_Zero && isError_Non_Zero && assIns.Platform__c !='App.Clear' && System.label.Enable_Standard_Plan != 'NO'){
                
            } else if( isError_Zero && assIns.Platform__c !='App.Clear' && System.label.Enable_Standard_Plan != 'NO'){
                
            } else if( isError_Non_Zero && assIns.Platform__c !='App.Clear' && System.label.Enable_Standard_Plan != 'NO'){
                
            } else{
                
            }
            /**	BIBHU : THIS WILL MOVE TO USAGE DETAILS OBJECT : END	**/
            /**	BIBHU : THIS LOGIC IS NOT REQUIRED : START	**/
            if(assIns.opportunity__c != NULL){
                
                opportunity oppUse 									= oppList.get(assIns.opportunity__c);
                assIns.asset_opportunity_type__c 					= oppUse.recordtype.name;
                assIns.deal_closure_date__c 						= oppUse.closeDate;
                assIns.ClearTax_Billing_Entity__c 					= oppUse.ClearTax_Billing_Entity__c;
                assIns.Billing_Address__c							= oppUse.Billing_Address__c;
                assIns.Billing_Frequency_for_Integration_Prods__c	= oppUse.Billing_Frequency_for_Integration_Prods__c;
                assIns.Billing_Frequency_for_Service_Fee_OTP__c 	= oppUse.Billing_Frequency__c;
                assIns.Billing_Frequency_for_Subscription_Fee__c  	= oppUse.Billing_F__c;
                assIns.Billing_Method__c 						  	= oppUse.Billing_Method__c;
                assIns.Legal_Entity_Name_Of_The_Client__c 		  	= oppUse.Legal_Entity_Name_Of_The_Client__c;
                assIns.Place_of_Supply__c 				 		  	= oppUse.Place_of_Supply__c;
                assIns.Shipping_Address__c 				 		  	= oppUse.Shipping_Address__c;
                assIns.Payment_Method__c							= oppUse.Payment_Method__c;
                assIns.Payment_Term__c								= oppUse.Payment_Term__c;
                
            }
            /**	BIBHU : THIS LOGIC IS NOT REQUIRED : END	**/
            
            /**	Asset Status Change Logic : MOVED : BIBHU : START	**/
            If( 
                assIns.PurchaseDate <= Date.Today() && 
                assIns.UsageEndDate >= Date.Today() && 
                (
                    assIns.Status != AssetConstants.STATUS_SALES_RETURN && 
                    assIns.Status != AssetConstants.STATUS_CHURN  && 
                    assIns.Status != AssetConstants.STATUS_UPCOMING_RENEWAL
                )  
                && 
                ( !( 
                    ParentIdList.contains(assIns.Id) && 
                    !assIns.multi_year__c 
                ) &&  
                 !( 
                     ParentIdList.contains(assIns.Id) && 
                     assIns.multi_year__c  && 
                     OppList.get(assIns.renewal_opportunity__c) != null &&  
                     renOppList.get(assIns.renewal_opportunity__c).stageName == OpportunityConstants.STAGENAME_CLOSED_WON 
                 )
                ) 
            ){
                assIns.Status = 'Valid';
            } else If(
                assIns.UsageEndDate < Date.Today() && 
                ( 
                    assIns.Status != AssetConstants.STATUS_SALES_RETURN && 
                    assIns.Status != AssetConstants.STATUS_CHURN  
                )
                && 
                (
                    !( 
                        ParentIdList.contains(assIns.Id) && 
                        !assIns.multi_year__c
                    ) &&  
                    !( 
                        ParentIdList.contains(assIns.Id) && 
                        assIns.multi_year__c  && 
                        OppList.get(assIns.renewal_opportunity__c) != null && 
                        renOppList.get(assIns.renewal_opportunity__c).stageName == OpportunityConstants.STAGENAME_CLOSED_WON 
                    )
                )
            ){
                assIns.Status = 'Expired';
            } 
            else If(
                (
                    (
                        ParentIdList.contains(assIns.Id) &&  
                        assIns.PurchaseDate <= Date.Today() && 
                        assIns.UsageEndDate >= Date.Today() && 
                        assIns.Multi_Year__c  && OppList.get(assIns.renewal_opportunity__c) != null && 
                        renOppList.get(assIns.renewal_opportunity__c).stageName == OpportunityConstants.STAGENAME_CLOSED_WON
                    ) || 
                    (
                        ParentIdList.contains(assIns.Id) &&  
                        assIns.PurchaseDate <= Date.Today() && 
                        assIns.UsageEndDate >= Date.Today() && 
                        !assIns.Multi_Year__c
                    )  
                )
                &&
                (assIns.Status != AssetConstants.STATUS_CHURN && assIns.Status != AssetConstants.STATUS_SALES_RETURN )
            ){
                assIns.Status = AssetConstants.STATUS_VALID_RENEWED;
            } else If( 
                (
                    ( 
                        (assIns.UsageEndDate < Date.Today()) && 
                        ParentIdList.contains(assIns.Id) && 
                        !assIns.Multi_Year__c
                    ) || 
                    ( 
                        (assIns.UsageEndDate < Date.Today() ) && 
                        ParentIdList.contains(assIns.Id) && 
                        assIns.Multi_Year__c  && 
                        OppList.get(assIns.renewal_opportunity__c) != null && 
                        renOppList.get(assIns.renewal_opportunity__c).stageName == OpportunityConstants.STAGENAME_CLOSED_WON
                    ) 
                    
                )
                
                &&
                (assIns.Status != AssetConstants.STATUS_CHURN && assIns.Status != AssetConstants.STATUS_SALES_RETURN )
            ){
                assIns.Status = AssetConstants.RENEWED;
            }   
            else If(
                (
                    assIns.Status != AssetConstants.STATUS_SALES_RETURN && 
                    assIns.Status != AssetConstants.STATUS_CHURN   && 
                    assIns.Status != AssetConstants.STATUS_UPCOMING_RENEWAL )   
                
                && !assIns.is_renewed__c
            ){
                assIns.Status = 'Future';
            } 
        }	/**	Moved : BIBHU : END	**/
        
        
    }
    
    public void afterInsert(List<Sobject> listofNewSobjects,Map<Id,Sobject> mapofNewSObjects){ 
        
        DealClosureQueueable 		 					DQ;
        Map<Id, Map<String,List<Additional_GSTIN__c>>>	opporIdAddGSTMap 	= new Map<Id, Map<String,List<Additional_GSTIN__c>>>();	
        List<Additional_GSTIN__c> 						addGSTINToBeUpdated = new List<Additional_GSTIN__c>();
        Set<String> 									setOfOpp			= new set<string>();
        Set<String> 									setOfOpp1			= new set<string>();        
        Set<String> 									setOfAssets			= new set<string>();
        Set<Id> 										integrationAssetId	= new set<Id>();
        Set<Id> 										integrationOppId	= new set<Id>();
        List<Asset> 									assetsToUpdateList 	= new List<Asset>();
        Set<Id> 										AMC_AssetId			= new set<Id>();
        Set<Id> 										DSC_AssetId			= new set<Id>();
        Set<Id> 										prodId 		    	= new Set<Id>();
        Set<Id>											parentAssetId		= new Set<Id>();
        String 							                Billing_GSTIN		= Schema.SObjectType.Additional_GSTIN__c.getRecordTypeInfosByDeveloperName().get('Billing_GSTIN').getRecordTypeId();
        String 							                Billing_GSTIN_GCC 	= Schema.SObjectType.Additional_GSTIN__c.getRecordTypeInfosByDeveloperName().get('International').getRecordTypeId();
        
        Map<Id, Id>										assetIdLineItemIdMap	= new Map<Id, Id>();
        Map<Id, Asset> 									assetMap				= (Map<Id, Asset>)mapofNewSObjects;
        Map<Id, Asset>									eligableAssetssMap		= new Map<Id, Asset>();		
        /*Deal Closure */
        //8
        Map<Id, Asset> assetExtendedMap = new Map<Id, Asset>([ 
            SELECT Id, Name, AccountId, Account.Is_Auto_Renewal_Enabled__c, Product2Id, Opportunity__r.RecordType.Name 
            FROM Asset WHERE Id IN :mapofNewSObjects.keySet() ]);
        
        
        for(Asset thisAsset : (List<Asset>)listofNewSobjects ){
            
            if( thisAsset.product2Id != NULL )
                prodId.add(thisAsset.product2Id);
            if( thisAsset.ParentId != NULL )
                parentAssetId.add(thisAsset.ParentId);
            if(thisAsset.Related_QLI_Id__c != NULL)
                assetIdLineItemIdMap.put(thisAsset.Related_QLI_Id__c , thisAsset.Id);
            
            if( 
                assetExtendedMap.containsKey(thisAsset.Id) && 
                assetExtendedMap.get(thisAsset.Id).Account.Is_Auto_Renewal_Enabled__c == FALSE && 
                assetExtendedMap.get(thisAsset.Id).Opportunity__r != NULL &&
                !assetExtendedMap.get(thisAsset.Id).Opportunity__r?.RecordType.Name.containsIgnoreCase('Renewal')
            ){
                eligableAssetssMap.put( thisAsset.Id, thisAsset );
            }
            
        }
        
        
        if(assetIdLineItemIdMap.size()>0)
            AssetTriggerHelper.createBillingAndRisk( assetMap.keySet(), assetIdLineItemIdMap );
        
        /** Parent Asset Status Update Flow - Niraj **/
        List<Asset> parentAssetList = new List<Asset>();
        if(parentAssetId.size() > 0){//9
            parentAssetList = [SELECT Id, Name, Status, PurchaseDate, UsageEndDate FROM Asset WHERE Id IN : parentAssetId];
            for(Asset parentAsset : parentAssetList){
                if(parentAsset.purchaseDate <= System.Today() && parentAsset.UsageEndDate >= System.Today() && (parentAsset.Status != 'Churn' && parentAsset.Status != 'Sales Return')){
                    parentAsset.Status = 'Valid & Renewed';
                } else if(parentAsset.UsageEndDate < System.Today() && (parentAsset.Status != 'Churn' && parentAsset.Status != 'Sales Return')){
                    parentAsset.Status = 'Renewed';
                }
            }
        }
        /** Parent Asset Status Update Flow - Niraj **/
        
        Map<Id, Product2> prodMap = new map<Id, Product2>(//10
            [ SELECT Id, Product_Category__c, ProductCode, Name, Family, 
             Plan_Tier__c, Product_Line__c, Is_Applicable_for_Licensing__c,
             Billing_Type__c
             FROM Product2 WHERE Id IN :prodId ]
        );
        /*Deal Closure */
        
        /* Added By Niraj : CSM Journey START*/
        if( eligableAssetssMap.values().size() > 0 ){
            system.enqueueJob( new CTX_CSMJorneyQueueable(eligableAssetssMap, NULL, prodMap, FALSE, parentAssetId) ); 
        }
        /* Added By Niraj : CSM Journey END*/ 
        
        /** if(!test.isRunningTest())
RecursiveTriggerHandler.isFirstTime = FALSE;**/
        
        CTX_ApexRecordSharing.apexShare_Asset_AccountSalesOwnerAccess(
            (Map<Id, Asset>) mapofNewSObjects
        );
        
        CTX_AssetDetailsCapture.getAssetDetails( 
            (List<Asset>) 	listofNewSobjects, 
            (Map<Id,Asset>) mapofNewSObjects
        );
        
        AssetARRSummary.assetARRSummaryMethod(
            mapofNewSObjects.values()
        );
        
        /**	BIBHU : TAKE OUT THIS BLOCK AND CREATE ROLLUP SUMMARY FIELD AS WE STILL HAVE A LIMIT OF 15 : START	**/
        List<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForActiveStatusCount = 
            new List<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition(
                    'COUNT', 
                    'Status',
                    'Number_Of_Assets_Active__c' )
                    };
                        RollUpSummaryUtility.rollUpTrigger(
                            fieldDefinitionsForActiveStatusCount, 
                            trigger.new, 
                            'Asset', 
                            'AccountId', 
                            'Account',
                            'And (Status = \'Active\' OR Status = \'Upcoming Renewal\' OR Status = \'At Risk\')' );
        
        List<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForChurnStatusCount = 
            new List<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition(
                    'COUNT', 
                    'Status',
                    'Number_Of_Assets_Churn__c' )
                    };
                        RollUpSummaryUtility.rollUpTrigger(
                            fieldDefinitionsForChurnStatusCount, 
                            trigger.new, 
                            'Asset', 
                            'AccountId', 
                            'Account',
                            'And Status = \'Churn\' ' );
        
        List<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForPendingStatusCount = 
            new List<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition(
                    'COUNT', 
                    'Status',
                    'Number_Of_Assets_Pending__c' )
                    };
                        RollUpSummaryUtility.rollUpTrigger(
                            fieldDefinitionsForPendingStatusCount, 
                            trigger.new, 
                            'Asset', 
                            'AccountId', 
                            'Account', 
                            'And (Status = \'Inactive\' OR Status = \'Expired\') ' );
        
        List<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForTotalCount = 
            new List<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition(
                    'COUNT', 
                    'Status',
                    'Total_number_Of_Assets__c' )
                    };
                        RollUpSummaryUtility.rollUpTrigger(
                            fieldDefinitionsForTotalCount, 
                            trigger.new, 
                            'Asset', 
                            'AccountId', 
                            'Account',
                            ' ' );
        /**	BIBHU : TAKE OUT THIS BLOCK AND CREATE ROLLUP SUMMARY FIELD AS WE STILL HAVE A LIMIT OF 15 : START	**/
        
        for(Asset tempAsset:(list<asset>)listofNewSobjects){
            
            setOfOpp1.add(tempAsset.Opportunity__c);
            
            if(prodMap.containsKey(tempAsset.Product2Id) && prodMap.get(tempAsset.Product2Id).Product_Category__c == 'AMC' && prodMap.get(tempAsset.Product2Id).Billing_Type__c != 'ARR' ){
                AMC_AssetId.add(tempAsset.Id);
            }
            
            /**	PMT Project - Asset Filter Block : START	**/
            if(tempAsset.RecordTypeId == System.Label.Asset_RecordType_Integration){
                //integrationAssetId.add(tempAsset.Id);
                integrationOppId.add(tempAsset.Opportunity__c);
            }	/**	/**	PMT Project - Asset Filter Block : END	**/
            
            if((tempAsset.RecordTypeId == System.Label.Asset_RecordType_Integration || tempAsset.RecordTypeId == AssetConstants.ASSET_INTEGRATIONID_RECORDTYPEID) && !AMC_AssetId.contains(tempAsset.Id) &&  !System.Label.ExcludeProjectAutoCreation.containsIgnoreCase(prodMap.get(tempAsset.Product2Id).ProductCode)){
                integrationAssetId.add(tempAsset.Id);
            }
            
            if(prodMap.containsKey(tempAsset.Product2Id) && prodMap.get(tempAsset.Product2Id).ProductCode == 'DSC-SIGN'){
                DSC_AssetId.add(tempAsset.Id);
            }
            
        }
        
        /**	PMT Project Creation Block : START	**/
        //11
        Map<Id, Integration_Scope_Add_On__c>	newQLIMap	= new Map<Id, Integration_Scope_Add_On__c>(
            [ SELECT Id, Related_Quote__c, Related_Asset__c, Product_SKU__c, ERP_Family__c
             FROM Integration_Scope_Add_On__c WHERE 
             Related_Opportunity__c IN :integrationOppId AND 
             Related_Quote__r.IsSyncing = TRUE ] );
        
        Map<Id, Asset>			newAssetMap = new Map<Id, Asset>(//12
            [ SELECT Id, AccountId, Opportunity__c, Product2Id, Asset_Type__c, 
             
             Type_of_Integration__c, Type_of_Integration_Project__c, ERP__c,
             
             Account.Name, Type_of_Integration_QLI__c,
             
             Opportunity__r.AccountId, Opportunity__r.Account.Name,
             
             Product2.Name, Product2.OrderForm_Product_Name__c, Price 
             
             FROM Asset WHERE Id IN :integrationAssetId ]
        );
        /**	PMT Project Creation Block : END	**/
        
        //bhaveshjindal
        system.debug('integrationAssetId :: '+integrationAssetId);
        if(integrationAssetId.size()>0){
            AssetTriggerHelper.autoCreateIntegrationProject(integrationAssetId);
        }
        //bhaveshjindal
        system.debug('AMC_AssetId :: '+AMC_AssetId);
        if(AMC_AssetId.size()>0){
            AssetTriggerHelper.autoCreateAmcProject(AMC_AssetId);
        }
        //bhaveshjindal
        system.debug('DSC_AssetId :: '+DSC_AssetId);
        if(DSC_AssetId.size()>0){
            AssetTriggerHelper.autoCreateDSCProject(DSC_AssetId);
        }
        
        Map<Id,Opportunity> oppList 	//13	
            =	new Map<Id,Opportunity>([ SELECT Id, RecordTypeId,Name, RecordType.Name, CloseDate, ClearTax_Billing_Entity__c,Amount,	
                                         Billing_F__c, Billing_Frequency__c, Billing_Frequency_for_Integration_Prods__c, 	
                                         Legal_Entity_Name_Of_The_Client__c, Billing_Address__c, Shipping_Address__c,CIN__c, 	
                                         Place_of_Supply__c, Payment_Method__c, Payment_Term__c, Billing_Method__c,Billing_GST__c,	
                                         Address_Line_2__c,city_2__c,state_2__c,pincode__c,TAN__c,PAN_No_as_per_PO__c,If_SEZ__c, VAT_Number_gcc__c,
                                         cr_number_gcc__c, TIN_Number__c, PO_Required__c, PO_Amount__c, PO_Number__c
                                         FROM Opportunity WHERE Id IN :setOfOpp1 ]);//14	
        List<Additional_GSTIN__c> addGSTINList = [ SELECT id,quote__r.opportunityId,quote_Line_Item__r.product2id,quote_Line_Item__r.period_start_date__c,quote_Line_Item__r.period_end_date__c FROM Additional_GSTIN__c WHERE quote__r.opportunityId in : oppList.keySet() ];	
        for(Additional_GSTIN__c addIns : addGSTINList){	
            List<Additional_GSTIN__c> tempAddList = new List<Additional_GSTIN__c>();	
            Map<String,List<Additional_GSTIN__c>> tempMap = new Map<String,List<Additional_GSTIN__c>>();	
            if(opporIdAddGSTMap.get(addIns.quote__r.opportunityId) == NULL){	
                tempAddList.add(addIns);	
                tempMap.put(addIns.quote_Line_Item__r.product2id+String.ValueOf(addIns.quote_Line_Item__r.period_start_date__c)+String.ValueOf(addIns.quote_Line_Item__r.period_end_date__c),tempAddList);	
                opporIdAddGSTMap.put(addIns.quote__r.opportunityId,tempMap);	
            }	
            else{	
                tempMap =  opporIdAddGSTMap.get(addIns.quote__r.opportunityId);	
                system.debug('map$#$#'+tempMap );	
                system.debug('%$%^'+addIns.quote_Line_Item__r.product2id+String.ValueOf(addIns.quote_Line_Item__r.period_start_date__c)+String.ValueOf(addIns.quote_Line_Item__r.period_end_date__c));	
                If(tempMap.get(addIns.quote_Line_Item__r.product2id+String.ValueOf(addIns.quote_Line_Item__r.period_start_date__c)+String.ValueOf(addIns.quote_Line_Item__r.period_end_date__c)) != null){	
                    tempAddList.addAll(tempMap.get(addIns.quote_Line_Item__r.product2id+String.ValueOf(addIns.quote_Line_Item__r.period_start_date__c)+String.ValueOf(addIns.quote_Line_Item__r.period_end_date__c)));	
                }	
                tempAddList.add(addIns);	
                tempMap.put(addIns.quote_Line_Item__r.product2id+String.ValueOf(addIns.quote_Line_Item__r.period_start_date__c)+String.ValueOf(addIns.quote_Line_Item__r.period_end_date__c),tempAddList);	
                opporIdAddGSTMap.put(addIns.quote__r.opportunityId,tempMap);	
            }	
        }
        
        /** if(!setOfOpp.isEmpty()){
DQ = new DealClosureQueueable(setOfOpp, NULL, TRUE,  TRUE);

} else if(!setOfAssets.isEmpty()){
DQ = new DealClosureQueueable(NULL, setOfAssets, FALSE, TRUE);
}

If(Limits.getQueueableJobs() < 1 && DQ != NULL)
System.enqueueJob(DQ);**/
        
        AssetTriggerHelper.CreateOrder(//15
            [ SELECT Id, product2id, product2.product_category__c, AccountId, PurchaseDate, Price
             FROM Asset WHERE 
             Id IN :trigger.new AND
             product2.product_category__c = 'Integration' AND
             Opportunity__c = NULL ]
        );
        
        /**
Map<Id, Asset> assetMap = new Map<Id, Asset>(
[ SELECT Id, Name, Opportunity__r.Bus_POC__c FROM Asset WHERE ID IN :assetIdSet ]
);
System.debug('assetMap : '+assetMap);	**/
        Map<String, Additional_GSTIN__c> uniqueueGSTINString = new Map<String, Additional_GSTIN__c>();
        for(Asset assetInstance : (List<Asset>)listofNewSobjects){
            
            /**  
if(assetMap.get(assetInstance.id).Opportunity__r.Bus_POC__c != null){
Asset assettoUpdate = new Asset(
Id = assetInstance.Id, 
Primary_POC__c = assetMap.get(assetInstance.Id).Opportunity__r.bus_poc__c
);
assetsToUpdateList.add(assettoUpdate);     
}
Update assetsToUpdateList;
**/
            
            if(assetInstance.Opportunity__c != NULL){
                if(opporIdAddGSTMap.get(assetInstance.Opportunity__c) != NULL){
                    if( 
                        opporIdAddGSTMap.get(assetInstance.Opportunity__c).get(assetInstance.product2id+String.ValueOf(assetInstance.purchaseDate)+String.ValueOf(assetInstance.usageEndDate)) != NULL
                    ){
                        system.debug('TestAddGSTIN :'+opporIdAddGSTMap.get(assetInstance.Opportunity__c).get(assetInstance.product2id+String.ValueOf(assetInstance.purchaseDate)+String.ValueOf(assetInstance.usageEndDate)));	
                        for(
                            Additional_GSTIN__c addIns: opporIdAddGSTMap.get(assetInstance.Opportunity__c).get(assetInstance.product2id+String.ValueOf(assetInstance.purchaseDate)+String.ValueOf(assetInstance.usageEndDate))){	
                                addIns.asset__c = assetInstance.id; 	
                                addGSTINToBeUpdated.add(addIns);	
                            }	
                    } else{	
                        if(!String.isBlank(oppList.get(assetInstance.Opportunity__c).Billing_GST__c)){
                            
                            Additional_GSTIN__c addGSTIN = new Additional_GSTIN__c();
                            addGSTIN.RecordTypeId = Billing_GSTIN;
                            addGSTIN.Name = oppList.get(assetInstance.Opportunity__c).Billing_GST__c;	
                            addGSTIN.Billing_PAN__c = oppList.get(assetInstance.Opportunity__c).PAN_No_as_per_PO__c;
                            addGSTIN.TAN__c = oppList.get(assetInstance.Opportunity__c).TAN__c;
                            addGSTIN.Name_Of_The_Customer__c = oppList.get(assetInstance.Opportunity__c).Legal_Entity_Name_Of_The_Client__c;
                            addGSTIN.SEZ_Yes_No__c = oppList.get(assetInstance.Opportunity__c).If_SEZ__c;
                            addGSTIN.Amount__c = assetInstance.price;	
                            addGSTIN.Asset__c = assetInstance.id;
                            addGSTIN.Opportunity__c = assetInstance.Opportunity__c;
                            addGSTIN.Address__c  = oppList.get(assetInstance.Opportunity__c).Billing_Address__c;	
                            addGSTIN.Address_Line_2__c = oppList.get(assetInstance.Opportunity__c).Address_Line_2__c;	
                            addGSTIN.city__c = oppList.get(assetInstance.Opportunity__c).city_2__c;	
                            addGSTIN.state__c = oppList.get(assetInstance.Opportunity__c).state_2__c;	
                            addGSTIN.pincode__c = oppList.get(assetInstance.Opportunity__c).pincode__c;	
                            addGSTIN.CIN__c  = oppList.get(assetInstance.Opportunity__c).CIN__c;
                            //addGSTIN.GSTIN_Verification_Bypass__c = TRUE;
                            addGSTINToBeUpdated.add(addGSTIN);	
                            
                        }else if(!String.isBlank(oppList.get(assetInstance.Opportunity__c).VAT_Number_gcc__c)){ 
                            
                            Additional_GSTIN__c addGSTIN = new Additional_GSTIN__c();
                            addGSTIN.RecordTypeId = Billing_GSTIN_GCC;
                            addGSTIN.Name = oppList.get(assetInstance.Opportunity__c).VAT_Number_gcc__c;
                            addGSTIN.Name_Of_The_Customer__c = oppList.get(assetInstance.Opportunity__c).Legal_Entity_Name_Of_The_Client__c;
                            addGSTIN.Amount__c = assetInstance.price;	
                            addGSTIN.Asset__c = assetInstance.id;
                            addGSTIN.Opportunity__c = assetInstance.Opportunity__c;
                            addGSTIN.Address__c  = oppList.get(assetInstance.Opportunity__c).Billing_Address__c;	
                            addGSTIN.Address_Line_2__c = oppList.get(assetInstance.Opportunity__c).Shipping_Address__c;	
                            addGSTIN.city__c = oppList.get(assetInstance.Opportunity__c).city_2__c;	
                            addGSTIN.state__c = oppList.get(assetInstance.Opportunity__c).state_2__c;	
                            addGSTIN.pincode__c = oppList.get(assetInstance.Opportunity__c).pincode__c;	
                            addGSTIN.CR_Number__c = oppList.get(assetInstance.Opportunity__c).cr_number_gcc__c;	
                            addGSTIN.TIN_Number__c = oppList.get(assetInstance.Opportunity__c).TIN_Number__c;
                            addGSTIN.Place_of_Supply__c = oppList.get(assetInstance.Opportunity__c).Place_of_Supply__c;
                            addGSTIN.PO_Required__c = oppList.get(assetInstance.Opportunity__c).PO_Required__c;
                            addGSTIN.PO_Amount__c = oppList.get(assetInstance.Opportunity__c).PO_Amount__c;
                            addGSTIN.PO_Number__c = oppList.get(assetInstance.Opportunity__c).PO_Number__c;
                            addGSTINToBeUpdated.add(addGSTIN);	
                        }		
                    }	
                } else{	
                    /**	Primary Billing GSTIN Creation: START 	**/
                    if(!String.isBlank(oppList.get(assetInstance.Opportunity__c).Billing_GST__c)){
                        
                        Additional_GSTIN__c addGSTIN = new Additional_GSTIN__c();
                        addGSTIN.RecordTypeId = Billing_GSTIN;
                        addGSTIN.Name = oppList.get(assetInstance.Opportunity__c).Billing_GST__c;	
                        addGSTIN.Billing_PAN__c = oppList.get(assetInstance.Opportunity__c).PAN_No_as_per_PO__c;
                        addGSTIN.TAN__c = oppList.get(assetInstance.Opportunity__c).TAN__c;
                        addGSTIN.Name_Of_The_Customer__c = oppList.get(assetInstance.Opportunity__c).Legal_Entity_Name_Of_The_Client__c;
                        addGSTIN.SEZ_Yes_No__c = oppList.get(assetInstance.Opportunity__c).If_SEZ__c;
                        addGSTIN.Amount__c = assetInstance.price;	
                        addGSTIN.Asset__c = assetInstance.id;
                        addGSTIN.Opportunity__c = assetInstance.Opportunity__c;
                        addGSTIN.Address__c  = oppList.get(assetInstance.Opportunity__c).Billing_Address__c;	
                        addGSTIN.Address_Line_2__c = oppList.get(assetInstance.Opportunity__c).Address_Line_2__c;	
                        addGSTIN.city__c = oppList.get(assetInstance.Opportunity__c).city_2__c;	
                        addGSTIN.state__c = oppList.get(assetInstance.Opportunity__c).state_2__c;	
                        addGSTIN.pincode__c = oppList.get(assetInstance.Opportunity__c).pincode__c;	
                        addGSTIN.CIN__c  = oppList.get(assetInstance.Opportunity__c).CIN__c;
                        //addGSTIN.GSTIN_Verification_Bypass__c = TRUE;
                        addGSTINToBeUpdated.add(addGSTIN);	
                        
                    }else if(!String.isBlank(oppList.get(assetInstance.Opportunity__c).VAT_Number_gcc__c)){ 
                        /**	International **/
                        Additional_GSTIN__c addGSTIN = new Additional_GSTIN__c();
                        addGSTIN.RecordTypeId = Billing_GSTIN_GCC;
                        addGSTIN.Name = oppList.get(assetInstance.Opportunity__c).VAT_Number_gcc__c;
                        addGSTIN.Name_Of_The_Customer__c = oppList.get(assetInstance.Opportunity__c).Legal_Entity_Name_Of_The_Client__c;
                        addGSTIN.Amount__c = assetInstance.price;	
                        addGSTIN.Asset__c = assetInstance.id;	
                        addGSTIN.Opportunity__c = assetInstance.Opportunity__c;
                        addGSTIN.Address__c  = oppList.get(assetInstance.Opportunity__c).Billing_Address__c;	
                        addGSTIN.Address_Line_2__c = oppList.get(assetInstance.Opportunity__c).Shipping_Address__c;	
                        addGSTIN.city__c = oppList.get(assetInstance.Opportunity__c).city_2__c;	
                        addGSTIN.state__c = oppList.get(assetInstance.Opportunity__c).state_2__c;	
                        addGSTIN.pincode__c = oppList.get(assetInstance.Opportunity__c).pincode__c;	
                        addGSTIN.CR_Number__c = oppList.get(assetInstance.Opportunity__c).cr_number_gcc__c;	
                        addGSTIN.TIN_Number__c = oppList.get(assetInstance.Opportunity__c).TIN_Number__c;
                        addGSTIN.Place_of_Supply__c = oppList.get(assetInstance.Opportunity__c).Place_of_Supply__c;
                        addGSTIN.PO_Required__c = oppList.get(assetInstance.Opportunity__c).PO_Required__c;
                        addGSTIN.PO_Amount__c = oppList.get(assetInstance.Opportunity__c).PO_Amount__c;
                        addGSTIN.PO_Number__c = oppList.get(assetInstance.Opportunity__c).PO_Number__c;
                        
                        String uniqueueKey = assetInstance.Related_QLI_Id__c + addGSTIN.Name;
                        uniqueueGSTINString.put(uniqueueKey, addGSTIN);
                        
                    }
                    
                    
                }	
            }	
        }	
        
        if(!addGSTINToBeUpdated.isEmpty()){
            RecursiveTriggerHandler.isAllowSAPBPCreation = FALSE;
            Upsert addGSTINToBeUpdated;
            RecursiveTriggerHandler.isAllowSAPBPCreation = TRUE;
        } 
        
        if( uniqueueGSTINString.values().size() > 0 ){
            RecursiveTriggerHandler.isAllowSAPBPCreation = FALSE;
            Upsert uniqueueGSTINString.values();
            RecursiveTriggerHandler.isAllowSAPBPCreation = TRUE;
        }
        
        Set<Account> accountsListToUpdateAccountType = new Set<Account>();
        for(Asset thisAsset : (list<Asset>)listofNewSobjects){
            Account acc = new Account(Id = thisAsset.AccountId);
            accountsListToUpdateAccountType.add(acc);
        }
        if(accountsListtoUpdateAccountType.size() > 0){
            Update new List<Account>(accountsListToUpdateAccountType);
        }
        
        /** Parent Asset Status Update Flow - Niraj **/
        if(parentAssetList.size() > 0){
            RecursiveTriggerHandler.isFirstTime = FALSE;
            RecursiveTriggerHandler.isFirstTimeRenewed = FALSE;
            update parentAssetList;
        }
        /** Parent Asset Status Update Flow - Niraj **/
        
        /** SAP Business Partner Upsert Flow Start - Niraj **/
        set<Id> enterpriseAssetId = new Set<Id>();//16
        for(Asset assetInst : [SELECT Id, Account.RecordTypeId, Opportunity__r.ClearTax_Billing_Entity__c, Account.Country_Of_Origin__c FROM Asset WHERE Id IN : assetMap.keySet()]){
            if(assetInst.Account.RecordTypeId == AccountConstants.Enterprise_RecordTypeId && assetInst?.Opportunity__r?.ClearTax_Billing_Entity__c == 'Defmacro' && assetInst?.Account?.Country_Of_Origin__c == 'India'){
                enterpriseAssetId.add(assetInst.Id);
            }
        }
        if(SAP_Integration_Settings__c.getInstance().Enable_SAP_Integration__c){
            if(enterpriseAssetId.size() > 0){
                Database.executeBatch(new CTX_ProcessBusinessPartnerBatch(new List<Id>(enterpriseAssetId)), Integer.ValueOf(System.Label.CTX_ProcessBusinessPartner_BatchSize));  
            }    
        }
        /** SAP Business Partner Upsert Flow END - Niraj **/
        
        //end by bhaveshjindal
        
        //Added by Ashwin - Create upsell
        //System.enqueueJob(new CTX_AutoCreateUpsell((Map<Id,Asset>) mapofNewSObjects));Uncomment
        
        //AssetTriggerHelper.updateAddons((Map<Id,Asset>) mapofNewSObjects);
        
        
    }
    
    public void beforeUpdate(Map<Id,Sobject> mapofNewSobjects,Map<Id,Sobject> mapofOldSobjects){
        
        //	CTX_AssetEmailTriggersConditions.populateCSMDetailsForAsset( (List<Asset>) mapofNewSobjects.values(), (Map<Id,Asset>) mapofOldSobjects);
        Map<String, String> 			assetFieldMap 					= new Map<String, String>{
            'Multi_year__c' 		=> 'IsCompetitorProduct',
                'JSON_Store__c' 	=> 'Description', 
                'Billing_Method__c' => 'DigitalAssetStatus', 
                'Is_Test_Asset__c' 	=> 'IsInternal', 
                'License_ID__c' 	=> 'ExternalIdentifier'
                };
                    CTX_IntegrationEscalationHelper.populateProjectDetailsOnAsset((Map<Id, Asset>) mapofNewSobjects, (Map<Id,Asset>) mapofOldSobjects);
        CTX_IntegrationEscalationHelper.updateAccountARRTypeDetails((List<Asset>) mapofNewSobjects.values());
        
        //List<Asset> ChildAsset=[select id,parentId from asset where parentid != '' limit 50000];
        list<id> ParentIdList = new list<id>();
        for ( //17
            Asset assIns : [ SELECT Id, ParentId,Parent_Asset_2__r.Id ,Parent_Asset_3__r.Id ,Parent_Asset_4__r.Id  FROM Asset WHERE 
                            (ParentId != '' OR Parent_Asset_2__r.Id != '' OR Parent_Asset_3__r.id != '' OR Parent_Asset_4__r.Id != '')  limit 50000] 
        ){
            if(assIns.parentId != NULL)
                ParentIdList.add(assIns.parentId);
            if(assIns.Parent_Asset_2__r.Id != NULL)
                ParentIdList.add(assIns.Parent_Asset_2__r.Id);
            if(assIns.Parent_Asset_3__r.Id != NULL)
                ParentIdList.add(assIns.Parent_Asset_3__r.Id);
            if(assIns.Parent_Asset_4__r.Id != NULL)
                ParentIdList.add(assIns.Parent_Asset_4__r.Id);
        }
        List<Asset> assetListToUpdateOnboardingStatus = new List<Asset>();
        List<Asset> assetListToUpdateOnboardingStage = new List<Asset>();
        List<Asset> assetListToUpdateOnboardingDate = new List<Asset>();
        List<Asset> assetListToUpdateSalesHandoverDate = new List<Asset>();
        List<Asset> assetListToUpdateKickOffDate = new List<Asset>();
        List<Asset> assetListForSalesHandoverSupportNotification = new List<Asset>();
        List<Asset> assetListForOnboardingSessionValidation = new List<Asset>();
        List<Asset> assetListToOnboardingSessionDate = new List<Asset>();
        List<Asset> assetListForOnboardingSessionSupportNotification = new List<Asset>();
        List<Asset> assetListForOnboardingCompletedNotification = new List<Asset>();
        List<Asset> assetListForDatesValidation = new List<Asset>();
        List<Asset> assetListForFeedbackValidation = new List<Asset>();
        List<Asset> assetListToUpdateFeedbackRecievedDate = new List<Asset>();
        Map<String, Set<String>>	num_MandatoryFieldMap_NonZero 	= new Map<String, Set<String>>();
        Map<String, Set<String>>	txt_MandatoryFieldMap_NonZero 	= new Map<String, Set<String>>();
        Map<String, Set<String>>	num_MandatoryFieldMap_WithZero 	= new Map<String, Set<String>>();
        String type                            ='Asset';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType quoteSchema            = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = quoteSchema.getDescribe().fields.getMap();
        String						errorMessage_Non_Zero			= ' Enter non-zero/non-null values for the following fields: ';
        String						errorMessage_Zero_Allowed		= ' Enter values for the following fields: ';
        set<Id>						accountId 						= new set<Id>();
        /**	Get Details from Custom Setting for Module and Mandatory Fields	**/
        //Need to check
        for(//18
            Mandatory_PM__c thisRec : [ SELECT Mandatory_Num_API_Name_Asset__c , Name, Mandatory_Text_API_Name_Asset__c , Mandatory_Num_API_Name_0_Allowed_Asset__c 
                                       FROM Mandatory_PM__c ] 
        ){
            
            if(thisRec.Mandatory_Num_API_Name_Asset__c  != NULL)
                num_MandatoryFieldMap_NonZero.put(thisRec.Name, new Set<String>(thisRec.Mandatory_Num_API_Name_Asset__c.split(',')));
            
            if(thisRec.Mandatory_Text_API_Name_Asset__c != NULL)
                txt_MandatoryFieldMap_NonZero.put(thisRec.Name, new Set<String>(thisRec.Mandatory_Text_API_Name_Asset__c.split(',')));
            
            if(thisRec.Mandatory_Num_API_Name_0_Allowed_Asset__c  != NULL)
                num_MandatoryFieldMap_WithZero.put(thisRec.Name, new Set<String>(thisRec.Mandatory_Num_API_Name_0_Allowed_Asset__c .split(',')));
            
        }
        
        Map<Id, Billing_Details__c> assetIdBillingDetailsMap = new Map<Id, Billing_Details__c>();
        Set<Id> parentAssetIds = new Set<Id>();
        
        for( //19
            Billing_Details__c thisRec : [ SELECt Id, Asset__c, Payment_Amount_Received__c, Outstanding_Payment__c 
                                          FROM Billing_Details__c WHERE 
                                          Asset__c IN :mapofOldSobjects.keySet() ] 
        ){
            assetIdBillingDetailsMap.put(thisRec.Asset__c, thisRec);
        }
        
        
        Map<Id,Asset> statusChangeAsset = new Map<Id,Asset>();
        set<id> opporId = new set<id>();
        for(asset aIns:(List<asset>)mapofNewSobjects.values()){
            Asset AssetNewInstance = (Asset)mapofNewSobjects.get(aIns.Id);
            Asset AssetOldInstance = (Asset)mapofOldSobjects.get(aIns.Id);
            
            if(aIns.License_ID__c != NULL){
                aIns.Force_Deactivate__c = FALSE;
            }
            
            if(!aIns.CSM_Handled_Asset__c && aIns.Onboarding_status__c != 'Onboarding Not Required'){
                aIns.Onboarding_status__c = 'Onboarding Not Required';
            }
            
            /**	Get Data of Old Fields to New Fields : START	**/
            for( String thisSTR : assetFieldMap.keySet() ){
                if( AssetNewInstance.get(thisSTR) != NULL ){
                    AssetNewInstance.put( assetFieldMap.get(thisSTR), AssetNewInstance.get(thisSTR) );
                }
            }
            /**	Get Data of Old Fields to New Fields : END		**/
            
            
            
            
            
            if(AssetNewInstance.AccountId != null){
                accountId.add(AssetNewInstance.AccountId);   
            } 
            
            /** Added By Niraj Start **/
            if(AssetOldInstance.Status != AssetNewInstance.Status && AssetNewInstance.Status == 'Churn'){
                if(String.isBlank(AssetOldInstance.Churn_Reason__c) && String.isBlank(AssetOldInstance.Churn_Level_2_Reason__c) && String.isBlank(AssetOldInstance.Competition_Currently_Using__c) && String.isBlank(AssetOldInstance.Other_Reason_for_Churn__c)){
                    if(!String.isBlank(AssetNewInstance.Churn_Reason__c) && !String.isBlank(AssetNewInstance.Churn_Level_2_Reason__c) && !String.isBlank(AssetNewInstance.Competition_Currently_Using__c) && !String.isBlank(AssetNewInstance.Other_Reason_for_Churn__c)){
                        AssetNewInstance.Status = AssetOldInstance.Status;
                    }
                }
            }
            /** Added By Niraj End **/
            
            if((AssetNewInstance.PurchaseDate != AssetOldInstance.PurchaseDate || AssetNewInstance.Usageenddate != AssetOldInstance.Usageenddate || AssetNewInstance.Price != AssetOldInstance.Price || AssetNewInstance.Product2 != AssetOldInstance.Product2) && !AssetConstants.TASK_APPROVAL && !label.Asset_Edit_Fields_Access.contains(UserInfo.getUserId()) )
                //aIns.addError('Please create a task!');
                If(aIns.opportunity__c != Null)
                opporId.add(aIns.opportunity__c);
            If(aIns.renewal_opportunity__c != Null)
                opporId.add(aIns.renewal_opportunity__c);
            
            //Autopopulate Churn Date
            if(AssetOldInstance.Status != AssetNewInstance.Status 	&& 
               (AssetNewInstance.Status == 'Churn' 					|| 
                AssetNewInstance.Status ==	'Sales return') 		&&
               AssetNewInstance.Churn_Date__c == NULL)
            {
                AssetNewInstance.Churn_Date__c = Date.today();
            }
            
            if(AssetNewInstance.If_Others_in_Activation_Pending__c != AssetOldInstance.If_Others_in_Activation_Pending__c){
                AssetNewInstance.Risk_Update_Date__c = System.today();
            }
            
            
            
            
        }
        
        List<Id> excludeProfileIds = new List<Id>();
        excludeProfileIds.addAll(System.Label.CTX_UsageEndDateValidationExcludeProfile.split(','));//20,21
        map<id,opportunity> oppList =new map<id,opportunity>([select id, recordtypeid,recordtype.name,closeDate,ClearTax_Billing_Entity__c,stageName,name from opportunity where id in:opporId ]);
        Map<Id,Account> accountMap =new Map<Id,Account>([SELECT Id, RecordtypeId, Country_of_Origin__c FROM Account where Id IN :accountId]);
        for(Id tempAssetId : mapofNewSobjects.KeySet()){
            Asset AssetNewInstance = (Asset)mapofNewSobjects.get(tempAssetId);
            Asset AssetOldInstance = (Asset)mapofOldSobjects.get(tempAssetId);
            
            /** Added By Niraj To 21 Days Validation Asset End Date - START **/
            if(AssetNewInstance.UsageEndDate != AssetOldInstance.UsageEndDate && AssetNewInstance.UsageEndDate != NULL){
                /** Added BY Niraj to Exclude Weekend Dates 

DateTime endDate = (DateTime)AssetNewInstance.UsageEndDate;
String dayOfWeek = endDate.format('u');
if(dayOfWeek == '6' || dayOfWeek == '7'){
AssetNewInstance.UsageEndDate = AssetNewInstance.UsageEndDate?.addDays(8-Integer.valueOf(dayOfWeek));
}
Added BY Niraj to Exclude Weekend Dates **/
                if(
                    ( accountMap.get(AssetNewInstance.AccountId)?.Country_of_Origin__c == NULL || 
                     accountMap.get(AssetNewInstance.AccountId)?.Country_of_Origin__c == 'India' ) && 
                    !excludeProfileIds.contains(UserInfo.getProfileId()) && AssetNewInstance.License_Id__c != NULL
                )
                {
                    if(AssetOldInstance.UsageEndDate?.daysBetween(AssetNewInstance.UsageEndDate) > 21){
                        Date maxEndDateAllowed = AssetOldInstance.UsageEndDate;
                        for(Integer i= 1 ; i < 21; ){
                            maxEndDateAllowed = maxEndDateAllowed.addDays(1); 
                            DateTime maxAllowedDateTime = maxEndDateAllowed;
                            if(maxAllowedDateTime.format('u') != '6' && maxAllowedDateTime.format('u') != '7'){ 
                                i++;
                            }
                        }
                        
                        if(AssetNewInstance.UsageEndDate > maxEndDateAllowed){
                            AssetNewInstance.addError('Can not extend Period End Date beyond 21 working days.');                	    
                        }
                    }   
                }
            }
            /** Added By Niraj To 21 Days Validation Asset End Date - END **/
            
            /*Commeneted by Raksha 
if( AssetNewInstance.Usage_status__c  !=  AssetOldInstance.Usage_status__c  ){
statusChangeAsset.Put(AssetNewInstance.Id, AssetNewInstance);
}*/
            //Added by kartikeya for ID record types
            /**  if(AssetNewInstance.Product2.Product_category__c == ProductConstants.PRODUCT_CATEGORY_INTEGRATION && AssetNewInstance.Product2.Product_Line__c.equals('Invoice Discounting')){
AssetNewInstance.RecordTypeId = AssetConstants.ASSET_INTEGRATIONID_RECORDTYPEID;
}
else if(AssetNewInstance.Product2.Product_Line__c.equals('Invoice Discounting') && (AssetNewInstance.Product2.Product_Category__c.equals('SaaS') || AssetNewInstance.Product2.Product_Category__c.equals('Transactional'))){
AssetNewInstance.RecordTypeId = AssetConstants.ASSET_LICENSEID_RECORDTYPEID;
}*/
            //End By Kartikeya 
            if( AssetNewInstance.opportunity__c != AssetOldInstance.opportunity__c && AssetNewInstance.opportunity__c != null ){
                opportunity oppUse = oppList.get(AssetNewInstance.opportunity__c);
                AssetNewInstance.asset_opportunity_type__c = oppUse.recordtype.name;
                AssetNewInstance.deal_closure_date__c = oppUse.closeDate;
                AssetNewInstance.ClearTax_Billing_Entity__c = oppUse.ClearTax_Billing_Entity__c;
            } 
            //Added by Raksha
            if(AssetNewInstance.Onboarding_status__c != AssetOldInstance.Onboarding_status__c && 
               AssetNewInstance.Onboarding_status__c == AssetConstants.ONBOARDING_STATUS_ONBOARDING_COMPLETED && 
               AssetOldInstance.Onboarding_status__c != AssetConstants.ONBOARDING_STATUS_ONBOARDING_COMPLETED){
                   AssetNewInstance.Onboarding_Completed_Date__c = System.today();
                   AssetNewInstance.Status = AssetConstants.STATUS_ACTIVE;
               }
            if(AssetNewInstance.Integration_status__c != AssetOldInstance.Integration_status__c && 
               AssetNewInstance.Integration_status__c == AssetConstants.INTEGRATION_STATUS_PROJECT_COMPLETED && 
               AssetOldInstance.Integration_status__c != AssetConstants.INTEGRATION_STATUS_PROJECT_COMPLETED ){
                   AssetNewInstance.Integration_Completed_Date__c = System.today();
                   AssetNewInstance.Status = AssetConstants.STATUS_ACTIVE;
               }
            
            
            
            
            
            
            
            
            If(AssetNewInstance.PurchaseDate <= Date.Today() && AssetNewInstance.UsageEndDate >= Date.Today() && ((AssetOldInstance.Status != AssetConstants.STATUS_SALES_RETURN && AssetNewInstance.Status != AssetConstants.STATUS_SALES_RETURN)  && (AssetOldInstance.Status != AssetConstants.STATUS_CHURN && AssetNewInstance.Status != AssetConstants.STATUS_CHURN)  && AssetNewInstance.Status != AssetConstants.STATUS_UPCOMING_RENEWAL) 
               && ( !(ParentIdList.contains(AssetNewInstance.Id) && !AssetNewInstance.multi_year__c ) &&  !(ParentIdList.contains(AssetNewInstance.Id) && AssetNewInstance.multi_year__c  && OppList.get(AssetNewInstance.renewal_opportunity__c) != null && OppList.get(AssetNewInstance.renewal_opportunity__c).stageName == OpportunityConstants.STAGENAME_CLOSED_WON) && !AssetNewInstance.is_renewed__c )){
                   AssetNewInstance.Status = 'Valid';
                   system.debug('Inside Valid Block');
               } else If(AssetNewInstance.UsageEndDate < Date.Today() && ((AssetOldInstance.Status != AssetConstants.STATUS_SALES_RETURN && AssetNewInstance.Status != AssetConstants.STATUS_SALES_RETURN)  && (AssetOldInstance.Status != AssetConstants.STATUS_CHURN && AssetNewInstance.Status != AssetConstants.STATUS_CHURN) ) 
                         && (!( ParentIdList.contains(AssetNewInstance.Id) && !AssetNewInstance.multi_year__c) &&  !(ParentIdList.contains(AssetNewInstance.Id) && AssetNewInstance.multi_year__c && OppList.get(AssetNewInstance.renewal_opportunity__c) != null && OppList.get(AssetNewInstance.renewal_opportunity__c).stageName == OpportunityConstants.STAGENAME_CLOSED_WON) && !AssetNewInstance.is_renewed__c )){
                             AssetNewInstance.Status = 'Expired';
                             system.debug('Inside Expired Block');
                         } else If(
                             (
                                 (ParentIdList.contains(AssetNewInstance.Id) &&  AssetNewInstance.PurchaseDate <= Date.Today() && AssetNewInstance.UsageEndDate >= Date.Today() && AssetNewInstance.Multi_Year__c  && OppList.get(AssetNewInstance.renewal_opportunity__c) != null && OppList.get(AssetNewInstance.renewal_opportunity__c).stageName == OpportunityConstants.STAGENAME_CLOSED_WON) || (ParentIdList.contains(AssetNewInstance.Id) &&  AssetNewInstance.PurchaseDate <= Date.Today() && AssetNewInstance.UsageEndDate >= Date.Today() && !AssetNewInstance.Multi_Year__c) 
                                 || (AssetNewInstance.PurchaseDate <= Date.Today() && AssetNewInstance.UsageEndDate >= Date.Today() && !AssetNewInstance.Multi_Year__c && AssetNewInstance.is_renewed__c )  
                             )
                             &&
                             (AssetNewInstance.Status != AssetConstants.STATUS_CHURN && AssetNewInstance.Status != AssetConstants.STATUS_SALES_RETURN )
                         ){
                             AssetNewInstance.Status = AssetConstants.STATUS_VALID_RENEWED;
                             system.debug('Inside Valid & Renewed Block');
                         } else If( 
                             (
                                 ( ( AssetNewInstance.PurchaseDate <= Date.Today()) && ParentIdList.contains(AssetNewInstance.Id) && !AssetNewInstance.Multi_Year__c) || 
                                 ( (AssetNewInstance.UsageEndDate < Date.Today() ) && ParentIdList.contains(AssetNewInstance.Id) && AssetNewInstance.Multi_Year__c  
                                  && OppList.get(AssetNewInstance.renewal_opportunity__c) != null 
                                  && OppList.get(AssetNewInstance.renewal_opportunity__c).stageName == OpportunityConstants.STAGENAME_CLOSED_WON) 
                                 || ( ( AssetNewInstance.PurchaseDate <= Date.Today()) && AssetNewInstance.is_renewed__c && !AssetNewInstance.Multi_Year__c) 
                             )
                             &&
                             (AssetNewInstance.Status != AssetConstants.STATUS_CHURN && AssetNewInstance.Status != AssetConstants.STATUS_SALES_RETURN )
                             
                         ){
                             AssetNewInstance.Status = AssetConstants.RENEWED;
                             system.debug('Inside Renewed Block');
                         } else If(((AssetOldInstance.Status != AssetConstants.STATUS_SALES_RETURN && AssetNewInstance.Status != AssetConstants.STATUS_SALES_RETURN)  && (AssetOldInstance.Status != AssetConstants.STATUS_CHURN && AssetNewInstance.Status != AssetConstants.STATUS_CHURN)   && AssetNewInstance.Status != AssetConstants.STATUS_UPCOMING_RENEWAL )  
                                   && !AssetNewInstance.is_renewed__c){
                                       AssetNewInstance.Status = 'Future';
                                   }
            
            if( 
                ( 
                    AssetNewInstance.StatusReason == 'Future Churn' || 
                    AssetNewInstance.StatusReason == 'Non Payment Suspended' 
                ) && 
                ( 
                    AssetNewInstance.Status != AssetConstants.STATUS_SALES_RETURN || 
                    AssetNewInstance.Status != AssetConstants.STATUS_CHURN || 
                    AssetNewInstance.Status != AssetConstants.STATUS_VALID_RENEWED ||
                    AssetNewInstance.Status != 'Expired'
                )
            ){
                // No Action
            } else{
                if(AssetNewInstance.StatusReason == 'Future Churn'){
                    AssetNewInstance.Status = 'Churn';
                    AssetNewInstance.Churn_Date__c = system.today();
                }
            }
            
            if( AssetNewInstance.StatusReason != 'Future Churn' && AssetNewInstance.StatusReason != 'Non Payment Suspended' ){
                AssetNewInstance.StatusReason = AssetNewInstance.Status;// Valid => StatusReason == Future Churn
            } else{
                if( AssetNewInstance.Status == 'Expired' || AssetNewInstance.Status == 'Renewed' ){
                    AssetNewInstance.Status = 'Churn';
                    AssetNewInstance.Churn_Date__c = system.today();
                }
            }
            
            
            system.debug('AssetNewInstance.StatusReason: '+AssetNewInstance.StatusReason);
            system.debug('AssetOldInstance.StatusReason: '+AssetOldInstance.StatusReason);
            /**	FUTURE CHURN : Condition START	**/
            if( AssetNewInstance.StatusReason == 'Future Churn' && AssetNewInstance.StatusReason != AssetOldInstance.StatusReason ){
                
                if( 
                    assetIdBillingDetailsMap.get(AssetNewInstance.Id).Payment_Amount_Received__c >= (AssetNewInstance.Price*.90) 
                    ||
                    ( 
                        ( assetIdBillingDetailsMap.get(AssetNewInstance.Id).Payment_Amount_Received__c == NULL || 
                         assetIdBillingDetailsMap.get(AssetNewInstance.Id).Payment_Amount_Received__c == 0 ) && 
                        ( assetIdBillingDetailsMap.get(AssetNewInstance.Id).Outstanding_Payment__c  == NULL || 
                         assetIdBillingDetailsMap.get(AssetNewInstance.Id).Outstanding_Payment__c  == 0 )
                    )
                ){
                    
                } else{
                    AssetNewInstance.addError('Future Churn can not be marked in case of outstanding amount');
                }
            }
            
            if( AssetNewInstance.StatusReason == 'Future Churn' && AssetNewInstance.StatusReason != AssetOldInstance.StatusReason ){
                AssetNewInstance.Churn_Date__c = system.today();
            }
            /**	FUTURE CHURN : Condition END	**/
            
            
            
            //End by Raksha
            
            //Bhavesh Jindal: CSM Flow Block: START
            
            System.debug('AssetNewInstance.Sales_handover_status__c'+AssetNewInstance.Sales_handover_status__c);
            System.debug('AssetOldInstance.Sales_handover_status__c'+AssetOldInstance.Sales_handover_status__c);
            
            if(AssetNewInstance.Sales_handover_status__c != AssetOldInstance.Sales_handover_status__c
               || AssetNewInstance.Onboarding_session_status__c  != AssetOldInstance.Onboarding_session_status__c ){
                   assetListToUpdateOnboardingStatus.add(AssetNewInstance);
               }
            if(AssetNewInstance.Sales_handover_status__c != AssetOldInstance.Sales_handover_status__c
               || AssetNewInstance.Kick_off_status__c   != AssetOldInstance.Kick_off_status__c 
               || AssetNewInstance.Onboarding_session_status__c  != AssetOldInstance.Onboarding_session_status__c){
                   assetListToUpdateOnboardingStage.add(AssetNewInstance);
               }
            if(AssetNewInstance.Sales_handover_start_date__c != AssetOldInstance.Sales_handover_start_date__c
               || AssetNewInstance.Last_Onboarding_session_date__c != AssetOldInstance.Last_Onboarding_session_date__c ){
                   assetListToUpdateOnboardingDate.add(AssetNewInstance);
               }
            if(AssetNewInstance.Sales_handover_status__c != AssetOldInstance.Sales_handover_status__c){
                assetListToUpdateSalesHandoverDate.add(AssetNewInstance);
            }
            if(AssetNewInstance.Kick_off_status__c  != AssetOldInstance.Kick_off_status__c ){
                assetListToUpdateKickOffDate.add(AssetNewInstance);
            }
            if(AssetNewInstance.Support_required_on_sales_handover__c != AssetOldInstance.Support_required_on_sales_handover__c 
               && AssetNewInstance.Support_required_on_sales_handover__c != NULL){
                   assetListForSalesHandoverSupportNotification.add(AssetNewInstance);
               }
            
            System.debug('AssetNewInstance.Onboarding_session_status__c' + AssetNewInstance.Onboarding_session_status__c);
            System.debug('AssetOldInstance.Onboarding_session_status__c' + AssetOldInstance.Onboarding_session_status__c);
            
            if(AssetNewInstance.Onboarding_session_status__c != AssetOldInstance.Onboarding_session_status__c 
               || AssetNewInstance.Onboarding_session_start_date__c   != AssetOldInstance.Onboarding_session_start_date__c   
               || AssetNewInstance.Last_Onboarding_session_date__c  != AssetOldInstance.Last_Onboarding_session_date__c  
               || AssetNewInstance.Onboarding_pending_reason_15_days__c  != AssetOldInstance.Onboarding_pending_reason_15_days__c  
               || AssetNewInstance.Support_required_on_onboarding__c  != AssetOldInstance.Support_required_on_onboarding__c 
               ||AssetNewInstance.Features_covered_in_onboarding__c   != AssetOldInstance.Features_covered_in_onboarding__c ){
                   
                   System.debug('Onboarding_session_validation_Entered');
                   assetListForOnboardingSessionValidation.add(AssetNewInstance);
               }
            if(AssetNewInstance.Onboarding_session_status__c != AssetOldInstance.Onboarding_session_status__c){
                assetListToOnboardingSessionDate.add(AssetNewInstance);
            }
            if(AssetNewInstance.Support_required_on_onboarding__c != AssetOldInstance.Support_required_on_onboarding__c 
               && AssetNewInstance.Support_required_on_onboarding__c != NULL){
                   assetListForOnboardingSessionSupportNotification.add(AssetNewInstance);
               }
            if(AssetNewInstance.Onboarding_status__c != AssetOldInstance.Onboarding_status__c 
               || AssetNewInstance.Onboarding_session_status__c != AssetOldInstance.Onboarding_session_status__c){
                   assetListForOnboardingCompletedNotification.add(AssetNewInstance);
               }
            if(AssetNewInstance.Sales_handover_start_date__c != AssetOldInstance.Sales_handover_start_date__c 
               || AssetNewInstance.Sales_handover_end_date__c != AssetOldInstance.Sales_handover_end_date__c 
               || AssetNewInstance.Kick_off_start_date__c != AssetOldInstance.Kick_off_start_date__c 
               || AssetNewInstance.Kick_off_end_date__c != AssetOldInstance.Kick_off_end_date__c 
               || AssetNewInstance.Onboarding_session_start_date__c   != AssetOldInstance.Onboarding_session_start_date__c   
               || AssetNewInstance.Last_Onboarding_session_date__c  != AssetOldInstance.Last_Onboarding_session_date__c){
                   assetListForDatesValidation.add(AssetNewInstance);
               }
            if(AssetNewInstance.Rate_the_overall_on_boarding__c != AssetOldInstance.Rate_the_overall_on_boarding__c 
               || AssetNewInstance.Feedback_Received_Date__c != AssetOldInstance.Feedback_Received_Date__c  
               || AssetNewInstance.Suggestions_to_improve_onboarding__c != AssetOldInstance.Suggestions_to_improve_onboarding__c  
               || AssetNewInstance.Do_you_feel_comfortable_handling_Filing__c != AssetOldInstance.Do_you_feel_comfortable_handling_Filing__c  
               || AssetNewInstance.Do_you_feel_comfortable_generating_IRN__c != AssetOldInstance.Do_you_feel_comfortable_generating_IRN__c	 
               || AssetNewInstance.Rate_product_knowledge_subject_matter__c  != AssetOldInstance.Rate_product_knowledge_subject_matter__c  
               || AssetNewInstance.Rate_the_pre_onboarding_process__c  != AssetOldInstance.Rate_the_pre_onboarding_process__c  
               || AssetNewInstance.Rate_the_on_boarding_prese__c   != AssetOldInstance.Rate_the_on_boarding_prese__c     
               || AssetNewInstance.Rate_the_query_resolution_support__c   != AssetOldInstance.Rate_the_query_resolution_support__c     
               || AssetNewInstance.Pace_of_onboarding__c   != AssetOldInstance.Pace_of_onboarding__c 
               || AssetNewInstance.Product_retraining_needed__c    != AssetOldInstance.Product_retraining_needed__c ){
                   assetListForFeedbackValidation.add(AssetNewInstance);
               }
            if(AssetNewInstance.Rate_the_overall_on_boarding__c != AssetOldInstance.Rate_the_overall_on_boarding__c){
                assetListToUpdateFeedbackRecievedDate.add(AssetNewInstance);
            }
            //Bhavesh Jindal: CSM Flow Block: END
            
        }	
        /*Commeneted by Raksha
AssetTriggerHelper.activeStatusChange(statusChangeAsset);*/ 
        
        //Bhavesh Jindal: CSM Flow Block: START	
        ///*
        //
        
        /** Commented By Niraj - Old CSM Flow Start **/
        
        /*
if(assetListToUpdateOnboardingStatus.size() > 0){
CTX_CSMFlowHandler.updateOnboardingStatus(assetListToUpdateOnboardingStatus);
}
if(assetListToUpdateOnboardingStage.size() > 0){
CTX_CSMFlowHandler.updateOnboardingStage(assetListToUpdateOnboardingStage);
}
if(assetListToUpdateSalesHandoverDate.size() > 0){
CTX_CSMFlowHandler.updateSalesHandoverDate(assetListToUpdateSalesHandoverDate);
}
if(assetListToUpdateOnboardingDate.size() > 0){
CTX_CSMFlowHandler.updateOnboardingDate(assetListToUpdateOnboardingDate);
}
if(assetListToUpdateKickOffDate.size() > 0){
CTX_CSMFlowHandler.updateKickOffDate(assetListToUpdateKickOffDate);
}
if(assetListForSalesHandoverSupportNotification.size() > 0){
CTX_CSMFlowHandler.salesHandoverSupportNotification(assetListForSalesHandoverSupportNotification);
}	
if(assetListForOnboardingSessionValidation.size() > 0){
CTX_CSMFlowHandler.onboardingSessionValidation(assetListForOnboardingSessionValidation);
}
if(assetListToOnboardingSessionDate.size() > 0){
CTX_CSMFlowHandler.updateOnboardingSessionDate(assetListToOnboardingSessionDate);
}
if(assetListForOnboardingSessionSupportNotification.size() > 0){
CTX_CSMFlowHandler.onboardingSessionSupportNotification(assetListForOnboardingSessionSupportNotification);
}
if(assetListForOnboardingCompletedNotification.size() > 0){
CTX_CSMFlowHandler.onboardingSessionCompletedNotification(assetListForOnboardingCompletedNotification);
}
if(assetListForDatesValidation.size() > 0){
CTX_CSMFlowHandler.datesValidation(assetListForDatesValidation);
}
if(assetListForFeedbackValidation.size() > 0){
CTX_CSMFlowHandler.feedbackFormValidation(assetListForFeedbackValidation);
}
if(assetListToUpdateFeedbackRecievedDate.size() > 0){
CTX_CSMFlowHandler.updateFeedbackRecievedDate(assetListToUpdateFeedbackRecievedDate);
}
*/
        
        /** Commented By Niraj - Old CSM Flow END **/
        
        //Bhavesh Jindal: CSM Flow Block: END	
        //*/
        
        //bhaveshjindal
        //clear churn related fields when status changed back from churn to other
        /**	Get AssetId and Asset Module Details	**/
        //22
        for(asset assIns : [SELECT id, Account.Onboarding_Owner__c, product2.Corrected_Module_for_metering__c,product2.name,status,Churn_Date__c,
                            Churn_Reason__c,First_Churn_Reason_L1__c,First_Churn_Reason_L2__c,First_Churn_Reason_L3__c,
                            Other_Reason_for_Churn__c,Billed_Upto__c,Competition_Currently_Using__c
                            FROM asset WHERE id in: mapofNewSobjects.KeySet()]){
                                
                                Asset AssetInstanceNew = (Asset)mapofNewSobjects.get(assIns.id);
                                Asset AssetInstanceOld = (Asset)mapofOldSobjects.get(assIns.id);
                                if(AssetInstanceNew.status != AssetInstanceOld.status && AssetInstanceOld.status == 'Churn'){
                                    AssetInstanceNew.Churn_Date__c = NULL;
                                    AssetInstanceNew.Churn_Reason__c ='';
                                    AssetInstanceNew.StatusReason =AssetInstanceNew.Status;
                                    AssetInstanceNew.First_Churn_Reason_L1__c  ='';
                                    AssetInstanceNew.First_Churn_Reason_L2__c  ='';
                                    AssetInstanceNew.First_Churn_Reason_L3__c  ='';
                                    AssetInstanceNew.Other_Reason_for_Churn__c ='';
                                    AssetInstanceNew.Billed_Upto__c = NULL;
                                    AssetInstanceNew.Competition_Currently_Using__c ='';	
                                }
                                
                                
                                
                                //Added by Kartikeya- for Mandatory PM logic
                                Boolean 	isError_Zero 		= FALSE;
                                Boolean 	isError_Non_Zero 	= FALSE;
                                Set<String> mandatory_NonZero 	= new Set<String>();
                                Set<String> mandatory_WithZero 	= new Set<String>();
                                if(	
                                    AssetInstanceNew.License_No_of_B2B_sales_invoices_used__c 					!= AssetInstanceOld.License_No_of_B2B_sales_invoices_used__c 					||
                                    AssetInstanceNew.License_No_of_B2C_sales_invoices_used__c 					!= AssetInstanceOld.License_No_of_B2C_sales_invoices_used__c 					||
                                    AssetInstanceNew.License_No_of_GSTINs_used__c  					!= AssetInstanceOld.License_No_of_GSTINs_used__c  					||
                                    AssetInstanceNew.License_No_of_PANs_used__c  					!= AssetInstanceOld.License_No_of_PANs_used__c  						||
                                    //AssetInstanceNew.License_No_of_Users_ids_used__c  				!= AssetInstanceOld.License_No_of_Users_ids_used__c  					||
                                    AssetInstanceNew.No_of_airline_invoices_annual__c  != AssetInstanceOld.No_of_airline_invoices_annual__c	||
                                    AssetInstanceNew.No_of_airline_invoices__c  				!=AssetInstanceOld.No_of_airline_invoices__c  				||
                                    AssetInstanceNew.License_No_of_purchase_invoices_used__c  			!= AssetInstanceOld.License_No_of_purchase_invoices_used__c  			||
                                    //AssetInstanceNew.Zone__c 								!= AssetInstanceOld.Zone__c 								||
                                    AssetInstanceNew.Type_of_Integration__c 				!= AssetInstanceOld.Type_of_Integration__c ||
                                    AssetInstanceNew.Type_of_Integration_QLI__c				!= AssetInstanceOld.Type_of_Integration_QLI__c ||
                                    AssetInstanceNew.License_No_of_EWBs_used__c             != AssetInstanceOld.License_No_of_EWBs_used__c
                                ){
                                    if( 
                                        num_MandatoryFieldMap_NonZero.size() > 0			&&
                                        num_MandatoryFieldMap_NonZero.containsKey(assIns.product2.Corrected_Module_for_metering__c)
                                    ){
                                        mandatory_NonZero.addAll(num_MandatoryFieldMap_NonZero.get(assIns.product2.Corrected_Module_for_metering__c));
                                    }
                                    
                                    if( 
                                        txt_MandatoryFieldMap_NonZero.size() > 0			&&
                                        txt_MandatoryFieldMap_NonZero.containsKey(assIns.product2.Corrected_Module_for_metering__c)
                                    ){
                                        mandatory_NonZero.addAll(txt_MandatoryFieldMap_NonZero.get(assIns.product2.Corrected_Module_for_metering__c));
                                    }
                                    
                                    if( 
                                        num_MandatoryFieldMap_WithZero.size() > 0			&&
                                        num_MandatoryFieldMap_WithZero.containsKey(assIns.product2.Corrected_Module_for_metering__c)
                                    ){
                                        mandatory_WithZero.addAll(num_MandatoryFieldMap_WithZero.get(assIns.product2.Corrected_Module_for_metering__c));
                                    }
                                    /**	Non Zero or Null Value Check	**/
                                    for(String thisSTR : mandatory_NonZero){
                                        if(AssetInstanceNew.get(thisSTR) == NULL || AssetInstanceNew.get(thisSTR) == 0 ){
                                            String fieldLabel = fieldMap.get(thisSTR).getDescribe().getLabel();
                                            errorMessage_Non_Zero += (fieldLabel+' ,');
                                            isError_Non_Zero = TRUE;
                                            // mapOfNewIdWithQuotes.get(quotekey).addError(thisSTR,'Enter non-zero value for this field');
                                        } 
                                    }
                                    
                                    /**	Zero allowed Value Check	**/
                                    for(String thisSTR : mandatory_WithZero){
                                        if( AssetInstanceNew.get(thisSTR) == NULL  ){
                                            String fieldLabel = fieldMap.get(thisSTR).getDescribe().getLabel();
                                            errorMessage_Zero_Allowed += (fieldLabel+' ,');
                                            isError_Zero = TRUE;
                                            // mapOfNewIdWithQuotes.get(quotekey).addError(thisSTR,'Enter value for this field');
                                        } 
                                    }
                                    
                                    /**	Remove End	**/
                                    errorMessage_Non_Zero 		= errorMessage_Non_Zero.removeEnd(' ,');
                                    errorMessage_Zero_Allowed 	= errorMessage_Zero_Allowed.removeEnd(' ,');
                                    
                                    /**	Error Condition Check	**/
                                    if( isError_Zero && isError_Non_Zero && AssetInstanceNew.Platform__c !='App.Clear'){
                                        AssetInstanceNew.adderror(errorMessage_Non_Zero + ' & ' +errorMessage_Zero_Allowed,false);
                                    } else if( isError_Zero  && AssetInstanceNew.Platform__c !='App.Clear'){
                                        AssetInstanceNew.adderror(errorMessage_Zero_Allowed);
                                    } else if( isError_Non_Zero && AssetInstanceNew.Platform__c !='App.Clear'){
                                        AssetInstanceNew.adderror(errorMessage_Non_Zero );
                                    } else{
                                        /**	No Error	**/
                                    }
                                    
                                    
                                }
                                
                                AssetInstanceNew.Asset_CSM__c = AssetInstanceNew.Account.Onboarding_Owner__c;
                                system.debug('AssetInstanceNew.Asset_CSM__c: '+AssetInstanceNew.Asset_CSM__c);
                            }
        
        /**bhaveshjindal
//churn date restrictions
for(Id assetInstanceID : mapofNewSobjects.KeySet()){
Asset AssetInstanceNew = (Asset)mapofNewSobjects.get(assetInstanceID);
Asset AssetInstanceOld = (Asset)mapofOldSobjects.get(assetInstanceID);

//ctxpopulate churn date
if(AssetInstanceNew.status != AssetInstanceOld.status && AssetInstanceNew.status == 'Churn'){
AssetInstanceNew.Churn_Date__c = Date.today();
}

//make churn date non editable
if(AssetInstanceNew.Churn_Date__c != AssetInstanceOld.Churn_Date__c){
if((AssetInstanceOld.Churn_Date__c == NULL || 
AssetInstanceNew.status == 'Churn')){
//do nothing
}else{
AssetInstanceNew.addError('You are not authorised to change Churn Date');
}
} 	
}**/
        
        /** ASHWIN : Onboarding status validation - CSM CSAT SURVEY - START**/
        Map<Id,List<String>> assetEventMap = new Map<Id,List<String>>();//23
        for(Event thisRec : [SELECT Id,WhatId,Stage__c,Subject
                             FROM Event 
                             WHERE Subject = 'Onboarding Meeting'
                             AND WhatId IN :mapofNewSobjects.KeySet()])
            
        {
            if(assetEventMap.containsKey(thisRec.WhatId)){
                assetEventMap.get(thisRec.WhatId).add(thisRec.Stage__c);
            }else{
                assetEventMap.put(thisRec.WhatId, new List<String> {thisRec.Stage__c});
            }
        }
        for(Id key : mapofNewSobjects.KeySet()){
            Asset assetNewInstanceNew = (Asset)mapofNewSobjects.get(key);
            Asset assetOldInstanceOld = (Asset)mapofOldSobjects.get(key);
            if(assetNewInstanceNew.Onboarding_status__c !=assetOldInstanceOld.Onboarding_status__c &&
               assetNewInstanceNew.Onboarding_status__c == 'Onboarding Complete')
            {
                if(assetEventMap.containsKey(assetNewInstanceNew.Id)){
                    if(!assetEventMap.get(assetNewInstanceNew.Id).contains('Completed')){
                        //assetNewInstanceNew.addError('Create an Onboarding event and complete the event to update the stage to Onboarding Complete');   
                    }
                }else{
                    //assetNewInstanceNew.addError('Create an Onboarding event and complete the event to update the stage to Onboarding Complete');
                }    
            }
            
        }
        
        /* Added for CSM Journy - NIRAJ START */
        CTX_CSMJourneyOnbaordingFlow.updateOnboardingSubstages((List<Asset>)mapofNewSobjects.values(), (Map<Id, Asset>)mapofOldSobjects);
        CTX_CSMJourneyOnbaordingFlow.updateStage((List<Asset>)mapofNewSobjects.values(), (Map<Id, Asset>)mapofOldSobjects);
        /* Added for CSM Journy - NIRAJ END */
        
        //ASHWIN : Onboarding status validation - CSM CSAT SURVEY - END
        
        CTX_MergeAssets.mergeAssets((Map<Id, Asset>)mapofNewSobjects, (Map<Id, Asset>)mapofOldSobjects);
        
    }
    
    public void afterUpdate(Map<Id,Sobject> mapofNewSobjects,Map<Id,Sobject> mapofOldSobjects){
        
        
        List<Asset>   delList = new List<Asset>();
        Set<Id> prodChangeIdList = new Set<Id>();//24
        Map<Id,Asset> parentChildMap = new Map<Id,Asset>([SELECT Id,(SELECT Id,parentId FROM ChildAssets) FROM Asset WHERE Id in :mapofNewSobjects.keySet()]);
        
        Map<Id,Asset> 			mapofNewAssets					= (Map<Id,Asset>)mapofNewSobjects;
        Map<Id,Asset> 			mapofOldAssets					= (Map<Id,Asset>)mapofOldSObjects;
        List<Asset> 			listOfAssetsToUpdateAccounts	= new List<Asset>();
        List<OrderItem> 		listOfOLIToUpdate 				= new List<OrderItem>(); //Added by Raksha
        list<opportunity> 		opporToUpdate 					= new List<opportunity>();
        set<id> 				relOpporId 						= new set<id>();
        set<String> 			setOfOpp						= new set<string>();
        set<String> 			setOfAssets						= new set<string>();
        List<String> 			fieldList 						= new List<String>();
        DealClosureQueueable 	DQ;
        Set<Id> 				prodId 		    				= new Set<Id>();
        Set<Id>					parentAssetId					= new Set<Id>();
        
        /*Deal Closure */
        for( Asset thisRec : mapofNewAssets.values() ){
            prodId.add(thisRec.Product2Id);
            
            if(thisRec.ParentId != NULL)
                parentAssetId.add(thisRec.ParentId);
        }
        //25
        Map<Id, Product2> prodMap = new map<Id, Product2>(
            [ SELECT Id, Product_Category__c, ProductCode, Name, Family, 
             Plan_Tier__c, Product_Line__c, Is_Applicable_for_Licensing__c 
             FROM Product2 WHERE Id IN :prodId ]
        );
        /*Deal Closure */
        
        /* Upsert - Asset Clallout */
        if(AssetConstants.SALES_SYNC_FLOW_RUN){
            CTX_LicensingAssetFilterLogic.filterAssetsForlicensing(mapofNewAssets, mapofOldAssets, prodMap, TRUE, parentAssetId);   
        }
        /* Upsert - Asset Clallout */
        
        /** Added By Niraj : Extension Notification to CSM **/
        CTX_SendLicenseNotifications.sendExtensionEmail(mapofNewAssets.values(), mapofOldAssets);
        /** Added By Niraj : Extension Notification to CSM**/
        //26
        Map<Id, Asset> filteredAsset = new Map<Id, Asset>(
            [ SELECT Id, Name, Account.Owner.Department, Opportunity__c, AccountId 
             FROM Asset WHERE 
             RecordType.DeveloperName = 'Integration_Asset' AND 
             Id IN: mapofNewAssets.keySet()] 
        );          
        
        Schema.FieldSet fdlst = Schema.SObjectType.asset.fieldSets.getMap().get('Deal_Closure');     
        system.debug('****fs1-->'+fdlst);        
        
        if(!fdlst.getFields().isEmpty()){
            for(Schema.FieldSetMember fd : fdlst.getFields()){
                fieldList.add(String.valueOf(fd.getSobjectfield()));
            }
        }
        system.debug('****fieldList-->'+fieldList);
        
        for(asset aIns:(List<asset>)mapofOldSobjects.values()){
            if(aIns.Renewal_Opportunity__c != null)
                relOpporId.add(aIns.Renewal_Opportunity__c);
        }
        //27
        map<id,opportunity> opporMap = new map<id,opportunity>([select id,Name, stageName from opportunity where id in:relOpporId ]);
        
        List<Asset> activationAssetList = new List<Asset>();	// Added By Niraj For CSM Activation Task creation
        if(!mapofNewAssets.isEmpty()){
            for(Id key:mapofNewAssets.keySet()){
                Asset newIns = mapofNewAssets.get(key);
                Asset oldIns = mapofOldAssets.get(key);
                
                /* CSM Journy Activation Task Creation - NIRAJ START */
                if(newIns.CSM_Handled_Asset__c == true && newIns.Stage__c == 'Onboarding' && oldIns.Onboarding_Stage__c != newIns.Onboarding_Stage__c && newIns.Onboarding_Stage__c == 'Sales CSM Handover'){
                    activationAssetList.add(newIns);
                }
                /* CSM Journy Activation Task Creation - NIRAJ END*/
                
                if(oldIns.Product2Id != newIns.Product2Id){
                    System.debug('oldIns@$$'+ oldIns.Product2Id);
                    System.debug('newIns@$$'+ newIns.Product2Id);
                    prodChangeIdList.add(newIns.Id);
                }
                //Added by Raksha
                if(mapofNewAssets.get(key).Onboarding_Status__c != mapofOldAssets.get(key).Onboarding_status__c ||
                   mapofNewAssets.get(key).Integration_status__c != mapofOldAssets.get(key).Integration_status__c||
                   mapofNewAssets.get(key).Onboarding_Completed_Date__c	!= mapofOldAssets.get(key).Onboarding_Completed_Date__c ||
                   mapofNewAssets.get(key).Integration_Completed_Date__c != mapofOldAssets.get(key).Integration_Completed_Date__c ||
                   mapofNewAssets.get(key).Status != mapofOldAssets.get(key).Status){
                       OrderItem oli = new OrderItem();
                       Map<Id, OrderItem> oli_Map = new Map<Id, OrderItem>();
                       if(mapofNewAssets.get(key).Order_Line__c!=null){ //added by Lokesh to  fix the bug start
                           oli.id = mapofNewAssets.get(key).Order_Line__c;
                           System.debug('Onboarding_Status__c '+mapofNewAssets.get(key).Onboarding_Status__c);
                           System.debug('Integration_status__c '+mapofNewAssets.get(key).Integration_status__c );
                           System.debug('Onboarding completed date '+mapofNewAssets.get(key).Onboarding_Completed_Date__c);
                           System.debug('Integration completed date '+mapofNewAssets.get(key).Integration_Completed_Date__c);
                           System.debug('Status__c '+mapofNewAssets.get(key).Status);
                           if(mapofNewAssets.get(key).Onboarding_Status__c != null &&
                              mapofNewAssets.get(key).Onboarding_Status__c != mapofOldAssets.get(key).Onboarding_status__c 
                             ){
                                 oli.Onboarding_Status__c = mapofNewAssets.get(key).Onboarding_status__c;
                             }
                           if(mapofNewAssets.get(key).Integration_status__c  != null &&
                              mapofNewAssets.get(key).Integration_status__c != mapofOldAssets.get(key).Integration_status__c 
                             ){
                                 oli.Integration_status__c = mapofNewAssets.get(key).Integration_status__c;
                             }
                           if(mapofNewAssets.get(key).Onboarding_Completed_Date__c != null &&
                              mapofNewAssets.get(key).Onboarding_Completed_Date__c	!= mapofOldAssets.get(key).Onboarding_Completed_Date__c){
                                  oli.Onboarding_Completed_Date__c = mapofNewAssets.get(key).Onboarding_Completed_Date__c;
                              }
                           if(mapofNewAssets.get(key).Integration_Completed_Date__c != null &&
                              mapofNewAssets.get(key).Integration_Completed_Date__c	!= mapofOldAssets.get(key).Integration_Completed_Date__c){
                                  oli.Integration_Completed_Date__c = mapofNewAssets.get(key).Integration_Completed_Date__c;
                              }
                           if(mapofNewAssets.get(key).Status != null && 
                              mapofNewAssets.get(key).Status != mapofOldAssets.get(key).Status){
                                  oli.Status__c = mapofNewAssets.get(key).Status;
                              }
                           listOfOLIToUpdate.add(oli);
                           oli_Map.put(oli.Id, oli);
                       }
                   }
                //End by Raksha
                
                for(string tempFieldName:fieldList){
                    
                    system.debug('tempFieldName '+tempFieldName);
                    system.debug('New Value: '+mapofNewAssets.get(key).get(tempFieldName));
                    system.debug('Old Value: '+mapofOldAssets.get(key).get(tempFieldName));
                    
                    if(mapofNewAssets.get(key).get(tempFieldName) != mapofOldAssets.get(key).get(tempFieldName)){
                        
                        system.debug('fds Yes');
                        
                        /**	SWITCH for Standard Plans : START	**/
                        /*if(!mapofNewAssets.get(key).Product_Name_Formula__c.Contains('GST')){

if(System.Label.Enable_Standard_Plan == 'YES'){

if(mapofNewAssets.get(key).Asset_Product_Line__c == 'GST'){

if(
mapofNewAssets.get(key).Platform__c == 'App.Clear' && 
mapofNewAssets.get(key).Is_License_Created__c && 
mapofNewAssets.get(key).License_ID__c == NULL
){
if(mapofNewAssets.get(key).Opportunity__c != NULL)
setOfOpp.add(mapofNewAssets.get(key).Opportunity__c);
else
setOfAssets.add(key);
}
} else{
if(mapofNewAssets.get(key).Opportunity__c != NULL)
setOfOpp.add(mapofNewAssets.get(key).Opportunity__c);
else
setOfAssets.add(key);
}

} else{
if(mapofNewAssets.get(key).Opportunity__c != NULL)
setOfOpp.add(mapofNewAssets.get(key).Opportunity__c);
else
setOfAssets.add(key);
}
}*/
                        /**	SWITCH for Standard Plans : END	**/
                        
                    }
                    
                }
                
                
                if(mapofNewAssets.get(key).status == 'Churn' && mapofNewAssets.get(key).Renewal_Opportunity__c != null){
                    opportunity oppor = opporMap.get(mapofNewAssets.get(key).Renewal_Opportunity__c);
                    oppor.Loss_Reason__c = 'Other';
                    oppor.Other_Reason_for_Loss__c='Source Asset is Churned.';
                    oppor.competition_Currently_Using__c='Other';
                    oppor.StageName = 'Closed Lost';
                    opporToUpdate.add(oppor);
                    
                }
                
                if(mapofOldAssets.get(key).Status == 'Upcoming Renewal'  && (mapofNewAssets.get(key).UsageEndDate != mapofOldAssets.get(key).UsageEndDate) && (mapofOldAssets.get(key).Renewal_Opportunity__c != null) && mapofNewAssets.get(key).UsageEndDate > Date.Today()) 
                {
                    opportunity oppUse = opporMap.get(mapofOldAssets.get(key).renewal_opportunity__c);
                    //delete(oppUse);
                }
                //Added By Kartikeya for deleting child and grandchild
                If(newIns.Status != oldIns.Status && (newIns.Status.equals(AssetConstants.STATUS_SALES_RETURN) || newIns.Status.equals(AssetConstants.STATUS_CHURN))){
                    if(parentChildMap.containsKey(newIns.id) && parentChildMap.get(newIns.id).childAssets.Size() >0 ){
                        delList.add(parentChildMap.get(newIns.id).childAssets);
                    }
                }
            }
        }
        if(delList.size() >0){
            delete(new List<Asset> (new Set<Asset>(delList)));
            
        }
        
        /* CSM Journy Activation Task Creation - NIRAJ START */
        if(!activationAssetList.isEmpty()){
            new CTX_CSM_TASK_CreationFormula(activationAssetList).createTasks();
            //database.executeBatch(new CTX_GenerateCSMTasksBatch(activationAssetList));
        }
        /* CSM Journy Activation Task Creation - NIRAJ END */
        
        RecursiveTriggerHandler.isFirstTime = FALSE; // Dont remove from here as delete operation needs to call this trigger for creating Deletion Task
        
        if(opporToUpdate.size()>0){
            update opporToUpdate;
        } 
        
        
        if(!setOfOpp.isEmpty()){
            DQ = new DealClosureQueueable(setOfOpp, NULL, TRUE,  FALSE);	/**	OpportunityIdSet, AssetIdSet, IsOpportunityAvailable, Insert/update	**/
        } else if(!setOfAssets.isEmpty()){
            DQ = new DealClosureQueueable(NULL, setOfAssets, FALSE, FALSE);	/**	OpportunityIdSet, AssetIdSet, IsOpportunityAvailable, Insert/update	**/
        }
        
        system.debug('Start firing queable job');
        
        //if(DQ != null && Limits.getQueueableJobs() < 1) //Required when called from another queable method as limit is 1 instead of 50
        //System.enqueueJob(DQ);
        
        
        //Added by Raksha
        System.debug('listOfOLIToUpdate '+listOfOLIToUpdate);
        if(!listOfOLIToUpdate.isEmpty()){
            update listOfOLIToUpdate;
        }//28
        AssetTriggerHelper.CreateOrder([select id,product2id,product2.product_category__c,AccountId,PurchaseDate,Price  from  asset where id in: prodChangeIdList and product2.product_category__c = 'Integration'] );
        //End by Raksha
        CTX_ApexRecordSharing.apexShare_Asset_AccountSalesOwnerAccess(
            (Map<Id, Asset>) mapofNewSObjects
        );
        
        CTX_AssetDetailsCapture.getAssetDetails( 
            (List<Asset>) 	mapofNewSobjects.values(), 
            (Map<Id,Asset>) mapofNewSObjects
        );
        
        
        AssetTriggerHelper.updatePriorityList(
            (Map<Id,Asset>)filteredAsset
        );
        
        AssetARRSummary.assetARRSummaryMethodUpdate(
            mapofNewSObjects, mapofOldSobjects
        );
        
        //Added by Raksha
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForActiveStatusCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Status', 
                                                         'Number_Of_Assets_Active__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForActiveStatusCount, trigger.new, 'Asset', 'AccountId', 'Account',
                                                           'And (Status = \'Active\' OR Status = \'Upcoming Renewal\' OR Status = \'At Risk\')'); //(Status = AssetConstants.STATUS_ACTIVE OR Status = AssetConstants.STATUS_RENEWAL_PENDING OR Status = AssetConstants.STATUS_AT_RISK)
        
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForChurnStatusCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Status', 
                                                         'Number_Of_Assets_Churn__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForChurnStatusCount, trigger.new, 'Asset', 'AccountId', 'Account',
                                                           'And Status = \'Churn\' ');
        
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForPendingStatusCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Status', 
                                                         'Number_Of_Assets_Pending__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForPendingStatusCount, trigger.new, 'Asset', 'AccountId', 'Account',
                                                           'And (Status = \'Inactive\' OR Status = \'Expired\') ');
        
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForTotalCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Status', 
                                                         'Total_number_Of_Assets__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForTotalCount, trigger.new, 'Asset', 'AccountId', 'Account',
                                                           ' ');
        
        /** Added by Ashwin - CSM CSAT SURVEY - START **/
        Map<Id,Asset> astMap = new Map<Id,Asset>();
        Set<Id> accIds = new Set<Id>();
        for(Asset ast : mapofNewAssets.values()){
            Asset assetNewInstance=(Asset)mapofNewAssets.get(ast.Id);
            Asset assetOldInstance=(Asset)mapofOldAssets.get(ast.Id);
            
            if(assetNewInstance.Onboarding_status__c != assetOldInstance.Onboarding_status__c){
                if(assetNewInstance.Onboarding_status__c == 'Onboarding Complete'){
                    astMap.put(assetNewInstance.Id,assetNewInstance);  
                    accIds.add(assetNewInstance.AccountId);
                }
                
            }
            if(astMap.size()>0){
                //CTX_OnboadingSurveyEmail.createSurveyInvitations(astMap,accIds);
            }
            
            
        }
        /** Added by Ashwin - CSM CSAT SURVEY - END 
List<String> allowedSatus = system.label.asset_status.split(',');
List<AggregateResult> assetGroup     =  [SELECT accountId Id, Count(Status) Demo_Text_Rollup__c    FROM Asset
WHERE id IN: mapofNewSObjects.KeySet() AND Status IN :allowedSatus  GROUP BY accountId];
Map<Id,sObject> accountMap = AssetTriggerHelper.CustomRollUp(assetGroup, 'Demo_Text_Rollup__c', 'Account');
Database.Update(accountMap.Values());**/
        
    }
    
    public void beforeDelete(List<Sobject> listofOldSobjects,Map<Id,Sobject> mapOfOldSobject){}
    
    public void afterDelete(Map<Id,Sobject> mapOfOldSobject){
        string assDel = 'Asset Deletion';
        
        /** Added By Niraj License Deactivation Flow **/
        set<Id> accountIdsOfAssetToDeactivate 				= new set<Id>();
        Map<String,Id> licenseIdToDeactivateToAccountIdMap 	= new Map<String,Id>();
        /** Added By Niraj License Deactivation Flow **/
        
        if(!AssetConstants.TASK_APPROVAL){  //29      
            Map<Id,Asset> assetMap = new Map<Id,Asset>([SELECT id,opportunity__r.name,License_Id__c,Account.Name,status,AccountId,Flag_for_Asset_Sucess__c
                                                        ,Billing_Type__c,Activation_Flag__c,Project_Stage__c ,Project_Status__c,Account.Onboarding_Owner__r.email
                                                        ,usageenddate,purchasedate,price,product2.name
                                                        FROM Asset WHERE
                                                        Id in: mapOfOldSobject.keySet() ALL ROWS]);
            List<Task> taskList = new List<Task>();
            for(Asset sIns: assetMap.values()){
                
                if(sIns.License_Id__c != NULL){
                    licenseIdToDeactivateToAccountIdMap.put(sIns.License_Id__c, sIns.AccountId);
                    accountIdsOfAssetToDeactivate.add(sIns.AccountId);
                }
                
                Task t1 = new  Task();
                t1.RecordTypeId = AssetConstants.ASSET_DELETE_RecordTypeId;
                t1.whatId = sIns.AccountId;
                t1.Status = 'Approved';
                t1.Asset_to_be_deleted__c = true;
                //t1.Comment__c = 'Deleted because parent asset marked as Churn/ Sales Return';
                t1.Approval_Rejected_Comment__c = 'Auto-Approved';
                t1.subject = assDel + '-Account:'+sIns.Account.Name;
                t1.asset_status__c = sIns.status ;
                t1.Asset_success_flag__c = sIns.Flag_for_Asset_Sucess__c;
                t1.Asset_Opportunity_Source__c = sIns.opportunity__r.name ;
                t1.Billing_Type__c = sIns.Billing_Type__c ;
                t1.Asset_Activation_flag__c = sIns.Activation_Flag__c;
                t1.Project_Stage__c = sIns.Project_Stage__c ;
                t1.Project_Status__c = sIns.Project_Status__c ;
                t1.Asset_Account_CSM_Email__c = sIns.Account.Onboarding_Owner__r.email;
                t1.Old_Value_PO_End_date__c = sIns.usageenddate;
                t1.Old_Value_PO_Start_date__c = sIns.purchasedate;
                t1.Old_Value_Price__c = sIns.price;
                t1.Old_Value_Product__c = sIns.product2.name;
                t1.related_account__C = sIns.account.name;
                taskList.add(t1);  
            }
            if(taskList.size() > 0){
                insert taskList;
            }
        }
        
        AssetARRSummary.assetARRSummaryMethod(mapOfOldSobject.values());
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForActiveStatusCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Status', 
                                                         'Number_Of_Assets_Active__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForActiveStatusCount, trigger.old, 'Asset', 'AccountId', 'Account',
                                                           'And (Status = \'Active\' OR Status = \'Upcoming Renewal\' OR Status = \'At Risk\')'); //(Status = AssetConstants.STATUS_ACTIVE OR Status = AssetConstants.STATUS_RENEWAL_PENDING OR Status = AssetConstants.STATUS_AT_RISK)
        
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForChurnStatusCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Status', 
                                                         'Number_Of_Assets_Churn__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForChurnStatusCount, trigger.old, 'Asset', 'AccountId', 'Account',
                                                           'And Status = \'Churn\' ');
        
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForPendingStatusCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Status', 
                                                         'Number_Of_Assets_Pending__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForPendingStatusCount, trigger.old, 'Asset', 'AccountId', 'Account',
                                                           'And (Status = \'Inactive\' OR Status = \'Expired\') ');
        
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForTotalCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Status', 
                                                         'Total_number_Of_Assets__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForTotalCount, trigger.old, 'Asset', 'AccountId', 'Account',
                                                           ' ');
        
        //End by Raksha
        //
        
        if(licenseIdToDeactivateToAccountIdMap.keySet().size() > 0){
            CTX_LicensingAssetFilterLogic.deactivateLicense(licenseIdToDeactivateToAccountIdMap, accountIdsOfAssetToDeactivate, TRUE);
        }
    }
    
    public void afterUndelete(List<Sobject> listofNewSobjects,Map<Id,Sobject> mapofNewSObject){
        //Added by Kartikeya
        AssetARRSummary.assetARRSummaryMethod(mapofNewSObject.values());
        //Added by Raksha
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForActiveStatusCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Status', 
                                                         'Number_Of_Assets_Active__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForActiveStatusCount, trigger.new, 'Asset', 'AccountId', 'Account',
                                                           'And (Status = \'Active\' OR Status = \'Upcoming Renewal\' OR Status = \'At Risk\')'); //(Status = AssetConstants.STATUS_ACTIVE OR Status = AssetConstants.STATUS_RENEWAL_PENDING OR Status = AssetConstants.STATUS_AT_RISK)
        
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForChurnStatusCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Status', 
                                                         'Number_Of_Assets_Churn__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForChurnStatusCount, trigger.new, 'Asset', 'AccountId', 'Account',
                                                           'And Status = \'Churn\' ');
        
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForPendingStatusCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Status', 
                                                         'Number_Of_Assets_Pending__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForPendingStatusCount, trigger.new, 'Asset', 'AccountId', 'Account',
                                                           'And (Status = \'Inactive\' OR Status = \'Expired\') ');
        
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForTotalCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'Status', 
                                                         'Total_number_Of_Assets__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForTotalCount, trigger.new, 'Asset', 'AccountId', 'Account',
                                                           ' ');
        //End by Raksha
    }
    
    
}