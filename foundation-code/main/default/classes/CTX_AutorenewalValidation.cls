public class CTX_AutorenewalValidation {
    
    @AuraEnabled
    public static string fetchUsageDetails(String licenseId, Id accountId){
        
        String responseMessage = '';
        
        HttpRequest 	request 		= new HttpRequest();
        HttpResponse 	response 		= new HttpResponse();
        
        request.setMethod( 'POST' );
        request.setEndpoint( 
            System.Label.SalesSync_Base_URI_India + 
            System.Label.CTX_FetchUsageDetails_EP +
            licenseId + '/action/validate-auto-renewals' 
        );
        request.setHeader( 'X-Api-Token', System.Label.SalesSyncService_X_Api_Token );
        request.setHeader( 'x-cleartax-user', UserInfo.getUserEmail() );
        request.setHeader( 'Content-Type', 'application/json' );
        
        try{
            
            response 						= new Http().send(request);
            String				licenselog 	= response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(licenselog);
            
            system.debug( '@getResponse Body: '			+response.getBody() );
            system.debug( '@getResponse Status Code: '	+response.getStatusCode() );
            
            List<Account> getAccountDetails = [ SELECT Id, Is_Auto_Renewal_Validated__c, Is_Auto_Renewal_Enabled__c 
                                               FROM Account WHERE 
                                               Id =: accountId LIMIT 1 ];
            
            if( response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
                
                CTX_LicenseMetadataParser.LicenseWrapper licenseWrap = CTX_LicenseMetadataParser.convertLicenseDetails(licenselog);
                system.debug( '@licenseWrap: '+licenseWrap );
                
                System.debug('@accountId'+accountId);
                //if( getAccountDetails[0].Is_Auto_Renewal_Validated__c == FALSE ){
                    
                    Account updateAccount = new Account( 
                        Id = accountId,  
                        Is_Auto_Renewal_Validated__c = TRUE,
                        Auto_Renewal_Validation_Error__c = 'Successfully Validated.'
                    );
                    update updateAccount;
                
                    responseMessage = 'Successfully Validated.';
                //}
                
            } else if( response.getStatusCode() == 400 ){
                if( responseMap.containsKey('errorMessage') && responseMap.containsKey('errorCode') ){
                    if( (String)responseMap.get('errorMessage') != NULL && (Integer)responseMap.get('errorCode') == 400 ){
                        
                        //if( getAccountDetails[0].Is_Auto_Renewal_Validated__c == TRUE ){
                            Account updateAccount = new Account( 
                                Id = accountId,  
                                Is_Auto_Renewal_Validated__c = FALSE, 
                                Is_Auto_Renewal_Enabled__c = FALSE,
                                Auto_Renewal_Validation_Error__c = (String)responseMap.get('errorMessage')
                            );
                            update updateAccount;
                        
                         responseMessage = (String)responseMap.get('errorMessage');
                       // }
                    }
                }
            }
        }catch(system.CalloutException e) {
            system.debug('Callout Error ==> '+ e);
            responseMessage = e.getMessage();
        }
        
        return JSON.serializePretty(responseMessage);
    }
    
    
    
}