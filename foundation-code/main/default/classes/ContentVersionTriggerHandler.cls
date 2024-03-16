public class ContentVersionTriggerHandler implements TriggerInterface{

    
    public static void beforeInsert(List<Sobject> listOfNewSObjects){
        for(ContentVersion contentVersionInstance:(List<ContentVersion>)listOfNewSObjects){
            if(contentVersionInstance.Type_Of_Document__c != NULL){
            if(contentVersionInstance.Type_Of_Document__c.equals('Order Form')){
				contentVersionInstance.Title = contentVersionInstance.Title.remove('/').remove('.').remove('_').remove('(').remove(')').remove(']')
                    .remove('{').remove('}').remove('&').remove('%').remove('*').remove('@').remove('$').remove('^');
            }
        }
        }
    }
    public static void afterInsert(List<Sobject> listOfNewSObjects,Map<Id,Sobject> mapOfNewSObjects){
        
        List<ContentVersion> listOfNewContentVersions=new List<ContentVersion>();
        
        for(ContentVersion contentVersionInstance:(List<ContentVersion>)listOfNewSObjects){
            if(contentVersionInstance.Parent_RecordId__c!=null){
				listOfNewContentVersions.add(contentVersionInstance);
            }
        }
        
        if(listOfNewContentVersions.size()>0){
            ContentVersionTriggerHelper.contentDocumentLink(listOfNewContentVersions);
        }
    }
    public static void beforeUpdate(Map<Id,Sobject> mapOfNewSObjects,Map<Id,Sobject> mapOfOldSObjects){
        
    }
    public static void afterUpdate(Map<Id,Sobject> mapOfNewSObjects,Map<Id,Sobject> mapOfOldSObjects){
        
    }
    public static void beforeDelete(List<Sobject> listOfOldSObjects,Map<Id,Sobject> mapOfOldSObjects){
        
    }
    public static void afterDelete(Map<Id,Sobject> mapOfOldSObjects){
        
    }
    public static void afterUndelete(List<Sobject> listOfNewSObjects,Map<Id,Sobject> mapOfNewSObjects){
        
    }
    
    
}