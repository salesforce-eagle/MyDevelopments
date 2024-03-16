public class CTX_LeadConverterHelper {
    
    public static void createrelatedActivities( Database.LeadConvertResult	convertedLead ){
        
        ResultWrapper	classWrapperResult		= new ResultWrapper();
        List<Sobject>	insertRelatedActivities = new List<Sobject>();
        
        List<Task> getLeadtask = new List<Task>();
        for(
            Task thisRec : [SELECt Id, CurrencyIsoCode, OwnerId, CallDurationInSeconds, CallObject, CallDisposition, CallType, Description, CompletedDateTime, 
                            IsRecurrence, CreatedById, ActivityDate, LastModifiedById, RecurrenceInterval, 
                            Status, Subject, RecordTypeId, TaskSubtype, Type, WhatId, WhoId 
                            FROM Task WHERE 
                            WhoId =: convertedLead.getLeadId() ]
        ){
            Task myTask = thisRec.Clone(FALSE, FALSE, FALSE, FALSE);
            myTask.WhoId = convertedLead.getContactId();
            getLeadtask.add(myTask);
        }
        insertRelatedActivities.addAll(getLeadtask);
        
        /**	Link Lead existing Task to the Contact Task	**/
        List<Event> getLeadEvent = new List<Event>();
        for(
            Event thisRec : [SELECt Id, DurationInMinutes, EndDateTime, ActivityDate, StartDateTime, Description, Subject, RecordTypeId, WhatId, WhoId 
                             FROM Event WHERE 
                             WhoId =: convertedLead.getLeadId() ]
        ){
            Event myEvent = thisRec.Clone(FALSE, FALSE, FALSE, FALSE);
            myEvent.WhoId = convertedLead.getContactId();
            getLeadEvent.add(myEvent);
        }
        insertRelatedActivities.addAll(getLeadEvent);
        
        try{
            insert insertRelatedActivities;
        } catch(Exception ex){
            system.debug('Error Message while inserting Activities in "CTX_LeadConverterHelper" is: '+ex.getMessage());
            classWrapperResult.isSuccess 		= FALSE;
            classWrapperResult.errorMessage 	= ex.getMessage();
        }
    }
    
    public static ResultWrapper validateRequiredDetailsBeforeLeadConversuin(
        Lead 		leadInstance, 
        List<Id> 	internationalRecordType, 
        String 		recordTypeName
    ){
        System.debug('I am being converted: '+leadInstance.Id);
        
        ResultWrapper	classWrapperResult	= new ResultWrapper();
        
        Boolean isInternationalLead = FALSE;
        if( leadInstance.Country_of_Origin__c != NULL ){
            isInternationalLead = leadInstance.Country_of_Origin__c != 'India' ? TRUE : FALSE;
        }
        List<Event> demoEventBeforeConversion = [ SELECT Id, Stage__c, WhoId FROM Event WHERE 
                                                 Subject = 'Demo Meeting' AND 
                                                 WhoId =: leadInstance.Id AND 
                                                 Stage__c = 'Completed'];
        
        if(
            demoEventBeforeConversion != NULL && 
            (!isInternationalLead) &&
            (
                recordTypeName != 'Cimplifive' || 
                recordTypeName == NULL
            )
        ){
            if(demoEventBeforeConversion.size() < 1){
                classWrapperResult.errorMessage = 'Please create an Event and mark that Demo Complete before we Proceed \n';
                classWrapperResult.isSuccess 	= FALSE;
            }
        } else{
            if(
                !isInternationalLead && 
                (
                    recordTypeName != 'Cimplifive' || 
                    recordTypeName == NULL
                )
            ){
                classWrapperResult.errorMessage = 'Please create an Event and mark that Demo Complete before we Proceed \n';
                classWrapperResult.isSuccess 	= FALSE;
            }
        }
        
        if( !classWrapperResult.isSuccess ){
            if(classWrapperResult.errorMessage != NULL ){
                if(!isInternationalLead && 
                   (
                       recordTypeName != 'Cimplifive' || 
                       recordTypeName == NULL
                   )
                  )
                    classWrapperResult.errorMessage = classWrapperResult.errorMessage + ' & Fill in the required informations - ';
            } 
        }else{
            if(
                !isInternationalLead && 
                (
                recordTypeName != 'Cimplifive' || 
                recordTypeName == NULL
            ))
                classWrapperResult.errorMessage = 'Please fill in the required informations - ';
        }
        
        if( 
            leadInstance.Number_of_PAN__c == NULL && 
            !isInternationalLead &&
            leadInstance.Scope__c != NULL &&
            !leadInstance.Scope__c.containsIgnoreCase('ID') && 
            (
                recordTypeName != 'Cimplifive' || 
                recordTypeName == NULL
            )
        ){
            classWrapperResult.errorMessage += 'Number of PAN ';//
            classWrapperResult.isSuccess 	= FALSE;
        }
        if( 
            leadInstance.Renewal_Date__c == NULL && 
            !isInternationalLead  &&
            leadInstance.Scope__c != NULL &&
            !leadInstance.Scope__c.containsIgnoreCase('ID') &&
            (
                recordTypeName != 'Cimplifive' || 
                recordTypeName == NULL
            )
        ){
            classWrapperResult.errorMessage += ', Renewal Date ';//
            classWrapperResult.isSuccess 	= FALSE;
        }
        if( 
            leadInstance.Competition_Currently_Using__c == NULL || String.isBlank(leadInstance.Competition_Currently_Using__c) ){
                
                if(!isInternationalLead &&
                   (
                       recordTypeName != 'Cimplifive' || 
                       recordTypeName == NULL
                   )){
                       classWrapperResult.errorMessage += ', Competition/Currently Using ';
                       classWrapperResult.isSuccess 	= FALSE;
                   }
            }
        if( leadInstance.ERP__c == NULL || String.isBlank(leadInstance.ERP__c) ){
            
            if(!isInternationalLead && 
               (
                   recordTypeName != 'Cimplifive' || 
                   recordTypeName == NULL
               )){
                   classWrapperResult.errorMessage += ', ERP ';
                   classWrapperResult.isSuccess 	= FALSE;
               }
        }
        if( 
            leadInstance.Number_of_Sales_Invoices__c == NULL && 
            !isInternationalLead  &&
            leadInstance.Scope__c != NULL &&
            !leadInstance.Scope__c?.containsIgnoreCase('ID') && 
            (
                recordTypeName != 'Cimplifive' || 
                recordTypeName == NULL
            )
        ){
            classWrapperResult.errorMessage += ', Number of Sales Invoice ';//
            classWrapperResult.isSuccess 	= FALSE;
        }
        if( 
            leadInstance.Number_Of_GSTN__c == NULL && 
            !isInternationalLead  && 
            leadInstance.Scope__c != NULL &&
            !leadInstance.Scope__c.containsIgnoreCase('ID') && 
            (
                recordTypeName != 'Cimplifive' || 
                recordTypeName == NULL
            )
        ){
            system.debug('Inside NUMBER OF GSTN');
            classWrapperResult.errorMessage	+= ', Number of GSTN';
            classWrapperResult.isSuccess 	= FALSE;
        }
        
        return classWrapperResult;
    }
    
    Public Class ResultWrapper{
        public Boolean 	isSuccess 	= TRUE;
        public String	errorMessage;
    }
}