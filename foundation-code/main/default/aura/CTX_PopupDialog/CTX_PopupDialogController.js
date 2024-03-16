({
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.quoteTobeUpdated", component.get("v.quoteTobeUpdated"));
        component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        component.set("v.userSelection", false);
        component.set("v.statusSelected", component.get("v.oldStatusValue"));
        window.location.reload();
        
    },
    submitDetails: function(component, event, helper) {
        
        var quoteFieldToValidate = component.find("formFieldToValidate");
        
        if(quoteFieldToValidate.length != undefined) {

            var allValid = quoteFieldToValidate.reduce(function (validSoFar, inputCmp) {
                // Show help message if single field is invalid
                inputCmp.showHelpMessageIfInvalid();
                // return whether all fields are valid or not
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            // If all fields are not valid increment the counter
            if (allValid) {
                component.set("v.userSelection", true);
                component.set("v.isModalOpen", false);
                component.set("v.submitButtonDisable", false);
            }else{
                component.set("v.submitButtonDisable", true);
            }
        }
        
    },
    handleOnChange : function(component, event, helper) {
        var reasonForDiscountValue = component.get("v.quoteTobeUpdated.Reason_for_Discount_Request__c");
        console.log('reasonForDiscountValue--->'+reasonForDiscountValue)
        if(reasonForDiscountValue=='Any other'){
            component.set("v.detailedReasonRequired",true);
            component.set("v.submitButtonDisable", true);
        }else{
            component.set("v.detailedReasonRequired",false); 
            component.set("v.submitButtonDisable", false);
        }
    },
    onchangeofDisReason : function(component, event, helper) {
        
        var quoteFieldToValidate = component.find("formFieldToValidate");
        if(quoteFieldToValidate.length!=undefined) {
            var allValid = quoteFieldToValidate.reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
            if (allValid) {
                component.set("v.submitButtonDisable", false);
            }else{
                component.set("v.submitButtonDisable", true);
            }
        }
        
    },
})