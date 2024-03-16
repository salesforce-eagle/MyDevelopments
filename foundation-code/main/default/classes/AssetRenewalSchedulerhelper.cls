public class AssetRenewalSchedulerhelper {
    
    @AuraEnabled
    //This method will clone the related Opportunity, Quote, Quote Line Item Record on the Account that the Assit Expires Today 
    public static Opportunity createOpportunityQuoteQuoteLineItem(List<Asset> listOfTodayExpiredAssets){
        // Map<Id,Opportunity> mapOfIdWithOpportunites=new OpportunitySelector().getOpportunityById(setOfAssetParentOpportunityIds);
        System.debug('AssetenewalSchedulerHelper createOpportunityQuoteQuoteLineItem()');
        System.debug('listOfTodayExpiredAssets '+listOfTodayExpiredAssets);
        Map<Id,Opportunity> mapOfNewRenewalOpportunites=new Map<Id,Opportunity>();
        Map<Id,Asset> mapOfAssets=new Map<Id,Asset>((List<Asset>)listOfTodayExpiredAssets);
        Map<Id,Asset> mapOfAssetsMultiYear = new Map<Id,Asset>([SELECT id,multi_year__c,UsageEndDate,account.country_of_origin__c,Opportunity_Record_Type_of_this_asset__c,
                                                                Billing_Frequency_for_Subscription_Fee__c, Billing_Frequency_for_Service_Fee_OTP__c, Billing_Frequency_for_Integration_Prods__c, 
                                                                Billing_Method__c, Place_of_Supply__c, Payment_Method__c, Payment_Term__c, Legal_Entity_Name_Of_The_Client__c, 
                                                                Opportunity__r.Country_of_Origin__c,Product2.Product_Line__c,Account.Account_Owner_Cimplifive__c, 
                                                                Opportunity__r.Custom_Billing_Freq_for_Integration_Prod__c, Opportunity__r.Order_Id_Only_If_Razorpay_Payment__c,
                                                                Opportunity__r.Term_Months__c, Opportunity__r.PO_Required__c,Opportunity__r.PO_Amount__c,Opportunity__r.Renewal_Clause_Required__c,
                                                                Opportunity__r.TAN__c,Opportunity__r.CIN__c,Opportunity__r.If_SEZ__c,Opportunity__r.Special_Terms__c,Billing_Address__c, Shipping_Address__c,
                                                                Opportunity__r.Renewal_Charge__c, Opportunity__r.PAN_No_as_per_PO__c,Opportunity__r.Billing_GST__c,Opportunity__r.Stage_Comments__c,
                                                                Opportunity__r.Unique_features_present_in_competition_s__c,Opportunity__r.Deal_Push_Comments__c,Opportunity__r.Reasons_for_deal_closure__c,
                                                                Opportunity__r.Customer_Billing_Name_as_Per_PO__c,Opportunity__r.PO_number__c,Opportunity__r.PO_Received_Date__c,Opportunity__r.Document_No_LOE_No__c
                                                                FROM ASSET 
                                                                WHERE ID in : listOfTodayExpiredAssets]);// Added as multi year field was coming blank for AssetRenew componenet
        List<Account> listOfAccount = new List<Account>();
        List<User> listOfUser = new List<User>();
        set<Id> setProductIds=new Set<Id>();
        set<Id> setOfAccountId=new Set<Id>();
        set<Id> setOfOwnerId=new Set<Id>();
        Set<Id> setOfQuoteIds = new Set<Id>();//Added by Raksha
        Id PriceBookId;
        if(!Test.isRunningTest()){
            PriceBookId=[select Id, Name, IsActive from PriceBook2 where IsStandard=True LIMIT 1].Id;
        }else{
            PriceBookId= Test.getStandardPricebookId();
        } 
        //Added by Thejas on 14/10/2020 
        for(Asset assetData:listOfTodayExpiredAssets){
            setOfAccountId.add(assetData.AccountId);
            setOfOwnerId.add(assetData.ownerId);
            if(assetData.BackEndQuote__c != null && assetData.account.country_of_origin__c != 'N/A' && assetData.Product2.isactive){
                setOfQuoteIds.add(assetData.BackEndQuote__c);
            }
        }
        Map<Id,Account> mapOfAccount = new Map<Id,Account>([Select Id,name,KAM_Type__c,OwnerId from Account where Id IN :setOfAccountId]);
        Map<Id,User> mapOfUser = new Map<Id,User>([Select Id,name,Profile.Name,AccountId,Account.OwnerId,Account.KAM_Type__c from User where Id IN :setOfOwnerId]);
        //Added by Raksha
        Map<Id,Quote> mapOfQuoteToClone = new Map<Id,Quote>([select id,AccountId from Quote where Id IN:setOfQuoteIds]); 
        List<Quote> listOfQuoteToBeCloned = new List<Quote>();
        listOfQuoteToBeCloned = DataBase.query(UtilityClass.getQueryString('Quote')+' FROM Quote WHERE Id IN: setOfQuoteIds');
        Map<Id,Quote> mapOfQuotesToBeCloned = new Map<Id,Quote>(listOfQuoteToBeCloned);
        Map<String,String> mapOfAssetToQuoteIdClone = new Map<String,String>();
        Map<String,Quote> mapOfAssetToClonedQuote = new Map<String,Quote>();
        //End by Raksha
        
        //End of Code added by Thejas
        if(listOfTodayExpiredAssets.size()>0){
            for(Asset assestInstance:listOfTodayExpiredAssets){
                //Added by Raksha
                if(assestInstance.BackEndQuote__c != null){
                    mapOfAssetToQuoteIdClone.put(assestInstance.Id,assestInstance.BackEndQuote__c);
                }
                //End by Raksha
                if(assestInstance.Renewal_Opportunity__c == NULL){
                    Opportunity newOpportunityInstance = new Opportunity();
                    
                    if(assestInstance.Name.length()<95){
                        newOpportunityInstance.Name='Renewal Opportunity '+ assestInstance.Name;  
                    }else{
                        newOpportunityInstance.Name='Renewal Opportunity '+assestInstance.Name.substring(0,95);
                    }
                    
                    newOpportunityInstance.StageName=OpportunityConstants.STAGENAME_RENEWAL_INITIATED;
                    if(mapOfAssetsMultiYear.get(assestInstance.Id).Product2.Product_Line__c != NULL && 
                       mapOfAssetsMultiYear.get(assestInstance.Id).Product2.Product_Line__c.containsIgnoreCase('Secretarial')){
                           //newOpportunityInstance.RecordTypeId		=	OpportunityConstants.RECORDTYPEID_NET_NEW_CIMPLYFIVE;
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
                        //newOpportunityInstance.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OpportunityConstants.RECORDTYPE_INTERNATIONAL).getRecordTypeId();
                    }else{
                        newOpportunityInstance.RecordTypeId         = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OpportunityConstants.RECORDTYPENAME_RENEWAL).getRecordTypeId();
                        newOpportunityInstance.Period_Start_date__c = mapOfAssetsMultiYear.get(assestInstance.id).UsageEndDate.addDays(1);
                        newOpportunityInstance.Period_End_date__c   =  newOpportunityInstance.Period_Start_date__c.addYears(1);
                    }
                    newOpportunityInstance.CloseDate=System.today()+30;
                    if(assestInstance.account.parentId != NULL){
                        newOpportunityInstance.AccountId=assestInstance.account.parentId;
                    }
                    else{
                        newOpportunityInstance.AccountId=assestInstance.AccountId;
                    }
                    newOpportunityInstance.CurrencyIsoCode = assestInstance.CurrencyIsoCode;
                    // if(mapOfAccount.get(assestInstance.AccountId).KAM_Type__c == 'Independent KAM')
                    //Added by Thejas on 14/10/2020 
                    if(newOpportunityInstance.RecordTypeId		!=	OpportunityConstants.RECORDTYPEID_NET_NEW_CIMPLYFIVE){
                        if(mapOfUser.get(assestInstance.OwnerId).Profile.Name == ProfileConstants.PARTNER_MANAGER || mapOfUser.get(assestInstance.OwnerId).Profile.Name == ProfileConstants.PARTNER_SALESTEAM)
                        {
                            if(mapOfUser.get(assestInstance.OwnerId).Account.KAM_Type__c == AccountConstants.EMAIL_KAM)
                            {
                                newOpportunityInstance.OwnerId = mapOfUser.get(assestInstance.OwnerId).Account.OwnerId; 
                            }
                            else
                            {
                                newOpportunityInstance.OwnerId = mapOfAccount.get(assestInstance.AccountId).OwnerId;
                            }
                        }
                        else
                        {
                            newOpportunityInstance.OwnerId = mapOfAccount.get(assestInstance.AccountId).OwnerId;
                        }
                        
                    }
                 
                    /** Map OF & PO details on Renewal Opp **/
                    newOpportunityInstance.Billing_Method__c 							= mapOfAssetsMultiYear.get(assestInstance.id)?.Billing_Method__c;
                    newOpportunityInstance.Place_of_Supply__c 							= mapOfAssetsMultiYear.get(assestInstance.id)?.Place_of_Supply__c;
                    //newOpportunityInstance.Payment_Term__c 								= mapOfAssetsMultiYear.get(assestInstance.id)?.Payment_Term__c;
                    newOpportunityInstance.Legal_Entity_Name_Of_The_Client__c 			= mapOfAssetsMultiYear.get(assestInstance.id)?.Legal_Entity_Name_Of_The_Client__c;
                    //newOpportunityInstance.Custom_Billing_Freq_for_Integration_Prod__c 	= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Custom_Billing_Freq_for_Integration_Prod__c;
                    newOpportunityInstance.Order_Id_Only_If_Razorpay_Payment__c 		= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Order_Id_Only_If_Razorpay_Payment__c;
                    newOpportunityInstance.Term_Months__c 								= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Term_Months__c;
                    newOpportunityInstance.PO_Required__c 								= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.PO_Required__c;
                    newOpportunityInstance.PO_Amount__c 								= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.PO_Amount__c;
                    newOpportunityInstance.Renewal_Clause_Required__c 					= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Renewal_Clause_Required__c == TRUE ? TRUE : FALSE;
                    newOpportunityInstance.TAN__c 										= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.TAN__c;
                    newOpportunityInstance.CIN__c 										= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.CIN__c;
                    newOpportunityInstance.If_SEZ__c 									= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.If_SEZ__c;
                    newOpportunityInstance.Special_Terms__c 							= mapOfAssetsMultiYear.get(assestInstance.id)?.Opportunity__r?.Special_Terms__c;
                    newOpportunityInstance.Billing_Address__c 							= mapOfAssetsMultiYear.get(assestInstance.id)?.Billing_Address__c;
                    newOpportunityInstance.Shipping_Address__c						    = mapOfAssetsMultiYear.get(assestInstance.id)?.Shipping_Address__c;
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
                    
                    //End
                    if(!mapOfNewRenewalOpportunites.containsKey(assestInstance.Id)){
                        mapOfNewRenewalOpportunites.put(assestInstance.Id,newOpportunityInstance);
                    }
                    if(!setProductIds.contains(assestInstance.Product2Id)){
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
                /*clonedQuote.E_Sign_Customer_Info__c = null;
clonedQuote.E_Sign_Type__c = '';
clonedQuote.Physically_Signed__c = false;
clonedQuote.ESign_Sign_Status__c = '';
clonedQuote.ESign_BE_Docket_ID__c = '';
clonedQuote.ESign_BE_Document_ID__c = '';
clonedQuote.ESign_BE_Reference_Doc_ID__c = '';
clonedQuote.ESign_Doc_Updated__c = false;
clonedQuote.Esign_Order__c = '';
clonedQuote.ESign_Message__c ='';            
clonedQuote.E_Sign_Status__c = QuoteConstants.ESIGN_STATUS_ESIGN;
clonedQuote.OTP_For_Electronic_Signature__c = '';*/
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
                if(!mapOfPriceBookEntry.isEmpty() && mapOfPriceBookEntry.containsKey(mapOfAssets.get(assetIdkey1).Product2Id)){
                    newQuoteLineItem.PricebookEntryId=mapOfPriceBookEntry.get(mapOfAssets.get(assetIdkey1).Product2Id).Id;
                    newQuoteLineItem.UnitPrice=mapOfPriceBookEntry.get(mapOfAssets.get(assetIdkey1).Product2Id).UnitPrice;
                }
                    /**	Default TDS % Applicable Rule : BIBHU	**/
                    if( 
                        mapOfAssets.get(assetIdkey1).Opportunity__r.Account.TDS_Percent_Applicable__c != NULL && 
                        mapOfAssets.get(assetIdkey1).Opportunity__r.Account.TDS__c != NULL
                    ){
                        newQuoteLineItem.Is_TDS_Applicable__c = TRUE;
                        newQuoteLineItem.Applicable_TDS__c = mapOfAssets.get(assetIdkey1).Opportunity__r.Account.TDS_Percent_Applicable__c;
                        newQuoteLineItem.TAN_Number__c = mapOfAssets.get(assetIdkey1).Opportunity__r.Account.TDS__c;
                    }
                    /**	Default TDS % Applicable Rule : BIBHU	**/
                listofQuoteLineItems.add(newQuoteLineItem);
                }
            }
            
            if(listofQuoteLineItems.size()>0)
            {
                if(!test.isRunningTest())
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
    
    @AuraEnabled
    public static List<Asset> getAssetDetails(String assetId){//Asset
        String Integration = 'Integration';
        List<Asset> listOfAsset = [SELECT Id, ContactId, AccountId, ParentId, RootAssetId, Product2Id, ProductCode, IsCompetitorProduct,  IsDeleted, Name, SerialNumber, 
                                   InstallDate, PurchaseDate, UsageEndDate, Status, Price, Quantity, Description, OwnerId, AssetProvidedById, AssetServicedById, IsInternal, 
                                   AssetLevel, StockKeepingUnit, LastViewedDate, LastReferencedDate, Onboarding_status__c, Usage_status__c, Integration_status__c, Opportunity__c,
                                   Managed_Service_Head__c, BackEndQuoteDiscount__c,Renewal_Opportunity__c, Product2.Product_category__c,BackEndQuote__c  FROM Asset WHERE id=:assetId AND Product2.Product_category__c != :Integration];
        if(!listOfAsset.isEmpty()){
            //return listOfAsset[0]; 
            return listOfAsset;
        }
        return null;
    }
}