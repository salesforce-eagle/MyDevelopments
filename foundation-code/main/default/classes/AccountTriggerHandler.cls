/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 11-06-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class AccountTriggerHandler implements TriggerInterface{
    
    public void beforeInsert(List<Sobject> listofNewSobjects){
        
        
        // listofNewSobjects = CSMOwnerAssigner.assignCSMOwner(listofNewSobjects).values();
        for(Account sobj : (List<Account>)listofNewSobjects){
            // if(sobj.recordTypeId == AccountConstants.International_RecordTypeId){
            // sobj.CurrencyIsoCode = 'USD';
            // }
            
            sobj.CurrencyISOCode =  sobj.Currency_Mapped__c;
            sobj.Account_Type__c = 'No assets-No opportunities(NAL)';
            
            /**	Bhavesh Jindal : update Account Recordtype Tax_Expert according to converted lead type	**/
            if(sobj.Record_Type_For_Conversion__c == 'Tax_Expert'){
                sobj.RecordTypeId = AccountConstants.TAX_EXPERT_RecordTypeId;
            }
            /**	Bhavesh Jindal : update Account Recordtype to SME according to converted lead type	**/
            if(sobj.Record_Type_For_Conversion__c == 'SME'){
                sobj.RecordTypeId = AccountConstants.SME_RecordTypeId;
            }
            if( sobj.Country_of_Origin__c != NULL && sobj.Country_of_Origin__c != 'India' ){
                sobj.CurrencyIsoCode = 'SAR';
            }
            //bhaveshjindal : SME <<->> Enterprise based on turnover
            if(sobj.Turnover__c != null && sobj.recordTypeId == AccountConstants.SME_RecordTypeId && 
               (sobj.Turnover__c == '25-50Cr' ||
                sobj.Turnover__c == '51-100 Cr' ||
                sobj.Turnover__c == '101-200 Cr' ||
                sobj.Turnover__c == '201-500 Cr' ||
                sobj.Turnover__c == '501-1000 Cr' ||
                sobj.Turnover__c == '1001-2500 Cr' || 
                sobj.Turnover__c == '2501-5000 Cr' || 
                sobj.Turnover__c == '5001+ Cr') ){
                    sobj.RecordTypeId = AccountConstants.Enterprise_RecordTypeId;
                }
            if(sobj.Turnover__c != null && sobj.recordTypeId == AccountConstants.Enterprise_RecordTypeId && 
               (sobj.Turnover__c == '<25Cr' ||
                sobj.Turnover__c == '< 50 Lakhs' ||
                sobj.Turnover__c == '50 Lakhs - 1Cr' ||
                sobj.Turnover__c == '1 - 5 Cr' |  
                sobj.Turnover__c == '5 - 10 Cr' ||
                sobj.Turnover__c == '10 - 20 Cr' || 
                sobj.Turnover__c == '20 - 25 Cr') ){
                    sobj.RecordTypeId = AccountConstants.SME_RecordTypeId;
                }

        }
        
        CTX_AccountValidation.getEnterpriseTurnOver((List<Account>)listofNewSobjects, NULL);
        CTX_AccountValidation.salesAndAccountOwnerMap((List<Account>)listofNewSobjects, NULL);
    }
    
    public void afterInsert(List<Sobject> listofNewSobjects,Map<Id,Sobject> mapofNewSObjects){
        CTX_AccountValidation.changeLeadOwnerBasedOnSalesOwner( (List<Account>)listofNewSobjects, (Map<Id, Account>) mapofNewSObjects );
        //	CTX_AccountValidation.updateAccountType((List<Account>)listofNewSobjects);
        CTX_ApexRecordSharing.apexShare_Account_SalesOwnerAccess( (Map<Id,Account>) mapofNewSObjects );
        
        /** Added By Niraj START - Partner Onboarding **/
        List<Account> accList = new List<Account>();
        for(Account accountInstance : (List<Account>)listofNewSobjects){
            if(accountInstance.RecordTypeId == AccountConstants.CHANNEL_PARTNER_RecordTypeId && accountInstance.Is_Partner_Live__c == false){
                accList.add(accountInstance);
            }
        }
        
        if(!accList.isEmpty()){
            CTX_SendPartnerAccountCreationMail.sendMailToLegalTeam(accList);
        }
        /** Added By Niraj END - Partner Onboarding **/
    }
    
    public void beforeUpdate(Map<Id,Sobject> mapofNewSobjects,Map<Id,Sobject> mapofOldSobjects){
        
        /** Added By Niraj SAL-750 : START **/
        Map<Id, Boolean> accountAssetLicenseMap = new Map<Id, Boolean>();
        
        for( 
            Asset thisRec : [ SELECT Id, AccountId, License_Id__c 
                             FROM Asset WHERE 
                             Status IN ('Valid', 'Valid & Renewed', 'Future', 'Upcoming Renewal') AND 
                             License_Id__c != NULL AND 
                             AccountId IN :mapofNewSobjects.keySet() ]
        ){
            if( !accountAssetLicenseMap.containsKey(thisRec.AccountId) ){
                accountAssetLicenseMap.put(thisRec.AccountId, TRUE);
            }
        }
        
        set<String> isClosedOppExistToAcc = new set<String>();
        for(AggregateResult aggrResult : [SELECT COUNT(Id) total, AccountId accId FROM Opportunity 
                                          WHERE AccountId IN : mapofNewSobjects.keySet() 
                                          AND StageName IN ('Closed Won','Closed Lost','Closed','Closed - Merged')
                                          GROUP BY AccountId]
           )
        {
            if((Integer)aggrResult.get('total')>0){
                System.debug((Integer)aggrResult.get('total'));
                isClosedOppExistToAcc.add((String)aggrResult.get('accId'));
            }
        }
        
        String currentUserProfileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        /** Added By Niraj SAL-750 : END **/
        
        if(AccountConstants.isFirstTimeAccount){
            CTX_AccountValidation.getEnterpriseTurnOver( 
                (List<Account>)mapofNewSobjects.values(), 
                (Map<Id, Account>)mapofOldSobjects 
            );
            //CTX_AccountValidation.salesAndAccountOwnerMap((List<Account>)mapofNewSobjects.values(), NULL);
            
            //triggered through a soft update on opportunityAfterUpdate
            CTX_AccountValidation.updateAccountType((List<Account>)mapofNewSobjects.Values());
            
            Map<string, TriggerActivationOrDeactivation__c> cs = TriggerActivationOrDeactivation__c.getAll();
            integer sizeTrigger = mapofNewSobjects.values().size();
            Map<Id,Id> mapOfSobjectWithUserId = new Map<Id,Id>();
            system.debug('VALS '+mapofNewSobjects.values());
            //mapOfSobjectWithUserId = roundRobinAssignmentGeneric.getUserIdtoAssign(mapofNewSobjects.values(),false,'Onboarding Owner');
            system.debug('MAP of USER ' +mapOfSobjectWithUserId);
            List<Account>	ownerChangedAccount = new List<Account>();
            
            for(Id sobjId : mapofNewSobjects.KeySet()){
                
                Account accountNewInstance = (Account)mapofNewSobjects.get(sobjId);
                Account  accountOldInstance = (Account)mapofOldSobjects.get(sobjId);
                String account_ITR_RecordTypeId = AccountConstants.ITR_RecordTypeId;
                
                /**	TDS Percentage	**/
                system.debug('TDS_Percent_Applicable__c in account change : '+accountNewInstance.TDS_Percent_Applicable__c);
                if( accountNewInstance.TDS_Percent_Applicable__c < 1 && accountNewInstance.TDS_Percent_Applicable__c != 0.50 ){
                    accountNewInstance.addError('Only 0.50 is allowed below 1%');
                } else if(accountNewInstance.TDS_Percent_Applicable__c >= 1){
                    
                    accountNewInstance.TDS_Percent_Applicable__c = Integer.valueOf(accountNewInstance.TDS_Percent_Applicable__c);
                    if( accountNewInstance.TDS_Percent_Applicable__c > 10 )
                        accountNewInstance.addError('TDS Value can be maximum of 10%.');
                    
                }
                /**	TDS Percentage	**/
                
                if( 
                    accountNewInstance.Is_Auto_Renewal_Enabled__c != accountOldInstance.Is_Auto_Renewal_Enabled__c 
                ){
                    if( accountNewInstance.Enable_E_Invoicing_Auto_Renewal__c !=  accountOldInstance.Enable_E_Invoicing_Auto_Renewal__c ){
                        if(accountNewInstance.Is_Auto_Renewal_Enabled__c != accountNewInstance.Enable_E_Invoicing_Auto_Renewal__c ){
                            accountNewInstance.addError('Please Disable/Enable both Auto Renewal and E-Invoicing together.');
                        }
                    }
                    if( accountNewInstance.Enable_GST_Auto_Renewal__c !=  accountOldInstance.Enable_GST_Auto_Renewal__c ){
                        if(accountNewInstance.Is_Auto_Renewal_Enabled__c != accountNewInstance.Enable_GST_Auto_Renewal__c ){
                            accountNewInstance.addError('Please Disable/Enable both Auto Renewal and GST together.');
                        }
                    }
                    if( accountNewInstance.Enable_Max_Auto_Renewal__c !=  accountOldInstance.Enable_Max_Auto_Renewal__c ){
                        if(accountNewInstance.Is_Auto_Renewal_Enabled__c != accountNewInstance.Enable_Max_Auto_Renewal__c ){
                            accountNewInstance.addError('Please Disable/Enable both Auto Renewal and MAX together.');
                        }
                    }
                    if( accountNewInstance.Enable_TDS_Auto_Renewal__c !=  accountOldInstance.Enable_TDS_Auto_Renewal__c ){
                        if(accountNewInstance.Is_Auto_Renewal_Enabled__c != accountNewInstance.Enable_TDS_Auto_Renewal__c ){
                            accountNewInstance.addError('Please Disable/Enable both Auto Renewal and TDS together.');
                        }
                    }
                }
                
                if( 
                    accountNewInstance.Enable_GST_Auto_Renewal__c !=  accountOldInstance.Enable_GST_Auto_Renewal__c &&
                    accountNewInstance.Enable_E_Invoicing_Auto_Renewal__c !=  accountOldInstance.Enable_E_Invoicing_Auto_Renewal__c &&
                    accountNewInstance.Enable_Max_Auto_Renewal__c !=  accountOldInstance.Enable_Max_Auto_Renewal__c &&
                    accountNewInstance.Enable_TDS_Auto_Renewal__c !=  accountOldInstance.Enable_TDS_Auto_Renewal__c
                  ){
                      accountNewInstance.addError('Can not enable/disable GST/E-Invoicing/Max/TDS together.');
                  }
                
                if(
                    accountOldInstance 					!= NULL && 
                    accountNewInstance.Product_Email__c != accountOldInstance.Product_Email__c &&
                    !UserInfo.getProfileId().containsIgnoreCase(System.Label.System_Admin_Profile_Id) &&
                    !System.label.Product_Email_Exclusion_List.containsIgnoreCase( UserInfo.getUserEmail() ) 
                ){
                    if(accountAssetLicenseMap.containsKey(sobjId)){
                        accountNewInstance.addError('Active Asset is present linked to the product email ID, please create a L2 ticket to change it. Either invite flow should be used or all licenses will have to be deactivated from old product email. Refer Licensing SOP Help (last) section');
                    }
                }
                
                
                /** Added By Niraj SAL-750 : START **/
                if(accountNewInstance.Channel_Partner_Account__c != accountOldInstance.Channel_Partner_Account__c){
                    if(isClosedOppExistToAcc.contains(accountNewInstance.Id) && !(currentUserProfileName == 'System Administrator')){
                        accountNewInstance.addError('There is a closed opportunity in this account. Please contact Admin team for changing Channel partner tagging.');
                    }
                }
                /** Added By Niraj SAL-750 : END **/
                
                if(
                    accountNewInstance.OwnerId 			!= accountOldInstance.OwnerId ||
                    accountNewInstance.Sales_Owner__c 	!= accountOldInstance.Sales_Owner__c
                ){
                    ownerChangedAccount.add(accountNewInstance);
                }
                
                if(accountNewInstance.RecordTypeId == account_ITR_RecordTypeId ){
                    if(accountNewInstance.ITR_Account_Stage__c != accountOldInstance.ITR_Account_Stage__c  && 
                       accountNewInstance.ITR_Account_Stage__c == 'Closed'){
                           accountNewInstance.Season_Closure_Date__c = Date.today();
                       }
                }
                
                if(accountNewInstance.RecordTypeId != account_ITR_RecordTypeId ){
                    System.debug('Active : '+accountNewInstance.Number_Of_Assets_Active__c);
                    System.debug('Churn : '+accountOldInstance.Number_Of_Assets_Churn__c);
                    System.debug('Pending : '+accountOldInstance.Number_Of_Assets_Pending__c);
                    /*if(accountNewInstance.Number_Of_Assets_Active__c != accountOldInstance.Number_Of_Assets_Active__c || 
accountNewInstance.Number_Of_Assets_Churn__c != accountOldInstance.Number_Of_Assets_Churn__c ||
accountNewInstance.Number_Of_Assets_Pending__c != accountOldInstance.Number_Of_Assets_Pending__c){*/
                    System.debug('***');
                    Decimal ActivePlusChurnAssetsCount = 0;
                    Decimal activeAssets = 0;
                    Decimal churnAssets = 0;
                    if(accountNewInstance.Number_Of_Assets_Active__c != null){
                        activeAssets = accountNewInstance.Number_Of_Assets_Active__c;
                    }
                    if(accountNewInstance.Number_Of_Assets_Churn__c != null){
                        churnAssets = accountNewInstance.Number_Of_Assets_Churn__c;
                    }
                    ActivePlusChurnAssetsCount = activeAssets + churnAssets;
                    System.debug('ActivePlusChurnAssetsCount '+ActivePlusChurnAssetsCount);
                    System.debug('ActivePlusChurnAssetsCount '+ActivePlusChurnAssetsCount);
                    if((accountNewInstance.Number_Of_Assets_Active__c != null && accountNewInstance.Number_Of_Assets_Active__c > 0 && 
                        accountNewInstance.Number_Of_Assets_Active__c == accountNewInstance.Total_number_Of_Assets__c)||
                       (accountNewInstance.Total_number_Of_Assets__c != null && accountNewInstance.Total_number_Of_Assets__c > 0 && 
                        ActivePlusChurnAssetsCount == accountNewInstance.Total_number_Of_Assets__c && accountNewInstance.Number_Of_Assets_Active__c !=0 && accountNewInstance.Number_Of_Assets_Active__c != null)){
                            //if(accountOldInstance.Status__c != AccountConstants.STATUS_ACTIVE){
                            accountNewInstance.Status__c = AccountConstants.STATUS_ACTIVE;
                            // }
                        }
                    if(accountNewInstance.Number_Of_Assets_Pending__c != 0 && accountNewInstance.Number_Of_Assets_Pending__c != null){
                        // if(accountOldInstance.Status__c != AccountConstants.STATUS_PENDING){
                        accountNewInstance.Status__c = AccountConstants.STATUS_PENDING;
                        // }
                    }else if(accountNewInstance.Number_Of_Assets_Churn__c != null && accountNewInstance.Number_Of_Assets_Churn__c > 0 &&
                             accountNewInstance.Number_Of_Assets_Churn__c == accountNewInstance.Total_number_Of_Assets__c){
                                 //   if(accountOldInstance.Status__c != AccountConstants.STATUS_CHURN){
                                 accountNewInstance.Status__c = AccountConstants.STATUS_CHURN; 
                             }
                    system.debug('CSM Owner@#$' + accountNewInstance.onboarding_owner__c);
                    if(cs.containsKey('CSM Logic Mass Update') && cs.get('CSM Logic Mass Update').isActive__c  ){
                        If((accountNewInstance.onboarding_owner__c == null || accountNewInstance.pgl_or_sb__c != accountOldInstance.pgl_or_sb__c || (accountNewInstance.pgl_or_sb__c == 'PGL' && !Label.PG_Users.contains((string.valueOf(accountNewInstance.onboarding_owner__c)).substring(0, 15)) || (accountNewInstance.pgl_or_sb__c == 'SB' && !Label.SB_Users.contains((string.valueOf(accountNewInstance.onboarding_owner__c)).substring(0, 15)))))
                           && accountNewInstance.Total_number_Of_Assets__c > 0 && accountNewInstance.parentId == null
                           && (accountNewInstance.onboarding_owner__c == null ||(Label.PIP_Users.contains(accountNewInstance.Onboarding_Owner__c) && (accountNewInstance.Total_number_Of_Assets__c !=accountOldInstance.Total_number_Of_Assets__c))|| !Label.PIP_Users.contains(accountNewInstance.Onboarding_Owner__c))){
                               list<id> PGminSBmin = CSMOwnerAssigner.assignCSMOwner((Account)mapofNewSobjects.get(sobjId) , (list<account>)mapofNewSobjects.values());
                               if(PGminSBmin != null){
                                   if(accountNewInstance.pgl_or_sb__c == 'SB')
                                   {        
                                       accountNewInstance.onboarding_owner__c = PGminSBmin[1];  
                                   }
                                   else if(accountNewInstance.pgl_or_sb__c == 'PGL'){
                                       accountNewInstance.onboarding_owner__c = PGminSBmin[0];
                                   }
                               }
                           }
                    }
                    
                }
                
                if(accountNewInstance.Turnover__c != accountOldInstance.Turnover__c){
                    if(accountNewInstance.Turnover__c != null && accountNewInstance.recordTypeId == AccountConstants.SME_RecordTypeId && 
                       (accountNewInstance.Turnover__c == '25-50Cr' ||
                        accountNewInstance.Turnover__c == '51-100 Cr' ||
                        accountNewInstance.Turnover__c == '101-200 Cr' ||
                        accountNewInstance.Turnover__c == '201-500 Cr' ||
                        accountNewInstance.Turnover__c == '501-1000 Cr' ||
                        accountNewInstance.Turnover__c == '1001-2500 Cr' || 
                        accountNewInstance.Turnover__c == '2501-5000 Cr' || 
                        accountNewInstance.Turnover__c == '5001+ Cr') ){
                            accountNewInstance.RecordTypeId = AccountConstants.Enterprise_RecordTypeId;
                        }
                    
                    if(accountNewInstance.Turnover__c != null && accountNewInstance.recordTypeId == AccountConstants.Enterprise_RecordTypeId && 
                       (accountNewInstance.Turnover__c == '<25Cr' ||
                        accountNewInstance.Turnover__c == '< 50 Lakhs' ||
                        accountNewInstance.Turnover__c == '50 Lakhs - 1Cr' ||
                        accountNewInstance.Turnover__c == '1 - 5 Cr' ||
                        accountNewInstance.Turnover__c == '5 - 10 Cr' ||
                        accountNewInstance.Turnover__c == '10 - 20 Cr' || 
                        accountNewInstance.Turnover__c == '20 - 25 Cr') ){
                            accountNewInstance.RecordTypeId = AccountConstants.SME_RecordTypeId;
                        }
                    
                }
                
                /** Added for Channel Partner E-sign Flow -START NIRAJ**/
                if(accountNewInstance.E_Sign_Status__c != accountOldInstance.E_Sign_Status__c && accountNewInstance.E_Sign_Status__c == 'E-Sign Successful'){
                    accountNewInstance.Partner_Onboarding_Stage__c = 'Approved';
                    accountNewInstance.Is_Partner_Live__c = true;
                    accountNewInstance.IsPartner = true;
                }
                /** Added for Channel Partner E-sign Flow -END NIRAJ**/
            }
            
            if(ownerChangedAccount.size() > 0){
                CTX_AccountValidation.salesAndAccountOwnerMap(ownerChangedAccount, NULL);
            }
            
        }
        
    }
    
    public void afterUpdate(Map<Id,Sobject> mapofNewSobjects,Map<Id,Sobject> mapofOldSobjects){
        
        if(AccountConstants.isFirstTimeAccount){
            AccountConstants.isFirstTimeAccount = false;
            
            Map<Id, Account>								newAccountMap								= (Map<Id, Account>)mapofNewSobjects;
            Map<Id, Account>								oldAccountMap								= (Map<Id, Account>)mapofOldSobjects;
            List<Account>									filteredAccountsNew 			    		= new List<Account>();
            Map<Id, Account>								filteredAccountOldMap 			    		= new Map<Id, Account>();
            Map<Id, AccountHistory>							accountIdAndHistoryMap						= new Map<Id, AccountHistory>();
            List<Account>           						accountListForCsmNotification 				= new List<Account>();
            List<Account>           						accountListForCsmChangeNotification 		= new List<Account>();
            List<Account>           						leadOwnerChangeAccountList          		= new List<Account>();
            List<Project__c> 								projectList 								= new List<Project__c>();
            Map<Id,Account> 								accountsApplicableForAutoRenew 				= new Map<Id,Account>();
            Map<Id, String>									accountIdAndAutoRenewalProductNameMap		= new Map<Id, String>();
            List<AccountProjectAssetJunction__c> 			apaJunctionToUpdateList 					= new List<AccountProjectAssetJunction__c>();
            Map<Id, AccountProjectAssetJunction__c> 		apaJunctionMap 								= new Map<Id, AccountProjectAssetJunction__c>();
            Map<Id, List<AccountProjectAssetJunction__c>> 	accountApaMap 								= new Map<Id, List<AccountProjectAssetJunction__c>>();
            Set<Id> 										accountIdSetForCommissionPartnerOpportunity	= new Set<Id>();
            for(
                AccountProjectAssetJunction__c thisApaJunction : [ SELECT Id, Customer_Account__c, SI_Partner_Account__c, Project__c, Customer_Account_Owner_CSM__c  
                                                                  FROM AccountProjectAssetJunction__c WHERE 
                                                                  Customer_Account__c IN :mapOfNewSObjects.keySet()]
            ){
                apaJunctionMap.put(thisApaJunction.Customer_Account__c,thisApaJunction);
                if(accountApaMap.containsKey(thisApaJunction.Customer_Account__c)){
                    accountApaMap.get(thisApaJunction.Customer_Account__c).add(thisApaJunction);
                }else{
                    accountApaMap.put(thisApaJunction.Customer_Account__c, new List<AccountProjectAssetJunction__c> {thisApaJunction});
                }
            }
            
            CTX_UpdatedCSMKAMDetailsAPI.UpdatedCSMKAMDetails(newAccountMap, oldAccountMap);
            
            for(
                AccountHistory thisAcc : [ SELECT Id, IsDeleted, AccountId, CreatedById, CreatedDate, 
                                          Field, DataType, OldValue, NewValue 
                                          FROM AccountHistory WHERE 
                                          AccountId IN :newAccountMap.keySet() AND 
                                          Field = 'Master_admin_Email__c'
                                          ORDER BY CreatedDate DESC ]
            ){
                if( !accountIdAndHistoryMap.containsKey(thisAcc.AccountId) ){
                    accountIdAndHistoryMap.put(thisAcc.AccountId, thisAcc);
                }
            }
            
            Map<String, Account> accountToUpdateMap = new Map<String, Account>(); // Added By Niraj SAL-442
            
            /** Added for Channel Partner E-sign Flow -START NIRAJ**/
            set<Id> partnerAccountIdsForEsignSet = new set<Id>();
            set<String> masterAdminEmailIds = new set<String>();
            /** Added for Channel Partner E-sign Flow -END NIRAJ**/    
            
            /** Added for Channel Partner User Creation Flow -START NIRAJ**/
            set<Id> partnerAccountForUserCreation = new set<Id>();
            set<String> masterAdminEmailIdsForUser = new set<String>();
            /** Added for Channel Partner User Creation Flow -END NIRAJ**/
            
            for(Account thisRec : (List<Account>)mapofNewSobjects.values()){
                
                Account oldAccount = (Account)mapofOldSobjects.get(thisRec.Id);
                
                if(thisRec.Master_admin_Email__c != oldAccount.Master_admin_Email__c){
                    
                    if(
                        accountIdAndHistoryMap.size() > 0 && accountIdAndHistoryMap.containsKey(thisRec.Id) &&
                        accountIdAndHistoryMap.get(thisRec.Id).OldValue != thisRec.Master_admin_Email__c
                    ){
                        System.debug('I am in Query Loop');
                        filteredAccountsNew.add(thisRec);
                        filteredAccountOldMap.put(thisRec.id, oldAccount);
                        
                    } else{
                        System.debug('I am in Query Loop - 1st Time');
                        filteredAccountsNew.add(thisRec);
                        filteredAccountOldMap.put(thisRec.id, oldAccount);
                    }
                }
                
                // Start : bhaveshjindal : csm notifications
                system.debug('accountNewInstance.Onboarding_Owner__c : '+thisRec.Onboarding_Owner__c);
                system.debug('accountOldInstance.Onboarding_Owner__c : '+oldAccount.Onboarding_Owner__c);
                if(thisRec.Onboarding_Owner__c != oldAccount.Onboarding_Owner__c && thisRec.Onboarding_Owner__c != NULL){
                    system.debug('csmNotificationConditionEntered');
                    accountListForCsmNotification.add(thisRec);
                    /*Changed By Niraj : CSM Journey START */
                    if(oldAccount.Onboarding_Owner__c != null){
                        accountListForCsmChangeNotification.add(thisRec);
                    }
                    /*Changed By Niraj : CSM Journey END */
                }
                // End : bhaveshjindal : csm notifications
                
                /* Added By Niraj SAL-442 : START */
                if(
                    thisRec.No_of_GSTIN__c != oldAccount.No_of_GSTIN__c ||
                    thisRec.No_of_PAN__c != oldAccount.No_of_PAN__c ||
                    thisRec.Number_of_Sales_Invoices__c != oldAccount.Number_of_Sales_Invoices__c ||
                    thisRec.Invoice_Discounting_Annual_Revenue__c != oldAccount.Invoice_Discounting_Annual_Revenue__c
                )
                {
                    accountToUpdateMap.put(thisRec.PAN__c, thisRec);                    
                }
                /* Added By Niraj SAL-442 : End */
                
                /** Added for Channel Partner E-sign Flow -START NIRAJ**/
                if(oldAccount.Partner_Onboarding_Stage__c == 'In Legal Approval' && thisRec.Partner_Onboarding_Stage__c == 'Sent For E-sign'){
                    partnerAccountIdsForEsignSet.add(thisRec.Id);
                    masterAdminEmailIds.add(thisRec.Master_admin_Email__c);
                }
                /** Added for Channel Partner E-sign Flow -END NIRAJ**/
                
                /** Added for Channel Partner User Creation Flow -START NIRAJ**/
                if(
                    oldAccount.E_Sign_Status__c != thisRec.E_Sign_Status__c && 
                    thisRec.E_Sign_Status__c == 'E-Sign Successful' &&
                    thisRec.Partner_Onboarding_Stage__c == 'Approved' &&
                    thisRec.Is_Partner_Live__c == true &&
                    thisRec.IsPartner == true
                )
                {
                    partnerAccountForUserCreation.add(thisRec.Id);
                    masterAdminEmailIdsForUser.add(thisRec.Master_admin_Email__c);
                }
                /** Added for Channel Partner User Creation Flow -END NIRAJ**/
            }
            
            /** Added for Channel Partner E-sign Flow -START NIRAJ**/    
            if(!partnerAccountIdsForEsignSet.isEmpty() && !masterAdminEmailIds.isEmpty()){
                CTX_PartnerAgreementESignSender.sendOrderFromForESign(partnerAccountIdsForEsignSet, masterAdminEmailIds);
            }
            /** Added for Channel Partner E-sign Flow -END NIRAJ**/    
            
            /** Added for Channel Partner User Creation Flow -END NIRAJ**/
            
            /* Added By Niraj SAL-442 : START */
            if(!accountToUpdateMap.keySet().isEmpty()){
                Database.executeBatch(new CTX_UpdateLeadFieldsFromAccountBatch(accountToUpdateMap), 5);
            }
            /* Added By Niraj SAL-442 : End */
            
            /*Changed By Niraj : CSM Journey START */
            if(accountListForCsmNotification.size()>0){
                AccountTriggerHelper.sendCSMNotification(accountListForCsmNotification);
            }
            if(accountListForCsmChangeNotification.size()>0){
                //AccountTriggerHelper.sendCSMIntroMail(accountListForCsmChangeNotification);
            }
            /*Changed By Niraj : CSM Journey END */
            
            
            
            
            for(Id sobjId : mapofNewSobjects.KeySet()){
                Account accountNewInstance = (Account)mapofNewSobjects.get(sobjId);
                Account accountOldInstance = (Account)mapofOldSobjects.get(sobjId);
                //get the list of account where ownerId/Sales_Owner__c is changed - By Kartikeya
                if(accountNewInstance.ownerId != accountOldInstance.ownerId ||  accountNewInstance.Sales_Owner__c != accountOldInstance.Sales_Owner__c){
                    leadOwnerChangeAccountList.add(accountNewInstance);
                }
                //get the list of account where ownerId/Sales_Owner__c is changed - By Kartikeya
                String account_ChannePartner_RecordTypeId = AccountConstants.CHANNEL_PARTNER_RecordTypeId;
                if(accountNewInstance.RecordTypeId == account_ChannePartner_RecordTypeId){
                    if(accountNewInstance.Channel_Partner_Type__c == 'Commission Partner'){
                        accountIdSetForCommissionPartnerOpportunity.add(accountNewInstance.Id);
                    }
                }
                if(accountNewInstance.Onboarding_Owner__c != accountOldInstance.Onboarding_Owner__c ||
                   accountNewInstance.OwnerId != accountOldInstance.OwnerId ){
                       AccountProjectAssetJunction__c apaJunctionToUpdate = apaJunctionMap.get(accountNewInstance.Id);
                       apaJunctionToUpdateList.add(apaJunctionToUpdate);
                   }
                if(accountNewInstance.Onboarding_Owner__c != accountOldInstance.Onboarding_Owner__c &&
                   accountApaMap.containsKey(accountNewInstance.Id)){
                       for(AccountProjectAssetJunction__c thisRec : accountApaMap.get(accountNewInstance.Id)){
                           Project__c prj = new Project__c(Id = thisRec.Project__c);
                           prj.Account_Owner_CSM__c = apaJunctionMap.get(accountNewInstance.Id).Customer_Account_Owner_CSM__c;
                           projectList.add(prj);
                       }  
                   }
            }
            if(apaJunctionToUpdateList.size()>0){
                try{
                    ProjectConstants.isFirstTimeApa = FALSE;
                    Update apaJunctionToUpdateList;
                    ProjectConstants.isFirstTimeApa = TRUE;
                    
                }Catch(Exception e){
                    System.debug('Error in updating apaJunction on CSM update on account : '+e.getMessage());
                    System.debug('Error cause : '+e.getCause());
                }
            }
            if(!projectList.isEmpty()){
                try{
                    ProjectConstants.isFirstTimeProject = FALSE;
                    update projectList;
                    ProjectConstants.isFirstTimeProject = TRUE;
                }Catch(Exception e){
                    System.debug('Error in updating project on CSM update on account : '+e.getMessage());
                }
                
            }
            
            List<Opportunity> opportunityListForCommissionedPartnnerAccounts = new List<Opportunity>();
            opportunityListForCommissionedPartnnerAccounts = [ SELECT Id, Name, AccountId, StageName FROM Opportunity 
                                                              WHERE AccountId IN :accountIdSetForCommissionPartnerOpportunity ];
            System.debug('size : '+opportunityListForCommissionedPartnnerAccounts.size()+'opportunityListForCommissionedPartnnerAccounts : '+opportunityListForCommissionedPartnnerAccounts);
            if(opportunityListForCommissionedPartnnerAccounts.size()>0){
                for(Opportunity thisOpportunity : opportunityListForCommissionedPartnnerAccounts){
                    thisOpportunity.StageName = 'Closed Lost';
                    thisOpportunity.Loss_Reason__c = 'Other';
                    thisOpportunity.Other_Reason_for_Loss__c = 'Commission Partner Account';
                    thisOpportunity.competition_Currently_Using__c = 'Don\'t Know';
                }
                update opportunityListForCommissionedPartnnerAccounts;
                
            }
            
            CTX_AccountValidation.changeLeadOwnerBasedOnSalesOwner( leadOwnerChangeAccountList, (Map<Id, Account>) mapofNewSObjects );
            CTX_HubspotChanges.accountOwnershipChange( (Map<Id,Account>)mapofNewSobjects, (Map<Id,Account>)mapofOldSobjects );
            CTX_ApexRecordSharing.apexShare_Account_SalesOwnerAccess( (Map<Id, Account>)mapofNewSobjects );
            
            
            Map<Id,Account> newAccMap = new Map<Id,Account>();
            Map<Id,Account> newAccMapForQli = new Map<Id,Account>();
            
            
            for(Id key : newAccountMap.keySet()){
                Account accNewInstance=(Account)newAccountMap.get(key);
                Account accOldInstance=(Account)oldAccountMap.get(key);  
                
                if(accNewInstance.Country_of_Origin__c != 'India' && accNewInstance.Country_of_Origin__c != NULL ){
                    if(accNewInstance.Owner_Full_Name__c != accOldInstance.Owner_Full_Name__c){
                        newAccMap.put(accNewInstance.Id,accNewInstance);
                    }  
                }
                
                /**	Auto Renewal Check Block : START	**/
                if( accNewInstance.Is_Auto_Renewal_Enabled__c != accOldInstance.Is_Auto_Renewal_Enabled__c ){
                    
                    //accountsApplicableForAutoRenew.put(accNewInstance.Id, accNewInstance);
                }
                
                if( 
                    accNewInstance.Enable_E_Invoicing_Auto_Renewal__c !=  accOldInstance.Enable_E_Invoicing_Auto_Renewal__c && 
                    accNewInstance.Is_Auto_Renewal_Enabled__c != accOldInstance.Is_Auto_Renewal_Enabled__c 
                ){
                    accountsApplicableForAutoRenew.put(accNewInstance.Id, accNewInstance);
                    accountIdAndAutoRenewalProductNameMap.put(accNewInstance.Id, 'E-invoicing & E-Way Bill');
                }
                
                if( 
                    accNewInstance.Enable_GST_Auto_Renewal__c != accOldInstance.Enable_GST_Auto_Renewal__c && 
                    accNewInstance.Is_Auto_Renewal_Enabled__c != accOldInstance.Is_Auto_Renewal_Enabled__c 
                  ){
                      accountsApplicableForAutoRenew.put(accNewInstance.Id, accNewInstance);
                      accountIdAndAutoRenewalProductNameMap.put(accNewInstance.Id, 'GST');
                  }
                
                if( 
                    accNewInstance.Enable_Max_Auto_Renewal__c  !=  accOldInstance.Enable_Max_Auto_Renewal__c  && 
                    accNewInstance.Is_Auto_Renewal_Enabled__c != accOldInstance.Is_Auto_Renewal_Enabled__c 
                ){
                    accountsApplicableForAutoRenew.put(accNewInstance.Id, accNewInstance);
                    accountIdAndAutoRenewalProductNameMap.put(accNewInstance.Id, 'Max');
                }
                
                if( 
                    accNewInstance.Enable_TDS_Auto_Renewal__c   !=  accOldInstance.Enable_TDS_Auto_Renewal__c  && 
                    accNewInstance.Is_Auto_Renewal_Enabled__c != accOldInstance.Is_Auto_Renewal_Enabled__c 
                ){
                    System.debug('Autorenewal enabled for tds');
                    accountsApplicableForAutoRenew.put(accNewInstance.Id, accNewInstance);
                    accountIdAndAutoRenewalProductNameMap.put(accNewInstance.Id, 'TDS');
                }
                /**	Auto Renewal Check Block : END	**/
                
            }
            if(newAccMap.size()>0){
                AccountTriggerHelper.updateAssetOwner(newAccMap);
            }
            
            AccountTriggerHelper.UpdateBillingActionOwner((Map<Id,Account>) newAccountMap, (Map<Id,Account>) oldAccountMap);
            
            if(!accountsApplicableForAutoRenew.isEmpty()){
                CTX_AutoRenewalFlag.whitelistAccount(accountsApplicableForAutoRenew, accountIdAndAutoRenewalProductNameMap, true);
            }
            
            
            
        }
    }
    
    public void beforeDelete(List<Sobject> listofOldSobjects,Map<Id,Sobject> mapOfOldSobject){ }
    
    public void afterDelete(Map<Id,Sobject> mapOfOldSobject){}
    
    public void afterUndelete(List<Sobject> listofNewSobjects,Map<Id,Sobject> mapofNewSObject){}
    
    
    
}