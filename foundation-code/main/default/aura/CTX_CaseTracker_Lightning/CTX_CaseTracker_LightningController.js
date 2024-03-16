({
    
    init: function (component, event, helper){},
    
    
    getCaseDetails : function(component, event, helper){
        
        component.set('v.disableFields', true);
        component.set('v.showLoading', true);
        var action = component.get("c.fetchCaseDetails");
        action.setParams({ 
            "caseNumber" : component.get('v.getCaseNumber'),
            "caseEmail" : component.get('v.getCaseEmail')
        });
        
        action.setCallback(this, function(response){
            
            var state = response.getState();
            
            if(state == 'SUCCESS'){
                
                var oResult		= response.getReturnValue();
                var mTilevalues	= [];
                var mTileMap 	= {};
                if(oResult != undefined){
                    
                    component.set('v.returnResult', oResult);
                    
                    if(oResult.isSuccess){

                        component.set('v.caseDetails'			, oResult.myCase);
                        component.set('v.caseNumber'			, oResult.caseNumber);
                        component.set('v.caseStatus'			, oResult.caseStatus);
                        component.set('v.caseSLA'				, oResult.caseSLA);
                        component.set('v.caseCreatedDate'		, $A.localizationService.formatDate(oResult.caseCreatedDate, "MMMM dd yyyy, hh:mm:ss a"));
                        component.set('v.caseLastModifiedDate'	, $A.localizationService.formatDate(oResult.caseLastModifiedDate, "MMMM dd yyyy, hh:mm:ss a"));
                        component.set('v.isEmailsAvailable'		, oResult.isMailThreadAvailable);
                        component.set('v.caseEmails'			, oResult.caseEmails);
                        component.set('v.latestEmailMessage'	, oResult.latestEmailMessage);
                        component.set('v.comparingOTP'			, oResult.generatedOTP);
                        component.set('v.showLoading'			, false);
                        
                        /** Show OTP Modal **/
                        component.set("v.showOtpModal", true);

                        for(var i in oResult.caseEmails){
                            oResult.caseEmails[i]['CreatedDate'] = $A.localizationService.formatDate(oResult.caseEmails[i].CreatedDate, "MMMM dd yyyy, hh:mm:ss a");
                        }
                        
                        mTileMap['Case Number'] 			= oResult.caseNumber;
                        mTileMap['Status'] 					= oResult.caseStatus;
                        if(oResult.caseStatus != undefined && oResult.caseStatus != 'Closed')
                            mTileMap['Expected Resolution'] = oResult.caseSLA;
                        mTileMap['Created On'] 				= $A.localizationService.formatDate(oResult.caseCreatedDate, "MMMM dd yyyy, hh:mm:ss a");
                        mTileMap['Subject'] 				= oResult.caseSubject;
                        
                        for(var i in mTileMap){
                            mTilevalues.push({key: i, value: mTileMap[i]});
                        }
                        component.set('v.tileMap', mTilevalues);
                        
                        var minutes = component.get("v.ltngMinute");
                        var seconds = component.get("v.ltngSecond");
                        component.set("v.ltngTimmer",minutes+":"+seconds);
                        helper.setStartTimeOnUI(component);
                        
                        /**	Post OTP Varification : START **/
                        
                        /**	Post OTP Varification : END	**/
                        
                        
                        
                        
                    } else{
                        component.set('v.isResultAvailable'	, false);
                        component.set('v.errorMessage'		, oResult.errorMessage);
                        component.set('v.showErrorMessage'	, true);
                        component.set('v.showLoading'		, false);
                        
                    }
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    submitOTP: function(component, event, helper) {
        
        var inputCmp = component.find("inputOTP");

        if(component.get("v.comparingOTP") == component.get("v.getOTP")){
            //alert("OTP is Correct!");
            inputCmp.setCustomValidity("");
            component.set("v.showOtpModal", false);
            component.set('v.isResultAvailable'		, true);
            component.set('v.showErrorMessage'		, false);
            helper.setClearTimeout(component);
            
        }
        else{
            //alert("OTP is invalid!");
            inputCmp.setCustomValidity("OTP is invalid!");
        }
        inputCmp.reportValidity();
   },
    
    
    handleClear : function(component, event, helper){
        component.set('v.getCaseNumber'		, '');
        component.set('v.getCaseEmail'		, '');
        component.set('v.disableFields'		, false);
        component.set('v.errorMessage'		, '');
        component.set('v.isResultAvailable'	, false);
        component.set('v.isEmailsAvailable'	, false);
        component.set('v.showErrorMessage'	, false);
        component.set('v.showLoading'		, false);
        component.set('v.showOtpModal'		, false);
        helper.setClearTimeout(component);
    },
    
    
    toggleAccordion : function(component, event, helper){
        component.set("v.showAccordion", !component.get("v.showAccordion"));
    },
    
    
    handleReplay : function(component, event, helper){
        component.set('v.replayAllBlock', true);
    },
    
    
    closeModel: function(component, event, helper) {
      component.set("v.replayAllBlock", false);
   },
  
    
})