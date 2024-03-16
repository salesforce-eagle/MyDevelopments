/**
* @File Name          : EmailMessageTriggerHelper.cls
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 03-14-2024
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    27/5/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public class EmailMessageTriggerHelper {
    
    Static Set<Id> 	caseIdEmailUnique 	= new Set<Id>();
    Static Integer	Count				= 0;
    
    /**	Before Insert Methods	**/
    
    /** 
public static void updateEmailSourceOnCaseWithToAddressForIncomingCases(
List<EmailMessage> 	listOfEmailMessages, 
Set<Id> 			parentCaseIds 
){

Map<Id, Case> caseMap_EmailSourceUpdate	= new Map<Id, Case>();

for(EmailMessage thisRec : listOfEmailMessages){
if(
thisRec.ToAddress.length()<=254 && 
parentCaseIds.contains(thisRec.ParentId)
){
Case parentCase = new Case(
Id 				= thisRec.ParentId,
Email_Source__c	= thisRec.ToAddress
);

caseMap_EmailSourceUpdate.put(parentCase.Id, parentCase);
}
}

if(caseMap_EmailSourceUpdate.size()>0){
DataBase.update(caseMap_EmailSourceUpdate.values(), FALSE);
}

//	return caseMap_EmailSourceUpdate;
}**/
    
    public static void updateNewCaseIdToEmailMessage(
        List<EmailMessage> listOfEmailMessages, 
        Set<Id> 			parentCaseIds
    ){
        
        Set<Id> 		setOfParentCaseIds			= new Set<Id>();
        Map<Id, Case> 	mapOfOldCaseIdWithNewCases	= new Map<Id, Case>();
        
        if(listOfEmailMessages.size() > 0){
            for(EmailMessage emailMessageInstance:listOfEmailMessages){
                setOfParentCaseIds.add(emailMessageInstance.ParentId);
            }
        } 
        
        Set<Id> 								setofUserIds						= new Set<Id>();
        Map<String, Boolean> 					mapOfUserAvailabilityInOmniChannel	= new Map<String, Boolean>();
        
        Map<Id,Case>							mapOfClosedCases					
            = new Map<Id,Case>((List<Case>)CaseSelector.getClosedCaseByIds(setOfParentCaseIds));
        
        List<CaseRecordTypeQueueMapping__mdt> 	listOfRecordTypeAndQueueMappings	= DataBase.query('SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, RecordType__c, QueueName__c FROM CaseRecordTypeQueueMapping__mdt');
        
        
        if(mapOfClosedCases.size() > 0 && mapOfClosedCases != NULL){ 
            for(Id key:mapOfClosedCases.keySet()){
                
                if(mapOfClosedCases.get(key).Status == CaseConstants.Status_Closed){
                    
                    Case caseClonedInstance						= mapOfClosedCases.get(key).clone(false,true);
                    caseClonedInstance.Status					= 'Open';
                    caseClonedInstance.Sub_Status__c			= '';
                    caseClonedInstance.First_Reply_Sent__c		= FALSE;
                    caseClonedInstance.Case_Solved_DataTime__c	= NULL;
                    caseClonedInstance.EntitlementId			= NULL;
                    caseClonedInstance.SlaStartDate				= NULL;
                    caseClonedInstance.isCloned__c				= TRUE;
                    caseClonedInstance.Auto_Response_Sent__c 	= FALSE;
                    caseClonedInstance.Incoming_Email_Count__c 	= NULL;
                    caseClonedInstance.Status 					= 'New';
                    caseClonedInstance.Solved__c 				= false;
                    caseClonedInstance.Followup_Parent_Case__c	= mapOfClosedCases.get(key).Id;
                    
                    setofUserIds.add(mapOfClosedCases.get(key).OwnerId);
                    mapOfOldCaseIdWithNewCases.put(mapOfClosedCases.get(key).Id, caseClonedInstance);
                }
            }
            
            mapOfUserAvailabilityInOmniChannel = CaseService.checkuserInOmni(setofUserIds);
        }
        
        if(!mapOfOldCaseIdWithNewCases.isEmpty()){
            CaseService.updateCaseOwner(mapOfOldCaseIdWithNewCases.values(), mapOfUserAvailabilityInOmniChannel, listOfRecordTypeAndQueueMappings, true);
            insert mapOfOldCaseIdWithNewCases.values();
        }
        
        if(!listOfEmailMessages.isEmpty()){
            for(EmailMessage emailMessageInstance : listOfEmailMessages){
                if(mapOfClosedCases.containsKey(emailMessageInstance?.ParentId)){
                    
                    String parentIdValue = emailMessageInstance?.ParentId;
                    if(mapOfOldCaseIdWithNewCases.get(parentIdValue)?.Id != NULL){
                        emailMessageInstance.ParentId=mapOfOldCaseIdWithNewCases.get(parentIdValue)?.Id;
                    }
                    
                    emailMessageInstance.MessageIdentifier	+= 	'<'+String.valueOf(UserInfo.getOrganizationId()).substring (0,3)+String.valueOf(parentIdValue).substring (2,5) + String.valueOf(System.now()).substring(2, 6);
                    emailMessageInstance.ThreadIdentifier	+= 	'<'+String.valueOf(UserInfo.getOrganizationId()).substring (0,3)+String.valueOf(parentIdValue).substring (2,5) + String.valueOf(System.now()).substring(2, 6);
                    emailMessageInstance.HtmlBody 			= 	emailMessageInstance?.HtmlBody?.replaceAll('ref:_','');
                    emailMessageInstance.Subject			= 	emailMessageInstance?.Subject?.replaceAll('ref:_','');
                    emailMessageInstance.TextBody			= 	emailMessageInstance?.TextBody?.replaceAll('ref:_','');
                }
            }
        }
        
    }
    
    public static void updateCaseToReopenFromSolved(Map<Id,EmailMessage> mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved){
        Set<Id>  parentCaseIds=new Set<Id>();
        for(EmailMessage emailMessageInstance:mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved.values()){
            if(emailMessageInstance.ParentId!=null){
                parentCaseIds.add(emailMessageInstance.ParentId);
            }
        }
        
        if(parentCaseIds.size()>0){
            CaseService.updateCaseToReopenFromSolved(parentCaseIds,mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved); // 24-11-2020 Enhancement
        } 
    }
    
    public static void updateCCAdreessOnCase(
        Set<Id> caseListWhereCCWillbeupdated, 
        List<EmailMessage> incomingEmailMessage
    ){
        
        Set<String> 	toAddresses				= new Set<String>();
        List<Case> 		casesToUpdate			= new List<Case>();
        Map<Id, Case>	caseMap	= new Map<Id, Case>( 
            [ SELECT Id, OwnerId, CCEmailAddress__c, Status FROM Case WHERE 
             Id IN : caseListWhereCCWillbeupdated ] );
        
        for( EmailMessage thisRec : incomingEmailMessage ){
            
            String 	presentCCAddresses;
            Set<String> CCEmailAddressSet =  new Set<String>();
            Case 	parentCase 			= new Case(
                Id = thisRec.ParentId
            );
            
            
            if(caseMap.containsKey(thisRec.ParentId)){
                if(caseMap.get(thisRec.ParentId).CCEmailAddress__c != NULL){
                    presentCCAddresses = caseMap.get(thisRec.ParentId).CCEmailAddress__c+';'+thisRec.CcAddress;
                }else{
                    presentCCAddresses = thisRec.CcAddress;
                    presentCCAddresses = presentCCAddresses + ';' + thisRec.ToAddress;
                }
            }
            if(!String.ISBLANK(presentCCAddresses)){
            CCEmailAddressSet =  new Set<String>(presentCCAddresses.split(';'));
            }
            for(string ccEmail : CCEmailAddressSet){
                if(system.label.Email_Exclusion_Email_To_Case.contains(ccEmail)) {
                    CCEmailAddressSet.remove(ccEmail);
                } 
            }
            
            parentCase.CCEmailAddress__c = String.Join(new List<String>(CCEmailAddressSet),';');
            /**	parentCase	= CTX_CaseOwnerMappingBasedOnSubject.assigneCaseOwnerBasedOnEMailSubject(thisRec, parentCase);	**/
            
            system.debug('EmailMessageTriggerHelper updateCCAdreessOnCase parentCase: '+parentCase);
            casesToUpdate.add(parentCase);
        }
        
        if(casesToUpdate.size() > 0)
            Database.update(casesToUpdate, FALSE);
    }
    
    
    
    
    
    
    
    
    
    /**	After Insert Methods	**/
    public static void updateFirstReplySentOnCase(Map<Id,EmailMessage> mapOfEmailMessages){
        Set<Id> setOfParentCaseIds=new Set<Id>();
        Set<Id> assignedIds = new Set<Id> ();
        list<case> casesToUpdate= new list<case>();
        if(!mapOfEmailMessages.isEmpty()){
            for(EmailMessage em:mapOfEmailMessages.values()){
                if(em.ParentId!=null){
                    setOfParentCaseIds.add(em.ParentId);
                }
            }
        }
        
        if(!setOfParentCaseIds.isEmpty()){
            list<case> listOfCases=[select id,User_Role_Type__c,First_Reply_Sent__c,(Select Id, CreatedBy.Name From EmailMessages Where Incoming = false) from case where id in:setOfParentCaseIds];
            if(!listOfCases.isEmpty()){
                for(case cs: listOfCases){
                    if( cs.User_Role_Type__c != NULL && cs.User_Role_Type__c.contains('CA/SME Tax Cloud')){
                        for(EmailMessage thisEmail : cs.EmailMessages){
                            if(thisEmail.CreatedBy.Name != 'Salesforce Automation'){
                                assignedIds.add(thisEmail.CreatedById);
                            }
                        }
                        
                        if(assignedIds.size() > 0 && !cs.First_Reply_Sent__c ){
                            cs.First_Reply_Sent__c=true;
                            casesToUpdate.add(cs);
                        }      
                    }else{
                        if(cs.EmailMessages.size() >= 1 && !cs.First_Reply_Sent__c ){
                            cs.First_Reply_Sent__c=true;
                            casesToUpdate.add(cs);
                        }   
                    }
                  	
                }
                
                if(!casesToUpdate.isEmpty()){
                    update casesToUpdate;
                }
            }     
        }
    }
    
    
    public static void updateCaseToOpenFromPending(Map<Id,EmailMessage> mapOfNewEmailMessagesSetCaseStatusToOpenFromPending){
        Set<Id>  parentCaseIds=new Set<Id>();
        for(EmailMessage emailMessageInstance:mapOfNewEmailMessagesSetCaseStatusToOpenFromPending.values()){
            if(emailMessageInstance.ParentId!=null){
                parentCaseIds.add(emailMessageInstance.ParentId);
            }
        }
        
        if(parentCaseIds.size()>0){
            CaseService.updateCaseToOpenFromPending(parentCaseIds);
        }
    }
    
    
    
    
    
    
    /**	Update Email_Source__c of Parent Case : START	**/
    
    
    public static void updateLatestEmailBodyToCase(List<EmailMessage> listOfNewEmailMessages){
        List<Case> listOfParentCasesToUpdate=new List<Case>();
        List<Id> parentCaseIdList = new List<Id>();
        for(EmailMessage emailIns : listOfNewEmailMessages){
            if(emailIns.parentId != NULL){
                parentCaseIdList.add(emailIns.parentId);
            }
        }
        
        list<EmailMessage> lastAgentEmail   = [SELECT TextBody,FromAddress FROM EmailMessage 
                                               WHERE (Incoming = FALSE AND FromAddress NOT IN :System.label.First_touch_resolution_exclusion_email.split(',')
                                                      AND parentId IN: parentCaseIdList) ORDER BY createddate DESC LIMIT 1] ;
        system.debug('****lastAgentEmail-->'+lastAgentEmail);
        if(listOfNewEmailMessages.size()>0){
            for(EmailMessage emailMessageInstance:listOfNewEmailMessages ){
                if(emailMessageInstance.Current_Body__c!=null &&  emailMessageInstance.Current_Body__c.length()<=131072 && emailMessageInstance.ParentId!=null){
                    Case caseInstance=new Case(Id=emailMessageInstance.ParentId);
                    caseInstance.Latest_EmailMessage__c=emailMessageInstance.Current_Body__c;
                    if(lastAgentEmail.Size() >0){
                        caseInstance.Last_Agent_Email_Message__c  =  lastAgentEmail[0]?.TextBody.SubstringBefore('--------------- Original Message ---------------');
                    }
                    system.debug('DebugCurrent_Body__c'+ emailMessageInstance.Current_Body__c);
                    listOfParentCasesToUpdate.add(caseInstance);
                }
                
            }
        }
        
        if(listOfParentCasesToUpdate.size()>0){
            new CaseService().updateCases(listOfParentCasesToUpdate, '');
        }
        
    }
    
    
    public static void updateIsCaseCreatedFromEmailMessage(Map<Id,EmailMessage> mapOfEmailMessage){
        Set<Id> setOfParentCaseIds=new Set<Id>();
        Set<Id> caseIdEmailTOBESent=new Set<Id>();
        Map<Id,EmailMessage> mapOfEmailMessagesToBeInserted = new Map<Id,EmailMessage>();
        Map<Id, Case> mapOfIdandCase = new Map<Id, Case>();
        
        
        List<Messaging.SingleEmailMessage> listOfMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        List<Org_wide_and_Email_Template_Mapping__mdt> listOfOrgwideandEmailTemplateMappings=new List<Org_wide_and_Email_Template_Mapping__mdt>();
        listOfOrgwideandEmailTemplateMappings=DataBase.query(UtilityClass.getQueryString('Org_wide_and_Email_Template_Mapping__mdt')+' FROM Org_wide_and_Email_Template_Mapping__mdt ');
        Map<String,Org_wide_and_Email_Template_Mapping__mdt> mapOfOrgwideandEmailTemplateMappings=new  Map<String,Org_wide_and_Email_Template_Mapping__mdt>();
        
        for(Org_wide_and_Email_Template_Mapping__mdt otm : listOfOrgwideandEmailTemplateMappings){
            if(!mapOfOrgwideandEmailTemplateMappings.containsKey(otm.Email_to_case_Inbound_Email__c)){
                mapOfOrgwideandEmailTemplateMappings.put(otm.Email_to_case_Inbound_Email__c, otm);
            }
        }
        system.debug('****mapOfOrgwideandEmailTemplateMappings-->'+mapOfOrgwideandEmailTemplateMappings);
        if(!mapOfEmailMessage.isEmpty()){
            for(Id key : mapOfEmailMessage.keySet()){
                if(mapOfEmailMessage.get(key).incoming){
                    setOfParentCaseIds.add(mapOfEmailMessage.get(key).ParentId);
                }
            }
        }
        system.debug('****setOfParentCaseIds-->'+setOfParentCaseIds);
        List<Case> listofCases = DataBase.query(UtilityClass.getQueryString('Case')+' FROM Case WHERE Id IN: setOfParentCaseIds AND Incoming_Email_Count__c = null');
        system.debug('****listofCases-->'+listofCases);
        Set<Id> setofOrgWiderIds=new Set<Id>();
        
        Set<Id> setofEmailTemplateIds=new Set<Id>();
        if(!listofCases.isEmpty()){
            for(Case caseInstance : listofCases){
                caseIdEmailTOBESent.add(caseInstance.Id);
                mapOfIdandCase.put(caseInstance.Id, caseInstance);
                if(!String.isEmpty(caseInstance.Email_Source__c )){
                    for(String str : caseInstance.Email_Source__c.split(';')){
                        if(mapOfOrgwideandEmailTemplateMappings.containsKey(str.trim()) && !String.isEmpty(mapOfOrgwideandEmailTemplateMappings.get(str.trim()).Org_Wide_Email_Id__c)){
                            if(!String.isEmpty(mapOfOrgwideandEmailTemplateMappings.get(str.trim()).Org_Wide_Email_Id__c)){
                                setofOrgWiderIds.add(mapOfOrgwideandEmailTemplateMappings.get(str.trim()).Org_Wide_Email_Id__c);
                            }
                            if(!String.isEmpty(mapOfOrgwideandEmailTemplateMappings.get(str.trim()).Email_Template_Id__c)){
                                setofEmailTemplateIds.add(mapOfOrgwideandEmailTemplateMappings.get(str.trim()).Email_Template_Id__c);
                            }
                        }
                    }
                }
            }
        }
        system.debug('****setofOrgWiderIds-->'+setofOrgWiderIds);
        system.debug('****setofEmailTemplateIds-->'+setofEmailTemplateIds);
        Map<Id,OrgWideEmailAddress> mapOforgWideEmailAddressInstance  =new Map<Id,OrgWideEmailAddress>([SELECT Id, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, Address, DisplayName, IsAllowAllProfiles FROM OrgWideEmailAddress WHERE Id IN:setofOrgWiderIds ]);
        Map<Id,emailTemplate>  mapOfemailTemplateInstanc= new Map<Id,emailTemplate>([Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Id IN: setofEmailTemplateIds  ]);
        Set<Id> caseIdToDelete = new Set<Id>();
        for(EmailMessage emsg : mapOfEmailMessage.values()){
            system.debug(emsg.FromAddress+' inside loop'+emsg.ToAddress);
            set<string> ToAddresses=new set<string>();
            set<string> CcAddresses=new set<string>();
            String supportAddresses = 'support@cleartaxmailer.com,notification@support.clear.in';
            if(!supportAddresses.Contains(emsg.FromAddress) || !supportAddresses.Contains(emsg.ToAddress)){
                
                if(caseIdEmailTOBESent.contains(emsg.ParentId)){
                    if(!caseIdEmailUnique.contains(emsg.ParentId)){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if(!String.isEmpty(mapOfIdandCase.get(emsg?.parentId).email_Source__c)){
                           for(String str : mapOfIdandCase.get(emsg?.parentId).Email_Source__c.split(';')){
                                if(mapOfOrgwideandEmailTemplateMappings.containsKey(str.trim())){
                                    if(mapOfemailTemplateInstanc.containsKey(mapOfOrgwideandEmailTemplateMappings.get(str.trim()).Email_Template_Id__c)){
                                        email.setTemplateId(mapOfemailTemplateInstanc.get(mapOfOrgwideandEmailTemplateMappings.get(str.trim()).Email_Template_Id__c).Id);
                                    }
                                    if(mapOforgWideEmailAddressInstance.containsKey(mapOfOrgwideandEmailTemplateMappings.get(str.trim()).Org_Wide_Email_Id__c)){
                                        email.setOrgWideEmailAddressId(mapOforgWideEmailAddressInstance.get(mapOfOrgwideandEmailTemplateMappings.get(str.trim()).Org_Wide_Email_Id__c).Id);
                                    }
                                }
                        }
                        }
                        if(!String.ISBLANK(emsg.ToAddress)){
                        for(string emailIds:emsg.ToAddress.split(';')){
                            if(!System.Label.Email_Exclusion_Email_To_Case.Contains( emailIds.trim()))
                                ToAddresses.add(emailIds.trim());
                        }
                        }
                        if(mapOfIdandCase.get(emsg?.parentId).Involved_Email__c != NULL){
                       for(string emailIds:mapOfIdandCase.get(emsg?.parentId).Involved_Email__c.split(';')){
                            if(!System.Label.Email_Exclusion_Email_To_Case.Contains( emailIds.trim()))
                                CcAddresses.add(emailIds.trim());
                        }
                        }
                        if(CcAddresses.Size() > 0){
                            email.setCcAddresses(new List<String>(CcAddresses));
                        }
                        system.debug(' ToAddresses '+ToAddresses);
                        email.setToAddresses(new List<String>(ToAddresses));
                        if(emsg.MessageIdentifier != null){
                            email.setInReplyTo(emsg.MessageIdentifier);
                        } 
                        email.setSaveAsActivity(true);
                        if(mapOfIdandCase.get(emsg.ParentId).ContactId!=null){
                            email.setTargetObjectId(mapOfIdandCase.get(emsg?.ParentId)?.ContactId);
                        }else{
                            if(String.valueOf(mapOfIdandCase.get(emsg?.ParentId)?.OwnerId).startsWith('005')){
                                email.setTargetObjectId(mapOfIdandCase.get(emsg?.ParentId)?.OwnerId);  
                            }else{
                                email.setTargetObjectId(UserInfo.getUserId());
                            }
                        }
                        email.setWhatId(emsg.parentId);
                        system.debug('****email-->'+email);
                        listOfMessagingSingleEmailMessage.add(email);
                        caseIdEmailUnique.add(emsg.ParentId);
                    }
                }
            }
            else{
                caseIdToDelete.add(emsg.ParentId);
            }
        }
        if(!listOfMessagingSingleEmailMessage.isEmpty()){
            Messaging.SendEmailResult[] msgResult = Messaging.sendEmail(listOfMessagingSingleEmailMessage,false);
            System.debug('****msgResult'+msgResult);
        }
        List<Case> csListToDelete = new List<Case>();
        if(!caseIdToDelete.isEmpty()){
            for(Id csId : caseIdToDelete){
                Case cs = new Case();
                cs.Id = csId;
                csListToDelete.add(cs);
            }
            delete csListToDelete;
        }
        
        List<Case> csListToUpdate = new List<Case>();
        for(Id csId : caseIdEmailUnique){
            Case cs = new Case();
            cs.Id = csId;
            cs.Auto_Response_Sent__c = true;
            csListToUpdate.add(cs);
        }
        if(!csListToUpdate.isEmpty()){
            update csListToUpdate;
        }
        
    }
    
    
    public static void updateCaseStatusAndSubStatus(Map<Id,EmailMessage> mapOfEmailMessagesToUpdateStatusSync){
        Set<Id> setOfParentIds=new Set<Id>();
        Map<Id,Case> mapOfIdWithCases=new Map<Id,Case>(); 
        Map<Id,Issue_Type__c> mapOfIdWithIssueType=new Map<Id,Issue_type__c>();
        set<id> setofIssueTypeIds=new Set<Id>();
        Map<Id, Case> updateCaseOnUiList = new Map<Id, Case>();
        
        if(!mapOfEmailMessagesToUpdateStatusSync.isEmpty()){
            for(EmailMessage emailMessageInstance :mapOfEmailMessagesToUpdateStatusSync.Values()){
                setOfParentIds.add(mapOfEmailMessagesToUpdateStatusSync.get(emailMessageInstance.Id).ParentId);
                setofIssueTypeIds.add(emailMessageInstance.Issue_Type__c);
            }
        }
        
        mapOfIdWithCases=new Map<Id,Case>(CaseSelector.getCaseByIds(setOfParentIds));
        mapOfIdWithIssueType=IssueTypeSelector.getIssueTypeById(setofIssueTypeIds);
        
        for(EmailMessage emailMessageInstance :mapOfEmailMessagesToUpdateStatusSync.Values()){
            System.debug(emailMessageInstance.Issue_Type__r?.Case_Type__c);
            if(mapOfIdWithCases.containsKey(emailMessageInstance.ParentId)){
                CaseConstants.constantEmailPending      = TRUE;
                CaseConstants.emailStatus               = emailMessageInstance.Status__c;
                CaseConstants.emailSubStatus            = emailMessageInstance.Sub_Status__c;//Added to pause the milestone for pending
                mapOfIdWithCases.get(emailMessageInstance.ParentId).Status=emailMessageInstance.Status__c;
                mapOfIdWithCases.get(emailMessageInstance.ParentId).Sub_Status__c=emailMessageInstance.Sub_Status__c;
                system.debug('RecordTypeNameDebug'+ (mapOfIdWithCases.get(emailMessageInstance.ParentId).RecordType.Name));
                if(mapOfIdWithCases.get(emailMessageInstance.ParentId).RecordType.Name.ContainsIgnoreCase(CaseConstants.Case_RECORDTYPENAME_E_INVOICING) && emailMessageInstance.Issue_Type__c!=null){ 
                    if(mapOfIdWithIssueType.get(emailMessageInstance.Issue_Type__c).Case_Type__c.equalsIgnoreCase('EInv')){
                        mapOfIdWithCases.get(emailMessageInstance.ParentId).Lookup_Issue_Type_EInv__c=emailMessageInstance.Issue_Type__c;
                    }else{
                        emailMessageInstance.Issue_Type__c.adderror(Label.Issue_Type_Error_on_Email_action_EInv);
                    }
                }else if((mapOfIdWithCases.get(emailMessageInstance.ParentId).RecordType.Name.ContainsIgnoreCase(CaseConstants.B2B_CA_SME) || mapOfIdWithCases.get(emailMessageInstance.ParentId).RecordType.Name.ContainsIgnoreCase(CaseConstants.B2B_ENTERPRISE) || mapOfIdWithCases.get(emailMessageInstance.ParentId).RecordType.Name.ContainsIgnoreCase(CaseConstants.CA_SME_Tax_Cloud) ) && emailMessageInstance.Issue_Type__c!=null) {
                    if(mapOfIdWithIssueType.get(emailMessageInstance.Issue_Type__c).Case_Type__c?.equalsIgnoreCase('B2B')){
                        mapOfIdWithCases.get(emailMessageInstance.ParentId).Lookup_Issue_Type__c=emailMessageInstance.Issue_Type__c;
                    }else{
                        emailMessageInstance.Issue_Type__c.adderror(Label.Issue_Type_Error_on_Email_action_B2B);
                    }
                }else if(mapOfIdWithCases.get(emailMessageInstance.ParentId).RecordType.Name.ContainsIgnoreCase(CaseConstants.B2C) && emailMessageInstance.Issue_Type__c!=null){
                    
                    if( mapOfIdWithIssueType.get(emailMessageInstance.Issue_Type__c).Case_Type__c.equalsIgnoreCase('B2C')){
                        mapOfIdWithCases.get(emailMessageInstance.ParentId).Lookup_Issue_Type1__c=emailMessageInstance.Issue_Type__c;
                    }else{
                        emailMessageInstance.Issue_Type__c.adderror(Label.Issue_Type_Error_on_Email_action_B2C);
                    }  
                    
                }
                /**Adding Priority and type field to be copied from emailMessageInstance fields to cases starts**/
                if(emailMessageInstance.Priority__c!=null){
                    system.debug('priority changes01------>'+emailMessageInstance.Priority__c);
                    mapOfIdWithCases.get(emailMessageInstance.ParentId).Priority=emailMessageInstance.Priority__c;
                    
                }
                if(emailMessageInstance.type__c!=null){
                    mapOfIdWithCases.get(emailMessageInstance.ParentId).type=emailMessageInstance.type__c;
                }
               if(emailMessageInstance.Using_product_through_ERP__c !=null){
                    mapOfIdWithCases.get(emailMessageInstance.ParentId).Using_product_through_ERP__c =emailMessageInstance.Using_product_through_ERP__c ;
                }
                if(emailMessageInstance.Products_Available__c !=null){
                    mapOfIdWithCases.get(emailMessageInstance.ParentId).Products_Available__c =emailMessageInstance.Products_Available__c ;
                }

                /**Adding Priority and type field to be copied from emailMessageInstance fields to cases ends**/
                updateCaseOnUiList.put( emailMessageInstance.ParentId, new Case(Id = emailMessageInstance.ParentId) );
            }
            
            if( updateCaseOnUiList.keySet()?.size() > 0 ){
             system.debug('Check Queuable');
            
            if( system.label.Support_API_Enablement == 'YES' ){
                Id jobID = System.enqueueJob( new CTX_UpsertCaseDetails( updateCaseOnUiList.values() ) );
            }
        }
            
            system.debug('priority changes------>'+mapOfIdWithCases.Values());
            if(!mapOfIdWithCases.isEmpty()){
                update mapOfIdWithCases.Values();
            }
            
        }
    }
    
    
    public static void closeSpamCases(List<EmailMessage> emailMsgList){
        List<Service_Admin_Configuration__c> sacList = [Select Id, Spam_Email__c From Service_Admin_Configuration__c Where RecordTypeId =: Constants.sacSpamRTId];
        
        Set<Id> caseIds = new Set<Id>();
        List<Case> csListToUpdate = new List<Case>();
        
        if(!sacList.isEmpty()){
            for(EmailMessage em : emailMsgList){
                if(caseIds.isEmpty() || !caseIds.contains(em.ParentId)){
                    for(Service_Admin_Configuration__c sac : sacList){
                        if(!String.isEmpty(em.FromAddress) && em.FromAddress.equalsIgnoreCase(sac.Spam_Email__c)){
                            caseIds.add(em.ParentId);
                            break;
                        }   
                    }
                }
            }
        }
        if(!caseIds.isEmpty()){
            for(Id csId : caseIds){
                Case cs = new Case();
                cs.Id = csId;
                csListToUpdate.add(cs);
            }
        }
        Constants.stopCaseTrigger = true;
        if(!csListToUpdate.isEmpty()){
            delete csListToUpdate;
        }
    }
    
    
    public static void sendEmailFromChildCases(Map<Id, EmailMessage> emailMap){
        List<case> childCases = new List<case>();
        Set<String> parentCaseID = new Set<String>();
        List<Case> caseList = new List<Case>();
        List<Messaging.SingleEmailMessage> emsgList = new List<Messaging.SingleEmailMessage>();
        
        for(EmailMessage em: emailMap.values()){
            if(em.ParentId != null && em.Incoming == false){
                parentCaseID.add(em.ParentId);
            }
        }
        caseList = [select id,(select id,Subject, OwnerId, ContactId from cases Where Type = 'Incident of problem'), 
                    (select id,Subject, MessageIdentifier, ToAddress,FromAddress, FromName, Headers, HtmlBody, TextBody, CcAddress from EmailMessages Where Incoming = false Order By CreatedDate DESC LIMIT 1) 
                    from case where Id =: parentCaseID AND Type = 'Problem'];
        if(!caseList.isEmpty()){
            for(Case cs : caseList){
                if(!cs.Cases.isEmpty() && !cs.EmailMessages.isEmpty()){
                    EmailMessage emsg = cs.EmailMessages[0];
                    for(Case childcs : cs.Cases){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new List<String>{emsg.ToAddress});
                        email.setSubject(emsg.Subject);
                        email.setOrgWideEmailAddressId(system.label.Support_Cleartax);
                        email.setSaveAsActivity(true);
                        email.setHtmlBody(emsg.HtmlBody);
                        email.setPlainTextBody(emsg.TextBody);
                        email.setWhatId(childcs.Id);
                        if(childcs.ContactId != null){
                            email.setTargetObjectId(childcs.ContactId);
                        }
                        else if(String.valueOf(childcs.OwnerId).startsWith('005')){
                            email.setTargetObjectId(childcs.OwnerId);
                        }
                        else{
                            email.setTargetObjectId(UserInfo.getUserId());
                        }
                        emsgList.add(email);
                    }
                }
            }
            if(!emsgList.isEmpty()){
                Messaging.SendEmailResult[] msgResult = Messaging.sendEmail(emsgList, false);
                system.debug('****msgResult-->'+msgResult);
            }
        }
        
    }
    
    
    //send mail to cc address
    
    
    Public static EmailMessage trimFrom_ToAddressAndCCAddress(EmailMessage record){
        
        
        system.debug('BEFORE INSERT - Before ToAddress is: '+record.ToAddress);
        system.debug('BEFORE INSERT - Before CcAddress is: '+record.CcAddress);
        system.debug('BEFORE INSERT - Before FromAddress is: '+record.FromAddress);
        
        Set<String> recipientsToEmail = new Set<String>();
        Set<String> recipientsCCEmail = new Set<String>();
        
        if(record.ToAddress != NULL)
            recipientsToEmail.addAll(record.ToAddress.split(';'));
        
        if(record.CcAddress != NULL)
            recipientsCCEmail.addAll(record.CcAddress.split(';'));
        
        if(recipientsToEmail.contains(record.FromAddress) && !record.FromAddress.containsIgnoreCase('team-salesforce@cleartax.in'))
            recipientsToEmail.remove(record.FromAddress);
        
        if(recipientsCCEmail.contains(record.FromAddress))
            recipientsCCEmail.remove(record.FromAddress);
        
        record.ToAddress = String.join( new List<String>(recipientsToEmail), ';');
        record.CcAddress = String.join( new List<String>(recipientsCCEmail), ';');
        
        system.debug('BEFORE INSERT - After ToAddress is: '+record.ToAddress);
        system.debug('BEFORE INSERT - After CcAddress is: '+record.CcAddress);
        system.debug('BEFORE INSERT - After FromAddress is: '+record.FromAddress);
        
        return record;
    }
    /**	Update Email_Source__c of Parent Case : START	**/
    public static void updateToAddressToParentCase(List<EmailMessage> listOfEmailMessages){
        
        List<Case> 	listOfParentCasesToUpdate	= new List<Case>();
        Set<id> 	setOfParentCaseIds			= new Set<Id>();
        
        if(listOfEmailMessages.size() > 0){
            
            for(EmailMessage emailMessageInstance : listOfEmailMessages){
                if(emailMessageInstance.ParentId!=null){
                    
                    setOfParentCaseIds.add(emailMessageInstance.ParentId);
                }
            }
        }
        
        Map<Id,Case> mapofIdWithCases = new Map<Id,Case>([ SELECT Id, Email_Source__c , Involved_Email__c 
                                                          FROM Case WHERE 
                                                          Id IN : setOfParentCaseIds ]);
        
        if( mapofIdWithCases.size() > 0 && mapofIdWithCases != NULL ){
            
            for(EmailMessage emailMessageInstance : listOfEmailMessages){
                if(mapofIdWithCases.containsKey(emailMessageInstance.ParentId)){
                    if(emailMessageInstance.ToAddress.length()<=254){
                        for(string str: (emailMessageInstance.ToAddress+';'+emailMessageInstance.CCAddress+';'+emailMessageInstance.BCCAddress).split(';')){
                            String str1 = str.trim();
                            system.debug('str'+str1);
                        if(System.label.Email_Exclusion_Email_To_Case.Contains(str1) && !String.ISBLANK(str1) && str1 != 'null')
                        mapofIdWithCases.get(emailMessageInstance.ParentId).Email_Source__c   = str1;
                        }
                        mapofIdWithCases.get(emailMessageInstance.ParentId).Involved_Email__c = mapofIdWithCases.get(emailMessageInstance.ParentId).Involved_Email__c+';'+emailMessageInstance.ToAddress+';'+emailMessageInstance.CcAddress+';'+emailMessageInstance.BccAddress;
                        List<String> emailList                                                = mapofIdWithCases.get(emailMessageInstance.ParentId).Involved_Email__c.Split(';');
                        Set<String> emailSet                                                  = new Set<String>(emailList);
                        for(String str : emailSet){
                            if(System.label.Email_Exclusion_Email_To_Case.Contains(str)) {
                               emailSet.remove(str); 
                            } 
                        }
                        
                        emailList                                                             = new List<String>(emailSet);
                        mapofIdWithCases.get(emailMessageInstance.ParentId).Involved_Email__c = String.join(emailList,';');
                        
                        
                        
                    }
                    listOfParentCasesToUpdate.add(mapofIdWithCases.get(emailMessageInstance.ParentId));
                }
            }
        }
        
        if(listOfParentCasesToUpdate.size()>0){
            new CaseService().updateCases(listOfParentCasesToUpdate, '');
        }
        
    }
    /**	Update Email_Source__c of Parent Case : END	**/
    
    /** Update Mailthread on comment section - SF <> JIRA **/
    public static void emailToJiraComment(List<EmailMessage> EmailMessagesList){
        Set<Id> caseIds = new  Set<Id>();
		Map<String, EmailMessage> issueMailtrail = new Map<String, EmailMessage>();
        
        for(EmailMessage thisMessage : [ SELECT Id, TextBody, ParentId, Parent.JIRA_Issue_Id__c, Jira_Comment_Id__c  
                                        FROM EmailMessage WHERE 
                                        Parent.JIRA_Issue_Id__c != NULL AND 
                                        Id IN :EmailMessagesList AND 
                                       Jira_Comment_Id__c = NULL 
                                        ORDER BY CreatedDate DESC])
        {
           issueMailtrail.put(thisMessage.Parent.JIRA_Issue_Id__c , thisMessage);
        }
        System.debug('@issueMailtrail'+issueMailtrail);
        if(!issueMailtrail.isEmpty()){
            CTX_JiraCalloutQueuable DQ = new CTX_JiraCalloutQueuable(issueMailtrail); 
            System.enqueueJob(DQ);
        }
    
    }

    public static void updateLatestEmailSentDate(Map<Id,EmailMessage> mapOfEmailMessagesToUpdateEmailSentDate){
        Set<Id> accountIds = new Set<Id>();
        List<Account> accountsToUpdateEmailSentDate = new List<Account>();
        
        for(EmailMessage em : mapOfEmailMessagesToUpdateEmailSentDate.values()){
            accountIds.add(em.RelatedToId);
        }
        
        Map<Id,Account> accountMap = new Map<Id,Account>([ SELECT Id, Latest_Email_Sent_Date__c  
                                                          FROM Account WHERE 
                                                          Id IN : accountIds ]);
        for(Account thisRec : accountMap.values()){
            thisRec.Latest_Email_Sent_Date__c = System.today();
            accountsToUpdateEmailSentDate.add(thisRec);
        }
        try{
            Update accountsToUpdateEmailSentDate;
        }Catch(Exception ex){
            System.debug(' Exception on Account Update xx updateLatestEmailSentDate \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
    }

}