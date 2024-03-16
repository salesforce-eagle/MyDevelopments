public  class AssetARRSummary {
    public static void  assetARRSummaryMethod(list<Sobject> listAsset){
        list<string> statusList = new list<string>{'Active','Inactive','Upcoming Renewal','At Risk','Valid','Valid & Renewed'};
            list<account> accList = new list<account>();
        set <Id> accountIdSet = new set<Id> ();
        for(Sobject assetIns :  listAsset){
            asset assetRec = (Asset)assetIns;
            if(!string.isBlank(assetRec.Billing_Type__c))
            if(assetRec.Billing_Type__c.equals('ARR') && (statusList.contains(assetRec.status)))
            accountIdSet.add(assetRec.Accountid);
        }
        for(account acc : [select id,Sum_of_ARR_Assets__c, (select id, price, status  from assets where  status IN :statusList AND Billing_type__c = 'ARR') from account where id =:accountIdSet] )
        {
            acc.Sum_of_ARR_Assets__c = 0;
            for(asset assIns : acc.assets)
            {
                if(assIns.Price != null){ 
                    acc.Sum_of_ARR_Assets__c += assIns.Price; 
                }
            }
            accList.add(acc);
        }

        if(accList.size() > 0 && !Test.isRunningTest())
        Upsert(accList);
    }
    
    public static void  assetARRSummaryMethodUpdate(map<Id,Sobject> mapNewAsset,map<Id,Sobject> mapOldAsset ){
        list<string> statusList = new list<string>{'Active','Inactive','Upcoming Renewal','At Risk','Valid','Valid & Renewed'};
            list<account> accList = new list<account>();
        set <Id> accountIdSet = new set<Id> ();
        for(Id assetIns :  mapOldAsset.keySet()){
            asset oldAssetIns =(Asset)mapOldAsset.get(assetIns);
            asset newAssetIns = (Asset)mapNewAsset.get(assetIns);
            //asset assetRec = (Asset)assetIns;
            if(!string.isBlank(newAssetIns.Billing_Type__c) )
            //if(newAssetIns.Billing_Type__c.equals('ARR') && (oldAssetIns.Status != newAssetIns.Status || oldAssetIns.Price !=  newAssetIns.Price ))
            accountIdSet.add(newAssetIns.Accountid);
        }
        for(account acc : [select id,Sum_of_ARR_Assets__c, (select id, price, status  from assets where  status IN :statusList AND Billing_type__c = 'ARR') from account where id =:accountIdSet] )
        {
            acc.Sum_of_ARR_Assets__c = 0;
            for(asset assIns : acc.assets)
            {
                if(assIns.Price != null){ 
                    acc.Sum_of_ARR_Assets__c += assIns.Price; 
                }
            }
            accList.add(acc);
        }

        if(accList.size() > 0 && !Test.isRunningTest())
        Upsert(accList);
    }
    
}