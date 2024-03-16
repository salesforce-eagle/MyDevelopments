({
    
    doInit : function (component, event, helper) {},
    
    handleSectionToggle : function (component, event, helper) {
        var openSections = event.getParam('openSections');
    }, 
    
    handleSave : function (component, event, helper) {
        
        var bDoServerCall = false;
        
        if( 
            (
                component.get('v.feedback') != undefined || 
                component.get('v.feedback') != null 
            ) &&
            (
                component.get('v.objectName') != undefined || 
                component.get('v.objectName') != null 
            )
        ){
            bDoServerCall = true;
        }
        
        if(bDoServerCall){
            
            var action = component.get('c.logFeedback'); 
            action.setParams({
                "objectName" 		: component.get("v.sObjectName"),
                "feedback" 			: component.get('v.feedback'),
                "pluses" 			: component.get('v.whatWentWell'),
                "needImprovement" 	: component.get('v.whatWentWrong')
            });
            
            action.setCallback(this, function(response){
                
                var state = response.getState();
                
                if(state == 'SUCCESS'){
                    
                    var oResult 		= response.getReturnValue();
                    var oReturnResult 	= [];
                    
                    if(oResult != undefined){
                        if(oResult.isSuccess){
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "type": "success",
                                "message": "You have successfully logged your Feedback. "
                            });
                            toastEvent.fire();
                        } else{
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message": oResult.errorMessage
                            });
                            toastEvent.fire();
                        }
                    }
                }
                
            });
            
            $A.enqueueAction(action);
        } else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "type": "warning",
                "message": "Please Fill Both Object and Feedback to Log a Feedback."
            });
            toastEvent.fire();
        }
        
    },
    
})