public class CTX_UserDeactivateSchedule implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        
        system.enqueueJob(new CTX_UserDeactivateQueue());
    }
}