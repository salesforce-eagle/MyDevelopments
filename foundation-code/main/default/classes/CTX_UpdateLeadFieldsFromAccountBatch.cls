public class CTX_UpdateLeadFieldsFromAccountBatch implements Database.Batchable<String>, Database.stateful {
    public Map<String, Account> accountMap;
    public CTX_UpdateLeadFieldsFromAccountBatch (Map<String, Account> accountMap){
        this.accountMap = accountMap;
    }
	public Iterable<String> start(Database.BatchableContext BC){
        return new List<String>(accountMap.keySet());
    }

    public void execute(Database.BatchableContext BC, List<String> accountPANList){
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Lead leadInstance : [SELECT Id, PAN__c, Number_Of_GSTN__c, Number_of_PAN__c, Number_of_Sales_Invoices__c, Invoice_Discounting_Annual_Revenue__c FROM Lead WHERE PAN__c IN : accountPANList]){
            leadInstance.Number_Of_GSTN__c = accountMap.get(leadInstance.PAN__c).No_of_GSTIN__c;
            leadInstance.Number_of_PAN__c = accountMap.get(leadInstance.PAN__c).No_of_PAN__c;
            leadInstance.Number_of_Sales_Invoices__c = accountMap.get(leadInstance.PAN__c).Number_of_Sales_Invoices__c;
            leadInstance.Invoice_Discounting_Annual_Revenue__c = accountMap.get(leadInstance.PAN__c).Invoice_Discounting_Annual_Revenue__c;
            leadsToUpdate.add(leadInstance);
        }
        
        if(!leadsToUpdate.isEmpty()){
            AccountConstants.updateLeadFields = true;
            Database.update(leadsToUpdate, false);
        }
        
        
    }

    public void finish(Database.BatchableContext BC){}
}