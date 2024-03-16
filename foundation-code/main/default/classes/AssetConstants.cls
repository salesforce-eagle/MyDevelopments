public class AssetConstants {

    public static Boolean TASK_APPROVAL 								= FALSE;
    public static Boolean isFirstTimeAdditionalGstin					= TRUE;
    public static Boolean isRun											= TRUE;
    public static final String RENEWAL_PENDING							='Renewal Pending';
    public static final String RENEWED									='Renewed';
    public static final String RECORD_TYPE_NAME_LICENCED_ASSET 			= 'License_Asset';
    public static final String RECORD_TYPE_NAME_INTEGRATION_ASSET 		= 'Integration_Asset';
    public static final String RECORD_TYPE_NAME_ONETIME_ASSET 			= 'One_Time_Asset';
    public static final String ONBOARDING_STATUS_ONBOARDING_COMPLETED 	= 'Onboarding Complete';
    public static final String INTEGRATION_STATUS_PROJECT_COMPLETED 	= 'Project complete';
    public static final String STATUS_ACTIVE 							= 'Active';
    public static final String STATUS_RENEWAL_PENDING 					= 'Renewal Pending';
    public static final String STATUS_UPCOMING_RENEWAL 					= 'Upcoming Renewal';
    public static final String STATUS_AT_RISK 							= 'At Risk';
    public static final String STATUS_INACTIVE 							= 'Inactive';
    public static final String STATUS_EXPERIED	 						= 'Expired';
    public static final String STATUS_CHURN 							= 'Churn';
    public static final String STATUS_SALES_RETURN 						= 'Sales return';
    public static final String STATUS_VALID_RENEWED 					= 'Valid & Renewed';
    public static final Id ASSET_UPDATE_RecordTypeId					= Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Asset_Update').getRecordTypeId();
    public static final Id ASSET_CREATE_RecordTypeId					= Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Asset_Create').getRecordTypeId();
    public static final Id ASSET_DELETE_RecordTypeId					= Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Asset_Delete').getRecordTypeId();
    PUBLIC STATIC FINAL ID ASSET_INTEGRATION_RECORDTYPEID 				= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Integration_Asset').getRecordTypeId();
    public static final Id ASSET_LICENSE_RECORDTYPEID					= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('License_Asset').getRecordTypeId();
    public static final Id ASSET_LICENSEID_RECORDTYPEID					= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('License_Asset_ID').getRecordTypeId();
    public static final Id ASSET_INTEGRATIONID_RECORDTYPEID				= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Integration_Asset_ID').getRecordTypeId();
    public static final Id ASSET_ONETIMEASSET_RECORDTYPEID						= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(AssetConstants.RECORD_TYPE_NAME_ONETIME_ASSET).getRecordTypeId();
    
    public static Boolean LICENSING_SYNC_FLOW_RUN 							= TRUE;
    public static Boolean SALES_SYNC_FLOW_RUN    							= TRUE;
    
    public static Map<Id, Boolean> CSMAssets (set<Id> assetIds) {
        Map<Id, Boolean> assetCSMValidationMap = new Map<Id, Boolean>();
        for(Asset asst : [SELECT Id, Name, Account.ARR_Total_Amount__c, Product2.Product_Category__c FROM Asset 
                          WHERE Id IN : assetIds AND 
                          RecordTypeId IN : new Set<Id>{ASSET_LICENSE_RECORDTYPEID, ASSET_LICENSEID_RECORDTYPEID}]
           ){
               if(asst.Account.ARR_Total_Amount__c > 50000 && asst.Product2.Product_Category__c != 'MS'){
                   assetCSMValidationMap.put(asst.Id, true);
               }else {
                   assetCSMValidationMap.put(asst.Id, false);
               }
           }
        return assetCSMValidationMap;
    }


}