import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchRelatedWorkspaces from "@salesforce/apex/CTX_AssetWorkspaceLinkageController.fetchRelatedWorkspaces";
import deleteSelectedWorkspaceJunctions from "@salesforce/apex/CTX_AssetWorkspaceLinkageController.deleteSelectedWorkspaceJunctions";

export default class Ctx_DeleteAssetWorkspaceLink extends LightningElement {
    @api recordId;
    @track workspaceList = [];
    renderOnce = false;
    showSpinner = false;
    isDisplay = false;

    isError = false;
    errorMessage;

    connectedCallback(){
        this.showSpinner = true;
    }

    renderedCallback() {
        if (this.recordId) {
            if (!this.renderOnce) {
                fetchRelatedWorkspaces({ assetId: this.recordId })
                    .then(result => {
                        result.forEach(item => {
                                item.isSelected = false;
                                this.workspaceList.push(item);
                            
                        });

                        this.isDisplay = true;
                        this.showSpinner = false;
                        
                    })
                    .catch(error => {
                        // const evt = new ShowToastEvent({
                        //     title: 'Error',
                        //     message: error.body.message,
                        //     variant: 'error',
                        //     mode: 'dismissable'
                        // });
                        // this.dispatchEvent(evt);
                        this.isDisplay = true;
                        this.showSpinner = false;

                        this.setError(true, error.body.message);
                    })
                this.renderOnce = true;
            }
        }
    }

    selectWorkspace(event) {
        let dataId = event.target.dataset.id;

        this.workspaceList[parseInt(dataId)].isSelected = event.target.checked; 

        
    }

    deleteWorkSpacesLinks() {
        this.closeError();
        let junctionsToDelete = [];

        this.workspaceList.forEach(item => {
            if(item.isSelected){
                junctionsToDelete.push(item);
            }
        })

        if(junctionsToDelete.length < this.workspaceList.length){
            if(junctionsToDelete.length > 0){
                this.showSpinner = true;
                deleteSelectedWorkspaceJunctions({ assetId: this.recordId, junctionsToDelete: junctionsToDelete})
                    .then(result => {
                        const evt = new ShowToastEvent({
                             title: 'Success',
                             message: 'Details Updated Successfully !!!',
                             variant: 'success',
                             mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        this.closeQuickAction();
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        // const evt = new ShowToastEvent({
                        //     title: 'Error',
                        //     message: error.body.message,
                        //     variant: 'error',
                        //     mode: 'dismissable'
                        // });
                        // this.dispatchEvent(evt);
                        this.showSpinner = false;
    
                        this.setError(true, error.body.message);
                    })
            } else {
                this.setError(true, 'Kindly Select a Workspace to remove.');
            }
        } else {
            this.setError(true, 'Can not remove all workspaces. At least on Workspace should be associated with a License.');
        }
    }


    closeQuickAction() {
        this.dispatchEvent(new CustomEvent('closeaction'));
    }

    get isEmptyWorkspaces() {
        return this.workspaceList.length === 0 ? true : false;
    }

    closeError(){
        this.setError(false, '');
    }

    setError(isError, errorMessage){
        this.isError        = isError;
        this.errorMessage   = errorMessage;
    }
}