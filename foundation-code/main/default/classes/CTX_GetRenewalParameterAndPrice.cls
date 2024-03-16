/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-05-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(urlMapping='/getRenewalDetails')
global class CTX_GetRenewalParameterAndPrice
{
    
    @HttpPost
    global static RenewalWrapper renewLicense() {
        
        RestRequest 								request								= RestContext.request;
        String 										requestBody							= request.requestBody.toString();
        CTX_LicenseMetadataParser.LicenseWrapper 	licenseWrap							= CTX_LicenseMetadataParser.convertLicenseDetails(requestBody);
        String 										licenseId							= licenseWrap.licenseId;
        String 										planTier							= licenseWrap.planTier;
        Map<String, Integer> 						usageParams							= licenseWrap.usageMap;
        
        String										queryString							= ' SELECT Id, IsSyncing__c, Auto_Renewal_Sale_Price__c, Quote.IsSyncing, Purchases_Invoices_one__c, TDS_Price_Recommended__c, Total_Tax_Value_Recommended__c, Total_Renewal_Price_Recommended__c, Product2.Plan_Tier__c, No_of_GSTIN_verification_credits__c, BtoB_Sales_one__c, BtoC_Sales_one__c, Number_of_Purchase_Invoice__c, Total_no_of_Pages_in_Purchase_Invoices__c, PR_B2B_0_2_B2C__c, Is_Plan_Upgradable__c, Recommended_Plan_Tier__c, Recommended_Plan_Parameters__c, No_of_days_to_Upgrade__c, Is_TDS_Applicable__c, Quote.Opportunity.If_SEZ__c, Period_Start_date__c, Period_End_date__c, Over_Usage_Charge__c, No_of_EWBs__c, Quote.OpportunityId, Quote.Opportunity.Account.Name, Quote.Opportunity.Account.TDS__c, Quote.Opportunity.Account.TDS_Percent_Applicable__c, Quote.Opportunity.Account.Bank_Account_Name__c, Quote.Opportunity.Account.Account_Number__c, Quote.Opportunity.Is_Auto_Renewal_Enabled__c, Quote.Opportunity.Account.Bank_Branch__c, Quote.Opportunity.Account.Bank_IFSC_Code__c, Quote.Opportunity.Account.Bank_Name__c, Quote.Opportunity.Account.Bank_Swift_Code__c, Product2Id, Product2.Name, Product_Formula__c, Applicable_TDS__c, TAN_Number__c, UnitPrice, Sale_Price__c, Is_Formula_Price_Applicable__c, Is_Price_Locked__c, Renewal_Service_Payload__c, Quote.Opportunity.Billing_Address__c, Quote.Opportunity.Shipping_Address__c, Quote.Opportunity.State_2__c, Quote.Opportunity.Pincode__c, Quote.Opportunity.Legal_Entity_Name_Of_The_Client__c, Quote.Opportunity.Billing_GST__c, Parent_Asset__r.License_ID__c, Quote.Opportunity.E_Sign_Customer_Info__r.Name, Quote.Opportunity.E_Sign_Customer_Info__r.Email, Quote.Opportunity.E_Sign_Customer_Info__r.Phone, No_of_PAN_one__c, No_of_GSTIN_one__c, No_of_User_ID_one__c, No_of_IRNs__c, Number_of_eway_bill__c, No_of_expected_B2C_invoices_for_QR_code__c, No_of_Vendors_one__c, No_of_TANs__c, Number_of_Deduction_Transactions_per_Qua__c FROM QuoteLineItem WHERE  Parent_Asset__r.License_Id__c =: licenseId AND Product2.Plan_Tier__c =: planTier ';
        List<QuoteLineItem> 						renewalQLIs 						= [ SELECT Id, IsSyncing__c, Auto_Renewal_Sale_Price__c, Purchases_Invoices_one__c, TDS_Price_Recommended__c, Total_Tax_Value_Recommended__c, Total_Renewal_Price_Recommended__c, Product2.Plan_Tier__c, No_of_GSTIN_verification_credits__c, BtoB_Sales_one__c, BtoC_Sales_one__c, Number_of_Purchase_Invoice__c, Total_no_of_Pages_in_Purchase_Invoices__c, PR_B2B_0_2_B2C__c, Is_Plan_Upgradable__c, Recommended_Plan_Tier__c, Recommended_Plan_Parameters__c, No_of_days_to_Upgrade__c, Is_TDS_Applicable__c, Quote.Opportunity.If_SEZ__c, Period_Start_date__c, Period_End_date__c, Over_Usage_Charge__c, No_of_EWBs__c, Quote.IsSyncing, Quote.OpportunityId, Quote.Opportunity.Account.Name, Quote.Opportunity.Account.TDS__c, Quote.Opportunity.Account.TDS_Percent_Applicable__c, Quote.Opportunity.Account.Bank_Account_Name__c, Quote.Opportunity.Account.Account_Number__c, Quote.Opportunity.Is_Auto_Renewal_Enabled__c, Quote.Opportunity.Account.Bank_Branch__c, Quote.Opportunity.Account.Bank_IFSC_Code__c, Quote.Opportunity.Account.Bank_Name__c, Quote.Opportunity.Account.Bank_Swift_Code__c, Product2Id, Product2.Name, Product_Formula__c, Applicable_TDS__c, TAN_Number__c, UnitPrice, Sale_Price__c, Is_Formula_Price_Applicable__c, Is_Price_Locked__c, Renewal_Service_Payload__c, Quote.Opportunity.Billing_Address__c, Quote.Opportunity.Shipping_Address__c, Quote.Opportunity.State_2__c, Quote.Opportunity.Pincode__c, Quote.Opportunity.Legal_Entity_Name_Of_The_Client__c, Quote.Opportunity.Billing_GST__c, Parent_Asset__r.License_ID__c, Quote.Opportunity.E_Sign_Customer_Info__r.Name, Quote.Opportunity.E_Sign_Customer_Info__r.Email, Quote.Opportunity.E_Sign_Customer_Info__r.Phone, No_of_PAN_one__c, No_of_GSTIN_one__c, No_of_User_ID_one__c, No_of_IRNs__c, Number_of_eway_bill__c, No_of_expected_B2C_invoices_for_QR_code__c, No_of_Vendors_one__c, No_of_TANs__c, Number_of_Deduction_Transactions_per_Qua__c FROM QuoteLineItem WHERE  Parent_Asset__r.License_Id__c =: licenseId AND Product2.Plan_Tier__c =: planTier ] ;
        Map<String, Auto_Renewal_Constraints__mdt> 	resourceConstraintMap 				= getMetadataDetails(planTier);
        Map<String, Auto_Renewal_Constraints__mdt> 	recomendedresourceConstraintMap;
        
        List<String>								autoRenewalEnabledPlanTiers			= new List<String>{ 'EINVOICE_STANDARD', 'EINVOICE_ULTIMATE', 'CLEAR_GST_ADVANTAGE', 'CLEAR_GST_PREMIUM', 'CLEAR_GST_ULTIMATE', 'MAX_PREMIUM', 'MAX_ULTIMATE', 'TDS_TE_ADVANTAGE', 'TDS_ULTIMATE' };
            RenewalWrapper 							renewalWrap 						= new RenewalWrapper();
        
        system.debug('licenseId: ' +licenseId);
        system.debug('renewalQLIs: '+renewalQLIs);
        
        if( !autoRenewalEnabledPlanTiers.contains(planTier) ){
            renewalWrap.errorMessage = 'Plan should be related to EINVOICE/GST';
        }
        
        if( renewalQLIs != NULL && renewalQLIs.size() > 0){
                        
            system.debug('is it Syncing: '+renewalQLIs[0].IsSyncing__c);
            Boolean isSync = renewalQLIs[0].IsSyncing__c;
            /**	Recomendaded Plan Block : START	**/
            if( renewalQLIs[0].Is_Plan_Upgradable__c ){
                if( renewalQLIs[0].Recommended_Plan_Tier__c != NULL ){
                    if( renewalQLIs[0].Recommended_Plan_Tier__c.containsIgnoreCase(';') ){
                        
                        
                    } else{
                        
                        system.debug('Inside Plan Recomended Tier Check');
                        PlanRecommendation upgradablePlan = new PlanRecommendation();
                        
                        upgradablePlan.productDetails.planTier 	= renewalQLIs[0].Recommended_Plan_Tier__c;
                        upgradablePlan.daysToUpgrade 			= renewalQLIs[0].No_of_days_to_Upgrade__c != NULL ? (Integer)renewalQLIs[0].No_of_days_to_Upgrade__c : 0;
                        recomendedresourceConstraintMap 		= getMetadataDetails(renewalQLIs[0].Recommended_Plan_Tier__c);
                        
                        if( renewalQLIs[0].Recommended_Plan_Parameters__c != NULL ){ 
                            
                            Map<String, Object> recommendedPriceAndPlanDetails	= (Map<String, Object>)JSON.deserializeUntyped(renewalQLIs[0].Recommended_Plan_Parameters__c);
                            system.debug('recommendedPriceAndPlanDetails: 			'+recommendedPriceAndPlanDetails);
                            system.debug('recommendedPriceAndPlanDetails.get: 		'+recommendedPriceAndPlanDetails.get('planTier'));
                            system.debug('renewalQLIs[0].Recommended_Plan_Tier__c: 	'+renewalQLIs[0].Recommended_Plan_Tier__c);
                            system.debug('recomendedresourceConstraintMap: 			'+recomendedresourceConstraintMap);
                            
                            if( 
                                recommendedPriceAndPlanDetails != NULL && 
                                recommendedPriceAndPlanDetails.containsKey('planTier') &&
                                recommendedPriceAndPlanDetails.get('planTier') == renewalQLIs[0].Recommended_Plan_Tier__c
                            ){      
                                system.debug('Inside Plantier recomendation check : '+recommendedPriceAndPlanDetails.get('planPrice'));
                                system.debug('Inside Plantier recomendation check : '+recommendedPriceAndPlanDetails.get('overusageCharge'));
                                
                                upgradablePlan.productDetails.name 											= (String)recommendedPriceAndPlanDetails.get('productName');
                                upgradablePlan.renewalDetails.renewalLicensePricingDetails.planPrice 		= (Decimal)recommendedPriceAndPlanDetails.get('planPrice');
                                upgradablePlan.renewalDetails.renewalLicensePricingDetails.overusageCharge 	= (Decimal)recommendedPriceAndPlanDetails.get('overusageCharge');
                                Decimal recomendedBasePrice 												= 
                                    (Decimal)recommendedPriceAndPlanDetails.get('planPrice') + 
                                    (Decimal)recommendedPriceAndPlanDetails.get('overusageCharge');
                                
                                if(renewalQLIs[0].Quote.Opportunity.If_SEZ__c == 'No'){
                                    if(renewalQLIs[0].Quote.Opportunity.State_2__c 		== 'Karnataka'){
                                        upgradablePlan.renewalDetails.renewalLicensePricingDetails.sgstTaxValue	=  (recomendedBasePrice * 9)/100;
                                        upgradablePlan.renewalDetails.renewalLicensePricingDetails.cgstTaxValue	=  (recomendedBasePrice * 9)/100;
                                        upgradablePlan.renewalDetails.renewalLicensePricingDetails.igstTaxValue	=  0;
                                        upgradablePlan.renewalDetails.renewalLicensePricingDetails.sgstTaxRate 	=  9;
                                        upgradablePlan.renewalDetails.renewalLicensePricingDetails.cgstTaxRate 	=  9;
                                        upgradablePlan.renewalDetails.renewalLicensePricingDetails.igstTaxRate 	=  0;
                                    }else{
                                        upgradablePlan.renewalDetails.renewalLicensePricingDetails.sgstTaxValue	=  0;
                                        upgradablePlan.renewalDetails.renewalLicensePricingDetails.cgstTaxValue	=  0;
                                        upgradablePlan.renewalDetails.renewalLicensePricingDetails.igstTaxValue	=  (recomendedBasePrice * 18)/100;
                                        upgradablePlan.renewalDetails.renewalLicensePricingDetails.sgstTaxRate	=  0;
                                        upgradablePlan.renewalDetails.renewalLicensePricingDetails.cgstTaxRate	=  0;
                                        upgradablePlan.renewalDetails.renewalLicensePricingDetails.igstTaxRate	=  18;
                                    }
                                    
                                }
                                
                                renewalQLIs[0].Total_Tax_Value_Recommended__c 	= 
                                    upgradablePlan.renewalDetails.renewalLicensePricingDetails.sgstTaxValue  + 
                                    upgradablePlan.renewalDetails.renewalLicensePricingDetails.cgstTaxValue  + 
                                    upgradablePlan.renewalDetails.renewalLicensePricingDetails.igstTaxValue;
                                
                                Decimal recomendedTDSPrice 						= 
                                    renewalQLIs[0].Is_TDS_Applicable__c && renewalQLIs[0].Applicable_TDS__c != NULL ? 
                                    ( (recomendedBasePrice  * renewalQLIs[0].Applicable_TDS__c)/100 ) : 0;
                                renewalQLIs[0].TDS_Price_Recommended__c 		= recomendedTDSPrice;
                                Decimal recomendedTotalPriceAfterTdsDeduction 	= (recomendedBasePrice - recomendedTDSPrice);
                                
                                upgradablePlan.renewalDetails.renewalLicensePricingDetails.totalOrderValue  	= 
                                    recomendedTotalPriceAfterTdsDeduction + 
                                    upgradablePlan.renewalDetails.renewalLicensePricingDetails.sgstTaxValue  + 
                                    upgradablePlan.renewalDetails.renewalLicensePricingDetails.cgstTaxValue  + 
                                    upgradablePlan.renewalDetails.renewalLicensePricingDetails.igstTaxValue ;
                                
                                renewalQLIs[0].Total_Renewal_Price_Recommended__c 								= 
                                    upgradablePlan.renewalDetails.renewalLicensePricingDetails.totalOrderValue; 
                                
                                
                                for( Auto_Renewal_Constraints__mdt mdtRec 	: recomendedresourceConstraintMap?.values() ){	/** Plan Recomendation - Renewal Parameters : START **/
                                    
                                    RenewalParameters renewParam 			= new RenewalParameters();
                                    renewParam.resource 					= mdtRec.Resource__c;
                                    renewParam.constraintType				= 'THRESHOLD';
                                    renewParam.displayName 					= mdtRec.Display_Text__c;
                                    renewParam.threshold			    	= 
                                        recommendedPriceAndPlanDetails.containsKey(mdtRec.Quote_Line_Item_Field__c) ? 
                                        ((Decimal)recommendedPriceAndPlanDetails.get(mdtRec.Quote_Line_Item_Field__c)).IntValue() : 0;
                                    
                                    upgradablePlan.renewalDetails.renewalParameters.add(renewParam);
                                }
                            }
                        }
                        
                        system.debug('upgradablePlan : '+upgradablePlan);
                        renewalWrap.planRecommendations.add(upgradablePlan);
                    }
                }  else{
                    renewalWrap.errorMessage = 'No Recomended Plans availablea and enabled for Plan Upgrade';
                }
            } 	
            /**	Recomendaded Plan Block : END	**/
            
            /**	Current Plan Calculations : START	**/
            if( 
                !renewalQLIs[0].Is_Price_Locked__c && 
                planTier?.containsIgnoreCase('EINVOICE')
            ){
                renewalQLIs[0] 			= calculateRenewalParameterAndPrice(licenseId, planTier, usageParams);
            }
            
            if( 
                !renewalQLIs[0].Quote.Opportunity.Is_Auto_Renewal_Enabled__c && 
                renewalQLIs[0].Renewal_Service_Payload__c != NULL 
            ){
                renewalWrap = (CTX_GetRenewalParameterAndPrice.RenewalWrapper)JSON.deserializeStrict(renewalQLIs[0].Renewal_Service_Payload__c, CTX_GetRenewalParameterAndPrice.RenewalWrapper.Class);
            } else{
                
                renewalWrap.licenseId												= renewalQLIs[0].Parent_Asset__r.License_ID__c;
                
                /*if( renewalQLIs[0].Sale_Price__c != renewalQLIs[0].Auto_Renewal_Sale_Price__c ){
                    if( qli?.Quote != NULL && !qli?.Quote.IsSyncing ){
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.planPrice	= 
                            renewalQLIs[0].Auto_Renewal_Sale_Price__c;
                            } else{
                                renewalWrap.renewalDetails.renewalLicensePricingDetails.planPrice	= renewalQLIs[0].Sale_Price__c;
                            }
                }*/
                renewalWrap.renewalDetails.renewalLicensePricingDetails.planPrice	= 
                    ( renewalQLIs[0].Sale_Price__c != renewalQLIs[0].Auto_Renewal_Sale_Price__c && 
                     !isSync ) 
                    ? renewalQLIs[0].Auto_Renewal_Sale_Price__c : renewalQLIs[0].Sale_Price__c;
                
                renewalWrap.ProductDetails.name 									= renewalQLIs[0].Product2.Name;
                renewalWrap.ProductDetails.planTier									= planTier != NULL ? planTier : renewalQLIs[0].Product2.Plan_Tier__c;
                renewalWrap.validity.startAt 										= renewalQLIs[0].Period_Start_date__c;
                renewalWrap.validity.endAt 											= renewalQLIs[0].Period_End_date__c;
                renewalWrap.contactInformation.name 								= renewalQLIs[0].Quote.Opportunity.E_Sign_Customer_Info__r.Name;
                renewalWrap.contactInformation.email 								= renewalQLIs[0].Quote.Opportunity.E_Sign_Customer_Info__r.Email;
                renewalWrap.contactInformation.phoneNumber  						= renewalQLIs[0].Quote.Opportunity.E_Sign_Customer_Info__r.Phone;
                renewalWrap.billingAddress.billingGSTIN     						= renewalQLIs[0].Quote.Opportunity.Billing_GST__c;
                renewalWrap.billingAddress.legalEntityName  						= renewalQLIs[0].Quote.Opportunity.Legal_Entity_Name_Of_The_Client__c;
                renewalWrap.billingAddress.billingAddress							= renewalQLIs[0].Quote.Opportunity.Billing_Address__c;
                renewalWrap.billingAddress.shippingAddress							= renewalQLIs[0].Quote.Opportunity.Shipping_Address__c;
                renewalWrap.billingAddress.state									= renewalQLIs[0].Quote.Opportunity.State_2__c;
                renewalWrap.billingAddress.pincode									= renewalQLIs[0].Quote.Opportunity.Pincode__c;
                renewalQLIs[0].Over_Usage_Charge__c 								= renewalQLIs[0].Over_Usage_Charge__c != NULL ? renewalQLIs[0].Over_Usage_Charge__c : 0;
                
                for(Auto_Renewal_Constraints__mdt mdtRec 	: resourceConstraintMap.values()){
                    
                    RenewalParameters renewParam 			= new RenewalParameters();
                    renewParam.resource 					= mdtRec.Resource__c;
                    renewParam.constraintType				= 'THRESHOLD';
                    renewParam.displayName 					= mdtRec.Display_Text__c;
                    system.debug('mdtRec.Quote_Line_Item_Field__c: '+mdtRec.Quote_Line_Item_Field__c);
                    renewParam.threshold			    	= ((Decimal)renewalQLIs[0].get(mdtRec.Quote_Line_Item_Field__c)).IntValue();
                    
                    renewalWrap.renewalDetails.renewalParameters.add(renewParam);
                }	/** Renewal Parameters : END **/
                
                /** Overusage **/
                renewalWrap.renewalDetails.renewalLicensePricingDetails.overusageCharge	= renewalQLIs[0].Over_Usage_Charge__c;
                
                Decimal tdsPrice = 0;
                Decimal basePrice  = ( renewalQLIs[0].Over_Usage_Charge__c + renewalWrap.renewalDetails.renewalLicensePricingDetails.planPrice );
                tdsPrice = renewalQLIs[0].Is_TDS_Applicable__c && renewalQLIs[0].Applicable_TDS__c 	!= NULL ? ( (basePrice  * renewalQLIs[0].Applicable_TDS__c)/100 ) : 0;
                renewalQLIs[0].TDS_Price__c = tdsPrice;
                
                Decimal totalPriceAfterTdsDeduction = (basePrice - tdsPrice);
                
                if(renewalQLIs[0].Quote.Opportunity.If_SEZ__c == 'No'){
                    if(renewalQLIs[0].Quote.Opportunity.State_2__c 		== 'Karnataka'){
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.sgstTaxValue  			=  (basePrice * 9)/100;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.cgstTaxValue  			=  (basePrice * 9)/100;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.igstTaxValue  			=  0;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.sgstTaxRate 	=  9;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.cgstTaxRate 	=  9;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.igstTaxRate 	=  0;
                    }else{
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.sgstTaxValue 			=  0;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.cgstTaxValue 			=  0;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.igstTaxValue 			=  (basePrice * 18)/100;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.sgstTaxRate	=  0;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.cgstTaxRate	=  0;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.igstTaxRate	=  18;
                    }
                }
                
                renewalQLIs[0].Total_Tax_Value__c = renewalWrap.renewalDetails.renewalLicensePricingDetails.sgstTaxValue  + 
                    renewalWrap.renewalDetails.renewalLicensePricingDetails.cgstTaxValue  + 
                    renewalWrap.renewalDetails.renewalLicensePricingDetails.igstTaxValue;
                /** Total Payable Price **/
                renewalWrap.renewalDetails.renewalLicensePricingDetails.totalOrderValue  	= 
                    totalPriceAfterTdsDeduction + 
                    renewalWrap.renewalDetails.renewalLicensePricingDetails.sgstTaxValue  + 
                    renewalWrap.renewalDetails.renewalLicensePricingDetails.cgstTaxValue  + 
                    renewalWrap.renewalDetails.renewalLicensePricingDetails.igstTaxValue ;
                
                /** TDS Applicable **/
                renewalWrap.tdsDetails.isTDSApplicable		= renewalQLIs[0].Is_TDS_Applicable__c;
                renewalWrap.tdsDetails.applicableTDS 		= renewalQLIs[0].Applicable_TDS__c;
                renewalWrap.tdsDetails.customerTAN 			= renewalQLIs[0].TAN_Number__c;
                
                try{
                    if( renewalQLIs[0].Quote.Opportunity.Account.TDS__c != NULL && renewalQLIs[0].Quote.Opportunity.Account.TDS_Percent_Applicable__c != NULL ){
                        renewalWrap.tdsDetails.isTDSChangeLocked = TRUE;
                    } else{
                        renewalWrap.tdsDetails.isTDSChangeLocked = FALSE;
                    }
                } catch(Exception ex){
                    system.debug('exception on TDS & Tax Applicable: '+ex.getMessage());
                }
                
                
                renewalWrap.bankDetail.accountName			= renewalQLIs[0].Quote.Opportunity.Account.Bank_Account_Name__c;
                renewalWrap.bankDetail.accountNumber		= renewalQLIs[0].Quote.Opportunity.Account.Account_Number__c;
                renewalWrap.bankDetail.bankName				= renewalQLIs[0].Quote.Opportunity.Account.Bank_Name__c;
                renewalWrap.bankDetail.ifscCode				= renewalQLIs[0].Quote.Opportunity.Account.Bank_IFSC_Code__c;
                renewalWrap.bankDetail.branch				= renewalQLIs[0].Quote.Opportunity.Account.Bank_Branch__c;
                renewalWrap.bankDetail.swiftCode			= renewalQLIs[0].Quote.Opportunity.Account.Bank_Swift_Code__c != NULL ? renewalQLIs[0].Quote.Opportunity.Account.Bank_Swift_Code__c : '100';
                
                
                
                System.debug('@renewalDetails'+JSON.serialize(renewalWrap));
                
            }
            
            
            renewalQLIs[0].Renewal_Service_Payload__c = JSON.serialize(renewalWrap);
            renewalQLIs[0].Is_Price_Locked__c = TRUE;
            renewalQLIs[0].Total_Renewal_Price__c = renewalWrap.renewalDetails.renewalLicensePricingDetails.totalOrderValue;
            
            
            
            
            /**	DML Section : START	**/
            OpportunityConstants.AUTO_RENEW_RULE = FALSE;
            QuoteConstants.ISFIRSTTIMEQLI = FALSE;
            Update renewalQLIs[0];
            QuoteConstants.ISFIRSTTIMEQLI = TRUE;
            
            syncOppLineItem( new Set<Id> {renewalQLIs[0].Id} );
            /**	DML Section : END	**/
            
        } else{
            renewalWrap.errorMessage = 'No matching license found.';
        }
        
        return renewalWrap; 
    }
    
    global static QuoteLineItem calculateRenewalParameterAndPrice( String licenseId, String planTier, Map<String, Integer> usageParams ){
        
        System.debug('@planTier'+planTier);
        Map<String, Auto_Renewal_Constraints__mdt> 		resourceConstraintMap 	= getMetadataDetails(planTier);
        AutoRenewal_Plan_Tier_Configs_Metadata__mdt 	configsMDT 				= [SELECT Id, Plan_Tier__c, Over_Usage_Formula__c FROM AutoRenewal_Plan_Tier_Configs_Metadata__mdt WHERE Plan_Tier__c =: planTier];
        List<String> fieldsToQuery = new List<String>(resourceConstraintMap.keySet());
        
        String assetQueryString;
        if(resourceConstraintMap.values().size() > 0 ){
            if( planTier != NULL && planTier.containsIgnoreCase('EINVOICE') ){
                assetQueryString  = 'SELECT Id, Name, Price, PurchaseDate, UsageEndDate, Status, License_Id__c, ' + String.join(fieldsToQuery,',') + ' FROM Asset WHERE License_Id__c =: licenseId' ;
            } else if( planTier != NULL && !planTier.containsIgnoreCase('EINVOICE') ){
                assetQueryString  = 'SELECT Id, Name, Price, PurchaseDate, UsageEndDate, Status, License_Id__c, License_no_of_irns_per_year__c, Number_of_eway_bill__c, ' + String.join(fieldsToQuery,',') + ' FROM Asset WHERE License_Id__c =: licenseId' ;
            }
        } else{
            assetQueryString  = 'SELECT Id, Name, Price, PurchaseDate, UsageEndDate, Status, License_Id__c, License_no_of_irns_per_year__c, Number_of_eway_bill__c FROM Asset WHERE License_Id__c =: licenseId' ;
        }
        
        
        system.debug('assetQueryString: '+assetQueryString);
        List<Asset> assetsToRenew = database.query(assetQueryString);
        system.debug('assetToRenew: '+assetsToRenew.size());
        QuoteLineItem renewalQLI;
        
        if( assetsToRenew.size() > 0 ){
            
            /** Extrapolation Logic Start **/
            Asset assetToRenew = assetsToRenew[0];
            Decimal daysSinceLicenseStart 	= assetToRenew.PurchaseDate.daysBetween(System.today()); 
            Decimal ExtrapolatedIRNUsage 	= usageParams.get('IRN_GENERATION') != NULL ? ((Decimal)usageParams.get('IRN_GENERATION')/daysSinceLicenseStart) * 364 : 0;
            Decimal ExtrapolatedEWBUsage 	= usageParams.get('EWB_GENERATION') != NULL ? ((Decimal)usageParams.get('EWB_GENERATION')/daysSinceLicenseStart) * 364 : 0;
            
            usageParams.put('IRN_GENERATION', ExtrapolatedIRNUsage.round().intValue());
            usageParams.put('EWB_GENERATION', ExtrapolatedEWBUsage.round().intValue());
            /** Extrapolation Logic End **/
            
            System.debug('##UsageParams: '+ usageParams);
            Decimal usageTotalInvoice 	= usageParams.get('IRN_GENERATION') + usageParams.get('EWB_GENERATION');
            assetToRenew.License_no_of_irns_per_year__c = assetToRenew.License_no_of_irns_per_year__c != NULL ? assetToRenew.License_no_of_irns_per_year__c : 0;
            assetToRenew.Number_of_eway_bill__c = assetToRenew.Number_of_eway_bill__c != NULL ? assetToRenew.Number_of_eway_bill__c : 0;
            Decimal actualTotalInvoice 	= assetToRenew?.License_no_of_irns_per_year__c + assetToRenew?.Number_of_eway_bill__c;
            Id assetId = assetToRenew.Id;
            
            List<QuoteLineItem> renewalQLIs = Database.query('SELECT Id, EC__c, Auto_Renewal_Sale_Price__c,Purchases_Invoices_one__c, No_of_GSTIN_verification_credits__c, PR_B2B_0_2_B2C__c, Is_TDS_Applicable__c,Quote.Opportunity.If_SEZ__c,Renewal_Service_Payload__c ,Quote.Opportunity.Is_Auto_Renewal_Enabled__c,Quote.Opportunity.Account.Channel_Partner_Account__c, Quote.Opportunity.Account.Channel_Partner_Account__r.Name,Quote.Opportunity.Account.Name,Quote.Opportunity.Account.Bank_Account_Name__c, Quote.Opportunity.Account.Account_Number__c, Quote.Opportunity.Account.Bank_Branch__c, Quote.Opportunity.Account.Bank_IFSC_Code__c , Quote.Opportunity.Account.Bank_Name__c,Quote.Opportunity.Account.Bank_Swift_Code__c ,Product2Id,Product2.Name,Applicable_TDS__c,TAN_Number__c,Product_Formula__c,UnitPrice,Sale_Price__c,Is_Formula_Price_Applicable__c,Is_Price_Locked__c,Quote.Opportunity.Billing_Address__c,Quote.Opportunity.Shipping_Address__c, Quote.Opportunity.State_2__c,Quote.Opportunity.Pincode__c,Quote.Opportunity.Legal_Entity_Name_Of_The_Client__c,Quote.Opportunity.Billing_GST__c,Parent_Asset__r.License_ID__c,Quote.Opportunity.E_Sign_Customer_Info__r.Name,Quote.Opportunity.E_Sign_Customer_Info__r.Email, Quote.Opportunity.E_Sign_Customer_Info__r.Phone,' + 'No_of_PAN_one__c,No_of_GSTIN_one__c,No_of_User_ID_one__c,No_of_IRNs__c,Number_of_eway_bill__c,No_of_expected_B2C_invoices_for_QR_code__c,Usage_Log__c' + ' FROM QuoteLineItem WHERE Parent_Asset__c =: assetId');
            
            if( planTier?.containsIgnoreCase('GST') || planTier?.containsIgnoreCase('MAX') || planTier?.containsIgnoreCase('TDS')  ){
                
                renewalQLI 						= renewalQLIs[0];
                renewalQLI.Id					= renewalQLIs[0].Id;
                renewalQLI.UnitPrice 			= renewalQLIs[0].UnitPrice;
                renewalQLI.Sale_Price__c 		= renewalQLIs[0].Sale_Price__c;
                renewalQLI.Over_Usage_Charge__c = 0;
                renewalQLI.Over_Usage_Charge__c	= 0;
                if(assetToRenew.UsageEndDate >= System.today()){
                    renewalQLI.Period_Start_date__c = assetToRenew.UsageEndDate.addDays(1);
                    renewalQLI.Period_End_date__c	= assetToRenew.UsageEndDate.addYears(1);
                } else {
                    renewalQLI.Period_Start_date__c = assetToRenew.UsageEndDate.addDays(1);
                    renewalQLI.Period_End_date__c	= assetToRenew.UsageEndDate.addYears(1);
                }
                renewalQLI.Is_Formula_Price_Applicable__c = FALSE;
                renewalQLI.Usage_Parameters__c = JSON.serialize(usageParams);
                
            } 
            else{
                
                if(renewalQLIs.size() > 0){
                    Decimal quotePrice 				= 0;
                    Decimal cappedQuotePrice 		= 0;
                    Decimal finalPrice 				= 0;
                    Decimal fairPrice 				= 0;
                    Decimal overUsageCharges 		= 0;
                    Decimal previousSellingPrice	= assetToRenew.Price; 
                    renewalQLI 						= renewalQLIs[0].clone(false, false, false, false);
                    String 	overUsageFormula		= configsMDT.Over_Usage_Formula__c;
                    
                    System.debug('##overUsageFormula: '+overUsageFormula);
                    
                    renewalQLI.Id = renewalQLIs[0].Id;
                    if( usageTotalInvoice <= (1.1 * actualTotalInvoice) && !planTier?.containsIgnoreCase('GST') ){
                        overUsageCharges = 0;
                    } else {
                        for(Auto_Renewal_Constraints__mdt mdtRec : resourceConstraintMap.values()){
                            
                            Decimal overuse = Math.max(((Decimal)usageParams.get(mdtRec.Resource__c) - (Decimal)assetToRenew.get(mdtRec.Asset_Field__c)), 0);
                            if( mdtRec.Quote_Line_Item_Field__c != 'PR_B2B_0_2_B2C__c' ){
                                renewalQLI.put(mdtRec.Quote_Line_Item_Field__c, overuse);
                            }
                            
                        }
                        
                        if( overUsageFormula != NULL ){
                            overUsageCharges = CTX_CustomStringToFormulaParser.customFormulaPriceCalculator(renewalQLI, overUsageFormula);
                            overUsageCharges = overUsageCharges.round();
                        }
                        
                    }
                    
                    for(Auto_Renewal_Constraints__mdt mdtRec : resourceConstraintMap.values()){
                        renewalQLI.put(mdtRec.Quote_Line_Item_Field__c, usageParams.get(mdtRec.Resource__c));
                    }
                    system.debug('##QLI: ' + renewalQLI);
                    
                    Decimal usagePrice 	= CTX_CustomStringToFormulaParser.customFormulaPriceCalculator(renewalQLI, renewalQLI.Product_Formula__c);
                    system.debug('##overUsageCharges: ' + overUsageCharges);
                    system.debug('##usagePrice: ' + usagePrice);
                    
                    system.debug('actualTotalInvoice: '+actualTotalInvoice);
                    system.debug('usageTotalInvoice: '+usageTotalInvoice);
                    system.debug('previousSellingPrice: '+previousSellingPrice);
                    system.debug('quotePrice: '+quotePrice);
                    
                    
                    if(usageTotalInvoice < actualTotalInvoice){
                        quotePrice = Math.max(50000, 1.3 * previousSellingPrice);
                    } else {
                        
                        quotePrice = previousSellingPrice < usagePrice ? Math.max((1.3*previousSellingPrice), usagePrice) : (1.3 * previousSellingPrice);
                            }
                    
                    system.debug('##quotePrice: ' + quotePrice);
                    
                    cappedQuotePrice 	= quotePrice > (2.5 * previousSellingPrice) ? (2.5 * previousSellingPrice) : quotePrice;
                    system.debug('##cappedQuotePrice: ' + cappedQuotePrice);
                    
                    finalPrice 			= previousSellingPrice > usagePrice ? (1.2 * previousSellingPrice) : Math.max((1.2 * previousSellingPrice), Math.min(cappedQuotePrice, usagePrice));
                    system.debug('##finalPrice1: ' + finalPrice);
                    
                    System.debug('@usageTotalInvoice'+usageTotalInvoice);
                    
                    if( system.label.Auto_Renewal_Latest_Pricing_Logic_Enable == 'YES' ){
                        /**	OND Pricing Calculator logic change : START	**/
                        if(previousSellingPrice > usagePrice){
                            Decimal usagePercentage = (usageTotalInvoice/actualTotalInvoice) * 100;
                            if( usagePercentage <= 30 )
                                fairPrice = (1.1 * previousSellingPrice);
                            else if( usagePercentage <= 60 &&  usagePercentage > 30 )
                                fairPrice = (1.15 * previousSellingPrice);
                            else
                                fairPrice = (1.2 * previousSellingPrice);
                        } else{
                            fairPrice = Math.min( (4 * previousSellingPrice),  Math.max(usagePrice, 1.2 * previousSellingPrice) );
                        }
                        /**	OND Pricing Calculator logic change : START	**/
                    }
                    
                    
                    If(usageTotalInvoice <= 10000 && 
                       (renewalQLI.Quote.Opportunity.Account.Channel_Partner_Account__c == NULL ||
                        (renewalQLI.Quote.Opportunity.Account.Channel_Partner_Account__c != NULL &&
                         !renewalQLI.Quote.Opportunity.Account.Channel_Partner_Account__r.Name.containsIgnoreCase('uneecop'))))
                    {
                        System.debug('@previousSellingPrice'+previousSellingPrice);
                        if(previousSellingPrice < 35000){
                            fairPrice = 35000;
                        }else if(previousSellingPrice >= 50000){
                            fairPrice = finalPrice;
                        }else{
                            fairPrice = (1.15 * previousSellingPrice);
                        }
                        
                    }else{
                        fairPrice = finalPrice;
                    }
                    
                    
                    Decimal fairPriceFraction 	= ((Decimal)fairPrice).round() / 1000;
                    fairPrice					= fairPriceFraction.setScale(1) * 1000;
                    
                    system.debug('##fairPrice: ' + fairPrice);
                    system.debug('usageParams: '+usageParams);
                    system.debug('assetToRenew: '+assetToRenew);
                    for(Auto_Renewal_Constraints__mdt mdtRec : resourceConstraintMap.values()){
                        system.debug('mdtRec: '+mdtRec);
                        system.debug('mdtRec.Quote_Line_Item_Field__c: '+mdtRec.Quote_Line_Item_Field__c);
                        system.debug('mdtRec.Resource__c: '+mdtRec.Resource__c);
                        system.debug('mdtRec.Asset_Field__c: '+mdtRec.Asset_Field__c);
                        
                        renewalQLI.put(
                            mdtRec.Quote_Line_Item_Field__c, 
                            Math.max(
                                usageParams.get(mdtRec.Resource__c) != NULL ? (Decimal)usageParams.get(mdtRec.Resource__c) : 0, 
                                assetToRenew.get(mdtRec.Asset_Field__c) != NULL ? (Decimal)assetToRenew.get(mdtRec.Asset_Field__c) : 0
                            )
                        );
                        
                    }
                    
                    renewalQLI.UnitPrice 			= fairPrice;
                    renewalQLI.Sale_Price__c 		= fairPrice;
                    renewalQLI.Over_Usage_Charge__c = 0;
                    renewalQLI.Over_Usage_Charge__c	= overUsageCharges;
                    if(assetToRenew.UsageEndDate >= System.today()){
                        renewalQLI.Period_Start_date__c = assetToRenew.UsageEndDate.addDays(1);
                        renewalQLI.Period_End_date__c	= assetToRenew.UsageEndDate.addYears(1);
                    } else {
                        renewalQLI.Period_Start_date__c = assetToRenew.UsageEndDate.addDays(1);
                        renewalQLI.Period_End_date__c	= assetToRenew.UsageEndDate.addYears(1);
                    }
                    renewalQLI.Is_Formula_Price_Applicable__c = FALSE;
                    renewalQLI.Usage_Parameters__c = JSON.serialize(usageParams);
                    
                }
                
                System.debug('@renewalQLI'+renewalQLI);
                
            }
            
        } else{
            
        }
        
        return renewalQLI;
        
    }
    
    /** Sync Opportunity line item on Quote Sync **/
    @future
    Public static void syncOppLineItem(set<Id> setOfQuoteLineItem){
        
        List<QuoteLineItem> listOfNewQuoteLineItem = new List<QuoteLineItem>();
        listOfNewQuoteLineItem = [SELECT Id, OpportunityLineItemId, MarkUp__c, Sale_Price__c, Discount,Period_End_date__c,
                                  Period_Start_date__c,Product_Code__c, Type_Of_Integration__c, Stage_in_MY__c, SOW_Start_Date__c, SOW_End_Date__c
                                  FROM QuoteLineItem WHERE Id IN: setOfQuoteLineItem];
        list<opportunityLineItem> listOfOppLineItemToUpdate = new list<opportunityLineItem>();
        for(QuoteLineItem tempQuoteLineItem : listOfNewQuoteLineItem){
            
            listOfOppLineItemToUpdate.add(
                new opportunityLineItem(
                    
                    Id 						= tempQuoteLineItem.OpportunityLineItemId,	
                    Sale_Price__c 			= tempQuoteLineItem.Sale_Price__c, 
                    MarkUp__c 				= tempQuoteLineItem.MarkUp__c, 
                    Discount 				= tempQuoteLineItem.Discount , 
                    Period_End_date__c 		= tempQuoteLineItem.Period_End_date__c,
                    Period_Start_date__c 	= tempQuoteLineItem.Period_Start_date__c,
                    Product_Code__c 		= tempQuoteLineItem.Product_Code__c , 
                    Type_of_Integration__c 	= tempQuoteLineItem.Type_Of_Integration__c, 
                    Stage_in_MY__c 			= tempQuoteLineItem.Stage_in_MY__c, 
                    SOW_Start_Date__c 		= tempQuoteLineItem.SOW_Start_Date__c, 
                    SOW_End_Date__c 		= tempQuoteLineItem.SOW_End_Date__c,
                    Related_QLI__c 			= tempQuoteLineItem.Id
                ));
            
        }
        
        if(listOfOppLineItemToUpdate.size()>0){
            RecursiveTriggerHandler.isFirstTimeOpportunity = FALSE;
            update listOfOppLineItemToUpdate;
            RecursiveTriggerHandler.isFirstTimeOpportunity = TRUE;
        }
    }
    
    public static Map<String, Auto_Renewal_Constraints__mdt> getMetadataDetails(String planTier){
        
        Map<String, Auto_Renewal_Constraints__mdt> resourceConstraintMap = new Map<String, Auto_Renewal_Constraints__mdt>();
        for( Auto_Renewal_Constraints__mdt thisRec : Auto_Renewal_Constraints__mdt.getAll().values() ){
            
            if(thisRec.Plan_Tier__c == planTier){
                resourceConstraintMap.put(thisRec.Asset_Field__c, thisRec);
            }
        }
        
        return resourceConstraintMap;
    } 
    
    Public Class ProductDetails{
        Public String name;
        Public String planTier;
    }
    
    Public Class RenewalPrice{
        Public Decimal price;
    }
    
    Public Class RenewalParameters{
        Public String 	constraintType;
        Public String 	resource;
        Public Integer  threshold = 0;
        Public String 	displayName;
    }
    
    Public Class Validity{
        Public DateTime startAt;
        Public DateTime endAt;
    }
    
    Public Class ContactInformation{
        Public String name = ' ';
        Public String email= ' ';
        Public String phoneNumber= ' ';
    } 
    
    Public Class BillingDetails{
        Public String billingGSTIN;
        Public String legalEntityName;
        Public String billingAddress;
        Public String shippingAddress;
        Public String state;
        Public String pincode;
    }
    
    Public Class TDSDetails{
        Public Boolean isTDSApplicable;
        Public Boolean isTDSChangeLocked;
        Public String  customerTAN;
        Public Decimal applicableTDS;
    }
    
    public class BankDetail {
        public string 		accountName;
        public string 		accountNumber;
        public string 		bankName;
        public string 		ifscCode;
        public string 		branch;
        public string 		swiftCode;
    }
    
    Public Class RenewalLicensePricingDetails{
        Public Decimal 			 		planPrice  			= 0;
        Public Decimal 			  		overusageCharge  	= 0;
        Public Decimal 			  		sgstTaxRate  		= 0;
        Public Decimal 			  		cgstTaxRate  		= 0;
        Public Decimal 			  		igstTaxRate  		= 0;
        Public Decimal 			  		sgstTaxValue  		= 0;
        Public Decimal 			  		cgstTaxValue  		= 0;
        Public Decimal 			  		igstTaxValue  		= 0;
        public Decimal					totalOrderValue  	= 0;
    } 
    
    Public Class RenewalDetails{ 
        public List<RenewalParameters> 	renewalParameters 	= new List<RenewalParameters>();
        public RenewalLicensePricingDetails renewalLicensePricingDetails  = new RenewalLicensePricingDetails();
    }
    
    Public Class RecommendadedProductDetails{
        public string name;
        public string planTier;
    }
    
    Public Class PlanRecommendation{
        public Integer 						daysToUpgrade;
        public RenewalDetails 				renewalDetails = new RenewalDetails();
        public RecommendadedProductDetails 	productDetails = new RecommendadedProductDetails();
    }
    
    Global Class RenewalWrapper{
        ProductDetails 													productDetails 		= new ProductDetails();
        Validity 														validity 			= new Validity();
        ContactInformation												contactInformation	= new ContactInformation();
        BillingDetails													billingAddress 		= new BillingDetails();
        RenewalDetails													renewalDetails		= new RenewalDetails(); 
        TdsDetails														tdsDetails			= new TdsDetails();
        BankDetail 														bankDetail			= new BankDetail();
        List<PlanRecommendation>										planRecommendations	= new List<PlanRecommendation>();
        Public	string 	errorMessage;
        Public  string	licenseId;
        
    }
    
    
}