public class LoggerTriggerHandler implements TriggerInterface{

    public void beforeInsert(list<sObject> listofNewsObjectRecords){}
    
    public void afterInsert(list<sObject> listofNewsObjectRecords,map<id,sObject> mapofNewsObjectRecords){
        
        Map<Id, Logger__c> newLoggerMap = (Map<Id, Logger__c>)mapofNewsObjectRecords;
        Set<Id> existingLoggersTobeDeleted = new Set<Id>();
        Map<Id, String> getExistingCombinationMap = new Map<Id, String>();
        
        List<Logger__c> sapFailures = new List<Logger__c>();
        
        CTX_SendLoggerEmailNotifications.sendEmailNotification(newLoggerMap);
        
        for(Logger__c thisRec : newLoggerMap.values()){
            if(thisRec.Error_Type__c.contains('SAP Callout Failure')){
                sapFailures.add(thisRec);
            }
            getExistingCombinationMap.put(
                thisRec.Record_Id__c, 
                thisRec.Object_Name__c+';'+thisRec.Apex_Class__c+';'+thisRec.Method_Name__c);
        }
        
        
        for(
            Logger__c thisRec : [ SELECT Id, Apex_Class__c, Method_Name__c, 
                                 Object_Name__c, Record_Id__c 
                                FROM Logger__c WHERE 
                                Record_Id__c IN :getExistingCombinationMap.keySet() ]
        ){
            String comboString = thisRec.Object_Name__c+';'+thisRec.Apex_Class__c+';'+thisRec.Method_Name__c;
            
            if( 
                getExistingCombinationMap.get(thisRec.Record_Id__c) == comboString &&  
                !newLoggerMap.containsKey(thisRec.Id) 
            ){
                existingLoggersTobeDeleted.add(thisRec.Id);
            }
        }
        
        if(!sapFailures.isEmpty()){
            CTX_SendLoggerEmailNotifications.sapIntegrationErrorNotification(sapFailures);
        }
        database.delete(new List<Id>(existingLoggersTobeDeleted));
        
    }
    
    public void beforeUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){}
    
    public void afterUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){}
    
    public void beforeDelete(list<sObject> listofOldsObjectRecords,map<id,sObject> mapofOldsObjectRecords){}
    
    public void afterDelete(map<id,sObject> mapofOldsObjectRecords){}
    
    public void afterUndelete(list<sObject> listofNewsObjectRecords,map<id,sObject> mapofNewsObjectRecords){}
}