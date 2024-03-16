({
    onInit : function(component, event, helper){
        
        var RecordId = component.get("v.recordId");
        var leadRecord = component.get('c.getLead');
        leadRecord.setParams({
            "recordId" : RecordId
        });
        
        leadRecord.setCallback(this, function(response){
            
            var state = response.getState();
            console.log('state '+state);
            console.log('component.isValid() '+component.isValid());
            
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                
                component.set("v.leadObject",response.getReturnValue());
                
                var leadObject = component.get("v.leadObject");
                
                if(leadObject.Sub_Stages__c == 'Demo Completed'){
                    
                    var convertLeadRecord = component.get('c.convertLead');
                    convertLeadRecord.setParams({
                        "leadObject" : leadObject
                    });
                    
                    convertLeadRecord.setCallback(this, function(convertResponse){
                        
                        var convertState = convertResponse.getState();
                        
                        if( component.isValid() && (convertState === 'SUCCESS' || convertState === 'DRAFT') ){
                            
                            var oReturnResult = convertResponse.getReturnValue();
                            
                            console.log('oReturnResult: '+oReturnResult);
                            if( oReturnResult != undefined ){
                                
                                console.log('Retun result of Lead Conversion oReturnResult: '+JSON.stringify(oReturnResult));
                                if(oReturnResult.isLeadConverted){
                                    
                                    var navEvt = $A.get("e.force:navigateToSObject");
                                    navEvt.setParams({
                                        "recordId": oReturnResult.accountId,
                                        "slideDevName": "detail"
                                    });
                                    navEvt.fire();
                                    
                                } else{
                                    
                                    component.set("v.spinner",false);
                                    component.set("v.genericErrorMsg",oReturnResult.errorMessage);
                                    component.set("v.showGenericError",true);
                                    component.set("v.leadError",false);
                                }
                            }
                        } else if(convertState==='INCOMPLETE'){
                            
                            component.set("v.errorMsg",JSON.stringify(response.getError()));
                            console.log('User is Offline System does not support drafts '
                                        + JSON.stringify(response.getError()));
                        } else if(convertState ==='ERROR'){
                            
                            console.log(response.getError());
                            component.set("v.errorMsg",JSON.stringify(response.getError()));
                            component.set("v.leadError",true);
                            component.set("v.spinner",false);
                        } else{
                            
                            component.set("v.errorMsg",JSON.stringify(response.getError()));
                            component.set("v.leadError",true);
                            component.set("v.spinner",false);
                        }
                    });
                    
                    $A.enqueueAction(convertLeadRecord);
                } else{
                    component.set("v.spinner",false);
                    component.set("v.leadStatus",true);
                }
            } else if(state==='INCOMPLETE'){
                
                console.log('User is Offline System does not support drafts '
                            + JSON.stringify(response.getError()));
            } else if(state ==='ERROR'){
                
                console.log(response.getError());
            } else{
                
            }
        });
        $A.enqueueAction(leadRecord);
    },
})