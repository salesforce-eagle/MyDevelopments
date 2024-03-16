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
                
                console.log(' inside error oResult',JSON.stringify(oResult));

                if(oResult != undefined){
                    component.set('v.loaded', false);
                    if(oResult.isSuccess){
                        component.set('v.isSuccess', oResult.isSuccess);
                    } else{
                        for(var i in oResult.returnresultMap){
                            oReturnResult.push({key: i, value: oResult.returnresultMap[i]});
                            console.log(' inside error i ',JSON.stringify(i));
                        }
                        component.set('v.returnResult', oReturnResult);

                        console.log(' inside error v.returnResult ',JSON.stringify(component.get(v.returnResult)));
                    }
                }
            }
        });
        
        $A.enqueueAction(action);
    }
})