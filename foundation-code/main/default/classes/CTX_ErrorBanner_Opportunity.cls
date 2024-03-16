public class CTX_ErrorBanner_Opportunity {
    
    
    Public Static Map<String, String> opportunity_Stage_Movement_Map 
        = new Map<String, String>{ 
            'Pre SQL' 					=> 'Quote Management',	
                'SQL' 					=> 'Quote Management',
                'POC' 					=> 'Quote Management',
                'Quote Management' 		=> 'In Finance Approval',
                'Negotiation Meetings' 	=> 'In Finance Approval',
                'Closure Meetings' 		=> 'In Finance Approval',
                'Follow Up' 			=> 'In Finance Approval',
                'Renewal initiated' 	=> 'In Progress',
                'In Progress' 			=> 'Quoting',
                'Quoting' 				=> 'On Track', 
                'On Track' 				=> 'In Finance Approval',
                'In Finance Approval' 	=> 'Closed Won'	};
                    
                    Public Static String trackErrors;
    
    @AuraEnabled
    public static ResultWrapper run(Id recordId){
        
        ResultWrapper thisResult = new ResultWrapper();
        
        Opportunity oppRecord = [ SELECT Id, Name, StageName,Receivable__r.Name,Receivable__r.SAP_BP_Code__c,
                                 
                                 Order_Form_Required__c, ESign_Category__c, ESign_BE_Docket_ID__c, ESign_BE_Document_ID__c, 
                                 ESign_Sign_Status__c, ESign_CTX_Status__c, ESign_Message__c, E_Sign_Customer_Info__c, 
                                 E_Sign_Customer_Info__r.Phone, E_Sign_Customer_Info__r.Email,
                                 
                                 ( SELECT Id, LinkedEntityId, ContentDocumentId, SystemModstamp 
                                  FROM ContentDocumentLinks ORDER BY SystemModstamp DESC LIMIT 1 )
                                 
                                 FROM Opportunity WHERE 
                                 Id = :recordId 
                                 LIMIT 1 ];
        
        if(oppRecord != NULL){
            
            String validationResult = checkValidationErrors(oppRecord);
            String orderfromResult 	= orderFromRelatedIssues(oppRecord);
            String receivableResult = checkReceivableRelatedErrors(oppRecord);
            
            if(validationResult != NULL){
                thisResult.returnresultMap.put('Validation Related Error', validationResult);
                thisResult.isSuccess = FALSE;
            }
            if(receivableResult != NULL){
                thisResult.returnresultMap.put('Receivable Related Error', receivableResult);
                thisResult.isSuccess = FALSE;
            }
            if(orderfromResult != NULL){
                thisResult.returnresultMap.put('Order From Related Error', orderfromResult);
                thisResult.isSuccess = FALSE;
            }
            
            
            if(validationResult != NULL && orderfromResult != NULL && receivableResult != NULL)
                thisResult.isSuccess = TRUE;
        }
        
        system.debug('thisResult: '+thisResult);
        return thisResult;
    }
    
    
    public static String checkReceivableRelatedErrors(Opportunity oppRecord){
        
        if(oppRecord.Receivable__r.SAP_BP_Code__c == 'ERROR' || oppRecord.Receivable__r.SAP_BP_Code__c =='' || oppRecord.Receivable__r.SAP_BP_Code__c == NULL){
            return 'Error in Opportunity Receivable : '+ oppRecord.Receivable__r.Name +' on SAP BP Code';
        }
        return NULL;
    }
    
    
    @AuraEnabled
    public static String checkValidationErrors(Opportunity oppRecord){
        
        String returnresult;
        Savepoint sp = Database.setSavepoint();
        
        if(opportunity_Stage_Movement_Map.containsKey(oppRecord.StageName)){
            oppRecord.put('StageName', opportunity_Stage_Movement_Map.get(oppRecord.StageName));
        }
        
        try{
            update oppRecord;
        } catch(Exception ex){
            /** if(ex.getMessage().split(';').size() > 1){
if(ex.getMessage().split(';')[1].split(',').size() > 1){
returnresult = ex.getMessage().split(';')[1].split(',')[1];
} else{
returnresult = ex.getMessage();
}
} else{ **/
            returnresult = ex.getMessage();
            //}
            
        }
        
        Database.rollback(sp);
        
        return returnresult; 
    }
    
    
    @AuraEnabled
    public static String orderFromRelatedIssues(Opportunity oppRecord){
        
        String returnResult;
        if(oppRecord.Order_Form_Required__c == 'Yes'){
            
            Id documentId = 
                oppRecord.getSobjects('ContentDocumentLinks') != NULL ? oppRecord.ContentDocumentLinks[0].ContentDocumentId : NULL;
            
            if(documentId != NULL){
                ContentVersion thisDoc = [ SELECT Id, ContentDocumentId, Type_of_document__c, 
                                          Parent_RecordId__c, system_generated__c
                                          
                                          FROM ContentVersion WHERE 
                                          ContentDocumentId =: documentId 
                                          LIMIT 1];
                
                if(thisDoc.Type_of_document__c != 'Order Form'){
                    returnResult = returnResult != NULL ? 
                        ( returnResult + '\n <br/> Please change Type of Document to "Order From" before going ahead.' ) :
                    'Please change Type of Document to "Order From" before going ahead. ';
                }
                
                if(oppRecord.ESign_Category__c == 'E-Sign' && !thisDoc.system_generated__c){
                    returnResult = returnResult != NULL ? 
                        ( returnResult + '\n <br/> E-Sign required System generated file as Order From. Please use Generate Order From button to get the file. ' ) :
                    'E-Sign required System generated file as Order From. Please use Generate Order From button to get the file. ';
                }
                
                if(oppRecord.ESign_Message__c != NULL){
                    returnResult = returnResult != NULL ? 
                        ( returnResult + '\n <br/> Error from Sign-Desk: '+oppRecord.ESign_Message__c+' ') :
                    'Error from Sign-Desk: '+oppRecord.ESign_Message__c+' ';
                }
            } else{
                returnResult  = 
                    returnResult != NULL ? 
                    ( returnResult + '\n <br/> Please Upload Order From before going for In Finance Approval Stage' ) :
                'Please Upload Order From before going for In Finance Approval Stage. ';
            }
        }
        
        return returnResult;
    }
    
    Public Class ResultWrapper{
        
        @AuraEnabled
        Public Map<String, String> returnresultMap = new Map<String, String>();
        
        @AuraEnabled
        Public Boolean isSuccess = TRUE;
        
    }
    
    
}