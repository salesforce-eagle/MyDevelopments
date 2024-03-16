Global Class CTX_ProductSyncByProductLineBatch IMPLEMENTS 
Database.Batchable<sObject>, 
Database.Stateful, 
Database.AllowsCallouts, 
Schedulable, 
Database.RaisesPlatformEvents 
{
    
    PRIVATE STATIC FINAL INTEGER 	STATUSCODE_SUCCESS 				= 200;
    Private Map<String, Boolean>	productLineToIsCustomAllowedMap	= new Map<String, Boolean>();
    Private String					queryString;
    Private List<WrapperCTX_ProductSync_Parse.ProductSFMapping>	responseParse;
    
    public CTX_ProductSyncByProductLineBatch( List<WrapperCTX_ProductSync_Parse.ProductSFMapping> responseParse ){
        
        this.responseParse = responseParse;
        
        for(WrapperCTX_ProductSync_Parse.ProductSFMapping thisRec : this.responseParse){
            productLineToIsCustomAllowedMap.put(thisRec.sfProductName, thisRec.isCustomPlanAllowed);
        }
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        set<String> productLines = new set<String>(productLineToIsCustomAllowedMap.keySet());
        queryString = 'SELECT Id, Name, Is_Custom_Plans_Allowed__c, Product_Line__c FROM Product2 WHERE Product_Line__c IN : productLines';
        return database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<Product2> productsList){
        
        List<Product2> productsToUpdate = new List<Product2>();
        
        for(Product2 product : productsList){
            if(
                product.Is_Custom_Plans_Allowed__c != productLineToIsCustomAllowedMap.get(product.Product_Line__c)
            ){
                product.Is_Custom_Plans_Allowed__c = productLineToIsCustomAllowedMap.get(product.Product_Line__c);
                productsToUpdate.add(product);
            }
        }
        
        if(!productsToUpdate.isEmpty()){
            Database.update(productsToUpdate, FALSE);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {}
    
    global void execute(SchedulableContext SC) {
        CTX_ProductSyncByProductLineCallout.requestCallout();        
    }
}