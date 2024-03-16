public class CTX_DealClosureNotification {
    
    public static Messaging.SingleEmailMessage constructEmailBody(Opportunity thisOpp){
        
        Messaging.SingleEmailMessage 	mail 			= new Messaging.SingleEmailMessage();
        
        mail.toAddresses = new List<String>(System.Label.Deal_Lost_Emails.split(','));
            
            mail.setUseSignature(FALSE); 
        mail.setBccSender(FALSE); 
        mail.setSaveAsActivity(TRUE);
        mail.setTemplateID(System.Label.Deal_Lost_Notification_Template_Id);
        mail.setOrgWideEmailAddressId(System.Label.Deal_Lost_Notification_Org_Wide_Email_Id);
        mail.setWhatId(thisOpp.Id);		/**	This is important for the merge fields in template to work	**/
        mail.setTargetObjectId(System.Label.Default_Email_Template_Target_Id); 
        
        return mail;
    }
}