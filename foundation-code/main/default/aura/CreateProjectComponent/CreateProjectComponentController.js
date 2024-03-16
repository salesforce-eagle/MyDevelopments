({
    onload : function(component, event, helper) {
        
        
        component.set('v.options',[
            {'label': 'SI Partner', 'value': 'SI Partner'},
            {'label': 'Development in House', 'value': 'Development in House'},
            {'label': 'Consultation only', 'value': 'Consultation only'},
            {'label': 'AMC', 'value': 'AMC'}
        ]);	
        
        
        component.set("v.columns",[
            {label: 'Account name', fieldName: 'Name', type: 'text'},
            {label: 'Record Type', fieldName: 'RecordType.Name', type: 'text'},
            {label: 'No of Active Projects', fieldName: 'No_Of_Active_Projects__c', type: 'Integer'}
        ]);
        
         component.set("v.isOpen",true);
        debugger;
        var closeQuickAction=$A.get("e.force:closeQuickAction");
        closeQuickAction.fire();
        debugger;
        helper.getExperties(component,event,helper);
        helper.getAllSIPartners(component,event,helper);
    },
    onCheckboxChange  : function(component, event, helper) {
        
        //Gets the checkbox group based on the checkbox id
        var availableCheckboxes = component.find('rowSelectionCheckboxId');
        var resetCheckboxValue  = false;
        
        if (Array.isArray(availableCheckboxes)) {
            //If more than one checkbox available then individually resets each checkbox
            availableCheckboxes.forEach(function(checkbox) {
                checkbox.set('v.value', resetCheckboxValue);
            }); 
        } else {
            //if only one checkbox available then it will be unchecked
            availableCheckboxes.set('v.value', resetCheckboxValue);
        }
        //mark the current checkbox selection as checked
        event.getSource().set("v.value",true);	
        //alert(JSON.stringify(event.getSource().get("v.text")));
        component.set("v.SelectedRow",event.getSource().get("v.text"));
        //alert(JSON.stringify(component.get("v.SelectedRow")));
        
    },
    handleonClick : function(component, event, helper) {
        helper.handleSaveClick(component, event, helper);
    },
    
    handleProjectSubmit : function(component, event, helper){
        helper.handleProjectSubmit(component, event, helper);
    },
    onChangeofExperties : function(Component, event, helper){
        helper.getSIAccountsBasedOnExperties(Component, event, helper);
    },
    onValueChange : function(component, event, helper){
        helper.changeOfFilterValues(Component, event, helper);
    },filter : function(component,event,helper){
        /*var filterData=[];
        //var searchTerm=component.get("v.searchTerm");
        var data=component.get("v.listOfAccounts");
        var isFiltered=component.get("v.isFiltered");
        var checkvalue = component.find("selectAll").get("v.value");  
        var checkProject = component.find("checkAccount"); 
        
        /*if(Array.isArray(data)){
            for (var i = 0; i < data.length; i++) {
				var projectName=data[i].name;
                if(projectName.toLowerCase().includes(searchTerm.toLowerCase())){
                    filterData.push(data[i]);
                    isFiltered=true;
                }
            }
        }*/
        /*component.set("v.isFiltered",isFiltered);
        component.set("v.filteredPorjects",filterData);*/
    },
    handleSelectAllProject : function(component,event,helper){
        /* alert('your in handleSelectAllProject');
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkProject = component.find("checkAccount"); 
        if(checkvalue == true){
            for(var i=0; i<checkProject.length; i++){
                checkProject[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkProject.length; i++){
                checkProject[i].set("v.value",false);
            }
        }*/
    },
    handleUnselectOtherAccounts : function(component,event,helper){
        /*  var accountList=component.find("checkAccount");
        alert(JSON.Stringifiy(accountList));*/
    },
    onRegionInputChange :function(component,event,helper){
        helper.onRegionInputChange(component,event,helper);
    },
    onCityInputChange :   function(component,event,helper){
        helper.onCityInputChange(component,event,helper);
    },
    onInputValueChange :  function(component, event, helper){
        helper.onInputValueChange(component, event, helper);
    },
    onExpertiesChange : function(component, event, helper){
        helper.onExpertiesChange(component, event, helper);
    },
    onNumberInputChange :  function(component, event, helper){
        helper.onNumberInputChange(component, event, helper);
    },handleOnSave :  function(component,event,helper){
        helper.handleOnSave(component, event, helper);
    },
    handleConfirmDialogNo :  function(component,event,helper){
        helper.handleConfirmDialogNo(component, event, helper);
    },
    handleConfirmDialogYes  :  function(component,event,helper){
        helper.handleConfirmDialogYes(component, event, helper);
    },onOrderCheckboxChange  :  function(component,event,helper){
        //alert('reached');
        helper.onOrderCheckboxChange(component, event, helper);
    },handleonSaveProject :  function(component,event,helper){
        helper.handleonSaveProject(component, event, helper);
    },onSelectSEForProject :  function(component,event,helper){
        helper.onSelectSEForProject(component, event, helper);
    },onSelectSEForSIProject: function(component,event,helper){
         helper.onSelectSEForSIProject(component, event, helper);
    },closeModel :  function(component,event,helper){
        component.set("v.isOpen",false);
        var closeQuickAction=$A.get("e.force:closeQuickAction");
        closeQuickAction.fire();
    },handlesubmitCreatProject : function(component,event,helper){
        helper.handlesubmitCreatProject(component,event,helper);
    },onsuccessHandler : function(component,event,helper){
        
        //console.log(event);
        var record = event.getParam("response");
        console.log('Record Info'+JSON.stringify(record));
       // console.log('Record Id ===>'+JSON.stringify(record.fields));
        //console.log('Record Id=====>'+record);
        //var recordId=record.Id;
        if(record!=undefined && record!=null && record!=''){
           
            helper.createProject(component,event,helper,JSON.stringify(record));
             helper.showSuccess(component,event,helper,'Project Created Successfully!..');
        }
        var closeQuickAction=$A.get("e.force:closeQuickAction");
        closeQuickAction.fire();
        
    }/*,handelCreateProject : function(component,event,helper){
        component.set("v.isOpen",true);
    }*/
    
})