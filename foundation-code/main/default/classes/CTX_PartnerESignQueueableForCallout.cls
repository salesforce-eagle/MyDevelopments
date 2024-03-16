public class CTX_PartnerESignQueueableForCallout implements Queueable, Database.AllowsCallouts {
    
    Public List<List<ESignRequestCallOutGeneric.valueInitiators>> listOfESignRequests;
    
    public CTX_PartnerESignQueueableForCallout(List<List<ESignRequestCallOutGeneric.valueInitiators>> listOfESignRequests){
        this.listOfESignRequests = listOfESignRequests;
    }
    
    public void execute(QueueableContext context) {
        
        List<List<ESignRequestCallOutGeneric.valueInitiators>> 	toBeRemoved 			= new List<List<ESignRequestCallOutGeneric.valueInitiators>>();
        List<Account> 										listOfAccountsToBeUpdated 	= new list<Account>();
        integer 												loopSize 				= (listOfESignRequests.size() < 10) ? listOfESignRequests.size() : 10;
        Id 														classId 				= [SELECT Id FROM Logger__c WHERE 
                                                                                           Apex_Class__c = 'CTX_PartnerESignQueueableForCallout' ]?.Id;
        Set<Logger__c>											loggerEntry				= new Set<Logger__c>();
        
        try{
            
            for(integer i=0; i<loopSize; i++){
                
                Account 										accInst 		= new Account();
                ESignRequestCallOutGeneric 							eSignRequest 	= new ESignRequestCallOutGeneric();
                List<ESignRequestCallOutGeneric.valueInitiators> 	listOfRequests 	= listOfESignRequests[i];
                String 												result 			= eSignRequest.requestCallOut(listOfRequests);
                accInst.Id 															= listOfRequests[0].recordId;
                
                if(result.startsWith('Request Successfull')){
                    
                    List<String> 		successResult	=	result.split('::');
                    Map<String, Object> JSONResult 		= (Map<String, Object>)JSON.deserializeUntyped(successResult[1]);
                    
                    /**	this.messageToDisplay = 'Docket '+JSONResult.docket_id + ' Document ' +JSONResult.signer_info[0].document_id +'Ref '+JSONResult.signer_info[0].reference_doc_id;	**/
                  
                    
                    accInst.Retrigger_E_Sign__c             = 'Sent Successfully';
                    accInst.E_Sign_Status__c 				= 'E-Sign Request Sent';
                    accInst.ESign_Message__c = '';
                    accInst.ESign_BE_Docket_ID__c 			= String.valueOf(JSONResult.get('docket_id'));
                    List<Object> listOfSigners 				= (List<Object>)JSONResult.get('signer_info');
                    Map<String, Object> JSONResultSigners 	= (Map<String, Object>)listOfSigners[0];
                    accInst.ESign_BE_Document_ID__c 		= String.valueOf(JSONResultSigners.get('document_id'));
                    accInst.ESign_BE_Reference_Doc_ID__c	= String.valueOf(JSONResultSigners.get('reference_doc_id'));
                }else if(result.contains(':')){
                    
                    list<string> 		successResult 	= result.split(':');
                    map<string,string> 	mapResult 		= new map<string,string>();
                    integer i1;
                    for(i1 = 1; i1 < successResult.size()-1 ; i1++ ){
                        mapResult.put(successResult[i1],successResult[i1+1]);
                    }
                    system.debug('ESignQueueableForCallOut Success Result - Else IF '+successResult);
                    
                    if(!result.contains('Unsuccessful')){
                        accInst.ESign_Message__c = successResult[1];
                    } else{
                        accInst.ESign_Message__c = mapResult.get(' error ');
                        system.debug('ESignQueueableForCallOut accInst.ESign_Message__c'+accInst.ESign_Message__c);
                    }
                }
                toBeRemoved.add(listOfESignRequests[i]);
                
                if(accInst.hasErrors()){
                    
                    String error;
                    if(accInst.getErrors().size() > 0){
                        error = accInst.getErrors()[0].getMessage();
                    }
                    
                    loggerEntry.add(
                        CTX_LoggerImplementation.createLoggerInstance(
                            error,
                            classId, 
                            'ESignQueueableForCallOut', 
                            'execute', 
                            'DML Issue', 
                            accInst.Id,
                            'Account'
                        ) );
                } else{
                    listOfAccountsToBeUpdated.add(accInst);
                }
                
            }
            
            for(List<ESignRequestCallOutGeneric.valueInitiators> each : toBeRemoved){
                listOfESignRequests.remove(toBeRemoved.indexOf(each));
            }

            if(!listOfAccountsToBeUpdated.isEmpty()){
                
                Integer 				i	= 0;
                Database.SaveResult[] 	lsr	= Database.update(listOfAccountsToBeUpdated,false);
                
                for(Database.SaveResult sr : lsr){
                    if(!sr.isSuccess()){
                        String errors;
                        Integer counter = 1;
                        for(Database.Error err : sr.getErrors()){
                            errors += counter + '. '+ err.getMessage() + '\n';                            
                        }
                        
                        loggerEntry.add(
                            CTX_LoggerImplementation.createLoggerInstance(
                                errors,
                                classId, 
                                'CTX_PartnerESignQueueableForCallout', 
                                'execute', 
                                'DML Issue', 
                                sr.getId(),
                                'Account'
                            ) 
                        );
                    }
                }
                i++;
            }
            
            /**	Insert Logger Records	**/
            if(loggerEntry.size() > 0){
                
                try{
                    insert (new List<Logger__c>(loggerEntry));
                }catch(Exception ex){
                    system.debug('CTX_AccountShare Looger Creation Issue: '+ex.getMessage());
                }
            }
            /**	Insert Logger Records : END	**/
            
            if(listOfESignRequests.size()>0){
                ESignQueueableForCallOut tempESignQueueableForCallOut = new ESignQueueableForCallOut(listOfESignRequests);
                System.enqueueJob(tempESignQueueableForCallOut);
            }
            
        }catch(Exception e){
            System.debug('#*# Exception Msg '+e.getMessage());
            System.debug('#*# Exception Line No '+e.getLineNumber());
            System.debug('#*# Exception StackTrace '+e.getStackTraceString());
            
            insert CTX_LoggerImplementation.createLoggerInstance(
                e.getMessage(),
                classId, 
                'CTX_PartnerESignQueueableForCallout', 
                'execute', 
                'DML Issue', 
                NULL,
                'Account'
            );
        } finally{
            system.debug('I am in Finally Block');
        }
        
    }
}