public class CTX_IntegrationAutomatedReportScheduler implements Schedulable{
    
    public static void execute(SchedulableContext ctx){
        CTX_IntegrationAutomatedReport_A.sendAutomatedReportA();
    }

}