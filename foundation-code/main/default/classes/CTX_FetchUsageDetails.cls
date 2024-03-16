/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-01-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_FetchUsageDetails implements Queueable, Database.AllowsCallouts{
    
    String 	licenseId;
    Id 		accountId;
    Map<Id, Asset> astMapToEnableAutoRenew;
    Map<String, String> assetAccountMap;
    
    Public CTX_FetchUsageDetails( String licenseId, Id accountId, Map<Id, Asset> astMapToEnableAutoRenew, Map<String, String> assetAccountMap ){
        this.licenseId = licenseId;
        this.accountId = accountId;
        this.astMapToEnableAutoRenew = astMapToEnableAutoRenew;
        this.assetAccountMap = assetAccountMap;
    }
    
    public void execute(QueueableContext context){
        
        Map<Id, String>								accountIdAndFailure	= new Map<Id, String>{ accountId => NULL };
            String									failureMessage;
        List<Account> 								accountsFailed 		= new List<Account>();
        List<Opportunity> 							opportunitysFailed 	= new List<Opportunity>();
        List<Auto_Renew_Whitelisting_Failure__e>   	failureEvents   	= new List<Auto_Renew_Whitelisting_Failure__e>();
        Boolean 									updateUsagePrice 	= FALSE;
        String										pathParams;
        
        for( Asset thisRec : astMapToEnableAutoRenew.values() ){
            if( thisRec.Product2.Product_Line__c == 'E-invoicing & E-Way Bill' ){
                pathParams = 'resourcesToFetch=EWB_GENERATION&resourcesToFetch=GSTIN_ADDITION&resourcesToFetch=IRN_GENERATION&resourcesToFetch=PAN_ADDITION&resourcesToFetch=USER_ADDITION';
            } else if( thisRec.Product2.Product_Line__c == 'GST' ){
                pathParams = 'resourcesToFetch=ACTIVE_GSTINS&resourcesToFetch=PURCHASE_INVOICE&resourcesToFetch=USER_ADDITION&resourcesToFetch=ACTIVE_PANS';
            } else if( thisRec.Product2.Product_Line__c == 'Max' ){
                pathParams = 'resourcesToFetch=PAN_ADDITION&resourcesToFetch=GSTIN_ADDITION&resourcesToFetch=PURCHASE_INVOICE&resourcesToFetch=VENDOR_ADDITION';
            } else if( thisRec.Product2.Product_Line__c == 'TDS' ){
                pathParams = 'resourcesToFetch=TAN_ADDITION&resourcesToFetch=TDS_DEDUCTIONS&resourcesToFetch=USER_ADDITION';
            }
        }
        
        HttpRequest 	request 		= new HttpRequest();
        HttpResponse 	response 		= new HttpResponse();
        request.setMethod('GET');
        request.setEndpoint(System.Label.SalesSync_Base_URI_India +System.Label.CTX_FetchUsageDetails_EP+licenseId+'/action/fetch-usage'+'?'+pathParams);
        request.setHeader('X-Api-Token', System.Label.SalesSyncService_X_Api_Token  );
        request.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        request.setHeader('Content-Type', 'application/json');

        
        try{	/**	CallOut Error Exception Handling Block	**/
            
            response 			= new Http().send(request);
            String 	licenselog 	= response.getBody();
            System.debug('CTX_FetchUsageDetails - licenselog: '+response.getBody());
            
            if( response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
                
                CTX_LicenseMetadataParser.LicenseWrapper 	licenseWrap = CTX_LicenseMetadataParser.convertLicenseDetails(licenselog);
                String 										planTier	= licenseWrap.planTier;
                Map<String, Integer> 						usageParams	= licenseWrap.usageMap;
                System.debug('CTX_FetchUsageDetails - usageParams: '+usageParams);
                
                try{	/**	Pricing Parameter Error Exception Handling Block	**/
                    
                    QuoteLineItem 	renewalQli = CTX_GetRenewalParameterAndPrice.calculateRenewalParameterAndPrice(licenseId, planTier, usageParams);
                    
                    
                    if(renewalQli == NULL){
                        
                        accountIdAndFailure.put( accountId, 'No Quote Line Item Available' );
                        failureMessage = failureMessage != NULL ? failureMessage+', '+ 'No Quote Line Item Available' : 'No Quote Line Item Available';
                        accountsFailed.add(
                            new Account(
                                Id=accountId, 
                                Is_Auto_Renewal_Enabled__c = FALSE, 
                                Auto_Renewal_Validation_Error__c = failureMessage
                            ));
                        failureEvents.add(
                            new Auto_Renew_Whitelisting_Failure__e(
                                Record_Id__c = accountId, 
                                ErrorMessages__c  = 'No Quote Line Item Available'
                            ));
                    } else{
                        
                        if( renewalQli.Usage_Log__c == NULL ){
                            renewalQli.Usage_Log__c = licenselog;
                            updateUsagePrice = TRUE;
                        }
                        System.debug('renewalQli : '+renewalQli);
                        
                        List<String>						fieldList	= new List<String>();
                        Schema.SObjectType 					targetType 	= Schema.getGlobalDescribe().get('Opportunity');
                        Map<String, Schema.SObjectField> 	fieldMap 	= targetType.getDescribe().fields.getMap();
                        
                        for( Schema.SObjectField field : fieldMap.values() ){
                            fieldList.add(field.getDescribe().getName());
                        }
                        
                        RecursiveTriggerHandler.isFirstTimeOpportunity 	= FALSE;
                        AssetConstants.LICENSING_SYNC_FLOW_RUN 			= FALSE;
                        RecursiveTriggerHandler.isFirstTime				= FALSE;
                        RecursiveTriggerHandler.isFirstTimeRenewed 		= FALSE;
                        QuoteConstants.ISFIRSTTIMEQUOTE					= FALSE;
                        OpportunityConstants.AUTO_RENEW_RULE 			= FALSE;
                        AssetConstants.isFirstTimeAdditionalGstin		= FALSE;
                        QuoteConstants.ISFIRSTTIMEQLI					= FALSE;
                        
                        try{	/**	Opportunity, Quote, QuoteLineItem upsertion Exception Handling Block	**/
                            
                            if(renewalQli != NULL && updateUsagePrice){
                                Update renewalQli; 
                            }
                            
                            
                            Id oppId = renewalQli.Quote.OpportunityId;
                            String queryString = ' SELECT Id, ( SELECT Id FROM Assets__r) '+ String.join(fieldList, ', ') + ' FROM Opportunity WHERE Id = :oppId LIMIT 1 '; 
                            List<Opportunity> thisOpp = database.query(queryString);
                            
                            if(thisOpp[0].Assets__r.size() == 0){
                                Quote quote = new Quote(Id=renewalQli.QuoteId); 
                                quote.status    = 'Quote Accept';
                                Update quote;
                                
                                Set<Id> qliIds = new Set<Id>();
                                qliIds.add(renewalQli.Id);
                                
                                Opportunity renewalOpp = thisOpp[0];
                                renewalOpp.Is_Auto_Renewal_Enabled__c = TRUE;
                                renewalOpp.SyncedQuoteId = renewalQli.QuoteId;
                                
                                update renewalOpp;
                                
                                /** FIX Related QLI Error	**/
                                
                                List<QuoteLineItem> listOfNewQuoteLineItem = new List<QuoteLineItem>();
                                listOfNewQuoteLineItem = [SELECT Id, OpportunityLineItemId, MarkUp__c, Sale_Price__c, Discount,Period_End_date__c,
                                                          Period_Start_date__c,Product_Code__c, Type_Of_Integration__c, Stage_in_MY__c, SOW_Start_Date__c, SOW_End_Date__c
                                                          FROM QuoteLineItem WHERE Id IN: qliIds];
                                list<opportunityLineItem> listOfOppLineItemToUpdate = new list<opportunityLineItem>();
                                for(QuoteLineItem tempQuoteLineItem : listOfNewQuoteLineItem){
                                    
                                    listOfOppLineItemToUpdate.add(
                                        new opportunityLineItem(
                                            
                                            Id 						= tempQuoteLineItem.OpportunityLineItemId,	
                                            Sale_Price__c 			= tempQuoteLineItem.Sale_Price__c, 
                                            MarkUp__c 				= tempQuoteLineItem.MarkUp__c, 
                                            Discount 				= tempQuoteLineItem.Discount , 
                                            Period_End_date__c 		= tempQuoteLineItem.Period_End_date__c,
                                            Period_Start_date__c 	= tempQuoteLineItem.Period_Start_date__c,
                                            Product_Code__c 		= tempQuoteLineItem.Product_Code__c , 
                                            Type_of_Integration__c 	= tempQuoteLineItem.Type_Of_Integration__c, 
                                            Stage_in_MY__c 			= tempQuoteLineItem.Stage_in_MY__c, 
                                            SOW_Start_Date__c 		= tempQuoteLineItem.SOW_Start_Date__c, 
                                            SOW_End_Date__c 		= tempQuoteLineItem.SOW_End_Date__c,
                                            Related_QLI__c 			= tempQuoteLineItem.Id
                                        ));
                                    
                                }
                                
                                if(listOfOppLineItemToUpdate.size()>0){
                                    RecursiveTriggerHandler.isFirstTimeOpportunity = FALSE;
                                    update listOfOppLineItemToUpdate;
                                    RecursiveTriggerHandler.isFirstTimeOpportunity = TRUE;
                                }
                                /**	Error Fix End	**/
                                
                                List<Asset> thisAsset = CTX_CreateAssetOrderHelper.CreateOrder(thisOpp[0], renewalQli.QuoteId, TRUE);
                                
                                RecursiveTriggerHandler.isFirstTimeOpportunity 	= TRUE;
                                QuoteConstants.ISFIRSTTIMEQLI					= TRUE;
                                AssetConstants.LICENSING_SYNC_FLOW_RUN 			= TRUE;
                                RecursiveTriggerHandler.isFirstTime				= TRUE;
                                RecursiveTriggerHandler.isFirstTimeRenewed 		= TRUE;
                                QuoteConstants.ISFIRSTTIMEQUOTE					= TRUE;
                                OpportunityConstants.AUTO_RENEW_RULE 			= TRUE;
                                AssetConstants.isFirstTimeAdditionalGstin		= TRUE;
                            }
                            
                            /**	Billing GSTIN API Check	**/
                            if( system.label.GSTIN_API_Enablement == 'YES' && thisOpp != NULL && thisOpp.size() > 0 ){
                                system.debug('Inside GSTIN API Block');
                                HttpRequest 	gstinRequest		= new HttpRequest();
                                Http			httpReq		= new Http();
                                HTTPResponse	gstinResponse;
                                gstinRequest.setEndpoint(System.Label.GST_Portal_Endpoint + thisOpp[0].Billing_GST__c );
                                gstinRequest.setMethod('GET');
                                gstinRequest.setHeader('Content-Type', 'application/json');
                                gstinRequest.setHeader('x-cleartax-auth-token', System.Label.GST_ApiToken);
                                gstinResponse = httpReq.send(gstinRequest);
                                if (gstinResponse.getStatusCode() == 200) { 
                                    system.debug('@response: '+ gstinResponse.getBody());
                                    Map<String, Object> responseMap         = (Map<String, Object>)JSON.deserializeUntyped(gstinResponse.getBody());
                                    if( responseMap.containsKey('taxPayerErrorResponse') ){
                                        Map<String, Object> taxPayerInfo		= (Map<String, Object>)responseMap.get('taxPayerErrorResponse');
                                        if( taxPayerInfo != NULL ){
                                            if( taxPayerInfo.get('errorCode') != NULL ){                                            
                                                accountIdAndFailure.put( accountId, (String)taxPayerInfo.get('message') );
                                                failureMessage = failureMessage != NULL ? failureMessage+', '+ (String)taxPayerInfo.get('message') : (String)taxPayerInfo.get('message');
                                                accountsFailed.add(
                                                    new Account(
                                                        Id=accountId, 
                                                        Is_Auto_Renewal_Enabled__c = FALSE,
                                                        Auto_Renewal_Validation_Error__c = failureMessage
                                                    ));
                                                failureEvents.add(
                                                    new Auto_Renew_Whitelisting_Failure__e(
                                                        Record_Id__c = accountId, 
                                                        ErrorMessages__c  = 'Error while updating Pricing Parameters. - '+(String)taxPayerInfo.get('message')
                                                    ));
                                            }
                                        }
                                    }
                                } else{
                                    String errorMessage0 = 'Not a valid GSTIN of Opportunity.';
                                    accountIdAndFailure.put( accountId, 'Not a valid GSTIN of Opportunity.' );
                                    failureMessage = failureMessage != NULL ? failureMessage+', '+ 'Not a valid GSTIN of Opportunity.' : 'Not a valid GSTIN of Opportunity.';
                                    accountsFailed.add(
                                        new Account(
                                            Id=accountId, 
                                            Is_Auto_Renewal_Enabled__c = FALSE,
                                            Auto_Renewal_Validation_Error__c = failureMessage
                                        ));
                                    failureEvents.add(
                                        new Auto_Renew_Whitelisting_Failure__e(
                                            Record_Id__c = accountId, 
                                            ErrorMessages__c  = 'Error while updating Pricing Parameters. - '+'Not a valid GSTIN of Opportunity.'
                                        ));
                                }
                            }
                            /**	Billing GSTIN API Check	**/
                        } 
                        catch(Exception ex){
                            accountIdAndFailure.put( accountId, ex.getMessage() );
                            failureMessage = failureMessage != NULL ? failureMessage+', '+ ex.getMessage() : ex.getMessage();
                            accountsFailed.add(
                                new Account(
                                    Id=accountId, 
                                    Is_Auto_Renewal_Enabled__c = FALSE,
                                    Auto_Renewal_Validation_Error__c = failureMessage
                                ));
                            failureEvents.add(
                                new Auto_Renew_Whitelisting_Failure__e(
                                    Record_Id__c = accountId, 
                                    ErrorMessages__c  = 'Error while updating Pricing Parameters. - '+ex.getMessage()
                                ));
                        }
                    }
                } 
                catch( Exception ex){
                    accountIdAndFailure.put( accountId, ex.getMessage() );
                    failureMessage = failureMessage != NULL ? failureMessage+', '+ ex.getMessage()  : ex.getMessage() ;
                    accountsFailed.add(
                        new Account(
                            Id=accountId, 
                            Is_Auto_Renewal_Enabled__c = FALSE, 
                            Auto_Renewal_Validation_Error__c = failureMessage
                        ));
                    failureEvents.add(
                        new Auto_Renew_Whitelisting_Failure__e(
                            Record_Id__c = accountId, 
                            ErrorMessages__c  = ex.getMessage() 
                        ));
                }
                
                
            } else{
                
                accountIdAndFailure.put( accountId, 'Callout Exception' );
                failureMessage = failureMessage != NULL ? failureMessage+', '+ 'Callout Exception'  : 'Callout Exception' ;
                accountsFailed.add(
                    new Account( 
                        Id=accountId, 
                        Is_Auto_Renewal_Enabled__c = FALSE, 
                        Auto_Renewal_Validation_Error__c = failureMessage
                    ));
                failureEvents.add(
                    new Auto_Renew_Whitelisting_Failure__e(
                        Record_Id__c = accountId, 
                        ErrorMessages__c  = failureMessage
                    ));
            }
        }
        catch(system.CalloutException e) {
            
            accountIdAndFailure.put( accountId, e.getMessage() );
            failureMessage = failureMessage != NULL ? failureMessage+', '+ e.getMessage()  : e.getMessage() ;
            accountsFailed.add(
                new Account(
                    Id=accountId, 
                    Is_Auto_Renewal_Enabled__c = FALSE, 
                    Auto_Renewal_Validation_Error__c = failureMessage));
            failureEvents.add(
                new Auto_Renew_Whitelisting_Failure__e(
                    Record_Id__c = accountId, 
                    ErrorMessages__c  = 'Callout Exception'
                ));
        }
        
        
        /**	Fire Platform Event and Update Account	**/
        if(failureEvents.size() > 0){
            List<Database.SaveResult> results = EventBus.publish(failureEvents);
        }
        if(!accountsFailed.isEmpty()){
            AccountConstants.isFirstTimeAccount = FALSE;
            update accountsFailed;
            AccountConstants.isFirstTimeAccount = TRUE;
        }
        /**	Fire Platform Event and Update Account	**/
        
        
        if( system.label.Auto_Renewal_Flag_Enable_Logic == 'YES' ){
            if( 
                failureMessage == NULL && 
                accountIdAndFailure.size() > 0 && 
                accountIdAndFailure.get(accountId) == NULL
            ){
                /**	Eligiable for Auto Renewal	**/
                system.debug('Inside Eligiable Asset');
                if(astMapToEnableAutoRenew.values().size() > 0 && assetAccountMap.values().size() > 0)
                    CTX_AutoRenewalFlag.enableAutoRenewal( astMapToEnableAutoRenew, assetAccountMap);
            } else{
                system.debug('Inside Error: '+failureMessage);
            }
        }
        
        
        
    }
    
}