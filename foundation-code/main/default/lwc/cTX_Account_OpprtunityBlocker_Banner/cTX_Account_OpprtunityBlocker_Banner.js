import { LightningElement, track, wire, api } from 'lwc';

import getAccountDetailsForError from '@salesforce/apex/OpportunityBlocker_LwcController.getAccountDetailsForError';
export default class CTX_Account_OpprtunityBlocker_Banner extends LightningElement {
    @api recordId;
    @track showError = false;

    @wire(getAccountDetailsForError, {accId: '$recordId'})
    WireAccountDetailsForError({error,data}){
        if(data){
            this.showError = data;
            this.error = undefined;
        }else{
            this.error = error;
            this.showError = undefined;
        }
    }
}