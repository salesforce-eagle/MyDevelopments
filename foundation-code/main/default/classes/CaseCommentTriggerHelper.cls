/**
* @File Name          : CaseCommentTriggerHelper.cls
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : Lokesh@SFDeveloper.SFDoc
* @Last Modified On   : 28/5/2020, 12:57:38 am
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    27/5/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public without sharing class CaseCommentTriggerHelper {
    
    
    /**
* @description  markIsInternalCommentCreatedToTrue
* @author Lokesh Thathuru | 05/11/2020
* @param List<CaseComment> listOfCaseComments
* @return void
*/    
    public static void markIsInternalCommentCreatedToTrue(List<CaseComment> listOfCaseComments){
     /**   Map<Id,Case> mapOfParentCases=new Map<Id,Case>(); // Logic has been moved to caseTrigger
        Set<Id> setOfParentCaseIds=new Set<Id>();
        
        if(listOfCaseComments.size()>0){
            for(CaseComment caseCommentInstance: listOfCaseComments){
                setOfParentCaseIds.add(caseCommentInstance.ParentId);
            }
        }
        
        mapOfParentCases=new Map<Id,Case>(CaseSelector.getCaseByIds(setOfParentCaseIds));
        
        if(!listOfCaseComments.isEmpty()){
            for(CaseComment caseCommentInstance: listOfCaseComments){
                if(mapOfParentCases.get(caseCommentInstance.ParentId).Is_Internal_Comment_Created__c!=true){
                    mapOfParentCases.get(caseCommentInstance.ParentId).Is_Internal_Comment_Created__c=true;
                }
            }
        }
        
        if(!mapOfParentCases.isEmpty()){
            new CaseService().updateCases(mapOfParentCases.values(), '');
        }**/ 
        
    }
    
    /**
* @description  Update the FirstReply CaseMileston to Complete and update the First Reply sent as True 
* @author Lokesh Thathuru | 05/11/2020
* @param Map<Id,CaseComment> mapOfCaseComments
* @return void
*/    
    public static void updateFirstReplyMilestoneToCompleted(Map<Id,CaseComment> mapOfCaseComments){
        system.debug('****updateFirstReplyMilestoneToCompleted case comment');
        Set<Id> setOfParentCaseIds=new Set<Id>();
        
        if(!mapOfCaseComments.isEmpty()){
            for(Id key: mapOfCaseComments.keySet()){
                if(mapOfCaseComments.containsKey(key)){
                    CaseComment caseCommentInstance=mapOfCaseComments.get(key);
                    if(caseCommentInstance.ParentId!=null){
                        setOfParentCaseIds.add(caseCommentInstance.ParentId);
                    }
                }
            }
        }
        
        List<CaseMilestone> listOfCaseMilestones=new List<CaseMilestone>();
        system.debug('***setOfParentCaseIds-->'+setOfParentCaseIds);
        if(setOfParentCaseIds.size()>0){
            listOfCaseMilestones=CaseMilestoneSelector.getCaseMilestonesByCaseIds(setOfParentCaseIds);
        }
        system.debug('***listOfCaseMilestones-->'+listOfCaseMilestones);
        if(listOfCaseMilestones.size()>0){
            CaseMilestoneService.updateMilestoneUtility(listOfCaseMilestones);
        }
    }
    
    
    /**
* @description  This Method helps to update the Current Body of the EmailMessage to the ParentCase
* @author Lokesh Thathuru | 06/21/2020
* @param List<CaseComment> listOfNewCaseComments
* @return void
*/    
    public static void updateLatestCommentBodyToCase(List<CaseComment> listOfNewCaseComments,set<id> parenCaseIDs){
        
        List<Case> listOfParentCasesToUpdate=new List<Case>();
        Map<Id,Case> mapOfParentCases =new Map<Id,Case>([Select id,MasterRecordId from case where ID IN:parenCaseIDs]);
        if(listOfNewCaseComments.size()>0){
            for(CaseComment caseCommentInstance:listOfNewCaseComments ){
                if(caseCommentInstance.CommentBody!=null &&  caseCommentInstance.CommentBody.length()<=131072 && caseCommentInstance.ParentId!=null){
                    Case caseInstance=new Case(Id=caseCommentInstance.ParentId);
                    caseInstance.Latest_CaseComment__c=caseCommentInstance.CommentBody;
                    IF(mapOfParentCases.containsKey(caseCommentInstance.ParentId) && 
                       mapOfParentCases.get(caseCommentInstance.ParentId).MasterRecordId !=null){
                           listOfParentCasesToUpdate.add(caseInstance);
                       }
                }
            }
        }
        
        if(listOfParentCasesToUpdate.size()>0){
            new CaseService().updateCases(listOfParentCasesToUpdate, '');
        }
        
    }
    
    
    
}