public class Constants {
    
    //Recursion variables
    public static Boolean stopCaseTrigger = false;
    
    public static final String entitlementFieldSetApiName = 'AssignEntitlement';
    
    //Record Type Name Constants
    public final String RECORDTYPENAME_SAC_CASE_ENTITLEMENT = 'Case_Entitlement';
    public final String RECORDTYPENAME_SAC_SPAM = 'Spam';
    public final String RECORDTYPENAME_CASE_B2B_ENTERPRISE = 'B2B_Enterprise';
    public final String RECORDTYPENAME_CASE_B2BCASME = 'B2B_CA_SME';
    public final String RECORDTYPENAME_CASE_EINVOICING = 'E_Invoicing';
    public final String RECORDTYPENAME_CASE_B2C = 'B2C';
    public final String RECORDTYPENAME_CASE_International = 'International';
    
    //Record Type Id Constants
    public static Id sacCaseEntRTId;
    public static Id sacSpamRTId;
    public static Id b2bEnterpriseRTId;
    public static Id b2bCASMERTId;
    public static Id eInvoicingRTId;
    public static Id b2CRTId;
    public static Id interantionalRTId;
    
    static{
        Constants cons= new Constants();
        
        if(sacCaseEntRTId==null){
            sacCaseEntRTId= UtilityClass.getRecordTypeIdByDeveloperName('Service_Admin_Configuration__c',cons.RECORDTYPENAME_SAC_CASE_ENTITLEMENT);
        }
        if(sacSpamRTId==null){
            sacSpamRTId= UtilityClass.getRecordTypeIdByDeveloperName('Service_Admin_Configuration__c',cons.RECORDTYPENAME_SAC_SPAM);
        }
        if(b2bEnterpriseRTId==null){
            b2bEnterpriseRTId= UtilityClass.getRecordTypeIdByDeveloperName('Case',cons.RECORDTYPENAME_CASE_B2B_ENTERPRISE);
        }
        if(b2bCASMERTId==null){
            b2bCASMERTId= UtilityClass.getRecordTypeIdByDeveloperName('Case',cons.RECORDTYPENAME_CASE_B2BCASME);
        }
        if(eInvoicingRTId==null){
            eInvoicingRTId= UtilityClass.getRecordTypeIdByDeveloperName('Case',cons.RECORDTYPENAME_CASE_EINVOICING);
        }
        if(b2CRTId==null){
            b2CRTId= UtilityClass.getRecordTypeIdByDeveloperName('Case',cons.RECORDTYPENAME_CASE_B2C);
        }
        if(interantionalRTId==null){
            interantionalRTId= UtilityClass.getRecordTypeIdByDeveloperName('Case',cons.RECORDTYPENAME_CASE_International);
        }
    }

}