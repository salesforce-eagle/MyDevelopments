global class BatchToCheckDealClosureCallOut implements Database.Batchable<sObject>,Database.AllowsCallouts, schedulable{
    
    global void execute(SchedulableContext sc) {
        BatchToCheckDealClosureCallOut bc=new BatchToCheckDealClosureCallOut();
        database.executebatch(bc,10);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //select id from opportunity where failed=true
        string Failed='Failed';
        string query =  'select id from opportunity where Integration_Status__c=:Failed'; //'select id from opportunity where Integration_Status__c !=null And Integration_Status__c =:Failed limit 10';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> listOfOppToCallAgain) {
        for ( Opportunity opp : listOfOppToCallAgain){
            //DealClosureCallOut.Callout(opp.id,false);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}