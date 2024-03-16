public class CTX_EMailMessageToJIRACommentCallout {
    
    public static SuccessErrorWrapper postJiraComment( String latestEmailTrail, string issueId ){ 
        
        Http 				http			= new Http();
        HttpRequest 		request 		= new HttpRequest();
        HttpResponse 		response 		= new HttpResponse();
        Blob 				header 			= Blob.valueOf(System.Label.JIRA_Credential);
        String 				authHeader		= 'Basic ' + EncodingUtil.base64Encode(header);
        String 				requestBody 	= JSON.serialize(new Map<String, String>{'body' => latestEmailTrail});
        SuccessErrorWrapper returnWrapper	= new SuccessErrorWrapper();
        
        request.setEndpoint('https://cleartaxtech.atlassian.net/rest/api/2/issue/'+issueId+'/comment');
        request.setHeader('Authorization', authHeader);
        request.setHeader('Content-Type','application/json');
        request.setMethod('POST');
        request.setBody(requestBody);       
        
        system.debug('Response Body: '+response.getBody());
        
        try{
            response = http.send(request);
            returnWrapper.isSuccess = TRUE;
            
            Map<String, Object> getResponseDetails = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            system.debug('getResponseDetails: '+getResponseDetails);
            
            for(String thisSTR : getResponseDetails.keySet()){
                
                system.debug('Key: '+thisSTR);
                system.debug('values: '+getResponseDetails.get(thisSTR));
                if(thisSTR.contains('id')){
                    returnWrapper.commentId = (String)getResponseDetails.get(thisSTR);
                }
            }
            
        }catch(system.CalloutException e) {
            returnWrapper.isSuccess = FALSE;
            returnWrapper.errorMessage = e.getMessage();
        } 
        
        
        return returnWrapper;
    }
    
    Public Class SuccessErrorWrapper{
        
        Public Boolean 	isSuccess;
        Public String	errorMessage;
        Public String	commentId;
    }
}