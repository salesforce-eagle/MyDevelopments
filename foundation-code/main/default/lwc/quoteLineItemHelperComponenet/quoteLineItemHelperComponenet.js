import { LightningElement, wire, api, track } from 'lwc';
import fetchidentitydata from '@salesforce/apex/CTX_MetadataRetriveUtility.getResourceConstraintMetadataDetailsByFieldAPI';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import {CurrentPageReference} from 'lightning/navigation';
import hasSuperAccess from '@salesforce/customPermission/Identity_Super_Access';

const FIELDS_METADATA = ['QuoteLineItem.Identity_Resource_Metadata__c'];
const COLS = [
    { label: 'Field Name', fieldName: 'labelname', wrapText: true, initialWidth: 320,hideDefaultActions: true },//320 - without permission, with permission - 320
    { label: 'Description', fieldName: 'description', wrapText: true, initialWidth: {fieldName: 'controlWidthFieldforDescription'},hideDefaultActions: true },//502- without permission, with permission - 362
    { label: 'Threshold', fieldName: 'count', editable: true, wrapText: true, initialWidth: 113,hideDefaultActions: true },//113- without permission, with permission - 113
    { label: 'Unit List Price', fieldName: 'perUnitListPrice', editable: true, wrapText: true, initialWidth: 118,hideDefaultActions: true },//118- without permission, with permission - 118
    { label: 'Unit Sell Price', fieldName: 'perUnitSellPrice', editable: true, wrapText: true, initialWidth: 122,hideDefaultActions: true },//122- without permission, with permission - 122
    { label: 'Unit Cost Price', fieldName: 'perUnitCostPrice', editable: true, wrapText: true, initialWidth: 136,hideDefaultActions: true },//- without permission, with permission - 136
];
export default class QuoteLineItemHelperComponenet extends LightningElement {
    @track isShowModal = false;
    @track filetabledata = [];
    recordId;
    records;
    columndata;
    maindata;
    i = 0;
    planTier ='CLEAR_IDENTITY_STANDARD';
    @track idAplicacion;
    @track columns;
   // columns = COLS;
    @track draftValues = [];
    @track demodata = [];
    @track getIdentitydata = [];
    @track info2 = [];
    isLoading = false;
    showButtom = false;
    @track qliRecordid;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
    if (currentPageReference) {
        
        this.recordId = currentPageReference.attributes.recordId;
        console.log('insdie current page',this.recordId);
    }
}

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS_METADATA })
    getMetadataConstarintsRecord({ data, error }) {
        if (data) {
           if(data.fields.Identity_Resource_Metadata__c.value){
            this.qliRecordid = this.recordId;
            console.log('inside wire 1.o', JSON.stringify(data));
            this.idAplicacion = data.fields.Identity_Resource_Metadata__c.value;
            this.getIdentitydata.push(this.idAplicacion);
            let apiInfo = this.idAplicacion?.replace(/[{}"]/g, '');
            this.info2 = apiInfo.split(',');
            if (hasSuperAccess) {
                this.columns = [...COLS];
            } else {
                // return every column but the one you want to hide
                this.columns = [...COLS].filter(COLS => COLS.fieldName != 'perUnitCostPrice');
            }
            this.getdata();
            
       } else if (error) {
        this.showButtom = false;
      }
    }
    else{
    console.log('Error in first wire',JSON.stringify(error));
    console.log('Error recoid',this.recordId);
    }
    }
getdata(){
    fetchidentitydata({ planTier:this.planTier})
            .then(data => {
                if (data && this.info2.length > 0) {
                    this.demodata = [];
                    let mainda = [];
                    mainda.push(data);
                    this.columndata = data;
                    let i = 0;
                    let l = 0;
                    this.filetabledata = [];
                    for (let q = 0; q < this.info2.length/4; q++) {
                        var tempdata = {};
                        var tempdataformap = {};
                        var isShow = false;
                        for (let j = 0; j < 4; j++) {

                            if (this.info2[i]) {
                                if (j == 0) {
                                    console.log('in +',j);
                                    let dem = this.info2[i].split(':');
                                    tempdata.count = parseFloat(dem[2]);
                                    tempdataformap.count = parseFloat(dem[2]);
                                    tempdata.identityname = dem[0].replace(/\[/g, '');
                                    let str = tempdata.identityname.trim();
                                    tempdata.labelname = mainda[0][str].Metadata_Title__c;
                                    tempdata.description = mainda[0][str].Description__c;
                                    if(mainda[0][str].isVisible__c == true){
                                        isShow = true;
                                    }
                                    else{
                                        isShow = false;
                                    }
                               
                                }
                                if (j == 1) {
                                    let dem = this.info2[i].split(':');
                                    tempdata.perUnitListPrice = parseFloat(dem[1]);
                                    tempdataformap.perUnitListPrice = parseFloat(dem[1]);
                                }
                                if (j == 2) {
                                    let dem = this.info2[i].split(':');
                                    tempdata.perUnitSellPrice = parseFloat(dem[1]);
                                    tempdataformap.perUnitSellPrice = parseFloat(dem[1]);
                                }
                                if (j == 3) {
                                    let dem = this.info2[i].split(':');
                                    tempdata.perUnitCostPrice = parseFloat(dem[1]);
                                    tempdataformap.perUnitCostPrice = parseFloat(dem[1]);
                                }
                               // tempdata.identityname = element;
                            }
                            i++;
                        }
                        if (hasSuperAccess) {
                            tempdata.controlWidthFieldforDescription = 362;
                        } else {
                            tempdata.controlWidthFieldforDescription = 502;
                        }
                        if(isShow){
                            this.filetabledata.push(tempdata);
                        }
                        var demo = {
                            [tempdata.identityname]: tempdataformap,
                        };
                        this.demodata.push(demo);
                        l++;
                    }
                    
                    this.showButtom = true;

                    console.log('get this.demodata' + JSON.stringify(this.demodata));
                }
            })
            .catch(error => {
                // Handle errors if any
                this.showButtom = true;
                console.log('Error calling Apex: ', JSON.stringify(error));
            });
}


    renderedCallback() {
        if (this.isShowModal) {
            const modalContainer = this.template.querySelector('.slds-modal__container');
            if (modalContainer) {
                modalContainer.style.width = '100%';
                modalContainer.style.maxWidth = '1300px';
                modalContainer.style.height = '100%';
                modalContainer.style.maxHeight = '900px';
            }
        }
    }
    connectedCallback() {}
    showModalBox() {
        console.log('data from showModalBox ', JSON.stringify(this.maindata));
        this.isShowModal = true;
    }
    hideModalBox() {
        this.isShowModal = false;
    }
    handleSave(event) {
        console.log('event.detail.draftValues: ' + JSON.stringify(event.detail.draftValues));
        console.log('event.detail.draftValues: detail' + JSON.stringify(event.detail));
        console.log('event.detail.draftValues: event' + JSON.stringify(event));
        console.log('get this.demodata 1' + JSON.stringify(this.demodata));
        console.log('get this.demodata lenght' + this.demodata.length);
        this.isLoading = true;
        let draftdata = event.detail.draftValues;
        console.log('get draftdata lenght' + draftdata.length);
        let mainstring = '';
        if (this.demodata.length > 0) {
            draftdata.forEach((acc) => {
                let va = acc.identityname;
                for (let i = 0; i < this.demodata.length; i++) {
                    if (this.demodata[i].hasOwnProperty(va)) {
                        if (acc.hasOwnProperty('count')) {
                            this.demodata[i][va].count = parseFloat(acc.count);
                        }
                        if (acc.hasOwnProperty('perUnitListPrice')) {
                            this.demodata[i][va].perUnitListPrice = parseFloat(acc.perUnitListPrice);
                        }
                        if (acc.hasOwnProperty('perUnitSellPrice')) {
                            this.demodata[i][va].perUnitSellPrice = parseFloat(acc.perUnitSellPrice);
                        }
                        if (acc.hasOwnProperty('perUnitCostPrice')) {
                            this.demodata[i][va].perUnitCostPrice = parseFloat(acc.perUnitCostPrice);
                        }
                    } else {
                        console.log('this.demodatainside else');
                    }
                }
            });
            for (let i = 0; i < this.demodata.length; i++) {
                mainstring = mainstring + JSON.stringify(this.demodata[i]) + ',';
            }
            mainstring = mainstring?.replace(/,\s*$/, '');
            let arr =[];
            arr.push(mainstring);
            let da = '['+mainstring+']';
            console.log('demo data after da', da);
            const fields = {};
            fields['Id'] = this.recordId;
            //fields['Identity_Resource_Metadata__c'] = mainstring;
            fields['Identity_Resource_Metadata__c'] = da;
            
            console.log('da',da);
            console.log('da stringfy',JSON.stringify(da));
            const recordInput = { fields };
            updateRecord(recordInput)
                .then(() => {
                    console.log('after update',recordInput);
                    console.log('after update string',JSON.stringify(recordInput));
                    this.hideModalBox();
                    this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record updated',
                            variant: 'success',
                        })
                    );
                    refreshApex(this.getMetadataConstarintsRecord);
                })
                .catch((error) => {
                    console.error('demodata array is empty',error);
                    this.hideModalBox();
                    this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating record',
                            message: error.body.message,
                            variant: 'error',
                        })
                    );
                });
        } else {
            console.error('demodata array is empty');
        }
    }
}