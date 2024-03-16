/** @ASHWIN - SAL-1042 **/

public class CTX_NotifySupportOwnerChange {
    
    @InvocableMethod
    public static void emailSend(list<Billing_Details__c> billingList){
		Map<Id, Billing_Details__c> billingMap = new Map<Id, Billing_Details__c>(billingList);
        System.debug('@billingList'+billingList);
        Id 					defaultMailId 				= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                           Address = 'notification@support.clear.in']?.Id;
        
        
        Map<Id, Billing_Details__c> billingDetailsMap = new Map<Id, Billing_Details__c>([SELECT Id,Support_Owner__r.Email,Support_Owner__r.Manager_Email__c,
                                                                                         Support_Owner_Email_Address__c, Asset__r.Account.Name,
                                                                                          Action_Owner_Collection__r.ManagerId, Action_Owner_Collection__c, Action_Owner_Collection__r.Name,
                                                                                         Asset__r.Product2.Name,Price__c,Outstanding_Overdue__c,Amount_Due_Un_Billed__c,
                                                                                         Support_required__c,Asset__r.Name, Asset__r.Account.Onboarding_Owner__r.Email, 
                                                                                         Asset__r.Account.Onboarding_Owner__r.Manager_Email__c
                                                                                         FROM Billing_Details__c 
                                                                                         WHERE Id IN :billingMap.keySet()]);
        List<Messaging.SingleEmailMessage> 	mailList 	= new List<Messaging.SingleEmailMessage>();
        
        for(Billing_Details__c thisRec : billingDetailsMap.values()){
            
            List<User>   userList 	 = new List<User>();
            List<String> ccAddresses = new List<String>();
            List<String> toAddresses = new List<String>();
            List<String>  toName 	 = new List<String>();
            List<String> supportOwnerEmailAddress;
            
            userList = [SELECT Id, Email, Manager_Email__c,User_Manager__c, Name FROM User 
                        WHERE (Id =:thisRec.Support_Owner__c OR Id =:thisRec.Action_Owner_Collection__c OR Id =:UserInfo.getUserId())];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.SaveAsActivity = TRUE;
            mail.setWhatId(thisRec.Id);
            
            for(User thisUser : userList){
                if(thisUser.Id != thisRec.Support_Owner__c){
                    ccAddresses.add(thisUser.Email);
                    ccAddresses.add(thisUser.Manager_Email__c);
                }else{
                    //toAddresses.add(thisUser.Email);
                    //ccAddresses.add(thisUser.Manager_Email__c);
                    toName.add(thisUser.Name);
                } 
            }
        	
            System.debug('@email'+billingDetailsMap.get(thisRec.Id).Support_Owner__r.Email );
            
            	
            if(thisRec.Action_Owner_Collection__r.ManagerId == System.Label.ActionOwnerManager_Regan_Mithani){
                ccAddresses.add(System.Label.SupportOwner_CCAddress);
            }
            
            if(billingDetailsMap.get(thisRec.Id).Support_Owner__r.Email != NULL){
                toAddresses.add(billingDetailsMap.get(thisRec.Id).Support_Owner__r.Email);
            }
            
            if(billingDetailsMap.get(thisRec.Id).Support_Owner__r.Manager_Email__c != NULL){
                ccAddresses.add(billingDetailsMap.get(thisRec.Id).Support_Owner__r.Manager_Email__c);
            }
           
            if(thisRec.Asset__r.Account.Onboarding_Owner__r.Email != NULL){
                ccAddresses.add(thisRec.Asset__r.Account.Onboarding_Owner__r.Email);
            } 
            
            if(thisRec.Asset__r.Account.Onboarding_Owner__r.Manager_Email__c != NULL){
                ccAddresses.add(thisRec.Asset__r.Account.Onboarding_Owner__r.Manager_Email__c);
            } 
            
            
            if(thisRec.Support_Owner_Email_Address__c != NULL){ 
                supportOwnerEmailAddress = thisRec.Support_Owner_Email_Address__c.split(';');
                toAddresses.addAll(thisRec.Support_Owner_Email_Address__c.split(';'));
            }
            
            if(thisRec.Support_Owner_Email_Address__c != NULL){
                for(String thisEmail : supportOwnerEmailAddress){
                    toName.add(thisEmail.SubstringBefore('@'));
                }
            }
            
            String currentUser = UserInfo.getName();
            String toAddr = String.Join(toName,',');
            String subject ='';
            String body;
            System.debug('@name'+thisRec.Asset__r.name);
            String href = URL.getSalesforceBaseUrl().toExternalForm() + '/'+thisRec.Asset__c ;
            Id taskId = [SELECT Id FROM Task WHERE WhatId = :thisRec.Id Order by CreatedDate Desc LIMIT 1]?.Id;
            String href1 = URL.getSalesforceBaseUrl().toExternalForm() + '/'+taskId ;
            subject ='Support Required - ' + thisRec.Asset__r.Account.Name;
            body = 'Hi '+toAddr+', <br/><br/>';
            body += +currentUser+' has requested your support on the following asset <a href='+href+'>' +thisRec.Asset__r.Name + '</a></td><br/><br/>';
            body += '<table border="1px" style="text-align:center">';
            body += '<tr bgcolor="Gold"><th>Account Name</th>';
            body += '<th>Product Name</th>';
            body += '<th>Price </th>';
            body += '<th>Oustanding Overdue</th>';
            body += '<th>Amount due but un-billed</th><tr/>';
            body+='<tr><td style="text-align:center; padding:4px">' + thisRec.Asset__r.Account.Name + '</td>';
            body+='<td style="text-align:center; padding:4px">' + thisRec.Asset__r.Product2.Name + '</td>';
            
            if(thisRec.Price__c != NULL){
                body+='<td style="text-align:center; padding:4px">' + thisRec.Price__c.format() + '</td>';
            }else{
                body+='<td></td>';
            }
            
            if(thisRec.Outstanding_Overdue__c != NULL){
                body+='<td style="text-align:center; padding:4px">' + thisRec.Outstanding_Overdue__c.format() + '</td>';
            }else{
                body+='<td></td>';
            }
            
            if(thisRec.Amount_Due_Un_Billed__c != NULL){
                body+='<td style="text-align:center; padding:4px">' + thisRec.Amount_Due_Un_Billed__c.format() + '</td><tr/>';
            }else{
                body+='<td></td>';
            }
            
            body+= '</table><br/>';
            
            body += '<table border="1px" style="text-align:center">';
            body += '<tr ><th bgcolor="Gold">Support Required - Collection</th>';
            body += '<th>'+thisRec.Support_required__c+ '</th></tr></table><br/><br/>';

            body+= 'Please resolve the issue and update the comments in "Support owner comments" field <a href='+href1+'>here </a>';

                
            mail.setSubject(subject);
            mail.setHtmlBody(body);
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            mail.setOrgWideEmailAddressId(defaultMailId);
            mailList.add(mail);
        }
        system.debug('mailList: '+mailList.size());
        if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
            }
            catch (Exception ex) {
                System.debug('Unable to send email'+ ex.getMessage());
            }
        }
    }
}