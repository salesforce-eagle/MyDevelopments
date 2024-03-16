Global Class CTX_ProductSyncByProductCodeBatch IMPLEMENTS 
Database.Batchable<sObject>, 
Database.Stateful, 
Database.AllowsCallouts, 
Schedulable, 
Database.RaisesPlatformEvents 
{
    
    PRIVATE STATIC FINAL INTEGER 							STATUSCODE_SUCCESS 	= 200;
    Private Map<String, WrapperCTX_ProductSync_Parse.Plans>	productWrapperMap	= new Map<String, WrapperCTX_ProductSync_Parse.Plans>();
    List<WrapperCTX_ProductSync_Parse.ResourceConstraints> 	resourceList 		= new List<WrapperCTX_ProductSync_Parse.ResourceConstraints>();
    Map<String, Object> 									prodInfoMap 		= new Map<String, Object>();
    Map<String, Object> 									prodPlanMap 		= new Map<String, Object>();
    Private String											queryString;
    Private List<WrapperCTX_ProductSync_Parse.plans>		responseParse;
    Map<String, Map<String, Object>>	productInfoMapNew	= new Map<String, Map<String, Object>>();
    
    
    
    public CTX_ProductSyncByProductCodeBatch( List<WrapperCTX_ProductSync_Parse.Plans> responseParse ){
        
        this.responseParse = responseParse;
        
        for(WrapperCTX_ProductSync_Parse.Plans thisRec : this.responseParse){
            productWrapperMap.put(thisRec.sfPlanName, thisRec);
            prodPlanMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize( thisRec));
            
            for(WrapperCTX_ProductSync_Parse.ResourceConstraints thisRecResourceConstraints : thisRec.ResourceConstraints){
                prodInfoMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize( thisRecResourceConstraints)); 
                productInfoMapNew.put(thisRec.sfPlanName,prodInfoMap);
                resourceList.add(thisRecResourceConstraints);
            }
            
        }
        
        system.debug('productWrapperMap: '+productWrapperMap);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Set<String> productCodeSet = new Set<String>(productWrapperMap.keySet());
        queryString = 'SELECT Id, Name, ProductCode, Description, IsActive, CreatedDate, CreatedById, '+
            'LastModifiedDate, LastModifiedById, SystemModstamp, Family, CurrencyIsoCode, ExternalDataSourceId,'+
            ' ExternalId, DisplayUrl, QuantityUnitOfMeasure, IsDeleted, IsArchived, LastViewedDate, LastReferencedDate,'+
            ' StockKeepingUnit, Asset__c, Billing_Type__c, External_Id__c, Onboarding_status__c, Product_category__c, '+
            'Usage_status_from_metadata__c, Formula__c, Module__c, New_Product_Family__c, OrderForm_Product_Name__c,'+
            ' Product_Group_C__c, Licensing_Product_Name_for_Display__c, Product_Buckets_C__c, Product_Id__c, '+
            'Threshold_List_Price__c, Corrected_Module_for_metering__c, Country_of_Origin__c, Product_family_New__c,'+
            ' Product_Line__c, Product_ID_18__c, Threshold_Price__c, Is_Licence_to_be_created__c, Product_License__c,'+
            ' Customer_Cohort__c, To_be_included_for_Risk__c, Record_Type_Product_Visibility__c,'+
            ' Module_for_Type_of_Integration_Threshold__c, Is_Custom_Plans_Allowed__c, Is_Standard__c,'+
            ' Product_Plan_Id__c, Plan_Allowance_GSTIN__c, Plan_Allowance_PAN__c, Plan_Allowance_IRN__c,'+
            ' Plan_Topup_Threshold_GSTIN__c, Plan_Topup_Threshold_PAN__c, Plan_Topup_Threshold_IRN__c'+
            ' FROM Product2 WHERE'+
            ' ProductCode IN : productCodeSet';
        
        return database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<Product2> productsList){
        
        system.debug('productsList: '+productsList);
        system.debug('productsList Size: '+productsList.size());
        
        List<Product2>										productsToUpdate 	   = new List<Product2>();
        Map<String,Product2> 									prodCodeMap 		= new Map<String,Product2>();
        Map<String, Product_Table_Sync_Field_Related_Info__mdt> mapProductMapping	= Product_Table_Sync_Field_Related_Info__mdt.getAll();
        Map<String, Product_Table_Sync_Field_Related_Info__mdt> sfProductCodeMap	= new Map<String, Product_Table_Sync_Field_Related_Info__mdt>();
        
        
        for(product2 prod : productsList){
            prodCodeMap.put(prod.productCode, prod);
        }
        
        for(Product_Table_Sync_Field_Related_Info__mdt mdtIns : mapProductMapping.Values()){
            sfProductCodeMap.put(mdtIns.developerName, mdtIns);
        }
        /** 
system.debug('sfProductCodeMap: '+sfProductCodeMap);

for(String productCodeName : productWrapperMap.keySet()){

system.debug('Inside productCodeName : '+productCodeName);
for( WrapperCTX_ProductSync_Parse.Plans thisRec : productWrapperMap.values() ){
prodInfoMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize( thisRec.ResourceConstraints)); 

for(String fieldName : sfProductCodeMap.keySet()){
if(prodInfoMap.containsKey(fieldName)){
system.debug('Inside fieldName: '+fieldName);
prodCodeMap.get(productCodeName).put(
sfProductCodeMap.get(fieldName).Related_Field__c,prodInfoMap.get(sfProductCodeMap.get(fieldName).developerName));
}
}
}

}**/
        
        
        for(WrapperCTX_ProductSync_Parse.Plans resourceIns : productWrapperMap.Values()){
            Product2 prodIns = prodCodeMap.get(resourceIns.sfPlanName);
          
            system.debug('String.ValueOf(resourceIns.planId:' +String.ValueOf(resourceIns.planId));
            if(String.ValueOf(resourceIns.planId) != 'null' && prodIns != NULL){
                prodIns.put('Is_Standard__c', TRUE);
                prodIns.put('Product_Plan_Id__c',String.ValueOf(resourceIns.planId));
            }
            system.debug('sfPlanName:'+resourceIns.sfPlanName);
            for(Product_Table_Sync_Field_Related_Info__mdt mdtIns : mapProductMapping.Values()){
                if( prodCodeMap.containsKey(resourceIns.sfPlanName)){
                    //prodIns.put(mdtIns.Related_Field__c,String.ValueOf(productInfoMapNew.get(resourceIns.sfPlanName).get(mdtIns.developerName)));
                 
                    for(WrapperCTX_ProductSync_Parse.ResourceConstraints resourceVal : resourceIns.resourceConstraints){
                        system.debug(resourceVal.resource+':'+resourceVal.threshold);
                        if(resourceVal.threshold != NULL){
                            if(resourceVal.resource == mdtIns.Resource__c){
                                system.debug('TEstval:'+String.ValueOf(resourceVal.threshold));
                                system.debug(mdtIns.Related_Field__c+':'+Integer.ValueOf(resourceVal.threshold));
                                prodIns.put(mdtIns.Related_Field__c,Integer.ValueOf(resourceVal.threshold));
                            }
                        }
                    }
                    prodIns.put('Plan_Tier__c', resourceIns.planTier);
                    prodIns.put('Constraint_JSON__c',JSON.serialize(productInfoMapNew.get(resourceIns.sfPlanName)));
                    system.debug('prodIns'+prodIns);
                }
                
            }
            if(prodIns != NULL){
                system.debug('prodInsListIns'+prodIns) ;  
                productsToUpdate.add(prodIns);
            }
        }
        
        
        if(productsToUpdate.Size()> 0){
            Database.update(productsToUpdate, TRUE);
        }
        
        
    }
    
    
    
    global void finish(Database.BatchableContext BC) {}
    
    global void execute(SchedulableContext SC) {
        CTX_ProductSyncByProductCodeCallout.requestCallout();        
    }
}