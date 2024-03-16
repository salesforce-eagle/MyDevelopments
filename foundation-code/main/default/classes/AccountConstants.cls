public class AccountConstants {
    public static Boolean isFirstTimeAccount = true;
    //RecordType Name Account
    public static final String CLEARTAX_RECORDTYPE='Cleartax';
    public static final String AWAITING_STATUS='Awaiting';
    
    //RecordType Name Account
    // public static final String INTERNATIONAL_RECORDTYPE='International';
    //KAM Type
    public static final String EMAIL_KAM = 'Email KAM';
       //Account status picklist values Added by Raksha
    public static final String STATUS_ACTIVE = 'Active';
    public static final String STATUS_PENDING = 'Pending';
    public static final String STATUS_CHURN = 'Churn';
    
     // Added by lokesh start
    public static final String SI_PARTNER_RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('SI Partner').getRecordTypeId();
    public static final String CHANNEL_PARTNER_RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();

    public static final String ITR_RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ITR').getRecordTypeId();
    // added by lokesh end
     
    public static final String TAX_EXPERT_RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Tax Expert').getRecordTypeId();
    public static final String SME_RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME').getRecordTypeId();
    public static final String Enterprise_RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
    //public static final String International_RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International').getRecordTypeId();
    
    //Added By Niraj
    public static boolean updateLeadFields= false; 
}