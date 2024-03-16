public class CTX_MergeAssets {
    public static void  mergeAssets(Map<Id,Asset> newAssetmap, Map<Id,Asset> oldAssetmap){
        Set<Id> assetIds = new Set<Id>();
        List<Asset> assetList = new List<Asset>();
        List<Asset> assetListToUpdateAmount = new List<Asset>();
        Map<Id, Decimal> assetPriceMap = new Map<Id, Decimal>();
        
        
        for(Id key : newAssetmap.keySet()){
            if(newAssetmap.get(key).ParentId != oldAssetmap.get(key).ParentId ||
            newAssetmap.get(key).Parent_Asset_2__c != oldAssetmap.get(key).Parent_Asset_2__c ||
            newAssetmap.get(key).Parent_Asset_3__c != oldAssetmap.get(key).Parent_Asset_3__c ||
            newAssetmap.get(key).Parent_Asset_4__c != oldAssetmap.get(key).Parent_Asset_4__c)
            {
                assetIds.add(newAssetmap.get(key).ParentId);
                assetIds.add(newAssetmap.get(key).Parent_Asset_2__c);
                assetIds.add(newAssetmap.get(key).Parent_Asset_3__c);
                assetIds.add(newAssetmap.get(key).Parent_Asset_4__c);
            }
        }
        System.debug('@assetIds'+assetIds);
        if(assetIds.size()>0){
            for(Asset ast : [SELECT Id, Price
            FROM Asset
            WHERE Id IN :assetIds])
            {
                assetPriceMap.put(ast.Id, ast.Price); 
            }
            
            
            Decimal RenewalPrice = 0;
            for(Asset ast : newAssetmap.values()){
                RenewalPrice = (ast.ParentId != NULL ? assetPriceMap.get(ast.ParentId) : 0) + 
                (ast.Parent_Asset_2__c != NULL ? assetPriceMap.get(ast.Parent_Asset_2__c) : 0) + 
                (ast.Parent_Asset_3__c != NULL ? assetPriceMap.get(ast.Parent_Asset_3__c) : 0) + 
                (ast.Parent_Asset_4__c != NULL ? assetPriceMap.get(ast.Parent_Asset_4__c) : 0);
                
                ast.PY_Renewal_Amount_New__c = RenewalPrice;
            }
        }
    }
    
}