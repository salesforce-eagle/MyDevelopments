public class CTX_AssetParrentTagging {
    
    public static void assetsParentTagging(List<Asset> newAssetList, Map<Id, Product2> prodMap, Map<Id,Opportunity> opportunityMap){
        System.debug('### Parent Tagging Execution Started ###');
        Set<Id>					accountIdSet 	= new Set<Id>();
        
        for(Asset thisAsset : newAssetList){
            if(thisAsset.Opportunity__c != NULL){
                if((opportunityMap.get(thisAsset.Opportunity__c).RecordTypeId == OpportunityConstants.RECORDTYPEID_RENEWAL || 
                   (opportunityMap.get(thisAsset.Opportunity__c).RecordTypeId == OpportunityConstants.RECORDTYPEID_NET_NEW ) && opportunityMap.get(thisAsset.Opportunity__c).ClearTax_Billing_Entity__c == 'CimplyFive') && /** Changed By Niraj : Removal of Net New Cimplyfive Record Type **/
                   (thisAsset.ParentId == NULL && 
                    thisAsset.Product2Id != NULL && 
                    thisAsset.AccountId != NULL &&
                    thisAsset.Billing_Type__c == 'ARR'
                   ))
                {
                    accountIdSet.add(thisAsset.AccountId);                    
                }   
            }
        }  
        
        
        
        Map<String, List<Asset>> 	accountIdProductIdExistingAsset 			= new Map<String, List<Asset>>();
        Map<String, List<Asset>> 	accountIdProductLineCategoryExistingAsset 	= new Map<String, List<Asset>>();
        /**	Make Licensing Changes : START	**/
        if(accountIdSet.size() > 0){
            
            for(
                Asset thisRec : [SELECT Id, AccountId, PurchaseDate, UsageEndDate, 
                                 Product2.Product_Line__c, Product2Id, Product2.Product_Category__c
                                 FROM Asset WHERE 
                                 AccountId IN :accountIdSet AND 
                                 ( NOT Status IN ('Churn', 'Sales return') ) AND
                                 Billing_Type__c NOT IN ('OTP')
                                 ORDER BY UsageEndDate DESC]
            ){
                String tempString1 = String.valueOf(thisRec.AccountId) + String.valueOf(thisRec.Product2Id);
                System.debug('tempString1: '+tempString1);
                
                if(!accountIdProductIdExistingAsset?.containsKey(tempString1)){
                    accountIdProductIdExistingAsset.put(tempString1, new List<Asset>{thisRec});
                } else {
                    accountIdProductIdExistingAsset.get(tempString1).add(thisRec);
                }
                
                if(thisRec.Product2.Product_Line__c != 'Secretarial Automation'){
                    String tempString2 = thisRec.AccountId + thisRec.Product2.Product_Line__c + thisRec.Product2.Product_Category__c;
                    System.debug('tempString2: '+tempString2);
                    
                    if(!accountIdProductLineCategoryExistingAsset?.containsKey(tempString2)){
                        accountIdProductLineCategoryExistingAsset.put(tempString2, new List<Asset>{thisRec});
                    } else{
                        accountIdProductLineCategoryExistingAsset.get(tempString2).add(thisRec);
                    }
                    
                }
            }
            
            for(Asset thisAsset : newAssetList){
                System.debug('##accountIdProductIdExistingAsset: '+accountIdProductIdExistingAsset);
                System.debug('##accountIdProductLineCategoryExistingAsset: '+accountIdProductLineCategoryExistingAsset);
                String tempString1 = String.valueOf(thisAsset.AccountId) + String.valueOf(thisAsset.Product2Id);
                String tempString2 = thisAsset.AccountId + prodMap?.get(thisAsset.Product2Id).Product_Line__c + prodMap?.get(thisAsset.Product2Id).Product_Category__c;
                if(accountIdProductIdExistingAsset?.containsKey(tempString1)){
                    for(Asset assetInst : accountIdProductIdExistingAsset.get(tempString1)){
                        if( assetInst.UsageEndDate != NULL && thisAsset.PurchaseDate != NULL && assetInst.UsageEndDate.daysBetween(thisAsset.PurchaseDate) <= 60 && assetInst.UsageEndDate.daysBetween(thisAsset.PurchaseDate) >= -15){
                            thisAsset.parentId = assetInst.Id;
                            break;
                        }
                    }
                    
                } 
                
                if(thisAsset.parentId == NULL && thisAsset.Product2.Product_Line__c != 'Secretarial Automation'){
                    if(accountIdProductLineCategoryExistingAsset?.containsKey(tempString2)){
                        for(Asset assetInst : accountIdProductLineCategoryExistingAsset.get(tempString2)){
                            if(assetInst.UsageEndDate   != NULL                                     &&
                                thisAsset.PurchaseDate  != NULL                                     &&
                                assetInst.UsageEndDate.daysBetween(thisAsset.PurchaseDate) <= 60    && 
                                assetInst.UsageEndDate.daysBetween(thisAsset.PurchaseDate) >= -15){
                                thisAsset.parentId = assetInst.Id; 
                                break;  
                            }
                        } 
                    }   
                }
            }
        }
         
    }

}