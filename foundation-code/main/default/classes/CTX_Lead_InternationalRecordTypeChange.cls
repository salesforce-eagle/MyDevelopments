public class CTX_Lead_InternationalRecordTypeChange {
    
    /**	Lead Mapping based on Company Domain : START	**/
    public static void getLeadDomainMapping(List<Lead> leads, Set<String> domainSet){
        
        Map<String, Id> domainLeadMap = new Map<String, Id>();
        
        if(domainSet.size() > 0){
            for( 
                Lead thisRec : [ SELECT Id, Domain_Name__c, Lead__c 
                                FROM Lead WHERE 
                                Domain_Name__c != NULL AND 
                                Domain_Name__c IN :domainSet AND 
                                ( NOT Domain_Name__c IN ('gmail.com', 'hotmail.com', 'rediffmail.com', 'yahoo.com', 'N/A') ) AND 
                                Lead__c = NULL AND 
                                IsConverted = FALSE
                                ORDER By CreatedDate DESC LIMIT 49999 ] 
            ){
                if(!domainLeadMap.containsKey(thisRec.Domain_Name__c))
                    domainLeadMap.put(thisRec.Domain_Name__c, thisRec.Id);
            }
        }
        
        for(Lead thisRec : leads){
            if( thisRec.Domain_Name__c != NULL || thisRec.Domain_Name__c != 'N/A' ){
                if( domainLeadMap.size() > 0 && domainLeadMap.containsKey(thisRec.Domain_Name__c) ){
                    if(thisRec.Id != domainLeadMap.get(thisRec.Domain_Name__c)){
                        thisRec.Lead__c = domainLeadMap.get(thisRec.Domain_Name__c);
                    }
                }
            }
        }
    }	/**	Lead Mapping based on Company Domain : END	**/
    
    
}