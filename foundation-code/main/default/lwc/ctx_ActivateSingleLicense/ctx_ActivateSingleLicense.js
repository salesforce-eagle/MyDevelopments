import { LightningElement, api } from 'lwc';
import activateSingleLicense from '@salesforce/apex/CTX_UpsertAssetLicense.activateSingleLicense';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ctx_ActivateSingleLicense extends LightningElement {
    @api recordId;
    showSpinner = false;

    connectedCallback(){
        // this.showSpinner = true;

        // if(this.recordId){
        //     activateSingleLicense({recordId : this.recordId})
        //         .then(result => {
        //             const evt = new ShowToastEvent({
        //                 title: 'Success',
        //                 message: 'License Activated Successfully!',
        //                 variant: 'success',
        //                 mode: 'dismissable'
        //             });
        //             this.showSpinner = false;
        //             this.dispatchEvent(evt);
        //             this.closeQuickAction();
        //         })
        //         .catch( error=> {
        //             let errorMessage = error.body.message.replace('{', '').replace('}','');
        //             const evt = new ShowToastEvent({
        //                 title: 'Error',
        //                 message: errorMessage,
        //                 variant: 'error',
        //                 mode: 'dismissable'
        //             });
        //             console.log(error.body.message);
        //             this.showSpinner = false;
        //             this.dispatchEvent(evt);
        //             this.closeQuickAction();
        //         })
        // }
    }

    createLicense(event){
        console.log('Hi');
        this.showSpinner = true;

        if(this.recordId){
            activateSingleLicense({recordId : this.recordId, workspaceIds : event.detail})
                .then(result => {
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'License Activated Successfully!',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.showSpinner = false;
                    this.dispatchEvent(evt);
                    this.closeQuickAction();
                    window.location.reload();
                })
                .catch( error=> {
                    let errorMessage = error.body.message.replaceAll('{', '').replaceAll('}','');
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    console.log(error.body.message);
                    this.showSpinner = false;
                    this.dispatchEvent(evt);
                    //this.closeQuickAction();
                })
        }
    }

    closeQuickAction() {
        this.dispatchEvent(new CustomEvent('closeaction'));
    }
}