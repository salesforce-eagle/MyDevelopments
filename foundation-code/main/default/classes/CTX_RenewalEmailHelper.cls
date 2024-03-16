public class CTX_RenewalEmailHelper {
    
    Public static void sendRenewalEmail(){
        
        Boolean 		isSuccess 			= FALSE;
        List<String> 	errorMessages 		= new List<String>();
        List<Asset> 	filteredAssetList 	= new list<Asset>();
        Date 			validatingDate 		= Date.today().addDays(30);
        Date 			DateToday 			= Date.Today();
        Id 				defaultMailId 		= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                               Address = 'e-invoicing@cleartaxmailer.com']?.Id;
        
        EmailTemplate 	emailTemplate 		= [ SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body 
                                               FROM EmailTemplate WHERE
                                               name = 'Renewal Email'];
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        filteredAssetList = [ SELECT id, Name, AccountId, Account.Owner.Id, Account.PGSB__c, UsageEndDate, Primary_POC__r.Email, Primary_POC__c, Account_owner_email__c,
                             Send_Renewal_Email__c, Renewal_Email_Sent__c, Additional_POC_1__c, Additional_POC_1__r.Email, Additional_POC_2__c, Additional_POC_2__r.Email 
                             FROM Asset WHERE 
                             Account.PGSB__c IN ('Silver', 'Bronze') AND
                             UsageEndDate <=:validatingDate AND 
                             UsageEndDate >=:DateToday AND 
                             Send_Renewal_Email__c = TRUE AND 
                             Renewal_Email_Sent__c = FALSE ];
        
        System.debug('filteredAssetList : '+filteredAssetList);
        System.debug('emailTemplate : '+emailTemplate.Id);
        
        for( Asset thisAsset : filteredAssetList ){
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(thisAsset.Primary_POC__r.Id);
            mail.setUseSignature(false);
            mail.SaveAsActivity = FALSE;
            mail.setWhatId(thisAsset.Id);
            mail.setTemplateId(emailTemplate.ID);
            List<String> ccAddresses = new List<String>();
            if(thisAsset.Primary_POC__c != NULL)
                ccAddresses.add(thisAsset.Primary_POC__r.Email);
            if(thisAsset.Additional_POC_1__c != NULL)
                ccAddresses.add(thisAsset.Additional_POC_1__r.Email);
            if(thisAsset.Additional_POC_2__c != NULL)
                ccAddresses.add(thisAsset.Additional_POC_2__r.Email);
            mail.setToAddresses(new String[]{thisAsset.Account_owner_email__c});
            mail.setccAddresses(ccAddresses);
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
        
        if(isSuccess){
            for(Asset thisRec : filteredAssetList){
                thisRec.Renewal_Email_Sent__c = TRUE;
            }
            Database.update(filteredAssetList,FALSE);
        }
        System.debug('Errors : ' +errorMessages);
    }
    
}