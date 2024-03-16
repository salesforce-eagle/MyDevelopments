/**
 * @File Name          : LeadTeamTriggerHelper.cls 
 * @Description        : 
 * @Author             : Lokesh@SFDeveloper.SFDoc
 * @Group              : 
 * @Last Modified By   : Lokesh@SFDeveloper.SFDoc
 * @Last Modified On   : 06/11/2020, 10:58:16 am
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    06/11/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public without sharing class LeadTeamTriggerHelper {
    
    
    /**
    * @description this below method opens the Share the Edit Access with the Lead Team
    * @author Lokesh@SFDeveloper.SFDoc | 06/11/2020 
    * @param Map<id,Lead_Team__c>  newLeadTeamsRecordAfterApproved 
    * @return void 
    **/
    public static void createApexSharRecordforLead(Map<id,Lead_Team__c> newLeadTeamsRecordAfterApproved){
        
        List<Sobject> listOfsObjectShares=new List<Sobject>();
        if(!newLeadTeamsRecordAfterApproved.isEmpty()){
            for(Id leadTeamId:newLeadTeamsRecordAfterApproved.keySet()){
                if(newLeadTeamsRecordAfterApproved.get(leadTeamId).Lead__c!=null){
                    if(newLeadTeamsRecordAfterApproved.get(leadTeamId).Approval_for_Co_Ownership__c=='Approved' && newLeadTeamsRecordAfterApproved.get(leadTeamId).User__c != newLeadTeamsRecordAfterApproved.get(leadTeamId).OwnerId ){
                        LeadShare leadShareInstance=new LeadShare();
                        leadShareInstance.LeadAccessLevel='Edit';
                        leadShareInstance.LeadId=newLeadTeamsRecordAfterApproved.get(leadTeamId).Lead__c;
                        leadShareInstance.RowCause='Manual';
                        leadShareInstance.UserOrGroupId=newLeadTeamsRecordAfterApproved.get(leadTeamId).User__c;
                        listOfsObjectShares.add(leadShareInstance);
                    }
                }
                /*if(newLeadTeamsRecordAfterApproved.get(leadTeamId).Opportunity__c!=null){
                    if(newLeadTeamsRecordAfterApproved.get(leadTeamId).Approval_for_Co_Ownership__c=='Approved'){
                        OpportunityShare opportunityShareInstance=new OpportunityShare();
                        opportunityShareInstance.OpportunityAccessLevel='Edit';
                        opportunityShareInstance.OpportunityId=newLeadTeamsRecordAfterApproved.get(leadTeamId).Opportunity__c;
                        opportunityShareInstance.RowCause='Manual';
                        opportunityShareInstance.UserOrGroupId=newLeadTeamsRecordAfterApproved.get(leadTeamId).User__c;
                        listOfsObjectShares.add(opportunityShareInstance);
                    }
                }*/
            }
        }
        
        
        if(listOfsObjectShares.size()>0){
            Database.insert(listOfsObjectShares, false); //insert listOfsObjectShares;
        }
    }
    
    /**
    * @description this below method helps to Increment the Count of Change of Attribution Share %
    * @author Lokesh@SFDeveloper.SFDoc | 07/11/2020 
    * @param List<Lead_Team__c> listOfLeadTeams 
    * @return void 
    **/
    public static void updateAttributionShare(List<Lead_Team__c> listOfLeadTeams){
		List<Id> listofLeadIds=new List<Id>();
        List<Id> listofOpportunitiesIds=new List<Id>();
        
        if(listOfLeadTeams.size()>0){
            for(Lead_team__c leadTeamInstance:listOfLeadTeams){
                if(leadTeamInstance.Opportunity__c!=null){
                    listofOpportunitiesIds.add(leadTeamInstance.Opportunity__c);
                }
                if(leadTeamInstance.Lead__c!=null){
                    listofLeadIds.add(leadTeamInstance.Lead__c);
                }
            }
        }
        List<Lead> listOfLeads=new List<Lead>();
        List<Opportunity> listOfOpportunites=new List<Opportunity>();
        if(listofOpportunitiesIds.size()>0){
            listOfOpportunites=DataBase.query(UtilityClass.getQueryString('Opportunity')+' FROM Opportunity WHERE Id IN: listofOpportunitiesIds');
        }
        
        if(listofLeadIds.size()>0){
            listOfLeads=DataBase.query(UtilityClass.getQueryString('Lead')+' FROM Lead WHERE Id IN: listofLeadIds');
        }
        
        
        if(listOfLeadTeams.size()>0 && listOfOpportunites.size()>0){
            for(Lead_team__c leadTeamInstance:listOfLeadTeams){
                for(Opportunity opportunityInstance:listOfOpportunites){
                    if(leadTeamInstance.Opportunity__c==opportunityInstance.Id){
                        if(opportunityInstance.No_of_times_Edited_By_Owner_Lead_Teams__c==null || opportunityInstance.No_of_times_Edited_By_Owner_Lead_Teams__c==0){
                            opportunityInstance.No_of_times_Edited_By_Owner_Lead_Teams__c=1; //No_of_times_Edited_By_Owner_Lead_Teams__c
                        }else{
                            opportunityInstance.No_of_times_Edited_By_Owner_Lead_Teams__c+=1;
                        }
                    }
                }
            }
            update listOfOpportunites;
        }
        
        if(listOfLeadTeams.size()>0 && listOfLeads.size()>0){
            for(Lead_team__c leadTeamInstance:listOfLeadTeams){
                for(Lead leadInstance:listOfLeads){
                    if(leadTeamInstance.Lead__c==leadInstance.Id){
                        if(leadInstance.No_of_times_Edited_By_Owner_Lead_Teams__c==null || leadInstance.No_of_times_Edited_By_Owner_Lead_Teams__c==0){
                            leadInstance.No_of_times_Edited_By_Owner_Lead_Teams__c=1; //No_of_times_Edited_By_Owner_Lead_Teams__c
                        }else{
                            leadInstance.No_of_times_Edited_By_Owner_Lead_Teams__c+=1;
                        }
                    }
                }
            }
            
          update  listOfLeads;
        }
        

    }
    
    
    
    /**
    * @description this below method helps to Create OpportunityTeam Member Record with Edit Access after Approved of Lead Teams
    * @author Lokesh@SFDeveloper.SFDoc | 10/11/2020 
    * @param Map<id,Lead_Team__c>  newLeadTeamsRecordAfterApproved 
    * @return void 
    **/
    public static void createOpportunityTeamMemberRecord(Map<id,Lead_Team__c>  newLeadTeamsRecordAfterApproved){
        
        List<OpportunityTeamMember> listOfOpportunityTeamMembers=new List<OpportunityTeamMember>();
        if(!newLeadTeamsRecordAfterApproved.isEmpty()){
            for(Id leadTeamId:newLeadTeamsRecordAfterApproved.keySet()){
                if(newLeadTeamsRecordAfterApproved.get(leadTeamId).Opportunity__c!=null){
                    OpportunityTeamMember opportunityTeamMemberInstance=new OpportunityTeamMember();
                    opportunityTeamMemberInstance.Approval_for_Co_Ownership__c=newLeadTeamsRecordAfterApproved.get(leadTeamId).Approval_for_Co_Ownership__c;
                    opportunityTeamMemberInstance.Attribution_share_percentage__c=newLeadTeamsRecordAfterApproved.get(leadTeamId).Attribution_share_percentage__c;
                    opportunityTeamMemberInstance.UserId=newLeadTeamsRecordAfterApproved.get(leadTeamId).User__c;
                    opportunityTeamMemberInstance.OpportunityId=newLeadTeamsRecordAfterApproved.get(leadTeamId).Opportunity__c;
                    //opportunityTeamMemberInstance
                    if(String.ISBLANK(newLeadTeamsRecordAfterApproved.get(leadTeamId)?.Record_Access__c) || newLeadTeamsRecordAfterApproved.get(leadTeamId)?.Record_Access__c?.equalsIgnoreCase(LeadTeamConstants.RECORDACCESS_READ_WRITE)){
                        opportunityTeamMemberInstance.OpportunityAccessLevel='Edit';
                    }
                    listOfOpportunityTeamMembers.add(opportunityTeamMemberInstance);
                }
            }
        }
        
        if(listOfOpportunityTeamMembers.size()>0){
            insert listOfOpportunityTeamMembers;
        }
        
    
    }
    
    
        /**
    * @description update Attribution Sharing from Lead Team 
    * @author Lokesh@SFDeveloper.SFDoc | 10/11/2020 
    * @param Map<id,Lead_Team__c>  newLeadTeamsRecordAfterApprovedAttributChange 
    * @return void 
    **/
    public static void updateAttributionSharing(Map<id,Lead_Team__c>  newLeadTeamsRecordAfterApprovedAttributChange){
        
        List<OpportunityTeamMember> listOfOpportunityTeamMembers=new List<OpportunityTeamMember>();
        Map<Id,Id> mapOfUserIdWithOppIds=new Map<Id,Id>();
        Map<Id,Lead_Team__c> mapIdWithLeadTeams=new Map<Id,Lead_Team__c>();
        
        if(!newLeadTeamsRecordAfterApprovedAttributChange.isEmpty()){
            for(Id leadTeamId:newLeadTeamsRecordAfterApprovedAttributChange.keySet()){
                if(newLeadTeamsRecordAfterApprovedAttributChange.get(leadTeamId).Opportunity__c!=null && newLeadTeamsRecordAfterApprovedAttributChange.get(leadTeamId).User__c!=null ){
                    if(!mapOfUserIdWithOppIds.containsKey(newLeadTeamsRecordAfterApprovedAttributChange.get(leadTeamId).User__c)){
                        mapOfUserIdWithOppIds.put(newLeadTeamsRecordAfterApprovedAttributChange.get(leadTeamId).User__c,newLeadTeamsRecordAfterApprovedAttributChange.get(leadTeamId).Opportunity__c);
                        mapIdWithLeadTeams.put(newLeadTeamsRecordAfterApprovedAttributChange.get(leadTeamId).User__c,newLeadTeamsRecordAfterApprovedAttributChange.get(leadTeamId));
                    }
                }
            }
        }
        
        List<OpportunityTeamMember> listofUsersFromOpportunityTeamMember=new List<OpportunityTeamMember>();
        
        if(!mapOfUserIdWithOppIds.isEmpty()){
            listofUsersFromOpportunityTeamMember=[SELECT id,Attribution_share_percentage__c,Approval_for_Co_Ownership__c,OpportunityId,UserId from OpportunityTeamMember WHERE UserId IN : mapOfUserIdWithOppIds.keySet() AND OpportunityId IN : mapOfUserIdWithOppIds.Values() ]; 
        }
        
        if(listofUsersFromOpportunityTeamMember.size()>0)
            for(OpportunityTeamMember opportunityTeamMemberInstance:listofUsersFromOpportunityTeamMember){
                if(opportunityTeamMemberInstance.OpportunityId!=null && mapIdWithLeadTeams.containsKey(opportunityTeamMemberInstance.UserId)){
                    opportunityTeamMemberInstance.Attribution_share_percentage__c =  mapIdWithLeadTeams.get(opportunityTeamMemberInstance.UserId).Attribution_share_percentage__c;
                    listOfOpportunityTeamMembers.add(opportunityTeamMemberInstance);
                }
            }
        
        if(listOfOpportunityTeamMembers.size()>0){
            update listOfOpportunityTeamMembers;
        }
    }
    
    
    
    /**
    * @description this below method helps to calculate the Lead_Team__c
    * @author Lokesh@SFDeveloper.SFDoc | 17/11/2020 
    * @param Map<id,Lead_Team__c>  listOfLeadsToUpdtaeToday365days 
    * @return void 
    **/
    public static void updateRequesterClosedDate(List<Lead_Team__c>  listOfLeadsToUpdtaeToday365days){
        
        if(listOfLeadsToUpdtaeToday365days.size()>0){
            for(Lead_Team__c leadTeam:listOfLeadsToUpdtaeToday365days){
                if(leadTeam.IsOwner__c==false){
                    leadTeam.Requester_Closed_Date__c=System.today()+Integer.valueOf(Label.RequestorClosedDate);
                }
            }
        }
    }
    
    
    
    /**
    * @description this below method helps to update the OwnerAttribution Sahre on Deletion of Requestors
    * @author Lokesh@SFDeveloper.SFDoc | 17/11/2020 
    * @param Map<id,Lead_Team__c>  mapOfLeadTeamMembers 
    * @return void 
    **/
    public static void updateOwnerShareOnDelete(Map<Id,Lead_Team__c>  mapOfLeadTeamMembers){
      /*  
        Map<Id,Lead_Team__c> mapOfleadIds=new Map<Id,Lead_Team__c>();
        
        for(Id key:mapOfLeadTeamMembers.keySet()){
            if(mapOfLeadTeamMembers.get(key).Lead__c!=null){
                if(!mapOfleadIds.containsKey(mapOfLeadTeamMembers.get(key).Lead__c)){
                    mapOfleadIds.put(mapOfLeadTeamMembers.get(key).Lead__c,mapOfLeadTeamMembers.get(key));
                }
            }
        }
        Set<Id> setOfIds=new Set<Id>();
        setOfIds.addAll(mapOfleadIds.keySet());
        List<Lead_Team__c> listOfLeadTeams=new List<Lead_Team__c>();
        if(setOfIds.size()>0){
            listOfLeadTeams=DataBase.query(UtilityClass.getQueryString('Lead_Team__c')+' FROM Lead_Team__c WHERE Id IN: setOfIds');
        }
        
        Map<Id,List<Lead_Team__c>> mapOfListleadTeamsIds=new Map<Id,List<Lead_Team__c>>();
        Map<Id,Lead_Team__c> mapOfwithleadTeamsOwners=new Map<Id,Lead_Team__c>();
        for(Id key:mapOfLeadTeamMembers.keySet()){
            if(mapOfLeadTeamMembers.get(key).Lead__c!=null){
                if(!mapOfListleadTeamsIds.containsKey(mapOfLeadTeamMembers.get(key).Lead__c)){
                    mapOfListleadTeamsIds.put(mapOfLeadTeamMembers.get(key).Lead__c,new List<Lead_team__c>{mapOfLeadTeamMembers.get(key)});
                }else{
                    mapOfListleadTeamsIds.get(mapOfLeadTeamMembers.get(key).Lead__c).add(mapOfLeadTeamMembers.get(key));
                }
                
                if(!mapOfwithleadTeamsOwners.containsKey(mapOfLeadTeamMembers.get(key).Lead__c)){
                    if(mapOfLeadTeamMembers.get(key).IsOwner__c){
                        mapOfwithleadTeamsOwners.put(mapOfLeadTeamMembers.get(key).Lead__c,mapOfLeadTeamMembers.get(key));
                    }
                }
            }
        }
        
        for(id key:mapOfLeadTeamMembers.keySet()){
            if(mapOfListleadTeamsIds.containsKey(mapOfLeadTeamMembers.get(key).Lead__c)){
                for(Lead_Team__c leadTeamInstance:mapOfListleadTeamsIds.get(mapOfLeadTeamMembers.get(key).Lead__c)){
                    if(mapOfwithleadTeamsOwners.containsKey(leadTeamInstance.Lead__c)){
                        mapOfwithleadTeamsOwners.get(leadTeamInstance.Lead__c).Attribution_Share_Percentage__c+=mapOfleadIds.get(leadTeamInstance.Lead__c)?.Attribution_Share_Percentage__c;
                    }
                }
            }
        }
        
        if(mapOfwithleadTeamsOwners.values().size()>0){
            update mapOfwithleadTeamsOwners.values();
        }*/
    }
    
    
     /**
    * @description this below method helps to update the OwnerAttribution Sahre on Deletion of Requestors
    * @author Lokesh@SFDeveloper.SFDoc | 17/11/2020 
    * @param Map<id,Lead_Team__c>  listOfLeadsToUpdtaeToday365days 
    * @return void 
    **/
    public static String calucualteTheAttributeSharingBasedOnformula(List<Lead_Team__c> listOfLeadTeams){
        /*
        Integer updateCount = 0;
         Set<Id> leadInstanceIds = new Set<Id>();
        Set<Id> opportunityInstanceIds = new Set<Id>();
        
        for(Lead_Team__c leadTeamInstance:listOfLeadTeams){
            if(leadTeamInstance.Lead__c != null ||  leadTeamInstance.Opportunity__c != null){
                if(leadTeamInstance.Lead__c != null){
                    leadInstanceIds.add(leadTeamInstance.Lead__c);
                }else{
                    opportunityInstanceIds.add(leadTeamInstance.Opportunity__c);
                }
            }
        }
        List<Lead_Team__c> listOfLeadTeamsToProcess=new List<Lead_Team__c>();
        if(leadInstanceIds.size()>0 || opportunityInstanceIds.size()>0){
			listOfLeadTeamsToProcess=DataBase.query(UtilityClass.getQueryString('Lead_team__c')+' FROM Lead_Team__c WHERE Lead__c IN : leadInstanceIds OR Opportunity__c IN : opportunityInstanceIds');
        }
        
        System.debug('listOfLeadTeamsToProcess***'+listOfLeadTeamsToProcess);
        
        Set<Id> leadIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        Lead_Team__c ownerLead = new Lead_Team__c();
        if(listOfLeadTeamsToProcess.size()>0){
            for(Lead_Team__c lte : listOfLeadTeamsToProcess){
                if((lte.Lead__c != null ||  lte.Opportunity__c != null)){
                    if(lte.IsOwner__c == true ){
                        if(lte.Lead__c != null){
                            leadIds.add(lte.Lead__c);
                        }else{
                            opportunityIds.add(lte.Opportunity__c);
                        }
                        ownerLead = lte;
                        System.debug('OwnerRecord'+ownerLead);
                    }
                }
            }
        }
        
        System.debug('LeadIds'+LeadIds);
        System.debug('opportunityIds'+opportunityIds);
        if(!LeadIds.isEmpty() && LeadIds.size() > 0){
            List<Lead_Team__c> listOfExistingLedaTeams = new List<Lead_Team__c>([
                Select Id, Attribution_share_percentage__c, IsOwner__c   from Lead_Team__c where Lead__c IN :LeadIds 
            ]);
            if(!listOfExistingLedaTeams.isEmpty() && listOfExistingLedaTeams.size() > 0){
                if(listOfExistingLedaTeams.size() == 1){
                    if(listOfExistingLedaTeams[0].IsOwner__c){
                        listOfExistingLedaTeams[0].Attribution_share_percentage__c = 100;
                    }
                    updateCount++;
                }else if(listOfExistingLedaTeams.size() == 2){
                    Decimal tempAtt=0;
                    for(Lead_Team__c lte : listOfExistingLedaTeams){
                        
                        if(lte.IsOwner__c){
                            if(lte.Attribution_share_percentage__c == null || lte.Attribution_share_percentage__c == 100){
                                lte.Attribution_share_percentage__c = Decimal.valueOf(Label.OwnerAttributionShareWhen1Requester);
                                tempAtt=lte.Attribution_share_percentage__c;
                            }
                        }else{
                            lte.Attribution_share_percentage__c = 100 - Decimal.valueOf(Label.OwnerAttributionShareWhen1Requester);
                        }
                        updateCount++;
                    }
                }else if(listOfExistingLedaTeams.size() > 2){
                    Decimal sharingpercentage = (Decimal.valueOf(Label.OwnerAttributionShareWhen1Requester) - ( 5 * (listOfExistingLedaTeams.size() - 1))); //Formula to calculate the OwnerShare  P(OwnerShare)-(5*(N-1)) 
                    Decimal requestShare = (100 -  sharingpercentage)/ (listOfExistingLedaTeams.size() - 1);
                    for(Lead_Team__c lte : listOfExistingLedaTeams){
                        if(lte.IsOwner__c){
                            lte.Attribution_share_percentage__c = sharingpercentage;
                        }else{
                            lte.Attribution_share_percentage__c = requestShare;
                        }
                        updateCount++;
                    }
                }
            }
            List<Lead> listOfLeadsToUpdate= new List<Lead>();
             for(Id parentId:leadIds){
                 Lead leadInstance=new Lead();
                 leadInstance.ID=parentId;
                 leadInstance.No_of_times_Edited_By_Owner_Lead_Teams__c=null;
                 listOfLeadsToUpdate.add(leadInstance);
            }
            
            if(listOfLeadsToUpdate.size()>0){
                update listOfLeadsToUpdate;
            }
            
            if(updateCount != 0){
                System.debug('listOfExistingLedaTeams'+listOfExistingLedaTeams);
                update listOfExistingLedaTeams;
                return 'success';
            }
        }else if(!opportunityIds.isEmpty()){
            
            
            List<Lead_Team__c> listOfExistingLedaTeams = new List<Lead_Team__c>([
                Select Id, Attribution_share_percentage__c, IsOwner__c   from Lead_Team__c where Opportunity__c IN :opportunityIds 
            ]);
            if(!listOfExistingLedaTeams.isEmpty() && listOfExistingLedaTeams.size() > 0){
                if(listOfExistingLedaTeams.size() == 1){
                    if(listOfExistingLedaTeams[0].IsOwner__c){
                        listOfExistingLedaTeams[0].Attribution_share_percentage__c = 100;
                    }
                    updateCount++;
                }else if(listOfExistingLedaTeams.size() == 2){
                    for(Lead_Team__c lte : listOfExistingLedaTeams){
                        if(lte.IsOwner__c){
                            if(lte.Attribution_share_percentage__c == null || lte.Attribution_share_percentage__c == 100){
                                lte.Attribution_share_percentage__c = Decimal.valueOf(Label.OwnerAttributionShareWhen1Requester);
                            }
                        }else{
                            lte.Attribution_share_percentage__c = 100 - ownerLead.Attribution_share_percentage__c;
                        }
                        updateCount++;
                    }
            }else if(listOfExistingLedaTeams.size() > 2){
                Decimal sharingpercentage = (ownerLead.Attribution_share_percentage__c - 5) / (listOfExistingLedaTeams.size() - 1); //Formula to calculate the OwnerShare  P(OwnerShare)-(5*(N-1)) 
                Decimal requestShare = (100 -  sharingpercentage)/ (listOfExistingLedaTeams.size() - 1);
                for(Lead_Team__c lte : listOfExistingLedaTeams){
                    if(!lte.IsOwner__c){
                        lte.Attribution_share_percentage__c = sharingpercentage;
                    }else{
                        lte.Attribution_share_percentage__c = requestShare;
                    }
                    updateCount++;
                }
            }
        }
            
          List<Opportunity> listOfOpportunityToUpdate= new List<Opportunity>();
             for(Id parentId:opportunityIds){
                 Opportunity opportunityInstance=new Opportunity();
                 opportunityInstance.ID=parentId;
                 opportunityInstance.No_of_times_Edited_By_Owner_Lead_Teams__c=null;
                 listOfOpportunityToUpdate.add(opportunityInstance);
            }
            
            if(listOfOpportunityToUpdate.size()>0){
                update listOfOpportunityToUpdate;
            }
            
        if(updateCount != 0){
                update listOfExistingLedaTeams;
                return 'success';
            }
        }*/
        
        return 'no records updated';
    }
    
     /**
    * @description this below method helps to update the Approved status
    * @author Lokesh@SFDeveloper.SFDoc | 17/11/2020 
    * @param List<Lead_Team__c>  listOfLeadTeams 
    * @return void 
    **/
    public static void updateApprovedforOwnerLeadTeam(List<Lead_Team__c> listOfLeadTeams){
        if(listOfLeadTeams.size()>0){
            for(Lead_Team__c newLeadTeam:listOfLeadTeams){
                if(newLeadTeam.IsOwner__c==true){
                    newLeadTeam.Approval_for_Co_Ownership__c='Approved';
                }
            }
        }
    }
        
    
    
    
    
    

}