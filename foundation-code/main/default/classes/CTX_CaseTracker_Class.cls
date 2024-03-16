public without sharing class CTX_CaseTracker_Class {
    
    @AuraEnabled
    Public static CaseWrapper fetchCaseDetails(String caseNumber, String caseEmail){
        
        CaseWrapper thisResult = new CaseWrapper();
        
        thisResult.generatedOTP = generateRandomOTP();
        
        List<Case> caseresults = [ SELECT Id, CaseNumber, 
                                  
                                  Subject, Status, Sub_Status__c, Priority, Description, CreatedDate, LastModifiedDate, 
                                  SLA_Time__c, SLA_time_calculated__c, SLA_Breach_Time__c, 
                                  
                                  Is_Case_Tracker_Used__c, Case_Tracker_Counter__c,
                                  
                                  ( SELECT Id, ToAddress, FromName, FromAddress, CcAddress, BccAddress, ParentId, Headers, 
                                   Subject, TextBody, HtmlBody, CreatedDate FROM EmailMessages ORDER BY CreatedDate DESC )
                                  
                                  FROM Case WHERE 
                                  CaseNumber =: caseNumber AND 
                                  ContactEmail =: caseEmail ];
        
        if(caseresults.size() > 0){
            
            try{
                writeTrackingMatrics(caseresults[0]);
            } catch(Exception ex){
                
            }finally{
                
                /**	Case Number	**/
                thisResult.caseNumber = caseresults[0].CaseNumber;
                
                /**	Created Date	**/
                thisResult.caseCreatedDate = caseresults[0].CreatedDate;
                
                /**	Last Modified Date	**/
                thisResult.caseLastModifiedDate = caseresults[0].LastModifiedDate;
                
                /**	Case Subject	**/
                thisResult.caseSubject	= caseresults[0].Subject;
                
                /**	Calculate Case Status	**/
                if(caseresults[0].Status == 'Solved' || caseresults[0].Status == 'Closed'){
                    thisResult.caseStatus = 'Closed';
                } else if(caseresults[0].Status == 'Pending'){
                    if( caseresults[0].Sub_Status__c.containsIgnoreCase('customer') ){
                        thisResult.caseStatus = 'Awaiting Your Response';
                    } else{
                        thisResult.caseStatus = 'In-Progress';
                    }
                } else if(caseresults[0].Status == 'Waiting for Customer'){
                    thisResult.caseStatus = 'Awaiting Your Response';
                } else{
                    thisResult.caseStatus = 'In-Progress';
                }
                
                /**	Calculate SLA	**/
                if(caseresults[0].SLA_Time__c != NULL && caseresults[0].SLA_Time__c.containsIgnoreCase('-')){ 
                    thisResult.caseSLA = 'Taking longer than expected';
                } else{
                    if(caseresults[0].SLA_Time__c == NULL || caseresults[0].SLA_Time__c == '' ){
                        thisResult.caseSLA = 'Taking longer than expected';
                    } else{
                        thisResult.caseSLA = 'Your case will be resolved in next: '+caseresults[0].SLA_Time__c+' Minutes. (Subjected to Business Hours)';
                    }
                }
                
                /**	Case Details	**/
                thisResult.myCase = caseresults[0];
                
                /**	Email Message Details	**/
                if(caseresults[0].getSobjects('EmailMessages') != NULL){
                    thisResult.isMailThreadAvailable = TRUE;
                    thisResult.caseEmails = (List<EmailMessage>)caseresults[0].getSobjects('EmailMessages');
                    if(thisResult.caseEmails.size() > 0)
                        thisResult.latestEmailMessage = thisResult.caseEmails[0];
                    
                }
                
                
                thisResult.isSuccess = TRUE;
                CTX_CaseTracker_OTP_Email_Helper.sendOTPEmail(caseEmail, thisResult.generatedOTP);
            }
            
        } else{
            thisResult.errorMessage = 'No matching record available in our Database with the given Combination.';
            thisResult.isSuccess = FALSE;
        }
        
        system.debug('thisResult: '+thisResult);
        return thisResult;
    }
    
    Public Class CaseWrapper{
        
        @AuraEnabled
        Public Case myCase;
        
        @AuraEnabled
        Public String generatedOTP;
        
        @AuraEnabled
        Public EmailMessage latestEmailMessage;
        
        @AuraEnabled
        Public String caseNumber;
        
        @AuraEnabled
        Public String caseStatus;
        
        @AuraEnabled
        Public String caseSLA;
        
        @AuraEnabled
        Public DateTime caseCreatedDate;
        
        @AuraEnabled
        Public DateTime caseLastModifiedDate;
        
        @AuraEnabled
        Public String caseSubject;
        
        @AuraEnabled
        Public List<EmailMessage> caseEmails;
        
        @AuraEnabled
        Public String errorMessage;
        
        @AuraEnabled
        Public Boolean isSuccess = TRUE;
        
        @AuraEnabled
        Public Boolean isMailThreadAvailable = TRUE;
    }
    
    @AuraEnabled
    Public static void writeTrackingMatrics(Case incomingCase){
        
        incomingCase.Is_Case_Tracker_Used__c = TRUE;
        incomingCase.Case_Tracker_Counter__c = incomingCase.Case_Tracker_Counter__c == NULL ? 1 : incomingCase.Case_Tracker_Counter__c+1;
        
        update incomingCase;
    }
    
    @AuraEnabled
    Public Static String generateRandomOTP(){
        
        String result = '';  
        
        String rand = string.valueof(Math.abs(Crypto.getRandomInteger()));
        String otp = rand.substring(0,6);
        result = otp;
        
        return result;
    }
}