public class CTX_UpsellEsignBatchScheduler implements Schedulable {
    
    public static void execute(SchedulableContext sc){ 
        database.executeBatch(new CTX_ContentStatusUpdateBatch('Upsell_Top_up__c'),5);
        database.executeBatch(new CTX_ContentVerUpdateBatch('Upsell_Top_up__c'),5);
    }
}