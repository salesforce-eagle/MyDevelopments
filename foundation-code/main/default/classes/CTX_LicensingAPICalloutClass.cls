/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-22-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_LicensingAPICalloutClass {
    
    public static HttpResponse workspaceSuggestionCallout(Set<String> emailIds, String licenseId, String saasProduct, String region){
        
        RequestWrapper reqWrap = new RequestWrapper();
        reqWrap.emailIds    = emailIds;
        reqWrap.licenseId   = licenseId;
        reqWrap.saasProduct = saasProduct;
        
        String json_Body = JSON.serialize(reqWrap);
        System.debug('json_Body: '+json_Body);
        
        String endPoint;
        String apitoken;
        if(region == 'India'){
            apitoken = System.Label.SalesSyncService_X_Api_Token;
            endPoint = System.Label.SalesSync_Base_URI_India + System.Label.SalesSyncService_Workspace_Suggestion;
        } else {
            apitoken = System.Label.SalesSyncService_X_Api_Token_GCC;
            endPoint = System.Label.SalesSync_Base_URI_GCC + System.Label.SalesSyncService_Workspace_Suggestion;
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint + '/?region=' + region.replace(' ', '+'));
        req.setHeader('X-Api-Token', apitoken);
        req.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        req.setMethod('POST');
        req.setBody(json_Body);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        HttpResponse        response    = new http().send(req);
        return response;
    }
    
    public static HttpResponse addWorkspaceToAssetcallout(String licenseId, String productEmailID, Set<String> workspaces, String region){
        
        RequestAddRemoveWorkspaceWrapper reqWrap = new RequestAddRemoveWorkspaceWrapper();
        reqWrap.licenseId   	= licenseId;
        reqWrap.workspaces  	= workspaces;
        reqWrap.productEmailID 	= productEmailID;
        String json_Body = JSON.serialize(reqWrap);
        System.debug('##json_body:'+json_Body);
        
        String endPoint;
        String apitoken;
        if(region == 'India'){
            apitoken = System.Label.SalesSyncService_X_Api_Token;
            endPoint = System.Label.SalesSync_Base_URI_India + System.Label.SalesSync_Add_Workspace_To_Asset;
        } else {
            apitoken = System.Label.SalesSyncService_X_Api_Token_GCC;
            endPoint = System.Label.SalesSync_Base_URI_GCC + System.Label.SalesSync_Add_Workspace_To_Asset;
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint + '/?region=' + region.replace(' ', '+'));
        req.setHeader('X-Api-Token', apitoken);
        req.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        req.setMethod('POST');
        req.setBody(json_Body);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        HttpResponse  		response 	= new http().send(req);
        System.debug('##json_response:'+response.getBody());
        return response;
    }
    
    public static HttpResponse removeWorkspaceFromAssetcallout(String licenseId, String productEmailID, Set<String> workspaces, String region){
        
        RequestAddRemoveWorkspaceWrapper reqWrap = new RequestAddRemoveWorkspaceWrapper();
        reqWrap.licenseId   = licenseId;
        reqWrap.workspaces  = workspaces;
        reqWrap.productEmailID = productEmailID;
        
        
        String json_Body = JSON.serialize(reqWrap);
        System.debug('##json_body:'+json_Body);
        
        String endPoint;
        String apitoken;
        if(region == 'India'){
            apitoken = System.Label.SalesSyncService_X_Api_Token;
            endPoint = System.Label.SalesSync_Base_URI_India + System.Label.SalesSync_Remove_Workspace_From_Asset;
        } else {
            apitoken = System.Label.SalesSyncService_X_Api_Token_GCC;
            endPoint = System.Label.SalesSync_Base_URI_GCC + System.Label.SalesSync_Remove_Workspace_From_Asset;
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint + '/?region=' + region.replace(' ', '+'));
        req.setHeader('X-Api-Token', apitoken);
        req.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        req.setMethod('POST');
        req.setBody(json_Body);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        HttpResponse        response    = new http().send(req);
        System.debug('##json_response:'+response.getBody());
        return response;
    }
    
    public static HttpResponse upsertAssetCallout(String json_Body, String origin){
        
        String endPoint;
        String apitoken;
        if(origin == 'India'){
            apitoken = System.Label.SalesSyncService_X_Api_Token;
            endPoint = System.Label.SalesSync_Base_URI_India + System.Label.SalesSync_Upsert_Asset_Endpoint;
        } else {
            apitoken = System.Label.SalesSyncService_X_Api_Token_GCC;
            endPoint = System.Label.SalesSync_Base_URI_GCC + System.Label.SalesSync_Upsert_Asset_Endpoint;
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setHeader('X-Api-Token', apitoken);
        req.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        req.setMethod('POST');
        req.setBody(json_Body);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        HttpResponse        response    = new http().send(req);
        return response;
    }
    
    public static HttpResponse upsertAssetCallout_AutoRenewal(String json_Body, String licenseId){
        
        String endPoint;
        String apitoken;

            apitoken = System.Label.SalesSyncService_X_Api_Token;
            endPoint = System.Label.SalesSync_Base_URI_India + System.Label.CTX_RenewLicense_EP+licenseId+'/action/renew-license';
        system.debug('endPoint: '+endPoint);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setHeader('X-Api-Token', apitoken);
        req.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        req.setMethod('POST');
        req.setBody(json_Body);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        HttpResponse        response    = new http().send(req);
        return response;
    }
    
      public static HttpResponse upsertAssetCallout_AutoRenewal_Offline (String json_Body, String licenseId){
        
        String endPoint;
        String apitoken;

            apitoken = System.Label.SalesSyncService_X_Api_Token;
            endPoint = System.Label.SalesSync_Base_URI_India + System.Label.CTX_RenewLicense_EP+licenseId+'/action/update-renew-status';
        system.debug('endPoint: '+endPoint);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setHeader('X-Api-Token', apitoken);
        req.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        req.setMethod('PUT');
        req.setBody(json_Body);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        HttpResponse        response    = new http().send(req);
        return response;
    }
    
    public static HttpResponse deactivateLicenseCallout(String licenseId, String region){
        
        String endPoint;
        String apitoken;
        if(region == 'India'){
            apitoken = System.Label.SalesSyncService_X_Api_Token;
            endPoint = System.Label.SalesSync_Base_URI_India + System.Label.SalesSync_License_Deactivation_Endpoint;
        } else {
            apitoken = System.Label.SalesSyncService_X_Api_Token_GCC;
            endPoint = System.Label.SalesSync_Base_URI_GCC + System.Label.SalesSync_License_Deactivation_Endpoint;
        }
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endPoint + licenseId + '/?region=' + region.replace(' ', '+'));
        req.setHeader('X-Api-Token', apitoken);
        req.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        HttpResponse response = new Http().send(req);
        return response;
    }
    
    public static HttpResponse bulkDeactivateLicenseCallout(List<String> licenseIds, String region){
        
        String endPoint;
        String apitoken;
        if(region == 'India'){
            apitoken = System.Label.SalesSyncService_X_Api_Token;
            endPoint = System.Label.SalesSync_Base_URI_India + System.Label.SalesSync_Bulk_License_Deactivation;
        } else {
            apitoken = System.Label.SalesSyncService_X_Api_Token_GCC;
            endPoint = System.Label.SalesSync_Base_URI_GCC + System.Label.SalesSync_Bulk_License_Deactivation;
        }
        
        RequestBulkDeactivationWrapper requestBody = new RequestBulkDeactivationWrapper();
        requestBody.externalIds = licenseIds;
        requestBody.deLinkAsset = TRUE;
        
		String json_body = JSON.serialize(requestBody);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endPoint + '/?region=' + region.replace(' ', '+'));
        req.setHeader('X-Api-Token', apitoken);
        req.setBody(json_Body);
        req.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        HttpResponse response = new Http().send(req);
        return response;
    }
    
    public static HttpResponse extendLicenseCallout(String licenseId, Integer numberOfDays, String region){
        
        String endPoint;
        String apitoken;
        if(region == 'India'){
            apitoken = System.Label.SalesSyncService_X_Api_Token;
            endPoint = System.Label.SalesSync_Base_URI_India + System.Label.SalesSync_Extend_License;
        } else {
            apitoken = System.Label.SalesSyncService_X_Api_Token_GCC;
            endPoint = System.Label.SalesSync_Base_URI_GCC + System.Label.SalesSync_Extend_License;
        }
        
        HttpRequest req = new HttpRequest();
        String requestbody = '{ "noOfDays": ' + numberOfDays + ' }';
        if(region == NULL || region == '')
            region = 'INDIA';
        system.debug('requestbody: '+requestbody);
        req.setMethod('POST');
        req.setBody(requestbody);
        req.setEndpoint(endPoint + licenseId + '/?region=' + region.replace(' ', '+'));
        system.debug('End Point: '+System.Label.SalesSync_Extend_License + licenseId + '/?region=' + region);
        req.setHeader('X-Api-Token', apitoken);
        req.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        HttpResponse response = new Http().send(req);
        
        return response;
    }
    
    public static HttpResponse fetchGSTLicenses(String emailId, String region){
        
        String endPoint;
        String apitoken;
        if(region == 'India'){
            apitoken = System.Label.SalesSyncService_X_Api_Token;
            endPoint = System.Label.SalesSync_Base_URI_India + System.Label.SalesSync_Fetch_GST_License + emailId + '/action/fetch';
        } else {
            apitoken = System.Label.SalesSyncService_X_Api_Token_GCC;
            endPoint = System.Label.SalesSync_Base_URI_GCC + System.Label.SalesSync_Fetch_GST_License + emailId + '/action/fetch';
        }
        
        HttpRequest req = new HttpRequest();
        if(region == NULL || region == '')
            region = 'INDIA';
        req.setMethod('GET');
        req.setEndpoint(endPoint + '/?region=' + region.replace(' ', '+'));
        req.setHeader('X-Api-Token', apitoken);
        req.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        HttpResponse response = new Http().send(req);
        
        return response;
    }
    
    public class RequestWrapper {
        Public Set<String> emailIds = new Set<String>();
        public string licenseId{get;set;}
        public string saasProduct{get;set;}
    }
    
    public class RequestBulkDeactivationWrapper {
        Public List<String> externalIds = new List<String>();
        public Boolean deLinkAsset 		= FALSE;
    }
    
    public class RequestAddRemoveWorkspaceWrapper {
        public string 		licenseId{get;set;}
        Public Set<String> 	workspaces{get;set;}
        public String 		productEmailID {get;set;}
    }
    
    /**	Update KAM CSM API	**/
    public static HttpResponse updateKAMCSMDetails(String json_Body, String origin){
        
        String endPoint;
        String apitoken;
        if(origin == 'India'){
            apitoken = System.Label.SalesSyncService_X_Api_Token;
            endPoint = System.Label.SalesSync_Base_URI_India + System.Label.SalesSync_Update_CSM_KAM_API_Endpoint;
            //https://salessyncservice-prod-pub.internal.cleartax.co/v0/public/license/salesforce/f926ed1e-64bc-4ff3-b49c-7349c732cb6a/action/update-account-details
        } else {
            apitoken = System.Label.SalesSyncService_X_Api_Token_GCC;
            endPoint = System.Label.SalesSync_Base_URI_GCC + System.Label.SalesSync_Upsert_Asset_Endpoint;
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setHeader('X-Api-Token', apitoken);
        req.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        req.setMethod('PUT');
        req.setBody(json_Body);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        HttpResponse        response    = new http().send(req);
        return response;
    }
    /**	**/
    
}