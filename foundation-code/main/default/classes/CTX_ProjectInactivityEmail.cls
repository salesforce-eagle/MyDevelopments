public class CTX_ProjectInactivityEmail implements Schedulable {
    
    public static void  execute(SchedulableContext ctx){
        CTX_ProjectInactivityEmailHelper.sendInactivityEmail();
    }
        
        
}