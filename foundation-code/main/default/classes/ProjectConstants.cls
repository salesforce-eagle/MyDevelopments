public class ProjectConstants {
    
    public static Boolean isFirstTimeProject = true;
    public static Boolean isFirstTimeApa = true;
    
    //Day to send email
    public static Set<Id> setOfProjectUpdated = new Set<Id>();
    public static final Integer AWAITING_KICK_OFF_1 = 1;
    public static final Integer AWAITING_KICK_OFF_2 = 7;
    public static final Integer AWAITING_KICK_OFF_3 = 14;
    public static final Integer AWAITING_KICK_OFF_4 = 21;
    public static final Integer AWAITING_KICK_OFF_5 = 30;
    public static final Integer AWAITING_KICK_OFF_6 = 40;
    
    public static final Integer PROJECT_PLAN_1 = 7;
    public static final Integer PROJECT_PLAN_2 = 20;
    public static final Integer PROJECT_PLAN_3 = 25;
    public static final Integer PROJECT_PLAN_4 = 30;
    public static final Integer PROJECT_PLAN_5 = 40;
    public static final Integer PROJECT_PLAN_6 = 50;
    
    public static final Integer IMPLEMENTAION_1 = 20;
    public static final Integer IMPLEMENTAION_2 = 30;
    public static final Integer IMPLEMENTAION_3 = 40;
    public static final Integer IMPLEMENTAION_4 = 50;
    public static final Integer IMPLEMENTAION_5 = 60;
    public static final Integer IMPLEMENTAION_6 = 70;
    
    public static final Integer UAT_1 = 30;
    public static final Integer UAT_2 = 50;
    public static final Integer UAT_3 = 60;
    public static final Integer UAT_4 = 70;
    public static final Integer UAT_5 = 80;
    public static final Integer UAT_6 = 90; 
    
    public static final Id PROJECT_MAXITC_RECORDTYPEID = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('Max_ITC_SAP').getRecordTypeId();
    public static final Id PROJECT_AMC_MODULE_RECORDTYPEID = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('AMC_Module').getRecordTypeId();
    public static final Id PROJECT_ID_RECORDTYPEID = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('Invoice_Discounting').getRecordTypeId();
    public static final Id PROJECT_DEFAULT_RECORDTYPEID = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();

}