import { LightningElement,api,wire,track } from 'lwc';
import createAsset from '@salesforce/apex/CTX_AdhocScriptForPostSale.createAssetPostOpportunityClosure';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CTX_CreateAssetOnOpportunity extends LightningElement {

    @api recordId;
    isRunningFirstTime = true;
    showSpinner = true;
    
    renderedCallback() {

        if( this.isRunningFirstTime && this.recordId ){
            console.log('Record Id is:  '+this.recordId);
            this.isRunningFirstTime = false;

            this.createAssetOnOpportunity();
        }
    }

createAssetOnOpportunity(){


    this.showSpinner = true;
    createAsset({opportunityId: this.recordId}).then(result => {
            
            console.log('result: result: '+JSON.stringify(result));
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
this.dispatchEvent(new CloseActionScreenEvent());
}

}