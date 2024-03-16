public class OpportunityClosureMail{
    public static String emailTemplateId;
    //public static Id recordId;
    @invocableMethod
    public static void sendEmail(Parameter[] par){
        string recordId;
        List<String> toUsers = new List<String>();
        List<String> SingleUsers = new List<String>();
        List<String> RoleIds = new List<String>();
        List<String> AdditionalIDs = new List<String>();
        List<string> useremails = new List<string>();
        List<string> ownerOrManager = new List<string>();
       //Uncomment List<string> noAttachmentRecipients = new List<string>(); 
        for(Parameter p: par){
            System.debug('To '+p.recipientList);
                if(p.emailTemplateId != null && p.emailTemplateId!=''){
                emailTemplateId = p.emailTemplateId;
            }
            if(p.recordId!=null && p.recordId!=''){
                recordId = p.recordId;
            }
                  if( p.ownerIdOrManagerId != null && p.ownerIdOrManagerId!=''){
                ownerOrManager=p.ownerIdOrManagerId.split(',');
                toUsers.addAll(p.ownerIdOrManagerId.split(','));
            }
            if(p.recordTypeName != 'International'){
                if( p.recipientList != null && p.recipientList!=''){
                    for(string tempRec : p.recipientList.remove('[').remove(']').split(',')){
                        if(tempRec != null && tempRec != '')
                            toUsers.add(tempRec);
                        	
                    }
                }
            if( p.roleID != null && p.roleID!='' ){
                RoleIds= p.roleID.split(',');
            }
            if( p.additionalMailIDs != null && p.additionalMailIDs!=''){
                AdditionalIDs=p.additionalMailIDs.split(','); //By Kartikeya
            }
            if( p.noAttachmentEmailIds != null && p.noAttachmentEmailIds!=''){
                //Uncomment noAttachmentRecipients = p.noAttachmentEmailIds.split(','); //By Bhavesh
            }
            }
            else{
                for(string tempRec : p.GCCRecipientList.remove('[').remove(']').split(',')){
                if(tempRec != null && tempRec != '')
                    toUsers.add(tempRec);
                    useremails.add(System.label.GCC_Category_Team);
            }
            }
        }
        System.debug('Recipient List '+toUsers);
        System.debug('Role Ids List'+RoleIds);
        List<User> listOfUsers=new List<User>();
        if(RoleIds.size()>0 || toUsers.size()>0){
            listOfUsers=new List<User>([Select Email from User where Id IN :toUsers OR UserRoleId IN :RoleIds ]) ;
        }
        if(listOfUsers.size()>0){
            for(User u1 : listOfUsers){
                useremails.add(u1.Email);
            }
        }
        System.debug('useremails***'+useremails);
        if(AdditionalIDs.size()>0){
            useremails.AddAll(AdditionalIDs);
        }
        System.debug('useremails****'+useremails);
        // useremails.add('lokesh@warpdrivetech.in');
        // useremails.add('renu.a@warpdrivetech.in');
        List<Opportunity> listOfOpportunity=new List<Opportunity>();
        Map<String,Contact> mapOfContactEmail=new Map<String,Contact>();
        List<Contact> listOfContacts=new List<Contact>();
        Map<String,String> mapOfStringWithString=new Map<String,String>();
        if(recordId!=null){
            id opportunityId=recordId;
            listOfOpportunity=new List<Opportunity>([SELECT id,Name from Opportunity WHERE id =: opportunityId ]);
        }
        if(useremails.size()>0){
            listOfContacts = new list<Contact>([select id,Email,Name,firstName,OwnerId,LastName from contact where Email IN : useremails ]);
        }
        System.debug('listOfContacts*****'+listOfContacts);
        if(listOfContacts.size()>0){
            for(Contact contactInstance:listOfContacts){
                if(!mapOfContactEmail.containsKey(contactInstance.Email)){
                    mapOfContactEmail.put(contactInstance.Email,contactInstance);
                }
                System.debug('contactrecords'+contactInstance.Email+''+contactInstance);
            }
        }
        if(listOfUsers.size()>0){
            for(User userInstance:listOfUsers){
                mapOfStringWithString.put(userInstance.Id,userInstance.Email );
                System.debug('userInstance.Id,userInstance.Email'+userInstance.Id+','+userInstance.Email);
            }
        }
        System.debug('Total Users List'+useremails);
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =: emailTemplateId ];
        for(Parameter parameterInstance: par){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            //Uncomment Messaging.SingleEmailMessage messageWithoutAttachment = new Messaging.SingleEmailMessage();
            //System.debug('mapOfContactEmail.containsKey(mapOfStringWithString.get(ownerOrManager[0]) Id '+ownerOrManager[0]+' key '+mapOfContactEmail.keySet()+' Values '+mapOfContactEmail.values() +' Values '+mapOfStringWithString.values()+' Keys '+mapOfStringWithString.keyset());
            //System.debug('mapOfContactEmail.get(mapOfStringWithString.get(ownerOrManager[0])).Id'+mapOfContactEmail.get(mapOfStringWithString.get(ownerOrManager[0])).Id);
            if(ownerOrManager.size()>0){
                for(String ownerOrManagerInstance:ownerOrManager){
                    if(mapOfStringWithString.containsKey(ownerOrManagerInstance)){
                        if(mapOfContactEmail.containsKey(mapOfStringWithString.get(ownerOrManagerInstance))){
                            message.setTargetObjectId(mapOfContactEmail.get(mapOfStringWithString.get(ownerOrManagerInstance)).Id); //ContactEmail
                            message.setReplyTo(mapOfStringWithString.get(ownerOrManagerInstance));
                            //Uncomment messageWithoutAttachment.setTargetObjectId(mapOfContactEmail.get(mapOfStringWithString.get(ownerOrManagerInstance)).Id);
                            //Uncomment messageWithoutAttachment.setReplyTo(mapOfStringWithString.get(ownerOrManagerInstance));
                        }
                    }
                }
            }
            //message.setSenderDisplayName('ClearTax');
            if(listOfContacts.size()>0){
                for(Contact conInstance:listOfContacts){
                    if(message.getTargetObjectId()==null){
                        message.setTargetObjectId(conInstance.Id);
                    }
                   //Uncomment  if(messageWithoutAttachment.getTargetObjectId()==null){
                     //Uncomment    messageWithoutAttachment.setTargetObjectId(conInstance.Id);
                   //Uncomment  }
                }
            }
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            message.setOrgWideEmailAddressId(Label.Clouser_Mail_From_Address);
            System.debug('emailTemplate'+emailTemplate);
            message.setTemplateID(emailTemplate.Id);
            message.setWhatId(parameterInstance.recordid);   //This is important for the merge fields in template to work
            message.toAddresses = useremails;
            System.debug('To Address :'+message.toAddresses);
            //without attachment
           //Uncomment  messageWithoutAttachment.setUseSignature(false);
           //Uncomment  messageWithoutAttachment.setBccSender(false);
           //Uncomment  messageWithoutAttachment.setSaveAsActivity(false);
           //Uncomment  messageWithoutAttachment.setOrgWideEmailAddressId(Label.Clouser_Mail_From_Address);
           //Uncomment  messageWithoutAttachment.setTemplateID(emailTemplate.Id);
           //Uncomment  messageWithoutAttachment.setWhatId(parameterInstance.recordid);
            //messageWithoutAttachment.toAddresses = noAttachmentRecipients;
          //Uncomment   System.debug('MessageWithoutAttachment To Address :'+messageWithoutAttachment.toAddresses);
            list<Messaging.Emailfileattachment> FileAttachments = new list<Messaging.Emailfileattachment>();
            List<id> ContentDocumentids = new List<id>();
            for(contentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid=:recordId])
            {
                ContentDocumentids.add(CDLink.ContentDocumentid);
            }
            for ( ContentVersion cversion : [SELECT title,
                                             PathOnClient, FileType,
                                             versiondata
                                             FROM contentversion
                                             WHERE ContentDocumentId IN :ContentDocumentids
                                            ])
            {
                blob WOCFbody = cversion.versiondata;
                system.debug('body : '+WOCFbody+'-----------'+cversion.title);
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(opportunity.name+'-'+cversion.title+'.'+ cversion.FileType);
                efa.setBody(WOCFbody);
                fileAttachments.add(efa);
            }
            message.setFileAttachments(FileAttachments);
            //message.setHtmlBody('<html></html>');
            messages.add(message);
           //Uncomment  messages.add(messageWithoutAttachment);
        }
        for(Messaging.SingleEmailMessage msgInstance : messages ){
            system.debug('msgInstance.getTargetObjectId() : '+msgInstance.getTargetObjectId());
        }
        Messaging.SendEmailResult[] results=new  List<Messaging.SendEmailResult>();
        System.debug('******message********'+messages);
        if(messages.size()>0){
            results = Messaging.sendEmail(messages,false);
        }
        if(results.size()>0){
            if (results[0].success)
            {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }
        }
    }
    public class Parameter{
        @invocablevariable(required=true)
        public String recordId;
        @invocablevariable
        public String recipientList;
        @invocablevariable
        public String GCCRecipientList;
        @invocablevariable
        public String recordTypeName;
        @invocablevariable(required=true)
        public String emailTemplateId;
        @invocablevariable
        public String additionalMailIDs;
        @invocablevariable
        public String roleID;
        @invocablevariable(required=true)
        public String ownerIdOrManagerId;
        @invocablevariable
        public String noAttachmentEmailIds;
    }
}