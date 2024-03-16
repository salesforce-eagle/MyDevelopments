public class CTX_GSTINVerificationCalloutBatch IMPLEMENTS Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {
    
    Public String 	query;
    Public String	type;
    
    public CTX_GSTINVerificationCalloutBatch( String type, String queryString ){
        this.query 	= queryString;
        this.type 	= type;
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String queryString;
        
        if( type == 'Query' ){
            queryString = query;
        } else if( type == 'FileId' ){
            
            ContentVersion 		contentDocumentVersionDetails	= [ SELECT VersionData FROM ContentVersion WHERE 
                                                                   ContentDocumentId =: query AND 
                                                                   IsLatest = TRUE ];
            Blob 				versionDataStringBody 			= contentDocumentVersionDetails.VersionData;
            List<String> 		columnLiner						= versionDataStringBody.tostring().split('\n');
            Set<String>			opportunityIds					= new Set<String>();
            
            for( Integer i = 1; i < columnLiner.size(); i++ ){
                opportunityIds.add( columnLiner[i].split(',')[0].trim() );
            }
            system.debug('opportunityIds: '+opportunityIds.size());
            
            queryString = ' SELECT Id, Name, Billing_GST__c, GSTIN_Error_Message__c FROM Opportunity WHERE Id IN :opportunityIds ';
        }
        
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(SchedulableContext SC) { 
        database.executeBatch(new CTX_GSTINVerificationCalloutBatch( 
            'Query',
            ' SELECT Id, Name, Billing_GST__c, GSTIN_Error_Message__c FROM Opportunity WHERE Opportunity.Account.Is_Auto_Renewal_Enabled__c = TRUE AND ( Enable_GST_Auto_Renewal__c = TRUE OR Enable_E_Invoicing_Auto_Renewal__c = TRUE ) '
        ), 30 );
    }
    
    public void execute( Database.BatchableContext BC, List<Opportunity> scope ){
        calloutGSTINAPI(scope);
    }
    
    public void finish(Database.BatchableContext BC){ }
    
    public static void calloutGSTINAPI( List<Opportunity> opportunitiesToProcess ){
        
        
        for( Opportunity thisOpp : opportunitiesToProcess ){
            
            HttpRequest 	gstinRequest	= new HttpRequest();
            Http			httpReq			= new Http();
            
            gstinRequest.setEndpoint(System.Label.GST_Portal_Endpoint + thisOpp.Billing_GST__c );
            gstinRequest.setMethod('GET');
            gstinRequest.setHeader('Content-Type', 'application/json');
            gstinRequest.setHeader('x-cleartax-auth-token', System.Label.GST_ApiToken);
            
            HTTPResponse	gstinResponse = httpReq.send(gstinRequest);
            
            if (gstinResponse.getStatusCode() == 200) {
                
                system.debug('@response: '+ gstinResponse.getBody());
                Map<String, Object> responseMap         = (Map<String, Object>)JSON.deserializeUntyped(gstinResponse.getBody());
                if( responseMap.containsKey('taxPayerErrorResponse') ){
                    Map<String, Object> taxPayerInfo		= (Map<String, Object>)responseMap.get('taxPayerErrorResponse');
                    if( taxPayerInfo != NULL ){
                        if( taxPayerInfo.get('errorCode') != NULL ){                                            
                            thisOpp.GSTIN_Error_Message__c = (String)taxPayerInfo.get('message');
                        }
                    }
                }
            } else{
                thisOpp.GSTIN_Error_Message__c = 'Not a valid GSTIN of Opportunity.';
            }
            
        }
        
        
        OpportunityConstants.ENABLE_GSTIN_VERIFICATION_RULE = FALSE;
        RecursiveTriggerHandler.isFirstTimeOpportunity 		= FALSE;
        OpportunityConstants.AUTO_RENEW_RULE 				= FALSE;
        
        update opportunitiesToProcess;
        
        OpportunityConstants.ENABLE_GSTIN_VERIFICATION_RULE = TRUE;
        RecursiveTriggerHandler.isFirstTimeOpportunity 		= TRUE;
        OpportunityConstants.AUTO_RENEW_RULE 				= TRUE;
    }
    
}