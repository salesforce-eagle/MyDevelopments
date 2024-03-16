public class CTX_CSMFlowEmailHelperBatch implements Database.Batchable<sObject>, Database.RaisesPlatformEvents{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        Date	validatingDate = Date.today().addDays(-90);        
        String 	queryString = ' SELECT Id, Name, AccountId, Account_owner_email__c, Onboarding_Status__c, Account.Onboarding_Owner__r.Manager.Email , Account.Onboarding_Owner__r.Email';
        queryString += ' FROM Asset WHERE  CreatedDate <= '+validatingDate+' AND Onboarding_Status__c != '+ '\'Onboarding Complete\'';
        
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        if(scope.size() > 0)
            CTX_CSMFlowEmailHelper.asset90DaysReminderEmail( (List<Asset>)scope );
    }
    
    public void finish(Database.BatchableContext BC){
    }
}