import { LightningElement,api,track } from 'lwc';
import getResults from '@salesforce/apex/CTX_MuliselectLookUpController.getResults';

export default class Ctx_MultiSelectLookup extends LightningElement {
    @api objectName;
    @api fieldName = 'Name';
    @api searchOnField ='Name';
    @api lookupFilterCondition;
    @api label;
    @track searchRecords = [];
    @track selectedRecords = [];
    @api required = false;
    @api iconName = 'action:new_account'
    @api loadingText = false;
    @track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track messageFlag = false;
    @api selectedContacts = [];

    connectedCallback(){
        if(this.selectedContacts.length > 0){
            this.selectedRecords = this.selectedContacts.map(item => {
                return {recId : item.Id, recName : item.Name, record : item};
            })
        }
    }
 
    searchField(event) {

        var currentText = event.target.value;
        var selectRecId = [];
        for(let i = 0; i < this.selectedRecords.length; i++){
            selectRecId.push(this.selectedRecords[i].recId);
        }
        this.loadingText = true;
        getResults({ ObjectName: this.objectName, fieldName: this.fieldName, searchOnField: this.searchOnField, lookupFilterCondition: this.lookupFilterCondition, value: currentText, selectedRecId : selectRecId })
        .then(result => {
            this.searchRecords= result;
            this.loadingText = false;
            
            this.txtclassname =  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
            if(currentText.length > 0 && result.length === 0) {
                this.messageFlag = true;
            }
            else {
                this.messageFlag = false;
            }

            if(this.selectRecordId != null && this.selectRecordId.length > 0) {
                this.iconFlag = false;
                this.clearIconFlag = true;
            }
            else {
                this.iconFlag = true;
                this.clearIconFlag = false;
            }
        })
        .catch(error => {
            console.log('-------error-------------'+error);
            console.log(error);
        });
        
    }
    
   setSelectedRecord(event) {
        var recId = event.currentTarget.dataset.id;
        this.selectedRecords.push(this.searchRecords.filter(result => result.recId === recId)[0]);
        this.txtclassname =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        let selRecords = this.selectedRecords.map(item => {
            return item.record;
        });
		this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = '';
        });
        const selectedEvent = new CustomEvent('selected', { detail: selRecords});
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    removeRecord (event){
        let selectRecId = [];
        for(let i = 0; i < this.selectedRecords.length; i++){
            if(event.detail.name !== this.selectedRecords[i].recId)
                selectRecId.push(this.selectedRecords[i]);
        }
        this.selectedRecords = [...selectRecId];
        let selRecords = this.selectedRecords.map(item => {
            return item.record;
        });
        const selectedEvent = new CustomEvent('selected', { detail: selRecords});
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}