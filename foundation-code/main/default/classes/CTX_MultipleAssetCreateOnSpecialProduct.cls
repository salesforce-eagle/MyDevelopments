/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-17-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_MultipleAssetCreateOnSpecialProduct {
    
    public static Asset createAssetOnOpportunityClosure( 
        OpportunityLineItem		oli, 
        Map<Id, Opportunity> 	mapOfOpportunity, 
        Map<Id, Asset> 			mapOfAssets, 
        Map<Id,Quote> 			mapOfSyncedQuotes, 
        Map<String,OrderItem> 	ordItemMap, 
        String 					Asset_Lincence_Asset_RecordTypeId, 
        String 					opportunity_Renewal_RecordTypeId, 
        String 					Asset_OneTime_Asset_RecordTypeId,
        String 					Asset_Integration_Asset_RecordTypeId, 
        String 					productId, 
        Decimal					price,
        Map<Id, Product2>		specialProductSplitProductDetailsMap,
        Map<String, Integer>	resourceConstraintsWithValuesMap
    ){
        
        
        system.debug('New Asset Condition Entered - Post Opportunity Closure Block');
        Asset newAsset 											= new Asset();
        
        if( specialProductSplitProductDetailsMap != NULL ){
            newAsset.Name 										= oli.Period_End_date__c != NULL ? 
                specialProductSplitProductDetailsMap.get(productId)?.Name + 
                ' '+oli.PO_End_Month__c + ' '+oli.Period_End_date__c.year() :
            specialProductSplitProductDetailsMap.get(productId)?.Name + ' '+oli.PO_End_Month__c;   
        } else{
            newAsset.Name 										= oli.Period_End_date__c != NULL ? 
                oli.PricebookEntry.Product2.Name + ' '+oli.PO_End_Month__c + ' '+oli.Period_End_date__c.year() :
            oli.PricebookEntry.Product2.Name + ' '+oli.PO_End_Month__c;
        }
        
        newAsset.CurrencyIsoCode 								= oli.CurrencyIsoCode;
        newAsset.AccountId 										= oli.Opportunity.AccountId;
        newAsset.Product2Id 									= productId;//oli.PricebookEntry.Product2Id;
        newAsset.Quantity 										= oli.Quantity;
        newAsset.Price 											= price;
        newAsset.PurchaseDate 									= oli.Period_Start_date__c ;
        newAsset.UsageEndDate  									= oli.Period_End_date__c;
        newAsset.Related_QLI_Id__c 								= oli.Related_QLI__c;
        newAsset.platform__c  									= oli.Related_QLI__r?.platform__c;
        newAsset.Status 										= 'Inactive';
        newAsset.Payment_term__c 								= oli.Opportunity.Payment_term__c;
        newAsset.Payment_method__c								= oli.Opportunity.Payment_method__c;
        newAsset.Description 									= oli.Description;
        newAsset.OwnerId 										= oli.Opportunity.Account.OwnerId;
        
        /**	Syncing Fields	**/
        newAsset.Transaction_Ref_No_To_be_moved_to_Opp__c       = oli.Related_QLI__r?.Transaction_Ref_No_To_be_moved_to_Opp__c; 
        newAsset.License_B2B_SalesInvoice_per_year__c 			= oli.Related_QLI__r?.BtoB_Sales_one__c ;
        newAsset.Opportunity__c									= oli.OpportunityId;                    
        newAsset.BackEndQuote__c 								= oli.Opportunity.SyncedQuoteId;
        newAsset.Number_of_TANs__c 								= oli.Related_QLI__r?.No_of_TANs__c;
        newAsset.Number_of_Deductees_per_Quarter_24Q_26__c 		= oli.Related_QLI__r?.Number_of_Deductees_per_Quarter_24Q_26__c;
        newAsset.Number_of_Deduction_Transactions_per_Qua__c 	= oli.Related_QLI__r?.Number_of_Deduction_Transactions_per_Qua__c;
        newAsset.Digital_Signing_Utility_for_TDS_Certific__c	= oli.Related_QLI__r?.Digital_Signing_Utility_for_TDS_Cert_del__c;
        newAsset.License_B2C_SalesInvoice_per_year__c 			= oli.Related_QLI__r?.BtoC_Sales_one__c;
        newAsset.Category_of_Company__c  						= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Category_of_Company__c;
        newAsset.ERP__c 										= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).ERP__c;
        newAsset.Existing_Vendor__c 							= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Existing_Vendor__c;
        newAsset.License_no_of_gstins__c 						= oli.Related_QLI__r?.No_of_GSTIN_one__c; 
        newAsset.License_no_of_pans__c 							= oli.Related_QLI__r?.No_of_PAN_one__c;
        newAsset.License_no_of_userids__c 						= oli.Related_QLI__r?.No_of_User_ID_one__c;
        newAsset.No_of_Vendor__c 								= oli.Related_QLI__r?.No_of_Vendors_one__c;
        newAsset.No_of_airline_invoices_annual__c 				= oli.Related_QLI__r?.No_of_airline_invoices_annual_one__c;
        newAsset.No_of_airline_invoices__c 						= oli.Related_QLI__r?.No_of_airline_invoices_annual_one__c;//Move to QLI
        newAsset.Turnover_one__c 								= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Turnover_one__c;
        newAsset.Type_of_Integration__c 						= oli.Related_QLI__r?.Type_of_Integration__c;
        newAsset.Zone__c 										= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Zone__c;
        newAsset.Number_of_eway_bill__c 						= oli.Related_QLI__r?.Number_of_eway_bill__c;
        newAsset.Number_of_Purchase_Invoice__c 					= oli.Related_QLI__r?.Purchases_Invoices_one__c;
        newAsset.lead_source__c 								= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).opportunity.LeadSource;
        newAsset.Anchor_Companys__c 							= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).opportunity.Anchor_Companys__c;
        newAsset.One_to_Many_Type__c 							= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).opportunity.One_to_Many_Type__c;
        newAsset.Number_of_eway_bill__c 						= oli.Related_QLI__r?.No_of_EWBs__c;
        newAsset.License_no_of_invoice_formats__c 				= oli.Related_QLI__r?.No_of_invoice_formats__c;
        newAsset.License_no_of_gstin_verification_credits__c 	= oli.Related_QLI__r?.No_of_GSTIN_verification_credits__c;
        newAsset.License_no_of_irns_per_year__c 				= oli.Related_QLI__r?.No_of_IRNs__c;
        newAsset.License_No_of_MM2A_2B_usage_GSTIN_mon__c 		= oli.Related_QLI__r?.No_MM2A_2B_usage_GSTIN_month__c;
        newAsset.License_no_of_Recon__c 						= oli.Related_QLI__r?.No_of_recons__c;
        newAsset.No_of_expected_B2C_invoices_for_QR_code__c 	= oli.Related_QLI__r?.No_of_expected_B2C_invoices_for_QR_code__c;
        newAsset.Partner_Count_for_GeEr_up_Reports__c 			= oli.Related_QLI__r?.Partner_Count_for_GeEr_up_Reports__c;
        newAsset.Monthly_throughput_Slab_1_Cr__c 				= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Monthly_throughput_Slab_1_Cr__c;
        newAsset.Monthly_throughput_Slab_2_Cr__c  				= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Monthly_throughput_Slab_2_Cr__c;
        newAsset.Monthly_throughput_Slab_3_Cr__c  				= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Monthly_throughput_Slab_3_Cr__c;
        newAsset.Transaction_Fee_Slab_1__c 						= oli.Related_QLI__r?.Transaction_Fee_Slab_1__c;
        newAsset.Transaction_Fee_Slab_2__c  					= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Transaction_Fee_Slab_2__c;
        newAsset.Transaction_Fee_Slab_3__c  					= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Transaction_Fee_Slab_3__c;
        newAsset.Flat_Transaction_Fee__c  						= oli.Related_QLI__r?.Flat_Transaction_Fee__c;
        newAsset.Tally_Connector_required__c   					= oli.Related_QLI__r?.Tally_Connector_required__c;
        newAsset.Total_annual_domestic_payables_Rs_Cr__c    	= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Total_annual_domestic_payables_Rs_Cr__c ;
        newAsset.No_of_retail_stores__c 						= oli.Related_QLI__r?.No_of_retail_stores__c!=NULL ? oli.Related_QLI__r?.No_of_retail_stores__c : NULL;
        newAsset.POS_system__c  								= oli.Related_QLI__r?.POS_system__c ;
        newAsset.No_of_Bank_verification_API__c 				= oli.Related_QLI__r?.No_of_Bank_verification_API__c;
        newAsset.No_of_API_calls_permissible__c 				= oli.Related_QLI__r?.No_of_API_calls_permissible__c;
        newAsset.No_of_MCA_Company_details_API__c 				= oli.Related_QLI__r?.No_of_MCA_Company_details_API__c;
        newAsset.No_of_MSME_API__c 								= oli.Related_QLI__r?.No_of_MSME_API__c;
        newAsset.No_of_PAN_verification_API__c 					= oli.Related_QLI__r?.No_of_PAN_verification_API__c;
        newAsset.No_of_TDS_206_sync_API__c 						= oli.Related_QLI__r?.No_of_TDS_206_sync_API__c;
        newAsset.Type_of_Integration_QLI__c 					= oli.Type_of_Integration__c;
        newAsset.SOW_Start_Date__c  							= oli.SOW_Start_Date__c;
        newAsset.SOW_End_Date__c  								= oli.SOW_End_Date__c;
        newAsset.OTP_SKUs__c                                    = oli.Related_QLI__r?.OTP_SKUs__c;
        newAsset.No_of_B2B_Invoices_per_GSTIN__c				= oli.Related_QLI__r?.No_of_B2B_Invoices_per_GSTIN__c;
        /**	Clear Identity Field Flow : START	**/
        newAsset.No_Of_GST_ADVANCED_APIs__c						= oli.Related_QLI__r?.No_Of_GST_ADVANCED_APIs__c;
        newAsset.No_Of_GST_ADVANCED_PLUS_APIs__c				= oli.Related_QLI__r?.No_Of_GST_ADVANCED_PLUS_APIs__c;
        newAsset.No_Of_PAN_OCR_APIs__c							= oli.Related_QLI__r?.No_Of_PAN_OCR_APIs__c;
        newAsset.EPFO_ESTABLISHMENT_ADVANCED_API_credit__c 		= oli.Related_QLI__r?.EPFO_ESTABLISHMENT_ADVANCED_API_credit__c;
        newAsset.EPFO_ESTABLISHMENT_BASIC_API_credit__c 		= oli.Related_QLI__r?.EPFO_ESTABLISHMENT_BASIC_API_credit__c;
        newAsset.EPFO_ESTABLISHMENT_DETAILED_API_credit__c		= oli.Related_QLI__r?.EPFO_ESTABLISHMENT_DETAILED_API_credit__c;
        newAsset.No_of_EPFO_UAN_FETCH_APIs__c 					= oli.Related_QLI__r.No_of_EPFO_UAN_FETCH_APIs__c;
        newAsset.No_of_EPFO_UAN_AUTH_APIs__c 					= oli.Related_QLI__r.No_of_EPFO_UAN_AUTH_APIs__c;
        newAsset.No_of_EPFO_UAN_DETAILS_APIs__c 				= oli.Related_QLI__r.No_of_EPFO_UAN_DETAILS_APIs__c;
        newAsset.No_of_GSTIN_FILING_CREDITS_APIs__c 			= oli.Related_QLI__r.No_of_GSTIN_FILING_CREDITS_APIs__c;
        newAsset.No_of_GSTIN_SEARCH_BY_NAME_APIs__c 			= oli.Related_QLI__r.No_of_GSTIN_SEARCH_BY_NAME_APIs__c;
        newAsset.No_of_CUSTOMER_IDENTITY_FETCH_APIs__c 			= oli.Related_QLI__r.No_of_CUSTOMER_IDENTITY_FETCH_APIs__c;
        newAsset.No_of_DRIVING_LICENSE_DETAILED_APIs__c 		= oli.Related_QLI__r.No_of_DRIVING_LICENSE_DETAILED_APIs__c;
        newAsset.No_of_VEHICLE_REGISTRATION_DETAILED_API__c 	= oli.Related_QLI__r.No_of_VEHICLE_REGISTRATION_DETAILED_API__c;
        /**	Clear Identity Field Flow : END	**/
        /**	Resource Constaints Added By Niraj for GST : START	**/
        newAsset.GSTIN_Level_Recon__c							= oli.Related_QLI__r?.GSTIN_Level_Recon__c;
        newAsset.PAN_Level_Recon__c								= oli.Related_QLI__r?.PAN_Level_Recon__c;
        /**	Resource Constaints Added By Niraj for GST : End	**/
        newAsset.Total_no_of_Pages_in_Purchase_Invoices__c 		= oli.ProductCode.containsIgnoreCase('CLRCAP') ? oli.Related_QLI__r?.Total_no_of_Pages_in_Purchase_Invoices__c : NULL ;
        newAsset.Stage_in_MY__c 								= oli.Stage_in_MY__c != NULL ? oli.Stage_in_MY__c : NULL;
        newAsset.No_of_templates__c 							= oli.ProductCode.containsIgnoreCase('CPT-EINV-BASIC') ? oli.Related_QLI__r?.No_of_templates__c : NULL;
        newAsset.No_of_fields_to_be_edited_per_template__c 		= oli.ProductCode.containsIgnoreCase('CPT-EINV-BASIC') ? oli.Related_QLI__r?.No_of_fields_to_be_edited_per_template__c : NULL;
        newAsset.No_of_templates__c 							= oli.ProductCode.containsIgnoreCase('CPT-EINV-ADVANCED') ? oli.Related_QLI__r?.No_of_templates__c : NULL;
        newAsset.No_of_PAN_to_GSTIN_APIs__c 			  		= oli.Related_QLI__r?.No_of_PAN_to_GSTIN_APIs__c;
        newAsset.No_of_PAN_verification_detailed_APIs__c 		= oli.Related_QLI__r?.No_of_PAN_verification_detailed_APIs__c;
        /** Added By Niraj CDC Applicable START**/
        newAsset.CDC_Applicable__c 								= oli.Related_QLI__r.CDC_Applicable__c;
        newAsset.Number_of_Pulls__c 							= oli.Related_QLI__r.Number_of_Pulls__c;
        newAsset.No_of_PAN_Verification_with_Father_Name__c 	= oli.Related_QLI__r.No_of_PAN_Verification_with_Father_Name__c;
        /** Added By Niraj CDC Applicable END**/
        
        //newAsset.License_B2B_SalesInvoice_per_year__c			= oli.Related_QLI__r.BtoB_Sales_one__c;
        //newAsset.License_B2C_SalesInvoice_per_year__c 		= oli.Related_QLI__r.BtoC_Sales_one__c;
        
        
        
        if(oli.Stage_in_MY__c == 'Year 1' || oli.Stage_in_MY__c == 'Middle Year'){
            newAsset.Next_Multiyear_Asset_Exists__c 			= TRUE;
            newAsset.Multi_year__c 								= TRUE;
        }
        
        if(oli.Product2.Product_category__c == ProductConstants.PRODUCT_CATEGORY_INTEGRATION){
            if(oli.Product2.Product_Line__c.equals('Invoice Discounting')){  
                newAsset.RecordTypeId 							= AssetConstants.ASSET_INTEGRATIONID_RECORDTYPEID;
            }
            else{
                newAsset.RecordTypeId 							= Asset_Integration_Asset_RecordTypeId;
            }
        }else If(oli.Product2.Product_category__c == ProductConstants.PRODUCT_CATEGORY_SETUPONBOARDING){
            newAsset.RecordTypeId 								= Asset_OneTime_Asset_RecordTypeId;
        }else If(oli.Product2.Product_Category__c == 'AMC'){
            newAsset.RecordTypeId 								= AssetConstants.ASSET_INTEGRATION_RECORDTYPEID;
        }else{
            if(oli.Product2.Product_Line__c.equals('Invoice Discounting') && (oli.Product2.Product_Category__c.equals('SaaS') || oli.Product2.Product_Category__c.equals('Transactional'))){
                newAsset.RecordTypeId 							= AssetConstants.ASSET_LICENSEID_RECORDTYPEID;
            }
            else{
                newAsset.RecordTypeId 							= Asset_Lincence_Asset_RecordTypeId;
            }
            if(mapOfOpportunity.get(oli.OpportunityId).RecordTypeId == opportunity_Renewal_RecordTypeId){
                newAsset.Onboarding_Status__c 					= OrderItemConstants.STATUS_ONBOARDING_NOT_REQUIRED;
            }else{
                newAsset.Onboarding_Status__c 					= OrderItemConstants.STATUS_ONBOARDING_PENDING;
            }
        }
        
        /**	Resource Constraints Code Block : Clear Identity - START	**/
        if( oli.Product2.SaaS_Product__c != NULL && oli.Product2.SaaS_Product__c.equals('CLEAR_IDENTITY') ){
            newAsset.Identity_Resource_Constraints__c = oli.Related_QLI__r.Identity_Resource_Metadata__c;
        }
        /**	Resource Constraints Code Block : Clear Identity - END	**/
        
        
        /** GCC - Quote Params */
        if( oli.Opportunity.Country_of_Origin__c != 'India' && !String.ISBLANK(oli.Opportunity.Country_of_Origin__c) ){
            
            newAsset.No_of_VAT__c 								= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).No_of_VAT__c; 
            newAsset.License_no_of_userids__c 					= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).No_of_User_ID_one__c;
            newAsset.POS_system__c  							= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).POS_system__c ;
            newAsset.ERP_GCC__c   								= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).ERP_GCC__c;
            newAsset.No_of_Online_devices__c 					= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).No_of_Online_devices__c;
            newAsset.No_of_Offline_devices__c 					= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).No_of_Offline_devices__c;
            newAsset.License_B2B_SalesInvoice_per_year__c 		= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).BtoB_Sales_one__c;
            newAsset.License_B2C_SalesInvoice_per_year__c 		= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).BtoC_Sales_one__c;
            newAsset.No_of_retail_stores__c 					= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).No_of_retail_stores__c;
            newAsset.Data_Archival__c 							= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Data_Archival__c;
            newAsset.Auto_Retry__c 								= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Auto_Retry__c;
            newAsset.Translation__c 							= mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Translation__c;
        }
        
        if(oli.Opportunity.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OpportunityConstants.RECORDTYPENAME_RENEWAL).getRecordTypeId() && mapOfAssets.containsKey(oli.OpportunityId)){
            newAsset.Create_License_on_Asset_Creation__c 		= TRUE;
            newAsset.Onboarding_Status__c 						= 'Onboarding Not Required';
            RecursiveTriggerHandler.isFirstTimeRenewed 			= TRUE;
        }
        
        if(oli.Product2.Family.equalsIgnoreCase('Managed Service'))
            newAsset.Asset_Type__c 								= 'Managed Service';
        else if(!(oli.Product2.Product_category__c.equalsIgnoreCase('Integration') || oli.Product2.Product_category__c.equalsIgnoreCase('OTP') || oli.Product2.Family.equalsIgnoreCase('Managed Service')))
            newAsset.Asset_Type__c 								= 'Products';
        else if(oli.Product2.Product_category__c.equalsIgnoreCase('Integration'))
            newAsset.Asset_Type__c 								= 'Integration';
        
        
        return newAsset;
    }
    
    
}