global class AssetRenewalScheduler implements Schedulable{
     
    public static void execute(SchedulableContext sctxt){ 
       
        Date assetWillExpireInNext3Months=System.today()+90;
        Date today=System.today();
        String Integration = 'Integration';
        String billingType = 'OTP';
        String upcomingRenewal = 'Upcoming Renewal';
        List<String> assetStatusChurn = new List<String>{AssetConstants.STATUS_CHURN,AssetConstants.RENEWED,AssetConstants.STATUS_VALID_RENEWED,'Sales return',AssetConstants.STATUS_EXPERIED};
        List<Asset> listOfTodayExpiredAssets=new List<Asset>();
        List<Asset> ChildAsset=[select id,parentId,Parent_Asset_2__c,Parent_Asset_3__c,Parent_Asset_4__c from asset where 
                                ( parentid != NULL or Parent_Asset_2__c != NULL or  Parent_Asset_3__c != NULL or Parent_Asset_4__c != NULL )
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
        String query='SELECT Id, ContactId, Opportunity__r.Account.TDS_Percent_Applicable__c, Opportunity__r.Account.TDS__c, CurrencyISOCode,Renewal_Opportunity__c, AccountId,account.parentId, ParentId, RootAssetId, Product2Id, ProductCode, IsCompetitorProduct,  IsDeleted, Name, SerialNumber, InstallDate, PurchaseDate, UsageEndDate, Status, Price, Quantity, Description, OwnerId, AssetProvidedById, AssetServicedById, IsInternal, AssetLevel, StockKeepingUnit, LastViewedDate, LastReferencedDate, Onboarding_status__c, Usage_status__c, Integration_status__c, Opportunity__c, Managed_Service_Head__c, BackEndQuoteDiscount__c,BackEndQuote__c,LastModifiedDate,Multi_year__c,account.country_of_origin__c,Product2.isactive, Opportunity_Record_Type_of_this_asset__c,Billing_Frequency_for_Subscription_Fee__c, Billing_Frequency_for_Service_Fee_OTP__c, Billing_Frequency_for_Integration_Prods__c, Billing_Method__c, Place_of_Supply__c, Payment_Method__c, Payment_Term__c, Legal_Entity_Name_Of_The_Client__c, Opportunity__r.Custom_Billing_Freq_for_Integration_Prod__c, Opportunity__r.Order_Id_Only_If_Razorpay_Payment__c,Opportunity__r.Term_Months__c, Opportunity__r.PO_Required__c,Opportunity__r.PO_Amount__c,Opportunity__r.Renewal_Clause_Required__c,Opportunity__r.TAN__c,Opportunity__r.CIN__c,Opportunity__r.If_SEZ__c,Opportunity__r.Special_Terms__c,Billing_Address__c, Shipping_Address__c,Opportunity__r.Renewal_Charge__c, Opportunity__r.PAN_No_as_per_PO__c,Opportunity__r.Billing_GST__c,Opportunity__r.Stage_Comments__c,Opportunity__r.Unique_features_present_in_competition_s__c,Opportunity__r.Deal_Push_Comments__c,Opportunity__r.Reasons_for_deal_closure__c,Opportunity__r.Customer_Billing_Name_as_Per_PO__c,Opportunity__r.PO_number__c,Opportunity__r.PO_Received_Date__c,Opportunity__r.Document_No_LOE_No__c, Product2.Product_Line__c FROM Asset WHERE Billing_Type__c != :billingType AND Status !=: assetStatusChurn AND( Renewal_Opportunity__c = null OR Status !=:upcomingRenewal)  AND UsageEndDate <=:assetWillExpireInNext3Months AND UsageEndDate >=:Today AND (Id  NOT IN: ParentIdList OR Multi_year__c = true) AND Is_Test_Asset__c = FALSE   ORDER BY UsageEndDate  ASC limit  '+limitSOQL ;
        listOfTodayExpiredAssets= DataBase.query(query);
        Set<Id> setOfAssetParentOpportunityIds=new Set<Id>();
        // Logic Changed to Create a new Renewal Opportunity 
        /*for(Asset assetInstance:listOfTodayExpiredAssets){
            setOfAssetParentOpportunityIds.add(assetInstance.Opportunity__c);
        }*/
        
        /*if(setOfAssetParentOpportunityIds.size()>0 && !setOfAssetParentOpportunityIds.isEmpty()){
            AssetRenewalSchedulerhelper.cloneOpportunityQuoteQuoteLineItem(setOfAssetParentOpportunityIds);
        }*/
        if(listOfTodayExpiredAssets.size()>0){
            AssetRenewalSchedulerhelper.createOpportunityQuoteQuoteLineItem(listOfTodayExpiredAssets);
        }
        Datetime sysTime = System.now();

       // this would increase the time to 1 hour after current time
        sysTime = sysTime.addHours(1);

        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        
        //Schedule the next job, and give it the system time so name is unique
        System.schedule('Asset Renewal Scheduler' + sysTime.getTime(),chron_exp, new AssetRenewalScheduler());
    }
        
}