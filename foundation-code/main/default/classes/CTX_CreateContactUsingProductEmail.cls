public class CTX_CreateContactUsingProductEmail {
    
    public static Map<String, String> getAssetAccountIdsMap( String contentDocumentId ){
        
        ContentVersion 		contentDocumentVersionDetails	= [ SELECT VersionData FROM ContentVersion WHERE 
                                                               ContentDocumentId = :contentDocumentId AND 
                                                               IsLatest = TRUE ];
        Blob 				versionDataStringBody 			= contentDocumentVersionDetails.VersionData;
        List<String> 		columnLiner						= versionDataStringBody.tostring().split('\n');
        Map<String, String>	assetIdAccountIdMap 			= new Map<String, String>();
        
        for( Integer i = 1; i < columnLiner.size(); i++ ){
            
            assetIdAccountIdMap.put(
                columnLiner[i].split(',')[0].trim(),
                columnLiner[i].split(',')[1].trim()
            );
        }
        
        system.debug('assetIdAccountIdMap: '+assetIdAccountIdMap);
        return assetIdAccountIdMap;
    }
    
    public static void tagESignerContactToOpportunity( Map<String, String> assetIdAccountIdMap ){
        
        Set<String> uniqueAccountIds = new Set<String>(assetIdAccountIdMap.values());
        Map<Id, String> accountIdProductEmailMap = new Map<Id, String>();
        Set<Id> accountIdWithExistingContacts = new Set<Id>();
        List<Contact> contsToCreate = new List<Contact>();
        Map<Id, Id> accountIdContactIdMap = new Map<Id, Id>();
        
        if( assetIdAccountIdMap.size() > 0 ){
            if( assetIdAccountIdMap.values().size() > 0 ){
                
                
                for( 
                    Account thisAcc : [ SELECT Id, Product_Email__c 
                                       FROM Account WHERE 
                                       Id IN :uniqueAccountIds AND 
                                       Product_Email__c != NULL ] 
                ){
                    accountIdProductEmailMap.put(thisAcc.Id, thisAcc.Product_Email__c);
                }
                
                for(
                    Contact thisCon : [ SELECT Id, AccountId 
                                       FROM Contact WHERE 
                                       Email IN :accountIdProductEmailMap.values() ] 
                ){
                    accountIdWithExistingContacts.add(thisCon.AccountId);
                }
                
                for( Id accId : accountIdProductEmailMap.keySet() ){
                    
                    if( !accountIdWithExistingContacts.contains(accId) ){
                        
                        Contact thisContact = new Contact(
                            AccountId = accId,
                            LastName = accountIdProductEmailMap.get(accId).split('@')[0],
                            Email = accountIdProductEmailMap.get(accId),
                            Designation_Oppor__c = 'IT',
                            Department = 'IT',
                            Designation__c = 'Admin',
                            Phone = '9999999999',
                            Is_Communicable__c = TRUE
                        );
                        
                        contsToCreate.add(thisContact);
                    }
                    
                }
                
                system.debug('contsToCreate: '+contsToCreate.size());
                
                try{
                    insert contsToCreate;
                    
                    for(
                        Contact thisCon : [ SELECT Id, AccountId 
                                           FROM Contact WHERE 
                                           AccountId IN :accountIdProductEmailMap.keySet() AND 
                                           Email IN :accountIdProductEmailMap.values() ]
                    ){
                        accountIdContactIdMap.put(thisCon.AccountId, thisCon.Id);
                    }
                    
                    system.debug('accountIdContactIdMap: '+accountIdContactIdMap);
                    Map<Id, Opportunity> opportunitiesToUpdateMap = new Map<Id, Opportunity>();
                    
                    for(
                        Asset thisRec : [ SELECT 
                                         Id, AccountId, 
                                         Opportunity__c, Opportunity__r.E_Sign_Customer_Info__c,
                                         Renewal_Opportunity__c, Renewal_Opportunity__r.E_Sign_Customer_Info__c
                                         FROM Asset WHERE 
                                         ( 
                                             ( Opportunity__c != NULL AND Opportunity__r.E_Sign_Customer_Info__c = NULL ) OR 
                                             ( Renewal_Opportunity__c != NULL AND Renewal_Opportunity__r.E_Sign_Customer_Info__c = NULL ) 
                                         ) AND 
                                         Id IN :assetIdAccountIdMap.keySet() ]
                    ){
                        
                        if( thisRec.Renewal_Opportunity__c != NULL && thisRec.Renewal_Opportunity__r.E_Sign_Customer_Info__c == NULL ){
                            
                            system.debug('Inside Renewal: ');
                            Opportunity newOpp = new Opportunity(
                                Id = thisRec.Renewal_Opportunity__c,
                                E_Sign_Customer_Info__c=  accountIdContactIdMap.get(thisRec.AccountId)  
                            );
                            opportunitiesToUpdateMap.put(thisRec.Renewal_Opportunity__c, newOpp);
                        } else if( thisRec.Opportunity__c != NULL && thisRec.Opportunity__r.E_Sign_Customer_Info__c == NULL ){
                            system.debug('Inside Opportunity: ');
                            Opportunity newOpp = new Opportunity(
                                Id = thisRec.Opportunity__c,
                                E_Sign_Customer_Info__c=  accountIdContactIdMap.get(thisRec.AccountId)  
                            );
                            opportunitiesToUpdateMap.put(thisRec.Opportunity__c, newOpp);
                        }
                    }
                    
                    if(opportunitiesToUpdateMap.size() > 0){
                        system.debug('opportunitiesToUpdateMap: '+opportunitiesToUpdateMap.size());
                        update opportunitiesToUpdateMap.values();
                    }
                    
                } catch(Exception ex){
                    
                }
                
            }
        }
    }
    
    public static void executeOpportunityContactTagging( String contentDocumentId ){
        
        if(contentDocumentId != NULL){
            
            Map<String, String> assetIdAccountIdMap = getAssetAccountIdsMap(contentDocumentId);
            tagESignerContactToOpportunity(assetIdAccountIdMap);
        }
        
    }
    
    
}