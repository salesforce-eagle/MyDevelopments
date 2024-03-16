import { LightningElement ,api, wire, track} from 'lwc';
import quoteLineItemsRefreshed from '@salesforce/apex/QuoteProductController.getQuoteLineItemList';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NoProducttoedit	 from '@salesforce/label/c.No_Product_to_edit';


const quoteColumns = [
    {
        label: 'Quote Line Number',
        fieldName: 'LineNumber',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Product',
        fieldName: 'ProductName',
        type: 'text',
        sortable: true,
        editable: false,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'UnitPrice',
        fieldName: 'UnitPrice',
        type: 'currency',
        sortable: true,
        editable: true,
        cellAttributes: { alignment: 'right' },
    },
    {
        label: 'Sale Price',
        fieldName: 'Sale_Price__c',
        type: 'currency',
        sortable: true,
        editable: true,
        cellAttributes: { alignment: 'right' },
    },
    {
        label: 'Threshold Price',
        fieldName: 'Threshold_Price__c',
        type: 'currency',
        sortable: true,
        editable: false,
        cellAttributes: { alignment: 'right' },
    },
    {
        label: 'Discount %',
        fieldName: 'Discount',
        type: 'percent-fixed',
        sortable: true,
        editable: false,
        cellAttributes: { alignment: 'right' },
        typeAttributes:{ maximumFractionDigits: 4 },
    },
    {
        label: 'MarkUp %',
        fieldName: 'MarkUp__c',
        type: 'percent-fixed',
        sortable: true,
        editable: false,
        cellAttributes: { alignment: 'right' },
        typeAttributes:{ maximumFractionDigits: 4 },
    },
    {
        label: 'Period Start date',
        fieldName: 'Period_Start_date__c',
        type: 'date-local',
        sortable: true,
        editable: true,
        cellAttributes: { alignment: 'right' },
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'Period End Date',
        fieldName: 'Period_End_date__c',
        type: 'date-local',
        sortable: true,
        editable: false,
        cellAttributes: { alignment: 'right' },
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'SOW Start date',
        fieldName: 'SOW_Start_Date__c',
        type: 'date-local',
        sortable: true,
        editable: true,
        cellAttributes: { alignment: 'right' },
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'SOW End Date',
        fieldName: 'SOW_End_Date__c',
        type: 'date-local',
        sortable: true,
        editable: true,
        cellAttributes: { alignment: 'right' },
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    }
];
export default class quoteLineItemEditor extends LightningElement {
    label = {
        NoProducttoedit
    };
    
    quoteColumns = quoteColumns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    noProductToShowError=true;
    

    @api recordId;
    @track error;
    @track quoteLineItemsFromApex;
    @track draftValues = [];
    @track refreshedQuoteItems;
    
    /*@wire(quoteLineItemsRefreshed,{quoteId: '$recordId'})
            quoteLineItemsFromApex;*/

    /*@wire(quoteLineItemsRefreshed,{quoteId: '$recordId'})
        quoteLineItemsFromApex;*/


        @wire(quoteLineItemsRefreshed, { quoteId: '$recordId' }) wired(result) {
            this.quoteLineItemsFromApex = result;
            console.log('result--->'+JSON.stringify(result));
            if (result.data && result.data != null && result.data != ''){
                let quoteLineItems = [];
                result.data.forEach(lineItems => {
                    let quoteLineItem = {};
                    quoteLineItem.Id = lineItems.Id;
                    quoteLineItem.LineNumber = lineItems.LineNumber;
                    quoteLineItem.ProductName = lineItems.Product2.Name;
                    quoteLineItem.UnitPrice = lineItems.UnitPrice;
                    quoteLineItem.Quantity = lineItems.Quantity;
                    quoteLineItem.Discount = lineItems.Discount;
                    quoteLineItem.MarkUp__c = lineItems.MarkUp__c;
                    quoteLineItem.Total_Price__c = lineItems.Total_Price__c;
                    //Addition on Feb 4th 2021
                    quoteLineItem.Sale_Price__c = lineItems.Sale_Price__c;
                    quoteLineItem.Period_Start_date__c = lineItems.Period_Start_date__c;
                    quoteLineItem.Period_End_date__c = lineItems.Period_End_date__c;
                    quoteLineItem.Threshold_Price__c = lineItems.Threshold_Price__c;
                    quoteLineItem.SOW_Start_Date__c = lineItems.SOW_Start_Date__c;
                    quoteLineItem.SOW_End_Date__c = lineItems.SOW_End_Date__c;
                    // and so on for other fields
                    quoteLineItems.push(quoteLineItem);
                });
                this.refreshedQuoteItems = quoteLineItems;
                this.noProductToShowError=false;
            }
            if (result.error) {
                this.error = result.error;
               
            }
            refreshApex(this.quoteLineItemsFromApex);
        }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.refreshedQuoteItems];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.refreshedQuoteItems = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    handleSave(event) {
        const recordInputs =  event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
   
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
       
        Promise.all(promises).then(quoteLineItems => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'All Quote Line Items updated',
                    variant: 'success'
                })
            );
             // Clear all draft values
             this.draftValues = [];
             this.error = '';
             // Display fresh data in the datatable
             //console.log('ee'+);
             
             return refreshApex(this.quoteLineItemsFromApex);
        }).catch(error => {
            var fieldErrors = error.body.output.fieldErrors;
            this.error = 'Unknown error';
            //this.error = error.pageErrors[0].message;
            if (error.body.output.fieldErrors != null) {
                console.log('Displaying Field Errors');
                for (var prop in fieldErrors) {
                    console.log(Object.keys(fieldErrors));
                    var val = Object.values(fieldErrors);
                    console.log(val[0][0]["message"]);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error Updating record',
                            message: val[0][0]["message"],
                            variant: 'error'
                        })
                    );
                }
            }
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if(Array.isArray(error.body.output.errors)){
                this.error = error.body.output.errors.map(e => e.message).join(', ');
            }
            else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            } else if(Array.isArray(error.body.pageErrors)){
                this.error = error.body.pageErrors.map(e => e.message).join(', ');
            }
            this.error = this.error.replace(/[{}]/g,'');
            const evt = new ShowToastEvent({
                title: 'Line Item Update failed',
                message: this.error,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log('EERR '+error);
        });
    }
}