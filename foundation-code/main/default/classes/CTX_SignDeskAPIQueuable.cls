public class CTX_SignDeskAPIQueuable implements Queueable, Database.AllowsCallouts {
    
    String documentId, docketId;
    
    Public CTX_SignDeskAPIQueuable(String documentId, String docketId){
        
        this.documentId =  documentId;
        this.docketId 	=  docketId;
    }
    
    
    public void execute(QueueableContext context) {

        Http 								http				= new Http();
        HttpRequest 						req 				= new HttpRequest();
        HttpResponse 						res 				= new HttpResponse();
        CTX_SignDeskRevokeAPI.MyRequestBody	requestBody 		= new CTX_SignDeskRevokeAPI.MyRequestBody(documentId, docketId);
        
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
            System.debug('Reovke Failed: '+getResponseDetails.get('message'));
            } else{ }
        }
    }
}