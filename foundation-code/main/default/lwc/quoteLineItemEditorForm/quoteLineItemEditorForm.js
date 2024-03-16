import { LightningElement, api, track, wire } from 'lwc';
import getQuoteLineItemList from '@salesforce/apex/QuoteProductController.getQuoteLineItemList';

export default class QuoteLineItemEditorForm extends LightningElement {
    @track error;
    @api quoteId;
    @track quoteLineItemsList;
    @track fields = ['LineNumber','ProductName','UnitPrice','Sale_Price__c','Threshold_Price__c','Discount','MarkUp__c','Period_Start_date__c','Period_End_date__c','SOW_Start_Date__c','SOW_End_Date__c'];
    @api insertedRecords =[];
    @track activeSections = [];

     
    @wire(getQuoteLineItemList, { quoteId: '$quoteId' }) 
    wired(result) {

        if(result.error){
            console.log(result.error);
            this.error = result.error;
        }
        if(result.data){
            console.log(JSON.stringify(result.data));
            let data2 = JSON.parse(JSON.stringify(result.data))
            data2.forEach(item=>{
                if(this.insertedRecords.includes(item.recordId)){
                    this.activeSections.push(item.recordId);
                }
                item.isMS = true;
            });
            this.quoteLineItemsList = data2;
        }
    }

    handleToggleSection(event){
        console.log(event);
    }

}