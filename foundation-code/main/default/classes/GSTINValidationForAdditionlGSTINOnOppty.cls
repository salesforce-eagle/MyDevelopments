public class GSTINValidationForAdditionlGSTINOnOppty {
    public static Map<Id,String> validateGstinBaseOnReceivablePan(List<Additional_GSTIN__c> mapofGSTINRecords){
        
        set<Id> gstids = new set<Id>();
        Map<Id,String> errorMsg = new Map<Id,String>();
        Map<Id,Additional_GSTIN__c> errorMapGSTINThrow = new Map<Id,Additional_GSTIN__c>();
        
        String pansInCustomLabel = System.Label.ByPassReceivableValidations;
        List<String> listOfPansFromLabel = new List<String>();
        
        if(pansInCustomLabel!='' && pansInCustomLabel!= NULL){
            listOfPansFromLabel = pansInCustomLabel.split(',');
        }
        
        for(Additional_GSTIN__c adgst:mapofGSTINRecords){
            gstids.add(adgst.Id);
            errorMapGSTINThrow.put(adgst.Id,adgst);
        }
        
        List<Additional_GSTIN__c> mapofNewGSTINRecords = [SELECT Id,Name,Opportunity__c,Opportunity__r.Account_ID_18__c,Opportunity__r.ClearTax_Billing_Entity__c,TIN_Number__c, 
                                                          Opportunity__r.TIN_Number__c,Opportunity__r.Billing_GST__c,Name_Of_The_Customer__c 
                                                          FROM Additional_GSTIN__c 
                                                          WHERE Id IN :gstids
                                                         ];
        
        map<id,List<Additional_GSTIN__c>> accountIdsWithGstin = new map<id,List<Additional_GSTIN__c>> ();
        
        List<Opportunity> opportunityToUpdate = new List<Opportunity>();
        
        map<String,Additional_GSTIN__c> errorMapofGstin = new  map<String,Additional_GSTIN__c>();
        
        for(Additional_GSTIN__c thisRecord : mapofNewGSTINRecords){
            if(accountIdsWithGstin.containsKey(thisRecord.Opportunity__r.Account_ID_18__c)){
                accountIdsWithGstin.get(thisRecord.Opportunity__r.Account_ID_18__c).add(thisRecord);
                
                system.debug('in if  '+thisRecord.Opportunity__r.Account_ID_18__c);
            }
            else{
                List<Additional_GSTIN__c> gstinData = new List<Additional_GSTIN__c>();
                gstinData.add(thisRecord);
                accountIdsWithGstin.put(thisRecord.Opportunity__r.Account_ID_18__c,gstinData);
                system.debug('in else  thisRecord'+thisRecord);
                system.debug('in else  thisRecord c '+thisRecord.Opportunity__c);
                system.debug('in else  thisRecord r '+thisRecord.Opportunity__r);
                system.debug('in else  '+thisRecord.Opportunity__r.Account_ID_18__c);
            }
        }
        system.debug('accountIdsWithGstin '+accountIdsWithGstin);
        
        map<Id,List<Receivables__c>> recivableMap = new map<Id,List<Receivables__c>>();
        
        
        for(Receivables__c  recRecord: [SELECT Id,Account_Owner_Id__c,PAN_TIN__c,CT_Billing_Entity__c,Account__c 
                                        FROM Receivables__c
                                        WHERE Account__c IN :accountIdsWithGstin.keyset()]){
                                            system.debug('Receivables__c recRecord '+recRecord);
                                            if(recivableMap.containskey(recRecord.Account__c)){
                                                recivableMap.get(recRecord.Account__c).add(recRecord);
                                            }
                                            else{
                                                List<Receivables__c> re = new List<Receivables__c>();
                                                re.add(recRecord);
                                                recivableMap.put(recRecord.Account__c,re);
                                            }
                                        }
        for(Id accountid: accountIdsWithGstin.keyset()){
            for(Additional_GSTIN__c lisGstin : accountIdsWithGstin.get(accountid)){
                Integer check = 0;
                Integer exists = 0;
                Id receivableId;
                system.debug('recivableMap '+recivableMap);
                if(recivableMap.containsKey(accountid)){
                    for(Receivables__c  recRecord: recivableMap.get(accountid)){
                        if(recRecord.CT_Billing_Entity__c!=NULL && recRecord.CT_Billing_Entity__c == lisGstin.Opportunity__r.ClearTax_Billing_Entity__c){
                            String oppPan = lisGstin.Name;
                            if(lisGstin.Opportunity__r.ClearTax_Billing_Entity__c!='KSA Branch of Defmacro'&& ((recRecord.PAN_TIN__c != oppPan.substring(2,12)))){
                                //throw error by taking records of id
                                exists = exists + 1;
                                
                            }
                            else if(lisGstin.Opportunity__r.ClearTax_Billing_Entity__c == 'KSA Branch of Defmacro' && recRecord.PAN_TIN__c != lisGstin.TIN_Number__c ){
                                //lisOppty.addError('show some error');
                                exists = exists + 1;
                            }
                            else if(lisGstin.Opportunity__r.ClearTax_Billing_Entity__c == 'KSA Branch of Defmacro' && recRecord.PAN_TIN__c == lisGstin.TIN_Number__c ){
                                system.debug('inside else in gstin');
                                check = check + 1;
                                receivableId = recRecord.id;
                            }
                            else if(lisGstin.Opportunity__r.ClearTax_Billing_Entity__c == recRecord.CT_Billing_Entity__c && recRecord.PAN_TIN__c == oppPan.substring(2,12) ){
                                system.debug('inside else in gstin');
                                check = check + 1;
                                receivableId = recRecord.id;
                            }
                        }
                        
                    }
                }
                if(check == 0  ){
                    system.debug('isnide check '+lisGstin.Opportunity__r.ClearTax_Billing_Entity__c);
                    system.debug('isnide check TIN_Number__c '+lisGstin.Name.substring(2,12));
                    if(lisGstin.Opportunity__r.ClearTax_Billing_Entity__c == 'KSA Branch of Defmacro' ){
                        if(lisGstin.TIN_Number__c!=''&&lisGstin.TIN_Number__c!=NULL){
                            errorMapofGstin.put(lisGstin.TIN_Number__c,lisGstin);
                        }
                        else{
                            //  errorMapGSTINThrow.get(lisGstin.Id).addError('TIN Number cannot be empty');
                            //Map<Id,String> errorMsg = new Map<Id,String>();
                            String Error = 'TIN Number cannot be empty';
                            errorMsg.put(lisGstin.Opportunity__c,Error);
                            // return errorMsg;
                        }
                    }
                    else{
                        if(lisGstin.Name!=''&&lisGstin.Name!=NULL){
                            errorMapofGstin.put(lisGstin.Name.substring(2,12),lisGstin);
                        }
                        else{
                            //errorMapGSTINThrow.get(lisGstin.Id).addError('GSTIN Number cannot be empty');
                            //Map<Id,String> errorMsg = new Map<Id,String>();
                            String Error = 'GSTIN Number cannot be empty';
                            errorMsg.put(lisGstin.Opportunity__c,Error);
                            //return errorMsg;
                            
                        }
                    }
                }
                
            }       
        }
        
        // if(exists!=0){
        List<Receivables__c> receviablesList = new List<Receivables__c>();
        system.debug('errorMapofGstin.keySet()'+errorMapofGstin.keySet());
        for(Receivables__c receviable :[SELECT Id,Name,Account__c,Account__r.Name,PAN_TIN__c,CT_Billing_Entity__c FROM Receivables__c WHERE PAN_TIN__c IN : errorMapofGstin.keySet()]){
            system.debug('errorMapofGstin.keySet() inside for pan rec '+receviable.PAN_TIN__c);
            system.debug('errorMapofGstin.keySet() inside for pan id '+receviable.Id);
            if(errorMapofGstin.containsKey(receviable.PAN_TIN__c) && errorMapofGstin.get(receviable.PAN_TIN__c).Opportunity__r.ClearTax_Billing_Entity__c == receviable.CT_Billing_Entity__c){
                Id gsid = errorMapofGstin.get(receviable.PAN_TIN__c).Id;
                
                if(!listOfPansFromLabel.contains(receviable.PAN_TIN__c)){
                    String Error = 'The PAN/TIN already exists under '+receviable.Account__r.Name+' under receviable '+receviable.Name+' Please contact sales ops for help: salesops@clear.in';
                    errorMsg.put(errorMapofGstin.get(receviable.PAN_TIN__c).Opportunity__c,Error);
                }
            }
        }
        
        for(Additional_GSTIN__c gstin : errorMapofGstin.values()){
            
            Receivables__c newRec = new Receivables__c();
            //newRec.Name = gstin.Name;
            newRec.Account__c = gstin.Opportunity__r.Account_ID_18__c;
            newRec.CT_Billing_Entity__c = gstin.Opportunity__r.ClearTax_Billing_Entity__c;
            // newRec.Name_of_the_entity__c = gstin.Name_Of_The_Customer__c;
            newRec.Name_of_the_entity__c = 'default data';
            if(gstin.Opportunity__r.ClearTax_Billing_Entity__c!= 'KSA Branch of Defmacro'){
                newRec.PAN_TIN__c = gstin.Name.substring(2,12);
                newRec.Name = newRec.CT_Billing_Entity__c+'_'+newRec.PAN_TIN__c +'_'+newRec.Name_of_the_entity__c;
            }
            else{
                newRec.PAN_TIN__c = gstin.TIN_Number__c;
                newRec.Name = newRec.CT_Billing_Entity__c+'_'+newRec.PAN_TIN__c +'_'+newRec.Name_of_the_entity__c;
            }
            system.debug('inside final else'+newRec);
            receviablesList.add(newRec);
        }
        
        try{
            system.debug('inside try'+receviablesList);
            insert receviablesList;
            for(Receivables__c receviable: receviablesList){
                Opportunity opp = new Opportunity();
                opp.id = errorMapofGstin.get(receviable.PAN_TIN__c).Opportunity__c;
                opp.Receivable__c = receviable.Id;
                opportunityToUpdate.add(opp);
            }
            update opportunityToUpdate;
        }
        catch(Exception e){
            system.debug('error while updating '+e.getmessage());
        }
        system.debug('return message'+errorMsg);
        return errorMsg;
        //  }
    }
    
}