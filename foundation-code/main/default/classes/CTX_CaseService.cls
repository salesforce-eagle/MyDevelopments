@RestResource(urlMapping='/ticketingService/*')
global class CTX_CaseService {
    
    @HttpGet
    global static String getCaseDetails(){
        
        RestRequest 				request					=  RestContext.request;
        String      				productEmail         	=  request?.params.get('productEmail');
        system.debug('productEmail: '+productEmail);
        List<CTX_ServiceWrapper> 	returnCaseDetailsList	= new List<CTX_ServiceWrapper>();
        
        
        if( !string.isBlank(productEmail) ){
            
            system.debug('Inside Block to get Case Details');
            for( 
                Case thisCase: [ SELECT Id, CaseNumber, Status 
                                FROM Case WHERE 
                                Account.Product_Email__c = :productEmail AND 
                                Status != 'Closed' ]	/**	CA/SME(0) or Enterprise(1)	**/
            ){
                
                CTX_ServiceWrapper returnDetails 	= new CTX_ServiceWrapper();
                returnDetails.caseId 				= thisCase.id;
                returnDetails.caseNumber 			= thisCase.CaseNumber;
                returnDetails.status 				= thisCase.status;
                returnDetails.isReOpenable			= thisCase.Status == 'Solved' ? TRUE : FALSE;
                
                returnCaseDetailsList.add(returnDetails);
            }
        }
        
        if(returnCaseDetailsList != NULL && returnCaseDetailsList.size() > 0 ){
            return JSON.serialize(returnCaseDetailsList);
        } else{
            return 'No open cases found for the customer.';
        }
        
    }
    
    @HttpPost
    global static String upsertCaseDetails(){
        
        RestRequest									request			= RestContext.request;
        String										requestBody		= request.requestBody.toString();
        CTX_CaseServiceParserClass.ReturnWrapper 	returnResponse;
        
        system.debug('caseBody: '+requestBody);
        
        if( requestBody != NULL && requestBody != '' ){
              returnResponse = CTX_CaseServiceParserClass.caseDetailsParser(requestBody);
        }
        
       return JSON.serialize(returnResponse); 
    }
    
}