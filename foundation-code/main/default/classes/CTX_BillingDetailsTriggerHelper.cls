public class CTX_BillingDetailsTriggerHelper {
    
    public static void postSupportRequired(Map<Id,Billing_Details__c> newBillingMap, Map<Id,Billing_Details__c> oldBillingMap){
        List<Billing_Details__c> billingListCollection = new List<Billing_Details__c>();
        List<Billing_Details__c> billingListRisk = new List<Billing_Details__c>();
        List<FeedItem>	postList 	= new List<FeedItem>();
        
        for(Billing_Details__c thisRec : newBillingMap.values()){
            if(thisRec.Support_Required__c != oldBillingMap.get(thisRec.Id).Support_Required__c &&
               thisRec.Support_Required__c != NULL){
                   billingListCollection.add(thisRec);
               }
            if(thisRec.Support_required_Risk__c  != oldBillingMap.get(thisRec.Id).Support_required_Risk__c  &&
               thisRec.Support_required_Risk__c  != NULL){
                   billingListRisk.add(thisRec);
               }
        }
        
        if(billingListCollection.size()>0){
            for(Billing_Details__c thisRec : billingListCollection){
                FeedItem post = new FeedItem();
                post.ParentId = thisRec.Id;
                post.Body = thisRec.Support_Required__c;
                
                postList.add(post);
            }
        }
        
          if(billingListRisk.size()>0){
            for(Billing_Details__c thisRec : billingListRisk){
                FeedItem post = new FeedItem();
                post.ParentId = thisRec.Id;
                post.Body = thisRec.Support_required_Risk__c;
                
                postList.add(post);
            }
        }
        
        if(!postList.isEmpty()){
            Insert postList;
        }
      
    }
    
    public static void fetchActionOwner(List<Billing_Details__c> billingDetails){
        List<Billing_Details__c> billingList = new List<Billing_Details__c> ();
        Set<Id> assetIds = new Set<Id>();
        
        for(Billing_Details__c thisRec : billingDetails){
            if(thisRec.Donot_Override__c == FALSE){
                billingList.add(thisRec);
                assetIds.add(thisRec.Asset__c);
            }
        }
        
        Map<Id,Asset> assetMap = new Map<Id,Asset>([SELECT Id, opportunity__c,Account.Sales_Owner__c,
                                                    opportunity__r.OwnerId, opportunity__r.Owner.isActive,
                                                    Account.Sales_Owner__r.isActive,
                                                    Account.OwnerId
                                                    FROM Asset
                                                    WHERE Id IN :assetIds]);
        
        for(Billing_Details__c thisRec : billingList){
            if(assetMap.containsKey(thisRec.Asset__c) &&
               assetMap.get(thisRec.Asset__c).opportunity__c != NULL && 
               assetMap.get(thisRec.Asset__c).opportunity__r.OwnerId != NULL &&
               assetMap.get(thisRec.Asset__c).opportunity__r.Owner.isActive)
            {
                thisRec.Action_Owner_Collection__c  = assetMap.get(thisRec.Asset__c).opportunity__r.OwnerId;
            }else if(assetMap.get(thisRec.Asset__c).Account.Sales_Owner__c != NULL &&
                     assetMap.get(thisRec.Asset__c).Account.Sales_Owner__r.isActive)
            {
                thisRec.Action_Owner_Collection__c  = assetMap.get(thisRec.Asset__c).Account.Sales_Owner__c;
            }else{
                thisRec.Action_Owner_Collection__c  = assetMap.get(thisRec.Asset__c).Account.OwnerId;
            }
        }
    }
    
}