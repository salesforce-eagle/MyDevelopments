public class ContentDocumentTriggerHelper {
     
    /**
     * Added by Raksha
     * Method Description : Restrict The deletion of the ContentDocument if its sent for Esign and the signed document is not yet uploaded
     */
    public static void restrictDeleteOfContentDoc(map<Id,ContentDocument> mapOfOldContentDocumentSObjectRecords){
        System.debug('CD Helper mapOfOldContentDocumentSObjectRecords '+mapOfOldContentDocumentSObjectRecords);
        Map<Id,ContentDocument> mapOfContentDocument=new Map<Id,ContentDocument>();
        Set<Id> setOfcontentDocIds=new Set<Id>();
        Set<String> contentVersionIds = new Set<String>();
        for(Id key:mapOfOldContentDocumentSObjectRecords.keySet()){
            setOfcontentDocIds.add(mapOfOldContentDocumentSObjectRecords.get(key).Id);
            mapOfContentDocument.put(mapOfOldContentDocumentSObjectRecords.get(key).Id, mapOfOldContentDocumentSObjectRecords.get(key));
        }
       
        System.debug('CD Helper setOfcontentDocIds '+setOfcontentDocIds);
        System.debug('CD Helper mapOfContentDocument '+mapOfContentDocument);
        List<ContentDocumentLink> lstOfCDL = new List<ContentDocumentLink>();
        if(!setOfcontentDocIds.isEmpty()){
           lstOfCDL = [SELECT Id, LinkedEntityId, ContentDocumentId  from ContentDocumentLink WHERE contentDocumentId IN:setOfcontentDocIds AND LinkedEntityId != null];
        }
        System.debug('CD Helper lstOfCDL '+lstOfCDL);
        Map<String,String> mapOfCDidToCDLid = new Map<String,String>();
        for(ContentDocumentLink cdl : lstOfCDL){
            if(cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                mapOfCDidToCDLid.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
            }
        }
        System.debug('CD Helper mapOfCDidToCDLid '+mapOfCDidToCDLid);
        List<Opportunity> listOfOpp = [SELECT id,ESign_BE_Reference_Doc_ID__c,E_Sign_Status__c FROM Opportunity 
                                       WHERE id IN: mapOfCDidToCDLid.values() AND E_Sign_Status__c	=: OpportunityConstants.ESIGN_STATUS_REQUEST_SENT];
        System.debug('CD Helper listOfOpp '+listOfOpp);
        for(Opportunity opp : listOfOpp){
            if(opp.ESign_BE_Reference_Doc_ID__c != null){
                contentVersionIds.add(opp.ESign_BE_Reference_Doc_ID__c);
            }
        }
        //List<ContentVersion> listOfContentVersion = [SELECT id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: mapOfCDidToCDLid.keySet()];
        List<ContentVersion> listOfContentVersion = [SELECT id,ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionIds];
        System.debug('CD Helper listOfContentVersion '+listOfContentVersion);
        for(ContentVersion contentVersionInstance : listOfContentVersion){
            System.debug('CD Helper contentVersionInstance '+contentVersionInstance);
            mapOfContentDocument?.get(contentVersionInstance?.ContentDocumentId).adderror('Cannot delete. The file is sent for ESign');
            System.debug('*******');
        }
        
        List<Opportunity> listOfOpp2 = [SELECT id,StageName, ESign_BE_Reference_Doc_ID__c,E_Sign_Status__c FROM Opportunity 
                                       WHERE id IN: mapOfCDidToCDLid.values()];
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(listOfOpp2);
        System.debug('CD Helper listOfOpp2 '+listOfOpp2);
        System.debug('CD Helper oppMap '+oppMap);
        
        for(ContentDocument cdInstance : mapOfOldContentDocumentSObjectRecords.Values()){
            if(mapOfCDidToCDLid.containsKey(cdInstance.id) && oppMap.containsKey(mapOfCDidToCDLid.get(cdInstance.id)) 
               &&  oppMap.get(mapOfCDidToCDLid.get(cdInstance.id)).StageName == OpportunityConstants.STAGENAME_IN_FINANCE_APPROVAL)
                cdInstance.adderror('Cannot delete. The Opportunity is in Finance Approval');
        }

    }
}