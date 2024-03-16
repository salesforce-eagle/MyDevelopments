public class CTX_Salesforce_JIRA_Callout {
    
    public static void callout_Salesforce_JIRA(
        CTX_Salesforce_JIRA_FilterResult.CreateUpdateJIRAIssueWrapper 			inputResult,
        CTX_Salesforce_JIRA_FilterResult.CreateUpdateJIRAIssueWrapper_Feature 	inputResult_Feature,
        Boolean																	isBug,
        Boolean 																isGetmethod,
        Boolean 																isPostMethod,
        Boolean 																isPutMethod
    ){
        
        system.debug('isPostMethod: '+isPostMethod+' -- isPutMethod: '+isPutMethod);
        system.debug('inputResult_Feature: '+ JSON.serialize(inputResult_Feature));
        Boolean			isSuccess;
        Boolean 		isBulk 				= FALSE;
        Http 			http				= new Http();
        HttpRequest 	req 				= new HttpRequest();
        HttpResponse 	res 				= new HttpResponse();
        Blob 			headerValue 		= Blob.valueOf(System.Label.JIRA_Credential);
        String 			authorizationHeader	= 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String			body;
        /**	Case Related Details : START	**/
        String			existingIssueId;
        Id				caseId;
        String			assigneName;
        String			mailTrail;
        String			emailMessageId;
        /**	Case Related Details : END	**/
        
        if(isBug){
            existingIssueId 	= inputResult.issueId;
            caseId 				= inputResult.caseId;
            assigneName 		= inputResult.assigneeName;
            body 				= JSON.serialize(inputResult.dummy);
            mailTrail			= inputResult.mailTrails;
            emailMessageId		= inputResult.emailMessageId;
        } else{
            existingIssueId 	= inputResult_Feature.issueId;
            caseId	 			= inputResult_Feature.caseId;
            assigneName 		= inputResult_Feature.assigneeName;
            body 				= JSON.serialize(inputResult_Feature.dummy);
            mailTrail			= inputResult_Feature.mailTrails;
            emailMessageId		= inputResult_Feature.emailMessageId;
        }
        system.debug('body: '+body);
        system.debug('caseId: '+caseId);
        
        if(isGetmethod 	&& !isBulk){ 
            req.setEndpoint('https://cleartaxtech.atlassian.net/rest/api/2/issue/'+existingIssueId);
            req.setMethod('GET');
        }
        
        if(isPostMethod){
            req.setEndpoint('https://cleartaxtech.atlassian.net/rest/api/2/issue');
            req.setMethod('POST');
            req.setBody(body);
        }
        
        if(isPutMethod){
            req.setEndpoint('https://cleartaxtech.atlassian.net/rest/api/2/issue/'+existingIssueId);
            req.setMethod('PUT');
            req.setBody(body);
        }
        
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        
        try{
            res = http.send(req);
            isSuccess = TRUE;
        }catch(system.CalloutException e) {
            system.debug('Callout error: '+ e);
            isSuccess = FALSE;
        }
        
        system.debug('Response Status Code: '+res.getStatusCode()+' :: Response Status: '+res.getStatus());
        if(isSuccess && !isPutMethod){
            
            system.debug('res.getBody(): '+res.getBody());
            Map<String, Object> getResponseDetails = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            system.debug('getResponseDetails: '+getResponseDetails);
            
            string issueId;
            string issueURL;
            string projectName;
            string issueNumber;
            for(String thisSTR : getResponseDetails.keySet()){
                
                if(thisSTR == 'id' )
                    issueId = (String)getResponseDetails.get(thisSTR);
                
                
                if( thisSTR == 'key' ){
                    issueNumber = (String)getResponseDetails.get(thisSTR);
                    projectName = issueNumber.substringBefore('-');
                    issueURL 	= System.Label.Jira_URL+projectName+'/issues/'+issueNumber;
                }
                
            }
            
            system.debug('issueId: '+issueId);
            system.debug('issueURL: '+issueURL);
            
            if( issueId != NULL && isSuccess ){
                
                Boolean caseDMLIsSuccess = FALSE;
                Case myCase = new Case(
                    Id 							= caseId,
                    Updated_in_JIRA__c 			= TRUE,
                    JIRA_Issue_Id__c 			= issueId,
                    Jira_URL__c					= issueURL,
                    Status_JIRA__c 				= 'PENDING FOR RESPONSE',
                    JIRA_Ticket_Created_Date__c = system.now(),
                    L3_Developer_JIRA__c 		= assigneName
                );
                
                try{
                    CaseConstants.isFirstTimeCase = FALSE;
                    update myCase; 
                    caseDMLIsSuccess = TRUE;
                }catch(Exception ex){
                    system.debug('Case Update Failed: '+ex.getMessage());
                    caseDMLIsSuccess = FALSE;
                }
                
                if(caseDMLIsSuccess){
                    
                    /*CTX_EMailMessageToJIRACommentCallout.SuccessErrorWrapper jiraCommentResponse = CTX_EMailMessageToJIRACommentCallout.postJiraComment( mailTrail, issueId );                
                    
                    if(jiraCommentResponse.isSuccess){
                        
                        EmailMessage myMessage = new EmailMessage(
                            Id 					= emailMessageId,
                            Jira_Comment_Id__c 	= jiraCommentResponse.commentId
                        );
                        
                        CTX_checkRecursive.isEmailMessageTriggerRunning = FALSE;
                        update myMessage;*/
                        
                    Map<String,EmailMessage> issueMailTrail = new Map<String,EmailMessage>();
                    if(mailTrail != NULL){
                        EmailMessage emailMsg = new EmailMessage(Id = emailMessageId);
                        emailMsg.TextBody = mailTrail;
                        issueMailTrail.put(issueId, emailMsg);
                        
                        CTX_JiraCalloutQueuable DQ = new CTX_JiraCalloutQueuable(issueMailTrail); 
                        System.enqueueJob(DQ); 
                        
                    }
                  
                }
            }
            
        }
        
    }
    
}