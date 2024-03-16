import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import { NavigationMixin } from 'lightning/navigation';
import getRecordTypeFields from '@salesforce/apex/CTX_CreateSupportCaseController.getRecordTypeFields';
import attachFilesToCase from '@salesforce/apex/CTX_CreateSupportCaseController.attachFilesToCase';
import ALLOWED_CASE_RECORDTYPES from '@salesforce/label/c.Case_Eligible_Record_Types';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ctx_CreateSupportCase extends NavigationMixin(LightningElement) {
    recordId;
    recordType;
    isPreSale = false;
    isPreSalesUser = false;
    objectApiName = 'Case';
    metadataResults;
    @track recordTypesOptions = [];
    @track recordTypeToField = [];
    @track recordTypeToField_PreSales = [];
    @track recordTypeNameToIdMap = [];
    @track fields = [];
    @track filesToUpload = [];
    @track fileNames = [];
    @track currentUserEmail;

    showSpinner = false;
    isError = false;
    errorMessage;
    renderOnce = false;

    //Toast 
    showToast = false;
    type = 'success';
    message;
    autoCloseTime = 5000;
    icon = '';

    

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    ObjectInfo({ error, data }) {
        if (data) {
            let allowedRecordTypes = ALLOWED_CASE_RECORDTYPES.split(',');
            const rtis = data.recordTypeInfos;
            let recordTypesOptions = [];
            let recordTypeNameToIdMap = [];
            Object.keys(rtis).forEach(item => {
                if (allowedRecordTypes.includes(rtis[item].name)) {
                    recordTypesOptions.push({ label: rtis[item].name, value: rtis[item].name });
                }
            });
            Object.keys(rtis).forEach(item => {
                if (allowedRecordTypes.includes(rtis[item].name)) {
                    recordTypeNameToIdMap.push({ label: rtis[item].name, value: rtis[item].recordTypeId });
                }
            });
            this.recordTypesOptions = recordTypesOptions;
            this.recordTypeNameToIdMap = recordTypeNameToIdMap;
        } else if (error) {
            // perform your logic related to error 
        }
    }


    connectedCallback() {

       
        
        getRecordTypeFields()
            .then(result => {

                console.log('Print Result:: '+JSON.stringify(result));
                console.log('Print Result metadataResults:: '+JSON.stringify(result.metadataResults));
                console.log('Print Result isPreSaleUser:: '+JSON.stringify(result.isPreSaleUser));
                
                let chckboxes = this.template.querySelector('[data-id = "checkbox"]');
                this.isPreSalesUser = result.isPreSaleUser;
                this.metadataResults = result.metadataResults;

                this.metadataResults.forEach(item => {
                    console.log('Check RecordTypeName: '+item.recordTypeName);
                    console.log('Check Pre Sales Flag: '+item.isPreSales);
                    
                    if( !item.isPreSales ){
                        this.recordTypeToField.push( { recordType: item.recordTypeName, fields: item.fields } );
                    }
                    
                })

                this.metadataResults.forEach(item => {
                    console.log('Check RecordTypeName: '+item.recordTypeName);
                    console.log('Check Pre Sales Flag: '+item.isPreSales);
                    
                    if( item.isPreSales ){
                        this.recordTypeToField_PreSales.push( { recordType: item.recordTypeName, fields: item.fields } );
                    }
                    
                })

            })
            .catch(error => {

            })
    }

    handleRecordTypeChange(event) {
        
        this.recordType = event.target.value;

        console.log( 'recordTypeToField Map Values: '+JSON.stringify(this.recordTypeToField) );
        console.log( 'recordTypeToField_PreSales Map Values: '+JSON.stringify(this.recordTypeToField_PreSales) );
        console.log( 'this.recordType: '+this.recordType );
        console.log( 'this.isPreSale: '+this.isPreSale );
        
        if(this.isPreSale == undefined)
        this.isPreSale = false;
        
        let currentFields;
        
        if(this.isPreSale){
            console.log('Presale Block ');
            currentFields = this.recordTypeToField_PreSales.filter(
            item => item.recordType === this.recordType
            )[0].fields;

            console.log('Presale Block currentFields: '+JSON.stringify(currentFields));
        } else{
            console.log('Non Presale Block ');
            currentFields = 
            this.recordTypeToField.filter(
                item => item.recordType === this.recordType
                )[0].fields;

                console.log('Non Presale Block currentFields: '+JSON.stringify(currentFields));
        }

        this.fields = currentFields;
        
        


        console.log('Final Fields to Display: '+JSON.stringify(this.fields));
        
        if (this.recordType) {
            setTimeout(() => {
                this.registedEventListeners();
            }, 1000);
        }

    }

    handleChange(event){
        this.isPreSale = event.target.checked;
    }

    handleSubmit(event) {
        console.log('Submit Event Call')
        event.preventDefault();
        event.stopPropagation();
        this.closeError();
        let inputFields = event.detail.fields;
        let emailField = inputFields.SuppliedEmail;
        if (emailField) {
            if (emailField.includes('@clear.in') || emailField.includes('@cleartax.in')) {
                this.setError(true, "Internal Emails are not allowed.");
            }
            else {
                this.showSpinner = true;
                inputFields.Origin = 'Internal Web Form';
                inputFields.Case_Sub_Origin__c = 'Other';
                inputFields.Is_Pre_Sales_Case__c = this.isPreSale;

                if(this.isPreSale){
                    inputFields.Disable_Email_Communication__c = true;
                } else{
                }

                //inputFields.Disable_Email_Communication__c = this.isPreSale ? true : false;
                this.template.querySelector('lightning-record-edit-form').submit(inputFields);
            }
        }
    }

    handleSuccess(event) {
        this.recordId = event.detail.id;
        attachFilesToCase({ recordId: this.recordId, filesToUpload: this.filesToUpload })
            .then(result => {
                this.showSpinner = false;
                let successMessage = 'Your request with case number : ' + result + ' is submitted Successfully!!';
                this.showToastMessage('success', successMessage);
                this.resetForm();
                this.navigateToNewCaseWithDefaults();
                this.closeQuickAction();
            })
            .catch(error => {
                this.showSpinner = false;
                this.navigateToNewCaseWithDefaults();
                let errorMessage = 'Failed to attach files to the case, Kindly Attach files Direct to Case in Notes and Attachments.'
                this.showToastMessage('error', errorMessage);
                this.closeQuickAction();
            })




    }

    handleError(event) {
        this.showSpinner = false;
    }

    get isRecordTypeSelected() {
        return this.recordType ? true : false;
    }
/*
    get isPreSalesUser() {
        return this.isPreSalesUser ? true : false;
    }*/

    navigateToNewCaseWithDefaults() {

        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                objectApiName: "Case",
                actionName: "view",
                recordId: this.recordId
            }
        });
    }

    /*get fields() {
        console.log(this.recordTypeToField);
        return this.recordTypeToField.filter(item => item.recordTypeName === this.recordType).fields;
    }*/

    closeQuickAction() {
        this.dispatchEvent(new CustomEvent('closeaction'));
    }

    get recordTypeId() {
        return this.recordTypeNameToIdMap.find(item => item.label === this.recordType).value;
    }

    closeError() {
        this.setError(false, '');
    }

    setError(isError, errorMessage) {
        this.isError = isError;
        this.errorMessage = errorMessage;
    }

    handleFilesChange(event) {
        let files = event.target.files;

        if (files.length > 0) {
            this.filesSelect(files);

        }
    }

    filesSelect(files) {
        for (let i = 0; i < files.length; i++) {
            let file = files[i];
            console.log(file.name);
            this.fileNames.push(file.name);

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

    handleRemoveFile(event) {
        let fileName = event.target.dataset.id;
        this.filesToUpload = this.filesToUpload.filter(item => item.Title !== fileName);

    }

    handleFileDrop(event) {
        let files = event.dataTransfer.files;
        console.log(files)
        if (files.length > 0) {
            this.filesSelect(files);
        }
        this.handleDragLeave(event);
    }

    handleDragOver(event) {
        this.template.querySelector('[data-id="fileSelector"]').classList.add('background');
        event.preventDefault();
        event.stopPropagation();
    }

    handleDragLeave(event) {
        this.template.querySelector('[data-id="fileSelector"]').classList.remove('background');
        event.preventDefault();
        event.stopPropagation();
    }

    registedEventListeners() {
        let dropArea = this.template.querySelector('[data-id="fileSelector"]');
        dropArea.addEventListener('drop', this.handleFileDrop.bind(this));
        dropArea.addEventListener('dragover', this.handleDragOver.bind(this));
        ['dragenter', 'dragleave'].forEach(eventName => {
            dropArea.addEventListener(eventName, this.handleDragLeave.bind(this));
        })
    }

    resetForm() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

    /** Custom Toast Functions **/

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

    showToastMessage(type, message) {
        this.showToast = true;
        this.type = type;
        this.message = message;

        setTimeout(() => {
            this.closeModel();
        }, this.autoCloseTime);
    }

    /** Custom Toast Functions **/

    // renderedCallback(){
    //     if(!this.renderOnce){
    //         let dropArea = this.template.querySelector('[data-id="fileSelector"]');
    //         /*['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    //             dropArea.addEventListener(eventName, )
    //         })*/
    //         dropArea.addEventListener('drop', this.handleFileDrop.bind(this));
    //         dropArea.addEventListener('dragover', this.handleDragOver.bind(this));
    //         ['dragenter', 'dragleave'].forEach(eventName => {
    //             dropArea.addEventListener(eventName, this.handleDragLeave.bind(this));
    //         })
    //         this.renderOnce = true;
    //     }       
    // }


}