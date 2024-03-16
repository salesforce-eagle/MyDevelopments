public class OpportunityBlocker_LwcController {
    
    @AuraEnabled(cacheable=true)
    public static Boolean getAccountDetailsForError(String accId) {
        system.debug('accId >> ' + accId);
        Account acc = [SELECT Id, ParentId from Account where Id = :accId];
        if(acc.ParentId != NULL){
            return True;
        }else{
            return False;
        }
    }

}