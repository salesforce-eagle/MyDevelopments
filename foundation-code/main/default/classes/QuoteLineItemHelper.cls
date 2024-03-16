public class QuoteLineItemHelper {
    /** public Static void calculateUnitPrice(List<QuoteLineItem> listOfNewQuoteLineItem, boolean isInsert){
         quoteLineItemPricingCalculator.productPriceCalculator(listOfNewQuoteLineItem, isInsert);
     }**/
     @Future
     Public static void updateCustomFieldsToOppLineItem(set<Id> setOfQuoteLineItem){
         system.debug('Called ');
         List<QuoteLineItem> listOfNewQuoteLineItem = new List<QuoteLineItem>();
         listOfNewQuoteLineItem = [SELECT Id, OpportunityLineItemId, MarkUp__c, Sale_Price__c, Discount,Period_End_date__c,
                                   Period_Start_date__c,Product_Code__c, Type_Of_Integration__c, Stage_in_MY__c, SOW_Start_Date__c, SOW_End_Date__c
                                   FROM QuoteLineItem WHERE Id IN: setOfQuoteLineItem];
         list<opportunityLineItem> listOfOppLineItemToUpdate = new list<opportunityLineItem>();
         for(QuoteLineItem tempQuoteLineItem : listOfNewQuoteLineItem){
             listOfOppLineItemToUpdate.add(new opportunityLineItem(Id = tempQuoteLineItem.OpportunityLineItemId,Sale_Price__c = tempQuoteLineItem.Sale_Price__c, MarkUp__c = tempQuoteLineItem.MarkUp__c, Discount = tempQuoteLineItem.Discount , 
                                                                   Period_End_date__c = tempQuoteLineItem.Period_End_date__c,Period_Start_date__c = tempQuoteLineItem.Period_Start_date__c,Product_Code__c = tempQuoteLineItem.Product_Code__c , 
                                                                   Type_of_Integration__c = tempQuoteLineItem.Type_Of_Integration__c, Stage_in_MY__c = tempQuoteLineItem.Stage_in_MY__c, SOW_Start_Date__c = tempQuoteLineItem.SOW_Start_Date__c,
                                                                   SOW_End_Date__c = tempQuoteLineItem.SOW_End_Date__c,Related_QLI__c = tempQuoteLineItem.Id
                                                                  ));
             
         }
         if(listOfOppLineItemToUpdate.size()>0){
             update listOfOppLineItemToUpdate;
         }
         //OpportunityLineItemId
     }
     Public static void showError( Map<Id,QuoteLineItem> mapOfQuotesLineItemsWithParentQuoteId,string beforeupdateInsert){
         system.debug('Called ');
         
         List<quote> listOfParentQuotes=[select Id, Status from quote where Id IN: mapOfQuotesLineItemsWithParentQuoteId.keySet()];
         for(Quote thisQuote : listOfParentQuotes){
             if(thisQuote.status =='Discount Approval'||thisQuote.status =='Quote Accept' ){
                 if(beforeupdateInsert=='beforeInsert'){
                     mapOfQuotesLineItemsWithParentQuoteId.get(thisQuote.Id).addError(System.Label.No_Product_to_add);
                 }else{
                     mapOfQuotesLineItemsWithParentQuoteId.get(thisQuote.Id).addError(System.Label.No_Product_to_edit);
                 }
                 
             }  
         }
         //OpportunityLineItemId
     }
     
     /** START :: bhaveshjindal :: Update Threshold Limit on QLI Based on Type Of Integration **/
     Public static void updateThresholdPriceForIntegrationQLI(Map<Id,QuoteLineItem> newQuoteLineItemMap){
         
         Map<String,Map<String,Integer>> prodModuleToMapOfThreshold = new Map<String,Map<String,Integer>>();
         for(
             QLI_Type_Of_Integration_Threshold__mdt  thisRec : [ SELECT Id, Product_Module__c , Threshold_List_Price__c , Type_of_Integration__c  
                                                                FROM QLI_Type_Of_Integration_Threshold__mdt ]
         ){
             if(prodModuleToMapOfThreshold.containsKey(thisRec.Product_Module__c)){
                 
                 Map<String, Integer> internalMapOfTypeOfIntegrationAndThreshold = prodModuleToMapOfThreshold.get(thisRec.Product_Module__c);
                 internalMapOfTypeOfIntegrationAndThreshold.put(thisRec.Type_of_Integration__c, (Integer)thisRec.Threshold_List_Price__c);
                 prodModuleToMapOfThreshold.put(thisRec.Product_Module__c, internalMapOfTypeOfIntegrationAndThreshold);
             } else{
                 prodModuleToMapOfThreshold.put(thisRec.Product_Module__c, new Map<String, Integer>{thisRec.Type_of_Integration__c => (Integer)thisRec.Threshold_List_Price__c});
             }
         }
         
         System.debug('prodModuleToMapOfThreshold :: '+prodModuleToMapOfThreshold);
         Map<Id,QuoteLineItem> QliMap = new Map<id,QuoteLineItem>([SELECT Id, Product2.Threshold_List_Price__c, Product2.Module_for_Type_of_Integration_Threshold__c FROM QuoteLineItem WHERE Id IN : newQuoteLineItemMap.keySet()]);
         
         System.debug('QliMap :: '+QliMap);
         for(Id thisQliId : newQuoteLineItemMap.keySet()){
             QuoteLineItem newQli = newQuoteLineItemMap.get(thisQliId);
             System.debug('newQli :: '+newQli);
             System.debug('newQli.Type_of_Integration__c :: '+newQli.Type_of_Integration__c);
             
             Integer totalThresholdListPrice = 0;
             if(newQli.Type_of_Integration__c != NULL){
                 for(String typeOfIntegrationInstance : newQli.Type_of_Integration__c.split(';')){
                     if(prodModuleToMapOfThreshold.get(QliMap.get(thisQliId).Product2.Module_for_Type_of_Integration_Threshold__c) != NULL 
                        && prodModuleToMapOfThreshold.get(QliMap.get(thisQliId).Product2.Module_for_Type_of_Integration_Threshold__c).get(typeOfIntegrationInstance) != NULL){
                            System.debug('(QliMap.get(thisQliId) :: '+QliMap.get(thisQliId));
                            System.debug('prodModuleToMapOfThreshold.get(QliMap.get(thisQliId) :: '+prodModuleToMapOfThreshold.get(QliMap.get(thisQliId).Product2.Module_for_Type_of_Integration_Threshold__c));
                            totalThresholdListPrice = totalThresholdListPrice + prodModuleToMapOfThreshold.get(QliMap.get(thisQliId).Product2.Module_for_Type_of_Integration_Threshold__c).get(typeOfIntegrationInstance);
                            System.debug('totalThresholdListPrice :: '+totalThresholdListPrice);
                        }
                 }
                 if(totalThresholdListPrice == 0){
                     totalThresholdListPrice = (Integer)QliMap.get(thisQliId).Product2.Threshold_List_Price__c;
                 }
                 
                 newQli.TOI_Calculated_Threshold_LP__c = totalThresholdListPrice;
             }
         }
         
     }
     
     /** END :: bhaveshjindal :: Update Threshold Limit on QLI Based on Type Of Integration **/
     
     /** START :: bhaveshjindal :: Update Threshold Error **/
     public static void thresholdPriceValidation(Map<Id,QuoteLineItem> newQuoteLineItemMap){
         for(Id thisRecId : newQuoteLineItemMap.keySet()){
             QuoteLineItem newQLI = newQuoteLineItemMap.get(thisRecId);
             System.debug('newQLI.UnitPrice :: '+newQLI.UnitPrice);
             System.debug('newQLI.Threshold_List_Price__c :: '+newQLI.Threshold_List_Price__c);
             if((newQLI.UnitPrice < newQLI.Threshold_List_Price__c || newQLI.UnitPrice == 0)
                && !System.Label.Threshold_Price_Profiles.Contains(userInfo.getProfileId()) ){
                    system.debug('threshold condition entered');
                    if(newQLI.Type_of_Integration__c != null){
                        newQLI.addError('List Price Value can not be less than Threshold List Price of the Product! i.e, '+newQLI.Threshold_List_Price__c + ' for selected Type of Integration ' + newQLI.Type_of_Integration__c);
                    }else{
                        newQLI.addError('List Price Value can not be less than Threshold List Price of the Product! i.e, '+newQLI.Threshold_List_Price__c);
                    }
                }
         }
     }
     /** END :: bhaveshjindal :: Update Threshold Error **/
     
     /** START :: bhaveshjindal :: SOW Dates For MS SKU Error **/
     public static void sowDatesForMsSkuValidation(Map<Id,QuoteLineItem> newQuoteLineItemMap){
         Map<Id,QuoteLineItem> qliMap = new Map<Id,QuoteLineitem>([SELECT Id, Product2.Product_Category__c FROM QuoteLineItem WHERE ID IN :newQuoteLineItemMap.keySet()]);
         for(Id thisRecId : newQuoteLineItemMap.keySet()){
             QuoteLineItem newQLI = newQuoteLineItemMap.get(thisRecId);
             System.debug('newQLI.SOW_Start_Date__c :: '+newQLI.SOW_Start_Date__c);
             System.debug('newQLI.SOW_End_Date__c :: '+newQLI.SOW_End_Date__c);
             if(qliMap.get(thisRecId).Product2.Product_Category__c == 'MS' 
                && newQLI.SOW_Start_Date__c == NULL || newQLI.SOW_End_Date__c == NULL){
                    system.debug('SOW Validation condition entered');
                    newQLI.addError('Please Enter SOW Start Date And SOW End Date');
                }
         }
     }
     /** END :: bhaveshjindal :: SOW Dates For MS SKU Error **/
     
     /** START : ASHWIN : Multi-year tagging from Quote line item - SAL-667 **/
     
     public static Map<Id,Boolean> dupCheck(Map<Id,QuoteLineItem> qliMap){
         
         Map<Id,Boolean> 				isDupExist 			= new Map<Id,Boolean>();
         Set<Id> 						QuoteIdSet	 	= new Set<id>();
         Map<Id,List<String>> 			quoteProductCodemap 	= new Map<Id,List<String>>();
         
         for(QuoteLineItem qli : qliMap.values()){
             QuoteIdSet.add(qli.QuoteId);
         }
         
         
         for(QuoteLineItem thisRec : [SELECT Id, QuoteId, Product_Code__c 
                                      from QuoteLineItem 
                                      where QuoteId IN :QuoteIdSet 
                                      AND Id NOT IN :qliMap.keySet()])
         {
             if(quoteProductCodemap.containsKey(thisRec.QuoteId)){
                 quoteProductCodemap.get(thisRec.QuoteId).add(thisRec.Product_Code__c);
             }else{
                 quoteProductCodemap.put(thisRec.QuoteId, new List<String> {thisRec.Product_Code__c});
             }
         }
         
         System.debug('quoteProductCodemap-->'+quoteProductCodemap);
         
         for(QuoteLineItem thisRec : qliMap.values()){
             if(quoteProductCodemap.containskey(thisRec.QuoteId)){
                 if(quoteProductCodemap.get(thisRec.QuoteId).contains(thisRec.Product_Code__c)){
                     isDupExist.put(thisRec.Id, True);
                 }
             }  
         } 
         
         return isDupExist;
         
     }
     
     
     public static void updateMultiYeartag(Map<Id,String> productQuoteMap){
         System.debug('<< UPDATE MULTI-YEAR TAG >>');
         Map<String, List<QuotelineItem>> 		productQliMap 		= new Map<String, List<QuotelineItem>>();
         List<QuoteLineItem> 					qliList 			= new List<QuoteLineItem>();
         List<qliWrapper> 						sortableQli 		= new List<qliWrapper>();
         
         for(QuoteLineItem qli : [SELECT id, QuoteId, Product_Code__c,Period_End_date__c,Period_Start_date__c, Platform__c
                                  from QuoteLineItem 
                                  where QuoteId IN : productQuoteMap.keySet()])
         {
             if(productQuoteMap.containskey(qli.QuoteId) 				&& 
                productQuoteMap.get(qli.QuoteId) == qli.Product_Code__c) 
             {
                 String productQuoteName = qli.Product_Code__c+qli.QuoteId;
                 
                 if(productQliMap.containsKey(productQuoteName)){
                     productQliMap.get(productQuoteName).add(qli);  
                 }else{
                     productQliMap.put(productQuoteName, new List<QuoteLineItem> {qli});
                 }
                 
             }
         }
         
         System.debug('productQliMap-->'+productQliMap);
         for(String str : productQliMap.keySet()){
             if(str != NULL){
                 
                 for(QuotelineItem qli : productQliMap.get(str)){
                     sortableQli.add(new qliWrapper(qli)); 
                 }
                 
                 sortableQli.sort();
                 System.debug('sortableQli-->'+sortableQli);
                 
                 for(QuotelineItem qli : productQliMap.get(str)){
                     qli.Platform__c = 'ASP/GSP';
                     if(qli.Period_Start_date__c != NULL && qli.Period_End_date__c != NULL){
                         Integer qliSize = sortableQli.size();
                         QuotelineItem firstQli = sortableQli[0].quoteline;
                         QuotelineItem lastQli = sortableQli[qliSize-1].quoteline;
                         
                         if(qli.id == firstQli.Id){
                             qli.Stage_in_MY__c  = 'Year 1';
                         }else if(qli.id == lastQli.Id){
                             qli.Stage_in_MY__c = 'Last Year';
                         }else {
                             qli.Stage_in_MY__c = 'Middle Year';
                         } 
                         
                         qliList.add(qli);
                     }
                     
                 }
             }
         }
         System.debug('qliList->'+qliList);
         if(!qliList.isEmpty()){
             update qliList;
         }
     }
     
     public class qliWrapper implements Comparable {
         
         private final QuotelineItem quoteLine;
         
         public qliWrapper(QuotelineItem qli){
             quoteLine = qli;
         }
         
         public integer compareTo(Object compareTo){
             qliWrapper compareQli = (qliWrapper)compareTo;
             
             Integer returnVal = 0;
             
             if(quoteLine.Period_Start_date__c > compareQli.quoteLine.Period_Start_date__c){
                 returnVal = 1;
             }else if(quoteLine.Period_Start_date__c < compareQli.quoteLine.Period_Start_date__c){
                 returnVal = -1;
             }
             
             return returnVal;
         }
     } 
     
     /** END : ASHWIN : Multi-year tagging from Quote line item **/
     
     /** START - ASHWIN - Update 10_hr_consultation_clause **/
     public static void updateConsultationClause(Map<Id,QuoteLineItem> mapOfNewIdWithQuotesLineItems){
         
         Set<Id> 					quoteId 						= new Set<Id>();
         Set<Id> 					quoteIdSetToActivate 			= new Set<Id>();
         Set<Id> 					quoteIdSetToInactivate 			= new Set<Id>();
         Map<Id,Set<String>> 		quoteProductMap 				= new Map<Id,Set<String>>();
         List<Quote> 				quoteList 						= new List<Quote>();
         Map<Id,List<QuoteLineItem>> quoteQliMap = new Map<Id,List<QuoteLineItem>>();
         
         for(QuoteLineItem qli : mapOfNewIdWithQuotesLineItems.values()){
             quoteId.add(qli.QuoteId);
         }
         
         for(QuoteLineItem qli : [SELECT Id, Product_Code__c, Type_of_Integration__c, 
                                  QuoteId, Sale_Price__c,
                                  Quote.X10_hr_consultation_clause__c
                                  FROM QuoteLineItem
                                  WHERE QuoteId IN :quoteId])
         {
             if(quoteQliMap.containsKey(qli.QuoteId)){
                 quoteQliMap.get(qli.QuoteId).add(qli);
             }else{
                 quoteQliMap.put(qli.QuoteId, new List<QuoteLineItem> {qli});
             }
         }
         
         for(Id thisQuote : quoteId){
             
             for(QuoteLineItem qli : quoteQliMap.get(thisQuote)){
                 
                 if(qli.Product_Code__c 	    			== 'INTGR_EWB_ASP_API'  				||
                    qli.Product_Code__c 					== 'INTGR_Einv_ASP_API'  				|| 
                    qli.Product_Code__c 					== 'INTGR_EINV-EWB_ASP_API')
                 {
                     
                     if(qli.Type_of_Integration__c 		== 'API- Only by Customer'				&&
                        qli.Sale_Price__c    			<= 20000)
                     {
                         quoteIdSetToActivate.add(qli.QuoteId);
                     }   
                 }
             }
             
             if(!quoteIdSetToActivate.contains(thisQuote)){
                 quoteIdSetToInactivate.add(thisQuote);
             }
             
         }
         
         System.debug('#quoteIdSetToActivate'+quoteIdSetToActivate);
         System.debug('#quoteIdSetToInactivate'+quoteIdSetToInactivate);
         
         
         for(Quote thisQuote : [SELECT Id, Opportunity_Owner_User_Category__c, X10_hr_consultation_clause__c 
                                FROM Quote 
                                WHERE Id IN :quoteIdSetToActivate OR Id IN :quoteIdSetToInactivate])
         {
             if(quoteIdSetToActivate.contains(thisQuote.Id)){
                 System.debug('#activate');
                 if(thisQuote.Opportunity_Owner_User_Category__c == 'EC' 			||
                    thisQuote.Opportunity_Owner_User_Category__c == 'TL_EC' 			||
                    thisQuote.Opportunity_Owner_User_Category__c == 'PBM' 			||
                    thisQuote.Opportunity_Owner_User_Category__c == 'TL_Channel')
                 {
                     if(thisQuote.X10_hr_consultation_clause__c == False)
                     {
                         thisQuote.X10_hr_consultation_clause__c = True;
                         quoteList.add(thisQuote);
                     }
                 }
                 else if(thisQuote.X10_hr_consultation_clause__c == True)
                 {
                     thisQuote.X10_hr_consultation_clause__c = False;
                     quoteList.add(thisQuote);
                 }
             }
             
             if(quoteIdSetToInactivate.contains(thisQuote.Id) && thisQuote.X10_hr_consultation_clause__c == True){
                 System.debug('#Inactivate');
                 thisQuote.X10_hr_consultation_clause__c = False;
                 quoteList.add(thisQuote);
             }
         }
         
         System.debug('#quoteList'+quoteList);
         if(!quoteList.isEmpty()){
             update quoteList;
         }
     }
     
     /** START :: bhaveshjindal :: update number of arrs under a quote **/
     public static void updateArrCountOnQuote(Map<Id,QuoteLineItem>newQliMap){
         Map<Id,Integer> quoteWithCount = new Map<Id,Integer>();
         Set<Id> QuoteIds = new Set<Id>();
         for(QuoteLineItem thisQli : newQliMap.Values()){
             quoteIds.add(thisQli.QuoteId);
         }
         for(AggregateResult thisQli : [SELECT count(id) idCount, quoteId FROM QuoteLineItem 
                                        WHERE Product2.billing_type__c = 'ARR'  AND (Stage_in_MY__c = NULL OR Stage_in_MY__c = 'Year 1')
                                        AND QuoteId IN: quoteIds
                                        GROUP BY QuoteId])
         {
             quoteWithCount.put((Id)thisQli.get('quoteId'),(Integer)thisQli.get('idCount'));
         }
         system.debug('quoteWithCount :: '+quoteWithCount);
         
         Set<Quote> QuotesToUpdate = new Set<Quote>();
         for(Id quoteId : quoteIds){
             if(quoteWithCount != Null && quoteWithCount.containsKey(quoteId)){
                 Quote newQuote = new Quote(id = quoteId);
                 newQuote.Number_of_ARRs__c = quoteWithCount.get(quoteId);
                 QuotesToUpdate.add(newQuote);
             }
         }
         if(QuotesToUpdate.size()>0){
             Update new List<Quote>(QuotesToUpdate);
         }
     }
     /** END :: bhaveshjindal :: update number of arrs under a quote **/
     
     /** START :: Ashwin :: update Duration And EndDate **/
     public static void updateDurationAndEndDate(List<QuoteLineItem> qliList){
         for(QuoteLineItem thisRec : qliList){
             if(thisRec.Quote_Line_Item_Billing_Type__c == 'OTP'){
                 if(thisRec.Quote_Line_Item_Product_Category__c  == 'Integration'){
                     if(thisRec.Type_of_Integration__c != NULL){
                         if(thisRec.Type_of_Integration__c.contains('API- Only by Customer') ||
                            thisRec.Type_of_Integration__c.contains('FTP/SFTP - Only by customer')){
                                if(thisRec.Quote_Line_Item_Product_Line__c 		== 'GST' ||
                                   thisRec.Quote_Line_Item_Product_Line__c 		== 'Invoice Discounting' ||
                                   thisRec.Quote_Line_Item_Product_Line__c 		== 'Max' ||
                                   thisRec.Quote_Line_Item_Product_Line__c 		== 'E-invoicing & E-Way Bill'){
                                       if( thisRec.Product2Id == '01tC5000000MAFaIAO' ){
                                          thisRec.Duration__c = (thisRec.Duration__c == NULL || thisRec.Duration__c < 14) ? 14 : thisRec.Duration__c;
                                       } else{
                                          thisRec.Duration__c = 60; 
                                       }
                                   }else if(thisRec.Quote_Line_Item_Product_Line__c == 'Clear Capture'){
                                       thisRec.Duration__c = 90;
                                   }
                                
                            }
                     }else{
                         
                         if(thisRec.Quote_Line_Item_Product_Line__c 		== 'GST' ||
                            thisRec.Quote_Line_Item_Product_Line__c 		== 'Invoice Discounting'){
                                thisRec.Duration__c = 60;
                            }else if(thisRec.Quote_Line_Item_Product_Line__c == 'Max' || 
                                     thisRec.Quote_Line_Item_Product_Line__c == 'Clear Capture'){
                                         thisRec.Duration__c = 90;
                                     }else if(thisRec.Quote_Line_Item_Product_Line__c == 'E-invoicing & E-Way Bill'){
                                         if( thisRec.Product2Id == '01tC5000000MAFaIAO' ){
                                            thisRec.Duration__c = (thisRec.Duration__c == NULL || thisRec.Duration__c < 14) ? 14 : thisRec.Duration__c;
                                       } else{
                                          thisRec.Duration__c = 45; 
                                       }
                                     }
                         
                     }
                     
                     if(thisRec.Period_Start_date__c != NULL && thisRec.Duration__c != NULL){
                         thisRec.Period_End_date__c = thisRec.Period_Start_date__c + (Integer)thisRec.Duration__c;
                     }
                 }
             }
         
             
             
         }
         
     }
     
     public static void updateSowDriveLink(List<QuoteLineItem> qliList){
         
         Set<Id> productIds = new Set<Id>();
         Map<Id, List<Product_ScopeOfService_Junction__c>> productSosJunctionMap = new Map<Id, List<Product_ScopeOfService_Junction__c>>();
         
         for(QuoteLineItem qli : qliList){
             productIds.add(qli.Product2Id);
         }
         
         for(Product_ScopeOfService_Junction__c  thisRec : [SELECT Id, Product__c, Type_of_Integration__c, SOS_URL__c  
                                                            FROM Product_ScopeOfService_Junction__c
                                                            WHERE Product__c IN :productIds])
         {
             if(productSosJunctionMap.containsKey(thisRec.Product__c)){
                productSosJunctionMap.get(thisRec.Product__c).add(thisRec); 
             }else{
                 productSosJunctionMap.put(thisRec.Product__c, new List<Product_ScopeOfService_Junction__c> {thisRec});
             }
         }
         
         for(QuoteLineItem qli : qliList){
             if(productSosJunctionMap.containsKey(qli.Product2Id)){
                 for(Product_ScopeOfService_Junction__c thisRec : productSosJunctionMap.get(qli.Product2Id)){
                     if(thisRec.SOS_URL__c != NULL){
                         if(thisRec.Type_of_Integration__c != NULL){
                             if(qli.Type_of_Integration__c != NULL &&
                                qli.Type_of_Integration__c.contains(thisRec.Type_of_Integration__c)){
                                    qli.SOW_Drive_Link__c = thisRec.SOS_URL__c;
                                } 
                         }else{
                             qli.SOW_Drive_Link__c = thisRec.SOS_URL__c;
                         }
                     }
                     
                 }
             }
         }
     }
     
     
 }