import { LightningElement,api,wire,track } from 'lwc';
import opportunityManualClosure from '@salesforce/apex/CTX_AdhocScriptForPostSale.closeOpportunityManually';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CTX_OpportunityManualClosure extends LightningElement {

    @api recordId;
    isRunningFirstTime = false;
    responseMessage;

    renderedCallback() {

        if( this.recordId ){
            this.isRunningFirstTime = true;
        }
        if( this.isRunningFirstTime && this.recordId ){
            console.log('Opportunity Id is: '+this.recordId);
            this.isRunningFirstTime = false;

            this.opportunityClosureCall();
        }
    }

    opportunityClosureCall(){

        this.showSpinner = true;
        opportunityManualClosure({opportunityId: this.recordId}).then(result => {
            
            console.log('show me result '+JSON.stringify(result));
            this.responseMessage = result;
            
            if( this.responseMessage.toLowerCase().includes('success') ){
            console.log('Inside Success Block');
            this.startToast('success','Success!',this.responseMessage);
        } else{
            console.log('Inside Error Block'+this.responseMessage);
            this.startToast('error','Error!',this.responseMessage);
        }

            this.showSpinner = false;            
        }).catch(error => {
            this.startToast('error','Error!',error);
        });
    }

    startToast(variant,title,msg){
        
        console.log('Message coming to display: '+msg);
        let event = new ShowToastEvent({   
            title: title,
            variant:variant,
            message:msg
        });
        this.dispatchEvent(event);
        this.dispatchEvent(new CloseActionScreenEvent());
    }



}