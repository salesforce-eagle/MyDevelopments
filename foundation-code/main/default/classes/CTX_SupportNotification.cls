public class CTX_SupportNotification implements Schedulable {
    
    public static void  execute(SchedulableContext ctx){
        CTX_SupportNotificationHelper.getAssetDetails();
    }
}