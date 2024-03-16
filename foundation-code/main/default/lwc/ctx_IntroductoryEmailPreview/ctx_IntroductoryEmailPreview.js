import { LightningElement,api } from 'lwc';
import getIntroductoryEmailContent from '@salesforce/apex/CTX_CSMJourneyHandler.getIntroductoryEmailContent';
import sendIntoductoryEmail from '@salesforce/apex/CTX_CSMJourneyHandler.sendIntoductoryEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Ctx_IntroductoryEmailPreview extends LightningElement {
    @api recordId;
    emailWrapper;
    lookupFilterCondition;
    showModal = false;
    showSpinner = false;
    
    connectedCallback(){
        getIntroductoryEmailContent({recordId:this.recordId})
            .then(result=> {
                this.emailWrapper = result;
                this.lookupFilterCondition = "Is_Communicable__c=true AND AccountId='" + this.emailWrapper.relatedAssetRecord.AccountId + "'";
            })
            .catch(error=>{

            })
    }

    handleSendEmail(event){
        if(this.emailWrapper.toContacts){
            if(this.emailWrapper.toContacts.length > 0){
                this.showSpinner = true;
                sendIntoductoryEmail({ emailWrapper: this.emailWrapper })
                    .then(result => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Email Sent Successfully!',
                                variant: 'success'
                            })
                        );
                        this.showSpinner = false;
                        this.handleToggleModal();
                        window.setTimeout(() => {
                            window.location.reload();
                        }, 3000);
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
        }
    }

    handleRecordSelected(event){
        this.emailWrapper.toContacts = event.detail; 
        console.log(JSON.stringify(this.emailWrapper.toContacts));
    }

    handleEmailBodyChange(event){
        this.emailWrapper.htmlBody = event.target.value;
    }

    handleSubjectChange(event){
        this.emailWrapper.subject = event.target.value;
    }

    handleToggleModal(){
        this.showModal = this.showModal ? false : true;
    }
}