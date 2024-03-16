public class CTX_FetchCompanyDetailsQueable implements Queueable, Database.AllowsCallouts{
    
    Map<Id, Additional_GSTIN__c> billingMap =  new Map<Id, Additional_GSTIN__c>();
    public static final String RECORDTYPEID_BILLING_GSTIN = Schema.SObjectType.Additional_GSTIN__c.getRecordTypeInfosByDeveloperName().get('Billing_GSTIN').getRecordTypeId();
    
    Public CTX_FetchCompanyDetailsQueable(Map<Id, Additional_GSTIN__c> mapOfgstins){
        
        billingMap = mapOfgstins;
    }
    
    public void execute(QueueableContext context) {
        
        List<Additional_GSTIN__c> 		updateCompanyInfo 			= new List<Additional_GSTIN__c>();
        List<Logger__c>   		  		logFaliures      			= new List<Logger__c>();
        set<Id>					  		gstinsToGoForBPCreation 	= new set<Id>();
        Map<Id, Additional_GSTIN__c> 	gstinMap 	 				= new Map<Id, Additional_GSTIN__c>([SELECT Id, Name, Asset__c, Opportunity__c, Asset__r.Account.RecordTypeId, Opportunity__r.ClearTax_Billing_Entity__c FROM Additional_GSTIN__c WHERE Id IN : billingMap.keyset()]);
        for(Additional_GSTIN__c thisRec : billingMap.values()){
            if(thisRec.Asset__c != NULL){
                if(gstinMap.get(thisRec.Id)?.Asset__r?.Account.RecordTypeId == AccountConstants.Enterprise_RecordTypeId && gstinMap.get(thisRec.Id)?.Opportunity__r?.ClearTax_Billing_Entity__c == 'Defmacro'){
                	gstinsToGoForBPCreation.add(thisRec.Id);    
                }
            }            
            if(thisRec.Name   != NULL && thisRec.RecordTypeId == RECORDTYPEID_BILLING_GSTIN){
                CTX_FetchCompanyDetails.CompanyInfoWrapper thisResponse = CTX_FetchCompanyDetails.fetchCompanyInfo(thisRec.Name , thisRec.Id);
                if(thisResponse.isSuccess){
                    updateCompanyInfo.add(thisResponse.billingInfo);
                }else{
                    logFaliures.add(thisResponse.logFailure);
                }
            }
        }
        
        try{
            
            if(!updateCompanyInfo.isEmpty()){
                RecursiveTriggerHandler.isFirstTimeGSTIN = FALSE;
                Update updateCompanyInfo;
                RecursiveTriggerHandler.isFirstTimeGSTIN = TRUE;
            }
            
            /** SAP Business Partner Upsert Flow Start - Niraj **/
            if(SAP_Integration_Settings__c.getInstance().Enable_SAP_Integration__c && RecursiveTriggerHandler.isAllowSAPBPCreation){
                CTX_UpsertBusinessPartner_SAP.processAdditionalGSTINsFuture(gstinsToGoForBPCreation, NULL);   
            }
            /** SAP Business Partner Upsert Flow Start - Niraj **/
            
            if(!logFaliures.isEmpty()){
                Insert logFaliures;
            }
            
        }Catch(Exception ex){
            
            System.debug(' ERROR @CTX_FetchCompanyDetailsQueable - updateCompanyInfo \n'+ex.getMessage()+'\n'+ex.getLineNumber());
            
        }
    }
}