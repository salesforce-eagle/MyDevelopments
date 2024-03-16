public class LeadTeamsController {
    @AuraEnabled
    public static Wrapper getDetails(String oppId){
        List<LeadTeam> listOfLTs = new List<LeadTeam>(); 
        Wrapper wap = new Wrapper();
        //List<Opportunity> oppDetails = [SELECT id,stageName, SyncedQuoteId FROM Opportunity WHERE id=:oppId LIMIT 1];
        List<Lead_Team__c> listOfLT = [SELECT id, Attribution_share_percentage__c ,Incentive_Attribution__c , Opportunity__c , Record_Access__c,	User__r.name ,Opportunity__r.name
                                         FROM Lead_Team__c  
                                         WHERE Opportunity__r.Id =:oppId];
        System.debug('listOfLT '+listOfLT);
        if(!listOfLT.isEmpty()){
            wap.listOfLTWrapper = listOfLT;
        }
        for(Lead_Team__c lt : listOfLT){
            LeadTeam AGWap = new LeadTeam();
            AGWap.Id = lt.Id;
            AGWap.RecordAccess = lt.Record_Access__c;
            AGWap.User = lt.User__c;
            AGWap.AttributionShare = String.ValueOf(lt.Attribution_share_percentage__c);
            AGWap.IncentiveShare = String.ValueOf(lt.Incentive_Attribution__c);
            listOfLTs.add(AGWap);
             }
        if(!listOfLTs.isEmpty()){
            wap.listOfLTWrapper2 = listOfLTs;
            System.debug(' wap.listOfLTWrapper '+ wap.listOfLTWrapper2);
        }else{
            LeadTeam AGWap = new LeadTeam();
            AGWap.Id = '';
            AGWap.RecordAccess = '';
            AGWap.User = '';
            AGWap.AttributionShare = '';
            AGWap.IncentiveShare = '';
            listOfLTs.add(AGWap);
            wap.listOfLTWrapper2 = listOfLTs;
        }
        System.debug('listOfLTs '+listOfLTs);
        System.debug('wap '+wap);
        return wap;
    }
    @AuraEnabled
    public static String saveDetails(String listOfLTToUpsertWrapper, List<String> listOfLTToDeleteWrapper, String opportunityId){ //List<AdditionGSTIN>
        try{
            List<Lead_Team__c> listOfLTToUpsert = new List<Lead_Team__c>();
            List<Lead_Team__c> listOfLTToDelete = new List<Lead_Team__c>();
            System.debug('listOfLTToUpsertWrapper '+listOfLTToUpsertWrapper);
            System.debug('listOfLTToDeleteWrapper '+listOfLTToDeleteWrapper);
            System.debug('opportunityId '+opportunityId);
            for(String IdsToDelete : listOfLTToDeleteWrapper){
                Lead_Team__c ag = new Lead_Team__c();
                ag.Id =IdsToDelete;
                listOfLTToDelete.add(ag);
            }
            List<LeadTeam> LTWrap = (List<LeadTeam>)JSON.deserialize(listOfLTToUpsertWrapper,List<LeadTeam>.class); 
            for(LeadTeam ag : LTWrap){
                Lead_Team__c eachAG = new Lead_Team__c();
                if(ag.Id != null && ag.Id != ''){
                    eachAG.Id = ag.Id; 
                }
                eachAG.User__c = ag.User;
                eachAG.Opportunity__c = opportunityId;
                eachAG.Record_Access__c = ag.RecordAccess;
                eachAG.Attribution_share_percentage__c = Decimal.ValueOf(ag.AttributionShare);
                eachAG.Incentive_Attribution__c = Decimal.ValueOf(ag.IncentiveShare);
                listOfLTToUpsert.add(eachAG);
            }
            System.debug('listOfLTToDelete '+listOfLTToDelete);
            System.debug('listOfLTToUpsert '+listOfLTToUpsert);
            if(!listOfLTToDelete.isEmpty()){
                delete listOfLTToDelete;
            }
            if(!listOfLTToUpsert.isEmpty()){
                upsert listOfLTToUpsert;
            }
        }catch(Exception e){
            System.debug('Exception Line no '+e.getLineNumber());
            System.debug('Exception MSG '+e.getMessage());
            System.debug('Exception Type '+e.getTypeName());
            System.debug('Exception Cause '+e.getCause());
            System.debug('Exception stack trace '+e.getStackTraceString());
            return e.getMessage();
        }
        return '';
    }
    public class Wrapper{
        @AuraEnabled
        public String errorMsg;
        @AuraEnabled
        public Boolean errorMsgClosedOrFin;
        @AuraEnabled
        public String opportunityId;
        @AuraEnabled
        public List<Lead_Team__c> listOfLTWrapper;
        @AuraEnabled
        public List<LeadTeam>     listOfLTWrapper2;
    }
    public class LeadTeam{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String User;
        @AuraEnabled
        public String RecordAccess;
        @AuraEnabled
        public String AttributionShare;  
        @AuraEnabled
        public String IncentiveShare;
    }
}