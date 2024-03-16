public without sharing class CTX_FeedbackLogClass {
    
    @AuraEnabled
    public static LogFeedbackReturnWrapper logFeedback(
        String 	objectName,
        String 	feedback,
        String 	pluses, 
        String 	needImprovement,
        Integer rating
    ){
        
        system.debug('currentRating: '+rating);
        LogFeedbackReturnWrapper thisResult = new LogFeedbackReturnWrapper();
        
        Feedback__c newfeedback = new Feedback__c(
            Feedback_Owner__c 	= UserInfo.getUserId(),
            Feedback_Object__c 	= objectName,
            Review__c 			= feedback,
            Pluses__c 			= pluses,
            Need_Improvement__c = needImprovement,
            Rating__c 			= rating
        );
        
        try{
            insert newfeedback; 
            thisResult.isSuccess = TRUE;
        } catch(Exception ex){
            system.debug('CTX_FeedbackLogClass Error: '+ex.getMessage());
            thisResult.errorMessage = ex.getMessage();
        }
        
        return thisResult;
    }
    
    Public Class LogFeedbackReturnWrapper{
        
        @AuraEnabled
        Public Boolean isSuccess = FALSE;
        
        @AuraEnabled
        Public String errorMessage;
    }
}