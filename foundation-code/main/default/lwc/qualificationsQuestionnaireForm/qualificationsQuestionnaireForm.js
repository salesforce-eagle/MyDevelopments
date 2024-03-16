import { LightningElement,api,wire,track } from 'lwc';
import getQuestionnaire from '@salesforce/apex/QuestionnaireFormController.getQuestionnaire';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import IS_VISIBLE_QUESTIONNAIRE from '@salesforce/schema/Opportunity.isVisibleQuestionnaire__c';

const questionnaireColumns = [
    {
        label: 'Question',
        fieldName: 'Questionnaire__c',
        type: 'text',
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Response',
        fieldName: 'Answer__c',
        type: 'text',
        editable: true,
        cellAttributes: { alignment: 'left' },
    }
];

export default class QualificationsQuestionnaireForm extends LightningElement {
    
    @api recordId
    @api objectApiName
    @track getQuestionnaireList;
    @track questionnaireList;
    @track draftValues = [];
    @track questionList
    @track error = []
    @track fieldErrors
    @track page = 1
    @track pageSize = 4
    @track totalpage = 0
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track totalRecountCount = 0;
    @track quesRec = []
    questionnaireColumns = questionnaireColumns;
    isVisibleQuestions = 'False'
    
    
    connectedCallback(){
        this.oppRecordId = this.recordId   
        this.objectName = this.objectApiName  
    }
    
    @wire(getRecord, {recordId : '$oppRecordId', fields: IS_VISIBLE_QUESTIONNAIRE })
    opportunity;
    
    
    @wire(getQuestionnaire, {opportunityId:'$oppRecordId'})
    fetchfieldList(result){
        this.getQuestionnaireList = result;
        if(result.data){ 
            let questionList = []
            result.data.forEach(question => {
                let thisQuestion = {}
                if(!question.Answer__c){
                    thisQuestion.Id = question.Id;
                    thisQuestion.Questionnaire__c = question.Questionnaire__c;
                    thisQuestion.Answer__c = question.Answer__c;
                    questionList.push(thisQuestion); 
                }
            })     
            this.isVisibleQuestions = questionList?.length > 0 ? true:false;
            this.displayQuestions(questionList);  
            
            console.log('questionnaireList'+JSON.stringify(this.questionnaireList));
            
        }else{
            this.error = result.error;
            
            this.questionnaireList = undefined;
        }
        refreshApex(this.getQuestionnaireList);
    }
    
    get isVisible() {
        return (getFieldValue(this.opportunity.data, IS_VISIBLE_QUESTIONNAIRE) && this.isVisibleQuestions);
    }
    
    
    
    handleSave(event) {
        
        
        const recordInputs =  event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        
        
        
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        
        Promise.all(promises).then(question => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Updated',
                    variant: 'success'
                })
                );
                this.draftValues = [];
                return refreshApex(this.getQuestionnaireList);
            }).catch(error => {
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
                    title: 'Error',
                    message: this.error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });
            
        }
    
    //Method to display question with defined pageSize
    displayQuestions(questionList) {
        this.quesRec = questionList;
        this.totalRecountCount = questionList.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        console.log('this.totalPage->',this.totalPage);
        this.questionnaireList = this.quesRec.slice(0, this.pageSize);
        this.endingRecord = this.pageSize;
    }
    
    previousHandler() {
        console.log('previousHandler');
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            console.log('previousHandler',this.page);
            this.displayQuestionsPerPage(this.page);
        }
    }
    
    nextHandler() {
        console.log('nextHandler');
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1; //increase page by 1
            console.log('nextHandler',this.page);
            this.displayQuestionsPerPage(this.page);
        }
    }
    
    //Method to display question page by page
    displayQuestionsPerPage(page) {
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord;
        this.questionnaireList = this.quesRec.slice(this.startingRecord, this.endingRecord);
        console.log('displayRecordPerPage ->',this.questionnaireList);
        this.startingRecord = this.startingRecord + 1;
    }
    
    
}