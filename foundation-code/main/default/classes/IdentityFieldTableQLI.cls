public class IdentityFieldTableQLI {
    
   @AuraEnabled
    public static string fetchIdentityData(Id recordId) {
    
        string data='';
        Schema.FieldSet fdlstForIdentity = Schema.SObjectType.QuoteLineItem.fieldSets.getMap().get('Identity_Related_Fields');
        
        if (!fdlstForIdentity.getFields().isEmpty()) {
            for (Schema.FieldSetMember fd : fdlstForIdentity.getFields()) {
                //   query += fd.getFieldPath() + ', ';
                data += fd.getFieldPath() + ', ';
            }
            data = data.removeEnd(', ');
        }
        
       return data;
    }
    
    @AuraEnabled
    public static boolean updateIdentityData(string updateddata,Id recordId){
        
        QuoteLineItem querieddata = [ SELECT Id, Identity_Resource_Metadata__c 
                                     FROM QuoteLineItem WHERE Id = :recordId ];
        system.debug('querieddata: '+querieddata);
        system.debug('querieddata: Identity_Resource_Metadata__c '+querieddata.Identity_Resource_Metadata__c);
         system.debug('updateddata Identity_Resource_Metadata__c: '+updateddata);
        
        querieddata.Identity_Resource_Metadata__c = updateddata;
        update querieddata;
        
        return true;
    }
    
    
    public class MeteringParamsClass {
        
        public string 	identityname;
        public Integer 	count = 0;
        public Integer 	perUnitListPrice = 0;
        public Integer 	perUnitSellPrice = 0;
        public Integer 	perUnitCostPrice = 0;
    }
    
}