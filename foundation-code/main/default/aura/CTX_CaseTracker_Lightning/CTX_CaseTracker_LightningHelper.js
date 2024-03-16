({
	waitingTimeId: null,
    setStartTimeOnUI : function(component) {
        component.set("v.disableOtp",false);
        var currTime =component.get("v.ltngTimmer");
        var ss = currTime.split(":");
        var dt = new Date();
        dt.setMinutes(ss[0]);
        dt.setSeconds(ss[1]);
        
        var dt2 = new Date(dt.valueOf() - 1000);
        var temp = dt2.toTimeString().split(" ");
        var ts = temp[0].split(":");
        
        component.set("v.ltngTimmer",ts[1] + ":" + ts[2]);
        this.waitingTimeId =setTimeout($A.getCallback(() => this.setStartTimeOnUI(component)), 1000);
        if(ts[1]==0 && ts[2]==0){
            component.set("v.ltngTimmer","EXPIRED");
            window.clearTimeout(this.waitingTimeId);
            component.set("v.disableOtp",true);
        }
    },
    
     setClearTimeout : function(component) {
        window.clearTimeout(this.waitingTimeId);
    }

})