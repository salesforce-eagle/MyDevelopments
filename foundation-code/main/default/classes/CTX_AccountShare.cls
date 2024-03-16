public without sharing class CTX_AccountShare {
    
    Public CTX_AccountShare(Map<Id, Account> newAccountMap){
        
        List<AccountShare> 	sharedAccount				= new List<AccountShare>();
        Set<Id>				userOrGroupIdSet			= new Set<Id>();
        Map<Id, Set<Id>>	accountIdAndShareUsersMap	= new Map<Id, Set<Id>>();
        
        
        for(
            AccountShare thisRec : [ SELECT Id, AccountId, UserOrGroupId, IsDeleted 
                                    FROM AccountShare WHERE 
                                    AccountId IN :newAccountMap.keySet() AND 
                                    IsDeleted = FALSE AND 
                                    RowCause != 'ImplicitParent' ]
        ){
            
            if(accountIdAndShareUsersMap.containsKey(thisRec.AccountId)){
                accountIdAndShareUsersMap.get(thisRec.AccountId).add(thisRec.UserOrGroupId);
            } else{
                accountIdAndShareUsersMap.put(thisRec.AccountId, new Set<Id>{thisRec.UserOrGroupId});
            }
        }
        system.debug('accountIdAndShareUsersMap: '+accountIdAndShareUsersMap);
        
        
        for(
            Account thisRec : [ SELECT Id, 
                               
                               Owner.ManagerId, Owner.Manager.IsActive, 
                               Sales_Owner__c, Sales_Owner__r.IsActive, Sales_Owner__r.ManagerId, Sales_Owner__r.Manager.IsActive,
                               
                               Id_Account_Owner__c, Id_Account_Owner__r.IsActive, Id_Account_Owner__r.ManagerId, Id_Account_Owner__r.Manager.IsActive,
                               ID_Sales_Owner__c, ID_Sales_Owner__r.IsActive, ID_Sales_Owner__r.ManagerId, ID_Sales_Owner__r.Manager.IsActive, 
                               Account_Owner_Cimplifive__c , Account_Owner_Cimplifive__r.IsActive
                               
                               FROM Account WHERE 
                               ( Sales_Owner__c != NULL OR Owner.ManagerId != NULL ) AND  
                               Id IN :newAccountMap.keySet() ]
        ){
            
            /**	Account > Owner > ManagerId	**/
            if(thisRec.Owner.ManagerId != NULL && thisRec.Owner.Manager.IsActive){
                if(accountIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !accountIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Owner.ManagerId) && !userOrGroupIdSet.contains(thisRec.Owner.ManagerId) ){
                        
                        sharedAccount.add(
                            CTX_ApexRecordSharingHelper.create_AccountShareRecord(thisRec.Id, thisRec.Owner.ManagerId)
                        );
                        userOrGroupIdSet.add(thisRec.Owner.ManagerId);
                    }
                }
            }
            
            /**	Account > Sales_Owner__c	**/
            if(thisRec.OwnerId != thisRec.Sales_Owner__c){
                if(thisRec.Sales_Owner__c != NULL && thisRec.Sales_Owner__r.IsActive){
                    if( !accountIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Sales_Owner__c) && !userOrGroupIdSet.contains(thisRec.Sales_Owner__c) ){
                        
                        sharedAccount.add(
                            CTX_ApexRecordSharingHelper.create_AccountShareRecord(thisRec.Id, thisRec.Sales_Owner__c)
                        );
                        userOrGroupIdSet.add(thisRec.Sales_Owner__c);
                    }
                }
            }
            
       
            
            /**	Account > Sales_Owner__c > ManagerId	**/
            if(thisRec.Sales_Owner__r.ManagerId != NULL && thisRec.Sales_Owner__r.Manager.IsActive){
                if( !accountIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Sales_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.Sales_Owner__r.ManagerId) ){
                    
                    sharedAccount.add(
                        CTX_ApexRecordSharingHelper.create_AccountShareRecord(thisRec.Id, thisRec.Sales_Owner__r.ManagerId)
                    );
                    userOrGroupIdSet.add(thisRec.Sales_Owner__r.ManagerId);
                }
            }
            
            /**	Account > Account_owner_Cimplifive__c	**/
            if(thisRec.Account_Owner_Cimplifive__c != NULL && thisRec.Account_Owner_Cimplifive__r.IsActive){
                if( !accountIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Account_Owner_Cimplifive__c) && !userOrGroupIdSet.contains(thisRec.Account_Owner_Cimplifive__c) ){
                    
                    sharedAccount.add(
                        CTX_ApexRecordSharingHelper.create_AccountShareRecord(thisRec.Id, thisRec.Account_Owner_Cimplifive__c)
                    );
                    userOrGroupIdSet.add(thisRec.Account_Owner_Cimplifive__c);
                }
            }
            
            /**	Account > Id_Account_Owner__c	
            if(thisRec.Id_Account_Owner__c != NULL && thisRec.Id_Account_Owner__r.IsActive){
                if(accountIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !accountIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Id_Account_Owner__c) && !userOrGroupIdSet.contains(thisRec.Id_Account_Owner__c) ){
                        
                        sharedAccount.add(
                        CTX_ApexRecordSharingHelper.create_AccountShareRecord(thisRec.Id, thisRec.Id_Account_Owner__c)
                    );
                        userOrGroupIdSet.add(thisRec.Id_Account_Owner__c);
                    }
                }
            }
            
            /**	Account > Id_Account_Owner__c > ManagerId	
            if(thisRec.Id_Account_Owner__r.ManagerId != NULL && thisRec.Id_Account_Owner__r.Manager.IsActive){
                if(accountIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !accountIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.Id_Account_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.Id_Account_Owner__r.ManagerId) ){
                        
                        sharedAccount.add(
                        CTX_ApexRecordSharingHelper.create_AccountShareRecord(thisRec.Id, thisRec.Id_Account_Owner__r.ManagerId)
                    );
                        userOrGroupIdSet.add(thisRec.Id_Account_Owner__r.ManagerId);
                    }
                }
            }
            
            /**	Account > ID_Sales_Owner__c	
            if(thisRec.ID_Sales_Owner__c != NULL && thisRec.ID_Sales_Owner__r.IsActive){
                if(accountIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !accountIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.ID_Sales_Owner__c) && !userOrGroupIdSet.contains(thisRec.ID_Sales_Owner__c) ){
                        
                        sharedAccount.add(
                        CTX_ApexRecordSharingHelper.create_AccountShareRecord(thisRec.Id, thisRec.ID_Sales_Owner__c)
                    );
                        userOrGroupIdSet.add(thisRec.ID_Sales_Owner__c);
                    }
                }
            }
            
            /**	Account > ID_Sales_Owner__c > ManagerId	
            if(thisRec.ID_Sales_Owner__r.ManagerId != NULL && thisRec.ID_Sales_Owner__r.Manager.IsActive){
                if(accountIdAndShareUsersMap.containsKey(thisRec.Id)){
                    if( !accountIdAndShareUsersMap.get(thisRec.Id).contains(thisRec.ID_Sales_Owner__r.ManagerId) && !userOrGroupIdSet.contains(thisRec.ID_Sales_Owner__r.ManagerId) ){
                        
                        sharedAccount.add(
                        CTX_ApexRecordSharingHelper.create_AccountShareRecord(thisRec.Id, thisRec.ID_Sales_Owner__r.ManagerId)
                    );
                        userOrGroupIdSet.add(thisRec.ID_Sales_Owner__r.ManagerId);
                    }
                }
            }	**/
            
        }
        system.debug('CTX_ApexRecordSharing sharedAccount: '+sharedAccount);
        
        if(sharedAccount.size() > 0){
            
            Id 						classId 	= [SELECT Id FROM Logger__c WHERE 
                                                   Apex_Class__c = 'CTX_AccountShare' ]?.Id;
            Integer 				i			= 0;
            Database.SaveResult[] 	lsr 		= Database.insert(sharedAccount,false);
            Set<Logger__c>			loggerEntry	= new Set<Logger__c>();
            
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    
                    for(Database.Error err : sr.getErrors()){
                        
                        if(
                            !(
                                err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION	&&  
                                err.getMessage().contains('AccessLevel')
                            )
                        ){
                            newAccountMap.get(sharedAccount[i].AccountId).addError(
                                'ACCOUNT :: CTX_AccountShare - Unable to grant sharing access due to following exception: '+ err.getMessage()
                            );
                            
                            loggerEntry.add(
                                CTX_LoggerImplementation.createLoggerInstance(
                                    err.getMessage(), 
                                    classId, 
                                    'CTX_AccountShare', 
                                    'Constructor', 
                                    'Access Issue', 
                                    newAccountMap.get(sharedAccount[i].AccountId).Id,
                                    'Account'
                                )
                            );
                        } else{
                            loggerEntry.add(
                                CTX_LoggerImplementation.createLoggerInstance(
                                    err.getMessage(), 
                                    classId, 
                                    'CTX_AccountShare', 
                                    'Constructor', 
                                    'DML Issue',
                                    newAccountMap.get(sharedAccount[i].AccountId).Id,
                                    'Account')
                            );
                        }
                    }
                }
                i++;
            }
            
            if(loggerEntry.size() > 0){
                
                try{
                    insert (new List<Logger__c>(loggerEntry));
                }catch(Exception ex){
                    system.debug('CTX_AccountShare Looger Creation Issue: '+ex.getMessage());
                }
            }
        }
    }
}