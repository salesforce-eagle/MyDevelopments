public without sharing class CTX_ApexRecordSharingHelper {
    
    public static AccountShare create_AccountShareRecord(Id accountId, Id userId){
        
        AccountShare ownerShare 	= new AccountShare(
            AccountId 				= accountId,
            UserOrGroupId 			= userId,
            AccountAccessLevel 		= 'Edit',
            OpportunityAccessLevel	= 'Edit',
            CaseAccessLevel			= 'Edit',
            RowCause				= Schema.AccountShare.RowCause.Manual
        );
        
        return ownerShare;
    }
    
    public static ContactShare create_ContactShareRecord(Id contactId, Id userId){
        
        ContactShare ownerShare = new ContactShare(
            ContactId 			= contactId,
            UserOrGroupId 		= userId,
            ContactAccessLevel	= 'Edit',
            RowCause			= Schema.ContactShare.RowCause.Manual
        );
        
        return ownerShare;
    }
    
    
    
    
    
    
}