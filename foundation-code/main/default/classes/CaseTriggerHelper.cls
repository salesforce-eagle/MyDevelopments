/**
* @File Name          : CaseTriggerHelper.cls
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 02-07-2024
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    27/5/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public without sharing class CaseTriggerHelper {
    
    /**	Reusable Method Block : START	**/
    /**	Reusable Method Block : END	**/
    
    /**	Before Insert Method Block : START	**/
    /**	Before Insert Method Block : END	**/
    
    /**	After Insert Method Block : START	**/
    /**	After Insert Method Block : END	**/
    
    /**	Before Update Method Block : START	**/
    /**	Before Update Method Block : END	**/
    
    /**	After Update Method Block : START	**/
    
    
    
    public static void updateITEMAILIDFieldOnCase(List<Case> listOfCasesToUpdateIT_EMAIL_ID){
        for(Case caseInstance:listOfCasesToUpdateIT_EMAIL_ID){
            caseInstance.IT_Email_ID__c=Label.IT_EMAIL_ID!=null?Label.IT_EMAIL_ID:'';
        }
    }
    
    public static void updateCaseSolvedDatTime(List<Case> listOfCasesToUpdateCaseSolvedDatTime){
        if(listOfCasesToUpdateCaseSolvedDatTime.size()>0){
            for(Case caseInstance:listOfCasesToUpdateCaseSolvedDatTime){
                if(caseInstance.Status==Caseconstants.STATUS_SOLVED)
                    caseInstance.Case_Solved_DataTime__c=System.now();
            }
        }
        
    }
    
    public static void pauseAndUnPauseMilestone(List<Case> listCaseWhereStatusIsPending,Map<Id,Case> mapOfOldCaseWhereStatusIsPending){
        
        if(listCaseWhereStatusIsPending.size()>0){
            for(Case caseInstance:listCaseWhereStatusIsPending){
                if((caseInstance.Status == CaseConstants.STATUS_PENDING && (caseInstance.Sub_Status__c == CaseConstants.SUB_STATUS_WITH_CUSTOMER_FOR_SOL_VER /*||  caseInstance.Sub_Status__c == 'With Kam for problem clarification' || caseInstance.Sub_Status__c == CaseConstants.SUB_STATUS_WITH_CUSTOMER_FOR_PRO_CLAR */|| caseInstance.Sub_Status__c=='With Vendor' || caseInstance.Sub_Status__c=='With Govt Dept')) || caseInstance.Status==CaseConstants.Status_UNRESOLVED 
                   || caseInstance.Sub_Status__c==CaseConstants.SUB_STATUS_INVOICE_COPY_REQUESTS || caseInstance.Sub_Status__c==CaseConstants.SUB_STATUS_REFUND_REQUESTS
                  ){
                      caseInstance.IsStopped=true;
                      DateTime dateTimeInstance=System.now();
                      caseInstance.DateTime_To_auto_Close_B2B__c=dateTimeInstance.addDays(CaseConstants.THRESHOLD_AUTO_CLOSE_15DAYS);
                      // backend field to handle the pending to auto close
                      caseInstance.IsPending_To_auto_close__c=true;
                  }
            }
        }
    }
    
    public static void updatePreviousOwnerId(Map<Id,Case> mapOfNewCases, Map<Id,Case> mapOfOldCases ){
        
        Map<Id,User> mapOfIdWithUsers=new Map<Id,User>();
        Map<Id,User> mapOfIdNewWithUsers=new Map<Id,User>();
        Set<Id> setOfUserIds=new Set<Id>();
        Set<Id> setOfNewUserIds=new Set<Id>();
        for(Id key:mapOfNewCases.keySet()){
            if(String.valueOf(mapOfOldCases.get(key).OwnerId).startsWithIgnoreCase('005')){
                setOfUserIds.add(mapOfOldCases.get(key).OwnerID);
            }
            if(String.valueOf(mapOfNewCases.get(key).OwnerId).startsWithIgnoreCase('005')){
                setOfNewUserIds.add(mapOfNewCases.get(key).OwnerID);
            }
            
        }
        
        mapOfIdWithUsers=new Map<Id,User>([SELECT id,Name,Email,User_Role_Type__c,Manager.Email FROM User Where Id IN:setOfUserIds ]);
        mapOfIdNewWithUsers=new Map<Id,User>([SELECT id,Name,Email,User_Role_Type__c,Manager.Email FROM User Where Id IN:setOfNewUserIds ]);
        String caseSobjectType='Case';
        Map<Id,Group> mapOfSelectedGroups=new Map<Id,Group>((List<Group>)DataBase.query(UtilityClass.getQueryString('Group') + ' FROM Group WHERE Id IN  (SELECT QueueId from QueueSobject WHERE SobjectType=:caseSobjectType)'));
        
        for(Id key:mapOfNewCases.keySet()){
            if(String.valueOf(mapOfOldCases.get(key).OwnerId).startsWith('005')){
                mapOfNewCases.get(key).Previous_Owner__c = mapOfOldCases.get(key).OwnerId;
                if(mapOfIdWithUsers.containsKey(mapOfOldCases.get(key).OwnerID)){
                    mapOfNewCases.get(key).Previous_Owner_EmailId__c=mapOfIdWithUsers.get(mapOfOldCases.get(key).OwnerID).Email;
                    //Enhanced 22 july 2020 start
                    mapOfNewCases.get(key).Old_Owner_TL_Manager_Email__c=mapOfIdWithUsers.get(mapOfOldCases.get(key).OwnerID).Manager.Email;
                    //Enhanced 22 july 2020 end
                }
                
            }
            if(mapOfIdNewWithUsers.containsKey(mapOfNewCases.get(key).OwnerID)){
                mapOfNewCases.get(key).Case_Owners_Manager_Email__c = mapOfIdNewWithUsers.get(mapOfNewCases.get(key).OwnerID).Manager.Email!=null ? mapOfIdNewWithUsers.get(mapOfNewCases.get(key).OwnerID).Manager.Email : '';
            }else{
                if(mapOfSelectedGroups.containsKey(mapOfNewCases.get(key).OwnerID) && mapOfSelectedGroups.get(mapOfNewCases.get(key).OwnerID).Email!=null){
                    mapOfNewCases.get(key).Case_Owners_Manager_Email__c = mapOfSelectedGroups.get(mapOfNewCases.get(key).OwnerID).Email;
                }else{
                    mapOfNewCases.get(key).Case_Owners_Manager_Email__c=null;
                }
            }
            
        }
        
    }
    
    public static Case futureHandleOnClose(case caseInstance2){
        caseInstance2.put('Status',CaseConstants.STATUS_SOLVED);
        return caseInstance2;   
    }
    
    public static void manageProblemAndIncident(List<Case> listOfCases){
        Set<Id> setOfParentCaseIds=new Set<Id>();
        Map<Id,Case> mapOfParentIdWithChildCases=new Map<Id,Case>();
        
        if(listOfCases.size()>0){
            for(Case caseInstance:listOfCases){
                if(caseInstance.ParentId==null && caseInstance.Type==CaseConstants.Type_PROBLEM){
                    setOfParentCaseIds.add(caseInstance.Id);
                }  
            }
        }
        
        List<Case> listOfParentChildCases=new List<Case>();
        if(setOfParentCaseIds.size()>0){
            listOfParentChildCases =CaseSelector.getParentChildCases(setOfParentCaseIds);
        }
        
        String FieldApiNameOFCase=CaseConstants.Field_API_Names_to_Sync_Child_Case;
        List<String> fields=FieldApiNameOFCase.split(',');
        
        Map<Id,Case> mapOfParentIdWithCase=new Map<Id,Case>();
        List<Case> listOfChildCasesToUpdate=new List<Case>();
        if(listOfParentChildCases.size()>0){
            for(Case caseParentInstance:listOfParentChildCases){
                mapOfParentIdWithCase.put(caseParentInstance.Id, caseParentInstance);
                if(caseParentInstance.cases.size()>0){
                    listOfChildCasesToUpdate.addAll(caseParentInstance.cases);
                }
            }
        }
        
        if(listOfChildCasesToUpdate.size()>0){
            for(Case childcaseInstance: listOfChildCasesToUpdate){
                if(childcaseInstance.ParentId!=null && fields.size()>0){
                    for(String field:fields){
                        if(mapOfParentIdWithCase.containsKey(childcaseInstance.ParentId)){
                            if((field=='Lookup_Issue_Type_EInv__c' && (childcaseInstance.RecordTypeId == Constants.eInvoicingRTId ))|| 
                               field=='Lookup_Issue_Type1__c' && ((childcaseInstance.RecordTypeId == Constants.b2bEnterpriseRTId ||
                                                                   childcaseInstance.RecordTypeId == Constants.b2bCASMERTId)) ||
                               field=='Lookup_Issue_Type__c' && (childcaseInstance.RecordTypeId == Constants.b2CRTId) &&
                               mapOfParentIdWithCase.get(childcaseInstance.ParentId).get(field)!=null){
                                   childcaseInstance.put(field,mapOfParentIdWithCase.get(childcaseInstance.ParentId).get(field));
                               }
                            else if(field !='Lookup_Issue_Type__c' || field !='Lookup_Issue_Type1__c' || field !='Lookup_Issue_Type_EInv__c'){
                                childcaseInstance.put(field,mapOfParentIdWithCase.get(childcaseInstance.ParentId).get(field));
                            }
                        }
                    }
                }
            }
        }
        
        if(listOfChildCasesToUpdate.size()>0){
            new CaseService().updateCases(listOfChildCasesToUpdate,'');
        }
    }
    
    public static void createCaseTeamMemberOnOwnerChange(List<Case> listOfNewCases,Map<Id,Case> mapOfOldCases){
        Set<Id> setParentIds=new Set<Id>();
        Set<Id> setPreviousOwnerIds=new Set<Id>();
        Set<Id> setEnterpriseCaseOwnerIds=new Set<Id>();
        Set<Id> setOfConsumerCaseOwnerIds=new Set<Id>();
        
        if(listOfNewCases.size()>0){        
            for(Case newcaseInstance:listOfNewCases){
                setParentIds.add(newcaseInstance.Id);
                if(String.valueof(mapOfOldCases.get(newcaseInstance.Id).OwnerId).startsWithIgnoreCase('005')){
                    setPreviousOwnerIds.add(mapOfOldCases.get(newcaseInstance.Id).OwnerId);
                }
            }
        }
        
        List<CaseTeamMember> listOfcaseTeamMembers=new List<CaseTeamMember>();
        
        if(setParentIds.size()>0 && setPreviousOwnerIds.size()>0){
            listOfcaseTeamMembers = new CaseTeamMemberSelector().getCaseTeamMemberByParentIdAndMemberId(setParentIds,setPreviousOwnerIds);
            System.debug('listOfcaseTeamMembers'+listOfcaseTeamMembers);
        }
        
        //This will helps to Identify the CaseTeamMember Has Duplicate record or not 
        Map<String,CaseTeamMember> mapOfCaseTeamMembers=new Map<String,CaseTeamMember>();
        
        if(listOfcaseTeamMembers.size()>0){
            for(CaseTeamMember caseTeamMemberInstance:listOfcaseTeamMembers){
                if(!mapOfCaseTeamMembers.containsKey(caseTeamMemberInstance.MemberId+'+'+caseTeamMemberInstance.ParentId)){
                    mapOfCaseTeamMembers.put(caseTeamMemberInstance.MemberId+'+'+caseTeamMemberInstance.ParentId,caseTeamMemberInstance);
                }
            }
        }
        System.debug('mapOfCaseTeamMembers'+mapOfCaseTeamMembers.keySet());
        List<CaseTeamRole> listOfCaseTeamRoles=DataBase.query(UtilityClass.getQueryString('CaseTeamRole')+' From CaseTeamRole');
        
        Map<String,CaseTeamRole> mapOfCaseTeamRoles=new Map<String,CaseTeamRole>();
        
        if(listOfCaseTeamRoles.size()>0){
            for(CaseTeamRole caseTeamRoleInstance:listOfCaseTeamRoles){
                if(!mapOfCaseTeamRoles.containsKey(caseTeamRoleInstance.Name)){
                    mapOfCaseTeamRoles.put(caseTeamRoleInstance.Name,caseTeamRoleInstance);
                }
            }
        }
        System.debug ('listOfCaseTeamRoles'+listOfCaseTeamRoles);       
        List<CaseTeamMember> listOfNewCaseTeamMember=new List<CaseTeamMember>();
        
        if(listOfNewCases.size()>0){
            for(Case newCaseInstance:listOfNewCases){
                System.debug('mapOfCaseTeamMembers'+mapOfCaseTeamMembers.get(mapOfOldCases.get(newCaseInstance.Id).OwnerId+'+'+newCaseInstance.Id));
                if(String.valueOf(mapOfOldCases.get(newCaseInstance.Id).OwnerId).startsWithIgnoreCase('005')){
                    if(!mapOfCaseTeamMembers.containskey(mapOfOldCases.get(newCaseInstance.Id).OwnerId+'+'+newCaseInstance.Id)){
                        CaseTeamMember newcaseTeamMember=new CaseTeamMember();
                        
                        if(newCaseInstance.RecordTypeId!=null && CaseSelector.getRecordTypeNameById('Case',newCaseInstance.RecordTypeId).containsIgnoreCase('B2B')){
                            if(mapOfOldCases.containsKey(newCaseInstance.Id)){
                                if(String.valueOf(mapOfOldCases.get(newCaseInstance.Id).OwnerId).startsWithIgnoreCase('005')){
                                    newcaseTeamMember.MemberId=mapOfOldCases.get(newCaseInstance.Id).OwnerId;
                                }
                            }
                            newcaseTeamMember.ParentId=newCaseInstance.Id;
                            if(mapOfCaseTeamRoles.ContainsKey(CaseConstants.CASETEAMROLE_ENTERPRISE_SUPPORT)){
                                newcaseTeamMember.TeamRoleId=mapOfCaseTeamRoles.get(CaseConstants.CASETEAMROLE_ENTERPRISE_SUPPORT).Id;
                            }
                        }else if(newCaseInstance.RecordTypeId!=null && CaseSelector.getRecordTypeNameById('Case',newCaseInstance.RecordTypeId).containsIgnoreCase('B2C')){
                            if(mapOfOldCases.containsKey(newCaseInstance.Id)){
                                if(String.valueOf(mapOfOldCases.get(newCaseInstance.Id).OwnerId).startsWithIgnoreCase('005')){
                                    newcaseTeamMember.MemberId=mapOfOldCases.get(newCaseInstance.Id).OwnerId;
                                }
                            }
                            newcaseTeamMember.ParentId=newCaseInstance.Id;
                            if(mapOfCaseTeamRoles.ContainsKey(CaseConstants.CASETEAMROLE_CONSUMER_SUPPORT)){
                                newcaseTeamMember.TeamRoleId=mapOfCaseTeamRoles.get(CaseConstants.CASETEAMROLE_CONSUMER_SUPPORT).Id;
                            }
                        }else if(newCaseInstance.RecordTypeId!=null && CaseSelector.getRecordTypeNameById('Case',newCaseInstance.RecordTypeId).containsIgnoreCase('E Invoicing')){
                            if(mapOfOldCases.containsKey(newCaseInstance.Id)){
                                if(String.valueOf(mapOfOldCases.get(newCaseInstance.Id).OwnerId).startsWithIgnoreCase('005')){
                                    newcaseTeamMember.MemberId=mapOfOldCases.get(newCaseInstance.Id).OwnerId;
                                }
                            }
                            newcaseTeamMember.ParentId=newCaseInstance.Id;
                            if(mapOfCaseTeamRoles.ContainsKey(CaseConstants.CASETEAMROLE_E_INVOICING_SUPPORT)){
                                newcaseTeamMember.TeamRoleId=mapOfCaseTeamRoles.get(CaseConstants.CASETEAMROLE_E_INVOICING_SUPPORT).Id;
                            }
                        }else{
                            //This case may changes but for now all other Intergration Support record Type will also be using - "Enterprise Support" CaseTeamRoleId
                            if(mapOfOldCases.containsKey(newCaseInstance.Id)){
                                if(String.valueOf(mapOfOldCases.get(newCaseInstance.Id).OwnerId).startsWithIgnoreCase('005')){
                                    newcaseTeamMember.MemberId=mapOfOldCases.get(newCaseInstance.Id).OwnerId;
                                }
                            }
                            newcaseTeamMember.ParentId=newCaseInstance.Id;
                            if(mapOfCaseTeamRoles.ContainsKey(CaseConstants.CASETEAMROLE_ENTERPRISE_SUPPORT)){
                                newcaseTeamMember.TeamRoleId=mapOfCaseTeamRoles.get(CaseConstants.CASETEAMROLE_ENTERPRISE_SUPPORT).Id;
                            }
                        }
                        listOfNewCaseTeamMember.add(newcaseTeamMember);
                    }
                }
            }
        }
        
        if(listOfNewCaseTeamMember.size()>0){
            insert listOfNewCaseTeamMember;
        }
        
        //end of createCaseTeamMemberOnOwnerChange Methods   
    }
    
    public static void updateQuestionToCase(List<Case> listofCases){
        Map<String,Schema.SObjectField> CleartaxOrgConfigurationfieldNames= Schema.getGlobalDescribe().get('Cleartax_Org_Configuration__c').getDescribe().fields.getMap();
        Map<String,Schema.SObjectField> caseFields= Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
        
        Cleartax_Org_Configuration__c orgConfig = Cleartax_Org_Configuration__c.getInstance();
        
        Map<String,String> mapOforgConfig=new Map<String,String>();
        for(String key:CleartaxOrgConfigurationfieldNames.keySet()){
            if(!mapOforgConfig.containsKey(key) && key.containsIgnoreCase('Survey')){
                mapOforgConfig.put(key,String.valueOf(orgConfig.get(key)));
            }
        }
        
        if(listofCases.size()>0){            
            for(Case caseInstance:listofCases){
                for(String key:mapOforgConfig.keySet()){
                    if(caseFields.containsKey(key) && mapOforgConfig.containsKey(key)){
                        caseInstance.put(key,mapOforgConfig.get(key));
                    }
                }
            }
        }
    }
    
    public static void updateGoogleFormSubmitterByEmail(List<Case> listOfGoogleFormSubmitterTagging){
        Map<String,Case> mapOfSubmitterEmails=new Map<String,Case>();
        if(listOfGoogleFormSubmitterTagging.size()>0){
            for(Case caseInstance:listOfGoogleFormSubmitterTagging){
                if(!mapOfSubmitterEmails.containsKey(caseInstance.Web_Form_Submitter_Email__c)){
                    mapOfSubmitterEmails.put(caseInstance.Web_Form_Submitter_Email__c,caseInstance);
                }
            }
        }
        
        List<Contact> listOfContacts=new List<Contact>();
        if(!mapOfSubmitterEmails.isEmpty()){
            listOfContacts  =new ContactSelector().getContactByEmail(new List<String>(mapOfSubmitterEmails.keySet()));
        }
        
        if(listOfContacts.size()>0){
            for(Contact contactInstance:listOfContacts){
                if( contactInstance.Email!=null && contactInstance.Email!='' && mapOfSubmitterEmails.containsKey(contactInstance.Email) && contactInstance.Account.RecordType.Name!=null  && contactInstance.Account.RecordType.Name!=''){
                    if(contactInstance.Account.RecordType.Name.EqualsIgnoreCase(AccountConstants.CLEARTAX_RECORDTYPE)){
                        mapOfSubmitterEmails.get(contactInstance.Email).Google_Form_Submitter__c=contactInstance.Id;
                    }
                }
            }
        }
    }
    
    public static Case caseRoundRobinAssignment(Case listOfCasesToApplyRoudRobinLogic){
        Cleartax_Org_Configuration__c cleartaxOrgConfiguration=Cleartax_Org_Configuration__c.getInstance();
        List<RoundRobinAssing__c> listOfRoundRobinAssings=new List<RoundRobinAssing__c>();
        if(cleartaxOrgConfiguration.Enable_Round_Robin_On_Case__c){
            String query=UtilityClass.getQueryString('RoundRobinAssing__c');
            query+=' FROM RoundRobinAssing__c WHERE Queue_Id__c!=null AND Sobject_Name__c=\'Case\'';
            listOfRoundRobinAssings=DataBase.query(query);
        }
        
        Map<Id,RoundRobinAssing__c> mapOfRoundRobinAssings=new Map<Id,RoundRobinAssing__c>();
        if(listOfRoundRobinAssings.size()>0){
            for(RoundRobinAssing__c roundRobinAssingInstance:listOfRoundRobinAssings){
                if(roundRobinAssingInstance.Queue_Id__c!=null && roundRobinAssingInstance.Queue_Id__c!='' ){
                    Id queueId=Id.ValueOf(roundRobinAssingInstance.Queue_Id__c);
                    if(!mapOfRoundRobinAssings.containsKey(queueId)){
                        mapOfRoundRobinAssings.put((Id)roundRobinAssingInstance.Queue_Id__c,roundRobinAssingInstance);
                    }
                }
            }
        }
        
        List<Case> listOfCasesToAssign=new List<Case>();
        Map<Id,Id> resultAfterAssignment=new Map<Id,Id>();
        
        
        /** if(listOfCasesToApplyRoudRobinLogic.OwnerId!=null && !String.valueOf(listOfCasesToApplyRoudRobinLogic.OwnerId).startsWithIgnoreCase('005') && mapOfRoundRobinAssings.containsKey(listOfCasesToApplyRoudRobinLogic.OwnerId)){
//call the RoundRobin and pass the Queue Id and Case
listOfCasesToAssign.add(listOfCasesToApplyRoudRobinLogic);
}

if(listOfCasesToAssign.size()>0){
resultAfterAssignment=roundRobinAssignmentGeneric.getUserIdtoAssign(listOfCasesToAssign,true,'Null');
}**/
        
        List<Case> listOfToAssignUserCases=new List<Case>();
        //for(case caseIns:resultAfterAssignment){
        listOfCasesToApplyRoudRobinLogic.put('OwnerId',resultAfterAssignment.get(listOfCasesToApplyRoudRobinLogic.Id));
        listOfCasesToApplyRoudRobinLogic.put('Handle_BackEnd_Validation_Off__c',TRUE);
        //caseInstance.Id=caseId;
        // caseInstance.OwnerId=resultAfterAssignment.get(caseId);
        //caseInstance.Handle_BackEnd_Validation_Off__c=true;
        //listOfToAssignUserCases.add(caseIns);
        //}
        system.debug('Owner#$%6'+listOfCasesToApplyRoudRobinLogic.OwnerId);
        return listOfCasesToApplyRoudRobinLogic;
        /** if(listOfToAssignUserCases.size()>0){
new CaseService().updateCases(listOfToAssignUserCases, '');
}

for(Case caseInstance:listOfToAssignUserCases){
caseInstance.Handle_BackEnd_Validation_Off__c=false;
}

if(listOfToAssignUserCases.size()>0){
new CaseService().updateCases(listOfToAssignUserCases, '');
}**/
        
    }
    
    public static void formatGoogleFormAttachmentsLinks(List<Case> updateHtmlLinkInRichTextField){
        for(Case caseInstance :updateHtmlLinkInRichTextField ){
            
            List<String> links=caseInstance.Google_Form_Attachments_URL__c.split(',');
            String finalLink='';
            
            if(links.size()>0){
                finalLink+='<table>';
                for(String link : links){
                    finalLink+='<tr><td><a href="'+link.trim()+'">'+link.trim()+'</a> </td></tr>';
                }
                finalLink+='</table>';
            }
            caseInstance.Google_Form_Attachments_URL__c=finalLink;
            
        }
        
    }   
    
    public static void tagIssueToCases(List<Case> listOfCasesToUpdateIssueTypes){
        /* commented by Lokesh*/
        System.debug('tagIssueToCases in');
        
        Set<Id> setOfLookupToIssueTypeIds=new Set<Id>();
        
        if(listOfCasesToUpdateIssueTypes.size()>0){
            for(Case caseInstance:listOfCasesToUpdateIssueTypes){
                if(caseInstance.Lookup_Issue_Type__c!=null || caseInstance.Lookup_Issue_Type1__c!=null || caseInstance.Lookup_Issue_Type_EInv__c!=null ){
                    if(caseInstance.RecordTypeId == Constants.eInvoicingRTId && caseInstance.Lookup_Issue_Type_EInv__c!=null){
                        setOfLookupToIssueTypeIds.add(caseInstance.Lookup_Issue_Type_EInv__c);
                    }
                    else if(caseInstance.RecordTypeId == Constants.b2CRTId && caseInstance.Lookup_Issue_Type1__c!=null){
                        setOfLookupToIssueTypeIds.add(caseInstance.Lookup_Issue_Type1__c);
                    }
                    else if((caseInstance.RecordTypeId == Constants.b2bEnterpriseRTId || caseInstance.RecordTypeId == Constants.b2bCASMERTId) && caseInstance.Lookup_Issue_Type__c!=null){
                        setOfLookupToIssueTypeIds.add(caseInstance.Lookup_Issue_Type__c);
                    }
                }
            }
        }
        system.debug('****setOfLookupToIssueTypeIds-->'+setOfLookupToIssueTypeIds);
        Map<Id,Issue_Type__c> mapOfIssueTypes=new Map<Id,Issue_Type__c>();
        if(setOfLookupToIssueTypeIds.size()>0){
            mapOfIssueTypes=IssueTypeSelector.getIssueTypeById(setOfLookupToIssueTypeIds);
        }
        system.debug('****mapOfIssueTypes-->'+mapOfIssueTypes);
        if(listOfCasesToUpdateIssueTypes.size()>0){
            for(Case caseInstance:listOfCasesToUpdateIssueTypes){
                if(mapOfIssueTypes.containsKey(caseInstance.Lookup_Issue_Type__c)){ 
                    system.debug('****In 1');
                    caseInstance.Lookup_Issue_Type_EInv__c = null; 
                    caseInstance.Lookup_Issue_Type1__c = null;
                    IssueTypeAssigner(caseInstance, mapOfIssueTypes, caseInstance.Lookup_Issue_Type__c);
                }else if(mapOfIssueTypes.containsKey(caseInstance.Lookup_Issue_Type1__c)){
                    system.debug('****In 2');
                    caseInstance.Lookup_Issue_Type__c = null;
                    caseInstance.Lookup_Issue_Type_EInv__c = null;
                    IssueTypeAssigner(caseInstance, mapOfIssueTypes, caseInstance.Lookup_Issue_Type1__c);
                }else if(mapOfIssueTypes.containsKey(caseInstance.Lookup_Issue_Type_EInv__c)){
                    system.debug('****In 3');
                    caseInstance.Lookup_Issue_Type__c = null;
                    caseInstance.Lookup_Issue_Type1__c = null;
                    IssueTypeAssigner(caseInstance, mapOfIssueTypes, caseInstance.Lookup_Issue_Type_EInv__c);
                }
            }
        }
    }
    
    private static void IssueTypeAssigner(Case caseInstance,Map<Id,Issue_Type__c> mapOfIssueTypes,Id caseLookupId){
        if(mapOfIssueTypes.containsKey(caseLookupId) && mapOfIssueTypes.get(caseLookupId).Issue_Type__c!=null ){
            caseInstance.Issue_Type__c= mapOfIssueTypes.get(caseLookupId).Issue_Type__c;   
        }
        if(mapOfIssueTypes.containsKey(caseLookupId) && mapOfIssueTypes.get(caseLookupId).Issue_Type_1__c!=null ){
            caseInstance.Issue_Type_1__c=mapOfIssueTypes.get(caseLookupId).Issue_Type_1__c;
        }
        if(mapOfIssueTypes.containsKey(caseLookupId) && mapOfIssueTypes.get(caseLookupId).Issue_Type_2__c!=null ){
            caseInstance.Issue_Type_2__c=mapOfIssueTypes.get(caseLookupId).Issue_Type_2__c;
        }
        if(mapOfIssueTypes.containsKey(caseLookupId) && mapOfIssueTypes.get(caseLookupId).Issue_Type_3__c!=null ){
            caseInstance.Issue_Type_3__c=mapOfIssueTypes.get(caseLookupId).Issue_Type_3__c;
        }
        if(mapOfIssueTypes.containsKey(caseLookupId) && mapOfIssueTypes.get(caseLookupId).Issue_Type_4__c!=null ){
            caseInstance.Issue_Type_4__c=mapOfIssueTypes.get(caseLookupId).Issue_Type_4__c;
        }
    }
    
    public static void updateCustomWebFormRTypesByCustomerSegment(List<Case> listofEnterpriseAndEInvoicingCases){
        Id eInvoicingQueueId=[SELECT id,Queue.Name,QueueId,Queue.DeveloperName from QueueSObject WHERE SobjectType='Case'  And Queue.DeveloperName='ENT_E_Invoice_L1_Team'].QueueId;
        
        if(listofEnterpriseAndEInvoicingCases.size()>0){
            for(Case caseInstance:listofEnterpriseAndEInvoicingCases){
                if(caseInstance.Customer_Segment__c.equalsIgnoreCase('GST - Enterprise')){
                    caseInstance.RecordTypeId=new CaseSelector().getCaseRecordTypeIdByName(CaseConstants.B2B_ENTERPRISE);
                }else if(caseInstance.Customer_Segment__c.equalsIgnoreCase('E Invoicing')){
                    caseInstance.RecordTypeId=new CaseSelector().getCaseRecordTypeIdByName(CaseConstants.Case_RECORDTYPENAME_E_INVOICING);
                    caseInstance.OwnerId=eInvoicingQueueId;
                }
            }
        }
        
        
    }
    
    public static void updateQueueIdToCase(List<Case> listOfCaesToUpdateQueueId){
        List<Case> listofCaseToUpdate=new List<Case>();
        for(Case caseNewInstance:listOfCaesToUpdateQueueId){
            caseNewInstance.Previous_Queue_Id__c=caseNewInstance.OwnerId;
        }
    }
    /** public static void updateQueueIdToCase(List<Case> listOfCaesToUpdateQueueId,map<Id,Case> caseOldMap){
List<Case> listofCaseToUpdate=new List<Case>();
for(Case caseNewInstance:listOfCaesToUpdateQueueId){
caseNewInstance.Previous_Queue_Id__c = caseOldMap.get(caseNewInstance.Id).ownerId;
}
}**/
    
    public static void eInvoicePriorityToP1(List<Case> listOfEInvoiceCases){
        if(listOfEInvoiceCases.size()>0){
            for(Case caseInstance:listOfEInvoiceCases){
                if(caseInstance.Priority!=null && caseInstance.Priority!='P0' && caseInstance.RecordTypeId==new CaseSelector().getCaseRecordTypeIdByName(CaseConstants.Case_RECORDTYPENAME_E_INVOICING)){
                    caseInstance.Priority=Label.Case_Form_E_Invoice_Default_Priority;
                }else{
                    caseInstance.Priority=Label.Case_Form_E_Invoice_Default_Priority;
                }
            }
        }
    }
    
    public static void updateCaseStatusToReopenFromTransferOnQueueToUser(List<Case> listOfCaseOwnerIsCaseReOpenedTrue){
        for(Case caseInstance:listOfCaseOwnerIsCaseReOpenedTrue){
            caseInstance.Status=CaseConstants.Status_REOPEN;
        }
    }
    
    public static void SyncTheStatusWithBackStatus(List<Case> listOfCasesToSyncTheStatus){
        if(listOfCasesToSyncTheStatus.size()>0){
            for(Case caseInstance:listOfCasesToSyncTheStatus){
                if(caseInstance.Status!=null){
                    if(caseInstance.Back_End_Status__c!=null){
                        if(!(caseInstance?.Back_End_Status__c?.equalsIgnoreCase('Transfered To Dev On Call') && caseInstance?.Back_End_Status__c?.equalsIgnoreCase('Transfered To Onboard/KAM')))
                            caseInstance.Back_End_Status__c=caseInstance.Status;
                    }else{
                        caseInstance.Back_End_Status__c=caseInstance.Status;
                    }
                }
            }
        }
    }
    
    public static case updateRTAndEntitlement(case caseInstance3){
        if(caseInstance3.User_Role_Type__c == NULL){
            caseInstance3 = caseTriggerHelper.updateUserRoleType(caseInstance3, caseInstance3.OwnerId);
        }
        Map<String, Service_Admin_Configuration__c> sacMap = UtilityClass.getServiceAdminConfig();
        List<String> fieldList = UtilityClass.getFieldFromCaseFieldSet(Constants.entitlementFieldSetApiName);
        
        Boolean bool = false;
        String key = '';
        System.debug('Entitlement Check Key:::::: ');
        for(String str : fieldList){
            system.debug('fieldList values for Entitlement Check: '+str);
            system.debug('fieldList values for Entitlement Check:caseInstance3.get(str):  '+caseInstance3.get(str));
            if(
                caseInstance3.get(str) != null || 
                (
                    str.containsIgnoreCase('priority') && 
                    caseInstance3.get(str.removeEndIgnoreCase('__c')) != NULL 
                )
            ){
                
                if( str.containsIgnoreCase('priority') ){
                    key += caseInstance3.get(str.removeEndIgnoreCase('__c'));
                } else{
                    key += caseInstance3.get(str);
                }
                system.debug('INSIDE IF fieldList values for Entitlement Check:caseInstance3.get(str): '+key);
            } else{
                bool = true;
                break;
            }
        }
        
        System.debug('Entitlement Check Key: '+key);
        key = key.toUpperCase();
        if(!bool){
            bool = sacMap.containsKey(key);
        }
        if(bool){
            if(key!=null && key!=''){
                if(sacMap.get(key).Entitlement__c != null){
                    caseInstance3.put('EntitlementId',sacMap.get(key).Entitlement__c);
                }
                String rtName = sacMap.get(key).Case_Record_Type__c;
                caseInstance3.put('RecordTypeId',Schema.SObjectType.Case.getRecordTypeInfosByName().get(rtName).getRecordTypeId());
                if(rtName == 'International'){
                    caseInstance3.put('BusinessHoursId',System.label.Business_Hours_International);
                }
            }
        }
        system.debug('Owner#$%7'+caseInstance3.OwnerId);
        return caseInstance3;
    }
    
    public static void validateUserRoletype(Map<Id, Case> caseMap, Set<Id> userOwnerIds){
        Map<Id, User> userMap = new Map<Id, User>([Select Id, Support_Departments__c From User Where Id =: userOwnerIds]);
        for(Case cs : caseMap.values()){
            User usr = userMap.get(cs.OwnerId);
            if(String.isEmpty(usr.Support_Departments__c) || !usr.Support_Departments__c.containsIgnoreCase(cs.User_Role_Type__c)){
                cs.User_Role_Type__c.addError(System.Label.TeamResponsibleError);
            }
        }
    }
    
    public static case updateUserRoleType(
        case C1, 
        Id queueOwnerIds/**, 
Map<Id, Case> oldMap**/
    ){
        
        
        Map<Id, Group> groupMap = new Map<Id, Group>([Select Id, Name From Group Where Id =: queueOwnerIds AND Type = 'Queue']);
        //List<String> einvoiceTeam = !String.isEmpty(System.label.Einvoice_Team)?System.label.Einvoice_Team.split(','):new List<String>();
        
        if(!groupMap.isEmpty() && groupMap.containsKey(C1.OwnerId)){
            C1.User_Role_Type__c = groupMap.get(C1.OwnerId).Name;
            /** if(oldMap != null && oldMap.get(cs.Id).User_Role_Type__c != cs.User_Role_Type__c && !einvoiceTeam.isEmpty() && einvoiceTeam.contains(cs.User_Role_Type__c) && !einvoiceTeam.contains(oldMap.get(cs.Id).User_Role_Type__c) && (cs.Priority == 'P3')){
cs.Priority = 'P1';
}**/
        }
        /** else if(oldMap != null && !einvoiceTeam.isEmpty() && einvoiceTeam.contains(cs.User_Role_Type__c) && ( cs.Priority == 'P3')){
cs.Priority = 'P1';
}**/
        return C1;
    }
    public static void updateStatusAsTransfer(List<Case> listOfCasesToUpdateTheStatusASTransfer){
        for(Case caseInstance:listOfCasesToUpdateTheStatusASTransfer){
            caseInstance.Status=CaseConstants.Status_Transfer;
            caseInstance.Sub_Status__c = null;
        }
    }
    
    public static void checkUserIsAwayWhenCaseReopened(set<id> setOfUsers,map<id,case> mapOfCaseIDToCase){
        Map<string,boolean> UserIsActive=CaseService.checkuserInOmni(setOfUsers);
        Map<string,id> mapOfQueue=new Map<string,id>();
        list<case> CaseToUpdate=new list<case>();
        list<group> listOfQueue= [select id,name from group where type='queue'];
        
        for(group grp:listOfQueue){
            mapOfQueue.put(grp.name, grp.id);
        }
        if(!mapOfCaseIDToCase.isEmpty()){
            for(case cs:mapOfCaseIDToCase.values()){
                if((cs.OwnerId != Label.Dev_On_call_user) && (!UserIsActive.containsKey(cs.OwnerId) || (UserIsActive.containsKey(cs.OwnerId) && !UserIsActive.get(cs.OwnerId)))){
                    CaseToUpdate.add(new case(id=cs.Id,ownerId=mapOfQueue.get(cs.User_Role_Type__c),
                                              POD_Group__c = cs.POD_Group__c));
                }
            }
        }
        if(!CaseToUpdate.isEmpty()){
            update CaseToUpdate;
        }
    }
    
    public static void updateAccountAndContactonCase(
        Set<String>	emailSet, 
        List<Case>	caseList, 
        Set<ID> 	queueOwnerIds 
    ){
        //get realted contact based on Email of case
        system.debug('Here Inside');
        List<Contact> conList    = [ SELECT Id, Email, AccountId,Account.RecordType.Name, 
                                    Account.pgl_or_sb__c, Account.Collection_Manager__c, Account.Collection_Manager__r.Email, account.Onboarding_Owner__c 
                                    FROM Contact WHERE Email IN :emailSet
                                    Order BY Account.Sum_of_ARR_Assets__c DESC ];
        System.debug('conList: '+conList);
        //Map<Id,Case>     caseMapAccCheck = new Map<Id,Case>();
        Map<String,Case> caseMapEmailCheck = new Map<String,Case>();
        for(case caseIns : caseList){
            if(caseIns.AccountId != NULL){
                //caseMapAccCheck.put(caseIns.AccountId,caseIns);
                caseMapEmailCheck.put(caseIns.SuppliedEmail,caseIns);
            }
        }
        
        Map<String, Contact> 	emailToContactMap 		= new Map<String, Contact>();
        Map<String, Contact>    intEmailToContactMap    = new Map<String, Contact>(); //International Logic
        Map<Id, Case> 			caseMapForDomain		= new Map<Id, Case>();
        List<Account> 			accList 				= new List<Account>();
        //List<Account> 			intAccList 				= new List<Account>();
        List<Case> 				csListToUpdate 			= new List<Case>();
        List<Case> 				caseListToUpdate 		= new List<Case>();
        list<string> 			MultipleAccount 		= new list<string>();
        Map<string,string> 		mapOfAccIdtoPSGorSBL	= new map<string,string>();
        Map <string,string>  	Queue_DistributionMap	= new Map <string,string>();
        Map<Id, Group> 			queueid_QueueName_Map 	= new Map<Id, Group>([Select Id, Name From Group Where Id =: queueOwnerIds AND Type = 'Queue']);
        
        List<QueueID_DistributionMailMapping__mdt> Queue_DistributionList =DataBase.query(UtilityClass.getQueryString('QueueID_DistributionMailMapping__mdt')+' FROM QueueID_DistributionMailMapping__mdt');
        
        for(QueueID_DistributionMailMapping__mdt thisQueue : Queue_DistributionList){
            Queue_DistributionMap.put(thisQueue.Queue_Id__c, thisQueue.DistributionEmailId__c);
        }
        system.debug('Queue_DistributionMap---> '+Queue_DistributionMap);
        
        //create Map email and contact record
        if(!conList.isEmpty()){
            for(Contact con : conList){
                if(!emailToContactMap.containsKey(con.Email)){
                    if(con.Account.RecordType.Name != CaseConstants.Case_RECORDTYPENAME_International){
                        if(!caseMapEmailCheck.isEmpty() && caseMapEmailCheck.containsKey(con.email)){
                            if(con.AccountId == caseMapEmailCheck.get(con.email).AccountId){
                                emailToContactMap.put(con.Email, con);
                            }
                        }
                        else{
                            emailToContactMap.put(con.Email, con);  
                        }
                    }
                    else{
                        if(!caseMapEmailCheck.isEmpty() && caseMapEmailCheck.containsKey(con.email)){
                            if(con.AccountId != caseMapEmailCheck.get(con.email).AccountId){
                                intEmailToContactMap.put(con.Email, con);
                            }
                        }
                        else{
                            intEmailToContactMap.put(con.Email, con);  
                        }
                    }
                }
            }
        }
        
        Map<String, User> caseEmail_DepartmentMap = new Map<String, User>();
        /**	Checking Start	**/
        for(Case cs : caseList){
            if(System.Label.Internal_Case_RecordTypeId.containsIgnoreCase(cs.RecordTypeId)){
                caseEmail_DepartmentMap.put(cs.ContactEmail, NULL);
            }
        }
        
        for(
            User thisRec : [ SELECT Id, Department, Email 
                            FROM User WHERE 
                            Email IN :caseEmail_DepartmentMap.keySet() AND 
                            IsActive = TRUE AND
                            Profile.UserLicense.Name LIKE '%Salesforce%' ]
        ){
            if(caseEmail_DepartmentMap.containsKey(thisRec.Email)){
                caseEmail_DepartmentMap.put(thisRec.Email, thisRec);
            }
        }
        
        /**	Checking End	**/
        for(Case cs : caseList){
            
            system.debug('here CaseList');
            Boolean isCaseComingfromCaseForm	= (cs.Case_Sub_Origin__c == 'GST Web Form') ? TRUE : FALSE;
            
            if(!isCaseComingfromCaseForm){
                
                if((emailToContactMap.containsKey(cs.SuppliedEmail) && cs.RecordTypeId != CaseConstants.INTERNATIONAL_RecordTypeId) || (intEmailToContactMap.containsKey(cs.SuppliedEmail)&& cs.RecordTypeId == CaseConstants.INTERNATIONAL_RecordTypeId)){
                    
                    Case csToUpdate								= cs.clone(FALSE, FALSE, FALSE, FALSE);
                    csToUpdate.Id 								= cs.Id;
                    Database.DMLOptions dmo = new Database.DMLOptions();
                    dmo.assignmentRuleHeader.useDefaultRule= false;
                    csToUpdate.ContactId 						= cs.RecordTypeId != CaseConstants.INTERNATIONAL_RecordTypeId ? emailToContactMap.get(cs.SuppliedEmail).Id : intEmailToContactMap.get(cs.SuppliedEmail).Id;
                    csToUpdate.AccountId 						= cs.RecordTypeId != CaseConstants.INTERNATIONAL_RecordTypeId ? emailToContactMap.get(cs.SuppliedEmail).AccountId : intEmailToContactMap.get(cs.SuppliedEmail).AccountId;
                    csToUpdate.Account_Collection_Manager__c	= cs.RecordTypeId != CaseConstants.INTERNATIONAL_RecordTypeId ? emailToContactMap.get(cs.SuppliedEmail).Account.Collection_Manager__c : intEmailToContactMap.get(cs.SuppliedEmail).Account.Collection_Manager__c;
                    
                    if(
                        (emailToContactMap.ContainsKey(cs.SuppliedEmail) && emailToContactMap.get(cs.SuppliedEmail)?.Account?.Collection_Manager__c != NULL) 
                        || 
                        (intEmailToContactMap.ContainsKey(cs.SuppliedEmail) && IntEmailToContactMap.get(cs.SuppliedEmail)?.Account?.Collection_Manager__c != NULL)
                    ){
                        csToUpdate.Account_Collection_Manager_Email__c 
                            = cs.RecordTypeId != CaseConstants.INTERNATIONAL_RecordTypeId ? emailToContactMap.get(cs.SuppliedEmail)?.Account?.Collection_Manager__r?.Email : intEmailToContactMap.get(cs.SuppliedEmail)?.Account?.Collection_Manager__r?.Email;
                        
                    }
                    system.debug('Check cs.ownerId: '+cs.ownerId);
                    if( System.Label.Financial_Query_RecordType_Id.containsIgnoreCase(cs.RecordTypeId) ){
                        csToUpdate = CTX_CaseValidations.financeQueriesCaseValidations(
                            csToUpdate, csToUpdate.Account_Collection_Manager__c, NULL
                        );
                    }
                    
                    if( System.Label.Internal_Case_RecordTypeId.containsIgnoreCase(cs.RecordTypeId) ){
                        csToUpdate = CTX_CaseValidations.internalIssuesCaseValidation(csToUpdate, caseEmail_DepartmentMap);
                    }
                    system.debug('AFTER Check cs.ownerId: '+csToUpdate.ownerId);
                    
                    if(
                        emailToContactMap.ContainsKey(cs.SuppliedEmail) &&
                        emailToContactMap.get(cs.SuppliedEmail).account.pgl_or_sb__c=='PGL' && 
                        cs.RecordTypeId ==Constants.eInvoicingRTId
                    ){
                        csToUpdate.OwnerId           = system.label.Priority_ENT_E_Invoice_L1_Team_QueueID;
                        csToUpdate.User_Role_Type__c = 'Priority ENT E Invoice L1 Team';
                        csToUpdate.Priority = 'P1';
                    }
                    else if(
                        cs.RecordTypeId ==Constants.eInvoicingRTId
                    ){
                        csToUpdate.OwnerId           = system.label.ENT_E_Invoice_L1_Team_Queue_ID;
                        csToUpdate.User_Role_Type__c = 'ENT E Invoice L1 Team';
                        csToUpdate.Priority = 'P1';
                    }
                    if(cs.RecordTypeId.equals(CaseConstants.INTERNATIONAL_RecordTypeId)){
                        if(intEmailToContactMap.containsKey(cs.SuppliedEmail)){
                            csToUpdate.ownerId           = intEmailToContactMap.get(cs.SuppliedEmail)?.account?.Onboarding_Owner__c == NULL ? system.label.International_L1_Queue : intEmailToContactMap.get(cs.SuppliedEmail).account.Onboarding_Owner__c;   
                        }
                        else{
                            csToUpdate.ownerId           = system.label.International_L1_Queue ; 
                        }
                        csToUpdate.User_Role_Type__c = 'GCC L2';
                    }
                    
                    if(
                        cs.RecordTypeId == Constants.b2bCASMERTId || 
                        cs.RecordTypeId == Constants.b2bEnterpriseRTId
                    ){
                        if(
                            (csToUpdate.AccountId == System.label.Global_Account  || 
                             csToUpdate.AccountId == System.label.GLOBAL_Account_B2B_CA_SME_for_Web_Form ||
                             csToUpdate.AccountId == System.label.Global_B2B_Account) && cs.Case_Sub_Origin__c  != 'Clear Capture form' && cs.User_Role_Type__c  != 'CA/SME Tax Cloud L1'
                        ){
                            if((System.Label.Call_Centre_Case_Email_Address.contains(cs.Owner_Email__c) ||
                                (cs.Web_Form_Submitter_Email__c != NULL &&
                                 System.Label.Call_Centre_Case_Email_Address.contains(cs.Web_Form_Submitter_Email__c))) &&
                               csToUpdate.Origin == 'Internal Web Form' 								&& 
                               csToUpdate.RecordtypeId == CaseConstants.B2B_CASME_RecordTypeId){
                                   csToUpdate.ownerId      = System.Label.GST_L2_Support_Team_QueueID;
                                   csToUpdate.User_Role_Type__c 	= 'GST L2 Support Team';
                                   csToUpdate.Priority 			= cs.Priority__c;
                               }else{
                                   csToUpdate.OwnerId				= System.label.GST_L1_Email_Support_Team_QueueID ;
                                   csToUpdate.User_Role_Type__c 	= 'GST L1 Email Support Team';
                                   csToUpdate.Priority 			= cs.Priority__c;
                               }
                            
                        } else if(
                            emailToContactMap.get(cs.SuppliedEmail).account.pgl_or_sb__c=='PGL' && 
                            !System.label.CA_SME_Tax_Cloud_L1_QueueId.Contains(cs.OwnerId) && 
                            !System.label.CA_SME_TDS_L1_QueueId.Contains(cs.OwnerId) &&
                            !cs.RecordTypeId.equals(CaseConstants.INTERNATIONAL_RecordTypeId)
                        ){
                            /**if(cs.Case_Sub_Origin__c  == 'Clear Capture form'){
csToUpdate.OwnerId='00G71000000Uvk1' ; 
csToUpdate.Priority= 'P0';
csToUpdate.User_Role_Type__c	= 'Priority Clear Capture L1 Support Team';
}
else{**/
                            if(System.label.Admin_Enterprise_Queue_Id.Contains(cs.OwnerId)){
                                csToUpdate.OwnerId				= System.label.Priority_Admin_Enterprise_Queue_Id;
                                csToUpdate.User_Role_Type__c	= 'Priority Admin Enterprise Queue';
                                csToUpdate.Priority 			= cs.Priority__c;
                            }
                            else{
                                csToUpdate.OwnerId				= System.label.Priority_ENT_GST_L1_Team_QueueID;
                                csToUpdate.Previous_Queue_Id__c = System.label.Priority_ENT_GST_L1_Team_QueueID;    
                                csToUpdate.User_Role_Type__c	= 'Priority ENT GST L1 Team';
                                csToUpdate.Priority 			= cs.Priority__c;
                            }
                            //}
                        }
                        
                        else if(
                            !System.label.CA_SME_Tax_Cloud_L1_QueueId.Contains(cs.OwnerId) && 
                            !System.label.CA_SME_TDS_L1_QueueId.Contains(cs.OwnerId) &&
                            !System.label.ENT_TDS_L1.Contains(cs.OwnerId) &&
                            !cs.RecordTypeId.equals(CaseConstants.INTERNATIONAL_RecordTypeId)
                        ){
                            /** if(cs.Case_Sub_Origin__c  == 'Clear Capture form'){
csToUpdate.OwnerId='00G71000000VxLZ' ; 
csToUpdate.Priority= 'P1';
csToUpdate.User_Role_Type__c	= 'Clear Capture L1 Support Team';
}
else{**/
                            if(System.label.Admin_Enterprise_Queue_Id.Contains(cs.OwnerId)){
                                csToUpdate.OwnerId				= System.label.Admin_Enterprise_Queue_Id;
                                csToUpdate.User_Role_Type__c	= 'Admin Enterprise Queue';
                                csToUpdate.Priority 			= cs.Priority__c;
                            }
                            else{
                                csToUpdate.OwnerId				= System.label.ENT_GST_L1_Team_CaseQueueId;
                                csToUpdate.User_Role_Type__c 	= 'ENT GST L1 Team';
                                csToUpdate.Previous_Queue_Id__c 	= System.label.ENT_GST_L1_Team_CaseQueueId;    
                                csToUpdate.Priority 			= cs.Priority__c;
                            }
                            // }
                        }
                        
                        
                    }
                    /** Tax Cloud Logic **/
                    if(System.label.CA_SME_Tax_Cloud_L1_QueueId.Contains(cs.OwnerId))
                    {
                        csToUpdate.User_Role_Type__c = 'CA/SME Tax Cloud L1';
                        System.debug('#Tax Cloud L1'+csToUpdate);
                        cs = updateRTAndEntitlement(csToUpdate);
                        csListToUpdate.add(csToUpdate); 
                        Continue;
                    }
                    if(System.label.CA_SME_TDS_L1_QueueId.Contains(cs.OwnerId))
                    {
                        csToUpdate.User_Role_Type__c    = 'CA/SME TDS L1';
                        csToUpdate.businessHoursId      = System.label.B2C_Business_Hours;
                        csToUpdate.Product_Type__c      = 'TDS';
                        csToUpdate.Priority 			= cs.Priority__c;
                        System.debug('#TDS L1'+csToUpdate);
                        cs = updateRTAndEntitlement(csToUpdate);
                        csListToUpdate.add(csToUpdate); 
                        Continue;
                    }
                    if(System.label.ENT_TDS_L1.Contains(cs.OwnerId))
                    {
                        csToUpdate.User_Role_Type__c     = 'ENT TDS L1';
                        csToUpdate.businessHoursId       = System.label.B2B_Business_Hours;
                        csToUpdate.Product_Type__c       = 'TDS';
                        csToUpdate.Priority 			 = cs.Priority__c;
                        System.debug('#TDS ENT L1'+csToUpdate);
                        cs = updateRTAndEntitlement(csToUpdate);
                        csListToUpdate.add(csToUpdate); 
                        Continue;
                    }
                    if(System.label.Clear_Identity_L2.Contains(cs.OwnerId))
                    {
                        csToUpdate.User_Role_Type__c = 'Clear Identity L2';
                        System.debug('#Clear Identity L2'+csToUpdate);
                        csToUpdate = updateRTAndEntitlement(csToUpdate);
                        csListToUpdate.add(csToUpdate); 
                        Continue;
                    }
                    if(System.label.ENT_Clear_Capture_L2_Team.Contains(cs.OwnerId))
                    {
                        csToUpdate.User_Role_Type__c = 'ENT Clear Capture L2 Team';
                        System.debug('#ENT Clear Capture L2 Team'+csToUpdate);
                        csToUpdate = updateRTAndEntitlement(csToUpdate);
                        csListToUpdate.add(csToUpdate); 
                        Continue;
                    }
                    if(System.label.ENT_Clear_Invoice_L2 .Contains(cs.OwnerId))
                    {
                        csToUpdate.User_Role_Type__c = 'ENT Clear Invoice L2 Team';
                        System.debug('#ENT Clear Invoice L2'+csToUpdate);
                        csToUpdate = updateRTAndEntitlement(csToUpdate);
                        csListToUpdate.add(csToUpdate); 
                        Continue;
                    }
                    if(System.label.MaxITC_Queue_Id.Contains(cs.OwnerId))
                    {
                        csToUpdate.User_Role_Type__c = 'MaxITC - L2';
                        System.debug('#Max L2'+csToUpdate);
                        csToUpdate = updateRTAndEntitlement(csToUpdate);
                        csListToUpdate.add(csToUpdate); 
                        Continue;
                    }
                    
                    system.debug('csToUpdate Line 689---->'+csToUpdate);
                    if(
                        queueid_QueueName_Map.containsKey(cs.OwnerId) && 
                        queueid_QueueName_Map.get(cs.OwnerId).Name.contains('On Call Team')
                    ){
                        csToUpdate.Queue_Distribution_mail__c 
                            = Queue_DistributionMap.containsKey(cs.POD_Group__c) ? Queue_DistributionMap.get(cs.POD_Group__c) : NULL;
                    } else if(
                        csToUpdate.OwnerId != NULL
                    ){
                        csToUpdate.Queue_Distribution_mail__c 
                            = Queue_DistributionMap.containsKey(cs.OwnerId) ? Queue_DistributionMap.get(cs.OwnerId) : NULL;
                    }
                    csToUpdate = updateRTAndEntitlement(csToUpdate);
                    csToUpdate = CTX_CaseValidations.CaseKeywordMining(csToUpdate);
                    csListToUpdate.add(csToUpdate);
                    Continue;
                }
            }
            //International Logic
            else if(intEmailToContactMap.containsKey(cs.SuppliedEmail) && cs.RecordTypeId.equals(caseConstants.INTERNATIONAL_RecordTypeId)){
                Case csToUpdate								= cs.clone(FALSE, FALSE, FALSE, FALSE);
                csToUpdate.Id 								= cs.Id;
                csToUpdate.ContactId 						= intEmailToContactMap.get(cs.SuppliedEmail).Id;
                csToUpdate.AccountId 						= intEmailToContactMap.get(cs.SuppliedEmail).AccountId;
                csToUpdate.Account_Collection_Manager__c	= intEmailToContactMap.get(cs.SuppliedEmail).Account.Collection_Manager__c;
                
                if(intEmailToContactMap.get(cs.SuppliedEmail).Account.Collection_Manager__c != NULL){
                    csToUpdate.Account_Collection_Manager_Email__c 
                        = intEmailToContactMap.get(cs.SuppliedEmail).Account.Collection_Manager__r.Email;
                }
                system.debug('Check cs.ownerId: '+cs.ownerId);
                
                system.debug('AFTER Check cs.ownerId: '+csToUpdate.ownerId);
                if(csToUpdate.RecordTypeId.equals(CaseConstants.INTERNATIONAL_RecordTypeId)){
                    
                    csToUpdate.ownerId           = intEmailToContactMap.get(cs.SuppliedEmail)?.account?.Onboarding_Owner__c == NULL ? system.label.International_L1_Queue : intEmailToContactMap.get(cs.SuppliedEmail).account.Onboarding_Owner__c; 
                    csToUpdate.User_Role_Type__c = 'GCC L2';
                }
                
                csToUpdate = updateRTAndEntitlement(csToUpdate);
                csListToUpdate.add(csToUpdate); 
                Continue;
            }
            //International Logic
            
            
            caseMapForDomain.put(cs.Id, cs);
            
            
            
        }
        
        if( !csListToUpdate.isEmpty() ){
            system.debug('CaseInsAfterDML1'+csListToUpdate[0].ownerId);
            system.debug('CaseInsAfterDML1'+csListToUpdate[0].accountId);
            Update(csListToUpdate);
            system.debug('CaseInsAfterDML2'+[SELECT ownerId,Id from case where id =: csListToUpdate[0].Id Limit 1].OwnerId);
            
            
        }
        
        if(!caseMapForDomain.isEmpty()){
            accList = [Select Id, Name, Company_Domain_Name__c, pgl_or_sb__c,recordtype.developername From Account Where Company_Domain_Name__c != null Order By CreatedDate DESC];
            /**for(Account acc : accList){
if(acc.recordtype.developername.equals(CaseConstants.Case_RECORDTYPENAME_International)){
intAccList.add(acc);
}
}**/
        }
        
        Map<String, List<Account>> emailDomainToAccListMap = new Map<String, List<Account>>();
        if(!accList.isEmpty()){
            for(Account acc : accList){
                for(String str : acc.Company_Domain_Name__c.trim().split(',')){
                    if(emailDomainToAccListMap.isEmpty() || !emailDomainToAccListMap.containsKey(str.trim())){
                        emailDomainToAccListMap.put(str.trim(), new List<Account>{acc});
                    }
                    else{
                        emailDomainToAccListMap.get(str.trim()).add(acc); 
                    }
                }
                mapOfAccIdtoPSGorSBL.put(acc.id,acc.pgl_or_sb__c);
            }
            
        }
        system.debug('****emailDomainToAccListMap-->'+emailDomainToAccListMap);
        Map<Id, Contact> caseIdToContactMap = new Map<Id, Contact>();
        
        
        if(!caseMapForDomain.isEmpty() && !emailDomainToAccListMap.isEmpty()){
            for(Case thisCSForDomainCheck : caseMapForDomain.values()){
                Id locAccountId;
                If(thisCSForDomainCheck.AccountId != NULL){
                    locAccountId = thisCSForDomainCheck.AccountId;
                }
                if(thisCSForDomainCheck.RecordTypeId != CaseConstants.INTERNATIONAL_RecordTypeId || !intEmailToContactMap.containsKey(thisCSForDomainCheck.SuppliedEmail)){
                    String em = thisCSForDomainCheck.SuppliedEmail.substringAfter('@');
                    system.debug('****em-->'+em);
                    system.debug('****in 1');
                    if(emailDomainToAccListMap.containsKey(em) && !emailDomainToAccListMap.isEmpty()){
                        system.debug('****in 2');
                        Contact con = new Contact();
                        con.Email = thisCSForDomainCheck.SuppliedEmail;
                        con.LastName = String.ISBLANK(thisCSForDomainCheck.SuppliedName) ? thisCSForDomainCheck.SuppliedEmail : thisCSForDomainCheck.SuppliedName;
                        if(locAccountId == NULL){
                            con.AccountId =  thisCSForDomainCheck.RecordTypeId==Constants.interantionalRTId /**&& emailDomainToAccListMap.get(em)[0].recordtype.developerName==AccountConstants.INTERNATIONAL_RECORDTYPE**/? emailDomainToAccListMap.get(em)[0].Id:
                            thisCSForDomainCheck.RecordTypeId!=Constants.interantionalRTId /**&& emailDomainToAccListMap.get(em)[0].recordtype.developerName!=AccountConstants.INTERNATIONAL_RECORDTYPE**/? emailDomainToAccListMap.get(em)[0].Id :System.label.New_Global_International_Account; 
                        }
                        else
                        {
                            con.AccountId = locAccountId;  
                        }
                        if(emailDomainToAccListMap.get(em).size()> 1){
                            MultipleAccount.add(thisCSForDomainCheck.Id);
                        }
                        if(con.AccountId !=null){
                            caseIdToContactMap.put(thisCSForDomainCheck.Id, con); 
                        }
                    }
                    else if(!emailDomainToAccListMap.containsKey(em)){
                        system.debug('suppliedEmail'+thisCSForDomainCheck.SuppliedEmail);
                        system.debug('suppliedEmail'+thisCSForDomainCheck.SuppliedName);
                        Contact con = new Contact();
                        con.Email = thisCSForDomainCheck.SuppliedEmail;
                        con.LastName = String.ISBLANK(thisCSForDomainCheck.SuppliedName) ? thisCSForDomainCheck.SuppliedEmail : thisCSForDomainCheck.SuppliedName;
                        
                        if(thisCSForDomainCheck.RecordTypeId == caseConstants.CLEAR_IDENTITY_RecordTypeId || thisCSForDomainCheck.RecordTypeId == caseConstants.MAX_ITC_RecordTypeId ||
                           thisCSForDomainCheck.RecordTypeId == caseConstants.CLEAR_INVOICE_RecordTypeId || thisCSForDomainCheck.RecordTypeId == caseConstants.CLEAR_CAPTURE_RecordTypeId
                          ){
                              if(locAccountId == NULL){
                                  con.AccountId = System.label.GLOBAL_Account_Clear_Identity;
                              }
                              else
                              {
                                  con.AccountId = locAccountId;  
                              }
                          }
                        if(locAccountId == NULL){
                            con.AccountId = thisCSForDomainCheck.RecordTypeId ==Constants.interantionalRTId?System.label.New_Global_International_Account:System.label.Global_Account;
                        }
                        {
                            con.AccountId = locAccountId;  
                        }
                        
                        caseIdToContactMap.put(thisCSForDomainCheck.Id, con); 
                    }
                } 
            }
        }
        
        if(!caseIdToContactMap.isEmpty()){
            insert caseIdToContactMap.values();
            for(String caseId : caseIdToContactMap.keyset()){
                Case csToupdate = caseMapForDomain.get(caseId).Clone(FALSE,FALSE,FALSE,FALSE);
                csToupdate.Id = caseId;
                csToupdate.ContactId = caseIdToContactMap.get(caseId).Id;
                csToupdate.AccountId = caseIdToContactMap.get(caseId).AccountId;
                if(MultipleAccount.contains(caseid)){
                    csToupdate.isMultiple_Account__c=true;
                }
                system.debug('***mapOfAccIdtoPSGorSBL'+mapOfAccIdtoPSGorSBL.get(csToupdate.AccountId));
                if(mapOfAccIdtoPSGorSBL.get(csToupdate.AccountId)=='PGL' && caseMapForDomain.get(caseId).RecordTypeId ==Constants.eInvoicingRTId){
                    csToupdate.OwnerId=System.label.Priority_ENT_E_Invoice_L1_Team_QueueID;
                    csToUpdate.User_Role_Type__c = 'Priority ENT E Invoice L1 Team';
                    csToUpdate.Priority = 'P1';
                }
                else if(caseMapForDomain.get(caseId).RecordTypeId ==Constants.eInvoicingRTId){
                    csToupdate.OwnerId=System.label.ENT_E_Invoice_L1_Team_Queue_Id;
                    csToUpdate.User_Role_Type__c = 'ENT E Invoice L1 Team';
                    csToUpdate.Priority = 'P1';
                }
                else if(caseMapForDomain.containsKey(caseId) && (caseMapForDomain.get(caseId).RecordTypeId == Constants.b2bCASMERTId || caseMapForDomain.get(caseId).RecordTypeId == Constants.b2bEnterpriseRTId || caseMapForDomain.get(caseId).RecordTypeId == CaseConstants.INTERNATIONAL_RecordTypeId) && !System.label.CA_SME_Tax_Cloud_L1_QueueId.Contains(caseMapForDomain.get(caseId).OwnerId) )
                { 
                    if((csToUpdate.AccountId==System.label.Global_Account && caseMapForDomain.get(caseId).Case_Sub_Origin__c  != 'Clear Capture form') || (caseMapForDomain.get(caseId).Case_Sub_Origin__c == 'GST Web Form' && CaseConstants.team1 == 'B2B CA/SME')
                      ){
                          system.debug('caseUserRoleType:'+caseMapForDomain.get(caseId).ownerId);
                          /** if(caseMapForDomain.get(caseId).Case_Sub_Origin__c  == 'Clear Capture form'){
csToUpdate.OwnerId='00G71000000VxLZ' ; 
csToUpdate.Priority= 'P1';
csToUpdate.User_Role_Type__c	= 'Clear Capture L1 Support Team';
}
else{**/ 					
                          //Reassign queue to GST_L2_Email_Support_Team_QueueID - Case Form 
                          if((System.Label.Call_Centre_Case_Email_Address.contains(csToUpdate.Owner_Email__c) ||
                              (csToUpdate.Web_Form_Submitter_Email__c != NULL &&
                               System.Label.Call_Centre_Case_Email_Address.contains(csToUpdate.Web_Form_Submitter_Email__c))) &&
                             csToUpdate.Origin == 'Internal Web Form' 									  	 && 
                             csToUpdate.RecordtypeId == CaseConstants.B2B_CASME_RecordTypeId){
                                 csToUpdate.ownerId      = System.Label.GST_L2_Support_Team_QueueID;
                                 csToUpdate.User_Role_Type__c 	= 'GST L2 Support Team';
                                 csToUpdate.Priority = caseMapForDomain.get(caseId).Priority__c;
                             }else{
                                 csToUpdate.OwnerId=System.label.GST_L1_Email_Support_Team_QueueID ;
                                 csToUpdate.User_Role_Type__c = 'GST L1 Email Support Team';
                                 csToUpdate.Priority = caseMapForDomain.get(caseId).Priority__c;
                             }
                      }
                    else if(mapOfAccIdtoPSGorSBL.get(csToupdate.AccountId)=='PGL' && CaseConstants.team1 != 'B2B CA/SME' ){
                        /** if(caseMapForDomain.get(caseId).Case_Sub_Origin__c  == 'Clear Capture form'){
csToUpdate.OwnerId='00G71000000Uvk1' ; 
csToUpdate.Priority= 'P1';
csToUpdate.User_Role_Type__c	= 'Priority Clear Capture L1 Support Team';
}
else{**/
                        csToupdate.OwnerId=system.label.Priority_ENT_GST_L1_Team_QueueID;
                        csToUpdate.User_Role_Type__c = 'Priority ENT GST L1 Team';
                        csToUpdate.Priority = caseMapForDomain.get(caseId).Priority__c;
                        // }
                    }
                    else if(CaseConstants.team1 != 'B2B CA/SME' ){
                        csToupdate.OwnerId=System.label.ENT_GST_L1_Team_CaseQueueId;
                        csToUpdate.User_Role_Type__c = 'ENT GST L1 Team';
                        csToUpdate.Priority = caseMapForDomain.get(caseId).Priority__c;
                    }
                    if(csToUpdate.RecordTypeId.equals(CaseConstants.INTERNATIONAL_RecordTypeId)){
                        if(intEmailToContactMap.containsKey(csToUpdate.SuppliedEmail)){
                            csToUpdate.ownerId           = intEmailToContactMap.get(csToUpdate.SuppliedEmail)?.account?.Onboarding_Owner__c == NULL ? system.label.International_L1_Queue : intEmailToContactMap.get(csToUpdate.SuppliedEmail).account.Onboarding_Owner__c;   
                        }else{
                            csToUpdate.ownerId           = system.label.International_L1_Queue ; 
                        }
                        csToUpdate.User_Role_Type__c = 'GCC L2';
                    }
                    
                    
                }
                else if(System.label.CA_SME_Tax_Cloud_L1_QueueId.Contains(caseMapForDomain.get(caseId).OwnerId)){
                    csToupdate.OwnerId=system.label.CA_SME_Tax_Cloud_L1_QueueId;
                    csToUpdate.User_Role_Type__c = 'CA/SME Tax Cloud L1';
                    csToUpdate.Priority = caseMapForDomain.get(caseId).Priority__c;
                }
                system.debug('caseMapForDomain.get(caseId) 790 Line---->'+caseMapForDomain.get(caseId));
                if(queueid_QueueName_Map.containsKey(csToupdate.OwnerId) && queueid_QueueName_Map.get(csToupdate.OwnerId).Name.contains('On Call Team')){
                    csToupdate.Queue_Distribution_mail__c=Queue_DistributionMap.containsKey(csToupdate.POD_Group__c)?Queue_DistributionMap.get(csToupdate.POD_Group__c):null;
                }else if(csToupdate.OwnerId !=null){
                    csToupdate.Queue_Distribution_mail__c=Queue_DistributionMap.containsKey(csToupdate.OwnerId)?Queue_DistributionMap.get(csToupdate.OwnerId):null;
                }
                csToUpdate = updateRTAndEntitlement(csToUpdate);
                caseListToUpdate.add(csToupdate);
            }
        }
        
        
        system.debug('****caseListToUpdate-->'+caseListToUpdate);
        if(!caseListToUpdate.isEmpty()){
            Update(caseListToUpdate);
        }
    }
    
    
    public static void UpdateOwnerIdBasedOnAccPGLorSBL(Map<String, list<case>> mapOfAccIdToCaseId){  //@sunil
        list<case> caselistToUpdateOwner=new list<case>();
        List<String> globalAccountsList = new List<String>();
        globalAccountsList.add(System.label.GLOBAL_Account_B2B_for_Web_Form);
        globalAccountsList.add(System.label.Global_Account);
        globalAccountsList.add(System.label.GLOBAL_Account_B2B_CA_SME_for_Web_Form);
        globalAccountsList.add(System.label.Global_B2B_Account);
        
        list<account>  accList = [Select Id, Name, Company_Domain_Name__c, pgl_or_sb__c From Account where id=:mapOfAccIdToCaseId.keySet() ];
        for(account ac:accList){
            for(case cs: mapOfAccIdToCaseId.get(ac.id)){
                case css = new case();
                css.Id = cs.Id;
                if(cs.RecordTypeId == Constants.eInvoicingRTId){
                    if(ac.pgl_or_sb__c == 'PGL'){
                        css.OwnerId = System.label.Priority_ENT_E_Invoice_L1_Team_QueueID;                        
                    }
                    else{
                        css.OwnerId = System.label.ENT_E_Invoice_L1_Team_Queue_Id;
                    }
                }
                if((cs.RecordTypeId==Constants.b2bCASMERTId || cs.RecordTypeId == Constants.b2bEnterpriseRTId) && !globalAccountsList.contains(ac.Id)){
                    if(ac.pgl_or_sb__c == 'PGL' && !System.label.CA_SME_Tax_Cloud_L1_QueueId.Contains(cs.OwnerId) && !System.label.CA_SME_TDS_L1_QueueId.Contains(cs.OwnerId) && !System.label.ENT_TDS_L1.Contains(cs.OwnerId)
                      ){
                          /** if(cs.Case_Sub_Origin__c  == 'Clear Capture form'){
css.OwnerId='00G71000000Uvk1' ;  
}
else{**/
                          css.OwnerId = System.label.Priority_ENT_GST_L1_Team_QueueID;
                          //}
                      }
                    else if(!System.label.CA_SME_Tax_Cloud_L1_QueueId.Contains(cs.OwnerId) && !System.label.CA_SME_TDS_L1_QueueId.Contains(cs.OwnerId) && !System.label.ENT_TDS_L1.Contains(cs.OwnerId)){
                        /**if(cs.Case_Sub_Origin__c  == 'Clear Capture form'){
css.OwnerId='00G71000000VxLZ' ;  
}
else{**/
                        css.OwnerId=System.label.ENT_GST_L1_Team_CaseQueueId;
                        // }
                    }
                }
                caselistToUpdateOwner.add(css);
            }
        }
        if(!caselistToUpdateOwner.isEmpty()){
            update caselistToUpdateOwner;
        }
    }
    @InvocableMethod 
    public static void stopTimeWhernSolved(List<Id> caseIdList) {
        Set<Id> caseIdSet = new Set<Id>(caseIdList);
        StopCustomerWaitTimeWhenCaseSolved(caseIdSet);
        CompletePeriodicUpdateMilestone(caseIdSet);
    }
    
    public static void CompleteFRTMilestone(set<id> caseIds){
        List<Case> listOfCases=new List<Case>();
        List<CaseMilestone> listOfCaseMilestones=new List<CaseMilestone>();
        if(caseIds.size()>0){
            listOfCaseMilestones= CaseMilestoneSelector.getCaseMilestonesByCaseIds(caseIds);
        }
        
        for(CaseMilestone cm:listOfCaseMilestones){
            if(cm.MilestoneType.Name.containsIgnoreCase('First reply time') && cm.IsCompleted == False){
                if(cm.CompletionDate == null ){
                    cm.CompletionDate=System.now();
                }
            }
        }
        
        if(listOfCaseMilestones.size()>0){
            try{
                List<DataBase.SaveResult> resultAfterUpdateEventOnCaseMilestone= DataBase.update(listOfCaseMilestones);
            }Catch(Exception ex){
                System.debug(' <----Exception on Case Update-----> \n'+ex.getMessage()+'\n'+ex.getLineNumber());
            }
        }        
    }
    
    public static void CompletePeriodicUpdateMilestone(set<id> caseIds){
        List<Case> listOfCases=new List<Case>();
        List<CaseMilestone> listOfCaseMilestones=new List<CaseMilestone>();
        if(caseIds.size()>0){
            listOfCaseMilestones= CaseMilestoneSelector.getCaseMilestonesByCaseIds(caseIds);
        }
        for(CaseMilestone cm:listOfCaseMilestones){
            Case caseInstance=new Case();
            caseInstance.id=cm.CaseId;
            if(cm.MilestoneType.Name.containsIgnoreCase('First reply time') && cm.IsCompleted == False){
                if(cm.CompletionDate == null ){
                    cm.CompletionDate=System.now();
                }
            }
            if(cm.MilestoneType.Name.containsIgnoreCase('Periodic update') && cm.IsCompleted == False ){
                System.debug('<---------Periodic update----------->');
                if(cm.CompletionDate == null ){
                    cm.CompletionDate=System.now();
                    caseInstance.Last_update_Sent__c=  System.now(); 
                    System.debug('caseInstance.Last_update_Sent__c'+caseInstance.Last_update_Sent__c);
                }
                listOfCases.add(caseInstance);
            }
            
        }
        
        if(listOfCases.size()>0){
            try{
                List<DataBase.SaveResult> resultAfterUpdateEventOnCase= DataBase.update(listOfCases);
            }Catch(Exception ex){
                System.debug(' <----Exception on Case Update-----> \n'+ex.getMessage()+'\n'+ex.getLineNumber());
            }
        } 
        if(listOfCaseMilestones.size()>0){
            try{
                List<DataBase.SaveResult> resultAfterUpdateEventOnCaseMilestone= DataBase.update(listOfCaseMilestones);
            }Catch(Exception ex){
                System.debug(' <----Exception on Case milestone Update-----> \n'+ex.getMessage()+'\n'+ex.getLineNumber());
            }
        } 
    }
    public static void StopCustomerWaitTimeWhenCaseSolved(set<id> caseId){
        List<case> caseListToUpdate= new list<case>();
        for(Id csid: caseId){
            Case caseInstance=new Case();
            caseInstance.Id=csid;
            caseInstance.IsStopped=true;
            caseListToUpdate.add(caseInstance);
        }
        
        if(!caseListToUpdate.isEmpty()){
            update caseListToUpdate; 
        }
    }
    
    public static Case StopCustomerWaitTimeWhenCaseSolved1(case caseInstance){
        Case caseInsLoc = caseInstance.Clone(FALSE,FALSE,FALSE,FALSE);
        caseInsLoc.Id = caseInstance.Id;
        caseInsLoc.IsStopped=true;
        return caseInstance;
    }
    
    
    public static void BeforeStopCustomerWaitTimeWhenCaseClosed(set<id> caseId){
        List<case> caseListToUpdate= new list<case>();
        for(Id csid: caseId){
            Case caseInstance=new Case();
            caseInstance.Id=csid;
            caseInstance.IsStopped=false;
            caseListToUpdate.add(caseInstance);
        }
    }
    
    
    public static void StopCustomerWaitTimeWhenCaseClosed(set<id> caseId){
        List<case> caseListToUpdate= new list<case>();
        for(Id csid: caseId){
            Case caseInstance=new Case();
            caseInstance.Id=csid;
            caseInstance.IsStopped=false;
            caseListToUpdate.add(caseInstance);
        }
        
        if(!caseListToUpdate.isEmpty()){
            update caseListToUpdate; 
        }
    }
    
    public static void CompleteCustomerWaitTimeMilestone(set<id> caseIds){
        caseConstants.completionCheck = TRUE;
        List<Case> listOfCases=new List<Case>();
        List<CaseMilestone> listOfCaseMilestones=new List<CaseMilestone>();
        map<Id,CaseMilestone> caseMilestoneMap = new map<Id,CaseMilestone>();
        if(caseIds.size()>0){
            listOfCaseMilestones= CaseMilestoneSelector.getCaseMilestonesByCaseIds(caseIds);
        }
        for(CaseMilestone cm:listOfCaseMilestones){
            if(cm.MilestoneType.Name.containsIgnoreCase('Customer wait time') && cm.IsCompleted == False){
                if(cm.CompletionDate == null ){
                    cm.CompletionDate=system.now();
                    //cm.CompletionDate=cm.StartDate.addMinutes(cm.ActualElapsedTimeInMins);
                }  
            }
        }
        
        
        try{
            if(listOfCaseMilestones.size()>0){
                
                List<DataBase.SaveResult> resultAfterUpdateEventOnCaseMilestone= DataBase.update(listOfCaseMilestones);
                if(caseIds.size()>0){
                    listOfCaseMilestones= CaseMilestoneSelector.getCaseMilestonesByCaseIds(caseIds);
                }
                for(CaseMilestone cm:listOfCaseMilestones){
                    if(cm.MilestoneType.Name.containsIgnoreCase('Customer wait time') ){
                        // cm.CompletionDate=system.now();
                        cm.CompletionDate=cm.StartDate.addMinutes(cm.ActualElapsedTimeInMins);
                        caseMilestoneMap.put(cm.caseId,cm);
                    }
                }
                
                List<DataBase.SaveResult> resultAfterUpdateEventOnCaseMilestone2= DataBase.update(listOfCaseMilestones);
            }           
            List<case> caseListToUpdate= new list<case>();
            
            for(Id csid: caseIds){
                Case caseInstance=new Case();
                caseInstance.Id = csid;
                if(caseMilestoneMap.get(csid).ActualElapsedTimeInMins > caseMilestoneMap.get(csid).TargetResponseInMins){
                    caseInstance.violated__c = true;  
                }
                caseInstance.SLA_Target_Actual__c  = String.ValueOf(caseMilestoneMap.get(csid).TargetResponseInMins - caseMilestoneMap.get(csid).ActualElapsedTimeInMins);
                caseListToUpdate.add(caseInstance);
            }
            
            if(!caseListToUpdate.isEmpty()){
                update caseListToUpdate; 
            }
        }Catch(Exception ex){
            System.debug(' <----Exception on Case milestone Update-----> \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
        
    }
    public static Case autoRespondManualCases( Case caseInstance2, Account thisAccount ){
        
        system.debug('caseInstance2.Account_CSM_Email__c: '+caseInstance2.Account_CSM_Email__c);
        
        List<Messaging.SingleEmailMessage> listOfMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        List<Org_wide_and_Email_Template_Mapping__mdt> listOfOrgwideandEmailTemplateMappings=new List<Org_wide_and_Email_Template_Mapping__mdt>();
        listOfOrgwideandEmailTemplateMappings=DataBase.query(UtilityClass.getQueryString('Org_wide_and_Email_Template_Mapping__mdt')+' FROM Org_wide_and_Email_Template_Mapping__mdt ');
        Map<String,Org_wide_and_Email_Template_Mapping__mdt> mapOfOrgwideandEmailTemplateMappings=new  Map<String,Org_wide_and_Email_Template_Mapping__mdt>();
        Map<String,Org_wide_and_Email_Template_Mapping__mdt> recordTypeToOTMMap = new  Map<String,Org_wide_and_Email_Template_Mapping__mdt>();
        Set<Id> setofOrgWiderIds = new Set<Id>();
        Set<Id> setofEmailTemplateIds = new Set<Id>();
        List<Case> caseListToUpdate = new List<Case>();
        
        for(Org_wide_and_Email_Template_Mapping__mdt otm : listOfOrgwideandEmailTemplateMappings){
            if(!String.isEmpty(otm.RecordType__c)){
                for(String str : otm.RecordType__c.trim().split(',')){
                    recordTypeToOTMMap.put(str.trim(), otm);
                }
            }
        }
        
        setofOrgWiderIds.add(recordTypeToOTMMap.get(caseInstance2?.RecordTypeId)?.Org_Wide_Email_Id__c);
        setofEmailTemplateIds.add(recordTypeToOTMMap.get(caseInstance2?.RecordTypeId)?.Email_Template_Id__c);
        
        Map<Id,OrgWideEmailAddress> mapOforgWideEmailAddressInstance  = new Map<Id,OrgWideEmailAddress>([SELECT Id, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, Address, DisplayName, IsAllowAllProfiles FROM OrgWideEmailAddress WHERE Id IN:setofOrgWiderIds]);
        Map<Id,emailTemplate>  mapOfemailTemplateInstanc = new Map<Id,emailTemplate>([Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Id IN: setofEmailTemplateIds]);
        system.debug('mapOforgWideEmailAddressInstance'+mapOforgWideEmailAddressInstance);
        caseInstance2.put('Auto_Response_Sent__c',TRUE);
        system.debug('recordTypeToOTMMap '+recordTypeToOTMMap.containsKey(caseInstance2.RecordTypeId));
        if(recordTypeToOTMMap.containsKey(caseInstance2.RecordTypeId)){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(mapOfemailTemplateInstanc.get(recordTypeToOTMMap.get(caseInstance2.RecordTypeId).Email_Template_Id__c).Id);
            email.setOrgWideEmailAddressId(mapOforgWideEmailAddressInstance.get(recordTypeToOTMMap.get(caseInstance2.RecordTypeId).Org_Wide_Email_Id__c).Id);
            system.debug('mapOforgWideEmailAddressInstance.get(recordTypeToOTMMap.get(caseInstance2.RecordTypeId).Org_Wide_Email_Id__c).Id'+mapOforgWideEmailAddressInstance.get(recordTypeToOTMMap.get(caseInstance2.RecordTypeId).Org_Wide_Email_Id__c).Id);
            // email.setSubject('test');
            // email.setHTMLBody('test email');
            List<String> exclusionList = System.Label.Email_Exclusion_CaseAck.split(';');
            system.debug('thisAccount in case'+thisAccount);
            system.debug('caseInstance2.ContactEmail'+caseInstance2.ContactEmail);
            System.debug('#emailList'+new List<String>{caseInstance2.SuppliedEmail});
            if(!exclusionList.contains(caseInstance2.ContactEmail)){
                email.setToAddresses(new List<String>{caseInstance2.ContactEmail});  
            }
            email.setSaveAsActivity(true);
            system.debug('thisAccount in case'+thisAccount);
            system.debug('caseInstance2'+caseInstance2);
            system.debug('caseInstance2.ContactId'+caseInstance2.ContactId);
            system.debug('caseInstance2.Account_CSM_Email__c'+caseInstance2.Account_CSM_Email__c);
            //  system.debug('thisAccount Onboarding_Owner__r in case'+thisAccount.Onboarding_Owner__r.Email);
            email.setTargetObjectId(caseInstance2.ContactId);
            
            //email.setCcAddresses();
            
            if( thisAccount != NULL && thisAccount.Onboarding_Owner__r.Email != NULL ){
                system.debug('inside if');
                email.setCcAddresses( new List<String>{ caseInstance2.Account_CSM_Email__c } );
                email.setBCCAddresses( new List<String>{ caseInstance2.Account_CSM_Email__c });
            } else{
                system.debug('inside else');
                email.setCcAddresses( new List<String>{} );
                email.setBCCAddresses( new List<String>{});
            }
            
            email.setWhatId(caseInstance2.Id);
            system.debug('email to send'+email);
            listOfMessagingSingleEmailMessage.add(email);
        }
        system.debug('listOfMessagingSingleEmailMessage'+listOfMessagingSingleEmailMessage);
        if(!listOfMessagingSingleEmailMessage.isEmpty()){
            Messaging.SendEmailResult[] msgResult = Messaging.sendEmail(listOfMessagingSingleEmailMessage,false);
            System.debug('****msgResult in after insert'+msgResult);
            
        }
        return caseInstance2;
    }
    public static void autoRespondManualCasesafterUpdate( Map<Id, Case> caseMap, Map<Id, Account> accountMap ){
        List<Messaging.SingleEmailMessage> listOfMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        List<Org_wide_and_Email_Template_Mapping__mdt> listOfOrgwideandEmailTemplateMappings=new List<Org_wide_and_Email_Template_Mapping__mdt>();
        listOfOrgwideandEmailTemplateMappings=DataBase.query(UtilityClass.getQueryString('Org_wide_and_Email_Template_Mapping__mdt')+' FROM Org_wide_and_Email_Template_Mapping__mdt ');
        Map<String,Org_wide_and_Email_Template_Mapping__mdt> mapOfOrgwideandEmailTemplateMappings=new  Map<String,Org_wide_and_Email_Template_Mapping__mdt>();
        Map<String,Org_wide_and_Email_Template_Mapping__mdt> recordTypeToOTMMap = new  Map<String,Org_wide_and_Email_Template_Mapping__mdt>();
        Set<Id> setofOrgWiderIds = new Set<Id>();
        Set<Id> setofEmailTemplateIds = new Set<Id>();
        List<Case> caseListToUpdate = new List<Case>();
        set<string> ToAddressesSet = new set<string>();
        system.debug('case map'+caseMap);
        for(Org_wide_and_Email_Template_Mapping__mdt otm : listOfOrgwideandEmailTemplateMappings){
            if(!String.isEmpty(otm.RecordType__c)){
                for(String str : otm.RecordType__c.trim().split(',')){
                    recordTypeToOTMMap.put(str.trim(), otm);
                }
            }
        }
        if(!caseMap.isEmpty()){
            for(Case caseInstance : caseMap.values()){
                setofOrgWiderIds.add(recordTypeToOTMMap.get(caseInstance?.RecordTypeId)?.Org_Wide_Email_Id__c);
                setofEmailTemplateIds.add(recordTypeToOTMMap.get(caseInstance?.RecordTypeId)?.Email_Template_Id__c);
            }
        }
        Map<Id,OrgWideEmailAddress> mapOforgWideEmailAddressInstance  = new Map<Id,OrgWideEmailAddress>([SELECT Id, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, Address, DisplayName, IsAllowAllProfiles FROM OrgWideEmailAddress WHERE Id IN:setofOrgWiderIds]);
        Map<Id,emailTemplate>  mapOfemailTemplateInstanc = new Map<Id,emailTemplate>([Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Id IN: setofEmailTemplateIds]);
        
        for(Case cs : caseMap.values()){
            system.debug('case cs'+cs);
            Case csToUpdate = new Case();
            csToUpdate.Id = cs.Id;
            csToUpdate.Auto_Response_Sent_To_CC__c  = true;
            if(recordTypeToOTMMap.containsKey(cs.RecordTypeId)){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(mapOfemailTemplateInstanc.get(recordTypeToOTMMap.get(cs.RecordTypeId).Email_Template_Id__c).Id);
                email.setOrgWideEmailAddressId(mapOforgWideEmailAddressInstance.get(recordTypeToOTMMap.get(cs.RecordTypeId).Org_Wide_Email_Id__c).Id);
                system.debug('org value--->'+mapOforgWideEmailAddressInstance.get(recordTypeToOTMMap.get(cs.RecordTypeId).Org_Wide_Email_Id__c).Id);
                email.setSaveAsActivity(true);
                email.setTargetObjectId(cs.ContactId);
                List<String> ccEmailAddressList = new List<String>();
                if(cs.CCEmailAddress__c.Contains(';')){
                    ccEmailAddressList = cs.CCEmailAddress__c.split(';');
                }
                else
                {
                    ccEmailAddressList = cs.CCEmailAddress__c.split(',');
                }
                
                for(string emailIds:ccEmailAddressList){
                    
                    List<String> exclusionList = System.Label.Email_Exclusion_Email_To_Case.split(';');
                    
                    if( 
                        !exclusionList.contains(emailIds.replaceAll('(\\s+)', '')) &&
                        emailIds.trim() !='null' &&  !emailIds.contains('support') && 
                        !emailIds.contains('crisp')
                    ){
                        ToAddressesSet.add(emailIds.replaceAll('(\\s+)', ''));
                    }
                    
                }
                List<string> listAddress=new List<String>();
                system.debug('ToAddressesSet===>'+ToAddressesSet);
                listAddress.addall(ToAddressesSet);
                email.setToAddresses(listAddress);
                system.debug('csToUpdate.AccountId'+cs.AccountId);
                system.debug('accountMap'+accountMap);
                system.debug('accountMap.get(cs.AccountId)'+accountMap.get(cs.AccountId));
                system.debug('accountMap.get(cs.AccountId).Onboarding_Owner__r.Email'+accountMap.get(cs.AccountId).Onboarding_Owner__r.Email);
                system.debug('check if 2 '+( 
                    cs.AccountId != NULL && 
                    accountMap.get(cs.AccountId) != NULL  && 
                    accountMap.get(cs.AccountId).Onboarding_Owner__r.Email != NULL ));
                if( 
                    cs.AccountId != NULL && 
                    accountMap.get(cs.AccountId) != NULL  && 
                    accountMap.get(cs.AccountId).Onboarding_Owner__r.Email != NULL ){
                        system.debug('inside if');
                        //email.setCcAddresses( new List<String>{ accountMap.get(cs.AccountId).Onboarding_Owner__r.Email } );
                        email.setBCCAddresses( new List<String>{ accountMap.get(cs.AccountId).Onboarding_Owner__r.Email });
                    } else{
                        system.debug('inside else');
                        email.setCcAddresses( new List<String>{} );
                        email.setBCCAddresses( new List<String>{});
                    }
                
                // email.setCcAddresses(ToAddresses);
                email.setWhatId(cs.Id);
                system.debug('email to send'+email);
                listOfMessagingSingleEmailMessage.add(email);
                caseListToUpdate.add(csToUpdate);
            }
        }
        system.debug('listOfMessagingSingleEmailMessage'+listOfMessagingSingleEmailMessage);
        if(!listOfMessagingSingleEmailMessage.isEmpty()){
            Messaging.SendEmailResult[] msgResult = Messaging.sendEmail(listOfMessagingSingleEmailMessage,false);
            System.debug('****msgResult'+msgResult);
            if(!caseListToUpdate.isEmpty()){
                update caseListToUpdate;
            }
        }
    }
    //added so the additional cases are not creted : 14 dec 2021
    
    public static void doNotInsertCases(List<case> listOfCasesToNotToInsertIds){
        for(case thisCase:listOfCasesToNotToInsertIds){
            thisCase.addError('Cannot Insert case');   
        }
    }
    
    public static void productTypeMaxITC(List<case> listOfCasesMaxITC){
        List<case> listCasesToUpdate=new List<case>(); 
        for(case thisCase:listOfCasesMaxITC){
            thisCase.ownerID=System.label.MaxITC_Queue_Id; 
        }
        
    }
    
    //added for sending auto ack to cases created by web :12 april 2022
    public static void autoRespondForWeb(Map<Id, Case> caseMap,Map<id,String> relatedContactsEmails){
        system.debug('relatedContactsEmails=====>'+relatedContactsEmails);
        List<Messaging.SingleEmailMessage> listOfMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        List<Org_wide_and_Email_Template_Mapping__mdt> listOfOrgwideandEmailTemplateMappings=new List<Org_wide_and_Email_Template_Mapping__mdt>();
        listOfOrgwideandEmailTemplateMappings=DataBase.query(UtilityClass.getQueryString('Org_wide_and_Email_Template_Mapping__mdt')+' FROM Org_wide_and_Email_Template_Mapping__mdt ');
        Map<String,Org_wide_and_Email_Template_Mapping__mdt> mapOfOrgwideandEmailTemplateMappings=new  Map<String,Org_wide_and_Email_Template_Mapping__mdt>();
        Map<String,Org_wide_and_Email_Template_Mapping__mdt> recordTypeToOTMMap = new  Map<String,Org_wide_and_Email_Template_Mapping__mdt>();
        Set<Id> setofOrgWiderIds = new Set<Id>();
        Set<Id> setofEmailTemplateIds = new Set<Id>();
        List<Case> caseListToUpdate = new List<Case>();
        set<string> ToAddressesSet = new set<string>();
        set<string> CCAddressesSet = new set<string>();
        MAp<string,Id> mapOfContactEMailAndID=new MAp<string,Id>();
        
        for(Org_wide_and_Email_Template_Mapping__mdt otm : listOfOrgwideandEmailTemplateMappings){
            if(!String.isEmpty(otm.RecordType__c)){
                for(String str : otm.RecordType__c.trim().split(',')){
                    recordTypeToOTMMap.put(str.trim(), otm);
                }
            }
        }
        if(!caseMap.isEmpty()){
            for(Case caseInstance : caseMap.values()){
                setofOrgWiderIds.add(recordTypeToOTMMap.get(caseInstance?.RecordTypeId)?.Org_Wide_Email_Id__c);
                setofEmailTemplateIds.add(recordTypeToOTMMap.get(caseInstance?.RecordTypeId)?.Email_Template_Id__c);
            }
        }
        Map<Id,OrgWideEmailAddress> mapOforgWideEmailAddressInstance  = new Map<Id,OrgWideEmailAddress>([SELECT Id, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, Address, DisplayName, IsAllowAllProfiles FROM OrgWideEmailAddress WHERE Id IN:setofOrgWiderIds]);
        Map<Id,emailTemplate>  mapOfemailTemplateInstanc = new Map<Id,emailTemplate>([Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Id IN: setofEmailTemplateIds]);
        system.debug('caseMap---->'+caseMap);
        list<contact> relatedContact =[Select id,Email from contact where email in : relatedContactsEmails.values() ];
        
        for(Contact thisContact:relatedContact){
            mapOfContactEmailAndID.put(thisContact.Email,thisContact.Id); 
        }
        for(Case cs : caseMap.values()){
            Case csToUpdate = new Case();
            csToUpdate.Id = cs.Id;
            csToUpdate.Auto_Response_Sent_To_CC__c  = true;
            
            if(recordTypeToOTMMap.containsKey(cs.RecordTypeId)){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(mapOfemailTemplateInstanc.get(recordTypeToOTMMap.get(cs.RecordTypeId).Email_Template_Id__c).Id);
                email.setOrgWideEmailAddressId(mapOforgWideEmailAddressInstance.get(recordTypeToOTMMap.get(cs.RecordTypeId).Org_Wide_Email_Id__c).Id);
                system.debug('org value--->'+mapOforgWideEmailAddressInstance.get(recordTypeToOTMMap.get(cs.RecordTypeId).Org_Wide_Email_Id__c).Id);
                
                if(mapOfContactEmailAndID.containsKey(cs.SuppliedEmail )){
                    email.setTargetObjectId(mapOfContactEmailAndID.get(cs.SuppliedEmail));
                    email.setSaveAsActivity(true);
                }
                if(!cs.Disable_Email_Communication__c){
                    ToAddressesSet.add(cs.SuppliedEmail);
                }
                if(!String.ISBLANK(cs.CCEmailAddress__c)){
                    if(cs.CCEmailAddress__c.contains(';'))
                        CCAddressesSet.addAll(cs.CCEmailAddress__c.split(';'));
                    else
                        CCAddressesSet.addAll(cs.CCEmailAddress__c.split(','));    
                }
                CCAddressesSet.add(cs.Owner_Email__c);
                //CCAddressesSet.add('murali.krishna@clear.in');
                email.setWhatId(cs.Id);
                if(ToAddressesSet.Size() > 0){
                    List<string> listAddress=new List<String>();
                    system.debug('ToAddressesSet===>'+ToAddressesSet);
                    listAddress.addall(ToAddressesSet);
                    email.setToAddresses(listAddress);
                    system.debug('listAddress@#$'+listAddress);
                    system.debug('listAddress@#$'+email.getToAddresses());
                }
                if(CCAddressesSet.Size() > 0){
                    CCAddressesSet.remove('null');
                    email.setCCAddresses(new List<String>(CCAddressesSet));
                    if( cs.AccountId != NULL && cs.Account_CSM_Email__c != NULL ){
                        system.debug('inside if');
                       // email.setCcAddresses( new List<String>{ cs.Account_CSM_Email__c } );
                        email.setBCCAddresses( new List<String>{ cs.Account_CSM_Email__c });
                    } else{
                        system.debug('inside else');
                        email.setCcAddresses( new List<String>{} );
                        email.setBCCAddresses( new List<String>{});
                    }
                    system.debug('cs.Account_CSM_Email__c'+cs.Account_CSM_Email__c);
                    system.debug('setCCAddresses@#$'+CCAddressesSet);
                    system.debug('setCCAddresses@#$'+email.getCCAddresses());
                }
                // email.setCcAddresses(ToAddresses);
                listOfMessagingSingleEmailMessage.add(email);
                caseListToUpdate.add(csToUpdate);
                system.debug('listAddress@#$123'+email.getToAddresses());
            }
        }
        system.debug('trigger is firing on insert');
        if(!listOfMessagingSingleEmailMessage.isEmpty()){
            Messaging.SendEmailResult[] msgResult = Messaging.sendEmail(listOfMessagingSingleEmailMessage,false);
            System.debug('****msgResult'+msgResult);
            if(!caseListToUpdate.isEmpty()){
                // update caseListToUpdate;
            }
        }
    }
    
    
    /** Added by Ashwin :: generateRandomOTP **/
    /* Public Static String generateRandomOTP(){

String result = '';  

String rand = string.valueof(Math.abs(Crypto.getRandomInteger()));
String otp = rand.substring(0,6);
result = otp;

return result;
}*/
    
    
}