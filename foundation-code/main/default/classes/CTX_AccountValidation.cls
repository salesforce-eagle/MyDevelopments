public class CTX_AccountValidation {
    
    public static void getEnterpriseTurnOver(List<Account> newAccounts, Map<Id, Account> oldAccountsMap){
        
        List<String>	turnOverList 	= new List<String>();
        Id 				accountRecordId = [ SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Enterprise' ]?.Id;
        
        if(System.Label.Account_Turnover != NULL)
            turnOverList.addAll(System.Label.Account_Turnover.split(','));  
        
        
        for(Account thisRec : newAccounts){
            
            Boolean isInternationalLead = FALSE;
        if( thisRec.Country_of_Origin__c != NULL ){
            isInternationalLead = thisRec.Country_of_Origin__c != 'India' ? TRUE : FALSE;
        }
            
            system.debug('Account recordType Id: '+thisRec.RecordTypeId);
            if( 
                thisRec.RecordTypeId == accountRecordId && 
                !isInternationalLead 
            ){
                
                system.debug('Account Enterprise RecordType Block: '+accountRecordId);
                if( turnOverList.size() > 0 && turnOverList.contains(thisRec.Turnover__c) ){
                    thisRec.Enterprise_Type__c = 'SME'; 
                } else{
                    thisRec.Enterprise_Type__c = 'Large Enterprise';
                }
                
                if(thisRec.Enterprise_Type__c == 'Large Enterprise' && thisRec.PAN__c == NULL && (thisRec.Country_of_Origin__c == 'India' || thisRec.Country_of_Origin__c == '')){
                    thisRec.addError('PAN is mandatory for Enterprise grater than 25cr.');
                }
            }
        }
        
    }
    
    public static void changeLeadOwnerBasedOnSalesOwner(List<Account> newAccounts, Map<Id, Account> oldAccountsMap){
        
        Map<Id, Id> ownerIdPANMap = new Map<Id, Id>();
        
        for(Account thisAcc : newAccounts){
            if(thisAcc.PAN__c != NULL)
                ownerIdPANMap.put(thisAcc.Id, thisAcc.Sales_Owner__c);
        }
        
        system.debug('ownerIdPANMap: '+ownerIdPANMap);
        if(ownerIdPANMap.size() > 0){
            
            List<Lead> updatesList = new List<Lead>();
            
            if(updatesList != NULL){
                for(
                    Lead thisRec : [ SELECT Id, OwnerId, PAN__c, Account__c 
                                    FROM Lead WHERE 
                                    Account__c In :ownerIdPANMap.keySet() ]
                ){
                    
                    system.debug('ownerIdPANMap.get(thisRec.Account__c): '+ownerIdPANMap.get(thisRec.Account__c));
                    thisRec.OwnerId = ownerIdPANMap.get(thisRec.Account__c);
                    updatesList.add(thisRec);
                }
            }
            
            try{
                update updatesList;
            } catch(Exception ex){
                system.debug('Error in CTX_AccountValidation in Lead Owner Update: '+ex.getMessage());
            }
        }
    }
    
    public static void updateAccountType(List<Account> accountList){
        
        Set<Id> 			accountIds 				= new Set<Id>();
        Map<Id, Integer> 	accountIdWithAssetCount = new Map<Id, Integer>();
        
        for(Account thisAccount : accountList){
            accountIds.add(thisAccount.Id);
        }
        
        AggregateResult[] 	assetCountResult 		= [ SELECT AccountId, Count(Id) assetCount FROM Asset WHERE AccountId in :accountIds GROUP BY AccountId];
        
        system.debug('assetCountResult' + assetCountResult);
        
        for(AggregateResult ar : assetCountResult){
            
            accountIdWithAssetCount.put((Id)ar.get('AccountId'),(Integer)ar.get('assetCount'));
        }
        
        system.debug('updateAccountType Entered');
        system.debug('accountIdWithAssetCount' + accountIdWithAssetCount);
        
        
        for(Account thisAccount : accountList){
            
            system.debug('accountIdWithAssetCount.get(thisAccount.Id) : ' 		+accountIdWithAssetCount.get(thisAccount.Id));
            system.debug('thisAccount.Total_no_of_Opportunities_C__c : ' 		+thisAccount.Total_no_of_Opportunities_C__c);
            system.debug('thisAccount.No_of_closed_lost_opportunities__c : '	+thisAccount.No_of_closed_lost_opportunities__c);
            system.debug('thisAccount.No_of_closed_merge_opportunities__c : ' 	+thisAccount.No_of_closed_merge_opportunities__c);
            system.debug('thisAccount.Total_Open_Opportunities__c : ' 			+thisAccount.Total_Open_Opportunities__c);
            system.debug('Before thisAccount.Account_Type__c : '				+thisAccount.Account_Type__c);
            
            if(
                thisAccount.Total_no_of_Opportunities_C__c != NULL 		&& 
                (
                    accountIdWithAssetCount.get(thisAccount.Id) == NULL || 
                    accountIdWithAssetCount.get(thisAccount.Id) == 0
                ) 														&& 
                thisAccount.Total_no_of_Opportunities_C__c == 0
            ){
                thisAccount.Account_Type__c = 'No assets-No opportunities(NAL)';
            } else if(
                thisAccount.No_of_closed_lost_opportunities__c != NULL 	&& 
                thisAccount.No_of_closed_merge_opportunities__c != NULL && 
                (
                    accountIdWithAssetCount.get(thisAccount.Id) == NULL || 
                    accountIdWithAssetCount.get(thisAccount.Id) == 0
                ) 														&& 
                (
                    thisAccount.No_of_closed_lost_opportunities__c > 0 	||  
                    thisAccount.No_of_closed_merge_opportunities__c > 0
                ) 														&& 
                thisAccount.Total_Open_Opportunities__c == 0
            ){
                thisAccount.Account_Type__c = 'No assets - Closed opportunities(NAL-lost)';
            } else if(
                thisAccount.Total_Open_Opportunities__c != NULL 		&& 
                (
                    accountIdWithAssetCount.get(thisAccount.Id) == NULL || 
                    accountIdWithAssetCount.get(thisAccount.Id) == 0
                ) 														&& 
                thisAccount.Total_Open_Opportunities__c > 0 
            ){
                thisAccount.Account_Type__c = 'No assets - Open opportunities(NAL-actively pitching)';
            }else{
                
                system.debug('Else Entered');
                thisAccount.Account_Type__c = 'Others';
            }
        }
    }
    
    public static void salesAndAccountOwnerMap(List<Account> newAccounts, Map<Id, Account> oldAccountsMap){
        
        Map<Id, Boolean>	ownershipCheck 			= new Map<Id, Boolean>();
        Map<Id, Boolean> 	salesOwnershipCheck 	= new Map<Id, Boolean>();
        Map<Id, Integer> 	salesOwnerCount			= new Map<Id, Integer>();
        
        for(Account thisRec : newAccounts){
            
            ownershipCheck.put(thisRec.OwnerId, NULL);
            salesOwnerCount.put(thisRec.OwnerId, NULL);
        }
        
        /**	Problmatic Query hitting Query Limit of 50001	**/
        Map<Id, Account> filterAccountMap = new Map<Id, Account>(
            [ SELECT Id, OwnerId, Owner.Name, 
             Sales_Owner__c, Sales_Owner__r.Sales_Owner_Threshold__c, 
             Sales_Owner__r.Name, Owner.Sales_Owner_Threshold__c,
             Account_Owner_Department__c 
             
             FROM Account WHERE 
             ( Sales_Owner__c IN :salesOwnerCount.keySet() AND 
              ( NOT Sales_Owner_Department__c IN ('Customer Success Team', 'KAM', 'PSU', 'VLC', 'Startup') )
             )  LIMIT :Integer.ValueOf(Label.AccountValidationQueryLimit)  
            ] 
        );
        
        system.debug('filterAccountMap.values(): '+filterAccountMap.values().size());
        for( Account thisAcc : filterAccountMap.values() ){
            if(
                thisAcc.Sales_Owner__r.Sales_Owner_Threshold__c != NULL && 
                thisAcc.Sales_Owner__r.Sales_Owner_Threshold__c != 0
            ){
                if(salesOwnerCount.containsKey(thisAcc.Sales_Owner__c)){
                    Integer tempVal = salesOwnerCount.get(thisAcc.Sales_Owner__c) != NULL ? salesOwnerCount.get(thisAcc.Sales_Owner__c) : 0;
                    salesOwnerCount.put(thisAcc.Sales_Owner__c, tempVal+1);
                } else{
                    salesOwnerCount.put(thisAcc.Sales_Owner__c, 1);
                }
            }
        }
        
        system.debug('salesOwnerCount: '+salesOwnerCount);
        for(
            User thisRec : [ SELECT Id, Department, Username, Sales_Owner_Threshold__c  
                            FROM User WHERE 
                            Id IN :ownershipCheck.keySet() OR 
                            Id IN : salesOwnerCount.keySet() ]
        ){
            
            if(salesOwnerCount.containsKey(thisRec.Id)){
                system.debug('thisRec.Sales_Owner_Threshold__c: '+thisRec.Sales_Owner_Threshold__c); 
                if(thisRec.Sales_Owner_Threshold__c != 0 || thisRec.Sales_Owner_Threshold__c != NULL){
                    if(thisRec.Sales_Owner_Threshold__c <= salesOwnerCount.get(thisRec.Id) ){
                        salesOwnershipCheck.put(thisRec.Id, TRUE);
                    } else{
                        salesOwnershipCheck.put(thisRec.Id, FALSE);
                    }
                }
            }
            
            if(ownershipCheck.containsKey(thisRec.Id)){
                if(thisRec.Department != null ){
                    if( 
                        thisRec.Department == 'Customer Success Team' 	|| 
                        thisRec.Department.contains('KAM') 				|| 
                        thisRec.Department.contains('PSU')				||
                        thisRec.Department.contains('GCC Delivery Head')||
                        thisRec.Department.contains('VLC') ||
                        thisRec.Department.contains('Startup')
                    ) {
                        ownershipCheck.put(thisRec.Id, FALSE);
                    } else{
                        ownershipCheck.put(thisRec.Id, TRUE);
                    }
                }
            }
        }
        
        for(Account thisRec : newAccounts){
            
            if( ownershipCheck.containsKey(thisRec.OwnerId) && ownershipCheck.get(thisRec.OwnerId) == TRUE && thisRec.Country_of_Origin__c == 'India' ){
                thisRec.Sales_Owner__c = thisRec.OwnerId;
            }
            
            if(salesOwnershipCheck.containsKey(thisRec.Sales_Owner__c) && salesOwnershipCheck.get(thisRec.Sales_Owner__c) == TRUE){
                thisRec.addError('You have reached the threshold limit of the accounts you can hold under your name.');
            }
        }
    }
    
    
    
}