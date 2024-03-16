public class WrapperCTX_ProductSync_Parse{
    
    Public List<Plans> 				plans 					= new List<Plans>();
    public List<ProductSFMapping> 	productSalesforceMappings {get;set;}
    
    public class Plans {
        public String updatedAt {get;set;} 
        public String createdAt {get;set;} 
        public String createdBy {get;set;} 
        public String updatedBy {get;set;} 
        public String planId {get;set;} 
        public String sfPlanName;
        public Metadata metadata {get;set;} 
        public String product {get;set;} 
        public Pricing pricing {get;set;} 
        public Boolean isDeprecated {get;set;} 
        public String planTier {get;set;} 
        public Boolean selfServeEligible {get;set;} 
        public List<Integer> extensionOrder {get;set;} 
        public String sku {get;set;} 
        public List<ResourceConstraints> resourceConstraints {get;set;} 
        public Integer durationInSeconds {get;set;} 
        public Integer shortExpiryDurationInSeconds {get;set;} 
        public Integer planTierOrdinal {get;set;} 
    }
    
    public class Metadata {
        public String name {get;set;} 
        public String description {get;set;} 
        public String bannerText {get;set;} 
        
    }
    public class Pricing {
        public String yearlyPrice {get;set;} 
        public String monthlyPrice {get;set;} 
        public String taxRate {get;set;} 
        public String monthlyTaxInclusivePrice {get;set;} 
        public String yearlyTaxInclusivePrice {get;set;} 
        
    }
    public class ResourceConstraints {
        public String updatedAt {get;set;} 
        public String createdAt {get;set;} 
        public String createdBy {get;set;} 
        public String updatedBy {get;set;} 
        public String resource {get;set;} 
        public String constraintType {get;set;}
        public String  Plan_Allowance_GSTIN  {get;set;}
        public String Plan_Allowance_PAN  {get;set;}
        public String Plan_Allowance_IRN  {get;set;}
        public String Plan_Topup_Threshold_GSTIN  {get;set;}
        public String Plan_Topup_Threshold_PAN  {get;set;}
        public String Plan_Topup_Threshold_IRN  {get;set;}
        public String Is_custom_allowed  {get;set;}
        public String threshold  {get;set;}
        
        public Boolean availability {get;set;} 
        public Boolean eligibleForNotification {get;set;} 
        public String resourceConstraintId {get;set;} 
        public Metadata_Z metadata {get;set;} 
        public String usageRuleResult {get;set;} 
        
    }
    public class Metadata_Z {
        public String title {get;set;} 
        public String resourceTitle {get;set;} 
        public String displayText {get;set;} 
        public Integer displayPriority {get;set;} 
        public Boolean showOnSummaryPage {get;set;} 
        public String category {get;set;} 
        public String categoryDisplayText {get;set;} 
        public Integer categoryDisplayPriority {get;set;} 
        
    }
    
    /**	Niraj Wrapper	**/
    public class ProductSFMapping {
        public String productName {get;set;}
        public String licensingProductName {get;set;}
        public String sfProductName {get;set;}
        public Boolean isCustomPlanAllowed {get;set;}
    }
    
}