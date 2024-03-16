/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 12-11-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_UpsertAssetLicense IMPLEMENTS Queueable, Database.AllowsCallouts {
    
    Public Map<Id, Asset>       filteredAssets          = new Map<Id, Asset>();
    Public Map<Id, Asset>       oldAssets               = new Map<Id, Asset>();
    Public Map<Id, Boolean>     assetUpsertBooleanMap   = new Map<Id, Boolean>();
    Public Set<Id>              parentAssetId           = new Set<Id>();
    
    public CTX_UpsertAssetLicense(
        Map<Id, Asset>      filteredAssets,
        Map<Id, Asset>      oldAssets,  
        Map<Id, Boolean>    assetUpsertBooleanMap,
        Set<Id>             parentAssetId
    ){
        this.filteredAssets         = filteredAssets;
        this.oldAssets              = oldAssets;
        this.assetUpsertBooleanMap  = assetUpsertBooleanMap;
        this.parentAssetId          = parentAssetId;
    }
    
    public void execute(QueueableContext context){
        callout_UpsertAsset_API(filteredAssets, oldAssets, assetUpsertBooleanMap, parentAssetId);
    } 
    
    public static void callout_UpsertAsset_API(
        Map<Id, Asset>      filteredAssets, 
        Map<Id, Asset>      oldAssets,
        Map<Id, Boolean>    assetUpsertBooleanMap,
        Set<Id>             parentAssetId
    ){  
        List<Asset>                             		failedAssets    		= new List<Asset>();
        List<Logger__c>                         		updateSnag      		= new List<Logger__c>();
        List<Asset>                             		updateAsset     		= new List<Asset>();
        List<Sales_Sync_Licensing_Failure__e>   		failureEvents   		= new List<Sales_Sync_Licensing_Failure__e>();
        Set<Id>											assetIds				= filteredAssets.keySet();
        Map<String, List<Resource_Constraints__mdt>> 	mdtResourceConstaintMap = new Map<String, List<Resource_Constraints__mdt>>();
        Set<String>										fieldsToQuery			= new Set<String>();
        
        /**	Get Metadata Result to Map : START	**/
        for(Resource_Constraints__mdt mdt : Resource_Constraints__mdt.getAll().values()){
            
            if(mdt.Include_In_GCC__c){
                if(mdtResourceConstaintMap.containsKey('GCC')){
                    mdtResourceConstaintMap.get('GCC').add(mdt);
                } else {
                    mdtResourceConstaintMap.put('GCC', new List<Resource_Constraints__mdt>{mdt});
                }
            } else {
                if(mdtResourceConstaintMap.containsKey(mdt.Plan_Tier__c)){
                    mdtResourceConstaintMap.get(mdt.Plan_Tier__c).add(mdt);
                } else {
                    mdtResourceConstaintMap.put(mdt.Plan_Tier__c, new List<Resource_Constraints__mdt>{mdt});
                }
            }
        }	/**	Get Metadata Result to Map : END	**/
        
        String 			queryString = ' SELECT '+CTX_LicensingConstants.LICENSEACTIVATIONQUERY+', '+CTX_LicensingConstants.CLEAR_IDENTITY_METERING_PARAMETER+ ' FROM Asset WHERE Id IN :assetIds ';
        Map<Id, Asset>  assetMap    = new Map<Id, Asset>( (List<Asset>)database.query(queryString) );
        
        /** Iterate Over Asset and get Wrapper Details : START  **/
        for( Asset thisRec : assetMap.values() ){
            
            CTX_UpsertAssetLicensingClass.OutterWrapper             resultWrapper 				= new CTX_UpsertAssetLicensingClass.OutterWrapper();
            CTX_UpsertAssetLicensingClass.AssetWrapper              myAsset 					= new CTX_UpsertAssetLicensingClass.AssetWrapper();
            CTX_UpsertAssetLicensingClass.AssetProductWrapper       relatedProduct 				= new CTX_UpsertAssetLicensingClass.AssetProductWrapper();
            CTX_UpsertAssetLicensingClass.AssetResourceConstraints	assetResourceConstraint		= new CTX_UpsertAssetLicensingClass.AssetResourceConstraints();
            List<String>                                            workspaceIds       			= new List<String>();
            Boolean                                                 isFetchWorkspaceSuccess 	= FALSE;
            
            if( !assetUpsertBooleanMap.get(thisRec.Id) ){
                if( thisRec.ParentId != NULL ){
                    
                    /**	Workspace Suggastion Callout : START	**/
                    Set<String>	productEmails   = new Set<String>();
                    String      region			= thisRec.Account.Country_of_Origin__c != NULL ? thisRec.Account.Country_of_Origin__c : 'INDIA';
                    
                    if( thisRec.Account.Product_Email__c != NULL ){
                        productEmails.add(thisRec.Account.Product_Email__c);
                    }
                    
                    HttpResponse response;
                    if( !productEmails.isEmpty() ){
                        
                        response = CTX_LicensingAPICalloutClass.workspaceSuggestionCallout(
                            productEmails, 
                            thisRec.Parent?.License_Id__c, 
                            thisRec.Product2?.SaaS_Product__c, 
                            region  
                        );
                        
                        if( response.getStatusCode() == 200 ){
                            
                            isFetchWorkspaceSuccess = TRUE;
                            Map<String, Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                            workspaceIds = new List<String>(rephraseSuggestionAPIResponse(responseMap, productEmails));
                            system.debug('workspaceIds: '+workspaceIds);
                            
                            if(workspaceIds.size() <= 0){
                                
                                isFetchWorkspaceSuccess = FALSE;
                                updateSnag.add(
                                    CTX_LoggerImplementation.createLoggerInstance(
                                        'No Workspace found with given product email. Please help the customer to create a workspace by logging into product in case new workspace needs to be created. If a workspace already exists, please ask the concerned workspace admin to invite ' + thisRec.Account?.Product_Email__c + ' to their workspace. License can be added to these workspaces once this step is done.',
                                        NULL,
                                        'CTX_UpsertAssetLicense',
                                        'CTX_LicensingAPICalloutClass.workspaceSuggestionCallout()',
                                        'Callout Failure',
                                        thisRec.Id,
                                        'Asset' )
                                );
                            }
                            
                            if(oldAssets != NULL){
                                failedAssets.add(oldAssets.get(thisRec.Id));
                                failureEvents.add(new Sales_Sync_Licensing_Failure__e(Record_Id__c = thisRec.Id, ErrorMessages__c = response.getBody()));
                            }
                            
                        } else{
                            
                            isFetchWorkspaceSuccess = FALSE;
                            updateSnag.add(
                                CTX_LoggerImplementation.createLoggerInstance(
                                    response.getBody(),
                                    NULL,
                                    'CTX_UpsertAssetLicense',
                                    'CTX_LicensingAPICalloutClass.workspaceSuggestionCallout()',
                                    'Callout Failure',
                                    thisRec.Id,
                                    'Asset' )
                            );
                            
                            if(oldAssets != NULL){
                                failedAssets.add(oldAssets.get(thisRec.Id));
                                failureEvents.add(new Sales_Sync_Licensing_Failure__e(Record_Id__c = thisRec.Id, ErrorMessages__c = response.getBody()));
                            }
                            
                            /**	Workspace Suggastion Callout : END	**/
                        }
                    }
                }
            } else{
                isFetchWorkspaceSuccess = TRUE;
            }
            
            if( isFetchWorkspaceSuccess ){
                
                
                /**	CSM + KAM Details : START	**/
                if(thisRec.Account.Onboarding_Owner__c != NULL){
                    resultWrapper.csm.email 									= thisRec.Account.Onboarding_Owner__r.Email;
                    resultWrapper.csm.phone 									= thisRec.Account.Onboarding_Owner__r.Phone;
                    resultWrapper.csm.managerEmail 								= thisRec.Account.Onboarding_Owner__r.Manager.Email;
                    resultWrapper.csm.superManagerEmail 						= thisRec.Account.Onboarding_Owner__r.Manager.Manager.Email;  
                }
                
                resultWrapper.kam.name 											= thisRec.Account.Owner.Name;
                resultWrapper.kam.email 										= thisRec.Account.Owner.Email;
                resultWrapper.kam.phone 										= thisRec.Account.Owner.Phone;
                resultWrapper.kam.managerEmail 									= thisRec.Account.Owner.Manager.Email;
                resultWrapper.kam.superManagerEmail 							= thisRec.Account.Owner.Manager.Manager.Email;
                /**	CSM + KAM Details : START	**/
                
                /** Wrapper Instance Value Assignment : START   **/
                resultWrapper.sfOpportunityId                                       = thisRec.Opportunity__c;
                resultWrapper.sfOrgName                                             = thisRec.Name;
                resultWrapper.isUpdate                                              = assetUpsertBooleanMap.get(thisRec.Id);
                resultWrapper.isTestLicense                                         = thisRec.Is_Test_Asset__c == NULL ? FALSE : thisRec.Is_Test_Asset__c;
                resultWrapper.masterEmailID                                         = thisRec.Account.Product_Email__c;
                resultWrapper.sfAccountId                                           = thisRec.AccountId;
                resultWrapper.region                                                = thisRec.Account.Country_of_Origin__c;
                resultWrapper.workspaceIds                                          = resultWrapper.isUpdate ? new List<String>() : workspaceIds; // Updated By Niraj
                resultWrapper.isApplicableForLicensingEmailer						= 
                    ( !thisRec.Name?.containsIgnoreCase('Assisted Services') && thisRec.Price > 0 ) ? TRUE : FALSE;
                
                /** Asset Wrapper Values : START    **/
                myAsset.assetId                                                     = thisRec.Id;
                myAsset.licenseId                                                   = thisRec.License_Id__c;
                myAsset.planTier                                                    = thisRec.Product2.Plan_Tier__c;
                
                myAsset.isCDCEnabled                                            	= thisRec.Product2.Plan_Tier__c == 'EINVOICE_STANDARD'|| thisRec.Product2.Plan_Tier__c == 'CLEAR_INVOICING_STANDARD' ? thisRec.CDC_Applicable__c : FALSE; // Added By Niraj
                
                myAsset.planId                                                      = thisRec.Product2.Product_Plan_Id__c;
                myAsset.assetEndDateEodInstant                                      = 0;
                myAsset.assetStartDate                                              = thisRec.PurchaseDate;
                myAsset.assetEndDate                                                = thisRec.UsageEndDate;
                myAsset.status                                                      = thisRec.Status;
                myAsset.price                                                       = thisRec.Price;
                myAsset.Name                                                        = thisRec.Name;
                myAsset.saasProduct                                                 = thisRec.Product2.Saas_Product__c;
                /** Asset > Product2    **/
                relatedProduct.licenseProduct                                       = thisRec.Product_Line__c;
                relatedProduct.productCode                                          = thisRec.Product2.ProductCode;
                relatedProduct.productFamily                                        = thisRec.Product2.Family;
                myAsset.product                                                     = relatedProduct;
                /** Asset > ResourceConstraints **/
                assetResourceConstraint.noOfUserIds                                 = thisRec.License_no_of_userids__c;
                assetResourceConstraint.noOfPurchaseInvoice                         = thisRec.Number_of_Purchase_Invoice__c;
                assetResourceConstraint.noOfPANs                                    = thisRec.License_no_of_pans__c;
                assetResourceConstraint.noOfGSTINs                                  = thisRec.License_no_of_gstins__c;
                assetResourceConstraint.noOfEwayBill                                = thisRec.Number_of_eway_bill__c;
                assetResourceConstraint.noOfB2CSalesInvoice                         = thisRec.License_B2C_SalesInvoice_per_year__c;
                assetResourceConstraint.noOfB2BSalesInvoice                         = thisRec.License_B2B_SalesInvoice_per_year__c;
                assetResourceConstraint.noOfAirlineInvoices                         = thisRec.No_of_airline_invoices__c;
                assetResourceConstraint.License_no_of_total_Sales_Invoices          = thisRec.License_no_of_total_Sales_Invoices__c;
                assetResourceConstraint.License_no_of_irns_per_year                 = thisRec.License_no_of_irns_per_year__c;
                assetResourceConstraint.License_no_of_invoice_formats               = thisRec.License_no_of_invoice_formats__c;
                assetResourceConstraint.License_no_of_gstin_verification_credits    = thisRec.License_no_of_gstin_verification_credits__c;
                assetResourceConstraint.License_No_of_MM2A_2B_usage_GSTIN_mon       = thisRec.License_No_of_MM2A_2B_usage_GSTIN_mon__c;
                assetResourceConstraint.License_no_of_Recon                         = thisRec.License_no_of_Recon__c;
                myAsset.sfResourceConstraints                                       = 
                    (
                        thisRec.Account.Country_of_Origin__c !=  'India' && 
                        !String.ISBLANK(thisRec.Account.Country_of_Origin__c) ) || 
                    thisRec.Product2.Plan_Tier__c == 'CLEAR_IDENTITY_STANDARD' || 
                    thisRec.Product2.SaaS_Product__c == 'NOTICE_MANAGEMENT' || 
                    thisRec.Product2.Plan_Tier__c == 'TDS_TE_ADVANTAGE' || 
                    thisRec.Product2.Plan_Tier__c == 'PARTNER_MANAGEMENT_STANDARD' 
                    ? NULL : assetResourceConstraint;
                
                myAsset.resourceConstraints = new List<CTX_UpsertAssetLicensingClass.ResourceConstraints>();
                
                if( 
                    ( thisRec.Account.Country_of_Origin__c !=  'India' && !String.ISBLANK(thisRec.Account.Country_of_Origin__c) ) 	|| 
                    thisRec.Product2.Plan_Tier__c 		== 'CLEAR_IDENTITY_STANDARD' 												|| 
                    thisRec.Product2.SaaS_Product__c 	== 'NOTICE_MANAGEMENT' 														|| 
                    thisRec.Product2.Plan_Tier__c 		== 'TDS_TE_ADVANTAGE' 														|| 
                    thisRec.Product2.Plan_Tier__c 		== 'CLEAR_GST_PREMIUM' 														|| 
                    thisRec.Product2.Plan_Tier__c 		== 'CLEAR_GST_ADVANTAGE' 													||
                    thisRec.Product2.Plan_Tier__c 		== 'PARTNER_MANAGEMENT_STANDARD' 											||
                    thisRec.Product2.Plan_Tier__c 		== 'CLEAR_GST_ULTIMATE'
                ){
                    
                    system.debug('Inside Resource Constraints');
                    /**	New Resource Constraints Block : START	**/
                    Map<String, Integer>	resourceConstraintsWithValuesMap = CTX_ClearResourceConstraintsClass.identityResourceConstraintsForLicensing(thisRec.Identity_Resource_Constraints__c);
                    /**	New Resource Constraints Block : START	**/
                    
                    
                    List<Resource_Constraints__mdt>	mdtList 
                        = ( thisRec.Account.Country_of_Origin__c !=  'India' && !String.ISBLANK(thisRec.Account.Country_of_Origin__c) ) 
                        ? mdtResourceConstaintMap.get('GCC') : mdtResourceConstaintMap.get(thisRec.Product2.Plan_Tier__c);
                    system.debug('mdtList : '+mdtList);
                    for( Resource_Constraints__mdt mdt : mdtList ){
                        
                        if( 
                          
                                mdt.Salesforce_Field_Source__c != 'Quote Line Item' &&
                                mdt.Salesforce_Field_Source__c != 'Invalid'  &&
                            thisRec.get(mdt.Salesforce_Field__c) != NULL
                        ){
                            system.debug('Non Identity Block');
                            
                            CTX_UpsertAssetLicensingClass.ResourceConstraints resourceConstraint = new CTX_UpsertAssetLicensingClass.ResourceConstraints();
                            resourceConstraint.resource 				= mdt.Resource__c;
                            resourceConstraint.constraintType 			= mdt.Constraint_Type__c;
                            
                            if(mdt.Constraint_Type__c == 'THRESHOLD'){
                                resourceConstraint.threshold 		= Integer.ValueOf(thisRec.get(mdt.Salesforce_Field__c)) != NULL ? Integer.ValueOf(thisRec.get(mdt.Salesforce_Field__c)) : 0;
                            } else if(mdt.Constraint_Type__c == 'FEATURE_AVAILABILITY'){
                                resourceConstraint.availability 	= Boolean.ValueOf(thisRec.get(mdt.Salesforce_Field__c));
                            }
                            
                            resourceConstraint.isUsageTimeBound 		= mdt.Is_Usage_Time_Bound__c;
                            resourceConstraint.eligibleForNotification 	= mdt.Is_Eligible_For_Notification__c;
                            
                            CTX_UpsertAssetLicensingClass.Metadata metadata = new CTX_UpsertAssetLicensingClass.Metadata();
                            
                            metadata.title								= mdt.Metadata_Title__c;
                            metadata.resourceTitle						= mdt.Metadata_Resource_Title__c;
                            metadata.displayText						= mdt.Metadata_Display_Text__c != NULL ? mdt.Metadata_Display_Text__c : '';
                            metadata.displayPriority					= mdt.Metadata_Display_Priority__c.IntValue();
                            metadata.showOnSummaryPage					= mdt.Metadata_Show_On_Summary_Page__c;
                            metadata.category							= mdt.Metadata_Category__c;
                            metadata.categoryDisplayText				= mdt.Metadata_Category_Display_Text__c;
                            
                            resourceConstraint.metadata				 	= metadata;
                            
                            myAsset.resourceConstraints.add(resourceConstraint);    
                        } 
                        else if( 
                            mdt.Salesforce_Field_Source__c == 'Quote Line Item' && 
                            resourceConstraintsWithValuesMap.containsKey( mdt.Salesforce_Field_QLI__c )
                        ){
                            
                            system.debug('Inside QLI Block - Identity');
                            CTX_UpsertAssetLicensingClass.ResourceConstraints resourceConstraint = new CTX_UpsertAssetLicensingClass.ResourceConstraints();
                            resourceConstraint.resource 				= mdt.Resource__c;
                            resourceConstraint.constraintType 			= mdt.Constraint_Type__c;
                            
                            if(mdt.Constraint_Type__c == 'THRESHOLD'){
                                //for( String thisSTR : resourceConstraintsWithValuesMap.keySet() ){
                                resourceConstraint.threshold 			= Integer.ValueOf(resourceConstraintsWithValuesMap.get(mdt.Salesforce_Field_QLI__c)) != NULL ? Integer.ValueOf(resourceConstraintsWithValuesMap.get(mdt.Salesforce_Field_QLI__c)) : 0;
                                //}
                            } else if(mdt.Constraint_Type__c == 'FEATURE_AVAILABILITY'){
                                //for( String thisSTR : resourceConstraintsWithValuesMap.keySet() ){
                                resourceConstraint.availability 		= Boolean.ValueOf(resourceConstraintsWithValuesMap.get(mdt.Salesforce_Field_QLI__c));
                                ///}
                            }
                            
                            
                            resourceConstraint.isUsageTimeBound 		= mdt.Is_Usage_Time_Bound__c;
                            resourceConstraint.eligibleForNotification 	= mdt.Is_Eligible_For_Notification__c;
                            
                            CTX_UpsertAssetLicensingClass.Metadata metadata = new CTX_UpsertAssetLicensingClass.Metadata();
                            
                            metadata.title								= mdt.Metadata_Title__c;
                            metadata.resourceTitle						= mdt.Metadata_Resource_Title__c;
                            metadata.displayText						= mdt.Metadata_Display_Text__c != NULL ? mdt.Metadata_Display_Text__c : '';
                            metadata.displayPriority					= mdt.Metadata_Display_Priority__c.IntValue();
                            metadata.showOnSummaryPage					= mdt.Metadata_Show_On_Summary_Page__c;
                            metadata.category							= mdt.Metadata_Category__c;
                            metadata.categoryDisplayText				= mdt.Metadata_Category_Display_Text__c;
                            
                            resourceConstraint.metadata				 	= metadata;
                            
                            myAsset.resourceConstraints.add(resourceConstraint);  
                            
                        }
                    }                    
                }
                
                resultWrapper.assets = new List<CTX_UpsertAssetLicensingClass.AssetWrapper>{myAsset};
                    /** Asset Wrapper Values : END  **/
                    
                    String requestJSON = JSON.serialize(resultWrapper);
                system.debug('CTX_UpsertAssetLicense - requestJSON: '+requestJSON);
                
                HttpResponse returnResponse = CTX_LicensingAPICalloutClass.upsertAssetCallout(
                    requestJSON, 
                    thisRec.Account.Country_of_Origin__c != NULL ? thisRec.Account.Country_of_Origin__c : 'INDIA'
                );
                
                system.debug('returnResponse: '+returnResponse);
                system.debug('returnResponse.getStatusCode(): '+returnResponse.getStatusCode());
                system.debug('returnResponse.getBody(): '+returnResponse.getBody());
                
                if( returnResponse.getStatusCode() == 200 ){    /** Operate over Success Response : START   **/
                    
                    
                    Map<String, Object> returnResponseOne = (Map<String, Object>)JSON.deserializeUntyped(returnResponse.getBody());
                    
                    if( 
                        thisRec.License_ID__c != (String)returnResponseOne.get('licenseId') && 
                        (String)returnResponseOne.get('licenseId') != NULL
                    ){
                        
                        updateAsset.add(
                            new Asset(
                                Id = thisRec.Id,
                                License_Id__c = (String)returnResponseOne.get('licenseId')
                            )
                        );
                        
                    }
                    
                } else{ 
                    
                    updateSnag.add(
                        CTX_LoggerImplementation.createLoggerInstance(
                            returnResponse.getBody(),
                            NULL,
                            'CTX_UpsertAssetLicense',
                            'CTX_LicensingAPICalloutClass.upsertAssetCallout()',
                            'Callout Failure',
                            thisRec.Id,
                            'Asset' )
                    );
                    if(oldAssets != NULL){
                        System.debug('####: '+oldAssets.get(thisRec.Id));
                        failedAssets.add(oldAssets.get(thisRec.Id));
                        failureEvents.add(new Sales_Sync_Licensing_Failure__e(Record_Id__c = thisRec.Id, ErrorMessages__c = returnResponse.getBody()));
                    }
                    
                }
                
            }
            /** Renewal Flow End **/
            
        }
        
        system.debug('updateSnag Size: '+updateSnag.size());
        system.debug('updateAsset Size: '+updateAsset.size());
        system.debug('failedAssets Size: '+failedAssets.size());
        
        if(updateAsset.size() > 0){
            database.update(updateAsset, FALSE);
        }
        
        if(updateSnag.size() > 0){
            database.insert(updateSnag, FALSE);
        }
        
        if(failedAssets.size() > 0){
            AssetConstants.SALES_SYNC_FLOW_RUN  = FALSE;
            //RecursiveTriggerHandler.isFirstTime = FALSE;
            database.update(failedAssets, FALSE);
            if(failureEvents.size() > 0){
                List<Database.SaveResult> results = EventBus.publish(failureEvents);
            }
        }
        
    }
    
    @AuraEnabled
    public static void activateSingleLicense(String recordId, List<String> workspaceIds){
        
        try{
            
            Map<String, List<Resource_Constraints__mdt>> mdtResourceConstaintMap = new Map<String, List<Resource_Constraints__mdt>>();
            for(Resource_Constraints__mdt mdt : Resource_Constraints__mdt.getAll().values()){
                if(mdt.Include_In_GCC__c){
                    if(mdtResourceConstaintMap.containsKey('GCC')){
                        mdtResourceConstaintMap.get('GCC').add(mdt);
                    } else {
                        mdtResourceConstaintMap.put('GCC', new List<Resource_Constraints__mdt>{mdt});
                    }
                } else {
                    if(mdtResourceConstaintMap.containsKey(mdt.Plan_Tier__c)){
                        mdtResourceConstaintMap.get(mdt.Plan_Tier__c).add(mdt);
                    } else {
                        mdtResourceConstaintMap.put(mdt.Plan_Tier__c, new List<Resource_Constraints__mdt>{mdt});
                    }
                }
            }
            
            system.debug('recordId: '+recordId);
            /** Extract Asset Field Details : START **/
            
            String queryString = ' SELECT '+CTX_LicensingConstants.LICENSEACTIVATIONQUERY+', '+CTX_LicensingConstants.CLEAR_IDENTITY_METERING_PARAMETER+ ' FROM Asset WHERE Id = :recordId ';
            system.debug(' queryString : '+queryString);
            Asset  currentAsset;
            for( Asset thisRec : (List<Asset>)database.query(queryString) ){
                currentAsset = thisRec;
            }
            system.debug(' currentAsset : '+currentAsset);
            
            /** Extract Asset Field Details : END   **/
            
            /** Iterate Over Asset and get Wrapper Details : START  **/
            CTX_UpsertAssetLicensingClass.OutterWrapper             resultWrapper 				= new CTX_UpsertAssetLicensingClass.OutterWrapper();
            CTX_UpsertAssetLicensingClass.AssetWrapper              myAsset 					= new CTX_UpsertAssetLicensingClass.AssetWrapper();
            CTX_UpsertAssetLicensingClass.AssetProductWrapper       relatedProduct				= new CTX_UpsertAssetLicensingClass.AssetProductWrapper();
            CTX_UpsertAssetLicensingClass.AssetResourceConstraints  assetResourceConstraint		= new CTX_UpsertAssetLicensingClass.AssetResourceConstraints();
            
            if( !workspaceIds.isEmpty() ){
                
                
                /**	CSM + KAM Details : START	**/
                if(currentAsset.Account.Onboarding_Owner__c != NULL){
                    resultWrapper.csm.email 									= currentAsset.Account.Onboarding_Owner__r.Email;
                    resultWrapper.csm.phone 									= currentAsset.Account.Onboarding_Owner__r.Phone;
                    resultWrapper.csm.managerEmail 								= currentAsset.Account.Onboarding_Owner__r.Manager.Email;
                    resultWrapper.csm.superManagerEmail 						= currentAsset.Account.Onboarding_Owner__r.Manager.Manager.Email;  
                }
                
                resultWrapper.kam.name 											= currentAsset.Account.Owner.Name;
                resultWrapper.kam.email 										= currentAsset.Account.Owner.Email;
                resultWrapper.kam.phone 										= currentAsset.Account.Owner.Phone;
                resultWrapper.kam.managerEmail 									= currentAsset.Account.Owner.Manager.Email;
                resultWrapper.kam.superManagerEmail 							= currentAsset.Account.Owner.Manager.Manager.Email;
                /**	CSM + KAM Details : START	**/
                /** Wrapper Instance Value Assignment : START   **/
                resultWrapper.sfOpportunityId                                       = currentAsset.Opportunity__c;
                resultWrapper.sfOrgName                                             = currentAsset.Name;
                resultWrapper.masterEmailID                                         = currentAsset.Account.Product_Email__c;
                resultWrapper.sfAccountId                                           = currentAsset.AccountId;
                resultWrapper.region                                                = currentAsset.Account.Country_of_Origin__c;
                resultWrapper.isUpdate                                              = FALSE;
                resultWrapper.isTestLicense                                         = currentAsset.Is_Test_Asset__c == NULL ? FALSE : currentAsset.Is_Test_Asset__c;
                resultWrapper.workspaceIds                                          = new List<String>(workspaceIds);
                resultWrapper.isApplicableForLicensingEmailer						= 
                    ( !currentAsset.Name?.containsIgnoreCase('Assisted Services') && currentAsset.Price > 0 ) ? TRUE : FALSE;
                
                /** Asset Wrapper Values : START    **/
                myAsset.assetId                                                     = currentAsset.Id;
                myAsset.Name                                                        = currentAsset.Name;
                myAsset.price                                                       = currentAsset.Price;
                myAsset.status                                                      = currentAsset.Status;
                myAsset.assetStartDate                                              = currentAsset.PurchaseDate;
                myAsset.assetEndDate                                                = currentAsset.UsageEndDate;
                myAsset.licenseId                                                   = currentAsset.License_Id__c;   /** NULL in case of Insert  **/
                myAsset.planTier                                                    = currentAsset.Product2.Plan_Tier__c;
                
                myAsset.isCDCEnabled                                            	= currentAsset.Product2.Plan_Tier__c == 'EINVOICE_STANDARD'|| currentAsset.Product2.Plan_Tier__c == 'CLEAR_INVOICING_STANDARD' ? currentAsset.CDC_Applicable__c : FALSE; //Added By Niraj
                
                myAsset.planId                                                      = currentAsset.Product2.Product_Plan_Id__c;
                myAsset.assetEndDateEodInstant                                      = 0;
                myAsset.saasProduct                                                 = currentAsset.Product2.Saas_Product__c;
                /** Asset > Product2    **/
                relatedProduct.licenseProduct                                       = currentAsset.Product_Line__c;
                relatedProduct.productCode                                          = currentAsset.Product2.ProductCode;
                relatedProduct.productFamily                                        = currentAsset.Product2.Family;
                relatedProduct.isStandard                                           = currentAsset.Product2.Is_Standard__c;
                myAsset.product                                                     = relatedProduct;
                /** Asset > ResourceConstraints **/
                assetResourceConstraint.noOfUserIds                                 = currentAsset.License_no_of_userids__c;
                assetResourceConstraint.noOfPurchaseInvoice                         = currentAsset.Number_of_Purchase_Invoice__c;
                assetResourceConstraint.noOfPANs                                    = currentAsset.License_no_of_pans__c;
                assetResourceConstraint.noOfGSTINs                                  = currentAsset.License_no_of_gstins__c;
                assetResourceConstraint.noOfEwayBill                                = currentAsset.Number_of_eway_bill__c;
                assetResourceConstraint.noOfB2CSalesInvoice                         = currentAsset.License_B2C_SalesInvoice_per_year__c;
                assetResourceConstraint.noOfB2BSalesInvoice                         = currentAsset.License_B2B_SalesInvoice_per_year__c;
                assetResourceConstraint.noOfAirlineInvoices                         = currentAsset.No_of_airline_invoices__c;
                assetResourceConstraint.License_no_of_total_Sales_Invoices          = currentAsset.License_no_of_total_Sales_Invoices__c;
                assetResourceConstraint.License_no_of_irns_per_year                 = currentAsset.License_no_of_irns_per_year__c;
                assetResourceConstraint.License_no_of_invoice_formats               = currentAsset.License_no_of_invoice_formats__c;
                assetResourceConstraint.License_no_of_gstin_verification_credits    = currentAsset.License_no_of_gstin_verification_credits__c;
                assetResourceConstraint.License_No_of_MM2A_2B_usage_GSTIN_mon       = currentAsset.License_No_of_MM2A_2B_usage_GSTIN_mon__c;
                assetResourceConstraint.License_no_of_Recon                         = currentAsset.License_no_of_Recon__c;
                myAsset.sfResourceConstraints                                       = (currentAsset.Account.Country_of_Origin__c !=  'India' && !String.ISBLANK(currentAsset.Account.Country_of_Origin__c)) || currentAsset.Product2.Plan_Tier__c == 'CLEAR_IDENTITY_STANDARD' || currentAsset.Product2.SaaS_Product__c == 'NOTICE_MANAGEMENT' || currentAsset.Product2.Plan_Tier__c == 'TDS_TE_ADVANTAGE' ? NULL : assetResourceConstraint;
                
                myAsset.resourceConstraints = new List<CTX_UpsertAssetLicensingClass.ResourceConstraints>();
                
                if(
                    ( currentAsset.Account.Country_of_Origin__c !=  'India' && !String.ISBLANK(currentAsset.Account.Country_of_Origin__c) )	|| 
                    currentAsset.Product2.Plan_Tier__c	 	== 'CLEAR_IDENTITY_STANDARD' 													|| 
                    currentAsset.Product2.SaaS_Product__c 	== 'NOTICE_MANAGEMENT' 															|| 
                    currentAsset.Product2.Plan_Tier__c 		== 'TDS_TE_ADVANTAGE' 															|| 
                    currentAsset.Product2.Plan_Tier__c 		== 'CLEAR_GST_PREMIUM' 															|| 
                    currentAsset.Product2.Plan_Tier__c 		== 'CLEAR_GST_ADVANTAGE' 														|| 
                    currentAsset.Product2.Plan_Tier__c 		== 'PARTNER_MANAGEMENT_STANDARD' 												||
                    currentAsset.Product2.Plan_Tier__c 		== 'CLEAR_GST_ULTIMATE'
                ){
                    
                    /**	New Resource Constraints Block : START	**/
                    Map<String, Integer>	resourceConstraintsWithValuesMap 
                        = CTX_ClearResourceConstraintsClass.identityResourceConstraintsForLicensing(currentAsset.Identity_Resource_Constraints__c);
                    /**	New Resource Constraints Block : START	**/
                    
                    List<Resource_Constraints__mdt>	mdtList 
                        = ( currentAsset.Account.Country_of_Origin__c !=  'India' && !String.ISBLANK(currentAsset.Account.Country_of_Origin__c) ) 
                        ? mdtResourceConstaintMap.get('GCC') : mdtResourceConstaintMap.get(currentAsset.Product2.Plan_Tier__c);
                    
                    for(Resource_Constraints__mdt mdt : mdtList){
                        system.debug('mdt: mdt: '+mdt);
                        if( 
                            mdt.Salesforce_Field_Source__c != 'Quote Line Item' &&
                                 mdt.Salesforce_Field_Source__c != 'Invalid'  &&
                            currentAsset.get(mdt.Salesforce_Field__c) != NULL
                        ){
                            
                            system.debug('Inside Asset Block: '+mdt);
                            
                            CTX_UpsertAssetLicensingClass.ResourceConstraints resourceConstraint = new CTX_UpsertAssetLicensingClass.ResourceConstraints();
                            resourceConstraint.resource 				= mdt.Resource__c;
                            resourceConstraint.constraintType 			= mdt.Constraint_Type__c;
                            
                            if(mdt.Constraint_Type__c == 'THRESHOLD'){
                                resourceConstraint.threshold 		= Integer.ValueOf(currentAsset.get(mdt.Salesforce_Field__c)) != NULL ? Integer.ValueOf(currentAsset.get(mdt.Salesforce_Field__c)) : 0;
                            } else if(mdt.Constraint_Type__c == 'FEATURE_AVAILABILITY'){
                                resourceConstraint.availability 	= Boolean.ValueOf(currentAsset.get(mdt.Salesforce_Field__c));
                            }
                            
                            resourceConstraint.isUsageTimeBound 		= mdt.Is_Usage_Time_Bound__c;
                            resourceConstraint.eligibleForNotification 	= mdt.Is_Eligible_For_Notification__c;
                            
                            CTX_UpsertAssetLicensingClass.Metadata metadata = new CTX_UpsertAssetLicensingClass.Metadata();
                            
                            metadata.title								= mdt.Metadata_Title__c;
                            metadata.resourceTitle						= mdt.Metadata_Resource_Title__c;
                            metadata.displayText						= mdt.Metadata_Display_Text__c != NULL ? mdt.Metadata_Display_Text__c : '';
                            metadata.displayPriority					= mdt.Metadata_Display_Priority__c.IntValue();
                            metadata.showOnSummaryPage					= mdt.Metadata_Show_On_Summary_Page__c;
                            metadata.category							= mdt.Metadata_Category__c;
                            metadata.categoryDisplayText				= mdt.Metadata_Category_Display_Text__c;
                            
                            resourceConstraint.metadata				 	= metadata;
                            
                            myAsset.resourceConstraints.add(resourceConstraint);    
                        } else if( 
                            mdt.Salesforce_Field_Source__c == 'Quote Line Item' && 
                            resourceConstraintsWithValuesMap.containsKey(mdt.Salesforce_Field_QLI__c) 
                        ){
                            
                            system.debug('Inside QLI Block: '+mdt);
                            CTX_UpsertAssetLicensingClass.ResourceConstraints resourceConstraint = new CTX_UpsertAssetLicensingClass.ResourceConstraints();
                            resourceConstraint.resource 				= mdt.Resource__c;
                            resourceConstraint.constraintType 			= mdt.Constraint_Type__c;
                            
                            if(mdt.Constraint_Type__c == 'THRESHOLD'){
                                
                                system.debug('Inside Threshhold : '+resourceConstraintsWithValuesMap.get(mdt.Salesforce_Field_QLI__c));
                                resourceConstraint.threshold 			= ( Integer.ValueOf( resourceConstraintsWithValuesMap.get(mdt.Salesforce_Field_QLI__c) ) != NULL || Integer.ValueOf( resourceConstraintsWithValuesMap.get(mdt.Salesforce_Field_QLI__c) ) != 0 ) 
                                    ? Integer.ValueOf( resourceConstraintsWithValuesMap.get(mdt.Salesforce_Field_QLI__c) ) : 0;
                            } else if(mdt.Constraint_Type__c == 'FEATURE_AVAILABILITY'){
                                resourceConstraint.availability 		= Boolean.ValueOf( resourceConstraintsWithValuesMap.get(mdt.Salesforce_Field_QLI__c) );
                            }
                            
                            
                            resourceConstraint.isUsageTimeBound 		= mdt.Is_Usage_Time_Bound__c;
                            resourceConstraint.eligibleForNotification 	= mdt.Is_Eligible_For_Notification__c;
                            
                            CTX_UpsertAssetLicensingClass.Metadata metadata = new CTX_UpsertAssetLicensingClass.Metadata();
                            
                            metadata.title								= mdt.Metadata_Title__c;
                            metadata.resourceTitle						= mdt.Metadata_Resource_Title__c;
                            metadata.displayText						= mdt.Metadata_Display_Text__c != NULL ? mdt.Metadata_Display_Text__c : '';
                            metadata.displayPriority					= mdt.Metadata_Display_Priority__c.IntValue();
                            metadata.showOnSummaryPage					= mdt.Metadata_Show_On_Summary_Page__c;
                            metadata.category							= mdt.Metadata_Category__c;
                            metadata.categoryDisplayText				= mdt.Metadata_Category_Display_Text__c;
                            
                            resourceConstraint.metadata				 	= metadata;
                            
                            myAsset.resourceConstraints.add(resourceConstraint);  
                            
                        }
                        
                    }                    
                }
                system.debug('myAsset.resourceConstraints: '+myAsset.resourceConstraints);
                resultWrapper.assets = new List<CTX_UpsertAssetLicensingClass.AssetWrapper>{myAsset};
                    /** Asset Wrapper Values : END  **/
                    
                    String requestJSON = JSON.serialize(resultWrapper);
                system.debug('CTX_UpsertAssetLicense.activateSingleLicense - requestJSON: '+requestJSON);
                
                HttpResponse returnResponse = CTX_LicensingAPICalloutClass.upsertAssetCallout(
                    requestJSON, 
                    currentAsset.Account.Country_of_Origin__c != NULL ? currentAsset.Account.Country_of_Origin__c : 'INDIA'
                );
                
                system.debug('returnResponse: '+returnResponse.getBody());
                
                if( returnResponse.getStatusCode() == 200 ){
                    Map<String, Object> returnResponseOne = (Map<String, Object>)JSON.deserializeUntyped(returnResponse.getBody());
                    
                    if( 
                        currentAsset.License_ID__c != (String)returnResponseOne.get('licenseId') && 
                        (String)returnResponseOne.get('licenseId') != NULL
                    ){
                        currentAsset.License_ID__c = (String)returnResponseOne.get('licenseId');
                    }
                    
                    currentAsset.JSON_Store__c = returnResponse.getBody();
                    
                    update currentAsset;
                } else{
                    
                    Map<String, Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(returnResponse.getBody());
                    if(errorMap.containsKey('errorCode')){
                        throw new CTX_UpsertAssetLicenseException('Error Creating License : '+errorMap.get('errorMessage'));   
                    } else if(errorMap.containsKey('code')){
                        throw new CTX_UpsertAssetLicenseException('Error Creating License : '+errorMap.get('message')); 
                    } else {
                        throw new CTX_UpsertAssetLicenseException(JSON.serialize(returnResponse.getBody()));
                    }
                    
                }
                
                
            }            
        } catch(Exception ex) {
            system.debug('Bibhu');
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    Public Static Set<String> rephraseSuggestionAPIResponse(Map<String, Object> response, Set<String> productEmails){
        
        try{
            Set<String>         productWorkspaces   = new Set<String>();
            Map<String, Object> test                = (Map<String, Object>)response.get('suggestions');
            
            for(Object thisResponse : (List<Object>)test.values()){
                
                CTX_ProductWorkspace_Response_Parser innerResponse_WorkspaceDetails 
                    = (CTX_ProductWorkspace_Response_Parser)JSON.deserialize(
                        JSON.serialize(thisResponse), CTX_ProductWorkspace_Response_Parser.class
                    );
                
                if( innerResponse_WorkspaceDetails.exactWorkspaceDetails != NULL ){
                    for(
                        CTX_ProductWorkspace_Response_Parser.ExactWorkspaceDetails thisRec : innerResponse_WorkspaceDetails.exactWorkspaceDetails
                    ){
                        
                        if(thisRec.licenseMatched){
                            productWorkspaces.add(thisRec.workSpaceId);   
                        } else{
                            for( String thisSTR : productEmails ){
                                if( thisRec.workspaceAdminEmail.containsIgnoreCase(thisSTR) ){
                                    productWorkspaces.add(thisRec.workSpaceId);
                                }
                            }
                        }
                        
                    }
                }
            } 
            return productWorkspaces;
            
        } catch(Exception ex){
            throw new AuraHandledException('Error Occured: '+ ex.getMessage());
        }
    }
    
    public class CTX_UpsertAssetLicenseException extends Exception {}  
    
    
    
}