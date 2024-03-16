public class CTX_UserActivationDeactivationClass {
    
    public static void run(){	/**	actionOnFilteredUsers	**/
        
        
        Id 								defaultMailId 	= System.Label.Notification_Default_Id;
        //	[ SELECT Id FROM OrgWideEmailAddress WHERE Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        Messaging.SingleEmailMessage[] 	mails 			= new List<Messaging.SingleEmailMessage>();
        User[]							usersToUpdate	= new List<User>();
        
        for(User thisRec : database.query(System.Label.User_Inactive_Query)){
            
            Boolean isDeactivate		= System.Label.User_Inactive_Enable == 'YES' ? TRUE : FALSE; 
            Integer inActivityInDays	= Date.valueOf(thisRec.LastloginDate).daysBetween(System.today());
            String 	email 				= thisRec.Email.containsIgnoreCase('invalid') ? thisRec.Email.replace('.invalid', '') : thisRec.Email; 
            system.debug('inActivityInDays: '+inActivityInDays);
            
            /**	Reminders Emails : START	**/
            if( inActivityInDays == Integer.valueOf(System.Label.User_Inactive_Reminder_1) ){
                
                mails.add(
                    sendEmailHelper(defaultMailId, email, inActivityInDays, 1, FALSE, thisRec)
                );
                thisRec.Inactivity_Reminder__c = 1;
                usersToUpdate.add(thisRec);
            }
            if( inActivityInDays == Integer.valueOf(System.Label.User_Inactive_Reminder_2) ){
                mails.add(
                    sendEmailHelper(defaultMailId, email, inActivityInDays, 2, FALSE, thisRec)
                );
                thisRec.Inactivity_Reminder__c = 2;
                usersToUpdate.add(thisRec);
            }
            if( inActivityInDays == Integer.valueOf(System.Label.User_Inactive_Reminder_3) ){
                mails.add(
                    sendEmailHelper(defaultMailId, email, inActivityInDays, 3, FALSE, thisRec)
                );
                thisRec.Inactivity_Reminder__c = 3;
                usersToUpdate.add(thisRec);
            }
            /**	Reminders Emails : END	**/
            /**	User Deactivations : START	**/
            if( inActivityInDays >= Integer.valueOf(System.Label.User_Inactive_Deactivation) ){
                
                if(isDeactivate){	/**	Deactivated all users falling in this group	**/
                    
                    thisRec.IsActive		= FALSE;
                    thisRec.IsPortalEnabled	= FALSE;
                    thisRec.ContactId		= NULL;
                    usersToUpdate.add(thisRec);
                    /**	mails.add( sendEmailHelper(defaultMailId, email, inActivityInDays, 0, TRUE, thisRec) );	**/
                } else{	/**	Send notifications all users falling in this group	**/
                    
                    system.debug('Inside Deactivate and Send Mail');
                    Decimal reminderCount = thisRec.Inactivity_Reminder__c == NULL ? 1 : thisRec.Inactivity_Reminder__c + 1;
                    mails.add(
                        sendEmailHelper(defaultMailId, email, inActivityInDays, (Integer)reminderCount, FALSE, thisRec)
                    );
                    thisRec.Inactivity_Reminder__c = (Integer)reminderCount;
                    usersToUpdate.add(thisRec);
                }
            }
            /**	User Deactivations : END	**/
        }
        
        Boolean isSuccess = FALSE;
        try{
            Messaging.sendEmail(mails);
            isSuccess = TRUE;
        } catch(Exception ex){
            system.debug('Send EMail error in CTX_UserActivationDeactivationClass: '+ex.getMessage());
        }
        
        if(isSuccess){
            try{
                update usersToUpdate;
            } catch(Exception ex){
                system.debug('update usersToUpdate: '+ex.getMessage());
            }
            
        }
    }
    
    public static Messaging.SingleEmailMessage sendEmailHelper(
        Id 		defaultMailId, 
        String 	email, 
        Integer inActivityInDays, 
        Integer reminderCount,
        Boolean isDeactivate,
        User 	thisRec
    ){
        
        List<String>					recipients	= new List<String>();//{'team-salesforce@cleartax.in'}
        recipients.add(email);
        Messaging.SingleEmailMessage 	mail 		= new Messaging.SingleEmailMessage();
        String 							subject;
        String							body;
        
        if(isDeactivate){
            
            subject = 'IMP: Your Salesforce access is revoked.';
            body	= 'Hi '+thisRec.Name+', '
                +' <br/> <br/> \n Your user is deactivated because of '+inActivityInDays+' days of inactivity. <br/> \n '
                +' Please get in touch with your <b>Salesforce Team</b>(team-salesforce@cleartax.in) incase you still need access.'
                +'<br/> <br/> \n Yours, <br/> /n Team Salesforce';
        } else{
            
            subject = 'Attention: Salesforce user access revoke notification.';
            body	= 'Hi '+thisRec.Name
                +' <br/> <br/> \n You haven\'t logged in to your Salesforce instance from last '
                +inActivityInDays+' days. <br/> \n '+ 'Please login to your Salesforce instance or '+
                'get in touch with your <b>Salesforce Team</b>(team-salesforce@cleartax.in) if you don\'t want your user to deactivated.';
        }
        
        mail.setOrgWideEmailAddressId(defaultMailId);
        mail.setToAddresses(recipients);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        return mail;
    }
    
}