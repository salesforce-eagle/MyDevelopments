@RestResource(urlMapping='/jira/webhook/updateSalesforceFromJIRA/d30cdba4-3b75-43cc-9421-057b2b312a50/*')//https://cleartax--jiraintg.sandbox.my.salesforce-sites.com/service/apexrest/jira/webhook/updateSalesforceFromJIRA/d30cdba4-3b75-43cc-9421-057b2b312a50/
global without sharing class CTX_JiraCaseIntegration {
    
    @HttpPost
    global static void updateSalesforceFromJIRA() {
        
        RestRequest 		request			= RestContext.request;
        Map<String, String> jiraSFFieldMap	= new Map<String, String>{
            'customfield_10118' => 'Planned_Release_Date_JIRA__c',
                'status' => 'Status_JIRA__c',
                'customfield_10633' => 'Developer_Comment_JIRA__c',
                'customfield_10605' => 'QA_Release_Date_JIRA__c',
                'customfield_10121' => 'Actual_Release_Date_JIRA__c',
                'assignee' => 'L3_Developer_JIRA__c',
                'assignee_to' => 'Jira_Assignee__c'
                };
                    String 	jiraIssueId;
        String				commentBody;
        Case 				caseToUpdate 	= new case();
        Map<String, Object> changeLogTrace;
        Map<String, Object> issueMap;
        List<Object> 		mapOfChangeLogDetails;
        Map<String, Object> jiraRequestBody;
        Map<String, Object> commentMap;
        Boolean				isCommentCreated = FALSE;
        system.debug('request Body: 	'+request);
        
        if( request != NULL ){
            jiraRequestBody = (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString());
            system.debug('jiraRequestBody: '+jiraRequestBody);
            
            for( String thisKey : jiraRequestBody.keySet()){
                
                system.debug('thisKey: thisKey: '+thisKey);
                system.debug('thisValue: thisValue: '+jiraRequestBody.get(thisKey));
                
                if(thisKey == 'issue'){
                    issueMap 	= (Map<String, Object>)jiraRequestBody.get(thisKey);
                    jiraIssueId = (String)issueMap.get('id');
                }
                caseToUpdate.JIRA_Issue_Id__c = jiraIssueId;
                
                /**	JIRA Comment Section	**/
                if( jiraRequestBody.containsKey('webhookEvent') && jiraRequestBody.get('webhookEvent') == 'comment_created' ){
                    if(thisKey == 'comment'){
                    
                    commentMap 	= (Map<String, Object>)jiraRequestBody.get(thisKey);
                    for( String thisRec : commentMap.keySet() ){
                        if( thisRec == 'body' ){
                            String latestComment = (String)commentMap.get(thisRec);
                            if( latestComment.containsIgnoreCase('request with case #') ){} else{
                                commentBody = latestComment+'<br></br>';
                            }
                            
                        }
                        
                        /**	Author	**/
                        if( thisRec == 'updateAuthor' ){
                            map<String, Object> authorMap = (Map<String, Object>)commentMap.get(thisRec);
                            for(String thisAut : authorMap.keySet() ){
                                if( thisAut == 'displayName' ){
                                    commentBody = ( commentBody != NULL && commentBody != '' && commentBody != 'null' )
                                        ? 'Author Name: '+authorMap.get(thisAut)+'<br></br>'+commentBody : 'Author Name: '+authorMap.get(thisAut)+'<br></br>';
                                }
                            }
                        }
                        
                    }
                    
                    
                  isCommentCreated = TRUE;  
                }
                }
                
                
                
                system.debug('Comment Body is: '+commentBody);
                
                if(thisKey == 'changelog'){
                    
                    changeLogTrace = (Map<String, Object>)jiraRequestBody.get(thisKey);
                    
                    for(String thisSTR : changeLogTrace.keySet()){
                        if(thisSTR == 'items'){
                            
                            mapOfChangeLogDetails = (List<Object>) changeLogTrace.get(thisSTR);
                            for(Object thisObj : mapOfChangeLogDetails){
                                Map<String, Object> mapOfChangeItem = (Map<String, Object>) thisObj;
                                if( jiraSFFieldMap.containsKey( (String)mapOfChangeItem.get('fieldId') ) ){
                                    system.debug('Value is to: '+mapOfChangeItem.get('to'));
                                    system.debug('Value is to toString: '+mapOfChangeItem.get('toString'));
                                    system.debug('Field Name: '+(String)mapOfChangeItem.get('fieldId'));
                                    
                                    if( 
                                        (String)mapOfChangeItem.get('fieldId') == 'customfield_10633' ||
                                        (String)mapOfChangeItem.get('fieldId') == 'status' 
                                    ){
                                        caseToUpdate.put(
                                            jiraSFFieldMap.get( (String)mapOfChangeItem.get('fieldId') ),
                                            mapOfChangeItem.get('toString')
                                        );
                                        system.debug('caseToUpdate Inside ToString: '+caseToUpdate);
                                    }else if((String)mapOfChangeItem.get('fieldId') == 'assignee'){
                                        caseToUpdate.put(
                                            jiraSFFieldMap.get( (String)mapOfChangeItem.get('fieldId') ),
                                            mapOfChangeItem.get('toString')
                                        );
                                        caseToUpdate.put(
                                            jiraSFFieldMap.get( 'assignee_to' ),
                                            mapOfChangeItem.get('to')
                                        );
                                    }else {
                                        String dt = String.valueOf(mapOfChangeItem.get('to'));
                                        Date dateValue = Date.valueOf(dt);
                                        System.debug('@dateValue'+dateValue);
                                        DateTime dateValueNew = DateTime.newInstance(dateValue.year(), dateValue.month(), dateValue.day(),0,0,0);
                                        caseToUpdate.put(
                                            jiraSFFieldMap.get( (String)mapOfChangeItem.get('fieldId') ),
                                            dateValue
                                        );
                                        system.debug('caseToUpdate Inside to: '+caseToUpdate);
                                    }
                                    
                                }
                                system.debug('caseToUpdate: '+caseToUpdate);
                            }
                            system.debug('mapOfChangeLogDetails: '+mapOfChangeLogDetails);
                            
                        }
                    }
                    
                }
            }
            commentBody = '--	Start	--<br></br>'+system.now()+'<br></br>'+commentBody+'<br></br>--	End	--<br></br>'; 
            system.debug('jiraIssueId: '+jiraIssueId);
            List<Case> caseDetails = [ SELECT 
                                      
                                      Id, JIRA_Issue_Id__c, Updated_in_JIRA__c,
                                      Planned_Release_Date_JIRA__c, Actual_Release_Date_JIRA__c, QA_Release_Date_JIRA__c, 
                                      Developer_Comment_JIRA__c, Status_JIRA__c,
                                      
                                      L3_Developer_JIRA__c, JIRA_Ticket_Created_Date__c, QA_Handover_Date_JIRA__c,
                                      
                                      JIRA_Comment_Updates__c
                                      
                                      FROM Case WHERE JIRA_Issue_Id__c = :jiraIssueId 
                                      LIMIT 1 ];
            
            if (caseDetails.size() == 1) {
                caseToUpdate.Id = caseDetails[0].Id;
                system.debug('got the case');
                
                
                if(isCommentCreated){ 
                    caseToUpdate.JIRA_Comment_Updates__c = String.isNotBlank(caseDetails[0].JIRA_Comment_Updates__c) && caseDetails[0].JIRA_Comment_Updates__c != NULL 
                        ? caseDetails[0].JIRA_Comment_Updates__c+'<br></br>'+commentBody : commentBody; 
                }
            }
            
            CaseConstants.isFirstTimeCase = FALSE;
            update caseToUpdate;
        }
        
    }
    
    
    
}