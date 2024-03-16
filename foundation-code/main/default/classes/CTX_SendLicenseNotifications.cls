public class CTX_SendLicenseNotifications {
    public static void sendExtensionEmail(List<Asset> assetList, Map<Id, Asset> oldAssetMap){
        List<Messaging.SingleEmailMessage> 	mailList 		= new List<Messaging.SingleEmailMessage>();
        Id 									defaultMailId 	= [SELECT Id FROM OrgWideEmailAddress WHERE 
                                                               Address =: System.Label.CSM_Intoductory_Mail_Org_Wide_Generic_Email]?.Id;
        for(Asset assetInstance : [SELECT Id, Account.Name, Account.Owner.Email, Account.Onboarding_Owner__r.Email, Product2.Name, Extended_Period_End_Date__c, Days_To_Extend__c, License_Id__c FROM Asset WHERE Id IN : assetList]){
            
            Asset oldAssetInstance = oldAssetMap.get(assetInstance.Id);
            if(assetInstance.Extended_Period_End_Date__c != oldAssetInstance.Extended_Period_End_Date__c && assetInstance.Extended_Period_End_Date__c != NULL){
                List<String> toAddresses = new List<String>{assetInstance.Account.Owner.Email};
                if(assetInstance.Account?.Onboarding_Owner__r?.Email != NULL){
                	toAddresses.add(assetInstance.Account.Onboarding_Owner__r.Email);
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.SaveAsActivity = TRUE;
                mail.setWhatId(assetInstance.Id);
                mail.setSubject('License Extension : '+ assetInstance.Account.Name + ' | ' + assetInstance.Product2.Name);
                String body = 'Hello, <br/><br/>';
                body += 'Following License has been extended by ' + assetInstance.Days_To_Extend__c.IntValue() + ' days. Find the details of extension below,<br/><br/>';
                body += '<b>Asset Link :</b> ' + URL.getSalesforceBaseUrl().toExternalForm()+'/'+assetInstance.Id +'<br/>';
                body += '<b>License Id :</b> ' + assetInstance.License_Id__c + '<br/>';
                body += '<b>Extended Period End Date :</b> ' + assetInstance.Extended_Period_End_Date__c + '<br/><br/>';
                body += 'Regards,<br/>';
            	body += 'Team Clear (formerly known as ClearTax)<br/>';
                mail.setHtmlBody(body);
                mail.setToAddresses(toAddresses);
                mail.setOrgWideEmailAddressId(defaultMailId);
                mailList.add(mail);
            }
        }
        
        if(!mailList.isEmpty()) {
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
            }
            catch (Exception ex) {
                System.debug('Unable to send CSM Intro email'+ ex.getMessage());
            }
        }
    }

}