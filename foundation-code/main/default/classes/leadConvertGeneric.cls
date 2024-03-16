/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-27-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without Sharing class leadConvertGeneric {
    
    @AuraEnabled 
    Public Static Lead getLead(string recordId){
        
        return [ SELECT 
                
                Id, Email, Type_of_Lead__c, PAN__c, Status, Sub_Stages__c, POC1_Name__c, POC1_Email__c, 
                POC1_Phone__c, POC2_Name__c, POC2_Email__c, POC2_Phone__c, RecordTypeId, MQL_or_Not__c,
                Profiling_Status__c, OwnerId, Products_Interested__c, LeadSource, Lead_Sub_Source__c, 
                Lead_Score__c,ERP__c, Calling_Status__c, Calling_Comments__c,Remarks__c, Referral_CA_name__c, 
                Referral_email_ID__c, Referral_phone_no__c, MQL_Date__c, Latest_TouchPoint_Date__c, 
                Number_Of_GSTN__c, Number_of_PAN__c, Renewal_Date__c, Competition_Currently_Using__c, 
                Number_of_Sales_Invoices__c, isConvertingNow__c, Scope__c, RecordType.Name, Country_of_Origin__c
                
                FROM Lead WHERE 
                
                Id =: recordId ];
    }
    
    Public Class LeadConvertResultWrapper{
        @AuraEnabled Public Id 			accountId;
        @AuraEnabled Public Boolean 	isLeadConverted;
        @AuraEnabled Public String 		errorMessage;
    }
    
    @AuraEnabled
    Public Static LeadConvertResultWrapper convertLead(lead leadObject){
        system.debug('leadConvertGeneric leadObject: '+leadObject);
        
        Boolean						isLeadUpdate;
        LeadConvertResultWrapper	resultWrapper			= new LeadConvertResultWrapper();
        Lead						leadInstance 			= leadObject;
        Database.LeadConvert		convertedLead 			= new Database.LeadConvert();
        Boolean 					deleteContact 			= FALSE;
        Boolean 					UpdateAccountRecordType = FALSE;
        Boolean						isNotOpportunityrequired= FALSE;
        Boolean						isConvertSuccess		= TRUE;
        List<Contact> 				listofContact 			= new List<Contact>();
        String 						parentAccountId;
        String 						parentContactId;
        List<Opportunity> 			listOfOpportunity 		= new List<Opportunity>();
        Database.LeadConvertResult	leadConvertResult;
        List<Account> 				filteredAccounts;
        String						recordTypeName;
        LeadStatus 					convertStatus 			= [ SELECT Id, MasterLabel 
                                                               FROM LeadStatus WHERE 
                                                               IsConverted = TRUE LIMIT 1 ];
        
        Id							leadOwersId				= [ SELECT Id FROM User WHERE 
                                                               isActive = TRUE AND
                                                               Username ='team-salesforce@cleartax.in' LIMIT 1]?.Id;
        //Id 							recordTypeId_NetNew		= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Net New - ID').getRecordTypeId();
        List<Id> 					internationalRecordType	= new List<Id>();
        List<Lead_POC__c> 			listOfLeadPOC			
            = [ SELECT id, Name__c, Lead__c,Phone_Number__c, Designation__c, Products_Interested__c,
               Lead_Source__c, ownerId, Lead_Sub_Source__c, Mark_Primary_Contact_after_Conversion__c, 
               Date_Of_Incoming_Lead__c, Attended_Webinar__c, Domain_Name__c, Is_Communicable__c, department__c, 
               Send_communication_to_this_Contact__c, Intent_Stage__c,Requested_For_Demo__c,Tag_Category__c, 
               Mobile_Number__c, Email_ID__c, Email_ID_Personal__c, seniority__c, Webinar_Attendance__c, 
               Webinar_Attendance_in_min__c, No_of_Times_POC_has_Came__c
               FROM Lead_POC__c WHERE 
               Lead__c =: leadInstance.Id ];
        
        for(
            RecordType thisRec : [ SELECT Id FROM RecordType WHERE 
                                  SobjectType = 'Lead' AND 
                                  Name IN ('International', 'Tax Expert', 'CA/SME', 'Cimplyfive') ] //Cimplyfive Added By Niraj
        ){
            internationalRecordType.add(thisRec.Id);
        }
        
        system.debug('leadInstance: '+leadInstance);
        system.debug('leadInstance.Country_of_Origin__c: '+leadInstance.Country_of_Origin__c);
        system.debug('leadInstance.PAN__c: '+leadInstance.PAN__c);
        
        Boolean isInternationalLead = FALSE;
        if( leadInstance.Country_of_Origin__c != NULL ){
            isInternationalLead = leadInstance.Country_of_Origin__c != 'India' ? TRUE : FALSE;
        }
        
        system.debug('isInternationalLead: '+isInternationalLead);
        if(leadInstance != NULL){
            try{
                leadInstance.isConvertingNow__c = TRUE;
                isLeadUpdate 					= TRUE;
            } catch(Exception ex){
                system.debug('leadConvertGeneric: '+ex.getMessage());
                isLeadUpdate = FALSE;
            }
            
        }
        
        if(isLeadUpdate){
            
            /**	Validations, Error Handling Details	**/
            CTX_LeadConverterHelper.ResultWrapper validateOpportunityResult;
            
            If( String.isNotBlank(leadInstance.PAN__c) || String.isNotEmpty(leadInstance.PAN__c) ){
                
                parentAccountId = [ SELECT Id FROM Account WHERE 
                                   PAN__c =: leadInstance.PAN__c 
                                   ORDER BY LastModifiedDate DESC 
                                   LIMIT 1 ]?.Id;
                
                if(parentAccountId != NULL){
                    convertedLead.setAccountId(parentAccountId);                
                } else{
                    UpdateAccountRecordType = TRUE;
                }
            }
            
            system.debug('parentAccountId: '+parentAccountId);
            
            if( parentAccountId != NULL && leadInstance.Email != NULL ){
                
                parentContactId = [ SELECT Id FROM Contact WHERE 
                                   AccountId	=: parentAccountId AND 
                                   Email 	=: leadInstance.Email 
                                   ORDER BY LastModifiedDate DESC LIMIT 1 ]?.Id;
                
                if(parentContactId != NULL){
                    
                    system.debug('Parent Contact Id: '+parentContactId);
                    convertedLead.setContactId(parentContactId);
                }
            }
           
            List<Opportunity> checkOpportunities = [ SELECT Id, RecordType.Name FROM Opportunity WHERE AccountId =: parentAccountId AND 
                                                    RecordType.Name IN ('Cross Sell/Upsell', 'Net New') AND
                                                    ( NOT StageName IN ('Closed Won', 'Closed Lost', 'Closed - Merged') ) ];
            
            system.debug('checkOpportunities list size: '+checkOpportunities.size());
            
            if(checkOpportunities.size() > 0)
                isNotOpportunityrequired = TRUE;
            else
                isNotOpportunityrequired = FALSE;
            
            if(isNotOpportunityrequired){
                for(Opportunity thisRec : checkOpportunities){
                    // Removal of Net New ID Record Type
                    if(leadInstance.Scope__c?.containsIgnoreCase('ID')){
                        if(thisRec.ClearTax_Billing_Entity__c == 'Xpedize'){  
                            
                            isNotOpportunityrequired = TRUE;
                            Break;
                        } else{
                            isNotOpportunityrequired = FALSE;
                        }
                    }
                }
            }
            
            /**	Billing Entity Check	**/
            //	Cimplifive
            if(
                leadInstance.Scope__c != NULL &&
                (
                leadInstance.Scope__c?.containsIgnoreCase('BLISS') 			||
                leadInstance.Scope__c?.containsIgnoreCase('CIMPLYBEST') 		||
                leadInstance.Scope__c?.containsIgnoreCase('DIGITIZATION') 	||
                leadInstance.Scope__c?.containsIgnoreCase('RETAINERSHIP') 	||
                leadInstance.Scope__c?.containsIgnoreCase('CUSTOMIZATION') 	||
                leadInstance.Scope__c?.containsIgnoreCase('ON-PREM')
                )
            ){
                recordTypeName 					= 'Cimplifive';
                leadInstance.Billing_Entity__c 	= 'CimplyFive';
            }
            
            if(leadInstance.Type_of_Lead__c == LeadConstants.TYPE_OF_LEAD_MQL)
                isNotOpportunityrequired = TRUE;
            
            if(!isNotOpportunityrequired){
                
                if(leadInstance.Country_of_Origin__c != 'India' && leadInstance.Country_of_Origin__c != ''){
                    validateOpportunityResult 		= CTX_LeadConverterHelper.validateRequiredDetailsBeforeLeadConversuin(
                        leadInstance, internationalRecordType, recordTypeName
                    );
                }
                
                system.debug('validateOpportunityResult: '+validateOpportunityResult);
                resultWrapper.isLeadConverted 	= validateOpportunityResult?.isSuccess;
                resultWrapper.errorMessage		= validateOpportunityResult?.errorMessage;
            } else{
                
            }
            
            /**	Convert Lead	**/
            convertedLead.setLeadId(leadInstance.Id);
            convertedLead.setConvertedStatus(convertStatus.MasterLabel);
            convertedLead.setDoNotCreateOpportunity(isNotOpportunityrequired);
            
            if(test.isRunningTest())
                convertedLead.setOwnerId(leadOwersId);
            
            if(validateOpportunityResult != NULL){
                
                if( validateOpportunityResult.isSuccess){
                    
                    try{
                        leadConvertResult = Database.convertLead(convertedLead);
                    } catch(Exception ex){
                        
                        resultWrapper.isLeadConverted 	= FALSE;
                        
                        if( ex.getMessage().contains('If the lead is not owned by a user') ){
                            resultWrapper.errorMessage	= 'Please change the Lead Owner from Queue to a User.';
                        } else{
                            resultWrapper.errorMessage	= ex.getMessage();
                        }
                    }
                }      
            } else{
                
                try{
                    leadConvertResult = Database.convertLead(convertedLead);
                } catch(Exception ex){
                    
                    resultWrapper.isLeadConverted 	= FALSE;
                    
                    if( ex.getMessage().contains('If the lead is not owned by a user') ){
                        resultWrapper.errorMessage	= 'Please change the Lead Owner from Queue to a User.';
                    } else{
                        resultWrapper.errorMessage	= ex.getMessage();
                    }
                }
            }	/**	Bibhu: Lead Conversions completes here	**/
            
            system.debug('leadConvertResult: '+leadConvertResult);
            if( leadConvertResult != NULL ){
                
                if(leadConvertResult.isSuccess()){
                    
                    resultWrapper.isLeadConverted 	= TRUE;
                    resultWrapper.accountId 		= leadConvertResult.getAccountId();
                    CTX_LeadConverterHelper.createrelatedActivities(leadConvertResult);
                    
                    update new Lead(
                        Id 					= leadInstance.Id,
                        isConvertingNow__c 	= FALSE
                    );
                    If(leadConvertResult.getOpportunityId() != null){
                        
                        Opportunity convertedOpp = new Opportunity(
                            Id = leadConvertResult.getOpportunityId()
                        );
                        
                        /**	Scope Check	**/
                        if(leadInstance.Scope__c != NULL){
                            convertedOpp.Bus_POC__c 	    = leadConvertResult.getContactId();
                            /**	ID Product	**/
                            if(
                                leadInstance.Scope__c.containsIgnoreCase('ID') 			|| 
                                leadInstance.Scope__c.containsIgnoreCase('KYC-APIs')
                            ){
                                convertedOpp.RecordTypeId	= opportunityConstants.RECORDTYPEID_NET_NEW; /** Changed By Niraj : Removal of Net New ID Record Type **/
                            }else if(
                                leadInstance.Scope__c.containsIgnoreCase('BLISS') 			||
                                leadInstance.Scope__c.containsIgnoreCase('CIMPLYBEST') 		||
                                leadInstance.Scope__c.containsIgnoreCase('DIGITIZATION') 	||
                                leadInstance.Scope__c.containsIgnoreCase('RETAINERSHIP') 	||
                                leadInstance.Scope__c.containsIgnoreCase('CUSTOMIZATION') 	||
                                leadInstance.Scope__c.containsIgnoreCase('ON-PREM')
                            ){
                                //convertedOpp.RecordTypeId	= LeadConstants.CIMPLYFIVE_RECORDTYPE_ID;
                                convertedOpp.RecordTypeId	= OpportunityConstants.RECORDTYPEID_NET_NEW; /** Changed By Niraj : Removal of Net New Cimplyfive Record Type **/
                                
                            }
                        }
                        
                       	OpportunityConstants.RECORDTYPE_CHANGE_VALIDATION_ENABLE = FALSE; //Added By Niraj To Escape Record Type Change Validation During Lead Conversion
                        update convertedOpp;
                    }
                    if(UpdateAccountRecordType){
                        
                        if(Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId() == leadInstance.RecordTypeId){
                            
                            update new Account(
                                Id 				= leadConvertResult.getAccountId(),
                                Sales_Owner__c 	= leadInstance.OwnerId,
                                recordTypeId 	= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId()
                            );
                        } else if(Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Community').getRecordTypeId() == leadInstance.RecordTypeId){
                            
                            update new Account(
                                Id 				= leadConvertResult.getAccountId(), 
                                Sales_Owner__c 	= leadInstance.OwnerId,
                                recordTypeId 	= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Success').getRecordTypeId()
                            );
                        } else if(
                            leadInstance.Scope__c?.containsIgnoreCase('BLISS') 			||
                            leadInstance.Scope__c?.containsIgnoreCase('CIMPLYBEST') 		||
                            leadInstance.Scope__c?.containsIgnoreCase('DIGITIZATION') 	||
                            leadInstance.Scope__c?.containsIgnoreCase('RETAINERSHIP') 	||
                            leadInstance.Scope__c?.containsIgnoreCase('CUSTOMIZATION') 	||
                            leadInstance.Scope__c?.containsIgnoreCase('ON-PREM')
                        ){
                            update new Account(
                                Id 				= leadConvertResult.getAccountId(), 
                                Sales_Owner__c 	= leadInstance.OwnerId,
                                recordTypeId 	= AccountConstants.Enterprise_RecordTypeId
                            );
                        } else{
                            update new Account(
                                Id 				= leadConvertResult.getAccountId(), 
                                Sales_Owner__c 	= leadInstance.OwnerId
                            );
                        }
                    }
                    
                    try{
                        /**	Previous Code Deleted	**/
                    } catch(Exception e){}
                }
            }
            
        }
        system.debug('LeadConvertResultWrapper: '+resultWrapper);
        return resultWrapper;
    }
    
    /**	Added by Raksha	**/
    public static void createMQL(Opportunity oppty, List<MQL__c> listOfMQL, List<Contact> leadPocContacts, Lead leadRecord,String convertedContactID){
        
        List<MQL__c> listOfMQLsToUpsert = new List<MQL__c>();
        System.debug('*MQL createMQL ');
        System.debug('*MQL oppty '+oppty);
        System.debug('*MQL listOfMQL '+listOfMQL);
        System.debug('*MQL leadPocContacts size '+leadPocContacts);
        System.debug('*MQL leadPocContacts '+leadPocContacts);
        System.debug('*MQL leadRecord '+leadRecord);
        System.debug('*MQL leadRecord.convertedContactID');
        System.debug('*MQL convertedContactID '+convertedContactID);
        Map<String,String> mapOfEmailToContactId = new Map<String,String>();
        mapOfEmailToContactId.put(leadRecord.email, convertedContactID);
        for(Contact con : leadPocContacts){
            mapOfEmailToContactId.put(con.Email, con.Id);
        }
        System.debug('*MQL mapOfEmailToContactId '+mapOfEmailToContactId);
        System.debug('*MQL mapOfEmailToContactId size '+mapOfEmailToContactId.size());
        for(MQL__c mql : listOfMQL){
            System.debug('*MQL mql '+mql);
            if(mql.Lead__c != null && mapOfEmailToContactId.containsKey(mql.Lead__r.email)){
                System.debug('*MQL ^^^^');
                MQL__c tempMQL = new MQL__c();
                tempMQL.id = mql.Id;
                tempMQL.Opportunity__c = oppty.Id;
                tempMQL.Contact__c =  mapOfEmailToContactId.get(mql.Lead__r.email);
                tempMQL.Category__c = 'Reinforcement';
                tempMQL.Lead__c = null;
                listOfMQLsToUpsert.add(tempMQL);
            }else if(mql.Lead_POC__c != null && mapOfEmailToContactId.containsKey(mql.Lead_POC__r.Email_ID__c)){
                System.debug('*MQL %%%%%');
                MQL__c tempMQL = new MQL__c();
                tempMQL.id = mql.Id;
                tempMQL.Opportunity__c = oppty.Id;
                tempMQL.Contact__c =  mapOfEmailToContactId.get(mql.Lead_POC__r.Email_ID__c);
                tempMQL.Category__c = 'Reinforcement';
                tempMQL.Lead_POC__c = null;
                listOfMQLsToUpsert.add(tempMQL);
            }
        }
        System.debug('*MQL listOfMQL '+listOfMQL);
        Database.update(listOfMQLsToUpsert, false);
    }
    
    
    public static String getDomain(String email){
        
        return email.subString(email.indexof('@')+1, email.length());
    }
    
    public class leadConvertGenericException extends Exception {}
    
}