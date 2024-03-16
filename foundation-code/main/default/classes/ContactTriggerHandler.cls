public class ContactTriggerHandler implements TriggerInterface {
 public static void beforeInsert(List<SObject> listOfNewSObjects){
       listOfNewSObjects= ContactTriggerHelper.checkDupEmail(listOfNewSObjects,null,false);
         //insert(listOfNewSObjects);
    }
    public static void afterInsert(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){
        CTX_ApexRecordSharing.apexShare_Contact_AccountSalesOwnerAccess( (Map<Id,Contact>) mapOfNewSObjects );
    }
    public static void beforeUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
       mapOfNewSObjects = new map <id,Contact>(ContactTriggerHelper.checkDupEmail(mapOfNewSObjects.values(),(map<id,Contact>)mapOfOldSObjects,true));
        //Update(mapOfNewSObjects.values());
    }
    public static void afterUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
        CTX_ApexRecordSharing.apexShare_Contact_AccountSalesOwnerAccess( (Map<Id,Contact>) mapOfNewSObjects );
    }
        public static void beforeDelete(List<SObject> listOfOldSObjects,Map<Id,SObject> mapOfOldSObjects){
        System.debug('<----beforeDelete---->');
    }
    public static void afterDelete(Map<Id,SObject> listOfOldSObjects){
    }
    public static void afterUnDelete(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){
    }
}