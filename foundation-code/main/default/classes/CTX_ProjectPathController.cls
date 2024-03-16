public class CTX_ProjectPathController {
    @AuraEnabled
    public static void updatePaymentTracker(String paymentStatus , String recordId){
        Project__c prj = [Select Id ,SI_Payment_Tracker__c from Project__c where Id=:recordId] ; 
        prj.SI_Payment_Tracker__c = paymentStatus ; 
        update prj ;  
    }

}