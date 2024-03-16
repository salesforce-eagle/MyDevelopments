public class OpportunityService {
    
    @InvocableMethod(label='CloneOpportunity' description='This Methdos helps to Clone the Opportunity Record')
    public static void cloneOpportunity(List<Id> listOfOpportunityIds){
        List<Opportunity> listOfClonedOpportunites=new List<Opportunity>();
        Map<id,Opportunity> mapOfOpportunites=new OpportunitySelector().getOpportunityById(new Set<Id>(listOfOpportunityIds));
        Map<Id,Opportunity> mapOfClonedOpportunites=new Map<Id,Opportunity>();
        
        if(!mapOfOpportunites.isEmpty()){
            for(Opportunity opportunityInstance:mapOfOpportunites.Values()){
                if(opportunityInstance.StageName == OpportunityConstants.STAGENAME_CLOSED_LOST){
                    Opportunity opportunityCopy = opportunityInstance.clone(false,true);
                    opportunityCopy.StageName=OpportunityConstants.STAGENAME_SQL;
                    if(!mapOfClonedOpportunites.containsKey(opportunityInstance.Id)){
                        mapOfClonedOpportunites.put(opportunityInstance.Id,opportunityCopy);
                    }
                }
            }
        }
        
        if(!mapOfClonedOpportunites.isEmpty()){ 
            new OpportunityService().insertOpportunity(mapOfClonedOpportunites.Values(),'');
        }
        
        Set<Id> setOfOpportunityIds=new Set<Id>(mapOfClonedOpportunites.keySet());
        Map<Id,Quote> mapOfClonedQuotes=new Map<Id,Quote>();
        Map<Id,Quote> mapOfIdWithQuotes=new Map<Id,Quote>((List<Quote>)DataBase.query(UtilityClass.getQueryString('Quote')+' FROM Quote WHERE OpportunityId =: setOfOpportunityIds AND IsSyncing=true'));
        
        for(Quote quoteInstance:mapOfIdWithQuotes.Values()){
            Quote quiteCopy = quoteInstance.clone(false,true);
            quiteCopy.Status = QuoteConstants.STATUS_DRAFT;
            if(mapOfClonedOpportunites.containsKey(quoteInstance.OpportunityId)){
                quiteCopy.OpportunityId= mapOfClonedOpportunites.get(quoteInstance.OpportunityId).Id;
            }
            //quiteCopy.StageName=OpportunityConstants.STAGENAME_RENEWAL_INITIATED;
            if(!mapOfClonedQuotes.containsKey(quoteInstance.Id)){
                mapOfClonedQuotes.put(quoteInstance.Id,quiteCopy);
            }
        }
        
        
        if(mapOfClonedQuotes.Values().size()>0){
            insert mapOfClonedQuotes.values();
        }
        
        Set<Id> setOfQuoteIds=new Set<Id>(mapOfIdWithQuotes.keySet());
        Map<Id,QuoteLineItem> mapOfClonedQuoteLineItems=new  Map<Id,QuoteLineItem>();
        Map<Id,QuoteLineItem> mapOfQuoteLineItems=new Map<Id,QuoteLineItem>((List<QuoteLineItem>)DataBase.query(UtilityClass.getQueryString('QuoteLineItem')+' FROM QuoteLineItem WHERE QuoteId =: setOfQuoteIds'));
        
        for(QuoteLineItem quotelineItemInstance:mapOfQuoteLineItems.Values()){
            QuoteLineItem quiteLineItemCopy=quotelineItemInstance.Clone(false,true);
            if( mapOfClonedQuotes.containsKey(quotelineItemInstance.QuoteId)){
                quiteLineItemCopy.QuoteId= mapOfClonedQuotes.get(quotelineItemInstance.QuoteId).Id;
            }
            
            if(!mapOfClonedQuoteLineItems.containsKey(quotelineItemInstance.QuoteId)){
                mapOfClonedQuoteLineItems.put(quotelineItemInstance.QuoteId,quiteLineItemCopy);
            }
        }
        
        if(!mapOfClonedQuoteLineItems.isEmpty()){
            insert mapOfClonedQuoteLineItems.Values();
        }
        
        /*
         * for(Opportunity opportunityInstance:mapOfIdWithOpportunites.Values()){
            Opportunity opportunityCopy = opportunityInstance.clone(false,true);
            opportunityCopy.StageName=OpportunityConstants.STAGENAME_RENEWAL_INITIATED;
            opportunityCopy.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OpportunityConstants.RECORDTYPENAME_RENEWAL).getRecordTypeId();
            if(!mapOfClonedOpportunites.containsKey(opportunityInstance.Id)){
                mapOfClonedOpportunites.put(opportunityInstance.Id,opportunityCopy);
            }
        } 
        
        if(!mapOfClonedOpportunites.isEmpty()){
            new OpportunityService().insertOpportunity(mapOfClonedOpportunites.values(),'');
        }
        
        
        Set<Id> setOfOpportunityIds=new Set<Id>(mapOfIdWithOpportunites.keySet());
        Map<Id,Quote> mapOfClonedQuotes=new Map<Id,Quote>();
        Map<Id,Quote> mapOfIdWithQuotes=new Map<Id,Quote>((List<Quote>)DataBase.query(UtilityClass.getQueryString('Quote')+' FROM Quote WHERE OpportunityId =: setOfOpportunityIds AND IsSyncing=true'));
        
        for(Quote quoteInstance:mapOfIdWithQuotes.Values()){
            Quote quiteCopy = quoteInstance.clone(false,true);
            if(mapOfClonedOpportunites.containsKey(quoteInstance.OpportunityId)){
                quiteCopy.OpportunityId= mapOfClonedOpportunites.get(quoteInstance.OpportunityId).Id;
            }
            //quiteCopy.StageName=OpportunityConstants.STAGENAME_RENEWAL_INITIATED;
            if(!mapOfClonedQuotes.containsKey(quoteInstance.Id)){
                mapOfClonedQuotes.put(quoteInstance.Id,quiteCopy);
            }
        }
        
        
        if(mapOfClonedQuotes.Values().size()>0){
            insert mapOfClonedQuotes.values();
        }
        
        Set<Id> setOfQuoteIds=new Set<Id>(mapOfIdWithQuotes.keySet());
        Map<Id,QuoteLineItem> mapOfClonedQuoteLineItems=new  Map<Id,QuoteLineItem>();
        Map<Id,QuoteLineItem> mapOfQuoteLineItems=new Map<Id,QuoteLineItem>((List<QuoteLineItem>)DataBase.query(UtilityClass.getQueryString('QuoteLineItem')+' FROM QuoteLineItem WHERE QuoteId =: setOfQuoteIds'));
        
        for(QuoteLineItem quotelineItemInstance:mapOfQuoteLineItems.Values()){
            QuoteLineItem quiteLineItemCopy=quotelineItemInstance.Clone(false,true);
            if( mapOfClonedQuotes.containsKey(quotelineItemInstance.QuoteId)){
                quiteLineItemCopy.QuoteId= mapOfClonedQuotes.get(quotelineItemInstance.QuoteId).Id;
            }
            
            if(!mapOfClonedQuoteLineItems.containsKey(quotelineItemInstance.QuoteId)){
                mapOfClonedQuoteLineItems.put(quotelineItemInstance.QuoteId,quiteLineItemCopy);
            }
        }
        
        if(!mapOfClonedQuoteLineItems.isEmpty()){
            insert mapOfClonedQuoteLineItems.Values();
        }
			*/
        
       
    }
    
    
    
    public void insertOpportunity(List<Opportunity> listOfOpportunites,String callingFrom){
        if(listOfOpportunites.size()>0){
            try{
                List<Database.SaveResult> resultAfterInster=database.insert(listOfOpportunites, true);
             }catch(Exception e){

                System.debug('<------Exception on Opportunity Insert ------> '+e.getMessage()+' line Number '+e.getLineNumber());
            }
        }
        
    }
}