/**
 * @File Name          : APAJunctionTriggerHandler.cls
 * @Description        : 
 * @Author             : Lokesh@SFDeveloper.SFDoc
 * @Group              : 
 * @Last Modified By   : Lokesh@SFDeveloper.SFDoc
 * @Last Modified On   : 07/12/2020, 12:57:38 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    07/12/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public class APAJunctionTriggerHandler implements TriggerInterface {

     /**
    * @description handle before Insert event on Trigger
    * @author Lokesh Thathuru | 07/12/2020
    * @param List<SObject> listOfNewSObjects
    * @return void
    */
    public static void beforeInsert(List<SObject> listOfNewSObjects){
        System.debug('<----beforeInsert---->');
       
        
  
    }
    
    
    /**
    * @description handle after Insert event on Trigger
    * @author Lokesh Thathuru | 07/12/2020
    * @param List<SObject> listOfNewSObjects
    * @param Map<Id,SObject> mapOfNewSObjects
    * @return void
    */
    public static void afterInsert(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){
        System.debug('<----afterInsert---->');
        
        Map<Id,AccountProjectAssetJunction__c> mapOfAccountProjectAssetsCount=new Map<Id,AccountProjectAssetJunction__c>();
        Map<Id,String> projectStartupAccountMap =new Map<Id,String>();
        
        if(listOfNewSObjects.size()>0){
            for(AccountProjectAssetJunction__c APAInstance:(List<AccountProjectAssetJunction__c>)listOfNewSObjects){
                if(APAInstance.Project__c!=null && APAInstance.SI_Partner_Account__c!=null){
                    mapOfAccountProjectAssetsCount.put(APAInstance.Id,APAInstance);
                }
            }
        }
        
        if(!mapOfAccountProjectAssetsCount.isEmpty()){
            APAJunctionTriggerHelper.updateSIPartnerAccountWithCount(mapOfAccountProjectAssetsCount);
        }
        
        
        APAJunctionTriggerHelper.updateStartupAccountInProject((Map<Id,AccountProjectAssetJunction__c>)mapOfNewSObjects);
        
        
    }
    
    
    /**
    * @description  handle before Update event on Trigger
    * @author Lokesh Thathuru | 07/12/2020
    * @param Map<Id,SObject> mapOfNewSObjects
    * @param Map<Id,SObject> mapOfOldSObjects
    * @return void
    */
    public static void beforeUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
        System.debug('<------beforeUpdate---->');
       
    }
    
     /**
    * @description  handle After Update event on Trigger
    * @author Lokesh Thathuru | 07/12/2020
    * @param Map<Id,SObject> mapOfNewSObjects
    * @param Map<Id,SObject> mapOfOldSObjects
    * @return void
    */
    public static void afterUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
        System.debug('<----afterUpdate---->');
        ProjectConstants.isFirstTimeApa = FALSE;
        Map<Id,AccountProjectAssetJunction__c> mapOfNewAccountProjectAssets=(Map<Id,AccountProjectAssetJunction__c>)mapOfNewSObjects;
        Map<Id,AccountProjectAssetJunction__c> mapOfOldAccountProjectAssets=(Map<Id,AccountProjectAssetJunction__c>)mapOfOldSObjects;
        
        Map<Id,AccountProjectAssetJunction__c> mapOfAccountProjectAssetsActiveCount=new Map<Id,AccountProjectAssetJunction__c>();
        Map<Id,AccountProjectAssetJunction__c> mapOfAccountProjectAssetsCompleted=new Map<Id,AccountProjectAssetJunction__c>();
        
        
        if(!mapOfNewSObjects.isEmpty()){
            for(AccountProjectAssetJunction__c APAInstance:mapOfNewAccountProjectAssets.values()){
                
                if((APAInstance.Project__c!=null && APAInstance.SI_Partner_Account__c!=null) && APAInstance.Project_Status__c!=mapOfOldAccountProjectAssets.get(APAInstance.Id).Project_Status__c){
                    mapOfAccountProjectAssetsActiveCount.put(APAInstance.Id,APAInstance);
                    mapOfAccountProjectAssetsCompleted.put(APAInstance.Id,APAInstance);
                }
            }
        }
        
        
        if(!mapOfAccountProjectAssetsActiveCount.isEmpty()){
            APAJunctionTriggerHelper.updateSIPartnerAccountWithCount(mapOfAccountProjectAssetsActiveCount);
        }
        
    }
    
     /**
    * @description  handle before delete event on Trigger
    * @author Lokesh Thathuru | 07/12/2020
    * @param List<SObject> listOfOldSObjects
    * @param Map<Id,SObject> mapOfOldSObjects
    * @return void
    */
    public static void beforeDelete(List<SObject> listOfOldSObjects,Map<Id,SObject> mapOfOldSObjects){
        System.debug('<----beforeDelete---->');
        
    }
    
     /**
    * @description  handle after Delete event on Trigger
    * @author Lokesh Thathuru | 07/12/2020
    * @param List<SObject> listOfOldSObjects
    * @return void
    */
    public static void afterDelete(Map<Id,SObject> listOfOldSObjects){
        System.debug('<----afterDelete---->');
        Map<Id,AccountProjectAssetJunction__c> mapOfAccountProjectAssetsCount=new Map<Id,AccountProjectAssetJunction__c>();
        
        if(listOfOldSObjects.size()>0){
            for(AccountProjectAssetJunction__c APAInstance:(List<AccountProjectAssetJunction__c>)listOfOldSObjects.values()){
                if(APAInstance.Project__c!=null && APAInstance.SI_Partner_Account__c!=null){
                    mapOfAccountProjectAssetsCount.put(APAInstance.Id,APAInstance);
                }
            }
        }
        
        if(!mapOfAccountProjectAssetsCount.isEmpty()){
            APAJunctionTriggerHelper.updateSIPartnerAccountWithCount(mapOfAccountProjectAssetsCount);
        }
    }
    
     /**
    * @description  handle after UpDelete event on Trigger
    * @author Lokesh Thathuru | 07/12/2020
    * @param List<SObject> listOfNewSObjects  
    * @param Map<Id,SObject> mapOfNewSObjects
    * @return void
    */
    public static void afterUnDelete(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){
        System.debug('<----afterUnDelete---->');

        Map<Id,AccountProjectAssetJunction__c> mapOfAccountProjectAssetsCount=new Map<Id,AccountProjectAssetJunction__c>();
        
        if(listOfNewSObjects.size()>0){
            for(AccountProjectAssetJunction__c APAInstance:(List<AccountProjectAssetJunction__c>)listOfNewSObjects){
                if(APAInstance.Project__c!=null && APAInstance.SI_Partner_Account__c!=null){
                    mapOfAccountProjectAssetsCount.put(APAInstance.Id,APAInstance);
                }
            }
        }
        
        if(!mapOfAccountProjectAssetsCount.isEmpty()){
            APAJunctionTriggerHelper.updateSIPartnerAccountWithCount(mapOfAccountProjectAssetsCount);
        }
        
    }
    
    
    
}