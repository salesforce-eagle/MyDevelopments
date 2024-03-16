/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-13-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class OpportunityTriggerHandler implements TriggerInterface{
    
    
    public void beforeInsert(list<sObject> listofNewsObjectRecords){
        
        List<Opportunity>	opportunities							= (List<Opportunity>)listofNewsObjectRecords;
        String 				opportunity_ITR_RecordTypeId 			= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OpportunityConstants.RECORDTYPE_ITR).getRecordTypeId();
        /**	BIBHU ClearFin	**/
        //String 				opportunity_NetNewId_RecordTypeId 		= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Net_New_ID').getRecordTypeId();
        String 				opportunity_ChannelPartner_RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OpportunityConstants.RECORDTYPE_CHANNEL_PARTNER).getRecordTypeId();
        List<Opportunity> 	listOfStageValidation 					= new List<Opportunity>();
        set<id> 			accountIds 								= new set<id>();
        List<Opportunity>	oppListForBlockingCheck					= new List<Opportunity>();
        
        for(Opportunity thisRec : opportunities){
            accountIds.add(thisRec.AccountId);
        }
        //  system.debug('before GSTINValidationHelperForOpportunity execution');
        //  GSTINValidationHelperForOpportunity.validateOpportunityBaseOnReceivablePan(opportunities);// added by Murali
        // system.debug('after GSTINValidationHelperForOpportunity');
        
        
        Map<Id,Account> accountMap = new Map<Id,Account>([ SELECT Id, 
                                                          ( SELECT Id FROM Contacts WHERE Primary_Contact__c = TRUE LIMIT 1 ),
                                                          Master_Admin_Email__c, Company_Domain_Name__c, CurrencyIsoCode,ID_Sales_Owner__c,OwnerId,
                                                          Currency_Mapped__c, Channel_Partner_Type__c, RecordType.DeveloperName,pan__c
                                                          FROM Account WHERE Id IN :accountIds ]);
        
        for(Opportunity thisRec : opportunities){
            
            /** Added By Niraj Pipeline Details Start **/
            if((thisRec.Forecast_Category__c == 'Pipeline' ||
                thisRec.Forecast_Category__c  == 'Best Case' ||
                thisRec.Forecast_Category__c  == 'Commit') &&
               thisRec.First_Pipeline_Date__c	== NULL){
                   thisRec.First_Pipeline_Date__c = System.today();
               }
            /** Added By Niraj Pipeline Details End **/
            
            /**	BIBHU ClearFin	**/
            if(thisRec.ClearTax_Billing_Entity__c == 'Xpedize'){
                
                if(accountMap.containsKey(thisRec.AccountId) && accountMap.get(thisRec.AccountId).ID_Sales_Owner__c != NULL)
                    thisRec.OwnerId = accountMap.get(thisRec.AccountId).ID_Sales_Owner__c;
                else
                    thisRec.OwnerId = accountMap.get(thisRec.AccountId).OwnerId;  
                
                
                thisRec.Forecast_Amount__c = 75000;
                
            }/**	BIBHU ClearFin	**/
            
            if(accountMap.containsKey(thisRec.AccountId)){
                thisRec.PAN_No_as_per_PO__c = accountMap.get(thisRec.AccountId).pan__c;
            }
            
            
            if(accountMap.containsKey(thisRec.accountId) && accountMap.get(thisRec.accountId).Currency_Mapped__c != NULL)
                thisRec.CurrencyIsoCode = accountMap.get(thisRec.accountId).Currency_Mapped__c;
            
            if(accountMap.containsKey(thisRec.accountId) && 
               accountMap.get(thisRec.accountId).Currency_Mapped__c != NULL &&
               thisRec.Country_of_Origin__c == 'Saudi Arabia')
            {
                thisRec.CurrencyIsoCode = accountMap.get(thisRec.accountId).Currency_Mapped__c;
                thisRec.ClearTax_Billing_Entity__c = 'KSA Branch of Defmacro';
            }
            
            
            if(thisRec.RecordTypeId != opportunity_ITR_RecordTypeId){
                
                if(thisRec.recordTypeId == OpportunityConstants.RECORDTYPEID_RENEWAL_MULTI_YEAR)
                    thisRec.Order_Form_Required__c = 'No';
                
                If(
                    !string.IsBlank(thisRec.account.master_admin_email__c)	&& 
                    !string.IsBlank(thisRec.account.Company_Domain_Name__c)
                ){
                    thisRec.Master_admin_Email__c =  accountMap.get(thisRec.accountId).master_admin_email__c;
                    thisRec.Company_Domain_Name__c =  accountMap.get(thisRec.accountId).Company_Domain_Name__c;
                }
                
                if(accountMap.containsKey(thisRec.accountId) && accountMap.get(thisRec.accountId).contacts.size() > 0 ){
                    thisRec.Primary_Contact__c = accountMap.get(thisRec.accountId).contacts[0].id;
                }
                
                if(thisRec.RecordTypeId != OpportunityConstants.RECORDTYPEID_TOPUP){
                    thisRec.StageName = 'SQL';
                }
                
                System.debug('Opportunity Stage Name :'+ thisRec.StageName +' '+thisRec);
                
                if(
                    thisRec.StageName != NULL 													&& 
                    (
                        thisRec.StageName != OpportunityConstants.STAGENAME_CLOSED_WON 			&& 
                        thisRec.StageName != OpportunityConstants.STAGENAME_ONBOARDED 			&& 
                        thisRec.StageName != OpportunityConstants.STAGENAME_POC 				&& 
                        thisRec.StageName != OpportunityConstants.STAGENAME_FOLLOWUP 			&& 
                        thisRec.StageName != OpportunityConstants.STAGENAME_PROFILING 			&& 
                        thisRec.StageName != OpportunityConstants.STAGENAME_RENEWAL 			&& 
                        thisRec.StageName != OpportunityConstants.STAGENAME_INPROGRESS 			&&  
                        thisRec.StageName != OpportunityConstants.STAGENAME_RENEWALINITIATED 	&& 
                        thisRec.StageName != OpportunityConstants.STAGENAME_ONGOING 			&&
                        thisRec.StageName != OpportunityConstants.STAGENAME_Quote_MANAGEMENT 	&&
                        thisRec.StageName != OpportunityConstants.STAGENAME_NEGOTIATION_MEETING &&
                        thisRec.StageName != OpportunityConstants.STAGENAME_QUOTING 			&&
                        thisRec.StageName != OpportunityConstants.STAGENAME_ON_TRACK 			&& 
                        thisRec.StageName != OpportunityConstants.STAGENAME_CLOSED_LOST 		&& 
                        thisRec.StageName != OpportunityConstants.STAGENAME_SQL                 &&
                        thisRec.StageName != OpportunityConstants.STAGENAME_ON_HOLD             &&
                        thisRec.StageName != OpportunityConstants.STAGENAME_SCH_DEMO            &&
                        thisRec.StageName != OpportunityConstants.STAGENAME_DEMO_DONE           &&
                        thisRec.StageName != OpportunityConstants.STAGENAME_QUALIFY             
                    )
                ){
                    listOfStageValidation.add(thisRec);
                }
                
                // System.debug('opprtunity Channel_Partner_Type__c = '+accountMap.get(thisRec.AccountId).Channel_Partner_Type__c);
                if(accountMap.containsKey(thisRec.accountId) && accountMap.get(thisRec.AccountId).Channel_Partner_Type__c == 'Commission Partner'){
                    thisRec.addError('New Opportunity cannot be created under this Account since its a Channel Commission Partner Account');
                }
                
                /**	Bhavesh Jindal : Disable Opportunity creation for ITR Accounts	**/
                // System.debug('opprtunity Account recordType = '+accountMap.get(thisRec.AccountId).RecordType.DeveloperName);
                if(accountMap.containsKey(thisRec.accountId) && accountMap.get(thisRec.AccountId).RecordType.DeveloperName == 'ITR'){
                    thisRec.addError('New Opportunity cannot be created under this Account since its an ITR Account');
                }
                
                // for blocking opportunity if parent account exist on the account.
                oppListForBlockingCheck.add(thisRec);
            }
            
        } 
        if(oppListForBlockingCheck.size()>0){
            OpportunityTriggerHelper.blockOpportunities(oppListForBlockingCheck,FALSE);
        }
        
        if(listOfStageValidation.size()>0){
            System.debug('Inside Calling method - Validation');
            OpportunityTriggerHelper.stageValidation(listOfStageValidation);
        }
        
        OpportunityTriggerHelper.calculateDealValue(opportunities);
        
    }
    
    
    public void afterInsert(list<sObject> listofNewsObjectRecords,map<id,sObject> mapofNewsObjectRecords){
        
        CTX_ApexRecordSharing.apexShare_Opportunity_AccountSalesOwnerAccess((Map<Id, Opportunity>)mapofNewsObjectRecords);
        OpportunityTriggerHelper.ARRRollUp(listofNewsObjectRecords);
        
        list<Opportunity> newOpportunity = new list<Opportunity>();
        /** added by Murali for receivable validation Start **/
        for(Opportunity opp : (list<Opportunity>)listofNewsObjectRecords){
            if(opp.Billing_GST__c!='' && opp.Billing_GST__c != NULL){
                newOpportunity.add(opp);
            }
        }
        
        if(system.label.ActiveOrDeactivateGSTINValidation == 'true'){
            GSTINValidationHelperForOpportunity.validateOpportunityBaseOnReceivablePan(newOpportunity);// added by Murali
        }
        /** END **/
        Set<Account> accountsListToUpdateAccountType = new Set<Account>();
        for(Opportunity thisOpportunity : (list<Opportunity>)listofNewsObjectRecords){
            Account acc = new Account(Id = thisOpportunity.AccountId);
            accountsListToUpdateAccountType.add(acc);
            
        }
        if(accountsListtoUpdateAccountType.size() > 0){
            Update new List<Account>(accountsListToUpdateAccountType);
        }
        
        OpportunityTriggerHelper.CreateDemoTask((map<id,Opportunity>) mapofNewsObjectRecords, NULL);
        
    }
    
    
    public void beforeUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){
        
        List<Id> listOfOpportunityIdWithDemoCompletEvent = new List<Id>();
        //Added By Kartikeya - Populate Regional Head
        //Map<String,Id>         mapUserRegionalHead     = new Map<String,Id>();
        //Commented By Kartikeya
        //Map<Id,Opportunity> mapOfOpportunity = new Map<Id,Opportunity>([select id,owner.department,owner.division,owner.manager.manager.Id from opportunity where id in:mapofNewsObjectRecords.keySet()]);
        //Commented By Niraj
        //Map<Id,User> mapOfUserSupMan = new Map<Id,User>([SELECT id,manager.managerid FROM user]);
        /*List<aggregateResult>  groupUserDepatDiv       = [SELECT  UserRole.name RoleName,department Dept,division Div,id RecId,username UName FROM User WHERE 
UserRole.name LIKE '%Regional%Head%' and isActive = TRUE GROUP BY  UserRole.name,department,division,id,username,manager.manager.id];
for(aggregateResult aggr: groupUserDepatDiv){
mapUserRegionalHead.put(String.ValueOf(aggr.get('Dept'))+String.ValueOf(aggr.get('Div')),String.ValueOf(aggr.get('RecId')));
}*/
        //End By Kartikeya
        
        /** Added by Murali 
Map<Id,Opportunity> mapofNewOpportunityRecords = (Map<Id, Opportunity>)mapofNewsObjectRecords;
Map<Id,Opportunity> mapofoldOpportunityRecords = (Map<Id, Opportunity>)mapofOldsObjectRecords;
List<Opportunity> newOppty = new List<Opportunity>();
for(Opportunity opp : mapofNewOpportunityRecords.values()){
system.debug('inside for in before new'+opp.Billing_GST__c);
system.debug('inside for in before old'+mapofoldOpportunityRecords.get(opp.id).Billing_GST__c);
if((opp.Billing_GST__c!= mapofoldOpportunityRecords.get(opp.id).Billing_GST__c) || (opp.TIN_Number__c!= mapofoldOpportunityRecords.get(opp.id).TIN_Number__c)){

newOppty.add(opp);
}
system.debug('newOppty'+newOppty);
}

GSTINValidationHelperForOpportunity.validateOpportunityBaseOnReceivablePan(newOppty);// added by Murali
/** End**/
        
        for(
            Event thisRec : [ SELECT Id, Stage__c, WhatId 
                             FROM Event WHERE 
                             Subject = 'Demo Meeting' AND 
                             WhatId =: mapofNewsObjectRecords.keySet() AND 
                             Stage__c = 'Completed' ]
        ){
            
            if(mapofNewsObjectRecords.containsKey(thisRec.WhatId)){
                listOfOpportunityIdWithDemoCompletEvent.add(thisRec.WhatId);
            }
        }
        
        
        System.debug('endered opportunity before update trigger');
        List<Opportunity> listOfOppToCheckValidation = new List<Opportunity>();
        List<Opportunity> listOfStageValidation = new List<Opportunity>();
        List<Opportunity> listOfOppForFileUploadValidation = new List<Opportunity>();
        List<Opportunity> listOfOppForFileUploadValidation_SME = new List<Opportunity>();
        List<Opportunity> listOfEventValidation = new List<Opportunity>();
        set<Id> renOpporId = new set<Id>();
        list<asset> relAssetList = new list<asset>();
        map<id,asset> relAssetMap = new map<id,asset>();
        /* Added by Raksha on 30th Oct 2020 */ 
        List<Opportunity> listOfOpportunitysToApplyElCheckAndAssignfromQueue=new List<Opportunity>(); //Enhanced as a Part of P3CTX SSD1.1 10-Nov-2020 start
        List<Opportunity> listOfOpportunities=new List<Opportunity>();// Enhanced as a part fo P3CTX SDD1.3
        List<Opportunity> listOfeSignRequest = new List<Opportunity>();// Pramodh Added for Esign
        Map<String,String> mapOfOppToItsESignCustomerId = new Map<String,String>();
        List<Opportunity> listOfPhysicalSignOppForOrderFormValidation = new List<Opportunity>();
        List<Opportunity> listOfOppForOrderFormValidation = new List<Opportunity>();
        List<Opportunity> listOfOppForMasterAdminEmailValidation = new List<Opportunity>();
        List<Opportunity> shareOpporList = new List<Opportunity>();
        
        //bhaveshjindal
        Map<Id, Account>	AccountsMap 	= new Map<Id, Account>();
        Map<Id, String>	allAccountsMap 	= new Map<Id, String>();
        List<Opportunity> oppListForBlocking = new List<Opportunity>();
        
        for(
            Account thisAccount : [ SELECT Id, Master_admin_Email__c, ParentId, Name,pan__c 
                                   FROM Account WHERE 
                                   ParentId = NULL AND 
                                   Master_admin_Email__c != NULL ]
        ){
            AccountsMap.put(thisAccount.Id,thisAccount);
            allAccountsMap.put(thisAccount.Id,thisAccount.Master_admin_Email__c);
        }
        
        //START : ListForMasterAdminCheck : bhaveshjindal
        
        /* List<Opportunity> oppListForMasterAdminCheck = new List<Opportunity>();
oppListForMasterAdminCheck = [SELECT Id, Name, AccountId, Master_admin_Email__c 
FROM Opportunity WHERE StageName = 'In Finance Approval' 
AND Master_admin_Email__c != NULL 
ORDER BY AccountId ];*/
        //END : ListForMasterAdminCheck
        
        set<Id> userId = new Set<Id>();  //This Line Added By Niraj     
        for(Opportunity Oppor:(list<Opportunity>)mapofNewsObjectRecords.Values()){
            userId.add(Oppor.ownerId);
            If(Oppor.recordTypeId == OpportunityConstants.RECORDTYPEID_RENEWAL && Oppor.StageName == OpportunityConstants.STAGENAME_CLOSED_LOST)
                renOpporId.add(Oppor.Id);
        }
        
        Map<Id,User> mapOfUserSupMan = new Map<Id,User>([SELECT id,manager.managerid,Team_WBR_C__c,Team_New__c FROM user WHERE Id IN : userId]); //This Line Added By Niraj From Line 152
        
        relAssetList = [select id,status,renewal_opportunity__c,name,account.pan__c,account.name from asset where renewal_opportunity__c in: renOpporId and (Status != 'Churn' and status != 'Sales return')];
        for(asset assIns : relAssetList){
            relAssetMap.put(assIns.renewal_Opportunity__c,assIns);  
        }
        String opportunity_ChannelPartner_RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OpportunityConstants.RECORDTYPE_CHANNEL_PARTNER).getRecordTypeId();
        String opportunity_Net_New_RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OpportunityConstants.RECORDTYPE_NET_NEW).getRecordTypeId();
        String opportunity_Cross_Sell_Upsell_RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OpportunityConstants.RECORDTYPE_CROSS_SELL_OR_UPSELL).getRecordTypeId();
        String opportunity_Partner_Success_RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OpportunityConstants.RECORDTYPE_PARTNER_SUCCESS).getRecordTypeId();
        String opportunity_Renewal_RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OpportunityConstants.RECORDTYPE_RENEWAL).getRecordTypeId();
        String opportunity_ITR_RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OpportunityConstants.RECORDTYPE_ITR).getRecordTypeId();
        
        for(Id key:mapofNewsObjectRecords.KeySet()){
            
            /**	Opportunity Instance	**/
            Opportunity	OpportunityNewInstance	= (Opportunity)mapofNewsObjectRecords.get(key);
            Opportunity	OpportunityOldInstance	= (Opportunity)mapofOldsObjectRecords.get(key);
            
            /** Added By Niraj Record Type Change Validation **/
            if(OpportunityNewInstance.RecordTypeId != OpportunityOldInstance.RecordTypeId && UserInfo.getProfileId() != (Id)System.Label.SystemAdminProfileId && OpportunityConstants.RECORDTYPE_CHANGE_VALIDATION_ENABLE){
                OpportunityNewInstance.addError('You do not have access to change opportunity type.');
            }
            /** Added By Niraj Record Type Change Validation **/
            
            If(OpportunityNewInstance.ForecastCategoryName != null &&
               (OpportunityNewInstance.ForecastCategoryName != OpportunityOldInstance.ForecastCategoryName) && 
               (OpportunityNewInstance.ForecastCategoryName != OpportunityNewInstance.Forecast_Category__c)){
                   OpportunityNewInstance.Forecast_Category__c = OpportunityNewInstance.ForecastCategoryName;
               }
            
            If(OpportunityNewInstance.Forecast_Category__c != null &&
               (OpportunityNewInstance.Forecast_Category__c != OpportunityOldInstance.Forecast_Category__c) && 
               (OpportunityNewInstance.Forecast_Category__c != OpportunityNewInstance.ForecastCategoryName)){
                   OpportunityNewInstance.ForecastCategoryName = OpportunityNewInstance.Forecast_Category__c;
               }
            
            /** Added By Niraj Pipeline Details Start **/
            if((OpportunityNewInstance.Forecast_Category__c == 'Pipeline' ||
                OpportunityNewInstance.Forecast_Category__c  == 'Best Case' ||
                OpportunityNewInstance.Forecast_Category__c  == 'Commit') &&
               OpportunityNewInstance.First_Pipeline_Date__c	== NULL){
                   OpportunityNewInstance.First_Pipeline_Date__c = System.today();
               }
            /** Added By Niraj Pipeline Details End **/
            
            
            if(OpportunityNewInstance.Country_of_Origin__c != 'India' &&
               OpportunityNewInstance.Country_of_Origin__c != 'N/A' &&
               OpportunityNewInstance.Country_of_Origin__c != 'NULL' &&
               OpportunityNewInstance.Finance_approval_status__c != OpportunityOldInstance.Finance_approval_status__c){
                   if(OpportunityNewInstance.Special_Terms__c == NULL){
                       if(OpportunityNewInstance.Finance_approval_status__c == 'Finance Approval Approved'){
                           OpportunityNewInstance.StageName = 'Closed Won';
                       }
                   }else{
                       if(OpportunityNewInstance.Finance_approval_status__c == 'Legal Approval Approved'){
                           OpportunityNewInstance.StageName = 'Closed Won';
                       }
                   }
               }
            
            
            If(OpportunityNewInstance.OwnerId != OpportunityOldInstance.OwnerId || OpportunityOldInstance.Regional_Head__c == null){
                OpportunityNewInstance.Regional_Head__c = mapOfUserSupMan.get(OpportunityNewInstance.OwnerId).manager.managerId;
            }
            /**	Bibhu Code for Opportunity Demo Event Check: START	**/
            if( 
                OpportunityNewInstance.StageName != OpportunityOldInstance.StageName && 
                ( 
                    OpportunityNewInstance.StageName != 'Pre SQL' || 
                    OpportunityNewInstance.StageName != 'SQL' 
                )
            ){
                
                if( 
                    OpportunityNewInstance.RecordTypeId == OpportunityConstants.RECORDTYPEID_CROSS_SELL_OR_UPSELL && 
                    OpportunityNewInstance.RecordTypeId == OpportunityConstants.RECORDTYPEID_NET_NEW 
                ){
                    
                    if( !listOfOpportunityIdWithDemoCompletEvent.contains(OpportunityNewInstance.Id) ){
                        OpportunityNewInstance.addError('Please create an Event and mark that Demo Complete before proceding for Stage change.');
                    }
                }
            }	/**	Bibhu Code for Opportunity Demo Event Check: END	**/
            /**	Resend ESign Details : START	**/
            if(!String.ISBLANK(OpportunityNewInstance.Retrigger_E_Sign__c) 
               && (OpportunityNewInstance.Retrigger_E_Sign__c != 'Sent' && OpportunityNewInstance.Retrigger_E_Sign__c != 'Sent Successfully' && OpportunityOldInstance.Retrigger_E_Sign__c != OpportunityNewInstance.Retrigger_E_Sign__c) && (OpportunityNewInstance.Finance_approval_status__c  == 'Legal Approval Approved' || OpportunityNewInstance.Finance_approval_status__c  == 'Finance Approval Approved')){
                   OpportunityConstants.ESIGNRESEND ='Resend';
                   OpportunityConstants.ListOfeSignRequest.add(OpportunityNewInstance);
                   OpportunityNewInstance.Retrigger_E_Sign__c = 'Sent';
                   OpportunityConstants.mapOfOppToItsESignCustomerId.put(OpportunityNewInstance.Id,OpportunityNewInstance.E_Sign_Customer_Info__c);
               }
            else if(!String.ISBLANK(OpportunityNewInstance.Retrigger_E_Sign__c) 
                    && OpportunityNewInstance.Retrigger_E_Sign__c != 'Sent' && OpportunityNewInstance.Retrigger_E_Sign__c != 'Sent Successfully' && OpportunityOldInstance.Retrigger_E_Sign__c != OpportunityNewInstance.Retrigger_E_Sign__c && (OpportunityNewInstance.Finance_approval_status__c  != 'Legal Approval Approved' && OpportunityNewInstance.Finance_approval_status__c  != 'Finance Approval Approved')){
                        OpportunityNewInstance.addError('Please try resending after Opportunity Approval!');
                    }
            if
                (
                    (OpportunityOldInstance.Physical_Sign_completed__c != OpportunityNewInstance.Physical_Sign_completed__c &&
                     !OpportunityNewInstance.Physical_Sign_completed__c) || !String.ISBLANK(OpportunityNewInstance.Retrigger_E_Sign__c)
                    && !(OpportunityOldInstance.Retrigger_E_Sign__c == 'Sent' && OpportunityNewInstance.Retrigger_E_Sign__c == 'Sent Successfully') && OpportunityOldInstance.Retrigger_E_Sign__c !=OpportunityNewInstance.Retrigger_E_Sign__c
                )
            {
                OpportunityNewInstance.E_Sign_Status__c 			= NULL;
                OpportunityNewInstance.ESign_CTX_Status__c 			= NULL;
                OpportunityNewInstance.ESign_Message__c 			= NULL;
                OpportunityNewInstance.ESign_Sign_Status__c 		= NULL;
            }
            if(AccountsMap.containsKey(OpportunityNewInstance.AccountId) && String.ISBLANK(OpportunityNewInstance.PAN_No_as_per_PO__c )){
                OpportunityNewInstance.PAN_No_as_per_PO__c = AccountsMap.get(OpportunityNewInstance.AccountId).pan__c;
            }
            /**	Resend ESign Details : END	**/
            if( OpportunityNewInstance.RecordTypeId != opportunity_ITR_RecordTypeId ){
                if( 
                    OpportunityNewInstance.recordTypeId == OpportunityConstants.RECORDTYPEID_RENEWAL_MULTI_YEAR && 
                    OpportunityNewInstance.recordTypeId != OpportunityOldInstance.recordTypeId
                ){
                    OpportunityNewInstance.Order_Form_Required__c = 'No';
                }
                
                if(OpportunityNewInstance.Country_of_Origin__c != 'Saudi Arabia'){
                    OpportunityNewInstance.CurrencyIsoCode = OpportunityNewInstance.Currency_Formula__c;
                }
                
                OpportunityNewInstance.Total_Roll_Up_OTP__c = string.valueOf(OpportunityNewInstance.OTP_Product_Total__c);/**	Added by Raksha for Term calculation	**/
                
                if(
                    OpportunityNewInstance.StageName!=null && 
                    OpportunityNewInstance.StageName!=OpportunityOldInstance.StageName && 
                    OpportunityNewInstance.StageName==OpportunityConstants.STAGENAME_CLOSED_WON
                ){	//'Closed Won'
                    OpportunityNewInstance.closedate = system.today();
                }
                
                /**	Clear the ESign Details : START	**/
                if(
                    OpportunityNewInstance.StageName != NULL &&
                    !OpportunityNewInstance.StageName.contains('Closed') && 
                    OpportunityOldInstance.StageName ==  OpportunityConstants.STAGENAME_IN_FINANCE_APPROVAL &&
                    OpportunityOldInstance.StageName !=  OpportunityNewInstance.StageName
                ){
                    if(OpportunityNewInstance.Finance_approval_status__c != NULL && 
                       !OpportunityNewInstance.Finance_approval_status__c.containsIgnoreCase('Rejected')){
                           OpportunityNewInstance.Finance_approval_status__c = NULL;
                       } 
                    OpportunityNewInstance.E_Sign_Status__c 				= NULL;
                    //OpportunityNewInstance.ESign_BE_Docket_ID__c 		= NULL;
                    //OpportunityNewInstance.ESign_BE_Document_ID__c 		= NULL;
                    //OpportunityNewInstance.ESign_BE_Reference_Doc_ID__c 	= NULL;
                    OpportunityNewInstance.ESign_CTX_Status__c 			= NULL;
                    OpportunityNewInstance.ESign_Message__c 				= NULL;
                    OpportunityNewInstance.ESign_Sign_Status__c 			= NULL;
                    OpportunityNewInstance.Physical_Sign_completed__c 	    = FALSE;
                    OpportunityNewInstance.ESign_Doc_Updated__c			    = FALSE;
                }	/**	Clear the ESign Details : END	**/
                
                /**	Closed Won or onboard the oppty if approved.	**/
                if(
                    OpportunityNewInstance.StageName == OpportunityConstants.STAGENAME_IN_FINANCE_APPROVAL 								&& 
                    OpportunityNewInstance.Finance_approval_status__c == OpportunityConstants.APPROVAL_STATUS_FINANCE_APPROVAL_APPROVED 	&&
                    OpportunityOldInstance.Finance_approval_status__c != OpportunityConstants.APPROVAL_STATUS_FINANCE_APPROVAL_APPROVED
                ){
                    if(OpportunityNewInstance.RecordTypeId == opportunity_ChannelPartner_RecordTypeId){}else{}
                }
                
                if(
                    OpportunityNewInstance.StageName!=null && 
                    OpportunityNewInstance.StageName!=OpportunityOldInstance.StageName &&
                    (
                        OpportunityNewInstance.StageName== OpportunityConstants.STAGENAME_CLOSED_WON || 
                        OpportunityNewInstance.StageName== OpportunityConstants.STAGENAME_ONBOARDED
                    )
                ){	//'Closed Won'  'Onboarded' 
                    //OpportunityNewInstance.CloseDate = system.today();
                    /* listOfOppToCheckValidation.add(OpportunityNewInstance);
OpportunityClosureMail.Parameter closureParam = new OpportunityClosureMail.Parameter();
closureParam.additionalMailIDs = System.label.Closure_Mail_additionalMailIDs ;
closureParam.emailTemplateId = 'Opportunity_Closed_won_with_attachment';
closureParam.ownerIdOrManagerId = OpportunityNewInstance.OwnerId ;
closureParam.recipientList = System.label.Closure_Mail_RecipientList ;
closureParam.roleID = System.label.Closure_Mail_roleID ;
closureParam.recordId = OpportunityNewInstance.Id ;
List<OpportunityClosureMail.Parameter> listOfClosureParam = new List<OpportunityClosureMail.Parameter>();
listOfClosureParam.add(closureParam);
//OpportunityClosureMail.sendMail(listOfClosureParam);*/
                }
                
                System.debug('*^* OpportunityNewInstance.StageName '+OpportunityNewInstance.StageName);
                System.debug('*^* OpportunityNewInstance.Finance_approval_status__c '+OpportunityNewInstance.Finance_approval_status__c);
                System.debug('*^*OpportunityNewInstance.Reason_for_reject__c '+ OpportunityNewInstance.Reason_for_reject__c);
                //By Raksha - To make "Reason for Reject" field mandatory before rejecting the approval
                if(OpportunityNewInstance.StageName == OpportunityConstants.STAGENAME_IN_FINANCE_APPROVAL && 
                   (OpportunityNewInstance.Finance_approval_status__c == OpportunityConstants.APPROVAL_STATUS_FINANCE_APPROVAL_REJECTED && OpportunityNewInstance.Reason_for_reject__c == null)||
                   (OpportunityNewInstance.Finance_approval_status__c == OpportunityConstants.APPROVAL_STATUS_LEGAL_APPROVAL_REJECTED && OpportunityNewInstance.Reason_for_reject__c == null)){
                       System.debug('*^* Show error');
                       //OpportunityNewInstance.addError(system.Label.Oppty_Finance_Approval_Rejection_Error_Msg);
                   }
                
                //Added and changed by Raksha
                //Check the fileUpload validation before moving into "In Finance approval" stage for Order Form not required Opportunities
                if(OpportunityNewInstance.StageName == OpportunityConstants.STAGENAME_IN_FINANCE_APPROVAL && OpportunityOldInstance.StageName != OpportunityConstants.STAGENAME_IN_FINANCE_APPROVAL && OpportunityNewInstance.Order_Form_Required__c == 'No'){
                    if(
                        OpportunityNewInstance.Account_Record_Type__c == AccountConstants.SME_RecordTypeId ||
                        AccountConstants.SME_RecordTypeId.containsIgnoreCase(OpportunityNewInstance.Account_Record_Type__c)
                    ){
                        listOfOppForFileUploadValidation_SME.add(OpportunityNewInstance);
                        system.debug('Inside SME block');
                    } else{
                        listOfOppForFileUploadValidation.add(OpportunityNewInstance);
                        system.debug('Inside NOT SME block');
                    }
                    
                }
                //Check for OrderForm Validation before moving into "In Finance approval" stage for Order Form required Opportunities
                if(OpportunityNewInstance.StageName == OpportunityConstants.STAGENAME_IN_FINANCE_APPROVAL && OpportunityOldInstance.StageName != OpportunityConstants.STAGENAME_IN_FINANCE_APPROVAL && OpportunityNewInstance.E_Sign_Status__c != 'E-Sign Successful' && OpportunityNewInstance.Order_Form_Required__c == 'Yes'){
                    listOfOppForOrderFormValidation.add(OpportunityNewInstance);
                }
                //End by Raksha
                
                //Enhanced as a Part of P3CTX SSD1.1 10-Nov-2020 start
                if(OpportunityNewInstance.Lead_Locking_Status__c!=null &&  OpportunityNewInstance.Lead_Locking_Status__c!=OpportunityOldInstance.Lead_Locking_Status__c && OpportunityNewInstance.Lead_Locking_Status__c==LeadConstants.Lead_Locking_Status_UNLOCKED){
                    listOfOpportunitysToApplyElCheckAndAssignfromQueue.add(OpportunityNewInstance);
                }
                //Enhanced as a Part of P3CTX SSD1.1 10-Nov-2020 end   
                //Enhanced as a Part of P3CTX SSD1.1 12-Nov-2020 start
                if(OpportunityNewInstance.Extension_Approval_Status__c!=null &&  OpportunityNewInstance.Extension_Approval_Status__c!=OpportunityOldInstance.Extension_Approval_Status__c ){
                    listOfOpportunities.add(OpportunityNewInstance);
                }
                //Enhanced as a Part of P3CTX SSD1.1 12-Nov-2020 end
                
                //By Raksha - Move a stage back if approval is rejected
                /*  if(OpportunityNewInstance.StageName == OpportunityConstants.STAGENAME_IN_FINANCE_APPROVAL && 
((OpportunityNewInstance.Finance_approval_status__c == OpportunityConstants.APPROVAL_STATUS_FINANCE_APPROVAL_REJECTED &&
OpportunityOldInstance.Finance_approval_status__c != OpportunityConstants.APPROVAL_STATUS_FINANCE_APPROVAL_REJECTED)||
(OpportunityNewInstance.Special_Terms__c != null &&  
OpportunityNewInstance.Finance_approval_status__c == OpportunityConstants.APPROVAL_STATUS_LEGAL_APPROVAL_REJECTED &&
OpportunityOldInstance.Finance_approval_status__c != OpportunityConstants.APPROVAL_STATUS_LEGAL_APPROVAL_REJECTED))){
if(OpportunityNewInstance.RecordTypeId == opportunity_Net_New_RecordTypeId  || OpportunityNewInstance.RecordTypeId == opportunity_Cross_Sell_Upsell_RecordTypeId ||  OpportunityNewInstance.RecordTypeId == opportunity_Partner_Success_RecordTypeId){
OpportunityNewInstance.StageName = OpportunityConstants.STAGENAME_FOLLOWUP;
}else if(OpportunityNewInstance.RecordTypeId == opportunity_ChannelPartner_RecordTypeId){
OpportunityNewInstance.StageName = OpportunityConstants.STAGENAME_TRANING;
}else if(OpportunityNewInstance.RecordTypeId == opportunity_Renewal_RecordTypeId){
OpportunityNewInstance.StageName = OpportunityConstants.STAGENAME_AT_RISK;
}
}*/
                
                
                //System.debug('allAccountsMap.Values() --> '+ allAccountsMap.Values());
                
                
                /* End by Raksha  */
                if(OpportunityNewInstance.StageName!=null && OpportunityNewInstance.StageName!=OpportunityOldInstance.StageName &&
                   (OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_CLOSED_WON && 
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_ONBOARDED && 
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_SQL && 
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_POC && 
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_Quote_MANAGEMENT &&
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_NEGOTIATION_MEETING &&
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_QUOTING &&
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_ON_TRACK &&
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_FOLLOWUP && 
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_PROFILING && 
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_RENEWAL && 
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_INPROGRESS && 
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_RENEWALINITIATED && 
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_ONGOING && 
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_CLOSED_LOST &&
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_PRE_SQL &&
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_ON_HOLD &&
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_SCH_DEMO  &&
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_DEMO_DONE  &&
                    OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_QUALIFY )) 
                {
                    System.debug('Inside Stage Validation List Check');
                    listOfStageValidation.add(OpportunityNewInstance);
                }    
                
                //renu added for checking if an event is present before making sub stage to demo scheduled of completed-- start
                if(
                    OpportunityOldInstance.StageName == OpportunityConstants.STAGENAME_SQL && 
                    OpportunityNewInstance.StageName != OpportunityOldInstance.StageName 
                ){    listOfEventValidation.add(OpportunityNewInstance);   
                 }
                //renu ended
                //Added by Raksha for new Esign Flow
                if(OpportunityNewInstance.Order_Form_Required__c == 'Yes' && OpportunityNewInstance.ESign_Category__c == 'Physical Sign' && OpportunityNewInstance.Physical_Sign_completed__c == true && OpportunityOldInstance.Physical_Sign_completed__c == false){
                    listOfPhysicalSignOppForOrderFormValidation.add(OpportunityNewInstance);
                }
                //Added by Raksha for new Esign Flow
                if(OpportunityNewInstance.Order_Form_Required__c == 'Yes' && OpportunityNewInstance.StageName == OpportunityConstants.STAGENAME_IN_FINANCE_APPROVAL && 
                   ((OpportunityNewInstance.Special_Terms__c == null && OpportunityNewInstance.Finance_approval_status__c == OpportunityConstants.APPROVAL_STATUS_FINANCE_APPROVAL_APPROVED)||
                    (OpportunityNewInstance.Special_Terms__c != null && OpportunityNewInstance.Finance_approval_status__c == OpportunityConstants.APPROVAL_STATUS_LEGAL_APPROVAL_APPROVED)) && //OpportunityOldInstance.Finance_approval_status__c != OpportunityConstants.APPROVAL_STATUS_FINANCE_APPROVAL_APPROVED &&
                   OpportunityNewInstance.ESign_Completed1__c <= 0 && OpportunityNewInstance.ESign_Category__c != null ){
                       System.debug('*ESign*');
                       if(OpportunityNewInstance.ESign_Category__c == 'E-Sign' && ((OpportunityNewInstance.Special_Terms__c == null && OpportunityOldInstance.Finance_approval_status__c != OpportunityConstants.APPROVAL_STATUS_FINANCE_APPROVAL_APPROVED)||(OpportunityNewInstance.Special_Terms__c != null && OpportunityOldInstance.Finance_approval_status__c != OpportunityConstants.APPROVAL_STATUS_LEGAL_APPROVAL_APPROVED))){
                           listOfeSignRequest.add(OpportunityNewInstance);
                           mapOfOppToItsESignCustomerId.put(OpportunityNewInstance.Id,OpportunityNewInstance.E_Sign_Customer_Info__c);
                       }else if(OpportunityNewInstance.ESign_Category__c == 'Physical Sign' && OpportunityNewInstance.Physical_Sign_completed__c == true && OpportunityOldInstance.Physical_Sign_completed__c == false){
                           listOfeSignRequest.add(OpportunityNewInstance);
                       }
                   }
                System.debug('listOfeSignRequest '+listOfeSignRequest);
                //End by Raksha for New Esign Flow
                
                //Added By Kartikeya 
                if(OpportunityNewInstance.StageName == OpportunityConstants.STAGENAME_CLOSED_LOST && OpportunityNewInstance.RecordTypeId == OpportunityConstants.RECORDTYPEID_RENEWAL)
                {
                    if(!relAssetMap.isEmpty())
                        if(relAssetMap.get(OpportunityNewInstance.id) != null){
                            OpportunityNewInstance.addError('Please mark the related asset -' +relAssetMap.get(OpportunityNewInstance.id).name +' related to PAN -'+relAssetMap.get(OpportunityNewInstance.id).account.PAN__c+' as Churn!' );
                        }
                }
                
                //bhaveshjindal
                //check if master admin email already exists in Accounts
                //System.debug('Debug for Master Admin email');
                //System.debug('OpportunityNewInstance.StageName'+ OpportunityNewInstance.StageName);
                //System.debug('OpportunityOldInstance.StageName'+ OpportunityOldInstance.StageName);
                //System.debug('OpportunityNewInstance.Finance_approval_status__c'+ OpportunityNewInstance.Finance_approval_status__c);
                //System.debug('OpportunityNewInstance.Master_admin_Email__c'+ OpportunityNewInstance.Master_admin_Email__c);
                
                /*if(
OpportunityNewInstance.StageName 					== OpportunityConstants.STAGENAME_IN_FINANCE_APPROVAL		&&
OpportunityNewInstance.StageName 					!= OpportunityOldInstance.StageName 						&&
OpportunityNewInstance.Master_admin_Email__c 		!= '' 
){

if( allAccountsMap.Values().contains(OpportunityNewInstance.Master_admin_Email__c) ){

system.debug('I am in Master Admin Check ');
System.debug('allAccountsMap.get(OpportunityNewInstance.AccountId) :' +allAccountsMap.get(OpportunityNewInstance.AccountId)+' OpportunityNewInstance.Master_admin_Email__c : ' +OpportunityNewInstance.Master_admin_Email__c);
if( 
allAccountsMap.get(OpportunityNewInstance.AccountId) != OpportunityNewInstance.Master_admin_Email__c
){
OpportunityNewInstance.addError('The Master Admin Email - ' +OpportunityNewInstance.Master_admin_Email__c +' already exists for a account.');
}
}
else{
for(Opportunity thisRec : oppListForMasterAdminCheck){
System.debug('thisRec.AccountId :' +thisRec.AccountId+'OpportunityNewInstance.AccountId : ' +OpportunityNewInstance.AccountId);
if(thisRec.AccountId != OpportunityNewInstance.AccountId){
System.debug('thisRec.Master_admin_Email__c :' +thisRec.Master_admin_Email__c+'OpportunityNewInstance.Master_admin_Email__c : ' +OpportunityNewInstance.Master_admin_Email__c);
if(thisRec.Master_admin_Email__c == OpportunityNewInstance.Master_admin_Email__c){
OpportunityNewInstance.addError('The Master Admin Email - ' +OpportunityNewInstance.Master_admin_Email__c +' already exists for an Opportunity : '+thisRec.Name);
}
}
}
}
}*/
                
                if(OpportunityNewInstance.StageName != OpportunityOldInstance.StageName 
                   && OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_CLOSED_LOST){
                       oppListForBlocking.add(OpportunityNewInstance);
                   }
            }
            if(OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_CLOSED_WON){
                shareOpporList.add(OpportunityNewInstance);
            }
            /**Added by NIRAJ - Update Opportunity Owner on Closeure**/
            if(OpportunityNewInstance.StageName != OpportunityOldInstance.StageName && OpportunityNewInstance.StageName.contains('Closed')){
                if(OpportunityNewInstance.Opportunity_Owner_Static__c == OpportunityOldInstance.Opportunity_Owner_Static__c && OpportunityNewInstance.Opportunity_Owner_Static__c == Null){
                    OpportunityNewInstance.Opportunity_Owner_Static__c = OpportunityNewInstance.OwnerId;
                }
                if(OpportunityNewInstance.Opportunity_Owner_Team_WBR_C_Static__c == OpportunityOldInstance.Opportunity_Owner_Team_WBR_C_Static__c &&
                   OpportunityNewInstance.Opportunity_Owner_Team_WBR_C_Static__c == Null)
                {
                    OpportunityNewInstance.Opportunity_Owner_Team_WBR_C_Static__c = mapOfUserSupMan.get(OpportunityNewInstance.OwnerId).Team_New__c != NULL ? mapOfUserSupMan.get(OpportunityNewInstance.OwnerId).Team_New__c : mapOfUserSupMan.get(OpportunityNewInstance.OwnerId).Team_WBR_C__c;
                }
            }
        }
        if(oppListForBlocking.size()>0){
            OpportunityTriggerHelper.blockOpportunities(oppListForBlocking,TRUE);
        }
        
        
        if(listOfOppToCheckValidation.size()>0){
            OpportunityTriggerHelper.stageValidation(listOfOppToCheckValidation);
            // OpportunityTriggerHelper.closedWonFilesValidation(listOfOppToCheckValidation); //Commented by Raksha
        }
        /* Added By Raksha */
        if(!listOfOppForFileUploadValidation.isEmpty()){
            OpportunityTriggerHelper.closedWonFilesValidation(listOfOppForFileUploadValidation, system.Label.OppDocTypeMandate, system.Label.Attachment_Error_Message);
        }
        /* End by Raksha */
        if( listOfOppForFileUploadValidation_SME.size()>0 && !Test.isRunningTest() ){
            OpportunityTriggerHelper.closedWonFilesValidation(listOfOppForFileUploadValidation_SME, system.Label.Opp_Doc_Type_INVOICE, system.Label.Attach_Invoice_Error_Message);
        }
        if(listOfStageValidation.size()>0 && !Test.isRunningTest()){
            OpportunityTriggerHelper.stageValidation(listOfStageValidation);
        }
        //renu start
        if(listOfEventValidation.size()>0){
            OpportunityTriggerHelper.opportunitySubstageValidationOnEvent(listOfEventValidation);
        }//renu end
        //Enhanced as a Part of P3CTX SSD1.1 10-Nov-2020 start
        if(listOfOpportunitysToApplyElCheckAndAssignfromQueue.size()>0){
            OpportunityTriggerHelper.updateOwnerBasedOnEligibilityFromMatrixfromQueueField(listOfOpportunitysToApplyElCheckAndAssignfromQueue);
        }
        //Enhanced as a Part of P3CTX SSD1.1 10-Nov-2020 end
        //Enhanced as a Part of P3CTX SSD1.1 12-Nov-2020 start
        if(listOfOpportunities.size()>0){
            OpportunityTriggerHelper.extensionApproveUpdateValue(listOfOpportunities);
        }
        //Enhanced as a Part of P3CTX SSD1.1 12-Nov-2020 end
        
        // Added by Raksha
        if(!listOfOppForOrderFormValidation.isEmpty()){
            System.debug('****** listOfOppForOrderFormValidation '+listOfOppForOrderFormValidation);
            OpportunityTriggerHelper.checkForOrderForm(listOfOppForOrderFormValidation,false);
        }
        if(!listOfPhysicalSignOppForOrderFormValidation.isEmpty()){
            
            //System.debug('****** listOfPhysicalSignOppForOrderFormValidation '+listOfPhysicalSignOppForOrderFormValidation);
            //listOfPhysicalSignOppForOrderFormValidation[0].addError('Test Error');
            //System.debug('***********************************');
            OpportunityTriggerHelper.checkForOrderForm(listOfPhysicalSignOppForOrderFormValidation,true);
        } //End by Raksha
        
        //Added by Raksha
        if(!listOfeSignRequest.isEmpty()){
            //System.debug('Handler listOfeSignRequest '+listOfeSignRequest);
            OpportunityTriggerHelper.eSignCallOutCTXAndClient(listOfeSignRequest,mapOfOppToItsESignCustomerId);
        }
        
        
        Map<Id,Opportunity> newOppMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> newOppMapToMandateBilling = new Map<Id,Opportunity>();
        Id currentProfileId = userinfo.getProfileId();
        
        for(Id key : mapofNewsObjectRecords.keySet()){
            Opportunity oppNewInstance=(Opportunity)mapofNewsObjectRecords.get(key);
            Opportunity oppOldInstance=(Opportunity)mapofOldsObjectRecords.get(key);
            
            if(oppNewInstance.StageName != oppOldInstance.StageName &&
               oppNewInstance.StageName == 'Closed Won' &&
               oppNewInstance.Win_Loss_Details__c != NULL &&
               oppNewInstance.Win_Loss_Reasons__c != NULL &&
               oppNewInstance.competition_Currently_Using__c != NULL){
                   oppNewInstance.Sales_Stage_New__c = 'Deal Won';
               }
            
            if(oppNewInstance.Sales_Stage_New__c != oppOldInstance.Sales_Stage_New__c &&
               oppNewInstance.Sales_Stage_New__c == 'Deal Lost'){
                   oppNewInstance.StageName = 'Closed Lost';
               }
            
            if(oppNewInstance.Is_Auto_Renewal_Enabled__c == oppOldInstance.Is_Auto_Renewal_Enabled__c &&
               OpportunityConstants.AUTO_RENEW_RULE &&
               oppNewInstance.Is_Auto_Renewal_Enabled__c == TRUE){
                   if( !system.label.Auto_Renewal_Discount_Approval_Eligible_Email.containsIgnoreCase( UserInfo.getUserEmail() ) ){
                       //oppNewInstance.addError(System.Label.CTX_AutoRenewal_Error_Msg );
                   }
               }
            
            if(oppNewInstance.Sales_Stage_New__c != oppOldInstance.Sales_Stage_New__c &&
               oppNewInstance.Sales_Stage_New__c == 'Deal Inactive'){
                   oppNewInstance.StageName = 'Inactive ';
               }
            
            /** START : Ashwin : restrictPaymentTerms **/
            if(
                ( oppNewInstance.Country_of_Origin__c == NULL || oppNewInstance.Country_of_Origin__c == 'India' ) &&
                oppNewInstance.ClearTax_Billing_Entity__c != 'CimplyFive' &&
                (
                    !oppNewInstance.Is_Auto_Renewal_Enabled__c && 
                    oppNewInstance.Billing_F__c == NULL ||
                    oppNewInstance.Billing_Frequency_for_Integration_Prods__c == NULL      ||
                    oppNewInstance.Billing_Frequency__c == NULL ||
                    oppNewInstance.MS_Billing_Frequency__c  == NULL)                            &&
                !System.isFuture()                                                      &&
                (oppNewInstance.SyncedQuoteId != NULL                                   &&
                 oppOldInstance.SyncedQuoteId != NULL)									&&
                oppNewInstance.StageName      != 'In Finance Approval' 					&&	
                oppNewInstance.StageName  	 != 'Closed Won' 							&&
                oppNewInstance.StageName  	 != 'Closed Lost'){
                    newOppMapToMandateBilling.put(oppNewInstance.Id, oppNewInstance);
                }
            
            if(!(System.label.SystemAdminProfileId.contains(currentProfileId))){
                if(
                    ( 
                        ( oppNewInstance.Country_of_Origin__c == NULL || oppNewInstance.Country_of_Origin__c == 'India' ) &&
                        oppNewInstance.ClearTax_Billing_Entity__c != 'CimplyFive' &&
                        oppNewInstance.StageName     != 'In Finance Approval' 					&&	
                        oppNewInstance.StageName  	 != 'Closed Won' 							&&
                        oppNewInstance.StageName  	 != 'Closed Lost') 							&&
                    oppNewInstance.SyncedQuoteId != NULL)
                {
                    if(oppNewInstance.Billing_F__c 							     != oppOldInstance.Billing_F__c ||
                       oppNewInstance.Billing_Frequency_for_Integration_Prods__c != oppOldInstance.Billing_Frequency_for_Integration_Prods__c || 
                       oppNewInstance.Billing_Frequency__c 					     != oppOldInstance.Billing_Frequency__c ||
                       oppNewInstance.Payment_Term__c 							 != oppOldInstance.Payment_Term__c ){
                           newOppMap.put(oppNewInstance.Id, oppNewInstance);
                       }
                    
                } 
            }  
        }
        
        
        if(!newOppMapToMandateBilling.values().isEmpty()){
            OpportunityTriggerHelper.mandatoryBillingTerms(newOppMapToMandateBilling);
        }
        
        if(!newOppMap.values().isEmpty()){
            OpportunityTriggerHelper.restrictPaymentTerms((Map<Id,Opportunity>)newOppMap,(Map<Id,Opportunity>)mapofOldsObjectRecords);
        }
        /** END : Ashwin : restrictPaymentTerms **/
        
        OpportunityTriggerHelper.calculateDealValue((list<Opportunity>)mapofNewsObjectRecords.Values());
        OpportunityTriggerHelper.validateCompanyInfo((Map<Id,Opportunity>)mapofNewsObjectRecords,(Map<Id,Opportunity>)mapofOldsObjectRecords);
        
        OpportunityTriggerHelper.mandatoryCheckBasedOnProductInterested((Map<Id,Opportunity>)mapofNewsObjectRecords,(Map<Id,Opportunity>)mapofOldsObjectRecords);
        //CTX_ApexRecordSharing.apexShare_Opportunity_AccountSalesOwnerpricinAccess(new Map<Id, Opportunity>(shareOpporList));
    }
    
    
    public void afterUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){
        
        //String 	opportunity_International_RecordTypeId 	= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OpportunityConstants.RECORDTYPE_INTERNATIONAL).getRecordTypeId();
        Map<Id, Opportunity> newOpportunityMap = (Map<Id, Opportunity>)mapofNewsObjectRecords;
        //Resend Logic Raw data
        //Map<Id, Opportunity>    opportunitiesWithAllDetails;
        Map<Id, ContentDocumentLink> opporCDLinkMap = new Map<Id, ContentDocumentLink>();
        Map<Id, ContentVersion> CDCVMapSystemGenerated = new Map<Id, ContentVersion>();
        Map<Id, ContentVersion> CDCVMapNonSystemGenerated = new Map<Id, ContentVersion>();
        List<ContentVersion> ClonedCV = new List<ContentVersion>();
        Set<Id> CDId = new Set<Id>();
        List<Opportunity> shareOpporList = new List<Opportunity>();
        
        
        
        /** Added by Murali **/
        Map<Id,Opportunity> mapofNewOpportunityRecords = (Map<Id, Opportunity>)mapofNewsObjectRecords;
        Map<Id,Opportunity> mapofoldOpportunityRecords = (Map<Id, Opportunity>)mapofOldsObjectRecords;
        List<Opportunity> newOppty = new List<Opportunity>();
        for(Opportunity opp : mapofNewOpportunityRecords.values()){
            system.debug('inside for in before new'+opp.Billing_GST__c);
            system.debug('inside for in before old'+mapofoldOpportunityRecords.get(opp.id).Billing_GST__c);
            if(((opp.Billing_GST__c!= mapofoldOpportunityRecords.get(opp.id).Billing_GST__c) || (opp.TIN_Number__c!= mapofoldOpportunityRecords.get(opp.id).TIN_Number__c) || (opp.ClearTax_Billing_Entity__c!= mapofoldOpportunityRecords.get(opp.id).ClearTax_Billing_Entity__c))
              && (opp.Billing_GST__c!='' && opp.Billing_GST__c != NULL)
              ){
                newOppty.add(opp);
            }
            system.debug('newOppty'+newOppty);
        }
        if(system.label.ActiveOrDeactivateGSTINValidation == 'true'){
            GSTINValidationHelperForOpportunity.validateOpportunityBaseOnReceivablePan(newOppty);// added by Murali
        }
        /** End**/
        
        
        /** Query Opportunity with Additional Details : START   **/
        /**opportunitiesWithAllDetails = new Map<Id, Opportunity>(
[ SELECT Id, AccountId, master_admin_email__c, Company_Domain_Name__c,  

Account.master_admin_email__c, Account.Company_Domain_Name__c, Account.Channel_Partner_Type__c 

FROM Opportunity WHERE 

Id IN :mapofNewsObjectRecords.keySet() ]
);**/
        List<Opportunity> oppRecordList = [ SELECT Id, Name, StageName,
                                           
                                           Order_Form_Required__c, ESign_Category__c, ESign_BE_Docket_ID__c, ESign_BE_Document_ID__c, 
                                           ESign_Sign_Status__c, ESign_CTX_Status__c, ESign_Message__c, E_Sign_Customer_Info__c, 
                                           E_Sign_Customer_Info__r.Phone, E_Sign_Customer_Info__r.Email,
                                           
                                           ( SELECT Id, LinkedEntityId, ContentDocumentId, SystemModstamp 
                                            FROM ContentDocumentLinks  ORDER BY SystemModstamp DESC LIMIT 1 )
                                           
                                           FROM Opportunity WHERE 
                                           Id IN :  mapofNewsObjectRecords.keySet()
                                          ];
        for(Opportunity oppor: oppRecordList ){
            If(oppor.ContentDocumentLinks.size() > 0){
                opporCDLinkMap.put(oppor.Id,oppor.ContentDocumentLinks[0]);
                CDId.add(oppor.ContentDocumentLinks[0].ContentDocumentId);
            }
        }
        List<ContentVersion> CVList = [SELECT Id, ContentDocumentId,  ContentUrl,PathOnClient,  VersionNumber, Title, Description, 
                                       
                                       OwnerId, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp, TagCsv, System_Generated__c,
                                       FileType, PublishStatus, VersionData, ContentSize, FileExtension, Origin, 
                                       NetworkId, ContentLocation, TextPreview, ExternalDocumentInfo1, ExternalDocumentInfo2, ExternalDataSourceId, 
                                       Parent_RecordId__c, Type_of_document__c, Lock_Content_Version__c
                                       FROM ContentVersion WHERE   (ContentDocumentId IN : CDId ) AND (Type_of_document__c = 'Order Form') 
                                       ORDER BY SystemModstamp DESC
                                      ];
        for(ContentVersion CVIns:CVList){
            if(!CDCVMapSystemGenerated.containsKey(CVIns.ContentDocumentId) && CVIns.System_Generated__c){
                CDCVMapSystemGenerated.put(CVIns.ContentDocumentId, CVIns);
            }
            else if(!CDCVMapNonSystemGenerated.containsKey(CVIns.ContentDocumentId) && !CVIns.System_Generated__c){
                CDCVMapNonSystemGenerated.put(CVIns.ContentDocumentId, CVIns);
            }
        }
        //Resend Logic Raw data
        RecursiveTriggerHandler.isFirstTimeOpportunityCounter++;
        if(
            !System.UserInfo.getUserId().contains('0052x0000026gDe') || 
            RecursiveTriggerHandler.isFirstTimeOpportunityCounter > 1
        ){
            RecursiveTriggerHandler.isFirstTimeOpportunity = false;
        }
        
        
        List<Opportunity>	ListofNewOpportunitytoUpdate	= new List<Opportunity>();
        List<Opportunity>	ListofOpportunitytoUpdate		= new List<Opportunity>();
        List<Opportunity>	ListofOpportunitytoAdmin		= new List<Opportunity>();
        List<Opportunity> 	listOfOpportunityForApproval 	= new List<Opportunity>();
        List<Account> 		ListOfAccounttoUpdate 			= new List<Account>();
        List<sObject> 		listOfOldAndNewRecords 			= new list<sObject>();
        String 				opportunity_ITR_RecordTypeId 	= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OpportunityConstants.RECORDTYPE_ITR).getRecordTypeId();
        
        Messaging.SingleEmailMessage[] 	mails				= new List<Messaging.SingleEmailMessage>();
        /**	Arr Roll up Pramodh: START	**/
        /*listOfOldAndNewRecords.addAll(mapofNewsObjectRecords.values());
listOfOldAndNewRecords.addAll(mapofOldsObjectRecords.values());
OpportunityTriggerHelper.ARRRollUp(listOfOldAndNewRecords);*/
        /**	Arr Roll up Pramodh: END	**/
        
        for(Id key:mapofNewsObjectRecords.KeySet()){
            Opportunity OpportunityNewInstance=(Opportunity)mapofNewsObjectRecords.get(key);
            Opportunity OpportunityOldInstance=(Opportunity)mapofOldsObjectRecords.get(key);
            
            if(OpportunityNewInstance.Is_Auto_Renewal_Enabled__c != OpportunityOldInstance.Is_Auto_Renewal_Enabled__c){
                
            }
            
            if
                (
                    !String.ISBLANK(OpportunityNewInstance.Retrigger_E_Sign__c)
                    && !(OpportunityOldInstance.Retrigger_E_Sign__c == 'Sent' && OpportunityNewInstance.Retrigger_E_Sign__c == 'Sent Successfully') && OpportunityConstants.ESIGNRESEND == 'Resend'
                ){ 
                    ContentVersion cv ;
                    if(OpportunityNewInstance.ESign_Category__c == 'E-Sign'){
                        if(
                            OpportunityNewInstance.Country_of_Origin__c != 'India' && 
                            OpportunityNewInstance.Country_of_Origin__c != 'N/A' &&
                            OpportunityNewInstance.Country_of_Origin__c != NULL
                        ){
                            cv = CDCVMapNonSystemGenerated.get(opporCDLinkMap.get(OpportunityNewInstance.Id).ContentDocumentId); 
                        }
                        else{
                            cv = CDCVMapSystemGenerated.get(opporCDLinkMap.get(OpportunityNewInstance.Id).ContentDocumentId);
                        }
                    }
                    else{
                        cv = CDCVMapNonSystemGenerated.get(opporCDLinkMap.get(OpportunityNewInstance.Id).ContentDocumentId); 
                    }
                    if(cv != null){
                        //system.debug('Versiondata$%^^$'+ EncodingUtil.base64Encode(cv.VersionData));
                        //system.debug('VersionBodyId$%^^$'+ cv.contentBodyId);
                        system.debug('VersionId$%^^$'+ cv.Id);
                        ContentVersion cvClone = cv.Clone();
                        cvClone.versionData= cv.VersionData;
                        cvClone.ContentBodyId = null;
                        If(!cvClone.Title.Contains('ResentFileV')){
                            cvClone.Title = cvClone.Title + 'ResentFileV0';
                        }
                        else{
                            Integer currentVer = Integer.ValueOf(cvClone.Title.substringAfterLast('V'))+1;
                            cvClone.Title = cvClone.Title.replace(cvClone.Title.substringAfterLast('V'),String.valueOf(currentVer));  
                        }
                        ClonedCV.add(cvClone);
                    }
                    else{
                        OpportunityNewInstance.addError('Please generate Order Form for E-Sign or Upload a signed copy for Physical Sign!');
                    }
                }
            if(OpportunityNewInstance.StageName != OpportunityConstants.STAGENAME_CLOSED_WON){
                shareOpporList.add(OpportunityNewInstance);
            }
            /**	Revoke Order Form : START	**/
            if(
                (OpportunityNewInstance.StageName != NULL                               && 
                 OpportunityOldInstance.StageName == 'In Finance Approval' 				&& 
                 !OpportunityNewInstance.StageName.contains('Closed') 					&& 
                 OpportunityOldInstance.StageName != OpportunityNewInstance.StageName) ||
                (
                    OpportunityOldInstance.Physical_Sign_completed__c != OpportunityNewInstance.Physical_Sign_completed__c &&
                    !OpportunityNewInstance.Physical_Sign_completed__c    
                ) || 
                (
                    !String.ISBLANK(OpportunityNewInstance.Retrigger_E_Sign__c)
                    && !(OpportunityOldInstance.Retrigger_E_Sign__c == 'Sent' && OpportunityNewInstance.Retrigger_E_Sign__c == 'Sent Successfully') && OpportunityOldInstance.Retrigger_E_Sign__c !=OpportunityNewInstance.Retrigger_E_Sign__c
                )
            ){ 
                system.debug('OpportunityOldInstance.Retrigger_E_Sign__c%%' +OpportunityOldInstance.Retrigger_E_Sign__c);
                system.debug('OpportunityNewInstance.Retrigger_E_Sign__c%%' +OpportunityNewInstance.Retrigger_E_Sign__c);
                System.debug('In Revoke Approval');
                CTX_SignDeskAPIQueuable myJob 
                    = new CTX_SignDeskAPIQueuable( 
                        OpportunityNewInstance.ESign_BE_Document_ID__c, 
                        OpportunityNewInstance.ESign_BE_Docket_ID__c
                    );
                System.enqueueJob(myJob);
            }	/**	Revoke Order Form : END	**/
            
            if(
                OpportunityNewInstance.RecordTypeId != opportunity_ITR_RecordTypeId
            ){
                if(
                    OpportunityNewInstance.StageName != NULL 										&& 
                    OpportunityNewInstance.StageName != OpportunityOldInstance.StageName 			&& 
                    OpportunityNewInstance.StageName == OpportunityConstants.STAGENAME_CLOSED_WON
                ){
                    
                    ListofNewOpportunitytoUpdate.add(OpportunityNewInstance);
                    System.debug('OpportunityNewInstance.hasErrors()' + OpportunityNewInstance.hasErrors());
                    
                    /**	Added By Kartikeya	**/
                    If(
                        OpportunityNewInstance.Master_admin_Email__c 	!= '' && 
                        OpportunityNewInstance.Company_Domain_Name__c 	!= ''
                    ){
                        if( !OpportunityNewInstance.hasErrors() ){
                            
                            Account acc 				= new account();
                            acc.id 						= OpportunityNewInstance.accountId;
                            if(
                                OpportunityNewInstance.Country_of_Origin__c != 'India' && 
                                OpportunityNewInstance.Country_of_Origin__c != 'N/A' && 
                                OpportunityNewInstance.Country_of_Origin__c != NULL
                            ){
                                acc.Master_admin_Email__c 	= OpportunityNewInstance.Master_admin_Email__c;
                            } else{
                                acc.Master_admin_Email__c 	= NULL;
                            }
                            
                            acc.Company_Domain_Name__c	= OpportunityNewInstance.Company_Domain_Name__c;
                            ListOfAccounttoUpdate.add(Acc);
                        }
                    }
                }
                
                
                if(
                    (
                        (
                            OpportunityNewInstance.Finance_approval_status__c != NULL && 
                            OpportunityNewInstance.Finance_approval_status__c != OpportunityOldInstance.Finance_approval_status__c && 
                            (
                                OpportunityNewInstance.Finance_approval_status__c == OpportunityConstants.APPROVAL_STATUS_FINANCE_APPROVAL_APPROVED || 
                                OpportunityNewInstance.Finance_approval_status__c==OpportunityConstants.APPROVAL_STATUS_LEGAL_APPROVAL_APPROVED 
                            )
                        ) || (
                            OpportunityNewInstance.E_Sign_Status__c != OpportunityOldInstance.E_Sign_Status__c
                        )
                    ) &&
                    RecursiveTriggerHandler.isFirstTimeOpportunityCounter < 2 //do not remove, can cause SOQL 101 error.
                ){
                    RecursiveTriggerHandler.isFirstTimeOpportunity = TRUE;  
                }
            }
            
            /**	Closed Lost Opportunity Email Trigger	**/
            System.debug('Closed Lost Opportunity Email Trigger');
            if(
                OpportunityNewInstance.StageName != OpportunityOldInstance.StageName && 
                OpportunityNewInstance.StageName == 'Closed Lost' &&
                !System.Label.Opportunity_Renewal_RecordType_Ids.containsIgnoreCase(OpportunityNewInstance.RecordTypeId)
            ){
                mails.add(
                    CTX_DealClosureNotification.constructEmailBody(OpportunityNewInstance)
                );
            }
            /**	Closed Lost Opportunity Email Trigger : END	**/
        }
        
        if(ListofNewOpportunitytoUpdate.size()>0){
            OpportunityTriggerHelper.CreateOrder(ListofNewOpportunitytoUpdate); 
        }
        
        //to avoid System.listException for duplicate Ids
        Map<id,account> accMap = new map<id,account>();
        accMap.putAll(ListOfAccounttoUpdate);
        
        if(OpportunityConstants.STATCHECK){ 
            If(accMap.size() > 0){
                
                try{
                    AccountConstants.isFirstTimeAccount = FALSE;
                    update accMap.values(); 
                }catch(DMLException ex){
                    for(Opportunity thisRec : newOpportunityMap.values()){
                        if(ex.getDmlId(0).contains(thisRec.AccountId)){
                            thisRec.addError(ex.getDmlMessage(0));
                        }
                    }
                }
                
                OpportunityConstants.STATCHECK = FALSE;
                
                for(
                    Opportunity Oppor : [ SELECT Id, master_admin_email__c, Account.master_admin_email__c, Account.Company_Domain_Name__c, Company_Domain_Name__c 
                                         FROM Opportunity WHERE 
                                         AccountId IN :ListOfAccounttoUpdate AND 
                                         ( NOT Id in:mapofNewsObjectRecords.keySet() ) AND  
                                         StageName != :OpportunityConstants.STAGENAME_CLOSED_WON AND 
                                         StageName != :OpportunityConstants.STAGENAME_CLOSED_LOST ]
                ){
                    
                    Oppor.Master_admin_Email__c 	= Oppor.account.master_admin_email__c;
                    Oppor.Company_Domain_Name__c 	= Oppor.account.Company_Domain_Name__c;
                    ListofOpportunitytoAdmin.add(Oppor);
                }
            }
            
            If(ListofOpportunitytoAdmin.size()>0){
                system.debug('ListofOpportunitytoAdmin Size: '+ListofOpportunitytoAdmin.size());
                try{
                    RecursiveTriggerHandler.isFirstTimeOpportunity = FALSE;
                    Database.Update (ListofOpportunitytoAdmin,TRUE);
                    RecursiveTriggerHandler.isFirstTimeOpportunity = TRUE;
                }
                catch(exception e){
                    system.debug('Error in opportunity'+e.getMessage());
                }
            }
        }
        
        Set<Account> accountsListToUpdateAccountType = new Set<Account>();
        for(
            Opportunity thisOpportunity : [ SELECT Id, AccountId, Account.Channel_Partner_Type__c 
                                           From Opportunity WHERE 
                                           Id IN :mapofNewsObjectRecords.keySet()]
        ){
            
            if( thisOpportunity.Account.Channel_Partner_Type__c != 'Commission Partner' ){
                
                accountsListToUpdateAccountType.add( 
                    new Account(
                        Id = thisOpportunity.AccountId
                    )
                );
            }
        }
        
        if(accountsListtoUpdateAccountType.size() > 0){
            
            System.debug('accountsListToUpdateAccountType'+ accountsListToUpdateAccountType);
            AccountConstants.isFirstTimeAccount = FALSE;
            update new List<Account>(accountsListToUpdateAccountType) ;
        }
        OpportunityTriggerHelper.CreateContactRoles((Map<Id, Opportunity>)mapofNewsObjectRecords,(Map<Id, Opportunity>)mapofOldsObjectRecords); 
        if(ClonedCV.size() > 0){
            insert(ClonedCV);
        }
        if(!OpportunityConstants.listOfeSignRequest.isEmpty()){
            System.debug('Handler listOfeSignRequest '+OpportunityConstants.listOfeSignRequest);
            OpportunityTriggerHelper.eSignCallOutCTXAndClient(OpportunityConstants.listOfeSignRequest,OpportunityConstants.mapOfOppToItsESignCustomerId);
        }
        
        /*        
Map<Id,Opportunity> mapOfNewOpp = new Map<Id,Opportunity>();
Set<Id> accountIdsToUpdateOwner = new Set<Id>();
for(Id key:mapofNewsObjectRecords.KeySet()){
Opportunity oppNewInstance=(Opportunity)mapofNewsObjectRecords.get(key);
Opportunity oppOldInstance=(Opportunity)mapofOldsObjectRecords.get(key);
//added by bhaveshjindal : update Account Owner based on region/PGSB/Segment 
if(
oppNewInstance.Country_of_Origin__c != 'India' &&
oppNewInstance.Country_of_Origin__c != 'N/A' &&
oppNewInstance.Country_of_Origin__c != NULL &&
oppNewInstance.StageName != oppOldInstance.StageName && 
oppNewInstance.StageName == 'Closed Won'){
accountIdsToUpdateOwner.add(oppNewInstance.AccountId);
}
}

if(accountIdsToUpdateOwner.size()>0){
AccountTriggerHelper.updateAccountOwner(accountIdsToUpdateOwner);
}
*/
        
        
        /**	Send Closure Mail : DEAL LOST	**/
        system.debug('mails:mails:mails: '+mails);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        
        system.debug('results:::: '+results);
        /*if (results[0]?.success) 
{
System.debug('The email was sent successfully.');
} else {
System.debug('The email failed to send: ' +results[0].errors[0].message);
}*/
        /**	Send Closure Mail : DEAL LOST END	**/
        
        
        OpportunityTriggerHelper.UpdateBillingDetailsActionOwner((Map<Id, Opportunity>) mapofNewsObjectRecords, (Map<Id, Opportunity>) mapofOldsObjectRecords);
        OpportunityTriggerHelper.CreateDemoTask((Map<Id, Opportunity>) mapofNewsObjectRecords, (Map<Id, Opportunity>) mapofOldsObjectRecords);
        
        CTX_ApexRecordSharing.apexShare_Opportunity_AccountSalesOwnerAccess(new Map<Id, Opportunity>(shareOpporList));
        
        
    }
    
    
    public void beforeDelete(list<sObject> listofOldsObjectRecords,map<id,sObject> mapofOldsObjectRecords){}
    
    
    public void afterDelete(map<id,sObject> mapofOldsObjectRecords){
        OpportunityTriggerHelper.ARRRollUp(mapofOldsObjectRecords.values());
    }
    
    
    public void afterUndelete(list<sObject> listofNewsObjectRecords,map<id,sObject> mapofNewsObjectRecords){
        OpportunityTriggerHelper.ARRRollUp(listofNewsObjectRecords);
    }
    
    
    
}