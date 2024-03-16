public class CTX_UnSyncQuoteOpportunity {
    
    @future
    public static void unSyncQuoteAndUpdateOpportunity( Set<Id> opportunityIds, Set<Id> QuoteIds ){
        
        List<Opportunity>	opportunityToUpdate = new List<Opportunity>();
        List<Quote> 		quoteToUpdate 		= new List<Quote>();
        
        for( Id oppId : opportunityIds ){
            opportunityToUpdate.add( new Opportunity(Id = oppId, SyncedQuoteId = NULL) );
        }
        
        for( Id quoteId : quoteIds ){ 
            quoteToUpdate.add( new Quote(Id = quoteId, Status = 'Discount Approval', Auto_Renewal_Discount_Approval_Stage__c = 'Pending', Approval_sub_status__c = NULL) );
        }
        
        if( opportunityToUpdate.size() > 0 && quoteToUpdate.size() > 0 ){
            
            update opportunityToUpdate;
            update quoteToUpdate;
            
            for( Quote thisRec : quoteToUpdate ){
                
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval automatically using Trigger');
                req1.setObjectId(thisRec.id);
                
                try{
                    Approval.ProcessResult result = Approval.process(req1);
                    Approval.lock(thisRec, true);
                }catch(exception e){
                    system.debug('Approval Process Exception: '+e.getMessage());
                }
            }
        }
        
        
    }
    
    public static void processOpportunityQuoteAndLineItemPostApproval( Map<Id, Quote> newQuoteMap, Map<Id, Quote> oldQuoteMap ){
        
        system.debug('processOpportunityQuoteAndLineItemPostApproval: ');
        Map<Id, Quote> 			quoteMap 		= new Map<Id, Quote>();
        Map<Id, Opportunity> 	opportunityMap 	= new Map<Id, Opportunity>();
        
        for( Quote thisRec : newQuoteMap.values() ){
            
            system.debug('thisRec.Auto_Renewal_Discount_Approval_Stage__c: '+thisRec.Auto_Renewal_Discount_Approval_Stage__c);
            system.debug('oldQuoteMap.get(thisRec.Id).Auto_Renewal_Discount_Approval_Stage__c: '+oldQuoteMap.get(thisRec.Id).Auto_Renewal_Discount_Approval_Stage__c);
            
            if( 
                thisRec.Auto_Renewal_Discount_Approval_Stage__c != oldQuoteMap.get(thisRec.Id).Auto_Renewal_Discount_Approval_Stage__c && 
                thisRec.Auto_Renewal_Discount_Approval_Stage__c ==  'Approved'
            ){
                system.debug('Inside - processOpportunityQuoteAndLineItemPostApproval: ');
                opportunityMap.put(thisRec.OpportunityId, new Opportunity(Id = thisRec.OpportunityId, SyncedQuoteId = thisRec.Id ));
                
                thisRec.Status = 'Quote Accept';
                quoteMap.put(thisRec.Id, thisRec);
            }
        }
        
        system.debug('Bibhu Testing this: '+opportunityMap);
        
        
        if( quoteMap != NULL && quoteMap.values().size() > 0 ){
            
            List<QuoteLineItem> relatedQLIs = [
                SELECT Id, Auto_Renewal_Sale_Price__c, Sale_Price__c 
                FROM QuoteLineItem WHERE 
                QuoteId IN :quoteMap.keySet()
            ];
            for( QuoteLineItem thisRec : relatedQLIs ){
                thisRec.Auto_Renewal_Sale_Price__c = thisRec.Sale_Price__c;
            }
            
            
            update opportunityMap.values();
            update quoteMap.values();
            
            
        }
        
        
    }
}