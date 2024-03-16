public class CTX_SignDeskRevokeAPI {
    
    @AuraEnabled
    Public Static ReturnWrapper serverTrip(String opportunityRecordId){
        
        ReturnWrapper myResult;
        Opportunity thisOpp = [ SELECT Id, ESign_BE_Document_ID__c, ESign_BE_Docket_ID__c 
                               FROM Opportunity WHERE 
                               Id = :opportunityRecordId 
                               LIMIT 1 ];
        if(thisOpp != NULL){
            myResult = callout_SDrevokeAPI(thisOpp.ESign_BE_Document_ID__c, thisOpp.ESign_BE_Docket_ID__c);
        } else{
            myResult.isSuccess 		= FALSE;
            myResult.errorMessage	= 'Bad Input.';
            
        }
        system.debug('myResult: '+myResult);
        
        return myResult;
    }
    
    @AuraEnabled
    Public static ReturnWrapper callout_SDrevokeAPI(String documentId, String docketId){
        ReturnWrapper myResult = new ReturnWrapper();
        
        Http 			http				= new Http();
        HttpRequest 	req 				= new HttpRequest();
        HttpResponse 	res 				= new HttpResponse();
        MyRequestBody	requestBody 		= new MyRequestBody(documentId, docketId);
        
        /**	Construct callout Request : START	**/
        req.setEndpoint(System.Label.SignDesk_EndPoint_URL);
        req.setMethod('POST');
        
        req.setHeader('x-parse-rest-api-key', System.Label.SignDesk_API_Key);
        req.setHeader('x-parse-application-id', System.Label.SignDesk_Application_Id);
        req.setHeader('Content-Type', 'application/json');
        
        req.setBody(JSON.serialize(requestBody));
        /**	Construct callout Request : END	**/
        
        /**	Send Request : START	**/
        res = http.send(req);
        /**	Send Request : END	**/
        
        /**	Operate on Response	**/
        Map<String, Object> getResponseDetails = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        
        if(getResponseDetails != NULL){
            if(getResponseDetails.get('status') == 'failed'){
                
                myResult.isSuccess 		= FALSE;
                myResult.errorMessage	= 'Please contact your System Admin with the details below: \n Status Code: '+getResponseDetails.get('error_code')+'\n Error Message: '+getResponseDetails.get('message');
            } else{
                myResult.isSuccess 		= TRUE;
                myResult.errorMessage	= 'Revoked Successfully.';
            }
        }
        
        return myResult; 
    }
    
    
    Public Class MyRequestBody{
        public string document_id;
        public string docket_id;
        
        Public MyRequestBody(String documentId, String docketId){
            this.document_id 	= documentId;
            this.docket_id		= docketId;
        }
    }
    
    Public Class ReturnWrapper{
        
        @AuraEnabled
        Public Boolean isSuccess;
        
        @AuraEnabled
        Public String errorMessage;
    }
    
}