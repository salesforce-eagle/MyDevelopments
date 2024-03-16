trigger FeedItemTrigger on FeedItem (after insert, after update) {
    system.debug('****Inside FeedItem Trigger');
    if(trigger.isInsert){
        FeedItemTiggerHandler.UpdateFeedItemToChildCases(Trigger.new);
        FeedItemTiggerHandler.UpdateFieldOnProject(Trigger.new,false);
        FeedItemTiggerHandler.UpdateFieldOnAsset(Trigger.new,false);
        FeedItemTiggerHandler.UpdateFieldOnBillingDetails(Trigger.new,false);
    }
    if(trigger.isUpdate){
        FeedItemTiggerHandler.UpdateFieldOnProject(Trigger.new,true);
        FeedItemTiggerHandler.UpdateFieldOnAsset(Trigger.new,true);
        FeedItemTiggerHandler.UpdateFieldOnBillingDetails(Trigger.new,true);
    }
    
}