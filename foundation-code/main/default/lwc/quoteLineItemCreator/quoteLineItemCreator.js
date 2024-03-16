import { LightningElement ,api, wire, track} from 'lwc';
import getProductList from '@salesforce/apex/QuoteProductController.getProductList';
import saveQuoteLineItems from '@salesforce/apex/QuoteProductController.saveQuoteProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NoProductToAdd	 from '@salesforce/label/c.No_Product_to_add';
import {NavigationMixin} from 'lightning/navigation';


const productColumns = [
    {
        label: 'Name',
        fieldName: 'Name',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Product Category',
        fieldName: 'Product_category__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Family',
        fieldName: 'Family',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'ProductCode',
        fieldName: 'ProductCode',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
];
export default class quoteLineItemCreator extends NavigationMixin(LightningElement){
    label = {
        NoProductToAdd
    };

    productColumns = productColumns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    noProductToShowError=true;
    
    @api recordId;
    @track selectedProducts = [];
    @track error;
    @track productListData;
    @track searchKey = '';
    @track showLineItem;
    @track insertedRecord;
    isSpinner = false;

    @wire(getProductList, { quoteId: '$recordId' }) wired(result) {
        if (result.data && result.data != null && result.data != '' ) {
            this.productListData = result.data;
            this.noProductToShowError=false;

        }
        if (result.error) {
            this.error = result.error;
        }
    }

    //Search Product
    get filteredProductListData() {
        if (this.searchKey) {
            return this.productListData.filter(record => {
                const { name } = record;
                return name.toLowerCase().includes(this.searchKey); 
            })
        }
        return this.productListData;
    }

    handleOnSearchChange(event) {
        this.searchKey = event.target.value;
    }
    //End Search Product

    // Used to sort the 'Age' column
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
        const cloneData = [...this.productListData];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.productListData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    getSelectedId(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedProducts = [];
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            this.selectedProducts.push(selectedRows[i].Id);
            this.isButtonActive = true;
        }
    }

    saveProduct(){
        this.isSpinner = true;
        console.log('id '+this.recordId);
        saveQuoteLineItems({ productIds: this.selectedProducts , quoteId: this.recordId})
        .then((data) => {
            //this.quoteLineItems = data;
            console.log('result '+data);
            this.insertedRecord = data;
            //this.template.querySelector("c-quote-line-item-creator").handleValueChange();
            this.error = '';
            this.showLineItem = true
            this.navigateToQLIRelatedListView();
            this.isSpinner = false;
        })
        .catch((error) => {
            this.isSpinner = false;
            this.error = 'Unknown error';
            //this.error = error.pageErrors[0].message;
            if(Array.isArray(error.body.pageErrors)){
                this.error = error.body.pageErrors.map(e => e.message).join(', ');
            }
            else if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if(Array.isArray(error.body.output.errors)){
                this.error = error.body.output.errors.map(e => e.message).join(', ');
            }
            else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            this.error = this.error.replace(/[{}]/g,'');
            const evt = new ShowToastEvent({
                title: 'Product Selection Failed',
                message: this.error,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        });
        
    }

    navigateToQLIRelatedListView() {
        const evt = new ShowToastEvent({
            title: 'SUCCESS',
            message: 'Quote Line Item Added Successfully! Kindly click on each Quote Line Item (Product Name) and update relevant values.',
            variant: 'success',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Quote',
                relationshipApiName: 'QuoteLineItems',
                actionName: 'view'
            },
        });
        eval("$A.get('e.force:refreshView').fire();");
    }
    
    get isProductSelected(){
        return this.selectedProducts.length > 0 ? true : false;
    }

 
}