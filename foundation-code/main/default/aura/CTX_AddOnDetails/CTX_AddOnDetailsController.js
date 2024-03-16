({
    
    doInit : function(component, event, helper){
        
        component.set('v.columns', [
            { label: 'Scope' 						, fieldName: 'Add_On_Scope__c'				, type: 'text', wrapText: true },
            { label: 'ERP Family'					, fieldName: 'ERP_Family__c'				, type: 'text' },
            { label: 'Product SKU'					, fieldName: 'Product_SKU__c'				, type: 'text' },
            { label: 'List Price'					, fieldName: 'List_Price__c'				, type: 'integer' },
            { label: 'Estimated Effort(in Days)'	, fieldName: 'Estimated_Effort_in_Days__c'	, type: 'integer' },
            { label: 'Module'						, fieldName: 'Module__c'					, type: 'text' }
        ]);
        
        var action = component.get("c.fetchRequiredDetails");
        action.setParams({ 
            recordId : component.get("v.recordId") 
        });
        action.setCallback(this, function(response){
            
            var state = response.getState();
            if (state === "SUCCESS"){
                
                var lResult = response.getReturnValue();
                
                if(lResult.integrationAddOns.length > 0)
                    component.set('v.noAddOnDataAvaialbe'			, true);
                
                component.set('v.data'							, lResult.integrationAddOns);
                component.set('v.availableData'					, lResult.availableScopeAddOns);
                component.set('v.showAvailableData'				, lResult.isScopeAvailable);
                component.set('v.totalDiscountedPriceAvailable'	, lResult.totalDiscountedPrice);
                component.set('v.totalSellPrice'				, lResult.totalSellPrice);
                component.set('v.totalDiscountedPrice'			, lResult.totalDiscountedPrice);
                component.set('v.totalPrice'					, lResult.totalSellPrice);
                
            }  else if(state === "ERROR"){
                var errors = response.getError();
            }
        });
        
        $A.enqueueAction(action);
    },
    
    handleSelect : function(component, event, helper){
        
        var filteredData 			= component.get("v.selectedRows");
        var selectedRows 			= event.getParam('selectedRows');
        var dTotalPriceAvailable 	= component.get('v.totalSellPrice');
        var setRows 				= [];
        var totalPrice				= dTotalPriceAvailable;
        var keyValueMapFilteredData = {};
        var availableIds 			= [];
        component.set("v.onSubmitClicked", false);
        
        for (var i = 0; i < selectedRows.length; i++) {
            
            availableIds.push(
                selectedRows[i].Id
            );
            
            selectedRows[i]['Add_On_Status__c'] = 'Draft';
            
            if(selectedRows[i]['Discount']  != 0){
            } else{
                selectedRows[i]['Discount'] = 0;
            }
            
            totalPrice = totalPrice + selectedRows[i]['List_Price__c'];
            setRows.push(selectedRows[i]);
        }
        
        
        for(var k in filteredData){
            if(availableIds.includes(filteredData[k].Id)){
                
            } else{
                //alert('Bibhu Catch')
            }
        }
        component.set("v.selectedRows", setRows);
        if(setRows.length > 0){
            component.set("v.showDetails", true);
        }
        component.set("v.totalPrice", totalPrice);
    },
    
    handleSubmit : function(component, event, helper){
        
        var filteredData 					= component.get("v.selectedRows");
        var dTotalDiscountedPriceAvailable 	= component.get('v.totalDiscountedPriceAvailable');
        var totalPrice 						= component.get('v.totalPrice');
        var discountPrice 					= dTotalDiscountedPriceAvailable;
        var lScopeAddOns 					= [];
        
        component.set("v.onSubmitClicked", true);
        
        
        for(var i in filteredData){
            
            var discount = isNaN(filteredData[i].Discount) ? 0 : filteredData[i].Discount;
            
            discountPrice	= discountPrice + 
                ( filteredData[i].List_Price__c - 
                 ( (filteredData[i].List_Price__c*discount) / 100 ) );
            
            if(filteredData[i].Type__c == 'Dynamic Add On')
                totalPrice 		= parseInt(totalPrice) + parseInt(filteredData[i].List_Price__c);
            
            console.log('totalPrice: '+totalPrice);
            lScopeAddOns.push({
                'sobjectType'					: 'Integration_Scope_Add_On__c',
                'Related_Quote__c'				: component.get("v.recordId"),
                'Related_Add_On__c'				: filteredData[i].Id,
                'Discount_Percentage__c'		: discount,
                'Is_Active__c'					: true,
                'Add_On_Status__c'				: 'In Approval',
                'Estimated_Effort_In_Days__c'	: filteredData[i].Estimated_Effort_in_Days__c,
                'ERP_Family__c'					: filteredData[i].ERP_Family__c,
                'List_Price__c'					: filteredData[i].List_Price__c,
                'Module__c'						: filteredData[i].Module__c,
                'Scope__c'						: filteredData[i].Add_On_Scope__c,
                'Product_SKU__c'				: filteredData[i].Product_SKU__c,
                'Name'							: filteredData[i].Name
            });
        }
        
        component.set("v.totalDiscountedPrice", discountPrice);
        component.set("v.totalPrice", totalPrice);
        component.set("v.scopeAddOns", lScopeAddOns);
    }, 
    
    handleApproval : function(component, event, helper){
        
        var action = component.get("c.sendForApproval");
        action.setParams({ 
            incomingValues : component.get("v.scopeAddOns"),
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            
            var state = response.getState();
            if (state === "SUCCESS"){
                
                var wResult = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if(wResult.isSuccess){
                    
                    toastEvent.setParams({
                        "title": "Success!",
                        "type":"success",
                        "message": 'An approval request is sent.'
                    });
                    toastEvent.fire();
                    
                    location.reload();
                } else{
                    
                    toastEvent.setParams({
                        "title": "Error!",
                        "type":"error",
                        "message": wResult.errorMessage
                    });
                    toastEvent.fire();
                }
                
            }  else if(state === "ERROR"){
                
                var errors = response.getError();
                if(errors){
                    if (errors[0] && errors[0].message){
                        console.log("Error message: " +errors[0].message);
                    }
                } else{
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    handleChangeDiscountRate:function(component, event, helper) {
        
        var filteredData 	= component.get("v.selectedRows");
        var dp 				= component.find("discountPrice");
        var cdp 			= 0;
        
        if(dp.length != undefined){
            
            for(var i in dp){
                cdp = cdp + (dp[i].get("v.value"))
            }
        } else{
            cdp = cdp + (dp.get("v.value"))
        }
        
        // component.set("v.totalDiscountedPrice", cdp);
    },
    
    handleCustomAddOn : function(component, event, helper){
        
        var bButtonStatus = component.get("v.isCustomAddOnAvailable");
        
        if(bButtonStatus){
            component.set("v.isCustomAddOnAvailable", false);
            component.set("v.customAddOnLabel", "Add a Custom Add-On");
        } else{
            component.set("v.isCustomAddOnAvailable", true);
            component.set("v.showDetails", true);
            component.set("v.customAddOnLabel", "Remove Add On");
            component.set("v.dynamicAddOnScope", null);
            component.set("v.dynamicAddOnFinalPrice", 0);
        }
        
    }
    
})