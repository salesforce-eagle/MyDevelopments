public class AdditionalGSTINsController {
    @AuraEnabled
    public static Wrapper getDetails(String oppId){
        List<AdditionGSTIN> listOfAddtionalGSTINs = new List<AdditionGSTIN>(); 
        Wrapper wap = new Wrapper();
        List<Opportunity> oppDetails = [SELECT id,stageName, Country_of_Origin__c, SyncedQuoteId FROM Opportunity WHERE id=:oppId LIMIT 1];
        if(oppDetails[0].stageName == 'Pre SQL' || oppDetails[0].stageName == 'SQL' || oppDetails[0].stageName == 'POC'){
            //wap.errorMsg = 'You can add Additional GSTIN  in Quote Management or further stages';
            return wap;
        }
        if(oppDetails[0].stageName == 'In Finance Approval' || oppDetails[0].stageName == 'Closed Won'){
            wap.errorMsgClosedOrFin = true;
        }
        if(oppDetails[0].Country_of_Origin__c != 'N/A' && oppDetails[0].Country_of_Origin__c != NULL && oppDetails[0].Country_of_Origin__c != 'INDIA'){
            wap.isGcc = true;
        }
        
        if(oppDetails[0].SyncedQuoteId == null){
            wap.errorMsg = 'Please Sync the Quote.';
            return wap;
        }else{
            wap.quoteID = oppDetails[0].SyncedQuoteId;
        }
        System.debug('wap '+wap);
        List<QuoteLineItem> listOfQLI = [SELECT id, Product2Id, Product2.Name, Product2.Billing_Type__c,Total_Price__c  
                                         FROM QuoteLineItem 
                                         WHERE QuoteId=:oppDetails[0].SyncedQuoteId AND (NOT Product2.Name LIKE '% Pass Through')];
        System.debug('listOfQLI '+listOfQLI);
        if(!listOfQLI.isEmpty()){
            wap.listOfQLI = listOfQLI;
        }
        System.debug('wap '+wap);
        List<Additional_GSTIN__c> listOfAddtnlGSTINs = [SELECT id, Quote_Line_Item__c, Quote__c,Quote__r.Opportunity.Update_Company_Information__c, Name, Quote_Line_Item__r.Product2Id, 
                                                        Quote_Line_Item__r.Product2.Name, Address__c,Amount__c,Address_Line_2__c,city__c,Quote__r.Opportunity.Country_of_Origin__c,
                                                        state__c,pincode__c,Name_Of_The_Customer__c,Billing_Pan__c,TAN__c,CIN__c,SEZ_yes_no__c, CR_Number__c,TIN_Number__c
                                                        FROM Additional_GSTIN__c WHERE Quote__c =:oppDetails[0].SyncedQuoteId];
        System.debug('listOfAddtnlGSTINs '+listOfAddtnlGSTINs);
        if(!listOfAddtnlGSTINs.isEmpty()){
            wap.listOfAdtnlGSTIN = listOfAddtnlGSTINs;
        } 
        for(Additional_GSTIN__c ag : listOfAddtnlGSTINs){
            AdditionGSTIN AGWap = new AdditionGSTIN();
            AGWap.Id = ag.Id;
            AGWap.QuteLineItemId = ag.Quote_Line_Item__c;
            AGWap.productId = ag.Quote_Line_Item__r.Product2Id;
            AGWap.productName = ag.Quote_Line_Item__r.Product2.Name;
            AGWap.GSTIN = ag.Name;
            AGWap.billingAddrs1 = ag.Address__c;
            AGWap.billingAddrs2 = ag.Address_Line_2__c;
            AGWap.city = ag.city__c;
            AGWap.state = ag.state__c;
            AGWap.pincode = ag.pincode__c;
            AGWap.amount = ag.Amount__c;
            AGWap.nameOfTheCustomer = ag.Name_Of_The_Customer__c;
            AGWap.billingPan = ag.Billing_Pan__c;
            AGWap.tan = ag.TAN__c;
            AGWap.cin = ag.CIN__c;
            AGWap.sez = ag.SEZ_yes_no__c;
            AGWap.CRNumber = ag.CR_Number__c;
            AGWap.tinNumber = ag.TIN_Number__c;
            AGWap.nameOfEntity = ag.Name_Of_The_Customer__c;
            if(ag.Quote__r.Opportunity.Country_of_Origin__c != 'N/A' && ag.Quote__r.Opportunity.Country_of_Origin__c != NULL && ag.Quote__r.Opportunity.Country_of_Origin__c != 'INDIA'){
                AGWap.disbaleInfo = TRUE;
            }else{
                AGWap.disbaleInfo = ag.Quote__r.Opportunity.Update_Company_Information__c;
            }
            
            listOfAddtionalGSTINs.add(AGWap);
        }
        if(!listOfAddtionalGSTINs.isEmpty()){
            wap.listOfAdditionGSTIN = listOfAddtionalGSTINs;
            System.debug(' wap.listOfAdditionGSTIN '+ wap.listOfAdditionGSTIN);
        }else{
            AdditionGSTIN AGWap = new AdditionGSTIN();
            AGWap.Id = '';
            AGWap.QuteLineItemId = '';
            AGWap.productId = '';
            AGWap.productName = '';
            AGWap.GSTIN = '';
            AGWap.billingAddrs1 = '';
            AGWap.billingAddrs2 = '';
            AGWap.city = '';
            AGWap.state = '';
            AGWap.pincode = '';
            AGWap.amount = null;
            AGWap.nameOfTheCustomer = '';
            AGWap.billingPan = '';
            AGWap.tan ='';
            AGWap.cin ='';
            AGWap.sez = '';
            AGWap.CRNumber = '';
            AGWap.tinNumber = '';
            AGWap.nameOfEntity = '';
            listOfAddtionalGSTINs.add(AGWap);
            wap.listOfAdditionGSTIN = listOfAddtionalGSTINs;
        }
        System.debug('listOfAddtionalGSTINs '+listOfAddtionalGSTINs);
        System.debug('wap '+wap);
        return wap;
    }
    @AuraEnabled
    public static String saveDetails(String listOfGstinToUpsertWrapper, List<String> listOfGstinToDelete, String quoteId, String opportunityId, Boolean isGCC){ //List<AdditionGSTIN>
        try{
            List<Additional_GSTIN__c> 	listOfAdditionalGstinsToUpsert 	= new List<Additional_GSTIN__c>();
            List<Additional_GSTIN__c> 	listOfAdditionalGstinToDelete 	= new List<Additional_GSTIN__c>();
            
            //Map<String, Business_Partner__c> billingPANtoBusinessPartnerMap 	= new Map<String,Business_Partner__c>(); // Added For Business Partnert Creattion : Niraj
            isGCC = isGCC != NULL && isGCC ? isGCC : FALSE;
            System.debug('@isGCC '+isGCC);    
            System.debug('listOfGstinToUpsertWrapper '+listOfGstinToUpsertWrapper);
            System.debug('listOfGstinToDelete '+listOfGstinToDelete);
            System.debug('quoteId '+quoteId);
            for(String IdsToDelete : listOfGstinToDelete){
                Additional_GSTIN__c ag = new Additional_GSTIN__c();
                ag.Id =IdsToDelete;
                listOfAdditionalGstinToDelete.add(ag);
            }
            List<AdditionGSTIN> additionalGstinWrap = (List<AdditionGSTIN>)JSON.deserialize(listOfGstinToUpsertWrapper,List<AdditionGSTIN>.class);
            
            
            for(AdditionGSTIN ag : additionalGstinWrap){
                /** Added For Business Partnert Creattion : Niraj **/
                String billingPAN = ag.GSTIN.substring(2,12);
                /*if(!billingPANtoBusinessPartnerMap.containsKey(billingPAN)){
                    billingPANtoBusinessPartnerMap.put(billingPAN, 
                                                       new Business_Partner__c(
                                                           Name 			= billingPAN,
                                                           Billing_Pan__c	= billingPAN
                                                       )
                                                      );
                }
                 Added For Business Partnert Creattion : Niraj **/
                
                Additional_GSTIN__c eachAG = new Additional_GSTIN__c();
                if(ag.Id != null && ag.Id != ''){
                    eachAG.Id = ag.Id; 
                }
                
                System.debug('@CRNumber'+ag.CRNumber);
                System.debug('@tinNumber'+ag.tinNumber);
                System.debug('@nameOfTheCustomer'+ag.nameOfTheCustomer);
                System.debug('@nameOfEntity'+ag.nameOfEntity);
                eachAG.Name = ag.GSTIN;
                eachAG.Quote__c = quoteId;
                eachAG.Quote_Line_Item__c = ag.QuteLineItemId;
                eachAG.Amount__c = ag.amount;
                eachAG.Address__c = ag.billingAddrs1;
                eachAG.Address_Line_2__c = ag.billingAddrs2;
                eachAG.city__c = ag.city;
                eachAG.state__c = ag.state;
                eachAG.pincode__c = ag.pincode;
                eachAG.Name_Of_The_Customer__c = ag.nameOfTheCustomer;
                eachAG.Billing_Pan__c = billingPAN;
                eachAG.TAN__c = ag.tan;
                eachAG.CIN__c = ag.cin;
                eachAG.SEZ_yes_no__c = ag.sez;
                eachAg.CR_Number__c = ag.CRNumber;
                eachAg.TIN_Number__c = ag.tinNumber;
                eachAG.Opportunity__c = opportunityId;
               // if(!isGcc && ag.nameOfTheCustomer == '' || ag.nameOfTheCustomer == NULL){
                    eachAG.Name_Of_The_Customer__c = ag.nameOfEntity;
              //  }
                if(isGcc){
                    System.debug('@gcc here');
                    eachAG.RecordTypeId = Schema.SObjectType.Additional_GSTIN__c.getRecordTypeInfosByDeveloperName().get('International').getRecordTypeId();
                    //eachAG.Name_Of_The_Customer__c = ag.nameOfEntity;
                }
                listOfAdditionalGstinsToUpsert.add(eachAG);
            }
            /** Added For Business Partnert Creattion : Niraj 
            if(billingPANtoBusinessPartnerMap.size() > 0){
                Database.upsert(billingPANtoBusinessPartnerMap.values(), Business_Partner__c.fields.Billing_PAN__c, false);
            }
            
            for(Additional_GSTIN__c addGST : listOfAdditionalGstinsToUpsert){
                String billingPAN = addGST.Name.substring(2,12);
                addGST.Business_Partner_SAP__c  = billingPANtoBusinessPartnerMap.get(billingPAN).Id;
                
			}**/
            /** Added For Business Partnert Creattion : Niraj **/
            
            System.debug('listOfAdditionalGstinToDelete '+listOfAdditionalGstinToDelete);
            System.debug('listOfAdditionalGstinsToUpsert '+listOfAdditionalGstinsToUpsert);
            if(!listOfAdditionalGstinToDelete.isEmpty()){
                delete listOfAdditionalGstinToDelete;
            }
            if(!listOfAdditionalGstinsToUpsert.isEmpty()){
                upsert listOfAdditionalGstinsToUpsert;
            }
        }catch(Exception e){
            System.debug('Exception Line no '+e.getLineNumber());
            System.debug('Exception MSG '+e.getMessage());
            System.debug('Exception Type '+e.getTypeName());
            System.debug('Exception Cause '+e.getCause());
            System.debug('Exception stack trace '+e.getStackTraceString());
            return e.getMessage();
        }
        return '';
    }
    public class Wrapper{
        @AuraEnabled
        public String errorMsg;
        @AuraEnabled
        public Boolean errorMsgClosedOrFin;
        @AuraEnabled
        public String quoteID;
        @AuraEnabled
        public List<QuoteLineItem> listOfQLI;
        @AuraEnabled
        public List<Additional_GSTIN__c> listOfAdtnlGSTIN;
        @AuraEnabled
        public List<AdditionGSTIN> listOfAdditionGSTIN;
        @AuraEnabled
        public Boolean isGcc = FALSE;
    }
    public class AdditionGSTIN{
        @AuraENabled
        public String Id;
        @AuraEnabled
        public String QuteLineItemId;
        @AuraEnabled
        public String productId;
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String GSTIN;
        @AuraEnabled
        public String billingAddrs1;
        @AuraEnabled
        public String billingAddrs2;
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String state;
        @AuraEnabled
        public String pincode;
        @AuraEnabled
        public Decimal amount;
        @AuraEnabled
        public String nameOfTheCustomer;
        @AuraEnabled
        public String billingPan;
        @AuraEnabled
        public String tan;
        @AuraEnabled
        public String cin;
        @AuraEnabled
        public String sez;
        @AuraEnabled
        public String CRNumber;
        @AuraEnabled
        public String tinNumber;
        @AuraEnabled
        public Boolean disbaleInfo;
        @AuraEnabled
        public String nameOfEntity;
        
        
    }
}