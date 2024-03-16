global class CTX_AssetStatusCorrector_Scheduler implements Schedulable {
    
    global void execute(SchedulableContext ctx){
        String soql = System.Label.CTX_AssetStatusCorrector_Scheduler_Query;
        CTX_AssetStatusCorrector_Batch batch = new CTX_AssetStatusCorrector_Batch(soql);
        Database.executebatch(batch, 200);
    }
}