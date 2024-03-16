public class CTX_CSMJourneyOnbaordingFlow {
    
    public static void updateStage(List<Asset> assetList, Map<Id, Asset> oldAssetMap){
        for(Asset thisAsset : assetList){
            Asset oldInstance = oldAssetMap.get(thisAsset.Id);
            if(oldInstance.Onboarding_Status__c != thisAsset.Onboarding_Status__c) {
                If(thisAsset.Onboarding_Status__c == 'Onboarding Complete'){
                    thisAsset.Stage__c = 'Activation';
                }
            }
            if(oldInstance.Is_Asset_Activated__c != thisAsset.Is_Asset_Activated__c){
                if (thisAsset.Is_Asset_Activated__c == true) {
                    thisAsset.Stage__c = 'Success';
                }   
            }            
        }
    }
    
    public static void updateOnboardingSubstages(List<Asset> assetList, Map<Id, Asset> oldAssetMap){
        for(Asset thisAsset : assetList){
           	Asset oldInstance = oldAssetMap.get(thisAsset.Id);
            if(oldInstance.Onboarding_Stage__c == 'Not started' && thisAsset.Onboarding_Stage__c == 'Sales CSM Handover'){
                thisAsset.Sales_CSM_Handover_Status__c = 'Started';
                thisAsset.Onboarding_status__c = 'Onboarding Pending';
                thisAsset.Onboarding_process_start_date__c = System.today();
            } else if(thisAsset.Onboarding_Stage__c == 'Sales CSM Handover' && thisAsset.Sales_CSM_Handover_Status__c == 'Completed'){
                thisAsset.Sales_CSM_Handover_Completion_Date__c = System.today();
                thisAsset.Onboarding_Stage__c = 'Introduction Email / Kickoff Call';
                thisAsset.Introduction_Email_Kickoff_Call_Status__c = 'Started';
            } else if(thisAsset.Onboarding_Stage__c == 'Introduction Email / Kickoff Call' && thisAsset.Introduction_Email_Kickoff_Call_Status__c == 'Completed') {
                thisAsset.Introduction_Email_Completion_Date__c = System.today();
                thisAsset.Onboarding_Stage__c = 'Customer Prerequisite Collection';
                thisAsset.Customer_Prerequisite_collection_Status__c = 'Started';
            } else if(thisAsset.Onboarding_Stage__c == 'Customer Prerequisite Collection' && thisAsset.Customer_Prerequisite_collection_Status__c == 'Completed') {
                thisAsset.Prerequisite_collection_Completion_Date__c = System.today();
                thisAsset.Onboarding_Stage__c = 'Customer License Account Creation';
                thisAsset.Customer_License_Account_creation_Status__c = 'Started';
            } else if(thisAsset.Onboarding_Stage__c == 'Customer License Account Creation' && thisAsset.Customer_License_Account_creation_Status__c == 'Completed') {
                thisAsset.License_Account_creation_Completion_Date__c = System.today();
                thisAsset.Onboarding_Stage__c = 'Product Training';
                thisAsset.Product_training_Status__c = 'Started';
            } else if(thisAsset.Onboarding_Stage__c == 'Product Training' && (thisAsset.Product_training_Status__c != oldInstance.Product_training_Status__c && thisAsset.Product_training_Status__c == 'Completed')) {
                thisAsset.Onboarding_status__c = 'Onboarding Complete';
                thisAsset.Product_training_Completion_Date__c = System.today();
                thisAsset.Onboarding_Completed_Date__c = System.today();
            }
        }
        
    }
}