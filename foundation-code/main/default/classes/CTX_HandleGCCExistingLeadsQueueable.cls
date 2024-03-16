public class CTX_HandleGCCExistingLeadsQueueable implements Queueable {
    public List<Lead> leadsToUpdate; 
    public CTX_HandleGCCExistingLeadsQueueable(List<Lead> leadsToUpdate){
        this.leadsToUpdate = leadsToUpdate;
    }
    
    public void execute(QueueableContext qc){
        
        List<Logger__c>	loggerCollection	= new List<Logger__c>();
        Boolean			isSuccess;
        
        try{
            update leadsToUpdate;
            isSuccess = TRUE;
        } catch(Exception ex){
            system.debug('Lead Update Fail: '+ex.getMessage());
            isSuccess = FALSE;
            loggerCollection.add(CTX_LoggerImplementation.createLoggerInstance(
                ex.getMessage(), 
                NULL, 
                'CTX_HandleGCCExistingLeadsQueueable', 
                'execute', 
                'Lead update Fail',
                NULL,
                'Lead'
            ));
            
            if(loggerCollection.size() > 0){
                try{
                    insert loggerCollection;
                } catch(Exception e){
                    System.debug('Error inserting Logger in Lead Queuable: '+e.getMessage());
                }
            }
        }
        
        if(isSuccess){
            Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, Name, Email, Owner.Name, OwnerId, Owner.Email, Company FROM Lead WHERE Id IN : leadsToUpdate]); 
            List<Messaging.SingleEmailMessage> 	mailList 		= new List<Messaging.SingleEmailMessage>();
            Id 									defaultMailId 	= [ SELECT Id FROM OrgWideEmailAddress WHERE Address = 'notifications.sf@cleartaxmailer.com']?.Id;
            for(Lead leadInstance : leadMap.values()){
                Messaging.SingleEmailMessage mailToLegal = new Messaging.SingleEmailMessage();
                
                String Subject = '[URGENT] Lead #'+ leadInstance.Company +' Re-requested Notification';
                mailToLegal.setSubject(Subject);
                String body = 'Hi ' + leadInstance.Owner.Name +',<br/><br/>';
                body += 'This Lead has come to us again, please communicate soon.'+'<br/>';
                body += 'Email : '+ leadInstance.Email +'<br/>';
                body += 'Name : '+ leadInstance.Name +'<br/><br/>';
                body += 'Use the below link to open the lead detail Page.'+'<br/>';
                body += URL.getOrgDomainUrl().toExternalForm() + '/' + leadInstance.Id +'<br/><br/>';
                body +='Regards'+',<br/>'+'\n Team CLEAR'+'<br/>';
                mailToLegal.setHtmlBody(body);
                mailToLegal.setToAddresses(new List<String> {leadInstance.Owner.Email});
                
                mailToLegal.setOrgWideEmailAddressId(defaultMailId);
                mailList.add(mailToLegal);
            }
            
            system.debug('mailList: '+mailList.size());
            if(!mailList.isEmpty()) {
                try{
                    Messaging.sendEmail(mailList);
                }
                catch (Exception ex) {
                    System.debug('Unable to send email'+ ex.getMessage());
                    loggerCollection.add(CTX_LoggerImplementation.createLoggerInstance(
                        ex.getMessage(), 
                        NULL, 
                        'CTX_HandleGCCExistingLeadsQueueable', 
                        'execute', 
                        'Email Send Fail',
                        NULL,
                        'EmailMessage'
                    ));
                    
                    if(loggerCollection.size() > 0){
                        try{
                            insert loggerCollection;
                        } catch(Exception e){
                            System.debug('Error Sending Email Queuable: '+e.getMessage());
                        }
                    }
                }
            }
        }
    }
}