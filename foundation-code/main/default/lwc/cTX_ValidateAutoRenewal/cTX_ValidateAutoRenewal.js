import { LightningElement, api } from 'lwc';
import getAutorenewalValidation from '@salesforce/apex/CTX_AutoRenewalValidateClass.getAutorenewalValidation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ctx_SyncQLIDetailsToAsset extends LightningElement {
    firstTimeRun = true;
    @api recordId;
    showSpinner = false;

    autorenewalValidation() {
        this.showSpinner = true;
        getAutorenewalValidation()
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
           //
        });
			 
			  
    }
    
    startToast(variant,title,msg){

			let error = msg;
        let event = new ShowToastEvent({
            title: title,
            variant:variant,
            message: 	error
        });
        this.dispatchEvent(event);
    }
}