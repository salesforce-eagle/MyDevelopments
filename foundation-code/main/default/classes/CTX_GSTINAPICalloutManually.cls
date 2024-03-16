public class CTX_GSTINAPICalloutManually {
    
    public static Set<String> getOpportunityIds( String contentDocumentId ){
        
        ContentVersion 		contentDocumentVersionDetails	= [ SELECT VersionData FROM ContentVersion WHERE 
                                                               ContentDocumentId = :contentDocumentId AND 
                                                               IsLatest = TRUE ];
        Blob 			versionDataStringBody	= contentDocumentVersionDetails.VersionData;
        List<String> 	columnLiner				= versionDataStringBody.tostring().split('\n');
        Set<String>		assetIds	 			= new Set<String>();
        Set<String>		opportunityIds	 		= new Set<String>();
        
        for( Integer i = 1; i < columnLiner.size(); i++ ){
            
            assetIds.add(
                columnLiner[i].split(',')[0].trim()
            );
        }
        system.debug('assetIds: '+assetIds);
        system.debug('assetIds size: '+assetIds.size());
        
        for( 
            Asset thisRec : [ SELECT Id, 
                             Opportunity__c, Opportunity__r.Billing_Address__c, Opportunity__r.Shipping_Address__c, Opportunity__r.State_2__c,
                             Renewal_Opportunity__c, Renewal_Opportunity__r.Billing_Address__c, Renewal_Opportunity__r.Shipping_Address__c, Renewal_Opportunity__r.State_2__c
                             FROM Asset WHERE Id IN :assetIds ] 
        ){
            
            if( 
                thisRec.Renewal_Opportunity__c != NULL &&
                (
                    thisRec.Renewal_Opportunity__r.Billing_Address__c == NULL ||
                    thisRec.Renewal_Opportunity__r.Shipping_Address__c == NULL || 
                    thisRec.Renewal_Opportunity__r.State_2__c == NULL
                )
            ){
                opportunityIds.add(thisRec.Renewal_Opportunity__c);
            } else if( 
                thisRec.Opportunity__c != NULL &&
                (
                    thisRec.Opportunity__r.Billing_Address__c == NULL ||
                    thisRec.Opportunity__r.Shipping_Address__c == NULL || 
                    thisRec.Opportunity__r.State_2__c == NULL
                )
            ){
                opportunityIds.add(thisRec.Opportunity__c);
            } 
            
            
        }
        
        system.debug('opportunityIds: '+opportunityIds);
        system.debug('opportunityIds size: '+opportunityIds.size());
        return opportunityIds;
    }
    
    
    public static List<Opportunity> getGSTINDetailsAndUpdateOpportunity( Set<String> opportunityIds ){
        
        List<Opportunity> updateOpportunities = new List<Opportunity>();
        
        for( Opportunity thisRec : [ SELECT Id, Billing_GST__c 
                                    FROM Opportunity WHERE 
                                    Id IN :opportunityIds LIMIT 90 ]
           ){
               
               if( thisRec.Billing_GST__c != NULL ){
                   
                   HttpRequest request		= new HttpRequest();
                   Http			http		= new Http();
                   HTTPResponse	response;
                   request.setEndpoint(System.Label.GST_Portal_Endpoint + thisRec.Billing_GST__c);
                   request.setMethod('GET');
                   request.setHeader('Content-Type', 'application/json');
                   request.setHeader('x-cleartax-auth-token', System.Label.GST_ApiToken);
                   response = http.send(request);
                   
                   if (response.getStatusCode() == 200) { 
                       
                       System.debug('@response: '+ response.getBody());
                       Map<String, Object> responseMap         = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                       Map<String, Object> taxPayerInfo		= (Map<String, Object>)responseMap.get('taxPayerInfo');
                       Map<String, Object> principalAddress 	= new  Map<String, Object>();
                       Map<String, Object> billingAddress 		= new Map<String, Object>();
                       
                       if(taxPayerInfo != NULL){
                           
                           if( taxPayerInfo.get('principalAddress') != NULL ){
                               principalAddress = (Map<String, Object>) taxPayerInfo.get('principalAddress');
                           }
                           if( principalAddress != NULL ) {
                               billingAddress = (Map<String, Object>) principalAddress.get('address');
                           }  
                           
                           String billingCity = '';
                           if(billingAddress != NULL){
                               billingCity = ((String) billingAddress?.get('city') != 'null' && (String) billingAddress?.get('city') != NULL &&(String) billingAddress?.get('city') != '') ? (String) billingAddress.get('city') :(String) billingAddress?.get('district');
                               
                           }
                           
                           Opportunity companyInfo = new Opportunity(
                               Id 									= thisRec.Id,
                               Legal_Entity_Name_Of_The_Client__c 	= (String)taxPayerInfo?.get('legalBusinessName'),
                               If_SEZ__c 							= ((String)taxPayerInfo.get('taxpayerType')).containsIgnoreCase('SEZ') ? 'Yes' : 'No',
                               PAN_No_as_per_PO__c 				= (String)taxPayerInfo?.get('pan'),
                               Pincode__c							= (String)billingAddress?.get('pinCode'),
                               City_2__c                           = billingCity,
                               State_2__c                          = (String)billingAddress?.get('stateName'),
                               Place_of_Supply__c                  = (String)billingAddress?.get('stateName')
                           );
                           companyInfo.Billing_Address__c			=   
                               (String) billingAddress?.get('doorNumber')  + ' ' + 
                               (String) billingAddress?.get('buildingName') + ' ' + 
                               (String) billingAddress?.get('floorNumber')  + ' ' +
                               (String) billingAddress?.get('street')      + ' ' +
                               (String) billingAddress?.get('locality')    + ' ' +
                               billingCity                        + ' ' +
                               (String) billingAddress?.get('district')    + ' ' +
                               (String) billingAddress?.get('stateName')   + ' ' +
                               (String) billingAddress?.get('pinCode');
                           companyInfo.Shipping_Address__c			= companyInfo?.Billing_Address__c;
                           companyInfo.Shipping_Address__c			= companyInfo?.Billing_Address__c;
                           
                           updateOpportunities.add(companyInfo);
                       }
                   }
               }
           }
        
        
        system.debug( 'updateOpportunities size: '+updateOpportunities.size() );
        return updateOpportunities;
    }
    
    
    public static void executeLogic( String contentDocumentId ){
        
        if( String.isNotBlank(contentDocumentId) ){
            Set<String> opportunityIds = getOpportunityIds(contentDocumentId);
            List<Opportunity> updateOpportunities =getGSTINDetailsAndUpdateOpportunity(opportunityIds);
            
            system.debug( 'updateOpportunities in Execute size: '+updateOpportunities.size() );
            OpportunityConstants.ENABLE_GSTIN_VERIFICATION_RULE = FALSE;
            RecursiveTriggerHandler.isFirstTimeOpportunity = FALSE;
            update updateOpportunities;
            RecursiveTriggerHandler.isFirstTimeOpportunity = TRUE;
        }
        
    }
    
}