public class LeadConstants {
    
    //Queue Names
    public static final String CENTRAL_PROFILING_QUEUE='Central_Profiling';
    
     
    //RecordType names
    public static final String CENTRAL_RECORDTYPE_NAME='Central Database';
    public static final String CENTRAL_RECORDTYPE_ID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Central Database').getRecordTypeId();
	public static final String ENTERPRISE_RECORDTYPE_ID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
    public static final String CHANNEL_PARTNER_RECORDTYPE_ID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
    public static final String PARTNER_COMMUNITY_RECORDTYPE_ID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Community').getRecordTypeId();
	public static final String CA_SME_RECORDTYPE_ID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CA/SME').getRecordTypeId();
    //_RECORDTYPE_ID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('International').getRecordTypeId();
    public static final String SME_RECORDTYPE_ID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SME').getRecordTypeId();
    public static final String CIMPLYFIVE_RECORDTYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Net New Cimplyfive').getRecordTypeId(); //Added By Niraj
        public static final String CA_SME_RECORDTYPE_NAME='CA/SME';
    
    //Lead Status
    public static final String LEAD_STATUS_DUPLICATE='Duplicate';
    //Added by Raksha
    public static final String LEAD_STATUS_QUALIFIED = 'Qualified';
    public static final String LEAD_STATUS_REJECTED = 'Rejected';
    public static final String LEAD_STATUS_UNQUALIFIED = 'Unqualified';
    //End by Raksha
    
    
    public static final String TYPE_OF_LEAD_MQL='MQL';
    public static final String TYPE_OF_LEAD_PSU='PSU';
    
    public static final String Lead_Locking_Status_LOCKED='Locked';
    public static final String Lead_Locking_Status_UNLOCKED='Unlocked';
    
    
    public static final boolean LEAD_CONVERTED=true;
}