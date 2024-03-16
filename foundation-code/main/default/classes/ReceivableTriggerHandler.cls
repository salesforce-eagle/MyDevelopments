public without sharing class ReceivableTriggerHandler implements TriggerInterface{
    
    public void beforeInsert(list<sObject> listofNewsObjectRecords){
        
        List<Receivables__c> newReceivableRecords = (List<Receivables__c>) listofNewsObjectRecords;
        ReceivableTriggerHelper.checkPanValidation(newReceivableRecords);
        
    }
    
    public void afterInsert(list<sObject> listofNewsObjectRecords,map<id,sObject> mapofNewsObjectRecords){
        
        List<Receivables__c> newReceivableRecords = (List<Receivables__c>) listofNewsObjectRecords;
        system.debug('after insert of receviable');
        for(Receivables__c thisRecord : newReceivableRecords){
            System.enqueueJob(new UpdateCardCodeOfReceivableFromSAP(thisRecord.PAN_TIN__c ,thisRecord.Id));
           // System.enqueueJob(new UpdateCardCodeOfReceivableFromSAP(newReceivableRecords[0].PAN_TIN__c ,newReceivableRecords[0].Id));
       
         }
        
    }
    
    public void beforeUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){
        
        map<id,Receivables__c> mapofNewReceivableRecords = (map<id,Receivables__c>) mapofNewsObjectRecords;
        map<id,Receivables__c> mapofOldReceivableRecords = (map<id,Receivables__c>) mapofOldsObjectRecords;
        
        List<Receivables__c> newReceivable = new List<Receivables__c>();
        
        for(Receivables__c rec:mapofNewReceivableRecords.values()){
            if(rec.PAN_TIN__c != mapofOldReceivableRecords.get(rec.id).PAN_TIN__c || rec.CT_Billing_Entity__c != mapofOldReceivableRecords.get(rec.id).CT_Billing_Entity__c){
                newReceivable.add(rec);
            }
        }
        ReceivableTriggerHelper.checkPanValidation(newReceivable);
        
    }
    
    public void afterUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){
        
        map<id,Receivables__c> mapofNewReceivableRecords = (map<id,Receivables__c>) mapofNewsObjectRecords;
        map<id,Receivables__c> mapofOldReceivableRecords = (map<id,Receivables__c>) mapofOldsObjectRecords;
        
        system.debug('after update of receviable');
        for(Receivables__c rec:mapofNewReceivableRecords.values()){
            if(rec.PAN_TIN__c != mapofOldReceivableRecords.get(rec.id).PAN_TIN__c ){
                
                System.enqueueJob(new UpdateCardCodeOfReceivableFromSAP(rec.PAN_TIN__c ,rec.Id));
                
            }
        }
    }
    
    public void beforeDelete(list<sObject> listofOldsObjectRecords,map<id,sObject> mapofOldsObjectRecords){}
    
    public void afterDelete(map<id,sObject> mapofOldsObjectRecords){}
    
    public void afterUndelete(list<sObject> listofNewsObjectRecords,map<id,sObject> mapofNewsObjectRecords){}
    
}