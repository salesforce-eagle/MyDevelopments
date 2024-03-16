({
    doInit : function(component, event, helper) {
        var modalBody;
        /*setTimeout(()=>{
            // Priority -> 1 || Please check if it will not work, consider Priority 2.
                //$A.get("e.force:closeQuickAction").fire(); 
            //Priority -> 2
                var stdModal = document.getElementsByClassName("uiModal forceModal");
                stdModal.forEach(function(a, b) {
                $A.util.addClass(a, "slds-hide");
                });
        },10);*/
        window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }),0
        ); 
      var recordId = component.get("v.recordId");
      console.log('Id '+recordId);
        $A.createComponent("c:quoteLineItemEditorForm", {'quoteId':recordId},
        function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content;
                component.find('overlayLib').showCustomModal({
                    header: "Quote Line Item",
                    body: modalBody,
                    showCloseButton: true,
                    cssClass: "slds-modal_medium",
                    closeCallback: function() {
                    }
                })
            }
        });
    }
})