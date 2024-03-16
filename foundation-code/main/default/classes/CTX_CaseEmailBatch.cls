/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-06-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class CTX_CaseEmailBatch implements Database.Batchable<sObject>, Schedulable {
    
    public string 	queryString;
    public integer 	queryInMinutes;
    
    public CTX_CaseEmailBatch( String queryString, Integer queryInMinutes ){
        this.queryString 	= queryString;
        this.queryInMinutes = queryInMinutes;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        if( queryString != NULL ){
            Datetime timeBeforeMinutes 	= queryInMinutes != NULL ? Datetime.now().addMinutes(queryInMinutes) : Datetime.now().addMinutes(-60);
            queryString  				= queryString + ' LastModifiedDate >= :timeBeforeMinutes';
        } else{
            Datetime thirtyMinutesAgo 	= Datetime.now().addMinutes(-60);
            queryString					= ' SELECT Id, LastModifiedDate, CaseNumber, JIRA_Notification_Rollout_Time__c, Account.Onboarding_Owner__r.EMail, Account.Onboarding_Owner__r.Manager_Email__c, LastModifiedBy.Email, LastModifiedBy.Manager_Email__c, Owner_Email__c, Owner.Email, Account_Name__c, Account_Active_ARR__c, Products_Available__c, Subject, Jira_URL__c, Owner.Name, Status_JIRA__c, JIRA_Comment_Updates__c, Developer_Comment_JIRA__c, Planned_Release_Date_JIRA__c, CreatedDate, JIRA_Ticket_Created_Date__c, L3_Developer_JIRA__c, OwnerId FROM Case WHERE JIRA_Issue_Id__c != NULL AND LastModifiedBy.Name LIKE \'%JIRA Integration Site Guest User%\' AND ( NOT Status IN (\'Solved\', \'Closed\') ) AND LastModifiedDate >= :thirtyMinutesAgo ';
        }

        system.debug('CTX_CaseEmailBatch queryString: '+queryString);
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> caseList) {
        
        system.debug('CTX_CaseEmailBatch caseList: '+caseList);
        try {
            RecursiveTriggerHandler.isFirstTime         = FALSE;
            RecursiveTriggerHandler.isFirstTimeRenewed  = FALSE;
            CaseConstants.isFirstTimeCase				= FALSE;
            
            String returnValue = CTX_CaseEmailsShooter.sendEmailAlertForJiraFieldUpdate(caseList);
            system.debug('returnValue'+returnValue);
            database.update( caseList, FALSE );/**	JIRA_Notification_Rollout_Time	**/

            CaseConstants.isFirstTimeCase				= TRUE;
            RecursiveTriggerHandler.isFirstTime 		= TRUE;
            RecursiveTriggerHandler.isFirstTimeRenewed  = TRUE;
        } catch(Exception e) {
            System.debug('exception in batch'+e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC){}
    
    global void execute(SchedulableContext sc) {

        if( queryString != NULL ){
            Datetime timeBeforeMinutes 	= queryInMinutes != NULL ? Datetime.now().addMinutes(queryInMinutes) : Datetime.now().addMinutes(-60);
            queryString  				= queryString + ' LastModifiedDate >= :timeBeforeMinutes';
        } else{
            Datetime thirtyMinutesAgo 	= Datetime.now().addMinutes(-60);
            queryString					= ' SELECT Id, LastModifiedDate, CaseNumber, JIRA_Notification_Rollout_Time__c, Account.Onboarding_Owner__r.EMail, Account.Onboarding_Owner__r.Manager_Email__c, LastModifiedBy.Email, LastModifiedBy.Manager_Email__c, Owner_Email__c, Owner.Email, Account_Name__c, Account_Active_ARR__c, Products_Available__c, Subject, Jira_URL__c, Owner.Name, Status_JIRA__c, JIRA_Comment_Updates__c, Developer_Comment_JIRA__c, Planned_Release_Date_JIRA__c, CreatedDate, JIRA_Ticket_Created_Date__c, L3_Developer_JIRA__c, OwnerId FROM Case WHERE JIRA_Issue_Id__c != NULL AND LastModifiedBy.Name LIKE \'%JIRA Integration Site Guest User%\' AND ( NOT Status IN (\'Solved\', \'Closed\') ) AND LastModifiedDate >= :thirtyMinutesAgo ';
        }
        
        Database.executeBatch( 
            new CTX_CaseEmailBatch( ' SELECT Id, LastModifiedDate, CaseNumber, JIRA_Notification_Rollout_Time__c, Account.Onboarding_Owner__r.EMail, Account.Onboarding_Owner__r.Manager_Email__c, LastModifiedBy.Email, LastModifiedBy.Manager_Email__c, Owner_Email__c, Owner.Email, Account_Name__c, Account_Active_ARR__c, Products_Available__c, Subject, Jira_URL__c, Owner.Name, Status_JIRA__c, JIRA_Comment_Updates__c, Developer_Comment_JIRA__c, Planned_Release_Date_JIRA__c, CreatedDate, JIRA_Ticket_Created_Date__c, L3_Developer_JIRA__c, OwnerId FROM Case WHERE JIRA_Issue_Id__c != NULL AND LastModifiedBy.Name LIKE \'%JIRA Integration Site Guest User%\' AND ( NOT Status IN (\'Solved\', \'Closed\') ) AND ', -60 ),
            100
        );
    }
    
}