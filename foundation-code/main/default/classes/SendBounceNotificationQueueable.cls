public class SendBounceNotificationQueueable implements Queueable {
    public case caseInstance ; 
    public SendBounceNotificationQueueable(Case caseList){
        this.caseInstance = caseList ;  
    }
    public void execute(QueueableContext context) {
       //Create parameter
   Map<String, Object> Params = new Map<String, Object>();
   Params.put('CaseIns',caseInstance);

   //create instance of Interview
    Flow.Interview.Case_Bounce_Email  stage = new Flow.Interview.Case_Bounce_Email (Params);

    //Invoke start method
    stage.start();

    //get value from Flow
    }
}