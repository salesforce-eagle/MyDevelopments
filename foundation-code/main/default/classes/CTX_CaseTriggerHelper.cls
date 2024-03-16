/**
* @File Name          : CTX_CaseTriggerHelper.cls
* @Description        : 
* @Author             : archana.kumari@cleartax.in
* @Group              : 
* @Last Modified By   : archana.kumari@cleartax.in
* @Last Modified On   : 11/11/2021
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    11/11/2021   archana.kumari@cleartax.in   Initial Version
* 1.1    04/07/2022   bibhuda.dash@clear.in		   Modified Version(Entente, Alignment and Naming and Spacing conventions)
**/

Public WITHOUT SHARING Class CTX_CaseTriggerHelper IMPLEMENTS TriggerInterface{
    
    private static String	MILESTONE_NAME 	= 'Customer wait time';
    private static Boolean	executeOnce		= TRUE;
    
    public static void beforeInsert(List<SObject> listOfNewSObjects){}
    
    public static void afterInsert(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){}
    
    public static void beforeUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
                /**	SLA Calculation	**/
        if(executeOnce){
            
            List<Case> casesToUpdates = new List<Case>();
            
            for (
                CaseMilestone thisRec : [ SELECT CaseId, MilestoneType.Name,
                                         TargetDate, StartDate, 
                                         TimeRemainingInMins, TimeSinceTargetInMins, TimeSinceTargetInHrs, 
                                         TimeRemainingInHrs  
                                         
                                         FROM CaseMilestone WHERE 
                                         
                                         CaseId IN :mapOfNewSObjects.keySet() AND
                                         MilestoneType.Name =: MILESTONE_NAME
                                        ]
            ){
                
                system.debug('TimeRemainingInMins---->'+thisRec.TimeSinceTargetInHrs);
                system.debug('thisRec.TimeRemainingInMins---->'+thisRec.TimeRemainingInHrs);
                
                  mapOfNewSObjects.get(thisRec.caseId);
                
                if(thisRec.TimeRemainingInMins == '00:00'){
                    ((Case)mapOfNewSObjects.get(thisRec.caseId)).SLA_time__c	= '-' + thisRec.TimeSinceTargetInHrs ;
                }else if(thisRec.TimeRemainingInMins!='00:00'){
                    ((Case)mapOfNewSObjects.get(thisRec.caseId)).SLA_time__c	= thisRec.TimeRemainingInHrs;
                }
                
               
            }
            
            
        } 
    }
    
    public static void beforeDelete(List<SObject> listOfOldSObjects,Map<Id,SObject> mapOfOldSObjects){}
    
    public static void afterInsert(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){}
    
    public static void afterDelete(Map<Id,SObject> listOfOldSObjects){}
    
    public static void afterUnDelete(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){}
    
    public static void afterupdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
        

    }
    
    public static void mergeCaseEmailTrigger(Map<id,case> mapOfMergedChildCases,Set<id> setOFMasterCaseIDs){
        system.debug('mapOfMergedChildCases ---->'+mapOfMergedChildCases);
        system.debug('CaseTriggerHandler.firstRunMergeEmailSend ---->'+ CaseTriggerHandler.firstRunMergeEmailSend);
         system.debug('setOFMasterCaseIDs ---->'+ setOFMasterCaseIDs);
        List<ID> listOfcaseIds=new List<ID>();
        listOfcaseIds.addAll(mapOfMergedChildCases.Keyset());
        setOfMasterCaseIDs.addAll(listOfcaseIds);
        Map<id,case> mapOfMasterCases=new Map<Id,case>([SELECT id,subject,createdDate,CreatedById,CreatedBy.Name,ContactEmail,Contact.Name,casenumber,Contact_Name__c FROM case Where Id IN:setOFMasterCaseIDs ]);
        system.debug('mapOfMasterCases ---->'+mapOfMasterCases);
        if(CaseTriggerHandler.firstRunMergeEmailSend){
            List<Messaging.SingleEmailMessage> listOfMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
            List<case> caseListToUpdate =new List<case>();
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress WHERE Address='support@cleartaxmailer.com'];
            //EmailTemplate et= [select id from EmailTemplate where developername='Merged_child_case_notification'];
            for(Case cs : mapOfMergedChildCases.values()){
                Case csToUpdate = new Case();
                csToUpdate.Id = cs.Id;
                csToUpdate.Do_not_send_CSAT__c = true;
                csToUpdate.IsMerged__c=true;
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                //  email.setTemplateId(et.Id);
                email.setHtmlBody('Hi,<br/> Thank you for writing in. We can see that there is already an ongoing thread with '
                                  + mapOfMasterCases.get(cs.MasterRecordId).casenumber +' for the same issue raised by '+ mapOfMasterCases.get(cs.MasterRecordId).Contact_Name__c +' with Subject ' + mapOfMasterCases.get(cs.MasterRecordId).Subject +
                                  ' created on ' +mapOfMasterCases.get(cs.MasterRecordId).createdDate+ ' . For ease of correspondence, we will close this thread and continue our conversation on the original thread.');
                if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }            
                email.setToAddresses(new List<String>{cs.ContactEmail});
                email.setSaveAsActivity(false);
                email.setTargetObjectId(UserInfo.getUserId());
                //email.setCcAddresses(new List<String>{});
                email.setWhatId(cs.Id);
                listOfMessagingSingleEmailMessage.add(email);
                caseListToUpdate.add(csToUpdate);
                
            }
            if(!listOfMessagingSingleEmailMessage.isEmpty()){
                System.debug('****listOfMessagingSingleEmailMessage'+listOfMessagingSingleEmailMessage);
                Messaging.SendEmailResult[] msgResult = Messaging.sendEmail(listOfMessagingSingleEmailMessage,false);
                System.debug('****msgResult'+msgResult);
                if(!caseListToUpdate.isEmpty()){
                    update caseListToUpdate;
                }
            }
            CaseTriggerHandler.firstRunMergeEmailSend=false;
        }
    }
    
    public static void handleOwnerchangeBasedonKeyword(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
        List<Case_Assignment_Based_Rule__mdt > allCaseAssignmentBasedRule	= [SELECT MasterLabel, QualifiedApiName,RecordTypes__c , Keywords__c  ,AssignedUser__c 
                                                                               FROM Case_Assignment_Based_Rule__mdt where IsActive__c=true];
        system.debug('allCaseAssignmentBasedRule----->'+allCaseAssignmentBasedRule);
        //  Map<id,case> mapOfNewCase=(case) mapOfNewSObjects;
        Map<string,string> validKeywordsMap=new Map<string,string> ();
        List<string> validRecordTypes=new List<string> ();
        Set<Case> setOfCasesToUpdate=new Set<Case> ();
        List<Case>  listOfCasesToUpdate=new  List<Case>();
        for(Case_Assignment_Based_Rule__mdt thisMDTRecord:allCaseAssignmentBasedRule){ 
            for(string validRT:thisMDTRecord.RecordTypes__c.split(',')){
                validRecordTypes.add(validRT);
            }
            for(string validKeyWord:thisMDTRecord.Keywords__c.split(',')){
                validKeyWord.uncapitalize();
                validKeywordsMap.put(validKeyWord,thisMDTRecord.AssignedUser__c);
            }
        }
        system.debug('validKeywordsMap----->'+validKeywordsMap);
        for(SObject objectInstance:mapOfNewSObjects.values()){
            case newCase=(Case)objectInstance;
            system.debug('newCase-->'+newCase);
            system.debug('validRecordTypes-->'+validRecordTypes);
            if(validRecordTypes.contains(newCase.recordtypeId))
                for(String keywordValue:validKeywordsMap.keyset()){
                        
                    if(newCase.subject !=null && newCase.subject.uncapitalize().contains(keywordValue) || newCase.Description !=null  && newCase.Description.uncapitalize().contains(keywordValue)){
                        case newCaseToUpdate= new case();
                        newCaseToUpdate.id=newCase.Id;
                        newCaseToUpdate.OwnerId = validKeywordsMap.get(keywordValue);  
                        setOfCasesToUpdate.add(newCaseToUpdate); 
                    }
                }
        }
        if(!setOfCasesToUpdate.isEmpty()){
            system.debug('setOfCasesToUpdate----->'+setOfCasesToUpdate);
            listOfCasesToUpdate.addAll(setOfCasesToUpdate);
            update listOfCasesToUpdate;
        }
    }
    
}