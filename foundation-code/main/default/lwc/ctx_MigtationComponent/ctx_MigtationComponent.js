import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import LICENSE_ID from '@salesforce/schema/Asset.License_ID__c';
import PRODUCT_ID from '@salesforce/schema/Asset.Product2Id';
import NAME from '@salesforce/schema/Asset.Name';
import PRODUCT_EMAIL from '@salesforce/schema/Asset.Account.Product_Email__c';
import activateNewLicense from '@salesforce/apex/CTX_AssetWorkspaceLinkageController.activateNewLicense';
import productUpdate from '@salesforce/apex/CTX_AssetWorkspaceLinkageController.productUpdate';
import getProducts from '@salesforce/apex/CTX_AssetWorkspaceLinkageController.getProducts';
import deactivateOldLicense_Migration from '@salesforce/apex/CTX_AssetWorkspaceLinkageController.deactivateOldLicense_Migration';
import getAllOldGSTLicenses from '@salesforce/apex/CTX_AssetWorkspaceLinkageController.getAllOldGSTLicenses';

export default class Ctx_MigtationComponent extends LightningElement {
    @api recordId;
    productId;
    isError = false;
    errorMessage;
    showSpinner = false;
    @track oldGSTLicenses = [];
    @track products = [];
    oldProductId;
    productEmail;
    assetName;
    isDisplayCreateLicense = false;
    

    @wire(getRecord, { recordId: '$recordId', fields: [NAME, LICENSE_ID, PRODUCT_ID, PRODUCT_EMAIL] })
    assetRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.assetName = getFieldValue(data, NAME);
            this.productEmail = getFieldValue(data, PRODUCT_EMAIL);
            if(!this.oldProductId){
                this.oldProductId = getFieldValue(data, PRODUCT_ID);
            }
        }
    }

    async connectedCallback(){
        this.showSpinner = true;

        getProducts()
            .then(result => {
                this.products = result.map(item => {
                    return { label: item.Name + ' - ' + item.Plan_Tier__c, value: item.Id };
                })
                return getAllOldGSTLicenses({recordId : this.recordId})
            })
            .then(result => {
                this.oldGSTLicenses = result.map(item => {
                    item.isSelected = false;
                    return item;
                })
                this.showSpinner = false
                console.log(this.oldGSTLicenses);
            })
            .catch(error => {
                this.showSpinner = false
                this.setError(true, error.body.message);
            })
    }

    /*getAllLicenses(){
        deactivateOldLicense_Migration({recordId : this.recordId})
            .then(result => {
                this.oldGSTLicenses = result.map(item => {
                    item.isSelected = false;
                    return item;
                })

                console.log(this.oldGSTLicenses);
            })
            .catch(error => {
                this.showSpinner = false
                this.setError(true, error.body.message);
            })
    }*/

    handleDeactivateLicense(){
        //this.isDisplayCreateLicense = true;
        this.closeError();
        let licenseIdsToDeactivate = [];
        if(this.oldGSTLicenses.length > 0){
            this.oldGSTLicenses.forEach(item => {
                if(item.isSelected === true){
                    licenseIdsToDeactivate.push(item.licenseId);
                }
            })
            if(licenseIdsToDeactivate.length > 0){
                if(this.recordId){
                    this.showSpinner = true;
                    deactivateOldLicense_Migration({recordId : this.recordId, licensesToDeactivate : licenseIdsToDeactivate})
                        .then(result => {
                            this.isDisplayCreateLicense = true;
                            this.showSpinner = false;
                        })
                        .catch(error => {
                            this.showSpinner = false
                            this.setError(true, error.body.message);
                        })
                }
            } else {
                this.setError(true, 'Kindly Select old GST Licenses to Deactivate;');
            }
        } else {
            this.isDisplayCreateLicense = true;
        }
    }

    handleProductChange(event) {
        this.productId = event.target.value;

        console.log('New Product Selected : ' + this.productId);
        console.log('Old Product : ' + this.oldProductId);
    }

    async activateSingleLicense(event) {
        this.closeError();
        let isValid = true;
        let fieldsRequired = [];
        let workspaceIds = event.detail;
        if(!this.productId){
            isValid = false;
            fieldsRequired.push('Product');
            //this.setError(true, 'Kindly Select Product');
        } 
        
        if(workspaceIds.length === 0){
            isValid = false;
            fieldsRequired.push('Workspace');
            //this.setError(true, 'Kindly Select Product');
        }

        if(!isValid){
            this.setError(true, 'Kindly Select ' + fieldsRequired.join(', ') + ' to migrate license.');
        } else {
            this.showSpinner = true;

            if (this.recordId) {
                
                productUpdate({recordId : this.recordId, productId : this.productId, oldProductId : this.oldProductId, assetName : this.assetName})
                    .then(result => {
                        return activateNewLicense({ recordId: this.recordId, workspaceIds: workspaceIds,oldProductId : this.oldProductId, assetName : this.assetName});
                    })
                    .then(result => {
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'License Migrated Successfully!',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.showSpinner = false;
                        this.dispatchEvent(evt);
                        this.closeQuickAction();
                        window.setTimeout(() => window.location.reload(), 3000);
                    })
                    .catch(error => {
                        this.showSpinner = false
                        this.setError(true, error.body.message);
                    }) 
                
            }

        }
    }

    handleError(event) {
        let errorMessage;
        if(!this.productId){
            errorMessage = '1. Kindly Select Product.\n';
        }
        errorMessage += ''
        this.setError(true, event.detail);
    }

    handleSelectLicenses(event){
        let dataId = event.target.dataset.id;

        this.oldGSTLicenses[parseInt(dataId)].isSelected = event.target.checked; 
    }

    selectAllLicenses(event){
        this.oldGSTLicenses.forEach(item => {
            item.isSelected = event.target.checked;
        })
    }

    get selectedLicense() {
        return this.oldGSTLicenses.filter(item => item.isSelected === true).length === 0 && this.oldGSTLicenses.length > 0;
    }

    get oldGSTLicensesEmpty () {
        return this.oldGSTLicenses.length > 0 ? false : true; 
    }

    closeQuickAction() {
        getRecordNotifyChange([{recordId: this.recordId}]);
        this.dispatchEvent(new CustomEvent('closeaction', { bubbles: true, composed: true }));
    }

    closeError() {
        this.setError(false, '');
    }

    setError(isError, errorMessage) {
        this.isError = isError;
        this.errorMessage = errorMessage;
    }
}