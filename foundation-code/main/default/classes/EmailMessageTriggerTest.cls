@IsTest
public class EmailMessageTriggerTest {
    
    @testSetup
    public static void testDataSetUpMethod(){
        
        List<Org_wide_and_Email_Template_Mapping__mdt> orgwideandEmailTemplateMappingInstance= new List<Org_wide_and_Email_Template_Mapping__mdt>();
        orgwideandEmailTemplateMappingInstance=DataBase.query('SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Email_to_case_Inbound_Email__c, Org_Wide_Email_Id__c, Email_Template_Id__c  FROM Org_wide_and_Email_Template_Mapping__mdt ');
        
        List<EmailMessage> listOfEmailMessages=TestDataFactory.createEmailMessageRelatedToCase(1);
        if(listOfEmailMessages.size()>0){
            for(EmailMessage instance :listOfEmailMessages){
                instance.Incoming=true; 
                instance.Subject='kansdjk';
            }
        }
        insert listOfEmailMessages;
        
        Account accountInstance=new Account();
        accountInstance.name='test1';
        insert accountInstance;        
        Contact contactInstance= new Contact(LastName='TestAccount1' ,FirstName='TestAccount1',Phone='900000000',Email='test1@cleartax.com',AccountId=accountInstance.Id);
        insert contactInstance;
        
        Case caseInstance=new Case();
        caseInstance.AccountId=contactInstance.AccountId;
        caseInstance.ContactId=contactInstance.Id;
        caseInstance.Priority='P1';
        caseInstance.Status='New';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        caseInstance.SuppliedName='Test';
        caseInstance.Subject='Test Case 112121';
        
        Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
        insert caseInstance;
        
        //        
        case inst= new case();
        inst.AccountId=contactInstance.AccountId;
        inst.ContactId=contactInstance.Id;
        inst.Priority='P1';
        inst.Status='Closed';
        inst.SuppliedName='Test';
        inst.Subject='Test Case 112121';

        insert inst;
       
        list<EmailMessage> listOfEmailMsg= new list<EmailMessage>();
        EmailMessage emailMessageInstance1=new EmailMessage(
            Subject                = 'test14'
            ,Status                 = '3'
            ,ToAddress              = 'heim@elastify.eu'
            ,FromAddress            = 'test@gmail.com'
            ,FromName               = 'Test'
            ,HtmlBody               = 'a body'
            ,Incoming               = true
            ,MessageDate            = DateTime.now()
            ,TextBody				='TextBody'
            ,ParentId				= inst.Id);  
        listOfEmailMsg.add(emailMessageInstance1);  
        
        test.startTest();
        //EmailMessageTriggerHelper.updateNewCaseIdToEmailMessage(listOfEmailMsg);
        test.stopTest();
        // insert listOfEmailMsg; 
        
        /* Case caseInstance1=new Case();
caseInstance1.Status='Open';
caseInstance1.Priority='P1';
caseInstance1.Followup_Parent_Case__c=inst.id;
insert caseInstance1; 


EmailMessage emailMessageInstance2=new EmailMessage(
Subject                = 'test12'
,Status                 = '3'
,ToAddress              = 'heim@elastify.eu'
,FromAddress            = 'test@gmail.com'
,FromName               = 'Test'
,HtmlBody               = 'a body'
,Incoming               = true
,MessageDate            = DateTime.now()
,ParentId				= caseInstance1.Id);
insert emailMessageInstance2;  */
        
        //
        
        List<EmailMessage> listEmailMessages=new List<EmailMessage>();
        for(Integer i=0;i<1;i++){
            EmailMessage emailMessageInstance=new EmailMessage(
                Subject                = 'test12'+i
                ,Status                 = '3'
                ,ToAddress              = 'heim'+i+'@elastify.eu'
                ,FromAddress            = 'test@gmail.com'
                ,FromName               = 'Test'
                ,HtmlBody               = 'a body ref:_'
                ,Incoming               = true
                ,MessageDate            = DateTime.now()
                ,ParentId				= caseInstance.Id
                // ,HasAttachment       = true // not possible: Read-Only!
            );
            listEmailMessages.add(emailMessageInstance);
        }
        System.debug('listEmailMessages'+listEmailMessages);
        System.debug('listEmailMessages'+UserInfo.getUserEmail());
        
        //insert listEmailMessages;
        
        
    }
    
    @isTest
    public static void TestProblemIncident(){
        list<case> listOfcases=[select id,type,status,parentId from case limit 2];
        listOfcases[0].type='Problem';
        listOfcases[1].type='Incident of problem';
         listOfcases[1].parentID=listOfcases[0].id;
        update listOfcases;
         EmailMessage emailMessageInstance=new EmailMessage(
                Subject                = 'test12'
                ,Status                 = '3'
                ,ToAddress              = 'heim@elastify.eu'
                ,FromAddress            = 'Warpdri@gmail.com'
                ,FromName               = UserInfo.getFirstName()+' - '+UserInfo.getLastName()
                ,HtmlBody               = 'a body'
                ,Incoming               = false
                ,MessageDate            = DateTime.now()
                ,ParentId				= listOfcases[0].Id
                ,TextBody 				= ' TextBody ');
        test.startTest();
        insert emailMessageInstance;
        test.stopTest();
    }
    @isTest
    public static void testmethod1(){
        List<EmailMessage> listOfEmailMessages= [SELECT id,ParentId from EmailMessage];
        Test.startTest();	
        System.assertNotEquals(null, listOfEmailMessages[0].ParentId);
        Test.stopTest();
    }
    
    @isTest
    public static void testmethod2(){
        List<EmailMessage> listOfEmailMessages= [SELECT id,ParentId from EmailMessage limit 1];
        case caseInstance = new case();
        
        Test.startTest();	
        update listOfEmailMessages;
        delete listOfEmailMessages;
        Test.stopTest();
    }
    @isTest
    public static void testMethod3(){
        List<EmailMessage> listOfEmailMessages=TestDataFactory.createEmailMessageRelatedToCase(1);
        if(listOfEmailMessages.size()>0){
            for(EmailMessage instance :listOfEmailMessages){
                instance.Incoming=false; 
            }
        }
        Test.startTest();	
        insert listOfEmailMessages;
        Test.stopTest();	
    } 
    @isTest
    public static void method4(){
        //  List<EmailMessage> listOfEmailMessages1= [SELECT id,ParentId from EmailMessage limit 1];
        Account accountInstance=new Account();
        accountInstance.name='test1';
        insert accountInstance;        
        Contact contactInstance= new Contact(LastName='TestAccount1' ,FirstName='TestAccount1',Phone='900000000',Email='test1@cleartax.com',AccountId=accountInstance.Id);
        insert contactInstance;
        Case caseInstance=new Case();
        caseInstance.AccountId=contactInstance.AccountId;
        caseInstance.ContactId=contactInstance.Id;
        caseInstance.Priority='P1';
        caseInstance.Status='Solved';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        caseInstance.Subject='Test Case';
        Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
        insert caseInstance;
        List<EmailMessage> listOfEmailMessages=new List<EmailMessage>();
        for(Integer i=0;i<1;i++){
            EmailMessage emailMessageInstance=new EmailMessage(
                Subject                = 'test12'+i
                ,Status                 = '3'
                ,ToAddress              = 'heim'+i+'@elastify.eu'
                ,FromAddress            = 'Warpdri@gmail.com'
                ,FromName               = UserInfo.getFirstName()+' - '+UserInfo.getLastName()
                ,HtmlBody               = 'a body'
                ,Incoming               = false
                ,MessageDate            = DateTime.now()
                ,ParentId				= caseInstance.Id
                ,TextBody 				= ' TextBody '
                // ,HasAttachment       = true // not possible: Read-Only!
            );
            
            listOfEmailMessages.add(emailMessageInstance);
        }
        
        Test.startTest();	
        insert listOfEmailMessages;
        Test.stopTest();  
    }
    @isTest
    static  void testCompleteMilestoneCase(){
        Account acc = new account(name='Test Account');
        insert acc;
        
        Contact oContact = new contact(firstname='John',lastname='Doe',email='test@test.com',accountid=acc.id);
        insert oContact;
        
        Entitlement entl = new entitlement(name='GST Engineering SLA On P1',accountid=acc.id,type='Gateway Support', StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        List<SLAProcess> listOfSLAProcesses=[SELECT SobjectType, Name, Id, IsActive, VersionNumber FROM SlaProcess WHERE Name Like '%GST Engineering%'  and IsActive = true  limit 1];
        if(listOfSLAProcesses.size()>0){
            entl.SlaProcessId= listOfSLAProcesses[0].Id;
        }
        insert entl;
        
        System.debug('listOfSLAProcesses'+listOfSLAProcesses);
        
        String contactId;
        if (oContact != null)
            contactId = oContact.Id;
        
        String entlId;
        if (entl != null)
            entlId = entl.Id;
        
        List<Case> cases = new List<Case>{};
            if (entlId != null){
                Case c = new Case(Subject = 'Test Case with Entitlement ', AccountId = acc.id, ContactId = oContact.id, EntitlementId=entl.id, slaStartDate=system.now());
                
                cases.add(c);
            }
        List<Id> caseIds = new List<Id>();
        // Insert the Account records that cause the trigger to execute.
        if (cases.isEmpty()==false){
            Test.setMock(HttpCalloutMock.class, new RestMockUtility());
            insert cases;
            for (Case cL : cases){
                caseIds.add(cL.Id);
                system.debug('Case Entitlement:'+cL.entitlementid);
            }
        }
        
        List<CaseMilestone> listOfCaseMilestones=CaseMilestoneSelector.getCaseMilestonesByCaseIds(new Set<Id>(caseIds));
        System.debug('listOfCaseMilestones'+listOfCaseMilestones);
        CaseMilestoneService.updateMilestoneUtility(listOfCaseMilestones);
        UtilityClass.getSObjectNameById(caseIds[0]);
        UtilityClass.getSObjectRecordById(new Set<Id>(caseIds));
        new AccountSelector().getAccount('Test Account');
    }
    
    @isTest
    private static void statusSynconOutboundEmails(){
        case inst= new case();
        // inst.AccountId=contactInstance.AccountId;
        // inst.ContactId=contactInstance.Id;
        inst.Priority='P1';
        inst.Status='';
        inst.SuppliedName='Test';
        inst.Subject='test Case';
        inst.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.B2B_CA_SME).getRecordTypeId();
        insert inst;
        
        Issue_Type__c issueType=new Issue_Type__c();
        issueType.Issue_Type__c='test';
        issueType.Issue_Type_1__c='test';
        issueType.Issue_Type_2__c='test';
        issueType.Issue_Type_3__c='test';
        issueType.Issue_Type_4__c='test';
        issueType.Case_Type__c='B2B';
        insert issueType;
        
        list<EmailMessage> listOfEmailMsg= new list<EmailMessage>();
        EmailMessage emailMessageInstance1=new EmailMessage(
            Subject                 = 'test14'
            ,ToAddress              = 'heim@elastify.eu'
            ,FromAddress            = 'test@gmail.com'
            ,FromName               = 'Test'
            ,HtmlBody               = '<HTML>a body</HTML>'
            ,Incoming               = false
            ,MessageDate            = DateTime.now()
            ,TextBody				='TextBody'
            ,Status__c				= 'Pending'
            ,sub_Status__c		    = CaseConstants.SUB_STATUS_WITH_CUSTOMER_FOR_PRO_CLAR
            ,Issue_Type__c			= issueType.Id
            ,ParentId				= inst.Id);  
        listOfEmailMsg.add(emailMessageInstance1);  
        insert listOfEmailMsg;
        
        //System.assertEquals('Open', inst.Status);
    }
    
    @isTest
    private static void statusSynconOutboundEmails1(){
        case inst= new case();
        // inst.AccountId=contactInstance.AccountId;
        // inst.ContactId=contactInstance.Id;
        inst.Priority='P1';
        inst.Status='';
        inst.SuppliedName='Test';
        inst.Subject='test Case';
        inst.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.Case_RECORDTYPENAME_E_INVOICING).getRecordTypeId();
        insert inst;
        
        Issue_Type__c issueType=new Issue_Type__c();
        issueType.Issue_Type__c='test';
        issueType.Issue_Type_1__c='test';
        issueType.Issue_Type_2__c='test';
        issueType.Issue_Type_3__c='test';
        issueType.Issue_Type_4__c='test';
        issueType.Case_Type__c='EInv';
        insert issueType;
        
        list<EmailMessage> listOfEmailMsg= new list<EmailMessage>();
        EmailMessage emailMessageInstance1=new EmailMessage(
            Subject                 = 'test14'
            ,ToAddress              = 'heim@elastify.eu'
            ,FromAddress            = 'test@gmail.com'
            ,FromName               = 'Test'
            ,HtmlBody               = '<HTML>a body</HTML>'
            ,Incoming               = false
            ,MessageDate            = DateTime.now()
            ,TextBody				='TextBody'
            ,Status__c				= 'Pending'
            ,sub_Status__c		    = 'With Customer'
            ,Issue_Type__c			= issueType.Id
            ,ParentId				= inst.Id);  
        listOfEmailMsg.add(emailMessageInstance1);  
        insert listOfEmailMsg;
        
        //System.assertEquals('Open', inst.Status);
    }
    
    @isTest
    private static void statusSynconOutboundEmails2(){
        case inst= new case();
        // inst.AccountId=contactInstance.AccountId;
        // inst.ContactId=contactInstance.Id;
        inst.Priority='P1';
        inst.Status='';
        inst.SuppliedName='Test';
        inst.Subject='test Case';
        inst.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.B2C).getRecordTypeId();
        insert inst;
        
        Issue_Type__c issueType=new Issue_Type__c();
        issueType.Issue_Type__c='test';
        issueType.Issue_Type_1__c='test';
        issueType.Issue_Type_2__c='test';
        issueType.Issue_Type_3__c='test';
        issueType.Issue_Type_4__c='test';
        issueType.Case_Type__c='B2C';
        insert issueType;
        Issue_Type__c issueType1=new Issue_Type__c();
        issueType1.Issue_Type__c='test';
        issueType1.Issue_Type_1__c='test';
        issueType1.Issue_Type_2__c='test';
        issueType1.Issue_Type_3__c='test';
        issueType1.Issue_Type_4__c='test';
        issueType1.Case_Type__c='EInv';
        insert issueType1;
        list<EmailMessage> listOfEmailMsg= new list<EmailMessage>();
        EmailMessage emailMessageInstance1=new EmailMessage(
            Subject                 = 'test14'
            ,ToAddress              = 'heim@elastify.eu'
            ,FromAddress            = 'test@gmail.com'
            ,FromName               = 'Test'
            ,HtmlBody               = '<HTML>a body</HTML>'
            ,Incoming               = false
            ,MessageDate            = DateTime.now()
            ,TextBody				='TextBody'
            ,Status__c				= 'Pending'
            ,sub_Status__c		    = 'With Customer'
            ,Issue_Type__c			= issueType.Id
            ,ParentId				= inst.Id);  
        listOfEmailMsg.add(emailMessageInstance1);  
        insert listOfEmailMsg;

        //System.assertEquals('Open', inst.Status);
    }
    
    public static Testmethod void testSpamCases(){
        UtilityClass.dummy();
        test.startTest();
        Account accountInstance=new Account();
        accountInstance.name='test1';
        insert accountInstance; 
        
        Contact contactInstance= new Contact(LastName='TestAccount1' ,FirstName='TestAccount1',Phone='900000000',Email='test1@cleartax.com',AccountId=accountInstance.Id);
        insert contactInstance;
        
        Service_Admin_Configuration__c sac = new Service_Admin_Configuration__c();
        sac.Spam_Email__c = 'test@gmail.com';
        sac.RecordTypeId = Constants.sacSpamRTId;
        insert sac;
        
        Case inst= new Case();
        inst.AccountId=contactInstance.AccountId;
        inst.ContactId=contactInstance.Id;
        inst.Priority='P1';
        inst.Status='New';
        inst.SuppliedName='Test';
        inst.Subject='Test Case 112121';
        
        insert inst;
        system.debug('iinst.id'+inst.id);
        inst.Status='Closed';
        update inst;
        
        Constants.stopCaseTrigger = true;
        
        EmailMessage emailMessageInstance = new EmailMessage(
            Subject                = 'test14'
            ,Status                 = '3'
            ,ToAddress              = 'heim@elastify.eu'
            ,FromAddress            = 'test@gmail.com'
            ,FromName               = 'Test'
            ,HtmlBody               = 'a body'
            ,Incoming               = true
            ,MessageDate            = DateTime.now()
            ,TextBody				='Test 123'
            ,ParentId				= inst.Id); 
        
        insert emailMessageInstance;
       test.stopTest();
    }
}