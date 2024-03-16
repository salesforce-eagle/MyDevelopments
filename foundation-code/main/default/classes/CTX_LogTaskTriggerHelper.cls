/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-23-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_LogTaskTriggerHelper {

    PUBLIC STATIC FINAL STRING	QSRRECORDTYPEID	= Schema.SObjectType.Log_Task__c.getRecordTypeInfosByDeveloperName().get('QSR').getRecordTypeId();
    
    
    public static void blockMoMUpdateOnNoAttachment( Map<Id, Log_Task__c> newTaskMap, Map<Id, Log_Task__c> oldTaskMap ){
        
        Map<Id, Boolean> 	taskWithAttachmentMap 		= new Map<Id, Boolean>();
        Map<Id, Set<Id>>	logTaskIdAndDocumentLinkMap = new Map<Id, Set<Id>>();
        Set<Id>				documentIdSet				= new Set<Id>();
        
        for( ContentDocumentLink thisRec : [ SELECT Id, LinkedEntityId, ContentDocumentId 
                                            FROM ContentDocumentLink WHERE 
                                            LinkedEntityId IN :newTaskMap.keySet() ]
           ){
               if( logTaskIdAndDocumentLinkMap.containsKey( thisRec.LinkedEntityId ) ){
                   logTaskIdAndDocumentLinkMap.get( thisRec.LinkedEntityId ).add(thisRec.ContentDocumentId);
               } else{
                   logTaskIdAndDocumentLinkMap.put( thisRec.LinkedEntityId, new set<Id>{thisRec.ContentDocumentId});
               }
               documentIdSet.add(thisRec.ContentDocumentId);
           }
                
        for( 
            ContentVersion thisRec : [ SELECT Id, ContentDocumentId 
                                      FROM ContentVersion WHERE 
                                      ContentDocumentId IN :documentIdSet ] 
        ){
            for( Id thisId : logTaskIdAndDocumentLinkMap.keySet() ){
                if( logTaskIdAndDocumentLinkMap.get(thisId) != NULL && logTaskIdAndDocumentLinkMap.get(thisId)?.contains(thisRec.ContentDocumentId) ){
                    taskWithAttachmentMap.put(thisId, TRUE);
                }
            }
            
        }
        
        for( Log_Task__c thisRec : newTaskMap.values() ){
            if( thisRec.RecordTypeId == QSRRECORDTYPEID && thisRec.MOM_Shared__c != oldTaskMap.get(thisRec.Id).MOM_Shared__c && thisRec.MOM_Shared__c && !taskWithAttachmentMap.containsKey(thisRec.Id) ){
                thisRec.addError('Please attach the MoM document before marking MoM Shared True.');
            }
        }
        
    }
    
    
    public static void beforeInsertValidations( List<Log_Task__c> taskList ){
        
        for( Log_Task__c thisRec : taskList ){
            if( thisRec.RecordTypeId == QSRRECORDTYPEID && thisRec.MOM_Shared__c ){
                thisRec.addError('MoM can not set to True while creating Log Task');
            }
        }
    }
    
    
    
    
}