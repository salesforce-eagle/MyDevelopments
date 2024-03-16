public class CTX_FetchCompanyDetails {
    public static CompanyInfoWrapper fetchCompanyInfo(String gstin, Id billingId)  {
        
        HttpRequest 	  	request     						= 	new HttpRequest();
        
        CompanyInfoWrapper  responseWrapper   					= 	new CompanyInfoWrapper();
        List<Logger__c>   logFaliures      		= new List<Logger__c>();
        request.setEndpoint(System.Label.GST_Portal_Endpoint + gstin);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-cleartax-auth-token', System.Label.GST_ApiToken);
        
        Http 				http 								= 	new Http();
        
        HTTPResponse 		response 							= 	http.send(request);
        
        
        
        if (response.getStatusCode() == 200) { 
            
            System.debug('@response: '+ response.getBody());
            
            Map<String, Object> responseMap 					= 	(Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            Map<String, Object> taxPayerInfo 					= 	(Map<String, Object>) responseMap.get('taxPayerInfo');
            
            Map<String, Object> principalAddress = new  Map<String, Object>();
            
            Map<String, Object> billingAddress = new Map<String, Object>();
            
            if(taxPayerInfo != NULL){
                
                if(taxPayerInfo.get('principalAddress') != NULL ){
                    principalAddress  = (Map<String, Object>) taxPayerInfo.get('principalAddress');
                }
                
                
                if(principalAddress != NULL) {
                    billingAddress 	= 	(Map<String, Object>) principalAddress.get('address');
                }               
                
                
                
                Additional_GSTIN__c  companyInfo = new Additional_GSTIN__c (Id 	= 	billingId);
                
                companyInfo.Name_Of_The_Customer__c   = 	(String) taxPayerInfo?.get('legalBusinessName');
                
                if(((String) taxPayerInfo.get('taxpayerType')).containsIgnoreCase('SEZ')){
                    
                    companyInfo.SEZ_Yes_No__c   						= 	'Yes';
                    
                }else{
                    
                    companyInfo.SEZ_Yes_No__c   						= 	'No';
                    
                }
                
                companyInfo.Billing_PAN__c  				= 	(String) taxPayerInfo.get('pan');
                String billingCity = '';
                if(billingAddress != NULL){
                    
                    billingCity = ((String) billingAddress?.get('city') != 'null' && (String) billingAddress?.get('city') != NULL &&(String) billingAddress?.get('city') != '') ? (String) billingAddress.get('city') :(String) billingAddress?.get('district');
                    
                    companyInfo.Address__c  					= 	(String) billingAddress?.get('doorNumber') 	+ ' ' + 
                        (String) billingAddress?.get('buildingName') + ' ' + 
                        (String) billingAddress?.get('floorNumber')  + ' ' +
                        (String) billingAddress?.get('street') 		+ ' ' +
                        (String) billingAddress?.get('locality') 	+ ' ' +
                         		 billingCity     					+ ' ' +
                        (String) billingAddress?.get('district') 	+ ' ' +
                        (String) billingAddress?.get('stateName') 	+ ' ' +
                        (String) billingAddress?.get('pinCode');
                }
                
                
                
                companyInfo.Address_Line_2__c  					= 	companyInfo?.Address__c;
                
                companyInfo.Pincode__c  							= 	(String) billingAddress?.get('pinCode');
                
                companyInfo.City__c     						= 	billingCity;
                
                companyInfo.State__c  							= 	(String) billingAddress?.get('stateName');
                
                companyInfo.Place_of_supply__c 					= 	(String) billingAddress?.get('stateName');
                
                responseWrapper.isSuccess 						= 	TRUE;
                
                responseWrapper.billingInfo = companyInfo;
                
            }else{
                
                responseWrapper.isSuccess 						= 	FALSE;
                responseWrapper.logFailure = CTX_LoggerImplementation.createLoggerInstance(
                    response.getBody(),
                    NULL,
                    'CTX_GstCompanyInfo',
                    'CTX_GstCompanyInfo.fetchCompanyInfo()',
                    'TaxPayerInfo Not Found',
                    billingId,
                    'Additional_GSTIN__c' 
                );
                
            }
            
        }else{
            
            responseWrapper.isSuccess 							= 	FALSE;
            responseWrapper.logFailure = CTX_LoggerImplementation.createLoggerInstance(
                response.getBody(),
                NULL,
                'CTX_GstCompanyInfo',
                'CTX_GstCompanyInfo.fetchCompanyInfo()',
                'Callout Failure',
                billingId,
                'Additional_GSTIN__c' 
            );
            
            
            
        }
        
        if(!logFaliures.isEmpty()){
            Insert logFaliures;
        }
        
        return responseWrapper;
        
    }
    
    Public Class CompanyInfoWrapper{
        
        Public Additional_GSTIN__c 		billingInfo;
        Public Logger__c 				logFailure;
        Public Boolean 					isSuccess;
        
    }
}