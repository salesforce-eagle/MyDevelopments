public class OpportunityConstants {
    
    public static String ESIGNRESEND = '';
    public static List<Opportunity>       listOfeSignRequest                                  = new List<Opportunity>(); 
    public static Map<String,String>      mapOfOppToItsESignCustomerId                        = new Map<String,String>();    
    //Opportunity Stage Picklist value
    public static final String STAGENAME_CLOSED_LOST='Closed Lost';
    public static  boolean STATCHECK=true;
    public static final String STAGENAME_CLOSED_WON='Closed Won';
    public static final String STAGENAME_SQL='SQL';
    public static final String STAGENAME_ON_HOLD='On Hold';
    public static final String STAGENAME_ONBOARDED='Onboarded';
    public static final String STAGENAME_POC='POC';
    public static final String STAGENAME_FOLLOWUP='Follow Up';
    public static final String STAGENAME_PROFILING='Profiling';
    public static final String STAGENAME_RENEWAL='Renewal Deck Shared';
    public static final String STAGENAME_CLOSURE_MEETINGS='Closure Meetings';
    public static final String STAGENAME_INPROGRESS='In Progress';
    public static final String STAGENAME_RENEWALINITIATED='Renewal Deck Shared';
    public static final String STAGENAME_ONGOING='Engagement Ongoing';
    public static final String STAGENAME_SCH_DEMO = 'Schedule Demo';
    public static final String STAGENAME_DEMO_DONE = 'Demo done';
    public static final String STAGENAME_QUALIFY = 'Qualify';
    //Added by Lokesh start 14 july 2020
    public static final String STAGENAME_Quote_MANAGEMENT='Quote management';
    public static final String STAGENAME_NEGOTIATION_MEETING='Negotiation Meetings';
    public static final String STAGENAME_QUOTING='Quoting';
    public static final String STAGENAME_ON_TRACK='On track';
    //Added by Raksha on 30th Oct 2020
    public static final String STAGENAME_IN_FINANCE_APPROVAL = 'In Finance Approval';
    public static final String STAGENAME_PRE_SQL = 'Pre SQL';
    public static final String STAGENAME_TRANING = 'Training';
    public static final String STAGENAME_AT_RISK = 'At Risk';
    //End by Raksha
    
    //Opportunity Sub_Stage Picklist value
    public static final String SUB_STAGENAME_QUOTE_PREPARATION='Quote preparation';
    public static final String SUB_STAGENAME_QUOTE_SHARED='Quote shared';
    public static final String SUB_STAGENAME_NEGOTIATION_MEETING_FIXED='Negotiation meeting fixed';
    public static final String SUB_STAGENAME_NEGOTIATION_CLOSED='Negotiation Closed';
    //Added by Lokesh End  14 july 2020
    //Added by Raksha on 30th Oct 2020
    public static final String SUB_STAGENAME_IN_APPROVAL = 'In Approval';
    public static final String SUB_STAGENAME_APPROVED = 'Approved';
    public static final String SUB_STAGENAME_REJECTED = 'Rejected';
    public static final String FINANCE_APPROVAL_STATUS_IN_PROGRESS = 'In Progress';
    //public static final String FINANCE_APPROVAL_STATUS_APPROVED = 'Approved';
    //public static final String FINANCE_APPROVAL_STATUS_REJECTED = 'Rejected';
    //End by Raksha
    
    //StageName to Renewal Initiated
    public static final String STAGENAME_RENEWAL_INITIATED='Renewal Initiated';
    
    //RecordType Label
    public static final String RECORDTYPENAME_RENEWAL='Renewal';
    public static final String RECORDTYPENAME_NET_NEW='Net New';
    public static final String RECORDTYPENAME_CROSS_SELL_UPSELL='Cross Sell/Upsell';
    public static final String RENEWAL_OPPORTUNITY='Renewal Opportunity';
    
    /*Added by Raksha*/
    //RecordType API Names
    public static final String RECORDTYPE_CHANNEL_PARTNER = 'Channel_Partner';
    public static final String RECORDTYPE_CROSS_SELL_OR_UPSELL = 'Cross_Sell_Upsell';
    public static final String RECORDTYPE_NET_NEW = 'Net_New';
    public static final String RECORDTYPE_PARTNER_SUCCESS = 'Partner_Success';
    public static final String RECORDTYPE_RENEWAL = 'Renewal';
    public static final String RECORDTYPE_ITR = 'ITR';
    public static final String RECORDTYPE_INTERNATIONAL = 'International';
    public static final String RECORDTYPE_NET_NEW_ID = 'Net_New_ID';
    public static final String RECORDTYPE_NET_NEW_CIMPLIFIVE = 'Net_New_Cimplyfive';
    /*End by Raksha*/
    /*Added by Lokesh start*/
    public static final String EXTENSION_APPROVAL_STATUS_IN_PROGRESS = 'In Progress';
    public static final String EXTENSION_APPROVAL_STATUS_APPROVED = 'Approved';
    public static final String EXTENSION_APPROVAL_STATUS_REJECTED = 'Rejected';
    
    public static final String LEAD_LOCKED_STATU_LOCKED = 'Locked';
    public static final String LEAD_LOCKED_STATU_UNLOCKED = 'Unlocked';
    
    /*Added by Lokesh end */
    /*Added by Raksha*/
    public static final String MQL_OR_NOT_MQL= 'MQL';
    public static final String MQL_OR_NOT_NEED_MORE_NURTURING = 'Need More Nurturing';
    public static final String TYPE_OF_LEAD_MQL = 'MQL';
    /*End by Raksha*/
    /*Added by Renu*/
    public static final String RECORDTYPEID_RENEWAL = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
    public static final String RECORDTYPEID_CHANNEL_PARTNER = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Channel_Partner').getRecordTypeId();
    public static final String RECORDTYPEID_CROSS_SELL_OR_UPSELL = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Cross_Sell_Upsell').getRecordTypeId();
    public static final String RECORDTYPEID_NET_NEW = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Net_New').getRecordTypeId();
    public static final String RECORDTYPEID_PARTNER_SUCCESS = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Success').getRecordTypeId();
    public static final String RECORDTYPEID_NET_NEW_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Net_New_ID').getRecordTypeId();
        public static final String RECORDTYPEID_NET_NEW_CIMPLYFIVE  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Net_New_Cimplyfive').getRecordTypeId();
    public static final String RECORDTYPEID_TOPUP = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Upsell_Topup').getRecordTypeId();
    public static final String RECORDTYPEID_UPSELL = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Upsell').getRecordTypeId();
    public static final String RECORDTYPEID_WINBACK = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Winback').getRecordTypeId(); 
    /*End By Renu*/
    /*Added by Raksha */
    public static final String ESIGN_STATUS_REQUEST_SENT = 'E-Sign Request Sent';
    public static final String APPROVAL_STATUS_FINANCE_APPROVAL_APPROVED = 'Finance Approval Approved';
    public static final String APPROVAL_STATUS_FINANCE_APPROVAL_REJECTED = 'Finance Approval Rejected';
    public static final String APPROVAL_STATUS_LEGAL_APPROVAL_APPROVED = 'Legal Approval Approved';
    public static final String APPROVAL_STATUS_LEGAL_APPROVAL_REJECTED = 'Legal Approval Rejected';
    public static final String RECORDTYPEID_ITR = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_ITR).getRecordTypeId();
    public static final String RECORDTYPEID_RENEWAL_MULTI_YEAR = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Multi_year').getRecordTypeId();    
    
    public static  boolean RECORDTYPE_CHANGE_VALIDATION_ENABLE = TRUE; //Added By Niraj
    public static  boolean ENABLE_GSTIN_VERIFICATION_RULE = TRUE;
    public static  boolean AUTO_RENEW_RULE = TRUE;
    /*End by Raksha*/
    PUBLIC STATIC FINAL LIST<String> LIST_STAGE_VALIDATION = new LIST<String>{
        STAGENAME_CLOSED_WON, STAGENAME_ONBOARDED, STAGENAME_POC, STAGENAME_FOLLOWUP, 
            STAGENAME_PROFILING, STAGENAME_RENEWAL, STAGENAME_INPROGRESS, STAGENAME_RENEWALINITIATED, 
            STAGENAME_ONGOING, STAGENAME_Quote_MANAGEMENT, STAGENAME_NEGOTIATION_MEETING, STAGENAME_QUOTING, 
            STAGENAME_ON_TRACK, STAGENAME_CLOSED_LOST, STAGENAME_SQL
            };
    Public static list<string> acquisitionOppRTList=new list<String>{'Net_New','Cross_Sell_Upsell','Upsell','Winback','Partner_Success','Channel_Partner','Net_New_ID','Net_New_Cimplyfive'};
        Public static list<string> RetentionOppRTList=new list<String>{'Renewal','Renewal_Multi_year'};
            
            }