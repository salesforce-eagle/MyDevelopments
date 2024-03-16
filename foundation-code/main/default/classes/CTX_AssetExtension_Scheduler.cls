global class CTX_AssetExtension_Scheduler implements Schedulable {
    
    // Execute at regular intervals
    global void execute(SchedulableContext ctx){
      String soql = 'SELECT Id, Status, PurchaseDate, UsageEndDate, Days_to_Extend__c, License_ID__c, Price FROM Asset WHERE  UsageEndDate <= NEXT_N_DAYS:7  AND UsageEndDate >=TODAY AND (Days_to_Extend__c = NULL OR Days_to_Extend__c = 0) AND Status IN ( \'Upcoming Renewal\', \'Valid\' ) AND License_ID__c != NULL ORDER BY UsageEndDate';
      CTX_AssetExtension_Batch batch = new CTX_AssetExtension_Batch(soql);
      Database.executebatch(batch, 10);
    }
}