public without sharing class CTX_CustomMessagingClass {
    
    @AuraEnabled
    public static String createEmailMessage(
        String	fromAddress,
        String	toAddress,
        String	ccAddress,
        String	subject,
        String	parentId,
        String 	body
    ){
        
        String returnMessage	= '';
        EmailMessage myMessage 	= new EmailMessage(
            
            FromAddress	= fromAddress, 
            ToAddress 	= toAddress,
            CCAddress	= ccAddress,
            Subject 	= subject, 
            ParentId 	= parentId,
            TextBody 	= body.remove('<p>')
        );
        myMessage.TextBody = myMessage.TextBody.remove('</p>');
        
        try{
            insert myMessage;
            returnMessage = 'Success';
        } catch(Exception ex){
            returnMessage = ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();
            system.debug('Return Error: '+ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString());
        }
        
        return returnMessage;
        
    }
    
     
    public static string processEmail(String email, String Subject, String Message){
        String sMessage='';
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {email}; 
                mail.setToAddresses(toAddresses);
            mail.setSubject(Subject);
            mail.setHtmlBody(Message);
            Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            sMessage='Success';
        }
        catch(Exception ex){
            sMessage=ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();
        }
        return sMessage;
    }
}