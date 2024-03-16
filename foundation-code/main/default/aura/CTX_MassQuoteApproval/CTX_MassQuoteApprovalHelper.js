({
    doInitHelper : function(component) {
        var self = this;
        var action = component.get("c.fetchApprovals");
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            
            console.log('result-->'+JSON.stringify(result));
            if (response.getState() === "SUCCESS") {
                if(!$A.util.isEmpty(result)) {
                    for(var i = 0; i < result.length; i++) {
                        if(!$A.util.isEmpty(result[i].data)) {
                            for(var j = 0; j < result[i].data.length; j++) {
                                var nameValue = result[i].data[j].record[result[i].fieldName];
                                result[i].data[j].record['Name'] = nameValue;
                            }
                        }
                    }
                    component.set('v.approvalList', result);
                }
                $A.util.addClass(component.find('Spinner'), 'slds-hide');
            } else {
                var errors = response.getError();
                if (Array.isArray(errors) && errors.length && errors[0] && errors[0].message) {
                    if(errors[0].message === 'No Pending Approvals found.') {
                        self.showToast(component, 'Info', errors[0].message);
                    } else {
                        self.showToast(component, 'Error', errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSelectedRows : function(component, event, actionTask) {
        var self = this;
        var selectedProcesses = [];
        var approvalList = component.get('v.approvalList');
        for(var index = 0; index < approvalList.length; index++) {
            if(approvalList[index].objName == event.getSource().get('v.name')) {
                for(var ind2 = 0; ind2 < approvalList[index].data.length; ind2++) {
                    if(approvalList[index].data[ind2].isChecked)
                        selectedProcesses.push(approvalList[index].data[ind2].processInstanceId);
                }
            }
        }
        if(!$A.util.isEmpty(selectedProcesses) && selectedProcesses.length > 0) {
            var comment = prompt("Please enter your comments. (optional)")
            self.updateApprovalHelper(component, selectedProcesses, comment, actionTask);
        } else {
            self.showToast(component, 'Info', 'Please select Record(s) to Approve/Reject.');
        }
    },
    
    updateApprovalHelper : function(component, selectedProcesses, comment, actionTask) {
        var self = this;
        $A.util.removeClass(component.find('Spinner'), 'slds-hide');
        var action = component.get("c.updateApprovalProcess");
        action.setParams({
            'processInstanceWorkitemIds' : JSON.stringify(selectedProcesses),
            'action' : actionTask,
            'comment' : comment
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            if (response.getState() === "SUCCESS") {
                component.set('v.approvalList', []);
                self.showToast(component, 'Success', 'Record(s) Updated Successfully');
                self.doInitHelper(component);
            } else {
                var errors = response.getError();
                if (Array.isArray(errors) && errors.length && errors[0] && errors[0].message) {
                    self.showToast(component, 'Error', errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(component, type, message) {
        $A.util.addClass(component.find('Spinner'), 'slds-hide');
        component.find('notifLib').showToastModel(message, type.toLowerCase());
    }
})