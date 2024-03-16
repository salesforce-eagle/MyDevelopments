import { LightningElement, api, wire, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import OPP_ID from '@salesforce/schema/Opportunity.Id';
import STAGE_CHECKLIST from '@salesforce/schema/Opportunity.Stage_CheckList__c';
import RECORD_TYPE_ID from '@salesforce/schema/Opportunity.RecordTypeId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

const FIELDS = [OPP_ID, STAGE_CHECKLIST, RECORD_TYPE_ID];

export default class CTX_OpportunityStageChecklist extends LightningElement {

    @api recordId;
    @api recordTypeId;
    @api objectApiName;
    @track selectedStage;
    selectedOptions = [];
    @track oppInfo
    optionSize;
    @track showSpinner = false;
    optionSize
    renderOnce = false;

    ; renderedCallback() {
        if (this.renderOnce == false) {
            setTimeout(() => {
                this.refreshPage();
            }, 2000)

            this.renderOnce = true;
        }

    }

    refreshPage() {
        this.template.querySelectorAll(`[data-id="checkbox"]`).forEach(item => {
            if (this.selectedStage.includes(item.dataset.value)) {
                item.checked = true;
            } else {
                item.checked = false;
            }
        })
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    fetchRecord({ error, data }) {
        if (error) {
            console.log('error', JSON.parse(JSON.stringify(error)));
        } else if (data) {
            this.oppInfo = JSON.parse(JSON.stringify(data));
            this.recordTypeId = this.oppInfo.recordTypeId;
            this.selectedStage = this.oppInfo.fields.Stage_CheckList__c.value;

        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: STAGE_CHECKLIST })
    stageChecklistVal



    get optionValues() {
        if (this.stageChecklistVal.data) {

            return this.stageChecklistVal.data.values.map(option => option.value);

        } else {
            return [];
        }
    }


    updateOpportunity() {

        this.template.querySelectorAll(`[data-id="checkbox"]`).forEach(item => {

            if (item.checked) {

                this.selectedOptions.push(item.dataset.value);
            }
        });
        this.showSpinner = true;
        const fields = {};
        fields[OPP_ID.fieldApiName] = this.recordId;
        fields[STAGE_CHECKLIST.fieldApiName] = this.selectedOptions.join(';');

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(async () => {
                this.showToast('Success!!', 'Updated successfully!!', 'success', 'dismissable');
                this.showSpinner = false;
                await getRecordNotifyChange([{ recordId: this.recordId }]);
                setTimeout(() => {
                    this.refreshPage();
                }, 2000)

                this.selectedOptions = [];
            })
            .catch(error => {
                this.showToast('Error!!', error.body.message, 'error', 'dismissable');
                this.showSpinner = false;
            });

    }


    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

}