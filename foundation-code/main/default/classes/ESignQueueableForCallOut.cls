/**
* @description       : 
* @author            : bibhudananda.dash@cleartax.in
* @group             : 
* @last modified on  : 03-07-2022
* @last modified by  : bibhudananda.dash@cleartax.in
* Modifications Log 
* 	Ver   	Date         	Author                     		Modification
*	-----------------------------------------------------------------------
* 	1.0   	01-22-2021   	pramodh@warpdrivetech.in   		Initial Version
*	2.0		03-07-2022		bibhudananda.dash@cleartax.in	Optimized Class
*	-----------------------------------------------------------------------
**/

public class ESignQueueableForCallOut implements Queueable, Database.AllowsCallouts {
    
    Public List<List<ESignRequestCallOutGeneric.valueInitiators>> listOfESignRequests;
    
    public ESignQueueableForCallOut(List<List<ESignRequestCallOutGeneric.valueInitiators>> listOfESignRequests){
        this.listOfESignRequests = listOfESignRequests;
    }
    
    public void execute(QueueableContext context) {
        System.debug('ESignQueueableForCallOut execute: ');
        
        List<List<ESignRequestCallOutGeneric.valueInitiators>> 	toBeRemoved 			= new List<List<ESignRequestCallOutGeneric.valueInitiators>>();
        List<Opportunity> 										listOfOppToBeUpdated 	= new list<Opportunity>();
        List<Upsell_Top_up__c> 								    listOfUpsToBeUpdated 	= new list<Upsell_Top_up__c>();
        integer 												loopSize 				= (listOfESignRequests.size() < 10) ? listOfESignRequests.size() : 10;
        Set<Logger__c>											loggerEntry				= new Set<Logger__c>();
        
        try{
            System.debug('ESignQueueableForCallOut loopSize size '+listOfESignRequests.size());
            System.debug('ESignQueueableForCallOut listOfESignRequests '+listOfESignRequests);
            
            for(integer i=0; i<loopSize; i++){
                
                System.debug('ESignQueueableForCallOut Loop Iteration '+i);
                System.debug('ESignQueueableForCallOut listOfRequests '+listOfESignRequests[i]);
                
                Opportunity 										tempOpp 		= new Opportunity();
                Upsell_Top_up__c									tempUps			= new Upsell_Top_up__c();
                ESignRequestCallOutGeneric 							eSignRequest 	= new ESignRequestCallOutGeneric();
                List<ESignRequestCallOutGeneric.valueInitiators> 	listOfRequests 	= listOfESignRequests[i];
                String 												result 			= eSignRequest.requestCallOut(listOfRequests);
                
                if(listOfRequests[0].recordId.StartsWithIgnoreCase('006')){
                    tempOpp.Id 				= listOfRequests[0].recordId; 
                }else{
                    tempUps.id				= listOfRequests[0].recordId; 
                }
               
                
                System.debug('ESignQueueableForCallOut listOfRequests[i].recordId '+listOfRequests[0].recordId);
                System.debug('ESignQueueableForCallOut result '+result);
                
                if(result.startsWith('Request Successfull')){
                    
                    system.debug('ESignQueueableForCallOut Success Result '+result.split('::'));
                    
                    List<String> 		successResult	=	result.split('::');
                    Map<String, Object> JSONResult 		= (Map<String, Object>)JSON.deserializeUntyped(successResult[1]);
                    
                    /**	this.messageToDisplay = 'Docket '+JSONResult.docket_id + ' Document ' +JSONResult.signer_info[0].document_id +'Ref '+JSONResult.signer_info[0].reference_doc_id;	**/
                    System.debug('ESignQueueableForCallOut JSONResult '+JSONResult);
                    List<Object> listOfSigners 				= (List<Object>)JSONResult.get('signer_info');
                    Map<String, Object> JSONResultSigners 	= (Map<String, Object>)listOfSigners[0];
                    if(tempOpp.Id != NULL){
                        tempOpp.Retrigger_E_Sign__c             = 'Sent Successfully';
                        tempOpp.E_Sign_Status__c 				= 'E-Sign Request Sent';
                        tempOpp.ESign_Message__c = '';
                        tempOpp.ESign_BE_Docket_ID__c 			= String.valueOf(JSONResult.get('docket_id'));
                        tempOpp.ESign_BE_Document_ID__c 		= String.valueOf(JSONResultSigners.get('document_id'));
                        tempOpp.ESign_BE_Reference_Doc_ID__c	= String.valueOf(JSONResultSigners.get('reference_doc_id'));
                    } 
                    if(tempUps.Id != NULL){
                        tempUps.Retrigger_E_Sign__c             = 'Sent Successfully';
                        tempUps.E_Sign_Status__c				= 'E-Sign Request Sent';
                        tempUps.ESign_Message__c = '';
                        tempUps.ESign_BE_Docket_ID__c 			= String.valueOf(JSONResult.get('docket_id'));
                        tempUps.ESign_BE_Document_ID__c 		= String.valueOf(JSONResultSigners.get('document_id'));
                        tempUps.ESign_BE_Reference_Doc_ID__c	= String.valueOf(JSONResultSigners.get('reference_doc_id'));
                    }

                    system.debug('ESignQueueableForCallOut tempOpp '+tempOpp);
                    system.debug('ESignQueueableForCallOut tempUps '+tempUps);
                }else if(result.contains(':')){
                    
                    list<string> 		successResult 	= result.split(':');
                    map<string,string> 	mapResult 		= new map<string,string>();
                    integer i1;
                    for(i1 = 1; i1 < successResult.size()-1 ; i1++ ){
                        mapResult.put(successResult[i1],successResult[i1+1]);
                    }
                    system.debug('ESignQueueableForCallOut Success Result - Else IF '+successResult);
                    
                    if(!result.contains('Unsuccessful')){
                        tempOpp.ESign_Message__c = successResult[1];
                    } else{
                        tempOpp.ESign_Message__c = mapResult.get(' error ');
                        system.debug('ESignQueueableForCallOut tempOpp.ESign_Message__c'+tempOpp.ESign_Message__c);
                    }
                }
                toBeRemoved.add(listOfESignRequests[i]);
                
                if(tempOpp.hasErrors()){
                    
                    String error;
                    if(tempOpp.getErrors().size() > 0){
                        error = tempOpp.getErrors()[0].getMessage();
                    }
                    
                    loggerEntry.add(
                        CTX_LoggerImplementation.createLoggerInstance(
                            error,
                            NULL, 
                            'ESignQueueableForCallOut', 
                            'execute', 
                            'DML Issue', 
                            tempOpp.Id,
                            'Opportunity'
                        ) );
                } else{
                    listOfOppToBeUpdated.add(tempOpp);
                    listOfUpsToBeUpdated.add(tempUps);
                }
                
            }
            
            for(List<ESignRequestCallOutGeneric.valueInitiators> each : toBeRemoved){
                listOfESignRequests.remove(toBeRemoved.indexOf(each));
            }
            System.debug('#*# ** listOfOppToBeUpdated '+listOfOppToBeUpdated);
            
            if(!listOfOppToBeUpdated.isEmpty()){
                
                Integer 				i	= 0;
                Database.SaveResult[] 	lsr	= Database.update(listOfOppToBeUpdated,false);
                
                for(Database.SaveResult sr : lsr){
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()){
                            
                            loggerEntry.add(
                                CTX_LoggerImplementation.createLoggerInstance(
                                    err.getMessage(),
                                    NULL, 
                                    'ESignQueueableForCallOut', 
                                    'execute', 
                                    'DML Issue', 
                                    listOfOppToBeUpdated[i].Id,
                                    'Opportunity'
                                ) );
                        }
                    }
                }
                i++;
            }
             if(!listOfUpsToBeUpdated.isEmpty()){
                
                Integer 				i	= 0;
                Database.SaveResult[] 	lsr	= Database.update(listOfUpsToBeUpdated,false);
                
                for(Database.SaveResult sr : lsr){
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()){
                            
                            loggerEntry.add(
                                CTX_LoggerImplementation.createLoggerInstance(
                                    err.getMessage(),
                                    NULL, 
                                    'ESignQueueableForCallOut', 
                                    'execute', 
                                    'DML Issue', 
                                    listOfUpsToBeUpdated[i].Id,
                                    'Opportunity'
                                ) );
                        }
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
                NULL, 
                'ESignQueueableForCallOut', 
                'execute', 
                'DML Issue', 
                NULL,
                'Opportunity'
            );
        } finally{
            system.debug('I am in Finally Block');
        }
        
    }
}