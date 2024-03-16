import { LightningElement, api } from 'lwc';
import getCaseForConEmail from '@salesforce/apex/CTX_HelpAndSupportController.getCaseForConEmail';

export default class Ctx_ManageCaseComponent extends LightningElement {
    @api email;
    @api contact;
    myCases =[];

    connectedCallback(){
        this.fetchUserCases();
    }

    refreshCases(){
        this.template.querySelector('lightning-tabset').activeTabValue = 'myCases';
        this.fetchUserCases();

    }

    @api
    fetchUserCases(){
        console.log('Hello');
        getCaseForConEmail({conEmail : this.email})
            .then(result => {
                this.myCases = result;
                console.log(this.myCases);
            })
            .catch(error => {
                console.log(error);
            })
    }
}