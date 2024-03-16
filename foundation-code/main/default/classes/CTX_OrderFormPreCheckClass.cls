public class CTX_OrderFormPreCheckClass {
    
    @AuraEnabled
    public static Boolean checkForSyncQuotes(String recordId){
        
        Boolean returnResult;
        if(recordId != NULL){
            List<Quote> childQuotes = [ SELECT Id, IsSyncing 
                                       FROM Quote WHERE 
                                       OpportunityId =: recordId AND 
                                       IsSyncing = TRUE ];
            if(childQuotes != NULL && childQuotes.size() > 0)
                returnResult = TRUE;
            else
                returnResult = FALSE;
        }
        
        return returnResult;
    }

}