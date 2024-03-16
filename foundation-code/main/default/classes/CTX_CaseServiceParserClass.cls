/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 01-31-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_CaseServiceParserClass {
    
    public static CTX_CaseServiceParserClass.ReturnWrapper caseDetailsParser( String jsonBody ){
        
        system.debug('jsonBody: '+jsonBody);
        Case										upsertCase		= new Case();
        CTX_CaseServiceParserClass.ReturnWrapper 	returnWrapper 	= new CTX_CaseServiceParserClass.ReturnWrapper();
        Map<String, Object> 						caseDetails 	= (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
        Map<String, String>							productMap		= new Map<String, String>{
            'PLATFORM' => 'GST 2.0', 
                'GST' => 'GST 2.0',
                'E_INVOICING' => 'E-Invoicing & E-Way Bill', 
                'TDS' => 'TDS',
                'CLEAR_INVOICE' => 'Clear Invoicing', 
                'CLEAR_IDENTITY' => 'Clear Identity', 
                'MaxItc' => 'MAX ITC', 
                'NOTICE_MANAGEMENT' => 'Notice Management', 
                'InvoiceCapture' => 'Capture', 
                'AP_INDIA' => 'Clear Supply Chain', 
                
                'CLEARTAX' => 'GST 2.0', 
                'CLEARONE' => 'GST 2.0', 
                'TAX_ENGINE' => 'GST 2.0', 
                'CLEAR_PRO' => 'GST 2.0', 
                'PARTNER_MANAGEMENT' => 'GST 2.0'
                };
                    String							productEmail;
        String										accountId;
        String										assetId;
        String										licenseId;
        
        /**	Details Coming from Product > Salesforce : START	**/
        if( caseDetails.containsKey('subject') )
            upsertCase.put( 'Subject', (String)caseDetails.get('subject') );
        if( caseDetails.containsKey('description') )
            upsertCase.put( 'Description', (String)caseDetails.get('description') );
        if( caseDetails.containsKey('phoneNumber') )
            upsertCase.put( 'SuppliedPhone', (String)caseDetails.get('phoneNumber') );
        if( caseDetails.containsKey('customerEmail') )
            upsertCase.put( 'SuppliedEmail', (String)caseDetails.get('customerEmail') );
        if( caseDetails.containsKey('productName') ){
            
            if( productMap.containsKey( (String)caseDetails.get('productName') ) ){
                upsertCase.put( 'Products_Available__c', productMap?.get( (String)caseDetails.get('productName') ) );
            } else{
                upsertCase.put( 'Products_Available__c', (String)caseDetails.get('productName') );
            }
        }
        
        if( caseDetails.containsKey('productPageUrl') )
            upsertCase.put( 'Product_Page_URL__c', (String)caseDetails.get('productPageUrl') );
        if( caseDetails.containsKey('documentNo') )
            upsertCase.put( 'Document_Number__c', (String)caseDetails.get('documentNo') );
        if( caseDetails.containsKey('environment') )
            upsertCase.put( 'Environment__c', (String)caseDetails.get('environment') );
        
        if( caseDetails.containsKey('attachments') ){
            
            String finalURL;
            String urls 	= caseDetails.get('attachments') != NULL ? (String)caseDetails.get('attachments') : NULL;
            
            for( String thisSTR : urls.split(',') ){
                if( finalURL != NULL ){
                    finalURL = finalURL + thisSTR + '\n';
                } else{
                    finalURL = 'Attached URLs: \n' + thisSTR + '\n';
                }
            }
            upsertCase.put( 'Pre_Signed_Attachment_URL__c', finalURL );
        }
        if( caseDetails.containsKey('productMetadata') )
            upsertCase.put( 'Product_Metadata__c', caseDetails.get('productMetadata') != NULL ? JSON.serialize( caseDetails.get('productMetadata') ) : NULL );
        if( caseDetails.containsKey('workspaceId') )
            upsertCase.put( 'Workspace_Id__c', (String)caseDetails.get('workspaceId') );
        if( caseDetails.containsKey('id') )
            upsertCase.put( 'Product_Unique_Identifier__c', (String)caseDetails.get('id') );
        
        
        /**	Get Product Email Details for Account Mapping : START	**/
        if( caseDetails.containsKey('productEmail') )
            productEmail = (String)caseDetails.get('productEmail');
        if( caseDetails.containsKey('salesForceAccountId') )
            accountId = (String)caseDetails.get('salesForceAccountId');
        if( caseDetails.containsKey('salesForceAssetId') )
            assetId = (String)caseDetails.get('salesForceAssetId');
        if( caseDetails.containsKey('licenseId') )
            licenseId = (String)caseDetails.get('licenseId');
        
        
        system.debug('Supplied Email: '+upsertCase.SuppliedEmail);
        try{
            /**	case Creation Block : START	**/
            CaseConstants.isFirstTimeCase 		= FALSE;
            upsert upsertCase;
            CaseConstants.isFirstTimeCase 		= TRUE;
            
            Case newCase = [ SELECT Id, CaseNumber FROM Case where Id =: upsertCase.id ];
            
            returnWrapper.isSuccess 			= TRUE;
            returnWrapper.successErrorMessage 	= 'Case Created Successfully.';
            returnWrapper.sfCaseNumber 			= newCase.CaseNumber;
            returnWrapper.sfCaseId 				= newCase.Id;
            /**	case Creation Block : END	**/
            
            updateCaseServiceResumeCaseProcesses(
                upsertCase.Id,
                upsertCase.Product_Unique_Identifier__c,
                upsertCase.Products_Available__c,
                upsertCase.SuppliedEmail,
                productEmail,
                accountId,
                assetId,
                licenseId,
                upsertCase.Workspace_Id__c,
                upsertCase.Pre_Signed_Attachment_URL__c
            );
            
        } catch( Exception ex){
            returnWrapper.isSuccess 			= FALSE;
            returnWrapper.successErrorMessage 	= 'Case Created Failed with error: '+ex.getMessage();
        }
        
        
        return returnWrapper;
    }
    
    Public Class CaseDetailsReturn{
        Public Case 	upsertCase = new Case();
        Public String	productEmail;
    }
    
    Public Class ReturnWrapper{
        Public String 	sfCaseNumber;
        Public String 	sfCaseId;
        Public Boolean	isSuccess;
        Public String	successErrorMessage;
    }
    
    @future
    public static void updateCaseServiceResumeCaseProcesses( 
        String caseId,
        String caseProductId,
        String productName, 
        String customerEmail,
        String productEmail,
        String accountId,
        String assetId,
        String licenseId,
        String workspaceId, 
        String preSignedURL 
    ){
        
        Case currentCase = [ SELECT Id, CaseNumber, RecordTypeId, AccountId, ContactId, 
                            SuppliedEmail, SuppliedPhone, ContactEmail,Account_CSM_Email__c 
                            FROM Case WHERE 
                            Id = :caseId LIMIT 1 ];
        
        currentCase = CTX_CaseServiceParserClass.caseUpdateProductDetails(productName, caseId, currentCase);
        
        currentCase = CTX_CaseServiceParserClass.updateAccountAndContactonCase( productEmail, customerEmail, currentCase, accountId );
        
        system.debug('currentCase: currentCase: '+currentCase);
      //  currentCase = CTX_CaseServiceParserClass.autoRespondManualCases(currentCase, caseId);
        
        if( accountId != NULL && accountId != '' ){
            currentCase.AccountId = accountId;
        }
        
        update currentCase;
    }
    
    public static Case caseUpdateProductDetails( String productName, String caseId, Case currentCase ){
        system.debug('Inside caseUpdateProductDetails: '+caseId);
        
        Map<String, Case_Mapping_For_Product_Ticketing__mdt> 	productMappingMetadata 	= new Map<String, Case_Mapping_For_Product_Ticketing__mdt>();
        
        for( 
            Case_Mapping_For_Product_Ticketing__mdt thisRec : [ SELECT 
                                                               Id, DeveloperName, Case_RecordTypeId__c, Team_Responsible__c,
                                                               Priority__c, Case_Origin__c, Entitlement_Id__c, 
                                                               Product_Name__c, Case_Owner_Queue_Id__c, Type__c 
                                                               FROM Case_Mapping_For_Product_Ticketing__mdt WHERE
                                                               Product_Name__c = :productName ] 
        ){
            productMappingMetadata.put(thisRec.Product_Name__c, thisRec);
        }
        
        if( productMappingMetadata.keySet().size() > 0 ){
            
            currentCase.RecordTypeId       	= productMappingMetadata.get(productName).Case_RecordTypeId__c;
            currentCase.User_Role_Type__c  	= productMappingMetadata.get(productName).Team_Responsible__c;
            currentCase.Priority 			= productMappingMetadata.get(productName).Priority__c;
            currentCase.Origin				= productMappingMetadata.get(productName).Case_Origin__c;
            currentCase.EntitlementId		= productMappingMetadata.get(productName).Entitlement_Id__c;
            currentCase.OwnerId				= productMappingMetadata.get(productName).Case_Owner_Queue_Id__c;
            currentCase.Type				= productMappingMetadata.get(productName).Type__c;
        }
        
        return currentCase;
    }
    
    public static Case updateAccountAndContactonCase( String productEmail, String suppliedEmail, Case currentCase, String accountId ){
        
        Map<String, Id>	mapOfEmailAndContactId 	= new Map<String, Id>();
        List<Contact> 	contactList;
        List<String>	productEmails;
        String accountCsmMail; //added by murali
        
        if( productEmail != NULL ){
            productEmails = productEmail.split(',');
        }
        
        system.debug('accountId: '+accountId);
        system.debug('currentCase: '+currentCase);
        system.debug('suppliedEmail: '+suppliedEmail);
        system.debug('productEmail: '+productEmail);
        system.debug('productEmails: '+productEmails);
        
        if( accountId != NULL && accountId != '' ){
            
            system.debug('Inside Account Id Block: '+accountId);
            contactList = [ SELECT Id, Email, AccountId 
                           FROM Contact WHERE 
                           Email = :suppliedEmail AND 
                           AccountId = :accountId 
                           Order BY Account.Sum_of_ARR_Assets__c DESC LIMIT 1 ];
        } else if( productEmail != NULL && productEmails != NULL && productEmails.size() > 0 ){
            
            system.debug('Inside Product Email Block: '+productEmails);
            for( 
                Account thisAcc : [ SELECT Id ,Onboarding_Owner__r.Email // added by murali
                                   FROM Account WHERE 
                                   Product_Email__c IN :productEmails 
                                   ORDER BY Sum_of_ARR_Assets__c LIMIT 1 ] 
            ){
                accountId        = thisAcc.Id;
                accountCsmMail   = thisAcc.Onboarding_Owner__r.Email; // added by murali
                
          system.debug('accountId final 0: '+accountId);
        system.debug('accountCsmMail final 0: '+accountCsmMail);
            }
            
            contactList = [ SELECT Id, Email, AccountId 
                           FROM Contact WHERE 
                           Email = :suppliedEmail AND 
                           Account.Product_Email__c IN :productEmails
                           ORDER BY Account.Sum_of_ARR_Assets__c DESC LIMIT 1 ];
        } else{
            contactList = [ SELECT Id, Email, AccountId,Account.Onboarding_Owner__r.Email 
                           FROM Contact WHERE 
                           Email = :suppliedEmail 
                           Order BY Account.Sum_of_ARR_Assets__c DESC LIMIT 1 ];
            if( contactList != NULL && contactList.size() > 0 ){
                
                accountId      = ( accountId != NULL && accountId != '' ) ? accountId : contactList[0].AccountId;
                accountCsmMail =  ( accountId != NULL && accountId != '' ) ? accountCsmMail :contactList[0].Account.Onboarding_Owner__r.Email; // added by murali
            
          system.debug('accountId final 1: '+accountId);
        system.debug('accountCsmMail final 1: '+accountCsmMail);
            }
        }
        system.debug('contactList: '+contactList);
        system.debug('accountId: '+accountId);
        
        if( contactList != NULL && contactList.size() > 0 ){
            for( Contact thisRec : contactList ){
                currentCase.ContactId = thisRec.Id;
                currentCase.AccountId = accountId != NULL && accountId != '' ? accountId : thisRec.AccountId;
            }
        } else{
            
            system.debug('Inside Else');
            String 			emailDomainName 		= suppliedEmail.split('@')[1];
            List<Account> 	accountBasedOnDomain 	= [ SELECT Id, Name,Onboarding_Owner__r.Email,  
                                                       Company_Domain_Name__c, Domain__c, Domain_Name_Proper__c 
                                                       FROM Account WHERE 
                                                       ( Company_Domain_Name__c = :emailDomainName OR
                                                        Domain__c = :emailDomainName OR 
                                                        Domain_Name_Proper__c = :emailDomainName ) AND 
                                                       ( NOT Name LIKE '%Test%' )
                                                       ORDER BY Sum_of_ARR_Assets__c DESC 
                                                       LIMIT 1 ];
            accountId 								= ( accountId != NULL && accountId != '' ) ? accountId : accountBasedOnDomain != NULL ? accountBasedOnDomain[0].Id : system.label.Global_Account_Product_UI;
            accountCsmMail   						= ( accountId != NULL && accountId != '' ) ? accountCsmMail : accountBasedOnDomain != NULL ? accountBasedOnDomain[0].Onboarding_Owner__r.Email : ''; // added by murali
            
          	system.debug('accountId final 2: '+accountId);
        	system.debug('accountCsmMail final 2: '+accountCsmMail);
            Contact 		createContact 			= new Contact(
                Email 					= suppliedEmail,
                LastName 				= suppliedEmail.split('@')[0],
                AccountId 				= accountId,
                Phone 					= '9988776655',
                Designation__c 			= 'Admin',
                Designation_Oppor__c 	= 'IT',
                Is_Communicable__c 		= TRUE,
                LeadSource 				= 'NAL'
            );
            
            CaseConstants.isFirstTimeCase = FALSE;
            insert createContact;
            CaseConstants.isFirstTimeCase = TRUE;
            
            currentCase.ContactId = createContact.Id;
            currentCase.AccountId = accountId;
        }
          system.debug('accountId final : '+accountId);
        system.debug('accountCsmMail final : '+accountCsmMail);
        CTX_CaseServiceParserClass.autoRespondManualCases(currentCase, currentCase.Id,accountCsmMail);
        currentCase.put('Auto_Response_Sent__c',TRUE);
        system.debug('currentCase : '+currentCase);
        return currentCase;
    }
    
    public static void autoRespondManualCases(Case currentCase, Id caseId, String accountCsmMail){
        
        system.debug('caseId: '+caseId);
        system.debug('accountCsmMail: '+accountCsmMail);
        system.debug('currentCase.RecordTypeId: '+currentCase.RecordTypeId);
        system.debug('currentCase: '+currentCase);
        List<Messaging.SingleEmailMessage> 						listOfMessagingSingleEmailMessage 		= new List<Messaging.SingleEmailMessage>();
        List<Org_wide_and_Email_Template_Mapping__mdt> 			listOfOrgwideandEmailTemplateMappings	= DataBase.query(UtilityClass.getQueryString('Org_wide_and_Email_Template_Mapping__mdt')+' FROM Org_wide_and_Email_Template_Mapping__mdt ');
        Map<String,Org_wide_and_Email_Template_Mapping__mdt>	mapOfOrgwideandEmailTemplateMappings	= new  Map<String,Org_wide_and_Email_Template_Mapping__mdt>();
        Map<String,Org_wide_and_Email_Template_Mapping__mdt> 	recordTypeToOTMMap 						= new  Map<String,Org_wide_and_Email_Template_Mapping__mdt>();
        Set<Id> 												setofOrgWiderIds 						= new Set<Id>();
        Set<Id> 												setofEmailTemplateIds 					= new Set<Id>();
        List<Case> 												caseListToUpdate 						= new List<Case>();
        
        for(Org_wide_and_Email_Template_Mapping__mdt otm : listOfOrgwideandEmailTemplateMappings){
            if(!String.isEmpty(otm.RecordType__c)){
                for(String str : otm.RecordType__c.trim().split(',')){
                    recordTypeToOTMMap.put(str.trim(), otm);
                }
            }
        }
        
        setofOrgWiderIds.add(recordTypeToOTMMap.get(currentCase?.RecordTypeId)?.Org_Wide_Email_Id__c);
        setofEmailTemplateIds.add(recordTypeToOTMMap.get(currentCase?.RecordTypeId)?.Email_Template_Id__c);
        
        Map<Id,OrgWideEmailAddress> mapOforgWideEmailAddressInstance  = new Map<Id,OrgWideEmailAddress>([ SELECT Id, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, Address, DisplayName, IsAllowAllProfiles FROM OrgWideEmailAddress WHERE Id IN:setofOrgWiderIds ]);
        Map<Id,emailTemplate>  mapOfemailTemplateInstanc = new Map<Id,emailTemplate>([ SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE Id IN: setofEmailTemplateIds ]);
        
        system.debug('mapOforgWideEmailAddressInstance: '+mapOforgWideEmailAddressInstance);
        system.debug('mapOfemailTemplateInstanc: '+mapOfemailTemplateInstanc);
        
        currentCase.put('Auto_Response_Sent__c',TRUE);
        if( recordTypeToOTMMap.containsKey(currentCase.RecordTypeId) ){
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(mapOfemailTemplateInstanc.get(recordTypeToOTMMap.get(currentCase.RecordTypeId).Email_Template_Id__c).Id);
            email.setOrgWideEmailAddressId(mapOforgWideEmailAddressInstance.get(recordTypeToOTMMap.get(currentCase.RecordTypeId).Org_Wide_Email_Id__c).Id);
            
            List<String> exclusionList = System.Label.Email_Exclusion_CaseAck.split(';');
            
            System.debug('#emailList'+new List<String>{currentCase.SuppliedEmail});
            if(!exclusionList.contains(currentCase.SuppliedEmail)){
                email.setToAddresses(new List<String>{currentCase.SuppliedEmail});     
            }
            email.setSaveAsActivity(true);
            email.setTargetObjectId(currentCase.ContactId);
            System.debug('currentCase.Account_CSM_Email__c'+currentCase.Account_CSM_Email__c);
            if(accountCsmMail != NULL && accountCsmMail != ''){
                system.debug('inside if');
               // email.setCcAddresses( new List<String>{ accountCsmMail} );
                email.setBCCAddresses( new List<String>{ accountCsmMail});
            } else{
                system.debug('inside else');
                email.setCcAddresses( new List<String>{} );
                email.setBCCAddresses( new List<String>{});
            }
            email.setWhatId(currentCase.Id);
            
            
            listOfMessagingSingleEmailMessage.add(email);
        }
        
        if(!listOfMessagingSingleEmailMessage.isEmpty()){
            Messaging.SendEmailResult[] msgResult = Messaging.sendEmail( listOfMessagingSingleEmailMessage, FALSE );
            System.debug('****msgResult'+msgResult);
        }
        
        //return currentCase;
    }
    
    
}