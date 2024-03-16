global without sharing class CTX_CaseTracker_OTP_Email_Helper {
    
    @AuraEnabled
    global static void sendOTPEmail(string caseEmail, String generatedOTP){
        
        List<String> 	 errorMessages 		= new List<String>();        
        String 				 defaultMailId 		= System.Label.Organisation_Wide_Address_Help_Support;        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String Subject = 'OTP for tracking your case.';
        mail.setSubject(Subject);
        String body = 'Hi,'+'<br/>';
        body += 'Please Use below OTP to verify your email :'+'<br/> <br/>';
        body += '<b>OTP :'+' '+generatedOTP+'</b> <br/>';
        body += 'Your OTP will be Valid for 5 minutes.'+'<br/>';
        body += ''+'<br/>';
        body +='Regards'+',<br/>'+'\n Team CLEAR'+'<br/>';
        mail.setHtmlBody(body);
        
        mail.setToAddresses(new String[]{caseEmail});
        //  mail.setCCAddresses(new String[]{'team-salesforce@cleartax.in'});
        
        mail.setOrgWideEmailAddressId(defaultMailId);
        mailList.add(mail);
        
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