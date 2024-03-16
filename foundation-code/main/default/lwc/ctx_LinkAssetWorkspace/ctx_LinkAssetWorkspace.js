import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import fetchProductWorkspaces from "@salesforce/apex/CTX_AssetWorkspaceLinkageController.fetchProductWorkspaces";
import linkAssetWorkspace from "@salesforce/apex/CTX_AssetWorkspaceLinkageController.linkAssetWorkspace";
import PRODUCT_EMAIL from '@salesforce/schema/Asset.Account.Product_Email__c';
import ACCOUNT_ID from '@salesforce/schema/Asset.AccountId';
import LICENSE_ID from '@salesforce/schema/Asset.License_ID__c';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import LICENSING_ADMINS from '@salesforce/label/c.Licensing_Workspace_Allocation_Admins';
//const FIELDS = ['Asset.AccountId', 'Asset.Phone'];

export default class Ctx_LinkAssetWorkspace extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track workspaceListExactMatch = [];
    @track workspaceListSuggested = [];
    @track workspaceList = [];
    showSpinner = false;
    isDisplay = false;
    isError = false;
    errorMessage;
    fields = ['Product_Email__c'];
    accountId;
    productEmail;
    licenseId;
    userId = USER_ID;
    @api saveLabel = "Add Workspace";
    @api isCreateLicense = false; 
    @api isMigrateLicense = false;  

    renderOnce = false;

    @wire(getRecord, { recordId: '$recordId', fields: [PRODUCT_EMAIL, ACCOUNT_ID, LICENSE_ID] })
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
            this.accountId = getFieldValue(data, ACCOUNT_ID);
            this.productEmail = getFieldValue(data, PRODUCT_EMAIL);
            this.licenseId = getFieldValue(data, LICENSE_ID);
            console.log(this.productEmail);
        }
    }

    connectedCallback(){
        this.showSpinner = true;
    }
    renderedCallback() {
        if (this.recordId) {
            if (!this.renderOnce) {
                setTimeout(this.fetchWorkspaces.bind(this), 1000);
                this.renderOnce = true;
            }
        }
    }

    fetchWorkspaces(){
        if(this.productEmail){
            fetchProductWorkspaces({ recordId: this.recordId })
                .then(result => {
                    let workspaceListExactMatch = [];
                    let workspaceListSuggested = [];
                    result.forEach(item => {
                        if(this.isMigrateLicense){
                            item.isExisting = false;
                        }
                        if (item.isSuggested === false) {
                            item.isSelected = item.isExisting;
                            workspaceListExactMatch.push(item);
                        } else {
                            workspaceListSuggested.push(item);
                        }
                    })
                    this.workspaceListExactMatch = workspaceListExactMatch;
                    this.workspaceListSuggested = workspaceListSuggested;
                    this.isDisplay = true;
                    this.showSpinner = false;
                })
                .catch(error => {
                    // const evt = new ShowToastEvent({
                    //     title: 'Error',
                    //     message: error.body.message,
                    //     variant: 'error',
                    //     mode: 'dismissable'
                    // });
                    // this.dispatchEvent(evt);
                    this.isDisplay = true;
                    this.showSpinner = false
                    this.setError(true, error.body.message);
                })
        } else {
            this.isDisplay = true;
            this.showSpinner = false
        }
    }

    handleAccountSuccess(){
        getRecordNotifyChange([{recordId: this.recordId}]);

        setTimeout(this.fetchWorkspaces.bind(this), 500);
    }

    /*get productEmail() {
        return getFieldValue(this.assetRecord.data, PRODUCT_EMAIL);
    }

    get accountId() {
        return getFieldValue(this.assetRecord.data, ACCOUNT_ID);
    }*/

    get isAccountNull() {
        return this.accountId ? false : true;
    }

    get isProductEmailNull() {
        return this.productEmail ? false : true;
    }

    get isDisplayTables() {
        return this.productEmail && this.workspaceListExactMatch.length > 0 ? true : false;
    }

    markActive(event) {
        let dataId = event.target.dataset.id;
        if(LICENSING_ADMINS.split(',').includes(this.userId)){
            this.workspaceListExactMatch[parseInt(dataId)].isSelected = event.target.checked;
        } else {
            console.log('Hi');
            this.workspaceListExactMatch.forEach((item, index) => {
                if(index === parseInt(dataId)){
                    item.isSelected = event.target.checked;
                } else {
                    if(!item.isExisting){
                        item.isSelected = false;
                    }
                }
            })
        }
    }

    updateDetails() {
        this.closeError();
        let workspaceList = [];
        let workspaceIdsList = [];
        this.workspaceListExactMatch.forEach(item => {
            if (item.isSelected && !item.isExisting) {
                workspaceList.push(item);
                workspaceIdsList.push(item.workspaceId);
            }
        });

        if(workspaceList.length > 0){
            console.log(this.licenseId);
            if(this.isMigrateLicense){
                this.dispatchEvent(new CustomEvent('migratelicense', {detail : workspaceIdsList}));
            }
            else if(this.licenseId){
                this.showSpinner = true;
                linkAssetWorkspace({ assetId: this.recordId, productWorkspace: workspaceList })
                    .then(result => {
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'Details Updated Successfully !!!',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        this.closeQuickAction();
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        // const evt = new ShowToastEvent({
                        //     title: 'Error',
                        //     message: error.body.message,
                        //     variant: 'error',
                        //     mode: 'dismissable'
                        // });
                        // this.dispatchEvent(evt);
                        this.showSpinner = false;

                        this.setError(true, error.body.message);
                    })
            } else if(this.isCreateLicense) {
                console.log(this.isCreateLicense);
                this.dispatchEvent(new CustomEvent('createlicense', {detail : workspaceIdsList}));
            } else {
                this.setError(true, 'Valid license is not available.');
            }
        } else {
            if(this.isMigrateLicense){
                this.dispatchEvent(new CustomEvent('migratelicense', {detail : workspaceIdsList}));
            } else {
                this.setError(true, 'Kindly Select a Workspace to add.');
            }
        }
    }

    markDefault(event) {
        let dataId = event.target.dataset.id;
        console.log(dataId);

        this.workspaceListExactMatch.forEach((item, index) => {
            console.log(parseInt(dataId));
            if (index === parseInt(dataId)) {
                item.workspace.Is_Default__c = event.target.checked;
            } else {
                item.workspace.Is_Default__c = false;
            }

        });
    }

    closeQuickAction() {
        this.dispatchEvent(new CustomEvent('closeaction', { bubbles: true, composed: true }));
    }

    get isSuggestionsEmpty() {
        return this.workspaceListSuggested.length === 0 ? true : false;
    }

    get isExactMatchEmpty() {
        return this.workspaceListExactMatch.length === 0 ? true : false;
    }
    get isdisableButton() {
        return this.workspaceListExactMatch.filter(item => item.isExisting === true).length === this.workspaceListExactMatch.length;
    }

    closeError(){
        this.setError(false, '');
    }

    setError(isError, errorMessage){
        this.isError        = isError;
        this.errorMessage   = errorMessage;
    }
}