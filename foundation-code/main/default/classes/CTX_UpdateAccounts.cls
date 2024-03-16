public class CTX_UpdateAccounts IMPLEMENTS Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String queryString = ' SELECT Id, RecordType.Name, Market_Team__c FROM Account WHERE RecordType.Name != NULL AND Market_Team__c = NULL AND RecordType.Name != \'International\' ';
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope){
        
        List<Account> updateAccounts = new List<Account>();
        
        for( Account thisRec : scope ){
            
            thisRec.Market_Team__c = thisRec.RecordType.Name;
            
            updateAccounts.add(thisRec);
        }
        
        database.update(updateAccounts, FALSE);
    }
    
    public void finish(Database.BatchableContext BC){}
}