import { LightningElement, api, wire, track } from 'lwc';
import getProductList from '@salesforce/apex/QuoteProductController.getProducts';
const productFields = [
    {
        label: 'Name',
        fieldName: 'Name',
        type: 'text',
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Plan Allowance GSTIN',
        fieldName: 'Plan_Allowance_GSTIN__c',
        type: 'text',
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Plan Allowance PAN',
        fieldName: 'Plan_Allowance_PAN__c',
        type: 'text',
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Plan Allowance GSTIN verification credit',
        fieldName: 'Plan_Allowance_GSTIN_Verification__c',
        type: 'text',
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Plan Allowance Total invoices',
        fieldName: 'Plan_Allowance_Total_invoices__c',
        type: 'text',
        cellAttributes: { alignment: 'left' },
    },
];
export default class QliProductEditor extends LightningElement {
    @track error;
    @api recordId;
    @track productList;
    isVisible = false

    productColumns = productFields;
    
    @wire(getProductList, { quoteId: '$recordId' }) 
    fetchProductList(result) {
        if(result.data){
            console.log(JSON.stringify(result.data));
            let products = JSON.parse(JSON.stringify(result.data));
             this.productList = products;
             this.isVisible = products?.length > 0 ? true:false;
        }
        else if(result.error){
            console.log(result.error);
            this.error = result.error;
        }
    }

}