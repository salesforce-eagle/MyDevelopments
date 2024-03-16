global class CTX_SuspendLicenseOnPaymentFail IMPLEMENTS 
Database.Batchable<sObject>, 
Database.Stateful, 
Database.AllowsCallouts, 
Schedulable, 
Database.RaisesPlatformEvents{
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        Set<String>	assetIdSet = getListOfAssetsToDeactivate();
        system.debug('assetIdSet: '+assetIdSet);
        
        String query = ' SELECT Id, License_Id__c, Status, StatusReason, IsInternal, ManufactureDate, Description, Price, '+
            ' AccountId, Account.Product_Email__c, Account.Name, Account.Owner.Email, Account.Onboarding_Owner__r.Email, '+
            ' Account.Country_of_Origin__c, Account.Collection_Manager__c, '+
            ' Product2.Name, Product2.OrderForm_Product_Name__c, '+
            ' ( SELECT Id, Invoice_Due_Date__c, Outstanding_Payment__c FROM Billing_Details__r ) '+
            ' FROM Asset WHERE Id IN :assetIdSet AND License_Id__c != NULL ';
        
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> licensesToDeactivate) {
        
        deactivateAssetsBasedOnNonPaymentReceive(licensesToDeactivate);
    }
    
    global void finish(Database.BatchableContext BC){}
    
    global void execute(SchedulableContext sc) {
        database.executebatch(new CTX_SuspendLicenseOnPaymentFail(),1);
    }
    
    public static void deactivateAssetsBasedOnNonPaymentReceive( List<Asset> licensesToDeactivate ){
        
        Map<Id, Asset> 	deactivatedAssetMap 		= new Map<Id, Asset>();
        Map<Id, Asset> 	deactivateFailedAssetMap 	= new Map<Id, Asset>();
        
        
        if( licensesToDeactivate != NULL && licensesToDeactivate.size() > 0 ){
            for( Asset thisRec : licensesToDeactivate ){	
                String region = thisRec.Account?.Country_of_Origin__c != null ? thisRec.Account?.Country_of_Origin__c : 'INDIA';
                
                try{
                    HttpResponse resp = CTX_LicensingAPICalloutClass.deactivateLicenseCallout(thisRec.License_ID__c, region);
                    System.debug('deactivateAssetsBasedOnNonPaymentReceive Callout Response: '+resp.getBody());
                    
                    if( resp.getStatusCode() == 200 || resp.getStatusCode() == 201 ){
                        System.debug('Success');
                        
                        thisRec.StatusReason 	= 'Non Payment Suspended';
                        thisRec.IsInternal 		= TRUE;
                        thisRec.ManufactureDate = system.today();
                        thisRec.License_Id__c 	= NULL;
                        
                        deactivatedAssetMap.put(thisRec.Id, thisRec);
                    } else{
                        System.debug('Service Error');
                        thisRec.Description = resp.getBody();
                        deactivateFailedAssetMap.put(thisRec.Id, thisRec);
                    }
                }catch(Exception ex){
                    
                    system.debug('error: '+ex.getMessage());
                }
                
            }
            
            /**	Success Cases	**/
            if(deactivatedAssetMap.size() > 0){
                system.debug('deactivatedAssetMap: '+deactivatedAssetMap);
                system.debug('deactivatedAssetMap.size: '+deactivatedAssetMap.size());
                runDeactivationSuccessActionables(deactivatedAssetMap);
            }
            /**	Failure Cases	**/
            if(deactivateFailedAssetMap.size() > 0){
                system.debug('deactivateFailedAssetMap: '+deactivateFailedAssetMap);
                system.debug('deactivateFailedAssetMap.size: '+deactivateFailedAssetMap.size());
                runDeactivationFailureActionables(deactivateFailedAssetMap);
            }
            
        }
    }
    
    public static void runDeactivationSuccessActionables( Map<Id, Asset> deactivatedAssetMap ){
        /**	StatusReason = Non Payment Suspended || IsInternal = TRUE || ManufactureDate = system.today()	**/
        system.debug('Deactivation success block');
        
        Boolean isMailSent = FALSE;
        try{
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail( sendEmailOnAssetDeactivation(deactivatedAssetMap) );
            isMailSent = TRUE;
            if(results.size()>0){
                if (results[0].success) 
                {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                }
            }
            
            try{
                RecursiveTriggerHandler.isFirstTime = FALSE;
                RecursiveTriggerHandler.isFirstTimeRenewed = FALSE;
                
                update deactivatedAssetMap.values();
                
                RecursiveTriggerHandler.isFirstTime = TRUE;
                RecursiveTriggerHandler.isFirstTimeRenewed = TRUE;
            } catch(Exception e){
                System.debug(' Exception on Asset Update \n'+e.getMessage()+'\n'+e.getLineNumber());
            }
            
        }Catch(Exception ex){
            System.debug(' Exception on EMail Send - Mail Sent \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
        
        if( !isMailSent ){
            try{
                RecursiveTriggerHandler.isFirstTime = FALSE;
                RecursiveTriggerHandler.isFirstTimeRenewed = FALSE;
                
                update deactivatedAssetMap.values();
                
                RecursiveTriggerHandler.isFirstTime = TRUE;
                RecursiveTriggerHandler.isFirstTimeRenewed = TRUE;
            } catch(Exception e){
                System.debug(' Exception on Asset Update - Mail Not Sent \n'+e.getMessage()+'\n'+e.getLineNumber());
            }
        } else {
            
        }
        
        
    }
    
    public static void runDeactivationFailureActionables( Map<Id, Asset> deactivateFailedAssetMap ){
        
        system.debug('Deactivation failure block');
        try{
            RecursiveTriggerHandler.isFirstTime = FALSE;
            RecursiveTriggerHandler.isFirstTimeRenewed = FALSE;
            /**	 Mail not sent box to be added	**/
            update deactivateFailedAssetMap.values();
            
            RecursiveTriggerHandler.isFirstTime = TRUE;
            RecursiveTriggerHandler.isFirstTimeRenewed = TRUE;
        } catch(Exception ex){
            system.debug( 'runDeactivationFailureActionables failure: '+ex.getMessage() );
        }
        
    }
    
    public static Messaging.SingleEmailMessage[] sendEmailOnAssetDeactivation( Map<Id, Asset> deactivatedAssetMap ){
        
        system.debug('Inside Send Email Class');
        Id 								defaultMailId 	= [ SELECT Id FROM OrgWideEmailAddress WHERE Address = :system.label.AR_Mail ]?.Id;
        Messaging.SingleEmailMessage[] 	mails 			= new List<Messaging.SingleEmailMessage>();
        
        for( Asset thisRec : deactivatedAssetMap.values() ){
            
            Date deuDate = thisRec.Billing_Details__r != NULL ? 
               thisRec.Billing_Details__r[0].Invoice_Due_Date__c : NULL;
            
            Integer dueAmount = thisRec.Billing_Details__r != NULL ? 
               (Integer)thisRec.Billing_Details__r[0].Outstanding_Payment__c : 0;
                 
            
            String body = 'Dear '+thisRec.Account.Name+',<br></br><br></br>';
            body += 'We regret to inform you that your services for <b>'+thisRec.Product2.OrderForm_Product_Name__c+'</b> has been temporarily deactivated due to non-payment of dues amounting to ';
            body += 'INR <b>'+dueAmount+'</b> which was due on <b>'+deuDate.format()+'</b>. <br></br><br></br>';
            body += 'To reactivate your account and resume services, please make the payment immediately and share the payment details as a reply to this email.<br></br><br></br>';
            body += 'Once the payment is successfully processed, your license will be reactivated within 24 hours.<br></br><br></br>';
            body += 'If you have any questions or require assistance, please reply to this email.<br></br><br></br>';
            body += 'Best regards,<br></br>';
            body += 'AR Team<br></br> Defmacro Software Private Limited (Cleartax)';
            
            Messaging.SingleEmailMessage 	mail 		= new Messaging.SingleEmailMessage();
            List<String> 					toAddress	= new List<String>();
            List<String> 					ccAddress	= new List<String>();
            
            if(system.label.Bulk_deactivation_Test == 'YES'){
                
                toAddress.add('bibhuda.dash@clear.in');
                toAddress.add('harsh.thakkar@clear.in');
                ccAddress.add('bibhuda.dash@clear.in');
                ccAddress.add('harsh.thakkar@clear.in');
                
            }
            
            if(system.label.Bulk_deactivation_Test == 'NO'){
                if(thisRec.Account.Product_Email__c != NULL)
                    toAddress.add(thisRec.Account.Product_Email__c);
                if(thisRec.Account.Owner.Email != NULL)
                    ccAddress.add(thisRec.Account.Owner.Email);
                if(thisRec.Account.Onboarding_Owner__r.Email != NULL)
                    ccAddress.add(thisRec.Account.Onboarding_Owner__r.Email);
                if(thisRec.Account.Collection_Manager__c != NULL)
                    ccAddress.add(thisRec.Account.Collection_Manager__c);
                
                ccAddress.add('ar@clear.in');
                ccAddress.add('bibhuda.dash@clear.in');
                ccAddress.add('harsh.thakkar@clear.in');
                
                if( toAddress.size() <= 0 ){
                    toAddress.add('bibhuda.dash@clear.in');
                    toAddress.add('harsh.thakkar@clear.in');
                }
            }
            
            
            
            mail.setOrgWideEmailAddressId(defaultMailId);
            mail.setToAddresses(toAddress);
            mail.setCCAddresses(ccAddress); 
            mail.setSubject('Urgent: Cleartax Account Deactivation due to non-payment | '+thisrec.Account.Name);
            mail.setBccSender(false);
            mail.setHtmlBody(body);
            mails.add(mail);
        }
        
        
        return mails;
    }
    
    public static set<String> getListOfAssetsToDeactivate(){
        
        ContentVersion 		contentDocumentVersionDetails	= [ SELECT VersionData FROM ContentVersion WHERE 
                                                               ContentDocumentId = :system.label.Bulk_Deactivation_File_Label AND 
                                                               IsLatest = TRUE ];
        Blob 				versionDataStringBody 			= contentDocumentVersionDetails.VersionData;
        List<String> 		columnLiner						= versionDataStringBody.tostring().split('\n');
        Set<String>			assetIdSet						= new Set<String>();
        
        for( Integer i = 1; i < columnLiner.size(); i++ ){
            assetIdSet.add( columnLiner[i].split(',')[0].trim() );
            system.debug( 'Asset Ids: '+columnLiner[i].split(',')[0].trim() );
        }
        
        return assetIdSet;
    }
    
    
}