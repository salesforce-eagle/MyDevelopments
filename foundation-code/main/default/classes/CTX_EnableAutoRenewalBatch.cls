public class CTX_EnableAutoRenewalBatch implements Database.Batchable<sObject>, Schedulable{
    Public string queryString;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String numberOfDays = System.Label.CTX_EnableAutoRenewalDate;
        Date assetWillExpireIn3Months=System.today() + Integer.valueOf(numberOfDays);
        
        String productLine = 'E-invoicing & E-Way Bill';
        
        Integer limitSOQL= integer.valueOf(label.limitSOQL);
        
        List<String> applicableStatus = System.Label.CTX_AutoRenewAssetStatus.split(',');
        
        queryString = 'SELECT Id, Name, License_ID__c,Account.Is_Auto_Renewal_Enabled__c, Product2.Plan_Tier__c,PurchaseDate,UsageEndDate,Price,';
        queryString+= 'Number_of_eway_bill__c,License_no_of_gstins__c,License_no_of_irns_per_year__c,License_no_of_pans__c ,License_no_of_userids__c ,';
        queryString+=  'Account.Owner.Name,Account.Owner.Email,Account.Owner.Phone,OwnerId, BackEndQuote__c,Account.Country_of_Origin__c,Account.ParentId,';
        queryString+=  'Account.Onboarding_Owner__c,Account.Onboarding_Owner__r.Email,Account.Onboarding_Owner__r.Phone,Product2.IsActive,CurrencyIsoCode,';
        queryString+=  'Account.Onboarding_Owner__r.ManagerId,Account.Onboarding_Owner__r.Manager.Email,Account.Onboarding_Owner__r.Manager.Phone,BackEndQuoteDiscount__c,';
        queryString+=  'Account.Onboarding_Owner__r.Manager.ManagerId,Account.Onboarding_Owner__r.Manager.Manager.Email,Account.Onboarding_Owner__r.Manager.Manager.Phone,';
        queryString+=  'Opportunity__r.Billing_Address__c,Opportunity__r.Billing_GST__c ,Opportunity__r.Legal_Entity_Name_Of_The_Client__c , Payment_Method__c,';
        queryString+=  'Renewal_Opportunity__c, Account.Name, Account.Account_Number__c, Account.Bank_Branch__c, Account.Bank_IFSC_Code__c , Account.Bank_Name__c,';
        queryString+=  'Account.Bank_Swift_Code__c, Renewal_Opportunity__r.E_Sign_Customer_Info__c, AccountId,Opportunity__r.Shipping_Address__c, Opportunity__r.State_2__c,'; 
        queryString+=  'Opportunity__r.E_Sign_Customer_Info__r.Name,Opportunity__r.E_Sign_Customer_Info__r.Email,Opportunity__r.E_Sign_Customer_Info__r.Phone, ';
        queryString+=  'Renewal_Opportunity__r.Billing_GST__c,Renewal_Opportunity__r.Billing_Address__c ,Renewal_Opportunity__r.Shipping_Address__c, ';
        queryString+=  'Renewal_Opportunity__r.State_2__c, Renewal_Opportunity__r.Legal_Entity_Name_Of_The_Client__c ';
        queryString+=  'FROM Asset WHERE Account.Is_Auto_Renewal_Enabled__c = TRUE AND Product2.Product_Line__c =:productLine AND License_ID__c != NULL AND Status IN :applicableStatus AND UsageEndDate = :assetWillExpireIn3Months ORDER BY UsageEndDate  ASC limit '+limitSOQL;
        
        System.debug('@queryString'+queryString);
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        
        Map<Id, Asset> astMapToEnableAutoRenew 			= new  Map<Id, Asset>();
        Map<String, String> assetAccountMap				= new Map<String, String>();
        List<Asset> createRenewalOpp 					= new List<Asset>();
        
        if(scope.size() > 0){
            for(Asset thisRec : (List<Asset>) scope){
                astMapToEnableAutoRenew.put(thisRec.Id, thisRec);               
                assetAccountMap.put(thisRec.License_ID__c, thisRec.AccountId);
            }
            
            CTX_AutoRenewalFlag.enableAutoRenewal(astMapToEnableAutoRenew, assetAccountMap);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
        
    }
    
    
    public void execute(SchedulableContext sc){
        database.executeBatch(new CTX_EnableAutoRenewalBatch(), 50);
    }
}