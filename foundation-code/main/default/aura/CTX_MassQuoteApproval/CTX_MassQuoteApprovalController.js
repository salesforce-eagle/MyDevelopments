({
 doInit : function(component, event, helper) {
 helper.doInitHelper(component);
 },
 
 handleApprove : function(component, event, helper) {
 helper.handleSelectedRows(component, event, 'Approve');
 },
 
 handleReject : function(component, event, helper) {
 helper.handleSelectedRows(component, event, 'Reject');
 },
    
    navigateToRecord: function (component, event, helper) {
 var recordId = event.currentTarget.id;
        var base_url = window.location.origin;
        var newUrl = base_url + '/' + recordId;
        window.open(newUrl, '_blank');
 },
})