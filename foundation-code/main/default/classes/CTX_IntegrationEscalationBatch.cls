public class CTX_IntegrationEscalationBatch implements Database.Batchable<sObject>{
    
    Public String 	queryString = ' SELECT Id, Name, Owner.Name, CreatedDate, PurchaseDate, RecordTypeId, Project_Stage__c, Status, Account_ARR_Type__c, Escalation_Days_Count__c, Priority_List__c, Escalation_Mail_Level__c, Aging_In_Stage__c, Product2.Name, Aging_in_current_Stage__c , Product2.Product_category__c, Account.Name, Price, Account.PGSB__c, Account.Onboarding_Owner__r.Name,  Account.Cross_Sell_KAM_Owner__r.Name, Account.Onboarding_Owner__r.Email, Account.Onboarding_Owner__r.Manager.Email, Account.Owner.Email, Account.Sales_Owner__r.Email, Account.Sales_Owner__r.Manager.Email, Account.Sales_Owner__r.Manager.Manager.Email,Account.Owner.Name, Project_Comment_Field__c, Project_Issue_Description_Field__c, Project_PM_Owner_Email_Field__c, Project_Solution_Engineer_Email_Field__c, PM_Project_Owner_Name__c, Project_Last_Modified_Date_Field__c, Project_Name__c, Project_Issue_Type__c, Project_Client_ERP__c, Project_ID__c FROM Asset WHERE Product2.Product_category__c = \'Integration\' AND Priority_List__c != NULL AND Account_ARR_Type__c != NULL AND Project_Status__c != \'Churn\' AND Project_Stage__c != \'Live\' AND Project_Scope_Category__c = \'Development\' AND Project_Stage__c != \'\' AND Aging_In_Stage__c != null ';
    Public String 	query;
    Public Integer	batchSize 	= 20;
    
    Public CTX_IntegrationEscalationBatch(String query){
        this.query 		= query;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        if(query == NULL){
            
            system.debug('Inside Query NULL: '+queryString);
            return Database.getQueryLocator(queryString);
        } else{
            
            system.debug('Inside Query Not NULL: '+query);
            return Database.getQueryLocator(query);
        }
    }
    
    public void execute(Database.BatchableContext BC, List<Asset> scope){
        
        if(scope.size() > 0){
            
            system.debug('Inside Scope Not Null: '+scope.size());
            CTX_ProjectEscalationEmailHelper.performEscalationEmailogic(scope);
        } else{
            system.debug('Inside Scope Null: ');
        }
    }
    
    public void finish(Database.BatchableContext BC){}
    
    
}