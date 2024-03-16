public class CTX_JiraCalloutQueuable implements Queueable, Database.AllowsCallouts {
    Private Map<String, EmailMessage> issueMailtTrail = new Map<String, EmailMessage> ();
    
    public CTX_JiraCalloutQueuable(Map<String, EmailMessage> mailTrail ) {
        this.issueMailtTrail = mailTrail;
    }
    
    public void execute(QueueableContext context) {
        
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        for(String thisIssue : issueMailtTrail.keySet()){
            
            CTX_EMailMessageToJIRACommentCallout.SuccessErrorWrapper thisResponse = CTX_EMailMessageToJIRACommentCallout.postJiraComment(issueMailtTrail.get(thisIssue).TextBody, thisIssue); 
            
            EmailMessage myMessage = new EmailMessage(
                Id 					= issueMailtTrail.get(thisIssue).Id,
                Jira_Comment_Id__c 	= thisResponse.commentId
            );
            
            CTX_checkRecursive.isEmailMessageTriggerRunning = FALSE;
            emailMessages.add(myMessage);
        }
        CTX_checkRecursive.isEmailMessageTriggerRunning = FALSE;
        update emailMessages;
    }
}