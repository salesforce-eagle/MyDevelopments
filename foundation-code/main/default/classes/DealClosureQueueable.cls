public class DealClosureQueueable implements Queueable, Database.AllowsCallouts {
    
    List<Account> 		newAccounts;
    Map<Id, Account> 	oldAccountMap;
    Set<String> 		setOfOppIds;
    Set<String> 		setOfAssetIds;
    Set<Id> 			assetIds;
    Boolean 			isInsert				= FALSE;
    Boolean				isOpportunityAvailable	= TRUE;
    Boolean				isAccountOnly			= FALSE;
    
    public DealClosureQueueable( 
        Set<String> 	opportunityIdsSet, 
        Set<String> 	assetIdsSet, 
        Boolean 		isOpportunityAvailable, 
        Boolean 		isInsert
    ){ 
        System.debug('I am being called by Asset Trigger');
        this.setOfOppIds 			= opportunityIdsSet;
        this.setOfAssetIds 			= assetIdsSet;
        this.isOpportunityAvailable = isOpportunityAvailable;
        this.isInsert 				= isInsert;
    }
    
    public DealClosureQueueable( List<Account> newAccounts, Map<Id, Account> oldAccountMap, Boolean isAccountOnly ){ 
        this.newAccounts 			= newAccounts;
        this.oldAccountMap			= oldAccountMap;
        this.isAccountOnly			= isAccountOnly;
        this.isOpportunityAvailable = FALSE;
        this.setOfOppIds 			= NULL;
        this.setOfAssetIds 			= NULL;
        this.isInsert 				= FALSE;
    }
    
    
    public void execute(QueueableContext context) {
        
        Set<String> 				oppToBeRemoved	= new Set<String>();
        List<String> 				oppIDs			= new list<string>(setOfOppIds);
        List<String> 				assetIds		= new list<string>(setOfAssetIds);
        Integer 					loopSize 		= 10;
        DealClosureQueueable 		DQ;
        
        if(isAccountOnly && !isOpportunityAvailable){
            for(Account thisRec : newAccounts){
                
                DealClosureCallOut.Callout(thisRec, oldAccountMap.get(thisRec.Id).Master_admin_Email__c);
            }
        } else{
            if(isOpportunityAvailable){	/**	In case Opportunity is Available	**/
                
                for(Integer i = 0; i < oppIDs.size(); i++){
                    DealClosureCallOut.Callout(oppIDs[i], NULL, isOpportunityAvailable, isInsert);
                }
            } else{	/**	In case Opportunity is Null	**/
                for(Integer i = 0; i < assetIds.size(); i++){
                    DealClosureCallOut.Callout(NULL, assetIds[i], FALSE, isInsert);
                }
            }
        }
    }
}