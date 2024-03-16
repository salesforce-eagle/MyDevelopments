public class CTX_CSMFlowEmailHelper {
    
    Public static void asset90DaysReminderEmail(List<Asset> assetList){
        List<String> 	errorMessages 		= new List<String>();
        List<Asset> 	filteredAssetList 	= new list<Asset>();
        Date 			validatingDate 		= Date.today().addDays(-90);
        Id 				defaultMailId 		= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                               Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        filteredAssetList = assetList;
        System.debug('filteredAssetList : '+filteredAssetList);
        
        for( Asset thisAsset : filteredAssetList ){
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String Subject = '90 Days Reminder For Asset '+thisAsset.Name+'.';
            mail.setSubject(Subject);
            mail.SaveAsActivity = True;
            mail.setWhatId(thisAsset.Id);
            String body = 'Hi '+thisAsset.Account.Onboarding_Owner__r.Name+','+'<br/>';
                body += 'It has been 90 days since the below asset was assigned. Please take necessary actions.'+'<br/>';
                body += '<b>Asset name :</b>'+' '+thisAsset.Name+'<br/>';
            	body += '<b>Asset Id :</b>'+' '+thisAsset.Id+'<br/>';
                body += ''+'<br/>';
                body += ''+'<br/>';
           		body +='Regards'+',<br/>'+'\n Asset Monitoring'+'<br/>';
            mail.setHtmlBody(body);
            mail.setToAddresses(new String[]{thisAsset.Account.Onboarding_Owner__r.Email});
            mail.setCcAddresses(new String[]{thisAsset.Account.Onboarding_Owner__r.Manager.Email});
            mail.setCcAddresses(new String[]{'bhavesh.jindal@cleartax.in'});
            mail.setOrgWideEmailAddressId(defaultMailId);
            mailList.add(mail);
        }
        
        system.debug('mailList: '+mailList.size());
        if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
            }
            catch (Exception ex) {
                errorMessages.add('Unable to send email'+ ex.getMessage());
            }
        }
        System.debug('Errors : ' +errorMessages);
    }
    
    Public static void onboardingAging15DaysNotification(){
        List<String> 	errorMessages 		= new List<String>();
        List<Asset> 	filteredAssetList 	= new list<Asset>();
        Date 			validatingDate 		= Date.today().addDays(-15);
        Date 			validatingDate2 	= Date.today().addDays(7);
        Id 				defaultMailId 		= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                               Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        
        filteredAssetList = [ SELECT id, Name, AccountId, Account_owner_email__c, Onboarding_Status__c, 
                             Account.Onboarding_Owner__r.Manager.Email , Account.Onboarding_Owner__r.Email,
                             Onboarding_process_start_date__c, PurchaseDate 
                             FROM Asset WHERE 
                             (Onboarding_process_start_date__c <=:validatingDate 
                              AND Onboarding_Status__c != 'Onboarding Complete') 
                             OR 
                             (PurchaseDate <=:validatingDate2
                              AND PurchaseDate >=: Date.today()
                              AND Onboarding_Status__c != 'Onboarding Complete')];
        
        system.debug('count : '+filteredAssetList.size()+' filteredAssetList' + filteredAssetList);
        
        for( Asset thisAsset : filteredAssetList ){
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String Subject = '15 Days Since Onboarding Started For Asset '+thisAsset.Name+'.';
            mail.setSubject(Subject);
            mail.SaveAsActivity = TRUE;
            mail.setWhatId(thisAsset.Id);
            String body = 'Hi '+thisAsset.Account.Onboarding_Owner__r.Name+','+'<br/>';
                body += 'It has been 15 days since the Onvoarding Process for below asset was Started and not Completed yet. Please take necessary actions.'+'<br/>';
                body += '<b>Asset Name :</b>'+' '+thisAsset.Name+'<br/>';
            	body += '<b>Asset Id :</b>'+' '+thisAsset.Id+'<br/>';
                body += ''+'<br/>';
                body += ''+'<br/>';
                body +='Regards'+',<br/>'+'\n Asset Monitoring'+'<br/>';
            mail.setHtmlBody(body);
            mail.setToAddresses(new String[]{thisAsset.Account.Onboarding_Owner__r.Email});
            mail.setCcAddresses(new String[]{thisAsset.Account.Onboarding_Owner__r.Manager.Email});
            mail.setCcAddresses(new String[]{'bhavesh.jindal@cleartax.in'});
            mail.setOrgWideEmailAddressId(defaultMailId);
            mailList.add(mail);
        }
        
        system.debug('mailList: '+mailList.size());
        if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
            }
            catch (Exception ex) {
                errorMessages.add('Unable to send email'+ ex.getMessage());
            }
        }
        System.debug('Errors : ' +errorMessages);
    }
    
    Public static void exepctedOnboardingCompletionDateNotification(){
        List<String> 	errorMessages 		= new List<String>();
        List<Asset> 	filteredAssetList 	= new list<Asset>();
        Date 			validatingDate 		= Date.today().addDays(-15);
        Id 				defaultMailId 		= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                               Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        
        filteredAssetList = [ SELECT id, Name, AccountId, Account_owner_email__c, Onboarding_Status__c, 
                             Account.Onboarding_Owner__r.Manager.Email , Account.Onboarding_Owner__r.Email,
                             Expected_Onboarding_Completion_Date_c__c, PurchaseDate 
                             FROM Asset WHERE 
                             Onboarding_Status__c != 'Onboarding Complete' ];
        
        system.debug('count : '+filteredAssetList.size()+' filteredAssetList' + filteredAssetList);
        
        for( Asset thisAsset : filteredAssetList ){
            if(thisAsset.Expected_Onboarding_Completion_Date_c__c > thisAsset.PurchaseDate){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String Subject = 'Expected Onboarding Completion Date is late For Asset '+thisAsset.Name+'.';
                mail.setSubject(Subject);
                mail.SaveAsActivity = TRUE;
                mail.setWhatId(thisAsset.Id);
                String body = 'Hi '+thisAsset.Account.Onboarding_Owner__r.Name+','+'<br/>';
                    body += 'It looks like the Onvoarding Process for below asset will get comleted later than its Period Start Date. Please take necessary actions.'+'<br/>';
                    body += '<b>Asset Name :</b>'+' '+thisAsset.Name+'<br/>';
                	body += '<b>Asset Id :</b>'+' '+thisAsset.Id+'<br/>';
                    body += '<b>Asset Expected Onboarding Complete Date :</b>'+' '+thisAsset.Expected_Onboarding_Completion_Date_c__c+'<br/>';
                    body += '<b>Asset Period Start Date :</b>'+' '+thisAsset.PurchaseDate+'<br/>';
                    body += ''+'<br/>';
                    body += ''+'<br/>';
                    body +='Regards'+',<br/>'+'\n Asset Monitoring'+'<br/>';
                mail.setHtmlBody(body);
                mail.setToAddresses(new String[]{thisAsset.Account.Onboarding_Owner__r.Email});
                mail.setCcAddresses(new String[]{thisAsset.Account.Onboarding_Owner__r.Manager.Email});
                mail.setCcAddresses(new String[]{'bhavesh.jindal@cleartax.in'});
                mail.setOrgWideEmailAddressId(defaultMailId);
                mailList.add(mail);
            }
        }
        
        system.debug('mailList: '+mailList.size());
        if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
            }
            catch (Exception ex) {
                errorMessages.add('Unable to send email'+ ex.getMessage());
            }
        }
        System.debug('Errors : ' +errorMessages);
    }
    
    Public static void assetCreationDateGreaterThanPeriodStartDateNotification(){
        List<String> 	errorMessages 		= new List<String>();
        List<Asset> 	filteredAssetList 	= new list<Asset>();
        Date 			validatingDate 		= Date.today().addDays(-15);
        Id 				defaultMailId 		= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                               Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        
        filteredAssetList = [ SELECT id, Name, AccountId, Account_owner_email__c, Onboarding_Status__c, 
                             Account.Onboarding_Owner__r.Manager.Email , Account.Onboarding_Owner__r.Email, 
                             Asset_Creation_date_PO_start_date__c 
                             FROM Asset WHERE 
                             Asset_Creation_date_PO_start_date__c = 'Yes' ];
        
        system.debug('count : '+filteredAssetList.size()+' filteredAssetList' + filteredAssetList);
        
        for( Asset thisAsset : filteredAssetList ){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String Subject = 'Creation Date is greater than Period Start Date For Asset '+thisAsset.Name+'.';
                mail.setSubject(Subject);
                mail.SaveAsActivity = TRUE;
                mail.setWhatId(thisAsset.Id);
                String body = 'Hi '+thisAsset.Account.Onboarding_Owner__r.Name+','+'<br/>';
                    body += 'It looks like the Creation Date of below asset is later than its Period Start Date. Please take necessary actions.'+'<br/>';
                    body += '<b>Asset Name :</b>'+' '+thisAsset.Name+'<br/>';
            		body += '<b>Asset Id :</b>'+' '+thisAsset.Id+'<br/>';
                    body += ''+'<br/>';
                    body += ''+'<br/>';
                    body +='Regards'+',<br/>'+'\n Asset Monitoring'+'<br/>';
                mail.setHtmlBody(body);
                mail.setToAddresses(new String[]{thisAsset.Account.Onboarding_Owner__r.Email});
                mail.setCcAddresses(new String[]{thisAsset.Account.Onboarding_Owner__r.Manager.Email});
                mail.setCcAddresses(new String[]{'bhavesh.jindal@cleartax.in'});
                mail.setOrgWideEmailAddressId(defaultMailId);
                mailList.add(mail);
        }
        
        system.debug('mailList: '+mailList.size());
        if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
            }
            catch (Exception ex) {
                errorMessages.add('Unable to send email'+ ex.getMessage());
            }
        }
        System.debug('Errors : ' +errorMessages);
    }
    
    Public static void salesHandover2DaysNotification(){
        Boolean 		isSuccess 			= FALSE;
        List<String> 	errorMessages 		= new List<String>();
        List<Asset> 	filteredAssetList 	= new list<Asset>();
        Date 			validatingDate 		= Date.today().addDays(-2);
        Id 				defaultMailId 		= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                               Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        
        filteredAssetList = [ SELECT id, Name, AccountId, Account.Owner.Email, Account_owner_email__c, Sales_handover_status__c , 
                             Account.Onboarding_Owner__r.Manager.Email ,
                             Sales_handover_start_date__c, Number_of_notification_sent_to_Sales_POC__c 
                             FROM Asset WHERE 
                             Sales_handover_start_date__c <=:validatingDate 
                             AND Sales_handover_status__c  != 'Completed' ];
        
        system.debug('count : '+filteredAssetList.size()+' filteredAssetList' + filteredAssetList);
        
        for( Asset thisAsset : filteredAssetList ){
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String Subject = '2 Days Since Sales Handover Started For Asset '+thisAsset.Name+'.';
            mail.setSubject(Subject);
            mail.SaveAsActivity = TRUE;
            mail.setWhatId(thisAsset.Id);
            String body = 'Hi '+thisAsset.Account.Owner.Name+','+'<br/>';
                body += 'The Sales handover for below asset was Started and not Completed yet. Please take necessary actions.'+'<br/>';
                body += '<b>Asset Name :</b>'+' '+thisAsset.Id+'<br/>';
            	body += '<b>Asset Id :</b>'+' '+thisAsset.Name+'<br/>';
                body += ''+'<br/>';
                body += ''+'<br/>';
                body +='Regards'+',<br/>'+'\n Asset Monitoring'+'<br/>';
            mail.setHtmlBody(body);
            mail.setToAddresses(new String[]{thisAsset.Account.Owner.Email});
            mail.setCcAddresses(new String[]{thisAsset.Account.Onboarding_Owner__r.Manager.Email});
            mail.setCcAddresses(new String[]{'bhavesh.jindal@cleartax.in'});
            mail.setOrgWideEmailAddressId(defaultMailId);
            mailList.add(mail);
        }
        
        system.debug('mailList: '+mailList.size());
        if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
                isSuccess = TRUE;
            }
            catch (Exception ex) {
                errorMessages.add('Unable to send email'+ ex.getMessage());
            }
        }
        System.debug('Errors : ' +errorMessages);
        
        if(isSuccess){
            for(Asset thisRec : filteredAssetList){
                if(thisRec.Number_of_notification_sent_to_Sales_POC__c == NULL){
                    thisRec.Number_of_notification_sent_to_Sales_POC__c = 0;
                    thisRec.Number_of_notification_sent_to_Sales_POC__c = thisRec.Number_of_notification_sent_to_Sales_POC__c + 1;
                }
                else{
                    thisRec.Number_of_notification_sent_to_Sales_POC__c = thisRec.Number_of_notification_sent_to_Sales_POC__c + 1;
                }
            }
            Database.update(filteredAssetList,FALSE);
        }
        System.debug('Errors : ' +errorMessages);
    }

}