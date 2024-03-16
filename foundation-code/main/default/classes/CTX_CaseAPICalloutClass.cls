/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_CaseAPICalloutClass {
    
    public static HttpResponse caseUpdateCallout(String reqBody, String productId, String environmentVariable){
        String endPoint 	= '';
        String apitoken 	= '';
        
        if(environmentVariable == 'Sandbox'){
            endPoint = System.Label.Support_Case_API_End_Point_Sandbox;
            apitoken = System.Label.Support_Case_API_Token_Sandbox;
        } else {
            endPoint = System.Label.Support_Case_API_End_Point;
            apitoken = System.Label.Support_Case_API_Token;
        } 
        //String endPoint 	= 'https://salessyncservice-qa-pub.internal.cleartax.co/v0/support-ticket/public';
        //  String apitoken 	= 'a8388878-5391-46cc-b2c0-0c1051e87e7c';
        String json_Body 	= reqBody;
        
        if( endPoint != '' &&  apitoken != '' ){
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint + '/' + productId + '/status');
            req.setHeader('X-Api-Token', apitoken);
            //req.setHeader('x-cleartax-user', UserInfo.getUserEmail());
            req.setMethod('PUT');
            req.setBody(json_Body);
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(12000);
            HttpResponse        response    = new http().send(req);
            return response;
        } else{
            return NULL;
        }
        
    }
}