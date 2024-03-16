/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-16-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class IdentityItemHelper {
    
    public static List<QuoteLineItem> QuoteLineIdentityCostUpdates(Map<Id,QuoteLineItem> mapOfNewIdWithQuotesLineItems,Map<Id,QuoteLineItem> mapOfOldIdWithQuotesLineItems){
        
        List<QuoteLineItem> newQuoteLineIteamObj = New List<QuoteLineItem>();// added by Murali
        List<QuoteLineItem> objectsToReturn = New List<QuoteLineItem>();// added by Murali
        set<Id> quoteIds = New set<Id>();// added by Murali
        set<Id> productIds = New set<Id>();// added by Murali
        List<String> fieldListidentity = new List<String>();// added by Murali
        
        Schema.FieldSet fdlstForIdentity = Schema.SObjectType.QuoteLineItem.fieldSets.getMap().get('Identity_Related_Fields');     
        system.debug('****fdlstForIdentity-->'+fdlstForIdentity);        
        
        if(!fdlstForIdentity.getFields().isEmpty()){
            for(Schema.FieldSetMember fd : fdlstForIdentity.getFields()){
                fieldListidentity.add(String.valueOf(fd.getSobjectfield()));
            }
        }
        system.debug('****fieldListidentity-->'+fieldListidentity);
        
        for(QuoteLineItem thisNewQLI : mapOfNewIdWithQuotesLineItems.values()){
            quoteIds.add(thisNewQLI.QuoteId);    
            productIds.add(thisNewQLI.Product2Id);  
        }
        
        system.debug('product idss'+productIds);
        system.debug('quoteIds idss'+quoteIds);
        Map<Id,Product2> productMapforIdentity = new Map<Id,Product2>([SELECT id,name FROM product2 where id in : productIds]);
        Map<Id,Quote > quoteMapforIdentity = new Map<Id,Quote >([SELECT id,name FROM Quote  where id in : quoteIds]);
        
        for(QuoteLineItem thisNewQLI : mapOfNewIdWithQuotesLineItems.values()){
            if( productMapforIdentity.get(thisNewQLI.Product2Id).name == 'Clear Identity (ARR)' ){
                
                system.debug('New: '+mapOfNewIdWithQuotesLineItems.get(thisNewQLI.Id).Identity_Resource_Metadata__c);
                system.debug('Old: '+mapOfOldIdWithQuotesLineItems.get(thisNewQLI.Id).Identity_Resource_Metadata__c );
                
                if( 
                    mapOfNewIdWithQuotesLineItems.get(thisNewQLI.Id).Identity_Resource_Metadata__c 
                    != mapOfOldIdWithQuotesLineItems.get(thisNewQLI.Id).Identity_Resource_Metadata__c  
                ){ 
                    system.debug('Inside site change');
                    newQuoteLineIteamObj.add(thisNewQLI);
                }
            } 
        }
        system.debug('newQuoteLineIteamObj'+newQuoteLineIteamObj);
        
        if(newQuoteLineIteamObj!=null && newQuoteLineIteamObj.size()>0){
            
            for(QuoteLineItem thisNewQLI : newQuoteLineIteamObj){
                QuoteLineItem newQLIRecord = thisNewQLI.clone(FALSE, FALSE, FALSE, FALSE);
                system.debug('CTX_LicensingConstants.IDENTITY_RESOURCE_CONSTRAINTS_FOR_QUOTE '+CTX_LicensingConstants.IDENTITY_RESOURCE_CONSTRAINTS_FOR_QUOTE);
                system.debug('Identity_Resource_Metadata__c in helper '+thisNewQLI.Identity_Resource_Metadata__c);
                CTX_ClearResourceConstraintsClass.ReturnWrapper resourceDetailsWrapper = CTX_ClearResourceConstraintsClass.identityResourceConstraintsForQuoteLineItem(thisNewQLI.Identity_Resource_Metadata__c);
                newQLIRecord.Id = thisNewQLI.Id;
                
                system.debug('resourceDetailsWrapper.identityResource: '+resourceDetailsWrapper.identityResource);
                Map<String, Object> resourceDetails = (Map<String, Object>)JSON.deserializeUntyped(resourceDetailsWrapper.identityResource);
                system.debug('resourceDetails: '+resourceDetails);
               
                Set<String> objectFields = Schema.SObjectType.QuoteLineItem.fields.getMap().keySet();
				system.debug('objectFields'+objectFields);
                system.debug('objectFields contains No_of_MSME_API__c'+objectFields.contains('no_of_msme_api__c'));
                system.debug('objectFields contains'+objectFields.contains('applicable_tds__c'));
                for( String thisSTR : resourceDetails.keySet() ){
                    system.debug('before trim: '+thisSTR);
                  //  thisSTR = thisSTR.trim(); str.deleteWhitespace()
                    String getStr = thisSTR.deleteWhitespace();
                   // String getStr = thisSTR;
                    system.debug('after trim: '+getStr);
                    system.debug('after trim: '+getStr.toLowerCase());
                    system.debug('get trim: '+(Integer)resourceDetails.get(getStr));
                    system.debug('objectFields.contains(getStr)'+objectFields.contains(getStr));
                 	if(objectFields.contains(getStr.toLowerCase())) {
                        system.debug('inside if');
  						newQLIRecord.put( getStr, (Integer)resourceDetails.get(thisSTR) );
                	}
                }
                
                newQLIRecord.Identity_Resource_Constraints__c = resourceDetailsWrapper.identityResource;
                system.debug('Stringified data identityData: '+newQLIRecord.Identity_Resource_Constraints__c);
                newQLIRecord.UnitPrice = resourceDetailsWrapper.totalListPrice;
                newQLIRecord.Sale_Price__c = resourceDetailsWrapper.totalSellPrice;
                newQLIRecord.Total_cost_price_Identity__c = resourceDetailsWrapper.totalCostPrice;
                
                system.debug('No_of_MSME_API__c: '+newQLIRecord.No_of_MSME_API__c);
                objectsToReturn.add(newQLIRecord);
                
            }
        }
        
        return objectsToReturn;
    }
}