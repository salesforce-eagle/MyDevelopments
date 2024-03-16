import { LightningElement,track, api } from 'lwc';
import generatePartnerAgreement from '@salesforce/apex/CTX_PartnerAgreementController.generatePartnerAgreement';
import saveStampReferance from '@salesforce/apex/CTX_PartnerAgreementController.saveStampReferance';
import uploadOrderFormManually from '@salesforce/apex/CTX_PartnerAgreementController.uploadOrderFormManually';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class Ctx_GeneratePartnerAgreement extends  NavigationMixin(LightningElement) {
    @api recordId;
    @track fileToUpload;
    showSpinner = false;
    stampRefNumber;
    uploadOrderForm = false;
    handleFilesChange(event) {
        let files = event.target.files;
        if (files.length > 0) {
            for (let i = 0; i < files.length; i++) {
                let file = files[i];
                let freader = new FileReader();
                freader.onload = f => {
                    let base64 = 'base64,';
                    let content = freader.result.indexOf(base64) + base64.length;
                    let fileContents = freader.result.substring(content);
                    let base64Contents = freader.result;
                    this.fileToUpload = {
                        Title: file.name,
                        VersionData: fileContents,
                        base64Content: base64Contents
                    };
                };
                freader.readAsDataURL(file);
            }
        }
    }

    handleRemoveFile(event) {
        this.fileToUpload = null;

    }

    get fileSelected (){
        return this.fileToUpload ? true : false;
    }

    handleStampRefChange(event){
        this.stampRefNumber = event.target.value;
    }

    async generatePartnerAgreement(){
        let formElement = this.template.querySelectorAll(`[data-id="Form"]`);

        const allValid = [...formElement].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if(allValid){
            this.showSpinner = true;
            if(this.fileToUpload){
                this.fileToUpload.Title = this.stampRefNumber;
            }

            if(this.fileToUpload){
                await saveStampReferance({accountId : this.recordId, fileToUpload : this.fileToUpload })
                    .then(result => {

                        
                    })
                    .catch(error => {
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        this.showSpinner = false;
                    })
            }

            generatePartnerAgreement({accountId : this.recordId})
                .then(result => {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'filePreview'
                        },
                        state: {
                            selectedRecordId: result
                        }
                    });
                    this.showSpinner = false;
                    this.resetForm();
                })
                .catch(error => {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.showSpinner = false;
                })

        }
    }

    uploadOrderFormManually(){
        let formElement = this.template.querySelectorAll(`[data-id="Form"]`);

        const allValid = [...formElement].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if(allValid){
            this.showSpinner = true;
            uploadOrderFormManually({accountId : this.recordId, fileToUpload : this.fileToUpload})
                .then(result=> {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'filePreview'
                        },
                        state: {
                            selectedRecordId: result
                        }
                    });
                    this.showSpinner = false;
                    this.resetForm();
                })
                .catch(error=>{
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.showSpinner = false;
                })
        }
    }

    get cardTitle(){
        return this.uploadOrderForm ? "Upload Order Form" : "Generate Partner Agreement Form";
    }

    handleToggleChange (event) {
        this.uploadOrderForm = event.target.checked;
        this.resetForm();
    }

    resetForm(){
        this.stampRefNumber = '';
        this.fileToUpload = null;
    }
}