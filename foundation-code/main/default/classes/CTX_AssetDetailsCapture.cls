public class CTX_AssetDetailsCapture {
    
    public static void getAssetDetails(List<Asset> newAssets, Map<Id, Asset> oldAssetMap){
        
        Map<Id, Asset>		accountIdLicenseAssetMap		= new Map<Id, Asset>();
        Set<Id> 			accountIdSet					= new Set<Id>();
        Map<Id, Id>			assetMapIntegrationLicense		= new Map<Id, Id>();
        List<Asset> 		licenseAssets;
        
        for(Asset thisAsset : newAssets){
            
            if(thisAsset.RecordTypeId == AssetConstants.ASSET_INTEGRATION_RECORDTYPEID){
                
                system.debug('I am in Asset After Update / Insert Block');
                accountIdLicenseAssetMap.put(thisAsset.accountId, thisAsset);
            }
        }	/**	Colse of Asset For to Fetch Details	**/
        
        if(accountIdLicenseAssetMap.size() > 0){
            
            licenseAssets = [ SELECT Id, AccountId, Project_Status__c, Project_Stage__c, Project_Awaiting_Kick_Off_Date__c, Project_Complete_Live_Date__c, 
                             Project_Estimated_Go_Live_Date__c, Project_Scope_Category__c, ProductFamily 
                             FROM Asset WHERE 
                             AccountId IN :accountIdLicenseAssetMap.keySet() AND 
                             RecordTypeId = :AssetConstants.ASSET_LICENSE_RECORDTYPEID ];
            
            system.debug('licenseAssets: '+licenseAssets.size());
            for(Asset thisRec : licenseAssets){
                
                
                if(accountIdLicenseAssetMap.containsKey(thisRec.AccountId)){
                    
                    if(thisRec.ProductFamily == 'E-invoice & EWB' ){
                        if(accountIdLicenseAssetMap.get(thisRec.AccountId).ProductFamily == 'E-invoice & EWB'){
                            
                            thisRec.Related_Integration_Asset__c 		= accountIdLicenseAssetMap.get(thisRec.AccountId).Id;
                            thisRec.ERP__c 								= accountIdLicenseAssetMap.get(thisRec.AccountId).ERP__c;
                            thisRec.Project_Status__c 					= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Status__c;
                            thisRec.Project_Stage__c 					= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Stage__c;
                            thisRec.Project_Awaiting_Kick_Off_Date__c	= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Awaiting_Kick_Off_Date__c;
                            thisRec.Project_Complete_Live_Date__c 		= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Complete_Live_Date__c;
                            thisRec.Project_Estimated_Go_Live_Date__c 	= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Estimated_Go_Live_Date__c;
                            thisRec.Project_Scope_Category__c 			= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Scope_Category__c;
                        }
                    }
                    //Start Add Invoicing Product Family by Mohan Raj
                    if(thisRec.ProductFamily == 'Invoicing' ){
                        if(accountIdLicenseAssetMap.get(thisRec.AccountId).ProductFamily == 'Invoicing'){
                            
                            thisRec.Related_Integration_Asset__c 		= accountIdLicenseAssetMap.get(thisRec.AccountId).Id;
                            thisRec.ERP__c 								= accountIdLicenseAssetMap.get(thisRec.AccountId).ERP__c;
                            thisRec.Project_Status__c 					= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Status__c;
                            thisRec.Project_Stage__c 					= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Stage__c;
                            thisRec.Project_Awaiting_Kick_Off_Date__c	= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Awaiting_Kick_Off_Date__c;
                            thisRec.Project_Complete_Live_Date__c 		= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Complete_Live_Date__c;
                            thisRec.Project_Estimated_Go_Live_Date__c 	= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Estimated_Go_Live_Date__c;
                            thisRec.Project_Scope_Category__c 			= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Scope_Category__c;
                        }
                    }
                    //End Added Invoicing Product Family by Mohan Raj
                    if(thisRec.ProductFamily == 'GST' ){
                        
                        if(accountIdLicenseAssetMap.get(thisRec.AccountId).ProductFamily == 'GST'){
                            
                            thisRec.Project_Status__c 					= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Status__c;
                            thisRec.Project_Stage__c 					= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Stage__c;
                            thisRec.Project_Awaiting_Kick_Off_Date__c	= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Awaiting_Kick_Off_Date__c;
                            thisRec.Project_Complete_Live_Date__c 		= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Complete_Live_Date__c;
                            thisRec.Project_Estimated_Go_Live_Date__c 	= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Estimated_Go_Live_Date__c;
                            thisRec.Project_Scope_Category__c 			= accountIdLicenseAssetMap.get(thisRec.AccountId).Project_Scope_Category__c;
                        } 
                    }
                    
                }
            }
        }
        
        if(licenseAssets != NULL){
            
            try{
                RecursiveTriggerHandler.isFirstTime = FALSE; //Added by Ashwin - SOQL 101
                update licenseAssets;
                RecursiveTriggerHandler.isFirstTime = TRUE;
            } catch(Exception ex){
                system.debug('CTX_AssetDetailsCapture Assert Update Fail: '+ex.getMessage());
            }
        }
    }
    
    
}