@isTest
public class CTX_HelpAndSupportController_TEST {
    
    @testsetup
    public static void setup(){
        Contact conInst = new Contact(LastName='test', Email='test@xyx.com');
        insert conInst;
        
        Test.setMock(HttpCalloutMock.class, new CTX_MockCalloutResponse());
        Case caseInst = new Case(ContactId=conInst.Id, Products_Available__c='GST', Type='Problem', Subject='Test Case Subject', Description='Test Case Description');
        insert caseInst;
    }
    
    @isTest
    public static void getProductsandIssueTypes_TEST(){
        CTX_HelpAndSupportController.ProductsAndIssueTypeWrapper testWrap = CTX_HelpAndSupportController.getProductsandIssueTypes();
        system.assert(!testWrap.issueTypes.isEmpty());
        system.assert(!testWrap.productsAvailable.isEmpty());
    }
    
    @isTest
    public static void sendOTPtoEmail_TEST(){
        CTX_HelpAndSupportController.ContactAndOTPReturnWrapper testWrap1 = CTX_HelpAndSupportController.sendOTPtoEmail('test@xyx.com');
        Contact con = [SELECT Id, Name FROM Contact WHERE LastName = 'test' LIMIT 1];
        system.assertEquals(con.Id, testWrap1.availableContact.Id);
        system.assert(!String.isBlank(testWrap1.returnOTP));
    }
    
    @isTest
    public static void createCustomerCaseWithoutAttachment_TEST(){
        Test.setMock(HttpCalloutMock.class, new CTX_MockCalloutResponse());
        Case caseInst = CTX_HelpAndSupportController.createCustomerCase('', 'test', 'test@xyx.com', 'GST', 'Problem', 'Test Subject', 'Test Description', null, null);
        Contact con = [SELECT Id, Email FROM Contact WHERE LastName = 'test' LIMIT 1];
        system.assertEquals(con.Id, caseInst.ContactId);
        
    }
    
    @isTest
    public static void createCustomerCaseWithAttachment_TEST(){
        String txtAttachment = '<HTML><BODY><p>This is a Test Document<p></BODY></HTML>';
        Blob pdfAttachment = Blob.toPdf(txtAttachment);
        
        CTX_HelpAndSupportController.FileInfo attachmentInfo = new CTX_HelpAndSupportController.FileInfo();
        attachmentInfo.Title = 'testDocument';
        attachmentInfo.VersionData = pdfAttachment;
        String serialisedAttachment = JSON.serialize(attachmentInfo);
        List<object> attachmentList = new List<object>{attachmentInfo};
            
        Test.setMock(HttpCalloutMock.class, new CTX_MockCalloutResponse());
        Case caseInst = CTX_HelpAndSupportController.createCustomerCase('', 'test', 'test@xyx.com', 'GST', 'Problem', 'Test Subject', 'Test Description', null, attachmentList);
        Contact con = [SELECT Id, Email FROM Contact WHERE LastName = 'test' LIMIT 1];
        system.assertEquals(con.Id, caseInst.ContactId);
        
    }
    
    @isTest
    public static void getCaseForConEmail_TEST(){
        Contact con = [SELECT Id, Email FROM Contact WHERE LastName = 'test' LIMIT 1];
        List<Case> caseList = CTX_HelpAndSupportController.getCaseForConEmail(con.Email);
        System.assertEquals(con.Email, caseList[0].ContactEmail);
        
    }

}