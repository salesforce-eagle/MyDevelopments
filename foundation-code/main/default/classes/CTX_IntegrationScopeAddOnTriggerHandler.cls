Public Class CTX_IntegrationScopeAddOnTriggerHandler IMPLEMENTS TriggerInterface{
    
    public static void beforeInsert(List<Sobject> listOfNewSObjects){}
    
    public static void afterInsert(List<Sobject> listOfNewSObjects,Map<Id,Sobject> mapOfNewSObjects){}
    
    public static void beforeUpdate(Map<Id,Sobject> mapOfNewSObjects,Map<Id,Sobject> mapOfOldSObjects){}
    
    public static void afterUpdate(Map<Id,Sobject> mapOfNewSObjects,Map<Id,Sobject> mapOfOldSObjects){}
    
    public static void beforeDelete(List<Sobject> listOfOldSObjects,Map<Id,Sobject> mapOfOldSObjects){}
    
    public static void afterDelete(Map<Id,Sobject> mapOfOldSObjects){
        
        System.debug('After Delete Trigger for ISAO');
        Map<Id, Integration_Scope_Add_On__c> oldIntegrationScopeMap = (Map<Id, Integration_Scope_Add_On__c>)mapOfOldSObjects;
        
        System.debug('After Delete Trigger for ISAO : '+oldIntegrationScopeMap.keySet());
        Map<String, Set<Integration_Scope_Add_On__c>> 	erpSKUIntegrationScopeMap 	= new Map<String, Set<Integration_Scope_Add_On__c>>();
        Map<Id, sObject>								quoteLineItemAndISAList		= new Map<Id, sObject>();        
        Set<Id>											quoteIds					= new Set<Id>();
        
        for(Integration_Scope_Add_On__c thisRec : oldIntegrationScopeMap.values()){
            
            if(thisRec.Add_On_Status__c == 'Approved'){
                String tempString = thisRec.ERP_Family__c + thisRec.Product_SKU__c;
                quoteIds.add(thisRec.Related_Quote__c);
                if(erpSKUIntegrationScopeMap.containsKey(tempString)){
                    erpSKUIntegrationScopeMap.get(tempString).add(thisRec);
                } else{
                    erpSKUIntegrationScopeMap.put(tempString, new Set<Integration_Scope_Add_On__c>{thisRec});
                }
            }
        }
        system.debug('erpSKUIntegrationScopeMap Integration_Scope_Add_On__c CTX_IntegrationScopeAddOnTriggerHandler: '+erpSKUIntegrationScopeMap);
        
        for(
            QuoteLineItem thisRec : [  SELECT Id, UnitPrice, Sale_Price__c, Add_On_Prices__c, Add_On_Discounted_Price__c, 
                                     Actual_Unit_Price__c, Actual_Sell_Price__c, Product2.OrderForm_Product_Name__c, 
                                     Quote.OpportunityId, Quote.Opportunity.ERP_Family__c, 
                                     Quote.Opportunity.Owner.ManagerId
                                     
                                     FROM QuoteLineItem WHERE QuoteId IN :quoteIds ]
        ){
            String tempString = thisRec.Quote.Opportunity.ERP_Family__c + thisRec.Product2.OrderForm_Product_Name__c;
            if(erpSKUIntegrationScopeMap.containsKey(tempString)){
                
                for( Integration_Scope_Add_On__c thisOne : erpSKUIntegrationScopeMap.get(tempString) ){
                    if(thisOne.Related_Opportunity__c == thisRec.Quote.OpportunityId){
                        
                        system.debug('Inside QLI List');
                        thisRec.Add_On_Prices__c			= thisRec.Add_On_Prices__c - thisOne.List_Price__c;
                        thisRec.Add_On_Discounted_Price__c	= thisRec.Add_On_Discounted_Price__c - thisOne.Discount_Rate__c;
                        
                        thisRec.UnitPrice 					= thisRec.UnitPrice - thisOne.List_Price__c;
                        thisRec.Sale_Price__c 				= thisRec.Sale_Price__c - thisOne.Discount_Rate__c;
                        
                        quoteLineItemAndISAList.put(thisRec.Id, thisRec);
                    } 
                }
                system.debug('quoteLineItemAndISAList QuoteLineItem erpSKUIntegrationScopeMap: '+quoteLineItemAndISAList);
            }
        }
        
        update quoteLineItemAndISAList.values();
    }
    
    public static void afterUndelete(List<Sobject> listOfNewSObjects,Map<Id,Sobject> mapOfNewSObjects){}
}