import { LightningElement, api, wire, track } from 'lwc';
import validateLicense from '@salesforce/apex/CTX_AutorenewalValidation.fetchUsageDetails';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class CTX_ValidateAutoRenewalLicense extends LightningElement {

    @api recordId;
    @track responseMessage;

    licenseId = '';

    handleChange(event) {
        this.licenseId = event.target.value;
    }

    handleSave(){
        console.log('@recordId'+this.recordId);
        validateLicense({  licenseId : this.licenseId, accountId: this.recordId })
        
        .then(result => {

            this.responseMessage = result;
			console.log('@responseMessage'+this.responseMessage);
            
            if(this.responseMessage.toLowerCase().includes('success')){		
                this.startToast('success','success',this.responseMessage);
            }else{
				console.log('@error'+this.responseMessage);
                this.startToast('error','error',this.responseMessage);
            }
				
            this.dispatchEvent(new CloseActionScreenEvent());
						
						getRecordNotifyChange([{recordId: this.recordId}]);

        })
        .catch(error => {
            this.startToast('error','error',+error);
        })
        
    }

    startToast(variant,title,msg){
        let error = msg.replaceAll('{','').replaceAll('}','').replaceAll('\\','');
        let event = new ShowToastEvent({
        title: title,
        variant:variant,
        message: 	error
    });
        this.dispatchEvent(event);
    }

}