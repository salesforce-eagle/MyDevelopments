/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-06-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class CaseConstants {
    public static Boolean isFirstTimeCase = true;
    public static List<Email_To_Case_Address__mdt> listOfEmailToCaseAddress = new List<Email_To_Case_Address__mdt>();
    
    static{
        listOfEmailToCaseAddress = DataBase.query(UtilityClass.getQueryString('Email_To_Case_Address__mdt')+' FROM Email_To_Case_Address__mdt');
    }
    
    
    public static final String GST_ENGINEERING_SLA_ON_P0='GST Engineering SLA On P0';
    public static final String GST_ENGINEERING_SLA_ON_P1='GST Engineering SLA On P1';
    public static final String GST_ENGINEERING_SLA_ON_P2='GST Engineering SLA On P2';
    
    public static final String GST_NON_ENGINEERING_SLA_ON_P0='GST Non-Engineering SLA On P0';
    public static final String GST_NON_ENGINEERING_SLA_ON_P1='GST Non-Engineering SLA On P1';
    public static final String GST_NON_ENGINEERING_SLA_ON_P2='GST Non-Engineering SLA On P2';
    
    public static final String B2C_ENTITLEMENT_SLA_ON_P0='B2C Entitlement SLA On P0';
    public static final String B2C_ENTITLEMENT_SLA_ON_P1='B2C Entitlement SLA On P1';
    public static final String B2C_ENTITLEMENT_SLA_ON_P2='B2C Entitlement SLA On P2';
    
    public static final String EINV_ENTITLEMENT_SLA_ON_P0_L1='E invoicing Support P0 L1';
    public static final String EINV_ENTITLEMENT_SLA_ON_P1_L1='E invoicing Support P1 L1';
    public static final String EINV_ENTITLEMENT_SLA_ON_P2_L1='E invoicing Support P2 L1';
    
    public static final String EINV_ENTITLEMENT_SLA_ON_P0_L2='E invoicing Support P0 L2';
    public static final String EINV_ENTITLEMENT_SLA_ON_P1_L2='E invoicing Support P1 L2';
    public static final String EINV_ENTITLEMENT_SLA_ON_P2_L2='E invoicing Support P2 L2';
    
    public static final String EINV_ENTITLEMENT_SLA_ON_P0_L3='E invoicing Support P0 L3';
    public static final String EINV_ENTITLEMENT_SLA_ON_P1_L3='E invoicing Support P1 L3';
    public static final String EINV_ENTITLEMENT_SLA_ON_P2_L3='E invoicing Support P2 L3';
    
    //recordType Names
    public static final String B2B_ENTERPRISE='B2B Enterprise';
    public static final String B2B_CA_SME='B2B CA/SME';
    public static final String B2C='B2C';
    public static final String CA_SME_TAX_CLOUD ='CA/SME - Tax Cloud';
    
   
    
    //CaseTeamRole Name
    public static final String CASETEAMROLE_ENTERPRISE_SUPPORT='Enterprise Support';
    public static final String CASETEAMROLE_CONSUMER_SUPPORT='Consumer Support';
    public static final String CASETEAMROLE_E_INVOICING_SUPPORT='E invoicing Support';

    //Case Priority Picklist
    public static final String P0='P0';
    public static final String P1='P1';
    public static final String P2='P2';
    Public Static String team1;
    
    
    
    //This Email Address need from warpdrivetech1@gmail.com to gstsupport@cleartax.in 
    public static final String ENTERPRISE_GSTSUPPORTEMAIL=  listOfEmailToCaseAddress[0].Gst_Support_Email_Address__c;
    public static final String B2C_Support_EMAil=  listOfEmailToCaseAddress[0].B2C_Support_Email__c;
    public static final String B2C_Invest_EMAIL=  listOfEmailToCaseAddress[0].B2C_invest_Email__c;
    public static final String B2C_taxcloud_Email=  listOfEmailToCaseAddress[0].B2C_taxcloud_Email__c;
    public static final String B2C_tds_Email=  listOfEmailToCaseAddress[0].B2C_tds_Email__c;
    public static final String B2C_MarketPlace_Email=  listOfEmailToCaseAddress[0].B2C_MarketPlace_Email__c;

    
    
    //Account Names
    public static final String GLOBAL_B2B_CA_SME ='global B2B CA/SME';
    public static final String GLOBAL_B2C='Global B2C';
    public static final String Global_Cleartax='cleartax';
    
    //Custom Labels
    public static final Integer THRESHOLD_AUTO_CLOSE_15DAYS = label.THRESHOLD_AUTO_CLOSE_DAYS_B2B_ENTERPRISE!=null?Integer.valueOf(label.THRESHOLD_AUTO_CLOSE_DAYS_B2B_ENTERPRISE):0;
    public static final Integer THRESHOLD_AUTO_CLOSE_3DAYS =label.THRESHOLD_AUTO_CLOSE_DAYS_B2C_B2B_CA_SME!=null?Integer.valueOf(label.THRESHOLD_AUTO_CLOSE_DAYS_B2C_B2B_CA_SME):0;
    public static final String Field_API_Names_to_Sync_Child_Case=Label.Field_API_Names_to_Sync_Child_Case;
    public static final String Tag_Values=Label.Tag_Values;
    public static final Integer Case_Solved_to_Reopen_Threshold=Label.Case_Solved_to_Reopen_Threshold!=null?Integer.valueOf(Label.Case_Solved_to_Reopen_Threshold):0;
    public static final String  POSSIBLE_FTR_HIT=Label.POSSIBLE_FTR_HIT;
    
    
    //Case Classification 
    public static final String CASE_CLASSIFICATION_PROBLEM='Problem';
    public static final String CASE_CLASSIFICATION_INCIDENT='Incident';
    public static final String INTERNATIONAL_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('International').getRecordTypeId();
    public static final String CLEAR_IDENTITY_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clear Identity').getRecordTypeId();
    public static final String MAX_ITC_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Max ITC').getRecordTypeId();
    public static final String CLEAR_CAPTURE_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clear Capture').getRecordTypeId();
    public static final String CLEAR_INVOICE_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clear Invoice').getRecordTypeId();
    public static final String B2B_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B Enterprise').getRecordTypeId(); 
    public static final String B2B_CASME_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B CA/SME').getRecordTypeId();
    public static final String INT_SUPPORT_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Integrations Support').getRecordTypeId();
    public static final String TDS_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('TDS').getRecordTypeId();	
    public static final String IRP_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('IRP').getRecordTypeId();
    public static final String E_INVOICING_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('E Invoicing').getRecordTypeId();
    public static final String ID_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clear ID').getRecordTypeId();
    public static final String GCC_RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('International').getRecordTypeId();
        
        //Case Status Picklist
    public static final String STATUS_SOLVED='Solved';
    public static final String STATUS_PENDING='Pending';
    public static final String STATUS_ON_HOLD='On hold';
    public static final String STATUS_CLOSED='Closed';
    public static final String Status_REOPEN='Reopen';
    public static final String Status_TRANSFER='Transfer';//Status_ASSIGNED='Assigned'; //Changed To Transfer.
    public static final String Status_UNRESOLVED='Unresolved';
    public static final String Status_DUPLICATE='Duplicate';
    public static final String Status_OPEN='Open';
    public static final String Status_NEW='New';
    
    //Case Sub Status Picklist
    public static final String SUB_STATUS_WITH_CUSTOMER_FOR_SOL_VER='With customer for solution verification';
    public static final String SUB_STATUS_WITH_CUSTOMER_FOR_PRO_CLAR='With customer for problem clarification';
        public static final String SUB_STATUS_WITH_KAM_FOR_PRO_CLAR='With customer for problem clarification';
    public static final String SUB_STATUS_INVOICE_COPY_REQUESTS='Invoice Copy Requests';
    public static final String SUB_STATUS_REFUND_REQUESTS='Refund Requests';

    public static final String SUB_STATUS_AUTO_CLOSED='Auto Closed';// added on 24/11
    //Case Type picklist 
    public static final String Type_INCIDENT_OF_PROBLEM='Incident of problem';
    public static final String Type_PROBLEM='Problem';
    
    //Case Origin picklist
    public static final String ORIGIN_EMAIL='Email';
    public static final String ORIGIN_WEB='Web';
    public static final String ORIGIN_INTERNAL_WEB_FORM='Internal Web Form';
    
    //Customer Segment Picklist Values
    public static final String CUSTOMER_SEGMENT_B2B_CA_SME='B2B - CA/SME';
    public static final String  CUSTOMER_SEGMENT_B2B_ENTERPRISE='B2B - Enterprise';
    
    
     //Case Sub Origin picklist
    public static final String SUB_ORIGIN_GST_PRODUCT_FORM='GST Product Form';
    public static final String SUB_ORIGIN_GST_WEB_FORM='GST Web Form';
    
    
    public static final String Case_RECORDTYPENAME_E_INVOICING='E Invoicing';
    public static final String Case_RECORDTYPENAME_International='International';
    
     /**	L3 Team Constants	**/
    PUBLIC STATIC FINAL LIST<STRING> CASE_TEAM_RESPONSIABLE_DEV_ON_CALL = 
        NEW LIST<STRING>{
            'Capture-On Call-Jira','Cimplyfive-On Call-Jira','Clear Identity-On Call-Jira','E-Inv/EWB-On Call-Jira',
                'GCC-On Call-Jira','GST-On Call-Jira','Invoice Discounting-On Call-Jira', 
                'Invoicing-On Call-Jira','IRP-On Call-Jira','MITC-On Call-Jira','Notice Management-On Call-Jira',
                'TDS-On Call-Jira', 
                
                
            'GST Dev On Call Team',
                'Consumer - Dev on Call',
                'E invoice Dev on call',
                'Priority ENT GST Dev On Call Team',
                'ENT GST Dev On Call Team',
                
                'Priority ENT E Invoice Dev On Call Team',
                'ENT E Invoice Dev On Call Team'
        };
     public Static  Boolean constantEmailPending = FALSE;
     public Static   String emailStatus    = '';
     public Static   String emailSubStatus = '';
    public Static Boolean completionCheck  = False;
    public Static Boolean closedCheck      = False;
    public Static Boolean taskTrigger      = True;

    PUBLIC STATIC FINAL LIST<Integer> FILLINGDAYSMAP_GST_MAXITC = new List<Integer>{10, 11, 19, 20, 21};
                //PUBLIC STATIC FINAL LIST<Integer> FILLINGDAYSMAP_CA_SME = new List<Integer>{30, 31};
    
}