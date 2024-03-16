public class CTX_AutoRenewLicense implements Queueable, Database.AllowsCallouts {
    
    Map<Id, Asset>      						filteredAssets;
    Map<Id, Asset>      						oldAssets;
    Set<Id>             						parentAssetId;
    String										planTier;
    Map<String, Product_Info_Metadata__mdt>		productPlanTierInfoMap;
    CTX_AutoRenewLicenseHelper.PaymentWrapper 	paymentWrapper;
    
    Public CTX_AutoRenewLicense(
        Map<Id, Asset>      filteredAssets, 
        Map<Id, Asset>      oldAssets,
        Set<Id>             parentAssetId,
        String										planTier,
        Map<String, Product_Info_Metadata__mdt>		productPlanTierInfoMap,
        CTX_AutoRenewLicenseHelper.PaymentWrapper 	paymentWrapper
    ){
        this.filteredAssets = filteredAssets;
        this.oldAssets		= oldAssets;
        this.parentAssetId	= parentAssetId;
        this.planTier = planTier;
        this.productPlanTierInfoMap = productPlanTierInfoMap;
        this.paymentWrapper = paymentWrapper;
    }
    
    public void execute(QueueableContext context){
        system.debug('productPlanTierInfoMap: '+productPlanTierInfoMap);
        callout_AutoRenew_API(filteredAssets, oldAssets, parentAssetId, planTier, productPlanTierInfoMap, paymentWrapper);
    }
    
    public static HttpResponse callout_AutoRenew_API(
        Map<Id, Asset>      						filteredAssets, 
        Map<Id, Asset>      						oldAssets,
        Set<Id>             						parentAssetId,
        String 										planTier,
        Map<String, Product_Info_Metadata__mdt>		productPlanTierInfoMap,
        CTX_AutoRenewLicenseHelper.PaymentWrapper	paymentWrapper
    ){ 
        
        system.debug('planTier AutoRenewLicense: '+planTier);
        system.debug('productPlanTierInfoMap AutoRenewLicense: '+productPlanTierInfoMap.get(planTier));
        
        List<Asset>                             	failedAssets    			= new List<Asset>();
        List<Logger__c>                         	updateSnag      			= new List<Logger__c>();
        List<Asset>                             	updateAsset     			= new List<Asset>();
        List<Billing_Details__c>                	updateBilledAmount			= new List<Billing_Details__c>();
        List<Sales_Sync_Licensing_Failure__e>   	failureEvents   			= new List<Sales_Sync_Licensing_Failure__e>();
        Boolean 										isPayLater 				= FALSE;
        Map<String, List<Resource_Constraints__mdt>>	mdtResourceConstaintMap = new Map<String, List<Resource_Constraints__mdt>>();
        Map<String, Object> 							returnResponseOne;
        HttpResponse 									returnResponse;
        Map<Id, Asset>  								assetMap    			= new Map<Id, Asset>(
            [ SELECT Id, Name, AccountId, Opportunity__c, ParentId,
             Billing_Type__c, Quantity, Price, Account_PAN__c, Status, 
             Payment_Term__c, Payment_Method__c, License_ID__c, PurchaseDate, 
             UsageEndDate, License_no_of_gstins__c, License_no_of_pans__c, 
             License_no_of_userids__c, No_of_Vendor__c,ERP__c, 
             License_B2B_SalesInvoice_per_year__c,
             No_of_VAT__c, No_of_Online_devices__c, No_of_Offline_devices__c,
             Number_of_Purchase_Invoice__c, Number_of_eway_bill__c, 
             No_of_airline_invoices__c, 
             License_B2C_SalesInvoice_per_year__c, 
             Type_of_Integration__c, 
             Type_of_Integration_QLI__c, 
             License_no_of_total_Sales_Invoices__c, 
             License_no_of_irns_per_year__c, 
             License_no_of_invoice_formats__c,
             License_no_of_gstin_verification_credits__c, 
             License_No_of_MM2A_2B_usage_GSTIN_mon__c, 
             License_no_of_Recon__c, 
             No_of_expected_B2C_invoices_for_QR_code__c, Workspace_Details__c, 
             CDC_Applicable__c,
             Master_Email__c, Product_Name_Formula__c, Platform__c, Product_Line__c, Is_Test_Asset__c, 
             Days_to_Extend__c, 
             
             No_Of_GST_ADVANCED_APIs__c, No_Of_GST_ADVANCED_PLUS_APIs__c, No_Of_PAN_OCR_APIs__c, No_of_PAN_verification_API_old__c,
             
             GSTIN_Level_Recon__c, PAN_Level_Recon__c,
             
             Parent.License_Id__c,
             Account_Record_Type__c,
             
             Account.Master_admin_Email__c, Account.Product_Email__c, 
             Account.Org_Unit_ID__c, Account.Name, Account.Country_of_Origin__c,
             Account.IsTestAccount__c, 
             
             Opportunity__r.Name, Opportunity__r.Billing_Frequency__c, 
             Opportunity__r.Billing_F__c, Opportunity__r.Billing_Method__c,
             
             Product2.Plan_Tier__c, Product2.Product_Plan_Id__c, Product2.Is_Standard__c, 
             Product2.Family, Product2.ProductCode, Product2.Constraint_JSON__c, Product2.Saas_Product__c,
             
             No_of_Bank_verification_API__c, No_of_MCA_Company_details_API__c, No_of_PAN_verification_detailed_APIs__c, 
             No_of_PAN_to_GSTIN_APIs__c, No_of_PAN_verification_API__c, No_of_TDS_206_sync_API__c, No_of_MSME_API__c, 
             Number_of_pulls__c, No_of_PAN_Verification_with_Father_Name__c, Number_of_TANs__c, 
             Number_of_Deduction_Transactions_per_Qua__c,
             
             Account.Onboarding_Owner__c,Account.Onboarding_Owner__r.Email,Account.Onboarding_Owner__r.Phone, 
             Product2.IsActive,CurrencyIsoCode,
             Account.Onboarding_Owner__r.ManagerId,Account.Onboarding_Owner__r.Manager.Email, 
             Account.Onboarding_Owner__r.Manager.Phone,BackEndQuoteDiscount__c,
             Account.Onboarding_Owner__r.Manager.ManagerId,Account.Onboarding_Owner__r.Manager.Manager.Email, 
             Account.Onboarding_Owner__r.Manager.Manager.Phone,
             
             Account.Owner.Name,Account.Owner.Email,Account.Owner.Phone,OwnerId, Account.Owner.Manager.Email, 
             Account.Owner.Manager.Manager.Email,
             
             (SELECT Id, Amount_Billed__c FROM Billing_Details__r)
             
             FROM Asset WHERE
             Id IN :filteredAssets.keySet() ] );
        List<QuoteLineItem> 							qliList 				= [ SELECT 
                                                                                   
                                                                                   Id, Sale_Price__c, 
                                                                                   Total_Renewal_Price__c, 
                                                                                   Product2.Plan_Tier__c
                                                                                   
                                                                                   FROM QuoteLineItem WHERE 
                                                                                   Quote.OpportunityId = :assetMap.values()[0].Opportunity__c ];
         QuoteLineItem									qliRec;
        
        /**	Check the Appropiate QLI to be mapped : START	**/
       
        if( planTier != NULL ){
            for( QuoteLineItem thisRec : qliList ){
                if( thisRec.Product2.Plan_Tier__c == planTier ){
                    qliRec = thisRec;
                }
        }
        } else{
            qliRec = qliList[0];
        }
        
        /**	Check the Appropiate QLI to be mapped : END	**/
        
        /** Iterate Over Asset and get Wrapper Details : START  **/
        Billing_Details__c thisBillingDetail = new Billing_Details__c();
        Boolean updateBilling = FALSE;
        if(assetMap.values().Billing_Details__r.size() > 0){
            updateBilling = TRUE;
            thisBillingDetail = assetMap.values()[0].Billing_Details__r[0];
        }
        
        for( Resource_Constraints__mdt mdt : Resource_Constraints__mdt.getAll().values() ){
            
            if(mdt.Include_In_GCC__c){
                if(mdtResourceConstaintMap.containsKey('GCC')){
                    mdtResourceConstaintMap.get('GCC').add(mdt);
                } else{
                    mdtResourceConstaintMap.put('GCC', new List<Resource_Constraints__mdt>{mdt});
                }
            } else{
                if(mdtResourceConstaintMap.containsKey(mdt.Plan_Tier__c)){
                    mdtResourceConstaintMap.get(mdt.Plan_Tier__c).add(mdt);
                } else{
                    mdtResourceConstaintMap.put(mdt.Plan_Tier__c, new List<Resource_Constraints__mdt>{mdt});
                }
            }
        }
        
        
        for( Asset thisRec : assetMap.values() ){
            
            CTX_AutoRenewLicensingClass.OutterWrapper             resultWrapper   
                = new CTX_AutoRenewLicensingClass.OutterWrapper();
            CTX_AutoRenewLicensingClass.AssetWrapper              myAsset 
                = new CTX_AutoRenewLicensingClass.AssetWrapper();
            CTX_AutoRenewLicensingClass.AssetProductWrapper       relatedProduct 
                = new CTX_AutoRenewLicensingClass.AssetProductWrapper();
            CTX_AutoRenewLicensingClass.AssetResourceConstraints  assetResourceConstraint
                = new CTX_AutoRenewLicensingClass.AssetResourceConstraints();
            
            List<String>                                            workspaceIds            
                = new List<String>();
            Boolean                                                 isFetchWorkspaceSuccess 
                = FALSE;
            
            CTX_AutoRenewLicensingClass.RenewalLicenseDetails 	renewalLicenseDetails
                = new CTX_AutoRenewLicensingClass.RenewalLicenseDetails();
            
            
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
            resultWrapper.isTestLicense                                         = thisRec.Is_Test_Asset__c == NULL ? FALSE : thisRec.Is_Test_Asset__c;
            resultWrapper.masterEmailID                                         = thisRec.Account.Product_Email__c;
            resultWrapper.sfAccountId                                           = thisRec.AccountId;
            resultWrapper.region                                                = thisRec.Account.Country_of_Origin__c;
            resultWrapper.isApplicableForLicensingEmailer						= 
                ( !thisRec.Name?.containsIgnoreCase('Assisted Services') && thisRec.Price > 0 ) ? TRUE : FALSE;
            /** Asset Wrapper Values : START    **/
            myAsset.assetId                                                     = thisRec.Id;
            myAsset.licenseId                                                   = thisRec.License_Id__c;
            myAsset.planTier                                                    = planTier != NULL ? planTier : thisRec.Product2.Plan_Tier__c;
            
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
            myAsset.sfResourceConstraints                                       = (thisRec.Account.Country_of_Origin__c !=  'India' && !String.ISBLANK(thisRec.Account.Country_of_Origin__c)) || thisRec.Product2.Plan_Tier__c == 'CLEAR_IDENTITY_STANDARD' || thisRec.Product2.SaaS_Product__c == 'NOTICE_MANAGEMENT' || thisRec.Product2.Plan_Tier__c == 'TDS_TE_ADVANTAGE' ? NULL : assetResourceConstraint;
            
            myAsset.resourceConstraints = new List<CTX_AutoRenewLicensingClass.ResourceConstraints>();
            
            if(
                (thisRec.Account.Country_of_Origin__c !=  'India' && !String.ISBLANK(thisRec.Account.Country_of_Origin__c)) || thisRec.Product2.Plan_Tier__c == 'CLEAR_IDENTITY_STANDARD' || thisRec.Product2.SaaS_Product__c == 'NOTICE_MANAGEMENT' || thisRec.Product2.Plan_Tier__c == 'TDS_TE_ADVANTAGE' || 
                thisRec.Product2.Plan_Tier__c == 'CLEAR_GST_PREMIUM' || thisRec.Product2.Plan_Tier__c == 'CLEAR_GST_ADVANTAGE' || thisRec.Product2.Plan_Tier__c == 'CLEAR_GST_ULTIMATE' || thisRec.Product2.Plan_Tier__c == 'EINVOICE_STANDARD' || thisRec.Product2.Plan_Tier__c == 'EINVOICE_ULTIMATE'
            ){
                //CTX_AutoRenewLicensingClass.ResourceConstraints
                List<Resource_Constraints__mdt> mdtList =  (thisRec.Account.Country_of_Origin__c !=  'India' && !String.ISBLANK(thisRec.Account.Country_of_Origin__c))? mdtResourceConstaintMap.get('GCC') : mdtResourceConstaintMap.get(thisRec.Product2.Plan_Tier__c);
                for(Resource_Constraints__mdt mdt : mdtList){
                    if(thisRec.get(mdt.Salesforce_Field__c) != NULL){
                        CTX_AutoRenewLicensingClass.ResourceConstraints resourceConstraint = new CTX_AutoRenewLicensingClass.ResourceConstraints();
                        resourceConstraint.resource 				= mdt.Resource__c;
                        resourceConstraint.constraintType 			= mdt.Constraint_Type__c;
                        if(mdt.Constraint_Type__c == 'THRESHOLD'){
                            resourceConstraint.threshold 				= Integer.ValueOf(thisRec.get(mdt.Salesforce_Field__c)) != NULL ? Integer.ValueOf(thisRec.get(mdt.Salesforce_Field__c)) : 0;
                        } else if(mdt.Constraint_Type__c == 'FEATURE_AVAILABILITY'){
                            resourceConstraint.availability 			= Boolean.ValueOf(thisRec.get(mdt.Salesforce_Field__c));
                        }
                        resourceConstraint.isUsageTimeBound 		= mdt.Is_Usage_Time_Bound__c;
                        resourceConstraint.eligibleForNotification 	= mdt.Is_Eligible_For_Notification__c;
                        
                        CTX_AutoRenewLicensingClass.Metadata metadata = new CTX_AutoRenewLicensingClass.Metadata();
                        
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
            
            resultWrapper.assets = new List<CTX_AutoRenewLicensingClass.AssetWrapper>{myAsset};
                System.debug('@paymentWrapper'+paymentWrapper);
            resultWrapper.renewalLicenseDetails.omsOrderId 			= paymentWrapper.omsOrderId;
            resultWrapper.renewalLicenseDetails.invoiceContent 		= paymentWrapper.invoice;
            resultWrapper.renewalLicenseDetails.paymentMode  		= paymentWrapper.paymentMode;
            resultWrapper.renewalLicenseDetails.orderStatus  		= paymentWrapper.paymentMode == 'PAY_NOW' ? 'Fulfilled': 'Initiated';
            resultWrapper.renewalLicenseDetails.overDuePrice 		= paymentWrapper.paymentMode == 'PAY_NOW' ? 0 : qliRec.Total_Renewal_Price__c;
            /** Asset Wrapper Values : END  **/
            
            String requestJSON = JSON.serialize(resultWrapper);
            system.debug('CTX_UpsertAssetLicense - requestJSON: '+requestJSON);
            
            
            If(paymentWrapper.paymentMode == 'PAY_NOW'){
                
                returnResponse  = CTX_LicensingAPICalloutClass.upsertAssetCallout_AutoRenewal(
                    requestJSON, 
                    paymentWrapper.previousLicense 
                );
                
                
            }else{
                isPayLater = TRUE;
                returnResponse  = CTX_LicensingAPICalloutClass.upsertAssetCallout_AutoRenewal_Offline(
                    requestJSON, 
                    paymentWrapper.previousLicense 
                );
            }
            
            system.debug('returnResponse: '+returnResponse);
            system.debug('returnResponse.getStatusCode(): '+returnResponse.getStatusCode());
            system.debug('returnResponse.getBody(): '+returnResponse.getBody());
            
            if( returnResponse.getStatusCode() == 200 ){    /** Operate over Success Response : START   **/
                
                if(!isPayLater){
                    
                    returnResponseOne = (Map<String, Object>)JSON.deserializeUntyped(returnResponse.getBody());
                    if( 
                        thisRec.License_ID__c != (String)returnResponseOne.get('licenseId') && 
                        (String)returnResponseOne.get('licenseId') != NULL
                    ){
                        // Async
                        updateAsset.add(
                            new Asset(
                                Id = thisRec.Id,
                                Product2Id = planTier != NULL ? productPlanTierInfoMap.get(planTier).Product_Id__c : thisRec.Product2Id,
                                License_Id__c = (String)returnResponseOne.get('licenseId')
                            )
                        );
                        
                        if(updateBilling){
                            thisBillingDetail.Payment_Amount_Received__c  = qliRec.Sale_Price__c;
                            updateBilledAmount.add(thisBillingDetail);
                        }
                        
                        
                    }
                } else{
                    
                    updateAsset.add(
                        new Asset(
                            Id = thisRec.Id,
                            Product2Id = planTier != NULL ? productPlanTierInfoMap.get(planTier).Product_Id__c : thisRec.Product2Id
                        )
                    );
                }
                
                RecursiveTriggerHandler.isFirstTimeOpportunity 	= FALSE;
                AssetConstants.LICENSING_SYNC_FLOW_RUN 			= FALSE;
                RecursiveTriggerHandler.isFirstTime				= FALSE;
                RecursiveTriggerHandler.isFirstTimeRenewed 		= FALSE;
                
                if(!system.isFuture()){
                    CTX_SyncQLIDetailsToAsset.syncAssetDetails(qliRec.Id); 
                }
                
                
                RecursiveTriggerHandler.isFirstTimeOpportunity 	= TRUE;
                AssetConstants.LICENSING_SYNC_FLOW_RUN 			= TRUE;
                RecursiveTriggerHandler.isFirstTime				= TRUE;
                RecursiveTriggerHandler.isFirstTimeRenewed 		= TRUE;
                
                
            } else{
                
                returnResponseOne = (Map<String, Object>)JSON.deserializeUntyped(returnResponse.getBody());
                
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
                
                failedAssets.add(assetMap.get(thisRec.Id));
                failureEvents.add(new Sales_Sync_Licensing_Failure__e(Record_Id__c = thisRec.Id, ErrorMessages__c = returnResponse.getBody()));
                
                
            }
            
        }
        /** Renewal Flow End **/
        
        
        
        system.debug('updateSnag Size: '+updateSnag.size());
        system.debug('updateAsset Size: '+updateAsset.size());
        system.debug('updateAsset : '+updateAsset);
        system.debug('failedAssets Size: '+failedAssets.size());
        system.debug('failedAssets : '+failedAssets);
        
        if(updateAsset.size() > 0){
            
            OpportunityConstants.AUTO_RENEW_RULE 			= FALSE;
            RecursiveTriggerHandler.isFirstTimeOpportunity 	= FALSE;
            RecursiveTriggerHandler.isFirstTime = FALSE;
            
            database.update(updateAsset, FALSE);
            
            OpportunityConstants.AUTO_RENEW_RULE 			= TRUE;
            RecursiveTriggerHandler.isFirstTimeOpportunity 	= TRUE;
            RecursiveTriggerHandler.isFirstTime = TRUE;
        }
        
        if(updateBilledAmount.size() > 0){
            database.update(updateBilledAmount, FALSE);
        }
        
        if(updateSnag.size() > 0){
            database.insert(updateSnag, FALSE);
        }
        
        if(failedAssets.size() > 0){
            AssetConstants.LICENSING_SYNC_FLOW_RUN  = FALSE;
            //RecursiveTriggerHandler.isFirstTime = FALSE;
            database.update(failedAssets, FALSE);
            if(failureEvents.size() > 0){
                List<Database.SaveResult> results = EventBus.publish(failureEvents);
            }
        }
        
        return returnResponse;
    } 
    
    
    
    public class CTX_UpsertAssetLicenseException extends Exception {}  
    
    
}