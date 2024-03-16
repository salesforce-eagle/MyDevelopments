import { LightningElement,api,wire,track } from 'lwc';
import activateLicense from '@salesforce/apex/CTX_AutoRenewActivateLicense.autoRenewActivateLicense';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';


export default class CTX_ActivateLicense extends LightningElement {

    @api recordId;
    @track responseMessage;
		showSpinner = false;
		
		@api async invoke() {
				this.activateRenewalLicense(); 

		} 

   activateRenewalLicense(){
			  this.showSpinner = true;
			 console.log('@recordId'+this.recordId);
        activateLicense({billingId: this.recordId})
        .then(result => {
            this.responseMessage = result;
						console.log('@responseMessage'+this.responseMessage);
            
            if(this.responseMessage.toLowerCase().includes('success')){
								
                this.startToast('success','success',this.responseMessage);
            }else{
								console.log('@error'+this.responseMessage);
                this.startToast('error','error',this.responseMessage);
            }
						
						this.showSpinner = false;
						
            getRecordNotifyChange([{recordId: this.recordId}]);
            
        })
        .catch(error => {

           this.startToast('error','error',+error);
        });
			 
			  
    }
    
    startToast(variant,title,msg){
				console.log('@msg'+msg);
				//let error = JSON.parse(msg);
				//let errorMessages = error.errors;
			let error = msg.replaceAll('{','').replaceAll('}','').replaceAll('\\','');
        let event = new ShowToastEvent({
            title: title,
            variant:variant,
            message: 	error
        });
        this.dispatchEvent(event);
    }
    
}