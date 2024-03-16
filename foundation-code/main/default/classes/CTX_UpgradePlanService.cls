@RestResource(urlMapping='/upgradePlan')
global class CTX_UpgradePlanService {
    
    @HttpPut
    global static void renewLicense(){
        
        RestRequest								request						= RestContext.request;
        String									requestBody					= request.requestBody.toString();
        Map<String, Object> 					planDetails					= (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        String									licenseId					= (String)planDetails.get('licenseId');
        String 									planTier					= (String)planDetails.get('planTier');
        String 									workspaceId 				= (String)planDetails.get('workspaceId');
        Date 									startDate 					= planDetails.get('startAt') != NULL ? (Date)date.parse( (String)planDetails.get('startAt') ) : NULL;
        Date 									endDate 					= planDetails.get('endAt') != NULL ? (Date)date.parse( (String)planDetails.get('endAt') ) : NULL;
        String 									type 						= 'QuoteLineItem';
        Map<String, Schema.SObjectType> 		schemaMap 					= Schema.getGlobalDescribe();
        Schema.SObjectType 						oppSchema					= schemaMap.get(type);
        Map<String, Schema.SObjectField> 		fieldMap					= oppSchema.getDescribe().fields.getMap();
        Map<String, Product_Info_Metadata__mdt>	productPlanTierInfoMap		= new Map<String, Product_Info_Metadata__mdt>();
        
        for( 
            Product_Info_Metadata__mdt thisRec : [ SELECT Id, MasterLabel, DeveloperName, Plan_Tier__c, Product_Id__c, Required_Fields__c 
                                                  FROM Product_Info_Metadata__mdt ] 
        ){
            productPlanTierInfoMap.put( thisRec.Plan_Tier__c, thisRec );
        }
        
        String									queryString					= ' SELECT '+ productPlanTierInfoMap.get(planTier).Required_Fields__c +' FROM QuoteLineItem WHERE Parent_Asset__r.License_Id__c =: licenseId ';
        system.debug('queryString Fields: '+productPlanTierInfoMap.get(planTier).Required_Fields__c);
        List<QuoteLineItem>						renewalQLIs 				= Database.query(queryString);
        QuoteLineItem 							upgradedQLI 				= renewalQLIs != NULL ? renewalQLIs[0].clone(FALSE, FALSE, FALSE, FALSE) : NULL;
        List<QuoteLineItem>						qlisToUpdate				= new List<QuoteLineItem>();        
        
        if( renewalQLIs.size() == 1 ){
            
            QuoteLineItem createUpgradedQuoteLineItem 			= renewalQLIs[0].clone(FALSE, FALSE, FALSE, FALSE);
            createUpgradedQuoteLineItem.Product2Id 				= productPlanTierInfoMap.get(planTier).Product_Id__c;
            createUpgradedQuoteLineItem.Total_Tax_Value__c 		= renewalQLIs[0].Total_Tax_Value_Recommended__c;
            createUpgradedQuoteLineItem.Total_Renewal_Price__c 	= renewalQLIs[0].Total_Renewal_Price_Recommended__c;
            createUpgradedQuoteLineItem.TDS_Price__c 			= renewalQLIs[0].TDS_Price_Recommended__c;
            
            if( createUpgradedQuoteLineItem.Recommended_Plan_Parameters__c != NULL ){
                        Map<String, Object> recommendedPriceAndPlanDetails	= (Map<String, Object>)JSON.deserializeUntyped(createUpgradedQuoteLineItem.Recommended_Plan_Parameters__c);
                        system.debug('recommendedPriceAndPlanDetails: '+recommendedPriceAndPlanDetails);
                        system.debug('Check Plan Tier: '+ recommendedPriceAndPlanDetails.containsKey('planTier') );
                        if( 
                            recommendedPriceAndPlanDetails != NULL && 
                            recommendedPriceAndPlanDetails.containsKey('planTier') &&
                            recommendedPriceAndPlanDetails.get('planTier') == createUpgradedQuoteLineItem.Recommended_Plan_Tier__c
                        ){
                            createUpgradedQuoteLineItem.put( 'No_of_PAN_one__c', (Decimal)recommendedPriceAndPlanDetails.get('No_of_PAN_one__c') );
                            createUpgradedQuoteLineItem.put( 'No_of_GSTIN_one__c', (Decimal)recommendedPriceAndPlanDetails.get('No_of_GSTIN_one__c') );
                            createUpgradedQuoteLineItem.put( 'Number_of_Purchase_Invoice__c', (Decimal)recommendedPriceAndPlanDetails.get('Number_of_Purchase_Invoice__c') );
                            createUpgradedQuoteLineItem.put( 'BtoB_Sales_one__c', (Decimal)recommendedPriceAndPlanDetails.get('BtoB_Sales_one__c') );
                            createUpgradedQuoteLineItem.put( 'BtoC_Sales_one__c', (Decimal)recommendedPriceAndPlanDetails.get('BtoC_Sales_one__c') );
                            createUpgradedQuoteLineItem.put( 'Period_Start_date__c', startDate);
                            createUpgradedQuoteLineItem.put( 'Period_End_date__c', endDate);
                            createUpgradedQuoteLineItem.put( 'Sale_Price__c', (Decimal)recommendedPriceAndPlanDetails.get('planPrice') );
                            createUpgradedQuoteLineItem.put( 'UnitPrice', (Decimal)recommendedPriceAndPlanDetails.get('planPrice') );
                            createUpgradedQuoteLineItem.put( 'Over_Usage_Charge__c', (Decimal)recommendedPriceAndPlanDetails.get('overusageCharge') );
                        }
                    }
            
            qlisToUpdate.add(createUpgradedQuoteLineItem);
        } else if( renewalQLIs.size() > 1 ){
            for( QuoteLineItem thisRec : renewalQLIs ){
                if( thisRec.Product2.Plan_Tier__c == planTier ){
                    
                    if( thisRec.Recommended_Plan_Parameters__c != NULL ){
                        Map<String, Object> recommendedPriceAndPlanDetails	= (Map<String, Object>)JSON.deserializeUntyped(thisRec.Recommended_Plan_Parameters__c);
                        system.debug('recommendedPriceAndPlanDetails: '+recommendedPriceAndPlanDetails);
                        system.debug('Check Plan Tier: '+ recommendedPriceAndPlanDetails.containsKey('planTier') );
                        if( 
                            recommendedPriceAndPlanDetails != NULL && 
                            recommendedPriceAndPlanDetails.containsKey('planTier') &&
                            recommendedPriceAndPlanDetails.get('planTier') == thisRec.Recommended_Plan_Tier__c
                        ){
                            thisRec.put( 'No_of_PAN_one__c', (Decimal)recommendedPriceAndPlanDetails.get('No_of_PAN_one__c') );
                            thisRec.put( 'No_of_GSTIN_one__c', (Decimal)recommendedPriceAndPlanDetails.get('No_of_GSTIN_one__c') );
                            thisRec.put( 'No_of_User_ID_one__c', (Decimal)recommendedPriceAndPlanDetails.get('No_of_User_ID_one__c') );
                            thisRec.put( 'Total_no_of_Pages_in_Purchase_Invoices__c', (Decimal)recommendedPriceAndPlanDetails.get('Total_no_of_Pages_in_Purchase_Invoices__c') );
                            thisRec.put( 'BtoB_Sales_one__c', (Decimal)recommendedPriceAndPlanDetails.get('BtoB_Sales_one__c') );
                            thisRec.put( 'BtoC_Sales_one__c', (Decimal)recommendedPriceAndPlanDetails.get('BtoC_Sales_one__c') );
                            thisRec.put( 'Period_Start_date__c', startDate);
                            thisRec.put( 'Period_End_date__c', endDate);
                            thisRec.put( 'Sale_Price__c', (Decimal)recommendedPriceAndPlanDetails.get('planPrice') );
                            /**	thisRec.put( 'TotalPrice', (Decimal)recommendedPriceAndPlanDetails.get('planPrice') );	**/
                            thisRec.put( 'UnitPrice', (Decimal)recommendedPriceAndPlanDetails.get('planPrice') );
                            thisRec.put( 'Over_Usage_Charge__c', (Decimal)recommendedPriceAndPlanDetails.get('overusageCharge') );

                        }
                    }
                    
                    qlisToUpdate.add(thisRec);
                } else{
                    
                }
            }
        } else{
            /**	No Action to Taken, Will not come in any usecase	**/
        }
        
        if( qlisToUpdate.size() > 0 ){
            
            OpportunityConstants.AUTO_RENEW_RULE = FALSE;
            upsert qlisToUpdate;
            OpportunityConstants.AUTO_RENEW_RULE = TRUE;
        }
        system.debug('request.requestBody: '+request.requestBody.toString());
        
    }
    
    
}