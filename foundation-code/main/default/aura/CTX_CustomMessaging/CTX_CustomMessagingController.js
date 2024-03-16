({
    send : function(component, event, helper) {
        
        var Message=component.get("v.myMessage");        

        if(Message==''){
            alert('Message is required');
        } else{
            helper.sendEmail(component);
        }
    },
    
    showSpinner: function(component, event, helper) {        
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){        
        component.set("v.Spinner", false);
    },
    
    handleCancel : function(component,event,helper){
        component.set("v.hideBlock", false);
    },


})



/**	var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/; 	**/