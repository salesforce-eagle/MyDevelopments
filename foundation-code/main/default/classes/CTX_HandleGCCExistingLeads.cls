public class CTX_HandleGCCExistingLeads {
    public Static void handleLeadsAlreadyExists(Map<String,Lead> leadEmailToLeadMap){
        Map<String, Lead> existingEmailToLeadMap = new Map<String, Lead>();
        List<Lead_Re_Request__e> eventList = new List<Lead_Re_Request__e>();
        for(Lead leadInst : [SELECT Id, Name, Email, Incoming_Count__c FROM Lead WHERE Email IN :leadEmailToLeadMap.keySet()])
        {
            existingEmailToLeadMap.put(leadInst.Email, leadInst);
            eventList.add(new Lead_Re_Request__e(
                    Existing_Lead_Emails__c = leadInst.Email,
                    Lead_Source__c 			= leadEmailToLeadMap.get(leadInst.Email).leadSource,
                    Lead_Subsource__c 		= leadEmailToLeadMap.get(leadInst.Email).Lead_Sub_Source__c,
                    Campaign_Name__c		= leadEmailToLeadMap.get(leadInst.Email).Campaign_Name__c,
                    UTM_Source__c			= leadEmailToLeadMap.get(leadInst.Email).UTM_Source__c,
                    UTM_Medium__c			= leadEmailToLeadMap.get(leadInst.Email).UTM_Medium__c,
                	Lead_Source_Details__c	= leadEmailToLeadMap.get(leadInst.Email).Lead_Source_Details__c,
                    UTM_Content__c			= leadEmailToLeadMap.get(leadInst.Email).UTM_Content__c,
                    UTM_Campaign__c			= leadEmailToLeadMap.get(leadInst.Email).UTM_Campaign__c
            	)
            );
        }
        if(!eventList.isEmpty()){
            List<Database.SaveResult> results = Eventbus.publish(eventList);
            for(Database.SaveResult res : results){
                if(!res.isSuccess()){
                    System.debug('Event Failed : ' + res.id);
                }
            }
        }
        
        for(Lead leadInstance : leadEmailToLeadMap.values()){
            if(existingEmailToLeadMap.keySet().contains(leadInstance.Email)){
                leadInstance.addError('The Lead (Id:'+ existingEmailToLeadMap.get(leadInstance.Email).Id +') already Exists.');
            }
        }
    }
    
}