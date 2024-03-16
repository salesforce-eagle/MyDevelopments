@isTest
public class CTX_SendPartnerAccountCreationMail_TEST {
    
	@isTest
    public static void sendMailToLegalTeam_TEST(){
        Account acc = new Account(
            Name 					= 'Test Account',
            RecordTypeId 			= AccountConstants.CHANNEL_PARTNER_RecordTypeId,
            Master_Admin_Email__c 	= 'test@test.com'
        );
        
        insert acc;
        
        Test.startTest();
        CTX_SendPartnerAccountCreationMail.sendMailToLegalTeam(new List<Account>{acc});
        Test.stopTest();
    }
}