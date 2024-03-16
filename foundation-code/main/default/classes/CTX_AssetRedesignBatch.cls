public class CTX_AssetRedesignBatch IMPLEMENTS Database.Batchable<sObject> {
    
    public String 				objectName;
    public Map<String, String> 	assetFieldMap;
    
    public CTX_AssetRedesignBatch(String objectName, Map<String, String> assetFieldMap){
        
        this.objectName 	= objectName;
        this.assetFieldMap	= assetFieldMap;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        InternalWrapper thisResult =  returnQueryResult();
        return Database.getQueryLocator(thisResult.queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Asset> scope){ 
        
        List<Asset> assetsToUpdate = new List<Asset>();
        
        if( assetFieldMap == NULL && objectName != NULL ){
            if(scope.size() > 0){
                Map<Id, Asset> filteredAssetMap = new Map<Id, Asset>(scope);
                createChildRecords(filteredAssetMap);
            }
        }
        
        if(assetFieldMap != NULL && objectName == NULL){
            if(scope.size() > 0){
                for(Asset thisRec : scope){
                    for( String thisSTR : assetFieldMap.keySet() ){
                        thisRec.put( assetFieldMap.get(thisSTR), thisRec.get(thisSTR) );
                    }
                    assetsToUpdate.add(thisRec);
                }
            }
            
            Database.update(assetsToUpdate, FALSE);
        }
        
    }
    
    public void finish(Database.BatchableContext BC){}
    
    public InternalWrapper returnQueryResult(){
        
        InternalWrapper wrapperResult = new InternalWrapper();
        
        if(assetFieldMap == NULL && objectName != NULL){
            
            Schema.SObjectType 					targetType	= Schema.getGlobalDescribe().get(objectName);
            Map<String, Schema.SObjectField> 	fieldMap	= targetType.getDescribe().fields.getMap();
            
            for( Schema.SObjectField field : fieldMap.values() ){
                
                if(
                    field.getDescribe().getName().containsIgnoreCase('__c') && 
                    field.getDescribe().getName() != 'Asset__c'				&&
                    field.getDescribe().getName() != 'Account__c'
                ){
                    if(field.getDescribe().isUpdateable()){
                        wrapperResult.assetChildDetailsFields.add(field.getDescribe().getName());
                    }
                }
            }
            system.debug( 'wrapperResult.assetChildDetailsFields: '+wrapperResult.assetChildDetailsFields.size() );
            
            wrapperResult.queryString = ' SELECT Id, AccountId, '+ String.join(wrapperResult.assetChildDetailsFields, ', ');	/**	CSM_Details__, KAM_Details__c, Usage_Details__c	**/
            
            if( objectName == 'Asset_CSM_Details__c' ){
                wrapperResult.queryString =  wrapperResult.queryString + ' , ( SELECT Id, Asset__c, ' + String.join(wrapperResult.assetChildDetailsFields, ', ') +' FROM Asset_CSM_Details__r ) ' + ' FROM Asset ';
            } else if( objectName == 'Asset_KAM_Details__c' ){
                wrapperResult.queryString =  wrapperResult.queryString + ' , ( SELECT Id, Asset__c, ' + String.join(wrapperResult.assetChildDetailsFields, ', ') +' FROM Asset_KAM_Details__r ) ' + ' FROM Asset ';
            } else if( objectName == 'Asset_Usage_Details__c' ){
                wrapperResult.queryString =  wrapperResult.queryString + ' , ( SELECT Id, Asset__c, ' + String.join(wrapperResult.assetChildDetailsFields, ', ') +' FROM Asset_Usage_Details__r ) ' + ' FROM Asset ';
            }
        }
        
        if(assetFieldMap != NULL && objectName == NULL){
            
            wrapperResult.queryString = ' SELECT Id, ' + String.join(new List<String>(assetFieldMap.keySet()), ', ') + ', ' 
                + String.join(assetFieldMap.values(), ', ') + ' FROM Asset ';
        }
        
        system.debug('wrapperResult: '+wrapperResult);
        return wrapperResult;
    }
    
    public void createChildRecords( Map<Id, Asset> filteredAssetMap ){
        
        InternalWrapper						wrapperResult		= returnQueryResult();
        List<Asset_CSM_Details__c> 			assetCSMDetails 	= new List<Asset_CSM_Details__c>();
        List<Asset_KAM_Details__c> 			assetKAMDetails 	= new List<Asset_KAM_Details__c>();
        List<Asset_Usage_Details__c> 		assetUsageDetails 	= new List<Asset_Usage_Details__c>();
        
        for( Asset thisRec : filteredAssetMap.values() ){
            Set<Id> assetWithChildRecords = new Set<Id>();
            
            if( objectName == 'Asset_CSM_Details__c' ){
                if(thisRec.Asset_CSM_Details__r != NULL && thisRec.Asset_CSM_Details__r.size() > 0){
                    for(Asset_CSM_Details__c thisChild : thisRec.Asset_CSM_Details__r){
                        
                        assetWithChildRecords.add(thisChild.Asset__c);
                        Asset_CSM_Details__c tempRecord = new Asset_CSM_Details__c(Id = thisChild.Id);
                        for( String thisSTR : wrapperResult.assetChildDetailsFields ){
                            tempRecord.put(thisSTR, thisRec.get(thisSTR));
                        }
                        
                        assetCSMDetails.add(tempRecord);
                    }
                }
                
                if( !assetWithChildRecords.contains(thisRec.Id) ){
                    
                    Asset_CSM_Details__c tempRecord = new Asset_CSM_Details__c();
                    for( String thisSTR : wrapperResult.assetChildDetailsFields ){
                        tempRecord.put(thisSTR, thisRec.get(thisSTR));
                    }
                    
                    tempRecord.put('Asset__c', thisRec.Id);
                    tempRecord.put('Account__c', thisRec.AccountId);
                    assetCSMDetails.add(tempRecord);
                }
            } else if( objectName == 'Asset_KAM_Details__c' ){
                if(thisRec.Asset_KAM_Details__r != NULL && thisRec.Asset_KAM_Details__r.size() > 0){
                    for(Asset_KAM_Details__c thisChild : thisRec.Asset_KAM_Details__r){
                        
                        assetWithChildRecords.add(thisChild.Asset__c);
                        Asset_KAM_Details__c tempRecord = new Asset_KAM_Details__c(Id = thisChild.Id);
                        for( String thisSTR : wrapperResult.assetChildDetailsFields ){
                            tempRecord.put(thisSTR, thisRec.get(thisSTR));
                        }
                        
                        assetKAMDetails.add(tempRecord);
                    }
                }
                
                if( !assetWithChildRecords.contains(thisRec.Id) ){
                    
                    Asset_KAM_Details__c tempRecord = new Asset_KAM_Details__c();
                    for( String thisSTR : wrapperResult.assetChildDetailsFields ){
                        tempRecord.put(thisSTR, thisRec.get(thisSTR));
                    }
                    
                    tempRecord.put('Asset__c', thisRec.Id);
                    tempRecord.put('Account__c', thisRec.AccountId);
                    assetKAMDetails.add(tempRecord);
                }
            } else if( objectName == 'Asset_Usage_Details__c' ){
                if(thisRec.Asset_Usage_Details__r != NULL && thisRec.Asset_Usage_Details__r.size() > 0){
                    for(Asset_Usage_Details__c thisChild : thisRec.Asset_Usage_Details__r){
                        
                        assetWithChildRecords.add(thisChild.Asset__c);
                        Asset_Usage_Details__c tempRecord = new Asset_Usage_Details__c(Id = thisChild.Id);                        
                        for( String thisSTR : wrapperResult.assetChildDetailsFields ){
                            tempRecord.put(thisSTR, thisRec.get(thisSTR));
                        }
                        
                        assetUsageDetails.add(tempRecord);
                    }
                }
                
                if( !assetWithChildRecords.contains(thisRec.Id) ){
                    
                    Asset_Usage_Details__c tempRecord = new Asset_Usage_Details__c();
                    for( String thisSTR : wrapperResult.assetChildDetailsFields ){
                        tempRecord.put(thisSTR, thisRec.get(thisSTR));
                    }
                    
                    tempRecord.put('Asset__c', thisRec.Id);
                    tempRecord.put('Account__c', thisRec.AccountId);
                    assetUsageDetails.add(tempRecord);
                }
            }
        }
        
        if( objectName == 'Asset_CSM_Details__c' &&  assetCSMDetails.size() > 0 ){
            
            system.debug('assetCSMDetails: '+assetCSMDetails.size());
            upsert assetCSMDetails;
        } else if( objectName == 'Asset_KAM_Details__c' && assetKAMDetails.size() > 0 ){
            
            system.debug('assetKAMDetails: '+assetKAMDetails.size());
            upsert assetKAMDetails;
        } else if( objectName == 'Asset_Usage_Details__c' && assetUsageDetails.size() > 0 ){

            system.debug('assetUsageDetails: '+assetUsageDetails.size());
            upsert assetUsageDetails;
        }
        
    }
    
    Public Class InternalWrapper{
        
        public string 		queryString;
        public List<String> assetChildDetailsFields = new List<String>();
    }
    
}