public class CTX_UserDeactivateQueue implements Queueable {
    
    public void execute(QueueableContext context) {
        //System.enqueueJob(new SecondJob());
        
        CTX_UserActivationDeactivationClass.run();
    }
}