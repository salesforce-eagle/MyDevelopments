public class ContentDocumentTriggerHandler implements TriggerInterface{
    
    public static void beforeInsert(List<Sobject> listOfNewSObjects){
        System.debug('ContentDocumentTriggerHandler before Insert: '+listOfNewSObjects);
        
        Integer fileSize 	= Integer.valueof(System.Label.File_Size);
        String ownerIds 	= System.Label.File_Exclusion_Users;
        
        for(ContentDocument thisRec : (List<ContentDocument>)listOfNewSObjects){
            
            if(
                thisRec.ContentSize > fileSize && 
                (
                    !ownerIds.split(',').contains(thisRec.OwnerId) || 
                    !ownerIds.split(',').contains(thisRec.CreatedById)
                )
            ){
                thisRec.addError('File Size greater than 2MB is not allowed.');
            }
        }
    }
    public static void afterInsert(List<Sobject> listOfNewSObjects,Map<Id,Sobject> mapOfNewSObjects){
        
        
    }
    public static void beforeUpdate(Map<Id,Sobject> mapOfNewSObjects,Map<Id,Sobject> mapOfOldSObjects){
        
        Map<Id, ContentDocument> 	newContentDocumentMap 	= (Map<Id, ContentDocument>)mapOfNewSObjects;
        Map<Id, ContentDocument> 	oldContentDocumentMap 	= (Map<Id, ContentDocument>)mapOfOldSObjects;
        
        Integer fileSize 	= Integer.valueof(System.Label.File_Size);
        String ownerIds		= System.Label.File_Exclusion_Users;
        
        for(ContentDocument thisRec : (List<ContentDocument>)newContentDocumentMap.values()){
            
            if(
                thisRec.CreatedDate == oldContentDocumentMap.get(thisRec.Id).LastModifiedDate && 
                thisRec.ContentSize > fileSize &&
                (
                    !ownerIds.split(',').contains(thisRec.OwnerId) || 
                    !ownerIds.split(',').contains(thisRec.CreatedById)
                )
            ){
                
                thisRec.addError('File Size greater than 2MB is not allowed.');
            }
        }
    }
    public static void afterUpdate(Map<Id,Sobject> mapOfNewSObjects,Map<Id,Sobject> mapOfOldSObjects){
        
    }
    public static void beforeDelete(List<Sobject> listOfOldSObjects,Map<Id,Sobject> mapOfOldSObjects){
        System.debug('ContentDocumentTriggerHandler before Delete');
        Map<id,ContentDocument> mapOfidWithContentDocument=new Map<Id,ContentDocument>();
        for(Id key:mapOfOldSObjects.keySet()){
            if(!mapOfidWithContentDocument.containsKey(key)){
                mapOfidWithContentDocument.put(key, (ContentDocument)mapOfOldSObjects.get(key));
            }
            System.debug('mapOfidWithContentDocument '+mapOfidWithContentDocument);
        }
        
        if(!mapOfidWithContentDocument.isEmpty()){
            ContentDocumentTriggerHelper.restrictDeleteOfContentDoc(mapOfidWithContentDocument);
        }
    }
    public static void afterDelete(Map<Id,Sobject> mapOfOldSObjects){
        
    }
    public static void afterUndelete(List<Sobject> listOfNewSObjects,Map<Id,Sobject> mapOfNewSObjects){
        
    }
    
    
}