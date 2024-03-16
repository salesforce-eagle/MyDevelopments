trigger Lead_Re_Request_Trigger on Lead_Re_Request__e (after insert) {
    Map<String,Lead_Re_Request__e> emailsToEventMap = new Map<String,Lead_Re_Request__e>();
    for(Lead_Re_Request__e event : Trigger.New){
        emailsToEventMap.put(event.Existing_Lead_Emails__c, event);
        EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.replayId);
    }
    
    if(!emailsToEventMap.keySet().isEmpty()){
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Lead leadInst : [SELECT Id, Name, Email, Incoming_Count__c FROM Lead WHERE Email IN : emailsToEventMap.keySet()]){
            leadInst.Incoming_Count__c 			+= 	1;
            leadInst.LeadSource					=	emailsToEventMap.get(leadInst.Email).Lead_Source__c;				
            leadInst.Lead_Sub_Source__c			=	emailsToEventMap.get(leadInst.Email).Lead_Subsource__c;
            leadInst.Campaign_Name__c			=	emailsToEventMap.get(leadInst.Email).Campaign_Name__c;
            leadInst.UTM_Source__c				=	emailsToEventMap.get(leadInst.Email).UTM_Source__c;
            leadInst.UTM_Medium__c				=	emailsToEventMap.get(leadInst.Email).UTM_Medium__c;
            leadInst.Lead_Source_Details__c 	=	emailsToEventMap.get(leadInst.Email).Lead_Source_Details__c ;
            leadInst.UTM_Content__c 			=	emailsToEventMap.get(leadInst.Email).UTM_Content__c;
            leadInst.UTM_Campaign__c 			=	emailsToEventMap.get(leadInst.Email).UTM_Campaign__c;
            leadInst.Date_Of_Incoming_Lead__c	= 	System.today();
            leadsToUpdate.add(leadInst);
        }
        
        if(!leadsToUpdate.isEmpty()){
            System.enqueueJob(new CTX_HandleGCCExistingLeadsQueueable(leadsToUpdate));
        }
    }
}