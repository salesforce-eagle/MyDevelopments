({
    doInit : function(component, event, helper) {
        
        /**	Check all conditions before creating Order Form	**/
        var action = component.get("c.checkForSyncQuotes");
        action.setParams({ recordId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.setTimeout(
                    $A.getCallback(function() {
                        $A.get("e.force:closeQuickAction").fire();
                    }),0
                );
                if(response.getReturnValue() != undefined && response.getReturnValue()){
                    
                    var modalBody;
                    window.setTimeout(
                        $A.getCallback(function() {
                            $A.get("e.force:closeQuickAction").fire();
                        }),0
                    ); 
                    
                    
                    var recordId = component.get("v.recordId");
                    console.log('Id '+recordId);
                    $A.createComponent("c:lwcPDFAndESignGenerator", 
                                       {'recordId':recordId},
                                       function(content, status) {
                                           if (status === "SUCCESS") {
                                               modalBody = content;
                                               component.find('overlayLib').showCustomModal({
                                                   header: "Fill in the details and Generate Order Form",
                                                   body: modalBody,
                                                   showCloseButton: true,
                                                   cssClass: "slds-modal_large",
                                                   closeCallback: function() {
                                                   }
                                               } )
                                           }
                                       } );
                } else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "No Sync quote available for the Opportunity"
                    });
                    toastEvent.fire();
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