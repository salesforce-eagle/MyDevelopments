({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.serverTrip");
        action.setParams({ opportunityRecordId : component.get("v.recordId") });
        
        window.setTimeout(
                    $A.getCallback(function() {
                        $A.get("e.force:closeQuickAction").fire();
                    }),0
                );
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                if(response.getReturnValue() != undefined){
                    if(response.getReturnValue().isSuccess){
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": response.getReturnValue().errorMessage
                        });
                        toastEvent.fire();
                    } else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": response.getReturnValue().errorMessage
                        });
                        toastEvent.fire();
                    }
                } else{
                    console.log('Return result is NULL');
                }
            } 
            else if (state === "INCOMPLETE") {} 
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +errors[0].message);
                        }
                    } 
                    else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
    }
})