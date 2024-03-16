import { LightningElement, api, wire, track } from 'lwc';
// import getPicklistValues method from lightning/uiObjectInfoApi
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// import getObjectInfo method from lightning/uiObjectInfoApi
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
// Import lead object APi from schema
import ASSET_OBJECT from '@salesforce/schema/Asset';
// import Lead status field from schema
import PICKLIST_FIELD from '@salesforce/schema/Asset.Onboarding_Stage__c';
// import record ui service to use crud services
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
// import show toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import update record api
import { updateRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Asset.Id',
    'Asset.RecordTypeId',
    'Asset.Onboarding_Stage__c',
    'Asset.Onboarding_status__c'
];

export default class Ctx_CustomPath extends LightningElement {
    isOboardingCompleted = true;
    @track selectedValue;
    @api recordId;
    @track showSpinner = false;
    @track picklistValues2;
 
    stageNameToStatusFieldMap = [
        {stage: 'Sales CSM Handover', stage_status : 'Sales_CSM_Handover_Status__c'},
        {stage: 'Introduction Email / Kickoff Call', stage_status : 'Introduction_Email_Kickoff_Call_Status__c'},
        {stage: 'Customer Prerequisite Collection', stage_status : 'Customer_Prerequisite_collection_Status__c'},
        {stage: 'Customer License Account Creation', stage_status : 'Customer_License_Account_creation_Status__c'},
        {stage: 'Product Training', stage_status : 'Product_training_Status__c'}

    ]

    @track pickListvalues = [
        {value : 'Sales CSM handover'},
        {value : 'Introduction email/Kickoff call'},
        {value : 'Customer Prerequisite collection'},
        {value : 'Customer License Account creation'},
        {value : 'Product  training'}
    ]

    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    objectInfo;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    record;

    @wire(getPicklistValues, { recordTypeId: '$record.data.fields.RecordTypeId.value', fieldApiName: PICKLIST_FIELD })
    picklistFieldValues;

    get picklistValues() {
        let itemsList = [];
        if (this.record.data) {
            this.isOboardingCompleted = this.record.data.fields.Onboarding_status__c.value === 'Onboarding Complete' ? true : false;
            if (this.selectedValue !== this.record.data.fields.Onboarding_Stage__c.value) {
                this.selectedValue = this.record.data.fields.Onboarding_Stage__c.value + '';
            }
            if (this.picklistFieldValues && this.picklistFieldValues.data && this.picklistFieldValues.data.values) {
                let selectedUpTo = 0;
                for (let item in this.picklistFieldValues.data.values) {
                    if(this.isOboardingCompleted){
                        const classList = 'slds-path__item slds-is-complete';
                        itemsList.push({
                            pItem: this.picklistFieldValues.data.values[item],
                            classList: classList
                        })
                    } else {
                        if (Object.prototype.hasOwnProperty.call(this.picklistFieldValues.data.values, item)) {
                            let classList;
                            if (this.picklistFieldValues.data.values[item].value === this.selectedValue) {
                                classList = 'slds-path__item slds-is-current slds-is-active';
                                selectedUpTo = item;
                            } else {
                                classList = 'slds-path__item slds-is-incomplete';
                            }

                            itemsList.push({
                                pItem: this.picklistFieldValues.data.values[item],
                                classList: classList
                            })
                        }
                    }
                }

                if (selectedUpTo > 0) {
                    for (let item = 0; item < selectedUpTo; item++) {
                        itemsList[item].classList = 'slds-path__item slds-is-complete';
                    }
                }
                this.picklistValues2 = itemsList;
                return this.picklistValues2;
            }
        }
        this.picklistValues2 = null;
        return this.picklistValues2;
    }

    handleSelect(event) {
        this.selectedValue = event.currentTarget.dataset.value;
    }

    handleMarkAsSelected() {
        this.showSpinner = true;
        const fields = {};
        // let nextValue;
        // let onboardingStatus;
        // if(this.picklistValues2[this.picklistValues2.length-1].pItem.value === this.selectedValue){
        //     nextValue = this.selectedValue;
        //     onboardingStatus = 'Onboarding Complete'; 
        // } else{
        //     onboardingStatus = 'Onboarding pending';
        //     for(let i = 0; i< this.picklistValues2.length; i++){
        //         if(this.picklistValues2[i].pItem.value === this.selectedValue){
        //             nextValue = this.picklistValues2[i+1].pItem.value;
        //         }
        //     }
        // }

        fields.Id = this.recordId;
        // fields.Onboarding_Stage__c = nextValue;
        // fields.Onboarding_status__c	= onboardingStatus;
        if(this.selectedValue === 'Not started'){
            fields.Onboarding_Stage__c = 'Sales CSM Handover';
        } else {
            let stageToStatusFieldMap = this.stageNameToStatusFieldMap.filter(item => item.stage === this.selectedValue)[0];

            if(stageToStatusFieldMap){
                fields[stageToStatusFieldMap.stage_status]= 'Completed';
            }
        }

        const recordInput = { fields };
        

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Status Updated!',
                        variant: 'success'
                    })
                );
                eval("$A.get('e.force:refreshView').fire();");
                getRecordNotifyChange([{recordId: this.recordId}]);
                console.log('success!');
            })
            .catch(
                error => {
                    console.log(error);
                    let errorMessage;
                    error.body.output.errors.forEach((item, index) => {
                        errorMessage = index + 1 + ') ' + item.message + '\n';
                    })
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating status!',
                            message: errorMessage,
                            variant: 'error'
                        })
                    );
                    console.log('failure => ' + error.body.message);
                }
            );
        this.showSpinner = false;
    }
}