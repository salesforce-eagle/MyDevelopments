public class CTX_SendPartnerAccountCreationMail {
    
    public static void sendMailToLegalTeam (List<Account> newCPAccountsList) {
        
        List<String> 	 				   errorMessages 	= new List<String>();        
        String 			 				   defaultMailId  	= System.Label.Organisation_Wide_Address_Help_Support;        
        List<Messaging.SingleEmailMessage> mailList 		= new List<Messaging.SingleEmailMessage>();
        List<String> 					   cpToAddresses    = System.Label.CTX_Channel_Partner_Creation_Mail_To_Addresses.split(',');
        List<String> 					   cpCCAddresses    = System.Label.CTX_Channel_Partner_Creation_Mail_CC_Addresses.split(',');
        
        for(Account accInstance : newCPAccountsList){
        
            Messaging.SingleEmailMessage mailToLegal = new Messaging.SingleEmailMessage();
            
            String Subject = 'Channel Partner Agreement Request.';
            mailToLegal.setSubject(Subject);
            String body = 'Hi Team,'+'<br/>';
            body += 'User has raised a request for Channel Partner Agreement, Please create the agreement and upload it in the Files for final signatures.'+'<br/>';
            body += 'The details can be viewed here. '+ URL.getOrgDomainUrl().toExternalForm() + '/' + accInstance.Id +'<br/>';
            body +='Regards'+',<br/>'+'\n Team CLEAR'+'<br/>';
            mailToLegal.setHtmlBody(body);
            
            mailToLegal.setToAddresses(cpToAddresses);
            mailToLegal.setCCAddresses(cpCCAddresses);
            
            mailToLegal.setOrgWideEmailAddressId(defaultMailId);
            mailList.add(mailToLegal);
            
            
            
            /*Messaging.SingleEmailMessage acknowledgementEmail = new Messaging.SingleEmailMessage();
            
            String Subject2 = 'Channel Partner Request Submitted';
            acknowledgementEmail.setSubject(Subject2);
            String body2 = 'Hello,' +'<br/>';
            body2 += 'Your Channel Partner Account Request is submitted Successfully'+'<br/>';
            body2 +='Regards'+',<br/>'+'\n Team CLEAR'+'<br/>';
            acknowledgementEmail.setHtmlBody(body2);
            
            acknowledgementEmail.setToAddresses(new String[] {accInstance.Master_admin_Email__c});
            
            acknowledgementEmail.setOrgWideEmailAddressId(defaultMailId);
            mailList.add(acknowledgementEmail);*/
        
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

}