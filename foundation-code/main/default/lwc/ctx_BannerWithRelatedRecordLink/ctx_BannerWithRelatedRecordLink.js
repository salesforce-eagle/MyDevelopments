import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import ACCOUNT_ID from '@salesforce/schema/Asset.AccountId';
export default class Ctx_BannerWithRelatedRecordLink extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api message;
    @api relatedFieldAPIName;
    @api relatedObject;
    fieldObject = {};
    record;

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_ID]})
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.record = data;
            this.fieldObject.fieldApiName = this.relatedFieldAPIName;
            this.fieldObject.objectApiName = this.objectApiName;
        }
    }

    navigate() {
        console.log(this.fieldObject);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: getFieldValue(this.record, this.fieldObject),
                objectApiName: this.relatedObject, // objectApiName is optional
                actionName: 'view'
            }
        });
    }
}