public class CTX_ProjectEscalationEmail implements Schedulable{

    public static void  execute(SchedulableContext ctx){
        Database.executeBatch(new CTX_IntegrationEscalationBatch(NULL), 20);
    }
}