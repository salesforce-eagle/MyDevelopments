/**
* @File Name          : TestDataFactory.cls
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : Lokesh@SFDeveloper.SFDoc
* @Last Modified On   : 27/5/2020, 12:37:31 pm
* @Modification Log   : 
* Ver       Date            Author              Modification
* 1.0    27/5/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
@isTest
public class TestDataFactory {
    
    
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @return List<Admin_Configuration__c> 
**/
    public static List<Admin_Configuration__c> createAdminConfiguration(){
        
        Set<String> IndustryReduce = new Set<String>();
        List<Admin_Configuration__c> listAdminConfigurations=new List<Admin_Configuration__c>();
        //listAdminConfigurations=Test.loadData(Admin_Configuration__c.sobjectType, 'Admin_Configuration_TestData');
        Admin_Configuration__c adminConfigurationRecord1=new Admin_Configuration__c(Parameter_Value__c='Advertising, Media & Entertainment',Parameter_Type__c='Industry',Ls_value__c=9.9,Ps_Value__c=9.4);
        listAdminConfigurations.add(adminConfigurationRecord1);
        Admin_Configuration__c adminConfigurationRecord2=new Admin_Configuration__c(Parameter_value__c='Hospitals & Healthcare',Parameter_Type__c='Industry',Ls_value__c=8.31,Ps_Value__c=8.3);
        listAdminConfigurations.add(adminConfigurationRecord2);
        Admin_Configuration__c adminConfigurationRecord3=new Admin_Configuration__c(Parameter_value__c='Information Technology (IT)',Parameter_Type__c='Industry',Ls_value__c=8.58,Ps_Value__c=8.3);
        listAdminConfigurations.add(adminConfigurationRecord3);
        Admin_Configuration__c adminConfigurationRecord4=new Admin_Configuration__c(Parameter_value__c='Logistics & Transport',Parameter_Type__c='Industry',Ls_value__c=7.53,Ps_Value__c=8.5);
        listAdminConfigurations.add(adminConfigurationRecord4);
        Admin_Configuration__c adminConfigurationRecord5=new Admin_Configuration__c(Parameter_value__c='Manufacturing',Parameter_Type__c='Industry',Ls_value__c=9.2,Ps_Value__c=7.6);
        listAdminConfigurations.add(adminConfigurationRecord5);
        Admin_Configuration__c adminConfigurationRecord6=new Admin_Configuration__c(Parameter_value__c='Pharmaceuticals',Parameter_Type__c='Industry',Ls_value__c=6.05,Ps_Value__c=7.8);
        listAdminConfigurations.add(adminConfigurationRecord6);
        Admin_Configuration__c adminConfigurationRecord7=new Admin_Configuration__c(Parameter_value__c='Retail & Wholesale',Parameter_Type__c='Industry',Ls_value__c=7.59,Ps_Value__c=8.1);
        listAdminConfigurations.add(adminConfigurationRecord7);
        Admin_Configuration__c adminConfigurationRecord8=new Admin_Configuration__c(Parameter_value__c='Services',Parameter_Type__c='Industry',Ls_value__c=6.46,Ps_Value__c=7.4);
        listAdminConfigurations.add(adminConfigurationRecord8);
        Admin_Configuration__c adminConfigurationRecord9=new Admin_Configuration__c(Parameter_value__c='Telecommunication',Parameter_Type__c='Industry',Ls_value__c=5.63,Ps_Value__c=9.8);
        listAdminConfigurations.add(adminConfigurationRecord9);
        
        for(Admin_Configuration__c tempAdmin : listAdminConfigurations){
            IndustryReduce.add(tempAdmin.Parameter_value__c);
        }
        
        Admin_Configuration__c adminConfigurationRecordTurnover1=new Admin_Configuration__c(Parameter_Value__c='5001+ Cr',Parameter_Type__c='Turnover',Ls_value__c=10,Ps_Value__c=10);
        listAdminConfigurations.add(adminConfigurationRecordTurnover1);
        Admin_Configuration__c adminConfigurationRecordTurnover2=new Admin_Configuration__c(Parameter_value__c='0-50 Cr',Parameter_Type__c='Turnover',Ls_value__c=6.2,Ps_Value__c=1.43);
        listAdminConfigurations.add(adminConfigurationRecordTurnover2);
        Admin_Configuration__c adminConfigurationRecordTurnover3=new Admin_Configuration__c(Parameter_value__c='101-200 Cr',Parameter_Type__c='Turnover',Ls_value__c=6.68,Ps_Value__c=4.29);
        listAdminConfigurations.add(adminConfigurationRecordTurnover3);
        Admin_Configuration__c adminConfigurationRecordTurnover4=new Admin_Configuration__c(Parameter_value__c='501-1000 Cr',Parameter_Type__c='Turnover',Ls_value__c=8.54,Ps_Value__c=7.14);
        listAdminConfigurations.add(adminConfigurationRecordTurnover4);
        Admin_Configuration__c adminConfigurationRecordTurnover5=new Admin_Configuration__c(Parameter_value__c='51-100 Cr',Parameter_Type__c='Turnover',Ls_value__c=6.23,Ps_Value__c=2.86);
        listAdminConfigurations.add(adminConfigurationRecordTurnover5);
        Admin_Configuration__c adminConfigurationRecordTurnover6=new Admin_Configuration__c(Parameter_value__c='201-500 Cr',Parameter_Type__c='Turnover',Ls_value__c=9.03,Ps_Value__c=5.71);
        listAdminConfigurations.add(adminConfigurationRecordTurnover6);
        Admin_Configuration__c adminConfigurationRecordTurnover7=new Admin_Configuration__c(Parameter_value__c='1001-2500 Cr',Parameter_Type__c='Turnover',Ls_value__c=7.45,Ps_Value__c=8.57);
        listAdminConfigurations.add(adminConfigurationRecordTurnover7);
        
        
        Admin_Configuration__c adminConfigurationRecordGSTIN1=new Admin_Configuration__c(Parameter_Value__c='2-4 GSTINs',Parameter_Type__c='GSTIN',Ls_value__c=3.33,Ps_Value__c=3.33);
        listAdminConfigurations.add(adminConfigurationRecordGSTIN1);
        Admin_Configuration__c adminConfigurationRecordGSTIN2=new Admin_Configuration__c(Parameter_value__c='5-10 GSTINs',Parameter_Type__c='GSTIN',Ls_value__c=5.0,Ps_Value__c=5.0);
        listAdminConfigurations.add(adminConfigurationRecordGSTIN2);
        Admin_Configuration__c adminConfigurationRecordGSTIN3=new Admin_Configuration__c(Parameter_value__c='11-20 GSTINs',Parameter_Type__c='GSTIN',Ls_value__c=6.67,Ps_Value__c=6.67);
        listAdminConfigurations.add(adminConfigurationRecordGSTIN3);
        Admin_Configuration__c adminConfigurationRecordGSTIN4=new Admin_Configuration__c(Parameter_value__c='1 GSTIN',Parameter_Type__c='GSTIN',Ls_value__c=1.67,Ps_Value__c=1.67);
        listAdminConfigurations.add(adminConfigurationRecordGSTIN4);
        Admin_Configuration__c adminConfigurationRecordGSTIN5=new Admin_Configuration__c(Parameter_value__c='21-50 GSTINs',Parameter_Type__c='GSTIN',Ls_value__c=8.33,Ps_Value__c=8.33);
        listAdminConfigurations.add(adminConfigurationRecordGSTIN5);
        Admin_Configuration__c adminConfigurationRecordGSTIN6=new Admin_Configuration__c(Parameter_value__c='above 50',Parameter_Type__c='GSTIN',Ls_value__c=10,Ps_Value__c=10);
        listAdminConfigurations.add(adminConfigurationRecordGSTIN6);
        
        Admin_Configuration__c adminConfigurationRecordIndustryWeight1=new Admin_Configuration__c(Parameter_Type__c='Industry',Ls_value__c=0.45,Ps_Value__c=0.20);
        listAdminConfigurations.add(adminConfigurationRecordIndustryWeight1);
        Admin_Configuration__c adminConfigurationRecordTurnoverWeight2=new Admin_Configuration__c(Parameter_Type__c='Turnover',Ls_value__c=0.25,Ps_Value__c=0.40);
        listAdminConfigurations.add(adminConfigurationRecordTurnoverWeight2);
        Admin_Configuration__c adminConfigurationRecordGSTINWeight1=new Admin_Configuration__c(Parameter_Type__c='GSTIN',Ls_value__c=0.3,Ps_Value__c=0.4);
        listAdminConfigurations.add(adminConfigurationRecordGSTINWeight1);
        
        
        Admin_Configuration__c adminConfigurationRecordBracket1=new Admin_Configuration__c(Type__c='PS Bracket',From__c=9.04,To__c=10,Value__c='Premium');
        listAdminConfigurations.add(adminConfigurationRecordBracket1);
        Admin_Configuration__c adminConfigurationRecordBracket2=new Admin_Configuration__c(Type__c='PS Bracket',From__c=6.48,To__c=9.04,Value__c='Value');
        listAdminConfigurations.add(adminConfigurationRecordBracket2);
        Admin_Configuration__c adminConfigurationRecordBracket3=new Admin_Configuration__c(Type__c='LS Bracket',From__c=7.94,To__c=10,Value__c='Hot');
        listAdminConfigurations.add(adminConfigurationRecordBracket3);
        Admin_Configuration__c adminConfigurationRecordBracket4=new Admin_Configuration__c(Type__c='LS Bracket',From__c=5.87,To__c=7.94,Value__c='Warm');
        listAdminConfigurations.add(adminConfigurationRecordBracket4);
        Admin_Configuration__c adminConfigurationRecordBracket5=new Admin_Configuration__c(Type__c='LS Bracket',From__c=0,To__c=5.87,Value__c='Cold');
        listAdminConfigurations.add(adminConfigurationRecordBracket5);
        Admin_Configuration__c adminConfigurationRecordBracket6=new Admin_Configuration__c(Type__c='PS Bracket',From__c=0,To__c=6.48,Value__c='Budget');
        listAdminConfigurations.add(adminConfigurationRecordBracket6);
        
        return listAdminConfigurations;
    }
    
    
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @param Integer noOfLeads 
* @param boolean isInsert 
* @param boolean isUpdate 
* @return List<Lead> 
**/
    public static List<Lead> createLeads(Integer noOfLeads,boolean isInsert,boolean isUpdate){
        List<Lead> listOfLeads=new List<Lead>();
        
        String objectName = 'Lead';
        String turnOver ='Turnover__c';
        String GST ='GSTIN__c';
        String Industry ='Industry';
        
        List<String> TurnOverValues = new List<String>();
        List<String> GSTINValues = new List<String>();
        List<String> IndustryValues = new List<String>();
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(turnOver).getDescribe();
        Schema.DescribeFieldResult fieldResult1 = fields.get(GST).getDescribe();
        Schema.DescribeFieldResult fieldResult2 = fields.get(Industry).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            TurnOverValues.add(pickListVal.getValue());
        } 
        for( Schema.PicklistEntry pickListVal : ple1){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            GSTINValues.add(pickListVal.getValue());
        } 
        for( Schema.PicklistEntry pickListVal : ple2){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            if(IndustryValues.size()<10)
              IndustryValues.add(pickListVal.getValue());
        } 
        
        /*integer unique=0;
        for(Integer i=0;i<noOfLeads;i++){
            for(String tempTO : TurnOverValues){
                for(String tempGST : GSTINValues){
                    for(String tempIndustry : IndustryValues){
                        listOfLeads.add(new Lead(LastName='testLead1'+unique, Company='SFDev1'+unique, Industry=tempIndustry,mobilePhone='99000'+unique,
                                                 email = 'testfactory@g.com'+unique, Turnover__c=tempTO, GSTIN__c=tempGST, PAN__c='TestFactory123'+unique));
                        unique++;
                    }
                }
            }
        }*/
        
        
        
        if(isInsert){
            insert listOfLeads;
        }else if(isUpdate){
            insert listOfLeads;
            for(Lead leadInstance:listOfLeads){
                leadInstance.Industry='Hospitality & Tourism';
                leadInstance.Turnover__c='0-50 Cr';
                leadInstance.GSTIN__c='2-4 GSTINs';
            }
            update listOfLeads;
        }
        
        
        return listOfLeads;
    }
    
    
    
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @param Integer numAccts 
* @param Integer numOppsPerAcct 
* @param boolean isInsert 
* @param boolean isUpdate 
* @return List<Account> 
**/
    public static List<Account> createAccountsWithOpps(Integer numAccts, Integer numOppsPerAcct,boolean isInsert,boolean isUpdate) {
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i, PAN__c='ABC123'+i);
            accts.add(a);
        }
        insert accts;
        
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];
            // For each account just inserted, add opportunities
            for (Integer k=0;k<numOppsPerAcct;k++) {
                opps.add(new Opportunity(Name=acct.Name + ' Opportunity ' + k,
                                         StageName='Prospecting',
                                         CloseDate=System.today().addMonths(1),
                                         AccountId=acct.Id));
            }
        }
        // Insert all opportunities for all accounts.
        insert opps;
        
        
        
        return accts;
    }
    
    
    
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @param Integer noOfCases 
* @param boolean isInsert 
* @param boolean isUpdate 
* @return List<Case> 
**/
    public static List<Case> createCasesWithAccountAndContact(Integer noOfCases,boolean isInsert,boolean isUpdate) {
        List<Account> listOfAccounts = new List<Account>();
        List<Contact> listOfContacts = new List<Contact>();
        List<Case> listofCases=new List<Case>();
        for(Integer i=0;i<noOfCases;i++) {
            Account accountInstance = new Account(Name='TestAccount' + i);
            listOfAccounts.add(accountInstance);
        }
        insert listOfAccounts;
        
        for(Integer j=0;j<listOfAccounts.size();j++){
            Contact contactInstance= new Contact(LastName='TestAccount' + j,FirstName='TestAccount' +j,Phone='900000000',Email='test@cleartax.com',AccountId=listOfAccounts[j].Id);
            listOfContacts.add(contactInstance);
        }
        insert listOfContacts;
        
        for(Integer k=0;k<noOfCases;k++){
            if(k==0){
                Case caseInstance=new Case();
                caseInstance.AccountId=listOfContacts[k].AccountId;
                caseInstance.ContactId=listOfContacts[k].Id;
                caseInstance.Priority='P0';
                caseInstance.Status='New';
                caseInstance.Functional_Area__c='Data Preparation';
                caseInstance.POD_Group__c='Galactus';
                listofCases.add(caseInstance);
            }else if(k==1){
                Case caseInstance=new Case();
                caseInstance.AccountId=listOfContacts[k].AccountId;
                caseInstance.ContactId=listOfContacts[k].Id;
                caseInstance.Priority='P0';
                caseInstance.Status='New';
                caseInstance.Functional_Area__c='Data Preparation';
                caseInstance.POD_Group__c='Galactus';
                listofCases.add(caseInstance);
            }else if(k==2){
                Case caseInstance=new Case();
                caseInstance.AccountId=listOfContacts[k].AccountId;
                caseInstance.ContactId=listOfContacts[k].Id;
                caseInstance.Priority='P1';
                caseInstance.Status='New';
                caseInstance.Functional_Area__c='Data Preparation';
                caseInstance.POD_Group__c='Galactus';
                listofCases.add(caseInstance);
            }
            else if(k==3){
                Case caseInstance=new Case();
                caseInstance.AccountId=listOfContacts[k].AccountId;
                caseInstance.ContactId=listOfContacts[k].Id;
                caseInstance.Priority='P2';
                caseInstance.Status='New';
                caseInstance.Functional_Area__c='Data Preparation';
                caseInstance.POD_Group__c='Galactus';
                listofCases.add(caseInstance);
            }else {
                Case caseInstance=new Case();
                caseInstance.AccountId=listOfContacts[k].AccountId;
                caseInstance.ContactId=listOfContacts[k].Id;
                caseInstance.Priority='P2';
                caseInstance.Status='New';
                caseInstance.Comments='test record';
                caseInstance.Functional_Area__c='Data Preparation';
                caseInstance.POD_Group__c='Galactus';
                listofCases.add(caseInstance);
            }
        }
        
        if(listofCases.size()>0 && isInsert){
            Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
            insert listofCases; 
        }else if(listofCases.size()>0 && isUpdate){
            Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
            insert listofCases;
            for(Case caseInstance:listofCases){
                caseInstance.Priority='P0';
                caseInstance.Status='Pending';
                caseInstance.Sub_Status__c=CaseConstants.SUB_STATUS_WITH_CUSTOMER_FOR_PRO_CLAR;
                caseInstance.Is_Customer_Unblocked__c=true;
                caseInstance.Comments='test record';
                caseInstance.Functional_Area__c='Data Preparation';
                caseInstance.POD_Group__c='Galactus';
            }
            Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
            update listofCases;
        }
        
        return listofCases;
    }
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @param boolean IsInsert 
* @param boolean isUpdate 
* @return List<Entitlement> 
**/
    public static List<Entitlement> createEntitlement(boolean IsInsert,boolean isUpdate){
        Account a=new Account(Name='Entitlement');
        insert a;
        Entitlement  instanceEntitlement=new Entitlement(Name='GST Engineering SLA On P0',AccountId=a.id,StartDate=System.today());
        Entitlement  instanceEntitlementUrgent=new Entitlement(Name='GST Engineering SLA On P0',AccountId=a.id,StartDate=System.today());
        Entitlement  instanceEntitlementNormal=new Entitlement(Name='GST Engineering SLA On P1',AccountId=a.id,StartDate=System.today());
        Entitlement  instanceEntitlementLow=new Entitlement(Name='GST Engineering SLA On P2',AccountId=a.id,StartDate=System.today());
        List<Entitlement> listofEntitlements=new List<Entitlement>();
        listofEntitlements.add(instanceEntitlement);
        listofEntitlements.add(instanceEntitlementUrgent);
        listofEntitlements.add(instanceEntitlementNormal);
        listofEntitlements.add(instanceEntitlementLow);
        if(IsInsert){
            insert listofEntitlements;
        }else if(IsUpdate)
        {
            insert listofEntitlements;
            
            for(Entitlement entitlementInstance:listofEntitlements){
                Date dateInstance=System.today();
                dateInstance.addDays(10);
                entitlementInstance.StartDate=dateInstance;
            }
            
            update listofEntitlements;
        }
        
        return listofEntitlements;
    }

    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @return List<Location_Master__c> 
**/
    public static List<Location_Master__c> createLocationMaster(){
        List<Location_Master__c> listOfLocationMasters=new List<Location_Master__c>();
        
        Location_Master__c locationMaster1=new Location_Master__c();
        Location_Master__c locationMaster2=new Location_Master__c();
        Location_Master__c locationMaster3=new Location_Master__c();
        Location_Master__c locationMaster4=new Location_Master__c();
        Location_Master__c locationMaster5=new Location_Master__c();
        
        locationMaster3.Name='South';
        Id recordTypeRegionId=Schema.SobjectType.Location_master__c.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        locationMaster3.recordTypeId=recordTypeRegionId;
        insert locationMaster3;
        
        locationMaster5.Name='Karnataka';
        Id recordTypeStateId=Schema.SobjectType.Location_master__c.getRecordTypeInfosByName().get('State').getRecordTypeId();
        locationMaster5.recordTypeId=recordTypeStateId;
        locationMaster5.Region__c= locationMaster3.Id; //locationMaster2.id;
        
        insert locationMaster5;
        
        locationMaster1.Name='Bangalore';
        Id recordTypeCityId=Schema.SobjectType.Location_master__c.getRecordTypeInfosByName().get('City').getRecordTypeId();
        locationMaster1.recordTypeId=recordTypeCityId;
        locationMaster1.Assignment_Policy__c='Area First';
        locationMaster1.Last_Assigned__c ='Area';
        locationMaster1.State__c=locationMaster5.id;
        insert locationMaster1;
        
        locationMaster2.Name='Kormanagala';
        Id recordTypeAreaId=Schema.SobjectType.Location_master__c.getRecordTypeInfosByName().get('Area').getRecordTypeId();
        locationMaster2.recordTypeId=recordTypeAreaId;
        locationMaster2.City__c=locationMaster1.Id;
        insert locationMaster2;
        
        locationMaster4.Name='560029';
        Id recordTypePincodeId=Schema.SobjectType.Location_master__c.getRecordTypeInfosByName().get('Pincode').getRecordTypeId();
        locationMaster4.recordTypeId=recordTypePincodeId;
        locationMaster4.City_Pincode__c=locationMaster2.ID;
        
        listOfLocationMasters.add(locationMaster4);
        Insert listOfLocationMasters;
        
        return listOfLocationMasters;
    }
    
    

    public static List<EmailMessage> createEmailMessageRelatedToCase(Integer noOfEmails){
        Account accountInstance=new Account();
        accountInstance.name='test';
        insert accountInstance;        
        Contact contactInstance= new Contact(LastName='TestAccount' ,FirstName='TestAccount',Phone='900000000',Email='test@cleartax.com',AccountId=accountInstance.Id);
        insert contactInstance;
        
        Case caseInstance=new Case();
        caseInstance.AccountId=contactInstance.AccountId;
        caseInstance.ContactId=contactInstance.Id;
        caseInstance.Priority='P0';
        caseInstance.Status='New';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
        insert caseInstance;
        
        List<EmailMessage> listEmailMessages=new List<EmailMessage>();
        for(Integer i=0;i<noOfEmails;i++){
            EmailMessage emailMessageInstance=new EmailMessage(
                Subject                = 'test12'+i
                ,Status                 = '3'
                ,ToAddress              = 'heim'+i+'@elastify.eu'
                ,FromAddress            = 'Warpdri@gmail.com'
                ,FromName               = UserInfo.getFirstName()+' - '+UserInfo.getLastName()
                ,HtmlBody               = 'a body'
                ,Incoming               = false
                ,MessageDate            = DateTime.now()
                ,ParentId        = caseInstance.Id
                // ,HasAttachment       = true // not possible: Read-Only!
            );
            
            listEmailMessages.add(emailMessageInstance);
        }
        
        return listEmailMessages;
    }
    
 public static List<CaseComment> createCaseCommentRelatedToCase(Integer noOfCaseComments){
        Account accountInstance=new Account();
        accountInstance.name='test';
        insert accountInstance;        
        Contact contactInstance= new Contact(LastName='TestAccount' ,FirstName='TestAccount',Phone='900000000',Email='test@cleartax.com',AccountId=accountInstance.Id);
        insert contactInstance;
        
        Case caseInstance=new Case();
        caseInstance.Status='New';
        caseInstance.AccountId=contactInstance.AccountId;
        caseInstance.ContactId=contactInstance.Id;
        caseInstance.Priority='P0';
        caseInstance.Status='New';
        caseInstance.Functional_Area__c='Data Preparation';
        caseInstance.POD_Group__c='Galactus';
        caseInstance.Comments='test Comment Info';
        Test.setMock(HttpCalloutMock.Class,new RestMockUtility());
        insert caseInstance;
        List<CaseComment> listOfCaseComments=new List<CaseComment>();
        
        for(Integer i=0;i<noOfCaseComments;i++){
            CaseComment caseCommentInstance=new CaseComment();
            caseCommentInstance.ParentId = caseInstance.Id;
            caseCommentInstance.CommentBody = 'Some Comment'+i;
            caseCommentInstance.IsPublished = TRUE;
            //caseCommentInstance.IsNotificationSelected = true;
            listOfCaseComments.add(caseCommentInstance);
        }
        
        return listOfCaseComments;
        
    }
    public static List<Account> createAccount(Integer numAccts){
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i, PAN__c='ABC123'+i);
            accts.add(a);
        }
        
        return accts;
    }
    
    
    
    /**
    * @description This method helps to generate the data for LeadTeam Object
    * @author Lokesh@SFDeveloper.SFDoc | 10/11/2020 
    * @return List<Lead_Team__c>  
    **/
    public static List<Lead_Team__c> createLeadTeams(Integer noOfLeadTeams,boolean isInsert){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='Field Sales']; 
        User testUser = new User(Alias = 'standt', Email='standarduserFSAles@WDtestorg1.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, 
                                 TimeZoneSidKey='Asia/Kolkata', UserName='standarduserFSAles@WDtestorg.com');
        insert testUser;
        
        List<Lead_Team__c> listOfLeadTeams=new List<Lead_Team__c>();
        
        Lead leadInstance=new Lead();
        leadInstance.LastName='testLead1';
        leadInstance.Company='SFDev1';
        leadInstance.Industry='Telecommunication';
        leadInstance.Turnover__c='0-50 Cr';
        leadInstance.GSTIN__c='1 GSTIN';
        leadInstance.PAN__c = 'PANZZZ1124';
        leadInstance.ownerId=UserInfo.getUserId();
        leadInstance.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Central Database').getRecordTypeId();
        
        insert leadInstance;
        if(noOfLeadTeams!=null){
            for(Integer i=0;i<noOfLeadTeams;i++){
                Lead_Team__c leadTeamInstance=new Lead_Team__c();
                leadTeamInstance.OwnerId=UserInfo.getUserId();
                leadTeamInstance.Approval_for_Co_Ownership__c='In Progress';
                leadTeamInstance.Attribution_share_percentage__c=65;
                leadTeamInstance.Record_Access__c='Public Read/Write';
                leadTeamInstance.Lead__c=leadInstance.Id;
                leadTeamInstance.User__c=testUser.Id;
                listOfLeadTeams.add(leadTeamInstance);
            }
        }
        
        if(isInsert){
            insert listOfLeadTeams;
        }
        
        
        return listOfLeadTeams;
    }
    
    public static Service_Admin_Configuration__c createSAdminConfigForEntitlement(Entitlement ent){
        Service_Admin_Configuration__c sac = new Service_Admin_Configuration__c();
        sac.User_Role_Type__c = 'L1 Support - CT';
        sac.Priority__c = 'P0';
        sac.Case_Record_Type__c = 'B2C';
        sac.Entitlement__c = ent.Id;
        sac.RecordTypeId = Schema.SObjectType.Service_Admin_Configuration__c.getRecordTypeInfosByName().get('Case Entitlement').getRecordTypeId();
        return sac;
    }
    
}