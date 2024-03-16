@isTest
public class GenerateOrderFormPDFTest {
    @testSetup static void setup() {
        Profile pr = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User testUser = new User(Alias = 'standt', Email='standarduser@WDtestorg1.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = pr.Id, 
                                 TimeZoneSidKey='Asia/Kolkata', UserName='standarduser2121@WDtestorg.com');
        insert testUser;
        User testUser1 = new User(Alias = 'standt', Email='standarduser1@WDtestorg1.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = pr.Id,ManagerId=testUser.Id, 
                                  TimeZoneSidKey='Asia/Kolkata', UserName='standarduser212@WDtestorg.com');
        insert testUser1;
        
        Account a1=new Account();
        a1.Name='KAM test validation';
        a1.PAN__c = 'HGFDR4435G';
        insert a1;
        
        Contact contactInstance=new Contact();
        contactInstance.email=Label.Closure_Mail_additionalMailIDs.split(',').get(0);
        contactInstance.LastName='test';
        contactInstance.AccountId=a1.Id;
        contactInstance.Designation__c = 'CEO';
        contactInstance.MobilePhone = '2164567890';
        contactInstance.Email = 'r@r.in';
        insert contactInstance;
        
        System.debug('contactInstanceII*'+contactInstance.Email);
        Contact contactInstance1=new Contact();
        contactInstance1.email=testUser.Email;
        contactInstance1.LastName='test';
        contactInstance1.AccountId=a1.Id;
        contactInstance1.MobilePhone = '2134567890';
        contactInstance1.Designation__c = 'COO';
        insert contactInstance1;
        System.debug('contactInstanceII*'+contactInstance1.Email);
        
        System.debug('contactInstanceII*'+contactInstance.Email);
        Contact contactInstance2=new Contact();
        contactInstance2.email=userInfo.getUserEmail();
        contactInstance2.LastName='test';
        contactInstance2.AccountId=a1.Id;
        contactInstance2.MobilePhone = '2164567890';
        contactInstance2.Designation__c = 'Finance Head';
        insert contactInstance2;
        System.debug('contactInstanceII*'+contactInstance2.Email);
        
        
        List<Opportunity>opportunitylist=new List<Opportunity>();
        
        Account a=new Account();
        a.PAN__c = 'GGFDR4435G';
        a.Name='KAM validation';
        insert a;
        
        Opportunity opp=new Opportunity();
        opp.Name='KAM';
        opp.StageName='SQL';
        opp.CloseDate=System.today();
        opp.AccountId=a.Id;
        opp.OwnerId = testUser1.id;
        opp.E_Sign_Status__c='E-Sign Request Sent';
        opp.Business_POC_Name__c='myName1';
        opp.Business_POC_Contact_Number__c = '4532456789';
        opp.Business_POC_Designation__c = 'Business Head';
        opp.Business_POC_Email__c = 'abscefghijklmnopq.rstuvwxyz@test.com';
        opp.Finance_POC_For_Invoice_Processing_Name__c='myName2';
        opp.Finance_POC_For_Invoice_Processing_Phone__c = '4532456789';
        opp.Finance_POC_For_Invoice_Processing_Desig__c = 'Finance Manager';
        opp.Finance_POC_For_Invoice_Processing_Email__c = 'test.rstuvwxyz@test.com';
        opp.Tax_Head_Name__c='myName3';
        opp.Tax_Head_Contact_Number__c = '4532456789';
        opp.Tax_Head_Designation__c = 'Tax Head';
        opp.Tax_Head_Email__c = 'test2.rstuvwxyz@test.com';
        opp.Finance_Head_Name__c='myName4';
        opp.Finance_Head_Contact_Number__c = '4532456789';
        opp.Finance_Head_Designation__c = 'Functional Head';
        opp.Finance_Head_Email__c = 'test3.rstuvwxyz@test.com';
        opp.IT_Head_Name__c='myname5';
        opp.IT_Head_Contact_Number__c = '4532456789';
        opp.IT_Head_Designation__c = 'IT Head';
        opp.IT_Head_Email__c = 'test4.rstuvwxyz@test.com';
        
        opportunitylist.add(opp);
        //opportunitylist.add(opp2);
        insert opportunitylist;
        Product2 p=new Product2();
        p.Name='E-invoicing license cost with KAM';
        p.Family='Airline';
        p.IsActive =true;
        p.Family = 'Managed Service';
        p.Formula__c = '1500';
        p.Billing_Type__c='ARR';
        p.Family='ASP/GSP';
        p.Product_category__c='Integration';
        insert p;
        
        Product2 p2=new Product2();
        p2.Name='ASP/GSP - GSP APIs';
        p2.Family='Products';
        p2.IsActive =true;
        p2.Family = 'Managed Service';
        p2.Formula__c = '1500';
        p2.Billing_Type__c='ARR';
        p2.Family='ASP/GSP';
        p2.Product_category__c='Integration';
        insert p2;
        
        Product2 p3=new Product2();
        p3.Name='KAM';
        p3.Family='Integration';
        p3.IsActive =true;
        p3.Family = 'Managed Service';
        p3.Formula__c = '1500';
        p3.Billing_Type__c='ARR';
        p3.Family='ASP/GSP';
        p3.Product_category__c='Integration';
        insert p3;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        
        PricebookEntry pl=new PricebookEntry();
        pl.UnitPrice=847348;
        pl.Minimum_Price__c=56228;
        pl.Product2Id=p.id;
        pl.Pricebook2Id=pricebookId;
        pl.IsActive=true;
        
        insert pl;
        
        
        PricebookEntry pl1=new PricebookEntry();
        pl1.UnitPrice=847348;
        pl1.Minimum_Price__c=56228;
        pl1.Product2Id=p2.id;
        pl1.Pricebook2Id=pricebookId;
        pl1.IsActive=true;
        
        insert pl1;
        
        PricebookEntry pl2=new PricebookEntry();
        pl2.UnitPrice=847348;
        pl2.Minimum_Price__c=56228;
        pl2.Product2Id=p3.id;
        pl2.Pricebook2Id=pricebookId;
        pl2.IsActive=true;
        
        insert pl2;
        
        
        Quote quoteRecord = new Quote();
        quoteRecord.OpportunityId = opp.Id;
        quoteRecord.Name = 'Test Class Quote';
        quoteRecord.Pricebook2Id = pricebookId;
        quoteRecord.Status='Draft';
        quoteRecord.Type_of_Integration__c='API- Only by Customer';
        
        insert quoteRecord;
        
        QuoteLineItem QuoteLineItem = new QuoteLineItem(
            Product2Id = p.Id, 					// Product
            UnitPrice = 12500.00,
            // Sales Price
            Quantity = 4.00,               // Quantity
            QuoteId = quoteRecord.Id,
            PricebookEntryId = pl.ID,
            period_end_date__c = system.today()+1,
            period_start_date__c = system.today()
        );
        
        insert QuoteLineItem;
        
        Additional_GSTIN__c agst=new Additional_GSTIN__c();
        agst.Quote__c=quoteRecord.Id;
        agst.Quote_Line_Item__c=QuoteLineItem.id;
        agst.Name='123456789012345';
        agst.Address__c='baab';
        agst.Amount__c=123;
        insert agst;
        
        
        
        QuoteDocument qd = new QuoteDocument(); 
        qd.document = Blob.toPDF('Your Contents Here');
        qd.QuoteId = quoteRecord.Id;
        insert qd;
        quoteRecord.Status='Draft';
        quoteRecord.Is_Primary_Quote__c=true;
        quoteRecord.Approval_Status__c='Approved';
        quoteRecord.Status='Quote Accept';
        update quoteRecord;
        opp.SyncedQuoteId = quoteRecord.Id; 
        opp.Document_No_LOE_No__c='T1';
        opp.Period_Start_date__c=Date.newInstance(2020, 07, 10);
        opp.Period_End_date__c=Date.newInstance(2020, 07, 31);
        opp.PO_Received_Date__c=Date.newInstance(2020, 07, 11);
        opp.StageName = 'Profiling';
        opp.E_Sign_Customer_Info__c = contactInstance1.Id;
        test.startTest();
        update opp;
        test.stopTest();
        
        E_Sign_Config__c esc=new E_Sign_Config__c();
        esc.Name='Type_Of_Doc';
        esc.Value__c='Order Form';
        insert esc;
        E_Sign_Config__c esc1=new E_Sign_Config__c();
        esc1.Name='CTX-Signer-Name';
        esc1.Value__c='Raksha H';
        insert esc1;
        E_Sign_Config__c esc2=new E_Sign_Config__c();
        esc2.Name='CTX-Signer-Designation';
        esc2.Value__c='Raksha H';
        insert esc2; 
        E_Sign_Config__c esc3=new E_Sign_Config__c();
        esc3.Name='CTX-Signer-Name1';
        esc3.Value__c='Raksha H';
        insert esc3; 
        E_Sign_Config__c esc4=new E_Sign_Config__c();
        esc4.Name='CTX-Signer-Designation1';
        esc4.Value__c='Raksha H';
        insert esc4; 
        
        
        ContentVersion contentVersionInsert1 = new ContentVersion(
            Title = 'Test1',
            PathOnClient = 'Test1.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true,
            Type_of_document__c=esc.Id
        );
        //contentVersionInsert1.Type_of_document__c=esc.Id;
        insert contentVersionInsert1;
        
        
        Id conDoc1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionInsert1.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = opp.id; 
        conDocLink.ContentDocumentId = conDoc1;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
        ContentVersion contentVersionInsert2 = new ContentVersion(
            Title = 'Test2',
            PathOnClient = 'Test2.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true,
            Type_of_document__c='LOE'
        );
        insert contentVersionInsert2;
        Id conDoc2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionInsert2.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink2 = New ContentDocumentLink();
        conDocLink2.LinkedEntityId = opp.id; 
        conDocLink2.ContentDocumentId = conDoc2;  //ContentDocumentId Id from ContentVersion
        conDocLink2.shareType = 'V';
        insert conDocLink2;
        //opp.StageName = 'Closed Won';
        //update opp;
        
        
        opp.Period_Start_date__c = System.today();
        opp.Period_End_date__c	= system.today()+120;
        opp.E_Sign_Customer_Info__c = contactInstance1.Id;
        opp.Billing_Frequency__c = '100 percent in advance';
        opp.Billing_Address__c = 'test';
        opp.Billing_F__c = 'Yearly in advance';
        opp.Billing_GST__c = '12asdfg1234a1b2';
        opp.Billing_Method__c = 'Email';
        opp.PAN_No_as_per_PO__c	 = 'asdfg1234a';
        opp.If_SEZ__c = 'Yes';
        opp.Payment_Method__c = 'Cheque';
        opp.Payment_Term__c = '10 days from date of invoice';
        opp.TAN__c = '1234567890';
        opp.Place_of_Supply__c =  'test';
        opp.Legal_Entity_Name_Of_The_Client__c = 'WarpDrive Tech Works';
        opp.PO_Required__c = 'Yes';
        opp.PO_number__c = '123456';
        opp.PO_Amount__c = 100000;
        opp.Special_Terms__c = 'test';
        opp.Shipping_Address__c = 'test';
        update opp;
        // list<Scope_Of_Service_VFs__c> listOfSOS= new list<Scope_Of_Service_VFs__c>()
        Scope_Of_Service_VFs__c sos=new Scope_Of_Service_VFs__c();
        sos.Name='CustomerInformation';
        Scope_Of_Service_VFs__c sos1=new Scope_Of_Service_VFs__c();
        sos1.Name='SOS_AirlineCreditModuleBasePrice';
        Scope_Of_Service_VFs__c sos2=new Scope_Of_Service_VFs__c();
        sos2.Name='SOS_ASP_GSP_CT';
        insert sos;
        insert sos1;
        insert sos2;
        Product_ScopeOfService_Junction__c pro= new Product_ScopeOfService_Junction__c();
        pro.Scope_Of_Service_VFs__c=sos.id;
        pro.Order__c=1;
        insert pro;
        Product_ScopeOfService_Junction__c pro1= new Product_ScopeOfService_Junction__c();
        pro1.Scope_Of_Service_VFs__c=sos1.id;
        pro1.Product__c=p.id;
        pro1.Order__c=2;
        insert pro1;
        Product_ScopeOfService_Junction__c pro2= new Product_ScopeOfService_Junction__c();
        pro2.Scope_Of_Service_VFs__c=sos2.id;
        pro2.Product__c=p2.id;
        pro2.Order__c=3;
        pro2.Type_of_Integration__c='API - Only by CT SI';
        insert pro2;
    }
    
    
    
    
    @isTest
    public static void getOpportunityDetalsOnLoad(){
        
        Opportunity opp=[select id,name,stageName,closedate,AccountId,OwnerId,E_Sign_Status__c,Business_POC_Name__c,
                         Finance_POC_For_Invoice_Processing_Name__c,Tax_Head_Name__c,Finance_Head_Name__c,IT_Head_Name__c,Period_Start_date__c,
                         Period_End_date__c,E_Sign_Customer_Info__c,Billing_Frequency__c,Billing_Address__c,Billing_F__c,Billing_GST__c,PAN_No_as_per_PO__c	,
                         If_SEZ__c,Payment_Method__c,Payment_Term__c,TAN__c,Place_of_Supply__c,Legal_Entity_Name_Of_The_Client__c,
                         PO_Required__c,PO_number__c,PO_Amount__c,Special_Terms__c,Shipping_Address__c from opportunity limit 1];
        
        
        
        
        PageReference pageRef = Page.generateOrderForm;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id',opp.id);
        
        
         Test.startTest();
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF = new generateOrderFormPDF(sc);
        
        generateOrderFormPDF.saveOrderFormToOpportunity(opp.Id);
        Test.stopTest();
        system.debug('1***********************######### '+generateOrderFormPDF.nextNumber);
        SOS_ASP_GSP_Controller SOS1 = new SOS_ASP_GSP_Controller(sc);									generateOrderFormPDF.nextNumber--;
        SOS_EINV_Controller SOS2 = new SOS_EINV_Controller(sc);		 									generateOrderFormPDF.nextNumber--;
        SOS_ASP_GSP_CT_Controller SOS3 = new SOS_ASP_GSP_CT_Controller(sc);								generateOrderFormPDF.nextNumber--;
        SOS_ASP_GSP_Customer_Controller SOS4 = new SOS_ASP_GSP_Customer_Controller(sc);					generateOrderFormPDF.nextNumber--;
        SOS_ASP_GSP_FTP_Controller SOS5 = new SOS_ASP_GSP_FTP_Controller(sc);							generateOrderFormPDF.nextNumber--;
        SOS_EINVIntegration_CT_Controller SOS6= new SOS_EINVIntegration_CT_Controller(sc);				generateOrderFormPDF.nextNumber--;
        SOS_EINVIntegration_Customer_Controller	SOS7 = new SOS_EINVIntegration_Customer_Controller(sc);	generateOrderFormPDF.nextNumber--;
        SOS_EINVIntegration_FTP_Controller SOS8 = new SOS_EINVIntegration_FTP_Controller(sc);			generateOrderFormPDF.nextNumber--;
        SOS_2AvsPR_2BvsPR_Controller SOS9 = new SOS_2AvsPR_2BvsPR_Controller(sc);						generateOrderFormPDF.nextNumber--;
        SOS_AdvancedRecon_Controller SOS10 = new SOS_AdvancedRecon_Controller(sc);						generateOrderFormPDF.nextNumber--;
        SOS_GSTINVerification_Controller SOS11 = new SOS_GSTINVerification_Controller(sc);				generateOrderFormPDF.nextNumber--;
        SOS_B2C_QR_CodeAPI_Controller SOS12 = new SOS_B2C_QR_CodeAPI_Controller(sc);					generateOrderFormPDF.nextNumber--;
        SOS_B2C_QR_CodeWeb_Controller SOS13 = new SOS_B2C_QR_CodeWeb_Controller(sc);					generateOrderFormPDF.nextNumber--;
        SOS_E_WayBill_GSPAPIs_Controller SOS14 = new SOS_E_WayBill_GSPAPIs_Controller(sc);				generateOrderFormPDF.nextNumber--;
        SOS_AirlineCreditModuleBase_Controller SOS15 = new SOS_AirlineCreditModuleBase_Controller(sc);	generateOrderFormPDF.nextNumber--;
        SOS_ClearOneInvoicing_Controller SOS16 = new SOS_ClearOneInvoicing_Controller(sc);				generateOrderFormPDF.nextNumber--;
        SOS_EWBLicenseCostWithKAM_Controller SOS17 = new SOS_EWBLicenseCostWithKAM_Controller(sc);		generateOrderFormPDF.nextNumber--;
        SOS_GSTR6_Controller SOS18 = new SOS_GSTR6_Controller(sc);										generateOrderFormPDF.nextNumber--;
        SOS_GSTR9_Controller SOS19 = new SOS_GSTR9_Controller(sc);										generateOrderFormPDF.nextNumber--;
        SOS_AnnualMaintenanceCharges_Controller	SOS20 = new SOS_AnnualMaintenanceCharges_Controller(sc);generateOrderFormPDF.nextNumber--;
        SOS_MaxITCLicenseCost_Controller SOS21 = new SOS_MaxITCLicenseCost_Controller(sc);				generateOrderFormPDF.nextNumber--;
        SOS_Reports_Controller SOS22 = new SOS_Reports_Controller(sc);									generateOrderFormPDF.nextNumber--;
        SOS_TDS_Controller SOS23 = new SOS_TDS_Controller(sc);											generateOrderFormPDF.nextNumber--;
        SOS_206AB_CCA_Controller SOS24 = new SOS_206AB_CCA_Controller(sc);								generateOrderFormPDF.nextNumber--;
        SOS_PANLevelReports_5Reports_Controller	SOS25 = new	SOS_PANLevelReports_5Reports_Controller(sc);generateOrderFormPDF.nextNumber--;
        SOS_E_WayBill_ASPAPIs_CT_Controller	SOS26 = new SOS_E_WayBill_ASPAPIs_CT_Controller(sc);		generateOrderFormPDF.nextNumber--;
        SOS_E_WayBill_ASPAPIs_Cust_Controller SOS27 = new SOS_E_WayBill_ASPAPIs_Cust_Controller(sc);	generateOrderFormPDF.nextNumber--;
        SOS_E_WayBill_ASPAPIs_SFTP_Controller SOS28 = new SOS_E_WayBill_ASPAPIs_SFTP_Controller(sc);	generateOrderFormPDF.nextNumber--;
        SOS_ClearTaxTDSSolution_Controller SOS29 = new SOS_ClearTaxTDSSolution_Controller(sc);			generateOrderFormPDF.nextNumber--;
        CustomerInformation_Controller SOS30 = new CustomerInformation_Controller(sc);					generateOrderFormPDF.nextNumber--;
        SubscriptionCharges_Controller SOS31 = new SubscriptionCharges_Controller(sc);					generateOrderFormPDF.nextNumber--;
        ServiceCharges_Controller SOS32 = new ServiceCharges_Controller(sc);							generateOrderFormPDF.nextNumber--;
        PaymentCharges_Controller SOS33 = new PaymentCharges_Controller(sc);							generateOrderFormPDF.nextNumber--;
        POInformation_Controller SOS34 = new POInformation_Controller(sc);								generateOrderFormPDF.nextNumber--;
        ContactDetails_Controller SOS35 = new ContactDetails_Controller(sc);							generateOrderFormPDF.nextNumber--;
        PricingParameters_Controller SOS36 = new PricingParameters_Controller(sc);						generateOrderFormPDF.nextNumber--;
        General_Controller SOS37 = new General_Controller(sc);											generateOrderFormPDF.nextNumber--;
        Annexure_Controller	SOS38 = new	Annexure_Controller(sc);										generateOrderFormPDF.nextNumber--;
        SOS_E_InvoicingLicenseWithT_Controller	SOS39 = new	SOS_E_InvoicingLicenseWithT_Controller(sc);	generateOrderFormPDF.nextNumber--;
        SOS_GEeR_up_Ecosystem_Controller SOS40 = new SOS_GEeR_up_Ecosystem_Controller(sc);				generateOrderFormPDF.nextNumber--;
        SpecialTerms_Controller SOS41 = new SpecialTerms_Controller(sc);								generateOrderFormPDF.nextNumber--;
        SOS_AMC_EINVSFTP_Controller SOS42 = new SOS_AMC_EINVSFTP_Controller(sc);                        generateOrderFormPDF.nextNumber--;
        SOS_E_INVOICE_PASSTHROUGH_Controller SOS43 = new SOS_E_INVOICE_PASSTHROUGH_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_B2C_QR_Code_Integration_Controller SOS44 = new SOS_B2C_QR_Code_Integration_Controller(sc);  generateOrderFormPDF.nextNumber--;
        SOS_ASP_GSP_Lic_Tally_Desktop_Controller SOS45 = new SOS_ASP_GSP_Lic_Tally_Desktop_Controller(sc);  generateOrderFormPDF.nextNumber--;
        SOS_EINV_GSP_API_BY_CUSTO_Controller SOS46 = new SOS_EINV_GSP_API_BY_CUSTO_Controller(sc);  generateOrderFormPDF.nextNumber--;
        
        GST_ASP_API_Only_by_CT_SI_Controller SOS47 = new GST_ASP_API_Only_by_CT_SI_Controller(sc);							generateOrderFormPDF.nextNumber--;
        SOS_ASP_GSP_API_CT_Inh_Hana_Controller SOS48 = new SOS_ASP_GSP_API_CT_Inh_Hana_Controller(sc);						generateOrderFormPDF.nextNumber--;
        SOS_ASPGSPAPI_CT_InCust_ERP_Controller SOS49 = new SOS_ASPGSPAPI_CT_InCust_ERP_Controller(sc);											generateOrderFormPDF.nextNumber--;
        SOS_ASPGSPAPI_CT_InTally_ERP_Controller	SOS50 = new	SOS_ASPGSPAPI_CT_InTally_ERP_Controller(sc);										generateOrderFormPDF.nextNumber--;
        SOS_ASP_GSP_API_onlybycust_controller	SOS51 = new	SOS_ASP_GSP_API_onlybycust_controller(sc);	generateOrderFormPDF.nextNumber--;
        SOS_ASPGSPAPI_CT_InNets_ERP_Controller SOS52 = new SOS_ASPGSPAPI_CT_InNets_ERP_Controller(sc);				generateOrderFormPDF.nextNumber--;
        SOS_ASPGSP_API_SFTPonlycust_Controller SOS53 = new SOS_ASPGSP_API_SFTPonlycust_Controller(sc);								generateOrderFormPDF.nextNumber--;
        SOS_EINV_EWB_CTINH_HANA_Controller SOS54 = new SOS_EINV_EWB_CTINH_HANA_Controller(sc);                        generateOrderFormPDF.nextNumber--;
        SOS_EINV_EWB_API_CTIN_ERP_Controller SOS55 = new SOS_EINV_EWB_API_CTIN_ERP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_EWB_GSP_API_BY_CUSTO_Controller SOS56 = new SOS_EINV_EWB_GSP_API_BY_CUSTO_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_Custom_Print_Template_Controller SOS57 = new SOS_Custom_Print_Template_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_MAXITCIntegrationController SOS58 = new SOS_MAXITCIntegrationController(sc);      generateOrderFormPDF.nextNumber--;
        SOS_2_factor_authcontroller SOS59 = new SOS_2_factor_authcontroller(sc);      generateOrderFormPDF.nextNumber--;
            SOS_user_access_mgmtcontroller SOS60 = new SOS_user_access_mgmtcontroller(sc);      generateOrderFormPDF.nextNumber--;
            SOS_multi_PAN_datacontroller SOS61 = new SOS_multi_PAN_datacontroller(sc);      generateOrderFormPDF.nextNumber--;
            SOS_PAN_level_2A_vs_PRcontroller SOS62 = new SOS_PAN_level_2A_vs_PRcontroller(sc);      generateOrderFormPDF.nextNumber--;
            SOS_PAN_level_gstr1controller SOS63 = new SOS_PAN_level_gstr1controller(sc);      generateOrderFormPDF.nextNumber--;
            SOS_PAN_level_gstr2Acontroller SOS64 = new SOS_PAN_level_gstr2Acontroller(sc);      generateOrderFormPDF.nextNumber--;
            SOS_PAN_level_gstr2Bcontroller SOS65 = new SOS_PAN_level_gstr2Bcontroller(sc);      generateOrderFormPDF.nextNumber--;
            SOS_PAN_level_gstr3Bcontroller SOS66 = new SOS_PAN_level_gstr3Bcontroller(sc);      generateOrderFormPDF.nextNumber--;
            SOS_PAN_level_gstr3Bvs1controller SOS67 = new SOS_PAN_level_gstr3Bvs1controller(sc);      generateOrderFormPDF.nextNumber--;
            SOS_PAN_level_gstr3Bvs2Acontroller SOS68 = new SOS_PAN_level_gstr3Bvs2Acontroller(sc);      generateOrderFormPDF.nextNumber--;
            SOS_TDS_206AB_controller SOS69 = new SOS_TDS_206AB_controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_ASP_GSP_API_CTIN_SAPB1_Controller SOS70 = new SOS_ASP_GSP_API_CTIN_SAPB1_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_API_CT_SI_Controller SOS71 = new SOS_GSP_API_CT_SI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_API_CTIN_SAPB1_Controller SOS72 = new SOS_GSP_API_CTIN_SAPB1_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_API_CT_In_Custom_ERP_Controller SOS73 = new SOS_GSP_API_CT_In_Custom_ERP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_GST_API_Controller SOS74 = new SOS_GSP_GST_API_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_EWB_CTIN_SAP_COntroller SOS75 = new SOS_EINV_EWB_CTIN_SAP_COntroller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EWB_API_CTSI_Controller SOS76 = new SOS_EWB_API_CTSI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EWB_CTIN_SAP_Controller SOS77 = new SOS_EWB_CTIN_SAP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EWB_API_CTIN_ERP_Controller SOS78 = new SOS_EWB_API_CTIN_ERP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_ASP_EWB_API_Controller SOS79 = new SOS_ASP_EWB_API_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EWB_SFTP_SI_Controller SOS80 = new SOS_EWB_SFTP_SI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_EWB_API_CTSI_Controller SOS81 = new SOS_GSP_EWB_API_CTSI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_EWB_API_HANA_Controller SOS82 = new SOS_GSP_EWB_API_HANA_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_EWB_API_SAP_Controller SOS83 = new SOS_GSP_EWB_API_SAP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_EWB_API_Controller SOS84 = new SOS_GSP_EWB_API_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINVEWBGST_API_CT_Controller SOS85 = new SOS_EINVEWBGST_API_CT_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINVEWBGST_API_CTSI_Controller SOS86 = new SOS_EINVEWBGST_API_CTSI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINVEWBGST_SFTP_CT_Controller SOS87 = new SOS_EINVEWBGST_SFTP_CT_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSTIN_API_CTSI_Controller SOS88 = new SOS_GSTIN_API_CTSI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSTIN_EINV_API_Controller SOS89 = new SOS_GSTIN_EINV_API_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_CTIN_SAP_Controller SOS90 = new SOS_EINV_CTIN_SAP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_API_CTIN_ERP_Controller SOS91 = new SOS_EINV_API_CTIN_ERP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_ASP_EINV_API_Controller SOS92 = new SOS_ASP_EINV_API_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_EWB_API_ERP_Controller SOS93 = new SOS_GSP_EWB_API_ERP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_SFTP_SI_Controller SOS94 = new SOS_EINV_SFTP_SI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_B2C_EINV_CTSI_Controller SOS95 = new SOS_B2C_EINV_CTSI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_B2C_EINV_Cust_Controller SOS96 = new SOS_B2C_EINV_Cust_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_CTINH_HANA_Controller SOS97 = new SOS_EINV_CTINH_HANA_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_EWB_API_Controller SOS98 = new SOS_EINV_EWB_API_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_ASP_GSP_API_CT_Inh_Hana_Controller SOS99 = new SOS_ASP_GSP_API_CT_Inh_Hana_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_ASPGSPAPI_CT_InCust_ERP_Controller SOS100 = new SOS_ASPGSPAPI_CT_InCust_ERP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_ASPGSPAPI_CT_InTally_ERP_Controller SOS101 = new SOS_ASPGSPAPI_CT_InTally_ERP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_ASPGSPAPI_CT_InNets_ERP_Controller SOS102 = new SOS_ASPGSPAPI_CT_InNets_ERP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_ASP_GSP_API_onlybycust_controller SOS103 = new SOS_ASP_GSP_API_onlybycust_controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_ASPGSP_API_SFTPonlycust_Controller SOS104 = new SOS_ASPGSP_API_SFTPonlycust_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_ASP_GSP_FTP_Inh_Controller SOS105 = new SOS_ASP_GSP_FTP_Inh_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_GST_API_CT_Inh_Hana_Controller SOS106 = new SOS_GSP_GST_API_CT_Inh_Hana_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_EWB_API_CTSI_Controller SOS107 = new SOS_EINV_EWB_API_CTSI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_EWB_CTINH_HANA_Controller SOS108 = new SOS_EINV_EWB_CTINH_HANA_Controller(sc);      generateOrderFormPDF.nextNumber--;
        
        SOS_EINV_EWB_API_CTIN_ERP_Controller SOS109 = new SOS_EINV_EWB_API_CTIN_ERP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_EWB_CTINH_Tally_Controller SOS110 = new SOS_EINV_EWB_CTINH_Tally_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_EWB_SFTP_SI_Controller SOS111 = new SOS_EINV_EWB_SFTP_SI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_EINVEWB_API_CTSI_Controller SOS112 = new SOS_GSP_EINVEWB_API_CTSI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_EINVEWBAPI_CTIN_HANA_COntroller SOS113 = new SOS_GSP_EINVEWBAPI_CTIN_HANA_COntroller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_EINVEWBAPI_CTIN_SAP_Controller SOS114 = new SOS_GSP_EINVEWBAPI_CTIN_SAP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSP_EINV_EWB_ERP_Controller SOS115 = new SOS_GSP_EINV_EWB_ERP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_API_Controller SOS116 = new SOS_EINV_API_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EWB_CTINH_HANA_Controller SOS117 = new SOS_EWB_CTINH_HANA_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_EWB_SFTP_Controller SOS118 = new SOS_EINV_EWB_SFTP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_MAX_BASIC_API_CT_COntroller SOS119 = new SOS_MAX_BASIC_API_CT_COntroller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_MAX_PRO_API_CT_Controller SOS120 = new SOS_MAX_PRO_API_CT_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_MAX_ADV_API_CT_Controller SOS121 = new SOS_MAX_ADV_API_CT_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_MAX_BASIC_API_CTSI_Controller SOS122 = new SOS_MAX_BASIC_API_CTSI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_MAX_PRO_API_CTSI_Controller SOS123 = new SOS_MAX_PRO_API_CTSI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_MAX_ADV_API_CTSI_Controller SOS124 = new SOS_MAX_ADV_API_CTSI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_MAX_BASIC_API_CUST_Controller SOS125 = new SOS_MAX_BASIC_API_CUST_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_MAX_PRO_API_CUST_Controller SOS126 = new SOS_MAX_PRO_API_CUST_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_MAX_ADV_API_CUST_Controller SOS127 = new SOS_MAX_ADV_API_CUST_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_EWBvsGSTR1controller SOS128 = new SOS_EWBvsGSTR1controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_PAN_level_cash_ledger_Controller SOS129 = new SOS_PAN_level_cash_ledger_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_GSTIN_API_CTSI_Controller SOS130 = new SOS_GSTIN_API_CTSI_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_MAX_ITC_Growth_Controller SOS131 = new SOS_MAX_ITC_Growth_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_Invoice_discounting_controller SOS132 = new SOS_Invoice_discounting_controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_Invoice_topay_controller SOS133 = new SOS_Invoice_topay_controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_FTP_EINVEWB_ASP_Controller SOS134 = new SOS_FTP_EINVEWB_ASP_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_FTP_SFTP_EINV_Controller SOS135 = new SOS_FTP_SFTP_EINV_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_FTP_SFTP_EWB_Controller SOS136 = new SOS_FTP_SFTP_EWB_Controller(sc);      generateOrderFormPDF.nextNumber--;
        SOS_FTP_SFTP_GST_Controller SOS137 = new SOS_FTP_SFTP_GST_Controller(sc);      generateOrderFormPDF.nextNumber--; 
         SOS_GST_ADV_MODULE_Controller  SOS138 = new SOS_GST_ADV_MODULE_Controller (sc);      generateOrderFormPDF.nextNumber--;
        SOS_Clearcapture_Controller   SOS139 = new SOS_Clearcapture_Controller (sc);      generateOrderFormPDF.nextNumber--;
        SOS_PAN_Basic_Controller          SOS140 = new SOS_PAN_Basic_Controller (sc);      generateOrderFormPDF.nextNumber--;
        SOS_PAN_Advanced_Controller       SOS141 = new SOS_PAN_Advanced_Controller  (sc);      generateOrderFormPDF.nextNumber--;
        SOS_MAXITC_Ent_2B_controller      SOS142 = new SOS_MAXITC_Ent_2B_controller (sc);      generateOrderFormPDF.nextNumber--;
        SOS_EINV_EWB_CTIN_MS_Controller   SOS143 = new SOS_EINV_EWB_CTIN_MS_Controller (sc);      generateOrderFormPDF.nextNumber--;
        
    }
    
    @isTest
    public static void test1(){
test.startTest() ;       
        Opportunity opp=[select id,name,stageName,closedate,AccountId,OwnerId,E_Sign_Status__c,Business_POC_Name__c,
                         Finance_POC_For_Invoice_Processing_Name__c,Tax_Head_Name__c,Finance_Head_Name__c,IT_Head_Name__c,Period_Start_date__c,
                         Period_End_date__c,E_Sign_Customer_Info__c,Billing_Frequency__c,Billing_Address__c,Billing_F__c,Billing_GST__c,Billing_Method__c,PAN_No_as_per_PO__c,
                         If_SEZ__c,Payment_Method__c,Payment_Term__c,TAN__c,Place_of_Supply__c,Legal_Entity_Name_Of_The_Client__c,
                         PO_Required__c,PO_number__c,PO_Amount__c,Special_Terms__c,Shipping_Address__c from opportunity limit 1];
        
        opp.E_Sign_Status__c='E-Sign Successful';
        update opp;
        list<Product2> p=[select id,Name,Billing_Type__c,Family from product2];
        list<Product2> listOFpro=new list<Product2>(); 
        for(product2 p1:p){
            p1.Billing_Type__c ='OTP';
            p1.Family='ASP/GSP';
            listofpro.add(p1);
        }
        update listofpro;
        Quote q=[select id,Type_of_Integration__c from quote limit 1];
        
        PageReference pageRef = Page.generateOrderForm;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id',opp.id);
        
        
        // Test.startTest();
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF = new generateOrderFormPDF(sc);
        
        //generateOrderFormPDF.saveOrderFormToOpportunity(opp.Id);
        //Test.stopTest();
        q.Type_of_Integration__c='API - Only by CT SI';
        update q;
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF1 = new generateOrderFormPDF(sc);
        
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc2 = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF2 = new generateOrderFormPDF(sc);
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc3 = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF3 = new generateOrderFormPDF(sc);
        test.stopTest()  ;
        
    }
    @isTest
    public static void test2(){
        Opportunity opp=[select id,name,stageName,closedate,AccountId,OwnerId,E_Sign_Status__c,Business_POC_Name__c,
                         Finance_POC_For_Invoice_Processing_Name__c,Tax_Head_Name__c,Finance_Head_Name__c,IT_Head_Name__c,Period_Start_date__c,	
                         Period_End_date__c,E_Sign_Customer_Info__c,Billing_Frequency__c,Billing_Address__c,Billing_F__c,Billing_GST__c,PAN_No_as_per_PO__c,
                         If_SEZ__c,Payment_Method__c,Payment_Term__c,TAN__c,Place_of_Supply__c,Legal_Entity_Name_Of_The_Client__c,
                         PO_Required__c,PO_number__c,PO_Amount__c,Special_Terms__c,Shipping_Address__c from opportunity limit 1];
        
        opp.E_Sign_Status__c='E-Sign Successful';
        update opp;
        list<Product2> p=[select id,Name,Billing_Type__c,Family from product2];
        list<Product2> listOFpro=new list<Product2>(); 
        for(product2 p1:p){
            p1.Billing_Type__c ='OTP';
            p1.Family='EINV';
            p1.Product_category__c='Others';
            listofpro.add(p1);
        }
        update listofpro;
        Quote q=[select id,Type_of_Integration__c from quote limit 1];
        
        PageReference pageRef = Page.generateOrderForm;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id',opp.id);
         
        // Test.startTest();
         test.startTest() ;
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF = new generateOrderFormPDF(sc);
        
        //generateOrderFormPDF.saveOrderFormToOpportunity(opp.Id);
        //Test.stopTest();
     test.stopTest() ;   
    }
    @isTest
    public static void test3(){
       test.startTest() ; 
        Opportunity opp=[select id,name,stageName,closedate,AccountId,OwnerId,E_Sign_Status__c,Business_POC_Name__c,
                         Finance_POC_For_Invoice_Processing_Name__c,Tax_Head_Name__c,Finance_Head_Name__c,IT_Head_Name__c,Period_Start_date__c,	
                         Period_End_date__c,E_Sign_Customer_Info__c,Billing_Frequency__c,Billing_Address__c,Billing_F__c,Billing_GST__c,PAN_No_as_per_PO__c,
                         If_SEZ__c,Payment_Method__c,Payment_Term__c,TAN__c,Place_of_Supply__c,Legal_Entity_Name_Of_The_Client__c,
                         PO_Required__c,PO_number__c,PO_Amount__c,Special_Terms__c,Shipping_Address__c from opportunity limit 1];
        
        opp.E_Sign_Status__c='E-Sign Successful';
        update opp;
        list<Product2> p=[select id,Name,Billing_Type__c,Family from product2];
        list<Product2> listOFpro=new list<Product2>(); 
        for(product2 p1:p){
            p1.Billing_Type__c ='OTP';
            p1.Family='ASP/GSP';
            p1.Product_category__c='Others';
            listofpro.add(p1);
        }
        update listofpro;
        Quote q=[select id,Type_of_Integration__c from quote limit 1];
        
        PageReference pageRef = Page.generateOrderForm;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id',opp.id);
        
        
        // Test.startTest();
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF = new generateOrderFormPDF(sc);
        
        //generateOrderFormPDF.saveOrderFormToOpportunity(opp.Id);
        //Test.stopTest();
        listofpro.clear();
        for(product2 p1:p){
            p1.Billing_Type__c ='OTP';
            p1.Family='E-Way Bill';
            p1.Product_category__c='Others';
            listofpro.add(p1);
        }
        update listofpro;
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF1 = new generateOrderFormPDF(sc);
        test.stopTest() ;
    }
    @isTest
    public static void test4(){
       test.startTest() ; 
        Opportunity opp=[select id,name,stageName,closedate,AccountId,OwnerId,E_Sign_Status__c,Business_POC_Name__c,
                         Finance_POC_For_Invoice_Processing_Name__c,Tax_Head_Name__c,Finance_Head_Name__c,IT_Head_Name__c,Period_Start_date__c,	
                         Period_End_date__c,E_Sign_Customer_Info__c,Billing_Frequency__c,Billing_Address__c,Billing_F__c,Billing_GST__c,Billing_Method__c,PAN_No_as_per_PO__c,
                         If_SEZ__c,Payment_Method__c,Payment_Term__c,TAN__c,Place_of_Supply__c,Legal_Entity_Name_Of_The_Client__c,
                         PO_Required__c,PO_number__c,PO_Amount__c,Special_Terms__c,Shipping_Address__c from opportunity limit 1];
        
        opp.E_Sign_Status__c='E-Sign Successful';
        update opp;
        list<Product2> p=[select id,Name,Billing_Type__c,Family from product2];
        list<Product2> listOFpro=new list<Product2>(); 
        for(product2 p1:p){
            p1.Billing_Type__c ='OTP';
            p1.Family='EINV';
            p1.Product_category__c='Others';
            listofpro.add(p1);
        }
        update listofpro;
        Quote q=[select id,Type_of_Integration__c from quote limit 1];
        //q.Type_of_Integration__c='API- Only by Customer';
        // update q;
        
        PageReference pageRef = Page.generateOrderForm;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id',opp.id);
        
        
        // Test.startTest();
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF = new generateOrderFormPDF(sc);
        
        //generateOrderFormPDF.saveOrderFormToOpportunity(opp.Id);
        //Test.stopTest();
      test.stopTest() ;  
    }
    @isTest
    public static void test5(){
        test.startTest() ;
        Opportunity opp=[select id,name,stageName,closedate,AccountId,OwnerId,E_Sign_Status__c,Business_POC_Name__c,
                         Finance_POC_For_Invoice_Processing_Name__c,Tax_Head_Name__c,Finance_Head_Name__c,IT_Head_Name__c,Period_Start_date__c,	
                         Period_End_date__c,E_Sign_Customer_Info__c,Billing_Frequency__c,Billing_Address__c,Billing_F__c,Billing_GST__c,Billing_Method__c,PAN_No_as_per_PO__c,
                         If_SEZ__c,Payment_Method__c,Payment_Term__c,TAN__c,Place_of_Supply__c,Legal_Entity_Name_Of_The_Client__c,
                         PO_Required__c,PO_number__c,PO_Amount__c,Special_Terms__c,Shipping_Address__c from opportunity limit 1];
        
        opp.E_Sign_Status__c='E-Sign Successful';
        update opp;
        list<Product2> p=[select id,Name,Billing_Type__c,Family from product2];
        list<Product2> listOFpro=new list<Product2>(); 
        for(product2 p1:p){
            p1.Billing_Type__c ='OTP';
            p1.Family='E-Way Bill';
            listofpro.add(p1);
        }
        update listofpro;
        Quote q=[select id,Type_of_Integration__c from quote limit 1];
        PageReference pageRef = Page.generateOrderForm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',opp.id);
        // Test.startTest();
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF = new generateOrderFormPDF(sc);
        //generateOrderFormPDF.saveOrderFormToOpportunity(opp.Id);
        //Test.stopTest();
     test.stopTest() ;   
    }
    @isTest
    public static void test6(){
        test.startTest() ;
        Opportunity opp=[select id,name,stageName,closedate,AccountId,OwnerId,E_Sign_Status__c,Business_POC_Name__c,
                         Finance_POC_For_Invoice_Processing_Name__c,Tax_Head_Name__c,Finance_Head_Name__c,IT_Head_Name__c,Period_Start_date__c,	
                         Period_End_date__c,E_Sign_Customer_Info__c,Billing_Frequency__c,Billing_Address__c,Billing_F__c,Billing_GST__c,Billing_Method__c,PAN_No_as_per_PO__c,
                         If_SEZ__c,Payment_Method__c,Payment_Term__c,TAN__c,Place_of_Supply__c,Legal_Entity_Name_Of_The_Client__c,
                         PO_Required__c,PO_number__c,PO_Amount__c,Special_Terms__c,Shipping_Address__c from opportunity limit 1];
        
        opp.E_Sign_Status__c='E-Sign Successful';
        update opp;
        list<Product2> p=[select id,Name,Billing_Type__c,Family from product2];
        list<Product2> listOFpro=new list<Product2>(); 
        for(product2 p1:p){
            p1.Billing_Type__c ='OTP';
            p1.Family='E-Way Bill';
            listofpro.add(p1);
        }
        update listofpro;
        Quote q=[select id,Type_of_Integration__c from quote limit 1];
        PageReference pageRef = Page.generateOrderForm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',opp.id);
        // Test.startTest();
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF = new generateOrderFormPDF(sc);
        //generateOrderFormPDF.saveOrderFormToOpportunity(opp.Id);
        //Test.stopTest();
        //
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF1 = new generateOrderFormPDF(sc);
        
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc2 = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF2 = new generateOrderFormPDF(sc);
        generateOrderFormPDF.getOpportunityDetalsOnLoad(opp.Id);
        ApexPages.StandardController sc3 = new ApexPages.StandardController(opp);
        generateOrderFormPDF generateOF3 = new generateOrderFormPDF(sc);
       test.stopTest() ; 
    }
}