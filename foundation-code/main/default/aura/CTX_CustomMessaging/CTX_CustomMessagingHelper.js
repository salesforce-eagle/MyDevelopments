({
    sendEmail : function(component) {
        
        var oLatestMail 	= component.get("v.latestEmailMessage");
        var sFromAddress	= component.get("v.getCaseEmail");
        var sToAddress 		= oLatestMail.ToAddress;
        var sCCAddress 		= oLatestMail.CCAddress;
        var sSubject 		= oLatestMail.Subject;
        var sParentId 		= oLatestMail.ParentId;
        var sTextBody 		= component.get("v.myMessage");
        
        var action			= component.get("c.createEmailMessage");
        action.setParams({
            "fromAddress"	: sFromAddress,
            "toAddress" 	: sToAddress,
            "ccAddress" 	: sCCAddress,
            "subject" 		: sSubject,
            "parentId" 		: sParentId,
            "body" 			: sTextBody
            
        });
        
        action.setCallback(this,function(e){
            if(e.getState() == 'SUCCESS'){
                
                var result = e.getReturnValue();
                
                if(result == 'Success'){
                    alert('Email Send Successfully!');
                    component.set("v.hideBlock", false);
                } else{

                }
            } else{
                alert(JSON.stringify(e.getError()));
            }
        });
        
        $A.enqueueAction(action);
    },
    
    _e:function(ele){
        return document.getElementById(ele);
    },
})