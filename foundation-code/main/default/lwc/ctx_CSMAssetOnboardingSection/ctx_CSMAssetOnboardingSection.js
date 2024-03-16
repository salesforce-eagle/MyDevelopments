import { LightningElement,api, track } from 'lwc';

export default class Ctx_CSMAssetOnboardingSection extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api fields;
    @track onbaordingFields = ['Onbaording_Stage__c','Prerequisites_Check__c','Prerequisites__c','Onboarding_process_start_date__c','Sales_CSM_Handover_Completion_Date__c','Introduction_Email_Completion_Date__c','Prerequisite_collection_Completion_Date__c','License_Account_creation_Completion_Date__c','Product_training_Completion_Date__c','Onboarding_Completed_Date__c','Support_Owner__c','Support_Emails__c', 'Is_Onboarding_Delayed__c','Onboarding_Delay_Reason__c','Onboarding_Delay_Reason_Comment__c'];

    connectedCallback() {
        this.onbaordingFields = this.fields.split(',').map(item =>{
            return item.trim();
        });
    }
}