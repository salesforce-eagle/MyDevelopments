public class CTX_BatchForSoftUpdateRecords implements Database.Batchable<sObject>{
    
    Public String queryString;
    public CTX_BatchForSoftUpdateRecords(String queryString){
        
        system.debug('queryString: '+queryString);
        this.queryString = queryString;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        system.debug('scope size: '+scope.size());
        Database.SaveResult[] saveResultList = Database.update(scope, FALSE);
        for (Database.SaveResult sr : saveResultList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            } else{
                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        
    }
    
    public void finish(Database.BatchableContext BC){}
    
    
}