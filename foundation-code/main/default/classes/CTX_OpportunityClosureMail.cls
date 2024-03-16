public class CTX_OpportunityClosureMail {
    /*
    public static void opportunity_KAM_Owner_Assignment_opportunityClosureMail(Map<Id,Opportunity> mapOfNewOpps, Map<Id,Opportunity> mapOfOldOpps){
        Map<Id, Opportunity> closedWonOpps = new Map<Id, Opportunity>();
        List<OpportunityClosureMail.Parameter> listOfClosureParam = new List<OpportunityClosureMail.Parameter>();
        
        for(Id key:mapOfNewOpps.KeySet()){
            Opportunity oppNewInstance=mapOfNewOpps.get(key);
            Opportunity oppOldInstance=mapOfOldOpps.get(key);
            if(
                oppNewInstance.StageName!=null && 
                oppNewInstance.StageName!=oppOldInstance.StageName){
                    if(oppNewInstance.StageName== OpportunityConstants.STAGENAME_CLOSED_WON)   
                    {
                        closedWonOpps.put(oppNewInstance.Id,oppNewInstance);
                    }
                }
        }
        
        if(closedWonOpps.values().size()>0){
            for(Opportunity thisRec : closedWonOpps.values())
            {
                OpportunityClosureMail.Parameter closureParam = new OpportunityClosureMail.Parameter();
                closureParam.additionalMailIDs = System.label.Closure_Mail_additionalMailIDs ;
                closureParam.emailTemplateId = 'Opportunity_Closed_won_with_attachment';
                closureParam.ownerIdOrManagerId = thisRec.OwnerId +','+thisRec.Owner.ManagerId+','+thisRec.Account.OwnerId+','+thisRec.Regional_Head__c;
                closureParam.recipientList = '' ;
                closureParam.roleID = System.label.Closure_Mail_roleID ;
                closureParam.recordId = thisRec.Id ;
                closureParam.GCCRecipientList = System.label.Closure_Recipient_GCC;
                closureParam.recordTypeName = thisRec.RecordType.developerName;
                closureParam.noAttachmentEmailIds = System.label.Closure_Mail_Without_Attachment;
                System.debug('recipientList-->'+closureParam.recipientList);
                listOfClosureParam.add(closureParam);      
            } 
        }
        
        if(!listOfClosureParam.isEmpty()){
            System.debug('OpportunityClosureMail');
            System.enqueueJob(new OpportunityClosureMail(listOfClosureParam));
        }
    }
    */
}