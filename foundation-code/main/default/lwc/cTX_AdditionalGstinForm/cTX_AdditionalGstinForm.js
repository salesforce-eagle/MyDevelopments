import { LightningElement, api, wire, track } from 'lwc';
import getAdditionalGstins from '@salesforce/apex/CTX_AdditionalGstinUpsellController.getAdditionalGstins';
import updateBillingIds from '@salesforce/apex/CTX_AdditionalGstinUpsellController.updateBillingIds';
import IS_VISIBLE_ADDITIONAL_GSTIN from '@salesforce/schema/Upsell_Top_up__c.isVisibleAdditionalGstin__c';
import IS_EDITABLE from '@salesforce/schema/Upsell_Top_up__c.Update_Company_Information__c';
import NAME from '@salesforce/schema/Additional_GSTIN__c.Name';
import AMOUNT from '@salesforce/schema/Additional_GSTIN__c.Amount__c';
import ADD_ON_SPLIT from '@salesforce/schema/Additional_GSTIN__c.Add_on_split__c';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ProfileName from '@salesforce/schema/User.Profile.Name';


const additionalGstnsColumns = [
    {
        label: 'GSTIN',
        fieldName: 'Name',
        type: 'text',
        cellAttributes: { alignment: 'left' },
    },

    {
        label: 'Add-On Split',
        fieldName: 'Add_on_split__c',
        type: 'text',
        editable: true,
        wrapText: false,
        cellAttributes: { alignment: 'left' },
    },

    {
        label: 'Name Of The Customer',
        fieldName: 'Name_Of_The_Customer__c',
        type: 'text',
        editable: false,
        wrapText: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Billing PAN',
        fieldName: 'Billing_PAN__c',
        type: 'text',
        cellAttributes: { alignment: 'left' },
    },
    
   
   {
        label: 'Address Line 1',
        fieldName: 'Address__c',
        type: 'text',
        editable: false,
        wrapText: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Address Line 2',
        fieldName: 'Address_Line_2__c',
        type: 'text',
        editable: false,
        wrapText: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'City',
        fieldName: 'City__c',
        type: 'text',
        editable: false,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'State',
        fieldName: 'State__c',
        type: 'text',
        editable: false,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Pincode',
        fieldName: 'Pincode__c',
        type: 'text',
        editable: false,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'SEZ (Yes/No)',
        fieldName: 'SEZ_Yes_No__c',
        type: 'text',
        editable: false,
        cellAttributes: { alignment: 'left' },
    }
];

export default class cTX_AdditionalGstinForm extends LightningElement {

    @api recordId;
    @api objectApiName
    @track getGstinsList;
    @track draftValues = [];
    @track additionalGstnList
    @track error = []
    @track fieldErrors
    additionalGstnsColumns = additionalGstnsColumns;
    isVisibleGstns = false
    isReadOnly = true;
    isEditable= false
   

    @wire(getRecord, {recordId : '$recordId', fields: [IS_VISIBLE_ADDITIONAL_GSTIN,IS_EDITABLE ]})
    topup;


    @wire(getAdditionalGstins, {topupId:'$recordId'})
    fetchAdditionalGstins(result){
        this.getGstinsList = result;
        if(result.data){ 
            let dataList = JSON.parse(JSON.stringify(result.data))    
            this.isVisibleGstns = dataList?.length > 0 ? true:false;
            this.additionalGstnList = dataList;
            this.accessCheck();
            console.log('additionalGstnList'+JSON.stringify(this.additionalGstnList));
            
        }else{
            this.error = result.error;
            
            this.additionalGstnList = undefined;
        }
        refreshApex(this.getGstinsList);
    }
    
    
    accessCheck(){
        console.log('@isEditable'+getFieldValue(this.topup.data, IS_EDITABLE));
        if(getFieldValue(this.topup.data, IS_EDITABLE)){
            this.additionalGstnsColumns = this.additionalGstnsColumns.map((column) => {
                if (column.fieldName != 'Add_on_split__c' || column.fieldName != 'Name') {
                    return { ...column, editable: true };
                }
                return column;
            });
        }
    }
    
    get isVisible() {
        return (getFieldValue(this.topup.data, IS_VISIBLE_ADDITIONAL_GSTIN) && this.isVisibleGstns)
    }

   
    
    
    
    handleSave(event) {
        const recordInputs =  event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        
        updateBillingIds({gstinList:event.detail.draftValues})
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Updated',
                    variant: 'success'
                })
                );
                return refreshApex(this.getGstinsList);
            }).catch(error=>{
                console.log('Error->');
                
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })
            
        } 
        
    }