public class CTX_SAPAPICallouts {
    
    public static Cache.OrgPartition 			orgPart 	= Cache.Org.getPartition('local.SAPSessionManagement');
    public static SAP_Integration_Settings__c 	SAP_CONFIGS = SAP_Integration_Settings__c.getOrgDefaults();
    
    public static String authorize(SAP_Integration_Settings_metadata__mdt retrivedMetadata){
        
        if(orgPart.contains('SAPSessionId')){
            return (String)orgPart.get('SAPSessionId'); 
        } else{
            refreshToken(retrivedMetadata);
            return (String)orgPart.get('SAPSessionId');
        }
    }
    
    public static void refreshToken(SAP_Integration_Settings_metadata__mdt retrivedMetadata){
        
        String sessionId = login(retrivedMetadata);
        orgPart.put('SAPSessionId', sessionId);
    }
    
    public static String login(SAP_Integration_Settings_metadata__mdt retrivedMetadata){
        
        system.debug('retrivedMetadata in calllout'+retrivedMetadata);
        LoginRequestWrapper requestBody 	= new LoginRequestWrapper();
        requestBody.CompanyDB 				= retrivedMetadata.Company_DB__c;
        requestBody.UserName 				= retrivedMetadata.Username__c;
        requestBody.Password 				= retrivedMetadata.Password__c;
        
        HttpRequest 		request		 	= new HttpRequest();
        HttpResponse        response;
        
        request.setEndpoint(retrivedMetadata.Base_URL__c + '/Login');
        request.setMethod('POST');
        request.setBody(JSON.serialize(requestBody));
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(90000);
        response = new http().send(request);
        
        system.debug('SessionId response body: '+ response.getBody());
        
        if(response.getStatusCode() == 200){
            Map<String, Object>	responseMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            
            return String.valueOf(responseMap.get('SessionId'));    
        } else {
            /**	Error Handling	**/
            List<Logger__c>           updateSnag      			= new List<Logger__c>();
            updateSnag.add(
                CTX_LoggerImplementation.createLoggerInstance(
                    response.getBody(),
                    NULL,
                    'CTX_SAPAPICallouts',
                    'CTX_SAPAPICallouts.login()',
                    'SAP Callout Failure',
                    NULL,
                    'Additional_GSTIN__c')
            );
            
            if(updateSnag.size() > 0){
                insert updateSnag;
            }
            
            return NULL; 
        }
        
    }
    
    public class LoginRequestWrapper {
        public String CompanyDB {get;set;}
        public String UserName {get;set;}
        public String Password {get;set;}
    }
    
    public static SAP_Integration_Settings_metadata__mdt getIntergartionMetadata(String billingEntity){
        
        Map<String,SAP_Integration_Settings_metadata__mdt> sapMetadata = SAP_Integration_Settings_metadata__mdt.getAll();

        return sapMetadata.containskey(billingEntity) ? sapMetadata.get(billingEntity) : NULL;
    }
}