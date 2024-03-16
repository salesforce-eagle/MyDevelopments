import { LightningElement, api } from 'lwc';
import syncDetails from '@salesforce/apex/CTX_SyncQLIDetailsToAsset.syncDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ctx_SyncQLIDetailsToAsset extends LightningElement {
    firstTimeRun = true;
    @api recordId;
    showSpinner = false;

    syncDetails() {
        this.showSpinner = true;
        syncDetails({recordId : this.recordId})
            .then(result => {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: "Details Synced To Asset SuccessFully",
                        variant: 'success'
                    })
                );
                this.showSpinner = false;
                this.closeQuickAction();
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
                this.closeQuickAction();
            })
    }

    closeQuickAction() {

        this.dispatchEvent(new CustomEvent('closeaction'));
    }
}