public class CTX_ErrorBanner_Quote {
    
    
    Public Static Map<String, String> quote_Stage_Movement_Map = new Map<String, String>{ 
        'Draft' 					=> 'Quote Sent',
            'In Quote Approvals' 	=> 'Quote Sent',
            'Document Generated' 	=> 'Quote Sent',
            'Quote Sent' 			=> 'Price Negotiation',
            'Price Negotiation' 	=> 'Discount Approval',
            'Discount Approval' 	=> 'Quote Accept' };
                
                Public Static String trackErrors;
    
    @AuraEnabled
    public static ResultWrapper run(Id recordId){
        
        ResultWrapper thisResult = new ResultWrapper();
        
        
        Quote quoteRecord = [ SELECT Id, Name, Status
                             
                             FROM Quote WHERE 
                             Id = :recordId 
                             LIMIT 1 ];
        
        if(quoteRecord != NULL){
            
            String validationResult = checkValidationErrors(quoteRecord);
            
            if(validationResult != NULL){
                thisResult.returnresultMap.put('Validation Related Error', validationResult);
                thisResult.isSuccess = FALSE;
            } else{
                thisResult.isSuccess = TRUE;
            }
            
            
        }
        
        return thisResult;
    }
    
    @AuraEnabled
    public static String checkValidationErrors(Quote quoteRecord){
        
        String returnresult;
        Savepoint sp = Database.setSavepoint();
        
        if(quote_Stage_Movement_Map.containsKey(quoteRecord.Status)){
            quoteRecord.put('Status', quote_Stage_Movement_Map.get(quoteRecord.Status));
        }
        
        try{
            update quoteRecord;
        } catch(Exception ex){
           /** if(ex.getMessage().split(';').size() > 1){
                if(ex.getMessage().split(';')[1].split(',').size() > 1){
                    returnresult = ex.getMessage().split(';')[1].split(',')[1];
                } else{
                    returnresult = ex.getMessage();
                }
            } else{**/
                returnresult = ex.getMessage();
           // }
        }
        
        Database.rollback(sp);
        
        return returnresult; 
    }
    
    Public Class ResultWrapper{
        
        @AuraEnabled
        Public Map<String, String> returnresultMap = new Map<String, String>();
        
        @AuraEnabled
        Public Boolean isSuccess = TRUE;
        
    }
    
}