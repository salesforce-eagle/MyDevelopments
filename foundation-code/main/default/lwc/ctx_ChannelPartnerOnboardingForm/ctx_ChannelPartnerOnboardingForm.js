import { LightningElement, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import createPartnerAccount from '@salesforce/apex/CTX_PartnerOnboardingController.createPartnerAccount';
import Employee_Size_Ranges from '@salesforce/label/c.Employee_Size_Ranges';
import Channel_Partner_Types from '@salesforce/label/c.Channel_Partner_Types';
import CTX_KAM_Clause from '@salesforce/label/c.CTX_KAM_Clause';

export default class Ctx_ChannelPartnerOnboardingForm extends LightningElement {

    cpRecordTypeId;
    formSubmitted = false;
    @track filesToUpload = [];
    accountRecord = new Object();
    employeeSizeLabel = Employee_Size_Ranges;
    partnerTypeLabel = Channel_Partner_Types;
    @track partnerTypes = [];
    @track employeeSizes = [];
    @track kamClause = [];
    @track activeSections = ["Partner_Information"];

    disableShippingAddress = false;
    showSpinner = false;

    //toast
    showToast = false;
    type = 'success';
    message;
    autoCloseTime = 5000;
    icon = '';

    // @wire(getObjectInfo,  { objectApiName: ACCOUNT_OBJECT })
    // getobjectInfo({ error, data }){
    //     if(error){
    //         console.log(error);
    //     }
    //     else if(data){
    //         const recordTypes = data.recordTypeInfos;
    //         this.cpRecordTypeId = Object.keys(recordTypes).find(recordType => recordTypes[recordType].name === 'Channel Partner');
    //     }
    // }

    connectedCallback() {
        this.partnerTypes = Channel_Partner_Types.split(',').map(item => {
            return { label: item, value: item };
        });
        this.employeeSizes = Employee_Size_Ranges.split(',').map(item => {
            return { label: item, value: item };
        });
        this.kamClause = CTX_KAM_Clause.split(',').map(item => {
            return { label: item, value: item };
        });
    }

    copyAddress(event) {
        if (event.target.checked) {
            this.template.querySelector(`[data-id="ShippingStreet"]`).value = this.template.querySelector(`[data-id="BillingStreet"]`).value;
            this.template.querySelector(`[data-id="ShippingCity"]`).value = this.template.querySelector(`[data-id="BillingCity"]`).value;
            this.template.querySelector(`[data-id="ShippingState"]`).value = this.template.querySelector(`[data-id="BillingState"]`).value;
            this.template.querySelector(`[data-id="ShippingCountry"]`).value = this.template.querySelector(`[data-id="BillingCountry"]`).value;
            this.template.querySelector(`[data-id="ShippingPostalCode"]`).value = this.template.querySelector(`[data-id="BillingPostalCode"]`).value;
            Promise.resolve().then(() => {
                this.template.querySelectorAll(`[data-section="ShippingAddress"]`).forEach( inputEle => {
                    inputEle.reportValidity();
                });
            });
            this.disableShippingAddress = true;
        } else {
            this.template.querySelector(`[data-id="ShippingStreet"]`).value = '';
            this.template.querySelector(`[data-id="ShippingCity"]`).value = '';
            this.template.querySelector(`[data-id="ShippingState"]`).value = '';
            this.template.querySelector(`[data-id="ShippingCountry"]`).value = '';
            this.template.querySelector(`[data-id="ShippingPostalCode"]`).value = '';
            this.disableShippingAddress = false;
        }

    }

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
                    this.filesToUpload.push({
                        Title: file.name,
                        VersionData: fileContents
                    });
                };
                freader.readAsDataURL(file);
            }
        }
    }

    handleRemoveFile(event) {
        let fileName = event.target.dataset.id;
        this.filesToUpload = this.filesToUpload.filter(item => item.Title !== fileName);

    }

    handleToggleSection (event) {
        
    }

    /*handleFormSubmit(event){
        console.log('Submit');
        this.template.querySelector('.background').scrollTop=0;
    }

    handleFormSuccess(event){
        console.log('Success');
        if(this.filesToUpload.length > 0){
            createFiles({accountId : event.detail.id, fileDetails : this.filesToUpload})
                .then(result => {

                })
                .catch(error => {

                })
        }
        this.formSubmitted = true;
    }*/

    submitForm() {
        let accountformElement = this.template.querySelectorAll(`[data-form="onboardingForm"]`);
        let contactformElement = this.template.querySelectorAll(`[data-id="contactform"]`);

        const allAccountValid = [...accountformElement].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        const allContactValid = [...contactformElement].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allAccountValid && allContactValid) {
            this.showSpinner = true;
            let accountRecord = new Object();
            let contactRecord = new Object();
            accountformElement.forEach(element => {
                accountRecord[element.name] = element.value;
            });
            contactformElement.forEach(element => {
                contactRecord[element.dataset.contactFieldName] = element.value;
            });
            createPartnerAccount({ accountDetails: accountRecord, contactDetails: contactRecord, fileDetails: this.filesToUpload })
                .then(result => {
                    this.showSpinner = false;
                    this.formSubmitted = true;
                })
                .catch(error => {
                    this.showSpinner = false;
                    console.log(error.body.message);
                    this.showToast = true;
                    this.type = 'error';
                    this.message = error.body.message;

                    setTimeout(() => {
                        this.closeModel();
                    }, this.autoCloseTime);
                })
        }

    }

    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-m-right_small slds-no-flex slds-align-top';
    }

    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }

    get getIconName() {
        if (this.icon) {
            return this.icon;
        }
        return 'utility:' + this.type;
    }

    closeModel() {
        this.showToast = false;
        this.type = '';
        this.message = '';
    }
}