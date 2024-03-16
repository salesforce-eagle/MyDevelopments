@isTest
public class CTX_PartnerOnboardingController_TEST {
    
    @isTest
    public static void createPartnerAccount_TEST(){
        Map<String, String> accMap = new Map<String, String>{
            'Name'			=> 'Test Account Pvt. Ltd.', 
            'RecordTypeId'	=> AccountConstants.CHANNEL_PARTNER_RecordTypeId, 
            'Master_Admin_Email__c' 	=> 'test@test.com'
        };
            
        Map<String, String> conMap = new Map<String, String>{
            'LastName'				=> 'Test Contact', 
            'Email'					=> accMap.get('Master_Admin_Email__c'),
            'Phone' 				=> '1111111111'
        };
		
        CTX_PartnerOnboardingController.FileInfo fileData = new CTX_PartnerOnboardingController.FileInfo();
        fileData.Title 			= 'Test File';
        fileData.VersionData 	= Blob.valueOf('Test Content');
        
        Test.startTest();
        CTX_PartnerOnboardingController.createPartnerAccount(accMap, conMap, new List<CTX_PartnerOnboardingController.FileInfo>{fileData});
        Test.stopTest();
        Account 			acc 		= [SELECT Id, Name FROM Account LIMIT 1];
        Contact 			con 		= [SELECT Id, LastName FROM Contact LIMIT 1];
        ContentDocumentLink conDocLink 	= [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: acc.Id];
        System.AssertEquals(accMap.get('Name'), acc.Name);
        System.AssertEquals(conMap.get('LastName'), con.LastName);
        System.AssertEquals(true, conDocLink != null);
    }
    
    @isTest
    public static void createFiles_TEST(){
        Account acc = new Account(
            Name 					= 'Test Account',
            RecordTypeId 			= AccountConstants.CHANNEL_PARTNER_RecordTypeId,
            Master_Admin_Email__c 	= 'test@test.com'
        );
        
        insert acc;
        
        CTX_PartnerOnboardingController.FileInfo fileData = new CTX_PartnerOnboardingController.FileInfo();
        fileData.Title 			= 'Test File';
        fileData.VersionData 	= Blob.valueOf('Test Content');
        
        Test.startTest();
        CTX_PartnerOnboardingController.createFiles(acc.Id, new List<CTX_PartnerOnboardingController.FileInfo>{fileData});
        Test.stopTest();
        
        ContentDocumentLink conDocLink 	= [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: acc.Id];
        System.AssertEquals(true, conDocLink != null);
        
    }
    
    @isTest
    public static void createDynamicObjectInstance_TEST(){
        Map<String, String> accMap = new Map<String, String>{
            'Name'						=> 'Test Account Pvt. Ltd.', 
            'RecordTypeId'				=> AccountConstants.CHANNEL_PARTNER_RecordTypeId, 
            'Master_Admin_Email__c' 	=> 'test@test.com',
            'Is_Partner_Live__c'		=> 'TRUE',
            'Effective_from__c'			=> String.valueOf(System.today()),
            'Expiry_Date__c'			=> String.valueOf(System.today().addDays(10)),
            'CreatedDate'				=> String.valueOf(System.now()),
            'Commission_New_Sales__c'	=> '10.0'
        };
        Sobject sObjectInst;
        Test.startTest();
        sObjectInst = CTX_PartnerOnboardingController.createDynamicObjectInstance('Account',accMap);
        Test.stopTest();
        System.assertEquals(true, sObjectInst instanceOf Account);
    }
}