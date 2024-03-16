import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import fetchidentitydata from '@salesforce/apex/CTX_MetadataRetriveUtility.getResourceConstraintMetadataDetailsByFieldAPI';
import {CurrentPageReference} from 'lightning/navigation';
import hasSuperAccess from '@salesforce/customPermission/Identity_Super_Access';
import hasEditAccess from '@salesforce/customPermission/Identity_Threshold_Edit_Access';

const FIELDS_METADATA = ['Asset.Identity_Resource_Constraints__c'];//editable: {fieldName: 'controlEditField'}, 
const COLS = [
    { label: 'Field Name', fieldName: 'labelname', wrapText: true, initialWidth: 320,hideDefaultActions: true },//320 - without permission, with permission - 320
    { label: 'Description', fieldName: 'description', wrapText: true, initialWidth: {fieldName: 'controlWidthFieldforDescription'},hideDefaultActions: true },//502- without permission, with permission - 362
    { label: 'Threshold', fieldName: 'count', editable: {fieldName: 'controlEditField'}, wrapText: true, initialWidth: 113,hideDefaultActions: true },//113- without permission, with permission - 113
    { label: 'Unit List Price', fieldName: 'perUnitListPrice', editable: {fieldName: 'controlEditField'}, wrapText: true, initialWidth: 118,hideDefaultActions: true },//118- without permission, with permission - 118
    { label: 'Unit Sell Price', fieldName: 'perUnitSellPrice', editable: {fieldName: 'controlEditField'}, wrapText: true, initialWidth: 122,hideDefaultActions: true },//122- without permission, with permission - 122
    { label: 'Unit Cost Price', fieldName: 'perUnitCostPrice', editable: {fieldName: 'controlEditField'}, wrapText: true, initialWidth: 136,hideDefaultActions: true },//- without permission, with permission - 136
];
export default class AssetIdentityFieldHelperButtonComponent extends LightningElement {
    @track isShowModal = false;
    @track filetabledata = [];
    recordId;
    
    records;
    planTier ='CLEAR_IDENTITY_STANDARD';
    columndata;
    @track idAplicacion;
    columns = COLS;
    @track draftValues = [];
    @track info2 = [];
    @track demodata = [];
    @track initialRecords = [];
    @track data1;
    isLoading = false;
    showButtom = false;

   /* get isRunReport() {
        return hasPermission;
    }*/

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
    if (currentPageReference) {
        this.recordId = currentPageReference.state.recordId;
    }
}

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS_METADATA })
    getMetadataConstarintsRecord({ data, error }) {
        if (data) {
            this.isLoading = true;
           if(data.fields.Identity_Resource_Constraints__c.value){
           // this.filetabledata=[];
            this.idAplicacion = data.fields.Identity_Resource_Constraints__c.value;
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
        this.isLoading = false;
      }
    }
    else{
        console.log('Error',JSON.stringify(error));
        console.log('Error inside id',this.recordId);
        this.isLoading = false;
    }
    }

    getdata(){
        this.filetabledata=[];
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
                                let dem = this.info2[i].split(':');
                                tempdata.count = parseInt(dem[2]);
                                tempdataformap.count = parseInt(dem[2]);
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
                                tempdata.perUnitListPrice = parseInt(dem[1]);
                                tempdataformap.perUnitListPrice = parseInt(dem[1]);
                            }
                            if (j == 2) {
                                let dem = this.info2[i].split(':');
                                tempdata.perUnitSellPrice = parseInt(dem[1]);
                                tempdataformap.perUnitSellPrice = parseInt(dem[1]);
                            }
                            if (j == 3) {
                                let dem = this.info2[i].split(':');
                                tempdata.perUnitCostPrice = parseInt(dem[1]);
                                tempdataformap.perUnitCostPrice = parseInt(dem[1]);
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
                    
                    if (hasEditAccess) {
                        tempdata.controlEditField = true;
                    } else {
                        tempdata.controlEditField = false;
                    }
                    var demo = {
                        [tempdata.identityname]: tempdataformap,
                    };
                    if(isShow){
                        this.filetabledata.push(tempdata);
                    }
                    this.data1 = [...this.filetabledata];
                    this.initialRecords = [...this.filetabledata];
                    this.demodata.push(demo);
                    l++;
                } 
            this.isLoading = false;
            this.showModalBox();
            this.showButtom = true;

            }
        })
        .catch(error => {
            this.isLoading = false;
            // Handle errors if any
            this.showButtom = true;
            console.error('Error calling Apex: ', JSON.stringify(error));
        });
    }

    handleSearch(event){

        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            this.data1 = this.initialRecords;
            if (this.data1) {
                let searchRecords = [];
                for (let record of this.data1) {
                    let valuesArray = Object.values(record);
                    for (let val of valuesArray) {
                        let strVal = String(val);
                        if (strVal) {
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
                this.data1 = searchRecords;
                this.filetabledata = [];
                this.filetabledata = [...this.data1];
            }
        } else {
            this.data1 = this.initialRecords;
            this.filetabledata = [];
            this.filetabledata = [...this.data1];
        }
    }

    renderedCallback() {
            const STYLE = document.createElement("style");
            STYLE.innerText = '.uiModal--horizontalForm .modal-container{ width: 100% !important; max-width: 1300px !important; height: 100% !important; max-height: 900px !important;}' ;
            this.template.querySelector('lightning-card').appendChild(STYLE);
           
        
    }
    connectedCallback() {}
    showModalBox() {
        this.isShowModal = true;
    }
    hideModalBox() {
       // this.isShowModal = false;
       this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleSave(event) {
        this.isLoading = true;
        let draftdata = event.detail.draftValues;
        let mainstring = '';
        if (this.demodata.length > 0) {
            draftdata.forEach((acc) => {
                let va = acc.identityname;
                for (let i = 0; i < this.demodata.length; i++) {
                    if (this.demodata[i].hasOwnProperty(va)) {
                        if (acc.hasOwnProperty('count')) {
                            this.demodata[i][va].count = parseInt(acc.count);
                        }
                        if (acc.hasOwnProperty('perUnitListPrice')) {
                            this.demodata[i][va].perUnitListPrice = parseInt(acc.perUnitListPrice);
                        }
                        if (acc.hasOwnProperty('perUnitSellPrice')) {
                            this.demodata[i][va].perUnitSellPrice = parseInt(acc.perUnitSellPrice);
                        }
                        if (acc.hasOwnProperty('perUnitCostPrice')) {
                            this.demodata[i][va].perUnitCostPrice = parseInt(acc.perUnitCostPrice);
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

           
            const fields = {};
            fields['Id'] = this.recordId;
            fields['Identity_Resource_Constraints__c'] = da;
            
            const recordInput = { fields };
            updateRecord(recordInput)
                .then(() => {
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