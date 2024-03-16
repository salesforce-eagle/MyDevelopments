({  
    handlePicklistSelect : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        var action = component.get("c.updatePaymentTracker");
        action.setParams({paymentStatus:stepName , recordId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                if (state === 'SUCCESS'){
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": " Status is Update Succesfully !."
                    });
                }
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})