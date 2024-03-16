public class CTX_LogTaskTriggerHandler implements TriggerInterface{

    public void beforeInsert(list<sObject> listofNewsObjectRecords){
        
        CTX_LogTaskTriggerHelper.beforeInsertValidations( (List<Log_Task__c>)listofNewsObjectRecords );
    }
    
    public void afterInsert(list<sObject> listofNewsObjectRecords,map<id,sObject> mapofNewsObjectRecords){}
    
    public void beforeUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){
        
        CTX_LogTaskTriggerHelper.blockMoMUpdateOnNoAttachment( (Map<Id, Log_Task__c>)mapofNewsObjectRecords, (Map<Id, Log_Task__c>)mapofOldsObjectRecords );
    }
    
    public void afterUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){}
    
    public void beforeDelete(list<sObject> listofOldsObjectRecords,map<id,sObject> mapofOldsObjectRecords){}
    
    public void afterDelete(map<id,sObject> mapofOldsObjectRecords){}
    
    
    public void afterUndelete(list<sObject> listofNewsObjectRecords,map<id,sObject> mapofNewsObjectRecords){}
    
}