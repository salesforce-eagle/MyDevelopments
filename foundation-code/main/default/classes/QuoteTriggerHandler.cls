/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-18-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class QuoteTriggerHandler implements TriggerInterface {
    
    public static void beforeInsert(List<Sobject> listOfNewSObjects){
        
        List<Quote>	listOfNewQuotes							= (List<Quote>)listOfNewSObjects;
        List<Quote> listOfNewQuotesToUpdateOpportuntiyStage	= new List<Quote>();
        Map<Id,Id> 	opportunityIdwithQuoteId 				= new Map<Id,Id>();
        map<Id,Id> 	accOpprMap 								= new map<Id,Id>();
        Id 			PriceBookId;
        
        if( test.isRunningTest() ){
            PriceBookId = test.getStandardPricebookId();
        }else{
            PriceBookId = [ SELECT Id, Name FROM Pricebook2 WHERE isStandard = TRUE LIMIT 1 ].Id;
        }
        
        for( Quote quoteInstance : listOfNewQuotes ){
            
            quoteInstance.Pricebook2Id	= PriceBookId;
            
            if( quoteInstance.OpportunityId != NULL ){
                
                quoteInstance.Is_Primary_Quote__c = TRUE;
                opportunityIdwithQuoteId.put(quoteInstance.OpportunityId, quoteInstance.Id);
            }
            
        }
        
        Map<Id,opportunity> opporMap = new map<Id,opportunity>([select id,accountId,owner.Manager.Id,owner.Manager.Manager.Id,regional_head__c from opportunity where id in : opportunityIdwithQuoteId.keyset()]);	
        for(opportunity oppor: opporMap.Values()){	
            accOpprMap.put(oppor.Id,oppor.accountId);	
        }	
        map<Id,account> accMap = new map<Id,account>([select id,city__r.city_head__c,city__c,region__r.KAM_Regional_Head__c from account where Id in: accOpprMap.Values()]);	
        for(Quote quoteInstance: listOfNewQuotes){
            //if(accMap.get(opporMap.get(quoteInstance.OpportunityId).accountId).city__c != null && accMap.get(opporMap.get(quoteInstance.OpportunityId).accountId).city__r.city_head__c != null )	
            // quoteInstance.City_Head__c = accMap.get(opporMap.get(quoteInstance.OpportunityId).accountId).city__r.city_head__c;	
            
            quoteInstance.Opportunity_Owner_Manager__c = opporMap.get(quoteInstance.OpportunityId)?.owner?.Manager.Id;
            quoteInstance.Super_Manager_Name__c  = opporMap.get(quoteInstance.OpportunityId)?.owner?.Manager?.Manager.Id;
            quoteInstance.regional_head__c = opporMap.get(quoteInstance.OpportunityId)?.regional_head__c;
            //Pramodh Added for Making one Quote as Primary
            if(opportunityIdwithQuoteId.size()>0){
                QuoteTriggerHelper.primaryCheck(opportunityIdwithQuoteId);
            }
            //Pramodh Ended for Making one Quote as Primary
            
        }
        
        
        
    }
    
    public static void afterInsert(List<Sobject> listOfNewSObjects,Map<Id,Sobject> mapOfNewSObjects){
        
        List<Quote> listOfNewQuotes=(List<Quote>)listOfNewSObjects;
        Set<Id> setOfNewQuotesToUpdateOpportuntiyStage=new Set<Id>();
        
        for(Quote quoteInstance:listOfNewQuotes){
            
            if(quoteInstance.OpportunityId!=null && quoteInstance.Is_Primary_Quote__c==true && quoteInstance.Status!=null){
                setOfNewQuotesToUpdateOpportuntiyStage.add(quoteInstance.Id);
            }
            
        }
        
        if(setOfNewQuotesToUpdateOpportuntiyStage.size()>0){
            QuoteTriggerHelper.updateOpps(setOfNewQuotesToUpdateOpportuntiyStage);
        }
        
    }
    
    public static void beforeUpdate(Map<Id,Sobject> mapOfNewSObjects,Map<Id,Sobject> mapOfOldSObjects){
        
        Map<Id,Quote> 				mapOfNewIdWithQuotes			=(Map<Id,Quote>)mapOfNewSObjects;
        Map<Id,Quote> 				mapOfOldIdWithQuotes			=(Map<Id,Quote>)mapOfOldSObjects;
        Map<Id,Set<String>>			quoteWithModules 				= new Map<Id,Set<String>>();
        Map<String, Set<String>>	num_MandatoryFieldMap_NonZero 	= new Map<String, Set<String>>();
        Map<String, Set<String>>	txt_MandatoryFieldMap_NonZero 	= new Map<String, Set<String>>();
        Map<String, Set<String>>	num_MandatoryFieldMap_WithZero 	= new Map<String, Set<String>>();
        String						errorMessage_Non_Zero			= ' Enter non-zero/non-null values for the following fields: ';
        String						errorMessage_Zero_Allowed		= ' Enter values for the following fields: ';
        Map<Id,String> 				mapQuoteMaxDiscCategory 		= new Map<Id,String>();	
        Map<Id,Id>    				accOpprMap               		= new Map<Id,Id>();	
        Double 						temp 							= 0;	
        List<Quote> 				listOfQuoteDiscountChanges 		= New List<Quote>();
        String 						type                            ='Quote';
        Map<Id,List<String>> 		quoteWithBlankDate   			= new Map<Id,List<String>>();
        Map<Id,List<String>> 		quoteWithBlankPrice   			= new Map<Id,List<String>>();
        Map<Id,List<String>> 		quoteWithBlankSalePrice   		= new Map<Id,List<String>>();
        Map<Id,List<String>> 		quoteWithThresholdSalePrice   	= new Map<Id,List<String>>();
        Map<Id,List<String>> 		quoteWithThresholdListPrice   	= new Map<Id,List<String>>();
        Map<String,Integer> 		prodWithTerm   					= new Map<String,Integer>();
        Map<Id,List<String>> 		prodWithTermError   			= new Map<Id,List<String>>();
        Integer 					i 								= 0;
        Map<Id, Boolean>			quoteIntegrationScopeInApproval = new Map<Id, Boolean>();
        Map<String, Schema.SObjectType> 	schemaMap 				= Schema.getGlobalDescribe();
        Schema.SObjectType 					quoteSchema            	= schemaMap.get(type);
        Map<String, Schema.SObjectField> 	fieldMap 				= quoteSchema.getDescribe().fields.getMap();
        
        List<String> 					postNegotiationStage 			= new List<String>{
            'Discount Approval', 'Quote Accept'};
                List<String> 			preNegotiationStage 			= new List<String>{
                    'Draft', 'In Quote Approvals', 'Document Generated', 
                        'Quote Sent', 'Integration Add On'};
                            List<Account> accountsToUpdate = new List<Account>();
        Map<Id,Quote> quotesForTypeOfIntegrationValidation 			= new Map<Id,Quote>();
        
        for(
            Integration_Scope_Add_On__c thisRec : [ SELECT Id, Related_Quote__c, Add_On_Status__c 
                                                   FROM Integration_Scope_Add_On__c WHERE 
                                                   Related_Quote__c IN :mapOfNewIdWithQuotes.keySet() AND 
                                                   Add_On_Status__c = 'In Approval' ] 
        ){
            quoteIntegrationScopeInApproval.put(thisRec.Related_Quote__c, TRUE);
        }
        
        
        //bhaveshjindal : Integration Price Guardrail
        QuoteTriggerHelper.integrationPriceGuardrailV2(mapOfNewIdWithQuotes,mapOfOldIdWithQuotes);
        
        //bhaveshjindal : Pricing Rule For EC
        QuoteTriggerHelper.updateFieldsForPricingRuleForEC((Map<Id,Quote>)mapOfNewSObjects);
        
        //bhaveshjindal : update Contains MS Product Field
        QuoteTriggerHelper.updateContainsMSProductField((Map<Id,Quote>)mapOfNewSObjects);
        
        //bhaveshjindal : update Contains ID Product Field
        QuoteTriggerHelper.updateContainsIDProductField((Map<Id,Quote>)mapOfNewSObjects);
        
        /** Start : bhaveshjindal : Type of Integrgration validation on quoteline item **/
        for(id thisQuoteId : mapOfNewIdWithQuotes.keySet()){
            
            Quote newQuote = mapOfNewIdWithQuotes.get(thisQuoteId);
            Quote oldQuote = mapOfOldIdWithQuotes.get(thisQuoteId);
            
            if(OpportunityConstants.AUTO_RENEW_RULE &&
               newQuote.Opportunity.Is_Auto_Renewal_Enabled__c == TRUE ){
                   if( !system.label.Auto_Renewal_Discount_Approval_Eligible_Email.containsIgnoreCase( UserInfo.getUserEmail() ) ){
                       //newQuote.addError(System.Label.CTX_AutoRenewal_Error_Msg);
                   }
               }
            /**	**/
            if(
                newQuote.Status != oldQuote.Status &&
                newQuote.Status == 'Price Negotiation' &&
                preNegotiationStage.contains(oldQuote.Status) && 
                !postNegotiationStage.contains(oldQuote.Status)
            ){
                newQuote.Is_Negotiation_Stage_Checked__c = TRUE;
            }	/**	Price Negotiation Filter : END	**/
            
            /**	Revoke Price Negotiation Logic : START	**/
            if(
                (
                    newQuote.IsSyncing != oldQuote.IsSyncing &&
                    !newQuote.IsSyncing &&
                    oldQuote.IsSyncing &&
                    newQuote.Status == 'Quote Sent' &&
                    postNegotiationStage.contains(oldQuote.Status)
                ) ||
                (
                    ( postNegotiationStage.contains(oldQuote.Status) || oldQuote.Status == 'Price Negotiation' )	&&
                    preNegotiationStage.contains(newQuote.Status)
                )
            ){
                newQuote.Is_Negotiation_Stage_Checked__c = FALSE;
            }
            /**	**/
            
            /**	**/
            if(
                oldQuote.Status != newQuote.Status && 
                preNegotiationStage.contains(oldQuote.Status) && 
                postNegotiationStage.contains(newQuote.Status)
            ){
                //newQuote.addError('Can not skip Price Negotiation Stage.');
            }	/**	Price Negotiation Filter : END	**/
            
            
            if(
                newQuote.IsSyncing != oldQuote.IsSyncing &&
                !newQuote.IsSyncing && oldQuote.IsSyncing
            ){
                newQuote.Status = 'Quote Sent';
                QuoteConstants.DISABLEQLIVAl = TRUE;
            }
            
            //bhaveshjindal :: to block moving stage if quote is in discount approval
            system.debug('newQuote.Status :: '+newQuote.Status);
            system.debug('oldQuote.Status :: '+oldQuote.Status);
            system.debug('newQuote.Approval_sub_status__c :: '+newQuote.Approval_sub_status__c);
            system.debug('oldQuote.Approval_sub_status__c :: '+oldQuote.Approval_sub_status__c);
            if(newQuote.Status != oldQuote.Status && oldQuote.Status == 'Discount Approval' 
               && (oldQuote.Approval_sub_status__c == 'Discount Approval in progress' || oldQuote.Approval_sub_status__c == 'MS Approval in progress' )
               && (newQuote.Approval_sub_status__c != 'Discount Approved' && newQuote.Approval_sub_status__c != 'Discount Rejected') 
               && (newQuote.Approval_sub_status__c != 'MS Approval done' && newQuote.Approval_sub_status__c != 'MS Approval Rejected')){
                   newQuote.addError('You can\'t move the Quote stage since its gone for Discount Approval.'); 
               }
            
            if(newQuote.Status != oldQuote.Status && (oldQuote.Status != 'Discount Approval' && oldQuote.Status != 'Quote Accept' )){
                if(oldQuote.Status == 'Integration Add On'){
                    if(quoteIntegrationScopeInApproval.containsKey(oldQuote.Id) && quoteIntegrationScopeInApproval.get(oldQuote.Id)){
                        newQuote.addError('You can\'t move the Quote stage since its gone for Approval to the integration team'); 
                    }
                }
                quotesForTypeOfIntegrationValidation.put(thisQuoteId,newQuote);
            }
        }
        if(quotesForTypeOfIntegrationValidation.size()>0){
            QuoteTriggerHelper.validateTypeOfIntegration(quotesForTypeOfIntegrationValidation);
        }
        /** END : bhaveshjindal **/
        
        //List<Quote> listOfQuoteDiscountChanges = New List<Quote>();
        
        //List<Quote> listOfNewQuotesToUpdateOpportuntiyStage=new List<Quote>();
        Set<Id> setOfNewQuotesToUpdateOpportuntiyStage=new Set<Id>();
        // Commeneted by Raksha Map<Id,Quote> quoteWithChangedStatus = new Map<Id,Quote>();
        Map<Id,Id> opportunityIdwithQuoteId = new Map<Id,Id>();
        Map<Id,Id> opportunityIdwithQuoteIdNew = new Map<Id,Id>();
        Id PriceBookId;
        if(test.isRunningTest()){
            PriceBookId = test.getStandardPricebookId();
        }else{
            PriceBookId = [select id, name from Pricebook2 where isStandard = true limit 1].Id;
        }
        /**	Get QuoteId and QuoteLineItem Category Details	**/	
        try{
            for(	
                aggregateResult aggrResult: [ SELECT max(Discount) maxDisc,product2.Product_Category__c prodCat,quoteId qId	
                                             FROM QuoteLineItem WHERE quoteId in: mapOfNewIdWithQuotes.keySet() group by product2.Product_Category__c,quoteId]	
            ){	
                Double curTemp =Double.ValueOf(aggrResult.get('maxDisc'));	
                Id qId = (Id)aggrResult.get('qId');	
                String prodCat= String.valueOf(aggrResult.get('prodCat'));	
                if(curTemp > temp){	
                    mapQuoteMaxDiscCategory.put(qId,prodCat);	
                    temp = curTemp;	
                } else if(curTemp == temp){	
                    mapQuoteMaxDiscCategory.put(qId,mapQuoteMaxDiscCategory.get(qId) + ','+prodCat) ;	
                }         	
            }
            
            /**	Get Details from Custom Setting for Module and Mandatory Fields	**/
            for(
                Mandatory_PM__c thisRec : [ SELECT Mandatory_Num_API_Name__c, Name, Mandatory_Text_API_Name__c, Mandatory_Num_API_Name_Zero_Allowed__c 
                                           FROM Mandatory_PM__c ] 
            ){
                
                if(thisRec.Mandatory_Num_API_Name__c != NULL)
                    num_MandatoryFieldMap_NonZero.put(thisRec.Name, new Set<String>(thisRec.Mandatory_Num_API_Name__c.split(',')));
                
                if(thisRec.Mandatory_Text_API_Name__c != NULL)
                    txt_MandatoryFieldMap_NonZero.put(thisRec.Name, new Set<String>(thisRec.Mandatory_Text_API_Name__c.split(',')));
                
                if(thisRec.Mandatory_Num_API_Name_Zero_Allowed__c != NULL)
                    num_MandatoryFieldMap_WithZero.put(thisRec.Name, new Set<String>(thisRec.Mandatory_Num_API_Name_Zero_Allowed__c.split(',')));
                
            }
            /**
/**	Get Details from Custom Setting for Prod term Validation	**/
            for(
                Product_Term_Validation__c  thisRec : [ SELECT Name, Term_Months__c 
                                                       FROM Product_Term_Validation__c ] 
            ){
                
                
                prodWithTerm.put(thisRec.Name, Integer.ValueOf(thisRec.Term_Months__c)); 
            }
            /**
List<aggregateResult> QLIgroup = [SELECT count(id) countId,quoteId parentQuoteId FROM QuoteLineItem 
WHERE (quoteId in: mapOfNewIdWithQuotes.keySet() AND (period_start_date__c = null OR period_end_date__c = null )) 
group by quoteId order by count(id) DESC];
for(AggregateResult QLI : QLIgroup){
Integer count = Integer.ValueOf(QLI.get('countId'));
if(count > 0){
quoteWithBlankDate.put(String.ValueOf(QLI.get('parentQuoteId')),count);
}
}
**/
            
            
            /**	Get QuoteId and QuoteLineItem Module Details	**/
            for(
                QuoteLineItem QLI: [SELECT id,quoteId,product2.Corrected_Module_for_metering__c,period_start_date__c,Product2.ProductCode,
                                    period_end_date__c,product2.name,UnitPrice,Sale_Price__c,Product2.Product_category__c, Threshold_Price__c,
                                    quote.MAX_PED_ID_TRANS__c,quote.MIN_PSD_ID_TRANS__c,Threshold_List_Price__c
                                    FROM QuoteLineItem WHERE quoteId in: mapOfNewIdWithQuotes.keySet()]
            ){

                //Added By Kartikeya for blank date/price check
                if(QLI.period_start_date__c == null || QLI.period_end_date__c == null){
                    if(!quoteWithBlankDate.containsKey(QLI.quoteId) ){
                        quoteWithBlankDate.put(QLI.quoteId,new List<String>{QLI.product2.name} );
                    }
                    else if(quoteWithBlankDate.containsKey(QLI.quoteId) ){
                        quoteWithBlankDate.get(QLI.quoteId).add(QLI.product2.name);
                    }
                }
                else if(QLI.period_start_date__c != null && QLI.period_end_date__c != null){
                    /** Term Validation for Product**/
                    if(prodWithTerm.containsKey(QLI.Product2.ProductCode) &&  QLI.quote.MIN_PSD_ID_TRANS__c != NULL && QLI.quote.MAX_PED_ID_TRANS__c != NULL
                       && QLI.quote.MIN_PSD_ID_TRANS__c .ADDMONTHS(prodWithTerm.get(QLI.Product2.ProductCode)) > (QLI.quote.MAX_PED_ID_TRANS__c+1) 
                       && !prodWithTermError.ContainsKey(QLI.QuoteId))
                    {
                        prodWithTermError.put(QLI.QuoteId,new List<String>{'Period End Date should not be less than ' + prodWithTerm.get(QLI.Product2.ProductCode)+ ' months from period start date for ' + QLI.Product2.Name});               
                        /** Term Validation for Product**/       
                    }
                }
                if(!quoteWithBlankPrice.containsKey(QLI.quoteId) && (QLI.UnitPrice == 0) && QLI.Product2.Product_category__c != 'Transactional'){
                    quoteWithBlankPrice.put(QLI.quoteId,new List<String>{QLI.product2.name} );
                }
                else if(quoteWithBlankPrice.containsKey(QLI.quoteId) && (QLI.UnitPrice == 0) && QLI.Product2.Product_category__c != 'Transactional'){
                    quoteWithBlankPrice.get(QLI.quoteId).add(QLI.product2.name);
                }
                if(!quoteWithBlankSalePrice.containsKey(QLI.quoteId) && (QLI.Sale_Price__c == 0) && QLI.Threshold_Price__c != 0){
                    quoteWithBlankSalePrice.put(QLI.quoteId,new List<String>{QLI.product2.name} );
                }
                else if(quoteWithBlankSalePrice.containsKey(QLI.quoteId) && (QLI.Sale_Price__c == 0) && QLI.Threshold_Price__c != 0){
                    quoteWithBlankSalePrice.get(QLI.quoteId).add(QLI.product2.name);
                }
                if(!quoteWithThresholdSalePrice.containsKey(QLI.quoteId) && (QLI.Threshold_Price__c != 0 && QLI.Threshold_Price__c > QLI.Sale_Price__c)){
                    quoteWithThresholdSalePrice.put(QLI.quoteId,new List<String>{QLI.product2.name} );
                }
                else if(quoteWithThresholdSalePrice.containsKey(QLI.quoteId) && (QLI.Threshold_Price__c != 0 && QLI.Threshold_Price__c > QLI.Sale_Price__c)){
                    quoteWithThresholdSalePrice.get(QLI.quoteId).add(QLI.product2.name);
                }
                if(!quoteWithThresholdListPrice.containsKey(QLI.quoteId) && (QLI.Threshold_List_Price__c != 0 && QLI.Threshold_List_Price__c > QLI.UnitPrice)){
                    quoteWithThresholdListPrice.put(QLI.quoteId,new List<String>{QLI.product2.name} );
                }
                else if(quoteWithThresholdListPrice.containsKey(QLI.quoteId) && (QLI.Threshold_List_Price__c != 0 && QLI.Threshold_List_Price__c > QLI.UnitPrice)){
                    quoteWithThresholdListPrice.get(QLI.quoteId).add(QLI.product2.name);
                }
                //End By Kartikeya
                
                if(!quoteWithModules.containsKey(QLI.quoteId)){
                    quoteWithModules.put(QLI.quoteId,new set<string>{QLI.product2.Corrected_Module_for_metering__c});
                } else{
                    quoteWithModules.get(QLI.quoteId).add(QLI.product2.Corrected_Module_for_metering__c);
                }
            }
            
            /**	Iterate over the list of Incoming Quote	**/
            List<String> profileIds = system.label.Quote_Validation_Exclusion.split(',');
            for(Id quotekey:mapOfNewIdWithQuotes.keySet()){
                //Added By Kartikeya for Blank Date Check
                if((mapOfNewIdWithQuotes.get(quotekey).Status != mapOfOldIdWithQuotes.get(quotekey).Status) && quoteWithBlankDate.containsKey(quotekey) ){
                    List<String> sList = quoteWithBlankDate.get(quotekey);
                    string allString = string.join(sList,',');
                    if( !profileIds.contains(UserInfo.getProfileId()) ){
                        mapOfNewIdWithQuotes.get(quotekey).addError('Enter period start date and period end date for : '+allString+' product(s)');
                    }
                    
                }
                if((mapOfNewIdWithQuotes.get(quotekey).Status != mapOfOldIdWithQuotes.get(quotekey).Status) && prodWithTermError.containsKey(quotekey) && !prodWithTermError.get(quotekey).Contains(null)){
                    system.debug('List@#$'+prodWithTermError.get(quotekey));
                    List<String> sList = prodWithTermError.get(quotekey);
                    string allString = string.join(sList,',');
                    if( !profileIds.contains(UserInfo.getProfileId()) ){
                        mapOfNewIdWithQuotes.get(quotekey).addError(allString);
                    }
                    
                }
                //End By Kartikeya
                //Added By Kartikeya for Blank Price Check
                
                if((mapOfNewIdWithQuotes.get(quotekey).Status != mapOfOldIdWithQuotes.get(quotekey).Status) && quoteWithBlankPrice.containsKey(quotekey) ){
                    List<String> sList = quoteWithBlankPrice.get(quotekey);
                    string allString = string.join(sList,',');
                    if( !profileIds.contains(UserInfo.getProfileId()) ){
                        mapOfNewIdWithQuotes.get(quotekey).addError('Enter List Price(E) for : '+allString+' product(s)');
                    }
                    
                }
                if((mapOfNewIdWithQuotes.get(quotekey).Status != mapOfOldIdWithQuotes.get(quotekey).Status) && quoteWithBlankSalePrice.containsKey(quotekey) ){
                    List<String> sList = quoteWithBlankSalePrice.get(quotekey);
                    string allString = string.join(sList,',');
                    
                    if( !profileIds.contains(UserInfo.getProfileId()) ){
                        mapOfNewIdWithQuotes.get(quotekey).addError('Enter Sale Price for : '+allString+' product(s)');
                    }
                    
                }
                
                system.debug('mapOfNewIdWithQuotes.get(quotekey).Status :: '+mapOfNewIdWithQuotes.get(quotekey).Status);
                system.debug('mapOfOldIdWithQuotes.get(quotekey).Status :: '+mapOfOldIdWithQuotes.get(quotekey).Status);
                
                //commented by bhaveshjindal
                /**if((mapOfNewIdWithQuotes.get(quotekey).Status != mapOfOldIdWithQuotes.get(quotekey).Status) && (mapOfOldIdWithQuotes.get(quotekey).Status != 'Discount Approval' && mapOfOldIdWithQuotes.get(quotekey).Status != 'Quote Sent') && quoteWithThresholdSalePrice.containsKey(quotekey) && !System.Label.Threshold_Price_Profiles.Contains(userInfo.getProfileId())){
List<String> sList = quoteWithThresholdSalePrice.get(quotekey);
string allString = string.join(sList,',');
mapOfNewIdWithQuotes.get(quotekey).addError('Enter Sale Price for : '+allString+' product(s) more than the respective Threshold Prices!');
}
if((mapOfNewIdWithQuotes.get(quotekey).Status != mapOfOldIdWithQuotes.get(quotekey).Status) && (mapOfOldIdWithQuotes.get(quotekey).Status != 'Discount Approval' && mapOfOldIdWithQuotes.get(quotekey).Status != 'Quote Sent') && quoteWithThresholdListPrice.containsKey(quotekey) && !System.Label.Threshold_Price_Profiles.Contains(userInfo.getProfileId())){
List<String> sList = quoteWithThresholdListPrice.get(quotekey);
string allString = string.join(sList,',');
mapOfNewIdWithQuotes.get(quotekey).addError('Enter List Price(E) for : '+allString+' product(s) more than the respective Threshold Prices!');
}**/
                //End By Kartikeya
                if(mapQuoteMaxDiscCategory.get(quotekey) != null){	
                    mapOfNewIdWithQuotes.get(quotekey).Max_Discount_Prod_Category__c =  mapQuoteMaxDiscCategory.get(quotekey);	
                }	
                else{	
                    mapOfNewIdWithQuotes.get(quotekey).Max_Discount_Prod_Category__c = '';	
                }
                
                Boolean 	isError_Zero 		= FALSE;
                Boolean 	isError_Non_Zero 	= FALSE;
                Set<String> mandatory_NonZero 	= new Set<String>();
                Set<String> mandatory_WithZero 	= new Set<String>();
                mapOfNewIdWithQuotes.get(quotekey).Pricebook2Id = PriceBookId;
                if(
                    mapOfNewIdWithQuotes.get(quotekey).status 								!= mapOfOldIdWithQuotes.get(quotekey).status 								|| 
                    mapOfNewIdWithQuotes.get(quotekey).BtoB_Sales_one__c 					!= mapOfOldIdWithQuotes.get(quotekey).BtoB_Sales_one__c 					||
                    mapOfNewIdWithQuotes.get(quotekey).BtoC_Sales_one__c 					!= mapOfOldIdWithQuotes.get(quotekey).BtoC_Sales_one__c 					||
                    mapOfNewIdWithQuotes.get(quotekey).No_of_GSTIN_one__c 					!= mapOfOldIdWithQuotes.get(quotekey).No_of_GSTIN_one__c 					||
                    mapOfNewIdWithQuotes.get(quotekey).No_of_PAN_one__c 					!= mapOfOldIdWithQuotes.get(quotekey).No_of_PAN_one__c 						||
                    mapOfNewIdWithQuotes.get(quotekey).No_of_User_ID_one__c 				!= mapOfOldIdWithQuotes.get(quotekey).No_of_User_ID_one__c 					||
                    mapOfNewIdWithQuotes.get(quotekey).No_of_airline_invoices_annual_one__c != mapOfOldIdWithQuotes.get(quotekey).No_of_airline_invoices_annual_one__c 	||
                    mapOfNewIdWithQuotes.get(quotekey).Purchases_Invoices_one__c 			!= mapOfOldIdWithQuotes.get(quotekey).Purchases_Invoices_one__c 			||
                    mapOfNewIdWithQuotes.get(quotekey).Zone__c 								!= mapOfOldIdWithQuotes.get(quotekey).Zone__c 								||
                    mapOfNewIdWithQuotes.get(quotekey).Type_of_Integration__c 				!= mapOfOldIdWithQuotes.get(quotekey).Type_of_Integration__c
                ){
                    
                    if(!quoteWithModules.isEmpty()){
                        for(String thisSTR : quoteWithModules.get(quotekey)){

                            if( 
                                num_MandatoryFieldMap_NonZero.size() > 0			&&
                                num_MandatoryFieldMap_NonZero.containsKey(thisSTR)
                            ){
                                mandatory_NonZero.addAll(num_MandatoryFieldMap_NonZero.get(thisSTR));
                            }
                            
                            if( 
                                txt_MandatoryFieldMap_NonZero.size() > 0			&&
                                txt_MandatoryFieldMap_NonZero.containsKey(thisSTR)
                            ){
                                mandatory_NonZero.addAll(txt_MandatoryFieldMap_NonZero.get(thisSTR));
                            }
                            
                            if( 
                                num_MandatoryFieldMap_WithZero.size() > 0			&&
                                num_MandatoryFieldMap_WithZero.containsKey(thisSTR)
                            ){
                                mandatory_WithZero.addAll(num_MandatoryFieldMap_WithZero.get(thisSTR));
                            }
                        }
                       
                        /**	Non Zero or Null Value Check	**/
                        for(String thisSTR : mandatory_NonZero){
                            
                            if( mapOfNewIdWithQuotes.get(quotekey).get(thisSTR) == NULL || mapOfNewIdWithQuotes.get(quotekey).get(thisSTR) == 0 ){
                                String fieldLabel = fieldMap.get(thisSTR).getDescribe().getLabel();
                                errorMessage_Non_Zero += (fieldLabel+' ,');
                                isError_Non_Zero = TRUE;
                                // mapOfNewIdWithQuotes.get(quotekey).addError(thisSTR,'Enter non-zero value for this field');
                            } 
                        }
                        
                        /**	Zero allowed Value Check	**/
                        for(String thisSTR : mandatory_WithZero){
                            if( mapOfNewIdWithQuotes.get(quotekey).get(thisSTR) == NULL  ){
                                String fieldLabel = fieldMap.get(thisSTR).getDescribe().getLabel();
                                errorMessage_Zero_Allowed += (fieldLabel+' ,');
                                isError_Zero = TRUE;
                                 //mapOfNewIdWithQuotes.get(quotekey).addError(thisSTR,'Enter value for this field');
                            } 
                        }
                        
                        /**	Remove End	**/
                        errorMessage_Non_Zero 		= errorMessage_Non_Zero.removeEnd(' ,');
                        errorMessage_Zero_Allowed 	= errorMessage_Zero_Allowed.removeEnd(' ,');
                        
                        /**	Error Condition Check	**/
                        if( isError_Zero && isError_Non_Zero ){
                             //mapOfNewIdWithQuotes.get(quotekey).adderror(errorMessage_Non_Zero + ' & ' +errorMessage_Zero_Allowed,false);
                        } else if( isError_Zero  ){
                            //mapOfNewIdWithQuotes.get(quotekey).adderror(errorMessage_Zero_Allowed);
                        } else if( isError_Non_Zero ){
                            //mapOfNewIdWithQuotes.get(quotekey).adderror(errorMessage_Non_Zero );
                        } else{
                            /**	No Error	**/
                        }
                    }
                }
                if(mapOfNewIdWithQuotes.get(quotekey).Status!=mapOfOldIdWithQuotes.get(quotekey).Status){
                    if(mapOfNewIdWithQuotes.get(quotekey).OpportunityId!=null && mapOfNewIdWithQuotes.get(quotekey).Is_Primary_Quote__c==true && mapOfNewIdWithQuotes.get(quotekey).Status!=null && mapOfNewIdWithQuotes.get(quotekey).IsSyncing == true ){
                        setOfNewQuotesToUpdateOpportuntiyStage.add(mapOfNewIdWithQuotes.get(quotekey).Id);
                    }
                    //Pramodh Added
                    if(mapOfNewIdWithQuotes.get(quotekey).status != QuoteConstants.STATUS_INQUOTEAPPROVALS && mapOfNewIdWithQuotes.get(quotekey).status != QuoteConstants.STATUS_DRAFT && mapOfNewIdWithQuotes.get(quotekey).Approval_Status__c != QuoteConstants.APPROVAL_APPROVED && mapOfNewIdWithQuotes.get(quotekey).Approval_Status__c != QuoteConstants.APPROVAL_NOT_REQUIRED){
                        // mapOfNewIdWithQuotes.get(quotekey).AddError(System.Label.Quote_Approval_Error);  commented on 9/2 due to new changes in pricing calculator. because of that this approval is not applicable
                    }
                    else if(mapOfNewIdWithQuotes.get(quotekey).status == QuoteConstants.STATUS_DOCUMENT_GENERATED ){
                        //quoteWithChangedStatus.put(quotekey,mapOfNewIdWithQuotes.get(quotekey));
                        
                    }
                    
                    //Pramodh Ended
                }
                //Pramodh Calling this method for Approval Process
                /**if((mapOfNewIdWithQuotes.get(quotekey).Discount != mapOfOldIdWithQuotes.get(quotekey).Discount && mapOfNewIdWithQuotes.get(quotekey).Discount > 0 && mapOfNewIdWithQuotes.get(quotekey).BackEndPreviousQuoteDiscount__c == null) || (mapOfNewIdWithQuotes.get(quotekey).BackEndPreviousQuoteDiscount__c != null && mapOfNewIdWithQuotes.get(quotekey).BackEndPreviousQuoteDiscount__c < mapOfNewIdWithQuotes.get(quotekey).Discount)){
listOfQuoteDiscountChanges.add(mapOfNewIdWithQuotes.get(quotekey));
mapOfNewIdWithQuotes.get(quotekey).Approval_Status__c = '';
mapOfNewIdWithQuotes.get(quotekey).status = QuoteConstants.STATUS_INQUOTEAPPROVALS;
}
else if(mapOfNewIdWithQuotes.get(quotekey).Discount <= 0 || (mapOfNewIdWithQuotes.get(quotekey).Discount != mapOfOldIdWithQuotes.get(quotekey).Discount && (mapOfNewIdWithQuotes.get(quotekey).BackEndPreviousQuoteDiscount__c != null && mapOfNewIdWithQuotes.get(quotekey).BackEndPreviousQuoteDiscount__c > mapOfNewIdWithQuotes.get(quotekey).Discount)) ){
mapOfNewIdWithQuotes.get(quotekey).Approval_Status__c = 'Not Required';   
//mapOfNewIdWithQuotes.get(quotekey).Level_1_Approver__c = null;
//mapOfNewIdWithQuotes.get(quotekey).Level_2_Approver__c = null;
//mapOfNewIdWithQuotes.get(quotekey).Level_3_Approver__c = null;
//mapOfNewIdWithQuotes.get(quotekey).Level_4_Approver__c = null;
}
system.debug('<0'+(mapOfNewIdWithQuotes.get(quotekey).Discount <= 0));
system.debug('2nd'+(mapOfNewIdWithQuotes.get(quotekey).BackEndPreviousQuoteDiscount__c != null && mapOfNewIdWithQuotes.get(quotekey).BackEndPreviousQuoteDiscount__c > mapOfNewIdWithQuotes.get(quotekey).Discount));
//Pramodh Ending this method for Approval Process**/
                if(mapOfNewIdWithQuotes.get(quotekey).OpportunityId!=null && mapOfNewIdWithQuotes.get(quotekey).Is_Primary_Quote__c ){
                    //Pramodh Added for Making one Quote as Primary
                    opportunityIdwithQuoteId.put(mapOfNewIdWithQuotes.get(quotekey).OpportunityId, mapOfNewIdWithQuotes.get(quotekey).Id);
                    //Pramodh Ended for Making one Quote as Primary
                }
                if(mapOfNewIdWithQuotes.get(quotekey).OpportunityId!=null){	
                    opportunityIdwithQuoteIdNew.put(mapOfNewIdWithQuotes.get(quotekey).OpportunityId, mapOfNewIdWithQuotes.get(quotekey).Id);	
                }
                if(!mapOfNewIdWithQuotes.get(quotekey).Is_Primary_Quote__c && !StopRecursion.stopQuoteRecursion && (mapOfNewIdWithQuotes.get(quotekey).Is_Primary_Quote__c != mapOfOldIdWithQuotes.get(quotekey).Is_Primary_Quote__c ) ){
                    mapOfNewIdWithQuotes.get(quotekey).AddError('Please Mark Other Quote As Primary to Automatically Uncheck This');
                }
                System.debug('app '+mapOfNewIdWithQuotes.get(quotekey).Approval_Status__c);
                If(mapOfNewIdWithQuotes.get(quotekey).RecordTypeId != Schema.SObjectType.Quote.getRecordTypeInfosByName().get('International').getRecordTypeId()){

                        mapOfNewIdWithQuotes.get(quotekey).RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Without Document Creation').getRecordTypeId();
                }
                
                
            }
            Map<Id,opportunity> opporMap = new Map<Id,opportunity>([SELECT id,accountId,owner.Manager.Id,owner.Manager.Manager.Id,regional_head__c from opportunity where id in : opportunityIdwithQuoteIdNew.keyset()]);	
            for(opportunity oppor: opporMap.values()){	
                accOpprMap.put(oppor.Id,oppor.accountId);	
            }	
            Map<Id,account> accMap       = new Map<Id,account>([SELECT id,city__r.city_head__c,city__c,region__r.KAM_Regional_Head__c from account where Id in: accOpprMap.Values()]);	
            for(Id quotekey:mapOfNewIdWithQuotes.keySet()){	
                if(accMap.get(opporMap.get(mapOfNewIdWithQuotes.get(quotekey).OpportunityId).accountId).city__c != null && accMap.get(opporMap.get(mapOfNewIdWithQuotes.get(quotekey).OpportunityId).accountId).city__r.city_head__c != null)
                    mapOfNewIdWithQuotes.get(quotekey).City_Head__c = accMap.get(opporMap.get(mapOfNewIdWithQuotes.get(quotekey).OpportunityId).accountId).city__r.city_head__c;	
                if(opporMap.get(mapOfNewIdWithQuotes.get(quotekey).OpportunityId).regional_head__c != null)	
                    mapOfNewIdWithQuotes.get(quotekey).regional_head__c = opporMap.get(mapOfNewIdWithQuotes.get(quotekey).OpportunityId).regional_head__c;	
                mapOfNewIdWithQuotes.get(quotekey).Opportunity_Owner_Manager__c = opporMap.get(mapOfNewIdWithQuotes.get(quotekey).OpportunityId).owner.Manager.Id;	
                mapOfNewIdWithQuotes.get(quotekey).Super_Manager_Name__c  = opporMap.get(mapOfNewIdWithQuotes.get(quotekey).OpportunityId).owner.Manager.Manager.Id;	
            }
            if(setOfNewQuotesToUpdateOpportuntiyStage.size()>0){
                QuoteTriggerHelper.updateOpps(setOfNewQuotesToUpdateOpportuntiyStage);
            }
            /* commeneted by Raksha
if(quoteWithChangedStatus.size() > 0){
QuoteTriggerHelper.statusError(quoteWithChangedStatus);
}*/
            if(opportunityIdwithQuoteId.size()>0){
                QuoteTriggerHelper.primaryCheck(opportunityIdwithQuoteId);
            }
            If(listOfQuoteDiscountChanges.size()>0){
                QuoteTriggerHelper.setApprovers(listOfQuoteDiscountChanges);
            }
            //discount approval rejection 
            List<Id> Ids = New List <Id>();
            Ids.addAll(mapOfNewSObjects.keyset());
            List<ProcessInstance> instances = [select Id, TargetObjectId from ProcessInstance where TargetObjectId in :mapOfNewSObjects.keySet()];
            Map<Id,Id> QuoteProcessMap = new Map<Id,Id>();
            Ids = New List <Id>();
            for(ProcessInstance pi:instances){
                QuoteProcessMap.put(pi.TargetObjectId,pi.Id); 
                Ids.add (pi.Id);
            }
            System.Debug ('** mapa1: '+QuoteProcessMap);
            
            List<ProcessInstanceStep> instancesSteps = [select Comments,ProcessInstanceId,StepStatus  from ProcessInstanceStep where ProcessInstanceId in :Ids and StepStatus ='Rejected'];
            Map<Id,String> QuoteProcessStepMap = new Map<Id,String>(); // String porque hace referencia a comentarios//
            for(ProcessInstanceStep pis:instancesSteps){
                QuoteProcessStepMap.put (pis.ProcessInstanceId, pis.Comments); 
            }
            System.Debug ('** mapa2: '+QuoteProcessStepMap);
            for (Quote thisQuote: mapOfNewIdWithQuotes.values()){
                if(QuoteProcessMap.containsKey(thisQuote.Id) && QuoteProcessStepMap.containsKey(QuoteProcessMap.get(thisQuote.Id))){
                    thisQuote.Reason_for_Discount_Rejection__c  = QuoteProcessStepMap.get(QuoteProcessMap.get(thisQuote.Id));
                }
            }
        
        }
        catch(Exception e){	
            
            
            throw new AuraHandledException('Error Exception happend'+e.getMessage());          
        }
        QuoteTriggerHelper.calculateOrderFormDiscount(mapOfNewIdWithQuotes, mapOfOldIdWithQuotes);
        
    }
    
    public static void afterUpdate(Map<Id,Sobject> mapOfNewSObjects,Map<Id,Sobject> mapOfOldSObjects){
        
        QuoteConstants.ISFIRSTTIMEQUOTE									= FALSE;
        Map<Id,Quote>					mapOfNewIdWithQuotes			= (Map<Id,Quote>)mapOfNewSObjects;
        Map<Id,Quote> 					mapOfOldIdWithQuotes			= (Map<Id,Quote>)mapOfOldSObjects;
        Set<Id> 					    quoteIds 						= new Set<Id>();
        Map<Id,Quote>					quoteMapForGracePeriod			= new Map<Id,Quote>();
        Map<Id, Quote>					statusAndQuoteMap_Approved		= new Map<Id, Quote>();
        Map<Id, Quote>					statusAndQuoteMap_Rejected		= new Map<Id, Quote>();
        Map<Id,Quote>					quoteMapForMaxItcCombo			= new Map<Id,Quote>();
        Map<Id, Quote>					priceNegotiationMap				= new Map<Id, Quote>();
        List<QuoteLineItem>				updateQLI						= new List<QuoteLineItem>();
        Set<Id>							quoteToMapPriceIds				= new Set<Id>();
        
        
        Set<Id>							quoteIds1						= new Set<Id>();
        List<String> 					postNegotiationStage 			= new List<String>{
            'Discount Approval', 'Quote Accept'};
                List<String> 			preNegotiationStage 			= new List<String>{
                    'Draft', 'In Quote Approvals', 'Document Generated', 
                        'Quote Sent', 'Integration Add On'};
                            List<Account> accountsToUpdate = new List<Account>();
        
        
        /**	BIBHU	Changes	**/
        CTX_UnSyncQuoteOpportunity.processOpportunityQuoteAndLineItemPostApproval(mapOfNewIdWithQuotes, mapOfOldIdWithQuotes);
        /**	BIBHU	Changes	**/
        
        for(Id quoteId : mapOfNewIdWithQuotes.keySet()){ 
            
            Quote 	newQuote 	= mapOfNewIdWithQuotes.get(quoteId);
            Quote	oldQuote	= mapOfOldIdWithQuotes.get(quoteId);
            
            
            if(
                newQuote.IsSyncing != oldQuote.IsSyncing &&
                newQuote.IsSyncing
            ){
                quoteToMapPriceIds.add(newQuote.Id);
            }
            
            system.debug('After Update - New IsSyncing: 	'+mapOfNewIdWithQuotes.get(quoteId).IsSyncing);
            system.debug('After Update - Old IsSyncing: 	'+mapOfOldIdWithQuotes.get(quoteId).IsSyncing);
            system.debug('After Update - New Status: 		'+mapOfNewIdWithQuotes.get(quoteId).Status);
            
            /**	Price Negotiation Filter : START	**/
            if(
                newQuote.Status != oldQuote.Status &&
                newQuote.Status == 'Price Negotiation' &&
                preNegotiationStage.contains(oldQuote.Status) && 
                !postNegotiationStage.contains(oldQuote.Status)
            ){
                System.debug('In Negotation Block');
                priceNegotiationMap.put( quoteId, newQuote );
            }	/**	Price Negotiation Filter : END	**/
            
            /**	Revoke Price Negotiation Logic : START	**/
            if(
                (
                    newQuote.IsSyncing != oldQuote.IsSyncing &&
                    !newQuote.IsSyncing &&
                    oldQuote.IsSyncing &&
                    newQuote.Status == 'Quote Sent' &&
                    postNegotiationStage.contains(oldQuote.Status)
                ) ||
                (
                    ( postNegotiationStage.contains(oldQuote.Status) || oldQuote.Status == 'Price Negotiation' )	&&
                    preNegotiationStage.contains(newQuote.Status)
                )
            ){
                system.debug('Ho Ho Ho Ho HO Ho ');
                quoteIds1.add(quoteId);
            }
            /**	Revoke Price Negotiation Logic : END	**/
            
            if( 
                mapOfNewIdWithQuotes.get(quoteId).Add_On_Approval_Status__c != mapOfOldIdWithQuotes.get(quoteId).Add_On_Approval_Status__c && 
                mapOfNewIdWithQuotes.get(quoteId).Add_On_Approval_Status__c == 'Approved'
            ){
                statusAndQuoteMap_Approved.put(quoteId, mapOfNewIdWithQuotes.get(quoteId));
            }
            
            if(
                mapOfNewIdWithQuotes.get(quoteId).Add_On_Approval_Status__c != mapOfOldIdWithQuotes.get(quoteId).Add_On_Approval_Status__c && 
                mapOfNewIdWithQuotes.get(quoteId).Add_On_Approval_Status__c == 'Rejected'
            ){
                statusAndQuoteMap_Rejected.put(quoteId, mapOfNewIdWithQuotes.get(quoteId));
            }
            
            if( 
                mapOfNewIdWithQuotes.get(quoteId).IsSyncing != mapOfOldIdWithQuotes.get(quoteId).IsSyncing && 
                mapOfNewIdWithQuotes.get(quoteId).IsSyncing 
            ){
                quoteIds.add(quoteId);
            }
            
            if( 
                mapOfNewIdWithQuotes.get(quoteId).IsSyncing != mapOfOldIdWithQuotes.get(quoteId).IsSyncing &&
                mapOfOldIdWithQuotes.get(quoteId).IsSyncing && !mapOfNewIdWithQuotes.get(quoteId).IsSyncing
            ){
                //quoteIds.add(quoteId);
            }
            
            /**	Start : bhaveshjindal : for QLI Date Grace Period Update	**/
            if(
                mapOfNewIdWithQuotes.get(quoteId).Enable_Grace_Period__c != mapOfOldIdWithQuotes.get(quoteId).Enable_Grace_Period__c
            ){
                quoteMapForGracePeriod.put(quoteId,mapOfNewIdWithQuotes.get(quoteId));   
            }
            if(
                mapOfNewIdWithQuotes.get(quoteId).Is_MAX_ITC_Combo_Required__c && mapOfNewIdWithQuotes.get(quoteId).Status != mapOfOldIdWithQuotes.get(quoteId).Status
            ){
                quoteMapForMaxItcCombo.put(quoteId,mapOfNewIdWithQuotes.get(quoteId));   
            }
            /**	End : bhaveshjindal : for QLI Date Grace Period Update	**/
            
            /**	Start : bhaveshjindal : for Quote Accept After MS Approval if Max Discount = 0	
if(
mapOfNewIdWithQuotes.get(quoteId).Approval_sub_status__c == 'MS Approval done' 
&& (mapOfNewIdWithQuotes.get(quoteId).Max_Discount__c == 0 
|| mapOfNewIdWithQuotes.get(quoteId).Max_Discount__c == NULL)
){
try{
mapOfNewIdWithQuotes.get(quoteId).Status = 'Quote Accept';
}catch(exception e){
System.debug('error on changing status after ms approval done : '+e.getMessage());
}

}
End : bhaveshjindal : for Quote Accept After MS Approval if Max Discount = 0	**/
            
            /* Added By Niraj : SAL-442 START */
            Quote newQuoteInstance = mapOfNewIdWithQuotes.get(quoteId);
            Quote oldQuoteInstance = mapOfOldIdWithQuotes.get(quoteId);
            
            if(
                (newQuoteInstance.IsSyncing && !oldQuoteInstance.IsSyncing) ||
                (newQuoteInstance.IsSyncing && 
                 (newQuoteInstance.No_of_GSTIN_one__c != oldQuoteInstance.No_of_GSTIN_one__c ||
                  newQuoteInstance.No_of_PAN_one__c != oldQuoteInstance.No_of_PAN_one__c ||
                  newQuoteInstance.Number_of_Sales_Invoices__c != oldQuoteInstance.Number_of_Sales_Invoices__c
                 )
                )
            )
            {
                accountsToUpdate.add(new Account(Id=newQuoteInstance.Account_ID__c, No_of_GSTIN__c=newQuoteInstance.No_of_GSTIN_one__c, No_of_PAN__c=newQuoteInstance.No_of_PAN_one__c, Number_of_Sales_Invoices__c=newQuoteInstance.Number_of_Sales_Invoices__c));  
            }
            /* Added By Niraj : SAL-442 END */
        }
        
        if( quoteIds1.size() > 0 ){
            for( 
                QuoteLineItem thisQLI : [ SELECT Id, UnitPrice, Combo_Discount_On_QLI__c, Is_Special_Price_Applicable__c, 
                                         Pre_Discount_Price__c, Is_Combo_Price_Applicable__c, Product_Formula__c,
                                         Threshold_List_Price_E__c, Threshold_Sale_Price_E__c
                                         FROM QuoteLineItem WHERE 
                                         QuoteId IN :quoteIds1 AND 
                                         Is_Combo_Price_Applicable__c = TRUE AND 
                                         Combo_Discount_On_QLI__c > 0 ]
            ){
                
                thisQLI.UnitPrice 						= thisQLI.Pre_Discount_Price__c;
                thisQLI.Combo_Discount_On_QLI__c 		= 0;
                thisQLI.Pre_Discount_Price__c 			= 0;
                thisQLI.Threshold_List_Price_E__c 		= NULL;
                thisQLI.Threshold_Sale_Price_E__c 		= NULL;
                
                thisQLI.Is_Combo_Price_Applicable__c 	= FALSE;
                thisQLI.Is_Special_Price_Applicable__c 	= FALSE;
                if( 
                    thisQLI.Product_Formula__c != NULL && 
                    thisQLI.Product_Formula__c != '' && 
                    thisQLI.Product_Formula__c != '0' 
                ){
                    thisQLI.Is_Formula_Price_Applicable__c 	= TRUE;
                } else{
                    thisQLI.Is_Formula_Price_Applicable__c 	= FALSE;
                }
                
                updateQLI.add(thisQLI);
            }
        }
        
        update updateQLI;
        
        
        /* Added By Niraj : SAL-442 START */	        
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
        /* Added By Niraj : SAL-442 END */
        
        
        
        if( quoteToMapPriceIds != NULL && quoteToMapPriceIds.size() > 0 ){
            
            
            List<QuoteLineItem> relatedQLIs = 
                [ SELECT Id, Auto_Renewal_Sale_Price__c, Sale_Price__c 
                FROM QuoteLineItem WHERE 
                QuoteId IN :quoteToMapPriceIds ];
            
            for( QuoteLineItem thisRec : relatedQLIs ){
                thisRec.Auto_Renewal_Sale_Price__c = thisRec.Sale_Price__c;
            }
            
            update relatedQLIs;
        }
        
        
        if(quoteMapForGracePeriod.keySet().size() > 0){
            QuoteTriggerHelper.addGracePeriod(quoteMapForGracePeriod);
        }
        if(quoteMapForMaxItcCombo.keySet().size() > 0){
            QuoteTriggerHelper.updateMaxItcComboPrice(quoteMapForMaxItcCombo);
        }
        
        
        /**	Old Code : START	**/
        if(quoteIds.size()>0){
            Map<Id,quoteLineItem> syncTheseValues = new Map<Id,QuoteLineItem>(
                [ SELECT Id FROM QuoteLineItem WHERE 
                 QuoteId IN: quoteIds ]
            );
            
            QuoteLineItemHelper.updateCustomFieldsToOppLineItem(syncTheseValues.keyset());
        }	/**	Old Code : END	**/
        
        if(statusAndQuoteMap_Approved.size() > 0 || statusAndQuoteMap_Rejected.size() > 0){
            CTX_AddOnDetailsClass.quoteApprovalProcessUpdates(statusAndQuoteMap_Approved, statusAndQuoteMap_Rejected);
        }         
        
        /**	Price Ne	**/
        CTX_ProductComboLogicImplementation.getQLIDetailsFromQuote(priceNegotiationMap);
        /**	Price Ne	**/
        
        QuoteTriggerHelper.submitForDiscountApproval(mapOfNewIdWithQuotes, mapOfOldIdWithQuotes);
    }
    
    public static void beforeDelete(List<Sobject> listOfOldSObjects,Map<Id,Sobject> mapOfOldSObjects){
        
        List<Quote> listOfQuoteOldRecords = (List<Quote>)listOfOldSObjects;
        for(Quote tempQuote : listOfQuoteOldRecords){
            if(tempQuote.Is_Primary_Quote__c){
                tempQuote.addError(System.Label.Primary_Quote_Error);
            }
        }
    }
    
    public static void afterDelete(Map<Id,Sobject> mapOfOldSObjects){}
    
    public static void afterUndelete(List<Sobject> listOfNewSObjects,Map<Id,Sobject> mapOfNewSObjects){
        
        List<Quote> listOfQuoteNewRecords = (List<Quote>)listOfNewSObjects;
        Map<Id,Id> opportunityIdwithQuoteId = new Map<Id,Id>();
        for(Quote tempQuote : listOfQuoteNewRecords){
            if(tempQuote.OpportunityId!=null && tempQuote.Is_Primary_Quote__c){
                //Pramodh Added for Making one Quote as Primary
                opportunityIdwithQuoteId.put(tempQuote.OpportunityId, tempQuote.Id);
                //Pramodh Ended for Making one Quote as Primary
            }
            
        }
        //Pramodh Added for Making one Quote as Primary
        if(opportunityIdwithQuoteId.size()>0){
            QuoteTriggerHelper.primaryCheck(opportunityIdwithQuoteId);
        }
        //Pramodh Ended for Making one Quote as Primary
    }
    
}