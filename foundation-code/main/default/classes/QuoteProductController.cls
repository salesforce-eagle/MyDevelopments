/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-05-2021
 * @last modified by  : pramodh@warpdrivetech.in
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-07-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class QuoteProductController {
    @AuraEnabled(cacheable=true)
    Public static List<Product2> getProductList(String quoteId){
       system.debug('GFGF'+quoteId); 
       Quote quoteIns = [select id,opportunity.Country_Of_Origin__c,opportunity.recordType.DeveloperName, opportunity.ClearTax_Billing_Entity__c from quote where id =:quoteId AND 
                         quote.Approval_sub_status__c != 'Discount Approval in progress' AND quote.Status NOT IN ('Discount Approval','Quote Accept')];
        system.debug('GFGF'+quoteIns);
        List<Product2> listOfProducts = new List<Product2>();
        //Added for Net New Id filter - By Kartikeya
         if(quoteIns.opportunity.ClearTax_Billing_Entity__c == 'Defmacro' || quoteIns.opportunity.ClearTax_Billing_Entity__c ==	'KSA Branch of Defmacro' || quoteIns.opportunity.ClearTax_Billing_Entity__c == NULL){
         listOfProducts = [select Id,Name,Product_category__c,Family,ProductCode,Record_Type_Product_Visibility__c from Product2 where IsActive =true and country_of_origin__c INCLUDES (:quoteIns.opportunity.Country_Of_Origin__c) 
                           and (
                               (Record_Type_Product_Visibility__c != '' and Record_Type_Product_Visibility__c INCLUDES (:quoteIns.opportunity.ClearTax_Billing_Entity__c))
                               OR
                               (Record_Type_Product_Visibility__c = '')
                           )];
         }else{
             listOfProducts = [select Id,Name,Product_category__c,Family,ProductCode,Record_Type_Product_Visibility__c from Product2 where IsActive =true and country_of_origin__c INCLUDES (:quoteIns.opportunity.Country_Of_Origin__c) 
                           and (
                               (Record_Type_Product_Visibility__c != '' and Record_Type_Product_Visibility__c INCLUDES (:quoteIns.opportunity.ClearTax_Billing_Entity__c))
                             
                           )];
             
         }
        /*else if(quoteIns.opportunity.recordType.DeveloperName.equals(OpportunityConstants.RECORDTYPE_NET_NEW_CIMPLIFIVE)){
            listOfProducts = [select Id,Name,Product_category__c,Family,ProductCode,Record_Type_Product_Visibility__c from Product2 where IsActive =true and country_of_origin__c INCLUDES (:quoteIns.opportunity.Country_Of_Origin__c) 
                              and (Record_Type_Product_Visibility__c != '' and Record_Type_Product_Visibility__c INCLUDES (:quoteIns.opportunity.recordType.DeveloperName))];
        }
        else{
        listOfProducts = [select Id,Name,Product_category__c,Family,ProductCode,Record_Type_Product_Visibility__c from Product2 where IsActive =true and country_of_origin__c INCLUDES (:quoteIns.opportunity.Country_Of_Origin__c)
                         and (
                               (Record_Type_Product_Visibility__c != '' and Record_Type_Product_Visibility__c INCLUDES (:quoteIns.opportunity.recordType.DeveloperName))
                               OR
                               (Record_Type_Product_Visibility__c = '')
                         )];
        }*/
        return listOfProducts;
    }
    @AuraEnabled
    Public static List<Id> saveQuoteProducts(List<String> productIds, String quoteId){
        List<QuoteLineItem> insertQuoteLineItems = new List<QuoteLineItem>();
        List<Id> insertedQLI = new List<Id>();
        for(string tempProductId : productIds){
            insertQuoteLineItems.add(new QuoteLineItem(QuoteId = quoteId, Product2Id = tempProductId, Quantity = 1, UnitPrice =100)); //renu added
        }
        Database.Saveresult [] dsResult = database.insert(insertQuoteLineItems,true);
        for(Database.Saveresult res : dsResult){
            if(res.isSuccess()){
                insertedQLI.add(res.getId());
            }
        }
        return insertedQLI;
    }
    
    @AuraEnabled(cacheable=true)
    Public static List<QLIWrapper> getQuoteLineItemList( String quoteId){
        List<QuoteLineItem> getInsertedLineItems = new List<QuoteLineItem>();
        Map<String, String> ProductCategoryDisplayFieldsMap = new Map<String, String>();
        for(QLI_Editor_Product_Category_Fields_Map__mdt mdt : [SELECT Id, Display_Fields__c, Product_Category__c FROM QLI_Editor_Product_Category_Fields_Map__mdt]){
            ProductCategoryDisplayFieldsMap.put(mdt.Product_Category__c, mdt.Display_Fields__c);
        }
        List<QLIWrapper> qliList = new List<QLIWrapper>();
        for(QuoteLineItem qli : [SELECT Id, Product2.Name, Product2.Product_category__c from QuoteLineItem WHERE
                                quoteId =: quoteId AND 
                                quote.Approval_sub_status__c != 'Discount Approval in progress' AND quote.Status NOT IN ('Discount Approval','Quote Accept') ORDER BY CreatedDate DESC
                                ])
        {
            QLIWrapper qliWrapInstance = new QLIWrapper();
            qliWrapInstance.recordId = qli.Id;
            qliWrapInstance.productName = qli.Product2.Name;
            qliWrapInstance.fields = ProductCategoryDisplayFieldsMap.get(qli.Product2.Product_category__c).split(',');
            qliList.add(qliWrapInstance);
        }
        system.debug('getQuoteLineItemList : qliList :: '+qliList);
        return qliList;
    }
    
    public class QLIWrapper {
        @AuraEnabled
        public Id recordId {get;set;}
        @AuraEnabled
        public String productName {get;set;}
        @AuraEnabled
        public List<String> fields {get;set;}
    }
    
    @AuraEnabled(cacheable=true)
    Public static List<Product2> getProducts(String quoteId){
        Set<String> productName	= new Set<String>();
        
        for(QuoteLineItem qli : [SELECT Id, Product2.Name, Product2.Product_category__c, Product2.ProductCode from QuoteLineItem WHERE
                                quoteId =: quoteId])
        {
            productName.add(qli.Product2.Name);
        }
            
        
        List<Product2> productList	= new List<Product2>
            (
                [ SELECT Id, Name, ProductCode, Plan_Allowance_GSTIN__c, Plan_Allowance_IRN__c, Plan_Allowance_PAN__c, 
                 Plan_Topup_Threshold_GSTIN__c, Plan_Topup_Threshold_IRN__c, Plan_Topup_Threshold_PAN__c,
                 Is_Standard__c , Plan_Allowance_GSTIN_Verification__c
                 FROM Product2
                 WHERE  Name IN :productName AND Is_Standard__c = true]
            ); 
        
        System.debug('productList-->'+productList);
        return productList;
    }
}