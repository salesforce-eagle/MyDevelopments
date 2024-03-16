public class EventTriggerHandler implements TriggerInterface{
    
    public static void beforeInsert(List<SObject> newRecordsList){
        
        final Id MEETING_LOG_RecordTypeId= Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Meeting_log').getRecordTypeId();
        final Id CALL_LOG_RecordTypeId= Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Call_log').getRecordTypeId();
           set<id> conId = new set<id>();
        set<id> opporId = new set<id>();
        set<id> leadId = new set<id>();
        for(event eventIns:(list<event>)newRecordsList){
            if(eventIns.whoId != null){
                leadId.add(eventIns.whoId);
            if(String.valueOf(eventIns.whoId).substring(0,3).equals('003'))
            conId.add(eventIns.whoId);
            }
           if(eventIns.whatId != null){
                opporId.add(eventIns.whatId);
            }
        }
        map<id,lead> leadMap = new map<id,lead> ([select id,Final_Segment__c from lead where id in: leadId]);
        map<id,opportunity> opporMap = new map<id,opportunity> ([select id,account.Final_Segment__c from opportunity where id in: opporId]);
        map<id,contact> conMap = new map<id,contact>([select id,accountid,email,account.pan__c,Designation__c,account.Final_Segment__c from contact where id in: conId]);
        for(Sobject sObj : newRecordsList){
            Event evntInstance = (Event)sObj;
              if(evntInstance.recordtypeid == MEETING_LOG_RecordTypeId || evntInstance.recordtypeid == CALL_LOG_RecordTypeId){
                if(conMap.get(evntInstance.whoId) != null){
                evntInstance.Email_of_POC__c = conMap.get(evntInstance.whoId).email;
                evntInstance.Designation_of_POC__c = conMap.get(evntInstance.whoId).Designation__c;
                evntInstance.Related_Account__c = conMap.get(evntInstance.whoId).accountid;
                }
                  if(evntInstance.whoId != null && String.valueOf(evntInstance.whoId).substring(0,3).equals('00Q')){
                      evntInstance.Object_Created_On__c = 'Lead';
                      evntInstance.account_segment__c = leadMap.get(evntInstance.whoId).Final_Segment__c;
                  }

                  else if(evntInstance.whatId != null && String.valueOf(evntInstance.whatId).substring(0,3).equals('006')){
                      evntInstance.Object_Created_On__c = 'Opportunity';
                      evntInstance.account_segment__c = opporMap.get(evntInstance.whatId).account.Final_Segment__c;
                  }
                      
                  
                   if(evntInstance.recordtypeid == CALL_LOG_RecordTypeId){
                        //evntInstance.StartDateTime = datetime.now();
                        evntInstance.EndDateTime = evntInstance.StartDateTime.addHours(1);
                        evntInstance.DurationInMinutes = 0;
                       evntInstance.ActivityDateTime = datetime.now();
                       
                    }
            }
            if(Boolean.valueOf(Label.activatEventValidation1)){
                /**if(evntInstance.ActivityDate < System.today()){
                    evntInstance.addError( system.Label.ActivityDate_Cannot_Be_BackDate);
                }
                if(evntInstance.ActivityDateTime < System.now()){
                    evntInstance.addError( system.Label.ActivityDateTime_Cannot_Be_BackDated);
                }**/
                if(evntInstance.StartDateTime < (System.now() - 2)){
                   // evntInstance.addError( system.Label.Activity_StartDate_EndDate_Greator_Than_Now);
                    
                }
                /* Commenting this because End Date and Time Cannot be choose as less than Start Date And Time in PageLayout (Standared Functionality)
                if(evntInstance.EndDateTime < evntInstance.StartDateTime){
                evntInstance.addError('Event End Date and Time should be greater than Now and greator than Start Date and Time');
                }*/
            }
        }
    }
    
    public static void afterInsert(List<SObject> newRecordsList,Map<Id,SObject> newRecordsMap){
        ID jobID = System.enqueueJob(new CTX_EventQueueForContactLeadUpdate( (List<Event>)newRecordsList ) );
    }
    
    public static void beforeUpdate(Map<Id,SObject> newRecordsMap,Map<Id,SObject> oldRecordsMap){
        final Id CALL_LOG_RecordTypeId= Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Call_log').getRecordTypeId();   
        final Id MEETING_LOG_RecordTypeId= Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Meeting_log').getRecordTypeId();
           set<id> conId = new set<id>();
        for(event eventIns:(list<event>)newRecordsMap.values()){
            if(eventIns.whoId != null){
            if(String.valueOf(eventIns.whoId).substring(0,3).equals('003'))
            conId.add(eventIns.whoId);
            }
        }
           map<id,contact> conMap = new map<id,contact>([select id,accountid,email,account.pan__c,Designation__c from contact where id in: conId]);
        for(Id sObjId : newRecordsMap.KeySet()){
            Event evntNewInstance = (Event)newRecordsMap.get(sObjId);
            Event evntOldInstance = (Event)oldRecordsMap.get(sObjId);
            if(evntNewInstance.recordtypeid == MEETING_LOG_RecordTypeId || evntNewInstance.recordtypeid == CALL_LOG_RecordTypeId){
                if(conMap.get(evntNewInstance.whoId) != null){
                    evntNewInstance.Email_of_POC__c = conMap.get(evntNewInstance.whoId).email;
                evntNewInstance.Designation_of_POC__c = conMap.get(evntNewInstance.whoId).Designation__c;
                evntNewInstance.Related_Account__c = conMap.get(evntNewInstance.whoId).accountid;
                    if(evntNewInstance.recordtypeid == CALL_LOG_RecordTypeId){
                        //evntNewInstance.StartDateTime = datetime.now();
                        evntNewInstance.EndDateTime = evntNewInstance.StartDateTime.addHours(1);
                        evntNewInstance.DurationInMinutes = 0;
                       evntNewInstance.ActivityDateTime = datetime.now();
                    }
                
                }
            }
            if(Boolean.valueOf(Label.activatEventValidation1)){
                /**if(evntNewInstance.ActivityDate != evntOldInstance.ActivityDate && evntNewInstance.ActivityDate < System.now()){
                    evntNewInstance.addError( system.Label.ActivityDate_Cannot_Be_BackDate);
                }
                if(evntNewInstance.ActivityDateTime != evntOldInstance.ActivityDateTime && evntNewInstance.ActivityDateTime < System.now()){
                    evntNewInstance.addError( system.Label.ActivityDateTime_Cannot_Be_BackDated);
                }
**/                if(evntNewInstance.StartDateTime != evntOldInstance.StartDateTime && evntNewInstance.StartDateTime < (System.now()-2)){
                    evntNewInstance.addError( system.Label.Activity_StartDate_EndDate_Greator_Than_Now);
                }
                
                 /* Commenting this because End Date and Time Cannot be choose as less than Start Date And Time in PageLayout (Standared Functionality)
                if(evntNewInstance.EndDateTime != evntOldInstance.EndDateTime && evntNewInstance.EndDateTime < evntNewInstance.StartDateTime){
                      evntNewInstance.addError('Event End Date and Time should be greater than Now and greator than Start Date and Time');
                }*/
                
               
             }
        }
    }
    
    public static void afterUpdate(Map<Id,SObject> newRecordsMap,Map<Id,SObject> oldRecordsMap){
        ID jobID = System.enqueueJob(new CTX_EventQueueForContactLeadUpdate( (List<Event>)newRecordsMap.values() ) );
    }
    
    public static void beforeDelete(List<SObject> oldRecordsList,Map<Id,SObject> oldRecordsMap){}
    
    public static void afterDelete(Map<Id,SObject> oldRecordsMap){}
    
    public static void afterUnDelete(List<SObject> newRecordsList,Map<Id,SObject> newRecordsMap){}
}
