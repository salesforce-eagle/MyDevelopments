public class CTX_MetadataRetriveUtility{
    
    @AuraEnabled
    public static Map<String, Resource_Constraints__mdt> getResourceConstraintMetadataDetailsByFieldAPI( String planTier ){
        
        Map<String, Resource_Constraints__mdt>  resourceDetailsBasedOnFieldName = new Map<String, Resource_Constraints__mdt>();
        /**	Get Metadata Result to Map : START	**/
        for(Resource_Constraints__mdt mdt : Resource_Constraints__mdt.getAll().values()){
            
            if( mdt.Plan_Tier__c == planTier ){
                resourceDetailsBasedOnFieldName.put(mdt.Salesforce_Field_QLI__c, mdt);
            }
            
        }	/**	Get Metadata Result to Map : END	**/
        
        return resourceDetailsBasedOnFieldName;
    }
 
}