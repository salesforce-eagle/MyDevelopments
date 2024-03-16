public class CTX_CSMFlowEmail implements Schedulable {
    
    public static void  execute(SchedulableContext ctx){
        Database.executeBatch(new CTX_CSMFlowEmailHelperBatch());
        CTX_CSMFlowEmailHelper.onboardingAging15DaysNotification();
        CTX_CSMFlowEmailHelper.exepctedOnboardingCompletionDateNotification();
        CTX_CSMFlowEmailHelper.assetCreationDateGreaterThanPeriodStartDateNotification();
        CTX_CSMFlowEmailHelper.salesHandover2DaysNotification();
    }
    
}