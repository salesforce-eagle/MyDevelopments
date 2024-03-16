/** 
This code will accept the AssetId and isUpdate and based on the It will Create or Update the License
Input Parameters:
    1. Asset Id
    2. isUpdate
**/

String  AssetId;
Boolean isUpdate;

Map<Id, Asset>  assetMap    = new Map<Id, Asset>(
            [ SELECT Id, Name, AccountId, Opportunity__c, ParentId, Billing_Type__c, Quantity, Price, Account_PAN__c, Status, 
             Payment_Term__c, Payment_Method__c, License_ID__c, PurchaseDate, UsageEndDate, License_no_of_gstins__c, License_no_of_pans__c, License_no_of_userids__c, No_of_Vendor__c,ERP__c, License_B2B_SalesInvoice_per_year__c, Number_of_Purchase_Invoice__c, Number_of_eway_bill__c, No_of_airline_invoices__c, License_B2C_SalesInvoice_per_year__c, Type_of_Integration__c, Type_of_Integration_QLI__c, License_no_of_total_Sales_Invoices__c, License_no_of_irns_per_year__c, License_no_of_invoice_formats__c, License_no_of_gstin_verification_credits__c, License_No_of_MM2A_2B_usage_GSTIN_mon__c, License_no_of_Recon__c, No_of_expected_B2C_invoices_for_QR_code__c, Workspace_Details__c, Master_Email__c, Product_Name_Formula__c, Platform__c, Product_Line__c,
             Parent.License_Id__c, Account.Master_admin_Email__c, Account.Product_Email__c, Account.Org_Unit_ID__c, Account.Name, Account.Country_of_Origin__c, Account.IsTestAccount__c, Opportunity__r.Name, Opportunity__r.Billing_Frequency__c, Opportunity__r.Billing_F__c, Opportunity__r.Billing_Method__c, Product2.Plan_Tier__c, Product2.Product_Plan_Id__c, Product2.Is_Standard__c, Product2.Family, Product2.ProductCode, Product2.Constraint_JSON__c, Product2.Saas_Product__c 
             FROM Asset WHERE Id = '02iC50000006zC1IAI' ] );

CTX_UpsertAssetLicense.callout_UpsertAsset_API(assetMap, assetMap, new Map<Id, Boolean>{'02iC50000006qVoIAI' => TRUE}, NULL);
