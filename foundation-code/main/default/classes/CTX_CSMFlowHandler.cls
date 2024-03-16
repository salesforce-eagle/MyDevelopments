public class CTX_CSMFlowHandler {
    
    public static void updateOnboardingStatus(List<Asset> assetList){
        for(Asset thisAsset : assetList){
            if(thisAsset.Sales_handover_status__c == 'Started' || thisAsset.Sales_handover_status__c == 'WIP' || thisAsset.Sales_handover_status__c == 'Completed'){
                thisAsset.Onboarding_status__c = 'Onboarding Started';
            }
            if(thisAsset.Onboarding_session_status__c == 'Completed'){
                thisAsset.Onboarding_status__c = 'Onboarding Complete';
                //onboardingSessionCompletedNotification(assetList);
            }
            if(thisAsset.Onboarding_session_status__c != 'Started' && thisAsset.Onboarding_session_status__c != 'Partially completed' && thisAsset.Onboarding_session_status__c != 'Completed' && thisAsset.Onboarding_session_status__c != NULL && thisAsset.Sales_handover_status__c == NULL){
                thisAsset.Onboarding_status__c = 'Onboarding Pending';
            }
        }
    }
    
    public static void updateOnboardingStage(List<Asset> assetList){
        for(Asset thisAsset : assetList){
            if(thisAsset.Sales_handover_status__c == 'Started' || thisAsset.Sales_handover_status__c == 'WIP' || thisAsset.Sales_handover_status__c == 'Completed'){
                thisAsset.Onboarding_Stage__c = 'Sales Handover';
            }
            if(thisAsset.Kick_off_status__c == 'Started' || thisAsset.Kick_off_status__c == 'Completed'){
                thisAsset.Onboarding_Stage__c = 'Kick-off';
            }
            if(thisAsset.Onboarding_session_status__c == 'Started' || thisAsset.Onboarding_session_status__c == 'Partially completed' || thisAsset.Onboarding_session_status__c == 'Completed'){
                thisAsset.Onboarding_Stage__c = 'Onboarding sessions';
            }
            if(thisAsset.Sales_handover_status__c == NULL && (thisAsset.Kick_off_status__c == NULL || thisAsset.Kick_off_status__c =='To be started' ) && (thisAsset.Onboarding_session_status__c == NULL || thisAsset.Onboarding_session_status__c == 'To be started')){
                thisAsset.Onboarding_Stage__c = 'Not Started';
            }
            if(thisAsset.Sales_handover_status__c != 'Completed' || thisAsset.Kick_off_status__c != 'Completed'){
                thisAsset.Onboarding_session_status__c = NULL;
                thisAsset.Onboarding_session_start_date__c  = NULL;
                thisAsset.Last_Onboarding_session_date__c = NULL;
                thisAsset.Onboarding_pending_reason_15_days__c = NULL;
                thisAsset.Support_required_on_onboarding__c = NULL;
                thisAsset.Features_covered_in_onboarding__c = NULL;
                thisAsset.Onboarding_status__c = Null;
                if(thisAsset.Sales_handover_status__c == 'Started' || thisAsset.Sales_handover_status__c == 'WIP' || thisAsset.Sales_handover_status__c == 'Completed'){
                    thisAsset.Onboarding_Stage__c = 'Sales Handover';
                }
                if(thisAsset.Kick_off_status__c == 'Started' || thisAsset.Kick_off_status__c == 'Completed'){
                    thisAsset.Onboarding_Stage__c = 'Kick-off';
                }
                if(thisAsset.Onboarding_session_status__c == 'Started' || thisAsset.Onboarding_session_status__c == 'Partially completed' || thisAsset.Onboarding_session_status__c == 'Completed'){
                    thisAsset.Onboarding_Stage__c = 'Onboarding sessions';
                }
                if(thisAsset.Sales_handover_status__c == NULL && (thisAsset.Kick_off_status__c == NULL || thisAsset.Kick_off_status__c =='To be started' ) && (thisAsset.Onboarding_session_status__c == NULL || thisAsset.Onboarding_session_status__c == 'To be started')){
                    thisAsset.Onboarding_Stage__c = 'Not Started';
                }
                updateOnboardingStatus(assetList);
            }
        }
    }
    
    /*public static void stageCompletedValidation(List<Asset> assetList){
        for(Asset thisAsset : assetList){
            if(thisAsset.Sales_handover_start_date__c == NULL && thisAsset.Sales_handover_status__c == 'Completed'){
                thisAsset.addError('Sales Handover Cannot be marked complete without entering Sales Handover Start Date');
            }
            if(thisAsset.Kick_off_start_date__c == NULL && thisAsset.Kick_off_status__c == 'Completed'){
                thisAsset.addError('Sales Handover Cannot be marked complete without entering Sales Handover Start Date');
            }
            if(thisAsset.Onboarding_start_date__c == NULL && thisAsset.Onboarding_session_status__c == 'Completed'){
                thisAsset.addError('Sales Handover Cannot be marked complete without entering Sales Handover Start Date');
            }
        }
    }*/
    
    public static void updateOnboardingDate(List<Asset> assetList){
        for(Asset thisAsset : assetList){
            thisAsset.Onboarding_process_start_date__c = thisAsset.Sales_handover_start_date__c ;
            thisAsset.Onboarding_Completed_Date__c  = thisAsset.Last_Onboarding_session_date__c;
        }
    }
    public static void updateSalesHandoverDate(List<Asset> assetList){
        for(Asset thisAsset : assetList){
            if(thisAsset.Sales_handover_status__c == 'Started'){
                thisAsset.Sales_handover_start_date__c = Date.today() ;
                thisAsset.Onboarding_process_start_date__c = thisAsset.Sales_handover_start_date__c ;
            }
            if(thisAsset.Sales_handover_status__c == 'Completed'){
                if(thisAsset.Sales_handover_start_date__c == NULL){
                    thisAsset.addError('Sales Handover Cannot be marked complete without entering Sales Handover Start Date');
                }
                else{
                    thisAsset.Sales_handover_end_date__c = Date.today() ;
                    thisAsset.Number_of_days_for_sale_handover__c = (Date.valueOf(thisAsset.CreatedDate)).daysBetween(thisAsset.Sales_handover_end_date__c);
                }
            }
            if(thisAsset.Sales_handover_status__c != 'Completed'){
                thisAsset.Sales_handover_end_date__c = null;
                thisAsset.Number_of_days_for_sale_handover__c = null;
            }
            if(thisAsset.Sales_handover_status__c == null){
                thisAsset.Sales_handover_start_date__c = null;
                thisAsset.Onboarding_process_start_date__c = null ;
            }
        }
    }
    public static void updateKickOffDate(List<Asset> assetList){
        for(Asset thisAsset : assetList){
            if(thisAsset.Kick_off_status__c == 'Started'){
                thisAsset.Kick_off_start_date__c  = Date.today() ;
            }
            if(thisAsset.Kick_off_status__c == 'Completed'){
                if(thisAsset.business_questionnarie_completed__c != TRUE){
                    thisAsset.addError('Business Questionnarie not completed.');
                }
                if(thisAsset.Sales_handover_status__c != 'Completed'){
                    thisAsset.addError('Kick-Off cannot be completed unless Sales Handover is marked Completed.');
                }
                if(thisAsset.Kick_off_start_date__c == NULL){
                    thisAsset.addError('Kick Off Cannot be marked complete without entering Kick Off Start Date');
                }
                else{
                    thisAsset.Kick_off_end_date__c  = Date.today() ;
                }
            }
            if(thisAsset.Kick_off_status__c != 'Completed'){
                thisAsset.Kick_off_end_date__c = null;
            }
            if(thisAsset.Kick_off_status__c == null || thisAsset.Kick_off_status__c =='To be started'){
                thisAsset.Kick_off_start_date__c = null;
            }
        }
    }
    public static void onboardingSessionValidation(List<Asset> assetList){
        for(Asset thisAsset : assetList){
            System.debug('thisAsset.Sales_handover_status__c : '+thisAsset.Sales_handover_status__c);
            System.debug('thisAsset.Kick_off_status__c : '+thisAsset.Kick_off_status__c);
            
            if(!(thisAsset.Sales_handover_status__c == 'Completed' && thisAsset.Kick_off_status__c == 'Completed')){
                thisAsset.addError('Onboarding Session Fields are not editable unless Sales Handover and Kick-Off status are marked as Completed.');
            }
            
        }
    }
    public static void feedbackFormValidation(List<Asset> assetList){
        for(Asset thisAsset : assetList){
            if(!(thisAsset.Onboarding_session_status__c == 'Completed')){
                thisAsset.addError('Feedback Form Fields are not editable unless Onboarding Session is marked as Completed.');
            }
        }
    }
    public static void updateOnboardingSessionDate(List<Asset> assetList){
        for(Asset thisAsset : assetList){
            if(thisAsset.Onboarding_session_status__c == 'Started'){
                thisAsset.Onboarding_session_start_date__c  = Date.today() ;
            }
            if(thisAsset.Onboarding_session_status__c == 'Completed'){
                if(thisAsset.Onboarding_session_start_date__c  == NULL){
                    thisAsset.addError('Onboarding Session Cannot be marked complete without entering Onboarding Session Start Date');
                }
                thisAsset.Last_Onboarding_session_date__c = Date.today() ;
                thisAsset.Onboarding_Completed_Date__c = thisAsset.Last_Onboarding_session_date__c ;
            }
            if(thisAsset.Onboarding_session_status__c != 'Completed'){
                thisAsset.Last_Onboarding_session_date__c = null;
                thisAsset.Onboarding_Completed_Date__c = null ;
            }
            if(thisAsset.Onboarding_session_status__c == null || thisAsset.Onboarding_session_status__c == 'To be started'){
                thisAsset.Onboarding_session_start_date__c  = null;
            }
        }
    }
    public static void updateFeedbackRecievedDate(List<Asset> assetList){
        for(Asset thisAsset : assetList){
            if(thisAsset.Rate_the_overall_on_boarding__c != NULL)
            	thisAsset.Feedback_Received_Date__c = Date.today();
            else
                thisAsset.Feedback_Received_Date__c = NULL;
        }
    }
    
    public static void datesValidation(List<Asset> assetList){
        for(Asset thisAsset : assetList){
            if(thisAsset.Sales_handover_start_date__c != null && thisAsset.Sales_handover_end_date__c != null){
                if(thisAsset.Sales_handover_start_date__c > thisAsset.Sales_handover_end_date__c)
                    thisAsset.addError('Sales Handover Start Date cannot be greater than Sales Handover End Date');
            }
            if(thisAsset.Kick_Off_start_date__c != null && thisAsset.Kick_Off_end_date__c != null){
                if(thisAsset.Kick_Off_start_date__c > thisAsset.Kick_Off_end_date__c)
                    thisAsset.addError('Kick Off Start Date cannot be greater than Kick Off End Date');
            }
            if(thisAsset.Onboarding_session_start_date__c  != null && thisAsset.Last_Onboarding_session_date__c != null){
                if(thisAsset.Onboarding_session_start_date__c  > thisAsset.Last_Onboarding_session_date__c)
                    thisAsset.addError('Onboarding Session Start Date cannot be greater than Onboarding Session End Date');
            }
        }
    }
    
    public static void onboardingSessionCompletedNotification(List<Asset> assetList){
        
        Id 					defaultMailId 				= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                           Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        List<Messaging.SingleEmailMessage> 	mailList 	= new List<Messaging.SingleEmailMessage>();
        List<String> 		errorMessages 				= new List<String>();
        for(Asset thisAsset : assetList){
            if(thisAsset.Onboarding_status__c == 'Onboarding Complete'){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.SaveAsActivity = TRUE;
                mail.setWhatId(thisAsset.Id);
                List<String> ccAddresses = new List<String>();
                List<String> toAddresses = new List<String>();
                String subject ='Onboarding Complete for '+thisAsset.Name+'';
                
                toAddresses.add(thisAsset.Account_Owner_Email__c);
                ccAddresses.add(thisAsset.Account.Onboarding_Owner__r.Email);
                ccAddresses.add(thisAsset.Account.Onboarding_Owner__r.Manager.Email);
                ccAddresses.add('bhavesh.jindal@cleartax.in');
                ccAddresses.add('soumya.goondla@cleartax.in');
                
                String body = 'Hi '+thisAsset.Account.Owner.Name+','+'<br/>';
                body += 'Onboarding Completed for below Asset.'+'<br/>';
                body += '<b>Asset Name :</b>'+' '+thisAsset.Name+'<br/>';
                body += '<b>Asset ID :</b>'+' '+thisAsset.Id+'<br/>';
                body += ''+'<br/>';
                body += ''+'<br/>';
                body +='Regards'+',<br/>'+'\n Asset Monitoring'+'<br/>';
                
                mail.setSubject(subject);
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
        }
    }
    
    
    public static void salesHandoverSupportNotification(List<Asset> assetList){
        Id 					defaultMailId 				= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                           Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        List<Messaging.SingleEmailMessage> 	mailList 	= new List<Messaging.SingleEmailMessage>();
        List<String> 		errorMessages 				= new List<String>();
        
        for(Asset thisAsset : assetList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.SaveAsActivity = TRUE;
            mail.setWhatId(thisAsset.Id);
            List<String> ccAddresses = new List<String>();
			List<String> toAddresses = new List<String>();
            String subject ='Support Required for '+thisAsset.Name;
            
            if(thisAsset.Support_required_on_sales_handover__c != NULL){
                if(thisAsset.Support_required_on_sales_handover__c == 'Integrations'){
                    toAddresses.add(thisAsset.Account_Owner_Email__c);
                    ccAddresses.add(thisAsset.Account.Owner.Manager.Email);
                    ccAddresses.add('bhavesh.jindal@cleartax.in');
                    ccAddresses.add('soumya.goondla@cleartax.in');
                }
                
                if(thisAsset.Support_required_on_sales_handover__c == 'Sales'){
                    toAddresses.add(thisAsset.Owner.Email);
                    ccAddresses.add(thisAsset.Owner.Manager.Email);
                    ccAddresses.add('bhavesh.jindal@cleartax.in');
                    ccAddresses.add('soumya.goondla@cleartax.in');
                }
            }
                        
            String body = '';
            
            if(thisAsset.Support_required_on_sales_handover__c == 'Integrations')
                body += 'Hi '+thisAsset.Account.Owner.Name+','+'<br/>';
            	body += 'Integration Support required for Sales Handover for below Asset. Please take necessary action.'+'<br/>';
            if(thisAsset.Support_required_on_sales_handover__c == 'Sales')
                body += 'Hi '+thisAsset.Owner.Name+','+'<br/>';
                body += 'Sales Support required for for Sales Handover below Asset. Please take necessary action.'+'<br/>';
            
            body += '<b>Asset name :</b>'+' '+thisAsset.Name+'<br/>';
            body += '<b>Asset ID :</b>'+' '+thisAsset.Id+'<br/>';
            body += ''+'<br/>';
            body += ''+'<br/>';
            body +='Regards'+',<br/>'+'\n Asset Monitoring'+'<br/>';
            
            mail.setSubject(subject);
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
    }
    
    public static void onboardingSessionSupportNotification(List<Asset> assetList){
        Id 					defaultMailId 				= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                           Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        List<Messaging.SingleEmailMessage> 	mailList 	= new List<Messaging.SingleEmailMessage>();
        List<String> 		errorMessages 				= new List<String>();
        
        for(Asset thisAsset : assetList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.SaveAsActivity = TRUE;
            mail.setWhatId(thisAsset.Id);
            List<String> ccAddresses = new List<String>();
			List<String> toAddresses = new List<String>();
            String subject ='Support Required for '+thisAsset.Name;
            
            if(thisAsset.Support_required_on_onboarding__c != NULL){
                if(thisAsset.Support_required_on_onboarding__c == 'Integrations'){
                    toAddresses.add(thisAsset.Account_Owner_Email__c);
                    ccAddresses.add(thisAsset.Account.Owner.Manager.Email);
                    toAddresses.add('bhaveshjindal97@gmail.com');
                    ccAddresses.add('soumya.goondla@cleartax.in');
                }
                
                if(thisAsset.Support_required_on_onboarding__c == 'Sales'){
                    toAddresses.add(thisAsset.Owner.Email);
                    ccAddresses.add(thisAsset.Owner.Manager.Email);
                    toAddresses.add('bhavesh.jindal@cleartax.in');
                    ccAddresses.add('soumya.goondla@cleartax.in');
                }
            }
            
            String body = '';
            
            if(thisAsset.Support_required_on_onboarding__c == 'Integrations')
                body += 'Hi '+thisAsset.Account.Owner.Name+','+'<br/>';
            	body += 'Integration Support required for Onboarding Session for below Asset. Please take necessary action.'+'<br/>';
            if(thisAsset.Support_required_on_onboarding__c == 'Sales')
                body += 'Hi '+thisAsset.Owner.Name+','+'<br/>';
                body += 'Sales Support required for Onboarding Session for below Asset. Please take necessary action.'+'<br/>';
            
            body += '<b>Asset name :</b>'+' '+thisAsset.Name+'<br/>';
            body += '<b>Asset ID :</b>'+' '+thisAsset.Id+'<br/>';
            body += ''+'<br/>';
            body += ''+'<br/>';
            body +='Regards'+',<br/>'+'\n Asset Monitoring'+'<br/>';
            
            mail.setSubject(subject);
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
    }
    
}