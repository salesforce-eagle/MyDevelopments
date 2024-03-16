public class CTX_ErrorBannerClass {
    
        public static void fetchError(Id recordId, String objectName){
        
        SObjectType objectType 	= ((SObject)Type.forName(objectName).newInstance()).getSObjectType();
        Sobject 	objects 	= objectType.newSObject();
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            update objects;
            system.debug('I have no error');
        } catch(Exception ex){
            system.debug('I am error: '+ex.getMessage());
        }
        
        Database.rollback(sp);
    }
    
}