public class CTX_LeadFieldsPopulateFromAccount {
    
    public static void updateNoOfGSTINSalesInvoice(Map<String, Lead> leadsToUpdateMap){
        for(Account acct : [SELECT Id, PAN__c, No_of_PAN__c, No_of_GSTIN__c, Invoice_Discounting_Annual_Revenue__c, Number_of_Sales_Invoices__c FROM Account WHERE PAN__c IN : leadsToUpdateMap.keySet()]){
            if(leadsToUpdateMap.get(acct.PAN__c) != null){
             	leadsToUpdateMap.get(acct.PAN__c).Number_Of_GSTN__c = acct.No_of_GSTIN__c;
                leadsToUpdateMap.get(acct.PAN__c).Number_of_PAN__c = acct.No_of_PAN__c;
                leadsToUpdateMap.get(acct.PAN__c).Number_of_Sales_Invoices__c  = acct.Number_of_Sales_Invoices__c;
                leadsToUpdateMap.get(acct.PAN__c).Invoice_Discounting_Annual_Revenue__c = acct.Invoice_Discounting_Annual_Revenue__c;
            }
        }
    }

}