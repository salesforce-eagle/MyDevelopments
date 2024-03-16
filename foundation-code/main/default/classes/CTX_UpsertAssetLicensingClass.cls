public class CTX_UpsertAssetLicensingClass {

    Public Class OutterWrapper{
        Public String				sfOpportunityId;
        Public String 				sfOrgName;
        Public Boolean 				isUpdate;
        Public Boolean				isTestLicense;
        Public String 				masterEmailID;
        Public String 				sfAccountId;
        public string				region;
        Public List<String>			workspaceIds;
        Public List<AssetWrapper>	assets;
        public CustomerSuccessManager   csm 				= new CustomerSuccessManager();
        public KeyAccountManager 	    kam 				= new KeyAccountManager();
        public Boolean				isApplicableForLicensingEmailer = FALSE;
    }
    
    public class CustomerSuccessManager {
        public string 		email;
        public string 		phone;
        public string 		managerEmail;
        public string 		superManagerEmail;
        
    }
    
    public class KeyAccountManager {
        public string 		name;
        public string 		email;
        public string 		phone;
        public string 		managerEmail;
        public string 		superManagerEmail;
    }
    
    Public Class AssetWrapper{
        Public String 							planTier;
        Public Boolean 							isCDCEnabled;
        Public Integer							assetEndDateEodInstant;
        Public Boolean 							customPlan;
        Public String 							licenseId;
        Public String 							assetId;
        Public DateTime	 						assetStartDate;
        Public DateTime	 						assetEndDate;
        Public String 							status;
        Public Decimal 							price;
        Public String 							Name;
        Public String 							planId;
        Public AssetMetadataWrapper 			metadata;
        Public AssetResourceConstraints 		sfResourceConstraints;
        Public AssetProductWrapper 				product;
        Public String 							saasProduct;
        Public List<ResourceConstraints>		resourceConstraints;
    }
    
    Public Class AssetMetadataWrapper{
        Public String	name;
        Public String 	description;
        Public String 	bannerText;
    }
    
    Public Class AssetResourceConstraints{
        Public Decimal noOfUserIds;
        Public Decimal noOfPurchaseInvoice;
        Public Decimal noOfPANs;
        Public Decimal noOfGSTINs;
        Public Decimal noOfEwayBill;
        Public Decimal noOfB2CSalesInvoice;
        Public Decimal noOfB2BSalesInvoice;
        Public Decimal noOfAirlineInvoices;
        Public Decimal License_no_of_total_Sales_Invoices;
        Public Decimal License_no_of_irns_per_year;
        Public Decimal License_no_of_invoice_formats;
        Public Decimal License_no_of_gstin_verification_credits;
        Public Decimal License_No_of_MM2A_2B_usage_GSTIN_mon;
        Public Decimal License_no_of_Recon;
        Public Decimal No_of_expected_B2C_invoices_for_QR_code;
    }
    
    Public Class AssetProductWrapper{
        Public String	productFamily;
        Public String 	productCode;
        Public String 	licenseProduct;
        Public Boolean 	isStandard;
    }
    
    Public Class ResourceConstraints{
        public String 	resource;
        public String 	constraintType;
        public Integer	threshold;
        public Boolean	isUsageTimeBound;
        public Boolean 	availability;
        public Boolean 	eligibleForNotification;
        Public Metadata metadata;
    }
    
    Public Class Metadata {
        Public String 	title;
        Public String	resourceTitle;
        Public String	displayText;
        Public Integer	displayPriority;
        Public Boolean	showOnSummaryPage;
        Public String	category;
        Public String	categoryDisplayText;
        
    }
   
    
}