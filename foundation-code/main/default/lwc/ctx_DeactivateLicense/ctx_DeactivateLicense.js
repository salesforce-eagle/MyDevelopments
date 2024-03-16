import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import LICENSE_ID from '@salesforce/schema/Asset.License_ID__c';
import deactivateExistingLicense from "@salesforce/apex/CTX_AssetWorkspaceLinkageController.deactivateExistingLicense";

export default class Ctx_DeactivateLicense extends LightningElement {
    @api recordId;
    showSpinner = false;
    hidePopup = false;

    /*async connectedCallback() {
        console.log(this.recordId);
        if (this.recordId) {
            const confirm = await LightningConfirm.open({
                message: 'Are you sure, You want to deactivate?',
                variant: 'headerless',
                label: 'Are you sure, You want to deactivate?'
                // label value isn't visible in the headerless variant
            });

            if(confirm){
                this.showSpinner = true;
                deactivateExistingLicense({ recordId: this.recordId })
                    .then(result => {
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'License Dactivated Successfully!',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.showSpinner = false;
                        this.dispatchEvent(evt);
                        this.closeQuickAction();
                        window.setTimeout(() => window.location.reload(), 3000);
                       
                    })
                    .catch(error => {
                        let errorMessage = error.body.message.replaceAll('{', '').replaceAll('}','');
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: errorMessage,
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.showSpinner = false;
                        this.dispatchEvent(evt);
                        this.closeQuickAction();
                    })
            }
        }
    }*/

    @wire(getRecord, { recordId: '$recordId', fields: [LICENSE_ID] })
    assetRecord({ error, data }) {
        if (error) {
            /**  **/
        } else if (data) {
            /**  **/
        }
    }

    handleConfirmDeactivate(event){
        if (this.recordId) {
            this.showSpinner = true;
            this.hidePopup = true;
            deactivateExistingLicense({ recordId: this.recordId })
                .then(result => {
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'License Deactivated Successfully!',
                        variant: 'success',
                        mode: 'sticky'
                    });
                    this.showSpinner = false;
                    this.dispatchEvent(evt);
                    getRecordNotifyChange([{recordId: this.recordId}]);
                    this.closeQuickAction();
                    //window.setTimeout(() => window.location.reload(), 3000);
                
                })
                .catch(error => {
                    let errorMessage = error.body.message.replaceAll('{', '').replaceAll('}','');
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.showSpinner = false;
                    this.dispatchEvent(evt);
                    this.closeQuickAction();
                })
        }
    }

    closeQuickAction() {

        this.dispatchEvent(new CustomEvent('closeaction'));
    }



}