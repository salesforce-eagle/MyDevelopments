/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class GSTINValidationHelperForOpportunity {
    
    public static void validateOpportunityBaseOnReceivablePan(List<Opportunity> mapofNewOpportunityRecords){
        
        map<Id,List<Opportunity>> accountIdsWithGstin = new map<id,List<Opportunity>> ();
        List<Opportunity> opportunityToUpdate = new List<Opportunity>();
        
        map<string,List<Opportunity>> exceptionalOpportunityReceivables = new map<string,List<Opportunity>>();
        
        String pansInCustomLabel = System.Label.ByPassReceivableValidations;
        List<String> listOfPansFromLabel = new List<String>();
        
        if(pansInCustomLabel!='' && pansInCustomLabel!= NULL){
            listOfPansFromLabel = pansInCustomLabel.split(',');
        }
        
        system.debug('listOfPansFromLabel '+listOfPansFromLabel);
        map<Id,Opportunity> mapOfOppty = new map<Id,Opportunity>();
        for(Opportunity opp :mapofNewOpportunityRecords){
            
            mapOfOppty.put(opp.Id,opp);
        }
        List <Additional_GSTIN__c> additionalGstin = [SELECT Id,Name,Opportunity__r.Id FROM Additional_GSTIN__c WHERE Opportunity__r.Id IN :mapOfOppty.keyset()];
        
        Map<Id,String> errorRetun = new  Map<Id,String>();
        errorRetun = GSTINValidationForAdditionlGSTINOnOppty.validateGstinBaseOnReceivablePan(additionalGstin);
        for(Id ids : errorRetun.keyset()){
            mapOfOppty.get(ids).addError(errorRetun.get(ids));
        }
        
        for(Additional_GSTIN__c add: additionalGstin){
            if(mapOfOppty.containsKey(add.Id)){
                mapOfOppty.remove(add.Id);
            }
        }
        for(Opportunity thisRecord : mapOfOppty.values()){
            if(accountIdsWithGstin.containsKey(thisRecord.AccountId)){
                accountIdsWithGstin.get(thisRecord.AccountId).add(thisRecord);
            }
            else{
                List<Opportunity> opty = new List<Opportunity>();
                opty.add(thisRecord);
                accountIdsWithGstin.put(thisRecord.AccountId,opty);
            }
        }
        map<Id,List<Receivables__c>> recivableMap = new map<Id,List<Receivables__c>>();
        for(Receivables__c  recRecord: [SELECT Id,Account_Owner_Id__c,PAN_TIN__c,CT_Billing_Entity__c,Account__c,Account__r.Name 
                                        FROM Receivables__c
                                        WHERE Account__c IN :accountIdsWithGstin.keyset()]){
                                            if(recivableMap.containskey(recRecord.Account__c)){
                                                recivableMap.get(recRecord.Account__c).add(recRecord);
                                            }
                                            else{
                                                List<Receivables__c> re = new List<Receivables__c>();
                                                re.add(recRecord);
                                                recivableMap.put(recRecord.Account__c,re);
                                            }
                                            
                                            
                                        }
        map<String,Opportunity> errorMapofOppty = new  map<String,Opportunity>();
        for(Id accountid: accountIdsWithGstin.keyset()){
            for(Opportunity lisOppty : accountIdsWithGstin.get(accountid)){
                Integer check = 0;
                String accountNames ='';
                Id receivableId;
                if(recivableMap.containsKey(accountid)){
                    for(Receivables__c  recRecord: recivableMap.get(accountid)){
                        system.debug('inside for Receivables__c CT_Billing_Entity__c '+recRecord.CT_Billing_Entity__c);
                        system.debug('inside for Receivables__c ClearTax_Billing_Entity__c '+lisOppty.ClearTax_Billing_Entity__c);
                        system.debug('inside for Receivables__c recRecord.PAN_TIN__c '+recRecord.PAN_TIN__c);
                        //system.debug('inside for Receivables__c lisOppty.Billing_GST__c '+lisOppty.Billing_GST__c.substring(2,12));
                        if(recRecord.CT_Billing_Entity__c!=NULL && recRecord.CT_Billing_Entity__c == lisOppty.ClearTax_Billing_Entity__c){
                            String oppPan = lisOppty.Billing_GST__c != NULL ? lisOppty.Billing_GST__c : NULL;
                            if( oppPan != NULL ){
                                if(lisOppty.ClearTax_Billing_Entity__c!='KSA Branch of Defmacro' &&  recRecord.PAN_TIN__c != oppPan.substring(2,12)){
                                    //throw error by taking records of id
                                    system.debug('inside 1 if ');
                                    accountNames = accountNames + recRecord.Account__r.Name + ',';
                                    // errorMapofOpptyAndAccountIds.put(lisOppty.Id,lisOppty);
                                    
                                }
                                else if(lisOppty.ClearTax_Billing_Entity__c == 'KSA Branch of Defmacro' && recRecord.PAN_TIN__c != lisOppty.TIN_Number__c  ){
                                    accountNames = accountNames + recRecord.Account__r.Name + ',';
                                    system.debug('inside 2 if ');
                                }
                                else if(lisOppty.ClearTax_Billing_Entity__c == 'KSA Branch of Defmacro' && recRecord.PAN_TIN__c == lisOppty.TIN_Number__c ){
                                    system.debug('inside else in gstin forreign');
                                    check = check + 1;
                                    receivableId = recRecord.id;
                                }
                                else if(lisOppty.ClearTax_Billing_Entity__c == recRecord.CT_Billing_Entity__c && recRecord.PAN_TIN__c == oppPan.substring(2,12) ){
                                    system.debug('inside else in gstin indian');
                                    check = check + 1;
                                    receivableId = recRecord.id;
                                }
                            }
                        }
                        
                    }
                }
                if(check == 0){
                    system.debug('inside check if '+lisOppty.ClearTax_Billing_Entity__c);
                    if(lisOppty.ClearTax_Billing_Entity__c == 'KSA Branch of Defmacro' ){
                        if(lisOppty.TIN_Number__c!=''&&lisOppty.TIN_Number__c!=NULL){
                            if(listOfPansFromLabel.contains(lisOppty.TIN_Number__c)){
                                if(exceptionalOpportunityReceivables.containsKey(lisOppty.TIN_Number__c)){
                                    exceptionalOpportunityReceivables.get(lisOppty.TIN_Number__c).add(lisOppty);
                                }
                                else{
                                    List<Opportunity> opty = new List<Opportunity>();
                                    opty.add(lisOppty);
                                    exceptionalOpportunityReceivables.put(lisOppty.TIN_Number__c,opty);
                                }
                            }
                            else{
                                errorMapofOppty.put(lisOppty.TIN_Number__c,lisOppty);
                            }
                            
                        }
                        else{
                            lisOppty.addError('TIN Number cannot be empty');
                        }
                    }
                    else{
                        if(lisOppty.Billing_GST__c!=''&&lisOppty.Billing_GST__c!=NULL){
                            system.debug('inside if lisOppty.Billing_GST__c '+lisOppty.Billing_GST__c);
                            if(listOfPansFromLabel.contains(lisOppty.Billing_GST__c.substring(2,12))){
                                if(exceptionalOpportunityReceivables.containsKey(lisOppty.Billing_GST__c.substring(2,12))){
                                    exceptionalOpportunityReceivables.get(lisOppty.Billing_GST__c.substring(2,12)).add(lisOppty);
                                }
                                else{
                                    List<Opportunity> opty = new List<Opportunity>();
                                    opty.add(lisOppty);
                                    exceptionalOpportunityReceivables.put(lisOppty.Billing_GST__c.substring(2,12),opty);
                                }
                            }
                            else{
                                errorMapofOppty.put(lisOppty.Billing_GST__c.substring(2,12),lisOppty);
                            }
                        }
                        else{
                            lisOppty.addError('Billing GST Number cannot be empty');
                        }
                    }
                }
                else if(receivableId!= NULL){
                    system.debug('inside check else '+lisOppty.ClearTax_Billing_Entity__c);
                    Opportunity opp = new Opportunity(); 
                    opp.id = lisOppty.id;
                    opp.Receivable__c = receivableId;
                    opportunityToUpdate.add(opp);
                }
                
            }       
        }
        system.debug('exceptionalOpportunityReceivables map '+exceptionalOpportunityReceivables);
        List<Receivables__c> receviablesList = new List<Receivables__c>();
        system.debug('errormap keyset '+errorMapofOppty.keySet());
        for(Receivables__c receviable :[SELECT Id,Name,Account__c,Account__r.Name,PAN_TIN__c,CT_Billing_Entity__c FROM Receivables__c WHERE PAN_TIN__c IN : errorMapofOppty.keySet()]){
            system.debug('errorMapofOppty.get(receviable.PAN_TIN__c).ClearTax_Billing_Entity__c '+errorMapofOppty.get(receviable.PAN_TIN__c).ClearTax_Billing_Entity__c);
            system.debug('receviable.CT_Billing_Entity__c '+receviable.CT_Billing_Entity__c);
            system.debug('receviable.PAN_TIN__c '+receviable.PAN_TIN__c);
            if(errorMapofOppty.containsKey(receviable.PAN_TIN__c) && errorMapofOppty.get(receviable.PAN_TIN__c).ClearTax_Billing_Entity__c == receviable.CT_Billing_Entity__c){
                errorMapofOppty.get(receviable.PAN_TIN__c).addError('The PAN/TIN already exists under '+receviable.Account__r.Name+' under receviable '+receviable.Name+' Please contact sales ops for help: salesops@clear.in');
            }
            
        } 
        // List<Opportunity> oppToUpdateFromLabel = new List<Opportunity>();
        if(exceptionalOpportunityReceivables != null && !exceptionalOpportunityReceivables.isEmpty()){
            for(Receivables__c receviable :[SELECT Id,Name,Account__c,Account__r.Name,PAN_TIN__c,CT_Billing_Entity__c FROM Receivables__c WHERE PAN_TIN__c IN : exceptionalOpportunityReceivables.keySet()]){
                if(exceptionalOpportunityReceivables.containsKey(receviable.PAN_TIN__c)){
                    for(Opportunity thisoppt : exceptionalOpportunityReceivables.get(receviable.PAN_TIN__c)){
                        Opportunity opp = new Opportunity();
                        opp.id = thisoppt.id;
                        opp.Receivable__c = receviable.Id;
                        opportunityToUpdate.add(opp);
                        
                        system.debug('inside for loop Opportunity'+opp);
                    }
                }
            }
            
        }
        system.debug('opportunityToUpdate before try '+opportunityToUpdate);
        for(Opportunity opp : errorMapofOppty.values()){
            
            Receivables__c newRec = new Receivables__c();
            // newRec.Name = opp.Name;
            newRec.Account__c = opp.AccountId;
            newRec.CT_Billing_Entity__c = opp.ClearTax_Billing_Entity__c;
            newRec.Name_of_the_entity__c=opp.Legal_Entity_Name_Of_The_Client__c;
            // newRec.Name_of_the_entity__c = 'default value';
            if(opp.ClearTax_Billing_Entity__c!= 'KSA Branch of Defmacro'){
                newRec.PAN_TIN__c = opp.Billing_GST__c.substring(2,12);
                newRec.Name = opp.ClearTax_Billing_Entity__c + '_'+newRec.PAN_TIN__c+'_'+newRec.Name_of_the_entity__c;
            }
            else{
                newRec.PAN_TIN__c = opp.TIN_Number__c;
                newRec.Name = opp.ClearTax_Billing_Entity__c + '_'+newRec.PAN_TIN__c+'_'+newRec.Name_of_the_entity__c;
            }
            system.debug('inside final else'+newRec);
            receviablesList.add(newRec);
        }
        
        try{
            system.debug('inside try'+receviablesList);
            insert receviablesList;
            for(Receivables__c receviable: receviablesList){
                Opportunity opp = new Opportunity();
                opp.id = errorMapofOppty.get(receviable.PAN_TIN__c).id;
                opp.Receivable__c = receviable.Id;
                opportunityToUpdate.add(opp);
            }
            system.debug('inside try opportunityToUpdate '+opportunityToUpdate);
            update opportunityToUpdate;
        }
        catch(Exception e){
            system.debug('error while updating '+e.getmessage());
        }
        
    }
}