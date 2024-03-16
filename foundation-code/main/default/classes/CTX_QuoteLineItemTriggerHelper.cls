/**
* @File Name          : CTX_QuoteLineItemTriggerHelper.cls
* @Description        : 
* @Author             : archana.kumari@cleartax.com
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 02-06-2024
* @Modification Log   : 
* Ver       Date            Author                    Modification
* 1.0    02/14/2020   archana.kumari@cleartax.com     Initial Version
**/

public class CTX_QuoteLineItemTriggerHelper {
    /**
* @description
* @author archana.kumari@cleartax.com | 02/14/2020
* @param List<Quote> updateQuotesForIntegrationQuoteLineItem
* @return void
*/
    public static void updateQuotesForIntegrationQuoteLineItem(set<Id> setOfQuoteIdsToBeUpdated,boolean setTrueOrFalseForIntegration){
        List<Quote> quoteTobeUpdatedList=new List<Quote>();
        system.debug('updateQuotesForIntegrationQuoteLineItem setOfQuoteIdsToBeUpdated'+setOfQuoteIdsToBeUpdated);
        for(Id quoteInstanceID:setOfQuoteIdsToBeUpdated){
            Quote quoteToBeupdated=new Quote();
            quoteToBeupdated.ID=quoteInstanceID;
            quoteToBeupdated.Has_Integration_QLI__c=setTrueOrFalseForIntegration;
            quoteTobeUpdatedList.add(quoteToBeupdated);
        }
        IF(!quoteTobeUpdatedList.isEmpty()){
            system.debug('updateQuotesForIntegrationQuoteLineItem'+quoteTobeUpdatedList);
            try{
                update quoteTobeUpdatedList ;
            }catch(exception e){
                System.debug('Error :: updateQuotesForIntegrationQuoteLineItem :: '+e.getMessage());
            }
            
        }
    }
    
    //Bhavesh : To Update Product Formula For GCC Renewal QLIs
    public static void updateProductFormulaFOrListProceForGccQLI(Map<Id,QuoteLineItem> quoteLineItemMap){
        Map<Id, QuoteLineItem> qliMapQueried = new Map<Id, QuoteLineItem>([SELECT Id, Quote.Country_Of_Origin__c,
                                                                           Quote.Opportunity_Record_Type__c,
                                                                           Parent_Asset__r.Price 
                                                                           FROM QuoteLineItem 
                                                                           WHERE Id IN :quoteLineItemMap.keySet()
                                                                          ]);
        for(QuoteLineItem thisQLI : quoteLineItemMap.Values()){
            
            if( 
                qliMapQueried.containsKey(thisQLI.Id) && 
                qliMapQueried.get(thisQLI.Id).Quote.Opportunity_Record_Type__c != NULL && 
                qliMapQueried.get(thisQLI.Id).Quote.Country_Of_Origin__c != NULL && 
                qliMapQueried.get(thisQLI.Id).Quote.Opportunity_Record_Type__c.Contains('Renewal') && 
                thisQLI.Parent_Asset__c != NULL 
            ){
                if( 
                    qliMapQueried.get(thisQLI.Id).Quote.Country_Of_Origin__c == 'Saudi Arabia' ||
                    qliMapQueried.get(thisQLI.Id).Quote.Country_Of_Origin__c == 'GCC' 
                ){
                    if( qliMapQueried.get(thisQLI.Id).Parent_Asset__r.Price != NULL && qliMapQueried.get(thisQLI.Id).Parent_Asset__r.Price != 0 ){
                        thisQLI.Product_Formula__c = String.ValueOf(qliMapQueried.get(thisQLI.Id).Parent_Asset__r.Price + qliMapQueried.get(thisQLI.Id).Parent_Asset__r.Price*0.1);
                        thisQLI.Is_Formula_Price_Applicable__c = TRUE;
                    } else{
                        thisQLI.Product_Formula__c = '0';
                        thisQLI.Is_Formula_Price_Applicable__c = TRUE;
                    }
                    
                }
            }
            
        }
    }
    
    
}