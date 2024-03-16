/** GSTIN Verification <> SF **/
import { LightningElement,api,wire,track } from 'lwc';
import fetchInfo from '@salesforce/apex/CTX_GSTCompanyInfo.fetchCompanyInfo';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import BILLING_GSTIN from '@salesforce/schema/Opportunity.Billing_GST__c';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class CTX_FetchCompanyInfo extends LightningElement { 
    
    @api recordId;
    @track responseMessage;
    
    @wire(getRecord, {recordId : '$recordId', fields: BILLING_GSTIN })
    opportunity;
    
    
    @api async invoke() {
        this.fetchCompanyDetails(); 

    }  


    fetchCompanyDetails(){
        fetchInfo({gstin : getFieldValue(this.opportunity.data, BILLING_GSTIN), opportunityId: this.recordId})
        .then(result => {
            this.responseMessage = result;

            if(this.responseMessage.toLowerCase().includes('success')){
                this.startToast('success',this.responseMessage);
            }else{
                this.startToast('error',this.responseMessage);
            }
            getRecordNotifyChange([{recordId: this.recordId}]);
            
        })
        .catch(error => {
            this.startToast('error','ERROR '+error);
        });
    }
    
    startToast(variant,title,msg){
        let event = new ShowToastEvent({
            title: title,
            variant:variant,
            message: msg,
        });
        this.dispatchEvent(event);
    }
    
    
    
}