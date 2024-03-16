({
        doInit : function(component, event, helper) {   
            //         helper.reloadCmp(component, event, helper);
            helper.getStageNameHelper(component, event, helper);       
        },
        
        statusPicklistField : function (component, event, helper) {
            var stepName = event.getParam("detail").value;
            component.set("v.PicklistField.Status", stepName);
            console.log('stepName ' + stepName);
            component.set("v.statusSelected", stepName);
            if(stepName == 'Discount Approval'){
                if(component.get('v.thisQuote').Approval_sub_status__c=='Discount Approval in progress'){
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Record Is Already In Approval",
                        "message": "You cannot make changes when Discount is in approval!!",
                        closeCallback: function() {
                            $A.get('e.force:refreshView').fire();
                        }
                    }); 
                }else{
                    helper.checkForAttachmentError(component, event, helper); 
                }
            }
            else if(stepName == 'Quote Accept'){
                component.set("v.PicklistField.Status", stepName);	
                helper.checkForAttachmentError(component, event, helper); 
            }
                else{
                    helper.updateQuoteRecord(component, event, helper, stepName); 
                    
                }
            
            $A.get('e.force:refreshView').fire();        
        },
        sendForApproval : function (component, event, helper) {
            console.log("numItems has changed");
            console.log("old value: " + event.getParam("oldValue"));
            console.log("current value: " + event.getParam("value"));
            console.log("quote from child----->" + JSON.stringify(component.get("v.quoteTobeUpdatedFromPopup")));
            if(event.getParam("value")){
                helper.sendQuoteForApproval(component, event, helper); 
            }
        },
        setStatusSelectedValues: function (component, event, helper) {
            console.log("statusSelected has changed");
            console.log("old value statusSelected: " + event.getParam("oldValue"));
            component.set("v.oldStatusPicklistField", event.getParam("oldValue"));
            $A.get('e.force:refreshView').fire();
            
        },
        
    })