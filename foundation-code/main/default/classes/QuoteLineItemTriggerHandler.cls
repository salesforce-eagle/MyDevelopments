/**
* @description       : 
* @author            : pramodh@warpdrivetech.in
* @group             : 
* @last modified on  : 03-13-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                     Modification
* 1.0   01-18-2021   pramodh@warpdrivetech.in   Initial Version
**/
public class QuoteLineItemTriggerHandler implements TriggerInterface {
    
    public static void beforeInsert( List<Sobject> listOfNewSObjects ){
        
        QuoteConstants.DISABLEQLIVAl = TRUE;
        
        List<QuoteLineItem>		listOfNewQuotes						= (List<QuoteLineItem>)listOfNewSObjects;
        Map<Id, String>			quoteIdAndERP						= new Map<Id, String>();
        Map<Id, String>			productAndSKU						= new Map<Id, String>();
        List<String> 			typeOfIntegCategoryValues 			= new List<String>();
        Map<Id, Product2>   	productMap 							= new Map<Id, Product2>();
        Map<Id,AggregateResult> productPriceMap 					
            = new Map<Id,AggregateResult>(
                [ SELECT MAX(product2id) Id, id PBId 
                 FROM PriceBookEntry Group By Id]
            );	/**	Pricing Calculator	: Kartikeya	**/
        
        List<String>				quoteStatusList = new List<String>{ 'Price Negotiation', 'Discount Approval', 'Quote Accept' };
            /** Type of integration restriction - Ashwin : START  **/
            Schema.DescribeFieldResult	picklistValues 	= QuoteLineItem.Type_of_integration_category__c.getDescribe();
        Schema.SObjectField 		field 			= picklistValues.getSObjectField();
        List<Schema.PicklistEntry> 	optionValues 	= field.getDescribe().getPicklistValues();
        Map<Id, String>				quoteIdStatusMap= new Map<Id, String>();     
        Map<Id, Quote>				quoteMap        = new Map<Id, Quote>(); 
        
        for(Schema.PicklistEntry thisRec : optionValues){
            typeOfIntegCategoryValues.add(thisRec.getLabel());
        }	/**	Type of integration restriction - Ashwin : END	**/
        
        for(QuoteLineItem thisRec : listOfNewQuotes){
            thisRec=quoteLineItemPricingCalculator.productPriceCalculator(thisRec);
            quoteIdAndERP.put(thisRec.QuoteId, 		NULL);
            productAndSKU.put(thisRec.Product2Id, 	NULL);
            quoteIdStatusMap.put(thisRec.QuoteId, NULL);
            thisRec.Identity_Resource_Metadata__c = CTX_LicensingConstants.IDENTITY_RESOURCE_CONSTRAINTS_FOR_QUOTE;//added by Murali
            thisRec.Identity_Resource_Constraints__c = CTX_LicensingConstants.IDENTITY_FINAL_RESOURCE_DETAILS_BY_COUNT;
            system.debug('Identity_Resource_Metadata__c '+thisRec.Identity_Resource_Metadata__c);
            
        }
        
        for(
            Quote thisRec : [ SELECT Id, Status,Opportunity.recordtype.Name,Opportunity.Account.Channel_Partner_Account_Name__c, 
                             Opportunity.Account.TDS__c 
                             FROM Quote WHERE 
                             Id IN :quoteIdStatusMap.keySet() ]
        ){
            quoteIdStatusMap.put(thisRec.Id, thisRec.Status);
            quoteMap.put(thisRec.Id,thisRec);
        }
        
        for(
            Product2 thisRec : [ SELECT Id, OrderForm_Product_Name__c, Product_Line__c, ProductCode, 
                                Product_category__c, Overuse__c, Formula__c
                                FROM Product2 WHERE Id IN :productAndSKU.keySet() ]
        ){
            productAndSKU.put(thisRec.Id, thisRec.OrderForm_Product_Name__c);
            productMap.put(thisRec.Id, thisRec);
        }
        
        
        for(QuoteLineItem thisRec : listOfNewQuotes){
            
            if(thisRec.Product_Code__c == NULL) {
                thisRec.Product_Code__c =  productMap.get(thisRec.Product2Id).ProductCode;
            }
            
            thisRec.Line_Item_Type__c  = quoteMap.get(thisRec.QuoteId).Opportunity.recordtype.Name;
            
            thisRec.TAN_Number__c = quoteMap.get(thisRec.QuoteId).Opportunity.Account.TDS__c != NULL ? quoteMap.get(thisRec.QuoteId).Opportunity.Account.TDS__c : thisRec.TAN_Number__c;
            /** Added BY Niraj to Exclude Weekend Dates 
if(thisRec.Period_End_date__c != NULL){

DateTime endDate = (DateTime)thisRec.Period_End_date__c;
String dayOfWeek = endDate.format('u');
if(dayOfWeek == '6' || dayOfWeek == '7'){
thisRec.Period_End_date__c = thisRec.Period_End_date__c.addDays(8-Integer.valueOf(dayOfWeek));
}
}
Added BY Niraj to Exclude Weekend Dates **/
            if(
                productMap.get(thisRec.Product2Id).Formula__c != NULL 	&& 
                productMap.get(thisRec.Product2Id).Formula__c != '0' 	&& 
                productMap.get(thisRec.Product2Id).Formula__c != '' 
            ){
                if( quoteIdStatusMap.size() > 0 && quoteIdStatusMap.get(thisRec.QuoteId) != NULL ){
                    if( !quoteStatusList.contains(quoteIdStatusMap.get(thisRec.QuoteId)) ){
                        thisRec.Is_Formula_Price_Applicable__c = TRUE;
                    }
                }
            }
            
            
            if( productAndSKU.containsKey(thisRec.Product2Id) ){
                
                if( productAndSKU.get(thisRec.Product2Id) == 'Max ITC Integration - Series X'){
                    thisRec.SLA_In_Weeks__c 	= 6;
                    thisRec.SOW_Drive_Link__c 	= 'https://docs.google.com/presentation/d/1zF1CpqHRYOciUc7Ojzp8qoW19BCIks9qfpup1bVu_Jk/edit?usp=sharing';
                }
                if( productAndSKU.get(thisRec.Product2Id) == 'Max ITC Integration - Series Y'){
                    thisRec.SLA_In_Weeks__c 	= 4;
                    thisRec.SOW_Drive_Link__c 	= 'https://docs.google.com/presentation/d/1zF1CpqHRYOciUc7Ojzp8qoW19BCIks9qfpup1bVu_Jk/edit?usp=sharing';
                }
                if( productAndSKU.get(thisRec.Product2Id) == 'Max ITC Integration - Series Z'){
                    thisRec.SLA_In_Weeks__c 	= 4;
                    thisRec.SOW_Drive_Link__c 	= 'https://docs.google.com/presentation/d/1zF1CpqHRYOciUc7Ojzp8qoW19BCIks9qfpup1bVu_Jk/edit?usp=sharing';
                }
                if( productAndSKU.get(thisRec.Product2Id) == 'EINV')
                    thisRec.SLA_In_Weeks__c 	= 2;
                if( productAndSKU.get(thisRec.Product2Id) == 'EWB')
                    thisRec.SLA_In_Weeks__c 	= 2;
                if( productAndSKU.get(thisRec.Product2Id) == 'GST')
                    thisRec.SLA_In_Weeks__c 	= 4;
                if( productAndSKU.get(thisRec.Product2Id) == 'ASP/GSP')
                    thisRec.SLA_In_Weeks__c 	= 6;
                if( productAndSKU.get(thisRec.Product2Id) == 'E-Invoicing')
                    thisRec.SLA_In_Weeks__c 	= 4;
                
                /** Type of integration restriction - Ashwin : START **/
                System.debug('typeOfIntegCategoryValues-->'+typeOfIntegCategoryValues);
                
                if(typeOfIntegCategoryValues.contains(productAndSKU.get(thisRec.Product2Id)))
                {
                    thisRec.Type_of_integration_category__c  = productAndSKU.get(thisRec.Product2Id);   
                }	/** Type of integration restriction - Ashwin : END **/
                
                /**	Product Line & Category update - Ashwin : START **/ 
                if(productMap.containsKey(thisRec.Product2Id)){
                    thisRec.Product_Line__c = productMap.get(thisRec.Product2Id).Product_Line__c;
                    thisRec.Product_Category__c = productMap.get(thisRec.Product2Id).Product_category__c;
                }	/**	Product Line & Category update - Ashwin : END **/ 
                
                /**	Pricing Calculator - Kartikeya : START	**/
                thisRec.PricebookEntryId  = Id.valueOf(String.valueOf(productPriceMap.get(thisRec.Product2Id).get('PBId')));
                thisRec.Product_formula__c  = productMap.get(thisRec.Product2Id).formula__c;
                /**	Pricing Calculator - Kartikeya : END	**/
                
            }
            
            if(productMap.containsKey(thisRec.Product2Id) ){
                if(productMap.get(thisRec.Product2Id).Overuse__c != NULL){
                    thisRec.Overuse__c  = productMap.get(thisRec.Product2Id).Overuse__c;
                }
            }
            
            if(thisRec.List_Price_Order_Form__c == NULL){
                thisRec.List_Price_Order_Form__c =  thisRec.UnitPrice;
            }
            if((!String.ISBLANK(thisRec.Line_Item_Type__c) && !System.label.Pricing_Applicable_RT.ToLowerCase().contains(thisRec?.Line_Item_Type__c?.ToLowerCase() )) || 
               (quoteMap.get(thisRec.QuoteId).Opportunity.Account?.Channel_Partner_Account_Name__c != NULL && quoteMap.get(thisRec.QuoteId).Opportunity.Account?.Channel_Partner_Account_Name__c?.ToLowerCase()?.Contains('uneecop'))){
                   thisRec.Is_Formula_Price_Applicable__c = FALSE; 
               }
        }
        
        QuoteLineItemHelper.updateDurationAndEndDate(listOfNewQuotes);
        //QuoteLineItemHelper.calculateUnitPrice(listOfNewQuotes,true);
        QuoteLineItemHelper.updateSowDriveLink(listOfNewQuotes);

		//Bhavesh : START : to update product formula for GCC renewal QLIs   
        Map<Id,QuoteLineItem> mapOfNewQLI = new Map<Id,QuoteLineItem>();
        mapOfNewQLI.putall(listOfNewQuotes);
        
        //CTX_QuoteLineItemTriggerHelper.updateProductFormulaFOrListProceForGccQLI(mapOfNewQLI);
        //Bhavesh : END : to update product formula for GCC renewal QLIs   
        
    }
    
    public static void afterInsert(List<Sobject> listOfNewSObjects,Map<Id,Sobject> mapOfNewSObjects){
        
        Map<Id,QuoteLineItem> 			mapOfNewIdWithQuotesLineItems		= (Map<Id,QuoteLineItem>)mapOfNewSObjects; 
        Set<Id> 						parentQuoteIDsToBeUpdated			= new Set<Id>();
        Set<Id> 						product2IDSet						= new Set<Id>();
        Set<Id>							parentQuoteIds						= new Set<Id>();
        Map<Id,QuoteLineItem>			licenseQLIMap						= new Map<Id, QuoteLineItem>();
        Map<Id,QuoteLineItem>			integrationQLIMap					= new Map<Id, QuoteLineItem>();
        Map<Id, List<QuoteLineItem>>	mapQuoteIdAndRelatedQLI 			= new Map<Id, List<QuoteLineItem>>();
        
        /**	Pricing Calculator	: Kartikeya - START	**/
        Map<String, Decimal> 			mapOfPrice            				= new Map<String, Decimal>();	
        Set<Id> 						Product2IdList                		= new Set<Id>();
        List<QuoteLineItem> 			QLIPriceUpdateList					= new List<QuoteLineItem>();
        /**	Pricing Calculator	: Kartikeya - END	**/
        
        quoteLineItemHelper.updateArrCountOnQuote(mapOfNewIdWithQuotesLineItems);
        
        Map<Id, QuoteLineItem> newLicenseQLIMap 	= new Map<Id, QuoteLineItem>();
        Map<Id, QuoteLineItem> newIntegrationQLIMap = new Map<Id, QuoteLineItem>();
        
        
        for(QuoteLineItem thisRec : mapOfNewIdWithQuotesLineItems.values()){
            
            parentQuoteIds.add(thisRec.QuoteId);
            Product2IdList.add(thisRec.Product2Id);
            
            /**	License QLI Block : START	**/
            if(
                thisRec.Quote_Line_Item_Product_Category__c != NULL &&
                !thisRec.Quote_Line_Item_Product_Category__c.containsIgnoreCase('Integration')
            ){
                newLicenseQLIMap.put(thisRec.Id, thisRec);
            }	
            /**	License QLI Block : END	**/
            
            /**	Integration QLI Block : START	**/
            if(
                thisRec.Quote_Line_Item_Product_Category__c != NULL &&
                thisRec.Quote_Line_Item_Product_Category__c.containsIgnoreCase('Integration')
            ){
                newIntegrationQLIMap.put(thisRec.Id, thisRec);
            }
            /**	Integration QLI Block : END	**/
            
            
            
        }
        
        /**	Pricing Calculator	: Kartikeya - START	**/
        mapOfPrice = CTX_CustomStringToFormulaParser.CTX_CustomStringToFormulaParserMethod(
            Product2IdList, mapOfNewIdWithQuotesLineItems.values()
        );	/**	Pricing Calculator	: Kartikeya - END	**/
        
        Map<Id, QuoteLineItem> 	newQuoteLineItemBasedOnQuoteMap = new Map<Id, QuoteLineItem>(
            [ SELECT Id, QuoteId, Discount, 
             Product2.Product_Line__c, Product2.Product_category__c, Product2.ProductCode, 
             Period_Start_date__c, Quote_Line_Item_Product_Category__c, Parent_Product_Code__c,
             Stage_in_MY__c
             FROM QuoteLineItem WHERE 
             QuoteId IN: parentQuoteIds 
             ORDER BY QuoteId ] 
        );
        
        for(QuoteLineItem thisRec : newQuoteLineItemBasedOnQuoteMap.values()){
            
            /**	Existing Code : START	**/
            if(mapOfNewIdWithQuotesLineItems.containsKey(thisRec.Id)){
                if(
                    thisRec.Product2.Product_category__c 	== 'Integration' 	&& 
                    thisRec.Product2.Product_Line__c 		!= 'Max' 			&&
                    thisRec.Discount > 15 
                ){
                    parentQuoteIDsToBeUpdated.add(thisRec.QuoteId);
                }
            }
            /**	Existing Code : END	**/
            
            if(mapQuoteIdAndRelatedQLI.containsKey(thisRec.QuoteId)){
                mapQuoteIdAndRelatedQLI.get(thisRec.QuoteId).add(thisRec);
            } else{
                mapQuoteIdAndRelatedQLI.put(thisRec.QuoteId, new List<QuoteLineItem>{thisRec});
            }
            
            
        }	/**	END of Iteration	**/
        
        QuoteConstants.ISFIRSTTIMEQUOTE = False;
        //Update QLIPriceUpdateList;	/**	Pricing Calculator	: Kartikeya - END	**/
        
        /**	**/
        
        
        CTX_SyncQuoteLineStartDate.syncQuoteStartDate(newLicenseQLIMap, newIntegrationQLIMap, mapQuoteIdAndRelatedQLI);
        
        if( !parentQuoteIDsToBeUpdated.isEmpty() ){
            CTX_QuoteLineItemTriggerHelper.updateQuotesForIntegrationQuoteLineItem(parentQuoteIDsToBeUpdated, TRUE);
        }
        /**	**/ 
        
    }
    
    public static void beforeUpdate(Map<Id,Sobject> mapOfNewSObjects,Map<Id,Sobject> mapOfOldSObjects){
        
        Map<Id,QuoteLineItem> 	mapOfNewIdWithQuotesLineItems			= (Map<Id,QuoteLineItem>)mapOfNewSObjects;
        Map<Id,QuoteLineItem> 	mapOfOldIdWithQuotesLineItems			= (Map<Id,QuoteLineItem>)mapOfOldSObjects;
        Map<Id,QuoteLineItem> 	mapOfQuotesLineItemsWithParentQuoteId	= new  Map<Id,QuoteLineItem>();
        Map<Id, String>			productAndSKU							= new Map<Id, String>();
        Map<Id,QuoteLineItem>	qliMapToUpdateCalculatedThresholdPrices	= new Map<Id,QuoteLineItem>();
        Map<Id,QuoteLineItem>	qliMapforThresholdPricesValidation		= new Map<Id,QuoteLineItem>();
        List<QuoteLineItem> 	listOfNewQuotes							= new list <QuoteLineItem>();
        Set<Id>					parentQuoteIdSet						= new Set<Id>();
        Map<Id, String>			productAndLine							= new Map<Id, String>(); 
        Map<String, Set<String>>	num_MandatoryFieldMap_NonZero 		= new Map<String, Set<String>>();
        Map<String, Set<String>>	txt_MandatoryFieldMap_NonZero 		= new Map<String, Set<String>>();
        Map<String, Set<String>>	num_MandatoryFieldMap_WithZero 		= new Map<String, Set<String>>();
        String						errorMessage_Non_Zero				= ' Enter non-zero/non-null values for the following fields: ';
        String						errorMessage_Zero_Allowed			= ' Enter values for the following fields: ';
        
        String type                            							= 'QuoteLineItem';
        Map<String, Schema.SObjectType> schemaMap 						= Schema.getGlobalDescribe();
        Schema.SObjectType quoteLineItemSchema            				= schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap 						= quoteLineItemSchema.getDescribe().fields.getMap();
        Set<Id> 						parentQuoteIds			 		= new Set<Id>();
        Map<Id, QuoteLineItem> 			newLicenseQLIMap 				= new Map<Id, QuoteLineItem>();
        Map<Id, QuoteLineItem> 			newIntegrationQLIMap 			= new Map<Id, QuoteLineItem>();
        Map<Id, List<QuoteLineItem>>	mapQuoteIdAndRelatedQLI 		= new Map<Id, List<QuoteLineItem>>();
        /**	Pricing Calculator	**/
        List<QuoteLineItem> 			listOfNewQuotes1				= new list <QuoteLineItem>();	
        Set<Id> 						productIdList 					= new Set<Id>();
        Map<String, Decimal> 			mapOfPrice         				= new Map<String, Decimal>();
        Map<Id,Product2> productMap 									= new Map<Id,Product2>([SELECT id,formula__c , ProductCode  FROM product2 ]);
        List<QuoteLineItem> qliToUpdateProductFormulaForGccRenewal		= new List<QuoteLineItem>();
        /**	Pricing Calculator : END	**/
        
        
        // Added by Ashwin
        //CTX_QliFieldUpdateBasedOnPlatform.updateQli(mapOfNewIdWithQuotesLineItems, mapOfOldIdWithQuotesLineItems);
        
        /** START >> Added by Ashwin **/
        List<String> typeOfIntegCategoryValues = new List<String>();
        Schema.DescribeFieldResult picklistValues = QuoteLineItem.Type_of_integration_category__c.getDescribe();
        Schema.SObjectField field = picklistValues.getSObjectField();
        List<Schema.PicklistEntry> optionValues = field.getDescribe().getPicklistValues();
        
        for(Schema.PicklistEntry thisRec : optionValues){
            typeOfIntegCategoryValues.add(thisRec.getLabel());
        }
        /** END >> Added by Ashwin **/
        for(QuoteLineItem thisQLI : mapOfNewIdWithQuotesLineItems.values()){
            
            
            
            parentQuoteIdSet.add(thisQLI.QuoteId);
            if(String.ISBLANK(thisQLI.Product_formula__c))
                thisQLI.Product_formula__c  = productMap.get(thisQLI.Product2Id).formula__c;
            
            
            
            
            if(!thisQLI.Is_Formula_Price_Applicable__c ){
                
                Decimal max = 0;
                
                if( thisQLI.Manual_High_Value_in_List_Price_OF__c && !thisQLI.Calculate_based_on_List_Price_OF__c){
                    max = Math.max(Math.max(thisQLI.unitprice , thisQLI.Sale_Price__c), thisQLI.List_Price_Order_Form__c);
                }
                
                if(!thisQLI.Manual_High_Value_in_List_Price_OF__c && 
                   !thisQLI.Calculate_based_on_List_Price_OF__c  && 
                   thisQLI.List_Price_Order_Form__c == mapOfOldIdWithQuotesLineItems.get(thisQLI.Id).List_Price_Order_Form__c){
                       max = Math.max(thisQLI.unitprice , thisQLI.Sale_Price__c);
                   }
                
                thisQLI.List_Price_Order_Form__c = max != 0 ? max : thisQLI.List_Price_Order_Form__c;
                
                System.debug('@List_Price_Order_Form__c__BU'+thisQLI.List_Price_Order_Form__c);
                
            }
            
            
            if(thisQLI.Product_Code__c == NULL) {
                thisQLI.Product_Code__c =  productMap.get(thisQLI.Product2Id).ProductCode;
            }
            
            productIdList.add(thisQLI.Product2Id);
            
            
        }
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
        
        System.debug('@num_MandatoryFieldMap_NonZero'+num_MandatoryFieldMap_NonZero);
        System.debug('@txt_MandatoryFieldMap_NonZero'+txt_MandatoryFieldMap_NonZero);
        System.debug('@num_MandatoryFieldMap_WithZero'+num_MandatoryFieldMap_WithZero);
        
        Map<Id,Quote> quoteMap = new Map<Id,Quote>([SELECT Id, Status, Opportunity.Is_Auto_Renewal_Enabled__c, Opportunity.Account.Is_Auto_Renewal_Enabled__c FROM Quote WHERE Id IN :parentQuoteIdSet]);
        System.debug('quoteMap :: '+quoteMap);
        
        
        for(QuoteLineItem quoteLinekey:mapOfNewIdWithQuotesLineItems.values()){
            
            if(OpportunityConstants.AUTO_RENEW_RULE &&
               quoteMap.get(quoteLinekey.QuoteId).Opportunity.Is_Auto_Renewal_Enabled__c == TRUE){
                   if( !system.label.Auto_Renewal_Discount_Approval_Eligible_Email.containsIgnoreCase( UserInfo.getUserEmail() ) ){
                       //quoteLinekey.addError(System.Label.CTX_AutoRenewal_Error_Msg );
                   }
               }
            
            /** Added BY Niraj to Exclude Weekend Dates 
if(quoteLinekey.Period_End_date__c != NULL && quoteLinekey.Period_End_date__c != mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).Period_End_date__c){

DateTime endDate = (DateTime)quoteLinekey.Period_End_date__c;
String dayOfWeek = endDate.format('u');
if(dayOfWeek == '6' || dayOfWeek == '7'){
quoteLinekey.Period_End_date__c = quoteLinekey.Period_End_date__c.addDays(8-Integer.valueOf(dayOfWeek));
}
}
Added BY Niraj to Exclude Weekend Dates **/
            
            //for Mandatory PM
            Boolean 	isError_Zero 										= FALSE;
            Boolean 	isError_Non_Zero 									= FALSE;
            Set<String> mandatory_NonZero 									= new Set<String>();
            Set<String> mandatory_WithZero 									= new Set<String>();
            
            
            if( 
                num_MandatoryFieldMap_NonZero.size() > 0			&&
                num_MandatoryFieldMap_NonZero.containsKey(quoteLinekey.Product_Module_Corrected__c )
            ){
                System.debug('@PMC'+quoteLinekey.Product_Module_Corrected__c );
                mandatory_NonZero.addAll(num_MandatoryFieldMap_NonZero.get(quoteLinekey.Product_Module_Corrected__c));
            }
            
            if( 
                txt_MandatoryFieldMap_NonZero.size() > 0			&&
                txt_MandatoryFieldMap_NonZero.containsKey(quoteLinekey.Product_Module_Corrected__c)
            ){
                System.debug('@PMC'+quoteLinekey.Product_Module_Corrected__c );
                mandatory_NonZero.addAll(txt_MandatoryFieldMap_NonZero.get(quoteLinekey.Product_Module_Corrected__c));
            }
            
            if( 
                num_MandatoryFieldMap_WithZero.size() > 0			&&
                num_MandatoryFieldMap_WithZero.containsKey(quoteLinekey.Product_Module_Corrected__c)
            ){
                System.debug('@PMC'+quoteLinekey.Product_Module_Corrected__c );
                mandatory_WithZero.addAll(num_MandatoryFieldMap_WithZero.get(quoteLinekey.Product_Module_Corrected__c));
            }
            //for Mandatory PM
            
            productAndSKU.put(quoteLinekey.Product2Id, NULL);
            productAndLine.put(quoteLinekey.Product2Id, NULL);
            
            if(mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).discount != quoteLinekey.discount || mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).MarkUp__c  != quoteLinekey.MarkUp__c || mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).Sale_Price__c   != quoteLinekey.Sale_Price__c  || mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).UnitPrice   != quoteLinekey.UnitPrice  ){
                listOfNewQuotes.add(quoteLinekey);
            }
            
            /** Duration : Validation for Integration Products **/
            if(mapOfNewIdWithQuotesLineItems.get(quoteLinekey.Id).Period_End_date__c  != mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).Period_End_date__c){
                if(quoteLinekey.Duration__c > 0  &&
                   quoteLinekey.Period_End_date__c != (quoteLinekey.Period_Start_date__c + (Integer)quoteLinekey.Duration__c)){
                       quoteLinekey.addError('Period end date should be '+quoteLinekey.Duration__c+' days from period start date');
                   }
            }
            
            if(
                mapOfNewIdWithQuotesLineItems.get(quoteLinekey.Id).period_start_date__c != 
                mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).period_start_date__c &&
                mapOfNewIdWithQuotesLineItems.get(quoteLinekey.Id).period_end_date__c == NULL
            ){
                mapOfNewIdWithQuotesLineItems.get(quoteLinekey.Id).period_end_date__c = 
                    mapOfNewIdWithQuotesLineItems.get(quoteLinekey.Id).period_start_date__c.ADDMONTHS(12)-1;
            }
            //listOfQuoteIDs.add(quoteLinekey.quoteID); 
            if(
                (
                    quoteLinekey.Period_End_date__c != 
                    mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).Period_End_date__c || 
                    quoteLinekey.Period_Start_date__c != 
                    mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).Period_Start_date__c
                ) && 
                (
                    quoteLinekey.Period_Start_date__c != NULL && 
                    quoteLinekey.Period_End_date__c != NULL
                )
            ){
                Integer numberDays = quoteLinekey.Period_Start_date__c.daysBetween(quoteLinekey.Period_End_date__c)+1;
                System.debug('numberDays '+numberDays);
                Decimal totalDays = numberDays; 
                Decimal val = totalDays/30.6;
                System.debug('val '+val);
                quoteLinekey.Term_Months__c = String.valueOf(val.round(System.RoundingMode.HALF_EVEN));
            }
            //  mapOfQuotesLineItemsWithParentQuoteId.put(quoteLinekey.quoteID,quoteLinekey);
            
            /** START : bhaveshjindal :: calculte threshold price based on type of integration **/
            
            if(quoteLinekey.Type_of_Integration__c != mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).Type_Of_Integration__c 
               && quoteLinekey.Type_of_Integration__c != NULL){
                   qliMapToUpdateCalculatedThresholdPrices.put(quoteLinekey.Id,quoteLinekey);
               }
            
            /** END : bhaveshjindal :: calculte threshold price based on type of integration **/
            
            /**	Non Zero or Null Value Check	**/
            for(String thisSTR : mandatory_NonZero){
                if( quoteLinekey.get(thisSTR) == NULL || quoteLinekey.get(thisSTR) == 0 ){
                    String fieldLabel = fieldMap.get(thisSTR).getDescribe().getLabel();
                    errorMessage_Non_Zero += (fieldLabel+' ,');
                    isError_Non_Zero = TRUE;
                    // mapOfNewIdWithQuotes.get(quotekey).addError(thisSTR,'Enter non-zero value for this field');
                } 
            }
            
            /**	Zero allowed Value Check	**/
            for(String thisSTR : mandatory_WithZero){
                if( quoteLinekey.get(thisSTR) == NULL  ){
                    String fieldLabel = fieldMap.get(thisSTR).getDescribe().getLabel();
                    errorMessage_Zero_Allowed += (fieldLabel+' ,');
                    isError_Zero = TRUE;
                    // mapOfNewIdWithQuotes.get(quotekey).addError(thisSTR,'Enter value for this field');
                } 
            }
            
            /**	Remove End	**/
            errorMessage_Non_Zero 		= errorMessage_Non_Zero.removeEnd(' ,');
            errorMessage_Zero_Allowed 	= errorMessage_Zero_Allowed.removeEnd(' ,');
            
            /**	Error Condition Check	**/
            System.debug('MandatoryCheck'+quoteLinekey.Id+'- errorMessage_Non_Zero -'+errorMessage_Non_Zero+'- errorMessage_Zero_Allowed - '+errorMessage_Zero_Allowed);
            if(OpportunityConstants.AUTO_RENEW_RULE){
                if(  isError_Zero && isError_Non_Zero && !QuoteConstants.DISABLEQLIVAl && quoteLinekey.Platform__c !='App.Clear' && System.label.Enable_Standard_Plan != 'NO'){
                    quoteLinekey.adderror(' ['+quoteLinekey.Id+'] : '+errorMessage_Non_Zero + ' & ' +errorMessage_Zero_Allowed ,false);
                } else if(  isError_Zero && !QuoteConstants.DISABLEQLIVAl && quoteLinekey.Platform__c !='App.Clear' && System.label.Enable_Standard_Plan != 'NO'){
                    quoteLinekey.adderror(' ['+quoteLinekey.Id+'] : '+errorMessage_Zero_Allowed );
                } else if(  isError_Non_Zero && !QuoteConstants.DISABLEQLIVAl && quoteLinekey.Platform__c !='App.Clear' && System.label.Enable_Standard_Plan != 'NO'){
                    quoteLinekey.adderror(' ['+quoteLinekey.Id+'] : '+errorMessage_Non_Zero );
                } else{
                    /**	No Error	**/
                }
                
            }
            
            
            isError_Zero = FALSE;
            isError_Non_Zero = FALSE;
            
        }
        
        for(
            Product2 thisRec : [ SELECT Id, OrderForm_Product_Name__c, Product_Line__c
                                FROM Product2 WHERE Id IN :productAndSKU.keySet() ]
        ){
            productAndSKU.put(thisRec.Id, thisRec.OrderForm_Product_Name__c);
            productAndLine.put(thisRec.Id, thisRec.Product_Line__c);
        }
        
        if(productAndSKU.keySet().size() > 0){
            /*
Map<String,Product_And_SKU_Mapping__mdt> productSKUMetadataMap = new Map<String,Product_And_SKU_Mapping__mdt>();
for(Product_And_SKU_Mapping__mdt mdt : Product_And_SKU_Mapping__mdt.getAll().values()){
productSKUMetadataMap.put(mdt.Label, mdt);
}*/
            for(QuoteLineItem thisRec : mapOfNewIdWithQuotesLineItems.values()){
                
                parentQuoteIds.add(thisRec.QuoteId);
                if( productAndSKU.containsKey(thisRec.Product2Id) ){
                    /*
Product_And_SKU_Mapping__mdt mdtRec = productSKUMetadataMap.get(productAndSKU.get(thisRec.Product2Id));
if(mdtRec != null){
thisRec.SLA_In_Weeks__c = mdtRec.SLA_In_Weeks__c;
thisRec.SOW_Drive_Link__c = mdtRec.SOW_Drive_Links__c != null ? mdtRec.SOW_Drive_Links__c : null;
}
*/
                    
                    if( productAndSKU.get(thisRec.Product2Id) == 'Max ITC Integration - Series X'){
                        thisRec.SLA_In_Weeks__c 	= 6;
                        thisRec.SOW_Drive_Link__c 	= 'https://docs.google.com/presentation/d/1zF1CpqHRYOciUc7Ojzp8qoW19BCIks9qfpup1bVu_Jk/edit?usp=sharing';
                    }
                    if( productAndSKU.get(thisRec.Product2Id) == 'Max ITC Integration - Series Y'){
                        thisRec.SLA_In_Weeks__c 	= 4;
                        thisRec.SOW_Drive_Link__c 	= 'https://docs.google.com/presentation/d/1zF1CpqHRYOciUc7Ojzp8qoW19BCIks9qfpup1bVu_Jk/edit?usp=sharing';
                    }
                    if( productAndSKU.get(thisRec.Product2Id) == 'Max ITC Integration - Series Z'){
                        thisRec.SLA_In_Weeks__c 	= 4;
                        thisRec.SOW_Drive_Link__c 	= 'https://docs.google.com/presentation/d/1zF1CpqHRYOciUc7Ojzp8qoW19BCIks9qfpup1bVu_Jk/edit?usp=sharing';
                    }
                    if( productAndSKU.get(thisRec.Product2Id) == 'EINV')
                        thisRec.SLA_In_Weeks__c 	= 2;
                    if( productAndSKU.get(thisRec.Product2Id) == 'EWB')
                        thisRec.SLA_In_Weeks__c 	= 2;
                    if( productAndSKU.get(thisRec.Product2Id) == 'GST')
                        thisRec.SLA_In_Weeks__c 	= 4;
                    if( productAndSKU.get(thisRec.Product2Id) == 'ASP/GSP')
                        thisRec.SLA_In_Weeks__c 	= 6;
                    if( productAndSKU.get(thisRec.Product2Id) == 'E-Invoicing')
                        thisRec.SLA_In_Weeks__c 	= 4;
                    
                    /** START >> Added by Ashwin >> Max ITC Integration ARR **/
                    System.debug('typeOfIntegCategory-->'+typeOfIntegCategoryValues);
                    if(typeOfIntegCategoryValues.contains(productAndSKU.get(thisRec.Product2Id))){
                        thisRec.Type_of_integration_category__c  = productAndSKU.get(thisRec.Product2Id);   
                    }else
                    {
                        thisRec.Type_of_integration_category__c  = 'Others';
                    }
                    /** END >> Added by Ashwin >> Max ITC Integration ARR **/
                    
                    if(productAndLine.containsKey(thisRec.Product2Id)){
                        thisRec.Product_Line__c = productAndLine.get(thisRec.Product2Id);
                    }
                    
                    /** Duration Automation for Integration Products **/
                    if(thisRec.Period_Start_date__c != NULL && thisRec.Duration__c != NULL){
                        thisRec.Period_End_date__c = thisRec.Period_Start_date__c + (Integer)thisRec.Duration__c;
                    }
                    
                }
            }
        }
        
        
        /**	Pricing Calculator	**/
        /**  mapOfPrice = CTX_CustomStringToFormulaParser.CTX_CustomStringToFormulaParserMethod(
productIdList, mapOfNewIdWithQuotesLineItems.values()
);
for(QuoteLineItem quoteLinekey:mapOfNewIdWithQuotesLineItems.values()){
system.debug('TestValues^$'+ mapOfPrice);
if(
quoteLinekey.Product_Formula__c  != mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).Product_Formula__c || 
quoteLinekey.Is_Formula_Price_Applicable__c
){
quoteLinekey.UnitPrice = mapOfPrice.get(quoteLinekey.Id);
}
}**/
        /**	Pricing Calculator	**/
        
        
        
        if(qliMapToUpdateCalculatedThresholdPrices.values().size()>0){
            quoteLineItemHelper.updateThresholdPriceForIntegrationQLI(qliMapToUpdateCalculatedThresholdPrices);
        }
        
        if(mapOfNewIdWithQuotesLineItems.values().size()>0){
            QuoteLineItemHelper.updateDurationAndEndDate(mapOfNewIdWithQuotesLineItems.values());
        }
        
        Map<Id, QuoteLineItem> 	newQuoteLineItemBasedOnQuoteMap = new Map<Id, QuoteLineItem>(
            [ SELECT Id, QuoteId, Discount, Product2.Name, 
             Product2.Product_Line__c, Product2.Product_category__c, Product2.ProductCode, 
             Period_Start_date__c, Quote_Line_Item_Product_Category__c, Parent_Product_Code__c,
             Stage_in_MY__c, 
             Quote.Opportunity.Account.TDS__c, Quote.Opportunity.Is_Auto_Renewal_Enabled__c
             FROM QuoteLineItem WHERE 
             QuoteId IN: parentQuoteIds 
             ORDER BY QuoteId ] 
        );
        
        /** Update start date - License <> Integration **/
        for(QuoteLineItem thisRec : mapOfNewIdWithQuotesLineItems.values()){
            
            
            /**	License QLI Block : START	**/
            if(
                thisRec.Quote_Line_Item_Product_Category__c != NULL &&
                !thisRec.Quote_Line_Item_Product_Category__c.containsIgnoreCase('Integration')
            ){
                newLicenseQLIMap.put(thisRec.Id, thisRec);
            }	/**	License QLI Block : END	**/
            
            /**	Integration QLI Block : START	**/
            if(
                thisRec.Quote_Line_Item_Product_Category__c != NULL &&
                thisRec.Quote_Line_Item_Product_Category__c.containsIgnoreCase('Integration')
            ){
                newIntegrationQLIMap.put(thisRec.Id, thisRec);
            }	/**	Integration QLI Block : END	**/
            
            
            
            if( newQuoteLineItemBasedOnQuoteMap.get(thisRec.Id).Quote.Opportunity.Is_Auto_Renewal_Enabled__c ){
                
                if( 
                    thisRec.Period_End_date__c != mapOfOldIdWithQuotesLineItems.get(thisRec.Id).Period_End_date__c ||
                    thisRec.Period_Start_date__c != mapOfOldIdWithQuotesLineItems.get(thisRec.Id).Period_Start_date__c
                ){
                    if( !system.label.Auto_Renewal_Discount_Approval_Eligible_Email.containsIgnoreCase( UserInfo.getUserEmail() ) ){
                        thisRec.addError('Changing Start & End Date is not allowed for Auto Renewal Cases');
                    }
                    
                }
                
            }  
            
            thisRec.TAN_Number__c = newQuoteLineItemBasedOnQuoteMap.get(thisRec.Id).Quote.Opportunity.Account.TDS__c != NULL ? newQuoteLineItemBasedOnQuoteMap.get(thisRec.Id).Quote.Opportunity.Account.TDS__c : thisRec.TAN_Number__c;
            
        }
        
        
        
        for(QuoteLineItem thisRec : newQuoteLineItemBasedOnQuoteMap.values()){
            
            if(mapQuoteIdAndRelatedQLI.containsKey(thisRec.QuoteId)){
                mapQuoteIdAndRelatedQLI.get(thisRec.QuoteId).add(thisRec);
            } else{
                mapQuoteIdAndRelatedQLI.put(thisRec.QuoteId, new List<QuoteLineItem>{thisRec});
            }
            
            
            
        }	/**	END of Iteration	**/
        
        
        
        CTX_SyncQuoteLineStartDate.syncQuoteStartDate(newLicenseQLIMap, newIntegrationQLIMap, mapQuoteIdAndRelatedQLI);
        
        QuoteLineItemHelper.updateSowDriveLink(mapOfNewIdWithQuotesLineItems.values());
        
        //Bhavesh : START : to update product formula for GCC renewal QLIs   
        
        for(QuoteLineItem thisQLI : mapOfNewIdWithQuotesLineItems.Values()){
            
            if(thisQLI.Is_Formula_Price_Applicable__c == FALSE &&
               mapOfOldIdWithQuotesLineItems.get(thisQLI.Id).Is_Formula_Price_Applicable__c == TRUE){
                   
               }else{
                   qliToUpdateProductFormulaForGccRenewal.add(thisQLI);
               }
        }
        Map<Id, QuoteLineItem> QliMapToUpdate = new Map<Id, QuoteLineItem>();
        QliMapToUpdate.putall(qliToUpdateProductFormulaForGccRenewal);
        CTX_QuoteLineItemTriggerHelper.updateProductFormulaFOrListProceForGccQLI(QliMapToUpdate);
        //Bhavesh : END : to update product formula for GCC renewal QLIs   
        
        
    } 
    
    public static void afterUpdate(Map<Id,Sobject> mapOfNewSObjects,Map<Id,Sobject> mapOfOldSObjects){
        
        
        QuoteConstants.ISFIRSTTIMEQLI = FALSE;
        set<Id> listOfNewQuotes=New set<Id>();
        
      /*  List<QuoteLineItem> newQuoteLineIteamObj = New List<QuoteLineItem>();// added by Murali
        List<QuoteLineItem> oldQuoteLineIteamObj = New List<QuoteLineItem>();// added by Murali
        set<Id> quoteIds = New set<Id>();// added by Murali
        set<Id> productIds = New set<Id>();// added by Murali
        List<String> fieldListidentity = new List<String>();// added by Murali*/
        
        
        Map<Id,QuoteLineItem> mapOfNewIdWithQuotesLineItems=(Map<Id,QuoteLineItem>)mapOfNewSObjects;
        Map<Id,QuoteLineItem> mapOfOldIdWithQuotesLineItems=(Map<Id,QuoteLineItem>)mapOfOldSObjects;
        Set<Id> 						parentQuoteIDsToBeUpdated	= new Set<Id>(); 
        Set<Id> 						parentQuoteIds			 	= new Set<Id>();
        Map<Id, QuoteLineItem> 			newLicenseQLIMap 			= new Map<Id, QuoteLineItem>();
        Map<Id, QuoteLineItem> 			newIntegrationQLIMap 		= new Map<Id, QuoteLineItem>();
        Map<Id, List<QuoteLineItem>>	mapQuoteIdAndRelatedQLI 	= new Map<Id, List<QuoteLineItem>>();
        Map<Id, QuoteLineItem>			updateLineItemMap			= new Map<Id, QuoteLineItem>();
        List<QuoteLineItem>             QLIListPrice                = new List<QuoteLineItem>();
        /**	Pricing Calculator	**/
        List<QuoteLineItem> 			listOfNewQuotes1				= new list <QuoteLineItem>();	
        Set<Id> 						productIdList 					= new Set<Id>();
        Map<String, Decimal> 			mapOfPrice         				= new Map<String, Decimal>();
        Map<Id,Product2> productMap 									= new Map<Id,Product2>([SELECT id,formula__c   FROM product2 ]);
        /**	Pricing Calculator : END	**/
        
        //added by bhaveshjindal
        Map<Id,QuoteLineItem>	qliMapforThresholdPricesValidation		= new Map<Id,QuoteLineItem>();
        Set<Id>					parentQuoteIdSet						= new Set<Id>();
        Map<Id, QuoteLineItem>	quoteIdAndQLIMap= new Map<Id, QuoteLineItem>();
        for(QuoteLineItem thisQLI : mapOfNewIdWithQuotesLineItems.values()){
            system.debug('after update metadat constarints'+thisQLI.Identity_Resource_Metadata__c);  
            parentQuoteIdSet.add(thisQLI.QuoteId);
            
            if( thisQLI.Discount > 0 && thisQLI.Discount != mapOfOldIdWithQuotesLineItems.get(thisQLI.Id).Discount ){
                quoteIdAndQLIMap.put(thisQLI.QuoteId, thisQLI);
            }
        }
        
        // added by Murali
       /* Schema.FieldSet fdlstForIdentity = Schema.SObjectType.QuoteLineItem.fieldSets.getMap().get('Identity_Related_Fields');     
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
                
                if( 
                    mapOfNewIdWithQuotesLineItems.get(thisNewQLI.Id).Identity_Resource_Metadata__c 
                    != mapOfOldIdWithQuotesLineItems.get(thisNewQLI.Id).Identity_Resource_Metadata__c  
                ){ 
                    newQuoteLineIteamObj.add(thisNewQLI);
                }
            } 
        }
        
        system.debug('newQuoteLineIteamObj'+newQuoteLineIteamObj);
       if(newQuoteLineIteamObj!=null && newQuoteLineIteamObj.size()>0){
            
            for(QuoteLineItem thisNewQLI : newQuoteLineIteamObj){
                QuoteLineItem newQLIRecord = thisNewQLI.clone(FALSE, FALSE, FALSE, FALSE);
                system.debug('CTX_LicensingConstants.IDENTITY_RESOURCE_CONSTRAINTS_FOR_QUOTE '+CTX_LicensingConstants.IDENTITY_RESOURCE_CONSTRAINTS_FOR_QUOTE);
                CTX_ClearResourceConstraintsClass.ReturnWrapper resourceDetailsWrapper = CTX_ClearResourceConstraintsClass.identityResourceConstraintsForQuoteLineItem(thisNewQLI.Identity_Resource_Metadata__c);
                newQLIRecord.Id = thisNewQLI.Id;
                Map<String, Object> resourceDetails = (Map<String, Object>)JSON.deserializeUntyped(resourceDetailsWrapper.identityResource);
                
                for( String thisSTR : resourceDetails.keySet() ){
                    newQLIRecord.put(
                        thisSTR, 
                        (Integer)resourceDetails.get(thisSTR)
                    );
                }
                
                newQLIRecord.Identity_Resource_Constraints__c = resourceDetailsWrapper.identityResource;
                system.debug('Stringified data identityData'+newQLIRecord.Identity_Resource_Constraints__c);
                newQLIRecord.UnitPrice = resourceDetailsWrapper.totalListPrice;
                newQLIRecord.Sale_Price__c = resourceDetailsWrapper.totalSellPrice;
                newQLIRecord.Total_cost_price_Identity__c = resourceDetailsWrapper.totalCostPrice;
                
                
                
                updateLineItemMap.put(newQLIRecord.Id, newQLIRecord);
                QLIListPrice.add(newQLIRecord);
            }
        }*/
        system.debug('Inside After Update');
       List<QuoteLineItem> identityQLI = IdentityItemHelper.QuoteLineIdentityCostUpdates(mapOfNewIdWithQuotesLineItems,mapOfOldIdWithQuotesLineItems);
        for(QuoteLineItem thisNewQLI : identityQLI){
            updateLineItemMap.put(thisNewQLI.Id, thisNewQLI);
            QLIListPrice.add(thisNewQLI);
        }
        // end by Murali
        
        Map<Id,Quote> quoteMap = new Map<Id,Quote>(
            [ SELECT Id, Status, IsSyncing, 
             Opportunity.RecordType.Name, Opportunity.Account.Channel_Partner_Account_Name__c,
             Opportunity.Is_Auto_Renewal_Enabled__c, Opportunity.Account.Is_Auto_Renewal_Enabled__c, Opportunity.SyncedQuoteId
             FROM Quote WHERE 
             Id IN :parentQuoteIdSet
            ]);
        System.debug('quoteMap :: '+quoteMap);
        
        /**	Auto Renewal Discount Approval Check : START	**/
        Map<Id, Quote> 			quoteMaptoUpdate 		= new Map<Id, Quote>();
        Map<Id, Opportunity> 	opportunityMaptoUpdate 	= new Map<Id, Opportunity>();
        
        for( Quote thisRec : quoteMap.values() ){
            if( thisRec.Opportunity.Is_Auto_Renewal_Enabled__c){
                
                if( quoteIdAndQLIMap.containsKey(thisRec.Id) ){
                    quoteMaptoUpdate.put(thisRec.Id, thisRec);
                    opportunityMaptoUpdate.put( thisRec.OpportunityId, new Opportunity( Id = thisRec.OpportunityId, SyncedQuoteId = NULL ) );
                }
            }
        }
        
        system.debug('opportunityMaptoUpdate: '+opportunityMaptoUpdate);
        system.debug('quoteIdAndQLIMap: '+quoteMaptoUpdate);
        
        
        if( opportunityMaptoUpdate.values().size() > 0 && quoteIdAndQLIMap.values().size() > 0 ){
            
            CTX_UnSyncQuoteOpportunity.unSyncQuoteAndUpdateOpportunity( 
                opportunityMaptoUpdate.keySet(), quoteMaptoUpdate.keySet()  
            );
        }
        /**	Auto Renewal Discount Approval Check : END	**/
        
        
        system.debug('afterUpdate QLI-->');
        for(Id quotekey:mapOfNewIdWithQuotesLineItems.keySet()){
            //if( (mapOfNewIdWithQuotesLineItems.get(quotekey).IsSyncing__c || mapOfNewIdWithQuotesLineItems.get(quotekey).OpportunityLineItemId != mapOfOldIdWithQuotesLineItems.get(quotekey).OpportunityLineItemId ) &&  ( mapOfOldIdWithQuotesLineItems.get(quotekey).OpportunityLineItemId == null ||
            system.debug('OPLI O '+mapOfOldIdWithQuotesLineItems.get(quotekey).OpportunityLineItemId);
            system.debug('OPLI N '+mapOfNewIdWithQuotesLineItems.get(quotekey).OpportunityLineItemId);
            system.debug('SP O '+mapOfOldIdWithQuotesLineItems.get(quotekey).Sale_Price__c);
            system.debug('SP N '+mapOfNewIdWithQuotesLineItems.get(quotekey).Sale_Price__c);
            system.debug('MU O '+mapOfOldIdWithQuotesLineItems.get(quotekey).MarkUp__c);
            system.debug('MU N '+mapOfNewIdWithQuotesLineItems.get(quotekey).MarkUp__c);
            if(mapOfNewIdWithQuotesLineItems.get(quotekey).IsSyncing__c &&
               !quoteIdAndQLIMap.containsKey( mapOfNewIdWithQuotesLineItems.get(quotekey).QuoteId ) &&
               (
                   mapOfNewIdWithQuotesLineItems.get(quotekey).Sale_Price__c !=mapOfOldIdWithQuotesLineItems.get(quotekey).Sale_Price__c ||
                   mapOfNewIdWithQuotesLineItems.get(quotekey).MarkUp__c  !=mapOfOldIdWithQuotesLineItems.get(quotekey).MarkUp__c || mapOfNewIdWithQuotesLineItems.get(quotekey).period_start_date__c  !=mapOfOldIdWithQuotesLineItems.get(quotekey).period_start_date__c
                   || mapOfNewIdWithQuotesLineItems.get(quotekey).period_end_date__c  !=mapOfOldIdWithQuotesLineItems.get(quotekey).period_end_date__c)){
                       listOfNewQuotes.add(mapOfNewIdWithQuotesLineItems.get(quotekey).Id);
                   }
            
            /** START : bhaveshjindal :: threshold price validation **/
            
            QuoteLineItem quoteLinekey = mapOfNewIdWithQuotesLineItems.get(quotekey);
            system.debug('quoteMap.get(quoteLinekey.QuoteId).Status : '+quoteMap.get(quoteLinekey.QuoteId).Status);
            if((quoteLinekey.Type_of_Integration__c != mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).Type_Of_Integration__c 
                || quoteLinekey.UnitPrice != mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).UnitPrice)
               && (quoteMap.get(quoteLinekey.QuoteId).Status != 'Discount Approval' 
                   && quoteMap.get(quoteLinekey.QuoteId).Status != 'Quote Accept')){
                       qliMapforThresholdPricesValidation.put(quoteLinekey.Id,quoteLinekey);
                   }
            
            /** END : bhaveshjindal :: threshold price validation **/
        }
        mapOfPrice = CTX_CustomStringToFormulaParser.CTX_CustomStringToFormulaParserMethod(
            productIdList, mapOfNewIdWithQuotesLineItems.values()
        );
        for(QuoteLineItem quoteLinekey:mapOfNewIdWithQuotesLineItems.values()){
            
            QuoteLineItem QLI;
            if( updateLineItemMap.containsKey(quoteLinekey.Id) ){
                QLI = updateLineItemMap.get(quoteLinekey.Id);
            } else{
                QLI = quoteLinekey.clone(false,true,false,false);
            }
            
            QLI.Id = quoteLinekey.Id;
            Boolean checkBool = FALSE;
            if((!String.ISBLANK(quoteLinekey.Line_Item_Type__c) && !System.label.Pricing_Applicable_RT.ToLowerCase().contains(quoteLinekey?.Line_Item_Type__c?.ToLowerCase() )) || 
               (quoteMap.get(quoteLinekey.QuoteId).Opportunity.Account?.Channel_Partner_Account_Name__c != NULL && quoteMap.get(quoteLinekey.QuoteId).Opportunity.Account?.Channel_Partner_Account_Name__c?.ToLowerCase()?.Contains('uneecop'))){
                   //QLI.Is_Formula_Price_Applicable__c = FALSE; 
                   checkBool = TRUE;
               }
            else if(quoteLinekey.Line_Item_Type__c != mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).Line_Item_Type__c){
                QLI.Is_Formula_Price_Applicable__c = TRUE;
                QLI.Product_Formula__c = productMap.get(quoteLinekey.Product2Id).Formula__c;
                checkBool = TRUE;
            }
            if(QLI.Is_Formula_Price_Applicable__c ){
                QLI.UnitPrice = mapOfPrice.get(quoteLinekey.Id);  
                
                checkBool = TRUE;
            }
            if(QLI.unitprice != mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).unitprice || QLI.Sale_Price__c != mapOfOldIdWithQuotesLineItems.get(quoteLinekey.Id).Sale_Price__c){
                QuoteLineItem QLI2 = quoteLineItemPricingCalculator.productPriceCalculator(QLI);
                if(QLI2 != NULL){
                    QLI=quoteLineItemPricingCalculator.productPriceCalculator(QLI);
                }
                
                checkBool = TRUE;
            }
            
            Decimal max = 0;
            
            if(checkBool){
                
                if( QLI.Manual_High_Value_in_List_Price_OF__c && !QLI.Calculate_based_on_List_Price_OF__c) {
                    max = Math.max(Math.max(QLI.unitprice , QLI.Sale_Price__c), QLI.List_Price_Order_Form__c);
                }
                
                if(!QLI.Manual_High_Value_in_List_Price_OF__c && 
                   !QLI.Calculate_based_on_List_Price_OF__c &&
                   QLI.List_Price_Order_Form__c == mapOfOldIdWithQuotesLineItems.get(QLI.Id).List_Price_Order_Form__c){
                       max = Math.max(QLI.unitprice , QLI.Sale_Price__c);
                   }
                
                QLI.List_Price_Order_Form__c = max != 0 ? max : QLI.List_Price_Order_Form__c;
                
                System.debug('@List_Price_Order_Form__c'+QLI.List_Price_Order_Form__c);
                
                updateLineItemMap.put(QLI.Id, QLI);
                QLIListPrice.add(QLI);
            }
        }
        
        if(updateLineItemMap.values().Size() > 0 ){
            
            update updateLineItemMap.values();
        }
        if(listOfNewQuotes.size()>0){
            QuoteLineItemHelper.updateCustomFieldsToOppLineItem(listOfNewQuotes);
        }
        if(qliMapforThresholdPricesValidation.values().size()>0){
            quoteLineItemHelper.thresholdPriceValidation(qliMapforThresholdPricesValidation);
        }
        
        //starts updpate made to update quote when there is integration product 
        List<QuoteLineItem> newIdWithQuotesLineItemsList =[Select id,Product2.Product_category__c, Discount,QuoteId ,Product2.Product_Line__c,Quote_Line_Item_Product_Category__c  from QuoteLineItem where id IN: mapOfNewIdWithQuotesLineItems.keyset()];
        Boolean isHasIntegrationQLI =true;
        for(QuoteLineItem quoteLineObj:newIdWithQuotesLineItemsList){
            system.debug('Quote_Line_Item_Product_Category---> '+quoteLineObj.Product2.Product_category__c);
            system.debug('Quote_Line_Item_Product_Category new---> '+quoteLineObj.Quote_Line_Item_Product_Category__c);
            system.debug('Quote_Line_Item_Product_Category old---> '+mapOfOldIdWithQuotesLineItems.get(quoteLineObj.ID).Quote_Line_Item_Product_Category__c);
            
            if(quoteLineObj.Product2.Product_category__c =='Integration' && quoteLineObj.Discount >15 && quoteLineObj.Product2.Product_Line__c != 'Max'){
                //system.debug('quoteLineObj.Quote_Line_Item_Product_Category'+quoteLineObj.Quote_Line_Item_Product_Category__c);
                parentQuoteIDsToBeUpdated.add(quoteLineObj.QuoteId);
                isHasIntegrationQLI=true;
            }else{
                parentQuoteIDsToBeUpdated.add(quoteLineObj.QuoteId);
                isHasIntegrationQLI=false;
            }
        }
        if(!parentQuoteIDsToBeUpdated.isEmpty()){
            system.debug('CTX_QuoteLineItemTriggerHelper called from update'+parentQuoteIDsToBeUpdated);
            try{
                CTX_QuoteLineItemTriggerHelper.updateQuotesForIntegrationQuoteLineItem(parentQuoteIDsToBeUpdated ,isHasIntegrationQLI);
            }
            catch(exception e){
                system.debug('Error Message : CTX_QuoteLineItemTriggerHelper : ' + e.getMessage() + 'line : ' + e.getLineNumber());
            }
        }
        
        //ends updpate made to update quote when there is integration product 
        
        /** ASHWIN : Multi-year tagging from Quote line item **/
        
        Map<Id,String>      productQuoteMap   = new Map<Id,String>();
        Map<Id,Boolean>     dupQlimap         = QuoteLineItemHelper.dupCheck(mapOfNewIdWithQuotesLineItems);
        
        for(QuoteLineItem qli : mapOfNewIdWithQuotesLineItems.values()){
            if(dupQlimap.get(qli.Id) == true){
                productQuoteMap.put(qli.QuoteId,qli.Product_Code__c);
            }
        }
        
        
        
        /** ASHWIN : Multi-year tagging from Quote line item **/ 
        
        
        /** START - ASHWIN - Update 10_hr_consultation_clause **/
        QuoteLineItemHelper.updateConsultationClause(mapOfNewIdWithQuotesLineItems);
        
        
        //Multiyear tag
        if(!productQuoteMap.isEmpty()){
            QuoteLineItemHelper.updateMultiYeartag(productQuoteMap);
        }  
    }
    
    public static void beforeDelete(List<Sobject> listOfOldSObjects,Map<Id,Sobject> mapOfOldSObjects){}
    
    public static void afterDelete(Map<Id,Sobject> mapOfOldSObjects){
        
        QuoteConstants.DISABLEQLIVAl = TRUE;
        
        Set<Id> parentQuoteIDsToBeUpdated= new Set<Id>();
        Map<Id,QuoteLineItem> mapOfDeletedIdWithQuotesLineItems=(Map<Id,QuoteLineItem>)mapOfOldSObjects;
        for(QuoteLineItem quoteLineObj:mapOfDeletedIdWithQuotesLineItems.values()){
            system.debug('Quote_Line_Item_Product_Category --->'+quoteLineObj.Quote_Line_Item_Product_Category__c);
            if(quoteLineObj.Quote_Line_Item_Product_Category__c =='Integration' && quoteLineObj.Discount >15 && quoteLineObj.Product2.Product_Line__c != 'Max'){
                system.debug('quoteLineObj.Quote_Line_Item_Product_Category---->'+quoteLineObj.Quote_Line_Item_Product_Category__c);
                parentQuoteIDsToBeUpdated.add(quoteLineObj.QuoteId);
            }
        }
        if(!parentQuoteIDsToBeUpdated.isEmpty()){
            system.debug('CTX_QuoteLineItemTriggerHelper called from update ---->'+parentQuoteIDsToBeUpdated);
            CTX_QuoteLineItemTriggerHelper.updateQuotesForIntegrationQuoteLineItem(parentQuoteIDsToBeUpdated ,false);
        }
        
        /** ASHWIN : Multi-year tagging from Quote line item **/
        
        Map<Id,String> productQuoteMap = new Map<Id,String>();
        Map<Id,Boolean> dupQlimap = QuoteLineItemHelper.dupCheck(mapOfDeletedIdWithQuotesLineItems);
        
        for(QuoteLineItem qli : mapOfDeletedIdWithQuotesLineItems.values()){
            if(dupQlimap.get(qli.Id) == true){
                productQuoteMap.put(qli.QuoteId,qli.Product_Code__c);
            }
        }
        
        System.debug('productQuoteMap-->'+productQuoteMap);
        if(!productQuoteMap.isEmpty()){
            QuoteLineItemHelper.updateMultiYeartag(productQuoteMap);
        } 
        
        /** ASHWIN : Multi-year tagging from Quote line item **/
        
        /** START - ASHWIN - Update 10_hr_consultation_clause **/
        QuoteLineItemHelper.updateConsultationClause(mapOfDeletedIdWithQuotesLineItems);
        
        //update number of arr on quote
        quoteLineItemHelper.updateArrCountOnQuote(mapOfDeletedIdWithQuotesLineItems);
        
    }
    
    public static void afterUndelete(List<Sobject> listOfNewSObjects,Map<Id,Sobject> mapOfNewSObjects){}
    
    
}