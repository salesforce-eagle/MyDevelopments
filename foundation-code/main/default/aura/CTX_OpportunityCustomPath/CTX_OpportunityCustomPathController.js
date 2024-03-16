({	
    doInit : function (component, event, helper) {
        component.set("v.salesStageNewValue", component.get("v.picklistField").Sales_Stage_New__c);
        component.set("v.stageNameNewValue", component.get("v.picklistField").StageName);
        component.set("v.displayInternalStage", false);
        var recordId = component.get("v.recordId");
        var action = component.get("c.getRecordTypeName");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var recordTypeName = response.getReturnValue();
                console.log("Record Type Name: " + recordTypeName);
                if(!($A.get("$Label.c.Opportunity_CustomPath_Visibility").includes(recordTypeName))){
                    component.set("v.displayInternalStage", true);
                }
            }
            else {
                console.error("Error: " + response.getError()[0].message);
            }
        });
       
        
        $A.enqueueAction(action);

    },
    handleSelect_SalesStageNew : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        component.set("v.salesStageNewValue", stepName);
    },
    
    handleSelect_StageName : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        component.set("v.stageNameNewValue", stepName);
    },
    
    handleClick : function (component, event, helper) {
        var action = component.get("c.updateStageDetails");         
        action.setParams({
            "recordId"		: component.get("v.recordId"),
            "stageNameVal"	: component.get("v.stageNameNewValue"),
            "salesStageVal"	: component.get("v.salesStageNewValue")
        });
        
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                
                var result 		= response.getReturnValue();
                var toastEvent 	= $A.get("e.force:showToast");
                
                toastEvent.setParams({
                    "title": "Success!",
                    "message": response.getReturnValue()
                });
                toastEvent.fire();
                
                $A.get('e.force:refreshView').fire();
            }
        });
        
        $A.enqueueAction(action);
    }
})