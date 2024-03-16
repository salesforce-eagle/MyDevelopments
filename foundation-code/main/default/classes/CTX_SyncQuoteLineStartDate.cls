public class CTX_SyncQuoteLineStartDate {
    
    public static void syncQuoteStartDate( 
        Map<Id,QuoteLineItem> 			newLicenseQLIMap,
        Map<Id,QuoteLineItem> 			newIntegrationQLIMap,
        Map<Id, List<QuoteLineItem>>	mapQuoteIdAndRelatedQLI
    ){
        
        Map<String, String>				licenseIntegrationProductCodeMap	= new Map<String, String>();
        Map<String, List<String>>		integrationLicenseProductCodeMap	= new Map<String, List<String>>();
        Map<Id, QuoteLineItem> 			updateQuoteLineItem 				= new Map<Id, QuoteLineItem>();
        Id currentProfileId = userinfo.getProfileId();
        
        for(
            QLI_License_Integration_Mapping__mdt thisRec : QLI_License_Integration_Mapping__mdt.getAll().values()
        ){
            licenseIntegrationProductCodeMap.put(thisRec.License_Product_Code__c, thisRec.Integration_Product_Code__c);
            if(integrationLicenseProductCodeMap.containsKey(thisRec.Integration_Product_Code__c)){
                integrationLicenseProductCodeMap.get(thisRec.Integration_Product_Code__c).add(thisRec.License_Product_Code__c);
            }else{
                integrationLicenseProductCodeMap.put(thisRec.Integration_Product_Code__c, new List<String> {thisRec.License_Product_Code__c});
            }
            
        }
        
        for(Id thisQuoteId : mapQuoteIdAndRelatedQLI.keySet()){
            Map<String, QuoteLineItem> 	LicensingQuoteLineItem 			= new Map<String, QuoteLineItem>();
            Map<String, QuoteLineItem> 	IntegrationQuoteLineItem 		= new Map<String, QuoteLineItem>();
            Map<String, QuoteLineItem> 	IntegrationQuoteLineItemMap 	= new Map<String, QuoteLineItem>();
            for(QuoteLineItem thisRec : mapQuoteIdAndRelatedQLI.get(thisQuoteId)){
                System.debug('@thisRec'+thisRec);
                if(licenseIntegrationProductCodeMap.containskey(thisRec.Product2.ProductCode)){
                    if(thisRec.Stage_in_MY__c != NULL){
                        if(thisRec.Stage_in_MY__c == 'Year 1'){
                            LicensingQuoteLineItem.put(thisRec.Product2.ProductCode, thisRec);    
                        }
                    } else{
                        
                        LicensingQuoteLineItem.put(thisRec.Product2.ProductCode, thisRec);
                    }
                    
                    
                }else{
                    if(thisRec.Stage_in_MY__c != NULL){
                        if(thisRec.Stage_in_MY__c == 'Year 1'){
                            IntegrationQuoteLineItem.put(thisRec.Product2.ProductCode, thisRec);   
                        }
                    } else{
                        
                        IntegrationQuoteLineItem.put(thisRec.Product2.ProductCode, thisRec);
                    }
                    
                    IntegrationQuoteLineItemMap.put(thisRec.Product2.ProductCode+thisRec.Id, thisRec);
                }
                
            }
            System.debug('@LicensingQuoteLineItem'+LicensingQuoteLineItem);
            System.debug('@#IntegrationQuoteLineItem'+IntegrationQuoteLineItem);
            
            for(QuoteLineItem thisQli : LicensingQuoteLineItem.values()){
                String getIntegrationCode = licenseIntegrationProductCodeMap.get(thisQli.Product2.ProductCode);
                if(thisQli.Period_Start_date__c != NULL &&
                   IntegrationQuoteLineItem.containsKey(getIntegrationCode) &&
                   IntegrationQuoteLineItem.get(getIntegrationCode).Period_Start_date__c != NULL  &&
                   newLicenseQLIMap.containsKey(thisQli.Id)){
                       if(!(System.label.SystemAdminProfileId.contains(currentProfileId)) && newLicenseQLIMap.get(thisQli.Id).Period_Start_date__c > IntegrationQuoteLineItem.get(getIntegrationCode).Period_Start_date__c){
                           newLicenseQLIMap.get(thisQli.Id).addError('Period start date of '+thisQli.product2.Name+' should be lesser than '+IntegrationQuoteLineItem.get(getIntegrationCode).product2.Name);
                       }
                   }
            }
            
            
            for(QuoteLineItem thisQli : IntegrationQuoteLineItemMap.values()){
                List<String> getLicenseCode = new List<String>();
                if(integrationLicenseProductCodeMap.containsKey(thisQli.Product2.ProductCode)){
                    getLicenseCode = integrationLicenseProductCodeMap.get(thisQli.Product2.ProductCode); 
                }
                
                if(getLicenseCode.size()>0){
                    for(String str : getLicenseCode){
                        if(LicensingQuoteLineItem.containsKey(str)			  &&
                           LicensingQuoteLineItem.get(str).Period_Start_date__c != NULL){
                               if(thisQli.Period_Start_date__c != NULL &&
                                  newIntegrationQLIMap.containsKey(thisQli.Id)){
                                      System.debug('@newIntegrationQLIMap'+thisQli.Id);
                                      if(newIntegrationQLIMap.get(thisQli.Id).Related_Quote_Line_Item__c == NULL){
                                          newIntegrationQLIMap.get(thisQli.Id).Related_Quote_Line_Item__c = LicensingQuoteLineItem.get(str).Id; 
                                      }
                                      if(!(System.label.SystemAdminProfileId.contains(currentProfileId)) && newIntegrationQLIMap.get(thisQli.Id).Period_Start_date__c < LicensingQuoteLineItem.get(str).Period_Start_date__c){
                                          newIntegrationQLIMap.get(thisQli.Id).addError('Period start date of '+thisQli.product2.Name+' should be greater '+LicensingQuoteLineItem.get(str).product2.Name);
                                      }
                                  }
                               
                               if(Trigger.isInsert){
                                   thisQli.Period_Start_date__c = LicensingQuoteLineItem.get(str).Period_Start_date__c;
                                   updateQuoteLineItem.put(thisQli.Id, thisQli);
                               }
                               
                           } 
                        
                    }
                    
                }
                
            }
        }
        
        try{
            if(updateQuoteLineItem.values().size() > 0){
                update updateQuoteLineItem.values(); 
            }           
        }Catch(Exception ex){
            System.debug(' Exception on CTX_SyncQuoteLineStartDate \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
        
    }
    
}