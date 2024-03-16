import { LightningElement ,api, wire, track} from 'lwc';
//import getVFOrigin from '@Salesforce/apex/generateOrderFormPDF.getVFOrigin';
import saveOrderFormToOpportunity from '@salesforce/apex/generateOrderFormPDF.saveOrderFormToOpportunity';
import getOpportunityDetalsOnLoad from '@salesforce/apex/generateOrderFormPDF.getOpportunityDetalsOnLoad';
//import { saveOrderFormToOpportunity } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class lwcPDFAndESignGenerator extends  NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track renderPDF;
    @api vfOrigin;
    @track vfURL;
    msg = '';
    receivedMessage = '';
    error;
    objectApiName = 'Opportunity';
    @api methodValue = '';
    @api recordType;
    @api countryOfOrigin;
    @api isBillingGSTINNotAvailable;
    @api gstAdvantage;
    @api totalCount;
    @api showNext = false;
    @api btnPressed;
    @api errorTitle;
    @api errorVariant;
    @api errorMessage;
    @api opportunityDetails;
    @track errorMsg;
    @api numberOfContacts;
    @api orderFormFileId;
    @api showSpinner = false;
    @api updateCompanyInfo;

    /*@wire(getOpportunityDetalsOnLoad)
    wiredContacts({error,data}){
        if (data) {
            this.opportunityDetails = data;
        } else if (error) {
            console.log(error);
            this.errorMsg = error;
        }
    }*/
   
    connectedCallback(event) {
        console.log('OnLoad');
        getOpportunityDetalsOnLoad({oppId : this.recordId})
        .then(result =>{
            console.log('On Load Success');
            console.log('** Results Stringified '+JSON.stringify(result));
            console.log('** result.errorMsg '+result.errorMsg);
            this.opportunityDetails = result.opptyDetails;
            console.log('** OpportunityDetails Stringified '+JSON.stringify(this.opportunityDetails));
            console.log('** Opportunity Name on Load '+this.opportunityDetails.Name);
            this.methodValue = this.opportunityDetails.ESign_Category__c;
            this.recordType = this.opportunityDetails.RecordType.DeveloperName;
            this.countryOfOrigin = this.opportunityDetails.Country_of_Origin__c;
            this.isBillingGSTINNotAvailable = this.opportunityDetails.Is_Billing_GSTIN_Not_Available__c;
            this.gstAdvantage = this.opportunityDetails.GST_Advantage_Count__c;
            this.totalCount = this.opportunityDetails.Total_Count_OP_Count__c;
            this.updateCompanyInfo = this.opportunityDetails.Update_Company_Information__c
        })
        .catch(error =>{
            this.errorMsg = error;
        })        
        //this.methodValue = 'E-Sign';
        console.log('on Load');
        console.log('record id '+this.recordId);
    }
    get condition() {
        console.log('on LoadRecordType'+ this.methodValue);
        return this.methodValue == 'E-Sign' ? false : true;
    }
    get gstAdvantageCheck() {
        return this.gstAdvantage != 0 && this.totalCount == this.gstAdvantage ? false : true;
    }
    get recordTypeMethod() {
        return this.countryOfOrigin != '' && this.countryOfOrigin != 'India' ? false : true;
        //return this.recordType == 'International' ? false : true;
    }

    get gstinVerificationBypassed() {
        return this.countryOfOrigin != 'India' ? false : 
                this.updateCompanyInfo == true ? false : true;
    }
    get recordTypeInternational() {
        return this.countryOfOrigin != '' && this.countryOfOrigin != 'India' ? true : false;
        //return this.recordType == 'International' ? true : false;
    }
    //Recordtype removal - C5
    get recordTypeMethodCimply() {
        return this.ClearTax_Billing_Entity__c == 'CimplyFive' ? false : true;
    }
    handleChange(event) {
        this.methodValue = event.detail.value;
    }
    get beforeNextStyle(){
        return this.showNext?'display:none;':'display:block;';
    }
    get afterNextStyle(){
        return this.showNext?'display:block;':'display:none;';
    }
    onclickOfNext(event){
        const fields = event.detail.fields;
        if(fields.Finance_approval_status__c == 'Approved' || fields.Finance_approval_status__c == 'Finance Approval Approved' || fields.Finance_approval_status__c == 'Legal Approval Approved'){
            this.errorTitle = 'Error';
            this.errorMessage = 'Sorry, cannot generate order form for an approved deal!';
            this.errorVariant = 'Error';
            this.raiseToast();
            return;
        }
        debugger;
        console.log('OnClickOfNext() start');
        /*const fields1 = event.detail.fields;
        console.log('fields1.E_Sign_Status__c '+fields1.E_Sign_Status__c);
        console.log('fields1.Esign_Order__c '+fields1.Esign_Order__c);
        console.log('fields1.E_Sign_Customer_Info__c '+fields1.E_Sign_Customer_Info__c);
        console.log('fields1.E_Sign_Type__c '+fields1.E_Sign_Type__c);
        console.log('fields1.OTP_For_Electronic_Signature__c '+fields1.OTP_For_Electronic_Signature__c);*/
        this.btnPressed = 'Next';
        //this.showNext = true;
        console.log('this.btnPressed '+this.btnPressed);
        console.log('OnClickOfNext() End');
    }
    updateRecordAndCreatePDF(){
       console.log('updateRecordAndCreatePDF()');
       this.btnPressed = 'updateRecordAndCreatePDF';
       console.log('this.btnPressed '+this.btnPressed);
    }
    handleSubmit(event){
        console.log('handleSubmit() start');
        console.log('btnPressed : '+this.btnPressed);
        //numberOfContacts = 0;
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        console.log('fields.ESign_Category__c'+fields.ESign_Category__c	);
        console.log('fields.Esign_Order__c '+fields.Esign_Order__c); 
        console.log('fields.E_Sign_Type__c '+fields.E_Sign_Type__c);
        console.log('fields.Billing_GST__c	'+fields.Billing_GST__c);
        console.log('fields.Special_Terms__c '+fields.Special_Terms__c);
        if(fields.ESign_Category__c == 'E-Sign' && (fields.Esign_Order__c == undefined || fields.Esign_Order__c == null)){
            this.errorTitle = 'Error';
            this.errorMessage = 'Please fill ESign Order.';
            this.errorVariant = 'Error';
            this.raiseToast();
            return;
        }
        if(fields.ESign_Category__c == 'E-Sign' && (fields.E_Sign_Type__c == undefined || fields.E_Sign_Type__c == null)){
            this.errorTitle = 'Error';
            this.errorMessage = 'Please fill ESign Type.';
            this.errorVariant = 'Error';
            this.raiseToast();
            return;    
        }
        if(fields.ESign_Category__c == 'E-Sign' && (fields.E_Sign_Customer_Info__c == undefined || fields.E_Sign_Customer_Info__c == null)){
            this.errorTitle = 'Error';
            this.errorMessage = 'Please fill Customer ESign Info.';
            this.errorVariant = 'Error';
            this.raiseToast();
            return;
        }
        if(fields.ESign_Category__c == 'E-Sign' && fields.E_Sign_Type__c == 'electronic' && (fields.OTP_For_Electronic_Signature__c == undefined || fields.OTP_For_Electronic_Signature__c == null)){
            this.errorTitle = 'Error';
            this.errorMessage = 'Please fill OTP For Electronic Signature.';
            this.errorVariant = 'Error';
            this.raiseToast();
            return;
        }
        this.showNext = true;
        console.log('Handle submit this.btnPressed '+this.btnPressed);
        var phoneno = /^\d{10}$/;
        if(this.btnPressed == 'updateRecordAndCreatePDF'){
            console.log('Legal Entity Name '+fields.Legal_Entity_Name_Of_The_Client__c);
            console.log('Billing_GST__c '+fields.Billing_GST__c);
            console.log('If_SEZ__c '+fields.If_SEZ__c);
            console.log('PAN_No_as_per_PO__c '+fields.PAN_No_as_per_PO__c);
            console.log('Billing_Method__c '+fields.Billing_Method__c);
            console.log('Billing_Frequency__c '+fields.Billing_Frequency__c);
            console.log('Billing_F__c '+fields.Billing_F__c);
            console.log('Billing_Frequency_for_Integration_Prods__c '+fields.Billing_Frequency_for_Integration_Prods__c);
            console.log('TAN__c '+fields.TAN__c);
            console.log('Legal Entity Name '+fields.Legal_Entity_Name_Of_The_Client__c);
            console.log('Legal Entity Name '+fields.Legal_Entity_Name_Of_The_Client__c);
            console.log('Legal Entity Name '+fields.Legal_Entity_Name_Of_The_Client__c);
            console.log('Legal Entity Name '+fields.Legal_Entity_Name_Of_The_Client__c);
            if(fields.Finance_approval_status__c == 'Approved' || fields.Finance_approval_status__c == 'Finance Approval Approved' || fields.Finance_approval_status__c == 'Legal Approval Approved'){
                this.errorTitle = 'Error';
                this.errorMessage = 'Sorry, cannot generate order form for an approved deal!';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            this.numberOfContacts = 0;
            if(fields.Legal_Entity_Name_Of_The_Client__c == null || fields.Legal_Entity_Name_Of_The_Client__c == ''){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Legal Entity name Of The Client.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if((fields.CIN__c == null || fields.CIN__c == '') && ( this.countryOfOrigin == '' || this.countryOfOrigin == 'India' ) ){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill CIN.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            console.log('!this.isBillingGSTINNotAvailable: '+this.isBillingGSTINNotAvailable);
            if( (fields.Billing_GST__c == null || fields.Billing_GST__c == '') && ( this.countryOfOrigin == '' || this.countryOfOrigin == 'India')){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Billing GSTIN.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if((fields.If_SEZ__c == null || fields.If_SEZ__c == '') && ( this.countryOfOrigin == '' || this.countryOfOrigin == 'India' ) ){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill If SEZ (Yes/No)';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Company_Domain_Name__c == null || fields.Company_Domain_Name__c == '' ){
            this.errorTitle = 'Error';
            this.errorMessage = 'Please fill Company Domain Name.';
            this.errorVariant = 'Error';
            this.raiseToast();
            return;
        }
        /*if(fields.City_2__c == null || fields.City_2__c == '' ){
            this.errorTitle = 'Error';
            this.errorMessage = 'Please fill Billing City';
            this.errorVariant = 'Error';
            this.raiseToast();
            return;
        }*/
        if(fields.State_2__c == null || fields.State_2__c == '' ){
            this.errorTitle = 'Error';
            this.errorMessage = 'Please fill Billing State';
            this.errorVariant = 'Error';
            this.raiseToast();
            return;
        }
        if(fields.Pincode__c == null || fields.Pincode__c == '' ){
            this.errorTitle = 'Error';
            this.errorMessage = 'Please fill Billing Pincode';
            this.errorVariant = 'Error';
            this.raiseToast();
            return;
        }
        if(fields.Company_Domain_Name__c == null || fields.Company_Domain_Name__c == '' ){
            this.errorTitle = 'Error';
            this.errorMessage = 'Please fill Company Domain Name.';
            this.errorVariant = 'Error';
            this.raiseToast();
            return;
        }
        if(fields.Master_admin_Email__c == null || fields.Master_admin_Email__c == ''){
            this.errorTitle = 'Error';
            this.errorMessage = 'Please fill Master admin Email.';
            this.errorVariant = 'Error';
            this.raiseToast();
            return;
        }
            if((fields.PAN_No_as_per_PO__c == null || fields.PAN_No_as_per_PO__c == '') && ( this.countryOfOrigin == '' || this.countryOfOrigin == 'India' ) ){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Billing PAN.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            /*if((fields.Billing_Frequency_for_retainership__c == null || fields.Billing_Frequency_for_retainership__c == '') && this.recordType == 'Net_New_Cimplyfive'){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Billing Frequency for retainership.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }*/
            if(fields.Billing_Method__c == null || fields.Billing_Method__c == ''){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Billing Method.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }

            /*if((fields.Billing_Frequency__c == null || fields.Billing_Frequency__c == '')  && (fields.Total_Roll_Up_OTP__c != '0.00' && fields.Total_Roll_Up_OTP__c != '' ) ){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Billing Frequency for Service Fee (OTP).';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }*/
            
            if(fields.Billing_F__c == null || fields.Billing_F__c == ''){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Billing Frequency for Subscription Fee.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Billing_Frequency_for_Integration_Prods__c == 'Custom' && (fields.Custom_Billing_Freq_for_Integration_Prod__c == null || fields.Custom_Billing_Freq_for_Integration_Prod__c == '')){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please enter Custom Billing Freq for Integration Prod.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if((fields.TAN__c == null || fields.TAN__c == '') && ( this.countryOfOrigin == '' || this.countryOfOrigin == 'India' ) ){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill TAN.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Place_of_Supply__c == null || fields.Place_of_Supply__c == ''){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Place of supply.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Payment_Method__c == null || fields.Payment_Method__c == ''){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Payment Method.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Payment_Term__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Payment Term.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Period_End_date__c  <= fields.Period_Start_date__c ){
                this.errorTitle = 'Error';
                this.errorMessage = 'PO Period To date cannot be less than PO Period From Date.Please fill appropriate PO Period To Date.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Billing_Address__c == null || fields.Billing_Address__c == ''){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Billing Address .';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Shipping_Address__c == null || fields.Shipping_Address__c == ''){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Shipping Address.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.PO_Required__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please select PO Required Yes or No.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.PO_Required__c == 'Yes' && (fields.PO_number__c == null || fields.PO_Amount__c == null)){
                this.errorTitle = 'Error';
                this.errorMessage = 'Enter PO Number and PO Amount.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
       
            if((fields.Fee_per_additional_usage__c == null || fields.Fee_per_additional_usage__c == '') && ( this.countryOfOrigin != '' && this.countryOfOrigin != 'India' ) ){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Fee per additional usage.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if((fields.GCC_initial_term_months__c == null || fields.GCC_initial_term_months__c == '') && ( this.countryOfOrigin != '' && this.countryOfOrigin != 'India' ) ){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Initial term ( months ).';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }

            console.log('Check 1');
            if(fields.Bus_POC__c != null && fields.Bus_POC__c != ''){
                console.log('*&*&*&* 1');
                this.numberOfContacts = this.numberOfContacts+1;
                console.log('this.numberOfContacts '+this.numberOfContacts);
            }
            if((fields.Bus_POC__c == null || fields.Bus_POC__c == '') && ( this.countryOfOrigin == '' || this.countryOfOrigin == 'India' ) ){
                this.errorTitle = 'Error';
                this.errorMessage = 'Enter Business POC.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }

            var businessPocCN = fields.Business_POC_Contact_Number__c;
            if(businessPocCN != null && !(businessPocCN.match(phoneno))){
                this.errorTitle = 'Error';
                this.errorMessage = 'Enter valid Business POC Contact Number.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            console.log('Check 2');
            if(fields.Finance_POC_contact__c != null && fields.Finance_POC_contact__c != ''){
                    console.log('*&*&*&* 2');
                    this.numberOfContacts = this.numberOfContacts+1;
                    console.log('this.numberOfContacts '+this.numberOfContacts);
            }

            if((fields.Finance_POC_contact__c == null || fields.Finance_POC_contact__c == '') && ( this.countryOfOrigin == '' || this.countryOfOrigin == 'India' ) ){
                this.errorTitle = 'Error';
                this.errorMessage = 'Enter Finance POC for invoice processing.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }

            var financePocCN = fields.Finance_POC_For_Invoice_Processing_Phone__c;
            if(financePocCN != null && !(financePocCN.match(phoneno))){
                this.errorTitle = 'Error';
                this.errorMessage = 'Enter valid Finance POC Phone Number.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            console.log('Check 3');
            console.log('fields.Tax_Head_Name__c '+fields.Tax_Head_Name__c);
            console.log('fields.Tax_Head_Email__c '+fields.Tax_Head_Email__c);
            console.log('fields.Tax_Head_Designation__c '+fields.Tax_Head_Designation__c);
            console.log('fields.Tax_Head_Contact_Number__c '+fields.Tax_Head_Contact_Number__c);
            if(fields.Tax_Head_contact__c != null && fields.Tax_Head_contact__c != ''){
                    console.log('*&*&*&* 3');
                    this.numberOfContacts = this.numberOfContacts+1;
                    console.log('this.numberOfContacts '+this.numberOfContacts);
            }
            var taxHeadCN = fields.Tax_Head_Contact_Number__c;
            if(taxHeadCN != null && !(taxHeadCN.match(phoneno))){
                this.errorTitle = 'Error';
                this.errorMessage = 'Enter valid Tax Head Contact Number.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            console.log('Check 4');
            console.log('fields.Finance_Head_Name__c '+fields.Finance_Head_Name__c);
            console.log('fields.Finance_Head_Email__c '+fields.Finance_Head_Email__c);
            console.log('fields.Finance_Head_Designation__c '+fields.Finance_Head_Designation__c);
            console.log('fields.Finance_Head_Contact_Number__c '+ fields.Finance_Head_Contact_Number__c);
            if(fields.Finance_Head_contact__c != null && fields.Finance_Head_contact__c != ''){
                    console.log('*&*&*&* 4');
                    this.numberOfContacts = this.numberOfContacts+1;
                    console.log('this.numberOfContacts '+this.numberOfContacts);
            }
            //Recordtype removal - C5
            if((fields.Finance_Head_contact__c == null || fields.Finance_Head_contact__c == '') && ( this.countryOfOrigin == '' || this.countryOfOrigin == 'India' ) && this.ClearTax_Billing_Entity__c != 'CimplyFive'){
                this.errorTitle = 'Error';
                this.errorMessage = 'Enter Finance Head.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Company_Secretary__c != null && fields.Company_Secretary__c != ''){
                console.log('*&*&*&* 4');
                this.numberOfContacts = this.numberOfContacts+1;
                console.log('this.numberOfContacts '+this.numberOfContacts);
        }

       /* if((fields.Company_Secretary__c == null || fields.Company_Secretary__c == '') && this.recordType == 'Net_New_Cimplyfive'){
            this.errorTitle = 'Error';
            this.errorMessage = 'Enter Company Secretary.';
            this.errorVariant = 'Error';
            this.raiseToast();
            return;
        }*/
            
            var financeHeadCN = fields.Finance_Head_Contact_Number__c;
            if(financeHeadCN != null && !(financeHeadCN.match(phoneno))){
                this.errorTitle = 'Error';
                this.errorMessage = 'Enter valid Finance Head Contact Number.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            console.log('Check 5');
            console.log('fields.IT_Head_Name__c '+fields.IT_Head_Name__c);
            console.log('fields.IT_Head_Email__c '+fields.IT_Head_Email__c);
            console.log('fields.IT_Head_Designation__c '+fields.IT_Head_Designation__c);
            console.log('fields.IT_Head_Contact_Number__c '+fields.IT_Head_Contact_Number__c);
            if(fields.IT_Head_contact__c != null && fields.IT_Head_contact__c != ''){
                    console.log('*&*&*&* 5');
                    this.numberOfContacts = this.numberOfContacts+1;
                    console.log('this.numberOfContacts '+this.numberOfContacts);
           }

            /*if((fields.IT_Head_contact__c == null || fields.IT_Head_contact__c == '') && this.recordType == 'International'){
                this.errorTitle = 'Error';
                this.errorMessage = 'Enter IT POC.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }*/

           var ITHeadCN = fields.IT_Head_Contact_Number__c;
            if(ITHeadCN != null && !(ITHeadCN.match(phoneno))){
                this.errorTitle = 'Error';
                this.errorMessage = 'Enter valid IT Head Contact Number.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
           console.log('numberOfContacts '+this.numberOfContacts);
            if(this.numberOfContacts < 2 && ( this.countryOfOrigin == '' || this.countryOfOrigin == 'India' ) ){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill all details(Name, Email, Designation, Phone Number) of atleast any 2 Contact Details';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            /*if(fields.Business_POC_Name__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Business POC Name.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Business_POC_Email__c	== null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Business POC Email.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Business_POC_Designation__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Business POC Designation.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Business_POC_Contact_Number__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Business POC COntact Number.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Finance_POC_For_Invoice_Processing_Name__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Finance POC For Invoice Processing Name.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Finance_POC_For_Invoice_Processing_Email__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Finance POC For Invoice Processing Email.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Finance_POC_For_Invoice_Processing_Desig__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Finance POC For Invoice Processing Desig.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Finance_POC_For_Invoice_Processing_Phone__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Billing GSTIN.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Tax_Head_Name__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Tax Head Name.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Tax_Head_Email__c	 == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Tax Head Email.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Tax_Head_Designation__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Tax Head Designation.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Tax_Head_Contact_Number__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Tax Head Contact Number.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Finance_Head_Name__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Finance Head Name.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Finance_Head_Email__c	 == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Finance Head Email.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Finance_Head_Designation__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Finance Head Designation.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.Finance_Head_Contact_Number__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill Finance Head Contact Number.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.IT_Head_Name__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill IT Head Name.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.IT_Head_Email__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill IT Head Email.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.IT_Head_Designation__c == null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill IT Head Designation.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }
            if(fields.IT_Head_Contact_Number__c	== null){
                this.errorTitle = 'Error';
                this.errorMessage = 'Please fill IT Head Contact Number.';
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            }*/
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
        console.log('handleSubmit() End');
     }
     
     handleSuccess(event){  
        console.log('handleSuccess Called'+this.recordId);
       /* this.vfURL  = '/apex/generateOrderForm?id='+this.recordId;*/
        const updatedRecord = event.detail.id;
        console.log('onsuccess: ', updatedRecord);
        /*this.renderPDF = true;*/
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: event.detail.apiName + ' Successfully Updated.',
                variant: 'success',
            }),
        );
        console.log('Before save');
        this.saveOrderForm();
        console.log('After save');
     }
     raiseToast(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.errorTitle,
                message: this.errorMessage,
                variant: this.errorVariant,
            }),
        );
     }
     
     saveOrderForm() {
        console.log('onClickOfSaveOrderForm() Start');
         var oppId = this.recordId;
         console.log('oppId '+oppId);
         console.log('this.recordId; '+this.recordId);
         this.showSpinner = true;
         saveOrderFormToOpportunity({oppId : this.recordId})
            .then((data) => {
                console.log('result '+data);
                this.showSpinner = false;
                if(data == null){
                    this.errorTitle = 'Error';
                    this.errorMessage = 'Error while generating OrderForm. Please Contact Admin';
                    this.errorVariant = 'Error';
                    this.raiseToast();
                    return;
                }else{
                    console.log('*data '+data);
                    this.orderFormFileId = data;
                    console.log('this.orderFormFileId '+this.orderFormFileId);
                    //this.renderPDF = true;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'filePreview'
                        },
                        state:{
                            selectedRecordId:this.orderFormFileId
                        }
                    });
                    console.log('****');
                }
                /*console.log('this.opportunityDetails.ESign_Category__c '+this.opportunityDetails.ESign_Category__c);
                if(this.opportunityDetails.ESign_Category__c == 'Physical Sign' ){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Order Form Successfuly Saved. Download The Order Form, get the Physical Sign and Upload.',
                            variant: 'success',
                        }),
                    );
                    eval("$A.get('e.force:refreshView').fire();");
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Order Form Successfuly Saved',
                            variant: 'success',
                        }),
                    );
                    eval("$A.get('e.force:refreshView').fire();");
                }*/
                
            })
            .catch(error => {
                console.log('Exception occured');
                console.log('error.body.message ',error);
                this.errorTitle = 'Error';
                this.errorMessage = error.body.message;
                this.errorVariant = 'Error';
                this.raiseToast();
                return;
            });
            console.log('onClickOfSaveOrderForm() End');
    }
     /*@wire(saveOrderFormToOpportunity,{})
     returnedValue(data){
        if (data) {
            console.log('data '+data);
        }else if (error) {
            console.log('error '+error);
        }
     }*/
    // Wire getVFOrigin Apex method to a Property
    /*@wire(getVFOrigin,{oppId : '$recordId'})
    vfOrigin;*/
    /*showValue(){
        console.log(‘*** ’+JSON.stringify(this.vfOrigin));
        let message = this.recordId;
        console.log(‘message ’+message);
        //Firing an event to send data to VF
        this.template.querySelector(“iframe”).contentWindow.postMessage(message, this.vfOrigin.data);
    }*/
}