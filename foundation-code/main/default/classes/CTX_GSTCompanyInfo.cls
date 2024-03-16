/** GSTIN verification API <> SF **/

public class CTX_GSTCompanyInfo {
    
 
     @AuraEnabled
    public static String fetchCompanyInfo(String gstin, Id opportunityId)  {
        
        HttpRequest 	  	request     						= 	new HttpRequest();
        
         List<Logger__c>   logFaliures      		= new List<Logger__c>();
        request.setEndpoint(System.Label.GST_Portal_Endpoint + gstin);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-cleartax-auth-token', System.Label.GST_ApiToken);
        
        Http 				http 								= 	new Http();
        
        HTTPResponse 		response 							= 	http.send(request);
        
        String toastMessage;
       
        
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
                
                Opportunity companyInfo = new Opportunity(Id 	= 	opportunityId);
                
                companyInfo.Legal_Entity_Name_Of_The_Client__c  = 	(String) taxPayerInfo?.get('legalBusinessName');
                
                if(((String) taxPayerInfo.get('taxpayerType')).containsIgnoreCase('SEZ')){
                    
                    companyInfo.If_SEZ__c  						= 	'Yes';
                    
                }else{
                    
                    companyInfo.If_SEZ__c  						= 	'No';
                    
                }
                
                companyInfo.PAN_No_as_per_PO__c 				= 	(String) taxPayerInfo?.get('pan');
                
                String billingCity = '';
                     
                if(billingAddress != NULL){
                    billingCity = ((String) billingAddress?.get('city') != 'null' && (String) billingAddress?.get('city') != NULL &&(String) billingAddress?.get('city') != '') ? (String) billingAddress.get('city') :(String) billingAddress?.get('district');

                    companyInfo.Billing_Address__c  					= 	(String) billingAddress?.get('doorNumber') 	+ ' ' + 
                        (String) billingAddress?.get('buildingName') + ' ' + 
                        (String) billingAddress?.get('floorNumber')  + ' ' +
                        (String) billingAddress?.get('street') 		+ ' ' +
                        (String) billingAddress?.get('locality') 	+ ' ' +
                         		 billingCity						+ ' ' +
                        (String) billingAddress?.get('district') 	+ ' ' +
                        (String) billingAddress?.get('stateName') 	+ ' ' +
                        (String) billingAddress?.get('pinCode');
                }
                
                companyInfo.Shipping_Address__c 				= 	companyInfo?.Billing_Address__c;
                
                companyInfo.Pincode__c 							= 	(String) billingAddress?.get('pinCode');
                
                companyInfo.City_2__c   						= 	billingCity;
                
                companyInfo.State_2__c 							= 	(String) billingAddress?.get('stateName');
                
                companyInfo.Place_of_Supply__c					= 	(String) billingAddress?.get('stateName');
                
                OpportunityConstants.ENABLE_GSTIN_VERIFICATION_RULE = FALSE;
                
                Database.SaveResult sr = Database.Update(companyInfo, false);
                
                if (sr.isSuccess()) {
                    toastMessage = 'Updated Successfully!';
                } else {
                    for (Database.Error err : sr.getErrors()) {
                        toastMessage = 'Error : ' + err.getMessage();
                    }
                }
                
                
                
                
                
               
            }else{

                Map<String, Object> taxPayerErrorResponse = (Map<String, Object>) responseMap.get('taxPayerErrorResponse');
                String ErrorMessage = (String) taxPayerErrorResponse.get('message');
                toastMessage = 'ERROR -'+ErrorMessage; 
                
                logFaliures.add(CTX_LoggerImplementation.createLoggerInstance(
                    response.getBody(),
                    NULL,
                    'CTX_GstCompanyInfo',
                    'CTX_GstCompanyInfo.fetchCompanyInfo()',
                    'TaxPayerInfo Not Found',
                    opportunityId,
                    'Opportunity' 
                ));
                
            }
            
        }else{
            
            logFaliures.add(CTX_LoggerImplementation.createLoggerInstance(
                response.getBody(),
                NULL,
                'CTX_GstCompanyInfo',
                'CTX_GstCompanyInfo.fetchCompanyInfo()',
                'Callout Failure',
                opportunityId,
                'Opportunity' 
            ));
            
             
            
        }
        
        if(!logFaliures.isEmpty()){
            Insert logFaliures;
        }
        
        return toastMessage;
        
    }
    
}