import { LightningElement, track, api, wire} from 'lwc';
import getProductsandIssueTypes from '@salesforce/apex/CTX_HelpAndSupportController.getProductsandIssueTypes';
import createCustomerCase from '@salesforce/apex/CTX_HelpAndSupportController.createCustomerCase';

export default class Ctx_CreateCaseForm extends LightningElement {
    objectApiName = 'Case';
    firstName;
    lastName;
    @api email;
    @api contact;
    contactId;
    @track productsAvailable;
    @track issueTypes;
    product;
    issueType;
    subject;
    description;
    @track filesToUpload = [];
    @track fileNames = [];
    //toast
    showToast = false;
    type='success';
    message;
    autoCloseTime = 5000;
    icon='';
    showSpinner = false;

    fields=['ContactEmail', 'Products_Available__c', 'Issue_Type__c', 'Subject'];

    connectedCallback(){
        this.contactId = this.contact ? this.contact.Id : '';
    }
    // @track issueTypes = [
    //     { label: 'ClearSave', value: 'ClearSave' },
    //     { label: 'Free Support', value: 'Free Support' },
    //     { label: 'TDS', value: 'TDS' },
    //     { label: 'Tax Cloud', value: 'Tax Cloud' },
    //     { label: 'GST Filing Assistance', value: 'GST Filing Assistance' },
    //     { label: 'GST Product demo', value: 'GST Product demo' },
    // ];

    // @track availableProducts = [
    //     { label: 'GST	', value: 'GST	' },
    //     { label: 'MAX ITC', value: 'MAX ITC' },
    //     { label: 'Invoice Discount', value: 'Invoice Discount' },
    //     { label: 'E-Invoicing & E-Way Bill', value: 'E-Invoicing & E-Way Bill' },
    //     { label: 'TDS', value: 'TDS' },
    //     { label: 'Capture', value: 'Capture' },
    // ];

    @wire (getProductsandIssueTypes)
        getPickListValues({ error, data }) {
            if(error){
                console.log(error);
            }
            if(data){
                let products = data.productsAvailable;
                let issueTypes = data.issueTypes;

                this.productsAvailable = products.map(item => {
                    return {label : item, value : item};
                })
                this.issueTypes = issueTypes.map(item => {
                    return {label : item, value : item};
                })
            }
        }

    handleFirstNameChange(event){
        this.firstName = event.target.value;
    }

    handleLastNameChange(event){
        this.lastName = event.target.value;
    }

    handleProductChange(event){
        this.product = event.target.value;
    }

    handleIssueTypeChange(event){
        this.issueType = event.target.value;
    }

    handleSubjectChange(event){
        this.subject = event.target.value;
    }

    handleDescriptionChange(event){
        this.description = event.target.value;
    }

    handleFilesChange(event){
        let files = event.target.files;

        if (files.length > 0) {

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
    }

    handleRemoveFile(event){
        let fileName = event.target.dataset.id;
        this.filesToUpload = this.filesToUpload.filter(item => item.Title !== fileName);

    }

    handleSubmit(){
        const isValid = [...this.template.querySelectorAll(`[data-id="caseForm"]`)].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if(isValid){
            this.showSpinner = true;
            createCustomerCase({firstName : this.firstName, lastName: this.lastName, contactEmail : this.email, availableProduct : this.product, issueType : this.issueType, subject : this.subject, description : this.description, contactId : this.contactId, fileDetails : this.filesToUpload})
                .then(result => {
                    
                    this.showToast = true;
                    this.type = 'success';
                    this.message = 'You request with case number : '+result.CaseNumber+' is submitted Successfully!!'
                    this.dispatchEvent(new CustomEvent('refreshcases'));

                    setTimeout(() => {
                        this.closeModel();
                    }, this.autoCloseTime);
                    
                    this.contactId = result.ContactId;
                    this.resetForm();
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.log(error);
                    this.showSpinner = false;
                })

        }
        
    }

    get existingContact(){
        return this.contactId ? true : false;
    }

    resetForm(){
        this.firstName='';
        this.lastName='';
        this.product='';
        this.issueType='';
        this.subject='';
        this.description='';
        this.filesToUpload=[]; 
    }

    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-m-right_small slds-no-flex slds-align-top';
    }
 
    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }

    get getIconName() {
        if(this.icon)
        {
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