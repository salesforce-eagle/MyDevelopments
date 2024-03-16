public class CTX_SendLoggerEmailNotifications {
    public static void sendEmailNotification(Map<Id, Logger__c> newMapLogger) {
        set<Id> assetIds 			= new set<Id>();
        List<Logger__c> loggerList 	= new List<Logger__c>();
        for(Logger__c logInstance : newMapLogger.values()){
            if(logInstance.Apex_Class__c == 'CTX_UpsertAssetLicense' && logInstance.Record_Id__c != NULL){
            	assetIds.add(logInstance.Record_Id__c); 
                loggerList.add(logInstance);
            }
        }
        if(!assetIds.isEmpty()){
            List<Messaging.SingleEmailMessage> 	mailList 		= new List<Messaging.SingleEmailMessage>();
        	Id 									defaultMailId 	= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                               Address =: System.Label.CSM_Journey_Org_Wide_Generic_Email ]?.Id;
            
            Map<Id,Asset> assetToCSMEmailMap = new Map<Id, Asset>([SELECT Id, License_Id__c, Account.Name, Account.Onboarding_Owner__r.Email, Account.Onboarding_Owner__r.Manager.Email FROM Asset WHERE Id IN : assetIds]);
            for(Logger__c logInstance : loggerList){
                Asset assetInst = assetToCSMEmailMap.get(logInstance.Record_Id__c);
                String licenseId = assetInst.License_Id__c != NULL ? assetInst.License_Id__c : 'Not Available';
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.SaveAsActivity = TRUE;
                mail.setWhatId(assetInst.Id);
                String Subject = '[!IMPORTANT] : License Creation Failure | ' + assetInst.Account?.Name;
                mail.setSubject(Subject);
                String body = 'Hello '+','+'<br/><br/>';
                body += 'License auto-renewal for below Asset has failed due to the following reason. Please fix & navigate to Asset URL and create license manually, to ensure customer is not blocked.'+'<br/><br/>';
                body += '<b>Response :</b>'+' '+logInstance.Error_Message__c+'<br/>';
                body += '<b>Asset URL :</b>'+' '+ URL.getSalesforceBaseUrl().toExternalForm()+'/'+assetInst.Id +'<br/>';
                body += '<b>License Id :</b>'+' '+ licenseId +'<br/>';
                body += ''+'<br/>';
                body +='Regards'+',<br/>'+'Team Salesforce'+'<br/>';
                mail.setHtmlBody(body);
                List<String> toAddresses = new List<String>();
                if(assetInst.Account?.Onboarding_Owner__r?.Email != NULL){
                    toAddresses.add(assetInst.Account?.Onboarding_Owner__r?.Email);
                }
                if(assetInst.Account?.Onboarding_Owner__r?.Manager?.Email != NULL){
                    toAddresses.add(assetInst.Account?.Onboarding_Owner__r?.Manager?.Email);
                }
                
                toAddresses.addAll(System.Label.CTX_LoggerNotificationEmailAddresses?.split(','));
                mail.setToAddresses(toAddresses);
                mail.setOrgWideEmailAddressId(defaultMailId);
                mailList.add(mail);
            }
            
            
            if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
            }
            catch (Exception ex) {
                System.debug('Unable to send CSM Intro email'+ ex.getMessage());
            }
        }
            
        }
    }
    
    public static void sapIntegrationErrorNotification(List<Logger__c> loggerList) {
        if(!loggerList.isEmpty()){
            List<Messaging.SingleEmailMessage> 	mailList 		= new List<Messaging.SingleEmailMessage>();
        	Id 									defaultMailId 	= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                               Address =: System.Label.CSM_Journey_Org_Wide_Generic_Email ]?.Id;
            for(Logger__c logInstance : loggerList){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.SaveAsActivity = TRUE;
                //mail.setWhatId(logInstance.Record_Id__c);
                String Subject = '[!IMPORTANT] | ' + logInstance.Error_Type__c;
                mail.setSubject(Subject);
                String body = 'Hello '+','+'<br/><br/>';
                body += logInstance.Error_Type__c +  + ' request Failed due to following reasons. Please fix the errors and ensure the data sync'+'<br/><br/>';
                body += '<b>Response :</b>'+' '+logInstance.Error_Message__c+'<br/>';
                body += '<b>Record Id :</b>'+' '+ logInstance.Record_Id__c +'<br/>';
                body += ''+'<br/>';
                body +='Regards'+',<br/>'+'Team Salesforce'+'<br/>';
                mail.setHtmlBody(body);
                List<String> toAddresses = new List<String>();
                
                toAddresses.addAll(System.Label.SF_SAP_Integration_Failure_Email_Addresses?.split(','));
                mail.setToAddresses(toAddresses);
                mail.setOrgWideEmailAddressId(defaultMailId);
                mailList.add(mail);
            }
            
            
            if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
            }
            catch (Exception ex) {
                System.debug('Unable to send CSM Intro email'+ ex.getMessage());
            }
        }
            
        }
    }
}