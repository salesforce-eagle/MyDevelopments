public without sharing class CTX_ApexRecordSharing {
    
    public static Id 		fieldSalesProfileId;
    public static id 		publicGroupId_TaxExpert;
    public static id 		publicGroupId_Enterprise;
    public static Id		recordTypeId_TaxExpert;
    public static Id		recordTypeId_Enterprise;
    public static Id		recordTypeId_Lead_TaxExpert;
    public static Id		recordTypeId_Lead_Enterprise;
    
    /**	Sharing Rule for Account: START	**/
    public static void apexShare_Account_SalesOwnerAccess(Map<Id, Account> newAccountMap){
        
        new CTX_AccountShare(newAccountMap);
    }
    
    public static void apexShare_Contact_AccountSalesOwnerAccess(Map<Id, Contact> newContactMap){
        
        List<ContactShare> 		sharedContact					= new List<ContactShare>();
        Set<Id>					userOrGroupIdSet				= new Set<Id>();
        Map<Id, Set<Id>>		contactIdAndShareUsersMap		= new Map<Id, Set<Id>>();
        
        
        List<Contact>	ContactFilteredList 
            = [ SELECT Id, 
               
               OwnerId, Owner.IsActive, Owner.ManagerId, Owner.Manager.IsActive, 
               
               Account.OwnerId, Account.Owner.IsActive, Account.Owner.ManagerId, Account.Owner.Manager.IsActive, 
               Account.Sales_Owner__c, Account.Sales_Owner__r.IsActive, Account.Sales_Owner__r.ManagerId, Account.Sales_Owner__r.Manager.IsActive,
               
               Account.Id_Account_Owner__c, Account.Id_Account_Owner__r.IsActive, Account.Id_Account_Owner__r.ManagerId, Account.Id_Account_Owner__r.Manager.IsActive,  
               Account.ID_Sales_Owner__c, Account.ID_Sales_Owner__r.IsActive, Account.ID_Sales_Owner__r.ManagerId, Account.ID_Sales_Owner__r.Manager.IsActive
               
               FROM Contact WHERE 
               Id IN :newContactMap.keySet() ];
        system.debug('ContactFilteredList: '+contactFilteredList);
        
        for(
            ContactShare thisRec : [ SELECT Id, ContactId, UserOrGroupId, IsDeleted 
                                    FROM ContactShare WHERE 
                                    ContactId IN :newContactMap.keySet() AND 
                                    IsDeleted = FALSE AND 
                                    RowCause != 'ImplicitParent' ]
        ){
            
            if(contactIdAndShareUsersMap.containsKey(thisRec.ContactId)){
                contactIdAndShareUsersMap.get(thisRec.ContactId).add(thisRec.UserOrGroupId);
            } else{
                contactIdAndShareUsersMap.put(thisRec.ContactId, new Set<Id>{thisRec.UserOrGroupId});
            }
        }
        system.debug('ContactIdAndShareUsersMap: '+contactIdAndShareUsersMap);
        
        
        
        for(Contact thisRec : ContactFilteredList){
            
            /**	Contact > Owner > Manager	**/
            if(thisRec.Owner.ManagerId != NULL && thisRec.Owner.Manager.IsActive){
                if(contactIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !contactIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Owner.ManagerId) && !userOrGroupIdSet.contains(thisRec.Owner.ManagerId) ){
                        
                        sharedContact.add(
                            CTX_ApexRecordSharingHelper.create_ContactShareRecord(thisRec.Id, thisRec.Owner.ManagerId)
                                         );
                        userOrGroupIdSet.add(thisRec.Owner.ManagerId);
                    }
                }
            }
            
            /**	Contact > Account > Owner	**/
            if(thisRec.Account.OwnerId != NULL && thisRec.Owner.IsActive){
                if(contactIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !contactIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.OwnerId) && !userOrGroupIdSet.contains(thisRec.Account.OwnerId) ){
                        
                        ContactShare ownerShare = new ContactShare(
                            ContactId 			= thisRec.Id,
                            UserOrGroupId 		= thisRec.Account.OwnerId,
                            ContactAccessLevel	= 'Edit',
                            RowCause			= Schema.ContactShare.RowCause.Manual
                        );
                        sharedContact.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.OwnerId);
                    }
                }
            }
            
            /**	Contact > Account > Owner > Manager	**/
            if(thisRec.Account.Owner.ManagerId != NULL && thisRec.Account.Owner.Manager.IsActive){
                if(contactIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !contactIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Owner.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account.Owner.ManagerId) ){
                        
                        ContactShare ownerShare = new ContactShare(
                            ContactId 			= thisRec.Id,
                            UserOrGroupId 		= thisRec.Account.Owner.ManagerId,
                            ContactAccessLevel	= 'Edit',
                            RowCause			= Schema.ContactShare.RowCause.Manual
                        );
                        sharedContact.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.Owner.ManagerId);
                    }
                }
            }
            
            /**	Contact > Account > Sales_Owner__c	**/
            if(thisRec.Account.Sales_Owner__c != NULL && thisRec.Account.Sales_Owner__r.IsActive){
                if(contactIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !contactIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Sales_Owner__c) && !userOrGroupIdSet.contains(thisRec.Account.Sales_Owner__c) ){
                        
                        ContactShare ownerShare = new ContactShare(
                            ContactId 			= thisRec.Id,
                            UserOrGroupId 		= thisRec.Account.Sales_Owner__c,
                            ContactAccessLevel	= 'Edit',
                            RowCause			= Schema.ContactShare.RowCause.Manual
                        );
                        sharedContact.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.Sales_Owner__c);
                    }
                }
            }
            
            /**	Contact > Account > Sales_Owner__c > Manager	**/
            if(thisRec.Account.Sales_Owner__r.ManagerId != NULL && thisRec.Account.Sales_Owner__r.Manager.IsActive){
                if(contactIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !contactIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Sales_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account.Sales_Owner__r.ManagerId) ){
                        
                        ContactShare ownerShare = new ContactShare(
                            ContactId 			= thisRec.Id,
                            UserOrGroupId 		= thisRec.Account.Sales_Owner__r.ManagerId,
                            ContactAccessLevel	= 'Edit',
                            RowCause			= Schema.ContactShare.RowCause.Manual
                        );
                        sharedContact.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.Sales_Owner__r.ManagerId);
                    }
                }
            }
            
            /**	Contact > Owner > Id Account Owner	**/
            if(thisRec.Account.Id_Account_Owner__c != NULL && thisRec.Account.Id_Account_Owner__r.IsActive){
                if(contactIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !contactIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Id_Account_Owner__c) && !userOrGroupIdSet.contains(thisRec.Account.Id_Account_Owner__c) ){
                        
                        ContactShare ownerShare = new ContactShare(
                            ContactId 			= thisRec.Id,
                            UserOrGroupId 		= thisRec.Account.Id_Account_Owner__c,
                            ContactAccessLevel	= 'Edit',
                            RowCause			= Schema.ContactShare.RowCause.Manual
                        );
                        sharedContact.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.Id_Account_Owner__c);
                    }
                }
            }
            
            /**	Contact > Owner > Id Account Owner > Manager	**/
            if(thisRec.Account.Id_Account_Owner__r.ManagerId != NULL && thisRec.Account.Id_Account_Owner__r.Manager.IsActive){
                if(contactIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !contactIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Id_Account_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account.Id_Account_Owner__r.ManagerId) ){
                        
                        ContactShare ownerShare = new ContactShare(
                            ContactId 			= thisRec.Id,
                            UserOrGroupId 		= thisRec.Account.Id_Account_Owner__r.ManagerId,
                            ContactAccessLevel	= 'Edit',
                            RowCause			= Schema.ContactShare.RowCause.Manual
                        );
                        sharedContact.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.Id_Account_Owner__r.ManagerId);
                    }
                }
            }
            
            /**	Contact > Owner > Id Account Owner	**/
            if(thisRec.Account.ID_Sales_Owner__c != NULL && thisRec.Account.ID_Sales_Owner__r.IsActive){
                if(contactIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !contactIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.ID_Sales_Owner__c) && !userOrGroupIdSet.contains(thisRec.Account.ID_Sales_Owner__c) ){
                        
                        ContactShare ownerShare = new ContactShare(
                            ContactId 			= thisRec.Id,
                            UserOrGroupId 		= thisRec.Account.ID_Sales_Owner__c,
                            ContactAccessLevel	= 'Edit',
                            RowCause			= Schema.ContactShare.RowCause.Manual
                        );
                        sharedContact.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.ID_Sales_Owner__c);
                    }
                }
            }
            
            /**	Contact > Owner > Id Account Owner > Manager	**/
            if(thisRec.Account.ID_Sales_Owner__r.ManagerId != NULL && thisRec.Account.ID_Sales_Owner__r.Manager.IsActive){
                if(contactIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !contactIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.ID_Sales_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account.ID_Sales_Owner__r.ManagerId) ){
                        
                        ContactShare ownerShare = new ContactShare(
                            ContactId 			= thisRec.Id,
                            UserOrGroupId 		= thisRec.Account.ID_Sales_Owner__r.ManagerId,
                            ContactAccessLevel	= 'Edit',
                            RowCause			= Schema.ContactShare.RowCause.Manual
                        );
                        sharedContact.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.ID_Sales_Owner__r.ManagerId);
                    }
                }
            }
            
        }
        system.debug('sharedContact: '+sharedContact);
        
        if(sharedContact.size() > 0){
            
            Integer i=0;
            Database.SaveResult[] lsr = Database.insert(sharedContact,false);
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    Database.Error err = sr.getErrors()[0];
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                         &&  err.getMessage().contains('AccessLevel'))){
                             newContactMap.get(sharedContact[i].ContactId).addError('CONTACT :: Unable to grant sharing access due to following exception: '+ err.getMessage());
                         }
                } else{
                    system.debug('Contact Success: '+sr.getId());
                }
                i++;
            }
        }
        
    }
    
    public static void apexShare_Lead_AccountSalesOwnerAccess(Map<Id, Lead> newLeadMap){
        
        List<LeadShare> 	sharedLead					= new List<LeadShare>();
        Set<Id>				userOrGroupIdSet			= new Set<Id>();
        Map<Id, Set<Id>>	leadIdAndShareUsersMap		= new Map<Id, Set<Id>>();
        
        
        List<Lead>	LeadFilteredList 
            = [ SELECT Id, 
               
               OwnerId, Owner.IsActive,
               
               Account__r.OwnerId, Account__r.Owner.IsActive, Account__r.Owner.ManagerId, Account__r.Owner.Manager.IsActive, 
               Account__r.Sales_Owner__c, Account__r.Sales_Owner__r.IsActive, Account__r.Sales_Owner__r.ManagerId, Account__r.Sales_Owner__r.Manager.IsActive,
               
               ID_Owner__c, ID_Owner__r.IsActive,
               
               Account__r.Id_Account_Owner__c, Account__r.Id_Account_Owner__r.IsActive, Account__r.Id_Account_Owner__r.ManagerId, Account__r.Id_Account_Owner__r.Manager.IsActive,  
               Account__r.ID_Sales_Owner__c, Account__r.ID_Sales_Owner__r.IsActive, Account__r.ID_Sales_Owner__r.ManagerId, Account__r.ID_Sales_Owner__r.Manager.IsActive
               
               FROM Lead WHERE 
               Id IN :newLeadMap.keySet() ];
        system.debug('LeadFilteredList: '+leadIdAndShareUsersMap);
        
        for(
            LeadShare thisRec : [ SELECT Id, LeadId, UserOrGroupId, IsDeleted 
                                 FROM LeadShare WHERE 
                                 LeadId IN :newLeadMap.keySet() AND 
                                 IsDeleted = FALSE  AND 
                                 RowCause != 'ImplicitParent' ]
        ){
            
            if(leadIdAndShareUsersMap.containsKey(thisRec.LeadId)){
                leadIdAndShareUsersMap.get(thisRec.LeadId).add(thisRec.UserOrGroupId);
            } else{
                leadIdAndShareUsersMap.put(thisRec.LeadId, new Set<Id>{thisRec.UserOrGroupId});
            }
        }
        system.debug('LeadIdAndShareUsersMap: '+leadIdAndShareUsersMap);
        
        
        
        for(Lead thisRec : LeadFilteredList){
            
            /**	Lead > Owner > Manager	**/
            
            /**	Lead > Account > ID_Owner__c	**/
            if(thisRec.ID_Owner__c != NULL && thisRec.ID_Owner__r.IsActive){
                
                System.debug('I am Account ID Owner Block');
                if(leadIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !leadIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.ID_Owner__c) && !userOrGroupIdSet.contains(thisRec.ID_Owner__c) ){
                        
                        LeadShare ownerShare = new LeadShare(
                            LeadId 			= thisRec.Id,
                            UserOrGroupId 			= thisRec.ID_Owner__c,
                            LeadAccessLevel	= 'Edit',
                            RowCause				= Schema.LeadShare.RowCause.Manual
                        );
                        sharedLead.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.ID_Owner__c);
                    }
                }
            }
            
            
            /**	Lead > Account > Owner	**/
            if(thisRec.Account__r.OwnerId != NULL && thisRec.Owner.IsActive){
                if(leadIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !leadIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account__r.OwnerId) && !userOrGroupIdSet.contains(thisRec.Account__r.OwnerId) ){
                        
                        LeadShare ownerShare = new LeadShare(
                            LeadId 			= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account__r.OwnerId,
                            LeadAccessLevel	= 'Edit',
                            RowCause				= Schema.LeadShare.RowCause.Manual
                        );
                        sharedLead.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account__r.OwnerId);
                    }
                }
            }
            
            /**	Lead > Account > Owner > Manager	**/
            if(thisRec.Account__r.Owner.ManagerId != NULL && thisRec.Account__r.Owner.Manager.IsActive){
                if(leadIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !leadIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account__r.Owner.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account__r.Owner.ManagerId) ){
                        
                        LeadShare ownerShare = new LeadShare(
                            LeadId 			= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account__r.Owner.ManagerId,
                            LeadAccessLevel	= 'Edit',
                            RowCause				= Schema.LeadShare.RowCause.Manual
                        );
                        sharedLead.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account__r.Owner.ManagerId);
                    }
                }
            }
            
            /**	Lead > Account > Sales_Owner__c	**/
            if(thisRec.Account__r.Sales_Owner__c != NULL && thisRec.Account__r.Sales_Owner__r.IsActive){
                if(leadIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !leadIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account__r.Sales_Owner__c) && !userOrGroupIdSet.contains(thisRec.Account__r.Sales_Owner__c) ){
                        
                        LeadShare ownerShare = new LeadShare(
                            LeadId 			= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account__r.Sales_Owner__c,
                            LeadAccessLevel	= 'Edit',
                            RowCause				= Schema.LeadShare.RowCause.Manual
                        );
                        sharedLead.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account__r.Sales_Owner__c);
                    }
                }
            }
            
            /**	Lead > Account > Sales_Owner__c > Manager	**/
            if(thisRec.Account__r.Sales_Owner__r.ManagerId != NULL && thisRec.Account__r.Sales_Owner__r.Manager.IsActive){
                if(leadIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !leadIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account__r.Sales_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account__r.Sales_Owner__r.ManagerId) ){
                        
                        LeadShare ownerShare = new LeadShare(
                            LeadId 			= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account__r.Sales_Owner__r.ManagerId,
                            LeadAccessLevel	= 'Edit',
                            RowCause				= Schema.LeadShare.RowCause.Manual
                        );
                        sharedLead.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account__r.Sales_Owner__r.ManagerId);
                    }
                }
            }
            
            
            
            /**	Contact > Owner > Id Account Owner	**/
            if(thisRec.Account__r.Id_Account_Owner__c != NULL && thisRec.Account__r.Id_Account_Owner__r.IsActive){
                if(leadIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !leadIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account__r.Id_Account_Owner__c) && !userOrGroupIdSet.contains(thisRec.Account__r.Id_Account_Owner__c) ){
                        
                        LeadShare ownerShare = new LeadShare(
                            LeadId 			= thisRec.Id,
                            UserOrGroupId 		= thisRec.Account__r.Id_Account_Owner__c,
                            LeadAccessLevel	= 'Edit',
                            RowCause			= Schema.LeadShare.RowCause.Manual
                        );
                        sharedLead.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account__r.Id_Account_Owner__c);
                    }
                }
            }
            
            /**	Contact > Owner > Id Account Owner > Manager	**/
            if(thisRec.Account__r.Id_Account_Owner__r.ManagerId != NULL && thisRec.Account__r.Id_Account_Owner__r.Manager.IsActive){
                if(leadIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !leadIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account__r.Id_Account_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account__r.Id_Account_Owner__r.ManagerId) ){
                        
                        LeadShare ownerShare = new LeadShare(
                            LeadId 			= thisRec.Id,
                            UserOrGroupId 		= thisRec.Account__r.Id_Account_Owner__r.ManagerId,
                            LeadAccessLevel	= 'Edit',
                            RowCause			= Schema.LeadShare.RowCause.Manual
                        );
                        sharedLead.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account__r.Id_Account_Owner__r.ManagerId);
                    }
                }
            }
            
            /**	Contact > Owner > Id Account Owner	**/
            if(thisRec.Account__r.ID_Sales_Owner__c != NULL && thisRec.Account__r.ID_Sales_Owner__r.IsActive){
                if(leadIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !leadIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account__r.ID_Sales_Owner__c) && !userOrGroupIdSet.contains(thisRec.Account__r.ID_Sales_Owner__c) ){
                        
                        LeadShare ownerShare = new LeadShare(
                            LeadId 			= thisRec.Id,
                            UserOrGroupId 		= thisRec.Account__r.ID_Sales_Owner__c,
                            LeadAccessLevel	= 'Edit',
                            RowCause			= Schema.LeadShare.RowCause.Manual
                        );
                        sharedLead.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account__r.ID_Sales_Owner__c);
                    }
                }
            }
            
            /**	Contact > Owner > Id Account Owner > Manager	**/
            if(thisRec.Account__r.ID_Sales_Owner__r.ManagerId != NULL && thisRec.Account__r.ID_Sales_Owner__r.Manager.IsActive){
                if(leadIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !leadIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account__r.ID_Sales_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account__r.ID_Sales_Owner__r.ManagerId) ){
                        
                        LeadShare ownerShare = new LeadShare(
                            LeadId 			= thisRec.Id,
                            UserOrGroupId 		= thisRec.Account__r.ID_Sales_Owner__r.ManagerId,
                            LeadAccessLevel	= 'Edit',
                            RowCause			= Schema.LeadShare.RowCause.Manual
                        );
                        sharedLead.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account__r.ID_Sales_Owner__r.ManagerId);
                    }
                }
            }
            
            
        }
        system.debug('sharedLead: '+sharedLead);
        
        if(sharedLead.size() > 0){
            
            Integer i=0;
            Database.SaveResult[] lsr = Database.insert(sharedLead,false);
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    Database.Error err = sr.getErrors()[0];
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                         &&  err.getMessage().contains('AccessLevel'))){
                             newLeadMap.get(sharedLead[i].LeadId).addError('LEAD :: Unable to grant sharing access due to following exception: '+ err.getMessage());
                         }
                } else{
                    system.debug('Lead Success: '+sr.getId());
                }
                i++;
            }
        }
        
    }
    
    public static void apexShare_Opportunity_AccountSalesOwnerAccess(Map<Id, Opportunity> newOpportunitieMap){
        
        Id 						devRecordTypeId 					= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Net New - ID').getRecordTypeId();
        List<OpportunityShare> 	sharedOpportunity					= new List<OpportunityShare>();
        Set<Id>					userOrGroupIdSet					= new Set<Id>();
        Map<Id, Set<Id>>		opportunityIdAndShareUsersMap		= new Map<Id, Set<Id>>();
        
        
        List<Opportunity>	opportunityFilteredList 
            = [ SELECT Id, RecordTypeId,
               
               OwnerId, Owner.IsActive, Owner.ManagerId, Owner.Manager.IsActive, 
               
               Account.OwnerId, Account.Owner.IsActive, Account.Owner.ManagerId, Account.Owner.Manager.IsActive, 
               Account.Sales_Owner__c, Account.Sales_Owner__r.IsActive, Account.Sales_Owner__r.ManagerId, Account.Sales_Owner__r.Manager.IsActive,
               
               Account.Id_Account_Owner__c, Account.Id_Account_Owner__r.IsActive, Account.Id_Account_Owner__r.ManagerId, Account.Id_Account_Owner__r.Manager.IsActive,  
               Account.ID_Sales_Owner__c, Account.ID_Sales_Owner__r.IsActive, Account.ID_Sales_Owner__r.ManagerId, Account.ID_Sales_Owner__r.Manager.IsActive
               
               FROM Opportunity WHERE 
               Id IN :newOpportunitieMap.keySet() ];
        system.debug('opportunityFilteredList: '+opportunityFilteredList);
        
        for(
            OpportunityShare thisRec : [ SELECT Id, OpportunityId, UserOrGroupId, IsDeleted 
                                        FROM OpportunityShare WHERE 
                                        OpportunityId IN :newOpportunitieMap.keySet() AND 
                                        IsDeleted = FALSE  AND 
                                        RowCause != 'ImplicitParent' ]
        ){
            
            if(opportunityIdAndShareUsersMap.containsKey(thisRec.OpportunityId)){
                opportunityIdAndShareUsersMap.get(thisRec.OpportunityId).add(thisRec.UserOrGroupId);
            } else{
                opportunityIdAndShareUsersMap.put(thisRec.OpportunityId, new Set<Id>{thisRec.UserOrGroupId});
            }
        }
        system.debug('opportunityIdAndShareUsersMap: '+opportunityIdAndShareUsersMap);
        
        
        
        for(Opportunity thisRec : opportunityFilteredList){
            
            /**	Opportunity > Owner > Manager	**/
            if(thisRec.Owner.ManagerId != NULL && thisRec.Owner.Manager.IsActive){
                if(opportunityIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !opportunityIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Owner.ManagerId) && !userOrGroupIdSet.contains(thisRec.Owner.ManagerId) ){
                        
                        OpportunityShare ownerShare = new OpportunityShare(
                            OpportunityId 			= thisRec.Id,
                            UserOrGroupId 			= thisRec.Owner.ManagerId,
                            OpportunityAccessLevel	= 'Edit',
                            RowCause				= Schema.OpportunityShare.RowCause.Manual
                        );
                        sharedOpportunity.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Owner.ManagerId);
                    }
                }
            }
            
            /**	Opportunity > Account > Owner	**/
            if(thisRec.Account.OwnerId != NULL && thisRec.Owner.IsActive){
                if(opportunityIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !opportunityIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.OwnerId) && !userOrGroupIdSet.contains(thisRec.Account.OwnerId) ){
                        
                        OpportunityShare ownerShare = new OpportunityShare(
                            OpportunityId 			= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account.OwnerId,
                            OpportunityAccessLevel	= 'Edit',
                            RowCause				= Schema.OpportunityShare.RowCause.Manual
                        );
                        sharedOpportunity.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.OwnerId);
                    }
                }
            }
            
            /**	Opportunity > Account > Owner > Manager	**/
            if(thisRec.Account.Owner.ManagerId != NULL && thisRec.Account.Owner.Manager.IsActive){
                if(opportunityIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !opportunityIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Owner.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account.Owner.ManagerId) ){
                        
                        OpportunityShare ownerShare = new OpportunityShare(
                            OpportunityId 			= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account.Owner.ManagerId,
                            OpportunityAccessLevel	= 'Edit',
                            RowCause				= Schema.OpportunityShare.RowCause.Manual
                        );
                        sharedOpportunity.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.Owner.ManagerId);
                    }
                }
            }
            
            /**	Opportunity > Account > Sales_Owner__c	**/
            if(thisRec.Account.Sales_Owner__c != NULL && thisRec.Account.Sales_Owner__r.IsActive){
                if(opportunityIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !opportunityIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Sales_Owner__c) && !userOrGroupIdSet.contains(thisRec.Account.Sales_Owner__c) ){
                        
                        OpportunityShare ownerShare = new OpportunityShare(
                            OpportunityId 			= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account.Sales_Owner__c,
                            OpportunityAccessLevel	= 'Edit',
                            RowCause				= Schema.OpportunityShare.RowCause.Manual
                        );
                        sharedOpportunity.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.Sales_Owner__c);
                    }
                }
            }
            
            /**	Opportunity > Account > Sales_Owner__c > Manager	**/
            if(thisRec.Account.Sales_Owner__r.ManagerId != NULL && thisRec.Account.Sales_Owner__r.Manager.IsActive){
                if(opportunityIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !opportunityIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Sales_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account.Sales_Owner__r.ManagerId) ){
                        
                        OpportunityShare ownerShare = new OpportunityShare(
                            OpportunityId 			= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account.Sales_Owner__r.ManagerId,
                            OpportunityAccessLevel	= 'Edit',
                            RowCause				= Schema.OpportunityShare.RowCause.Manual
                        );
                        sharedOpportunity.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.Sales_Owner__r.ManagerId);
                    }
                }
            }
            
            
            if(thisRec.RecordTypeId == devRecordTypeId){
                
                /**	Contact > Owner > Id Account Owner	**/
                if(thisRec.Account.Id_Account_Owner__c != NULL && thisRec.Account.Id_Account_Owner__r.IsActive){
                    if(opportunityIdAndShareUsersMap.containsKey(thisRec.Id)){
                        if( !opportunityIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Id_Account_Owner__c) && !userOrGroupIdSet.contains(thisRec.Account.Id_Account_Owner__c) ){
                            
                            OpportunityShare ownerShare = new OpportunityShare(
                                OpportunityId 			= thisRec.Id,
                                UserOrGroupId 		= thisRec.Account.Id_Account_Owner__c,
                                OpportunityAccessLevel	= 'Edit',
                                RowCause			= Schema.OpportunityShare.RowCause.Manual
                            );
                            sharedOpportunity.add(ownerShare);
                            userOrGroupIdSet.add(thisRec.Account.Id_Account_Owner__c);
                        }
                    }
                }
                
                /**	Contact > Owner > Id Account Owner > Manager	**/
                if(thisRec.Account.Id_Account_Owner__r.ManagerId != NULL && thisRec.Account.Id_Account_Owner__r.Manager.IsActive){
                    if(opportunityIdAndShareUsersMap.containsKey(thisRec.Id)){
                        if( !opportunityIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Id_Account_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account.Id_Account_Owner__r.ManagerId) ){
                            
                            OpportunityShare ownerShare = new OpportunityShare(
                                OpportunityId 			= thisRec.Id,
                                UserOrGroupId 		= thisRec.Account.Id_Account_Owner__r.ManagerId,
                                OpportunityAccessLevel	= 'Edit',
                                RowCause			= Schema.OpportunityShare.RowCause.Manual
                            );
                            sharedOpportunity.add(ownerShare);
                            userOrGroupIdSet.add(thisRec.Account.Id_Account_Owner__r.ManagerId);
                        }
                    }
                }
                
                /**	Contact > Owner > Id Account Owner	**/
                if(thisRec.Account.ID_Sales_Owner__c != NULL && thisRec.Account.ID_Sales_Owner__r.IsActive){
                    if(opportunityIdAndShareUsersMap.containsKey(thisRec.Id)){
                        if( !opportunityIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.ID_Sales_Owner__c) && !userOrGroupIdSet.contains(thisRec.Account.ID_Sales_Owner__c) ){
                            
                            OpportunityShare ownerShare = new OpportunityShare(
                                OpportunityId 			= thisRec.Id,
                                UserOrGroupId 		= thisRec.Account.ID_Sales_Owner__c,
                                OpportunityAccessLevel	= 'Edit',
                                RowCause			= Schema.OpportunityShare.RowCause.Manual
                            );
                            sharedOpportunity.add(ownerShare);
                            userOrGroupIdSet.add(thisRec.Account.ID_Sales_Owner__c);
                        }
                    }
                }
                
                /**	Contact > Owner > Id Account Owner > Manager	**/
                if(thisRec.Account.ID_Sales_Owner__r.ManagerId != NULL && thisRec.Account.ID_Sales_Owner__r.Manager.IsActive){
                    if(opportunityIdAndShareUsersMap.containsKey(thisRec.Id)){
                        if( !opportunityIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.ID_Sales_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account.ID_Sales_Owner__r.ManagerId) ){
                            
                            OpportunityShare ownerShare = new OpportunityShare(
                                OpportunityId 			= thisRec.Id,
                                UserOrGroupId 		= thisRec.Account.ID_Sales_Owner__r.ManagerId,
                                OpportunityAccessLevel	= 'Edit',
                                RowCause			= Schema.OpportunityShare.RowCause.Manual
                            );
                            sharedOpportunity.add(ownerShare);
                            userOrGroupIdSet.add(thisRec.Account.ID_Sales_Owner__r.ManagerId);
                        }
                    }
                }
                
            }
        
        }
        system.debug('sharedOpportunity: '+sharedOpportunity);
        
        if(sharedOpportunity.size() > 0){
            
            Integer i=0;
            Database.SaveResult[] lsr = Database.insert(sharedOpportunity,false);
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    Database.Error err = sr.getErrors()[0];
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                         &&  err.getMessage().contains('AccessLevel'))){
                             newOpportunitieMap.get(sharedOpportunity[i].OpportunityId).addError('OPPORTUNITY :: Unable to grant sharing access due to following exception: '+ err.getMessage());
                         }
                } else{
                    system.debug('OPPORTUNITY Success: '+sr.getId());
                }
                i++;
            }
        }
        
    }
    
    public static void apexShare_Asset_AccountSalesOwnerAccess(Map<Id, Asset> newAssetMap){
        
        List<AssetShare> 	sharedAssets					= new List<AssetShare>();
        Set<Id>				userOrGroupIdSet					= new Set<Id>();
        Map<Id, Set<Id>>	assetIdAndShareUsersMap		= new Map<Id, Set<Id>>();
        
        
        List<Asset>	assetFilteredList 
            = [ SELECT Id, 
               
               OwnerId, Owner.IsActive, Owner.ManagerId, Owner.Manager.IsActive, 
               
               Account.OwnerId, Account.Owner.IsActive, Account.Owner.ManagerId, Account.Owner.Manager.IsActive, 
               Account.Sales_Owner__c, Account.Sales_Owner__r.IsActive, Account.Sales_Owner__r.ManagerId, Account.Sales_Owner__r.Manager.IsActive,
               Account.Onboarding_Owner__c, Account.Onboarding_Owner__r.IsActive
               
               FROM Asset WHERE 
               Id IN :newAssetMap.keySet() ];
        system.debug('assetFilteredList: '+assetFilteredList);
        
        for(
            AssetShare thisRec : [ SELECT Id, AssetId, UserOrGroupId, IsDeleted 
                                  FROM AssetShare WHERE 
                                  AssetId IN :newAssetMap.keySet() AND 
                                  IsDeleted = FALSE  AND 
                                  RowCause != 'ImplicitParent' ]
        ){
            
            if(assetIdAndShareUsersMap.containsKey(thisRec.AssetId)){
                assetIdAndShareUsersMap.get(thisRec.AssetId).add(thisRec.UserOrGroupId);
            } else{
                assetIdAndShareUsersMap.put(thisRec.AssetId, new Set<Id>{thisRec.UserOrGroupId});
            }
        }
        system.debug('assetIdAndShareUsersMap: '+assetIdAndShareUsersMap);
        
        
        for(Asset thisRec : assetFilteredList){
            
            /**	Asset > Owner > Manager	**/
            if(thisRec.Owner.ManagerId != NULL && thisRec.Owner.Manager.IsActive){
                if(assetIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !assetIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Owner.ManagerId) && !userOrGroupIdSet.contains(thisRec.Owner.ManagerId) ){
                        
                        AssetShare ownerShare 		= new AssetShare(
                            AssetId 				= thisRec.Id,
                            UserOrGroupId 			= thisRec.Owner.ManagerId,
                            AssetAccessLevel		= 'Edit',
                            RowCause				= Schema.AssetShare.RowCause.Manual
                        );
                        sharedAssets.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Owner.ManagerId);
                    }
                }
            }
            
            /**	Asset > Account > Owner	**/
            if(thisRec.Account.OwnerId != NULL && thisRec.Owner.IsActive){
                if(assetIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !assetIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.OwnerId) && !userOrGroupIdSet.contains(thisRec.Account.OwnerId) ){
                        
                        AssetShare ownerShare 		= new AssetShare(
                            AssetId		 			= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account.OwnerId,
                            AssetAccessLevel		= 'Edit',
                            RowCause				= Schema.AssetShare.RowCause.Manual
                        );
                        sharedAssets.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.OwnerId);
                    }
                }
            }
            
            /**	Asset > Account > Owner > Manager	**/
            if(thisRec.Account.Owner.ManagerId != NULL && thisRec.Account.Owner.Manager.IsActive){
                if(assetIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !assetIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Owner.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account.Owner.ManagerId) ){
                        
                        AssetShare ownerShare 		= new AssetShare(
                            AssetId		 			= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account.Owner.ManagerId,
                            AssetAccessLevel		= 'Edit',
                            RowCause				= Schema.AssetShare.RowCause.Manual
                        );
                        sharedAssets.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.Owner.ManagerId);
                    }
                }
            }
            
            /**	Asset > Account > Sales_Owner__c	**/
            if(thisRec.Account.Sales_Owner__c != NULL && thisRec.Account.Sales_Owner__r.IsActive){
                if(assetIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !assetIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Sales_Owner__c) && !userOrGroupIdSet.contains(thisRec.Account.Sales_Owner__c) ){
                        
                        AssetShare ownerShare 		= new AssetShare(
                            AssetId 				= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account.Sales_Owner__c,
                            AssetAccessLevel		= 'Edit',
                            RowCause				= Schema.AssetShare.RowCause.Manual
                        );
                        sharedAssets.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.Sales_Owner__c);
                    }
                }
            }
            
            /**	Asset > Account > Sales_Owner__c > Manager	**/
            if(thisRec.Account.Sales_Owner__r.ManagerId != NULL && thisRec.Account.Sales_Owner__r.Manager.IsActive){
                if(assetIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !assetIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Sales_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.Account.Sales_Owner__r.ManagerId) ){
                        
                        AssetShare ownerShare 		= new AssetShare(
                            AssetId 				= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account.Sales_Owner__r.ManagerId,
                            AssetAccessLevel		= 'Edit',
                            RowCause				= Schema.AssetShare.RowCause.Manual
                        );
                        sharedAssets.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.Sales_Owner__r.ManagerId);
                    }
                }
            }
            
            /**	Asset > Account > Onboarding_Owner__c	**/
            if(thisRec.Account.Onboarding_Owner__c != NULL && thisRec.Account.Onboarding_Owner__r.IsActive){
                if(assetIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !assetIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account.Onboarding_Owner__c) && !userOrGroupIdSet.contains(thisRec.Account.Onboarding_Owner__c) ){
                        
                        AssetShare ownerShare 		= new AssetShare(
                            AssetId 				= thisRec.Id,
                            UserOrGroupId 			= thisRec.Account.Onboarding_Owner__c,
                            AssetAccessLevel		= 'Edit',
                            RowCause				= Schema.AssetShare.RowCause.Manual
                        );
                        sharedAssets.add(ownerShare);
                        userOrGroupIdSet.add(thisRec.Account.Onboarding_Owner__c);
                    }
                }
            }
        }
        system.debug('sharedAssets: '+sharedAssets);
        
        if(sharedAssets.size() > 0){
            Integer i=0;
            Database.SaveResult[] lsr = Database.insert(sharedAssets,false);
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    Database.Error err = sr.getErrors()[0];
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                         &&  err.getMessage().contains('AccessLevel'))){
                             newAssetMap.get(sharedAssets[i].AssetId).addError('ACCOUNT :: Unable to grant sharing access due to following exception: '+ err.getMessage());
                         }
                }
                i++;
            }
        }
        
    }
    
    /**	Sharing Rue for Account Owner & SalesOwner Access: END	**/
    
    
    
    /**	Old Code	**/
    public static void getGenericDetails(){
        
        fieldSalesProfileId	= [ SELECT Id FROM Profile WHERE
                               Name = 'Field Sales Profile' ]?.Id;
        
        /**	Public Group Details		Field Sales Enterprise **/
        for(
            Group thisRec : [ SELECT Id, Name FROM Group WHERE 
                             Name IN ('Field Sales Tax Expert/SME', 'Field Sales Enterprise') ] 
        ){
            
            if(thisRec.Name == 'Field Sales Tax Expert/SME')
                publicGroupId_TaxExpert = thisRec.Id;
            if(thisRec.Name == 'Field Sales Enterprise')
                publicGroupId_Enterprise = thisRec.Id;
        }
        
        /**	Get RecordType Details	**/
        for(
            RecordType thisRec : [ SELECT Id,SobjectType, Name FROM RecordType WHERE 
                                  SobjectType IN ('Account', 'Lead') AND 
                                  Name IN ('Tax Expert', 'Enterprise') ]
        ){
            if(thisRec.Name == 'Tax Expert' && thisRec.SobjectType == 'Account')
                recordTypeId_TaxExpert 		= thisRec.id;
            if(thisRec.Name == 'Enterprise' && thisRec.SobjectType == 'Account')
                recordTypeId_Enterprise 	= thisRec.id;
            if(thisRec.Name == 'Tax Expert' && thisRec.SobjectType == 'Lead')
                recordTypeId_Lead_TaxExpert = thisRec.id;
            if(thisRec.Name == 'Enterprise' && thisRec.SobjectType == 'Lead')
                recordTypeId_Lead_Enterprise = thisRec.id;
        }
        
    }
    
    public static void setAccountSharingRule_FieldSalesProfile(List<Account> newAccounts){
        
        List<AccountShare> 	sharedAccount	= new List<AccountShare>();
        
        for(Account thisRec : newAccounts){
            
            if(
                thisRec.RecordTypeId == recordTypeId_TaxExpert 			||
                ( thisRec.RecordTypeId == recordTypeId_Enterprise	&&
                 thisRec.Enterprise_Type__c == 'SME' )
            ){
                
                AccountShare newrecord = new AccountShare(
                    AccountId 				= thisRec.Id,
                    UserOrGroupId 			= publicGroupId_TaxExpert,
                    AccountAccessLevel 		= 'Edit',
                    OpportunityAccessLevel	= 'Edit',
                    CaseAccessLevel			= 'Edit',
                    RowCause				= 'Manual'
                );
                
                System.debug('I am in SME');
                sharedAccount.add(newrecord);
            }
            
            if(
                thisRec.RecordTypeId == recordTypeId_Enterprise	&&
                thisRec.Enterprise_Type__c == 'Large Enterprise' 
            ){
                
                AccountShare newrecord = new AccountShare(
                    AccountId 				= thisRec.Id,
                    UserOrGroupId 			= publicGroupId_Enterprise,
                    AccountAccessLevel 		= 'Edit',
                    OpportunityAccessLevel	= 'Edit',
                    CaseAccessLevel			= 'Edit',
                    RowCause				= 'Manual'
                );
                
                System.debug('I am in Large');
                sharedAccount.add(newrecord);
            }
        }
        
        try{
            insert sharedAccount;
        } catch(Exception ex){
            system.debug('I am an error in Account Sharing rule Class: '+ex.getMessage());
        }
        
    }
    
    public static void setLeadSharingRule_FieldSalesProfile(List<Lead> newLeads){
        
        List<LeadShare> sharedLead	= new List<LeadShare>();
        
        for(Lead thisRec : newLeads){
            
            if(
                thisRec.RecordTypeId == recordTypeId_TaxExpert 			||
                ( thisRec.RecordTypeId == recordTypeId_Enterprise	&&
                 thisRec.Business_Type__c == 'SME' )
            ){
                
                LeadShare newrecord = new LeadShare(
                    LeadId 					= thisRec.Id,
                    UserOrGroupId 			= recordTypeId_Lead_TaxExpert,
                    LeadAccessLevel 		= 'Edit',
                    RowCause				= 'Manual'
                );
                
                System.debug('I am in SME');
                sharedLead.add(newrecord);
            }
            
            if(
                thisRec.RecordTypeId == recordTypeId_Enterprise	&&
                thisRec.Business_Type__c == 'Large Enterprise' 
            ){
                
                LeadShare newrecord = new LeadShare(
                    LeadId 					= thisRec.Id,
                    UserOrGroupId 			= recordTypeId_Lead_Enterprise,
                    LeadAccessLevel 		= 'Edit',
                    RowCause				= 'Manual'
                );
                
                System.debug('I am in Large');
                sharedLead.add(newrecord);
            }
        }
        
        try{
            insert sharedLead;
        } catch(Exception ex){
            system.debug('I am an error in Account Sharing rule Class: '+ex.getMessage());
        }
    }
    
    
    /**	End of Class	**/    
}