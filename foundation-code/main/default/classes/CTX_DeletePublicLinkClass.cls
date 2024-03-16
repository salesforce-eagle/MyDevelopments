global class CTX_DeletePublicLinkClass IMPLEMENTS Database.Batchable<sObject>, Database.Stateful, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id FROM ContentDistribution LIMIT 49999');
    }
    
    global void execute(Database.BatchableContext BC, List<ContentDistribution> scope){
        system.debug('CTX_DeletePublicLinkClass :: scope size :: '+scope.size());
        try{
            Database.delete(scope, FALSE);
        } catch (Exception e){
            system.debug('CTX_DeletePublicLinkClass :: :: error is :: '+e.getMessage() );
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    
    
    global void execute(SchedulableContext sc){
        ID BatchId = Database.executeBatch(new CTX_DeletePublicLinkClass(), 200);
    }
    
    global static void schedulerMethod(){ 
        string cornExpression = '0 5 * * * ?';
        System.schedule('CTX_DeletePublicLinkClass Schedulable', cornExpression, new CTX_DeletePublicLinkClass());
    }
    
}