({
	doInit : function(component, event, helper) {
        console.log($A.get("$Label.c.CTX_Default_RecordType_Test_Asset"));
        var recordTypeId = $A.get("$Label.c.CTX_Default_RecordType_Test_Asset");
        var createAcountContactEvent = $A.get("e.force:createRecord");
        createAcountContactEvent.setParams({
            "entityApiName": "Asset",
            "recordTypeId": recordTypeId,
            "defaultFieldValues": {
                "AccountId" : component.get("v.recordId"),
                'Is_Test_Asset__c' : true,
                'Price' : 0
            }
        });
        createAcountContactEvent.fire();	
    }
})