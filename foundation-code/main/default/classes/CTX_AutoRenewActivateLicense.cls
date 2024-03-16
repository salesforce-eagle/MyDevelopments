public class CTX_AutoRenewActivateLicense {
    @AuraEnabled
    public static String autoRenewActivateLicense(Id billingId)  {
        String responseMessage = '';
        Map<String, Object> responseMap;
        Billing_Details__c billingDetails = [SELECT Id, Asset__c, Asset__r.Product2.Plan_Tier__c, Asset__r.License_ID__c, Asset__r.Parent.License_Id__c, Asset__r.Opportunity__c, Asset__r.ParentId
                                             FROM Billing_Details__c
                                             WHERE Id =:billingId];
        
        if(billingDetails != NULL){
            QuoteLineItem renewalQli = [ SELECT Id,Order_Details__c  
                                        FROM QuoteLineItem WHERE 
                                        Quote.OpportunityId  = :billingDetails.Asset__r.Opportunity__c AND  
                                       Product2.Plan_Tier__c =: billingDetails.Asset__r.Product2.Plan_Tier__c ];
            
            if(renewalQli != NULL){
                if(renewalQli.Order_Details__c != NULL){
                    CTX_AutoRenewLicenseHelper.PaymentWrapper paymentInfo = new CTX_AutoRenewLicenseHelper.PaymentWrapper();
                if(renewalQli.Order_Details__c != NULL)
                    paymentInfo = (CTX_AutoRenewLicenseHelper.PaymentWrapper)JSON.deserializeStrict(renewalQli.Order_Details__c, CTX_AutoRenewLicenseHelper.PaymentWrapper.Class);
                    paymentInfo.paymentMode = 'PAY_NOW';
                paymentInfo.previousLicense =  billingDetails.Asset__r.Parent.License_Id__c;
                    
                    Map<String, Product_Info_Metadata__mdt>	productPlanTierInfoMap		= new Map<String, Product_Info_Metadata__mdt>();
                    for( 
                Product_Info_Metadata__mdt thisRec : [ SELECT Id, MasterLabel, DeveloperName, Plan_Tier__c, Product_Id__c, Required_Fields__c 
                                                      FROM Product_Info_Metadata__mdt WHERE Plan_Tier__c =: billingDetails.Asset__r.Product2.Plan_Tier__c ] 
            ){
                productPlanTierInfoMap.put( thisRec.Plan_Tier__c, thisRec );
            }
                    
                    
                    HttpResponse response = CTX_AutoRenewLicense.callout_AutoRenew_API(
                        (new Map<Id, Asset>{billingDetails.Asset__c=>new Asset(Id=billingDetails.Asset__c)}), 
                        (new Map<Id, Asset>{billingDetails.Asset__r.ParentId=>new Asset(Id=billingDetails.Asset__r.ParentId)}) ,
                        (new Set<Id>{billingDetails.Asset__r.ParentId}), 
                        
                        billingDetails.Asset__r.Product2.Plan_Tier__c,
                        productPlanTierInfoMap,
                        
                        paymentInfo); 
                    
                    if(response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
                        responseMessage = 'Success';
                        
                    }else{
                        responseMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                        responseMessage = (String) responseMap.get('errorMessage');
                    }
                    
                    System.debug('@responseMessage'+responseMessage);    
                    
                }else{
                    responseMessage = 'Order Details not found.';
                    
                }
                
            }else{
                responseMessage = 'Primary Opportunity in Blank.';
            }
            
            billingDetails.Payment_Confirmation_Error_Message__c = responseMessage;
            
            CTX_BillingDetailsConstants.isFirstTimeBilling = FALSE;
            Update billingDetails;
            CTX_BillingDetailsConstants.isFirstTimeBilling = TRUE;
            
        }
        
        
        return JSON.serializePretty(responseMessage);
        
    }
    
	@future(Callout = TRUE)    
    public static void autoRenewActivateLicenseCallout(Id billingId)  {
        String responseMessage = '';
        Map<String, Object> responseMap;
        Billing_Details__c billingDetails = [ SELECT 
                                             
                                             Id, Asset__c, Asset__r.Product2.Plan_Tier__c, Asset__r.License_ID__c, 
                                             Asset__r.Parent.License_Id__c, Asset__r.Opportunity__c, Asset__r.ParentId
                                             
                                             FROM Billing_Details__c WHERE Id =: billingId LIMIT 1 ];
        
        if(billingDetails != NULL){
            QuoteLineItem renewalQli = [ SELECT Id, Order_Details__c 
                                        FROM QuoteLineItem WHERE 
                                        Quote.OpportunityId =: billingDetails.Asset__r.Opportunity__c AND 
                                       Product2.Plan_Tier__c =: billingDetails.Asset__r.Product2.Plan_Tier__c ];
            
            if(renewalQli != NULL){
                if(renewalQli.Order_Details__c != NULL){
                    CTX_AutoRenewLicenseHelper.PaymentWrapper paymentInfo = new CTX_AutoRenewLicenseHelper.PaymentWrapper();
                if(renewalQli.Order_Details__c != NULL)
                    paymentInfo = (CTX_AutoRenewLicenseHelper.PaymentWrapper)JSON.deserializeStrict(renewalQli.Order_Details__c, CTX_AutoRenewLicenseHelper.PaymentWrapper.Class);
                    paymentInfo.paymentMode = 'PAY_NOW';
                paymentInfo.previousLicense =  billingDetails.Asset__r.Parent.License_Id__c;
                    
                     Map<String, Product_Info_Metadata__mdt>	productPlanTierInfoMap		= new Map<String, Product_Info_Metadata__mdt>();
                    for( 
                Product_Info_Metadata__mdt thisRec : [ SELECT Id, MasterLabel, DeveloperName, Plan_Tier__c, Product_Id__c, Required_Fields__c 
                                                      FROM Product_Info_Metadata__mdt WHERE Plan_Tier__c =: billingDetails.Asset__r.Product2.Plan_Tier__c ] 
            ){
                productPlanTierInfoMap.put( thisRec.Plan_Tier__c, thisRec );
            }
                    
                    HttpResponse response = CTX_AutoRenewLicense.callout_AutoRenew_API(
                        (new Map<Id, Asset>{billingDetails.Asset__c=>new Asset(Id=billingDetails.Asset__c)}), 
                        (new Map<Id, Asset>{billingDetails.Asset__r.ParentId=>new Asset(Id=billingDetails.Asset__r.ParentId)}) ,
                        (new Set<Id>{billingDetails.Asset__r.ParentId}),
                        
                        billingDetails.Asset__r.Product2.Plan_Tier__c,
                        productPlanTierInfoMap,
                        
                        paymentInfo); 
                    
                    if(response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
                        responseMessage = 'Success';
                        
                    }else{
                        responseMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                        responseMessage = (String) responseMap.get('errorMessage');
                    }
                    
                    System.debug('@responseMessage'+responseMessage);    
                    
                }else{
                    responseMessage = 'Order Details not found.';
                    
                }
                
            }else{
                responseMessage = 'Primary Opportunity in Blank.';
            }
            
            billingDetails.Payment_Confirmation_Error_Message__c = responseMessage;
            
            CTX_BillingDetailsConstants.isFirstTimeBilling = FALSE;
            Update billingDetails;
            CTX_BillingDetailsConstants.isFirstTimeBilling = TRUE;
            
        }
        
        
    }
    
}