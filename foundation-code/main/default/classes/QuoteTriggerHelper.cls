/**
* @File Name          : QuoteTriggerHelper.cls
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 02-29-2024
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    07/14/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public without sharing class QuoteTriggerHelper {
    
    /**
* @description
* @author Lokesh Thathuru | 07/14/2020
* @param List<Quote> listOfNewQuotesToMarkasPrimary
* @return void
*/
    
    /**
* @description
* @author Lokesh Thathuru | 07/14/2020
* @param Set<Id> setOfQuotes
* @return void
*/
    @future
    public static void updateOpps(Set<Id> setOfQuotes){
        List<Quote> listOfQuotesWithOpportunity=DataBase.query(UtilityClass.getQueryString('Quote')+' FROM Quote WHERE ID IN :setOfQuotes');
        updateOpportunityStage(listOfQuotesWithOpportunity);
    }
    /**Asset Renewal Changes by Murali **/
    public static void deleteJunkQLI(Map<Id,Quote> mapOfQuoteAndId){
        
        List<QuoteLineItem> quoteLineItemsToDelete = [SELECT Id FROM QuoteLineItem 
                                                      WHERE QuoteId IN : mapOfQuoteAndId.keyset()
                                                      AND (Period_End_date__c = NULL  OR Period_Start_date__c = NULL  OR UnitPrice = NULL OR Sale_Price__c = NULL)];
        system.debug('quoteLineItemsToDelete '+quoteLineItemsToDelete);
        if(quoteLineItemsToDelete.size() > 0){
            delete quoteLineItemsToDelete;
        }
    }
    
    /**
* @description
* @author Lokesh Thathuru | 07/14/2020
* @param List<Quote> listOfQuotesWithOpportunity
* @return void
*/
    public static void updateOpportunityStage(List<Quote> listOfQuotesWithOpportunity){
        
        set<Id> setOfOpportunityIds=new  set<Id> ();
        
        if(listOfQuotesWithOpportunity.size()>0){
            for(Quote quoteInstance:listOfQuotesWithOpportunity){
                if(!setOfOpportunityIds.contains(quoteInstance.OpportunityId)){
                    setOfOpportunityIds.add(quoteInstance.OpportunityId);
                }
            }
        }
        
        Map<Id,Opportunity> mapOfIdWithOpportunities=new Map<Id,Opportunity>();
        if(setOfOpportunityIds.size()>0){
            mapOfIdWithOpportunities=new Map<Id,Opportunity>((List<Opportunity>)DataBase.query(UtilityClass.getQueryString('Opportunity')+',RecordType.Name FROM Opportunity WHERE ID IN: setOfOpportunityIds AND StageName!=null'));
        }
        
        if(listOfQuotesWithOpportunity.size()>0){
            for(Quote quoteInstance:listOfQuotesWithOpportunity){
                if(quoteInstance.OpportunityId!=null && mapOfIdWithOpportunities.containsKey(quoteInstance.OpportunityId)){
                    System.debug('<--->'+mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).RecordType.Name);
                    if((mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).RecordType.Name.EqualsIgnoreCase(OpportunityConstants.RECORDTYPENAME_NET_NEW) || mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).RecordType.Name.EqualsIgnoreCase(OpportunityConstants.RECORDTYPENAME_CROSS_SELL_UPSELL))){
                        switch on quoteInstance.Status {
                            When 'Draft'{
                                
                                mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).StageName = OpportunityConstants.STAGENAME_Quote_MANAGEMENT ;
                                mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).Substages__c = OpportunityConstants.SUB_STAGENAME_QUOTE_PREPARATION;
                                
                            }
                            When 'Quote Sent'{
                                
                                
                                //mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).StageName = OpportunityConstants.STAGENAME_Quote_MANAGEMENT ;
                                //mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).Substages__c = OpportunityConstants.SUB_STAGENAME_QUOTE_SHARED;
                                
                            }
                            when 'Price Negotiation'{
                                
                                
                                // mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).StageName = OpportunityConstants.STAGENAME_Quote_MANAGEMENT ;
                                // mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).Substages__c = OpportunityConstants.SUB_STAGENAME_NEGOTIATION_MEETING_FIXED;
                                
                            }
                            when 'Quote Accept'{
                                
                                mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).StageName = OpportunityConstants.STAGENAME_NEGOTIATION_MEETING ;
                                mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).Substages__c = OpportunityConstants.SUB_STAGENAME_NEGOTIATION_CLOSED;	
                                
                            }
                        }
                    }else if(mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).RecordType.Name.EqualsIgnoreCase(OpportunityConstants.RECORDTYPENAME_RENEWAL)){
                        switch on quoteInstance.Status{
                            When 'Draft'{
                                
                                mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).StageName = OpportunityConstants.STAGENAME_QUOTING ;
                                
                            }
                            when 'Quote Accept'{
                                
                                mapOfIdWithOpportunities.get(quoteInstance.OpportunityId).StageName = OpportunityConstants.STAGENAME_ON_TRACK ;
                                
                            }
                        }
                    }
                }
            }
        }
        
        if(!mapOfIdWithOpportunities.isEmpty()){
            update mapOfIdWithOpportunities.values();
            System.debug('mapOfIdWithOpportunities.values()'+mapOfIdWithOpportunities.keySet());
        }
    }
    
    /* Method - statusError() commented by Raksha : we dont have to generate Quote Doc in Quote
public static void statusError(Map<Id,Quote> newMapOfQuotes){
for(quote tempQuote : [ select Id,(select Id from QuoteDocuments ) from Quote where Id IN: newMapOfQuotes.keySet() ]){
if(!(tempQuote.QuoteDocuments.size() > 0)){
newMapOfQuotes.get(tempQuote.Id).addError(System.Label.Quote_Document_Error);
}
}
}*/
    
    Public static void primaryCheck(Map<Id,Id> OpportunityIdWithQuoteId){
        List<Opportunity> OpportunityWithQuote = new List<Opportunity>([select Id,(select Id,Is_Primary_Quote__c from Quotes where Is_Primary_Quote__c = true ) from Opportunity where Id IN: OpportunityIdWithQuoteId.keySet()]);
        List<Quote> toBeUnchecked = new List<Quote>();
        for(Opportunity tempOpp : OpportunityWithQuote){
            if(tempOpp.Quotes.size()>0){
                for(Quote tempQuote : tempOpp.Quotes){
                    if( OpportunityIdWithQuoteId.get(tempOpp.Id) != tempQuote.Id ){
                        toBeUnchecked.add(new Quote(Id = tempQuote.Id, Is_Primary_Quote__c = false));
                    }
                }
            }
        }
        if(toBeUnchecked.size()>0){
            StopRecursion.stopQuoteRecursion = true;
            try{
                Update toBeUnchecked;
            }catch(Exception e){
                System.debug('Error in primary quote check : '+e.getMessage());
            }
        }
    }
    
    
    public static void setApprovers(list<Quote> listOfQuotes){
        
        List<User>  listOfUsers = new List<User>();
        listOfUsers = [select Id,ManagerId from user where IsActive = True];
        Map<Id,Id> mapOfUsersWithManager = new Map<Id,Id>();
        for(user tempUser : listOfUsers){
            mapOfUsersWithManager.put(tempUser.Id, tempUser.ManagerId);
        }
        for(Quote tempQuote : listOfQuotes){
            System.debug('Disount '+tempQuote.Discount );
            
            /**  If( mapOfUsersWithManager.containsKey(tempQuote.OwnerId) ){
tempQuote.Level_1_Approver__c = mapOfUsersWithManager.get(tempQuote.OwnerId);
}
If( mapOfUsersWithManager.containsKey(tempQuote.Level_1_Approver__c) ){
tempQuote.Level_2_Approver__c = mapOfUsersWithManager.get(tempQuote.Level_1_Approver__c);
}
If(mapOfUsersWithManager.containsKey(tempQuote.Level_2_Approver__c) ){
tempQuote.Level_3_Approver__c = mapOfUsersWithManager.get(tempQuote.Level_2_Approver__c);
}
If(mapOfUsersWithManager.containsKey(tempQuote.Level_3_Approver__c) ){
tempQuote.Level_4_Approver__c = mapOfUsersWithManager.get(tempQuote.Level_3_Approver__c);
}**/
            
            
        }
    }
    
    /**public static void integrationPriceGuardrail(list<Quote> quoteList){

set<Id> 					quoteIdSet 				= new set<Id>();
map<Id,list<QuoteLineItem>> quoteToQuoteLineItemMap = new map<Id, list<QuoteLineItem>>();
map<Id,list<String>> 		quoteToProductsMap 		= new map<Id, list<String>>();

for(Quote thisRec : quoteList){
quoteIdSet.add(thisRec.Id);
}

list<Quote> quoteListWithQuoteLineItem = [ SELECT Id, (SELECT Id,Product2.Name, Sale_Price__c FROM QuoteLineItems) FROM Quote WHERE Id IN :quoteIdSet ];
for(Quote thisRec : quoteListWithQuoteLineItem){
quoteToQuoteLineItemMap.put(thisRec.Id, thisRec.QuoteLineItems);
}

for(Quote thisRec : quoteListWithQuoteLineItem){
if(quoteToProductsMap.containsKey(thisRec.Id)){
List<String> products = quoteToProductsMap.get(thisRec.Id);
for(QuoteLineItem qli : thisRec.QuoteLineItems){
products.add(qli.Product2.Name);
}
}
else
{
List<String> products = new List<String>();
for(QuoteLineItem qli : thisRec.QuoteLineItems){
products.add(qli.Product2.Name);
}
quoteToProductsMap.put(thisRec.Id,products);
}
}

Map<String, list<Integration_price_guardrail__mdt>> integrationPriceGuardrail = 
new Map<String, list<Integration_price_guardrail__mdt>>();

for(
Integration_price_guardrail__mdt thisRec : [ SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix,
Label, QualifiedApiName, ARR_Price_Threshold__c,
Integration_SKU__c, Linked_ARR__c FROM Integration_price_guardrail__mdt ]
){
if(integrationPriceGuardrail.containsKey(thisRec.Integration_SKU__c)){

integrationPriceGuardrail.get(thisRec.Integration_SKU__c).add(thisRec);
} else{
integrationPriceGuardrail.put(thisRec.Integration_SKU__c, new List<Integration_price_guardrail__mdt>{thisRec});
}
}

for(ID thisquoteId : quoteToQuoteLineItemMap.keySet()){
for(QuoteLineItem thisQli : quoteToQuoteLineItemMap.get(thisquoteId)){
if(integrationPriceGuardrail.ContainsKey(thisQli.Product2.Name)){
for(Integration_price_guardrail__mdt thisRec : integrationPriceGuardrail.get(thisQli.Product2.Name)){

}
}
}
}

for(
Integration_price_guardrail__mdt thisRec : [ SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix,
Label, QualifiedApiName, ARR_Price_Threshold__c,
Integration_SKU__c, Linked_ARR__c FROM Integration_price_guardrail__mdt ]
){
for(Id thisquoteId : quoteToQuoteLineItemMap.keySet()){

}
}
for(quoteLineItem thisRec : [SELECT Id, Product2.Name, QuoteId FROM QuoteLineItem WHERE QuoteId IN :quoteIdSet]){

}
}**/
    
    /** bhaveshjindal : Integration Price Guardrail : START **/
    
    //needs to be optimized
    
    public static void integrationPriceGuardrail(Map<Id,Quote> quoteTriggerNewMap,Map<Id,Quote> quoteTriggerOldMap){
        
        Map<String, Set<String>>    integrationSKU_LinkedARR    = new Map<String, Set<String>>();
        Map<String, Set<String>>    integrationSKU_DependantARR = new Map<String, Set<String>>();
        Map<String, Double>         integrationSKU_ARRPrice     = new Map<String, Double>();
        Map<String, Double>         linkedARR_ARRPrice     		= new Map<String, Double>();
        Map<Id, Set<QuoteLineItem>> quoteAndQuoteLineItemMap    = new Map<Id, Set<QuoteLineItem>>();
        Map<String, date> quoteAndQuoteLineItemMINDateMap    = new Map<String, date>();
        for(
            Integration_price_guardrail__mdt thisRec : [ SELECT Id, MasterLabel, DeveloperName, Integration_SKU__c, Linked_ARR__c, ARR_Price_Threshold__c, Dependant_ARR__c	
                                                        FROM Integration_price_guardrail__mdt]
        ){
            //for linkedArrMap
            if( integrationSKU_LinkedARR.containsKey(thisRec.Integration_SKU__c) ){
                integrationSKU_LinkedARR.get(thisRec.Integration_SKU__c).add(thisRec.Linked_ARR__c);
            } else{
                integrationSKU_LinkedARR.put(thisRec.Integration_SKU__c, new Set<String>{thisRec.Linked_ARR__c});
            }
            
            //for dependantArrMap
            if( integrationSKU_DependantARR.containsKey(thisRec.Integration_SKU__c) ){
                if(thisRec.Dependant_ARR__c != NULL){
                    integrationSKU_DependantARR.get(thisRec.Integration_SKU__c).add(thisRec.Dependant_ARR__c);
                }
            } else{
                if(thisRec.Dependant_ARR__c != NULL){
                    integrationSKU_DependantARR.put(thisRec.Integration_SKU__c, new Set<String>{thisRec.Dependant_ARR__c});
                }
            }
            
            integrationSKU_ARRPrice.put(thisRec.Integration_SKU__c, thisRec.ARR_Price_Threshold__c);
            linkedARR_ARRPrice.put(thisRec.Linked_ARR__c, thisRec.ARR_Price_Threshold__c);
        }
        
        
        for (AggregateResult agrIns: [SELECT quoteId QID,product2.name PNAME,MIN(period_start_date__c) MINPSD  FROM QuoteLineItem WHERE
                                      QuoteId IN :Trigger.NewMap.keySet() GROUP BY quoteId,product2.name])
        {
            quoteAndQuoteLineItemMINDateMap.put(String.ValueOf(agrIns.get('QID'))+String.ValueOf(agrIns.get('PNAME')), Date.ValueOf(agrIns.get('MINPSD')));
            
        }
        for(
            QuoteLineItem thisRec : [ SELECT Id, QuoteId, Product2Id, Product2.Name, sale_price__c
                                     FROM QuoteLineItem WHERE
                                     QuoteId IN :Trigger.NewMap.keySet()
                                     ORDER BY QuoteId ]
        ){
            /** Start */
            if( quoteAndQuoteLineItemMap.containsKey(thisRec.QuoteId) ){
                quoteAndQuoteLineItemMap.get(thisRec.QuoteId).add(thisRec);
            } else{
                quoteAndQuoteLineItemMap.put(thisRec.QuoteId, new Set<QuoteLineItem>{thisRec});
            }
            /** End */
        }
        for(Id thisRecId : quoteTriggerNewMap.keySet()){
            Quote QuoteNewInstance = (Quote)quoteTriggerNewMap.get(thisRecId);
            Quote QuoteOldInstance = (Quote)quoteTriggerOldMap.get(thisRecId);
            Boolean containsDependantARR = FALSE;
            Boolean isArrDependant = FALSE;
            String dependantArrError = '';
            
            if( quoteAndQuoteLineItemMap.containsKey(thisRecId) ){
                List<String>  integrationSKU = new List<String>();
                String  linkedARR;
                Integer  linkedARRPrice;
                /** Checking Integration SKU */
                for( QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisRecId) ){
                    if(integrationSKU_LinkedARR.containsKey(thisQLI.Product2.Name)){
                        integrationSKU.add(thisQLI.Product2.Name);
                    }
                }
                system.debug('integrationSKU :: '+integrationSKU);
                system.debug('integrationSKU_DependantARR :: '+integrationSKU_DependantARR);
                system.debug('integrationSKU_LinkedARR :: '+integrationSKU_LinkedARR);
                
                /** Checking Dependant Arr */
                for( QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisRecId) ){
                    if(integrationSKU.size() > 0){
                        for(String thisSKU : integrationSKU){
                            system.debug('thisSKU :: '+thisSKU +' integrationSKU_DependantARR.get(thisSKU) :: '+integrationSKU_DependantARR.get(thisSKU));
                            system.debug('thisQLI.Product2.Name :: '+thisQLI.Product2.Name + 'thisSKU :: '+thisSKU);
                            //system.debug('integrationSKU_DependantARR.get(thisSKU).contains(thisQLI.Product2.Name :: '+integrationSKU_DependantARR.get(thisSKU).contains(thisQLI.Product2.Name));
                            if(integrationSKU_DependantARR.get(thisSKU) != NULL){
                                isArrDependant = TRUE;
                                if(integrationSKU_DependantARR.get(thisSKU).contains(thisQLI.Product2.Name)){
                                    //do nothing
                                    containsDependantARR = TRUE;
                                    system.debug('curProductMin'+ quoteAndQuoteLineItemMINDateMap.get(thisQLI.quoteId+thisQLI.Product2.Name) );
                                    system.debug('intProductMin'+ quoteAndQuoteLineItemMINDateMap.get(thisQLI.quoteId+thisSKU) );
                                    
                                    If(quoteAndQuoteLineItemMINDateMap.get(thisQLI.quoteId+thisQLI.Product2.Name) > quoteAndQuoteLineItemMINDateMap.get(thisQLI.quoteId+thisSKU)){
                                        
                                    }
                                    system.debug('containsDependantARR :: '+containsDependantARR);
                                }else{
                                    dependantArrError = 'You can Only select '+thisSKU+' with '+integrationSKU_DependantARR.get(thisSKU)+' ARRs.';
                                }
                            }
                        }
                        
                    }
                }
                if(integrationSKU.size() > 0 && containsDependantARR == False && isArrDependant == True){
                    //QuoteNewInstance.addError(dependantArrError);
                }
                
                /** Checking Linked ARR 
for( QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisRecId) ){
if(integrationSKU.size() > 0){
for(String thisSKU : integrationSKU){
if(integrationSKU_LinkedARR.get(thisSKU).contains(thisQLI.Product2.Name)){
linkedARR = thisQLI.Product2.Name;
linkedARRPrice = (Integer)thisQLI.sale_price__c;

// Check ARR Pricing 
system.debug('linkedARR :: '+linkedARR);
system.debug('linkedARRPrice :: '+linkedARRPrice);
system.debug('linkedARR_ARRPrice.get(linkedARR) : '+linkedARR_ARRPrice.get(linkedARR));
if(linkedARRPrice < linkedARR_ARRPrice.get(linkedARR) && (linkedARRPrice != 0.00)){
system.debug('IF Entered : linkedARRPrice < linkedARR_ARRPrice.get(linkedARR)');
if(QuoteNewInstance.IsSyncing == QuoteOldInstance.IsSyncing && (QuoteNewInstance.status != 'Quote Accept')){
system.debug('IF Entered : QuoteNewInstance.IsSyncing == QuoteOldInstance.IsSyncing && (QuoteNewInstance.status != Quote Accept)');
if(QuoteNewInstance.Type_of_Integration__c != 'API- Only by Customer' && QuoteNewInstance.Type_of_Integration__c != 'FTP/SFTP - Only by customer'){
system.debug('IF Entered : QuoteNewInstance.Type_of_Integration__c != API- Only by Customer && QuoteNewInstance.Type_of_Integration__c != FTP/SFTP - Only by customer');
QuoteNewInstance.addError('Type Of integration can only be "API - Only by Customer" or "FTP/SFTP - Only by customer" for this Quote since the ARR product : '+linkedARR +' associated with the integration SKU : '+thisSKU+' is less than ' +linkedARR_ARRPrice.get(linkedARR));
}
}
}
}
}
}
}**/
                system.debug('linkedARR :: '+linkedARR);
                system.debug('linkedARRPrice :: '+linkedARRPrice);
            }
        }
    }
    /** bhaveshjindal : Integration Price Guardrail : END **/
    
    public static void integrationPriceGuardrailV2(Map<Id,Quote> quoteTriggerNewMap,Map<Id,Quote> quoteTriggerOldMap){
        
        Map<String, Set<String>>    integrationSKU_LinkedARR    = new Map<String, Set<String>>();
        Map<String, Set<String>>    integrationSKU_DependantARR = new Map<String, Set<String>>();
        Map<String, Double>         integrationSKU_ARRPrice     = new Map<String, Double>();
        Map<String, Double>         linkedARR_ARRPrice     		= new Map<String, Double>();
        Map<Id, Set<QuoteLineItem>> quoteAndQuoteLineItemMap    = new Map<Id, Set<QuoteLineItem>>();
        Map<String, String>    		productCodeProductNameMap   = new Map<String, String>();
        Set<String>					dependantArrSet				= new Set<String>();
        Map<String, date> quoteAndQuoteLineItemMINDateMap    = new Map<String, date>();
        for (AggregateResult agrIns: [SELECT quoteId QID,product2.name PNAME,MIN(period_start_date__c) MINPSD  FROM QuoteLineItem WHERE
                                      QuoteId IN :Trigger.NewMap.keySet() GROUP BY quoteId,product2.name])
        {
            quoteAndQuoteLineItemMINDateMap.put(String.ValueOf(agrIns.get('QID'))+String.ValueOf(agrIns.get('PNAME')), Date.ValueOf(agrIns.get('MINPSD')));
            
        }
        
        for(
            Integration_price_guardrail__mdt thisRec : [ SELECT Id, MasterLabel, DeveloperName, Integration_SKU__c, Linked_ARR__c, ARR_Price_Threshold__c, Dependant_ARR__c	
                                                        FROM Integration_price_guardrail__mdt]
        ){
            dependantArrSet.add(thisRec.Dependant_ARR__c);
            
            //for linkedArrMap
            if( integrationSKU_LinkedARR.containsKey(thisRec.Integration_SKU__c) ){
                integrationSKU_LinkedARR.get(thisRec.Integration_SKU__c).add(thisRec.Linked_ARR__c);
            } else{
                integrationSKU_LinkedARR.put(thisRec.Integration_SKU__c, new Set<String>{thisRec.Linked_ARR__c});
            }
            
            //for dependantArrMap
            if( integrationSKU_DependantARR.containsKey(thisRec.Integration_SKU__c) ){
                if(thisRec.Dependant_ARR__c != NULL){
                    integrationSKU_DependantARR.get(thisRec.Integration_SKU__c).add(thisRec.Dependant_ARR__c);
                }
            } else{
                if(thisRec.Dependant_ARR__c != NULL){
                    integrationSKU_DependantARR.put(thisRec.Integration_SKU__c, new Set<String>{thisRec.Dependant_ARR__c});
                }
            }
            
            integrationSKU_ARRPrice.put(thisRec.Integration_SKU__c, thisRec.ARR_Price_Threshold__c);
            linkedARR_ARRPrice.put(thisRec.Linked_ARR__c, thisRec.ARR_Price_Threshold__c);
        }
        
        
        
        for(
            QuoteLineItem thisRec : [ SELECT Id, QuoteId, Product2Id, Product2.Name, sale_price__c, Product2.ProductCode
                                     FROM QuoteLineItem WHERE
                                     QuoteId IN :Trigger.NewMap.keySet()
                                     OR Product2.ProductCode IN :dependantArrSet
                                     ORDER BY QuoteId ]
        ){
            /** Start */
            if( quoteAndQuoteLineItemMap.containsKey(thisRec.QuoteId) ){
                quoteAndQuoteLineItemMap.get(thisRec.QuoteId).add(thisRec);
            } else{
                quoteAndQuoteLineItemMap.put(thisRec.QuoteId, new Set<QuoteLineItem>{thisRec});
            }
            /** End */
            
            //Creating Product code => Product Name Map.
            productCodeProductNameMap.put(thisRec.Product2.ProductCode,thisRec.Product2.Name);
        }
        for(Id thisRecId : quoteTriggerNewMap.keySet()){
            Quote QuoteNewInstance = (Quote)quoteTriggerNewMap.get(thisRecId);
            Quote QuoteOldInstance = (Quote)quoteTriggerOldMap.get(thisRecId);
            Boolean containsDependantARR = FALSE;
            Boolean isArrDependant = FALSE;
            String dependantArrError = '';
            
            if( quoteAndQuoteLineItemMap.containsKey(thisRecId) ){
                Map<String,String> integrationSKU = new Map<String,String>();
                String  linkedARR;
                Integer  linkedARRPrice;
                /** Checking Integration SKU */
                for( QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisRecId) ){
                    if(integrationSKU_LinkedARR.containsKey(thisQLI.Product2.Name)){
                        integrationSKU.put(thisQLI.Product2.ProductCode,thisQLI.Product2.Name);
                    }
                }
                system.debug('integrationSKU :: '+integrationSKU);
                system.debug('integrationSKU_DependantARR :: '+integrationSKU_DependantARR);
                system.debug('integrationSKU_LinkedARR :: '+integrationSKU_LinkedARR);
                
                /** Checking Dependant Arr */
                for( QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisRecId) ){
                    if(integrationSKU.size() > 0){
                        for(String thisSKU : integrationSKU.keySet()){
                            system.debug('thisSKU :: '+thisSKU +' integrationSKU_DependantARR.get(thisSKU) :: '+integrationSKU_DependantARR.get(thisSKU));
                            system.debug('thisQLI.Product2.Name :: '+thisQLI.Product2.Name + 'thisSKU :: '+thisSKU);
                            //system.debug('integrationSKU_DependantARR.get(thisSKU).contains(thisQLI.Product2.Name :: '+integrationSKU_DependantARR.get(thisSKU).contains(thisQLI.Product2.Name));
                            if(integrationSKU_DependantARR.get(thisSKU) != NULL){
                                isArrDependant = TRUE;
                                if(integrationSKU_DependantARR.get(thisSKU).contains(thisQLI.Product2.ProductCode)){
                                    //do nothing
                                    containsDependantARR = TRUE;
                                    system.debug('curProductMin'+ quoteAndQuoteLineItemMINDateMap.get(thisQLI.quoteId+thisQLI.Product2.Name) );
                                    system.debug('intProductMin'+ quoteAndQuoteLineItemMINDateMap.get(thisQLI.quoteId+integrationSKU.get(thisSKU)) );
                                    
                                    If(quoteAndQuoteLineItemMINDateMap.get(thisQLI.quoteId+thisQLI.Product2.Name) > quoteAndQuoteLineItemMINDateMap.get(thisQLI.quoteId+integrationSKU.get(thisSKU))){
                                        dependantArrError = 'Period start date of '+thisQLI.Product2.Name+' should not be  greater than '+integrationSKU.get(thisSKU); 
                                        containsDependantARR = FALSE;
                                    }
                                    system.debug('containsDependantARR :: '+containsDependantARR);
                                }else{
                                    String arrs = '';
                                    for(String pc : integrationSKU_DependantARR.get(thisSKU)){
                                        arrs += productCodeProductNameMap.get(pc)+', ';
                                    }
                                    if(String.ISBLANK(dependantArrError))
                                        dependantArrError = 'You can Only select '+integrationSKU.get(thisSKU)+' with '+arrs+' ARRs.';
                                }
                            }
                        }
                        
                    }
                }
                if(integrationSKU.size() > 0 && containsDependantARR == False && isArrDependant == True && !System.label.QuoteCustomValidationsBypass.Contains(userinfo.getProfileId())){
                    //QuoteNewInstance.addError(dependantArrError);
                }
                
                /** Checking Linked ARR 
for( QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisRecId) ){
if(integrationSKU.size() > 0){
for(String thisSKU : integrationSKU){
if(integrationSKU_LinkedARR.get(thisSKU).contains(thisQLI.Product2.Name)){
linkedARR = thisQLI.Product2.Name;
linkedARRPrice = (Integer)thisQLI.sale_price__c;

// Check ARR Pricing 
system.debug('linkedARR :: '+linkedARR);
system.debug('linkedARRPrice :: '+linkedARRPrice);
system.debug('linkedARR_ARRPrice.get(linkedARR) : '+linkedARR_ARRPrice.get(linkedARR));
if(linkedARRPrice < linkedARR_ARRPrice.get(linkedARR) && (linkedARRPrice != 0.00)){
system.debug('IF Entered : linkedARRPrice < linkedARR_ARRPrice.get(linkedARR)');
if(QuoteNewInstance.IsSyncing == QuoteOldInstance.IsSyncing && (QuoteNewInstance.status != 'Quote Accept')){
system.debug('IF Entered : QuoteNewInstance.IsSyncing == QuoteOldInstance.IsSyncing && (QuoteNewInstance.status != Quote Accept)');
if(QuoteNewInstance.Type_of_Integration__c != 'API- Only by Customer' && QuoteNewInstance.Type_of_Integration__c != 'FTP/SFTP - Only by customer'){
system.debug('IF Entered : QuoteNewInstance.Type_of_Integration__c != API- Only by Customer && QuoteNewInstance.Type_of_Integration__c != FTP/SFTP - Only by customer');
QuoteNewInstance.addError('Type Of integration can only be "API - Only by Customer" or "FTP/SFTP - Only by customer" for this Quote since the ARR product : '+linkedARR +' associated with the integration SKU : '+thisSKU+' is less than ' +linkedARR_ARRPrice.get(linkedARR));
}
}
}
}
}
}
}**/
                system.debug('linkedARR :: '+linkedARR);
                system.debug('linkedARRPrice :: '+linkedARRPrice);
            }
        }
    }
    /** bhaveshjindal : Integration Price Guardrail : END **/
    
    /** START : bhaveshjindal : Enable/Disable Grace Period **/
    public static void addGracePeriod(Map<Id,Quote> quoteTriggerNewMap){
        
        Map<Id, Set<QuoteLineItem>> quoteAndQuoteLineItemMap    	= new Map<Id, Set<QuoteLineItem>>();
        Set<String>					dependantArrSet					= new Set<String>();
        Map<String, Integer>        dependantArr_GracePeriodMap   	= new Map<String, Integer>();
        List<String>				QLI_KeyList						= new List<String>();
        Set<Id>						QuotesContainingIntegrationARR  = new Set<Id>();
        
        System.debug('<<----:: START : addGracePeriod : START ::---->>');
        for(
            Integration_price_guardrail__mdt thisRec : [ SELECT Id, MasterLabel, DeveloperName, Integration_SKU__c, 
                                                        Linked_ARR__c, ARR_Price_Threshold__c, Dependant_ARR__c, 
                                                        Grace_Period__c
                                                        FROM Integration_price_guardrail__mdt ]
        ){
            
            dependantArrSet.add(thisRec.Dependant_ARR__c);
            
            //dependantArr_GracePeriod Map
            if(thisRec.Dependant_ARR__c != NULL){
                dependantArr_GracePeriodMap.put(thisRec.Dependant_ARR__c, (Integer)thisRec.Grace_Period__c);
            }
        }
        System.debug('dependantArr_GracePeriodMap :: '+dependantArr_GracePeriodMap);
        
        //querying MAX date QLI for each ARR for multiyear deal
        for( AggregateResult ar : [ SELECT QuoteID, Product2.ProductCode PCode, MAX(Period_Start_Date__c) MaxDate
                                   FROM QuoteLineItem WHERE QuoteId IN :quoteTriggerNewMap.keySet() 
                                   AND Product2.ProductCode IN :dependantArrSet 
                                   GROUP BY QuoteId, Product2.ProductCode ]
           ){
               QLI_KeyList.add(String.valueOf(ar.get('QuoteID'))+String.valueOf(ar.get('PCode'))+String.valueOf((Date)ar.get('MaxDate')));
           }
        System.debug('QLI_KeyWithMaxStartDate :: '+QLI_KeyList);
        
        //to check if quote contains integration product
        for(QuoteLineItem thisQLI : [SELECT QuoteId FROM QuoteLineItem 
                                     WHERE QuoteId IN :quoteTriggerNewMap.keySet()
                                     AND Product2.Product_category__c = 'Integration' 
                                     ORDER BY QuoteId])
        {
            QuotesContainingIntegrationARR.add(thisQLI.QuoteId);
        }
        
        for(
            QuoteLineItem thisRec : [ SELECT Id, QuoteId, period_start_date__c, period_end_date__c, Product2.ProductCode
                                     FROM QuoteLineItem WHERE
                                     QuoteId IN :quoteTriggerNewMap.keySet()
                                     OR Product2.ProductCode IN :dependantArrSet
                                     ORDER BY QuoteId ]
        ){
            /** Start */
            if( quoteAndQuoteLineItemMap.containsKey(thisRec.QuoteId) ){
                quoteAndQuoteLineItemMap.get(thisRec.QuoteId).add(thisRec);
            } else{
                quoteAndQuoteLineItemMap.put(thisRec.QuoteId, new Set<QuoteLineItem>{thisRec});
            }
            /** End */
        }
        System.debug('quoteAndQuoteLineItemMap :: '+quoteAndQuoteLineItemMap);
        
        List<QuoteLineItem> qliListToUpdate = new List<QuoteLineItem>();
        
        for(Id thisRecId : quoteTriggerNewMap.keySet()){
            Quote QuoteNewInstance = (Quote)quoteTriggerNewMap.get(thisRecId);
            
            //if enable grace period is marked true : add n days
            if(QuoteNewInstance.Enable_grace_period__c == TRUE){
                if(QuotesContainingIntegrationARR.contains(thisRecId)){
                    for(QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisRecId)){
                        System.debug('QLI_QuoteId+ProductCode+StartDate_Key :: '+String.valueOf(thisQLI.QuoteID)+String.valueOf(thisQLI.Product2.ProductCode)+String.valueOf(thisQLI.Period_Start_date__c));
                        if(QLI_KeyList.Contains(String.valueOf(thisQLI.QuoteID)+String.valueOf(thisQLI.Product2.ProductCode)+String.valueOf(thisQLI.Period_Start_date__c))){
                            System.debug('QLI_KEY_FOUND');
                            Integer days = dependantArr_GracePeriodMap.get(thisQLI.Product2.ProductCode);
                            thisQLI.Period_End_date__c = thisQLI.Period_End_date__c.addDays(days);
                            qliListToUpdate.add(thisQLI);
                        }
                    }
                }else{
                    QuoteNewInstance.addError('Grace period can only be enabled if integration product is added.');
                }
            }
            //if enable grace period is marked false : subtract n days
            else if(QuoteNewInstance.Enable_grace_period__c == FALSE){
                for(QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisRecId)){
                    System.debug('QLI_QuoteId+ProductCode+StartDate_Key :: '+String.valueOf(thisQLI.QuoteID)+String.valueOf(thisQLI.Product2.ProductCode)+String.valueOf(thisQLI.Period_Start_date__c));
                    if(QLI_KeyList.Contains(String.valueOf(thisQLI.QuoteID)+String.valueOf(thisQLI.Product2.ProductCode)+String.valueOf(thisQLI.Period_Start_date__c))){
                        System.debug('QLI_KEY_FOUND');
                        Integer days = dependantArr_GracePeriodMap.get(thisQLI.Product2.ProductCode);
                        thisQLI.Period_End_date__c = thisQLI.Period_End_date__c.addDays(-days);
                        qliListToUpdate.add(thisQLI);
                    }
                }
            }
            
            
        }
        System.debug('qliListToUpdate :: '+qliListToUpdate);
        if(qliListToUpdate.size()>0){
            update qliListToUpdate;
        }
        System.debug('<<---- :: END : addGracePeriod : END ::---->>');
    }
    /** END : bhaveshjindal : Enable/Disable Grace Period **/
    
    /** START : bhaveshjindal : update Contains_GST_Advantage_Products__c & Contains_E_invoice_Products__c on quote **/
    public static void updateFieldsForPricingRuleForEC( Map<Id,Quote> mapOfNewQuote){
        
        Map<Id, Set<QuoteLineItem>> quoteAndQuoteLineItemMap    	= new Map<Id, Set<QuoteLineItem>>();
        set<Id> gstQLIs = new Set<Id>();
        set<Id> einvoiceQLIs = new set<Id>();
        set<Id> clearSupplyChainQLIs = new Set<Id>();
        
        
        for(
            QuoteLineItem thisRec : [ SELECT Id, QuoteId, period_start_date__c, period_end_date__c, Product2.ProductCode, 
                                     Quote.Opportunity.Owner.User_Category__c 
                                     FROM QuoteLineItem WHERE
                                     QuoteId IN :mapOfNewQuote.keySet()
                                     ORDER BY QuoteId ]
        ){
            /** Start */
            if( quoteAndQuoteLineItemMap.containsKey(thisRec.QuoteId) ){
                quoteAndQuoteLineItemMap.get(thisRec.QuoteId).add(thisRec);
            } else{
                quoteAndQuoteLineItemMap.put(thisRec.QuoteId, new Set<QuoteLineItem>{thisRec});
            }
            /** End */
        }
        System.debug('quoteAndQuoteLineItemMap :: '+quoteAndQuoteLineItemMap);
        
        for(QuoteLineItem thisQli : [SELECT Id, QuoteId FROM QuoteLineItem WHERE Product2.ProductCode IN ('GST-ADVANTAGE','GST-ADVANTAGE_CSM') AND QuoteId IN :mapOfNewQuote.keySet() ]){
            gstQLIs.add(thisQli.Id);
        }
        System.debug('gstQLIs :: '+gstQLIs);
        for(QuoteLineItem thisQli : [SELECT Id, QuoteId FROM QuoteLineItem WHERE Product2.ProductCode = 'EINV-EWB-LIC_NKAM' AND QuoteId IN :mapOfNewQuote.keySet() ]){
            einvoiceQLIs.add(thisQli.Id);
        }
        System.debug('einvoiceQLIs :: '+einvoiceQLIs);
        for(QuoteLineItem thisQli : [SELECT Id, QuoteId FROM QuoteLineItem WHERE Product2.ProductCode IN ('Clear_SC-Managed_Services','CLRSC_INTEGRATION','CLR_SUPCHN') AND QuoteId IN :mapOfNewQuote.keySet() ]){
            clearSupplyChainQLIs.add(thisQli.Id);
        }
        System.debug('clearSupplyChainQLIs :: '+clearSupplyChainQLIs);
        
        
        for(Id thisQuoteId : mapOfNewQuote.keySet()){
            Quote QuoteInstance = mapOfNewQuote.get(thisQuoteId);
            
            Boolean containsGstProd = FALSE;
            Boolean containsEinvoiceProd = FALSE;
            Boolean containsClearSupplyChainProd = FALSE;
            
            if(quoteAndQuoteLineItemMap.get(thisQuoteId) != NULL){
                for(QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisQuoteId)){
                    if(gstQLIs.contains(thisQLI.Id)){
                        QuoteInstance.Contains_GST_Advantage_Products__c  = TRUE;
                        containsGstProd = TRUE;
                    }else if(containsGstProd == FALSE){
                        QuoteInstance.Contains_GST_Advantage_Products__c  = FALSE;
                    }
                    
                    if(einvoiceQLIs.contains(thisQLI.Id)){
                        QuoteInstance.Contains_E_invoice_Products__c  = TRUE;
                        containsEinvoiceProd = TRUE;
                    }else if(containsEinvoiceProd == FALSE){
                        QuoteInstance.Contains_E_invoice_Products__c  = FALSE;
                    }
                    if(clearSupplyChainQLIs.contains(thisQLI.Id)){
                        QuoteInstance.Contains_Clear_Supply_Chain_SKU__c  = TRUE;
                        containsClearSupplyChainProd = TRUE;
                    }else if(containsClearSupplyChainProd == FALSE){
                        QuoteInstance.Contains_Clear_Supply_Chain_SKU__c  = FALSE;
                    }
                }
            }
        }
        
    }
    /** END : bhaveshjindal : update Contains_GST_Advantage_Products__c & Contains_E_invoice_Products__c on quote **/
    
    /** START : bhaveshjindal : making type of integration required for integration SKU on quoteLineItem **/
    public static void validateTypeOfIntegration(Map<Id,Quote> mapOfNewQuote){
        
        Map<Id, Set<QuoteLineItem>> quoteAndQuoteLineItemMap    = new Map<Id, Set<QuoteLineItem>>();
        set<Id> integrationQLIs 								= new Set<Id>();
        
        for(
            QuoteLineItem thisRec : [ SELECT Id, QuoteId, period_start_date__c, period_end_date__c, Product2.ProductCode, 
                                     Product2.Name, Quote.Opportunity.Owner.User_Category__c, Type_of_Integration__c
                                     FROM QuoteLineItem WHERE
                                     QuoteId IN :mapOfNewQuote.keySet()
                                     ORDER BY QuoteId ]
        ){
            /** Start */
            if( quoteAndQuoteLineItemMap.containsKey(thisRec.QuoteId) ){
                quoteAndQuoteLineItemMap.get(thisRec.QuoteId).add(thisRec);
            } else{
                quoteAndQuoteLineItemMap.put(thisRec.QuoteId, new Set<QuoteLineItem>{thisRec});
            }
            /** End */
        }
        System.debug('quoteAndQuoteLineItemMap :: '+quoteAndQuoteLineItemMap);
        
        for(QuoteLineItem thisQli : [SELECT Id, QuoteId FROM QuoteLineItem WHERE Product2.Product_category__c = 'Integration' AND QuoteId IN :mapOfNewQuote.keySet() ]){
            integrationQLIs.add(thisQli.Id);
        }
        System.debug('integrationQLIs :: '+integrationQLIs);
        
        for(Id thisQuoteId : mapOfNewQuote.keySet()){
            Quote QuoteInstance = mapOfNewQuote.get(thisQuoteId);
            String arrs = '';
            Boolean showError = FALSE;
            if(quoteAndQuoteLineItemMap.get(thisQuoteId) != NULL){
                for(QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisQuoteId)){
                    if(integrationQLIs.contains(thisQLI.Id) && thisQLI.Type_of_Integration__c == NULL){
                        showError = TRUE;
                        arrs += thisQLI.product2.Name+', ';
                    }
                }
                if(showError){
                    QuoteInstance.addError('Please specify Type of integration on Quote Line Item for '+arrs);
                }
            }
        }
    }
    /** END : bhaveshjindal : making type of integration required for integration SKU on quoteLineItem **/
    
    /** START : bhaveshjindal : Update contains MS Product field **/
    public static void updateContainsMSProductField(Map<Id,Quote> mapOfNewQuote){
        
        Map<Id, Set<QuoteLineItem>> quoteAndQuoteLineItemMap    = new Map<Id, Set<QuoteLineItem>>();
        set<Id> msQLIs 											= new Set<Id>();
        
        for(
            QuoteLineItem thisRec : [ SELECT Id, QuoteId
                                     FROM QuoteLineItem WHERE
                                     QuoteId IN :mapOfNewQuote.keySet()
                                     ORDER BY QuoteId ]
        ){
            /** Start */
            if( quoteAndQuoteLineItemMap.containsKey(thisRec.QuoteId) ){
                quoteAndQuoteLineItemMap.get(thisRec.QuoteId).add(thisRec);
            } else{
                quoteAndQuoteLineItemMap.put(thisRec.QuoteId, new Set<QuoteLineItem>{thisRec});
            }
            /** End */
        }
        System.debug('quoteAndQuoteLineItemMap :: '+quoteAndQuoteLineItemMap);
        
        for(QuoteLineItem thisQli : [SELECT Id, QuoteId FROM QuoteLineItem WHERE Product2.Product_category__c = 'MS' AND QuoteId IN :mapOfNewQuote.keySet() ]){
            msQLIs.add(thisQli.Id);
        }
        System.debug('msQLIs :: '+msQLIs);
        
        for(Id thisQuoteId : mapOfNewQuote.keySet()){
            Quote QuoteInstance = mapOfNewQuote.get(thisQuoteId);
            
            Boolean containsMsProduct = False;
            if(quoteAndQuoteLineItemMap.get(thisQuoteId) != NULL){
                for(QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisQuoteId)){
                    if(msQLIs.contains(thisQLI.Id)){
                        QuoteInstance.Contains_MS_Product__c = TRUE;
                        containsMsProduct = TRUE;
                    }else if(containsMsProduct == FALSE){
                        QuoteInstance.Contains_MS_Product__c = FALSE;
                    }
                }
            }
        }
    }
    /** END : bhaveshjindal : Update contains MS Product field **/
    
    /** START : bhaveshjindal : making SOW Dates required for MS SKU on quoteLineItem **/
    public static void validateSOWdates(Map<Id,Quote> mapOfNewQuote){
        
        Map<Id, Set<QuoteLineItem>> quoteAndQuoteLineItemMap    = new Map<Id, Set<QuoteLineItem>>();
        set<Id> integrationQLIs 								= new Set<Id>();
        
        for(
            QuoteLineItem thisRec : [ SELECT Id, QuoteId, period_start_date__c, period_end_date__c, Product2.ProductCode, 
                                     Product2.Name, Quote.Opportunity.Owner.User_Category__c, Type_of_Integration__c
                                     FROM QuoteLineItem WHERE
                                     QuoteId IN :mapOfNewQuote.keySet()
                                     ORDER BY QuoteId ]
        ){
            /** Start */
            if( quoteAndQuoteLineItemMap.containsKey(thisRec.QuoteId) ){
                quoteAndQuoteLineItemMap.get(thisRec.QuoteId).add(thisRec);
            } else{
                quoteAndQuoteLineItemMap.put(thisRec.QuoteId, new Set<QuoteLineItem>{thisRec});
            }
            /** End */
        }
        System.debug('quoteAndQuoteLineItemMap :: '+quoteAndQuoteLineItemMap);
        
        for(QuoteLineItem thisQli : [SELECT Id, QuoteId FROM QuoteLineItem WHERE Product2.Product_category__c = 'Integration' AND QuoteId IN :mapOfNewQuote.keySet() ]){
            integrationQLIs.add(thisQli.Id);
        }
        System.debug('integrationQLIs :: '+integrationQLIs);
        
        for(Id thisQuoteId : mapOfNewQuote.keySet()){
            Quote QuoteInstance = mapOfNewQuote.get(thisQuoteId);
            String arrs = '';
            Boolean showError = FALSE;
            if(quoteAndQuoteLineItemMap.get(thisQuoteId) != NULL){
                for(QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisQuoteId)){
                    if(integrationQLIs.contains(thisQLI.Id) && thisQLI.Type_of_Integration__c == NULL){
                        showError = TRUE;
                        arrs += thisQLI.product2.Name+', ';
                    }
                }
                if(showError){
                    QuoteInstance.addError('Please specify Type of integration on Quote Line Item for '+arrs);
                }
            }
        }
    }
    /** END : bhaveshjindal : making SOW Dates required for MS SKU on quoteLineItem **/
    
    /** START : bhaveshjindal : Update MAX ITC Combo Price **/
    public static void updateMaxItcComboPrice(Map<Id,Quote> mapOfNewQuote){
        System.debug('<----- : START : updateMaxItcComboPrice ----->');
        Map<Id, Set<QuoteLineItem>> quoteAndQuoteLineItemMap    = new Map<Id, Set<QuoteLineItem>>();
        set<Id> MaxItcIntegrationSKUs 							= new Set<Id>();
        List<QuoteLineItem> 		maxItcUltimateSKUs			= new List<QuoteLineItem>();
        
        for(
            QuoteLineItem thisRec : [ SELECT Id, QuoteId, period_start_date__c, period_end_date__c, Product2.ProductCode, Stage_in_MY__c,
                                     Product2.Name, Quote.Opportunity.Owner.User_Category__c, Type_of_Integration__c, MAX_ITC_Combo_Price__c, Total_Price__c
                                     FROM QuoteLineItem WHERE
                                     QuoteId IN :mapOfNewQuote.keySet()
                                     ORDER BY QuoteId ]
        ){
            /** Start */
            if( quoteAndQuoteLineItemMap.containsKey(thisRec.QuoteId) ){
                quoteAndQuoteLineItemMap.get(thisRec.QuoteId).add(thisRec);
            } else{
                quoteAndQuoteLineItemMap.put(thisRec.QuoteId, new Set<QuoteLineItem>{thisRec});
            }
            /** End */
        }
        System.debug('quoteAndQuoteLineItemMap :: '+quoteAndQuoteLineItemMap);
        
        for(QuoteLineItem thisQli : [SELECT Id, QuoteId FROM QuoteLineItem WHERE Product2.Module__c  = 'Max ITC' AND Product2.Product_Category__c = 'Integration' AND QuoteId IN :mapOfNewQuote.keySet() ]){
            MaxItcIntegrationSKUs.add(thisQli.Id);
        }
        System.debug('MaxItcIntegrationSKUs :: '+MaxItcIntegrationSKUs);
        
        for(Id thisQuoteId : mapOfNewQuote.keySet()){
            Quote QuoteInstance = mapOfNewQuote.get(thisQuoteId);
            QuoteLineItem MaxItcARR = new QuoteLineItem();
            Map<String, QuoteLineItem> MaxItcMultiYearMap = new Map<String, QuoteLineItem>();
            
            if(quoteAndQuoteLineItemMap.get(thisQuoteId) != NULL){
                System.debug('quoteAndQuoteLineItemMap.get(thisQuoteId) :: '+quoteAndQuoteLineItemMap.get(thisQuoteId));
                for(QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisQuoteId)){
                    if(thisQLI.Product2.ProductCode == 'MITC-ULTIMATE' || thisQLI.Product2.ProductCode == 'MITC-ULTIMATE-NOPAY'){
                        if(MaxItcIntegrationSKUs.size()>1){
                            MaxItcMultiYearMap.put(thisQLI.Stage_in_MY__c,thisQli);
                            System.debug('MaxItcMultiYearMap :: '+MaxItcMultiYearMap);
                        }else{
                            MaxItcARR = thisQLI;
                            System.debug('MaxItcARR :: '+MaxItcARR);
                        }
                    }
                }
                for(QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisQuoteId)){
                    if(MaxItcARR != NULL && MaxItcIntegrationSKUs.contains(thisQLI.Id) && !(thisQLI.Product2.Name.endsWithIgnoreCase('Pass Through'))){
                        if(MaxItcIntegrationSKUs.size()>1){
                            MaxItcMultiYearMap.get(thisQLI.Stage_in_MY__c).MAX_ITC_Combo_Price__c = MaxItcMultiYearMap.get(thisQLI.Stage_in_MY__c).Total_Price__c + thisQLI.Total_Price__c;
                            thisQLI.MAX_ITC_Combo_Price__c = 0;
                            maxItcUltimateSKUs.add(MaxItcMultiYearMap.get(thisQLI.Stage_in_MY__c));
                            maxItcUltimateSKUs.add(thisQLI);
                        }else{
                            MaxItcARR.MAX_ITC_Combo_Price__c = MaxItcARR.Total_Price__c + thisQLI.Total_Price__c;
                            thisQLI.MAX_ITC_Combo_Price__c = 0;
                            maxItcUltimateSKUs.add(MaxItcARR);
                            maxItcUltimateSKUs.add(thisQLI);
                        }
                    }
                }
            }
        }
        System.debug('maxItcUltimateSKUs :: '+maxItcUltimateSKUs);
        if(maxItcUltimateSKUs.size()>0){
            Update maxItcUltimateSKUs;
        }
        
        System.debug('<----- : END : updateMaxItcComboPrice ----->');
        
    }
    /** END : bhaveshjindal : Update MAX ITC Combo Price **/
    
    /** START : bhaveshjindal : Update contains ID Product field **/
    public static void updateContainsIDProductField(Map<Id,Quote> mapOfNewQuote){
        
        Map<Id, Set<QuoteLineItem>> quoteAndQuoteLineItemMap    = new Map<Id, Set<QuoteLineItem>>();
        set<Id> 					ID_SKUs 					= new Set<Id>();
        Map<Id, Integer>			quoteAndTotalIdSkuPrice		= new Map<Id, Integer>();
        
        for(
            QuoteLineItem thisRec : [ SELECT Id, QuoteId
                                     FROM QuoteLineItem WHERE
                                     QuoteId IN :mapOfNewQuote.keySet()
                                     ORDER BY QuoteId ]
        ){
            /** Start */
            if( quoteAndQuoteLineItemMap.containsKey(thisRec.QuoteId) ){
                quoteAndQuoteLineItemMap.get(thisRec.QuoteId).add(thisRec);
            } else{
                quoteAndQuoteLineItemMap.put(thisRec.QuoteId, new Set<QuoteLineItem>{thisRec});
            }
            /** End */
        }
        System.debug('quoteAndQuoteLineItemMap :: '+quoteAndQuoteLineItemMap);
        
        for(AggregateResult ar : [SELECT quoteId qId, sum(Total_Price__c) IdTotal FROM quotelineitem 
                                  WHERE quoteid IN :mapOfNewQuote.keySet() 
                                  AND product2.Product_Line__c = 'Invoice Discounting' 
                                  GROUP BY quoteid])
        {
            quoteAndTotalIdSkuPrice.put((String)ar.get('qId'),Integer.valueOf(ar.get('IdTotal')));
        }
        
        for(QuoteLineItem thisQli : [SELECT Id, QuoteId FROM QuoteLineItem WHERE product2.Product_Line__c = 'Invoice Discounting' AND QuoteId IN :mapOfNewQuote.keySet() ]){
            ID_SKUs.add(thisQli.Id);
        }
        System.debug('ID_SKUs :: '+ID_SKUs);
        
        for(Id thisQuoteId : mapOfNewQuote.keySet()){
            Quote QuoteInstance = mapOfNewQuote.get(thisQuoteId);
            QuoteInstance.Total_Price_ID_SKUs__c = quoteAndTotalIdSkuPrice.get(thisQuoteId);
            
            Boolean containsIdSku = False;
            if(quoteAndQuoteLineItemMap.get(thisQuoteId) != NULL){
                system.debug('if(quoteAndQuoteLineItemMap.get(thisQuoteId) != NULL)');
                for(QuoteLineItem thisQLI : quoteAndQuoteLineItemMap.get(thisQuoteId)){
                    if(ID_SKUs.contains(thisQLI.Id)){
                        system.debug('if(ID_SKUs.contains(thisQLI.Id))');
                        QuoteInstance.Contains_ID_Product__c = TRUE;
                        containsIdSku = TRUE;
                    }else if(containsIdSku == FALSE){
                        system.debug('else');
                        QuoteInstance.Contains_ID_Product__c = FALSE;
                    }
                }
            }
        }
    }
    /** END : bhaveshjindal : Update contains ID Product field **/
    
    
    
    public static void submitForDiscountApproval(Map<Id,Quote> mapofNewQuote,Map<Id,Quote> mapofOldQuote){
        System.debug('DISC APPROVAL -->'+mapofNewQuote);
        for(Id key:mapofNewQuote.KeySet()){
            if((mapofNewQuote.get(key).Approval_sub_status__c  				!= mapofOldQuote.get(key).Approval_sub_status__c &&
                (mapofNewQuote.get(key).Approval_sub_status__c 				== 'Integration Discount Approved'  ||
                 mapofNewQuote.get(key).Approval_sub_status__c				== 'Multiyear Discount Approved' 	||
                 mapofNewQuote.get(key).Approval_sub_status__c 				== 'Max Discount Approved' 			||
                 mapofNewQuote.get(key).Approval_sub_status__c 				== 'AP Discount Approved')) &&
               ((mapofNewQuote.get(key).Non_Integration_Maximum_Discount__c != NULL &&
                 mapofNewQuote.get(key).Non_Integration_Maximum_Discount__c > 0) ||
                (mapofNewQuote.get(key).Opportunity_Record_Type__c 			== 'Net_New_Id' && 
                 (mapofNewQuote.get(key).ID_Approval_Type__c  				== 'Double Approval' ||
                  mapofNewQuote.get(key).ID_Approval_Type__c  				== 'Single Approval' ))))
            {
                Approval.ProcessSubmitRequest appReq = new Approval.ProcessSubmitRequest();
                appReq.setComments('Submitting request for Discount approval');
                appReq.setObjectId(key);       
                Approval.ProcessResult result = Approval.process(appReq);
            }
            
        }
        
    }
    
    /** To calculate Discount (Order Form) on Quote Accept **/
    public static void calculateOrderFormDiscount(Map<Id,Quote> mapofNewQuote,Map<Id,Quote> mapofOldQuote){
        
        Map<Id, Quote> quoteToCalcDisc = new Map<Id, Quote>();
        
        Decimal ARR_Total_OF = 0;
        Decimal Total_Price = 0;
        
        for(Quote thisQuote : mapofNewQuote.values()){
            if(thisQuote.Status != mapofOldQuote.get(thisQuote.Id).Status &&
               thisQuote.Status == 'Quote Accept')
            {
                quoteToCalcDisc.put(thisQuote.Id, thisQuote);
            }
        }
        Map<Id, List<Quotelineitem>> qliMap = new  Map<Id, List<Quotelineitem>>();
        
        for(Quotelineitem qli : [SELECT Id, UnitPrice,List_Price_Order_Form__c, 
                                 quoteId, Total_Price__c, Calculate_based_on_List_Price_OF__c 
                                 FROM Quotelineitem
                                 WHERE quoteId IN :quoteToCalcDisc.keySet()
                                 AND Product2.Billing_Type__c = 'ARR'])
        {
            if(qliMap.containsKey(qli.quoteId)){
                qliMap.get(qli.quoteId).add(qli);
            }else{
                qliMap.put(qli.quoteId, new List<Quotelineitem>{qli});
            }
        }
        
        if(qliMap.values().size()>0){
            
            for(Quote thisQuote : quoteToCalcDisc.values()){
                
                if( qliMap.containsKey(thisQuote.Id)){
                    
                    for(Quotelineitem qli : qliMap.get(thisQuote.Id) ){
                        
                        Total_Price += qli.Total_Price__c;
                        if(qli.List_Price_Order_Form__c > qli.UnitPrice){
                            
                            ARR_Total_OF += qli.List_Price_Order_Form__c;
                            
                        }else{
                            
                            if(qli.Calculate_based_on_List_Price_OF__c){
                                
                                ARR_Total_OF += qli.List_Price_Order_Form__c;
                                
                            }else{
                                
                                ARR_Total_OF += qli.UnitPrice;
                                
                            }
                        }
                    }
                }
                
                System.debug('@ARR_Total_OF'+ARR_Total_OF);
                System.debug('@Total_Price'+Total_Price);
                
                thisQuote.Discount_Order_Form__c  = (((ARR_Total_OF-Total_Price)/ARR_Total_OF)*100).round(System.RoundingMode.CEILING);
                ARR_Total_OF = 0;
                Total_Price = 0;
                
            }
        }
        
    }
    
    
}