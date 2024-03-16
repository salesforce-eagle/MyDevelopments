/**
* @File Name          : LeadTriggerHelper.cls 
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 02-16-2024
* @Modification Log   : 
* Ver       Date            Author              Modification
* 1.0    27/5/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public without Sharing  class LeadTriggerHelper {
    
    /**
* @description
* @author Lokesh Thathuru | 05/19/2020
* @param List<Lead> listOfLeads 
* @return List<Lead>
*/
    public static void calculateLeadScore( List<Lead> listOfNewLeads){
        List<Lead> listOfLeadsToUpdate=new List<Lead>();
        listOfLeadsToUpdate=LeadService.calculateLeadScore(listOfNewLeads);
    }
    
    
    /**	Turnover and Business Type Change: Bibhu - START	**/
    
    
    public static void getEnterpriseTurnOver(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap){
        
        List<String>	turnOverList 	= new List<String>();
        Id 				accountRecordId = [ SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND Name = 'Enterprise' ]?.Id;
        
        if(System.Label.Account_Turnover != NULL)
            turnOverList.addAll(System.Label.Account_Turnover.split(','));  
        
        for(Lead thisRec : newLeads){
            
            system.debug('Lead recordType Id: '+thisRec.RecordTypeId);
            if( thisRec.RecordTypeId == accountRecordId ){
                
                system.debug('Lead Enterprise RecordType Block: '+accountRecordId);
                
                if( turnOverList.size() > 0 && turnOverList.contains(thisRec.Turnover__c) ){
                    thisRec.Business_Type__c  = 'SME';
                } else{
                    thisRec.Business_Type__c  = 'Large Enterprise';
                }
                
                if(
                    thisRec.Business_Type__c == 'Large Enterprise' && 
                    thisRec.PAN__c == NULL && 
                    thisRec.Lead_Request_Type__c == NULL && (thisRec.Country_of_Origin__c == 'India' ||  thisRec.Country_of_Origin__c == '')
                ){
                    thisRec.addError('PAN is mandatory for Enterprise grater than 25cr.');
                }
            }
        }
        
    }
    
    
    /**	Turnover and Business Type Change: Bibhu - END	**/
    
    /**
* @description This methods will check that the leads which are coming and if the PAN Name Matches to the Existing Records 
*          then Mark the New record as Duplicate and add as a child. and also updating the Lead source to the Parent from child
* @author Lokesh Thathuru | 05/22/2020
* @param List<Lead> listOfLeads
* @return List<Lead>
*/
    public static List<Lead> duplicateDuplicateCheckOnLeads(List<Lead> listOfLeads){
        List<Lead> listOfAllNONDuplicateLeads=new List<Lead>();
        
        //Map<String,Lead> mapOfNewLeads=new  Map<String,Lead>();
        Map<String,Lead> mapOfLeads=new  Map<String,Lead>();
        //Map<String,List<Lead>> mapOfNewDuplicateLeads=new  Map<String,List<Lead>>();
        //List<Lead> listOfAllLeads=new List<Lead>();
        Set<String> setOfPANNames=new Set<String>();
        
        if(listOfLeads.size()>0){
            for(Lead leadInstance:listOfLeads){
                if(leadInstance.PAN__c!=null ){
                    if(!mapOfLeads.containsKey(leadInstance.PAN__c)){
                        mapOfLeads.put(leadInstance.PAN__c,leadInstance);
                        setOfPANNames.add(leadInstance.PAN__c);
                    }
                }
            }
        }
        
        System.debug(setOfPANNames.size());
        System.debug(setOfPANNames);
        
        List<Lead> listOfDBLeads=new List<Lead>();
        List<Lead> listOfDBWithPANLeads=new List<Lead>();   
        List<Account> listOfAccounts=new List<Account>();
        
        if(setOfPANNames.size()>0){
            listOfDBLeads=new LeadSelector().getLeadsByPanNameAndRecordTypeName(setOfPANNames,LeadConstants.CENTRAL_RECORDTYPE_NAME); //  LeadConstants.CENTRAL_RECORDTYPE_NAME  constant variable where we can change the value in that class if needed.
            listOfDBWithPANLeads=new LeadSelector().getLeadsByPanName(setOfPANNames); 
            listOfAccounts=new AccountSelector().getAccountsByPAN(setOfPANNames);
        }
        
        
        
        Map<String,Lead> mapOfLeadsWithKeyAsPAN=new  Map<String,Lead>();
        Map<String,Account> mapOfAccountsWithKeyAsPAN=new  Map<String,Account>();
        Map<String,Lead> mapOfCDBLeadsWithKeyAsPAN=new  Map<String,Lead>();
        
        System.debug(listOfDBLeads.size());
        System.debug(listOfDBWithPANLeads.size());
        System.debug(listOfAccounts.size());
        
        if(listOfDBLeads.size()>0){
            for(Lead leadInstance:listOfDBLeads){
                if(!mapOfCDBLeadsWithKeyAsPAN.containsKey(leadInstance.PAN__c)){
                    mapOfCDBLeadsWithKeyAsPAN.put(leadInstance.PAN__c,leadInstance);
                }
            }
        }
        
        if(listOfDBWithPANLeads.size()>0){
            for(Lead cDBLeadInstance:listOfDBWithPANLeads){
                if(!mapOfLeadsWithKeyAsPAN.containsKey(cDBLeadInstance.PAN__c)){
                    mapOfLeadsWithKeyAsPAN.put(cDBLeadInstance.PAN__c,cDBLeadInstance);
                }
            }
        }
        
        if(listOfAccounts.size()>0){
            for(Account accountInstance:listOfAccounts){
                if(!mapOfAccountsWithKeyAsPAN.containsKey(accountInstance.PAN__c)){
                    mapOfAccountsWithKeyAsPAN.put(accountInstance.PAN__c,accountInstance);
                }
            }
        }
        
        Id recordId=[SELECT Id, Name FROM RecordType Where Name=:LeadConstants.CENTRAL_RECORDTYPE_NAME].Id; //   LeadConstants.CENTRAL_RECORDTYPE_NAME  constant variable where we can change the value in that class if needed.
        
        if(listOfLeads.size()>0){
            for(Lead leadInstance:listOfLeads){
                
                if(mapOfLeadsWithKeyAsPAN.containsKey(leadInstance.PAN__c) && !mapOfAccountsWithKeyAsPAN.containsKey(leadInstance.Pan__c)){
                    leadInstance.Status =LeadConstants.LEAD_STATUS_DUPLICATE;
                    
                    if(leadInstance.Lead__c!=mapOfLeadsWithKeyAsPAN.get(leadInstance.PAN__c).Id){
                        leadInstance.Lead__c=mapOfLeadsWithKeyAsPAN.get(leadInstance.PAN__c).Id;
                    }
                    
                    
                    if(String.valueOf(leadInstance.OwnerId).StartsWithIgnoreCase('005')){
                        leadInstance.OwnerId=mapOfLeadsWithKeyAsPAN.get(leadInstance.PAN__c).OwnerId;
                    }
                    if(!mapOfCDBLeadsWithKeyAsPAN.containsKey(leadInstance.PAN__c)){
                        //  leadInstance.addError('The Lead is already present with the PAN Number : '+mapOfLeadsWithKeyAsPAN.get(leadInstance.PAN__c).PAN__c+' please Contact the Lead Owner '+mapOfLeadsWithKeyAsPAN.get(leadInstance.PAN__c).Owner.Name+' and Email Id: '+mapOfLeadsWithKeyAsPAN.get(leadInstance.PAN__c).Owner.Email);
                    }
                }
                if(mapOfAccountsWithKeyAsPAN.containsKey(leadInstance.Pan__c) ){
                    //  leadInstance.addError('The Account is already present with the PAN Number : '+mapOfAccountsWithKeyAsPAN.get(leadInstance.PAN__c).PAN__c+' please Contact the account Owner '+mapOfAccountsWithKeyAsPAN.get(leadInstance.PAN__c).Owner.Name+' and Email Id: '+mapOfAccountsWithKeyAsPAN.get(leadInstance.PAN__c).Owner.Email);                       
                }
                
                if(mapOfLeadsWithKeyAsPAN.containsKey(leadInstance.PAN__c) && (leadInstance.RecordTypeId==LeadConstants.CHANNEL_PARTNER_RECORDTYPE_ID || leadInstance.RecordTypeId==LeadConstants.PARTNER_COMMUNITY_RECORDTYPE_ID  )){
                    leadInstance.addError(mapOfLeadsWithKeyAsPAN.get(leadInstance.PAN__c).PAN__c+' '+Label.Channel_Validation_Error_Message);      
                }
                
                if(!mapOfAccountsWithKeyAsPAN.containsKey(leadInstance.PAN__c) && !mapOfLeadsWithKeyAsPAN.containsKey(leadInstance.PAN__c)){
                    listOfAllNONDuplicateLeads.add(leadInstance);
                }
                
                
            }
        }
        
        //allocationLeadsAfterDuplicateCheck(listOfAllNONDuplicateLeads);
        return listOfAllNONDuplicateLeads;
    }
    
    //renu start
    public static void leadSubStageValidation(list<lead> listOfLeadForEventvalidation ){
        // map<id, lead> mapOfLead = new map<id, lead>();
        set<Id> setOfleadIds = new set<Id>();
        map<id, lead> mapOfLead = new map<id, lead>(listOfLeadForEventvalidation);
        system.debug('mapOfLead'+mapOfLead.KeySet());
        list<Event> listOfEvent= new list<Event>();
        map<id, list<Event>> mapOfLeadToItsListOfEvents = new map<id, list<Event>>();
        listOfEvent=[SELECT id, Stage__c,whoId FROM Event where (type='Call' OR type='Meeting' or type='Demo/POC') AND whoId IN:mapOfLead.keySet()];
        system.debug(' size of listOfEvent'+listOfEvent);
        
        for(Event eve:listOfEvent){
            if(mapOfLeadToItsListOfEvents.containsKey(eve.whoId)){
                mapOfLeadToItsListOfEvents.get(eve.whoId).add(eve);
            }else{
                mapOfLeadToItsListOfEvents.put(eve.WhoId, new List<Event>{eve}); 
            }
        }
        system.debug('size of eve'+mapOfLeadToItsListOfEvents.size());
        for(Lead leadRecord : listOfLeadForEventvalidation){
            
            /**
if(leadRecord.Sub_Stages__c == 'Demo Scheduled'){
if(!mapOfLeadToItsListOfEvents.containsKey(leadRecord.Id)){
//leadRecord.addError(Label.DemoScheduled);
}
}
else if(leadRecord.Sub_Stages__c == 'Demo Completed'){
if(mapOfLeadToItsListOfEvents.containsKey(leadRecord.Id)){
Boolean isNotComplete = false;
List<Event> listOfEvents = mapOfLeadToItsListOfEvents.get(leadRecord.id);
for(Event ev : listOfEvents){
if(ev.Stage__c != 'Completed'){
isNotComplete = true;
break;
}
}
if(isNotComplete){
Lead leadInstance = mapOfLead.get(leadRecord.Id);
//leadInstance.addError(Label.Demo_Completed_Error_on_Lead);
}
}else{
//leadRecord.addError(Label.Demo_Complete_Event_Error);
}
} **/
        } 
        
    }
    //renu end
    
    //Method Added by Raksha - To insert MQL Records for each product in Lead and also a MQL record for Delta capture
    public static void createMQLRecords(List<Lead> listOfLeads){
        List<MQL__c> listOfMQLToInsert = new List<MQL__c>();
        for(Lead ld : listOfLeads){
            MQL__c mql = new MQL__c();
            mql.Lead__c = ld.Id;
            mql.Type__c = 'Delta Capture';
            if(ld.Attended_Webinar__c != null){
                mql.Attended_Webinar__c = ld.Attended_Webinar__c;
            }
            if(ld.City__c != null){
                mql.City__c = ld.City__c;
            }
            if(ld.Company != null){
                mql.Company__c = ld.Company;
            }
            if(ld.Date_Of_Incoming_Lead__c != null){
                mql.Date_Of_Incoming_Lead__c = ld.Date_Of_Incoming_Lead__c;
            }
            if(ld.Designation__c != null){
                mql.Designation__c = ld.Designation__c;
            }
            if(ld.Domain_Name__c != null){
                mql.Domain_Name__c = ld.Domain_Name__c;
            }
            if(ld.Intent_Stage__c != null){
                mql.Intent_Stage__c = ld.Intent_Stage__c;
            }
            if(ld.Phone != null){
                mql.Phone_Number__c = ld.Phone;
            }
            if(ld.Products_Interested__c != null){
                mql.Products_Interested__c = ld.Products_Interested__c;
            }
            if(ld.Profiling_Status__c != null){
                mql.Profiling_Status__c = ld.Profiling_Status__c;
            }
            if(ld.Region__c != null){
                mql.Region__c = ld.Region__c;
            }
            if(ld.Requested_For_Demo__c != null){
                mql.Requested_For_Demo__c = ld.Requested_For_Demo__c;
            }
            if(ld.LeadSource != null){
                mql.Source__c = ld.LeadSource;
            }
            if(ld.State__c != null){
                mql.State__c = ld.State__c;
            }
            if(ld.Lead_Sub_Source__c != null){
                mql.Sub_Source__c = ld.Lead_Sub_Source__c;
            }
            if(ld.Turnover__c != null){
                mql.Turnover__c = ld.Turnover__c;
            }
            if(ld.Webinar_Attendance__c != null){
                mql.Webinar_Attendance__c = ld.Webinar_Attendance__c;
            }
            if(ld.Webinar_Attendance_in_min__c != null){
                mql.Webinar_Attendance_in_min__c = ld.Webinar_Attendance_in_min__c;
            }
            if(ld.Calling_Comments__c != null){
                mql.Calling_Comments__c = ld.Calling_Comments__c;
            }
            if(ld.Calling_Status__c != 'Not interested'){
                mql.Calling_Status__c = ld.Calling_Status__c;
            }
            if(ld.Remarks__c != null){
                mql.Remarks__c = ld.Remarks__c;
            }
            if(ld.Referral_CA_name__c != null){
                mql.Referral_CA_name__c = ld.Referral_CA_name__c;
            }
            if(ld.Referral_email_ID__c != null){
                mql.Referral_email_ID__c = ld.Referral_email_ID__c;
            }
            if(ld.Referral_phone_no__c != null){
                mql.Referral_phone_no__c = ld.Referral_phone_no__c;
            }
            listOfMQLToInsert.add(mql);
            List<String> listOfProducts=new List<String>();
            if(ld.Products_Interested__c!=null){
                listOfProducts = ld.Products_Interested__c.split(';');
            }
            Set<String> setOfProducts = new Set<String>(listOfProducts);
            for(String eachProduct : setOfProducts){
                MQL__c eachMQL = new MQL__c();
                eachMQL.Lead__c = ld.Id;
                eachMQL.Type__c = 'Product Capture';
                eachMQL.Products_Interested__c = eachProduct;
                eachMQL.Product_Reinforcement_count__c = 1;
                listOfMQLToInsert.add(eachMQL);
            }
        }
        if(!listOfMQLToInsert.isEmpty()){
            insert listOfMQLToInsert;
        }
    }
    
    
    
    
    /**
* @description this Method helps to assign the Admin Queue or Current User if the Eligible from the Matrix
* @author Lokesh Thathuru | 11/02/2020
* @param List<Lead> listOfLeadsToApplyEligibilityCheck 
* @return void
*/
    public static void  updateOwnerBasedOnEligibilityFromMatrix(List<Lead> listOfLeadsToApplyEligibilityCheck){
        //List<Lead> listOfLeadsToUpdate=new List<Lead>();
        if(listOfLeadsToApplyEligibilityCheck.size()>0){
            //LeadService.updateOwnerBasedOnEligibilityFromMatrix(listOfLeadsToApplyEligibilityCheck,UserInfo.getUserId());
        }
    }
    
    /**
* @description this Method helps to assign the Admin Queue or the user from Queue for Locking userIds
* @author Lokesh Thathuru | 11/02/2020
* @param List<Sobject> listOfLeadsToApplyElCheckAndAssignfromQueue 
* @return void
*/
    public static void  updateOwnerBasedOnEligibilityFromMatrixfromQueueField(List<Sobject> listOfLeadsToApplyElCheckAndAssignfromQueue){
        if(listOfLeadsToApplyElCheckAndAssignfromQueue.size()>0){
            UtilityClass.beforeUpdateToApplyElCheckAndAssignfromQueue(listOfLeadsToApplyElCheckAndAssignfromQueue);
        }
    }
    
    /**
* @description this below method helps to update Opportunity Id to the Lead Team on Convert
* @author Lokesh@SFDeveloper.SFDoc | 17/11/2020 
* @param Map<id,Lead_Team__c>  listOfConvertedLeads 
* @return void 
**/
    public static void updateOpportunityIdToLeadTeamsOnConvertOpportunityId(List<Lead>  listOfConvertedLeads){
        
        Set<Id> setOfLeadIds=new Set<Id>();
        List<Lead_Team__c> listOfLeadTeamsToUpdate=new List<Lead_Team__c>();
        List<Queue_For_locking_User__c> listOfQueueForlockingUsersToUpdate=new List<Queue_For_locking_User__c>();
        
        if(listOfConvertedLeads.size()>0){
            for(Lead leadInstance:listOfConvertedLeads){
                setOfLeadIds.add(leadInstance.Id);
            }
        }
        
        String queryString=UtilityClass.getQueryString('Lead_Team__c')+' FROM Lead_Team__c WHERE Lead__c IN: setOfLeadIds ';
        String queryStringQueue=UtilityClass.getQueryString('Queue_For_Locking_User__c')+' FROM Queue_For_Locking_User__c WHERE Lead__c IN: setOfLeadIds ';
        
        Map<Id,Queue_For_Locking_User__c> mapOfQueueForLockingUsers=new Map<Id,Queue_For_Locking_User__c>((List<Queue_For_Locking_User__c>)DataBase.query(queryStringQueue));
        Map<Id,Lead_Team__c> mapOfLeads=new Map<Id,Lead_Team__c>((List<Lead_Team__c>)DataBase.query(queryString));
        
        if(listOfConvertedLeads.size()>0){
            for(Lead leadInstance:listOfConvertedLeads){
                System.debug('leadInstance.ConvertedOpportunityId***'+leadInstance.ConvertedOpportunityId);
                if(leadInstance.ConvertedOpportunityId!=null){
                    for(Lead_Team__c leadTeamInstance:mapOfLeads.values()){
                        System.debug('leadInstance.ConvertedOpportunityId'+leadInstance.ConvertedOpportunityId);
                        if(leadTeamInstance.Lead__c==leadInstance.Id){
                            leadTeamInstance.Opportunity__c=leadInstance.ConvertedOpportunityId;
                            System.debug('leadTeamInstance.Opportunity__c'+leadTeamInstance.Opportunity__c);
                            listOfLeadTeamsToUpdate.add(leadTeamInstance);
                        }
                    }
                    
                    for(Queue_For_Locking_User__c queueInstance:mapOfQueueForLockingUsers.values()){
                        System.debug('leadInstance.ConvertedOpportunityId'+leadInstance.ConvertedOpportunityId);
                        if(queueInstance.Lead__c==leadInstance.Id){
                            queueInstance.Opportunity__c=leadInstance.ConvertedOpportunityId;
                            System.debug('queueInstance.Opportunity__c'+queueInstance.Opportunity__c);
                            listOfQueueForlockingUsersToUpdate.add(queueInstance);
                        }
                    }
                }
            }
        }
        
        if(listOfLeadTeamsToUpdate.size()>0){
            update listOfLeadTeamsToUpdate;
        }
        
        if(listOfQueueForlockingUsersToUpdate.size()>0){
            update listOfQueueForlockingUsersToUpdate;
        }
    }
    
    
    /**
* @description this below method helps to create the Lead_Team__c from the Lead Owner
* @author Lokesh@SFDeveloper.SFDoc | 17/11/2020 
* @param List<Lead_Team__c>  listOfLeads 
* @return void 
**/
    public static void createOwnerAsLeadTeamMember(List<Lead>  listOfLeads ){
        List<Lead_Team__c> listOfLeadTeamsToLeadTeamMembers=new List<Lead_Team__c>();
        if(listOfLeads.size()>0){
            for(Lead leadInstance:listOfLeads){
                if(String.valueOf(leadInstance.OwnerId).startsWith('005')){
                    Lead_Team__c leadteamInstance=new Lead_Team__c();
                    leadteamInstance.IsOwner__c=true;
                    leadteamInstance.Lead__c=leadInstance.Id;
                    leadteamInstance.User__c=leadInstance.OwnerId;
                    leadteamInstance.Attribution_share_percentage__c=100;
                    leadteamInstance.Approval_for_Co_Ownership__c='Approved';
                    leadteamInstance.Record_Access__c=LeadTeamConstants.RECORDACCESS_READ_WRITE;
                    listOfLeadTeamsToLeadTeamMembers.add(leadteamInstance);
                }
            }
        }
        
        if(listOfLeadTeamsToLeadTeamMembers.size()>0){
            insert listOfLeadTeamsToLeadTeamMembers;
        }
        
    }
    
    public static void checkEmailInContacts(List<Lead> newLeads, Map<Id, Lead> oldMapLeads) {
        
        Set<String> emails = new Set<String>();
        List<Lead> leadToProcess = new List<Lead>();
        for(lead ld : newLeads) {
            if((ld.Email != null) && (Trigger.isInsert || (Trigger.isUpdate && ld.Email != oldMapLeads.get(ld.Id).Email))) {
                emails.add(ld.Email);
                leadToProcess.add(ld);
            }               
        }
        
        Set<String> contactEmails = new Set<String>();
        
        for (Contact con : [SELECT Id, Email FROM Contact WHERE Email In :emails]){
            contactEmails.add(con.Email);
        }
        
        for(lead ld : leadToProcess) {
            if(contactEmails.contains(ld.Email)){
                ld.Email.addError('There is existing contact with same email, Can\'t use same email.');
            }                  
        }
    }
    
    public static void updateLeadParams(List<Lead> newLeads) {
        Set<Id> accId = new Set<Id>();
        for(Lead thisRec : newLeads){
            accId.add(thisRec.Account__c);
        }
        
        Map<Id,Account> accMap = new  Map<Id,Account>([SELECT Id, Industry, Final_Segment__c 
                                                       FROM Account where Id IN :accId]);        
        for(Lead thisRec : newLeads){
            if(accMap.containsKey(thisRec.Account__c)){
                if(accMap.get(thisRec.Account__c).Industry != NULL && accMap.get(thisRec.Account__c).Final_Segment__c != NULL){
                    thisRec.Industry = accMap.get(thisRec.Account__c).Industry;
                    thisRec.Final_Segment__c = accMap.get(thisRec.Account__c).Final_Segment__c;   
                }
                
            }
        }
        
    }

    @future
    public static void allowLeadAssignmentPostTransaction( Set<Id> leadIds ){
        
        AssignmentRule ar = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Lead' AND Active = True LIMIT 1];
        List<Lead> lUpdList = [SELECT Id FROM Lead WHERE Id IN: leadIds ];
        for (Lead l:lUpdList){
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= ar.id;
            l.setOptions(dmlOpts);
        }
        
        update(lUpdList);
    }
    
}