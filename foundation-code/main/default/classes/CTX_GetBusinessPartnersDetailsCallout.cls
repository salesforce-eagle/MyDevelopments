public class CTX_GetBusinessPartnersDetailsCallout {
    
    Public Static String sessionId;
    public static SAP_Integration_Settings__c 	SAP_CONFIGS = SAP_Integration_Settings__c.getOrgDefaults();
    
    public static HttpResponse getBusinessPartnerDetails( String cardCode, String billingEntity ){ // added by Murali
        
        //Added by Murali
        SAP_Integration_Settings_metadata__mdt retrivedMetadata = CTX_SAPAPICallouts.getIntergartionMetadata(billingEntity);
        String sessionId = CTX_SAPAPICallouts.authorize(retrivedMetadata);
        
		system.debug('##sessionId: ' + sessionId);        
        SAP_Integration_Settings__c 			SAP_CONFIGS = SAP_Integration_Settings__c.getOrgDefaults();
        String endPoint = 'https://www.clear-sap.in:50000/b1s/v1/BusinessPartners' + '(CardCode=\''+cardCode+'\')';
        HttpRequest 							request 	= new HttpRequest();
        request.setEndpoint(endPoint);
        system.debug('End Point: '+endPoint);
        system.debug('sessionId: '+sessionId);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Cookie', 'B1SESSION='+sessionId);
        request.setTimeout(90000);
        HttpResponse        response    = new http().send(request);
        system.debug('request: '+request);
        system.debug('response: '+response.getBody());
        return response;
        /*if(response.getStatusCode() == 200){
            //CTX_SAPResponseTrimClass.SAPReturnWrapper businessPartnerDetails = CTX_SAPResponseTrimClass.formatSAPBuisnessPartnersResponse(response.getBody());
            CTX_BusinessPartnersWrapper businessPartnerDetails = (CTX_BusinessPartnersWrapper)JSON.deserialize(response.getBody(), CTX_BusinessPartnersWrapper.class);
            
            system.debug('businessPartnerDetails: '+businessPartnerDetails);
            return businessPartnerDetails;
        } else {
            
            return NULL;
        }*/
    }
    
    public static HttpResponse createBusinessPartner( String businessPartnerJSON, String billingEntity ){
        
        //Added by Murali
        SAP_Integration_Settings_metadata__mdt retrivedMetadata = CTX_SAPAPICallouts.getIntergartionMetadata(billingEntity);
        String sessionId = CTX_SAPAPICallouts.authorize(retrivedMetadata);
        
        system.debug('##sessionId: ' + sessionId);
        String cookie 	= 'B1SESSION='+sessionId; 
        system.debug('Create Business Partner - Cookie: '+cookie);
        
        HttpRequest		request	= new HttpRequest();
        HttpResponse	response;
        
        request.setEndpoint(SAP_CONFIGS.Base_URL__c + '/BusinessPartners');
        request.setBody(businessPartnerJSON);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Cookie', 'B1SESSION='+sessionId);
        request.setTimeout(90000);
        
        response = new http().send(request);
        
        system.debug('createBusinessPartner request: '+request);
        system.debug('createBusinessPartner response: '+response.getBody());
        return response;
    }
    
    public static HttpResponse updateBusinessPartner( String cardCode, String businessPartnerJSON, String billingEntity ){
        //Added by Murali
        SAP_Integration_Settings_metadata__mdt retrivedMetadata = CTX_SAPAPICallouts.getIntergartionMetadata(billingEntity);
        String sessionId = CTX_SAPAPICallouts.authorize(retrivedMetadata);
        
        system.debug('##sessionId: ' + sessionId);
        HttpRequest 							request 	= new HttpRequest();
        request.setEndpoint('https://www.clear-sap.in:50000/b1s/v1/BusinessPartners' + '(CardCode=\''+cardCode+'\')');
        request.setMethod('PATCH');
        request.setBody(businessPartnerJSON);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Cookie', 'B1SESSION='+sessionId);
        request.setTimeout(60000);
        HttpResponse        response    = new http().send(request);
        
        return response;
    }
    
    public static HttpResponse upsertSalesContract(String salesContractJSON, String billingEntity ){
        //Added by Murali
        SAP_Integration_Settings_metadata__mdt retrivedMetadata = CTX_SAPAPICallouts.getIntergartionMetadata(billingEntity);
        String sessionId = CTX_SAPAPICallouts.authorize(retrivedMetadata);
        
        system.debug('##sessionId: ' + sessionId);
        HttpRequest 							request 	= new HttpRequest();
        request.setEndpoint('https://www.clear-sap.in:50000/b1s/v1/AC_OBRDR');
        request.setMethod('POST');
        request.setBody(salesContractJSON);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Cookie', 'B1SESSION='+ sessionId);
        request.setTimeout(60000);
        HttpResponse        response    = new http().send(request);
        
        return response;
    }
    
    
}