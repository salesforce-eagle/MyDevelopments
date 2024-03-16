public class CTX_CSMJourneyHandler {
    @AuraEnabled
    public static List<Task> getRelatedTasks(String recordId, String taskRecordTypeName) {

        return [SELECT Id, Description, Status, ActivityDate, CompletedDateTime, Status_Of_Customer__c, Subject FROM Task WHERE WhatId =: recordId AND RecordType.Name =: taskRecordTypeName Order By Activitydate];
    }
    @AuraEnabled
    public static void updateTask(String taskId, Map<String, String> taskObject, List<object>	fileDetails){
        if(fileDetails != null){
            if(!fileDetails.isEmpty()){
                list<Id> lstCntVerIds = new list<Id>();
                List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
                for (Object file : fileDetails) {
                    FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
                    ContentVersion objCntVersion = new ContentVersion();
                    objCntVersion.PathOnClient = fileData.Title;
                    objCntVersion.Title = fileData.Title;
                    objCntVersion.VersionData = fileData.VersionData;
                    lstVersionsToInsert.add(objCntVersion);
                }
                
                list<Database.saveResult> res = Database.insert(lstVersionsToInsert);
                for (Database.SaveResult saveResult : res) {
                    if(saveResult.isSuccess()) {
                        lstCntVerIds.add(saveResult.getId());
                    }
                }
                
                List<ContentDocumentLink> ctnLinks = new List<ContentDocumentLink>();
                for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: lstCntVerIds]){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cv.ContentDocumentId;
                    cdl.LinkedEntityId = taskId;
                    cdl.ShareType = 'V';
                    ctnLinks.add(cdl);
                }
                insert ctnLinks;
            }
        }
        if(!taskObject.keySet().isEmpty()){
            Task tsk = new Task();
            for(String field : taskObject.keySet()){
                tsk.put(field, taskObject.get(field));
            }
            update tsk;
        }
    }
    
    @AuraEnabled
    public static IntroductoryEmailWrapper getIntroductoryEmailContent(String recordId){
        Asset currentAsset = [SELECT Id, Name, AccountId, Account.Name, Product2.Product_Line__c, Account.Onboarding_Owner__c, 
                              Account.Sales_Owner__r.Email, Account.Onboarding_Owner__r.Name, Account.Onboarding_Owner__r.Email, 
                              Account.Onboarding_Owner__r.MobilePhone, Account.Onboarding_Owner__r.Phone, 
                              Account.Onboarding_Owner__r.Manager.Name, Account.Onboarding_Owner__r.Manager.Email, Account.Onboarding_Owner__r.Manager.Manager.Name, 
                              Account.Onboarding_Owner__r.Manager.Phone, Account.Onboarding_Owner__r.Manager.MobilePhone, Account.Onboarding_Owner__r.Manager.Manager.Email,
                              Account.Onboarding_Owner__r.Manager.Manager.Phone, Account.Onboarding_Owner__r.Manager.Manager.MobilePhone, Product2.OrderForm_Product_Name__c 
                              FROM Asset WHERE Id =: recordId];
        List<Contact> conList = [SELECT Id, Name, Email FROM Contact WHERE AccountId =: currentAsset.AccountId AND Is_Communicable__c = true];
        IntroductoryEmailWrapper wrapInstance = new IntroductoryEmailWrapper();
        
        //List<CSM_Product_Line_To_Action_Item_Email__mdt> mdtList = [SELECT Id, Product_Line__c, Action_Items__c, Order__c FROM CSM_Product_Line_To_Action_Item_Email__mdt WHERE Product_Line__c =: currentAsset.Product2.Product_Line__c ORDER BY Order__c];
        if(currentAsset != null){
            String body = 'Dear '+ currentAsset.Account.Name +' Team,'+'<br/><br/>';
            body += 'I, '+ currentAsset.Account.Onboarding_Owner__r.Name +' am pleased to welcome you into the ClearTax community & am ready to onboard you at the earliest. I will be your Success Manager and will be available for your assistance between 10AM - 7PM (Mon-Fri).'+'<br/><br/>';
            body += 'Thank you for choosing Clear as your partner for <b>'+ currentAsset.Product2.OrderForm_Product_Name__c + '</b><br/><br/>';
            body += '<b>Overview of Next Action Points : Onboarding & Product Training</b>'+ '<br/>';
            body += 'I will connect with you shortly to fix a date & time for a one-time account setup & product training session for you & your team members. During this onboarding session, we will take you through the following important features of our software -<br/><br/>';
            body += '<ul style="list-style-type: number;">';
            /*if(mdtList != null){
                if(!mdtList.isEmpty()){
                    for(CSM_Product_Line_To_Action_Item_Email__mdt mdt : mdtList){
                        body += '<li>' + mdt.Action_Items__c + '</li>';
                    }
                }
            }*/
            
            body += '<li>Sign-up into the software</li>';
            body += '<li>Setting up businesses & GSTINs</li>';
            body += '<li>Sales & Purchase Templates</li>';
            body += '<li>GSTR 1 & 3B Filing - Data upload & validation</li>';
            body += '<li>PR vs 2A/2B Reconciliation</li>';
            body += '<li>E-Invoicing & E-Waybill</li>';
            body += '<li>Reports & other add-on features</li>';
            body += '</ul><br/>';
            body += '<b>Pre-requisites for product onboarding -</b><br/>' ;
            body += 'We at Clear, value your time dearly. For a quick & smooth onboarding, we request you to share the following essential details beforehand or keep them handy during the onboarding session:<br/>';
            body += '<ul style="list-style-type: number;">';
            body += '<li><span style="text-decoration: underline;">Admin email ID</span> - The email-ID using which Clear account will be created ( Decision Maker, official e-mail ID of the user is expected )</li>';
            body += '<li><span style="text-decoration: underline;">List of all GSTINs</span></li>';
            body += '<li>Availability/ Reachability on the phone number <span style="text-decoration: underline;">(registered on govt. portal)</span> during onboarding for OTP verification purposes </li>';
            body += '<li><span style="text-decoration: underline;">List of team members / employees</span> who will be using the software (<span style="text-decoration: underline;">with email ids</span>)  </li>';
            body += '<li><span style="text-decoration: underline;">1-month sales & purchase data</span> for successful product demonstration & excel ingestion template creation </li>';
            body += '</ul><br/>';
            body += 'Contact Details & Escalation Matrix ( for all account & service related queries )<br/><br/>';
            body += '<table border="1px">';
            body += '<tr>';
            body += '<th bgcolor="yellow">POC Name</th>';
            body += '<th bgcolor="yellow">Designation</th>';
            body += '<th bgcolor="yellow">Phone number</th>';
            body += '<th bgcolor="yellow">Email ID</th>';
            body += '<th bgcolor="yellow">Contact type</th>';
            body += '</tr>';
            body += '<tr>';
            body += '<td style="text-align:center"><b>'+currentAsset.Account.Onboarding_Owner__r.Name+'</b></td>';
            body += '<td style="text-align:center">Customer Success Manager</td>';
            if(currentAsset.Account.Onboarding_Owner__r.Phone != NULL)
                body += '<td style="text-align:center">'+currentAsset.Account.Onboarding_Owner__r.Phone+'</td>';
            else if(currentAsset.Account.Onboarding_Owner__r.MobilePhone != NULL)
                body += '<td style="text-align:center">'+currentAsset.Account.Onboarding_Owner__r.MobilePhone+'</td>';
            else
                body += '<td style="text-align:center"> </td>';
            body += '<td style="text-align:center">'+'<a href="mailto:'+currentAsset.Account.Onboarding_Owner__r.Email+'">'+currentAsset.Account.Onboarding_Owner__r.Email+'</a>'+'</td>';
            body += '<td style="text-align:center">Primary contact (L1)</td>';
            body += '</tr>';
            body += '<tr>';
            body += '<td style="text-align:center"><b>'+currentAsset.Account.Onboarding_Owner__r.Manager.Name+'</b></td>';
            body += '<td style="text-align:center">Customer Success Leader</td>';
            if(currentAsset.Account.Onboarding_Owner__r.Manager.Phone != NULL)
                body += '<td style="text-align:center">'+currentAsset.Account.Onboarding_Owner__r.Manager.Phone+'</td>';
            else if(currentAsset.Account.Onboarding_Owner__r.Manager.MobilePhone != NULL)
                body += '<td style="text-align:center">'+currentAsset.Account.Onboarding_Owner__r.Manager.MobilePhone+'</td>';
            else
                body += '<td style="text-align:center"> </td>';
            body += '<td style="text-align:center">'+'<a href="mailto:'+currentAsset.Account.Onboarding_Owner__r.Manager.Email+'">'+currentAsset.Account.Onboarding_Owner__r.Manager.Email+'</a>'+'</td>';
            body += '<td style="text-align:center">Secondary contact (L2)</td>';
            body += '</tr>';
            body += '<tr>';
            body += '<td style="text-align:center"><b>'+currentAsset.Account.Onboarding_Owner__r.Manager.Manager.Name+'</b></td>';
            body += '<td style="text-align:center">Customer Success Leader</td>';
            if(currentAsset.Account.Onboarding_Owner__r.Manager.Manager.Phone != NULL)
                body += '<td style="text-align:center">'+currentAsset.Account.Onboarding_Owner__r.Manager.Manager.Phone+'</td>';
            else if(currentAsset.Account.Onboarding_Owner__r.Manager.Manager.MobilePhone != NULL)
                body += '<td style="text-align:center">'+currentAsset.Account.Onboarding_Owner__r.Manager.Manager.MobilePhone+'</td>';
            else
                body += '<td style="text-align:center"> </td>';
            body += '<td style="text-align:center">'+'<a href="mailto:'+currentAsset.Account.Onboarding_Owner__r.Manager.Manager.Email+'">'+currentAsset.Account.Onboarding_Owner__r.Manager.Manager.Email+'</a>'+'</td>';
            body += '<td style="text-align:center">Secondary contact (L3)</td>';
            body += '</tr>';
            body += '</table>';
            body += '<br/><br/>';
            body += 'Thanks again for choosing Clear as your preferred solution.<br/>';
            body += 'Looking forward to a long & successful partnership ahead,<br/><br/>';
            body += 'Regards,<br/>';
            body += 'Team Clear (formerly known as ClearTax)<br/>';
            
            wrapInstance.htmlBody = body;
            wrapInstance.subject = 'Warm Greetings! ' + currentAsset.Account.Name + ' Welcome to the Cleartax community';
            wrapInstance.relatedAssetRecord = currentAsset;
            wrapInstance.toContacts = conList;
            List<String> ccAddress = new List<String>();
            if(currentAsset.Account?.Onboarding_Owner__r?.Email != null){
            	ccAddress.add(currentAsset.Account.Onboarding_Owner__r.Email);   
            }
            if(currentAsset.Account?.Onboarding_Owner__r?.Manager?.Email == NULL){
                ccAddress.add(currentAsset.Account.Onboarding_Owner__r.Manager.Email);
            }
            if(currentAsset.Account.Sales_Owner__c != null){
            	ccAddress.add(currentAsset.Account.Sales_Owner__r.Email);
            }  
            
            if(!ccAddress.isEmpty()){
                wrapInstance.ccAddress = ccAddress;
            }
        }
         
        return wrapInstance;
    }
    
    @AuraEnabled
    public static void sendIntoductoryEmail(Object emailWrapper){
        IntroductoryEmailWrapper 			emailWrapData 	= (IntroductoryEmailWrapper)JSON.deserialize(JSON.serialize(emailWrapper), IntroductoryEmailWrapper.class);
        List<Messaging.SingleEmailMessage> 	mailList 		= new List<Messaging.SingleEmailMessage>();
        Id 									defaultMailId 	= [SELECT Id FROM OrgWideEmailAddress WHERE 
                                                               Address =: System.Label.CSM_Intoductory_Mail_Org_Wide_Generic_Email]?.Id;
        List<String> toAddresses = new List<String>();
        for(Contact conInstance : (List<Contact>)emailWrapData.toContacts){
            toAddresses.add(conInstance.Email);
        }
        
        if(toAddresses == null){
            
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.SaveAsActivity = TRUE;
        mail.setWhatId(emailWrapData.relatedAssetRecord.Id);
        mail.setSubject(emailWrapData.subject);
        mail.setHtmlBody(emailWrapData.htmlBody);
        mail.setToAddresses(toAddresses);
        if(emailWrapData.ccAddress != null){
        	mail.setCcAddresses(emailWrapData.ccAddress);   
        }
        mail.setOrgWideEmailAddressId(defaultMailId);
        mailList.add(mail);
        
        if(!mailList.isEmpty()) {
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
                
                if(results[0].isSuccess()){
                    update (new Asset(Id = emailWrapData.relatedAssetRecord.Id, Introduction_Email_Kickoff_Call_Status__c = 'Completed'));
                }
            }
            catch (Exception ex) {
                System.debug('Unable to send CSM Intro email'+ ex.getMessage());
            }
        }
    }
    
    public class FileInfo {
        public String Title;
        public Blob VersionData;
    }
    
    public class IntroductoryEmailWrapper {
        @AuraEnabled
        public Asset relatedAssetRecord{get;set;}
        @AuraEnabled
        public List<Contact> toContacts{get;set;}
        @AuraEnabled
        public List<String> ccAddress{get;set;}
        @AuraEnabled
        public String htmlBody{get;set;}
        @AuraEnabled
        public String subject{get;set;}
    }
}