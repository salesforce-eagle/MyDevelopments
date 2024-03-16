public without sharing class ReceivableTriggerHelper {
    
    public static void checkPanValidation(List<Receivables__c> newMainReceivableRecords){
        List<Receivables__c> newReceivableRecords = newMainReceivableRecords;
        Map<String, Receivables__c> mapOfReceiveIdAndPan = new Map<String, Receivables__c>();
        for (Receivables__c thisRecord : newReceivableRecords){
            mapOfReceiveIdAndPan.put(thisRecord.PAN_TIN__c,thisRecord);
        }
        
        for(Receivables__c receviable :[SELECT Id,Account__c,Account__r.Name,PAN_TIN__c,CT_Billing_Entity__c FROM Receivables__c WHERE PAN_TIN__c IN : mapOfReceiveIdAndPan.keySet()]){
            if(mapOfReceiveIdAndPan.containsKey(receviable.PAN_TIN__c) && mapOfReceiveIdAndPan.get(receviable.PAN_TIN__c).CT_Billing_Entity__c == receviable.CT_Billing_Entity__c){
                // mapOfReceiveIdAndPan.get(receviable.PAN_TIN__c).addError('PAN is already exists with that account Id');
                // add Error
                Receivables__c rc = mapOfReceiveIdAndPan.get(receviable.PAN_TIN__c);
                rc.adderror('The PAN already exists under '+receviable.Account__r.Name+' Please contact sales ops for help: salesops@clear.in');
            }
        }        
    }
}