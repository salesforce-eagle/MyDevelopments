public class CTX_ProjectInactivityEmailHelper {
    
    Public static void sendInactivityEmail(){
        
        Date 				dateToday 					= Date.today();
        Date 				sevenWorkingDaysBeforeToday = BusinessDays.AddBusinessDays(dateToday, -7);
        List<Project__c> 	parentProjectsList 			= new List<Project__c>();
        Id 					defaultMailId 				= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                           Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        List<String> 		errorMessages 				= new List<String>();
        
        parentProjectsList 								= [ SELECT id, Name, Issue_Type__c, Issue_Description__c, CreatedDate, 
                                                           Project_Stage__c, Status__c, Pm_Project_Owner_Lookup__r.Email, 
                                                           Pm_Project_Owner_Lookup__c ,CTX_SE__c ,SE_Owner_Email__c 
                                                           FROM Project__c WHERE Status__c NOT IN ('Churn') 
                                                           AND Project_Stage__c NOT IN ('Live') 
                                                           AND CreatedDate <=: sevenWorkingDaysBeforeToday ];
        
        Map<Id, Project__c> mapOfParentProjects			= new Map<Id, Project__c>();
        mapOfParentProjects.putAll(parentProjectsList);
        
        List<Project__History> historyProjectsList		= new List<Project__History>();
        historyProjectsList								= [ SELECT Id, ParentId, CreatedDate, Field 
                                                           FROM Project__History 
                                                           WHERE ParentId IN:mapOfParentProjects.keySet() 
                                                           AND Field IN ('Issue_Type__c', 'Issue_Description__c') 
                                                           AND CreatedDate >=: sevenWorkingDaysBeforeToday ];
        
        List<Messaging.SingleEmailMessage> 	mailList 	= new List<Messaging.SingleEmailMessage>();
        
        if(historyProjectsList != NULL)
            for(Project__History historyProjectInstance : historyProjectsList){
                mapOfParentProjects.remove(historyProjectInstance.ParentId);
            }
        
        for(Id thisProjectsId : mapOfParentProjects.keySet()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.SaveAsActivity = TRUE;
            mail.setWhatId(thisProjectsId);
            List<String> ccAddresses = new List<String>();
			List<String> toAddresses = new List<String>();
            
            if(mapOfParentProjects.get(thisProjectsId).Pm_Project_Owner_Lookup__c != NULL)
                toAddresses.add(mapOfParentProjects.get(thisProjectsId).Pm_Project_Owner_Lookup__r.Email);
                toAddresses.add('bhavesh.jindal@cleartax.in');
            if(mapOfParentProjects.get(thisProjectsId).CTX_SE__c != NULL)
                ccAddresses.add(mapOfParentProjects.get(thisProjectsId).SE_Owner_Email__c);
            
            String body = 'Your Attention Please!  '+','+'<br/>';
            body += 'Issue Type and Issue Description for below Project has not been updated since last 7 working Days. Please take necessary action.'+'<br/>';
            body += '<b>Project name :</b>'+' '+mapOfParentProjects.get(thisProjectsId).Name+'		'+'<b>Created Date :</b>'+mapOfParentProjects.get(thisProjectsId).CreatedDate+'<br/>';
            body += ''+'<br/>';
            body += '<b>Issue Type :</b>'+mapOfParentProjects.get(thisProjectsId).Issue_Type__c+'<br/>';
            body += '<b>Issue Description :</b>'+' '+mapOfParentProjects.get(thisProjectsId).Issue_Description__c+'<br/>';
            body += ''+'<br/>';
            body +='Regards'+',<br/>'+'\n Project Inactivity Monitoring'+'<br/>';
            
            mail.setSubject('Inactivity in Project.');
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
                errorMessages.add('Unable to send email'+ ex.getMessage());
            }
        }
        
        //debugs
        System.debug( ' Size of Map : ' + mapOfParentProjects.keySet().size());
        System.debug('Size : ' + parentProjectsList.size() + ' parentProjectsList '+ parentProjectsList);
        System.debug('Size : ' + historyProjectsList.size() + ' historyProjectsList '+ historyProjectsList);
        System.debug('today date'+ dateToday);
        System.debug('subtracted date'+sevenWorkingDaysBeforeToday);
        
    }
    
}