({
    doInit : function(component, event, helper) {
        
        var action = component.get('c.run'); 
        action.setParams({
            "recordId" : component.get('v.recordId') 
        });
        
        action.setCallback(this, function(response){
            
            var state = response.getState();
            
            if(state == 'SUCCESS'){
                
                var oResult 		= response.getReturnValue();
                var oReturnResult 	= [];
                
                if(oResult != undefined){
                    component.set('v.loaded', false);
                    if(oResult.isSuccess){
                        component.set('v.isSuccess', oResult.isSuccess);
                    } else{
                        for(var i in oResult.returnresultMap){
                            oReturnResult.push({key: i, value: oResult.returnresultMap[i]});
                        }
                        component.set('v.returnResult', oReturnResult);
                    }
                }
            }
            
        });
        
        $A.enqueueAction(action);
    }
})