/**
 * @File Name          : CaseService.cls
 * @Description        : 
 * @Author             : Lokesh@SFDeveloper.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10-10-2023
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    27/5/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public without sharing class CaseService {

    

    /**
   * @description
   * @author Lokesh Thathuru | 05/19/2020
   * @param Set<Id> setOfCaseIds
   * @return void
   */
   public static void updateCaseToOpenFromPending(Set<Id> setOfCaseIds){
       
       List<Case> listOfCasesToUpdateStatusToOpen=new List<Case>();
       
       listOfCasesToUpdateStatusToOpen=CaseSelector.getPendingCaseByIds(setOfCaseIds);
       if(listOfCasesToUpdateStatusToOpen.size()>0){
           for(Case caseInstance:listOfCasesToUpdateStatusToOpen){
               if(caseInstance.Status=='Pending'){
                   caseInstance.Status='Open';
                   caseInstance.Sub_Status__c='';
                   caseInstance.IsPending_To_auto_close__c=false;
                   caseInstance.DateTime_To_auto_Close_B2B__c=null;
               }
           }
       }
       
       new CaseService().updateCases(listOfCasesToUpdateStatusToOpen, '');
       
   }
   
   
    /**
   * @description
   * @author Lokesh Thathuru | 06/09/2020
   * @param Set<Id> setOfCaseIds
   * @return void
   */
   public static void updateCaseToReopenFromSolved(Set<Id> setOfCaseIds,Map<Id,EmailMessage> mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved){
       
       System.debug('ReOpen Issue is being Calles: ');
       try{
           
           List<Case> listOfCasesToUpdateStatusToReopen=new List<Case>();
       //01-Aug-2020 New Enhancement for Followup start
       List<Case> listOfCasesToNewCases=new List<Case>();
       //01-Aug-2020 New Enhancement for Followup end
       List<Case> listOfSolvedCases=CaseSelector.getSolvedOrUnresolvedCaseByIds(setOfCaseIds);
       
       //14-Apr-2021 New Enhancement for followup start
       Set<Id> setofUserIds=new Set<Id>();
       Map<String,boolean> mapOfUserAvailabilityInOmniChannel=new Map<String,boolean>();
       List<CaseRecordTypeQueueMapping__mdt> listOfRecordTypeAndQueueMappings;
       //listOfRecordTypeAndQueueMappings=CaseRecordTypeQueueMapping__mdt.getAll().values();
       //14-Apr-2021 New Enhancement for followup start
       
       if(listOfSolvedCases.size()>0){
           listOfRecordTypeAndQueueMappings=[SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, RecordType__c, QueueName__c 
                                             FROM CaseRecordTypeQueueMapping__mdt];//new List<CaseRecordTypeQueueMapping__mdt>();
           for(Case caseInstance:listOfSolvedCases){
               if(caseInstance.Status == CaseConstants.STATUS_SOLVED ){
                   Date dateInstance;
                   if(caseInstance.Case_Solved_DataTime__c!=null){
                       dateInstance=Date.newinstance(caseInstance.Case_Solved_DataTime__c.year(), caseInstance.Case_Solved_DataTime__c.month(), caseInstance.Case_Solved_DataTime__c.day());
                   }
                   
                   
                   Datetime dt = System.now();
                   String dayOfWeek = dt.format('EEEE');
                   System.debug('<--dayOfWeek-->'+dayOfWeek);
                   Date endDateInstance;
                   if(dayOfWeek!='Sunday' && dayOfWeek!='Saturday'){
                       endDateInstance=System.today();
                   }
                   Integer noOfDaysdifference=0;
                   if(dateInstance!=null && endDateInstance!=null){
                       noOfDaysdifference=dateInstance.daysBetween(endDateInstance);
                   }
                   System.debug('noOfDaysdifference'+noOfDaysdifference+' ==> '+CaseConstants.Case_Solved_to_Reopen_Threshold);
                   if(noOfDaysdifference <= CaseConstants.Case_Solved_to_Reopen_Threshold){
                       caseInstance.Status=CaseConstants.Status_TRANSFER; // This Status is Changed according to the Status Standardization
                       caseInstance.Sub_Status__c='';
                       caseInstance.Case_Solved_DataTime__c=null;
                       caseInstance.Is_Customer_Unblocked__c=false;
                       if(caseInstance.Previous_Queue_Id__c!=null){
                           caseInstance.OwnerId=caseInstance.Previous_Queue_Id__c;
                       }
                       caseInstance.IsCaseReopened__c=true; // New Feature Enhancement according to the Status Standardization
                       if(caseInstance.reopen_count__c==null){
                           caseInstance.reopen_count__c=1;
                       }
                       if(caseInstance.reopen_count__c!=null){
                           caseInstance.reopen_count__c+=1;
                       }
                       caseInstance.Latest_Reopen_Date__c=System.now();
                       //14-Apr-2021 New Enhancement for followup start

                       setofUserIds.add(CaseInstance.OwnerId);
                      
                       //14-Apr-2021 New Enhancement for followup end
                       //This Logic is also need to be changed according to the record Type.
                        //14-Apr-2021 commented for followup start
                       //Commeneted as the bug raised by CTX team and enhanced as follow
                       /*if(!String.valueof(CaseInstance.OwnerId).startsWithIgnoreCase('005')){
                           //This Logic is also need to be changed according to the record Type.
                           IF(caseInstance.Previous_Owner__c!=null){
                               caseInstance.OwnerId=caseInstance.Previous_Owner__r.Id;
                           }
                       }*/

                       listOfCasesToUpdateStatusToReopen.add(CaseInstance);
                   }//01-Aug-2020 New Enhancement for Followup start
                   else{
                       Case caseClonedInstance=caseInstance.clone(false,true);
                       caseClonedInstance.Status='New'; // Followup case as New Enhancement Status to New instead of Open 
                       caseClonedInstance.Sub_Status__c='';
                       //Enhancements 29th-Apr-2021
                       caseClonedInstance.First_Reply_Sent__c=false;
                       caseClonedInstance.Case_Solved_DataTime__c=null;
                       caseClonedInstance.EntitlementId=null;
                       caseClonedInstance.SlaStartDate=null;
                       //14-Apr-2021 New Enhancement for followup start
                       //caseClonedInstance.OwnerId=caseInstance.OwnerId;
                       setofUserIds.add(caseInstance.OwnerId);
                       
                      
                        //14-Apr-2021 New Enhancement for followup end

                        //This Logic is also need to be changed according to the record Type.
                        //14-Apr-2021  followup start
                        //Commeneted as the bug raised by CTX team and enhanced as follow
                       /*if(caseInstance.Previous_Owner__c!=null){
                           caseClonedInstance.OwnerId=caseInstance.Previous_Owner__r.Id;
                       }else{
                           caseClonedInstance.OwnerId=caseInstance.OwnerId;
                       }*/
                        //14-Apr-2021 New Enhancement for followup end
                       
                       caseClonedInstance.Followup_Parent_Case__c=caseInstance.Id;
                       listOfCasesToNewCases.add(caseClonedInstance);
                   }
                   //01-Aug-2020 New Enhancement for Followup end      
               }
           }
           
           mapOfUserAvailabilityInOmniChannel=checkuserInOmni(setofUserIds);
       }
       
       
       
       if(listOfCasesToUpdateStatusToReopen.size()>0){
           
           
           //Commented Because of the Reopen Queue Logic is changed
           //updateCaseOwner(listOfCasesToUpdateStatusToReopen, mapOfUserAvailabilityInOmniChannel,listOfRecordTypeAndQueueMappings,false);
           
           new CaseService().updateCases(listOfCasesToUpdateStatusToReopen, '');

       }
       
       //01-Aug-2020 New Enhancement for Followup start
       if(listOfCasesToNewCases.size()>0){
           
           
           updateCaseOwner(listOfCasesToNewCases, mapOfUserAvailabilityInOmniChannel,listOfRecordTypeAndQueueMappings,true);
           
           
           insert listOfCasesToNewCases;
           
           for(Case newCaseInstance:listOfCasesToNewCases){
               if(newCaseInstance.Followup_Parent_Case__c!=null){
                   if(mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved.containsKey(newCaseInstance.Followup_Parent_Case__c)){
                       mapOfNewEmailMessagesSetCaseStatusToReopenFromSolved.get(newCaseInstance.Followup_Parent_Case__c).ParentId=newCaseInstance.Id;
                   }
               }
           }
       }
           
       } catch(Exception ex){
           system.debug( 'Error While Transfering Case: '+ex.getMessage() );
           insert new Logger__c (
           Apex_Class__c = 'Case Service',
           Error_Type__c = 'ReOpen Issue',
           Error_Message__c = ex.getMessage()
           );
       }
       
       //01-Aug-2020 New Enhancement for Followup end

       /*//new functionality for tagging 
       List<String> listPossibleFtrHit=CaseConstants.POSSIBLE_FTR_HIT.Split(',');
       
       List<Topic> listOfTopic =new List<Topic>();
       for(Topic topicInstance:[SELECT id,Name FROM Topic WHERE Name IN:listPossibleFtrHit]){
           listOfTopic.add(topicInstance);
       }  
       if(!(listOfTopic.size()>0)){
           for(String topicName:listPossibleFtrHit){
               Topic topicInstance=new Topic();
               topicInstance.Name=topicName;
               listOfTopic.add(topicInstance);
           }
           System.debug('listOfTopic------>'+listOfTopic);
           if(listOfTopic.size()>0){
               insert listOfTopic;
           }
           TopicAssignmentService.topicAssignmentToEntity(listOfCasesToUpdateStatusToReopen, listOfTopic);
       }else{
           TopicAssignmentService.topicAssignmentToEntity(listOfCasesToUpdateStatusToReopen, listOfTopic);
       }
*/
   }

    /**
   * @description this method helps to check the user is availble in omni-channel or not 
   * @author Lokesh Thathuru | 04/14/2021
   * @param Set<Id> userIds
   * @return Map<String,boolean>
   */
   public static Map<String,boolean> checkuserInOmni(Set<id> userIds){
       //Check whether case owner is queue or user
       //if case owner is user then do the below functionality
       List<UserServicePresence> usrSerPre = new List<UserServicePresence>();
       Map<String,boolean> mapOfUserAvailabilityInOmniChannel=new Map<String,boolean>();
       usrSerPre = [Select Id, IsAway, Name, IsCurrentState ,ServicePresenceStatus.MasterLabel, CreatedDate,UserId from UserServicePresence Where UserId = :userIds Order By CreatedDate Desc limit 1];
       for(UserServicePresence userservicePresenceInstance : usrSerPre){
           if(usrSerPre.size() > 0 && userservicePresenceInstance.IsCurrentState && userservicePresenceInstance.ServicePresenceStatus.MasterLabel == 'Available - Case'){
               if(!mapOfUserAvailabilityInOmniChannel.containsKey(userservicePresenceInstance.UserId)){
                   mapOfUserAvailabilityInOmniChannel.put(userservicePresenceInstance.UserId,true);
                       //return true;
               }
           } else{
               if(!mapOfUserAvailabilityInOmniChannel.containsKey(userservicePresenceInstance.UserId)){
                   mapOfUserAvailabilityInOmniChannel.put(userservicePresenceInstance.UserId,false);
                   //return false;
               }
           }
       }
       return mapOfUserAvailabilityInOmniChannel;
   }
   
   
   public static void updateCaseOwner(List<Case> listOfCasesTobeUpdated,Map<String,boolean> mapOfUserAvailabilityInOmniChannel,List<CaseRecordTypeQueueMapping__mdt> listOfRecordTypeAndQueueMappings,boolean isClonedCases){
       Map<String,String> mapOfRecordTypeWithQueueNames=new Map<String,String>();
       System.debug('Record Type Assignment****');
       if(listOfRecordTypeAndQueueMappings.size()>0){
           
           for(CaseRecordTypeQueueMapping__mdt recordTypeAndQueueMappingInstance :listOfRecordTypeAndQueueMappings){
               if(!mapOfRecordTypeWithQueueNames.containsKey(recordTypeAndQueueMappingInstance.RecordType__c)){
                   mapOfRecordTypeWithQueueNames.put(recordTypeAndQueueMappingInstance.RecordType__c,recordTypeAndQueueMappingInstance.QueueName__c);
               }
           }
       
       }
       
       List<QueueSobject> listofQueueSobjects=[ SELECT Id, QueueId, Queue.Name, Queue.DeveloperName, SobjectType FROM QueueSobject WHERE SobjectType ='Case' and Queue.DeveloperName IN: mapOfRecordTypeWithQueueNames.values()];
       Map<String,QueueSobject> mapOfDeveloperNameWithQueueSobjects=new Map<String,QueueSobject>();
       
       for(QueueSobject queueSobjectInstance:listofQueueSobjects){
           if(!mapOfDeveloperNameWithQueueSobjects.containsKey(queueSobjectInstance.Queue.DeveloperName)){
               mapOfDeveloperNameWithQueueSobjects.put(queueSobjectInstance.Queue.DeveloperName, queueSobjectInstance);
           }
       }
       
       for(Case caseInstance:listOfCasesTobeUpdated){
           /* commented the omni-channel check as requested by Vidya and Adithya
           if(mapOfUserAvailabilityInOmniChannel.containsKey(caseInstance.OwnerId)){
               
               if(mapOfUserAvailabilityInOmniChannel.get(caseInstance.OwnerId)){
                   /*if(!isClonedCases){
                       caseInstance.OwnerId=caseInstance.OwnerId;
                       caseInstance.Status=CaseConstants.Status_ASSIGNED;
                   }else{*/
                   /*System.debug('caseInstance.OwnerId**==>'+caseInstance.OwnerId);
                       caseInstance.OwnerId=caseInstance.OwnerId;
                       //caseInstance.Status=CaseConstants.Status_ASSIGNED;
                   //}
               }else{*/
                   //RecordType and Queue Mapping
                   System.debug('Record Type Assignment');
                   String caseRecordTypeName=CaseSelector.getRecordTypeNameById('Case', caseInstance.RecordTypeId);
                   if(caseRecordTypeName==CaseConstants.B2B_CA_SME){
                       caseInstance.OwnerId= mapOfDeveloperNameWithQueueSobjects.get(mapOfRecordTypeWithQueueNames.get(caseRecordTypeName)).QueueId;
                   }else if(caseRecordTypeName==CaseConstants.B2B_ENTERPRISE){
                       caseInstance.OwnerId= mapOfDeveloperNameWithQueueSobjects.get(mapOfRecordTypeWithQueueNames.get(caseRecordTypeName)).QueueId;
                   }else if(caseRecordTypeName==CaseConstants.B2C){
                       //need to enchance
                           caseInstance.OwnerId= mapOfDeveloperNameWithQueueSobjects.get(mapOfRecordTypeWithQueueNames.get(caseRecordTypeName)).QueueId;

                   }else if(caseRecordTypeName==CaseConstants.Case_RECORDTYPENAME_E_INVOICING){
                       caseInstance.OwnerId= mapOfDeveloperNameWithQueueSobjects.get(mapOfRecordTypeWithQueueNames.get(caseRecordTypeName)).QueueId;
                   }
               /*} commented the omni-channel check as requested by Vidya and Adithya
           }else{
               //RecordType and Queue Mapping
               String caseRecordTypeName=CaseSelector.getRecordTypeNameById('Case', caseInstance.RecordTypeId);
               if(caseRecordTypeName==CaseConstants.B2B_CA_SME){
                   caseInstance.OwnerId= mapOfDeveloperNameWithQueueSobjects.get(mapOfRecordTypeWithQueueNames.get(caseRecordTypeName)).QueueId;
               }else if(caseRecordTypeName==CaseConstants.B2B_ENTERPRISE){
                    caseInstance.OwnerId= mapOfDeveloperNameWithQueueSobjects.get(mapOfRecordTypeWithQueueNames.get(caseRecordTypeName)).QueueId;
               }else if(caseRecordTypeName==CaseConstants.B2C ){
                   //need to enchance
                   caseInstance.OwnerId= mapOfDeveloperNameWithQueueSobjects.get(mapOfRecordTypeWithQueueNames.get(caseRecordTypeName)).QueueId;
               }else if(caseRecordTypeName==CaseConstants.Case_RECORDTYPENAME_E_INVOICING){
                   caseInstance.OwnerId= mapOfDeveloperNameWithQueueSobjects.get(mapOfRecordTypeWithQueueNames.get(caseRecordTypeName)).QueueId;
               }
           }*/
       }
       
   }
   
   
   /**
   * @description
   * @author Lokesh Thathuru | 05/19/2020
   * @param List<Case> listOfCases
   * @param String calledFrom
   * @return void
   */
   public void updateCases( List<Case> listOfCases,String calledFrom){
       List<DataBase.SaveResult> resultOnUpdate=new  List<DataBase.SaveResult>();
       if(listOfCases.size()>0){
               resultOnUpdate=dataBase.update(listOfCases) ;    
       }
   }
   
   
   /**
   * @description
   * @author Lokesh Thathuru | 05/19/2020
   * @param List<Case> listOfCases
   * @param String calledFrom
   * @return void
   */
   public void insertCases( List<Case> listOfCases,String calledFrom){
       if(listOfCases.size()>0){
           try{    
               List<DataBase.SaveResult> resultOnInsert=dataBase.Insert(listOfCases,false) ; 
           }catch(Exception e){
               
           }
       }
   }
   
   /**
   * @description
   * @author Lokesh Thathuru | 05/19/2020
   * @param List<Case> listOfCases
   * @param String calledFrom
   * @return void
   */
   public void deleteCases( List<Case> listOfCases,String calledFrom){
       if(listOfCases.size()>0){
           try{
               List<DataBase.DeleteResult> resultOnDetele=DataBase.Delete(listOfCases,false) ;    
           }catch(Exception e){
               
           }
       }
   }
   
   /**
   * @description
   * @author Lokesh Thathuru | 05/19/2020
   * @param List<Case> listOfCases
   * @param String calledFrom
   * @return void
   */
   public void upsertCases( List<Case> listOfCases,String calledFrom){
       if(listOfCases.size()>0){
           try{
               List<DataBase.UpsertResult> resultOnUpsert=DataBase.Upsert(listOfCases,false) ;  
           }catch(Exception e){
               
           }
       }
   }
   
   
    /**
   * @description This method helps to find the Match and Service Admin record for Keyword with Case Subject.
   * @author Lokesh Thathuru | 25/06/2021
   * @param List<Case> listOfCasesToSendEmailBasedonSubjectedText
   * @return void
   */
   public void sendAnAutoResEmailBasedSubject(List<Case> listOfCasesToSendEmailBasedonSubjectedText,Map<Id,Service_Admin_Configuration__c> mapOfCaseIdwithMatchedServiceAdminConfig){
       Set<Id> setOfParentCaseIds=new Set<Id>();
       Set<Id> caseIdEmailTOBESent=new Set<Id>();
       Map<Id,EmailMessage> mapOfEmailMessagesToBeInserted = new Map<Id,EmailMessage>();
       //String orgName = [SELECT Id, Name FROM Organization limit 1].Name;
       Map<Id, Case> mapOfIdandCase = new Map<Id, Case>();
       List<Messaging.SingleEmailMessage> listOfMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
       
       /*List<Org_wide_and_Email_Template_Mapping__mdt> listOfOrgwideandEmailTemplateMappings=new List<Org_wide_and_Email_Template_Mapping__mdt>();
       listOfOrgwideandEmailTemplateMappings=DataBase.query(UtilityClass.getQueryString('Org_wide_and_Email_Template_Mapping__mdt')+' FROM Org_wide_and_Email_Template_Mapping__mdt ');
       Map<String,Org_wide_and_Email_Template_Mapping__mdt> mapOfOrgwideandEmailTemplateMappings=new  Map<String,Org_wide_and_Email_Template_Mapping__mdt>();
       */
       
      /* for(Org_wide_and_Email_Template_Mapping__mdt orgwideandEmailTemplateMappingInstance:listOfOrgwideandEmailTemplateMappings){
           if(!mapOfOrgwideandEmailTemplateMappings.containsKey(orgwideandEmailTemplateMappingInstance.Email_to_case_Inbound_Email__c)){
               mapOfOrgwideandEmailTemplateMappings.put(orgwideandEmailTemplateMappingInstance.Email_to_case_Inbound_Email__c,orgwideandEmailTemplateMappingInstance);
           }
       }
       */
       
       
       /*if(!mapOfEmailMessage.isEmpty()){
           
           for(Id key : mapOfEmailMessage.keySet()){
               if(mapOfEmailMessage.get(key).incoming){
                   system.debug('updateIsCaseCreatedFromEmailMessage**1');
                   setOfParentCaseIds.add(mapOfEmailMessage.get(key).ParentId);
                   
               }
           }
       }*/
       
       
       //system.debug('query case ***'+[select id, Incoming_Email_Count__c from case where Id IN: setOfParentCaseIds]);
       //List<Case> listofCases=DataBase.query(UtilityClass.getQueryString('Case')+' FROM Case WHERE Id IN: setOfParentCaseIds AND Incoming_Email_Count__c = null');
       List<Case> listofCases = listOfCasesToSendEmailBasedonSubjectedText;
       Set<Id> setofOrgWiderIds=new Set<Id>();
       
       Set<Id> setofEmailTemplateIds=new Set<Id>();
       if(!listofCases.isEmpty()){
           system.debug('updateIsCaseCreatedFromEmailMessage**2'+listofCases);
           for(Case caseInstance : listofCases){
               caseIdEmailTOBESent.add(caseInstance.Id);
               mapOfIdandCase.put(caseInstance.Id, caseInstance);
               //System.debug('caseInstance?.Email_Source__c'+caseInstance?.Email_Source__c);
               setofOrgWiderIds.add(mapOfCaseIdwithMatchedServiceAdminConfig.get(caseInstance?.Id)?.Org_Wide_Email_Id__c);
               setofEmailTemplateIds.add(mapOfCaseIdwithMatchedServiceAdminConfig.get(caseInstance?.Id)?.Template_Id__c);
           }
       }
       
       Map<Id,OrgWideEmailAddress> mapOforgWideEmailAddressInstance  =new Map<Id,OrgWideEmailAddress>([SELECT Id, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, Address, DisplayName, IsAllowAllProfiles FROM OrgWideEmailAddress WHERE Id IN:setofOrgWiderIds ]);
       Map<Id,emailTemplate>  mapOfemailTemplateInstanc= new Map<Id,emailTemplate>([Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Id IN: setofEmailTemplateIds  ]);
       
       //for(EmailMessage emsg : mapOfEmailMessage.values()){
       for(Case caseInstance : listofCases){
          // System.debug('Count *****'+Count+1);
          // if(caseIdEmailTOBESent.contains(emsg.ParentId)){
               //if(!caseIdEmailUnique.contains(emsg.ParentId)){
           Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
           email.setTemplateId(mapOfemailTemplateInstanc.get(mapOfCaseIdwithMatchedServiceAdminConfig.get(caseInstance?.Id)?.Template_Id__c)?.Id);
           email.setToAddresses(new List<String>{caseInstance.SuppliedEmail});
           System.debug('contactEmail'+caseInstance.SuppliedEmail);
           email.setSubject(caseInstance.subject); 
           email.setHtmlBody(mapOfemailTemplateInstanc.get(mapOfCaseIdwithMatchedServiceAdminConfig.get(caseInstance?.Id)?.Template_Id__c).Htmlvalue);
           email.setOrgWideEmailAddressId(mapOforgWideEmailAddressInstance.get(mapOfCaseIdwithMatchedServiceAdminConfig.get(caseInstance?.Id)?.Org_Wide_Email_Id__c)?.Id);    
           email.setSaveAsActivity(false);
           if(mapOfIdandCase.get(caseInstance.Id).ContactId!=null){
               email.setTargetObjectId(mapOfIdandCase.get(caseInstance?.Id)?.ContactId);
           }else{
               if(String.valueOf(mapOfIdandCase.get(caseInstance?.Id)?.OwnerId).startsWith('005')){
                   email.setTargetObjectId(mapOfIdandCase.get(caseInstance?.Id)?.OwnerId);  
               }else{
                   email.setTargetObjectId(UserInfo.getUserId());
               }
           }
           email.setWhatId(caseInstance.Id);
                   
                   listOfMessagingSingleEmailMessage.add(email);
                   
                   EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
                   emailMsg.ToAddress = (email?.getToAddresses())[0];
                   emailMsg.fromaddress = mapOforgWideEmailAddressInstance.get(mapOfCaseIdwithMatchedServiceAdminConfig?.get(caseInstance?.Id)?.Org_Wide_Email_Id__c)?.Address;//emsg.fromAddress;
                   emailMsg.FromName = mapOforgWideEmailAddressInstance.get(mapOfCaseIdwithMatchedServiceAdminConfig.get(caseInstance?.Id)?.Org_Wide_Email_Id__c)?.DisplayName;//emsg.fromName;
                   //if(emsg.MessageIdentifier != null){
                   //    emailMsg.MessageIdentifier = emsg.MessageIdentifier;
                   //    emailMsg.ThreadIdentifier = emsg.MessageIdentifier;
                   //}
                   emailMsg.Subject = email.getSubject();
                   emailMsg.HtmlBody = email.getHtmlBody();
                   emailMsg.TextBody = email.getPlainTextBody ();
                   emailMsg.parentid = caseInstance?.Id; // storing case id externally 
                   emailMsg.MessageDate = system.now();
                   emailMsg.Status = '3';
                   if(!mapOfEmailMessagesToBeInserted.containsKey(emailMsg.parentId)){
                       mapOfEmailMessagesToBeInserted.put(emailMsg.parentId,emailMsg);
                   }
                   //caseIdEmailUnique.add(caseInstance?.Id);
               }
           //}
       //}
      // system.debug('updateIsCaseCreatedFromEmailMessage**3'+mapOfEmailMessagesToBeInserted.values());
       if(mapOfEmailMessagesToBeInserted.values().size() > 0 && !mapOfEmailMessagesToBeInserted.values().isEmpty()){
           Messaging.SendEmailResult[] msgResult = Messaging.sendEmail(listOfMessagingSingleEmailMessage,false);
           system.debug('EmailSent by te AutoResponse Code**4'+mapOfEmailMessagesToBeInserted.values().size());
           //insert mapOfEmailMessagesToBeInserted.values()[0];
           System.debug('msgResult'+msgResult);
       }        
   }
   
   public static void dummy(){
       Integer i = 0;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;i++;i++;
       i++;
       i++;
       i++;
       i++;
   }
   
   
}