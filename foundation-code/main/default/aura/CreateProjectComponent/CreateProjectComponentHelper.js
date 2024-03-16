({
    getAllSIPartners : function(component,event,helper){
        var  action=component.get("c.getSIPartner");
        var recordId=component.get("v.recordId");
        var recordTypeName = 'SI Partner';
        
        action.setParams({
            "orderId" : recordId ,
            "optionRecordTypeName" : recordTypeName
        });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            var responseResult=response.getReturnValue();
            if(state==='SUCCESS'){
                component.set("v.listOfAccounts",responseResult);
                //if(component.get('v.value')==='SI Partner'){
                    component.set("v.listOfAccounts",responseResult);
                    console.log(JSON.stringify(component.get("v.listOfAccounts")));
                //}
                console.log(JSON.stringify(component.get("v.listOfSIPartners")));
                //var closeQuickAction=$A.get("e.force:closeQuickAction");
                //closeQuickAction.fire();
            }else if(state==='ERROR'){
                
            }
            
        });
        $A.enqueueAction(action);
    },
    getExperties : function(component,event,helper){
        //alert('Loading.....');
        var action=component.get("c.getExperties");
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                var result=response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.experties", fieldMap);

            }else if (state==='ERROR'){
                console.log('Failed To Get the Values');
                console.log('Failed to load ');
            }
        });
        $A.enqueueAction(action);
        //helper.onExpertiesChange(component,event,helper);
    },
    handleSaveClick : function(component, event, helper) {
       
        var  action=component.get("c.getSIPartner");
        var recordId=component.get("v.recordId");
        var recordTypeName='';
        console.log(JSON.stringify(component.get('v.value')));
        console.log(component.get('v.value') !== "");
        if(component.get('v.value') !== null && component.get('v.value') !== "" ){
            component.set("v.radioButtionDisable",'true');
            component.set("v.SubmitButtonDisable",'true');
            if(component.get('v.value')==='SI Partner'){
                var recordTypeName = component.get('v.value');
                component.set("v.showSEForProject",true);
                component.set("v.showSIPartnerAccounts",false);
                component.set("v.isSIPartner",true);
                component.set("v.showRadion",false);
            }else if(component.get('v.value')==='Development in House'){
                component.set("v.showSIPartnerAccounts",false);
                component.set("v.isSIPartner",false);
                component.set("v.showRadion",false);
                component.set("v.showDevelopmentInHouse",true);
            }else if(component.get('v.value')==='AMC'){
                component.set("v.displayNonAmcFields",false);
                component.set("v.showDevelopmentInHouse",true);
                component.set("v.showSIPartnerAccounts",false);
                component.set("v.isSIPartner",false);
                component.set("v.showRadion",false);
            }else{
                component.set("v.showSIPartnerAccounts",false);
                component.set("v.isSIPartner",false);
                component.set("v.showRadion",false);
                component.set("v.showDevelopmentInHouse",true);
            }
            
            action.setParams({
                "orderId" : recordId ,
                "optionRecordTypeName" : recordTypeName
            });
            
            action.setCallback(this,function(response){
                var state=response.getState();
                var responseResult=response.getReturnValue();
                if(state==='SUCCESS'){
                    component.set("v.listOfAccounts",responseResult);
                    if(component.get('v.value')==='SI Partner'){
                        component.set("v.listOfSIPartners",responseResult);
                        console.log(JSON.stringify(component.get("v.listOfSIPartners")));
                        //alert(JSON.stringify(component.get("v.listOfAccounts")));
                    }
                    //alert(JSON.stringify(component.get("v.listOfSIPartners")));
                    //var closeQuickAction=$A.get("e.force:closeQuickAction");
                    //closeQuickAction.fire();
                }else if(state==='ERROR'){
                    
                }
                
            });
            $A.enqueueAction(action);
        }else{
            //alert('Your in handleProjectSubmit'+JSON.stringify(row.get("v.text")));
			helper.showError(component, event, helper , ' Please Select the Type of Project...! ');
        }
         helper.getSENameFROMAccount(component, event, helper);
    },getSENameFROMAccount : function(component, event, helper){
         var action = component.get("c.getSEUserFROMAccountCustomerLevel");
           action.setParams({
                "orderId" : component.get("v.recordId") ,
            });
            
            action.setCallback(this,function(response){
                var state=response.getState();
                var responseResult=response.getReturnValue();
                if(state==='SUCCESS'){
                    component.set("v.OrderInstance",responseResult);
                    //if(component.get('v.value')==='SI Partner'){
                        console.log(responseResult);
                        var userName=responseResult.Account.SE_User__r;
                        component.set("v.customerAccountName",userName.Name);
                        //console.log(JSON.stringify(component.get("v.customerAccountName")));
                   // }
                    //alert(JSON.stringify(component.get("v.listOfSIPartners")));
                    //var closeQuickAction=$A.get("e.force:closeQuickAction");
                    //closeQuickAction.fire();
                }else if(state==='ERROR'){
                    
                }
            });
            $A.enqueueAction(action);
        
    },
    handleProjectSubmit : function(component, event, helper) {
    	console.log('Your in handleProjectSubmit');
        var row=component.find("rowSelectionCheckboxId");
        debugger;
        if(Array.isArray(row)){
            row.forEach(function(rs){
                if(rs.get("v.value"))
                {
                    console.log('Your in handleProjectSubmit'+JSON.stringify(rs.get("v.text").Id));
                    var selectedSIPartnerRecordId=rs.get("v.text").Id;
                    component.set("v.selectedSIPartnerRecordId",selectedSIPartnerRecordId);
                    var action=component.get("c.getOrderAndAssetsBySIPartnerAccountId");
                    if(selectedSIPartnerRecordId !== "" && selectedSIPartnerRecordId!== null){
                        action.setParams({
                            "siPartnerAccountrecordId" : selectedSIPartnerRecordId,
                            "orderId" : component.get("v.recordId")
                        });
                        action.setCallback(this,function(response){
                            var state=response.getState();
                            if(state==='SUCCESS'){
                                var listOfAssets=response.getReturnValue();
                                debugger;
                                if(listOfAssets!== null ){
                                    if(listOfAssets.length>0){
                                        component.set("v.listOfRelatedIntegrationAssets",listOfAssets);
                                        console.log(JSON.stringify(listOfAssets));                                
                                    }
                                }
                            }else if(state==='ERROR'){
                                
                            }
                        });
                        $A.enqueueAction(action);
                        component.set("v.showSIPartnerAccounts",false);
                        component.set("v.showIntegrationAssets",true);
                    } 
                }else{
                   // helper.showError(component, event, helper , ' Please Select the SI Partner...!')
                }
            })
        }else{
            if(row.get("v.value"))
            {
                console.log('Your in handleProjectSubmit'+JSON.stringify(row.get("v.text").Id));
                var selectedSIPartnerRecordId=row.get("v.text").Id;
                component.set("v.selectedSIPartnerRecordId",selectedSIPartnerRecordId);
                var action=component.get("c.getOrderAndAssetsBySIPartnerAccountId");
                if(selectedSIPartnerRecordId !== "" && selectedSIPartnerRecordId!== null){
                    action.setParams({
                        "siPartnerAccountrecordId" : selectedSIPartnerRecordId,
                        "orderId" : component.get("v.recordId")
                    });
                    action.setCallback(this,function(response){
                        var state=response.getState();
                        if(state==='SUCCESS'){
                            var listOfAssets=response.getReturnValue();
                            debugger;
                            if(listOfAssets!== null ){
                                if(listOfAssets.length>0){
                                    component.set("v.listOfRelatedIntegrationAssets",listOfAssets);
                                    console.log(JSON.stringify(listOfAssets));                                
                                }
                            }
                        }else if(state==='ERROR'){
                            
                        }
                    });
                    $A.enqueueAction(action);
                    component.set("v.showSIPartnerAccounts",false);
                    component.set("v.showIntegrationAssets",true);
                } 
            }
        }
    },
    getSIAccountsBasedOnExperties : function (component, event, helper){
        //alert('Your in getSIAccountsBasedOnExperties');
    },
    changeOfFilterValues : function(component, event, helper){
       // alert('Your in changeOfFilterValues');
    },
    onInputValueChange :  function(component, event, helper){
        //alert('Your are inside InputValuesCHnage');
    },
    onExpertiesChange : function(component, event, helper){
       //alert('Your are inside onExpertiesChange'+component.get('v.selectedValue'));
       //alert('Your are inside selected'+event.getSource().get("v.selectedValue"));
        var action=component.get("c.getSIPartnerBasedonFilter");
        var selectedValue=component.get("v.selectedValue");
        debugger;
        if(selectedValue!==null){
            action.setParams({
                "experties": selectedValue,
                "noOfActiveProjects": null,
                "city": null,
                "region":null
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state==='SUCCESS'){
                    debugger;
                    var result = response.getReturnValue();
                    component.set("v.listOfAccounts",result);
                    //console.log(result[0].Name);
                }else if(state==='ERROR'){
                    
                }
            });
            $A.enqueueAction(action);
        }else if(selectedValue === '--None--'){
            action.setParams({
                "orderId" : recordId ,
                "optionRecordTypeName" : recordTypeName
            });
            
            action.setCallback(this,function(response){
                var state=response.getState();
                var responseResult=response.getReturnValue();
                if(state==='SUCCESS'){
                    component.set("v.listOfAccounts",responseResult);
                    if(component.get('v.value')==='SI Partner'){
                        component.set("v.listOfSIPartners",responseResult);
                        console.log(JSON.stringify(component.get("v.listOfAccounts")));
                    }
                    console.log(JSON.stringify(component.get("v.listOfSIPartners")));
                    //var closeQuickAction=$A.get("e.force:closeQuickAction");
                    //closeQuickAction.fire();
                }else if(state==='ERROR'){
                    
                }
                
            });
            $A.enqueueAction(action);
        }
    },
    onNumberInputChange :  function(component, event, helper){
         //alert('Your are inside onNumberInputChange');
        var action=component.get("c.getSIPartnerBasedonFilter");
        var numberValue=component.get("v.numberInputvalue");
        if(!(numberValue>0)){
            numberValue=null;
        }
        action.setParams({
            "experties": null,
            "noOfActiveProjects": numberValue,
            "city": null,
            "region":null
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.listOfAccounts",result);
            }else if(state==='ERROR'){
                
            }
        });
        $A.enqueueAction(action);

    },
    onRegionInputChange :function(component,event,helper){
		// alert('Your are inside onRegionInputChange');
		var action=component.get("c.getSIPartnerBasedonFilter");
        var region=component.get("v.Regioninputvalue");
		action.setParams({
            "experties": null,
            "noOfActiveProjects": null,
            "city": null,
            "region":region
            });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.listOfAccounts",result);
            }else if(state==='ERROR'){
                
            }
        });
        $A.enqueueAction(action);
    },
    onCityInputChange :   function(component,event,helper){
		//alert('Your are inside onCityInputChange');
		var action=component.get("c.getSIPartnerBasedonFilter");
        var city=component.get("v.Cityinputvalue");
		action.setParams({
            "experties": null,
            "noOfActiveProjects": null,
            "city": city,
            "region":null
            });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.listOfAccounts",result);
            }else if(state==='ERROR'){
                
            }
        });
        $A.enqueueAction(action);
    },handleOnSave :   function(component,event,helper){
        
        var row=component.find("rowSelectionOrderCheckboxId");
        console.log('row Information==>'+row);
        if( row!=null && row!=undefined){
            component.set("v.disableSave",true);
            component.set("v.showProjectSelectionDialog",true);
        }else{
            helper.showError(component, event, helper , 'Please Select atleast once Integration Asset');
        }
        
    },handleConfirmDialogYes :   function(component,event,helper){
		component.set("v.showIntegrationAssets",false);
        
        component.set("v.showProjectRecordInformation",true);
        
        component.set('v.showProjectSelectionDialog', false);
    },handleConfirmDialogNo :   function(component,event,helper){
        
        console.log('handleConfirmDialogNo'+component.get("v.ShowExistingProjects"));
        component.set("v.showIntegrationAssets",false);
        component.set("v.ShowExistingProjects",true);
        console.log(component.get("v.ShowExistingProjects"));
        console.log( 'handleConfirmDialogNo' +component.get("v.ShowExistingProjects"));        
        component.set('v.showProjectSelectionDialog', false);
       
    },onOrderCheckboxChange : function(component,event,helper){
        //alert('reached 1');
        var row=component.find("rowSelectionOrderCheckboxId");
        //alert(Array.isArray(row));
        var selectedAssetRecord=[];	
        if(Array.isArray(row)){
            row.forEach(function(rs){
                console.log(rs.get("v.value"));
                if(rs.get("v.value")){
                    selectedAssetRecord.push(rs.get("v.text"));
                    console.log(JSON.stringify(selectedAssetRecord));
                }
                
            });
        }else{
            if(row.get("v.value")){
                selectedAssetRecord.push(row.get("v.text"));
                console.log(JSON.stringify(selectedAssetRecord));
            }
        }
        if(selectedAssetRecord.length>0){
            component.set("v.listOfSelectedRows",selectedAssetRecord);
            console.log('********listOfSelectedRows********'+JSON.stringify(component.get("v.listOfSelectedRows")));
        }   
    },handleonSaveProject : function(component,event,helper){
        var existingProjectId = '';
        if(component.get("v.selectedProjectLookUpRecord").Id != undefined){
            existingProjectId = component.get("v.selectedProjectLookUpRecord").Id;
        } 
		
        var nameOfProject='';
        if(component.get("v.isSIPartner")){
            nameOfProject=' SI Partner Project';
        }else{
            nameOfProject=' Dev In House Or Consultent Only';
        }
        
        var action=component.get("c.insertOrUpdateProject");	
        console.log(JSON.stringify(component.get("v.listOfSelectedRows")));
        action.setParams({
            "listOfAssets": component.get("v.listOfSelectedRows"),
            "projectId" : existingProjectId ,
            "nameOfProject":  nameOfProject ,
            "selectedSEUserId" : component.get("v.SelectedSEUserId"),
            "siPartnerAccountrecordId" :  component.get("v.selectedSIPartnerRecordId"),
            "jsonAfterProjectInsertfromUI" : null,
            "orderId" : component.get("v.recordId"),
            "typeOfProject" : component.get("v.value")
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state === "SUCCESS")
            {
                if(response.getReturnValue()!== null){
                    var result=response.getReturnValue();
                    console.log("Project are Inserted Successfully"+JSON.stringify(result)); 
                    var closeQuickAction=$A.get("e.force:closeQuickAction");
                    closeQuickAction.fire();
                     component.set("v.isOpen",false);
                }else{
                    console.log("handleConfirmDialogYes"+"No Project are Inserted");  
                }
            }else if(state === "ERROR"){
                console.log("handleConfirmDialogYes  helper"+"ERROR ");  
            }
        });
        $A.enqueueAction(action);
        
        var closeQuickAction=$A.get("e.force:closeQuickAction");
        closeQuickAction.fire();
        component.set("v.isOpen",false);
        
    },onSelectSEForProject : function(component,event,helper){
        var seUser=''; 
        if(component.get("v.selectedLookUpRecord").Id != undefined){
            component.set("v.showDevelopmentInHouse",false);
            seUser = component.get("v.selectedLookUpRecord").Id;
            
            component.set("v.SelectedSEUserId",seUser);
            var action = component.get("c.getOrderAndAssets");
            action.setParams({
                "orderId" : component.get("v.recordId")
            });
            action.setCallback(this,function(response){
                
                if(response.getState()==="SUCCESS"){
                    component.set("v.showIntegrationAssets",true);
                    if(response.getReturnValue()!==null){
                        component.set("v.listOfRelatedIntegrationAssets",response.getReturnValue());
                    }
                }else if(response.getState()==="ERROR"){
                    
                }
            });
            $A.enqueueAction(action);
        }else{
            helper.showError(component, event, helper,'Please Select the SE User and Click Next');
        }
    },onSelectSEForSIProject : function(component, event, helper){
        var seUser=''; 
        if(component.get("v.selectedLookUpRecord").Id != undefined){
            component.set("v.showDevelopmentInHouse",false);
            component.set("v.showSEForProject",false);
            seUser = component.get("v.selectedLookUpRecord").Id;
            
            
            if(seUser!==null){
                component.set("v.SelectedSEUserId",seUser);
                var action=component.get("c.updateSEUserFROMAccountCustomerLevel");
                action.setParams({
                    "orderId":component.get("v.recordId"),
                    "userId" :seUser 
                });
                action.setCallback(this,function(response){
                    var state=response.getState();
                    if(state==="SUCCESS"){
                        component.set("v.showSIPartnerAccounts",true);
                    }
                });
                $A.enqueueAction(action);
            }
        }else{
            var seuserId=component.get("v.OrderInstance").Account.SE_User__c;
            component.set("v.SelectedSEUserId",seuserId);
            component.set("v.showDevelopmentInHouse",false);
            component.set("v.showSEForProject",false);
            component.set("v.showSIPartnerAccounts",true);
        }
    },
    handlesubmitCreatProject : function(component,event,helper){
        event.preventDefault();
        var fields = event.getParam("fields");
        component.find("recordEditForm").submit(fields);
        
    },createProject : function(component,event,helper,jsonAfterProjectInsertfromUI){
        
        var action=component.get("c.insertOrUpdateProject");	
        console.log('Log 1======> '+JSON.stringify(component.get("v.listOfSelectedRows")));
        var nameOfProject='';
        /*var recordId=jsonAfterProjectInsertfromUI.id;//.Id.value;
        console.log('Log 2==>'+recordId);*/
        if(component.get("v.isSIPartner")){
            nameOfProject=' SI Partner Project';
        }else{
            nameOfProject=' Dev In House Or Consultent Only';
        }
        //List<Asset> listOfAssets,Id projectId,String nameOfProject,String selectedSEUserId,String siPartnerAccountrecordId
        action.setParams({
            "listOfAssets": component.get("v.listOfSelectedRows"),
            "projectId" :  null,
            "nameOfProject":  nameOfProject ,
            "selectedSEUserId" : component.get("v.SelectedSEUserId"),
            "siPartnerAccountrecordId" :  component.get("v.selectedSIPartnerRecordId"),
            "jsonAfterProjectInsertfromUI" : jsonAfterProjectInsertfromUI,
            "orderId" : component.get("v.recordId"),
            "typeOfProject" : component.get("v.value")
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state === "SUCCESS")
            {
                if(response.getReturnValue()!== null){
                    var result=response.getReturnValue();
                    console.log("Project are Inserted Successfully"+JSON.stringify(result)); 
                    var closeQuickAction=$A.get("e.force:closeQuickAction");
                    closeQuickAction.fire();
                    component.set("v.isOpen",false);
                    helper.showSuccess(component, event, helper,'Project is Created Successfully');
                }else{
                    console.log("handleConfirmDialogYes"+" No Project are Inserted ");  
                }
            }else if(state === "ERROR"){
                console.log("handleConfirmDialogYes  helper"+"ERROR ");  
            }
        });
        $A.enqueueAction(action);

    },
    showInfo : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info',
            message: 'This is an information message.',
            duration:'5000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    showSuccess : function(component, event, helper,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: message,
            duration:'5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showError : function(component, event, helper , errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:errorMessage,
            duration:'5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showWarning : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Warning',
            message: 'This is a warning message.',
            duration:'5000',
            key: 'info_alt',
            type: 'warning',
            mode: 'sticky'
        });
        toastEvent.fire();
    }
    
                       
})