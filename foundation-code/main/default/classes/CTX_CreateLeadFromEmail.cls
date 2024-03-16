global class CTX_CreateLeadFromEmail implements Messaging.InboundEmailHandler{
    
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.inboundEmail 		email, 
        Messaging.InboundEnvelope 	env
    ){
        
        List<String>	exclussionEmailList = new List<String>{
            'gcc-leads@cleartax.in',
                'me-sales@cleartax.in'
                };
                    /**	Debug Block : START	**/
                    system.debug('env.fromAddress: '	+env.fromAddress);
        system.debug('env.toAddress: '					+env.toAddress);
        system.debug('email.binaryAttachments: '		+email.binaryAttachments);
        system.debug('email.ccAddresses: '				+email.ccAddresses);
        system.debug('email.fromAddress: '				+email.fromAddress);
        system.debug('email.fromName: '					+email.fromName);
        system.debug('email.headers: '					+email.headers);
        system.debug('email.htmlBody: '					+email.htmlBody);
        system.debug('email.htmlBodyIsTruncated: '		+email.htmlBodyIsTruncated);
        system.debug('email.inReplyTo: '				+email.inReplyTo);
        system.debug('email.messageId: '				+email.messageId);
        system.debug('email.plainTextBody: '			+email.plainTextBody);
        system.debug('email.plainTextBodyIsTruncated: '	+email.plainTextBodyIsTruncated);
        system.debug('email.references: '				+email.references);
        system.debug('email.replyTo: '					+email.replyTo);
        system.debug('email.subject: '					+email.subject);
        system.debug('email.textAttachments: '			+email.textAttachments);
        system.debug('email.toAddresses: '				+email.toAddresses);
        /**	Debug Block : END	**/
        
        String							leadEmail;
        Boolean							restrictLeadCreation = FALSE;
        if(exclussionEmailList.contains(email.fromAddress)){
            leadEmail	=	email.replyTo != NULL  ? email.replyTo : email.fromAddress;
        } else{
            leadEmail	= 	email.fromAddress;
        }
        
        if(email.subject.contains(System.Label.ExclusionSubject )){
            restrictLeadCreation = TRUE;
        }
        
        Messaging.InboundEmailResult 	result 				= new Messaging.InboundEmailResult();
        Lead 							gccLead				= new Lead();
        Lead[] 							existingLeads 		= [ SELECT Id, Name, Email, Company, Domain_Name__c, 
                                                               Activity_Type__c, LeadSource, Status, 
                                                               Incoming_Count__c, Date_Of_Incoming_Lead__c, 
                                                               Communicated_to_Lead__c, OwnerId, Owner.Name, Owner.Email
                                                               FROM Lead WHERE 
                                                               Email = :leadEmail AND 
                                                               Country_of_Origin__c != 'India' AND 
                                                               Country_of_Origin__c != NULL
                                                               ORDER BY CreatedDate DESC ];
        
        if(existingLeads.size() > 0){
            system.debug('existingLeads is there');
            gccLead.Id 							=	existingLeads[0].Id;
            gccLead.Incoming_Count__c			=	email.references == NULL ? existingLeads[0].Incoming_Count__c+1 : existingLeads[0].Incoming_Count__c;
            gccLead.Date_Of_Incoming_Lead__c	= 	System.today();
            gccLead.Communicated_to_Lead__c		=	FALSE;
        } else{
            system.debug('New Lead getting created');
            gccLead.ownerId 					= 	System.Label.CTX_GCC_Email_Leads_Default_Owner;
            gccLead.Email 						=	leadEmail;
            gccLead.Country_of_Origin__c		= 	'GCC';
            gccLead.Date_Of_Incoming_Lead__c	=	System.Today();
            gccLead.Activity_Type__c			=	email.plainTextBody;
            gccLead.LeadSource					=	'Marketing';
            gccLead.Status						=	'New';
            gccLead.Incoming_Count__c			=	1;
            gccLead.Communicated_to_Lead__c		=	FALSE;
            gccLead.Company						= 	leadEmail.split('@')[1];
            gccLead.Domain_Name__c				= 	leadEmail.split('@')[1];
            gccLead.LastName 					= 	email.fromName != NULL ? email.fromName : leadEmail.split('@')[0];
        }
        
        /**	Filter Based on Email-to-Lead ToAddress : START	**/
        if( email.fromAddress.containsIgnoreCase('gcc-leads@cleartax.in') ){
            gccLead.Lead_Sub_Source__c			=	'Inbound Chat';
            gccLead.Campaign_Name__c			=	'Website Chat';
            gccLead.UTM_Source__c				=	'';
            gccLead.UTM_Medium__c				=	'';
            
            
            if(email.htmlBody.containsIgnoreCase('Name: ')){
                List<String> splitResult = email.htmlBody.split('Name: ');
                for(String thisRes : splitResult)
                    system.debug('splitResult Me: '+thisRes);
            }
            
        } else if( email.fromAddress.containsIgnoreCase('me-sales@cleartax.in') ){
            gccLead.Lead_Sub_Source__c			=	'Inbound Mail';
            gccLead.Campaign_Name__c			=	'ME-Sales Email';
            gccLead.UTM_Source__c				=	'ME_reply';
            gccLead.UTM_Medium__c				=	'email';            
            gccLead.Email 						=	email.replyTo != NULL  ? email.replyTo : leadEmail;
            
            gccLead.LastName 					= 	gccLead.Email.split('@')[0];
        } else if( String.join(email.toAddresses,'; ').containsIgnoreCase('abdelrahman.khamis@cleartaxmailer.com') ||
				   String.join(email.toAddresses,'; ').containsIgnoreCase('reda.omar@cleartaxmailer.com')){
            gccLead.Lead_Sub_Source__c			=	'Email Reply';
            gccLead.Campaign_Name__c			=	'';
            gccLead.UTM_Source__c				=	'drip_email';
            gccLead.UTM_Medium__c				=	'';
        }
        /**	Filter Based on Email-to-Lead ToAddress : END	**/
        
        try{
            if(gccLead.Id != NULL){
                if(email.references == NULL) {
                 	System.enqueueJob(new CTX_HandleGCCExistingLeadsQueueable(new List<Lead>{gccLead}));   
                } else {
                    update gccLead;
                }
            }else if(!restrictLeadCreation){
                insert gccLead;
            }
            
            if(gccLead.Id != NULL){
                
                Task myTask 		= new Task();
                myTask.ActivityDate	= System.today();
                myTask.Subject		= email.subject;
                myTask.Type			= 'Email-to-Lead';
                myTask.WhoId 		= gccLead.Id;
                myTask.Description 	= email.plainTextBody;
                
                try{
                    insert myTask;
                } catch(Exception ex){
                    system.debug('Error Adding Task on GSS Lead Email Flow: '+ex.getMessage());
                }
            }
        } catch(Exception error){
            system.debug('Error Creating Lead on GSS Lead Email Flow: '+error.getMessage());
        }
        
        result.success = true;
        return result;
    }
}