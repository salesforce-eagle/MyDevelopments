/**
* @File Name          : EmailMessageTriggerHandler.cls
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : Lokesh@SFDeveloper.SFDoc
* @Last Modified On   : 28/5/2020, 1:05:16 am
* @Modification Log   : 
* 	Ver		Date		Author						Modification
* 	1.0		28/5/2020	Lokesh@SFDeveloper.SFDoc	Initial Version
*	1.1		17/6/2022	bibhuda.dash@clear.in		Email-to-Case related Changes
**/

public class EmailMessageTriggerHandler implements TriggerInterface{ 
    
    /**	Available Fields : 
*	Id, ParentId, ActivityId, TextBody, HtmlBody, Headers, Subject, 
*	FromName, FromAddress, ToAddress, CcAddress, ValidatedFromAddress, 
*	Incoming, HasAttachment, Status, MessageDate, IsDeleted, ReplyToEmailMessageId, IsPrivateDraft, 
*	IsExternallyVisible, MessageIdentifier, ThreadIdentifier, IsClientManaged, RelatedToId, IsTracked, IsOpened, 
*	FirstOpenedDate, LastOpenedDate, IsBounced, EmailTemplateId, Current_Body__c, Status__c, Sub_Status__c, 
*	Issue_Type__c, Priority__c, Type__c
**/
    
    /**	Before Insert Code : START	**/
    public static void beforeInsert(List<SObject> listOfNewSObjects){
        if(caseconstants.taskTrigger){
        
        List<EmailMessage> 		incomingEmailMessages 									= (List<EmailMessage>)listOfNewSObjects;
        List<EmailMessage> 		listOfNewCasesWithEmail									= new List<EmailMessage>();
        List<EmailMessage> 		listOfTageEmailFollowupNewCase							= new List<EmailMessage>();
        Map<Id,EmailMessage> 	mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved	= new Map<Id,EmailMessage>();
        Set<Id> 				ListOfcasesToupdateCC									= new Set <ID>();
        Set<Id>					parentCaseIds											= new Set<Id>();
        
           
        /**	New Changes	**/
        for(EmailMessage thisRec : incomingEmailMessages){
            if(thisRec.ParentId != NULL){
                parentCaseIds.add(thisRec.ParentId);
            }
         
        }
            
        Map<Id, Case>							parentCaseMaps							= new Map<Id, Case>();
       // List<CaseRecordTypeQueueMapping__mdt> 	listOfRecordTypeAndQueueMappings		= CaseRecordTypeQueueMapping__mdt.getAll().values();
        
        Map<Id,Case>							mapOfClosedCases					
            = new Map<Id,Case>((List<Case>)CaseSelector.getClosedCaseByIds(parentCaseIds));
        
        
        
        
        for(EmailMessage thisRec : incomingEmailMessages){
            
            Case parentCase = new Case(Id = thisRec?.ParentId);
            thisRec 		= EmailMessageTriggerHelper.trimFrom_ToAddressAndCCAddress(thisRec);
            
            if( thisRec.ParentId != NULL && thisRec.ToAddress != NULL && thisRec.incoming == TRUE ){
                parentCase.put('Email_Source__c', thisRec.ToAddress);
                parentCase.put('Involved_Email__c', thisRec.ToAddress+';'+thisRec.CcAddress+';'+thisRec.BccAddress);
                
                listOfNewCasesWithEmail.add(thisRec);
            }
            
            if(thisRec.HtmlBody != NULL){
                
                List<String> currentbody = thisRec.HtmlBody.split('----- Original Message -----');
                
                if(currentbody.size()>0){
                    
                    thisRec.Current_Body__c = currentbody.get(0);
                    
                    if(
                        thisRec.Current_Body__c != NULL && 
                        thisRec.Current_Body__c.contains('----- Forwarded message -----')
                    ){
                        
                        List<String> newCurrentbody = thisRec.Current_Body__c.split('----- Forwarded message -----');
                        
                        if(newCurrentbody.size()>0){
                            thisRec.Current_Body__c = newCurrentbody.get(0);
                        }
                    }
                }
            }
            
            if(thisRec.ParentId != NULL && thisRec.Incoming == TRUE ){
                
                listOfTageEmailFollowupNewCase.add(thisRec);
                mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved.put(thisRec.ParentId,thisRec);
                ListOfcasesToupdateCC.add(thisRec.ParentId);
            } 
            
                 system.debug('Before Insert Parent Check: '+mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved);
            if(thisRec.Subject.containsIgnoreCase('Support')){
                Id activityId = [SELECT Id FROM Task WHERE WhatId = :thisRec.RelatedToId ORDER BY CreatedDate Desc LIMIT 1]?.Id;
                thisRec.Subject += 'RelatedTask #'+activityId;
            }
   
        }
        
        /**	Covered in EmailMessage Loop
if(!listOfNewCasesWithEmail.isEmpty()){
EmailMessageTriggerHelper.updateEmailSourceOnCaseWithToAddressForIncomingCases(
listOfNewCasesWithEmail, 
parentCaseIds
);
}
**/
        
        if(listOfTageEmailFollowupNewCase.size()>0){
            EmailMessageTriggerHelper.updateNewCaseIdToEmailMessage(
                listOfTageEmailFollowupNewCase, 
                parentCaseIds 
            );
        }
        
        if(!mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved.isEmpty()){
            EmailMessageTriggerHelper.updateCaseToReopenFromSolved(mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved);
        }
        if(!ListOfcasesToupdateCC.isEmpty()){	
            EmailMessageTriggerHelper.updateCCAdreessOnCase(ListOfcasesToupdateCC,listOfNewCasesWithEmail);	
        }
        if(!listOfNewCasesWithEmail.isEmpty()){
            EmailMessageTriggerHelper.updateToAddressToParentCase(listOfNewCasesWithEmail);
        } 
        if(!listOfNewCasesWithEmail.isEmpty()){
            EmailMessageTriggerHelper.updateToAddressToParentCase(listOfNewCasesWithEmail);
        }
            
        }
    }
    
    /**	After Insert Code : START	**/
    public static void afterInsert(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){
        if(caseconstants.taskTrigger){
        Map<Id,EmailMessage>	mapOfNewEmailMessages								= new  Map<Id,EmailMessage>();
        Map<Id,EmailMessage> 	mapOfNewEmailMessagesSetCaseStatusToOpenFromPending	= new  Map<Id,EmailMessage>();
            Map<Id,EmailMessage> 	mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved	= new  Map<Id,EmailMessage>();
            
        List<EmailMessage> 		listOfNewEmailMessages								= new List<EmailMessage>();
        Map<Id,EmailMessage> 	mapOfEmailMessages									= new Map<Id,EmailMessage>(); 
        Map<Id,EmailMessage> 	mapOfEmailMessagesTSendACK							= new Map<Id,EmailMessage>(); 
        Map<Id,EmailMessage>   	mapOfEmailMessagesToUpdateStatusSync				= new Map<Id,EmailMessage>();
		Map<Id,EmailMessage>   	mapOfEmailMessagesToUpdateEmailSentDate				= new Map<Id,EmailMessage>();
        
        
        for(SObject objectInstance : mapOfNewSObjects.Values()){
            
            EmailMessage emailMessageInstance = (EmailMessage)objectInstance;
            
            
            if(
                !mapOfNewEmailMessages.containsKey(emailMessageInstance.Id) && 
                emailMessageInstance.ParentId != NULL && 
                emailMessageInstance.Incoming != TRUE
            ){
                mapOfNewEmailMessages.put(emailMessageInstance.Id,emailMessageInstance);
            }
            
            if(
                !mapOfNewEmailMessagesSetCaseStatusToOpenFromPending.containsKey(emailMessageInstance.Id) && 
                emailMessageInstance.ParentId != NULL && 
                emailMessageInstance.Incoming == TRUE
            ){
                mapOfNewEmailMessagesSetCaseStatusToOpenFromPending.put(emailMessageInstance.Id,emailMessageInstance);
            }
            
            if(
                !mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved.containsKey(emailMessageInstance.Id) && 
                emailMessageInstance.ParentId != NULL && 
                emailMessageInstance.Incoming == TRUE
            ){
                mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved.put(emailMessageInstance.Id,emailMessageInstance);
            }
            
            
            
            if(
                emailMessageInstance.ParentId != NULL && 
                emailMessageInstance.Current_Body__c != NULL
                
            ){
                listOfNewEmailMessages.add(emailMessageInstance);
            }
            
            
            if(
                emailMessageInstance.Incoming	&& 
                emailMessageInstance.ParentId != NULL
            ){
                mapOfEmailMessages.put(emailMessageInstance.Id,emailMessageInstance);
            }
            
            if(
                !emailMessageInstance.inComing && 
                emailMessageInstance.ParentId != NULL && 
                (
                    emailMessageInstance.Status__c != NULL || 
                    emailMessageInstance.Sub_Status__c != NULL 
                )
            ){
                mapOfEmailMessagesToUpdateStatusSync.put(emailMessageInstance.Id,emailMessageInstance);
            }
            
            
            if(emailMessageInstance.RelatedToId  != NULL && String.valueOf(emailMessageInstance.RelatedToId).StartsWith('001')){
                mapOfEmailMessagesToUpdateEmailSentDate.put(emailMessageInstance.Id,emailMessageInstance); 
            }
           
       
        }
        
        

            
            EmailMessageTriggerHelper.updateFirstReplySentOnCase(mapOfNewEmailMessages);
            EmailMessageTriggerHelper.sendEmailFromChildCases(mapOfNewEmailMessages);

        
        if( !mapOfNewEmailMessagesSetCaseStatusToOpenFromPending.isEmpty() ){
            
            EmailMessageTriggerHelper.updateCaseToOpenFromPending(mapOfNewEmailMessagesSetCaseStatusToOpenFromPending);
        }
        
            if(!mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved.isEmpty()){
            EmailMessageTriggerHelper.updateCaseToReopenFromSolved(mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved);
        }
            
            
        if( listOfNewEmailMessages.size()>0 ){
            EmailMessageTriggerHelper.updateLatestEmailBodyToCase(listOfNewEmailMessages);
        }
        
        if( !mapOfEmailMessages.isEmpty() ){
            EmailMessageTriggerHelper.updateIsCaseCreatedFromEmailMessage(mapOfEmailMessages);
        }
        
        if( !mapOfEmailMessagesToUpdateStatusSync.isEmpty() ){
            EmailMessageTriggerHelper.updateCaseStatusAndSubStatus(mapOfEmailMessagesToUpdateStatusSync);
        }
        
        
        EmailMessageTriggerHelper.closeSpamCases((List<EmailMessage>)listOfNewSObjects);
            
            if(!mapOfEmailMessagesToUpdateEmailSentDate.isEmpty()){
                EmailMessageTriggerHelper.updateLatestEmailSentDate(mapOfEmailMessagesToUpdateEmailSentDate);
            }
        }
    }
    
    /**	Before Update Code : START	**/
    public static void beforeUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
        
        List<EmailMessage> incomingEmailMessages = (List<EmailMessage>)mapOfNewSObjects.values();
        
        /**	Email To Case Implementation : START	**/
        for(EmailMessage thisRec : incomingEmailMessages){
            
            system.debug('BEFORE UPDATE - Before ToAddress is: '+thisRec.ToAddress);
            system.debug('BEFORE UPDATE - Before CcAddress is: '+thisRec.CcAddress);
            system.debug('BEFORE UPDATE - Before FromAddress is: '+thisRec.FromAddress);
            
            Set<String> recipientsToEmail = new Set<String>();
            Set<String> recipientsCCEmail = new Set<String>();
            
            if(thisRec.ToAddress != NULL)
                recipientsToEmail.addAll(thisRec.ToAddress.split(';'));
            
            if(thisRec.CcAddress != NULL)
                recipientsCCEmail.addAll(thisRec.CcAddress.split(';'));
            
            if(recipientsToEmail.contains(thisRec.FromAddress))
                recipientsToEmail.remove(thisRec.FromAddress);
            
            if(recipientsCCEmail.contains(thisRec.FromAddress))
                recipientsCCEmail.remove(thisRec.FromAddress);
            
            thisRec.ToAddress = String.join( new List<String>(recipientsToEmail), ';');
            thisRec.CcAddress = String.join( new List<String>(recipientsCCEmail), ';');
            
            system.debug('BEFORE UPDATE - After ToAddress is: '+thisRec.ToAddress);
            system.debug('BEFORE UPDATE - After CcAddress is: '+thisRec.CcAddress);
            system.debug('BEFORE UPDATE - After FromAddress is: '+thisRec.FromAddress);
            
        }
    }
    
    /**	After Update Code : START	**/
    public static void afterUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
        Map<Id,EmailMessage> mapOfEmailMessagesToUpdateStatusSync=new Map<Id,EmailMessage>();
        Map<Id,EmailMessage> mapOfNewEmailMessages=new  Map<Id,EmailMessage>();
        for(SObject objectInstance:mapOfNewSObjects.Values()){
            EmailMessage emailMessageInstance=(EmailMessage)objectInstance;
            if(emailMessageInstance.inComing!=true && emailMessageInstance.ParentId!=null && (emailMessageInstance.Status__c !=null || emailMessageInstance.Sub_Status__c !=null)){
                mapOfEmailMessagesToUpdateStatusSync.put(emailMessageInstance.Id,emailMessageInstance);
            } 
            if(!mapOfNewEmailMessages.containsKey(emailMessageInstance.Id) && emailMessageInstance.ParentId!=null && emailMessageInstance.Incoming!=true){
                mapOfNewEmailMessages.put(emailMessageInstance.Id,emailMessageInstance);
            }
        }
        if(!mapOfEmailMessagesToUpdateStatusSync.isEmpty()){
            EmailMessageTriggerHelper.updateCaseStatusAndSubStatus(mapOfEmailMessagesToUpdateStatusSync);
        }
        if(!mapOfNewEmailMessages.isEmpty()){
            EmailMessageTriggerHelper.sendEmailFromChildCases(mapOfNewEmailMessages);
        }
    }
    
    /**	Before Delete Code : START	**/
    public static void beforeDelete(List<SObject> listOfOldSObjects,Map<Id,SObject> mapOfOldSObjects){}
    
    /**	After Delete Code : START	**/
    public static void afterDelete(Map<Id,SObject> listOfOldSObjects){}
    
    /**	After UnDelete Code : START	**/
    public static void afterUnDelete(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){}
    
    /**	END of Code Block	**/
}