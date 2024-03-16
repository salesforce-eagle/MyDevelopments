public class EmailManager {
// Public method
    public static void sendMail(List<Project__c> projectList) {
        
        Id 					defaultMailId 				= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                           Address = 'notification@support.clear.in']?.Id;
        List<Messaging.SingleEmailMessage> 	mailList 	= new List<Messaging.SingleEmailMessage>();
        List<String> 		errorMessages 				= new List<String>();
        Set<Id> projectIds = new Set<Id>();
        for(Project__c thisProject : projectList){
            //projectIds.add(thisProject.Id);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String RecordlinkForProduct = URL.getOrgDomainUrl().toExternalForm()+'/'+thisProject.Project_ID_18__c;
            String RecordlinkForAccount = URL.getOrgDomainUrl().toExternalForm()+'/'+thisProject.Account__c;
            mail.SaveAsActivity = TRUE;
            mail.setWhatId(thisProject.Id);
            List<String> ccAddresses = new List<String>();
            List<String> toAddresses = new List<String>();
            String subject = 'Regarding SI billing details required for'+ thisProject.Project_Name__c;
            String body = 'Hi Nagesh,'+'<br/>';
            body += 'Please fill in the SI Billing details(All Fields in the section "SI Billing Details") for the '+ '<a href='+RecordlinkForProduct+'>' + thisProject.Project_ID_18__c + '</a>'+' & project name - '+thisProject.Project_Name__c+' for account '+ '<a href='+RecordlinkForAccount+'>' + thisProject.Account__c + '</a>';
           // toAddresses.add('murali.krishna@clear.in');//System.Label.DemoLabel
           // toAddresses.add(System.Label.Project_Email_Notification_Scope);
            List<String> toAddressesSplit1 = System.Label.Project_Email_Notification_Scope.split(',');
            for(String toMail : toAddressesSplit1){
               toAddresses.add(toMail); 
            }
            mail.setSubject(subject);
            mail.setHtmlBody(body);
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            mail.setOrgWideEmailAddressId(defaultMailId);//"Cleartax" <notifications.sf@cleartaxmailer.com>
            //mail.setOrgWideEmailAddressId('notifications.sf@cleartaxmailer.com');
            
            
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.SaveAsActivity = TRUE;
            mail1.setWhatId(thisProject.Id);
            List<String> ccAddresses1 = new List<String>();
            List<String> toAddresses1 = new List<String>();
            String subject1 = 'Regarding SI billing details required for'+ thisProject.Project_Name__c;
            String body1 = 'Hi Harish,'+'<br/>';
            body1 += 'Please fill in the SI Billing details(fields = PO value given to SI and CR checkbox) for the '+ '<a href='+RecordlinkForProduct+'>' + thisProject.Project_ID_18__c + '</a>'+' & project name - '+thisProject.Project_Name__c+' for account '+ '<a href='+RecordlinkForAccount+'>' + thisProject.Account__c + '</a>';
            //toAddresses1.add('murali.krishna@clear.in');
            List<String> toAddressesSplit = System.Label.Project_Email_Notification.split(',');
            for(String toMail : toAddressesSplit){
               toAddresses1.add(toMail); 
            }
            mail1.setSubject(subject1);
            mail1.setHtmlBody(body1);
            mail1.setToAddresses(toAddresses1);
            mail1.setCcAddresses(ccAddresses1);
            mail1.setOrgWideEmailAddressId(defaultMailId);//"Cleartax" <notifications.sf@cleartaxmailer.com>
            
            mailList.add(mail);
            mailList.add(mail1);
            system.debug('email manager mail: '+mail);
            
            
        }
        system.debug('email manager mailList: '+mailList.size());
            if(!mailList.isEmpty()) {
                try{
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
                    inspectResults(results);
                }
                catch (Exception ex) {
                    errorMessages.add('Unable to send email'+ ex.getMessage());
                }
            }
        
    }
    // Helper method
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            }
            else {
                sendResult = false;
                System.debug('The following errors occurred: ' + res.getErrors());                 
            }
        }
        return sendResult;
    }
}