public class CTX_AssetExpirationReminderEmailsShooter {
    
    public static void sendEmailAlertForReminder(){
        
        List<Messaging.SingleEmailMessage> 	mailList 		= new List<Messaging.SingleEmailMessage>();
        Id 									defaultMailId 	= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                               Address =: system.label.GccAssetExoirationOrgWideEmail ]?.Id;
        Boolean 							isSuccess 		= FALSE;
        List<String> 						errorMessages 	= new List<String>();
        
        Date 	ninetyDays 		= System.Today().addDays(90);
        Date 	sixtyDays 		= System.Today().addDays(60);
        Date 	thirtyDays 		= System.Today().addDays(30);
        Date 	threeDays 		= System.Today().addDays(3);
        Date 	expired7Days 	= System.Today().addDays(-7);
        
        List<Asset> assetList = [SELECT Id, Name, OwnerId, Product_Name__c, Billing_Type__c, UsageEndDate, Account.Onboarding_Owner__r.Email, Account.Onboarding_Owner__c,
                                 Account.Name, Account.OwnerId, Account.Owner.Email, Account.Owner.Name, Owner.Email, Account.Onboarding_Owner__r.Name, 
                                 Account.Owner.Manager.email, Account.Sales_Owner__r.ManagerId, Account.Sales_Owner__r.Manager.Email
                                 FROM Asset 
                                 WHERE (UsageEndDate =: ninetyDays OR UsageEndDate =: sixtyDays OR UsageEndDate =: thirtyDays 
                                        OR UsageEndDate =: threeDays OR UsageEndDate =: expired7Days ) AND Product_Name__c = 'KSA ClearTax E-invoicing' 
                                 AND Billing_Type__c = 'ARR' AND Status != 'Renewed' AND Status != 'Valid & Renewed' ];
        
        if(assetList.size()>0){
            for(Asset thisAsset : assetList){
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(thisAsset.OwnerId);
                mail.setUseSignature(false);
                mail.SaveAsActivity = FALSE;
                List<String> ccAddresses = new List<String>();
                if(thisAsset.Account.OwnerId != NULL)
                    ccAddresses.add(thisAsset.Account.Owner.Email);
                if(thisAsset.Account.Owner.ManagerId != NULL)
                    ccAddresses.add(thisAsset.Account.Owner.Manager.Email);
                if(thisAsset.Account.Sales_Owner__r.ManagerId != NULL)
                    ccAddresses.add(thisAsset.Account.Sales_Owner__r.Manager.Email);
                if(thisAsset.Account.Onboarding_Owner__c != NULL)
                    ccAddresses.add(thisAsset.Account.Onboarding_Owner__r.Email);
                ccAddresses.add('gcc-category-team@clear.in,akash.prasad@clear.in,ankur.agrawal@clear.in,usha.dr@clear.in,ahmed.syed@clear.in');
                mail.setToAddresses(new String[]{thisAsset.Owner.Email});
                //mail.setToAddresses(new String[]{'bhavesh.jindal@clear.in'});
                mail.setccAddresses(ccAddresses);
                mail.setOrgWideEmailAddressId(defaultMailId);
                String emailBody = '';
                if(thisAsset.UsageEndDate == ninetyDays){
                    mail.setSubject('Upcoming Renewal : Attention Required - Asset will expire in 90 days');
                    emailBody += 'First Reminder :- Asset will expire in 90 days. <br/><br/>';
                    emailBody += 'Hi Team,<br/><br/>';
                    emailBody += 'The asset id <a href="https://cleartax.lightning.force.com/'+thisAsset.Id+'">'+thisAsset.Name+'</a> is going to expire on product usage end date '+thisAsset.UsageEndDate+'.<br/><br/>';
                    emailBody += ' Kindly, complete the renewal process before that, corresponding to this Account Name <a href="https://cleartax.lightning.force.com/'+thisAsset.AccountId+'">'+thisAsset.Account.Name+'</a>.  Please start reaching out to customers POC from today.<br/><br/>';
                    emailBody += '<b>Account Owner :</b> '+thisAsset.Account.Owner.Name+'<br/>';
                    emailBody += '<b>Account CSM :</b> '+thisAsset.Account.Onboarding_Owner__r.Name+'<br/><br/>';
                    emailBody += 'Thanks,<br/> Cleartax';
                }else if(thisAsset.UsageEndDate == sixtyDays){
                    mail.setSubject('Upcoming Renewal : Attention Required - Asset will expire in 60 days');
                    emailBody += 'Second Reminder :- Asset will expire in 60 days. <br/><br/>';
                    emailBody += 'Hi Team,<br/><br/>';
                    emailBody += 'The asset id <a href="https://cleartax.lightning.force.com/'+thisAsset.Id+'">'+thisAsset.Name+'</a> is going to expire on product usage end date '+thisAsset.UsageEndDate+'.<br/><br/>';
                    emailBody += ' Kindly, close the renewal deal for <a href="https://cleartax.lightning.force.com/'+thisAsset.AccountId+'">'+thisAsset.Account.Name+'</a> as early as possible in salesforce, if not done yet.<br/><br/>';
                    emailBody += '<b>Account Owner :</b> '+thisAsset.Account.Owner.Name+'<br/>';
                    emailBody += '<b>Account CSM :</b> '+thisAsset.Account.Onboarding_Owner__r.Name+'<br/><br/>';
                    emailBody += 'Thanks,<br/> Cleartax';
                }else if(thisAsset.UsageEndDate == thirtyDays){
                    mail.setSubject('Upcoming Renewal : Attention Required - Asset will expire in 30 days');
                    emailBody += 'Final Reminder :- Asset will expire in 30 days. <br/><br/>';
                    emailBody += 'Hi Team,<br/><br/>';
                    emailBody += 'Last 30 days remaining before the asset id <a href="https://cleartax.lightning.force.com/'+thisAsset.Name+'">'+thisAsset.Id+'</a> is going to expire on product usage end date '+thisAsset.UsageEndDate+'.<br/><br/>';
                    emailBody += ' Please close the renewal deal for <a href="https://cleartax.lightning.force.com/'+thisAsset.AccountId+'">'+thisAsset.Account.Name+'</a> within the next 15 days to avoid escalation from the Management side.<br/><br/>';
                    emailBody += '<b>Account Owner :</b> '+thisAsset.Account.Owner.Name+'<br/>';
                    emailBody += '<b>Account CSM :</b> '+thisAsset.Account.Onboarding_Owner__r.Name+'<br/><br/>';
                    emailBody += 'Thanks,<br/> Cleartax';
                }else if(thisAsset.UsageEndDate == threeDays){
                    mail.setSubject('Upcoming Renewal : Attention Required - Asset will expire in next 3 days');
                    emailBody += 'Escalation Reminder :- Asset will expire in 3 days. <br/><br/>';
                    emailBody += 'Hi Team,<br/><br/>';
                    emailBody += 'Last 3 days remaining before the asset id <a href="https://cleartax.lightning.force.com/'+thisAsset.Name+'">'+thisAsset.Id+'</a> is going to expire on product usage end date '+thisAsset.UsageEndDate+'.<br/><br/>';
                    emailBody += ' Please close the renewal deal for <a href="https://cleartax.lightning.force.com/'+thisAsset.AccountId+'">'+thisAsset.Account.Name+'</a> within the next 3 days to avoid escalation from the Management side.<br/><br/>';
                    emailBody += '<b>Account Owner :</b> '+thisAsset.Account.Owner.Name+'<br/>';
                    emailBody += '<b>Account CSM :</b> '+thisAsset.Account.Onboarding_Owner__r.Name+'<br/><br/>';
                    emailBody += 'Thanks,<br/> Cleartax';
                }else if(thisAsset.UsageEndDate == expired7Days){
                    mail.setSubject('Upcoming Renewal : Attention Required - Asset will expire in next 3 days');
                    emailBody += 'Warning : Renewal Pending for expired asset. <br/><br/>';
                    emailBody += 'Hi Team,<br/><br/>';
                    emailBody += 'The asset id <a href="https://cleartax.lightning.force.com/'+thisAsset.Id+'">'+thisAsset.Name+'</a> is expired on product usage end date '+thisAsset.UsageEndDate+'.<br/><br/>';
                    emailBody += ' Please close the renewal deal for <a href="https://cleartax.lightning.force.com/'+thisAsset.AccountId+'">'+thisAsset.Account.Name+'</a> as early as possible. ';
                    emailBody += 'CSM Owner Name : '+thisAsset.Account.Onboarding_Owner__r.Name+' please extend the license after aligning the same with the respective sales owner.<br/><br/>';
                    emailBody += '<b>Account Owner :</b> '+thisAsset.Account.Owner.Name+'<br/>';
                    emailBody += '<b>Account CSM :</b> '+thisAsset.Account.Onboarding_Owner__r.Name+'<br/><br/>';
                    emailBody += 'Thanks,<br/> Cleartax';
                }
                mail.setHtmlBody(emailBody);
                mailList.add(mail);
            }
        }
        
        system.debug('mailList: '+mailList.size());
        if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
                isSuccess = TRUE;
                System.debug('Success');
            }
            catch (Exception ex) {
                errorMessages.add('Unable to send email'+ ex.getMessage());
                System.debug('Errors : ' +errorMessages);
            }
        }
        
        
    }
    
}