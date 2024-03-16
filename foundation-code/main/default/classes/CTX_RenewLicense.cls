@RestResource(urlMapping='/renewLicense')
global class CTX_RenewLicense{
    
    @HttpPut
    global static String renewLicense() { 
        
        Map<String, Object> 						renewalDetails	= (Map<String, Object>)System.JSON.deserializeUntyped( RestContext.request.requestBody.toString() ); 
        CTX_AutoRenewLicenseHelper.PaymentWrapper 	paymentWrapper	= new CTX_AutoRenewLicenseHelper.PaymentWrapper();
        String 										licenseId		= (String)renewalDetails?.get('licenseId'); 
        String 										paymentMethod 	= (String)renewalDetails?.get('paymentMode');
        String 										invoiceContent 	= (String)renewalDetails?.get('invoiceContent');
        String 										omsOrderId 		= (String)renewalDetails?.get('omsOrderId');
        String										planTier		= (String)renewalDetails?.get('planTier');
        Blob 										invoice 		= invoiceContent != NULL ? Blob.valueOf(invoiceContent) : NULL;
        
        paymentWrapper.invoice 			= invoiceContent;
        paymentWrapper.omsOrderId 		= (String)renewalDetails?.get('omsOrderId');
        paymentWrapper.paymentMode 		= (String)renewalDetails?.get('paymentMode');
        paymentWrapper.previousLicense	= licenseId;
        
        system.debug('planTier Renew License : '+planTier);
        system.debug('renewalDetails Renew License : '+renewalDetails);

        /** POST PAYMENT ACTIONS **/
        
        CTX_AutoRenewLicenseHelper.AssetWrapper astWrapper  = CTX_AutoRenewLicenseHelper.postPaymentActions(licenseId, planTier, paymentWrapper);
        system.debug('@astWrapper : '+astWrapper);
        
        /**	GET DETAILS OF PAYMENT METHOD AND NAVIGATE BASED ON THE OPERATION : start	**/
        HttpResponse response  = CTX_AutoRenewLicenseHelper.paymentUtility(paymentWrapper, astWrapper);
        /**	GET DETAILS OF PAYMENT METHOD AND NAVIGATE BASED ON THE OPERATION : end	**/
        
        
        if( response.getStatusCode() == 200 ){   
            
            OpportunityConstants.AUTO_RENEW_RULE 			= FALSE;
            RecursiveTriggerHandler.isFirstTimeOpportunity 	= FALSE;
            /*if(paymentWrapper.paymentMode == 'PAY_NOW'){
if(invoiceContent != NULL){
ContentDocumentLink contentDoc = CTX_AutoRenewLicenseHelper.generateInvoice(invoiceContent, astWrapper.oppRec); 
astWrapper.upsertObjs.add(contentDoc);     
} 
}*/
            
            try{
                Database.update(astWrapper.updateQli, FALSE);
                Database.update(astWrapper.updateOpp, FALSE);
                OpportunityConstants.AUTO_RENEW_RULE 			= TRUE;
                RecursiveTriggerHandler.isFirstTimeOpportunity 	= FALSE; 
            } catch( Exception ex){
                CTX_SendEmailOnAutoRenewalFailure.sendMailOnPostPaymentFailure(astWrapper, paymentMethod, omsOrderId, ex );
            }
        } else{
            CalloutException e = new CalloutException();
            e.setMessage(response.getBody());
            throw e;
        }
        
        
        
        return response.getBody();
        
    }
    
}