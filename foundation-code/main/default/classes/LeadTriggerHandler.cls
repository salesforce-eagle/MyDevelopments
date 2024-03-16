/**
* @File Name          : LeadTriggerHandler.cls 
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 02-27-2024
* @Modification Log   : 
* Ver       Date            Author              Modification
* 1.0    27/5/2020   Lokesh@SFDeveloper.SFDoc     Initial Version CTX_Lead_InternationalRecordTypeChange
**/
public without Sharing class LeadTriggerHandler implements TriggerInterface{
    
    public static void beforeInsert( 
        List<SObject> newRecordsList 
    ){
        
        List<Lead> 			nonInternationalLeads 				= new List<Lead>();
        List<Lead> 			internationalLeads 					= new List<Lead>();
        List<Lead> 			allIncomingLeads 					= new List<Lead>();
        
        List<Lead>			listofNewLeads						= new List<Lead>();
        List<Lead> 			listLeadsAfterFilter				= new List<Lead>();
        List<Lead> 			listOfLeadsWithTurnOver				= new List<Lead>();
        List<Lead> 			listOfLeadsToCheckDuplicate			= new List<Lead>();
        List<Lead> 			listOfLeadsToApplyEligibilityCheck	= new List<Lead>();
        list<Sobject> 		listOfSobjects 						= new list<Sobject>();
        Map<String, Lead> 	panToLeadInstance 					= new Map<String, Lead>();
        Set<String>			domainSet							= new Set<String>();
        Map<String,Lead>	leadEmailToLeadMap					= new Map<String,Lead>();
        
        for(Lead leadInstance : (List<Lead>)newRecordsList){
            /** Added By Niraj GCC- Handle Existing Leads with same email -START**/
            if( 
                leadInstance.Email != NULL && 
                ( leadInstance.Country_of_Origin__c != NULL &&
                leadInstance.Country_of_Origin__c != 'India' )
            ){
                leadEmailToLeadMap.put(leadInstance.Email, leadInstance);
                leadInstance.Incoming_Count__c = 1;
            }
            /** Added By Niraj GCC- Handle Existing Leads with same email -End**/
            
            allIncomingLeads.add(leadInstance);
            
            if( leadInstance.Domain_Name__c == NULL || String.isBlank(leadInstance.Domain_Name__c) ){
                leadInstance.Domain_Name__c = leadInstance.Email?.split('@')[1];
                if(leadInstance.Domain_Name__c == 'gmail.com' 
                   ||leadInstance.Domain_Name__c == 'hotmail.com' 
                   ||leadInstance.Domain_Name__c == 'outlook.com'
                   ||leadInstance.Domain_Name__c == 'yahoo.com' 
                   ||leadInstance.Domain_Name__c == 'icloud.com'
                   ||leadInstance.Domain_Name__c == 'rediff.com'){
                       leadInstance.Domain_Name__c = 'N/A';
                   }
            }
            
            if(
                ( leadInstance.Country_of_Origin__c != NULL &&
                leadInstance.Country_of_Origin__c != 'India' )
            ){
                if(leadInstance.Domain_Name__c != NULL)
                    domainSet.add(leadInstance.Domain_Name__c);
                
                leadInstance.CurrencyIsoCode 			= 'SAR';
                leadInstance.Date_Of_Incoming_Lead__c	= System.Today();
                leadInstance.Incoming_Count__c 			= 1;
                leadInstance.Communicated_to_Lead__c 	= FALSE;
                
                internationalLeads.add(leadInstance);
            }	/**	International END	**/
            System.debug('#internationalLeads'+internationalLeads);
            if( leadInstance.CurrencyIsoCode != 'INR' &&    (leadInstance.Country_of_Origin__c == NULL ||
                leadInstance.Country_of_Origin__c == 'India')){
                    leadInstance.addError('Please select currency as INR!');
            }
            
            /**	International START	**/
            if(
                leadInstance.Country_of_Origin__c != NULL &&
                leadInstance.Country_of_Origin__c != 'India'
            ){
                
                nonInternationalLeads.add(leadInstance);
                
                
                if(
                    leadInstance.Industry 			!= NULL 							&& 
                    leadInstance.Turnover__c 		!= NULL 							&& 
                    leadInstance.GSTIN__c 			!= NULL 							&& 
                    leadInstance.Type_of_Lead__c 	!= LeadConstants.TYPE_OF_LEAD_MQL
                ){
                    listofNewLeads.add(leadInstance);
                }
                
                if(
                    leadInstance.Turnover__c	!= NULL 							&& 
                    leadInstance.recordTypeId 	== LeadConstants.SME_RECORDTYPE_ID 	&& 
                    (
                        leadInstance.Turnover__c == '25-50Cr' 						||
                        leadInstance.Turnover__c == '51-100 Cr' 					||
                        leadInstance.Turnover__c == '101-200 Cr' 					||
                        leadInstance.Turnover__c == '201-500 Cr' 					||
                        leadInstance.Turnover__c == '501-1000 Cr' 					||
                        leadInstance.Turnover__c == '1001-2500 Cr' 					|| 
                        leadInstance.Turnover__c == '2501-5000 Cr' 					|| 
                        leadInstance.Turnover__c == '5001+ Cr'
                    ) 
                ){
                    leadInstance.RecordTypeId = LeadConstants.ENTERPRISE_RECORDTYPE_ID;
                }
                
                if(
                    leadInstance.Turnover__c 	!= NULL 									&& 
                    leadInstance.recordTypeId 	== LeadConstants.ENTERPRISE_RECORDTYPE_ID 	&& 
                    (
                        leadInstance.Turnover__c == '<25Cr' 								||
                        leadInstance.Turnover__c == '< 50 Lakhs' 							||
                        leadInstance.Turnover__c == '50 Lakhs - 1Cr' 						||
                        leadInstance.Turnover__c == '1 - 5 Cr' 								||
                        leadInstance.Turnover__c == '5 - 10 Cr' 							||
                        leadInstance.Turnover__c == '10 - 20 Cr' 							|| 
                        leadInstance.Turnover__c == '20 - 25 Cr'
                    ) 
                ){
                    leadInstance.RecordTypeId = LeadConstants.SME_RECORDTYPE_ID;
                }
                
                
                if(
                    leadInstance.Type_of_Lead__c 		== LeadConstants.TYPE_OF_LEAD_MQL	&& 
                    leadInstance.Products_Interested__c != NULL
                ){
                    leadInstance.MQL_Date__c = system.today();
                }
                
                if( 
                    leadInstance.PAN__c 		!= NULL	&& 
                    leadInstance.IsConverted 	!= TRUE 
                ){
                    listOfLeadsToCheckDuplicate.add(leadInstance);  
                }	/**	Channel Partner and Channel sucess need to move to ConstantsUtility Class	**/
                
                if(
                    leadInstance.Turnover__c 	!= NULL 	|| 
                    leadInstance.Pan__c 		!= NULL 	|| 
                    leadInstance.RecordTypeId 	!= NULL 
                ){
                    listOfLeadsToApplyEligibilityCheck.add(leadInstance);
                }
                
                if( !String.isBlank(leadInstance.PAN__c) ){
                    panToLeadInstance.put(leadInstance.PAN__c, leadInstance);
                }
                
                
            }
            
            /** Added By Niraj GCC- Landing Page Lead Default Owner -START**/
            if( leadInstance.Country_of_Origin__c != NULL &&
            leadInstance.Country_of_Origin__c != 'India' && 
               leadInstance.Lead_Sub_Source__c == 'Landing Page'
              )
            {
                leadInstance.OwnerId = System.Label.GCC_Landing_Page_Leads_Default_Owner;
            }
            /** Added By Niraj GCC- Landing Page Lead Default Owner -START**/
            
        }
        
        /** Added By Niraj GCC- Handle Existing Leads with same email -End**/
        if(!leadEmailToLeadMap.keySet().isEmpty()){
            CTX_HandleGCCExistingLeads.handleLeadsAlreadyExists(leadEmailToLeadMap);
        }
        /** Added By Niraj GCC- Handle Existing Leads with same email -End**/
        
        /**	Applicable for Both International & Non-International RecordType : START	**/
        
        LeadTriggerHelper.checkEmailInContacts(allIncomingLeads, NULL);
        
        /**	Applicable for Both International & Non-International RecordType : END	**/
        
        
        /**	Non-International RecordType Block : START	**/
        
        CTX_HubspotChanges.ownershipChanges(nonInternationalLeads, NULL);
        LeadTriggerHelper.getEnterpriseTurnOver(nonInternationalLeads, NULL);
        LeadTriggerHelper.updateLeadParams(nonInternationalLeads);
        
        if(
            !panToLeadInstance.keySet().isEmpty()
        ){
            //CTX_LeadFieldsPopulateFromAccount.updateNoOfGSTINSalesInvoice(panToLeadInstance);
        }
        
        if( listofNewLeads.size() > 0 ){
            LeadTriggerHelper.calculateLeadScore(listofNewLeads);
        }
        
        if( listOfLeadsToCheckDuplicate.size() > 0 ){
            
            listLeadsAfterFilter = LeadTriggerhelper.duplicateDuplicateCheckOnLeads(listOfLeadsToCheckDuplicate);
            
        }
        /**	No Task is performed Here
if( listOfLeadsToApplyEligibilityCheck.size() > 0 ){
LeadTriggerHelper.updateOwnerBasedOnEligibilityFromMatrix(listOfLeadsToApplyEligibilityCheck);

}
**/
        
        /**	Non-International RecordType Block : END	**/
        
        
        /**	International RecordType Block : START	**/
        
        CTX_Lead_InternationalRecordTypeChange.getLeadDomainMapping(internationalLeads ,domainSet);
        /**	International RecordType Block : END	**/
        
        
        
    }
    
    public static void afterInsert( 
        List<SObject> 	newRecordsList, 
        Map<Id,SObject> newRecordsMap
    ){
        
        List<Lead>	listOfLeadForMQLCreation 	= new List<Lead>();
        List<Lead>	listOfLeads					= new List<Lead>();
        
        CTX_ApexRecordSharing.apexShare_Lead_AccountSalesOwnerAccess( (Map<Id,Lead>) newRecordsMap );
        
        for( Lead leadInstance: (List<Lead>)newRecordsList ){
            
            if( 
                leadInstance.Type_of_Lead__c == LeadConstants.TYPE_OF_LEAD_MQL 
            ){
                listOfLeadForMQLCreation.add(leadInstance);
            }
            
            if(
                leadInstance.OwnerId != NULL && 
                String.valueOf(leadInstance.OwnerId).startsWithIgnoreCase('005')
            ){
                listOfLeads.add(leadInstance);
            }
            
        }
        
        if( !listOfLeadForMQLCreation.isEmpty() ){
            LeadTriggerHelper.createMQLRecords(listOfLeadForMQLCreation);
        }
        
        if( listOfLeads.size() > 0 ){
            LeadTriggerHelper.createOwnerAsLeadTeamMember(listOfLeads);
        }


        Set<Id> casmeLeadIds = new Set<Id>();
        List<String> leadAssignmentRecordType = 
            system.label.Lead_Assignment_Applicable != NULL ? system.label.Lead_Assignment_Applicable.split(',') : NULL;
        
        for(Lead thisRec : (List<Lead>)newRecordsList){
            
            system.debug('thisRec.RecordTypeId: '+thisRec.RecordTypeId);
            system.debug('leadAssignmentRecordType: '+leadAssignmentRecordType);
            
            /**	if( leadAssignmentRecordType != NULL && leadAssignmentRecordType.contains(thisRec.RecordTypeId) ){	**/
            if( 
                thisRec.RecordTypeId == '012C50000004ImMIAU' || 
                thisRec.RecordTypeId == '0122x000000t7bBAAQ' || 
                thisRec.RecordTypeId == '012C50000004InUIAU' ){
                
                system.debug('Inside RecordType Block');
                casmeLeadIds.add(thisRec.Id);
            }
            /**/
        }
        
        if( casmeLeadIds.size() > 0 ){
            /** Call a future method to run post transaction	**/
            //LeadTriggerHelper.allowLeadAssignmentPostTransaction( casmeLeadIds );
        }
    }
    
    public static void beforeUpdate( 
        Map<Id,SObject>	newRecordsMap,
        Map<Id,SObject>	oldRecordsMap
    ){
        
        CTX_HubspotChanges.ownershipChanges((List<Lead>)newRecordsMap.values(), (Map<Id, Lead>) oldRecordsMap);
        LeadTriggerHelper.getEnterpriseTurnOver((List<Lead>)newRecordsMap.values(), (Map<Id, Lead>)oldRecordsMap);
        LeadTriggerHelper.checkEmailInContacts((List<Lead>)newRecordsMap.values(), (Map<Id, Lead>)oldRecordsMap);
        
        List<Lead>	listofNewLeadsToUpdate						= new List<Lead>();
        List<Lead> 	listOfNewLeadForAllocations					= new List<Lead>();
        List<Lead> 	listOfNewLeadsWithTurnOver					= new List<Lead>();
        List<Lead> 	listOfLeadsToCheckDuplicate					= new List<Lead>();
        List<Lead> 	listOfLeadForEventvalidation				= new List<Lead>();
        List<Lead> 	listOfLeadsToApplyEligibilityCheck			= new List<Lead>();
        List<Lead> 	listOfLeadsToApplyElCheckAndAssignfromQueue	= new List<Lead>();
        List<Lead> 	listOfConvertedLeads						= new List<Lead>();
        List<Lead> 	listOfLeadsToCreateNewLeadTeam				= new List<Lead>();
        /**	MQL Lead Scoring	**/
        Map<String,String>	mapOfFieldNameToItsValue 			= new Map<String,String>();
        Map<String,String> 	mapOfFieldNameToItsOldValue 		= new Map<String,String>();
        Map<String,String> 	mapOfCombinationFields 				= new Map<String,String>();
        Map<String,String> 	mapOfCombinationFieldsToItsOldVal 	= new Map<String,String>();
        /**	MQL Lead Scoring : END	**/
        /**	Niraj SAL-442	**/
        Map<String, Lead> 	panToLeadInstance 					= new Map<String, Lead>();
        Map<String, Lead> 	panToErrorLeadInstance 				= new Map<String, Lead>();
        /**	Niraj SAL-442 : END	**/
        Set<String>			domainSet							= new Set<String>();
        List<Lead> 			internationalLeads 					= new List<Lead>();
        
        for(Id key:newRecordsMap.KeySet()){
            
            Lead leadNewInstance	= (Lead)newRecordsMap.get(key);
            Lead leadOldInstance	= (Lead)oldRecordsMap.get(key);
            
            if( leadNewInstance.Domain_Name__c == NULL || String.isBlank(leadNewInstance.Domain_Name__c) ){
                if(
                    leadNewInstance.Email?.split('@')[1] != 'gmail.com' 	||
                    leadNewInstance.Email?.split('@')[1] != 'hotmail.com' 	||
                    leadNewInstance.Email?.split('@')[1] != 'outlook.com' 	||
                    leadNewInstance.Email?.split('@')[1] != 'yahoo.com'  	||
                    leadNewInstance.Email?.split('@')[1] != 'icloud.com'	||
                    leadNewInstance.Email?.split('@')[1] != 'rediff.com'	
                ){
                    leadNewInstance.Domain_Name__c = leadNewInstance.Email?.split('@')[1];   
                }
            }
            
            if(leadNewInstance.Country_of_Origin__c != NULL &&
            leadNewInstance.Country_of_Origin__c != 'India'){
                internationalLeads.add(leadNewInstance);
                domainSet.add(leadNewInstance.Domain_Name__c);
            }
            
            if(
                leadNewInstance.Type_of_Lead__c !=  LeadConstants.TYPE_OF_LEAD_MQL && 
                (
                    leadNewInstance.Industry != NULL && 
                    leadNewInstance.Industry != leadOldInstance.Industry
                ) || 
                ( 
                    leadNewInstance.Turnover__c	!= NULL && 
                    leadNewInstance.Turnover__c != leadOldInstance.Turnover__c
                ) || 
                ( 
                    leadNewInstance.GSTIN__c != NULL && 
                    leadNewInstance.GSTIN__c != leadOldInstance.GSTIN__c 
                )
            ){
                listofNewLeadsToUpdate.add(leadNewInstance);
            }
            
            if( leadNewInstance.CurrencyIsoCode == 'INR' &&    (leadNewInstance.Country_of_Origin__c != NULL &&
                leadNewInstance.Country_of_Origin__c != 'India')){
                leadNewInstance.addError('Please select other currency!');
            } else if(
               (leadNewInstance.Country_of_Origin__c == NULL ||
                leadNewInstance.Country_of_Origin__c == 'India') && 
                leadNewInstance.CurrencyIsoCode != 'INR'
            ){
                leadNewInstance.addError('Please select currency as INR!');
            }
            /** Added By Niraj Start **/
            if(
                leadNewInstance.Country_of_Origin__c != NULL &&
                leadNewInstance.Country_of_Origin__c != 'India' && 
                leadNewInstance.recordTypeId != leadOldInstance.recordTypeId
            ){
                leadNewInstance.CurrencyIsoCode = 'USD';
            }
            /** Added By Niraj End **/
            
            //filter the Data for Duplication Check on Insert
            if( leadNewInstance.PAN__c != NULL ){
                if( 
                    !leadNewInstance.PAN__c.equals(leadOldInstance.PAN__c )  && 
                    leadNewInstance.IsConverted != TRUE 
                ){ /**	Channel Partner and Channel sucess need to move to ConstantsUtility Class	**/
                    listOfLeadsToCheckDuplicate.add(leadNewInstance);  
                }
            }            
            
            if(
                leadNewInstance.Turnover__c != NULL && 
                leadNewInstance.Turnover__c != leadOldInstance.Turnover__c
            ){
                listOfNewLeadsWithTurnOver.add(leadNewInstance);
            }
            
            if(
                leadNewInstance.Country_of_Origin__c != NULL &&
                leadNewInstance.Country_of_Origin__c != 'India' && 
                leadNewInstance.Sub_Stages__c != NULL && 
                leadNewInstance.Sub_Stages__c != leadOldInstance.Sub_Stages__c &&
                (
                    (
                        leadNewInstance.Sub_Stages__c=='Demo Scheduled' || 
                        leadNewInstance.Sub_Stages__c=='Demo Completed'
                    ) && 
                    leadNewInstance.IsConverted != TRUE
                )
            ){
                listOfLeadForEventvalidation.add(leadNewInstance);
            }
            
            
            if(
                leadNewInstance.Turnover__c != NULL &&
                leadNewInstance.Turnover__c != leadOldInstance.Turnover__c 
            ){
                listOfLeadsToApplyEligibilityCheck.add(leadNewInstance);
            }
            
            if(
                leadNewInstance.Lead_Locking_Status__c != NULL &&
                leadNewInstance.Lead_Locking_Status__c != leadOldInstance.Lead_Locking_Status__c && 
                leadNewInstance.Lead_Locking_Status__c == LeadConstants.Lead_Locking_Status_UNLOCKED
            ){
                listOfLeadsToApplyElCheckAndAssignfromQueue.add(leadNewInstance);
            }
            
            if(
                (
                    leadNewInstance.IsConverted != leadOldInstance.IsConverted && 
                    leadNewInstance.IsConverted == LeadConstants.LEAD_CONVERTED
                ) && 
                leadNewInstance.ConvertedOpportunityId != NULL 
            ){
                listOfConvertedLeads.add(leadNewInstance);
            }
            
            if(
                (
                    leadNewInstance.OwnerId != leadOldInstance.OwnerId && 
                    String.valueOf(leadNewInstance.OwnerId).startsWith('005')
                )
            ){
                listOfLeadsToCreateNewLeadTeam.add(leadNewInstance);
            }
            
            //End by Raksha for MQL Lead Scoring
            
            //Added by Raksha
            if(
                leadNewInstance.Profiling_Turnover__c != NULL && 
                leadNewInstance.Profiling_Turnover__c != '0-50 Cr' && 
                (
                    leadOldInstance.Category__c == 'Junk' || 
                    leadOldInstance.Category__c == '' || 
                    leadOldInstance.Category__c == NULL
                ) && 
                leadNewInstance.Category__c != 'Viable'
            ){
                leadNewInstance.Category__c = 'Viable';
            }
            
            if((leadNewInstance.Category__c != 'Reinforcement (MQL)' || leadNewInstance.Category__c != 'Reinforcement') && (leadNewInstance.Profiling_Turnover__c == null || leadOldInstance.Category__c == '' || leadNewInstance.Profiling_Turnover__c == '0-50 Cr') && leadNewInstance.Category__c != 'Junk'){ //&& leadNewInstance.Profiling_Turnover__c != leadOldInstance.Profiling_Turnover__c
                leadNewInstance.Category__c = 'Junk';
            }
            if(leadOldInstance.Type_of_Lead__c != leadNewInstance.Type_of_Lead__c && 
               leadOldInstance.Type_of_Lead__c != LeadConstants.TYPE_OF_LEAD_MQL && 
               leadNewInstance.Type_of_Lead__c == LeadConstants.TYPE_OF_LEAD_MQL && 
               leadNewInstance.Products_Interested__c != null && leadNewInstance.MQL_Date__c == null){
                   leadNewInstance.MQL_Date__c = System.today();
               }
            //End by Raksha
            
            //bhaveshjindal : SME <<->> Enterprise based on turnover
            if(leadNewInstance.Turnover__c != leadOldInstance.Turnover__c){
                if(leadNewInstance.Turnover__c != null && leadNewInstance.recordTypeId == LeadConstants.SME_RECORDTYPE_ID && 
                   (leadNewInstance.Turnover__c == '25-50Cr' ||
                    leadNewInstance.Turnover__c == '51-100 Cr' ||
                    leadNewInstance.Turnover__c == '101-200 Cr' ||
                    leadNewInstance.Turnover__c == '201-500 Cr' ||
                    leadNewInstance.Turnover__c == '501-1000 Cr' ||
                    leadNewInstance.Turnover__c == '1001-2500 Cr' || 
                    leadNewInstance.Turnover__c == '2501-5000 Cr' || 
                    leadNewInstance.Turnover__c == '5001+ Cr') ){
                        leadNewInstance.RecordTypeId = LeadConstants.ENTERPRISE_RECORDTYPE_ID;
                    }
                
                if(leadNewInstance.Turnover__c != null && leadNewInstance.recordTypeId == LeadConstants.ENTERPRISE_RECORDTYPE_ID && 
                   (leadNewInstance.Turnover__c == '<25Cr' ||
                    leadNewInstance.Turnover__c == '< 50 Lakhs' ||
                    leadNewInstance.Turnover__c == '50 Lakhs - 1Cr' ||
                    leadNewInstance.Turnover__c == '1 - 5 Cr' ||
                    leadNewInstance.Turnover__c == '5 - 10 Cr' ||
                    leadNewInstance.Turnover__c == '10 - 20 Cr' || 
                    leadNewInstance.Turnover__c == '20 - 25 Cr') ){
                        leadNewInstance.RecordTypeId = LeadConstants.SME_RECORDTYPE_ID;
                    }
                
            }
            /* Added By Niraj SAL-442 : Start */
            if(!AccountConstants.updateLeadFields && leadOldInstance.Account__c != null && 
               (
                   leadNewInstance.Number_Of_GSTN__c != leadOldInstance.Number_Of_GSTN__c ||
                   leadNewInstance.Number_of_PAN__c != leadOldInstance.Number_of_PAN__c ||
                   leadNewInstance.Number_of_Sales_Invoices__c != leadOldInstance.Number_of_Sales_Invoices__c
               )
              )
            {
                //panToErrorLeadInstance.put(leadOldInstance.PAN__c, leadNewInstance);   
                leadNewInstance.addError('Number of GSTN, Number of PAN and Number of Sales Invoice can only be edited from Associated Account Level.');      
            }
            
            
            if(!AccountConstants.updateLeadFields && leadOldInstance.Account__c != null && 
               leadNewInstance.Invoice_Discounting_Annual_Revenue__c != leadOldInstance.Invoice_Discounting_Annual_Revenue__c
              )
            { 
                leadNewInstance.addError('Invoice Discounting Annual Revenue can only be edited from Associated Account Level.');      
            }            
            
            if(leadNewInstance.PAN__c != leadOldInstance.PAN__c && !String.isBlank(leadNewInstance.PAN__c)){
                panToLeadInstance.put(leadNewInstance.PAN__c, leadNewInstance);
            }
            /* Added By Niraj SAL-442 : End */
            /* Added by Ashwin : Update Communicated_to_Lead__c */
            if(leadNewInstance.Incoming_Count__c  != leadOldInstance.Incoming_Count__c  && 
               leadNewInstance.Incoming_Count__c   >  0)
            {
                leadNewInstance.Communicated_to_Lead__c = False;
            }
            
        }
        
        CTX_Lead_InternationalRecordTypeChange.getLeadDomainMapping(internationalLeads ,domainSet);
        /* Added By Niraj SAL-442 : Start */
        if(!panToLeadInstance.keySet().isEmpty()){
            CTX_LeadFieldsPopulateFromAccount.updateNoOfGSTINSalesInvoice(panToLeadInstance);
        }
        /*if(!panToErrorLeadInstance.keySet().isEmpty()){
CTX_LeadFieldsPopulateFromAccount.validateNoOfGSTINSalesInvoice(panToErrorLeadInstance);
}*/
        /* Added By Niraj SAL-442 : End */
        if(listofNewLeadsToUpdate.size()>0){
            LeadTriggerHelper.calculateLeadScore(listofNewLeadsToUpdate);
        }        
        
        if(listOfLeadsToCheckDuplicate.size()>0){
            LeadTriggerhelper.duplicateDuplicateCheckOnLeads(listOfLeadsToCheckDuplicate);
        }
        
        //renu start
        if(listOfLeadForEventvalidation.size()>0){
            LeadTriggerHelper.leadSubStageValidation(listOfLeadForEventvalidation);
        }
        //renu end
        
        /*Map<id,Lead> mapOfLeadsToUpdate = (Map<Id,Lead>)newRecordsMap;
for(Lead tempLead : mapOfLeadsToUpdate.values() ){
//if(tempLead.Status == 'Demo Completed' ) 

}*/
        //Enhanced as a Part of P3CTX SSD1.1 02-Nov-2020 start
        if(listOfLeadsToApplyEligibilityCheck.size()>0){
            LeadTriggerHelper.updateOwnerBasedOnEligibilityFromMatrix(listOfLeadsToApplyEligibilityCheck); //locking 
        }
        //Enhanced as a Part of P3CTX SSD1.1 02-Nov-2020 end
        //Enhanced as a Part of P3CTX SSD1.1 10-Nov-2020 start
        if(listOfLeadsToApplyElCheckAndAssignfromQueue.size()>0){
            LeadTriggerHelper.updateOwnerBasedOnEligibilityFromMatrixfromQueueField(listOfLeadsToApplyElCheckAndAssignfromQueue); //locking
        }
        //Enhanced as a Part of P3CTX SSD1.1 10-Nov-2020 end
        
        if(listOfConvertedLeads.size()>0){
            LeadTriggerHelper.updateOpportunityIdToLeadTeamsOnConvertOpportunityId(listOfConvertedLeads);
        }
        
        if(listOfLeadsToCreateNewLeadTeam.size()>0){
            LeadTriggerHelper.createOwnerAsLeadTeamMember(listOfLeadsToCreateNewLeadTeam); //Lead Locking 
        }
        //LeadTriggerHelper.getGenericOwner((List<Lead>)newRecordsMap.Values(), 'Opportunity_Owner__c');
    }
    
    public static void afterUpdate(Map<Id,SObject> newRecordsMap,Map<Id,SObject> oldRecordsMap){
        CTX_ApexRecordSharing.apexShare_Lead_AccountSalesOwnerAccess( (Map<Id,Lead>) newRecordsMap );
    }
    
    public static void beforeDelete(List<SObject> oldRecordsList,Map<Id,SObject> oldRecordsMap){}
    
    public static void afterDelete(Map<Id,SObject> oldRecordsMap){}
    
    public static void afterUnDelete(List<SObject> newRecordsList,Map<Id,SObject> newRecordsMap){}
    
}