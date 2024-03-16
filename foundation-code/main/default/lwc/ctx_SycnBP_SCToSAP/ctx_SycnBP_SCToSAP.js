import { LightningElement,api,track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import syncDetails from '@salesforce/apex/CTX_SyncBP_SCToSAPController.syncDetails';
export default class Ctx_SycnBP_SCToSAP extends LightningElement {

    firstTimeRun = true;
    @api recordId;
    showSpinner = false;
    @track errors = [];

    renderedCallback(){
        if(this.recordId){
            if(this.firstTimeRun){
                this.syncDetails();
                this.firstTimeRun = false;
            }
        }
    }
    syncDetails() {
        this.showSpinner = true;
        syncDetails({recordId : this.recordId})
            .then(result => {
                this.showSpinner = false;
                if(result.length > 0){
                    this.errors = result;
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: "All the details are synced Successfully to SAP.",
                            variant: 'success'
                        })
                    );
                    this.closeQuickAction();
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                this.showSpinner = false;
            })
    }

    get isError() {
        return this.errors.length > 0;
    }

    closeQuickAction() {

        this.dispatchEvent(new CloseActionScreenEvent());
    }
}