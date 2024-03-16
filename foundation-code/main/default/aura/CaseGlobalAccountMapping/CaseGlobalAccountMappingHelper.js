({
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        
        var action;// = component.get("c.fetchLookUpValues");
        if(component.get("v.objectAPIName") === 'User' && !component.get("v.showAllUsers")){
            action = component.get("c.featchLookupUserByUserRoleTypeAsSE");
        }else if(component.get("v.objectAPIName") === 'EmailTemplate' && component.get("v.whereCondition")!==null && component.get("v.whereCondition")!=='' && component.get("v.whereCondition")!==undefined  ){
            //  where Name LIKE: searchKey 
            action = component.get("c.fetchLookUpValues");  
        } else if(component.get("v.objectAPIName") === 'Case' && component.get("v.whereCondition")!==null && component.get("v.whereCondition")!=='' && component.get("v.whereCondition")!==undefined ){
            debugger;
            //This code is improved because of Case will not have Name field 
            console.log(component.get("v.whereCondition"));
            action = component.get("c.fetchLookUpValues");
        }else{
            action = component.get("c.fetchLookUpValues");
        }
        //This code is improved because of Case will not have Name field 
        if(component.get("v.objectAPIName") !== 'EmailTemplate' && component.get("v.objectAPIName") !== 'Case' ){
            // set param to method  
            console.log('without Where condition');
            action.setParams({
                'searchKeyWord': getInputkeyWord,
                'ObjectName' : component.get("v.objectAPIName"),
            });
        }else{
            // set param to method  
            console.log('with Where condition');
            action.setParams({
                'searchKeyWord': getInputkeyWord,
                'ObjectName' : component.get("v.objectAPIName"),
                'whereCondition' : component.get("v.whereCondition")
            }); 
        }
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },
    
    searchAccount : function(component,event, getInputkeyWord,getcount){
        debugger;
        
        var action = component.get("c.fetchAccount");
        action.setParams({
            'caseId': component.get("v.recordId"),
            'searchKey' : getInputkeyWord
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
                if(getcount){
                    var isMultipleAccounts=false;
                    console.log('toreResponse.size()'+storeResponse.length);
                    isMultipleAccounts=storeResponse.length>1?true:false;
                    component.set("v.isMultipleAccounts", isMultipleAccounts);
                }  
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },
    
    saveRecord : function(component,event, selected){
        debugger;
        var action = component.get("c.createContact");
        action.setParams({
            'caseId': component.get("v.recordId"),
            'accName' : selected.Name,
            'accId' : selected.Id
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.selectedRecord", {});
                var lookUpTarget = component.find("lookupField");
                $A.util.removeClass(lookUpTarget, 'slds-hide');
                $A.util.addClass(lookUpTarget, 'slds-show');  
                $A.get('e.force:refreshView').fire();
            }
            
        });
        $A.enqueueAction(action);
    }
})