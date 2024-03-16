@isTest
public class CTX_PartnerAgreementESignSender_TEST {
    @testsetup
    public static void setup(){
        List<sObject> ls = Test.loadData(E_Sign_Config__c.sObjectType, 'ESign_Config');
System.debug(ls);
        Account acc = new Account(
            Name 					= 'Test Account',
            RecordTypeId 			= AccountConstants.CHANNEL_PARTNER_RecordTypeId,
            Master_Admin_Email__c 	= 'test@test.com'
        );
        
        insert acc;
        
        Contact con = new Contact(
        	LastName 	= 'Test Contact',
            Email 		= acc.Master_Admin_Email__c,
            Phone 		= '1111111111',
            AccountId 	= acc.Id
        );
        
        insert con;
        
        Map<String, E_Sign_Config__c> 	eSignConfig 				= E_Sign_Config__c.getAll();
        
        ContentVersion conVersion = new ContentVersion(
            PathOnClient 		= 'OrderForm' + '.pdf',
            Title 				= 'OrderFrom',
            Type_of_document__c = eSignConfig.get('Type_Of_Doc').Value__c,
            System_Generated__c = true,
            VersionData 		= Blob.valueOf('abcd')
        );
        insert conVersion;
        
        Id cdId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE id = : conVersion.id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink(
        	ContentDocumentId = cdId,
            LinkedEntityId = acc.Id,
            ShareType = 'V'
        );
        insert cdl;
        
    }
    
    @isTest
    public Static void sendOrderFromForESign_TEST(){
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id,Name,Agreement_Sign_Method__c,Master_Admin_Email__c,Owner.Name,RecordType.name,CC__c,OTP_For_Electronic_Signature__c,Esign_Order__c, E_Sign_Type__c 
                                                                             FROM Account WHERE Name = 'Test Account']);
        Test.setMock(HttpCalloutMock.class, new CTX_ESignGenericRespoceMock());
        Test.StartTest();
        //CTX_PartnerAgreementESignSender.sendOrderFromForESign(accMap, new set<String>{'test@test.com'});
        Test.StopTest();    
    }
    
}