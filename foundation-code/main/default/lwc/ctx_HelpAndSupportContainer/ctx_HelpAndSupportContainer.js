import { LightningElement,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class Ctx_HelpAndSupportContainer extends LightningElement {
    email;
    contact;
    showOTP = true;

    @wire (CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          console.log(currentPageReference);
       }
    }

    handleVerifyOTP(event) {
        this.email = event.detail.contactEmail;
        this.contact = event.detail.contact;
        this.showOTP = false;
    }
}