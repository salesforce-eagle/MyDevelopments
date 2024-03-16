({
    doInit : function(component, event, helper) {
        helper.onInit(component, event, helper);
    },
    closeMessage: function(component, event, helper) {
        component.set("v.leadStatus", false);
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})