({
	 doLoad : function(component, event) {
        var opportunityId = component.get("v.recordId");
        component.set("v.showSpinner",true);
        var action = component.get("c.getDetails");
        action.setParams({
            oppId : opportunityId
        });
        action.setCallback(this,function(response){
            component.set("v.showSpinner",false);
            var state = response.getState();
            console.log('state '+state);
            if(state === 'SUCCESS'){
                var wrapperInstance = response.getReturnValue();
                component.set("v.hideSaveDelete",wrapperInstance.errorMsgClosedOrFin);
                component.set("v.isGcc",wrapperInstance.isGcc);
                
                console.log('wrapperInstance ',wrapperInstance);
                console.log('WrapperInstance.listOfAdditionGSTIN ',wrapperInstance.listOfAdditionGSTIN);
                 //console.log('WrapperInstance.listOfAdditionGSTIN.length ',wrapperInstance.listOfAdditionGSTIN.length);
                 console.log('wrapperInstance.listOfQLI '+wrapperInstance.listOfQLI);
                if(wrapperInstance.listOfQLI != undefined){
                    var options = [];
                    for(var i=0; i<wrapperInstance.listOfQLI.length; i++){
                        options.push({label: wrapperInstance.listOfQLI[i].Product2.Name ,value: wrapperInstance.listOfQLI[i].Id});
                    }
                    console.log(i+' Option ',options);
                    component.set("v.productOptions", options);
                }
                
                component.set("v.mainWrapper",wrapperInstance);
                console.log('^^ MainWrapper ',component.get("v.mainWrapper"));
                if(wrapperInstance.listOfAdditionGSTIN === undefined || wrapperInstance.listOfAdditionGSTIN === '' || wrapperInstance.listOfAdditionGSTIN === null){
                    console.log('***');
                     /*var newGSTINList;
                    console.log('newGSTINList '+newGSTINList);
                    //Add New GSTIN Record
                     newGSTINList.push({
                        'Id':'',
                        'QuteLineItemId':'',
                        'productId':'',
                        'productName':'',
                        'GSTIN':'',
                        'billingAddrs':'',
                        'amount':''
                    });
                    console.log('*** newGSTINList '+newGSTINList);
                    component.set("v.mainWrapper.listOfAdditionGSTIN", newGSTINList);
                    console.log('** wrapperInstance.listOfAdditionGSTIN ',wrapperInstance.listOfAdditionGSTIN);*/
                }
                console.log('Main Wrapper listOfGSTINs ',component.get("v.mainWrapper.listOfAdditionGSTIN")); 
                console.log('Main Wrapper listOfGSTINs ',component.get("v.mainWrapper.listOfAdditionGSTIN").length); 
            }
        });
        $A.enqueueAction(action);
        component.set("v.showSpinner",false);
    },
    addGSTINRecord: function(component, event) {
        console.log('adding new row');
        //get the GSTIN List from component  
        //var existingGSTINList = component.get("v.mainWrapper.listOfAdtnlGSTIN");
        var existingGSTINList = component.get("v.mainWrapper.listOfAdditionGSTIN");
        //Add New GSTIN Record
        /*existingGSTINList.push({
            'Quote_Line_Item__r.Product2.Name': '',
            'Address__c': '',
            'Name':'',
            'ARR__c' : '',
            'OTP_Integration__c' : '',
            'Quote_Line_Item__c' : '',
            'Quote__c' : ''
        });*/
        existingGSTINList.push({
            'Id':'',
            'QuteLineItemId':'',
            'productId':'',
            'productName':'',
            'GSTIN':'',
            'billingAddrs1':'',
            'amount':'',
            'nameOfTheCustomer':'',
            'billingAddrs2' : '',
            'city' : '',
            'state' : '',
            'pincode' : '',
            'billingPan' : '',
            'tan':'',
            'cin':'',
            'sez' :'',
            'CRNumber' :'',
            'tinNumber' :'',
            'nameOfEntity' : ''
            
        });
        console.log('size: ',existingGSTINList.length);
        console.log('existingGSTINList: ',existingGSTINList);
        /*component.set("v.mainWrapper.listOfAdtnlGSTIN", existingGSTINList);
        console.log('v.mainWrapper.listOfAdtnlGSTIN', component.get("v.mainWrapper.listOfAdtnlGSTIN"));*/
        component.set("v.mainWrapper.listOfAdditionGSTIN", existingGSTINList);
        console.log('v.mainWrapper.listOfAdditionGSTIN', component.get("v.mainWrapper.listOfAdditionGSTIN"));
    },
    saveAdditionalGSTINRecords : function(component, event){
        var listOfGSTINRecords = component.get("v.mainWrapper.listOfAdditionGSTIN");
        component.set("v.showSpinner",true);
        var action = component.get("c.saveDetails");
        action.setParams({
            listOfGstinToUpsertWrapper 	: JSON.stringify(component.get("v.mainWrapper.listOfAdditionGSTIN")),
            listOfGstinToDelete 		: component.get("v.listOfExistingGSTINRecordToDelete"),
            quoteId 					: component.get("v.mainWrapper").quoteID,
            opportunityId 				: component.get("v.recordId"),
            isGCC 						: component.get("v.isGcc")
        });
        action.setCallback(this,function(response){
            component.set("v.showSpinner",false);
            var state = response.getState();
            console.log('state '+state);
            if(state === 'SUCCESS'){
                var errorMsg = response.getReturnValue();
                if(errorMsg != undefined && errorMsg != '' && errorMsg != null){
                    this.showToastMessage(component, event, errorMsg,"Error","Error");
                    return;
                }
                this.showToastMessage(component, event, 'Saved Succesfully',"Success","Success");
                component.set("v.displayCompanyInfo",true);
                //this.closeTheModal();
            }else{
                console.log('Error');
                this.showToastMessage(component, event, 'Error in saving the records. Please Contact Admin',"Error","Error");
            }
        });
        $A.enqueueAction(action);
        component.set("v.showSpinner",false);
        
    },
    showToastMessage : function(component, event, msg, typeName, titleName){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": typeName,
            "title" : titleName,
            "message": msg
        });
        toastEvent.fire();
    },
    closeTheModal :  function(component, event){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})