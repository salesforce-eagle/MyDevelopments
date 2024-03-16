public class CTX_EventQueueForContactLeadUpdate implements Queueable {
    
    public List<Event> events = new List<Event>();
    
    public CTX_EventQueueForContactLeadUpdate(List<Event> incomingEvents){
        this.events = incomingEvents;
    }
    
    public void execute(QueueableContext context) {
        
        Set<Id>				contactIds						= new Set<Id>();
        Map<Id, Integer> 	contact_ScheduledMeetingCount 	= new Map<Id, Integer>();
        Map<Id, Integer> 	contact_CompleteddMeetingCount 	= new Map<Id, Integer>();
        Set<Id>				leadIds							= new Set<Id>();
        Map<Id, Integer> 	lead_ScheduledMeetingCount 		= new Map<Id, Integer>();
        Map<Id, Integer> 	lead_CompleteddMeetingCount 	= new Map<Id, Integer>();
        
        List<Contact>		updateContactBasedOnEventDetails= new List<Contact>();
        List<Lead>			updateLeadBasedOnEventDetails	= new List<Lead>();
        List<Sobject> 		updateList 						= new List<Sobject>();
        
        
        /**	Event Details Fetch	**/
        for(Event thisRec : events){
            if(thisRec.Subject == 'Demo Meeting'){
                
                String whoIdInString = thisRec.WhoId;
                if( whoIdInString != NULL || String.isNotBlank(whoIdInString) || String.isNotEmpty(whoIdInString) ){
                    
                    if(whoIdInString.startsWith('003'))
                        contactIds.add(thisRec.WhoId);
                    if(whoIdInString.startsWith('00Q'))
                        leadIds.add(thisRec.WhoId);
                }
            }
        }
        
        system.debug('contactIds: '+contactIds);
        system.debug('leadIds: '+leadIds);
        Integer contact_TempInt_Complete = 0;
        Integer contact_TempInt_Schedule = 0;
        
        Integer lead_TempInt_Complete = 0;
        Integer lead_TempInt_Schedule = 0;
        
        for(
            Event thisRec : [ SELECT Id, WhoId, Subject, Stage__c 
                             FROM Event WHERE 
                             WhoId IN: contactIds OR 
                             WhoId IN: leadIds ]
        ){
            
            String whoIdInString = thisRec.WhoId;
            /**	Contact Details	**/
            if( contactIds.contains(whoIdInString) ){
                
                if(thisRec.Stage__c == 'Completed'){
                    
                    system.debug('In Side Contact Complete');
                    contact_TempInt_Complete = contact_TempInt_Complete+1;
                    contact_CompleteddMeetingCount.put(thisRec.WhoId, contact_TempInt_Complete);
                } else{
                    
                    contact_TempInt_Schedule = contact_TempInt_Schedule+1;
                    contact_ScheduledMeetingCount.put(thisRec.WhoId, contact_TempInt_Schedule);
                    system.debug('In Side Contact Schedule: '+contact_TempInt_Schedule);
                }
            }
            
            /**	Lead Details	**/
            if( leadIds.contains(whoIdInString) ){
                
                if(thisRec.Stage__c == 'Completed'){
                    
                    lead_TempInt_Complete = lead_TempInt_Complete+1;
                    lead_CompleteddMeetingCount.put(thisRec.WhoId, lead_TempInt_Complete);
                } else{
                    
                    lead_TempInt_Schedule = lead_TempInt_Schedule+1;
                    lead_ScheduledMeetingCount.put(thisRec.WhoId, lead_TempInt_Schedule);
                }
            }
        }
        
        system.debug('contact_TempInt_Complete: '+contact_TempInt_Complete);
        system.debug('contact_TempInt_Schedule: '+contact_TempInt_Schedule);
        
        /**	Update Block Contact : START	**/
        if(contactIds.size() > 0){
            
            for(Id thisId : contactIds){
                
                Contact myContact = new Contact(
                    Id 							= thisId,
                    No_of_Demos_completed__c 	= (contact_CompleteddMeetingCount.get(thisId) != NULL) ? contact_CompleteddMeetingCount.get(thisId) : 0,
                    No_of_Demos_Scheduled__c	= (contact_ScheduledMeetingCount.get(thisId) != NULL) ? contact_ScheduledMeetingCount.get(thisId) : 0
                );
                updateContactBasedOnEventDetails.add(myContact);
            }
        }	/**	Update Block Contact : END	**/
        updateList.addAll(updateContactBasedOnEventDetails);
        
        /**	Update Block Lead : START	**/
        if(leadIds.size() > 0){
            
            for(Id thisId : leadIds){
                
                Lead myLead = new Lead(
                    Id 							= thisId,
                    No_of_Demos_completed__c 	= (lead_CompleteddMeetingCount.get(thisId) != NULL) ? lead_CompleteddMeetingCount.get(thisId) : 0,
                    No_of_Demos_Scheduled__c	= (lead_ScheduledMeetingCount.get(thisId) != NULL) ? lead_ScheduledMeetingCount.get(thisId) : 0
                );
                updateLeadBasedOnEventDetails.add(myLead);
            }
        }	/**	Update Block Lead : END	**/
        updateList.addAll(updateLeadBasedOnEventDetails);
        
        
        try{
            update updateList;
        } catch(Exception ex){
            system.debug('CTX_EventQueueForContactLeadUpdate Update Error: '+ex.getMessage());
        }
        
    }
}