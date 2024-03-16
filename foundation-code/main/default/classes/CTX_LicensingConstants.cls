/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_LicensingConstants {
    
    /**	Licensing Queries **/
    PUBLIC STATIC FINAL STRING LICENSEACTIVATIONQUERY 						= ' Id, Name, AccountId, Opportunity__c, ParentId, Billing_Type__c, Quantity, Price, Account_PAN__c, Status, Payment_Term__c, Payment_Method__c, License_ID__c, PurchaseDate, UsageEndDate, License_no_of_gstins__c, License_no_of_pans__c, License_no_of_userids__c, No_of_Vendor__c, ERP__c, License_B2B_SalesInvoice_per_year__c, No_of_VAT__c, No_of_Online_devices__c, No_of_Offline_devices__c, Number_of_Purchase_Invoice__c, Number_of_eway_bill__c, No_of_airline_invoices__c, License_B2C_SalesInvoice_per_year__c, Type_of_Integration__c, Type_of_Integration_QLI__c, License_no_of_total_Sales_Invoices__c, License_no_of_irns_per_year__c, License_no_of_invoice_formats__c, License_No_of_MM2A_2B_usage_GSTIN_mon__c, License_no_of_Recon__c, No_of_expected_B2C_invoices_for_QR_code__c, Workspace_Details__c, CDC_Applicable__c, Master_Email__c, Product_Name_Formula__c, Platform__c, Product_Line__c, Is_Test_Asset__c, Days_to_Extend__c, No_of_PAN_verification_API_old__c, Parent.License_Id__c, Account_Record_Type__c, Account.Master_admin_Email__c, Account.Product_Email__c, Account.Org_Unit_ID__c, Account.Name, Account.Country_of_Origin__c, Account.IsTestAccount__c, Opportunity__r.Name, Opportunity__r.Billing_Frequency__c, Opportunity__r.Billing_F__c, Opportunity__r.Billing_Method__c, Product2.Plan_Tier__c, Product2.Product_Plan_Id__c, Product2.Is_Standard__c, Product2.Family, Product2.ProductCode, Product2.Constraint_JSON__c, Product2.Saas_Product__c, Number_of_pulls__c, Number_of_TANs__c, Number_of_Deduction_Transactions_per_Qua__c, GSTIN_Level_Recon__c, PAN_Level_Recon__c, Data_Archival__c, Auto_Retry__c, Translation__c, Identity_Resource_Constraints__c, Account.Onboarding_Owner__c,Account.Onboarding_Owner__r.Email,Account.Onboarding_Owner__r.Phone,Product2.IsActive,CurrencyIsoCode, Account.Onboarding_Owner__r.ManagerId,Account.Onboarding_Owner__r.Manager.Email,Account.Onboarding_Owner__r.Manager.Phone,BackEndQuoteDiscount__c, Account.Onboarding_Owner__r.Manager.ManagerId,Account.Onboarding_Owner__r.Manager.Manager.Email,Account.Onboarding_Owner__r.Manager.Manager.Phone, Account.Owner.Name,Account.Owner.Email,Account.Owner.Phone,OwnerId, Account.Owner.Manager.Email,  Account.Owner.Manager.Manager.Email  ' ;

    PUBLIC STATIC FINAL STRING CLEAR_IDENTITY_METERING_PARAMETER			= ' ONBOARDED_PARTNERS__c, PARTNER_COMPLIANCE_VALIDATIONS__c, No_of_Bank_verification_API__c, No_of_MCA_Company_details_API__c, No_of_CUSTOMER_IDENTITY_FETCH_APIs__c, No_of_DRIVING_LICENSE_DETAILED_APIs__c, EPFO_ESTABLISHMENT_ADVANCED_API_credit__c, EPFO_ESTABLISHMENT_BASIC_API_credit__c, EPFO_ESTABLISHMENT_DETAILED_API_credit__c, No_of_EPFO_UAN_AUTH_APIs__c, No_of_EPFO_UAN_DETAILS_APIs__c, No_of_EPFO_UAN_FETCH_APIs__c, No_Of_GST_ADVANCED_APIs__c, No_Of_GST_ADVANCED_PLUS_APIs__c, No_of_GSTIN_FILING_CREDITS_APIs__c, No_of_GSTIN_SEARCH_BY_NAME_APIs__c, License_no_of_gstin_verification_credits__c, No_of_PAN_verification_detailed_APIs__c, No_Of_PAN_OCR_APIs__c, No_of_PAN_to_GSTIN_APIs__c, No_of_PAN_verification_API__c, No_of_PAN_Verification_with_Father_Name__c, No_of_TDS_206_sync_API__c, No_of_MSME_API__c, No_of_VEHICLE_REGISTRATION_DETAILED_API__c ';
      
    /**	Opportunity Helper - Asset Creation Queries **/
    PUBLIC STATIC FINAL STRING OPPORTUNITYLINITEME_OPPORTUNITYHELPER_QUERY 	= ' Id, Name,Related_QLI__r.No_of_B2B_Invoices_per_GSTIN__c,  Related_QLI__r.Transaction_Ref_No_To_be_moved_to_Opp__c, ProductCode, Quantity, PricebookEntry.Product2Id, Product2.SaaS_Product__c, PricebookEntry.Product2.Name, PricebookEntry.Product2.Plan_Tier__c, PricebookEntryId, UnitPrice, Product2.Family, Product2.Product_category__c, Sale_Price__c, Description, OpportunityId, Opportunity.AccountId, Opportunity.Country_of_Origin__c, Opportunity.Account.OwnerId, Opportunity.SyncedQuoteId, Opportunity.CloseDate, Opportunity.Period_Start_date__c, CurrencyIsoCode, Opportunity.Period_End_date__c, PO_End_Month__c, Period_End_date__c, Period_Start_date__c, Opportunity.Payment_method__c, Opportunity.Payment_term__c, Opportunity.RecordTypeId, MarkUp__c, Discount, Opportunity.LeadSource, Opportunity.One_to_Many_Type__c, Opportunity.Anchor_Companys__c, Product2.Product_Line__c, Type_Of_Integration__c, Stage_in_MY__c, SOW_Start_Date__c, SOW_End_Date__c, Total_Price__c, Opportunity.platform__c, Related_QLI__r.BtoB_Sales_one__c, Related_QLI__r.BtoC_Sales_one__c, Related_QLI__r.Flat_Transaction_Fee__c, Related_QLI__r.Number_of_Deductees_per_Quarter_24Q_26__c, Related_QLI__r.Number_of_Deduction_Transactions_per_Qua__c, Related_QLI__r.No_of_EWBs__c, Related_QLI__r.No_of_expected_B2C_invoices_for_QR_code__c, Related_QLI__r.No_of_GST_GSP_API_calls_permissible__c, Related_QLI__r.No_of_GSTIN_one__c, Related_QLI__r.No_of_invoice_formats__c, Related_QLI__r.No_of_IRNs__c, Related_QLI__r.No_of_PAN_one__c, Related_QLI__r.No_of_recons__c, Related_QLI__r.No_of_TANs__c, Related_QLI__r.No_of_Total_invoices__c, Related_QLI__r.No_of_User_ID_one__c, Related_QLI__r.No_of_Vendors_one__c, Related_QLI__r.No_of_airline_invoices_annual_one__c, Related_QLI__r.Number_of_eway_bill__c, Related_QLI__r.Partner_Count_for_GeEr_up_Reports__c, Related_QLI__r.Purchases_Invoices_one__c, Related_QLI__r.Tally_Connector_required__c, Related_QLI__r.Transaction_Fee_Slab_1__c, Related_QLI__r.Type_of_Compliance_service__c, Related_QLI__r.platform__c, Related_QLI__r.No_MM2A_2B_usage_GSTIN_month__c, Related_QLI__r.Type_of_Integration__c, Related_QLI__r.No_of_API_calls_permissible__c, Related_QLI__r.Digital_Signing_Utility_for_TDS_Cert_del__c, Related_QLI__r.Total_B2B_PR_B2C_invoice__c, Related_QLI__r.POS_system__c, Related_QLI__r.No_of_retail_stores__c, Related_QLI__r.CDC_Applicable__c, Related_QLI__r.Number_of_Pulls__c, Related_QLI__r.OTP_SKUs__c, Related_QLI__r.No_of_fields_to_be_edited_per_template__c, Related_QLI__r.No_of_templates__c, Related_QLI__r.Total_no_of_Pages_in_Purchase_Invoices__c, Related_QLI__r.GSTIN_Level_Recon__c, Related_QLI__r.PAN_Level_Recon__c ';
    PUBLIC STATIC FINAL STRING CLEAR_IDENTITY_METERING_PARAMETER_OPPLNE		= ' Related_QLI__r.Identity_Resource_Constraints__c, Related_QLI__r.Identity_Resource_Metadata__c, Related_QLI__r.ONBOARDED_PARTNERS__c, Related_QLI__r.PARTNER_COMPLIANCE_VALIDATIONS__c, Related_QLI__r.No_of_Bank_verification_API__c, Related_QLI__r.No_of_MCA_Company_details_API__c, Related_QLI__r.No_of_CUSTOMER_IDENTITY_FETCH_APIs__c, Related_QLI__r.No_of_DRIVING_LICENSE_DETAILED_APIs__c, Related_QLI__r.EPFO_ESTABLISHMENT_ADVANCED_API_credit__c, Related_QLI__r.EPFO_ESTABLISHMENT_BASIC_API_credit__c, Related_QLI__r.EPFO_ESTABLISHMENT_DETAILED_API_credit__c, Related_QLI__r.No_of_EPFO_UAN_AUTH_APIs__c, Related_QLI__r.No_of_EPFO_UAN_DETAILS_APIs__c, Related_QLI__r.No_of_EPFO_UAN_FETCH_APIs__c, Related_QLI__r.No_Of_GST_ADVANCED_APIs__c, Related_QLI__r.No_Of_GST_ADVANCED_PLUS_APIs__c, Related_QLI__r.No_of_GSTIN_FILING_CREDITS_APIs__c, Related_QLI__r.No_of_GSTIN_SEARCH_BY_NAME_APIs__c, Related_QLI__r.No_of_GSTIN_verification_credits__c, Related_QLI__r.No_of_PAN_verification_detailed_APIs__c, Related_QLI__r.No_Of_PAN_OCR_APIs__c, Related_QLI__r.No_of_PAN_to_GSTIN_APIs__c, Related_QLI__r.No_of_PAN_verification_API__c, Related_QLI__r.No_of_PAN_Verification_with_Father_Name__c, Related_QLI__r.No_of_TDS_206_sync_API__c, Related_QLI__r.No_of_MSME_API__c, Related_QLI__r.No_of_VEHICLE_REGISTRATION_DETAILED_API__c, Related_QLI__r.No_of_PAN_SIMPLE_DETAILS_APIs_No_of_FS__c, Related_QLI__r.No_of_FSSAI_VERIFICATION_APIs__c, Related_QLI__r.No_of_PAN_VERIFICATION_BASIC_APIs__c, Related_QLI__r.No_of_GST_ANALYTICS_AUTH_APIs__c, Related_QLI__r.No_of_GST_ANALYTICS_DETAILS_APIs__c, Related_QLI__r.No_of_INTERNATIONAL_BUSINESS_NAME_SEARC__c, Related_QLI__r.No_of_LEGAL_NAME_PAN_FETCH_APIs__c, Related_QLI__r.No_of_GST_OWNERSHIP_VERIFICATION_APIs__c, Related_QLI__r.No_of_AADHAAR_VERIFICATION_DIGILOCKER_A__c, Related_QLI__r.No_of_COMPANY_FINANCIALS_DETAILS_APIs__c, Related_QLI__r.No_of_UPI_VERIFICATION_APIs__c, Related_QLI__r.No_of_UPI_FETCH_APIs__c, Related_QLI__r.No_of_UPI_QR_GENERATION_APIs__c, Related_QLI__r.No_of_COMPANY_DETAILS_FULL_APIs__c, Related_QLI__r.No_of_EPFO_UAN_VERIFICATION_APIs__c, Related_QLI__r.No_of_OTP_VERIFICATION_PHONE_APIs__c, Related_QLI__r.No_of_OTP_VERIFICATION_EMAIL_APIs__c, Related_QLI__r.No_of_EINVOICE_QR_EXTRACTION_APIs__c, Related_QLI__r.No_of_EINVOICE_IRN_DETAILS_APIs__c, Related_QLI__r.No_of_UNREGISTERED_GST_APPLICANT_DETAIL__c, Related_QLI__r.No_of_UNREGISTERED_GST_APPLICANT_VERIFI__c, Related_QLI__r.No_of_HSN_SAC_SEARCH_APIs__c, Related_QLI__r.No_of_EINVOICE_INBOUND_DETAILS_APIs__c, Related_QLI__r.No_of_AADHAAR_DEMOGRAPHICS_FETCH_APIs__c, Related_QLI__r.No_of_COMPANY_DOCUMENTS_FETCH_APIs__c ';
    
    /**	Sync Quote - Opportunity Helper Queries **/
    PUBLIC STATIC FINAL STRING SYNCQUOTE_OPPORTUNITYHELPER_QUERY 			= ' BtoB_Sales__c,BtoC_Sales_one__c,BtoB_Sales_one__c,No_of_GSTIN_one__c,No_of_PAN_one__c,No_of_User_ID_one__c, No_of_Vendors_one__c,No_of_airline_invoices_annual_one__c, Purchases_Invoices_one__c,Turnover_one__c,BtoC_Sales__c, Category_of_Company__c, ERP__c, Existing_Vendor__c, No_of_GSTIN__c, No_of_PAN__c, No_of_User_ID__c, No_of_Vendors__c, No_of_airline_invoices_annual__c, No_of_airlines__c, Purchases_Invoices__c, Turnover__c, Type_of_Integration__c, Zone__c, Number_of_eway_bill__c, Number_of_Sales_Invoices__c,Opportunity.LeadSource,Opportunity.One_to_Many_Type__c,Opportunity.Anchor_Companys__c, No_of_expected_B2C_invoices_for_QR_code__c, No_of_recons__c, No_MM2A_2B_usage_GSTIN_month__c, No_of_IRNs__c, No_of_GSTIN_verification_credits__c, No_of_invoice_formats__c, No_of_EWBs__c,No_of_TANs__c, Number_of_Deductees_per_Quarter_24Q_26__c, Number_of_Deduction_Transactions_per_Qua__c,Digital_Signing_Utility_for_TDS_Certific__c,Partner_Count_for_GeEr_up_Reports__c, Monthly_throughput_Slab_1_Cr__c,Flat_Transaction_Fee__c ,Monthly_throughput_Slab_2_Cr__c ,Monthly_throughput_Slab_3_Cr__c, Transaction_Fee_Slab_1__c, Transaction_Fee_Slab_2__c , Transaction_Fee_Slab_3__c,Tally_Connector_required__c,Total_annual_domestic_payables_Rs_Cr__c, No_of_Bank_verification_API__c, No_of_API_calls_permissible__c, No_of_MCA_Company_details_API__c, No_of_MSME_API__c, No_of_PAN_verification_API__c, No_of_TDS_206_sync_API__c,ERP_GCC__c, No_of_Online_devices__c, No_of_Offline_devices__c, No_of_Customised_Invoice_Print_template__c, No_of_VAT__c, POS_system__c,No_of_retail_stores__c, Data_Archival__c, Auto_Retry__c, Translation__c ';
    
    
    /** Identity for QuoteLineItem **/
    //PUBLIC STATIC FINAL STRING IDENTITY_RESOURCE_CONSTRAINTS_FOR_QUOTE      = ' [{" EPFO_ESTABLISHMENT_ADVANCED_API_credit__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" EPFO_ESTABLISHMENT_BASIC_API_credit__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" EPFO_ESTABLISHMENT_DETAILED_API_credit__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_AADHAAR_DEMOGRAPHICS_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_AADHAAR_VERIFICATION_DIGILOCKER_A__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_AGGREGATED_ONBOARDING_VERIFICATION__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_Bank_verification_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_COMPANY_DETAILS_FULL_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_COMPANY_DOCUMENTS_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_COMPANY_FINANCIALS_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_CUSTOMER_IDENTITY_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_DRIVING_LICENSE_DETAILED_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EINVOICE_INBOUND_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EINVOICE_IRN_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EINVOICE_QR_EXTRACTION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_AUTH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_VERIFICATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_FSSAI_VERIFICATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSP_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_Of_GST_ADVANCED_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_Of_GST_ADVANCED_PLUS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GST_ANALYTICS_AUTH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GST_ANALYTICS_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GST_OWNERSHIP_VERIFICATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSTIN_FILING_CREDITS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSTIN_SEARCH_BY_NAME_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSTIN_verification_credits__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_HSN_SAC_SEARCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_INGESTION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_INTERNATIONAL_BUSINESS_NAME_SEARC__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_LEGAL_NAME_PAN_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_MCA_Company_details_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_MSME_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_OTP_VERIFICATION_EMAIL_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_OTP_VERIFICATION_PHONE_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_Of_PAN_OCR_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_SIMPLE_DETAILS_APIs_No_of_FS__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_to_GSTIN_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_verification_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_verification_API_QR__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_VERIFICATION_BASIC_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_verification_detailed_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_Verification_with_Father_Name__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_TDS_206_sync_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UNREGISTERED_GST_APPLICANT_DETAIL__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UNREGISTERED_GST_APPLICANT_VERIFI__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UPI_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UPI_QR_GENERATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UPI_VERIFICATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_VALIDATE_OTP_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_VEHICLE_REGISTRATION_DETAILED_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}}] ';
   
    PUBLIC STATIC FINAL STRING IDENTITY_RESOURCE_CONSTRAINTS_FOR_QUOTE      = '  [{" EPFO_ESTABLISHMENT_ADVANCED_API_credit__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" EPFO_ESTABLISHMENT_BASIC_API_credit__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" EPFO_ESTABLISHMENT_DETAILED_API_credit__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_AADHAAR_VERIFICATION_DIGILOCKER_A__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_Bank_verification_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_COMPANY_DETAILS_FULL_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_COMPANY_FINANCIALS_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_CUSTOMER_IDENTITY_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_DRIVING_LICENSE_DETAILED_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EINVOICE_IRN_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EINVOICE_QR_EXTRACTION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_AUTH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EINVOICE_IRN_LIST_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_FSSAI_VERIFICATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSP_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_Of_GST_ADVANCED_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_Of_GST_ADVANCED_PLUS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GST_ANALYTICS_AUTH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GST_ANALYTICS_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GST_OWNERSHIP_VERIFICATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSTIN_FILING_CREDITS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSTIN_SEARCH_BY_NAME_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSTIN_verification_credits__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_HSN_SAC_SEARCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_INGESTION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_INTERNATIONAL_BUSINESS_NAME_SEARC__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_LEGAL_NAME_PAN_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_MCA_Company_details_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_MSME_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_OTP_VERIFICATION_EMAIL_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_OTP_VERIFICATION_PHONE_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_Of_PAN_OCR_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_SIMPLE_DETAILS_APIs_No_of_FS__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_to_GSTIN_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_verification_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_verification_API_QR__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_VERIFICATION_BASIC_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_verification_detailed_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_Verification_with_Father_Name__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_TDS_206_sync_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UNREGISTERED_GST_APPLICANT_DETAIL__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UNREGISTERED_GST_APPLICANT_VERIFI__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UPI_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UPI_QR_GENERATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UPI_VERIFICATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_VEHICLE_REGISTRATION_DETAILED_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}}] ';
   // PUBLIC STATIC FINAL STRING IDENTITY_RESOURCE_CONSTRAINTS_FOR_QUOTE      = ' [{" EPFO_ESTABLISHMENT_ADVANCED_API_credit__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" EPFO_ESTABLISHMENT_BASIC_API_credit__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" EPFO_ESTABLISHMENT_DETAILED_API_credit__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_Bank_verification_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_COMPANY_DETAILS_FULL_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_COMPANY_FINANCIALS_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_CUSTOMER_IDENTITY_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_DRIVING_LICENSE_DETAILED_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EINVOICE_IRN_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EINVOICE_QR_EXTRACTION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_AUTH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EINVOICE_IRN_LIST_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_FSSAI_VERIFICATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSP_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_Of_GST_ADVANCED_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_Of_GST_ADVANCED_PLUS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GST_ANALYTICS_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GST_OWNERSHIP_VERIFICATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSTIN_FILING_CREDITS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSTIN_SEARCH_BY_NAME_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSTIN_verification_credits__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_HSN_SAC_SEARCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_INTERNATIONAL_BUSINESS_NAME_SEARC__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_LEGAL_NAME_PAN_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_MCA_Company_details_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_MSME_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_OTP_VERIFICATION_EMAIL_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_OTP_VERIFICATION_PHONE_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_Of_PAN_OCR_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_SIMPLE_DETAILS_APIs_No_of_FS__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_to_GSTIN_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_verification_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_verification_API_QR__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_VERIFICATION_BASIC_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_verification_detailed_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_Verification_with_Father_Name__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_TDS_206_sync_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UNREGISTERED_GST_APPLICANT_DETAIL__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UNREGISTERED_GST_APPLICANT_VERIFI__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_UPI_VERIFICATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_VEHICLE_REGISTRATION_DETAILED_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}}]';
    /**	Identity Resources for Asset	**/
//	PUBLIC STATIC FINAL STRING IDENTITY_FINAL_RESOURCE_DETAILS_BY_COUNT	    = ' {"EPFO_ESTABLISHMENT_ADVANCED_API_credit__c":0,"EPFO_ESTABLISHMENT_BASIC_API_credit__c":0,"EPFO_ESTABLISHMENT_DETAILED_API_credit__c":0,"No_of_AADHAAR_DEMOGRAPHICS_FETCH_APIs__c":0,"No_of_AADHAAR_VERIFICATION_DIGILOCKER_A__c":0,"No_of_AGGREGATED_ONBOARDING_VERIFICATION__c":0,"No_of_Bank_verification_API__c":0,"No_of_COMPANY_DETAILS_FULL_APIs__c":0,"No_of_COMPANY_DOCUMENTS_FETCH_APIs__c":0,"No_of_COMPANY_FINANCIALS_DETAILS_APIs__c":0,"No_of_CUSTOMER_IDENTITY_FETCH_APIs__c":0,"No_of_DRIVING_LICENSE_DETAILED_APIs__c":0,"No_of_EINVOICE_INBOUND_DETAILS_APIs__c":0,"No_of_EINVOICE_IRN_DETAILS_APIs__c":0,"No_of_EINVOICE_QR_EXTRACTION_APIs__c":0,"No_of_EPFO_UAN_AUTH_APIs__c":0,"No_of_EPFO_UAN_DETAILS_APIs__c":0,"No_of_EPFO_UAN_FETCH_APIs__c":0,"No_of_EPFO_UAN_VERIFICATION_APIs__c":0,"No_of_FSSAI_VERIFICATION_APIs__c":0,"No_of_GSP_APIs__c":0,"No_Of_GST_ADVANCED_APIs__c":0,"No_Of_GST_ADVANCED_PLUS_APIs__c":0,"No_of_GST_ANALYTICS_AUTH_APIs__c":0,"No_of_GST_ANALYTICS_DETAILS_APIs__c":0,"No_of_GST_OWNERSHIP_VERIFICATION_APIs__c":0,"No_of_GSTIN_FILING_CREDITS_APIs__c":0,"No_of_GSTIN_SEARCH_BY_NAME_APIs__c":0,"No_of_GSTIN_verification_credits__c":0,"No_of_HSN_SAC_SEARCH_APIs__c":0,"No_of_INGESTION_APIs__c":0,"No_of_INTERNATIONAL_BUSINESS_NAME_SEARC__c":0,"No_of_LEGAL_NAME_PAN_FETCH_APIs__c":0,"No_of_MCA_Company_details_API__c":0,"No_of_MSME_API__c":0,"No_of_OTP_VERIFICATION_EMAIL_APIs__c":0,"No_of_OTP_VERIFICATION_PHONE_APIs__c":0,"No_Of_PAN_OCR_APIs__c":0,"No_of_PAN_SIMPLE_DETAILS_APIs_No_of_FS__c":0,"No_of_PAN_to_GSTIN_APIs__c":0,"No_of_PAN_verification_API__c":0,"No_of_PAN_verification_API_QR__c":0,"No_of_PAN_VERIFICATION_BASIC_APIs__c":0,"No_of_PAN_verification_detailed_APIs__c":0,"No_of_PAN_Verification_with_Father_Name__c":0,"No_of_TDS_206_sync_API__c":0,"No_of_UNREGISTERED_GST_APPLICANT_DETAIL__c":0,"No_of_UNREGISTERED_GST_APPLICANT_VERIFI__c":0,"No_of_UPI_FETCH_APIs__c":0,"No_of_UPI_QR_GENERATION_APIs__c":0,"No_of_UPI_VERIFICATION_APIs__c":0,"No_of_VALIDATE_OTP_APIs__c":0,"No_of_VEHICLE_REGISTRATION_DETAILED_API__c":0} ';
    
    PUBLIC STATIC FINAL STRING IDENTITY_FINAL_RESOURCE_DETAILS_BY_COUNT	    = ' {"EPFO_ESTABLISHMENT_ADVANCED_API_credit__c":0,"EPFO_ESTABLISHMENT_BASIC_API_credit__c":0,"EPFO_ESTABLISHMENT_DETAILED_API_credit__c":0,"No_of_AADHAAR_VERIFICATION_DIGILOCKER_A__c":0,"No_of_Bank_verification_API__c":0,"No_of_COMPANY_DETAILS_FULL_APIs__c":0,"No_of_COMPANY_FINANCIALS_DETAILS_APIs__c":0,"No_of_CUSTOMER_IDENTITY_FETCH_APIs__c":0,"No_of_DRIVING_LICENSE_DETAILED_APIs__c":0,"No_of_EINVOICE_IRN_DETAILS_APIs__c":0,"No_of_EINVOICE_QR_EXTRACTION_APIs__c":0,"No_of_EPFO_UAN_AUTH_APIs__c":0,"No_of_EPFO_UAN_DETAILS_APIs__c":0,"No_of_EPFO_UAN_FETCH_APIs__c":0,"No_of_FSSAI_VERIFICATION_APIs__c":0,"No_of_GSP_APIs__c":0,"No_Of_GST_ADVANCED_APIs__c":0,"No_Of_GST_ADVANCED_PLUS_APIs__c":0,"No_of_GST_ANALYTICS_AUTH_APIs__c":0,"No_of_GST_ANALYTICS_DETAILS_APIs__c":0,"No_of_GST_OWNERSHIP_VERIFICATION_APIs__c":0,"No_of_GSTIN_FILING_CREDITS_APIs__c":0,"No_of_GSTIN_SEARCH_BY_NAME_APIs__c":0,"No_of_GSTIN_verification_credits__c":0,"No_of_HSN_SAC_SEARCH_APIs__c":0,"No_of_INGESTION_APIs__c":0,"No_of_INTERNATIONAL_BUSINESS_NAME_SEARC__c":0,"No_of_LEGAL_NAME_PAN_FETCH_APIs__c":0,"No_of_MCA_Company_details_API__c":0,"No_of_MSME_API__c":0,"No_of_OTP_VERIFICATION_EMAIL_APIs__c":0,"No_of_OTP_VERIFICATION_PHONE_APIs__c":0,"No_Of_PAN_OCR_APIs__c":0,"No_of_PAN_SIMPLE_DETAILS_APIs_No_of_FS__c":0,"No_of_PAN_to_GSTIN_APIs__c":0,"No_of_PAN_verification_API__c":0,"No_of_PAN_verification_API_QR__c":0,"No_of_PAN_VERIFICATION_BASIC_APIs__c":0,"No_of_PAN_verification_detailed_APIs__c":0,"No_of_PAN_Verification_with_Father_Name__c":0,"No_of_TDS_206_sync_API__c":0,"No_of_UNREGISTERED_GST_APPLICANT_DETAIL__c":0,"No_of_UNREGISTERED_GST_APPLICANT_VERIFI__c":0,"No_of_UPI_FETCH_APIs__c":0,"No_of_UPI_QR_GENERATION_APIs__c":0,"No_of_UPI_VERIFICATION_APIs__c":0,"No_of_EINVOICE_IRN_LIST_APIs__c":0,"No_of_VEHICLE_REGISTRATION_DETAILED_API__c":0} ';
//	PUBLIC STATIC FINAL STRING IDENTITY_FINAL_RESOURCE_DETAILS_BY_COUNT	 = ' {"EPFO_ESTABLISHMENT_ADVANCED_API_credit__c":0,"EPFO_ESTABLISHMENT_BASIC_API_credit__c":0,"EPFO_ESTABLISHMENT_DETAILED_API_credit__c":0,"No_of_Bank_verification_API__c":0,"No_of_COMPANY_DETAILS_FULL_APIs__c":0,"No_of_COMPANY_FINANCIALS_DETAILS_APIs__c":0,"No_of_CUSTOMER_IDENTITY_FETCH_APIs__c":0,"No_of_DRIVING_LICENSE_DETAILED_APIs__c":0,"No_of_EINVOICE_IRN_DETAILS_APIs__c":0,"No_of_EINVOICE_QR_EXTRACTION_APIs__c":0,"No_of_EPFO_UAN_AUTH_APIs__c":0,"No_of_EPFO_UAN_DETAILS_APIs__c":0,"No_of_EPFO_UAN_FETCH_APIs__c":0,"No_of_FSSAI_VERIFICATION_APIs__c":0,"No_of_GSP_APIs__c":0,"No_Of_GST_ADVANCED_APIs__c":0,"No_Of_GST_ADVANCED_PLUS_APIs__c":0,"No_of_GST_ANALYTICS_DETAILS_APIs__c":0,"No_of_GST_OWNERSHIP_VERIFICATION_APIs__c":0,"No_of_GSTIN_FILING_CREDITS_APIs__c":0,"No_of_GSTIN_SEARCH_BY_NAME_APIs__c":0,"No_of_GSTIN_verification_credits__c":0,"No_of_HSN_SAC_SEARCH_APIs__c":0,"No_of_INTERNATIONAL_BUSINESS_NAME_SEARC__c":0,"No_of_LEGAL_NAME_PAN_FETCH_APIs__c":0,"No_of_MCA_Company_details_API__c":0,"No_of_MSME_API__c":0,"No_of_OTP_VERIFICATION_EMAIL_APIs__c":0,"No_of_OTP_VERIFICATION_PHONE_APIs__c":0,"No_Of_PAN_OCR_APIs__c":0,"No_of_PAN_SIMPLE_DETAILS_APIs_No_of_FS__c":0,"No_of_PAN_to_GSTIN_APIs__c":0,"No_of_PAN_verification_API__c":0,"No_of_PAN_verification_API_QR__c":0,"No_of_PAN_VERIFICATION_BASIC_APIs__c":0,"No_of_PAN_verification_detailed_APIs__c":0,"No_of_PAN_Verification_with_Father_Name__c":0,"No_of_TDS_206_sync_API__c":0,"No_of_UNREGISTERED_GST_APPLICANT_DETAIL__c":0,"No_of_UNREGISTERED_GST_APPLICANT_VERIFI__c":0,"No_of_UPI_VERIFICATION_APIs__c":0,"No_of_EINVOICE_IRN_LIST_APIs__c":0,"No_of_VEHICLE_REGISTRATION_DETAILED_API__c":0}';
}