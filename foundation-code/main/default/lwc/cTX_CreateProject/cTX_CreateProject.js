import { LightningElement,api,wire,track } from 'lwc';
import createintegrationProject from '@salesforce/apex/CTX_AdhocScriptForPostSale.createIntegrationProjectOnAsset';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class cTX_CreateProject extends LightningElement {

    @api recordId;
    @api objectApiName;
    @api isRunningFirstTime;
 
   
    renderedCallback() {

        if( this.recordId ){
            this.isRunningFirstTime = true;
        }

        if( this.isRunningFirstTime && this.recordId ){
            console.log('Record Id is:  '+this.recordId);
            this.isRunningFirstTime = false;
            this.createProject();
                
        }
    }

    createProject(){

        createintegrationProject({assetId: this.recordId}).then(result => {
               
                console.log('result: result: '+JSON.stringify(result));
                this.responseMessage = result;
                
                if( this.responseMessage.toLowerCase().includes('success') ){
                console.log(' Success');
                this.startToast('success','Success!',this.responseMessage);
            } else{
                console.log('Inside Error '+this.responseMessage);
                this.startToast('error','Error!',this.responseMessage);
            }
    
                       
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