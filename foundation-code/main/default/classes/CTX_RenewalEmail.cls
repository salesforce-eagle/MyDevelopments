public class CTX_RenewalEmail implements Schedulable {
    
    public static void  execute(SchedulableContext ctx){
        CTX_RenewalEmailHelper.sendRenewalEmail();
    }
        
        
}