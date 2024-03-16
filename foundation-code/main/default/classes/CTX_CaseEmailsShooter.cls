/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-07-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_CaseEmailsShooter {
    
    public static String sendEmailAlertForJiraFieldUpdate( List<Case> caseList ){
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        List<Messaging.SingleEmailMessage> 	mailList 		= new List<Messaging.SingleEmailMessage>();
        Id 									defaultMailId 	= [ SELECT Id 
                                                               FROM OrgWideEmailAddress WHERE 
                                                               Address = :System.Label.Org_Default_Email_Id_For_Email_Sending ]?.Id;
        Boolean 							isSuccess 		= FALSE;
        List<String> 						errorMessages 	= new List<String>();
        List <String> 						toAddresses 	= new List<String>();
        String 								customLabel 	= System.Label.Jira_Case_Email_Recipients;
        List<String>						defaultEmails	= 
            
            System.Label.Jira_Case_Email_Recipients != NULL ? System.Label.Jira_Case_Email_Recipients.split(',') : NULL ;
        
        for( Case thisCase : caseList ){
            
            String ownerEmail;
            if( thisCase.Owner_Email__c != NULL ){
                String currentDomain = thisCase.Owner_Email__c.split('@')[1];
                if( currentDomain.containsIgnoreCase('clear.in') || currentDomain.containsIgnoreCase('cleartax') ){
                    ownerEmail = thisCase.Owner_Email__c;
                }
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setTargetObjectId(thisCase.OwnerId);
            mail.setUseSignature(FALSE);
            mail.SaveAsActivity = FALSE;
            
            List<String> toList = new List<String>();
            
            if( thisCase.Account.Onboarding_Owner__r.Email != NULL )
                toList.add(thisCase.Account.Onboarding_Owner__r.Email);
            if( thisCase.Account.Onboarding_Owner__r.Manager_Email__c != NULL )
                toList.add(thisCase.Account.Onboarding_Owner__r.Manager_Email__c);
            if( thisCase.LastModifiedBy.Email != NULL )
                toList.add(thisCase.LastModifiedBy.Email);
            if( thisCase.LastModifiedBy.Manager_Email__c != NULL )
                toList.add(thisCase.LastModifiedBy.Manager_Email__c);
            if( thisCase.Owner.Email != NULL )
                toList.add(thisCase.Owner.Email);
            if( ownerEmail != NULL )
                toList.add(ownerEmail);
            
            
            mail.setToAddresses( toList );
            if( defaultEmails != NULL )
                mail.setccAddresses(defaultEmails);
            
            mail.setOrgWideEmailAddressId(defaultMailId);
            
            mail.setSubject( 'JIRA Update related to ' + thisCase.CaseNumber + ' : ' + thisCase.Subject );
            String emailBody = 'Hi Team,<br/><br/>';
            emailBody += 'There is an update to the JIRA associated to the case, please find the below details: <br/><br/>';
            

            emailBody += '<tr><th style="text-align: left; vertical-align: top; width: 200px; padding-right: 10px;"><b>Account Name</b></th><td style="max-width: 200px; word-wrap: break-word; padding-right: 10px;">'+thisCase.Account_Name__c +'</td></tr>'; 
            //emailBody += '<tr><th><b>Account Name </b></th><td>'+thisCase.Account_Name__c +'</td></tr>'; 
            emailBody += '<tr><th style="text-align: left; vertical-align: top; max-width: 300px; padding-right: 10px;"><b>Active ARR</b></th><td style="max-width: 200px; word-wrap: break-word; padding-right: 10px;">'+thisCase.Account_Active_ARR__c +'</td></tr>'; 
           // emailBody += '<tr><th><b>Active ARR </b></th><td>'+thisCase.Account_Active_ARR__c  +'</td></tr>';
           emailBody += '<tr><th style="text-align: left; vertical-align: top; max-width: 300px; padding-right: 10px;"><b>Product</b></th><td style="max-width: 200px; word-wrap: break-word; padding-right: 10px;">'+thisCase.Products_Available__c +'</td></tr>'; 
          //emailBody += '<tr><th><b>Product </b></th><td>'+thisCase.Products_Available__c  +'</td></tr>'; 
            emailBody += '<tr><th style="text-align: left; vertical-align: top; max-width: 300px; padding-right: 10px;"><b>JIRA Status </b></th><td style="max-width: 200px; word-wrap: break-word; padding-right: 10px;">'+thisCase.Status_JIRA__c +'</td></tr>'; 
           //emailBody += '<tr><th><b>JIRA Status </b></th><td>'+thisCase.Status_JIRA__c  +'</td></tr>';
            emailBody += '<tr><th style="text-align: left; vertical-align: top; max-width: 300px; padding-right: 10px;"><b>Case Created Date </b></th><td style="max-width: 200px; word-wrap: break-word; padding-right: 10px;">'+thisCase.CreatedDate +'</td></tr>'; 
           //emailBody += '<tr><th><b>Case Created Date </b> </th><td>'+thisCase.CreatedDate  +'</td></tr>';
            emailBody += '<tr><th style="text-align: left; vertical-align: top; max-width: 300px; padding-right: 10px;"><b>JIRA Created Date </b></th><td style="max-width: 200px; word-wrap: break-word; padding-right: 10px;">'+thisCase.JIRA_Ticket_Created_Date__c +'</td></tr>'; 
           //emailBody += '<tr><th><b>JIRA Created Date </b></th><td>'+thisCase.JIRA_Ticket_Created_Date__c  +'</td></tr>'; 
            emailBody += '<tr><th style="text-align: left; vertical-align: top; max-width: 300px; padding-right: 10px;"><b>L3 Developer </b></th><td style="max-width: 200px; word-wrap: break-word; padding-right: 10px;">'+thisCase.L3_Developer_JIRA__c +'</td></tr>'; 
           //emailBody += '<tr><th><b>L3 Developer </b></th><td>'+thisCase.L3_Developer_JIRA__c +'</td></tr>'; 
           emailBody += '<tr><th style="text-align: left; vertical-align: top; max-width: 300px; padding-right: 10px;"><b>JIRA URL </b></th><td style="max-width: 200px; word-wrap: break-word; padding-right: 10px;">'+thisCase.Jira_URL__c +'</td></tr>'; 
           // emailBody += '<tr><th><b>JIRA URL </b></th><td>'+thisCase.Jira_URL__c +'</td></tr>';
           emailBody += '<tr><th style="text-align: left; vertical-align: top; max-width: 300px; padding-right: 10px;"><b>Release date</b></th><td style="max-width: 200px; word-wrap: break-word; padding-right: 10px;">'+thisCase.Planned_Release_Date_JIRA__c +'</td></tr>'; 
           // emailBody += '<tr><th><b>Release date </b></th><td>'+thisCase.Planned_Release_Date_JIRA__c +'</td></tr>';
            emailBody += '<tr><th style="text-align: left; vertical-align: top; max-width: 300px; padding-right: 10px;"><b>Owner </b></th><td style="max-width: 200px; word-wrap: break-word; padding-right: 10px;">'+thisCase.Owner.Name +'</td></tr>'; 
           //emailBody += '<tr><th><b>Owner </b></th><td>'+thisCase.Owner.Name +'</td></tr>';
           emailBody += '<tr><th style="text-align: left; vertical-align: top; max-width: 300px; padding-right: 10px;"><b>Link To Case  </b></th><td style="max-width: 200px; word-wrap: break-word; padding-right: 10px;">'+baseUrl+'/'+ thisCase.Id +'</td></tr>'; 
           // emailBody += '<tr><th><b>Link To Case </b></th><td>'+baseUrl+'/'+ thisCase.Id +'</td></tr>';
            emailBody += '<tr><th style="text-align: left; vertical-align: top; max-width: 300px; padding-right: 10px;"><b>Latest Comment </b></th><td style="max-width: 900px; word-wrap: break-word; padding-right: 10px;">'+thisCase.JIRA_Comment_Updates__c +'</td></tr>'; 
           //emailBody += '<tr><th><b>Latest Comment </b></th><td>'+thisCase.JIRA_Comment_Updates__c  +'</td></tr>';
            emailBody += '</table><br/><br/>';
            emailBody += 'Thanks!<br/>';
            emailBody += 'Team Salesforce';
            mail.setHtmlBody(emailBody);
            
            mailList.add(mail);
        }
        
        system.debug('mailList size: '+mailList.size());
        if(!mailList.isEmpty()) {
            try{
                
                RecursiveTriggerHandler.isFirstTime         = FALSE;
                RecursiveTriggerHandler.isFirstTimeRenewed  = FALSE;
                CaseConstants.isFirstTimeCase				= FALSE;
                
                Messaging.sendEmail(mailList);
                isSuccess = TRUE;
                for( Case thisCase : caseList ){
                    thisCase.JIRA_Notification_Rollout_Time__c = system.now();
                }
                update caseList;
                System.debug('Success');
                
                CaseConstants.isFirstTimeCase				= TRUE;
                RecursiveTriggerHandler.isFirstTime 		= TRUE;
                RecursiveTriggerHandler.isFirstTimeRenewed  = TRUE;
            }
            catch (Exception ex) {
                errorMessages.add('Unable to send email'+ ex.getMessage());
                System.debug('Errors : ' +errorMessages);
            }
        }
        
        if(isSuccess){
            return 'Success';
        }else{
            return 'Failed';
        }
        
    }
    
}