public class CTX_QliFieldUpdateBasedOnPlatform {
    public static void updateQli(Map<Id, QuoteLineItem> mapOfNewQuoteLines, Map<Id, QuoteLineItem> mapOfOldQuoteLines){
        Set<Id> 			productIds 				= new Set<Id>();
        
        for(QuoteLineItem qli : mapOfNewQuoteLines.values()){
            if(qli.Platform__c == 'App.Clear'){
                productIds.add(qli.Product2Id);
            }
        }
        
        Map<Id,Product2> ProductMap = new Map<Id,Product2>([SELECT Id, Plan_Allowance_GSTIN__c,Plan_Allowance_PAN__c,
                                                            Plan_Allowance_GSTIN_Verification__c , Plan_Allowance_Total_invoices__c 
                                                            FROM Product2 
                                                            WHERE Id IN : productIds]);
        
        for(QuoteLineItem thisRec : mapOfNewQuoteLines.values()){
            if(ProductMap.containsKey(thisRec.Product2Id)){
                if(ProductMap.get(thisRec.Product2Id).Plan_Allowance_GSTIN__c != NULL){
                    thisRec.No_of_GSTIN_one__c = ProductMap.get(thisRec.Product2Id).Plan_Allowance_GSTIN__c;
                }
                if(ProductMap.get(thisRec.Product2Id).Plan_Allowance_PAN__c != NULL){
                    thisRec.No_of_PAN_one__c = ProductMap.get(thisRec.Product2Id).Plan_Allowance_PAN__c;
                }
                if(ProductMap.get(thisRec.Product2Id).Plan_Allowance_GSTIN_Verification__c != NULL){
                    thisRec.No_of_GSTIN_verification_credits__c	 = ProductMap.get(thisRec.Product2Id).Plan_Allowance_GSTIN_Verification__c;
                }
                if(ProductMap.get(thisRec.Product2Id).Plan_Allowance_Total_invoices__c != NULL){
                    thisRec.No_of_Total_invoices__c = ProductMap.get(thisRec.Product2Id).Plan_Allowance_Total_invoices__c;
                }
            }
            
            
        }
        

    }
    
}