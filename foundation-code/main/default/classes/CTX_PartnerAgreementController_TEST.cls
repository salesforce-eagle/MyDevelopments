@isTest
public class CTX_PartnerAgreementController_TEST {
    
    @testsetup
    public static void setup(){
        Account acc = new Account(
            Name 					= 'Test Account',
            RecordTypeId 			= AccountConstants.CHANNEL_PARTNER_RecordTypeId,
            Master_Admin_Email__c 	= 'test@test.com'
        );
        
        insert acc;
    }
	
    @isTest
    public static void cTX_PartnerAgreementPDF_Page_TEST(){
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        
        CTX_PartnerAgreementController.FileInfo fileData = new CTX_PartnerAgreementController.FileInfo();
        fileData.Title 			= 'Test File';
        fileData.VersionData 	= Blob.valueOf('Test Content');
        Test.startTest();
        CTX_PartnerAgreementController.saveStampReferance(acc.Id, fileData);
        
        PageReference pageRef = Page.CTX_PartnerAgreementPDF;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(acc.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        CTX_PartnerAgreementController contoller = new CTX_PartnerAgreementController(sc);
        Test.stopTest();
    }
    
    @isTest
    public static void saveStampReferance_TEST(){
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        
        CTX_PartnerAgreementController.FileInfo fileData = new CTX_PartnerAgreementController.FileInfo();
        fileData.Title 			= 'Test File';
        fileData.VersionData 	= Blob.valueOf('Test Content');
        
        Test.startTest();
		CTX_PartnerAgreementController.saveStampReferance(acc.Id, fileData);
        Test.stopTest();
        
        ContentDocumentLink conDocLink 	= [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: acc.Id];
        System.AssertEquals(true, conDocLink != null);
    }
    
    @isTest
    public static void generatePartnerAgreement_TEST(){
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
		CTX_PartnerAgreementController.generatePartnerAgreement(acc.Id);
        Test.stopTest();
        
        ContentDocumentLink conDocLink 	= [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: acc.Id];
        System.AssertEquals(true, conDocLink != null);
        
        ContentVersion conVersion = [SELECT Id, Title, ContentDocumentId, Type_of_document__c, System_Generated__c FROM ContentVersion WHERE ContentDocumentId =: conDocLink.ContentDocumentId];
        System.AssertEquals('Order Form', conVersion.Type_of_document__c);
    }
    @isTest
    public static void uploadOrderFormManually_TEST(){
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        CTX_PartnerAgreementController.FileInfo fileData = new CTX_PartnerAgreementController.FileInfo();
        fileData.Title 			= 'Test File';
        fileData.VersionData 	= Blob.valueOf('Test Content');
        
        Test.startTest();
		CTX_PartnerAgreementController.uploadOrderFormManually(acc.Id, fileData);
        Test.stopTest();
        
        ContentDocumentLink conDocLink 	= [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: acc.Id];
        System.AssertEquals(true, conDocLink != null);
        ContentVersion conVersion = [SELECT Id, Title, ContentDocumentId, Type_of_document__c, System_Generated__c FROM ContentVersion WHERE ContentDocumentId =: conDocLink.ContentDocumentId];
        System.AssertEquals('Order Form', conVersion.Type_of_document__c);
    }
}