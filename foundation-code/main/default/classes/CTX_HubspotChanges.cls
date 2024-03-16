public class CTX_HubspotChanges {
    
    public static string hubspotId;
    public static string adminQueueId;
    
    public static void getDetails(){
        hubspotId 		= [ SELECT Id FROM User WHERE username = 'bibhuda.dash@cleartax.in.hubspot' ]?.Id;
    }
    
    
    public static void ownershipChanges(List<Lead> newLeadList, Map<Id, Lead> oldLeadRecordsMap){
        
        Map<String, Id> 		accountOwnerPANMap 	= new Map<String, Id>();
        Map<String, Id>			accountIdPANMap		= new Map<String, Id>();
        Map<String, Id>			accountIdOwnerPANMap= new Map<String, Id>();
        Map<String, Id>			leadIdPANMap		= new Map<String, Id>();
        Set<Id>					getLeadIds			= new Set<Id>();
        Map<String, Set<Lead>>	leadMap				= new Map<String, Set<Lead>>();
        
        for(Lead thisRec: newLeadList){
            
            if(thisRec.PAN__c != NULL){
                accountOwnerPANMap.put(thisRec.PAN__c, NULL);
                accountIdPANMap.put(thisRec.PAN__c, NULL);
                accountIdOwnerPANMap.put(thisRec.PAN__c, NULL);
                leadIdPANMap.put(thisRec.PAN__c, NULL);
                getLeadIds.add(thisRec.Id);
                
                if(leadMap.containsKey(thisRec.PAN__c)){
                    leadMap.get(thisRec.PAN__c).add(thisRec);
                } else{
                    leadMap.put(thisRec.PAN__c, new Set<Lead>{thisRec});
                }
                
            }
        }
        
        if(leadIdPANMap.size() > 0){
            for(
                Lead thisRec : [ SELECT Id, OwnerId, PAN__c, CreatedDate 
                                FROM Lead WHERE 
                                PAN__c IN: leadMap.keySet() AND
                                ( NOT Id IN :getLeadIds ) ] 
            ){
                
                if(leadMap.containsKey(thisRec.PAN__c)){
                    for( Lead thisLead : leadMap.get(thisRec.PAN__c) ){
                        
                        if(thisRec.CreatedDate < thisLead.CreatedDate){
                            leadIdPANMap.put(thisRec.PAN__c, thisRec.OwnerId);
                        } else{
                            leadIdPANMap.put(thisRec.PAN__c, thisLead.OwnerId); 
                        }
                    }
                }
            }
        }
        
        if(accountOwnerPANMap.size() > 0){
            for(
                Account thisRec : [ SELECT Id, OwnerId, PAN__c, Sales_Owner__c, ID_Sales_Owner__c 
                                   FROM Account WHERE 
                                   PAN__c IN :accountOwnerPANMap.keySet() ]
            ){
                
                accountOwnerPANMap.put(thisRec.PAN__c, thisRec.Sales_Owner__c);
                accountIdPANMap.put(thisRec.PAN__c, thisRec.Id);
                accountIdOwnerPANMap.put(thisRec.PAN__c, thisRec.ID_Sales_Owner__c);
            }
        }
        
        if( accountIdPANMap != NULL && accountIdOwnerPANMap != NULL){
            for(Lead thisRec : newLeadList){

                system.debug('thisRec.RecordTypeId: '+thisRec.RecordTypeId);
                if( thisRec.Country_of_Origin__c == 'India' || thisRec.Country_of_Origin__c == NULL  ){
                    
                    if(accountIdPANMap.containsKey(thisRec.PAN__c) && accountIdPANMap.get(thisRec.PAN__c) != NULL){
                        
                        thisRec.Account__c = accountIdPANMap.get(thisRec.PAN__c);
                    } else{
                        
                        thisRec.Account__c = NULL;
                    }
                    
                    if(accountIdOwnerPANMap.containsKey(thisRec.PAN__c) && accountIdOwnerPANMap.get(thisRec.PAN__c) != NULL){
                        thisRec.ID_Owner__c = accountIdOwnerPANMap.get(thisRec.PAN__c);
                    } else{
                        // thisRec.ID_Owner__c = NULL;
                    }
                }
            }
        }
        
        if(oldLeadRecordsMap == NULL){
            
            system.debug('Before Insert Trigger');
            for(Lead thisRec: newLeadList){
                if(thisRec.Lead_Owner_department__c != NULL && !System.label.LeadOwnerDepartment.contains(thisRec?.Lead_Owner_department__c)){
                    if( accountOwnerPANMap.containsKey(thisRec.PAN__c) && accountOwnerPANMap.get(thisRec.PAN__c) != NULL ){
                        
                        thisRec.OwnerId = accountOwnerPANMap.get(thisRec.PAN__c);
                    } else if(leadIdPANMap.size() > 0){
                        if(leadIdPANMap.containsKey(thisRec.PAN__c) && leadIdPANMap.get(thisRec.PAN__c) != NULL  ){
                            
                            thisRec.OwnerId = leadIdPANMap.get(thisRec.PAN__c);
                        }
                    } 
                }
            }
        } else{
            
            system.debug('Before Update Trigger');
            for(Lead thisRec: newLeadList){
                if(thisRec.Lead_Owner_department__c != NULL && !System.label.LeadOwnerDepartment.contains(thisRec?.Lead_Owner_department__c)){
                    if( thisRec.OwnerId == oldLeadRecordsMap.get(thisRec.Id).OwnerId ){
                        if( accountOwnerPANMap.containsKey(thisRec.PAN__c) && accountOwnerPANMap.get(thisRec.PAN__c) != NULL ){
                            
                            thisRec.OwnerId = accountOwnerPANMap.get(thisRec.PAN__c);
                        }
                    } else if(leadIdPANMap.size() > 0){
                        if(
                            leadIdPANMap.containsKey(thisRec.PAN__c) && 
                            leadIdPANMap.get(thisRec.PAN__c) != NULL 
                        ){
                            
                            thisRec.OwnerId = leadIdPANMap.get(thisRec.PAN__c);
                        }
                    }
                }
            }
        }
        
        
    }
    
    
    public static void accountOwnershipChange(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap){
        
        Map<String, Id> panOwnerIdMap = new Map<String, Id>();
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Account thisRec : newAccountMap.values()){
            
            if( thisRec.Sales_Owner__c != oldAccountMap.get(thisRec.Id).Sales_Owner__c && thisRec.PAN__c != NULL ){
                panOwnerIdMap.put(thisRec.PAN__c, thisRec.Sales_Owner__c);
            }
        }
        
        for(Lead thisRec : [ SELECT Id, OwnerId, PAN__c FROM Lead WHERE PAN__c IN :panOwnerIdMap.keySet() ] ){
            
            if( panOwnerIdMap.containsKey(thisRec.PAN__c) ){
                thisRec.OwnerId = panOwnerIdMap.get(thisRec.PAN__c);
                leadsToUpdate.add(thisRec);
            }
        }
        
        database.update(leadsToUpdate, FALSE);
    }
    
    
    /**	End of Class	**/
}