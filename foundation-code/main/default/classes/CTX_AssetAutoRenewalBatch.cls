/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_AssetAutoRenewalBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    Public String 	queryString;
    public List<Id> parentIdList = new List<Id>();
    
    Public CTX_AssetAutoRenewalBatch( String query ){
        this.queryString = query;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        if( queryString == NULL && queryString == '' ){
            system.debug('Inside Null Query CTX_AssetAutoRenewalBatch');
            Date assetWillExpireInNext3Months=System.today()+90;
            Date today=System.today();
            String Integration = 'Integration';
            String billingType = 'OTP';
            String upcomingRenewal = 'Upcoming Renewal';
            List<String> assetStatusChurn = new List<String>{AssetConstants.STATUS_CHURN,AssetConstants.RENEWED,AssetConstants.STATUS_VALID_RENEWED,'Sales return',AssetConstants.STATUS_EXPERIED};
                List<Asset> listOfTodayExpiredAssets=new List<Asset>();
            List<Asset> ChildAsset=[select id,parentId,Parent_Asset_2__c,Parent_Asset_3__c,Parent_Asset_4__c from asset where 
                                    ( parentid != NULL AND (Parent.UsageEndDate <=:assetWillExpireInNext3Months AND Parent.UsageEndDate >=:Today)) or 
                                    (Parent_Asset_2__c != NULL AND (Parent_Asset_2__r.UsageEndDate <=:assetWillExpireInNext3Months AND Parent_Asset_2__r.UsageEndDate >=:Today)) or  
                                    (Parent_Asset_3__c != NULL AND (Parent_Asset_3__r.UsageEndDate <=:assetWillExpireInNext3Months AND Parent_Asset_3__r.UsageEndDate >=:Today)) or 
                                    (Parent_Asset_4__c != NULL AND (Parent_Asset_4__r.UsageEndDate <=:assetWillExpireInNext3Months AND Parent_Asset_4__r.UsageEndDate >=:Today))
                                    limit 50000];
            list<id> ParentIdList = new list<id>();
            for (asset assIns : ChildAsset){
                if(assIns.parentId != NULL)
                    ParentIdList.add(assIns.parentId);
                if(assIns.Parent_Asset_2__c != NULL)
                    ParentIdList.add(assIns.Parent_Asset_2__c);
                if(assIns.Parent_Asset_3__c != NULL)
                    ParentIdList.add(assIns.Parent_Asset_3__c);
                if(assIns.Parent_Asset_4__c != NULL)
                    ParentIdList.add(assIns.Parent_Asset_4__c);
            }
            Integer limitSOQL= integer.valueOf(label.limitSOQL);
            queryString ='SELECT Id, ContactId, Opportunity__r.Account.Enable_GST_Auto_Renewal__c, Opportunity__r.Account.Enable_E_Invoicing_Auto_Renewal__c, Opportunity__r.Account.TDS_Percent_Applicable__c, Opportunity__r.Account.TDS__c, CurrencyISOCode,Renewal_Opportunity__c, AccountId,account.parentId, Account.Is_Auto_Renewal_Enabled__c, ParentId, Parent_Asset_2__c,Parent_Asset_3__c,Parent_Asset_4__c, RootAssetId, Product2Id, ProductCode, IsCompetitorProduct,  IsDeleted, Name, SerialNumber, InstallDate, PurchaseDate, UsageEndDate, Status, Price, Quantity, Description, OwnerId, AssetProvidedById, AssetServicedById, IsInternal, AssetLevel, StockKeepingUnit, LastViewedDate, LastReferencedDate, Onboarding_status__c, Usage_status__c, Integration_status__c, Opportunity__c, Managed_Service_Head__c, BackEndQuoteDiscount__c,BackEndQuote__c,LastModifiedDate,Multi_year__c,account.country_of_origin__c,Product2.isactive, Opportunity_Record_Type_of_this_asset__c,Billing_Frequency_for_Subscription_Fee__c, Billing_Frequency_for_Service_Fee_OTP__c, Billing_Frequency_for_Integration_Prods__c, Billing_Method__c, Place_of_Supply__c, Payment_Method__c, Payment_Term__c, Legal_Entity_Name_Of_The_Client__c, Opportunity__r.Custom_Billing_Freq_for_Integration_Prod__c, Opportunity__r.Order_Id_Only_If_Razorpay_Payment__c,Opportunity__r.Term_Months__c, Opportunity__r.PO_Required__c,Opportunity__r.PO_Amount__c,Opportunity__r.Renewal_Clause_Required__c,Opportunity__r.TAN__c,Opportunity__r.CIN__c,Opportunity__r.If_SEZ__c,Opportunity__r.Special_Terms__c,Billing_Address__c, Shipping_Address__c,Opportunity__r.Renewal_Charge__c, Opportunity__r.PAN_No_as_per_PO__c,Opportunity__r.Billing_GST__c,Opportunity__r.Stage_Comments__c,Opportunity__r.Unique_features_present_in_competition_s__c,Opportunity__r.Deal_Push_Comments__c,Opportunity__r.Reasons_for_deal_closure__c,Opportunity__r.Customer_Billing_Name_as_Per_PO__c,Opportunity__r.PO_number__c,Opportunity__r.PO_Received_Date__c,Opportunity__r.Document_No_LOE_No__c, Product2.Product_Line__c, Product2.Plan_Tier__c FROM Asset';
            queryString += ' WHERE Billing_Type__c != :billingType AND Status !=: assetStatusChurn AND( Renewal_Opportunity__c = null OR Status !=:upcomingRenewal)  AND UsageEndDate <=:assetWillExpireInNext3Months AND UsageEndDate >=:Today AND (Id  NOT IN: ParentIdList OR Multi_year__c = true) AND Is_Test_Asset__c = FALSE   ORDER BY UsageEndDate  ASC limit  '+limitSOQL ;
            
        } else{
            system.debug('Inside Non Null Query CTX_AssetAutoRenewalBatch: '+queryString);
        }
        
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        if(scope.size()>0){
            createOpportunityQuoteQuoteLineItem((List<Asset>)scope);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
    public void execute(SchedulableContext sc){
        database.executeBatch(new CTX_AssetAutoRenewalBatch(NULL), 50);
    }
    
    @AuraEnabled
    //This method will clone the related Opportunity, Quote, Quote Line Item Record on the Account that the Assit Expires Today 
    public static Opportunity createOpportunityQuoteQuoteLineItem(List<Asset> listOfTodayExpiredAssets){
        
        List<String>		autoRenewalEnabledPlanTiers			= new List<String>{ 'EINVOICE_STANDARD', 'EINVOICE_ULTIMATE', 'CLEAR_GST_ADVANTAGE', 'CLEAR_GST_PREMIUM', 'CLEAR_GST_ULTIMATE' };
            Id 					PriceBookId;
        List<Account> 		listOfAccount 				= new List<Account>();
        List<User> 			listOfUser 					= new List<User>();
        set<Id> 			setProductIds				= new Set<Id>();
        set<Id> 			setOfAccountId				= new Set<Id>();
        set<Id> 			setOfOwnerId				= new Set<Id>();
        Set<Id> 			setOfQuoteIds 				= new Set<Id>();
        Map<Id,Opportunity>	mapOfNewRenewalOpportunites	= new Map<Id,Opportunity>();
        Map<Id,Asset> 		mapOfAssets					= new Map<Id,Asset>((List<Asset>)listOfTodayExpiredAssets);
        Map<Id,Asset> 		mapOfAssetsMultiYear 		= new Map<Id,Asset>([ SELECT id,multi_year__c,UsageEndDate,account.country_of_origin__c,Opportunity_Record_Type_of_this_asset__c,OwnerId,
                                                                             Billing_Frequency_for_Subscription_Fee__c, Billing_Frequency_for_Service_Fee_OTP__c, Billing_Frequency_for_Integration_Prods__c, 
                                                                             Billing_Method__c, Place_of_Supply__c, Payment_Method__c, Payment_Term__c, Legal_Entity_Name_Of_The_Client__c, 
                                                                             Opportunity__r.Country_of_Origin__c,Product2.Product_Line__c,Account.Account_Owner_Cimplifive__c, 
                                                                             Opportunity__r.Custom_Billing_Freq_for_Integration_Prod__c, Opportunity__r.Order_Id_Only_If_Razorpay_Payment__c,
                                                                             Opportunity__r.Term_Months__c, Opportunity__r.PO_Required__c,Opportunity__r.PO_Amount__c,Opportunity__r.Renewal_Clause_Required__c,
                                                                             Opportunity__r.TAN__c,Opportunity__r.CIN__c,Opportunity__r.If_SEZ__c,Opportunity__r.Special_Terms__c,Billing_Address__c, Shipping_Address__c,
                                                                             Opportunity__r.Renewal_Charge__c, Opportunity__r.PAN_No_as_per_PO__c,Opportunity__r.Billing_GST__c,Opportunity__r.Stage_Comments__c,
                                                                             Opportunity__r.Unique_features_present_in_competition_s__c,Opportunity__r.Deal_Push_Comments__c,Opportunity__r.Reasons_for_deal_closure__c,
                                                                             Opportunity__r.Customer_Billing_Name_as_Per_PO__c,Opportunity__r.PO_number__c,Opportunity__r.PO_Received_Date__c,Opportunity__r.Document_No_LOE_No__c,
                                                                             Opportunity__r.E_Sign_Customer_Info__c,Opportunity__r.Billing_Address__c,Opportunity__r.Shipping_Address__c,Opportunity__r.Legal_Entity_Name_Of_The_Client__c,
                                                                             Opportunity__r.State_2__c,
                                                                             Opportunity__r.Account.TDS_Percent_Applicable__c, Opportunity__r.Account.TDS__c
                                                                             FROM ASSET 
                                                                             WHERE ID in : listOfTodayExpiredAssets ]);// Added as multi year field was coming blank for AssetRenew componenet
        
        if(!Test.isRunningTest()){
            PriceBookId =[ SELECT Id FROM PriceBook2 WHERE IsStandard = TRUE LIMIT 1 ].Id;
        }else{
            PriceBookId = Test.getStandardPricebookId();
        } 
        
        for( Asset assetData : listOfTodayExpiredAssets ){
            
            setOfAccountId.add(assetData.AccountId);
            setOfOwnerId.add(assetData.ownerId);
            if( assetData.BackEndQuote__c != NULL && assetData.account.country_of_origin__c != 'N/A' && assetData.Product2.isactive ){
                setOfQuoteIds.add(assetData.BackEndQuote__c);
            }
        }
        
        Map<Id,Account> 	mapOfAccount 				= new Map<Id,Account>([ SELECT Id,name,KAM_Type__c,OwnerId FROM Account WHERE Id IN :setOfAccountId ]);
        Map<Id,User> 		mapOfUser 					= new Map<Id,User>([ SELECT Id,name,Profile.Name,AccountId,Account.OwnerId,Account.KAM_Type__c FROM User WHERE Id IN :setOfOwnerId ]);
        Map<Id,Quote>	 	mapOfQuoteToClone 			= new Map<Id,Quote>([ SELECT id,AccountId FROM Quote WHERE Id IN:setOfQuoteIds ]); 
        List<Quote> 		listOfQuoteToBeCloned 		= DataBase.query(UtilityClass.getQueryString('Quote')+' FROM Quote WHERE Id IN: setOfQuoteIds');
        Map<Id,Quote> 		mapOfQuotesToBeCloned 		= new Map<Id,Quote>(listOfQuoteToBeCloned);
        Map<String,String> 	mapOfAssetToQuoteIdClone	= new Map<String,String>();
        Map<String,Quote>	mapOfAssetToClonedQuote 	= new Map<String,Quote>();
        
        if( listOfTodayExpiredAssets.size()>0 ){
            for( Asset assestInstance : listOfTodayExpiredAssets ){
                
                if(assestInstance.BackEndQuote__c != null){
                    mapOfAssetToQuoteIdClone.put(assestInstance.Id,assestInstance.BackEndQuote__c);
                }
                
                if(assestInstance.Renewal_Opportunity__c == NULL){
                    Opportunity newOpportunityInstance = new Opportunity();
                    
                    if( autoRenewalEnabledPlanTiers.contains(assestInstance.Product2.Plan_Tier__c) && assestInstance.Account.Is_Auto_Renewal_Enabled__c){
                        newOpportunityInstance.Is_Auto_Renewal_Enabled__c = TRUE;
                    }
                    
                    if(assestInstance.Name.length()<95){
                        newOpportunityInstance.Name='Renewal Opportunity '+ assestInstance.Name;  
                    }else{
                        newOpportunityInstance.Name='Renewal Opportunity '+assestInstance.Name.substring(0,95);
                    }
                    
                    newOpportunityInstance.Order_Form_Required__c = 'Yes';
                    newOpportunityInstance.StageName=OpportunityConstants.STAGENAME_RENEWAL_INITIATED;
                    if(mapOfAssetsMultiYear.get(assestInstance.Id).Product2.Product_Line__c != NULL && 
                       mapOfAssetsMultiYear.get(assestInstance.Id).Product2.Product_Line__c.containsIgnoreCase('Secretarial')){
                           newOpportunityInstance.ClearTax_Billing_Entity__c 	= 'CimplyFive';
                           newOpportunityInstance.ownerId 			=  	 mapOfAssetsMultiYear.get(assestInstance.Id).Account.Account_Owner_Cimplifive__c;
                       }
                    if(
                        mapOfAssetsMultiYear.get(assestInstance.id).Multi_Year__c && 
                        ( mapOfAssetsMultiYear.get(assestInstance.id).Opportunity__r.Country_of_Origin__c == NULL || 
                         mapOfAssetsMultiYear.get(assestInstance.id).Opportunity__r.Country_of_Origin__c == 'India' )
                    ){
                        newOpportunityInstance.RecordTypeId=OpportunityConstants.RECORDTYPEID_RENEWAL_MULTI_YEAR; 
                        newOpportunityInstance.Period_Start_date__c = mapOfAssetsMultiYear.get(assestInstance.id).UsageEndDate.addDays(1);
                        newOpportunityInstance.Period_End_date__c =  newOpportunityInstance.Period_Start_date__c.addYears(1);
                    }
                    else if(
                        ( mapOfAssetsMultiYear.get(assestInstance.id).Opportunity__r.Country_of_Origin__c != NULL && 
                         mapOfAssetsMultiYear.get(assestInstance.id).Opportunity__r.Country_of_Origin__c != 'India' )
                    ){
                    }else{
                        newOpportunityInstance.RecordTypeId         = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OpportunityConstants.RECORDTYPENAME_RENEWAL).getRecordTypeId();
                        newOpportunityInstance.Period_Start_date__c = mapOfAssetsMultiYear.get(assestInstance.id).UsageEndDate.addDays(1);
                        newOpportunityInstance.Period_End_date__c   =  newOpportunityInstance.Period_Start_date__c.addYears(1);
                    }
                    newOpportunityInstance.CloseDate=System.today()+30;
                    if( assestInstance.account.parentId != NULL ){
                        newOpportunityInstance.AccountId=assestInstance.account.parentId;
                    } else{
                        newOpportunityInstance.AccountId=assestInstance.AccountId;
                    }
                    newOpportunityInstance.CurrencyIsoCode = assestInstance.CurrencyIsoCode;
                    
                    if( newOpportunityInstance.RecordTypeId		!=	OpportunityConstants.RECORDTYPEID_NET_NEW_CIMPLYFIVE ){
                        if(
                            mapOfUser.get(assestInstance.OwnerId).Profile.Name == ProfileConstants.PARTNER_MANAGER || 
                            mapOfUser.get(assestInstance.OwnerId).Profile.Name == ProfileConstants.PARTNER_SALESTEAM
                        ){
                            if(mapOfUser.get(assestInstance.OwnerId).Account.KAM_Type__c == AccountConstants.EMAIL_KAM){
                                newOpportunityInstance.OwnerId = mapOfUser.get(assestInstance.OwnerId).Account.OwnerId; 
                            } else{
                                newOpportunityInstance.OwnerId = mapOfAccount.get(assestInstance.AccountId).OwnerId;
                            }
                        } else{
                            newOpportunityInstance.OwnerId = mapOfAccount.get(assestInstance.AccountId).OwnerId;
                        }
                    }
                    
                    newOpportunityInstance.Billing_Method__c 							= mapOfAssetsMultiYear.get(assestInstance.id)?.Billing_Method__c;
                    newOpportunityInstance.Place_of_Supply__c 							= mapOfAssetsMultiYear.get(assestInstance.id)?.Place_of_Supply__c;
                    newOpportunityInstance.Legal_Entity_Name_Of_The_Client__c 			= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Legal_Entity_Name_Of_The_Client__c;
                    newOpportunityInstance.State_2__c									= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.State_2__c;
                    newOpportunityInstance.Order_Id_Only_If_Razorpay_Payment__c 		= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Order_Id_Only_If_Razorpay_Payment__c;
                    newOpportunityInstance.Term_Months__c 								= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Term_Months__c;
                    newOpportunityInstance.PO_Required__c 								= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.PO_Required__c;
                    newOpportunityInstance.PO_Amount__c 								= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.PO_Amount__c;
                    newOpportunityInstance.Renewal_Clause_Required__c 					= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Renewal_Clause_Required__c == TRUE ? TRUE : FALSE;
                    newOpportunityInstance.TAN__c 										= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.TAN__c;
                    newOpportunityInstance.CIN__c 										= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.CIN__c;
                    newOpportunityInstance.If_SEZ__c 									= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.If_SEZ__c;
                    newOpportunityInstance.Special_Terms__c 							= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Special_Terms__c;
                    newOpportunityInstance.Billing_Address__c 							= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Billing_Address__c;
                    newOpportunityInstance.Shipping_Address__c						    = mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Shipping_Address__c;
                    newOpportunityInstance.Renewal_Charge__c 							= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Renewal_Charge__c;
                    newOpportunityInstance.PAN_No_as_per_PO__c 							= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.PAN_No_as_per_PO__c;
                    newOpportunityInstance.Billing_GST__c 								= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Billing_GST__c;
                    newOpportunityInstance.Stage_Comments__c 							= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Stage_Comments__c;
                    newOpportunityInstance.Unique_features_present_in_competition_s__c  = mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Unique_features_present_in_competition_s__c;
                    newOpportunityInstance.Deal_Push_Comments__c 						= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Deal_Push_Comments__c;
                    newOpportunityInstance.Reasons_for_deal_closure__c 					= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Reasons_for_deal_closure__c;
                    newOpportunityInstance.Customer_Billing_Name_as_Per_PO__c 			= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Customer_Billing_Name_as_Per_PO__c;
                    newOpportunityInstance.PO_number__c 								= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.PO_number__c;
                    newOpportunityInstance.PO_Received_Date__c 							= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.PO_Received_Date__c;
                    newOpportunityInstance.Document_No_LOE_No__c 						= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Document_No_LOE_No__c;
                    newOpportunityInstance.E_Sign_Customer_Info__c 						= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.E_Sign_Customer_Info__c;
                    if(!mapOfNewRenewalOpportunites.containsKey(assestInstance.Id)){
                        mapOfNewRenewalOpportunites.put(assestInstance.Id,newOpportunityInstance);
                    }
                    if( !setProductIds.contains(assestInstance.Product2Id) ){
                        setProductIds.add(assestInstance.Product2Id);
                    }
                } 
            }
            
            System.debug('Product '+setProductIds);
            if(!mapOfNewRenewalOpportunites.isEmpty()){
                new OpportunityService().insertOpportunity(mapOfNewRenewalOpportunites.values(),'');
            }
            
            System.debug('-- key --'+mapOfNewRenewalOpportunites.keySet()+' -- value -- '+mapOfNewRenewalOpportunites.values());
        }
        List<Asset> listOfAssetsToUpdate=new List<Asset>();
        
        Map<Id,Quote> mapOfNewQuotes=new Map<Id,Quote>();
        for(Asset assetIdkey:listOfTodayExpiredAssets){
            Asset assetInstance=new Asset();
            assetInstance.Id=assetIdkey.Id;
            assetInstance.Status = AssetConstants.STATUS_UPCOMING_RENEWAL;
            if(mapOfNewRenewalOpportunites.containsKey(assetIdkey.Id)){
                //Pramodh Changed to new opportunity lookup
                assetInstance.Renewal_Opportunity__c = mapOfNewRenewalOpportunites.get(assetIdkey.Id).Id;
                //Status to Upcoming Renewal 
                
            }
            listOfAssetsToUpdate.add(assetInstance);
            //Added by Raksha
            System.debug('mapOfAssetToQuoteIdClone '+mapOfAssetToQuoteIdClone);
            System.debug('mapOfQuotesToBeCloned '+mapOfQuotesToBeCloned);
            System.debug('assetIdkey '+assetIdkey);
            String QuoteIdToClone = mapOfAssetToQuoteIdClone.get(assetIdkey.Id);
            System.debug('QuoteIdToClone '+QuoteIdToClone);
            Quote quoteToClone = mapOfQuotesToBeCloned.get(QuoteIdToClone);
            System.debug('quoteToClone '+quoteToClone);
            If(quoteToClone != null){
                Quote clonedQuote = quoteToClone.clone(false,true,false,false);
                clonedQuote.Name = QuoteConstants.RENEWAL_QUOTE;
                clonedQuote.Pricebook2Id = PriceBookId;
                clonedQuote.Status = QuoteConstants.STATUS_DRAFT;
                if(mapOfNewRenewalOpportunites.containsKey(assetIdkey.Id)){
                    clonedQuote.currencyISOCode = mapOfNewRenewalOpportunites.get(assetIdkey.Id).currencyISOCode;
                    clonedQuote.OwnerId = mapOfNewRenewalOpportunites.get(assetIdkey.Id).ownerId;
                    
                    clonedQuote.OpportunityId=mapOfNewRenewalOpportunites.get(assetIdkey.Id).Id;
                    clonedQuote.BackEndPreviousQuoteDiscount__c = mapOfAssets.get(assetIdkey.Id).BackEndQuoteDiscount__c;
                }
                System.debug('clonedQuote '+clonedQuote);
                if(assetInstance.Renewal_Opportunity__c != NULL){
                    mapOfAssetToClonedQuote.put(assetIdkey.Id, clonedQuote);
                }
                
                
                //End by Raksha
                /*Commented by Raksha since Quote is clone not created
Quote quoteInstance=new Quote();
quoteInstance.Name=QuoteConstants.RENEWAL_QUOTE;
quoteInstance.Pricebook2Id=PriceBookId;

if(mapOfNewRenewalOpportunites.containsKey(assetIdkey)){
quoteInstance.OpportunityId=mapOfNewRenewalOpportunites.get(assetIdkey).Id;
quoteInstance.BackEndPreviousQuoteDiscount__c = mapOfAssets.get(assetIdkey).BackEndQuoteDiscount__c;
}
mapOfNewQuotes.put(assetIdkey,quoteInstance);*/
            }
        }
        if(!mapOfAssetToClonedQuote.isEmpty() ){
            QuoteConstants.ISFIRSTTIMEQUOTE = FALSE;
            OpportunityConstants.AUTO_RENEW_RULE = FALSE;
            insert mapOfAssetToClonedQuote.values();
            
            
            
            System.debug('mapOfAssetToClonedQuote '+mapOfAssetToClonedQuote);
            System.debug('mapOfAssetToClonedQuote Keys '+mapOfAssetToClonedQuote.keySet());
            System.debug('mapOfAssetToClonedQuote Values '+mapOfAssetToClonedQuote.values());
            
            
            /*Commeneted by Raksha
if(!mapOfNewQuotes.isEmpty()){
insert mapOfNewQuotes.values();
}*/
            
            //System.debug('-- key --'+mapOfNewQuotes.keySet()+' -- value -- '+mapOfNewQuotes.values());
            
            List<QuoteLineItem> listofQuoteLineItems=new List<QuoteLineItem>();
            
            List<PriceBookEntry> listOfPriceBooksByProductIds=new List<PricebookEntry>();
            listOfPriceBooksByProductIds=DataBase.query(UtilityClass.getQueryString('PricebookEntry')+' FROM PricebookEntry WHERE Product2Id IN: setProductIds Order by CreatedDate desc');
            
            System.debug('listOfPriceBooksByProductIds '+listOfPriceBooksByProductIds);
            Map<Id,PriceBookEntry> mapOfPriceBookEntry=new Map<Id,PriceBookEntry>();
            for(PricebookEntry pricebookEntryInstance:listOfPriceBooksByProductIds){
                if(!mapOfPriceBookEntry.containsKey(pricebookEntryInstance.Product2Id)){
                    mapOfPriceBookEntry.put(pricebookEntryInstance.Product2Id, pricebookEntryInstance);
                }
            }
            System.debug('mapOfPriceBookEntry '+mapOfPriceBookEntry);
            
            
            for(Id assetIdkey1:mapOfAssetToClonedQuote.keySet()){ // Raksha changed from 'mapOfNewQuotes' to 'mapOfAssetToClonedQuote'
                if(mapOfAssets.get(assetIdkey1).Product2.isactive){
                    QuoteLineItem newQuoteLineItem=new QuoteLineItem();
                    newQuoteLineItem.QuoteId=mapOfAssetToClonedQuote.get(assetIdKey1).Id; // Raksha changed from 'mapOfNewQuotes' to 'mapOfAssetToClonedQuote'
                    newQuoteLineItem.Product2Id=mapOfAssets.get(assetIdkey1).Product2Id;
                    newQuoteLineItem.Quantity=1;
                    newQuoteLineItem.Sale_Price__c = 0;
                    newQuoteLineItem.Parent_Asset__c =  assetIdkey1;
                    
                    
                    /**	Default TDS % Applicable Rule : BIBHU	**/
                    if( 
                        mapOfAssets.get(assetIdkey1).Opportunity__r.Account?.TDS_Percent_Applicable__c != NULL && 
                        mapOfAssets.get(assetIdkey1).Opportunity__r.Account?.TDS__c != NULL
                    ){
                        newQuoteLineItem.Is_TDS_Applicable__c = TRUE;
                        newQuoteLineItem.Applicable_TDS__c = mapOfAssets.get(assetIdkey1).Opportunity__r.Account?.TDS_Percent_Applicable__c;
                        newQuoteLineItem.TAN_Number__c = mapOfAssets.get(assetIdkey1).Opportunity__r.Account?.TDS__c;
                    }
                    /**	Default TDS % Applicable Rule : BIBHU	**/
                    
                    
                    
                    if(!mapOfPriceBookEntry.isEmpty() && mapOfPriceBookEntry.containsKey(mapOfAssets.get(assetIdkey1).Product2Id)){
                        newQuoteLineItem.PricebookEntryId=mapOfPriceBookEntry.get(mapOfAssets.get(assetIdkey1).Product2Id).Id;
                        newQuoteLineItem.UnitPrice=mapOfPriceBookEntry.get(mapOfAssets.get(assetIdkey1).Product2Id).UnitPrice;
                    }
                    listofQuoteLineItems.add(newQuoteLineItem);
                }
            }
            
            if(listofQuoteLineItems.size()>0)
            {
                if(!test.isRunningTest())
                    OpportunityConstants.AUTO_RENEW_RULE = FALSE;
                insert listofQuoteLineItems;
            }
            
            
            
            //System.debug('listofQuoteLineItems'+listofQuoteLineItems);
        }
        
        if(listOfAssetsToUpdate.size()>0){
            update listOfAssetsToUpdate;
        }
        
        System.debug('listOfAssetsToUpdate'+listOfAssetsToUpdate);
        return mapOfNewRenewalOpportunites.get(listOfTodayExpiredAssets[0].id);
        
    }
    
    
    
}