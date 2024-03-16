/** Ashwin - Auto Renewal - To Sync Licenses where Auto Renewal is opted in/out in SF **/

public class CTX_AutoRenewalFlag {
    
    public static void whitelistAccount( 
        Map<Id,Account> autoRenewAccounts, 
        Map<Id, String> accountIdAndAutoRenewalProductNameMap, 
        Boolean productAddition ){ /**	Bulkification is disabled : Do in Set of 1	*/
            
            system.debug('Inside CTX_AutoRenewalFlag');
            List<Asset> 						createRenewalOpp 		= new List<Asset>();
            List<QuoteLineItem> 				updateRenewalQli 		= new List<QuoteLineItem>();
            Map<Id, Asset> 						astMap 					= new  Map<Id, Asset>();
            Map<Id, Asset> 						astMapToEnableAutoRenew	= new  Map<Id, Asset>();
            Map<String, String> 				assetAccountMap			= new Map<String, String>();
            String 								type 					= 'Opportunity';
            Map<String, Schema.SObjectType> 	schemaMap 				= Schema.getGlobalDescribe();
            Schema.SObjectType 					oppSchema            	= schemaMap.get(type);
            Map<String, Schema.SObjectField> 	fieldMap 				= oppSchema.getDescribe().fields.getMap();
            String 								numberOfDays 			= System.Label.CTX_EnableAutoRenewalDate;
            Date 								assetWillExpireIn3Months= System.today() + Integer.valueOf(numberOfDays);
            String 								runningAccountId		= new List<Id>(autoRenewAccounts.keySet())[0];
            Account								runningAccount			= autoRenewAccounts.values()[0];
            List<String>						enabledProduct			= system.label.Auto_Renewal_Product_Enablement?.split(',');
            Map<Id, Asset>						assetMapForRenewal		= new Map<Id, Asset>(
                [ SELECT 
                 
                 Id, Name, AccountId, License_ID__c, PurchaseDate, UsageEndDate, Price, CurrencyIsoCode,  
                 Opportunity__c, Renewal_Opportunity__c, 
                 BackEndQuote__c, BackEndQuoteDiscount__c, 
                 OwnerId, Payment_Method__c,  
                 Number_of_eway_bill__c, License_no_of_gstins__c, 
                 License_no_of_irns_per_year__c, License_no_of_pans__c, License_no_of_userids__c, 
                 
                 Product2.Plan_Tier__c, 
                 Product2.IsActive,
                 Product2.Product_Line__c,
                 
                 Account.Name, 
                 Account.Account_Number__c, 
                 Account.Bank_Branch__c, 
                 Account.Bank_IFSC_Code__c, 
                 Account.Bank_Name__c,
                 Account.Bank_Swift_Code__c, 
                 Account.Bank_Account_Name__c, 
                 Account.TDS__c, 
                 Account.TDS_Percent_Applicable__c,
                 Account.Sum_of_ARR_Assets__c, 
                 Account.Auto_Renewal_Product__c,
                 Account.Country_of_Origin__c, 
                 Account.ParentId, 
                 Account.Is_Auto_Renewal_Enabled__c,
                 
                 Account.Onboarding_Owner__c, 
                 Account.Onboarding_Owner__r.Email,
                 Account.Onboarding_Owner__r.Phone,
                 Account.Onboarding_Owner__r.ManagerId,
                 Account.Onboarding_Owner__r.Manager.Email,
                 Account.Onboarding_Owner__r.Manager.Phone,
                 Account.Onboarding_Owner__r.Manager.ManagerId,
                 Account.Onboarding_Owner__r.Manager.Manager.Email,
                 Account.Onboarding_Owner__r.Manager.Manager.Phone,
                 
                 Account.Owner.Name,
                 Account.Owner.Email,
                 Account.Owner.Phone, 
                 Account.Owner.Manager.Email, 
                 Account.Owner.Manager.Manager.Email,
                 
                 Opportunity__r.Billing_Address__c,
                 Opportunity__r.Billing_GST__c,
                 Opportunity__r.Pincode__c, 
                 Opportunity__r.Legal_Entity_Name_Of_The_Client__c,
                 Opportunity__r.Shipping_Address__c, 
                 Opportunity__r.State_2__c, 
                 Opportunity__r.E_Sign_Customer_Info__r.Name,
                 Opportunity__r.E_Sign_Customer_Info__r.Email,
                 Opportunity__r.E_Sign_Customer_Info__r.Phone, 
                 Opportunity__r.Account.TDS__c, 
                 Opportunity__r.Account.TDS_Percent_Applicable__c,
                 
                 Renewal_Opportunity__r.Billing_GST__c,
                 Renewal_Opportunity__r.Billing_Address__c,
                 Renewal_Opportunity__r.Shipping_Address__c, 
                 Renewal_Opportunity__r.State_2__c, 
                 Renewal_Opportunity__r.Legal_Entity_Name_Of_The_Client__c,
                 Renewal_Opportunity__r.Pincode__c,
                 Renewal_Opportunity__r.E_Sign_Customer_Info__c
                 
                 FROM Asset WHERE 
                 AccountId 						= :runningAccountId 						AND 
                 Product2.Product_Line__c 	 	IN :enabledProduct						 	AND
                 License_ID__c 					!= NULL										AND
                 Status IN :System.Label.CTX_AutoRenewAssetStatus.split(',') ]
            );
            
            if( assetMapForRenewal.values() != NULL && assetMapForRenewal.values().size() > 0 ){
                
                if( !autoRenewAccounts.isEmpty() ){
                    
                    for( Asset thisRec : assetMapForRenewal.values() ){
                        if( thisRec.Product2.Product_Line__c == accountIdAndAutoRenewalProductNameMap.get(thisRec.AccountId) ){
                            
                            String	errorMessage	= ' Enter values for the following fields: ';
                            Boolean isErrorExist 	= FALSE;
                            
                            if( thisRec.Account.Is_Auto_Renewal_Enabled__c  ){
                                if(thisRec.Renewal_Opportunity__c != NULL){
                                    
                                    errorMessage += thisRec.Renewal_Opportunity__c+' - ';
                                    
                                    for( String thisSTR : system.label.Auto_Renewal_Opportunity_Required_Fields.split(';') ){
                                        
                                        if( thisRec.Renewal_Opportunity__r.get(thisSTR) == NULL ){
                                            String fieldLabel = fieldMap.get(thisSTR).getDescribe().getLabel();
                                            errorMessage += (fieldLabel+' ,');
                                            isErrorExist = TRUE;
                                        }
                                    }
                                    
                                    if(isErrorExist){
                                        errorMessage 	= errorMessage.removeEnd(' ,');
                                        autoRenewAccounts.get(thisRec.AccountId).addError(errorMessage);
                                        isErrorExist = FALSE;
                                    }
                                }else if(thisRec.Opportunity__c != NULL){
                                    errorMessage += thisRec.Opportunity__c+' - ';
                                    
                                    for( String thisSTR : system.label.Auto_Renewal_Opportunity_Required_Fields.split(';') ){
                                        
                                        if( thisRec.Opportunity__r.get(thisSTR) == NULL ){
                                            String fieldLabel = fieldMap.get(thisSTR).getDescribe().getLabel();
                                            errorMessage += (fieldLabel+' ,');
                                            isErrorExist = TRUE;
                                        }
                                    }
                                    
                                    if(isErrorExist){
                                        errorMessage 	= errorMessage.removeEnd(' ,');
                                        autoRenewAccounts.get(thisRec.AccountId).addError(errorMessage);
                                        isErrorExist = FALSE;
                                    }
                                    
                                }else{
                                    autoRenewAccounts.get(thisRec.AccountId).addError('Opportunity Not Found');
                                }
                                
                                
                            }
                            
                            astMap.put(thisRec.Id, thisRec);               
                            
                            if(thisRec.Account.Is_Auto_Renewal_Enabled__c == TRUE && thisRec.Renewal_Opportunity__c == NULL){
                                createRenewalOpp.add(thisRec);
                            }/**	What if the Renewal Opportunity is Created bt Asset is yet to be created	**/
                            
                            System.debug('@UsageEndDate'+thisRec.UsageEndDate);
                            System.debug('@assetWillExpireIn3Months'+assetWillExpireIn3Months);
                            
                            if(!thisRec.Account.Is_Auto_Renewal_Enabled__c ||
                               (thisRec.Account.Is_Auto_Renewal_Enabled__c && thisRec.UsageEndDate < assetWillExpireIn3Months)){
                                   astMapToEnableAutoRenew.put(thisRec.Id, thisRec); 
                                   assetAccountMap.put(thisRec.License_ID__c, thisRec.AccountId);   
                               } else{
                                   /** Throw an error for no Renewal Enablement	**/
                                   autoRenewAccounts.get(thisRec.AccountId).addError('Renewal is outside '+(assetWillExpireIn3Months-1)+' days window');
                               }
                            
                        }
                    }
                    
                    /** Create Renewal Opportunity if Auto Renwal enabled 3 months before PED and Renewal Opportunity is not created **/
                    if(!createRenewalOpp.isEmpty()){
                        try{
                            Opportunity thisOpp = CTX_AssetAutoRenewalBatch.createOpportunityQuoteQuoteLineItem(createRenewalOpp);
                        } catch( Exception ex ){
                            runningAccount.addError(ex.getMessage());
                        }
                        
                    }
                    
                    
                    if(astMap.values().size() > 0){
                        for(Asset thisRec : astMap.values()){ 
                            if(thisRec.Account.Is_Auto_Renewal_Enabled__c == TRUE){
                                System.enqueueJob(new CTX_FetchUsageDetails(thisRec.License_ID__c, thisRec.AccountId, astMapToEnableAutoRenew, assetAccountMap));
                            } else {
                                if(astMapToEnableAutoRenew.values().size() > 0 && assetAccountMap.values().size() > 0)
                                    enableAutoRenewal( astMapToEnableAutoRenew, assetAccountMap);
                            }
                        }
                    }
                    
                }
            } else{
                system.debug('No Asset available for Auto Renewal.');
            }
            
        }
    
    Public static void enableAutoRenewal( Map<Id, Asset> astMapToEnableAutoRenew, Map<String, String> assetAccountMap){
        
        
        List<CTX_AutoRenewalFlagCallout.EnableAutoRenewalWrapper> 		requestBody  	= new List<CTX_AutoRenewalFlagCallout.EnableAutoRenewalWrapper>();
        
        if(astMapToEnableAutoRenew.values().size() > 0){
            for(Asset thisRec : astMapToEnableAutoRenew.values()){ 
                
                Map<String, Auto_Renewal_Constraints__mdt> resourceConstraintMap = CTX_GetRenewalParameterAndPrice.getMetadataDetails(thisRec.Product2.Plan_Tier__c);
                
                CTX_AutoRenewalFlagCallout.EnableAutoRenewalWrapper 	reqWrap 		= new CTX_AutoRenewalFlagCallout.EnableAutoRenewalWrapper();
                
                reqWrap.licenseId 						= thisRec.License_Id__c;
                reqWrap.autoRenewalStatus 				= thisRec.Account.Is_Auto_Renewal_Enabled__c;
                reqWrap.numberOfDaysExtended			= thisRec.Account.Sum_of_ARR_Assets__c <= 100000 ? 
                    Integer.valueOf(system.Label.Days_Extension_1L) : Integer.valueOf(system.Label.Days_Extension_1L_LessThan) ;
                
                if(thisRec.Account.Onboarding_Owner__c != NULL){
                    reqWrap.csm.email 						= thisRec.Account.Onboarding_Owner__r.Email;
                    reqWrap.csm.phone 						= thisRec.Account.Onboarding_Owner__r.Phone;
                    reqWrap.csm.managerEmail 				= thisRec.Account.Onboarding_Owner__r.Manager.Email;
                    reqWrap.csm.superManagerEmail 			= thisRec.Account.Onboarding_Owner__r.Manager.Manager.Email;  
                }
                
                reqWrap.kam.name 							= thisRec.Account.Owner.Name;
                reqWrap.kam.email 							= thisRec.Account.Owner.Email;
                reqWrap.kam.phone 							= thisRec.Account.Owner.Phone;
                reqWrap.kam.managerEmail 					= thisRec.Account.Owner.Manager.Email;
                reqWrap.kam.superManagerEmail 				= thisRec.Account.Owner.Manager.Manager.Email;
                
                
                reqWrap.previousYearPrice					= thisRec.Price;
                
                reqWrap.bankDetails.accountName				= thisRec.Account.Bank_Account_Name__c;
                reqWrap.bankDetails.accountNumber			= thisRec.Account.Account_Number__c;
                reqWrap.bankDetails.bankName				= thisRec.Account.Bank_Name__c;
                reqWrap.bankDetails.bankIFSCCode			= thisRec.Account.Bank_IFSC_Code__c;
                reqWrap.bankDetails.bankBranch				= thisRec.Account.Bank_Branch__c;
                reqWrap.bankDetails.bankSwiftCode			= thisRec.Account.Bank_Swift_Code__c;		
                
                reqWrap.validity.startAt					= thisRec.UsageEndDate?.addDays(1);
                reqWrap.validity.endAt						= reqWrap.validity.startAt.addYears(1);
                
                requestBody.add(reqWrap);
            }
        }
        
        if(requestBody != NULL && !assetAccountMap.isEmpty()){
            System.enqueuejob(new CTX_AutoRenewalFlagCallout(requestBody, assetAccountMap)); 
        }
        
        
    }
    
    
}