public class CTX_AssetExpirationReminderEmails implements Schedulable{
    
    public static void  execute(SchedulableContext ctx){
        CTX_AssetExpirationReminderEmailsShooter.sendEmailAlertForReminder();
    }

}