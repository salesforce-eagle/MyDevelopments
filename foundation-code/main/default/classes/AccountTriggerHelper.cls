public without sharing class AccountTriggerHelper {
    
    public static void sendCSMNotification(List<Account> accountList){
        
        Map<Id, Account> accountMap 		= new Map<Id, Account>(accountList);
        List<String> 	 errorMessages 		= new List<String>();        
        Id 				 defaultMailId 		= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                               Address =: System.Label.CSM_Journey_Org_Wide_Generic_Email]?.Id;        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        
        
        for( Account thisAccount : [Select Id, Name, Onboarding_Owner__c, Onboarding_Owner__r.Name, Onboarding_Owner__r.email,
                                    Onboarding_Owner__r.Manager.email, Sales_Owner__r.email
                                    FROM Account WHERE Id IN :accountMap.keySet() ] ){
                                        
                                        System.debug('thisAccount.Onboarding_Owner__r.email : '+thisAccount.Onboarding_Owner__r.email);
                                        System.debug('thisAccount : '+thisAccount);
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        mail.SaveAsActivity = TRUE;
                                        mail.setWhatId(thisAccount.Id);
                                        String Subject = 'CSM Assignment For Account '+thisAccount.Name+'.';
                                        mail.setSubject(Subject);
                                        String body = 'Hi '+thisAccount.Onboarding_Owner__r.Name+','+'<br/>';
                                        body += 'You have been assigned CSM for below Account.'+'<br/>';
                                        body += '<b>Account Name :</b>'+' '+thisAccount.Name+'<br/>';
                                        body += '<b>Account Id :</b>'+' '+thisAccount.Id+'<br/>';
                                        body += ''+'<br/>';
                                        body += ''+'<br/>';
                                        body +='Regards'+',<br/>'+'\n CSM Team'+'<br/>';
                                        mail.setHtmlBody(body);
                                        List<String> ccAddresses = new List<String>();
                                        ccAddresses.add(thisAccount.Onboarding_Owner__r.Manager.email);
                                        ccAddresses.add(thisAccount.Sales_Owner__r.email);
                                        mail.setToAddresses(new String[]{thisAccount.Onboarding_Owner__r.email });
                                        mail.setccAddresses(ccAddresses);
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
    
    /** START : bhaveshjindal : Send CSM Intro mail to communicable Contacts of the Account **/
    public static void sendCSMIntroMail(List<Account> accountList){
        
        Set<Id> 							accountIds 		= new Set<Id>();
        List<Contact> 						contactList 	= new List<Contact>();
        List<String> 						errorMessages 	= new List<String>();        
        List<Messaging.SingleEmailMessage> 	mailList 		= new List<Messaging.SingleEmailMessage>();
        Id 									defaultMailId 	= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                               Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        /*Changed By Niraj CSM Journey - START */
        Map<Id,List<String>> accountIdToContactEmailsMap = new Map<Id,List<String>>();
        
        /*for(Account thisAccount : accountList){
accountIds.add(thisAccount.Id);
}
System.debug('accountIds :: '+accountIds);*/
        
        for(Contact conInstance : [SELECT Id, Name, Email, AccountID FROM Contact WHERE AccountId IN :accountList AND Is_Communicable__c = TRUE]){
            if(accountIdToContactEmailsMap.keySet().contains(conInstance.AccountId)){
                List<String> tempList = accountIdToContactEmailsMap.get(conInstance.AccountId);
                tempList.add(conInstance.Email);
                accountIdToContactEmailsMap.put(conInstance.AccountID, tempList);
            } else {
                accountIdToContactEmailsMap.put(conInstance.AccountID, new List<String>{conInstance.Email});
            }
        }
        System.debug('ContactList :: '+contactList);
        
        for(Account accInstance : [SELECT Id, Name, Onboarding_Owner__r.Name, Onboarding_Owner__r.Email, Onboarding_Owner__r.Phone, Onboarding_Owner__r.MobilePhone, 
                                   Onboarding_Owner__r.Manager.Email, Onboarding_Owner__r.Manager.Phone, Onboarding_Owner__r.Manager.MobilePhone
                                   FROM Account WHERE Id IN : accountList])
        {
            List<String> toAddresses = accountIdToContactEmailsMap.get(accInstance.Id);
            if(toAddresses != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.SaveAsActivity = TRUE;
                mail.setWhatId(accInstance.Id);
                String Subject = 'You have been assigned a new Customer Success manager.';
                mail.setSubject(Subject);
                String body = 'Dear '+ accInstance.Name +' Team,'+'<br/><br/>';
                body += 'This is to keep you all in the loop to be notified of the change with the assigned Customer Success Manager for '+ accInstance.Name +' from Clear.'+'<br/><br/>';
                body += '<b>The new primary point of contact from Clear will be ' + accInstance.Onboarding_Owner__r.Name + '</b><br/><br/>';
                body += 'It was a pleasure working with you all and I will ensure a smooth account transition to ' + accInstance.Onboarding_Owner__r.Name + ' in the next few days.'+ '<br/>';
                body += 'Feel free to get in touch with him/her if you have any open product query or need other assistance.<br/><br/>';
                body += 'The updated support escalation matrix is provided for your reference below. <br/><br>';
                body += '<b>Contact Details & Escalation Matrix ( for all account & service related queries )</b><br/>';
                body += '<table border="1px">';
                body += '<tr>';
                body += '<th bgcolor="yellow">POC Name</th>';
                body += '<th bgcolor="yellow">Designation</th>';
                body += '<th bgcolor="yellow">Phone number</th>';
                body += '<th bgcolor="yellow">Email ID</th>';
                body += '<th bgcolor="yellow">Contact type</th>';
                body += '</tr>';
                body += '<tr>';
                body += '<td style="text-align:center"><b>'+accInstance.Onboarding_Owner__r.Name+'</b></td>';
                body += '<td style="text-align:center">Customer Success Manager</td>';
                if(accInstance.Onboarding_Owner__r.Phone != NULL)
                    body += '<td style="text-align:center">'+accInstance.Onboarding_Owner__r.Phone+'</td>';
                else if(accInstance.Onboarding_Owner__r.MobilePhone != NULL)
                    body += '<td style="text-align:center">'+accInstance.Onboarding_Owner__r.MobilePhone+'</td>';
                else
                    body += '<td style="text-align:center"> </td>';
                body += '<td style="text-align:center">'+'<a href="mailto:'+accInstance.Onboarding_Owner__r.Email+'">'+accInstance.Onboarding_Owner__r.Email+'</a>'+'</td>';
                body += '<td style="text-align:center">Primary contact (L1)</td>';
                body += '</tr>';
                body += '<tr>';
                body += '<td style="text-align:center"><b>'+accInstance.Onboarding_Owner__r.Manager.Name+'</b></td>';
                body += '<td style="text-align:center">Customer Success Leader</td>';
                if(accInstance.Onboarding_Owner__r.Manager.Phone != NULL)
                    body += '<td style="text-align:center">'+accInstance.Onboarding_Owner__r.Manager.Phone+'</td>';
                else if(accInstance.Onboarding_Owner__r.Manager.MobilePhone != NULL)
                    body += '<td style="text-align:center">'+accInstance.Onboarding_Owner__r.Manager.MobilePhone+'</td>';
                else
                    body += '<td style="text-align:center"> </td>';
                body += '<td style="text-align:center">'+'<a href="mailto:'+accInstance.Onboarding_Owner__r.Manager.Email+'">'+accInstance.Onboarding_Owner__r.Manager.Email+'</a>'+'</td>';
                body += '<td style="text-align:center">Secondary contact (L2)</td>';
                body += '</tr>';
                body += '</table>';
                body += '<br/><br/>';
                body += accInstance.Onboarding_Owner__r.Name + ', your new Customer Success Manager from Clear will be connecting with you shortly for a first introduction & health check call.';
                body += 'Regards,<br/>';
                body += 'Team Clear (formerly known as ClearTax)<br/>';
                mail.setHtmlBody(body);
                mail.setToAddresses(toAddresses);
                mail.setCCAddresses(new List<String>{accInstance.Onboarding_Owner__r.Email, accInstance.Sales_Owner__r.Email});
                mail.setOrgWideEmailAddressId(defaultMailId);
                mailList.add(mail);
            }
            
        }
        /*Changed By Niraj CSM Journey - END */
        system.debug('CSM Intro mailList : '+mailList.size());
        if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
            }
            catch (Exception ex) {
                errorMessages.add('Unable to send CSM Intro email'+ ex.getMessage());
            }
        }
        System.debug('Errors : ' +errorMessages);
        
    }
    
    /** START : Ashwinkrishna : Update Asset Owner **/
    public static void updateAssetOwner(Map<Id,Account> newAccMap){
        
        Map<Id,Asset> assetMap = new Map<Id,Asset>([SELECT id,OwnerId, AccountId from Asset where AccountId IN:newAccMap.keySet()]);
        List<Asset> astList = new List<Asset>();
        try{
            for(Asset ast : assetMap.values()){
                ast.OwnerId = newAccMap.get(ast.AccountId).OwnerId;
                astList.add(ast);
            }
            if(!astList.isEmpty()){
                RecursiveTriggerHandler.isFirstTime = FALSE;
                update astList;
                RecursiveTriggerHandler.isFirstTime = TRUE;
            }
        }catch (Exception ex) {
            System.debug('Exception on Update Asset Owner'+ ex.getMessage());
        }
        
    }
    /** END : Ashwinkrishna : Update Asset Owner **/
    
    /** Update Action Owner - Billing & Risk **/
    public static void UpdateBillingActionOwner(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap){
        Map<Id,Account> salesOwnerChangeMap  = new Map<Id,Account>();
        Map<Id,Account> OwnerChangeMap  	 = new Map<Id,Account>();
        List<Billing_Details__c> billingList = new List<Billing_Details__c>();
        for(Id key : newAccountMap.keyset()){
            if(newAccountMap.get(key).Sales_Owner__c != oldAccountMap.get(key).Sales_Owner__c && newAccountMap.get(key).Sales_Owner__c != NULL){
                salesOwnerChangeMap.put(key,newAccountMap.get(key));
            }
            if(newAccountMap.get(key).OwnerId != oldAccountMap.get(key).OwnerId && newAccountMap.get(key).OwnerId != NULL){
                OwnerChangeMap.put(key,newAccountMap.get(key));
            }
        }
        if(salesOwnerChangeMap.values().size()>0 || OwnerChangeMap.values().size()>0){
            for(Billing_Details__c thisRec : [SELECT Id, Asset__r.Opportunity__r.OwnerId, Action_Owner_Collection__c,
                                              Asset__r.AccountId, Asset__r.Opportunity__r.Owner.IsActive
                                              FROM Billing_Details__c
                                              WHERE Asset__r.AccountId IN :salesOwnerChangeMap.keySet() OR
                                                    Asset__r.AccountId IN :OwnerChangeMap.keySet()])
            {
                System.debug('@thisRec'+thisRec);
                if(salesOwnerChangeMap.containsKey(thisRec.Asset__r.AccountId) && ((oldAccountMap.get(thisRec.Asset__r.AccountId).Sales_Owner__c == thisRec.Action_Owner_Collection__c &&
                                                                                   !thisRec.Asset__r.Opportunity__r.Owner.IsActive) || 
                   thisRec.Action_Owner_Collection__c == NULL ))
                {
                    thisRec.Action_Owner_Collection__c = salesOwnerChangeMap.get(thisRec.Asset__r.AccountId).ownerId; 
                    billingList.add(thisRec);  
                }
                
                if(OwnerChangeMap.containsKey(thisRec.Asset__r.AccountId) && ((oldAccountMap.get(thisRec.Asset__r.AccountId).OwnerId == thisRec.Action_Owner_Collection__c &&
                                                                                   !thisRec.Asset__r.Opportunity__r.Owner.IsActive) || 
                   thisRec.Action_Owner_Collection__c == NULL ))
                {
                    thisRec.Action_Owner_Collection__c = OwnerChangeMap.get(thisRec.Asset__r.AccountId).ownerId; 
                    billingList.add(thisRec);  
                }
            }
            
            System.Debug('@billingList'+billingList);
            
            try{
                if(!billingList.isEmpty()){
                    CTX_BillingDetailsConstants.isFirstTimeBilling = FALSE;
                    Update billingList;
                    CTX_BillingDetailsConstants.isFirstTimeBilling = TRUE;
                }
            }catch(Exception ex){
                System.debug(' Exception on UpdateBillingActionOwner  \n'+ex.getMessage()+'\n'+ex.getLineNumber());
            }
        }
        
    }
    
    
}