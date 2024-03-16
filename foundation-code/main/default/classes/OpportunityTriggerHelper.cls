/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-09-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class OpportunityTriggerHelper {
    
    public static void CreateOrder(List<Opportunity> ListofNewOpportuinty){
        
        String 					Asset_Lincence_Asset_RecordTypeId 		= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(AssetConstants.RECORD_TYPE_NAME_LICENCED_ASSET).getRecordTypeId();
        String 					Asset_OneTime_Asset_RecordTypeId 		= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(AssetConstants.RECORD_TYPE_NAME_ONETIME_ASSET).getRecordTypeId();
        String 					Asset_Integration_Asset_RecordTypeId 	= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(AssetConstants.RECORD_TYPE_NAME_INTEGRATION_ASSET).getRecordTypeId();
        String 					opportunity_Renewal_RecordTypeId		= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OpportunityConstants.RECORDTYPE_RENEWAL).getRecordTypeId();
        Map<id,Opportunity> 	mapOfOpportunity 						= new Map<id,Opportunity>(ListofNewOpportuinty);
        Set<Id>					oppIdSet								= new Set<Id>();
        List<Order> 			orderlist	 							= new List<Order>();
        Map<String,OrderItem> 	ordItemMap								= new Map<String,OrderItem>(); 
        List<Asset>				assetlist								= new List<Asset>();
        set<id> 				syncedQuoteIds 							= new set<Id>();
        set<Id> 				renewalOpportunityIds 					= new set<id>();
        Map<Id,Asset> 			mapOfAssets 							= new Map<Id,Asset>();
        Map<Id, Order> 			orderMap 								= new Map<Id, Order>();
        Map<String, String> 	getSpecialProductComboMap	 			= new Map<String, String>();
        List<Id>				productIdListForSpecialProductSplit		= new List<Id>();
        Map<Id, Product2>		specialProductSplitProductDetailsMap;
        
        Map<String, Special_Product_Combination__mdt> specialProductComboMap = Special_Product_Combination__mdt.getAll();
        
        for( Special_Product_Combination__mdt thisRec : specialProductComboMap.values() ){
            
            getSpecialProductComboMap.put( thisRec.Special_Product_Id__c, thisRec.Related_Products_to_Create__c );
            
            if( thisRec.Related_Products_to_Create__c != NULL ){
                productIdListForSpecialProductSplit.addAll( thisRec.Related_Products_to_Create__c.split(',') );
            }
        }
        
        specialProductSplitProductDetailsMap = new Map<Id, Product2>(
            [ SELECT Id, Name FROM Product2 WHERE Id IN :productIdListForSpecialProductSplit ]
        );
        
        
        if( ListofNewOpportuinty.size()>0 ){
            for( Opportunity opp : ListofNewOpportuinty ){
                if( opp.AccountId != NULL ){
                    
                    oppIdSet.add(opp.Id);
                    Order newOrder = new Order();
                    newOrder.OpportunityId = opp.Id;
                    newOrder.AccountId = opp.AccountId;
                    newOrder.EffectiveDate = opp.CloseDate;
                    newOrder.CurrencyIsoCode = opp.CurrencyIsoCode;
                    
                    if(opp.RecordTypeId == opportunity_Renewal_RecordTypeId){
                        newOrder.Status= OrderConstants.ORDER_ONBOARDING_NOT_REQUIRED;
                    }else{
                        newOrder.Status= OrderConstants.ORDER_DOCUMENT_PENDING;
                    }
                    /*End by Raksha*/
                    newOrder.Pricebook2Id = opp.Pricebook2Id;
                    orderlist.add(newOrder);
                    syncedQuoteIds.add(opp.SyncedQuoteId);
                }
                
                if( opp.RecordTypeId == opportunity_Renewal_RecordTypeId ){
                    renewalOpportunityIds.add(opp.Id);
                }
            }
        }
        system.debug('oppIdSet '+oppIdSet);
        
        if(!orderlist.isEmpty()){
            insert orderlist;
        }
        
        String queryString_SyncedQuote 		= ' SELECT ' +CTX_LicensingConstants.SYNCQUOTE_OPPORTUNITYHELPER_QUERY+ ' FROM QUOTE WHERE Id IN: syncedQuoteIds ';
        String queryString_OpportunityLine 	= ' SELECT ' +CTX_LicensingConstants.OPPORTUNITYLINITEME_OPPORTUNITYHELPER_QUERY+' , '+CTX_LicensingConstants.CLEAR_IDENTITY_METERING_PARAMETER_OPPLNE+ ' FROM OpportunityLineItem WHERE OpportunityId IN: oppIdSet ';
        
        Map<Id,Quote> mapOfSyncedQuotes = new Map<Id,Quote>( (List<Quote>)database.query(queryString_SyncedQuote) );
        system.debug('mapOfSyncedQuotes: '+mapOfSyncedQuotes);
        
        if( !oppIdSet.isEmpty() ){
            
            for( Order order: orderlist ) {
                orderMap.put( order.OpportunityId, order );
            }
            
            for( 
                Asset thisAsset : [ SELECT Id, Renewal_Opportunity__c, Status FROM Asset WHERE Renewal_Opportunity__c IN: renewalOpportunityIds ] 
            ){
                mapOfAssets.put( thisAsset.Renewal_Opportunity__c, thisAsset );
            }
            
            
            for( OpportunityLineItem oli: (List<OpportunityLineItem>)database.query(queryString_OpportunityLine) ){ 
                
                Boolean 	doNotCreateAsset 	= FALSE;
                OrderItem 	oi 					= new OrderItem(); 
                
                oli.Sale_Price__c 		= Test.isRunningTest() ? 10000 : oli.Sale_Price__c;
                oi.OrderId 				= orderMap.get(oli.OpportunityId).Id;
                oi.Quantity 			= oli.Quantity;
                oi.PricebookEntryId 	= oli.PricebookEntryId;
                oi.UnitPrice 			= oli.Sale_Price__c;
                oi.Product2Id 			= oli.PricebookEntry.Product2Id;
                
                if(mapOfOpportunity.get(oli.OpportunityId).RecordTypeId != opportunity_Renewal_RecordTypeId){
                    oi.Status__c 		= OrderItemConstants.STATUS_FINANCE_APPROVAL_PENDING;
                }
                
                if(oli.Product2.Family.equalsIgnoreCase('Managed Service'))
                {
                    oi.OrderType__c		= 'Managed Service';
                } else if(!(oli.Product2.Product_category__c.equalsIgnoreCase('Integration') || oli.Product2.Product_category__c.equalsIgnoreCase('OTP') || oli.Product2.Family.equalsIgnoreCase('Managed Service')))
                {
                    oi.OrderType__c		= 'Products';
                } else if(oli.Product2.Product_category__c.equalsIgnoreCase('Integration'))
                {
                    oi.OrderType__c		= 'Integration';
                } else if(oli.Product2.Product_category__c.equalsIgnoreCase('OTP') ){
                    oi.OrderType__c		= 'OTP';
                    doNotCreateAsset 	= TRUE;
                }
                
                doNotCreateAsset 		= oli.Opportunity.RecordTypeId == opportunityConstants.RECORDTYPEID_RENEWAL_MULTI_YEAR ? TRUE : FALSE;
                system.debug('doNotCreateAsset : '+doNotCreateAsset);
                system.debug('oi.UnitPrice: '+oi.UnitPrice);
                
                ordItemMap.put(oli.OpportunityId+'-'+oi.Product2Id+'-'+oi.Quantity+'-'+oi.UnitPrice, oi);
                system.debug('oi: '+oi);
                
                IF(!doNotCreateAsset){
                    
                    
                 
                    
                    /**	Incase of Special Product : START	**/
                    system.debug('Inside Asset Creation');
                    If( system.label.Special_Products.containsIgnoreCase( oli.PricebookEntry.Product2Id ) ){
                        
                        system.debug('Inside Combo Special Product');
                        if( getSpecialProductComboMap.containsKey(oli.PricebookEntry.Product2Id) ){
                            List<String> productList = getSpecialProductComboMap.get(oli.PricebookEntry.Product2Id).split(',');
                            Set<String> productSet = new Set<String>(productList);
                            
                            Decimal indivudalPrice  = oli.Total_Price__c/productSet.size();
                            for( String thisSTR : productSet ){
                                
                                Asset newAsset = CTX_MultipleAssetCreateOnSpecialProduct.createAssetOnOpportunityClosure(
                                    oli, mapOfOpportunity, mapOfAssets, mapOfSyncedQuotes, ordItemMap, 
                                    Asset_Lincence_Asset_RecordTypeId, opportunity_Renewal_RecordTypeId, 
                                    Asset_OneTime_Asset_RecordTypeId, Asset_Integration_Asset_RecordTypeId, thisSTR, indivudalPrice, 
                                    specialProductSplitProductDetailsMap, NULL 
                                );
                                
                                if( newAsset != NULL ){
                                    assetlist.add(newAsset);
                                }
                            }
                        }
                    } else{/**	In normal Cases	**/
                        
                        system.debug('Inside Normal Product');
                        Asset newAsset = CTX_MultipleAssetCreateOnSpecialProduct.createAssetOnOpportunityClosure(
                            oli, mapOfOpportunity, mapOfAssets, mapOfSyncedQuotes, ordItemMap, 
                            Asset_Lincence_Asset_RecordTypeId, opportunity_Renewal_RecordTypeId, 
                            Asset_OneTime_Asset_RecordTypeId, Asset_Integration_Asset_RecordTypeId, oli.PricebookEntry.Product2Id, oli.Total_Price__c, 
                            NULL, NULL 
                        );
                        
                        assetlist.add(newAsset);
                    }
                    
                }
                
            }
            List<OrderItem> oiToUpdate = new List<OrderItem> ();
            List<Asset> asstetsToProcess = new List<Asset> ();
            if(!ordItemMap.isEmpty()){
                oiToUpdate = ordItemMap.values();
            }
            
            if( !assetlist.isEmpty() ){
                asstetsToProcess = assetlist;

            }
            System.enqueueJob(new AssetCreationOnOpptyClosure(asstetsToProcess,oiToUpdate));
			system.debug('Queued Asset and Order Item creation ');
            
        }
    }
    
    
    
    public static void closedWonFilesValidation(List<Opportunity> newListOfOpportunity, String staticLabelValue, String errorMessage){
        
        set<Id> setOfOppIds = new set<Id>();
        set<Id> setOfDocIds = new set<Id>();
        Map<Id,List<Id>> oppIdWithContentDocId = new Map<Id,List<Id>>();
        Map<Id, List<Quote>> mapOfQuote = new Map<Id, List<Quote>>();
        Map<Id,String> versionWithType = new Map<Id,String>();
        Map<Id,Integer> mapCount = new Map<Id,Integer>();
        Map<Id,Opportunity> mapOfOpportunity = new Map<Id,Opportunity>();
        List<Id>			oppIds = new List<Id>();
        
        for(Opportunity tempOpp : newListOfOpportunity){
            setOfOppIds.add(tempOpp.Id);
            mapOfOpportunity.put(tempOpp.Id, tempOpp);
        }
        oppIds.addAll(setOfOppIds);
        List<ContentDocumentLink> contentDocList;
        if(setOfOppIds.size() > 0 && setOfOppIds.size() == 1){
            Id oppId = oppIds[0];
            contentDocList = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :oppId ];
        } else if(setOfOppIds.size() > 0 && setOfOppIds.size() > 1){
            contentDocList = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: setOfOppIds ];
        }
        
        
        for(ContentDocumentLink tempContent : contentDocList){
            setOfDocIds.add(tempContent.ContentDocumentId);
            if(oppIdWithContentDocId.containsKey(tempContent.LinkedEntityId)){
                List<Id> newListValue = oppIdWithContentDocId.get(tempContent.LinkedEntityId);
                newListValue.add(tempContent.ContentDocumentId);
                oppIdWithContentDocId.put(tempContent.LinkedEntityId,newListValue);
            }else{
                oppIdWithContentDocId.put(tempContent.LinkedEntityId,new list<Id>{tempContent.ContentDocumentId});
            } 
        }
        
        List<ContentVersion> contentverList = [SELECT Type_of_document__c,ContentDocumentId FROM ContentVersion where ContentDocumentId IN: setOfDocIds];
        for(ContentVersion tempVersion : contentverList){
            versionWithType.put(tempVersion.ContentDocumentId, tempVersion.Type_of_document__c );
        }
        Map<id,List<String>> entityIdWithTypeOfDoc = new Map<id,List<String>>();
        for(Id tempOppId : oppIdWithContentDocId.keySet()){
            for(Id tempContentId : versionWithType.keySet()){
                if(oppIdWithContentDocId.get(tempOppId).Contains(tempContentId)){
                    if(entityIdWithTypeOfDoc.containsKey(tempOppId)){
                        List<string> newListValue = entityIdWithTypeOfDoc.get(tempOppId);
                        newListValue.add(versionWithType.get(tempContentId));
                        entityIdWithTypeOfDoc.put(tempOppId,newListValue);
                    }else{
                        entityIdWithTypeOfDoc.put(tempOppId,new list<String>{versionWithType.get(tempContentId)});
                    }
                }
            }
        }
        Map<string,Boolean> typeOfDocToCheck = new Map<string,Boolean>(); 
        String errorMsg = '';
        Map<string,Map<String,Boolean>> checkAllCombination = new Map<string,Map<String,Boolean>>();
        Set<Id> entityToError = new Set<Id>();
        for(String orTempMandate : staticLabelValue?.split(';')){//system.Label.Opp_Doc_Type_INVOICE || system.Label.OppDocTypeMandate
            system.debug('orTempMandate: '+orTempMandate);
            if(errorMsg == ''){
                errorMsg = orTempMandate;
            }
            else{
                errorMsg = errorMsg +' OR '+ orTempMandate;
            }
            for(string tempMandate : orTempMandate.split(',')){
                typeOfDocToCheck.put(tempMandate, false);
                if(checkAllCombination.containsKey(orTempMandate)){
                    Map<String,Boolean> tempMapVal = checkAllCombination.get(orTempMandate);
                    tempMapVal.put(tempMandate,false);
                    checkAllCombination.put(orTempMandate,tempMapVal);
                }
                else{
                    checkAllCombination.put(orTempMandate,new Map<String,Boolean>{tempMandate => false});
                } 
            }
        }
        for(Id tempEntityId : entityIdWithTypeOfDoc.keySet()){
            Map<string,Boolean> availTypeOfDocToCheck = typeOfDocToCheck;
            Map<string,Map<String,Boolean>> checkingAllCombination = new Map<string,Map<String,Boolean>>(checkAllCombination);
            for(String tempType : entityIdWithTypeOfDoc.get(tempEntityId)){
                if(availTypeOfDocToCheck.containsKey(tempType)){
                    availTypeOfDocToCheck.put(tempType,true);
                }
            }
            
            for(String orTempMandate : staticLabelValue.split(';')){
                integer countCheck = 0;
                for(string tempMandate : orTempMandate.split(',')){
                    if(availTypeOfDocToCheck.get(tempMandate)){
                        countCheck++;
                    }
                }
                if(countCheck == orTempMandate.split(',').size()){
                    entityToError.add(tempEntityId);
                }
            }
            
            
        }
        
        for(Opportunity tempOpp : newListOfOpportunity){
            if(!entityToError.Contains(tempOpp.Id)){
                tempOpp.addError(errorMessage);//('Please Add Attachment of Type :  1- COF, 2- LOE or PO or AGREEMENT. '); //+errorMsg
            }
        }
    }
    /*Added by Thejas : To fire the Validation Error*/
    
    
    public static void stageValidation(List<Opportunity> newListOfOpportunity){
        
        set<Id> 				setOfOppIds 		= new set<Id>();
        Map<Id, List<Quote>> 	mapOfQuote	 		= new Map<Id, List<Quote>>();
        Map<Id,Integer> 		mapCount 			= new Map<Id,Integer>();
        Map<Id,Opportunity> 	mapOfOpportunity 	= new Map<Id,Opportunity>();
        
        for(Opportunity tempOpp : newListOfOpportunity){
            if(tempOpp.Merge_With_Opportunity__c == NULL) {
                setOfOppIds.add(tempOpp.Id);
                mapOfOpportunity.put(tempOpp.Id, tempOpp);
            }
        }
        
        System.debug('Opp Id :'+setOfOppIds);
        for(
            Opportunity oppInstance : [ SELECT Id, 
                                       ( SELECT Id, Name, OpportunityId, IsSyncing, Is_Primary_Quote__c, Status, 
                                        Total_Quote_Items__c 
                                        FROM Quotes WHERE
                                        IsSyncing = TRUE AND 
                                        Is_Primary_Quote__c = TRUE ) 
                                       FROM Opportunity WHERE
                                       Id IN :setOfOppIds ] 
        ){
            if(oppInstance.Quotes.size()>0)
            {
                for(Quote quoteInstance : oppInstance.Quotes)
                {
                    if( quoteInstance.Total_Quote_Items__c <= 0)
                    {
                        mapOfOpportunity.get(quoteInstance.OpportunityId).addError(Label.Quote_Should_be_synced_to_move_Stages);  
                    }
                    else if(quoteInstance.Status != QuoteConstants.STATUS_QUOTE_ACCEPT)
                    {
                        mapOfOpportunity.get(quoteInstance.OpportunityId).addError(Label.Closed_Won_With_Quote_and_Line_Item);
                    }
                }  
            }else
            {
                mapOfOpportunity.get(oppInstance.Id).addError(Label.Quote_Should_be_synced_to_move_Stages);
            }
        }
    }
    //End of Code
    //renu start
    
    
    public static void opportunitySubstageValidationOnEvent(list<Opportunity> listOfEventValidation){
        set<Id> setOfleadIds = new set<Id>();
        map<id, Opportunity> mapOfOpportunity = new map<id, Opportunity>(listOfEventValidation);
        system.debug('mapOfOpportunity'+mapOfOpportunity.KeySet());
        list<Event> listOfEvent= new list<Event>();
        map<id, list<Event>> mapOfOpportunityToItsListOfEvents = new map<id, list<Event>>();
        listOfEvent=[SELECT id, Stage__c,WhatId FROM Event where (type='Call' OR type='Meeting' or type='Demo/POC') AND WhatId IN:mapOfOpportunity.keySet()]; // commented by lokesh removed subtype='demo' and added type='Demo/POC' 
        system.debug(' size of listOfEvent'+listOfEvent);
        
        for(Event eve:listOfEvent){
            if(mapOfOpportunityToItsListOfEvents.containsKey(eve.WhatId)){
                mapOfOpportunityToItsListOfEvents.get(eve.WhatId).add(eve);
            }else{
                mapOfOpportunityToItsListOfEvents.put(eve.WhatId, new List<Event>{eve}); 
            }
        }
        system.debug('size of eve'+mapOfOpportunityToItsListOfEvents.size());
        for(Opportunity OpportunityRecord : listOfEventValidation){
            if(OpportunityRecord.Substages__c == 'POC Meeting Scheduled'){
                if(!mapOfOpportunityToItsListOfEvents.containsKey(OpportunityRecord.Id)){
                    OpportunityRecord.addError(Label.Demo_POC_Error_on_Opportunity);
                }
            }
            else if(OpportunityRecord.Substages__c == 'Demo Completed'){
                if(mapOfOpportunityToItsListOfEvents.containsKey(OpportunityRecord.Id)){
                    Boolean isNotComplete = false;
                    List<Event> listOfEvents = mapOfOpportunityToItsListOfEvents.get(OpportunityRecord.id);
                    for(Event ev : listOfEvents){
                        if(ev.Stage__c != 'Completed'){
                            isNotComplete = true;
                            break;
                        }
                    }
                    if(isNotComplete){
                        Opportunity OpportunityInstance = mapOfOpportunity.get(OpportunityRecord.Id);
                        OpportunityInstance.addError(Label.Demo_Poc_Completed_Customer_Error_on_Opportunity);
                    }
                }else{
                    OpportunityRecord.addError(Label.Demo_Poc_Error_on_Stage_Change_on_Opportunity);
                }
            }
        } 
    }    //renu end
    
    
    
    /**
* @description this Method helps to assign the Admin Queue or the user from Queue for Locking userIds
* @author Lokesh Thathuru | 11/02/2020
* @param List<Sobject> listOfLeadsToApplyElCheckAndAssignfromQueue 
* @return void
*/
    public static void  updateOwnerBasedOnEligibilityFromMatrixfromQueueField(List<Sobject> listOfLeadsToApplyElCheckAndAssignfromQueue){
        if(listOfLeadsToApplyElCheckAndAssignfromQueue.size()>0){
            UtilityClass.beforeUpdateToApplyElCheckAndAssignfromQueue(listOfLeadsToApplyElCheckAndAssignfromQueue);
        }
    }
    
    /**
* @description this Method helps to assign the Admin Queue or the user from Queue for Locking userIds
* @author Lokesh Thathuru | 11/02/2020
* @param List<Sobject> listOfLeadsToApplyElCheckAndAssignfromQueue 
* @return void
*/
    public static void extensionApproveUpdateValue(List<Opportunity> listOfOpportunities){
        if(listOfOpportunities.size()>0){
            for(Opportunity opportunityInstance:listOfOpportunities){
                if(opportunityInstance.Extension_Approval_Status__c==OpportunityConstants.EXTENSION_APPROVAL_STATUS_APPROVED){
                    if(opportunityInstance?.Extension_Days__c!=null && opportunityInstance?.Lead_Locked_Date__c!=null){
                        opportunityInstance.Lead_Locked_Date__c = opportunityInstance?.Lead_Locked_Date__c+Integer.valueOf(opportunityInstance?.Extension_Days__c);
                    }
                }else if(opportunityInstance.Extension_Approval_Status__c==OpportunityConstants.EXTENSION_APPROVAL_STATUS_REJECTED){
                    opportunityInstance.Lead_Locking_Status__c = opportunityConstants.LEAD_LOCKED_STATU_UNLOCKED;
                } 
            }
        }
    }
    
    //New Custom roll up becoz standard rollup is not working properly
    public static void ARRRollUp(List<sObject> records){
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForActiveStatusCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'ARR_Product_Total_Amount__c', 
                                                         'ARR_Total_Amount_Custom__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForActiveStatusCount, records, 'Opportunity', 'AccountId', 'Account',
                                                           'And (StageName = \'Closed Won\' OR StageName = \'Onboarded\' )'); 
        
    }
    
    //Pramodh Adding Esign CallOut 
    /*public static void eSignCallOut(List<Opportunity> listOfOpportunitieseSignRequest){
List<ESignRequestCallOutGeneric.valueInitiators> listOfeSignRequestValues = new List<ESignRequestCallOutGeneric.valueInitiators>();
set<Id> quoteIds = new set<Id>();
for(Opportunity tempOpportunity : listOfOpportunitieseSignRequest){
If(tempOpportunity.SyncedQuoteID != null)
quoteIds.add(tempOpportunity.SyncedQuoteID);
}
set<Id> setOfOppIds = new set<Id>();
set<Id> setOfDocIds = new set<Id>();
Map<Id,List<Id>> quoteIdWithContentDocId = new Map<Id,List<Id>>();
Map<Id, List<Quote>> mapOfQuote = new Map<Id, List<Quote>>();
Map<Id,ContentVersion> versionWithType = new Map<Id,ContentVersion>();
Map<Id,Quote> mapOfQuotes = new Map<Id,Quote>();
Map<Id,List<ContentVersion>> entityIdWithContentVersion = new Map<Id,List<ContentVersion>>();
Map<String, E_Sign_Config__c> eSignConfig = E_Sign_Config__c.getAll();
List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: quoteIds ];

for(ContentDocumentLink tempContent : contentDocList){
setOfDocIds.add(tempContent.ContentDocumentId);
if(quoteIdWithContentDocId.containsKey(tempContent.LinkedEntityId)){
List<Id> newListValue = quoteIdWithContentDocId.get(tempContent.LinkedEntityId);
newListValue.add(tempContent.ContentDocumentId);
quoteIdWithContentDocId.put(tempContent.LinkedEntityId,newListValue);
}else{
quoteIdWithContentDocId.put(tempContent.LinkedEntityId,new list<Id>{tempContent.ContentDocumentId});
}
}

List<ContentVersion> contentverList = [SELECT Id,Title,FileType,Type_of_document__c,ContentDocumentId,VersionData FROM ContentVersion where ContentDocumentId IN: setOfDocIds AND IsLatest = true AND Type_of_document__c =: eSignConfig.get('Type_Of_Doc').Value__c];
for(ContentVersion tempVersion : contentverList){
versionWithType.put(tempVersion.ContentDocumentId, tempVersion );
}

for(Id tempQuoteId : quoteIdWithContentDocId.keySet()){
for(Id tempContentId : versionWithType.keySet()){
if(quoteIdWithContentDocId.get(tempQuoteId).Contains(tempContentId)){
if(entityIdWithContentVersion.containsKey(tempQuoteId)){
List<ContentVersion> newListValue = entityIdWithContentVersion.get(tempQuoteId);
newListValue.add(versionWithType.get(tempContentId));
entityIdWithContentVersion.put(tempQuoteId,newListValue);
}else{
entityIdWithContentVersion.put(tempQuoteId,new list<ContentVersion>{versionWithType.get(tempContentId)});
}
}
}
}

for(Opportunity tempOpportunity : listOfOpportunitieseSignRequest){
system.debug('Data '+entityIdWithContentVersion);
system.debug('Val '+entityIdWithContentVersion.get(tempOpportunity.SyncedQuoteID));
//system.debug('res '+entityIdWithContentVersion.get(tempOpportunity.SyncedQuoteID).size());
if(entityIdWithContentVersion.containsKey(tempOpportunity.SyncedQuoteID)){
if(! (entityIdWithContentVersion.get(tempOpportunity.SyncedQuoteID).size()>0) ){
tempOpportunity.addError(eSignConfig.get('Error-Document').Error_Message__c);
}else{
ESignRequestCallOutGeneric eSignRequest = new ESignRequestCallOutGeneric();
ESignRequestCallOutGeneric.valueInitiators eSignRequestValues = new ESignRequestCallOutGeneric.valueInitiators();
eSignRequestValues.contentVersionId = entityIdWithContentVersion.get(tempOpportunity.SyncedQuoteID)[0].Id;
eSignRequestValues.contentVersionFileType = entityIdWithContentVersion.get(tempOpportunity.SyncedQuoteID)[0].FileType;
eSignRequestValues.contentVersionData = EncodingUtil.base64Encode(entityIdWithContentVersion.get(tempOpportunity.SyncedQuoteID)[0].VersionData);
eSignRequestValues.contentVersionTitle = entityIdWithContentVersion.get(tempOpportunity.SyncedQuoteID)[0].Title;
eSignRequestValues.signerType = 'Signer-CTX';//'Signer-Customer';
eSignRequestValues.signerId = eSignConfig.get('CTX-Signer-ID').Value__c;
eSignRequestValues.signerEmailId = eSignConfig.get('CTX-Signer-Email-ID').Value__c;
eSignRequestValues.signerName = eSignConfig.get('CTX-Signer-Name').Value__c;
eSignRequestValues.signerMobileNo = eSignConfig.get('CTX-Signer-Mobile').Value__c;
eSignRequestValues.eSignType = eSignConfig.get('CTX-Signer-Type').Value__c;
eSignRequestValues.recordId = tempOpportunity.SyncedQuoteID;
listOfeSignRequestValues.add(eSignRequestValues);
}
}
else{
tempOpportunity.addError(eSignConfig.get('Error-Document').Error_Message__c);
}
}
If(listOfeSignRequestValues.size()>0){
ESignQueueableForCallOut tempESignQueueableForCallOut = new ESignQueueableForCallOut(listOfeSignRequestValues);
System.enqueueJob(tempESignQueueableForCallOut);
}
}*/
    
    //Pramodh Ending Esign CallOut
    
    //Added by Raksha to check for Order avaliable before the opportunity is moved to "In Finance Approval" stage
    public static void checkForOrderForm(List<Opportunity> listOfOpportunity, Boolean isApprovedPhySignOpps){
        Map<Id,Opportunity> mapOfOpp = new Map<Id,Opportunity>(listOfOpportunity);
        Map<String, E_Sign_Config__c> eSignConfig = E_Sign_Config__c.getAll();
        Set<String> setOfContentDocIds = new Set<String>();
        Map<Id,List<Id>> oppIdWithContentDocId = new Map<Id,List<Id>>();
        Map<Id,ContentVersion> versionWithType = new Map<Id,ContentVersion>();
        Map<String,String> mapOfContentDocIdToObjId = new Map<String,String>();
        Map<String,List<ContentVersion>> mapOfOppIdToListOfCV = new Map<String,List<ContentVersion>>();
        
        List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: mapOfOpp.keySet() ];
        System.debug('** contentDocList '+contentDocList);
        for(ContentDocumentLink cdl : contentDocList){
            mapOfContentDocIdToObjId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            /*setOfContentDocIds.add(cdl.ContentDocumentId);
if(oppIdWithContentDocId.containsKey(cdl.LinkedEntityId)){
List<Id> newListValue = oppIdWithContentDocId.get(cdl.LinkedEntityId);
newListValue.add(cdl.ContentDocumentId);
oppIdWithContentDocId.put(cdl.LinkedEntityId,newListValue);
}else{
oppIdWithContentDocId.put(cdl.LinkedEntityId,new list<Id>{cdl.ContentDocumentId});
}*/
        }
        System.debug('** mapOfContentDocIdToObjId '+mapOfContentDocIdToObjId);
        System.debug('** mapOfContentDocIdToObjId.keySet() '+mapOfContentDocIdToObjId.keySet());
        System.debug('** ESign Type Of Doc '+eSignConfig.get('Type_Of_Doc').Value__c);
        List<ContentVersion> contentverList = [SELECT Id, Title, FileType, Type_of_document__c, ContentDocumentId, VersionData, System_Generated__c 
                                               FROM ContentVersion WHERE ContentDocumentId IN: mapOfContentDocIdToObjId.keySet() //AND IsLatest = true
                                               AND Type_of_document__c =: eSignConfig.get('Type_Of_Doc').Value__c]; //
        System.debug('** contentverList Size '+contentverList.size());
        for(ContentVersion tempVersion : contentverList){
            System.debug('** tempVersion.ContentDocumentId '+tempVersion.ContentDocumentId);
            String opptyId = mapOfContentDocIdToObjId.get(tempVersion.ContentDocumentId);
            System.debug('** opptyId '+opptyId);
            if(mapOfOppIdToListOfCV.containsKey(opptyId)){
                mapOfOppIdToListOfCV.get(opptyId).add(tempVersion);
            }else{
                mapOfOppIdToListOfCV.put(opptyId, new List<ContentVersion>{tempVersion});
            }
            // versionWithType.put(tempVersion.ContentDocumentId, tempVersion );
        }
        System.debug('** mapOfOppIdToListOfCV '+mapOfOppIdToListOfCV);
        if(isApprovedPhySignOpps == true){
            for(Opportunity opp : listOfOpportunity){
                Boolean isExist = false;
                for(ContentVersion cv : mapOfOppIdToListOfCV.get(opp.Id)){
                    if(opp.ESign_Category__c == 'Physical Sign' && cv.System_Generated__c == false){ 
                        isExist = true;
                        break;
                    }
                }
                if(!isExist){
                    opp.addError('Please Upload the OrderForm and update the Type of Document to Order Form to submit it for Physical Sign');
                }
            }
        }else{
            for(Opportunity opp : listOfOpportunity){
                Boolean isExist = false;
                if(mapOfOppIdToListOfCV.containsKey(opp.Id)){
                    for(ContentVersion cv : mapOfOppIdToListOfCV.get(opp.Id)){
                        if(opp.ESign_Category__c == 'E-Sign' && cv.System_Generated__c == true){ //&& cv.ESign_Status__c == 'Request for ESign'
                            isExist = true;
                            break;
                        }else if(opp.ESign_Category__c == 'Physical Sign'){ //&& cv.System_Generated__c == false
                            isExist = true;
                            break;
                        }
                    }
                    if(!isExist){
                        if(opp.ESign_Category__c == 'E-Sign'){
                            opp.addError('Please Generate the '+eSignConfig.get('Type_Of_Doc').Value__c+' for ESign before submitting for Approval');
                        }/*else{
opp.addError('Please Complete the Physical Sign and upload the '+eSignConfig.get('Type_Of_Doc').Value__c+' before submitting for Approval');
}*/
                    }
                }else{
                    opp.addError('Please Generate '+eSignConfig.get('Type_Of_Doc').Value__c+' before submitting for Approval');
                }
            }
        }
        
    }
    
    //Added by Raksha for Esign callOut
    public static void eSignCallOutCTXAndClient(List<Opportunity> listOfOpportunitiesForESignRequest,Map<String,String> mapOfOppToItsESignCustomerId){
        //System.debug('eSignCallOutCTXAndClient Helper ');
        Map<Id,Opportunity> mapOfOppForEsignRequest = new Map<Id,Opportunity>(listOfOpportunitiesForESignRequest);
        Map<Id,Opportunity> mapOfOppForEsignRequestDocket = new Map<Id,Opportunity>([SELECT Id,name,E_Sign_Type__c,CC__c,ESign_Category__c,
                                                                                     E_Sign_Customer_Info__c,OTP_For_Electronic_Signature__c,Esign_Order__c,
                                                                                     account.name,recordType.name,owner.name,Amount__c
                                                                                     FROM opportunity WHERE id IN: listOfOpportunitiesForESignRequest]);
        List<List<ESignRequestCallOutGeneric.valueInitiators>> listOfeSignRequestValues = new List<List<ESignRequestCallOutGeneric.valueInitiators>>();
        set<Id> setOfOppIds = new set<Id>();
        set<Id> setOfDocIds = new set<Id>();
        Map<Id,List<Id>> oppIdWithContentDocId = new Map<Id,List<Id>>();
        Map<Id, List<Quote>> mapOfQuote = new Map<Id, List<Quote>>();
        Map<Id,ContentVersion> versionWithType = new Map<Id,ContentVersion>();
        Map<Id,Quote> mapOfQuotes = new Map<Id,Quote>();
        Map<Id,List<ContentVersion>> entityIdWithContentVersion = new Map<Id,List<ContentVersion>>();
        //Newely Added start
        //Map<String,String> mapOfContentDocIdToOppId = new Map<String,String>();
        Map<Id,ContentVersion> entityIdWithESignContentVersion = new Map<Id,ContentVersion>();
        //Newely added end
        
        Map<String, E_Sign_Config__c> eSignConfig = E_Sign_Config__c.getAll();
        
        Map<Id,Contact> mapOfCustomerContacts = new Map<Id,Contact>([SELECT id, name, email,mobilephone,phone from Contact WHERE id IN: mapOfOppToItsESignCustomerId.values()]);
        
        List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId,LinkedEntityId 
                                                    FROM ContentDocumentLink WHERE LinkedEntityId IN: mapOfOppForEsignRequest.keySet() ];
        //System.debug('^ contentDocList '+contentDocList);
        
        for(ContentDocumentLink tempContent : contentDocList){
            setOfDocIds.add(tempContent.ContentDocumentId);
            if(oppIdWithContentDocId.containsKey(tempContent.LinkedEntityId)){
                List<Id> newListValue = oppIdWithContentDocId.get(tempContent.LinkedEntityId);
                newListValue.add(tempContent.ContentDocumentId);
                oppIdWithContentDocId.put(tempContent.LinkedEntityId,newListValue);
            }else{
                oppIdWithContentDocId.put(tempContent.LinkedEntityId,new list<Id>{tempContent.ContentDocumentId});
            }
            //Newely added start
            //mapOfContentDocIdToOppId.put(tempContent.ContentDocumentId,tempContent.LinkedEntityId);
            //Newely added end
        }
        //System.debug('^ oppIdWithContentDocId '+oppIdWithContentDocId);
        
        List<ContentVersion> contentverList = [SELECT Id,Title,FileType,Type_of_document__c,
                                               ContentDocumentId,VersionData,System_Generated__c,CreatedDate  
                                               FROM ContentVersion 
                                               WHERE ContentDocumentId IN: setOfDocIds AND IsLatest = true AND
                                               Type_of_document__c =: eSignConfig.get('Type_Of_Doc').Value__c];
        //System.debug('^ contentverList '+contentverList);
        for(ContentVersion tempVersion : contentverList){
            versionWithType.put(tempVersion.ContentDocumentId, tempVersion );
        }
        //System.debug('^ versionWithType '+versionWithType);
        
        for(Id OppId : oppIdWithContentDocId.keySet()){
            for(Id tempContentId : versionWithType.keySet()){
                if(oppIdWithContentDocId.get(OppId).Contains(tempContentId)){
                    if(entityIdWithContentVersion.containsKey(OppId)){
                        List<ContentVersion> newListValue = entityIdWithContentVersion.get(OppId);
                        newListValue.add(versionWithType.get(tempContentId));
                        entityIdWithContentVersion.put(OppId,newListValue);
                    }else{
                        entityIdWithContentVersion.put(OppId,new list<ContentVersion>{versionWithType.get(tempContentId)});
                    }
                }
            }
        }
        //System.debug('^ entityIdWithContentVersion '+entityIdWithContentVersion);
        for(String oppId : entityIdWithContentVersion.keySet()){
            Opportunity tempOpptyRecord = mapOfOppForEsignRequest.get(oppId);
            List<ContentVersion> contentVersions = entityIdWithContentVersion.get(oppId);
            for(ContentVersion cv : contentVersions){
                //System.debug('^ cv '+cv);
                //System.debug('^ New CreatedDate '+cv.CreatedDate);
                if(entityIdWithESignContentVersion.containsKey(oppId)){
                    // System.debug('^ Existing CreatedDate '+entityIdWithESignContentVersion.get(oppId).CreatedDate);
                }
                if(tempOpptyRecord.ESign_Category__c == 'Physical Sign' && cv.System_Generated__c == false){
                    if((!entityIdWithESignContentVersion.containsKey(oppId)) || (entityIdWithESignContentVersion.containsKey(oppId) && entityIdWithESignContentVersion.get(oppId).CreatedDate < cv.CreatedDate)){
                        entityIdWithESignContentVersion.put(oppId, cv);
                    }
                }else if(tempOpptyRecord.ESign_Category__c == 'E-Sign' && (cv.System_Generated__c == true || 
                                                                           (tempOpptyRecord.Country_of_Origin__c != 'India' &&
                                                                            tempOpptyRecord.Country_of_Origin__c != 'N/A' &&
                                                                            tempOpptyRecord.Country_of_Origin__c != NULL) ) ){
                                                                                if((!entityIdWithESignContentVersion.containsKey(oppId)) || (entityIdWithESignContentVersion.containsKey(oppId) && entityIdWithESignContentVersion.get(oppId).CreatedDate < cv.CreatedDate)){
                                                                                    entityIdWithESignContentVersion.put(oppId, cv);
                                                                                    //system.debug('Here for international!');
                                                                                }
                                                                            }
            }
        }
        //System.debug('^ entityIdWithESignContentVersion '+entityIdWithESignContentVersion);
        
        for(Opportunity tempOpportunity : listOfOpportunitiesForESignRequest){
            List<ESignRequestCallOutGeneric.valueInitiators> listOfeSignRequestValuesInitiators = new List<ESignRequestCallOutGeneric.valueInitiators>();
            //System.debug('^ tempOpportunity '+tempOpportunity);
            //system.debug('res '+entityIdWithContentVersion.get(tempOpportunity.SyncedQuoteID).size());
            if(entityIdWithContentVersion.containsKey(tempOpportunity.Id)){
                /*if(! (entityIdWithContentVersion.get(tempOpportunity.Id).size()>0) ){
tempOpportunity.addError(eSignConfig.get('Error-Document').Error_Message__c);
}else{*/
                //System.debug('^ tempOpportunity '+tempOpportunity);
                //System.debug('^ ContentVersion '+entityIdWithESignContentVersion.get(tempOpportunity.Id));
                ESignRequestCallOutGeneric eSignRequest = new ESignRequestCallOutGeneric();
                //CTX
                ESignRequestCallOutGeneric.valueInitiators eSignRequestValueCTX = new ESignRequestCallOutGeneric.valueInitiators();
                eSignRequestValueCTX.contentVersionId = entityIdWithESignContentVersion.get(tempOpportunity.Id).Id;//entityIdWithContentVersion.get(tempOpportunity.Id)[0].Id;
                eSignRequestValueCTX.contentVersionFileType = entityIdWithESignContentVersion.get(tempOpportunity.Id).FileType; //entityIdWithContentVersion.get(tempOpportunity.Id)[0].FileType;
                eSignRequestValueCTX.contentVersionData = EncodingUtil.base64Encode(entityIdWithESignContentVersion.get(tempOpportunity.Id).VersionData);//EncodingUtil.base64Encode(entityIdWithContentVersion.get(tempOpportunity.Id)[0].VersionData);
                eSignRequestValueCTX.contentVersionTitle = entityIdWithESignContentVersion.get(tempOpportunity.Id).Title;//entityIdWithContentVersion.get(tempOpportunity.Id)[0].Title;
                eSignRequestValueCTX.signerType = 'Signer-CTX';//'Signer-Customer';
                
                /**	Signer Based on Entity Type : START : BIBHU Changed on 24/11/2022	**/
                if(
                    
                    tempOpportunity.ClearTax_Billing_Entity__c == 'CimplyFive'
                ){
                    /** Cimplifive Greater then 10 Lakhs    **/
                    if( tempOpportunity.Amount__c >= Decimal.ValueOf(System.label.ESign_Amount_Threshold_Cimplifive_10)){
                        eSignRequestValueCTX.signerEmailId = eSignConfig.get('CTX-Signer-Email-ID-Srivatsan').Value__c;
                        eSignRequestValueCTX.signerName = eSignConfig.get('CTX-Signer-Name-Srivatsan').Value__c;
                        eSignRequestValueCTX.signerMobileNo = eSignConfig.get('CTX-Signer-Mobile-Srivatsan').Value__c;
                    }
                    /** Cimplifive Less then 10 Lakhs   **/
                    else if( tempOpportunity.Amount__c < Decimal.ValueOf(System.label.ESign_Amount_Threshold_Cimplifive_10) ){
                        eSignRequestValueCTX.signerEmailId = eSignConfig.get('CTX-Signer-Email-ID-Shankar').Value__c;
                        eSignRequestValueCTX.signerName = eSignConfig.get('CTX-Signer-Name-Shankar').Value__c;
                        eSignRequestValueCTX.signerMobileNo = eSignConfig.get('CTX-Signer-Mobile-Shankar').Value__c;
                    }
                }
                else if(
                    tempOpportunity.Amount__c > Decimal.ValueOf(System.label.ESign_Amount_Threshold) || 
                    tempOpportunity.ClearTax_Billing_Entity__c == 'Xpedize'
                ){
                    eSignRequestValueCTX.signerEmailId = eSignConfig.get('CTX-Signer-Email-ID').Value__c;
                    eSignRequestValueCTX.signerName = eSignConfig.get('CTX-Signer-Name').Value__c;
                    eSignRequestValueCTX.signerMobileNo = eSignConfig.get('CTX-Signer-Mobile').Value__c;
                }else{
                    eSignRequestValueCTX.signerEmailId = eSignConfig.get('CTX-Signer-Email-ID1').Value__c;
                    eSignRequestValueCTX.signerName = eSignConfig.get('CTX-Signer-Name1').Value__c;
                    eSignRequestValueCTX.signerMobileNo = eSignConfig.get('CTX-Signer-Mobile1').Value__c;
                }
                /**	Signer Based on Entity Type : END : BIBHU Changed on 24/11/2022	**/
                
                
                eSignRequestValueCTX.signerId = eSignConfig.get('CTX-Signer-ID').Value__c;
                eSignRequestValueCTX.eSignType = eSignConfig.get('CTX-Signer-Type').Value__c;
                if(tempOpportunity.ESign_Category__c == 'E-Sign'){
                    eSignRequestValueCTX.eSignType = tempOpportunity.E_Sign_Type__c;
                }
                //System.debug('eSignConfig CTX-Signer-Mode-Of-OPT '+eSignConfig.get('CTX-Signer-Mode-Of-OPT').Value__c);
                eSignRequestValueCTX.modeOfOTPForElectronicSignature = eSignConfig.get('CTX-Signer-Mode-Of-OPT').Value__c;
                //System.debug(' eSignRequestValueCTX.modeOfOTPForElectronicSignature '+ eSignRequestValueCTX.modeOfOTPForElectronicSignature);
                eSignRequestValueCTX.ccAddress = tempOpportunity.CC__c  ;//Pramodh CC
                eSignRequestValueCTX.signatureSequence = '1';
                eSignRequestValueCTX.recordId = tempOpportunity.Id;
                eSignRequestValueCTX.docket_description ='For ' +  mapOfOppForEsignRequestDocket.get(tempOpportunity.id).account.Name + ' - Opportunity Type :'+ mapOfOppForEsignRequestDocket.get(tempOpportunity.id).recordType.name
                    + ' - by CTX Owner :'+mapOfOppForEsignRequestDocket.get(tempOpportunity.id).Owner.Name+' for Opportunity Name :'+ tempOpportunity.name + ' of Price '+ tempOpportunity.Amount__c ; //Fetching reference fields through mapOfOppForEsignRequestDocket
                
                
                //Client
                if(tempOpportunity.ESign_Category__c == 'E-Sign'){
                    ESignRequestCallOutGeneric.valueInitiators eSignRequestValuesCustomer = new ESignRequestCallOutGeneric.valueInitiators();
                    eSignRequestValuesCustomer.contentVersionId = entityIdWithESignContentVersion.get(tempOpportunity.Id).Id;//entityIdWithContentVersion.get(tempOpportunity.Id)[0].Id;
                    eSignRequestValuesCustomer.contentVersionFileType = entityIdWithESignContentVersion.get(tempOpportunity.Id).FileType;//entityIdWithContentVersion.get(tempOpportunity.Id)[0].FileType;
                    eSignRequestValuesCustomer.contentVersionData = EncodingUtil.base64Encode(entityIdWithESignContentVersion.get(tempOpportunity.Id).VersionData);//EncodingUtil.base64Encode(entityIdWithContentVersion.get(tempOpportunity.Id)[0].VersionData);
                    eSignRequestValuesCustomer.contentVersionTitle = entityIdWithESignContentVersion.get(tempOpportunity.Id).Title;//entityIdWithContentVersion.get(tempOpportunity.Id)[0].Title;
                    eSignRequestValuesCustomer.signerType = 'Signer-Customer';
                    eSignRequestValuesCustomer.signerId = tempOpportunity.E_Sign_Customer_Info__c;
                    if(mapOfCustomerContacts.containsKey(tempOpportunity.E_Sign_Customer_Info__c) && mapOfCustomerContacts.get(tempOpportunity.E_Sign_Customer_Info__c).email != null){
                        eSignRequestValuesCustomer.signerEmailId = mapOfCustomerContacts.get(tempOpportunity.E_Sign_Customer_Info__c).Email;
                    }
                    if(mapOfCustomerContacts.containsKey(tempOpportunity.E_Sign_Customer_Info__c) && mapOfCustomerContacts.get(tempOpportunity.E_Sign_Customer_Info__c).name != null){
                        eSignRequestValuesCustomer.signerName = mapOfCustomerContacts.get(tempOpportunity.E_Sign_Customer_Info__c).name;
                    }
                    if(mapOfCustomerContacts.containsKey(tempOpportunity.E_Sign_Customer_Info__c) && mapOfCustomerContacts.get(tempOpportunity.E_Sign_Customer_Info__c).Phone != null){
                        eSignRequestValuesCustomer.signerMobileNo =  mapOfCustomerContacts.get(tempOpportunity.E_Sign_Customer_Info__c).Phone;
                    }
                    eSignRequestValuesCustomer.eSignType = tempOpportunity.E_Sign_Type__c;
                    //System.debug('tempOpportunity.OTP_For_Electronic_Signature__c '+tempOpportunity.OTP_For_Electronic_Signature__c);
                    eSignRequestValuesCustomer.modeOfOTPForElectronicSignature = tempOpportunity.OTP_For_Electronic_Signature__c;
                    //System.debug('eSignRequestValuesCustomer.modeOfOTPForElectronicSignature '+eSignRequestValuesCustomer.modeOfOTPForElectronicSignature);
                    eSignRequestValuesCustomer.ccAddress = tempOpportunity.CC__c  ;//Pramodh CC
                    eSignRequestValuesCustomer.recordId = tempOpportunity.Id;
                    eSignRequestValueCTX.docket_description ='For ' +  mapOfOppForEsignRequestDocket.get(tempOpportunity.id).account.Name + ' - Opportunity Type :'+ mapOfOppForEsignRequestDocket.get(tempOpportunity.id).recordType.name
                        + ' - by CTX Owner :'+mapOfOppForEsignRequestDocket.get(tempOpportunity.id).Owner.Name+' for Opportunity Name :'+ tempOpportunity.name + ' of Price '+ tempOpportunity.Amount__c ; //Fetching reference fields through mapOfOppForEsignRequestDocket
                    If(tempOpportunity.Esign_Order__c == 'Client First'){
                        eSignRequestValuesCustomer.signatureSequence = '1';
                        eSignRequestValueCTX.signatureSequence = '2';
                    }else{
                        eSignRequestValuesCustomer.signatureSequence = '2';
                        eSignRequestValueCTX.signatureSequence = '1';
                    }
                    listOfeSignRequestValuesInitiators.add(eSignRequestValuesCustomer);
                    //System.debug('eSignRequestValuesCustomer '+eSignRequestValuesCustomer);
                }
                //System.debug('eSignRequestValueCTX '+eSignRequestValueCTX);
                listOfeSignRequestValuesInitiators.add(eSignRequestValueCTX);
                //}
            }
            else{
                tempOpportunity.addError(eSignConfig.get('Error-Document').Error_Message__c);
            }
            
            if(listOfeSignRequestValuesInitiators.size()>0){
                //ESignQueueableForCallOut tempESignQueueableForCallOut = new ESignQueueableForCallOut(listOfeSignRequestValuesInitiators);
                listOfeSignRequestValues.add(listOfeSignRequestValuesInitiators);
            }
        }
        
        If(listOfeSignRequestValues.size()>0){
            ESignQueueableForCallOut tempESignQueueableForCallOut = new ESignQueueableForCallOut(listOfeSignRequestValues);
            System.enqueueJob(tempESignQueueableForCallOut);
        }
    }
    
    /*Method added by Raksha
public static void updateQLI(Map<String,Opportunity> mapOfOpportunity){
Map<String,String> mapOfOpptyToQuote = new Map<String,String>();
Map<String,List<QuoteLineItem>> mapOfOpptyToListOfItsQLI = new Map<String,List<QuoteLineItem>>();
List<Quote> listOfSyncedQuotes = [SELECT id,OpportunityId FROM Quote WHERE OpportunityId=:mapOfOpportunity.keySet() AND IsSyncing=true LIMIT 1];
for(Quote q : listOfSyncedQuotes){
mapOfOpptyToQuote.put(q.OpportunityId,q.Id);
}     
List<QuoteLineItem> listOfQLI = [SELECT id,QuoteId,Quote.OpportunityId FROM QuoteLineItem WHERE QuoteId =:mapOfOpptyToQuote.values()];
for(QuoteLineItem qli : listOfQLI){
Opportunity opp = mapOfOpportunity.get(qli.Quote.OpportunityId);
if(opp.Term_Months__c != null){
qli.Term_Months__c = String.valueOf(opp.Term_Months__c); 
}else{
qli.Term_Months__c = '0';
}
}
if(!listOfQLI.isEmpty()){
update listOfQLI;
}

}*/
    public static void CreateContactRoles(Map<Id,Opportunity> MapOfNewOpportuinty,Map<Id,Opportunity> MapOfOldOpportuinty){
        
        Set<Id> conId = new Set<Id>();
        for(Id curId: MapOfNewOpportuinty.KeySet()){
            Opportunity NewIns = MapOfNewOpportuinty.get(curId);
            conId.add(NewIns.Bus_POC__c);
            conId.add(NewIns.Finance_Head_contact__c);
            conId.add(NewIns.Tax_Head_contact__c);
            conId.add(NewIns.IT_Head_contact__c);
            conId.add(NewIns.Finance_POC_contact__c);
        }
        Map<Id,Contact> conList                                  = new Map<Id,Contact>(
            [SELECT id,Designation_Oppor__c  FROM contact WHERE id in: conId]
        );
        //List<OpportunityContactRole> newContactRoleList          = new List<OpportunityContactRole>();
        Map<String,OpportunityContactRole> newContactRoleListMap = new Map<String,OpportunityContactRole>();
        //List<OpportunityContactRole> delContactRoleList = new List<OpportunityContactRole>();
        Map<Id,OpportunityContactRole> existingContactRoleMap    = new Map<Id,OpportunityContactRole>();
        //Map<Id,Set<OpportunityContactRole>> delContactRoleMap = new Map<Id,Set<OpportunityContactRole>>();
        
        for(OpportunityContactRole conRoleIns :[SELECT id,role,contactId,OpportunityId FROM OpportunityContactRole WHERE opportunityId in: MapOfNewOpportuinty.KeySet()] ){
            existingContactRoleMap.put(conRoleIns.contactId,conRoleIns);
            /**Set<OpportunityContactRole> tempSet = new Set<OpportunityContactRole>();
if(!delContactRoleMap.ContainsKey(conRoleIns.OpportunityId)){
tempSet.add(conRoleIns);
delContactRoleMap.put(conRoleIns.OpportunityId,tempSet);
}
else{
tempSet = delContactRoleMap.get(conRoleIns.OpportunityId);
tempSet.add(conRoleIns);
delContactRoleMap.put(conRoleIns.OpportunityId,tempSet);
}**/
        }
        
        for(Id curId: MapOfNewOpportuinty.KeySet()){
            Opportunity newIns = MapOfNewOpportuinty.get(curId);
            Opportunity oldIns = MapOfOldOpportuinty.get(curId);
            
            if(!newIns.Order_form_generated_c__c.equals(oldIns.Order_form_generated_c__c) ||
               (
                   newIns.Bus_POC__c != oldIns.Bus_POC__c ||
                   newIns.Finance_Head_contact__c != oldIns.Finance_Head_contact__c ||
                   newIns.Tax_Head_contact__c != oldIns.Tax_Head_contact__c ||
                   newIns.IT_Head_contact__c != oldIns.IT_Head_contact__c ||
                   newIns.Finance_POC_contact__c != oldIns.Finance_POC_contact__c || 
                   newIns.StageName != oldIns.StageName && newIns.StageName != OpportunityConstants.STAGENAME_CLOSED_LOST
               ) 
              ){ 
                  
                  if(newIns.Bus_POC__c != null){
                      OpportunityContactRole temp = new OpportunityContactRole();
                      if(!existingContactRoleMap.containsKey(newIns.Bus_POC__c)){
                          temp = switchContactRole(conList.get(newIns.Bus_POC__c),curId,null);
                          
                          //newContactRoleList.add(switchContactRole(conList.get(newIns.Bus_POC__c),curId,null));
                      }
                      else{
                          temp = switchContactRole(conList.get(newIns.Bus_POC__c),curId,existingContactRoleMap.get(newIns.Bus_POC__c).Id);
                          //newContactRoleList.add(switchContactRole(conList.get(newIns.Bus_POC__c),curId,existingContactRoleMap.get(newIns.Bus_POC__c).Id)); 
                      }
                      newContactRoleListMap.put(String.ValueOf(temp.OpportunityId)+String.ValueOf(temp.Contactid),temp);
                  }
                  if(newIns.Finance_Head_contact__c != null){
                      OpportunityContactRole temp = new OpportunityContactRole();
                      if(!existingContactRoleMap.containsKey(newIns.Finance_Head_contact__c)){
                          temp = switchContactRole(conList.get(newIns.Finance_Head_contact__c),curId,null);
                          
                          //newContactRoleList.add(switchContactRole(conList.get(newIns.Finance_Head_contact__c),curId,null));
                      }
                      else{
                          temp = switchContactRole(conList.get(newIns.Finance_Head_contact__c),curId,existingContactRoleMap.get(newIns.Finance_Head_contact__c).Id);
                          //newContactRoleList.add(switchContactRole(conList.get(newIns.Finance_Head_contact__c),curId,existingContactRoleMap.get(newIns.Finance_Head_contact__c).Id)); 
                      }
                      newContactRoleListMap.put(String.ValueOf(temp.OpportunityId)+String.ValueOf(temp.Contactid),temp);
                  }
                  if(newIns.Tax_Head_contact__c != null){
                      OpportunityContactRole temp = new OpportunityContactRole();
                      if(!existingContactRoleMap.containsKey(newIns.Tax_Head_contact__c)){
                          temp = switchContactRole(conList.get(newIns.Tax_Head_contact__c),curId,null);
                          //newContactRoleList.add(switchContactRole(conList.get(newIns.Tax_Head_contact__c),curId,null));
                      }
                      else{
                          temp = switchContactRole(conList.get(newIns.Tax_Head_contact__c),curId,existingContactRoleMap.get(newIns.Tax_Head_contact__c).Id);
                          //newContactRoleList.add(switchContactRole(conList.get(newIns.Tax_Head_contact__c),curId,existingContactRoleMap.get(newIns.Tax_Head_contact__c).Id)); 
                      }
                      newContactRoleListMap.put(String.ValueOf(temp.OpportunityId)+String.ValueOf(temp.Contactid),temp);
                  }
                  if(newIns.IT_Head_contact__c != null){
                      OpportunityContactRole temp = new OpportunityContactRole();
                      if(!existingContactRoleMap.containsKey(newIns.IT_Head_contact__c)){
                          temp = switchContactRole(conList.get(newIns.IT_Head_contact__c),curId,null);
                          //newContactRoleList.add(switchContactRole(conList.get(newIns.IT_Head_contact__c),curId,null));
                      }
                      else{
                          temp = switchContactRole(conList.get(newIns.IT_Head_contact__c),curId,existingContactRoleMap.get(newIns.IT_Head_contact__c).Id);
                          
                          // newContactRoleList.add(switchContactRole(conList.get(newIns.IT_Head_contact__c),curId,existingContactRoleMap.get(newIns.IT_Head_contact__c).Id)); 
                      }
                      newContactRoleListMap.put(String.ValueOf(temp.OpportunityId)+String.ValueOf(temp.Contactid),temp);
                  }
                  if(newIns.Finance_POC_contact__c != null){
                      OpportunityContactRole temp = new OpportunityContactRole();
                      if(!existingContactRoleMap.containsKey(newIns.Finance_POC_contact__c)){
                          temp = switchContactRole(conList.get(newIns.Finance_POC_contact__c),curId,null);
                          //newContactRoleList.add(switchContactRole(conList.get(newIns.Finance_POC_contact__c),curId,null));
                      }
                      else{
                          temp = switchContactRole(conList.get(newIns.Finance_POC_contact__c),curId,existingContactRoleMap.get(newIns.Finance_POC_contact__c).Id);
                          //newContactRoleList.add(switchContactRole(conList.get(newIns.Finance_POC_contact__c),curId,existingContactRoleMap.get(newIns.Finance_POC_contact__c).Id)); 
                      }
                      newContactRoleListMap.put(String.ValueOf(temp.OpportunityId)+String.ValueOf(temp.Contactid),temp);
                  }
                  /**if(delContactRoleMap.ContainsKey(curId)){
delContactRoleList.addAll(new List<OpportunityContactRole>(delContactRoleMap.get(curId)));
}**/
              }
        }
        
        if(newContactRoleListMap.Values().Size() >0){
            /** Set<OpportunityContactRole> tempSet = new Set<OpportunityContactRole>();
tempSet.addAll(newContactRoleList);
tempSet.remove(null);
newContactRoleList = new List<OpportunityContactRole> (tempSet); //To remove duplicates**/
            upsert(newContactRoleListMap.Values());
        }
        /**if(delContactRoleList.size()>0){
delete(delContactRoleList);
}**/
    }
    
    public static OpportunityContactRole switchContactRole(Contact con,Id opporId,Id conRoleId){
        OpportunityContactRole contactRoleIns = new OpportunityContactRole();
        if(conRoleId == null){
            switch on con.Designation_Oppor__c{
                when 'Business'  {
                    contactRoleIns.OpportunityId = opporId;
                    contactRoleIns.ContactId = con.Id;
                    contactRoleIns.Role = 'Decision Maker';
                    return contactRoleIns;
                    
                }
                when 'Finance/Invoice Processing' {
                    contactRoleIns.OpportunityId = opporId;
                    contactRoleIns.ContactId = con.Id;
                    contactRoleIns.Role = 'Economic Decision Maker';
                    return contactRoleIns;
                }
                when 'IT' {
                    contactRoleIns.OpportunityId = opporId;
                    contactRoleIns.ContactId = con.Id;
                    contactRoleIns.Role = 'Technical Buyer';
                    return contactRoleIns;
                }
                when 'Finance' {
                    contactRoleIns.OpportunityId = opporId;
                    contactRoleIns.ContactId = con.Id;
                    contactRoleIns.Role = 'Economic Buyer';
                    return contactRoleIns;
                }
                when 'Tax' {
                    contactRoleIns.OpportunityId = opporId;
                    contactRoleIns.ContactId = con.Id;
                    contactRoleIns.Role = 'Evaluator';
                    return contactRoleIns;
                }
                when 'CEO' {
                    contactRoleIns.OpportunityId = opporId;
                    contactRoleIns.ContactId = con.Id;
                    contactRoleIns.Role = 'Other';
                    return contactRoleIns;
                }
            }
        }
        else{
            switch on con.Designation_Oppor__c{
                when 'Business'  {
                    contactRoleIns.OpportunityId = opporId;
                    contactRoleIns.Id = conRoleId;
                    contactRoleIns.ContactId = con.Id;
                    contactRoleIns.Role = 'Decision Maker';
                    return contactRoleIns;
                    
                }
                when 'Finance/Invoice Processing' {
                    contactRoleIns.OpportunityId = opporId;
                    contactRoleIns.Id = conRoleId;
                    contactRoleIns.ContactId = con.Id;
                    contactRoleIns.Role = 'Economic Decision Maker';
                    return contactRoleIns;
                }
                when 'IT' {
                    contactRoleIns.OpportunityId = opporId;
                    contactRoleIns.Id = conRoleId;
                    contactRoleIns.ContactId = con.Id;
                    contactRoleIns.Role = 'Technical Buyer';
                    return contactRoleIns;
                }
                when 'Finance' {
                    contactRoleIns.OpportunityId = opporId;
                    contactRoleIns.Id = conRoleId;
                    contactRoleIns.ContactId = con.Id;
                    contactRoleIns.Role = 'Economic Buyer';
                    return contactRoleIns;
                }
                when 'Tax' {
                    contactRoleIns.OpportunityId = opporId;
                    contactRoleIns.Id = conRoleId;
                    contactRoleIns.ContactId = con.Id;
                    contactRoleIns.Role = 'Evaluator';
                    return contactRoleIns;
                }
                when 'CEO' {
                    contactRoleIns.OpportunityId = opporId;
                    contactRoleIns.Id = conRoleId;
                    contactRoleIns.ContactId = con.Id;
                    contactRoleIns.Role = 'Other';
                    return contactRoleIns;
                }
            }
        }
        return null;
    }
    
    /** START : bhaveshjindal : block opportunities if Account has a parent account populated **/
    public static void blockOpportunities(List<Opportunity> opportunityList, Boolean isUpdated){
        /**  set<Id> accountIds = new set<Id>();
for(Opportunity thisRec : opportunityList){
accountIds.add(thisRec.AccountId);
}
Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id, ParentID FROM Account WHERE Id IN :accountIds]);
for(Opportunity thisRec : opportunityList){
if(accMap.containsKey(thisRec.AccountId) && accMap.get(thisRec.AccountId).ParentID != NULL 
&& thisRec.RecordTypeId != OpportunityConstants.RECORDTYPEID_RENEWAL_MULTI_YEAR){
if(isUpdated){
thisRec.addError('You cannot update this opportunity stage. Parent account exists for this account.');
}else{
thisRec.addError('You cannot create Net new, cross-sell/upsell or renewal opportunity for this Account. A parent account already exists for this Account.');
}
}
}**/
    }   
    
    /** START : Ashwin : restrictPaymentTerms **/
    public static void restrictPaymentTerms(Map<Id,Opportunity> newOppMap,Map<Id,Opportunity> oldOppMap){
        
        Map<Id,List<String>> oppProductCategoryMap = new Map<Id,List<String>>();
        Map<Id,Double> oppIdAccountARRMap 			= new Map<Id,Double>();
        Map<Id,Double> oppIdOppIntegMap 			= new Map<Id,Double>();
        
        for(OpportunityLineItem thisRec : [SELECT Id, Product_Category__c, OpportunityId, 
                                           Opportunity.Account.Sum_of_ARR_Assets__c,
                                           Sale_Price__c
                                           FROM OpportunityLineItem 
                                           WHERE OpportunityId IN :newOppMap.keySet()])
        {
            if(thisRec.Product_Category__c == 'Integration'){
                if(oppIdOppIntegMap.containsKey(thisRec.OpportunityId))
                {
                    Double tempPrice = oppIdOppIntegMap.get(thisRec.OpportunityId) + thisRec.Sale_Price__c;
                    oppIdOppIntegMap.put(thisRec.OpportunityId, tempPrice); 
                }else{
                    oppIdOppIntegMap.put(thisRec.OpportunityId, thisRec.Sale_Price__c);    
                }
            }
            oppIdAccountARRMap.put(thisRec.OpportunityId, thisRec.Opportunity.Account.Sum_of_ARR_Assets__c);
            
            if(oppProductCategoryMap.containsKey(thisRec.OpportunityId)){
                oppProductCategoryMap.get(thisRec.OpportunityId).add(thisRec.Product_Category__c);
            }else{
                oppProductCategoryMap.put(thisRec.OpportunityId, new List<String> {thisRec.Product_Category__c});
            }
        }
        
        for(Id key : newOppMap.keySet()){
            Opportunity oppNewInstance=(Opportunity)newOppMap.get(key);
            
            if(oppNewInstance.RecordTypeId == OpportunityConstants.RECORDTYPEID_NET_NEW 				||
               oppNewInstance.ClearTax_Billing_Entity__c == 'Xpedize'			    || 
               oppNewInstance.RecordTypeId == OpportunityConstants.RECORDTYPEID_CROSS_SELL_OR_UPSELL 	    ||
               oppNewInstance.RecordTypeId == OpportunityConstants.RECORDTYPEID_RENEWAL 				    ||
               oppNewInstance.RecordTypeId == OpportunityConstants.RECORDTYPEID_RENEWAL_MULTI_YEAR	        ||
               oppNewInstance.RecordTypeId == OpportunityConstants.RECORDTYPEID_UPSELL 					||
               oppNewInstance.RecordTypeId == OpportunityConstants.RECORDTYPEID_WINBACK){
                   Double tempValueNonIntegration;
                   Double tempValueIntegration 		= oppIdOppIntegMap.get(oppNewInstance.Id);
                   if(tempValueIntegration == NULL){
                       tempValueIntegration = 0;
                   }
                   if(oppIdAccountARRMap.get(key) == NULL){
                       tempValueNonIntegration = oppNewInstance.Total_Amount__c - tempValueIntegration;
                   }
                   else{
                       tempValueNonIntegration 	    = (oppNewInstance.Total_Amount__c + oppIdAccountARRMap.get(key)) - tempValueIntegration; 
                   }
                   System.debug('#tempValueIntegration'+tempValueIntegration);
                   System.debug('#tempValueNonIntegration'+tempValueNonIntegration);
                   
                   if(
                       tempValueNonIntegration > 0 																	&& 
                       tempValueNonIntegration < 5000000 																&& 
                       oppNewInstance.Billing_F__c != 'Annually'														&& 
                       oppNewInstance.Billing_F__c != ''
                   ){
                       oppNewInstance.addError('Please select Billing Frequency for Subscription Fee - Annually');    
                   } else if(
                       tempValueNonIntegration >= 5000000  																&& 
                       tempValueNonIntegration < 15000000  		     													&& 
                       oppNewInstance.Billing_F__c != 'Annually'															&& 
                       oppNewInstance.Billing_F__c != 'Half-yearly'														&&
                       oppNewInstance.Billing_F__c != ''
                   ){
                       oppNewInstance.addError('Please select Billing Frequency for Subscription Fee - Annually/Half-yearly');
                   }else if(
                       tempValueNonIntegration >= 15000000  													&& 
                       oppNewInstance.Billing_F__c != 'Annually'												&& 
                       oppNewInstance.Billing_F__c != 'Half-yearly'											&&
                       oppNewInstance.Billing_F__c != 'Quarterly'												&&
                       oppNewInstance.Billing_F__c != ''
                   ){
                       oppNewInstance.addError('Please select Billing Frequency for Subscription Fee - Annually/Half-yearly/Quarterly');
                   }
                   
                   if(
                       tempValueIntegration > 0  																		&& 
                       tempValueIntegration <= 10000000  		     													&&
                       oppNewInstance.Billing_Frequency_for_Integration_Prods__c  != '100% upfront basis Integration Project start date'	&& 
                       oppNewInstance.Billing_Frequency_for_Integration_Prods__c  != ''
                   ){
                       oppNewInstance.addError('Please select Billing Frequency for Integration - 100% upfront basis Integration Project start date');
                   }
                   
                   if(
                       (tempValueNonIntegration+tempValueIntegration) 	> 0  											&& 
                       (tempValueNonIntegration+tempValueIntegration) 	< 500000  		     							&&
                       oppNewInstance.Payment_Term__c   			!= '7 days from date of invoice'					&&
                       oppNewInstance.Payment_Term__c   		    != '15 days from date of invoice'
                   ){
                       oppNewInstance.addError('Please select Payment Terms - 7 days from date of invoice/15 days from date of invoice');
                   }
               }else if(oppProductCategoryMap.containsKey(oppNewInstance.Id)){
                   
                   if(oppNewInstance.Total_Amount__c >= 0 								&& 
                      oppNewInstance.Total_Amount__c < 200000 							&& 
                      oppNewInstance.ARR_Product_Total_Amount__c > 0 					&&
                      (!(oppProductCategoryMap.get(oppNewInstance.Id).contains('MS')) 	&&
                       oppNewInstance.Total_Amount__c < 100000)						&&
                      oppNewInstance.Billing_F__c != 'Annually'						&& 
                      oppNewInstance.Billing_F__c != '')    
                       
                   {
                       oppNewInstance.addError('Please select Billing Frequency for Subscription Fee - Annually');    
                   }
                   
                   else if(oppNewInstance.Total_Amount__c >= 200000  					&& 
                           oppNewInstance.Total_Amount__c < 300000  		     		&& 
                           oppNewInstance.ARR_Product_Total_Amount__c > 0 				&& 
                           oppNewInstance.Billing_F__c != 'Annually'			&& 
                           oppNewInstance.Billing_F__c != 'Half-yearly'		&&
                           oppNewInstance.Billing_F__c != '')
                   {
                       oppNewInstance.addError('Please select Billing Frequency for Subscription Fee - Annually/Half-yearly');
                   }
                   
                   else if(oppNewInstance.Total_Amount__c >= 300000  					&& 
                           oppNewInstance.ARR_Product_Total_Amount__c > 0 				&& 
                           oppNewInstance.Billing_F__c != 'Annually'			&& 
                           oppNewInstance.Billing_F__c != 'Half-yearly'		&&
                           oppNewInstance.Billing_F__c != 'Quarterly'			&&
                           oppNewInstance.Billing_F__c != '')
                   {
                       oppNewInstance.addError('Please select Billing Frequency for Subscription Fee - Annually/Half-yearly/Quarterly');
                   }
                   
                   else if(oppNewInstance.Total_Amount__c >= 100000  					&& 
                           oppNewInstance.ARR_Product_Total_Amount__c > 0 				&& 
                           oppProductCategoryMap.get(oppNewInstance.Id).contains('MS') &&
                           oppNewInstance.Billing_F__c != 'Annually'			&& 
                           oppNewInstance.Billing_F__c != 'Half-yearly'		&&
                           oppNewInstance.Billing_F__c != 'Quarterly'			&&
                           oppNewInstance.Billing_F__c != 'Monthly in advance'	&&
                           oppNewInstance.Billing_F__c != '')
                   {
                       oppNewInstance.addError('Please select Billing Frequency for Subscription Fee - Yearly in advance/Half - Annual in advance/Quarterly in advance/Monthly in advance');
                   }
                   
                   if(oppNewInstance.Total_Amount__c >= 0  															&& 
                      oppNewInstance.Total_Amount__c < 100000  		     											&& 
                      oppProductCategoryMap.get(oppNewInstance.Id).contains('Integration') 							&&
                      oppNewInstance.OTP_Product_Total_Amount__c  > 0 												&& 
                      oppNewInstance.Billing_Frequency_for_Integration_Prods__c  != '100% upfront basis Integration Project start date'	&& 
                      oppNewInstance.Billing_Frequency_for_Integration_Prods__c  != '')
                   {
                       oppNewInstance.addError('Please select Billing Frequency for Integration - 100% upfront basis Integration Project start date');
                   }
                   
                   if(oppNewInstance.Total_Amount__c >= 0  											&& 
                      oppNewInstance.Total_Amount__c < 300000  		     							&& 
                      (oppProductCategoryMap.get(oppNewInstance.Id).contains('MS ') 					||
                       oppProductCategoryMap.get(oppNewInstance.Id).contains('Setup & Onboarding') 	||
                       oppProductCategoryMap.get(oppNewInstance.Id).contains('SaaS') 					||
                       oppProductCategoryMap.get(oppNewInstance.Id).contains('Others') 				||
                       oppProductCategoryMap.get(oppNewInstance.Id).contains('Transactional') 		||
                       oppProductCategoryMap.get(oppNewInstance.Id).contains('AMC') 					||
                       oppProductCategoryMap.get(oppNewInstance.Id).contains('TDS - MS'))				&&
                      oppNewInstance.OTP_Product_Total_Amount__c  > 0 								&& 
                      oppNewInstance.Billing_Frequency__c   != '100% Upon signing Order form'		&& 
                      oppNewInstance.Billing_Frequency__c   != '')
                   {
                       oppNewInstance.addError('Please select Billing Frequency for Service Fee (OTP) - 100% Upon signing Order form');
                   } 
               } 
        }
    }
    
    /** END : Ashwin : restrictPaymentTerms **/
    /** START : Ashwin : mandatoryBillingTerms **/
    public static void mandatoryBillingTerms(Map<Id,Opportunity> newOppMap){
        
        Set<Id> mandatoryBiilngFreqInteg = new  Set<Id>();
        Set<Id> mandatoryBiilngFreqNonInteg = new  Set<Id>();
        Set<Id> mandatoryMsBiilngFreq = new  Set<Id>();
        Set<Id> mandatoryBiilngFreqSubs = new  Set<Id>();
        
        for(Opportunity thisRec : [SELECT Id ,(SELECT Id, Product_Category__c, OpportunityId, 
                                               Sale_Price__c, Product2.Billing_Type__c 
                                               FROM OpportunityLineItems   
                                              )
                                   FROM Opportunity
                                   WHERE Id IN :newOppMap.keySet()])
        {
            
            
            if(thisRec.OpportunityLineItems.size()>0){
                for(OpportunityLineItem thisLineItem : thisRec.OpportunityLineItems){
                    if(thisLineItem.Product2.Billing_Type__c  == 'OTP'){
                        if(thisLineItem.Product_Category__c == 'Integration'){
                            mandatoryBiilngFreqInteg.add(thisRec.Id);
                        }else{
                            mandatoryBiilngFreqNonInteg.add(thisRec.Id);
                        }
                    }
                    if(thisLineItem.Product2.Billing_Type__c == 'ARR'){
                        if(thisLineItem.Product_Category__c == 'MS' ||  thisLineItem.Product_Category__c == 'TDS - MS'){
                            mandatoryMsBiilngFreq.add(thisRec.Id); 
                        }else{
                            mandatoryBiilngFreqSubs.add(thisRec.Id);
                        }
                    }
                }     
            }
        }
        
        System.debug('@mandatoryMsBiilngFreq'+mandatoryMsBiilngFreq);
        
        for(Opportunity thisRec : newOppMap.values()){
            if(mandatoryBiilngFreqInteg.contains(thisRec.Id) && thisRec.Billing_Frequency_for_Integration_Prods__c == NULL && thisRec.SyncedQuoteId != NULL){
                thisRec.addError('Please enter Billing Frequency for Integration Prods');
            }
            if(mandatoryBiilngFreqNonInteg.contains(thisRec.Id) && thisRec.Billing_Frequency__c == NULL && thisRec.SyncedQuoteId != NULL){
                thisRec.addError('Please enter Billing Frequency for Service Fee (OTP)');
            }  
            
            if(mandatoryMsBiilngFreq.contains(thisRec.Id) && thisRec.MS_Billing_Frequency__c  == NULL && thisRec.SyncedQuoteId != NULL){
                thisRec.addError('Please enter MS billing frequency ( ARR only )');
            } 
            
            if(mandatoryBiilngFreqSubs.contains(thisRec.Id) && thisRec.Billing_F__c == NULL && thisRec.SyncedQuoteId != NULL){
                thisRec.addError('Please enter Billing Frequency for Subscription Fee');
            } 
        }
    }
    
    /** Update Action Owner - Billing & Risk **/
    
    public static void UpdateBillingDetailsActionOwner(Map<Id,Opportunity> newOppMap, Map<Id,Opportunity> oldOppMap){
        Map<Id,Opportunity> oppMap  = new Map<Id,Opportunity>();
        List<Billing_Details__c> billingList = new List<Billing_Details__c>();
        for(Id key : newOppMap.keyset()){
            if(newOppMap.get(key).OwnerId != oldOppMap.get(key).OwnerId && newOppMap.get(key).OwnerId != NULL){
                oppMap.put(key,newOppMap.get(key));
            }
        }
        System.Debug('@oppMap'+oppMap);
        if(oppMap.values().size()>0){
            for(Billing_Details__c thisRec : [SELECT Id, Asset__r.Opportunity__r.OwnerId, Action_Owner_Collection__c
                                              FROM Billing_Details__c
                                              WHERE Asset__r.Opportunity__c IN :oppMap.keySet()])
            {
                if((oldOppMap.get(thisRec.Asset__r.Opportunity__c).ownerId == thisRec.Action_Owner_Collection__c) || 
                   thisRec.Action_Owner_Collection__c == NULL ){
                       thisRec.Action_Owner_Collection__c = oppMap.get(thisRec.Asset__r.Opportunity__c).ownerId; 
                       billingList.add(thisRec);  
                   }
            }
            
            System.Debug('@billingList'+billingList);
            
            try{
                if(!billingList.isEmpty()){
                    Update billingList;
                }
            }catch(Exception ex){
                System.debug(' Exception on UpdateBillingDetailsActionOwner \n'+ex.getMessage()+'\n'+ex.getLineNumber());
            }
        }
        
    }
    
    public static void calculateDealValue(List<Opportunity> ListofNewOpportuinty){
        for(Opportunity thisOpp : ListofNewOpportuinty){
            if(thisOpp.Record_Type_cumulated__c == 'Upsell_Topup'){
                thisOpp.Deal_Amount__c = thisOpp.Upsell_Amount__c;
            }else if(thisOpp.ClearTax_Billing_Entity__c == 'Xpedize' )
            {
                thisOpp.Deal_Amount__c = thisOpp.Forecast_Amount__c ; 
            }else if(thisOpp.SyncedQuoteId != NULL){
                thisOpp.Deal_Amount__c = thisOpp.Actual_Amount__c;
            }else{
                thisOpp.Deal_Amount__c = thisOpp.Forecast_Amount__c ;
            }
            
        }
    }
    
    
    public static void CreateDemoTask(Map<Id,Opportunity> newOppMap, Map<Id,Opportunity> oldOppMap){
        Map<Id, List<String>> oppProductMap = new Map<Id, List<String>>();
        Map<Id, List<String>> oldOppProductMap = new Map<Id, List<String>>();
        List<Qualifications_Questionnaire__c > qualList = new List<Qualifications_Questionnaire__c >(); 
        for(Opportunity thisOpp : newOppMap.values()){
            if(oldOppMap == NULL){
                if(thisOpp.Product__c != NULL){
                    oppProductMap.put(thisOpp.Id, thisOpp.Product__c.split(';'));
                }
            }else if(thisOpp.Product__c != NULL && thisOpp.Product__c != oldOppMap.get(thisOpp.Id).Product__c){
                if(oldOppMap.get(thisOpp.Id).Product__c != NULL){
                    oldOppProductMap.put(thisOpp.Id, oldOppMap.get(thisOpp.Id).Product__c.split(';'));
                }
                oppProductMap.put(thisOpp.Id, thisOpp.Product__c.split(';'));
            }
            
        }
        System.debug('@oppProductMap'+oppProductMap);
        if(oppProductMap.size() > 0){
            for(Id oppId : oppProductMap.keySet()){
                for(String thisProduct : oppProductMap.get(oppId)){
                    Qualifications_Questionnaire__c qual = new Qualifications_Questionnaire__c();
                    qual.RecordTypeId = Schema.SObjectType.Qualifications_Questionnaire__c.getRecordTypeInfosByDeveloperName().get('Demo_Task').getRecordTypeId();
                    qual.OwnerId = newOppMap.get(oppId).ownerId;
                    
                    if(oldOppProductMap.containsKey(oppId)){
                        if( !oldOppProductMap.get(oppId).contains(thisProduct)){
                            qual.Demo_product__c  = thisProduct;
                            qual.Opportunity__c = oppId;
                            qualList.add(qual);
                        }
                    }else{
                        qual.Demo_product__c  = thisProduct;
                        qual.Opportunity__c = oppId;
                        qualList.add(qual);
                    }
                }
                
            }
        }
        
        
        if(!qualList.isEmpty()){
            Insert qualList;
        }
        
        
    }
    
    /** Ashwin - Restrict Company Info update **/
    public static void validateCompanyInfo(Map<Id,Opportunity> newOppMap, Map<Id,Opportunity> oldOppMap){
        Id currentProfileId = userinfo.getProfileId();
        if(OpportunityConstants.ENABLE_GSTIN_VERIFICATION_RULE){
            for(Opportunity thisOpp : newOppMap.values()){
                if(
                    thisOpp.Country_of_Origin__c == 'India' &&
                    !thisOpp.Update_Company_Information__c &&
                    (thisOpp.Legal_Entity_Name_Of_The_Client__c != oldOppMap.get(thisOpp.Id).Legal_Entity_Name_Of_The_Client__c ||
                     thisOpp.If_SEZ__c != oldOppMap.get(thisOpp.Id).If_SEZ__c ||
                     thisOpp.PAN_No_as_per_PO__c != oldOppMap.get(thisOpp.Id).PAN_No_as_per_PO__c ||
                     thisOpp.Billing_Address__c != oldOppMap.get(thisOpp.Id).Billing_Address__c ||
                     thisOpp.Shipping_Address__c != oldOppMap.get(thisOpp.Id).Shipping_Address__c ||
                     thisOpp.Pincode__c != oldOppMap.get(thisOpp.Id).Pincode__c ||
                     thisOpp.City_2__c != oldOppMap.get(thisOpp.Id).City_2__c ||
                     thisOpp.State_2__c != oldOppMap.get(thisOpp.Id).State_2__c ||
                     thisOpp.Place_of_Supply__c != oldOppMap.get(thisOpp.Id).Place_of_Supply__c  ))
                {
                    thisOpp.addError(System.Label.Restrict_Company_Info_Error_Msg );
                }
                
            }
        }
    }
    
    public static void mandatoryCheckBasedOnProductInterested(Map<Id,Opportunity> newOppMap, Map<Id,Opportunity> oldOppMap){
        
        Map<String, Set<String>>	MandatoryField_PI	= new Map<String, Set<String>>();
        Set<Id> accIds = new  Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(Opportunity thisOpp : newOppMap.values()){
            
            if(thisOpp.Country_of_Origin__c 	!= 'Saudi Arabia' && 
               thisOpp.StageName != 'Closed Won' &&
               thisOpp.StageName != 'Closed Lost' &&
               thisOpp.StageName != 'In Finance Approval' &&
               System.Label.RecordType_MandatoryCheckBasedOnProductInterested.containsIgnoreCase(thisOpp.Record_Type_cumulated__c) &&
               thisOpp.Product__c 				!= oldOppMap.get(thisOpp.Id).Product__c &&
               thisOpp.Product__c  				!= NULL)
            {
                accIds.add(thisOpp.AccountId);
                oppList.add(thisOpp);
            }
        }
        
        Map<Id,Opportunity> oppMap = new  Map<Id,Opportunity>([SELECT Id, Account.EC_LC_Startup_Account__c,
                                                               Account.Is_E_Invoicing_5cr_Wave__c
                                                               FROM Opportunity 
                                                               WHERE Id IN :oppList]);
        
        if(oppList.size()>0){
            for(
                ProductIntersted_PM__c  thisRec : [ SELECT Product_Interested__c , Name, Mandatory_Fields__c 
                                                   FROM ProductIntersted_PM__c  ] 
            ){
                if(thisRec.Mandatory_Fields__c != NULL)
                    MandatoryField_PI.put(thisRec.Product_Interested__c, new Set<String> (thisRec.Mandatory_Fields__c.split(',')));
            }
            
            
            
            for(Opportunity thisOpp : oppList){
                if( !oppMap.get(thisOpp.Id).Account.Is_E_Invoicing_5cr_Wave__c ){
                    if(oppMap.get(thisOpp.Id).Account.EC_LC_Startup_Account__c != 'Emerging Corporate'){
                        Set<String>  mandatory_Field   = new Set<String>();
                        List<String> prodInterested    = thisOpp.product__c.split(';');
                        
                        for(String thisProduct : prodInterested){
                            if(MandatoryField_PI.containsKey(thisProduct)){
                                mandatory_Field.addAll(MandatoryField_PI.get(thisProduct));
                            }
                        }
                        
                        System.debug('@mandatory_Field'+mandatory_Field);
                        for(String thisField : mandatory_Field){
                            if(thisOpp.get(thisField) == NULL){
                                thisOpp.addError(thisField,'Enter value for this field');
                            }
                        }
                    }
                }
            }
        }
    }   
 
    
}