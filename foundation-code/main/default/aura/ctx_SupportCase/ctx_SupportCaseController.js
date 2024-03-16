({
    /*doInit : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ctx_CreateSupportCase"
        });
        evt.fire();
        window.setTimeout(function(){
            $A.get("e.force:closeQuickAction").fire();
        },2000);
    },*/
	closeQuickAction : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})