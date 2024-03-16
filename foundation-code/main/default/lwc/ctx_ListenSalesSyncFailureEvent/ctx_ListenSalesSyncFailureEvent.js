import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';

export default class Ctx_ListenSalesSyncFailureEvent extends LightningElement {
    @api recordId;
    @api channelName;
    errorMessage;
    isError = false;

    connectedCallback() {       
        // Register error listener  
        console.log(this.channelName);   
        this.registerErrorListener();
        this.handleSubscribe();
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = function(response) {
            
            var obj = JSON.parse(JSON.stringify(response));
            console.log(JSON.stringify(obj));
            if(obj.data.payload.Record_Id__c === this.recordId){
                this.setError(true, obj.data.payload.ErrorMessages__c);
                let errorMessage = this.errorMessage.replaceAll('{', '').replaceAll('}', '');
                const evt = new ShowToastEvent({
                    title: 'Error!!',
                    message: errorMessage,
                    variant: 'error',
                });

                this.dispatchEvent(evt);
                //getRecordNotifyChange([{recordId: this.recordId}]);
                updateRecord({ fields: { Id: this.recordId } });
                // Response contains the payload of the new message received
            }
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback.bind(this)).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    // Handles unsubscribe button click
    handleUnsubscribe() {

        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }
   
    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

    get isError() {
        return this.errorMessage ? true : false;
    }

    closeError(){
        this.setError(false, '');
    }

    setError(isError, errorMessage){
        this.isError        = isError;
        this.errorMessage   = errorMessage;
    }

}