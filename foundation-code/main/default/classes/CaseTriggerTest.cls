/**
* @File Name          : CaseTriggerTest.cls
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : Lokesh@SFDeveloper.SFDoc
* @Last Modified On   : 27/5/2020, 10:55:31 am
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    27/5/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
@isTest
private class CaseTriggerTest {
    
    
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @return void 
**/
    @testSetup
    private static void testSetupMethod(){
        List<Entitlement> listOfEntitlements=TestDataFactory.createEntitlement(true,false);
        
        List<Case> listOfCases=TestDataFactory.createCasesWithAccountAndContact(7,false,false);
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
        insert listOfCases;
        Test.stopTest();
        List<Case> listupdatedCases=new List<Case>();
        for(Case instance:listOfCases){
            instance.Priority='P0';
            instance.Status='Pending';
            instance.Sub_Status__c = CaseConstants.SUB_STATUS_WITH_CUSTOMER_FOR_PRO_CLAR;
            instance.Is_Customer_Unblocked__c=true;
            listupdatedCases.add(instance);
        }
        
        new CaseService().upsertCases(listupdatedCases,'');
        
        //mixDmlAvoidTeamRole();
        
        List<Case> listOfCasesToDelete=new List<Case>();
        listOfCasesToDelete.add(listupdatedCases[0]);
        listOfCasesToDelete.add(listupdatedCases[1]);
        
        new CaseService().deleteCases(listOfCasesToDelete, '');
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        /*User testUser = new User(Alias = 'standt', Email='standarduser@WDtestorg1.com', 
EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = p.Id, 
TimeZoneSidKey='Asia/Kolkata', UserName='standarduser2121@WDtestorg.com',User_Role_Type__c='GST Dev on Call team');
insert testUser;*/
        User testUser2 = new User(Alias = 'standt', Email='standarduser2@WDtestorg1.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                  isActive=true,
                                  TimeZoneSidKey='Asia/Kolkata', UserName='standarduser21@WDtestorg.com',User_Role_Type__c='GST L2 Support team');
        insert testUser2;
        avoidMixedDMLGroupMember();
    } 
    
    @future
    public static void mixDmlAvoidTeamRole(){
        List<CaseTeamRole> listOfCaseTeamRoles=new List<CaseTeamRole>();
        CaseTeamRole caseTeamRoleInstance=new CaseTeamRole();
        caseTeamRoleInstance.Name='Enterprice Support';
        caseTeamRoleInstance.AccessLevel='Edit';
        listOfCaseTeamRoles.add(caseTeamRoleInstance);
        CaseTeamRole caseTeamRoleInstance1=new CaseTeamRole();
        caseTeamRoleInstance1.Name='Consumer Support';
        caseTeamRoleInstance.AccessLevel='Edit';
        listOfCaseTeamRoles.add(caseTeamRoleInstance1);
        insert listOfCaseTeamRoles;
    }
    
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @return void 
**/
    @isTest private static void testCaseMethod1(){
        List<Case> listOfLowPriorityCases=new List<Case>();
        listOfLowPriorityCases=[SELECT Id,CaseNumber,Priority,Status FROM Case Where Priority='P2'];
        if(listOfLowPriorityCases.size()>0)
            for(Case caseInstance:listOfLowPriorityCases){
                caseInstance.Priority='P2';
                caseInstance.Status='Pending';
                caseInstance.Sub_Status__c='With Customer';
            }
        
        Test.startTest();
        if(listOfLowPriorityCases.size()>0)
            update listOfLowPriorityCases;
        Test.stopTest();
    }
    
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @return void 
**/
    @isTest private static void testCaseMethod2(){
        /*List<Case> listOfLowPriorityCases=new List<Case>();
listOfLowPriorityCases=[SELECT Id,CaseNumber,Priority,Status,sub_Status__c FROM Case Where Priority='P0'];

if(listOfLowPriorityCases.size()>0){
for(Case caseInstance:listOfLowPriorityCases){
caseInstance.Priority='P2';
caseInstance.Status='Closed'; 
caseInstance.Sub_Status__c='';
}
}

Test.startTest();
if(listOfLowPriorityCases.size()>0)
try{
update listOfLowPriorityCases;
}catch(Exception e){
System.debug('Error Message '+e.getMessage());
}
Test.stopTest();*/
    }
    
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @return void 
**/
    /*
@isTest private static void testCaseMethod3(){
List<Case> listOfLowPriorityCases=new List<Case>();
listOfLowPriorityCases=[SELECT Id,CaseNumber,Priority,Status FROM Case Where Priority='P1'];
if(listOfLowPriorityCases.size()>0){
for(Case caseInstance:listOfLowPriorityCases){
caseInstance.Priority='P2';
caseInstance.Status='On hold';
}
}

Test.startTest();
if(listOfLowPriorityCases.size()>0){
update listOfLowPriorityCases;
}
Test.stopTest();
}
*/
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @return void 
**/
    @isTest private static void testCaseMethod4(){
        List<Case> listOfLowPriorityCases=new List<Case>();
        listOfLowPriorityCases=[SELECT Id,CaseNumber,Priority,Status FROM Case Where Priority='Urgent'];
        if(listOfLowPriorityCases.size()>0)
            for(Case caseInstance:listOfLowPriorityCases){
                caseInstance.Priority='P2';
                caseInstance.Status='Open';
            }
        Test.startTest();
        if(listOfLowPriorityCases.size()>0)
            update listOfLowPriorityCases;
        Test.stopTest();
    }
    
    public static TestMethod void einvoicetest(){
        List<Case> listOfCases=TestDataFactory.createCasesWithAccountAndContact(1,false,false);
        listOfCases[0].RecordTypeId = Constants.eInvoicingRTId;
        listOfCases[0].Customer_Segment__c = 'E Invoicing';
        insert listOfCases;
        //CaseTriggerHelper.futureHandleOnClose(new Set<Id>{listOfCases[0].Id});
        CaseTriggerHelper.updateCaseStatusToReopenFromTransferOnQueueToUser(listOfCases);
        CaseTriggerHelper.updateCustomWebFormRTypesByCustomerSegment(listOfCases);
        //CaseTriggerHelper.futureCompleteTheMilestonAllMilestonsOnClose(Json.serialize(listOfCases));
    }
    
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @return void 
**/
    @isTest private static void testCaseMethod5(){
        List<Case> listOfLowPriorityCases=new List<Case>();
        listOfLowPriorityCases=[SELECT Id,CaseNumber,Priority,Status FROM Case Where Priority='Low'];
        if(listOfLowPriorityCases.size()>0)
            for(Case caseInstance:listOfLowPriorityCases){
                caseInstance.Priority='P0';
                caseInstance.Status='Closed';
            }
        
        Test.startTest();
        if(listOfLowPriorityCases.size()>0)
            
            update listOfLowPriorityCases;
        Test.stopTest();
        
    }
    
    
    
    
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @return void 
**/
    @isTest 
    public static void testCaseMethod7(){
        
        Account accountInstance=new Account(Name=CaseConstants.GLOBAL_B2C);
        Contact contactInstance=new Contact();
        contactInstance.Email='testAccountCreation@gmail.com';
        contactInstance.LastName='testAccountCreati';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
        insert contactInstance;
        List<Case> listOfCases=new List<Case>();
        Case caseInstance=new Case();
        caseInstance.SuppliedEmail='testAccountCreation@gmail.com';
        caseInstance.SuppliedCompany='testAccountCreation';
        caseInstance.SuppliedName='testAccountCreati';
        caseInstance.SuppliedPhone='9111111111';
        caseInstance.ContactId=contactInstance.Id;
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        listOfCases.add(caseInstance);
        insert listOfCases;
        CaseSelector.getCaseByContactIds(new Set<Id>{contactInstance.Id});
        new ContactSelector().getContactById(new Set<Id>{contactInstance.Id});
        CaseSelector.getCaseByEmails(new Set<String>{listOfCases[0].SuppliedEmail});
        Test.stopTest();
        
        
    }
    
    
    
    @isTest
    public static void updateOwnerIds(){
        
        Case caseInstance=new Case();
        caseInstance.Status='New';
        caseInstance.Origin='Email';
        caseInstance.Type='Problem';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        caseInstance.SuppliedEmail='test@gmail.com';
        caseInstance.SuppliedName='testEmail';
        List<User> userInstance=[SELECT id,Name,Email from User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name='System Administrator') AND  isActive=true limit 2];
        System.runAs(userInstance[0]){
            Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
            Test.startTest();
            List<Case> listOfCases=new List<Case>();
            listOfCases.add(caseInstance);
            new CaseService().insertCases(listOfCases,'');
            listOfCases[0].Status='Open';
            listOfCases[0].OwnerId=userInstance[0].Id;
            update caseInstance;
            Test.stopTest();
            
        }
    }
    
    
    @isTest
    public static void updateStatusToSolved(){
        
        Case caseInstance=new Case();
        caseInstance.Status='New';
        caseInstance.Origin='Email';
        caseInstance.Type='Problem';
        caseInstance.SuppliedEmail='test@gmail.com';
        caseInstance.SuppliedName='testEmail';
        caseInstance.Survey_send__c=1;
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
        Test.stopTest();
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        List<Case> listOfCases=new List<Case>();
        listOfCases.add(caseInstance);
        new CaseService().insertCases(listOfCases,'');
        caseInstance.Status='Solved';
        caseInstance.Is_Customer_Unblocked__c=true;
        DataBase.update(caseInstance,false);
        //CaseService.updateCaseToReopenFromSolved(new Set<Id>{caseInstance.Id});
    }
    
    @isTest
    public static void updateTypeToProblemAndStatusToClose(){
        Account acc = new account(name='Test Account');
        insert acc;
        
        Contact oContact = new contact(firstname='John',lastname='Doe',email='test@test.com',accountid=acc.id);
        insert oContact;
        
        Entitlement entl = new entitlement(name='ENT Einv support - P0',accountid=acc.id,type='Gateway Support', StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        List<SLAProcess> listOfSLAProcesses=[SELECT SobjectType, Name, Id, IsActive, VersionNumber FROM SlaProcess WHERE Name Like '%ENT Einv%'  and IsActive = true  limit 1];
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
        Case caseInstance=new Case();
        caseInstance.Status='New';
        caseInstance.Origin='Email';
        caseInstance.Type='Problem';
        caseInstance.SuppliedEmail='test@gmail.com';
        caseInstance.SuppliedName='testEmail';
        caseInstance.Survey_send__c=1;
        caseInstance.ContactId=contactId;
        caseInstance.AccountId=acc.id;
        caseInstance.EntitlementId=entlId;
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
        Test.stopTest();
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        List<Case> listOfCases=new List<Case>();
        listOfCases.add(caseInstance);
        new CaseService().insertCases(listOfCases,'');
        caseInstance.Status='Closed';
        caseInstance.First_Reply_Sent__c=true;
        update caseInstance;
        Map<String, list<case>> mapOfAccIdToCaseId =new Map<String, list<case>>();
        mapOfAccIdToCaseId.put(acc.id,new list<case>{caseInstance});
    }
    
    @isTest
    public static void updateOwner1Ids(){
        
        Case caseInstance=new Case();
        caseInstance.Status='New';
        caseInstance.Origin='Email';
        caseInstance.Type='Problem';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        caseInstance.SuppliedEmail='test@gmail.com';
        caseInstance.SuppliedName='testEmail';
        List<User> userInstance=[SELECT id,Name,Email from User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name='System Administrator')AND isActive=true  limit 2];
        
        caseInstance.OwnerId=userInstance[0].Id;
        System.runAs(userInstance[0]){
            Test.startTest();
            Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
            Test.stopTest();
            List<Case> listOfCases=new List<Case>();
            listOfCases.add(caseInstance);
            new CaseService().insertCases(listOfCases,'');
            listOfCases[0].Status='Open';
            listOfCases[0].OwnerId=userInstance[1].Id;
            listofCases[0].First_Reply_Sent__c=true;
            update caseInstance;
        }
    }
    
    @istest
    public static void testMethodupdateCaseToOpenFromPending(){
        try{
            Account acc = new account(name='Test Account',Company_Domain_Name__c='gmail.com');
            insert acc;
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User usr = new User(Alias = 'standt', Email='sunil@WDtestorg2.com', 
                                EmailEncodingKey='UTF-8', LastName='Sunil', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                isActive=true,TimeZoneSidKey='Asia/Kolkata', UserName='sunil@WDtestorg2.com',
                                User_Role_Type__c='GST L2 Support team', Support_Departments__c='ENT E Invoice L1 Team');
            insert usr;
            Case caseInstance=new Case();
            caseInstance.Status='Pending';
            caseInstance.Origin='Email';
            caseInstance.Type='Problem';
            caseInstance.Functional_Area__c='Data Preparation';
            caseInstance.POD_Group__c='Galactus';
            caseInstance.SuppliedEmail='test@gmail.com';
            caseInstance.SuppliedName='testEmail';
            caseInstance.User_Role_Type__c='ENT E Invoice L1 Team';//	Sunil K M
            caseInstance.OwnerId=usr.id;
            caseInstance.Google_Form_Attachments_URL__c='htt://yha,http://kjjd,http://kjkad';
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockUtility());
            insert caseInstance;
            CaseService.updateCaseToOpenFromPending(new Set<Id>{caseInstance.Id});
            test.stopTest();
        }
        catch(Exception e){
            
        }
    }
    
    @istest
    public static void testAccountMapping(){
        try{
            Account acc = new account(name='Test Account',Company_Domain_Name__c='gmail.com');
            insert acc;
            Account acc2 = new account(name='Test Account',Company_Domain_Name__c='gmail.com', Big_Logo__c = 'Yes');
            insert acc2;
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User usr = new User(Alias = 'standt', Email='sunil@WDtestorg2.com', 
                                EmailEncodingKey='UTF-8', LastName='Sunil', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                isActive=true,TimeZoneSidKey='Asia/Kolkata', UserName='sunil@WDtestorg2.com',
                                User_Role_Type__c='GST L2 Support team', Support_Departments__c='ENT E Invoice L1 Team');
            insert usr;
            Case caseInstance=new Case();
            caseInstance.Status='New';
            caseInstance.Origin='Email';
            caseInstance.Functional_Area__c='Data Preparation';
            caseInstance.POD_Group__c='Galactus';
            caseInstance.SuppliedEmail='test@gmail.com';
            caseInstance.SuppliedName='testEmail';
            caseInstance.User_Role_Type__c='ENT E Invoice L1 Team';//	Sunil K M
            caseInstance.OwnerId = usr.id;
            caseInstance.Google_Form_Attachments_URL__c='htt://yha,http://kjjd,http://kjkad';
            
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestMockUtility());
            insert caseInstance;
            
            caseInstance.AccountId = acc2.Id;
            update caseInstance;
            test.stopTest();
        }
        catch(Exception e){
            
        }
    }
    
    
    
    /**
* The milestone completion trigger is invoked after case update
*/
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
    
    @future
    public static void avoidMixedDMLGroupMember(){
        Id userId=[SELECT id,Name from User WHERE UserName='standarduser21@WDtestorg.com'].Id;
        Group testGroup = new Group(Name='GST L2 Support Team', Type='Queue');
        insert testGroup;
        GroupMember grpMember=new GroupMember();
        grpMember.GroupId=testGroup.Id;
        grpMember.UserOrGroupId=userId;
        insert grpMember;
    }
    
    @istest
    public static void testMethodCaseRoundRobinAssignment(){
        
        Cleartax_Org_Configuration__c Cleartax_Org_Configuration=new Cleartax_Org_Configuration__c();
        Cleartax_Org_Configuration.Enable_Round_Robin_On_Case__c=true;
        insert Cleartax_Org_Configuration;
        Id GroupId =[SELECT id,Name from Group WHere type='Queue' And Name='GST L2 Support Team' limit 1].Id;
        RoundRobinAssing__c roundRobinInstance=new RoundRobinAssing__c();
        roundRobinInstance.Queue_Id__c=GroupId;
        roundRobinInstance.Name='GST L2 Support Team';
        roundRobinInstance.Sobject_Name__c='Case';
        insert roundRobinInstance;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = GroupId, SObjectType = 'Case');
            insert testQueue;
        }
        
        
        Case caseInstance=new Case();
        caseInstance.Status='Pending';
        caseInstance.Origin='Email';
        caseInstance.Type='Problem';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        caseInstance.SuppliedEmail='test@gmail.com';
        caseInstance.SuppliedName='testEmail';
        caseInstance.OwnerId = GroupId;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockUtility());
        insert caseInstance;
        CaseService.updateCaseToOpenFromPending(new Set<Id>{caseInstance.Id});
        test.stopTest();
        
    }
    
    @isTest
    public static void IssueTypeTagging(){
        
        
        Issue_Type__c ins=new Issue_Type__c();
        ins.Issue_Type__c='test';
        ins.Issue_Type_1__c='test1';
        ins.Issue_Type_2__c='test2';
        ins.Issue_Type_3__c='test3';
        ins.Issue_Type_4__c='test4';
        ins.Case_Type__c='B2B';
        
        Issue_Type__c ins1=new Issue_Type__c();
        ins1.Issue_Type__c='test';
        ins1.Issue_Type_1__c='test1';
        ins1.Issue_Type_2__c='test2';
        ins1.Issue_Type_3__c='test3';
        ins1.Issue_Type_4__c='test4';
        ins1.Case_Type__c='B2C';
        
        /*B2B - CA/SME
B2C - Consumer ITR
B2C - Consumer Invest
B2C - Tax Cloud
B2C - TDS
B2C - Marketplace
B2B - Enterprise*/
        insert new List<Issue_Type__c>{ins,ins1};
            
            Case caseInstance=new Case();
        caseInstance.Status='New';
        caseInstance.Origin='Email';
        caseInstance.Type='Problem';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        caseInstance.SuppliedEmail='test@gmail.com';
        caseInstance.SuppliedName='testEmail';
        caseInstance.OwnerId = userinfo.getUserId();
        caseInstance.Lookup_Issue_Type__c=ins.id;
        //caseInstance.Case_Type__c='B2B';
        
        Case caseInstance1=new Case();
        caseInstance1.Status='New';
        caseInstance1.Origin='Email';
        caseInstance1.Type='Problem';
        caseInstance1.Functional_Area__c='Data Preparation';
        caseInstance1.POD_Group__c='Galactus';
        caseInstance1.SuppliedEmail='test@gmail.com';
        caseInstance1.SuppliedName='testEmail';
        caseInstance1.OwnerId = userinfo.getUserId();
        caseInstance1.Lookup_Issue_Type1__c=ins1.id;
        //caseInstance.Case_Type__c='B2C';
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockUtility());
        insert new List<Case>{caseInstance,caseInstance1};
            
            }
    
    
    @isTest
    public static void testMethodToGlobalB2C_Cases(){
        Case caseInstance=new Case();
        caseInstance.Status='New';
        caseInstance.Origin='Email';
        caseInstance.Type='Problem';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        caseInstance.SuppliedEmail='test@gmail.com';
        caseInstance.SuppliedName='testEmail';
        CaseInstance.Email_Source__c=CaseConstants.B2C_Support_EMAil;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockUtility());
        insert caseInstance;
        CaseInstance.Email_Source__c=CaseConstants.B2C_Invest_EMAIL;
        update caseInstance;
        test.stopTest();
    }
    
    
    @isTest
    public static void testMethodTogstProductCasesUpdate(){
        Account a=new Account(Name='global B2B CA/SME');
        insert a;
        Contact cn=new Contact();
        cn.Email='test@gmail.com';
        cn.AccountId=a.id;
        cn.LastName='test';
        insert cn;
        
        Case caseInstance=new Case();
        caseInstance.Status='New';
        caseInstance.Origin='Web';
        caseInstance.ContactId=cn.id;
        caseInstance.AccountId=a.Id;
        caseInstance.Case_Sub_Origin__c='GST Product Form';
        caseInstance.Type='Problem';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        caseInstance.SuppliedEmail='test@gmail.com';
        caseInstance.SuppliedName='testEmail';
        CaseInstance.Email_Source__c=CaseConstants.B2C_Support_EMAil;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockUtility());
        insert caseInstance;
        test.stopTest();
    }
    
    @isTest
    public static void testMethodTogstProductCasesUpdate2(){
        
        Case caseInstance=new Case();
        caseInstance.Status='New';
        caseInstance.Origin='Web';
        caseInstance.Case_Sub_Origin__c='GST Product Form';
        caseInstance.Type='Problem';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        caseInstance.SuppliedEmail='test@gmail.com';
        caseInstance.SuppliedName='testEmail';
        CaseInstance.Email_Source__c=CaseConstants.B2C_Support_EMAil;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockUtility());
        //   insert caseInstance;
        test.stopTest();
    }
    
    @isTest
    public static void testMethodToupdateCaseMilestoCompleteOnOwnerChange(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        /*User testUser = new User(Alias = 'standt', Email='standarduser@WDtestorg1.com', 
EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = p.Id, 
TimeZoneSidKey='Asia/Kolkata', UserName='standarduser2121@WDtestorg.com',User_Role_Type__c='GST Dev on Call team');
insert testUser;*/
        User testUser2 = new User(Alias = 'standt', Email='standarduser1t2@WDtestorg1.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                  isActive=true,
                                  TimeZoneSidKey='Asia/Kolkata', UserName='standarduser1t2@WDtestorg.com',User_Role_Type__c='GST L2 Support team');
        insert testUser2;
        testUser2.User_Role_Type__c='ENT E Invoice L1 Team';
        update testUser2;
        Case caseInstance=new Case();
        caseInstance.Status='New';
        caseInstance.Origin='Web';
        caseInstance.Case_Sub_Origin__c='GST Product Form';
        caseInstance.Type='Problem';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        caseInstance.SuppliedEmail='test@gmail.com';
        caseInstance.SuppliedName='testEmail';
        CaseInstance.Email_Source__c='EInvoicing@cleartax.in';
        CaseInstance.Customer_Type__c=null;
        CaseInstance.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('E Invoicing').getRecordTypeId();
        CaseInstance.OwnerId=UserInfo.getUserId();
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockUtility());
        // insert caseInstance;
        caseInstance.OwnerId= testUser2.Id;
        //   update caseInstance;
        // CaseTriggerHelper.updateCaseMilestoCompleteOnOwnerChange(new List<Case>{caseInstance});
        test.stopTest();
    }
    
    
    @isTest
    public static void testMethodToupdateSolved(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        /*User testUser = new User(Alias = 'standt', Email='standarduser@WDtestorg1.com', 
EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', ProfileId = p.Id, 
TimeZoneSidKey='Asia/Kolkata', UserName='standarduser2121@WDtestorg.com',User_Role_Type__c='GST Dev on Call team');
insert testUser;*/
        User testUser2 = new User(Alias = 'standt', Email='standarduser1t2@WDtestorg1.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                  isActive=true,
                                  TimeZoneSidKey='Asia/Kolkata', UserName='standarduser1t2@WDtestorg.com',User_Role_Type__c='GST L2 Support team');
        insert testUser2;
        testUser2.User_Role_Type__c='ENT E Invoice L1 Team';
        update testUser2;
        Case caseInstance=new Case();
        caseInstance.Status='New';
        caseInstance.Origin='Web';
        caseInstance.Case_Sub_Origin__c='GST Product Form';
        caseInstance.Type='Problem';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        caseInstance.SuppliedEmail='test@gmail.com';
        caseInstance.SuppliedName='testEmail';
        CaseInstance.Email_Source__c='EInvoicing@cleartax.in';
        CaseInstance.Customer_Type__c=null;
        CaseInstance.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('E Invoicing').getRecordTypeId();
        CaseInstance.OwnerId=UserInfo.getUserId();
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockUtility());
        //insert caseInstance;
        caseInstance.OwnerId= testUser2.Id;
        caseInstance.Status= 'Solved';
        //update caseInstance;
        DateTime dateTimepast4days = System.now()-4;
        caseInstance.Case_Solved_DataTime__c= dateTimepast4days;
        // update caseInstance;
        //  CaseTriggerHelper.updateCaseMilestoCompleteOnOwnerChange(new List<Case>{caseInstance});
        test.stopTest();
        
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
            ,ParentId				= caseInstance.Id);  
        insert emailMessageInstance1;
    }
    
    public static Testmethod void testRTAndEntitlementUpdate(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        List<user> userList = new List<User>();
        User usr1 = new User(Alias = 'standt', Email='sysadm@WDtestorg1.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, 
                             TimeZoneSidKey='Asia/Kolkata', UserName='sysadm123@WDtestorg1.com',
                             User_Role_Type__c = 'L1 Support - CT');
        
        userList.add(usr1);
        insert userList;
        
        Account a=new Account(Name='Entitlement');
        insert a;
        
        Entitlement ent = new Entitlement(Name='B2C Entitlement SLA On P0',AccountId=a.id,StartDate=System.today());
        insert ent;
        
        Service_Admin_Configuration__c sac = TestDataFactory.createSAdminConfigForEntitlement(ent);
        insert sac;
        
        Case cs1 = TestDataFactory.createCasesWithAccountAndContact(1, true, false)[0];
        cs1.ownerId = usr1.Id;
        update cs1;
        
        Case csRes1 = [Select Id, RecordTypeId, EntitlementId From Case Where Id =: cs1.Id];
        // system.assertEquals(Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2C').getRecordTypeId(), csRes1.RecordTypeId);
        //system.assertEquals(ent.Id, csRes1.EntitlementId);
        
        String queueId = [Select Id, Name From Group Where Type = 'Queue' AND DeveloperName = 'GST_L1_Email_Support_Team'].Id;
        Case cs2 = TestDataFactory.createCasesWithAccountAndContact(1, true, false)[0];
        cs2.User_Role_Type__c = 'GST L1 Email Support Team';
        cs2.ownerId = queueId;
        update cs2;
        
        Case csRes2 = [Select Id, RecordTypeId From Case Where Id =: cs2.Id];
        system.assertEquals(Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B CA/SME').getRecordTypeId(), csRes2.RecordTypeId);
    }
    
}