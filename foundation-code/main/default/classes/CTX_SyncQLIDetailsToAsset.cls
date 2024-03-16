public class CTX_SyncQLIDetailsToAsset {
    public class CTX_SyncQLIDetailsToAssetException extends Exception {}
    
    @AuraEnabled
    public static void syncDetails(Id recordId){
        System.debug('@recordId'+recordId);
        try{
            List<OpportunityLineItem> oliList = [SELECT Id, Name, ProductCode, Quantity,PricebookEntry.Product2Id, PricebookEntry.Product2.Name, PricebookEntryId, UnitPrice,Product2.Family,Product2.Product_category__c,Sale_Price__c,
                                                 Description, OpportunityId, Opportunity.AccountId, Opportunity.Country_of_Origin__c, Opportunity.Account.OwnerId, Opportunity.SyncedQuoteId, Opportunity.CloseDate, Opportunity.Period_Start_date__c,CurrencyIsoCode,
                                                 Opportunity.Period_End_date__c,PO_End_Month__c,Period_End_date__c,Period_Start_date__c,Opportunity.Payment_method__c,Opportunity.Payment_term__c,Opportunity.RecordTypeId,MarkUp__c,Discount,Opportunity.LeadSource,Opportunity.One_to_Many_Type__c,Opportunity.Anchor_Companys__c,
                                                 Product2.Product_Line__c, Type_Of_Integration__c, Stage_in_MY__c, SOW_Start_Date__c, SOW_End_Date__c, Total_Price__c,Opportunity.platform__c,
                                                 Related_QLI__r.BtoB_Sales_one__c ,Related_QLI__r.BtoC_Sales_one__c ,Related_QLI__r.Flat_Transaction_Fee__c ,Related_QLI__r.Number_of_Deductees_per_Quarter_24Q_26__c ,
                                                 Related_QLI__r.Number_of_Deduction_Transactions_per_Qua__c ,Related_QLI__r.No_of_EWBs__c ,Related_QLI__r.No_of_expected_B2C_invoices_for_QR_code__c ,Related_QLI__r.No_of_GST_GSP_API_calls_permissible__c ,
                                                 Related_QLI__r.No_of_GSTIN_one__c ,Related_QLI__r.No_of_GSTIN_verification_credits__c ,Related_QLI__r.No_of_invoice_formats__c ,Related_QLI__r.No_of_IRNs__c ,
                                                 Related_QLI__r.No_of_PAN_one__c ,Related_QLI__r.No_of_recons__c ,Related_QLI__r.No_of_TANs__c ,Related_QLI__r.No_of_Total_invoices__c ,
                                                 Related_QLI__r.No_of_User_ID_one__c ,Related_QLI__r.No_of_Vendors_one__c ,Related_QLI__r.No_of_airline_invoices_annual_one__c ,Related_QLI__r.Number_of_eway_bill__c ,
                                                 Related_QLI__r.Partner_Count_for_GeEr_up_Reports__c ,Related_QLI__r.Purchases_Invoices_one__c ,Related_QLI__r.Tally_Connector_required__c,
                                                 Related_QLI__r.Transaction_Fee_Slab_1__c ,Related_QLI__r.Type_of_Compliance_service__c,Related_QLI__r.platform__c,Related_QLI__r.No_MM2A_2B_usage_GSTIN_month__c,Related_QLI__r.Type_of_Integration__c,Related_QLI__r.No_of_API_calls_permissible__c,
                                                 Related_QLI__r.No_of_Bank_verification_API__c,Related_QLI__r.Digital_Signing_Utility_for_TDS_Cert_del__c,
                                                 Related_QLI__r.No_of_MCA_Company_details_API__c,Related_QLI__r.No_of_MSME_API__c,Related_QLI__r.No_of_PAN_verification_API__c,Related_QLI__r.No_of_TDS_206_sync_API__c,Related_QLI__r.Total_B2B_PR_B2C_invoice__c,
                                                 Related_QLI__r.POS_system__c ,Related_QLI__r.No_of_retail_stores__c,
                                                 Related_QLI__r.No_of_PAN_to_GSTIN_APIs__c,  Related_QLI__r.No_of_PAN_verification_detailed_APIs__c, Related_QLI__r.CDC_Applicable__c, Related_QLI__r.Number_of_Pulls__c,Related_QLI__r.No_of_PAN_Verification_with_Father_Name__c,
                                                 
                                                 Related_QLI__r.No_Of_GST_ADVANCED_APIs__c,
                                                 Related_QLI__r.No_Of_GST_ADVANCED_PLUS_APIs__c,
                                                 Related_QLI__r.No_Of_PAN_OCR_APIs__c,
                                                 Related_QLI__r.No_of_fields_to_be_edited_per_template__c,
                                                 Related_QLI__r.No_of_templates__c,
                                                 Related_QLI__r.Total_no_of_Pages_in_Purchase_Invoices__c,
                                                 
                                                 Related_QLI__r.Parent_Asset__r.License_ID__c,
                                                 
                                                 Opportunity.SyncedQuote.No_of_VAT__c, Opportunity.SyncedQuote.No_of_User_ID_one__c,
                                                 Opportunity.SyncedQuote.POS_system__c , Opportunity.SyncedQuote.ERP_GCC__c,
                                                 Opportunity.SyncedQuote.No_of_Online_devices__c, Opportunity.SyncedQuote.No_of_Offline_devices__c,
                                                 Opportunity.SyncedQuote.BtoB_Sales_one__c, Opportunity.SyncedQuote.BtoC_Sales_one__c,
                                                 Opportunity.SyncedQuote.No_of_retail_stores__c, Opportunity.SyncedQuote.Total_annual_domestic_payables_Rs_Cr__c,
                                                 Opportunity.SyncedQuote.Transaction_Fee_Slab_3__c, Opportunity.SyncedQuote.Transaction_Fee_Slab_2__c,
                                                 Opportunity.SyncedQuote.Monthly_throughput_Slab_1_Cr__c, Opportunity.SyncedQuote.Monthly_throughput_Slab_2_Cr__c, 
                                                 Opportunity.SyncedQuote.Monthly_throughput_Slab_3_Cr__c, Opportunity.SyncedQuote.opportunity.Anchor_Companys__c,
                                                 Opportunity.SyncedQuote.opportunity.One_to_Many_Type__c, Opportunity.SyncedQuote.Zone__c, Opportunity.SyncedQuote.Turnover_one__c,
                                                 Opportunity.SyncedQuote.Existing_Vendor__c, Opportunity.SyncedQuote.ERP__c, Opportunity.SyncedQuote.Category_of_Company__c
                                                 
                                                 FROM OpportunityLineItem where Related_QLI__c =: recordId];
            
            List<Asset> assetList = [SELECT Id, License_ID__c ,Name FROM Asset WHERE Related_QLI_Id__c =: recordId];
            
            
            if(assetList.size() > 0){
                Asset 				Newassets 	= assetList[0];
                OpportunityLineItem oli			= oliList[0];
                
                Newassets.CurrencyIsoCode = oli.CurrencyIsoCode;
                Newassets.AccountId = oli.Opportunity.AccountId;
                Newassets.Product2Id = oli.PricebookEntry.Product2Id;
                Newassets.Quantity = oli.Quantity;
                Newassets.Price =  oli.Total_Price__c;
                Newassets.PurchaseDate = oli.Period_Start_date__c ;
                Newassets.UsageEndDate  = oli.Period_End_date__c;
                Newassets.Related_QLI_Id__c = oli.Related_QLI__c;
                Newassets.platform__c  = oli.Related_QLI__r?.platform__c;
                Newassets.Status = 'Inactive';
                Newassets.Payment_term__c = oli.Opportunity.Payment_term__c;
                Newassets.Payment_method__c = oli.Opportunity.Payment_method__c;
                Newassets.Description = oli.Description;
                if(oli.Period_End_date__c != NULL)
                    Newassets.Name = oli.PricebookEntry.Product2.Name + ' '+oli.PO_End_Month__c + ' '+oli.Period_End_date__c.year();
                else
                    Newassets.Name = oli.PricebookEntry.Product2.Name + ' '+oli.PO_End_Month__c;
                Newassets.OwnerId = oli.Opportunity.Account.OwnerId;
                //Pramodh Started Syncing Fields
                Newassets.License_B2B_SalesInvoice_per_year__c = oli.Related_QLI__r?.BtoB_Sales_one__c ;
                Newassets.Opportunity__c=oli.OpportunityId;                    
                Newassets.BackEndQuote__c = oli.Opportunity.SyncedQuoteId;
                Newassets.Number_of_TANs__c = oli.Related_QLI__r?.No_of_TANs__c;
                Newassets.Number_of_Deductees_per_Quarter_24Q_26__c = oli.Related_QLI__r?.Number_of_Deductees_per_Quarter_24Q_26__c;
                Newassets.Number_of_Deduction_Transactions_per_Qua__c = oli.Related_QLI__r?.Number_of_Deduction_Transactions_per_Qua__c;
                Newassets.Digital_Signing_Utility_for_TDS_Certific__c = oli.Related_QLI__r?.Digital_Signing_Utility_for_TDS_Cert_del__c;
                Newassets.License_B2C_SalesInvoice_per_year__c = oli.Related_QLI__r?.BtoC_Sales_one__c;
                Newassets.Category_of_Company__c  = oli.Opportunity.SyncedQuote.Category_of_Company__c;
                Newassets.ERP__c = oli.Opportunity.SyncedQuote.ERP__c;
                Newassets.Existing_Vendor__c = oli.Opportunity.SyncedQuote.Existing_Vendor__c;
                
                Newassets.License_no_of_gstins__c = oli.Related_QLI__r?.No_of_GSTIN_one__c; 
                Newassets.License_no_of_pans__c = oli.Related_QLI__r?.No_of_PAN_one__c;
                
                Newassets.License_no_of_userids__c = oli.Related_QLI__r?.No_of_User_ID_one__c;
                Newassets.No_of_Vendor__c = oli.Related_QLI__r?.No_of_Vendors_one__c;
                Newassets.No_of_airline_invoices_annual__c = oli.Related_QLI__r?.No_of_airline_invoices_annual_one__c;
                Newassets.No_of_airline_invoices__c = oli.Related_QLI__r?.No_of_airline_invoices_annual_one__c;//Move to QLI
                Newassets.Turnover_one__c = oli.Opportunity.SyncedQuote.Turnover_one__c;
                Newassets.Type_of_Integration__c = oli.Related_QLI__r?.Type_of_Integration__c;
                Newassets.Zone__c = oli.Opportunity.SyncedQuote.Zone__c;
                // Newassets.Number_of_Sales_Invoices__c = mapOfSyncedQuotes.get(oli.Opportunity.SyncedQuoteId).Number_of_Sales_Invoices__c;
                //Newassets.Number_of_eway_bill__c = oli.Related_QLI__r?.Number_of_eway_bill__c;
                Newassets.Number_of_Purchase_Invoice__c = oli.Related_QLI__r?.Purchases_Invoices_one__c;
                Newassets.lead_source__c = oli.Opportunity.LeadSource;
                Newassets.Anchor_Companys__c = oli.Opportunity.SyncedQuote.opportunity.Anchor_Companys__c;
                Newassets.One_to_Many_Type__c = oli.Opportunity.SyncedQuote.opportunity.One_to_Many_Type__c;
                Newassets.Number_of_eway_bill__c = oli.Related_QLI__r?.No_of_EWBs__c;
                Newassets.License_no_of_invoice_formats__c = oli.Related_QLI__r?.No_of_invoice_formats__c;
                Newassets.License_no_of_gstin_verification_credits__c =  oli.Related_QLI__r?.No_of_GSTIN_verification_credits__c;
                Newassets.License_no_of_irns_per_year__c = oli.Related_QLI__r?.No_of_IRNs__c;
                Newassets.License_No_of_MM2A_2B_usage_GSTIN_mon__c = oli.Related_QLI__r?.No_MM2A_2B_usage_GSTIN_month__c;
                Newassets.License_no_of_Recon__c = oli.Related_QLI__r?.No_of_recons__c;
                Newassets.No_of_expected_B2C_invoices_for_QR_code__c = oli.Related_QLI__r?.No_of_expected_B2C_invoices_for_QR_code__c;
                Newassets.Partner_Count_for_GeEr_up_Reports__c = oli.Related_QLI__r?.Partner_Count_for_GeEr_up_Reports__c;
                Newassets.Monthly_throughput_Slab_1_Cr__c = oli.Opportunity.SyncedQuote.Monthly_throughput_Slab_1_Cr__c;
                Newassets.Monthly_throughput_Slab_2_Cr__c  = oli.Opportunity.SyncedQuote.Monthly_throughput_Slab_2_Cr__c;
                Newassets.Monthly_throughput_Slab_3_Cr__c  = oli.Opportunity.SyncedQuote.Monthly_throughput_Slab_3_Cr__c;
                Newassets.Transaction_Fee_Slab_1__c = oli.Related_QLI__r?.Transaction_Fee_Slab_1__c;
                Newassets.Transaction_Fee_Slab_2__c  = oli.Opportunity.SyncedQuote.Transaction_Fee_Slab_2__c;
                Newassets.Transaction_Fee_Slab_3__c  = oli.Opportunity.SyncedQuote.Transaction_Fee_Slab_3__c;
                Newassets.Flat_Transaction_Fee__c  = oli.Related_QLI__r?.Flat_Transaction_Fee__c;
                Newassets.Tally_Connector_required__c   = oli.Related_QLI__r?.Tally_Connector_required__c;
                Newassets.Total_annual_domestic_payables_Rs_Cr__c    = oli.Opportunity.SyncedQuote.Total_annual_domestic_payables_Rs_Cr__c ;
                if(oli.Related_QLI__r?.No_of_retail_stores__c!=NULL)
                {   
                    Newassets.No_of_retail_stores__c = oli.Related_QLI__r?.No_of_retail_stores__c;// Asset Usage Details
                }
                Newassets.POS_system__c  = oli.Related_QLI__r?.POS_system__c ;
                //new fields mapping : bhaveshjindal
                Newassets.No_of_Bank_verification_API__c 	= oli.Related_QLI__r?.No_of_Bank_verification_API__c;
                Newassets.No_of_API_calls_permissible__c 	= oli.Related_QLI__r?.No_of_API_calls_permissible__c;
                Newassets.No_of_MCA_Company_details_API__c 	= oli.Related_QLI__r?.No_of_MCA_Company_details_API__c;
                Newassets.No_of_MSME_API__c 				= oli.Related_QLI__r?.No_of_MSME_API__c;
                Newassets.No_of_PAN_verification_API__c 	= oli.Related_QLI__r?.No_of_PAN_verification_API__c;
                Newassets.No_of_TDS_206_sync_API__c 		= oli.Related_QLI__r?.No_of_TDS_206_sync_API__c;
                
                //newTypeOfIntegration
                //added by bhaveshjindal
                Newassets.Type_of_Integration_QLI__c = oli.Type_of_Integration__c;
                
                //Sow FieldsMapping
                //added by bhaveshjindal
                Newassets.SOW_Start_Date__c  = oli.SOW_Start_Date__c;
                Newassets.SOW_End_Date__c  = oli.SOW_End_Date__c;
                
                //Multi-year tagging from Quote line 
                //added by Ashwinkrishna
                
                /**	Clear Identity Field Flow : START	**/
                Newassets.No_Of_GST_ADVANCED_APIs__c			= oli.Related_QLI__r?.No_Of_GST_ADVANCED_APIs__c;
                Newassets.No_Of_GST_ADVANCED_PLUS_APIs__c		= oli.Related_QLI__r?.No_Of_GST_ADVANCED_PLUS_APIs__c;
                Newassets.No_Of_PAN_OCR_APIs__c					= oli.Related_QLI__r?.No_Of_PAN_OCR_APIs__c;
                /**	Clear Identity Field Flow : END	**/
                
                
                
                if(oli.ProductCode.containsIgnoreCase('CLRCAP')){
                    Newassets.Total_no_of_Pages_in_Purchase_Invoices__c = oli.Related_QLI__r?.Total_no_of_Pages_in_Purchase_Invoices__c ;
                }
                
                if(oli.ProductCode.containsIgnoreCase('CPT-EINV-BASIC')){
                    Newassets.No_of_templates__c = oli.Related_QLI__r?.No_of_templates__c;  
                    Newassets.No_of_fields_to_be_edited_per_template__c = oli.Related_QLI__r?.No_of_fields_to_be_edited_per_template__c; 
                }
                
                if(oli.ProductCode.containsIgnoreCase('CPT-EINV-ADVANCED')){
                    Newassets.No_of_templates__c = oli.Related_QLI__r?.No_of_templates__c; 
                }
                
                if(oli.Stage_in_MY__c != NULL){
                    Newassets.Stage_in_MY__c = oli.Stage_in_MY__c;
                }
                
                if(oli.Stage_in_MY__c == 'Year 1' || oli.Stage_in_MY__c == 'Middle Year'){
                    Newassets.Next_Multiyear_Asset_Exists__c = TRUE;
                    Newassets.Multi_year__c = TRUE;
                }
                
                Newassets.No_of_PAN_to_GSTIN_APIs__c 			  = oli.Related_QLI__r?.No_of_PAN_to_GSTIN_APIs__c;
                Newassets.No_of_PAN_verification_detailed_APIs__c = oli.Related_QLI__r?.No_of_PAN_verification_detailed_APIs__c;
                
                /** Added By Niraj CDC Applicable START**/
                Newassets.CDC_Applicable__c = oli.Related_QLI__r.CDC_Applicable__c;// Asset Usage Details
                Newassets.Number_of_Pulls__c = oli.Related_QLI__r.Number_of_Pulls__c;// Asset Usage Details
                Newassets.No_of_PAN_Verification_with_Father_Name__c = oli.Related_QLI__r.No_of_PAN_Verification_with_Father_Name__c;// Asset Usage Details - Identity
                /** Added By Niraj CDC Applicable END**/
                
                //Pramodh Ended Syncing Fields
                //Added by Raksha
                if(oli.Product2.Product_category__c == ProductConstants.PRODUCT_CATEGORY_INTEGRATION){
                    if(oli.Product2.Product_Line__c.equals('Invoice Discounting')){  
                        Newassets.RecordTypeId = AssetConstants.ASSET_INTEGRATIONID_RECORDTYPEID;
                    }
                    else{
                        Newassets.RecordTypeId = AssetConstants.ASSET_INTEGRATION_RECORDTYPEID;
                    }
                }else If(oli.Product2.Product_category__c == ProductConstants.PRODUCT_CATEGORY_SETUPONBOARDING){
                    Newassets.RecordTypeId = AssetConstants.ASSET_ONETIMEASSET_RECORDTYPEID;
                }else If(oli.Product2.Product_Category__c == 'AMC'){
                    Newassets.RecordTypeId = AssetConstants.ASSET_INTEGRATION_RECORDTYPEID;
                }else{
                    if(oli.Product2.Product_Line__c.equals('Invoice Discounting') && (oli.Product2.Product_Category__c.equals('SaaS') || oli.Product2.Product_Category__c.equals('Transactional'))){
                        Newassets.RecordTypeId = AssetConstants.ASSET_LICENSEID_RECORDTYPEID;
                    }
                    else{
                        Newassets.RecordTypeId = AssetConstants.ASSET_LICENSE_RECORDTYPEID;
                    }
                    if(oli.Opportunity.RecordTypeId == OpportunityConstants.RECORDTYPEID_RENEWAL){
                        Newassets.Onboarding_Status__c = OrderItemConstants.STATUS_ONBOARDING_NOT_REQUIRED;
                    }else{
                        Newassets.Onboarding_Status__c = OrderItemConstants.STATUS_ONBOARDING_PENDING;
                    }
                }
                if(oli.MarkUp__c != null){
                    Newassets.MarkUp__c = oli.MarkUp__c;
                }
                if(oli.Discount != null){
                    Newassets.Discount__c = oli.Discount; 
                }
                
                /** GCC - Quote Params */
                if(oli.Opportunity.Country_of_Origin__c != 'India' && !String.ISBLANK(oli.Opportunity.Country_of_Origin__c)){
                    Newassets.No_of_VAT__c 				= oli.Opportunity.SyncedQuote.No_of_VAT__c; 
                    Newassets.License_no_of_userids__c 	= oli.Opportunity.SyncedQuote.No_of_User_ID_one__c;
                    Newassets.POS_system__c  			= oli.Opportunity.SyncedQuote.POS_system__c ;
                    Newassets.ERP_GCC__c   				= oli.Opportunity.SyncedQuote.ERP_GCC__c;
                    Newassets.No_of_Online_devices__c 	= oli.Opportunity.SyncedQuote.No_of_Online_devices__c;
                    Newassets.No_of_Offline_devices__c 	= oli.Opportunity.SyncedQuote.No_of_Offline_devices__c;
                    Newassets.License_B2B_SalesInvoice_per_year__c = oli.Opportunity.SyncedQuote.BtoB_Sales_one__c;
                    Newassets.License_B2C_SalesInvoice_per_year__c = oli.Opportunity.SyncedQuote.BtoC_Sales_one__c;
                    Newassets.No_of_retail_stores__c = oli.Opportunity.SyncedQuote.No_of_retail_stores__c;
                }
                update Newassets;
                //Temp Code Need to replace with best practice End
            } else {
                new CTX_SyncQLIDetailsToAssetException('No Related Asset found');
            }
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    @future
    public static void syncAssetDetails(Id recordId){
        try{
            List<OpportunityLineItem> oliList = 
                [ SELECT 
                 
                 Id, Name, ProductCode, Quantity,PricebookEntry.Product2Id, 
                 PricebookEntry.Product2.Name, PricebookEntryId, UnitPrice,Product2.Family,
                 Product2.Product_category__c,Sale_Price__c,
                 Description, OpportunityId, Opportunity.AccountId, 
                 Opportunity.Country_of_Origin__c, Opportunity.Account.OwnerId, 
                 Opportunity.SyncedQuoteId, Opportunity.CloseDate, Opportunity.Period_Start_date__c,
                 CurrencyIsoCode, Opportunity.Period_End_date__c,PO_End_Month__c,
                 Period_End_date__c,Period_Start_date__c,Opportunity.Payment_method__c,
                 Opportunity.Payment_term__c,Opportunity.RecordTypeId,MarkUp__c,Discount,
                 Opportunity.LeadSource,Opportunity.One_to_Many_Type__c,
                 Opportunity.Anchor_Companys__c, Product2.Product_Line__c, Type_Of_Integration__c,
                 Stage_in_MY__c, SOW_Start_Date__c, SOW_End_Date__c, Total_Price__c,
                 Opportunity.platform__c, Related_QLI__r.BtoB_Sales_one__c ,
                 Related_QLI__r.BtoC_Sales_one__c ,Related_QLI__r.Flat_Transaction_Fee__c ,
                 Related_QLI__r.Number_of_Deductees_per_Quarter_24Q_26__c ,
                 Related_QLI__r.Number_of_Deduction_Transactions_per_Qua__c ,
                 Related_QLI__r.No_of_EWBs__c ,
                 Related_QLI__r.No_of_expected_B2C_invoices_for_QR_code__c ,
                 Related_QLI__r.No_of_GST_GSP_API_calls_permissible__c ,
                 Related_QLI__r.No_of_GSTIN_one__c ,
                 Related_QLI__r.No_of_GSTIN_verification_credits__c ,
                 Related_QLI__r.No_of_invoice_formats__c ,Related_QLI__r.No_of_IRNs__c ,
                 Related_QLI__r.No_of_PAN_one__c ,Related_QLI__r.No_of_recons__c ,
                 Related_QLI__r.No_of_TANs__c ,Related_QLI__r.No_of_Total_invoices__c ,
                 Related_QLI__r.No_of_User_ID_one__c ,Related_QLI__r.No_of_Vendors_one__c ,
                 Related_QLI__r.No_of_airline_invoices_annual_one__c ,Related_QLI__r.Number_of_eway_bill__c ,
                 Related_QLI__r.Partner_Count_for_GeEr_up_Reports__c ,Related_QLI__r.Purchases_Invoices_one__c ,
                 Related_QLI__r.Tally_Connector_required__c,
                 Related_QLI__r.Transaction_Fee_Slab_1__c ,Related_QLI__r.Type_of_Compliance_service__c,
                 Related_QLI__r.platform__c,Related_QLI__r.No_MM2A_2B_usage_GSTIN_month__c,Related_QLI__r.Type_of_Integration__c,
                 Related_QLI__r.No_of_API_calls_permissible__c,
                 Related_QLI__r.No_of_Bank_verification_API__c,Related_QLI__r.Digital_Signing_Utility_for_TDS_Cert_del__c,
                 Related_QLI__r.No_of_MCA_Company_details_API__c,Related_QLI__r.No_of_MSME_API__c,
                 Related_QLI__r.No_of_PAN_verification_API__c,Related_QLI__r.No_of_TDS_206_sync_API__c,
                 Related_QLI__r.Total_B2B_PR_B2C_invoice__c,
                 Related_QLI__r.POS_system__c ,Related_QLI__r.No_of_retail_stores__c,
                 Related_QLI__r.No_of_PAN_to_GSTIN_APIs__c,  Related_QLI__r.No_of_PAN_verification_detailed_APIs__c,
                 Related_QLI__r.CDC_Applicable__c, Related_QLI__r.Number_of_Pulls__c,
                 Related_QLI__r.No_of_PAN_Verification_with_Father_Name__c,
                 Related_QLI__r.No_Of_GST_ADVANCED_APIs__c,
                 Related_QLI__r.No_Of_GST_ADVANCED_PLUS_APIs__c,
                 Related_QLI__r.No_Of_PAN_OCR_APIs__c,
                 Related_QLI__r.No_of_fields_to_be_edited_per_template__c,
                 Related_QLI__r.No_of_templates__c,
                 Related_QLI__r.Total_no_of_Pages_in_Purchase_Invoices__c,
                 Related_QLI__r.UnitPrice,
                 Related_QLI__r.Sale_Price__c,

                 Opportunity.SyncedQuote.No_of_VAT__c, Opportunity.SyncedQuote.No_of_User_ID_one__c,
                 Opportunity.SyncedQuote.POS_system__c , Opportunity.SyncedQuote.ERP_GCC__c,
                 Opportunity.SyncedQuote.No_of_Online_devices__c, Opportunity.SyncedQuote.No_of_Offline_devices__c,
                 Opportunity.SyncedQuote.BtoB_Sales_one__c, Opportunity.SyncedQuote.BtoC_Sales_one__c,
                 Opportunity.SyncedQuote.No_of_retail_stores__c, Opportunity.SyncedQuote.Total_annual_domestic_payables_Rs_Cr__c,
                 Opportunity.SyncedQuote.Transaction_Fee_Slab_3__c, Opportunity.SyncedQuote.Transaction_Fee_Slab_2__c,
                 Opportunity.SyncedQuote.Monthly_throughput_Slab_1_Cr__c, Opportunity.SyncedQuote.Monthly_throughput_Slab_2_Cr__c, 
                 Opportunity.SyncedQuote.Monthly_throughput_Slab_3_Cr__c, Opportunity.SyncedQuote.opportunity.Anchor_Companys__c,
                 Opportunity.SyncedQuote.opportunity.One_to_Many_Type__c, Opportunity.SyncedQuote.Zone__c, Opportunity.SyncedQuote.Turnover_one__c,
                 Opportunity.SyncedQuote.Existing_Vendor__c, Opportunity.SyncedQuote.ERP__c, Opportunity.SyncedQuote.Category_of_Company__c
                 
                 FROM OpportunityLineItem where Related_QLI__c =: recordId ];
            system.debug('oliList: '+oliList);
            
            List<Asset> assetList = [ SELECT Id, Name FROM Asset WHERE Related_QLI_Id__c =: recordId ];
            
            List<Additional_GSTIN__c> additionalGstin = [ SELECT Id, Amount__c 
                                                         FROM Additional_GSTIN__c WHERE 
                                                         Asset__c IN :assetList];
            
            if(assetList.size() > 0){
                Asset 				Newassets 	= assetList[0];
                
                OpportunityLineItem oli			= oliList[0];
                
                Newassets.CurrencyIsoCode = oli.CurrencyIsoCode;
                Newassets.AccountId = oli.Opportunity.AccountId;
                Newassets.Product2Id = oli.PricebookEntry.Product2Id;
                Newassets.Quantity = oli.Quantity;
                Newassets.Price =  oli.Related_QLI__r?.Sale_Price__c;
                if(additionalGstin.size()>0){
                    additionalGstin[0].Amount__c = oli.Related_QLI__r?.Sale_Price__c;
                }
                
                Newassets.PurchaseDate = oli.Period_Start_date__c ;
                Newassets.UsageEndDate  = oli.Period_End_date__c;
                Newassets.Related_QLI_Id__c = oli.Related_QLI__c;
                Newassets.platform__c  = oli.Related_QLI__r?.platform__c;
                Newassets.Status = 'Inactive';
                Newassets.Payment_term__c = oli.Opportunity.Payment_term__c;
                Newassets.Payment_method__c = oli.Opportunity.Payment_method__c;
                Newassets.Description = oli.Description;
                if(oli.Period_End_date__c != NULL)
                    Newassets.Name = oli.PricebookEntry.Product2.Name + ' '+oli.PO_End_Month__c + ' '+oli.Period_End_date__c.year();
                else
                    Newassets.Name = oli.PricebookEntry.Product2.Name + ' '+oli.PO_End_Month__c;
                Newassets.OwnerId = oli.Opportunity.Account.OwnerId;
                
                Newassets.License_B2B_SalesInvoice_per_year__c = oli.Related_QLI__r?.BtoB_Sales_one__c ;
                Newassets.Opportunity__c=oli.OpportunityId;                    
                Newassets.BackEndQuote__c = oli.Opportunity.SyncedQuoteId;
                Newassets.Number_of_TANs__c = oli.Related_QLI__r?.No_of_TANs__c;
                Newassets.Number_of_Deductees_per_Quarter_24Q_26__c = oli.Related_QLI__r?.Number_of_Deductees_per_Quarter_24Q_26__c;
                Newassets.Number_of_Deduction_Transactions_per_Qua__c = oli.Related_QLI__r?.Number_of_Deduction_Transactions_per_Qua__c;
                Newassets.Digital_Signing_Utility_for_TDS_Certific__c = oli.Related_QLI__r?.Digital_Signing_Utility_for_TDS_Cert_del__c;
                Newassets.License_B2C_SalesInvoice_per_year__c = oli.Related_QLI__r?.BtoC_Sales_one__c;
                Newassets.Category_of_Company__c  = oli.Opportunity.SyncedQuote.Category_of_Company__c;
                Newassets.ERP__c = oli.Opportunity.SyncedQuote.ERP__c;
                Newassets.Existing_Vendor__c = oli.Opportunity.SyncedQuote.Existing_Vendor__c;
                
                Newassets.License_no_of_gstins__c = oli.Related_QLI__r?.No_of_GSTIN_one__c; 
                Newassets.License_no_of_pans__c = oli.Related_QLI__r?.No_of_PAN_one__c;
                
                Newassets.License_no_of_userids__c = oli.Related_QLI__r?.No_of_User_ID_one__c;
                Newassets.No_of_Vendor__c = oli.Related_QLI__r?.No_of_Vendors_one__c;
                Newassets.No_of_airline_invoices_annual__c = oli.Related_QLI__r?.No_of_airline_invoices_annual_one__c;
                Newassets.No_of_airline_invoices__c = oli.Related_QLI__r?.No_of_airline_invoices_annual_one__c;//Move to QLI
                Newassets.Turnover_one__c = oli.Opportunity.SyncedQuote.Turnover_one__c;
                Newassets.Type_of_Integration__c = oli.Related_QLI__r?.Type_of_Integration__c;
                Newassets.Zone__c = oli.Opportunity.SyncedQuote.Zone__c;
                Newassets.Number_of_Purchase_Invoice__c = oli.Related_QLI__r?.Purchases_Invoices_one__c;
                Newassets.lead_source__c = oli.Opportunity.LeadSource;
                Newassets.Anchor_Companys__c = oli.Opportunity.SyncedQuote.opportunity.Anchor_Companys__c;
                Newassets.One_to_Many_Type__c = oli.Opportunity.SyncedQuote.opportunity.One_to_Many_Type__c;
                Newassets.Number_of_eway_bill__c = oli.Related_QLI__r?.No_of_EWBs__c;
                Newassets.License_no_of_invoice_formats__c = oli.Related_QLI__r?.No_of_invoice_formats__c;
                Newassets.License_no_of_gstin_verification_credits__c =  oli.Related_QLI__r?.No_of_GSTIN_verification_credits__c;
                Newassets.License_no_of_irns_per_year__c = oli.Related_QLI__r?.No_of_IRNs__c;
                Newassets.License_No_of_MM2A_2B_usage_GSTIN_mon__c = oli.Related_QLI__r?.No_MM2A_2B_usage_GSTIN_month__c;
                Newassets.License_no_of_Recon__c = oli.Related_QLI__r?.No_of_recons__c;
                Newassets.No_of_expected_B2C_invoices_for_QR_code__c = oli.Related_QLI__r?.No_of_expected_B2C_invoices_for_QR_code__c;
                Newassets.Partner_Count_for_GeEr_up_Reports__c = oli.Related_QLI__r?.Partner_Count_for_GeEr_up_Reports__c;
                Newassets.Monthly_throughput_Slab_1_Cr__c = oli.Opportunity.SyncedQuote.Monthly_throughput_Slab_1_Cr__c;
                Newassets.Monthly_throughput_Slab_2_Cr__c  = oli.Opportunity.SyncedQuote.Monthly_throughput_Slab_2_Cr__c;
                Newassets.Monthly_throughput_Slab_3_Cr__c  = oli.Opportunity.SyncedQuote.Monthly_throughput_Slab_3_Cr__c;
                Newassets.Transaction_Fee_Slab_1__c = oli.Related_QLI__r?.Transaction_Fee_Slab_1__c;
                Newassets.Transaction_Fee_Slab_2__c  = oli.Opportunity.SyncedQuote.Transaction_Fee_Slab_2__c;
                Newassets.Transaction_Fee_Slab_3__c  = oli.Opportunity.SyncedQuote.Transaction_Fee_Slab_3__c;
                Newassets.Flat_Transaction_Fee__c  = oli.Related_QLI__r?.Flat_Transaction_Fee__c;
                Newassets.Tally_Connector_required__c   = oli.Related_QLI__r?.Tally_Connector_required__c;
                Newassets.Total_annual_domestic_payables_Rs_Cr__c    = oli.Opportunity.SyncedQuote.Total_annual_domestic_payables_Rs_Cr__c ;
                if(oli.Related_QLI__r?.No_of_retail_stores__c!=NULL)
                {   
                    Newassets.No_of_retail_stores__c = oli.Related_QLI__r?.No_of_retail_stores__c;// Asset Usage Details
                }
                Newassets.POS_system__c  = oli.Related_QLI__r?.POS_system__c ;
                //new fields mapping : bhaveshjindal
                Newassets.No_of_Bank_verification_API__c 	= oli.Related_QLI__r?.No_of_Bank_verification_API__c;
                Newassets.No_of_API_calls_permissible__c 	= oli.Related_QLI__r?.No_of_API_calls_permissible__c;
                Newassets.No_of_MCA_Company_details_API__c 	= oli.Related_QLI__r?.No_of_MCA_Company_details_API__c;
                Newassets.No_of_MSME_API__c 				= oli.Related_QLI__r?.No_of_MSME_API__c;
                Newassets.No_of_PAN_verification_API__c 	= oli.Related_QLI__r?.No_of_PAN_verification_API__c;
                Newassets.No_of_TDS_206_sync_API__c 		= oli.Related_QLI__r?.No_of_TDS_206_sync_API__c;
                
                //newTypeOfIntegration
                //added by bhaveshjindal
                Newassets.Type_of_Integration_QLI__c = oli.Type_of_Integration__c;
                
                //Sow FieldsMapping
                //added by bhaveshjindal
                Newassets.SOW_Start_Date__c  = oli.SOW_Start_Date__c;
                Newassets.SOW_End_Date__c  = oli.SOW_End_Date__c;
                
                //Multi-year tagging from Quote line 
                //added by Ashwinkrishna
                
                /**	Clear Identity Field Flow : START	**/
                Newassets.No_Of_GST_ADVANCED_APIs__c			= oli.Related_QLI__r?.No_Of_GST_ADVANCED_APIs__c;
                Newassets.No_Of_GST_ADVANCED_PLUS_APIs__c		= oli.Related_QLI__r?.No_Of_GST_ADVANCED_PLUS_APIs__c;
                Newassets.No_Of_PAN_OCR_APIs__c					= oli.Related_QLI__r?.No_Of_PAN_OCR_APIs__c;
                /**	Clear Identity Field Flow : END	**/
                
                
                
                if(oli.ProductCode.containsIgnoreCase('CLRCAP')){
                    Newassets.Total_no_of_Pages_in_Purchase_Invoices__c = oli.Related_QLI__r?.Total_no_of_Pages_in_Purchase_Invoices__c ;
                }
                
                if(oli.ProductCode.containsIgnoreCase('CPT-EINV-BASIC')){
                    Newassets.No_of_templates__c = oli.Related_QLI__r?.No_of_templates__c;  
                    Newassets.No_of_fields_to_be_edited_per_template__c = oli.Related_QLI__r?.No_of_fields_to_be_edited_per_template__c; 
                }
                
                if(oli.ProductCode.containsIgnoreCase('CPT-EINV-ADVANCED')){
                    Newassets.No_of_templates__c = oli.Related_QLI__r?.No_of_templates__c; 
                }
                
                if(oli.Stage_in_MY__c != NULL){
                    Newassets.Stage_in_MY__c = oli.Stage_in_MY__c;
                }
                
                if(oli.Stage_in_MY__c == 'Year 1' || oli.Stage_in_MY__c == 'Middle Year'){
                    Newassets.Next_Multiyear_Asset_Exists__c = TRUE;
                    Newassets.Multi_year__c = TRUE;
                }
                
                Newassets.No_of_PAN_to_GSTIN_APIs__c 			  = oli.Related_QLI__r?.No_of_PAN_to_GSTIN_APIs__c;
                Newassets.No_of_PAN_verification_detailed_APIs__c = oli.Related_QLI__r?.No_of_PAN_verification_detailed_APIs__c;
                
                /** Added By Niraj CDC Applicable START**/
                Newassets.CDC_Applicable__c = oli.Related_QLI__r.CDC_Applicable__c;// Asset Usage Details
                Newassets.Number_of_Pulls__c = oli.Related_QLI__r.Number_of_Pulls__c;// Asset Usage Details
                Newassets.No_of_PAN_Verification_with_Father_Name__c = oli.Related_QLI__r.No_of_PAN_Verification_with_Father_Name__c;// Asset Usage Details - Identity
                /** Added By Niraj CDC Applicable END**/
                
                //Pramodh Ended Syncing Fields
                //Added by Raksha
                if(oli.Product2.Product_category__c == ProductConstants.PRODUCT_CATEGORY_INTEGRATION){
                    if(oli.Product2.Product_Line__c.equals('Invoice Discounting')){  
                        Newassets.RecordTypeId = AssetConstants.ASSET_INTEGRATIONID_RECORDTYPEID;
                    }
                    else{
                        Newassets.RecordTypeId = AssetConstants.ASSET_INTEGRATION_RECORDTYPEID;
                    }
                }else If(oli.Product2.Product_category__c == ProductConstants.PRODUCT_CATEGORY_SETUPONBOARDING){
                    Newassets.RecordTypeId = AssetConstants.ASSET_ONETIMEASSET_RECORDTYPEID;
                }else If(oli.Product2.Product_Category__c == 'AMC'){
                    Newassets.RecordTypeId = AssetConstants.ASSET_INTEGRATION_RECORDTYPEID;
                }else{
                    if(oli.Product2.Product_Line__c.equals('Invoice Discounting') && (oli.Product2.Product_Category__c.equals('SaaS') || oli.Product2.Product_Category__c.equals('Transactional'))){
                        Newassets.RecordTypeId = AssetConstants.ASSET_LICENSEID_RECORDTYPEID;
                    }
                    else{
                        Newassets.RecordTypeId = AssetConstants.ASSET_LICENSE_RECORDTYPEID;
                    }
                    if(oli.Opportunity.RecordTypeId == OpportunityConstants.RECORDTYPEID_RENEWAL){
                        Newassets.Onboarding_Status__c = OrderItemConstants.STATUS_ONBOARDING_NOT_REQUIRED;
                    }else{
                        Newassets.Onboarding_Status__c = OrderItemConstants.STATUS_ONBOARDING_PENDING;
                    }
                }
                if(oli.MarkUp__c != null){
                    Newassets.MarkUp__c = oli.MarkUp__c;
                }
                if(oli.Discount != null){
                    Newassets.Discount__c = oli.Discount; 
                }
                
                /** GCC - Quote Params */
                if(oli.Opportunity.Country_of_Origin__c != 'India' && !String.ISBLANK(oli.Opportunity.Country_of_Origin__c)){
                    Newassets.No_of_VAT__c 				= oli.Opportunity.SyncedQuote.No_of_VAT__c; 
                    Newassets.License_no_of_userids__c 	= oli.Opportunity.SyncedQuote.No_of_User_ID_one__c;
                    Newassets.POS_system__c  			= oli.Opportunity.SyncedQuote.POS_system__c ;
                    Newassets.ERP_GCC__c   				= oli.Opportunity.SyncedQuote.ERP_GCC__c;
                    Newassets.No_of_Online_devices__c 	= oli.Opportunity.SyncedQuote.No_of_Online_devices__c;
                    Newassets.No_of_Offline_devices__c 	= oli.Opportunity.SyncedQuote.No_of_Offline_devices__c;
                    Newassets.License_B2B_SalesInvoice_per_year__c = oli.Opportunity.SyncedQuote.BtoB_Sales_one__c;
                    Newassets.License_B2C_SalesInvoice_per_year__c = oli.Opportunity.SyncedQuote.BtoC_Sales_one__c;
                    Newassets.No_of_retail_stores__c = oli.Opportunity.SyncedQuote.No_of_retail_stores__c;
                }
                
                update Newassets;
                
                AssetConstants.isFirstTimeAdditionalGstin = FALSE;
                
                if(additionalGstin.size()>0){
                    update additionalGstin[0];
                }
                
                AssetConstants.isFirstTimeAdditionalGstin = TRUE;
                
                //Temp Code Need to replace with best practice End
            } else {
                new CTX_SyncQLIDetailsToAssetException('No Related Asset found');
            }
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
}