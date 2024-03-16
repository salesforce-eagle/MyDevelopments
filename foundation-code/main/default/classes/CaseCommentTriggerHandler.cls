/**
 * @File Name          : CaseCommentTriggerHandler.cls
 * @Description        : 
 * @Author             : Lokesh@SFDeveloper.SFDoc
 * @Group              : 
 * @Last Modified By   : Lokesh@SFDeveloper.SFDoc
 * @Last Modified On   : 28/5/2020, 1:03:22 am
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/5/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public class CaseCommentTriggerHandler implements TriggerInterface{
    

    
     
    /**
    * @description handle before Insert event on Trigger
    * @author Lokesh Thathuru | 05/11/2020
    * @param List<SObject> listOfNewSObjects
    * @return void
    */
     public static void beforeInsert(List<SObject> listOfNewSObjects){
        System.debug('<----CaseComment-beforeInsert---->');
         List<CaseComment> listOfCaseComments=new List<CaseComment>();
         
         if(listOfNewSObjects.size()>0){
             for(Sobject objectInstance:listOfNewSObjects){
                 CaseComment caseCommentInstance=(CaseComment)objectInstance;
                // if(caseCommentInstance.IsNotificationSelected == false){
                     listOfCaseComments.add(caseCommentInstance);
                 //}
             }
         }
         
         if(listOfCaseComments.size()>0){
             CaseCommentTriggerHelper.markIsInternalCommentCreatedToTrue(listOfCaseComments);
         }
         
    }
    
    /**
    * @description handle after Insert event on Trigger
    * @author Lokesh Thathuru | 05/11/2020
    * @param List<SObject> listOfNewSObjects 
    * @param Map<Id,SObject> mapOfNewSObjects
    * @return void
    */
    public static void afterInsert(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){
        System.debug('<----CaseComment-afterInsert---->');
        Map<Id,CaseComment> mapOfNewCaseComments=new  Map<Id,CaseComment>();
        List<CaseComment> listOfNewCaseComments=new List<CaseComment>();
        Set<Id> parenCaseIDs=new Set<ID>();
        if(!mapOfNewSObjects.isEmpty()){
            for(SObject objectInstance:mapOfNewSObjects.Values()){
                CaseComment caseCommentInstance=(CaseComment)objectInstance;
                if(!mapOfNewCaseComments.containsKey(caseCommentInstance.Id)/* && caseCommentInstance.IsNotificationSelected == true */){
                    mapOfNewCaseComments.put(caseCommentInstance.Id,caseCommentInstance);
                }
                if(caseCommentInstance.ParentId!=null && caseCommentInstance.CommentBody!=null ){
                    listOfNewCaseComments.add(caseCommentInstance);
                    parenCaseIDs.add(caseCommentInstance.ParentId);
                }
            }
        }
        
        system.debug('****mapOfNewCaseComments-->'+mapOfNewCaseComments);
        if(!mapOfNewCaseComments.isEmpty()){
            CaseCommentTriggerHelper.updateFirstReplyMilestoneToCompleted(mapOfNewCaseComments);
        }
        
        if(listOfNewCaseComments.size()>0){
            CaseCommentTriggerHelper.updateLatestCommentBodyToCase(listOfNewCaseComments, parenCaseIDs);
        }
        
    }
    
     /**
    * @description  handle before Update event on Trigger
    * @author Lokesh Thathuru | 05/11/2020
    * @param Map<Id,SObject> mapOfNewSObjects
    * @param Map<Id,SObject> mapOfOldSObjects
    * @return void
    */
    public static void beforeUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
        System.debug('<----CaseComment-beforeUpdate---->');
    }
    
     /**
    * @description  handle After Update event on Trigger
    * @author Lokesh Thathuru | 05/11/2020
    * @param Map<Id,SObject> mapOfNewSObjects
    * @param Map<Id,SObject> mapOfOldSObjects
    * @return void
    */
    public static void afterUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
        System.debug('<----CaseComment-afterUpdate---->');
    }
    
    /**
    * @description  handle before delete event on Trigger
    * @author Lokesh Thathuru | 05/11/2020
    * @param List<SObject> listOfOldSObjects
    * @param Map<Id,SObject> mapOfOldSObjects
    * @return void
    */
    public static void beforeDelete(List<SObject> listOfOldSObjects,Map<Id,SObject> mapOfOldSObjects){
        System.debug('<----CaseComment-beforeDelete---->');
    }
    
    
	/**
    * @description  handle after Delete event on Trigger
    * @author Lokesh Thathuru | 05/11/2020
    * @param List<SObject> listOfOldSObjects
    * @return void
    */    
    public static void afterDelete(Map<Id,SObject> listOfOldSObjects){
         System.debug('<----CaseComment-afterDelete---->');
    }
    
      /**
    * @description handle after UpDelete event on Trigger
    * @author Lokesh Thathuru | 05/11/2020
    * @param List<SObject> listOfNewSObjects
    * @param Map<Id,SObject> mapOfNewSObjects
    * @return void
    */
    public static void afterUnDelete(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){
         System.debug('<----CaseComment-afterUnDelete---->');
    }
    
}