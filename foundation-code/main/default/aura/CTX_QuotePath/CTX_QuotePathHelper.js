({
    /*reloadCmp : function(component, event, helper) {        
        var action =   component.get("c.getQuoteStatusName");         
        action.setParams({"recId":component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.thisQuote', result);
                component.set('v.recordId', result.Id);
                component.set('v.discountValue', result.Discount);
                //component.set('v.statusSelected', result.Status);
                console.log('in reload Page-->'+JSON.stringify(result));
                component.set("v.PicklistField.Status", result.Status);
                //var dis= Math.floor(result.Discount);
//alert(x.toFixed(2)); 
                var modalBody ="This Quote will be routed for approval and " +result.Discount.toFixed(2)+ " te% is given against the quote";
                component.set('v.modalBody', modalBody);
               
            }
        });
        $A.enqueueAction(action);
    },*/
    getStageNameHelper : function(component, event, helper) {        
        var action =   component.get("c.getQuoteStatusName");         
        action.setParams({"recId":component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.thisQuote', result.quoteRecord);
                component.set("v.PicklistField.Status", result.quoteRecord.Status);
                if(result.quoteRecord.Discount >0){
                    component.set('v.recordId', result.quoteRecord.Id);
                    component.set('v.discountValue', result.quoteRecord.Discount);
                    component.set("v.oldStatusPicklistField", result.quoteRecord.Status);
                    component.set("v.acquisitionOppRTList", result.acquisitionOppRTList);
                    component.set("v.oppRTName",result.quoteRecord.Opportunity.RecordType.DeveloperName);
                    component.set("v.isOpportunityRenewal",result.isOpportunityRenewal);
                    var isQLIproductcategory=result.quoteRecord.Max_Discount_Prod_Category__c =='MS'?true:false;
                    component.set("v.isQLIproductcategory", isQLIproductcategory);
                    console.log('in  result'+JSON.stringify(result));
                    // var dis= Math.floor(result.Discount);
                    var discountGiven=result.isOpportunityRenewal ? result.quoteRecord.Discount.toFixed(2):result.quoteRecord.Max_Discount__c.toFixed(2);
                    var modalBody ="This Quote will be routed for approval and " +discountGiven+ "% is given against the quote";
                    component.set('v.modalBody', modalBody);
                    //starts
                    
                    var action2 = component.get("c.getReasonForDiscount");
                    action2.setParams({"OpportunityRTName":result.quoteRecord.Opportunity.RecordType.DeveloperName});
                    
                    action2.setCallback(this, function(response){
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var result2 = response.getReturnValue();
                            var fieldMap = [];
                            console.log('in  result2'+JSON.stringify(result2));
                            for(var key in result2){
                                fieldMap.push({key: key, value: result2[key]});
                            }
                            component.set("v.reasonDisFieldMap", fieldMap);
                            console.log('in  Field'+JSON.stringify(fieldMap));
                            
                        }
                    });
                    $A.enqueueAction(action2);
                }
            }
        });
        $A.enqueueAction(action);
    },
    openDiscountPopup: function(component, event, helper) {
        console.log('in  openDiscountPopup ' );
        var quoteToupdate=component.get('v.thisQuote');
        console.log('thisQuote ' + JSON.stringify(quoteToupdate));
        console.log('quoteToupdate.hasOwnProperty("Flat_Transaction_Fee__c") :: ' + quoteToupdate.hasOwnProperty('Flat_Transaction_Fee__c'));
        console.log('thisQuote Opportunity rec type ID' + JSON.stringify(quoteToupdate.Opportunity["RecordType"]["DeveloperName"]));
        var opportunityRecordTypeName = JSON.stringify(quoteToupdate.Opportunity["RecordType"]["DeveloperName"]);
        console.log('opportunityRecordTypeName :: '+opportunityRecordTypeName);
        //console.log('opp record type ' + JSON.stringify(quoteToupdate.get("Opportunity").get("Recordtype").DeveloperName));
        if(quoteToupdate.Max_Discount__c   > 0){
            
            if(quoteToupdate.Total_Price_ID_SKUs__c>=500000 && quoteToupdate.ClearTax_Billing_Entity__c == 'Xpedize'
               &&(quoteToupdate.Flat_Transaction_Fee__c == 0 || !quoteToupdate.hasOwnProperty('Flat_Transaction_Fee__c') || quoteToupdate.Flat_Transaction_Fee__c >20) 
               && (quoteToupdate.Transaction_Fee_Slab_1__c == 0 || !quoteToupdate.hasOwnProperty('Transaction_Fee_Slab_1__c') || quoteToupdate.Transaction_Fee_Slab_1__c >20) 
               && (quoteToupdate.Transaction_Fee_Slab_2__c == 0 || !quoteToupdate.hasOwnProperty('Transaction_Fee_Slab_2__c') || quoteToupdate.Transaction_Fee_Slab_2__c >20) 
               && (quoteToupdate.Transaction_Fee_Slab_3__c == 0 || !quoteToupdate.hasOwnProperty('Transaction_Fee_Slab_3__c') || quoteToupdate.Transaction_Fee_Slab_3__c >20)
              )
            {
                console.log('in  openDiscountPopup False' );
                this.sendQuoteForApproval(component, event, helper);
            }else{
                console.log('in  openDiscountPopup True' );
                component.set('v.isDiscountApproval', true);
            }
        }else if(quoteToupdate.Discount == 0){
            /*component.set("v.PicklistField.Status", 'Quote Accept');
            component.set("thisQuote.Status",'Quote Accept');
            component.find("record").saveRecord($A.getCallback(function(response) {
                if (response.state === "SUCCESS") {
                    console.log('thisQuote ----> after dis 0' + JSON.stringify(quoteToupdate));
                    //this.reloadCmp(component, event, helper);
                }
            }));
            var quoteToupdate=component.get('v.thisQuote');
            quoteToupdate.Status='Quote Accept';
            // component.set("thisQuote.Status",'Quote Accept');
            this.updateQuoteRecord(component, event, helper);*/
            this.sendQuoteForApproval(component, event, helper);
        }
        
        
    },
    
    
    
    sendQuoteForApproval: function(component, event, helper) {
        var action =   component.get("c.submitQuoteForApproval");  
        var thisQuoteToUpdate=component.get("v.thisQuote");
        if(thisQuoteToUpdate){
            var quoteTobeUpdatedFromPopup=component.get("v.quoteTobeUpdatedFromPopup");
            thisQuoteToUpdate.Reason_for_Discount_Request__c = quoteTobeUpdatedFromPopup.Reason_for_Discount_Request__c;
            thisQuoteToUpdate.Detailed_reason_for_discount__c =quoteTobeUpdatedFromPopup.Detailed_reason_for_discount__c;
            thisQuoteToUpdate.Estimated_Delivery_Cost__c = quoteTobeUpdatedFromPopup.Estimated_Delivery_Cost__c;
            thisQuoteToUpdate.Reason_For_Not_Opting_For_Integration__c =quoteTobeUpdatedFromPopup.Reason_For_Not_Opting_For_Integration__c;
            thisQuoteToUpdate.Incumbent__c = quoteTobeUpdatedFromPopup.Incumbent__c;
            thisQuoteToUpdate.Customer_Opted_For_Integration__c =quoteTobeUpdatedFromPopup.Customer_Opted_For_Integration__c =='Yes'?true:false;
            thisQuoteToUpdate.Products_Can_Be_Cross_Sold_In_Future__c=
                quoteTobeUpdatedFromPopup.Reason_for_Discount_Request__c=='Future cross/up-sell potential is high'?quoteTobeUpdatedFromPopup.Products_Can_Be_Cross_Sold_In_Future__c:null;
            thisQuoteToUpdate.Projected_Customer_Lifetime_Value__c=
                quoteTobeUpdatedFromPopup.Reason_for_Discount_Request__c=='Foot in the door for a large brand/logo'?
                quoteTobeUpdatedFromPopup.Projected_Customer_Lifetime_Value__c:null;
            thisQuoteToUpdate.Name_of_Competitor__c=
                quoteTobeUpdatedFromPopup.Reason_for_Discount_Request__c=='Lower quote by competition'? 
                quoteTobeUpdatedFromPopup.Name_of_Competitor__c:null;
            thisQuoteToUpdate.Opportunity_Type__c =component.get('v.acquisitionOppRTList').indexOf(component.get('v.oppRTName')) > -0?'Retention':'Acquisition';
            thisQuoteToUpdate.Status=component.get("v.statusSelected");
            
            thisQuoteToUpdate.Price_Offered_to_Match_Competitor__c = quoteTobeUpdatedFromPopup.Price_Offered_to_Match_Competitor__c;
            thisQuoteToUpdate.Old_Anchor_Price__c = quoteTobeUpdatedFromPopup.Old_Anchor_Price__c;
            thisQuoteToUpdate.Next_Pitch_Date__c = quoteTobeUpdatedFromPopup.Next_Pitch_Date__c;
            thisQuoteToUpdate.Features_not_in_Use__c = quoteTobeUpdatedFromPopup.Features_not_in_Use__c;
            
        }
        action.setParams({"thisQuote":thisQuoteToUpdate});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('result Approval ' + JSON.stringify(result));
                if(result.isSuccess){
                    component.set("v.PicklistField.Status", result.Status);
                    component.find('notifLib').showToast({
                        "title": "Success!",
                        "message": "The record is submitted for approval successfully ."
                    });
                    component.set('v.thisQuote',result.quoteRecord);
                    //$A.get('e.force:refreshView').fire();
                    window.location.reload();
                }else{
                    var errors = response.getError();    
                    var errorMsg= errors[0].message;
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Something has gone wrong!",
                        "message": errorMsg,
                        closeCallback: function() {
                            window.location.reload();
                        }
                    });
                }
                
            }
            else if (state === "INCOMPLETE") {
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Something has gone wrong! ",
                    "message": "Unfortunately, there was a problem updating the record.Contact your admin !!",
                    closeCallback: function() {
                        console.log('You closed the alert!');
                    }
                });
            }
                else if (state === "ERROR") {
                    var errors = response.getError();  
                    var errorMsg= errors[0].message;
                    var erms=errorMsg.substr(errorMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,'),errorMsg.length-1);
                    
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Something has gone wrong!",
                        "message": erms,
                        closeCallback: function() {
                            window.location.reload();
                        }
                    });
                }
            
        });        
        
        $A.enqueueAction(action);  
    },
    
    
    
    acceptQuoteError: function(component, event, helper) { 
        var quoteToupdate=component.get('v.thisQuote');
        if(quoteToupdate !=null){
            if(quoteToupdate.Discount  > 0 && component.get("v.oldStatusPicklistField") !='Discount Approval'){
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "",
                    "message": "Move to Discount Approval, before moving to Quote Accept",
                    closeCallback: function() {
                        window.location.reload();
                        
                    }
                });
                
            }else{
                component.set("v.PicklistField.Status", component.get("v.statusSelected"));
                /* component.find("record").saveRecord($A.getCallback(function(response) {
                    if (response.state === "SUCCESS") {
                        $A.get('e.force:refreshView').fire();
                        // this.reloadCmp(component, event, helper);
                    }
                }));*/
                this.updateQuoteRecord(component, event, helper, component.get("v.statusSelected")); 
            }
        }
    },
    checkForAttachmentError: function(component, event, helper) {
        console.log('thisQuote ' + JSON.stringify(component.get("v.thisQuote")));
        var action =   component.get("c.showDiscountApprovalError");         
        action.setParams({"thisQuoteId":component.get("v.thisQuote").Id,
                          "thisQuote": component.get("v.thisQuote") });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('result opp eroor ' + JSON.stringify(result));
                if(result.isQuoteError){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "error" ,
                        "title": "Error!",
                        "message": result.errorString
                    });
                    
                    toastEvent.fire();
                    
                    
                }else{
                    if(component.get("v.statusSelected")=='Discount Approval'){
                        this.openDiscountPopup(component, event, helper); 
                    }
                    else if(component.get("v.statusSelected")=='Quote Accept'){
                        this.acceptQuoteError(component, event, helper); 
                    }
                    
                }
            }
            else if (state === "INCOMPLETE") {
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Something has gone wrong! ",
                    "message": "Unfortunately, there was a problem updating the record.Contact your admin !!",
                    closeCallback: function() {
                        console.log('You closed the alert!');
                    }
                });
            }
                else if (state === "ERROR") {
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Something has gone wrong!",
                        "message": "Unfortunately, there was a problem updating the record.Contact your admin !!",
                        closeCallback: function() {
                            console.log('You closed the alert!');
                        }
                    });
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });        
        
        $A.enqueueAction(action);  
    },
    updateQuoteRecord: function(component, event, helper, stepName) {
        console.log('thisQuote updateQuoteRecord' + JSON.stringify(component.get("v.thisQuote")));
        var action =   component.get("c.quoteRecordToUpdateFunction");  
        var quoteToupdate=component.get("v.quoteRecordToUpdate");
        quoteToupdate.Status=stepName;
        quoteToupdate.Id=component.get("v.recordId");
        action.setParams({"quoteRecordToUpdate":quoteToupdate});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('updateQuoteRecord---> ' + JSON.stringify(result));
                if(result){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "success" ,
                        "title": "Success",
                        "message": "Updated the record successfully!!"
                    });
                    
                    toastEvent.fire();
                    window.location.reload(); 
                    
                }else{
                    //this.openDiscountPopup(component, event, helper); 
                    
                }
            }
            else if (state === "INCOMPLETE") {
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Something has gone wrong! ",
                    "message": "Unfortunately, there was a problem updating the record.Contact your admin !!",
                    closeCallback: function() {
                        console.log('You closed the alert!');
                    }
                });
            }
                else if (state === "ERROR") {
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var errorMsg= errors[0].message;
                            console.log("Error message: " + 
                                        errorMsg.substr(errorMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,'),errorMsg.length-1));
                            component.find('notifLib').showNotice({
                                "variant": "error",
                                "header": "Something has gone wrong!",
                                "message": errorMsg.substr(errorMsg.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,'),errorMsg.length-1),
                                closeCallback: function() {
                                    window.location.reload();
                                }
                            });
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            
        });        
        
        $A.enqueueAction(action);  
    },
    
    
    
})