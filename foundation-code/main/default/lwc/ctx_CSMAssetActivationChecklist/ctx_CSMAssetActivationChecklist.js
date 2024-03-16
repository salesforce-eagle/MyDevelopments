import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getRelatedTasks from '@salesforce/apex/CTX_CSMJourneyHandler.getRelatedTasks';
import updateTask from '@salesforce/apex/CTX_CSMJourneyHandler.updateTask';
import { updateRecord } from 'lightning/uiRecordApi';
import STATUS_OF_CUSTOMER from '@salesforce/label/c.CTX_Status_Of_Customer';
import {NavigationMixin} from 'lightning/navigation';

export default class Ctx_CSMAssetActivationChecklist extends NavigationMixin(LightningElement) {
    @api recordId;
    //@track tasksList = [];
    @track tasksList =[];
    /*@wire(getRelatedTasks, { recordId: '$recordId' })
    wiredgetTasksList(result) {
        for(result){

        }
        this.tasksList = result;
    }*/
    @api taskRecordType;
    @api stageName;
    taskId;
    showModal = false;
    showSpinner = false;
    renderOnce = false;
    healthCheckFields = ['Status_Of_Completion__c','Description'];
    statusOfCustomer;
    statusOfCustomerOptions;
    @track filesToUpload = [];

    connectedCallback() {
        if(this.taskRecordType.includes('Health Check')){
            this.statusOfCustomerOptions = STATUS_OF_CUSTOMER.split(',').map(item => {
                return { label: item, value: item };
            });
        }
        this.getTasks();
    }

    getTasks() {
        getRelatedTasks({ recordId: this.recordId, taskRecordTypeName : this.taskRecordType })
            .then(result => {
                this.tasksList = result.map(item => {
                    let isCompleted = item.Status === 'Completed' ? true : false;
                    return { isCompleted: isCompleted, data: item };
                })

                console.log(result);
            })
            .catch(error => {
                console.log(error);
            })
    }

    get title(){
        return this.stageName + ' Checklist'; 
    }

    handleOpenModal(event) {
        this.taskId = event.target.dataset.id;
        this.showModal = true;
        setTimeout(this.addEventListners.bind(this), 1000);
    }

    handleCompleteTask() {
        const element = this.template.querySelectorAll(`[data-id="form"]`);
        const isValid = [...element].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);


        if (isValid) {
            console.log(JSON.stringify(element));
            this.showSpinner = true;
            const taskId = this.taskId;
            let taskObject = new Object();
            taskObject.Id = this.taskId;
            taskObject.Status = 'Completed';
            element.forEach(item=>{
                taskObject[item.dataset.field] = item.value;
            });
            //const comments = element[0].value
            updateTask({ taskId: taskId, taskObject : taskObject, fileDetails : this.filesToUpload})
                .then(result => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Task Marked Completed!',
                            variant: 'success'
                        })
                    );
                    // Display fresh data in the form
                    this.closeModal();
                    this.getTasks();
                    this.showSpinner = false;
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    this.showSpinner = false;
                });
        }
    }

    handleFilesChange(event){
        let files = event.target.files;

        if (files.length > 0) {
            this.filesSelect(files);
            
        }
    }

    filesSelect(files){
        for (let i = 0; i < files.length; i++) {
            let file = files[i];

            let freader = new FileReader();
            freader.onload = f => {
                let base64 = 'base64,';
                let content = freader.result.indexOf(base64) + base64.length;
                let fileContents = freader.result.substring(content);
                this.filesToUpload.push({
                    Title: file.name,
                    VersionData: fileContents
                });
            };
            freader.readAsDataURL(file);
        }
    }

    handleRemoveFile(event){
        let fileName = event.target.dataset.id;
        this.filesToUpload = this.filesToUpload.filter(item => item.Title !== fileName);

    }

    navigateToAttchments(event){
        const recordId = event.target.dataset.id;
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Task',
                relationshipApiName: 'AttachedContentDocuments',
                actionName: 'view'
            },
        });
    }

    get isEmptyTaskList() {
        return this.tasksList.length > 0 ? false : true;
    }

    get isHealthCheckTask() {
        return this.taskRecordType.includes('CSM Health Check') ? true : false;
    }

    closeModal(){
        this.showModal = false;
        this.taskId = '';
    }

    handleFileDrop(event){
        let files = event.dataTransfer.files;
        console.log(files)
        if(files.length > 0){
            this.filesSelect(files);
        }
        this.handleDragLeave(event);
    }

    handleDragOver(event){
        this.template.querySelector('[data-id="fileSelector"]').classList.add('background');
        event.preventDefault();
        event.stopPropagation();
    }

    handleDragLeave(event){
        this.template.querySelector('[data-id="fileSelector"]').classList.remove('background');
        event.preventDefault();
        event.stopPropagation();
    }

    addEventListners(){
        let dropArea = this.template.querySelector('[data-id="fileSelector"]');
        dropArea.addEventListener('drop', this.handleFileDrop.bind(this));
        dropArea.addEventListener('dragover', this.handleDragOver.bind(this));
        ['dragenter', 'dragleave'].forEach(eventName => {
            dropArea.addEventListener(eventName, this.handleDragLeave.bind(this));
        })
    }
}