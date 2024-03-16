global class CTX_GenericBatchToDeleteRecords implements Database.Batchable<sObject>{
    
    public string 	queryString;
    
    public CTX_GenericBatchToDeleteRecords( String queryString ){
        this.queryString 	= queryString;
        
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator(queryString);
    }
    global void execute(Database.BatchableContext BC, List<Sobject> objList) {
        
        system.debug('objList'+objList);
        database.delete(objList);
        
        
    }
    
    
    
    global void finish(Database.BatchableContext BC){}
    
}