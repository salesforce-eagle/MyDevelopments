/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-07-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class CTX_HelpAndSupportController {
    @AuraEnabled (cacheable=true)
    global static ProductsAndIssueTypeWrapper getProductsandIssueTypes(){
        
        ProductsAndIssueTypeWrapper wrap = new ProductsAndIssueTypeWrapper();
        
        wrap.productsAvailable = System.Label.Available_Products?.split(',');
        wrap.issueTypes = System.Label.Case_Issue_Type?.Split(',');
        
        return wrap;
    }
    
    @AuraEnabled
    global Static ContactAndOTPReturnWrapper sendOTPtoEmail(String contactEmail){
        
        ContactAndOTPReturnWrapper thisWerpperResult = new ContactAndOTPReturnWrapper();
        for(
            Contact thisCon : [ SELECT Id, Name, AccountId 
                               FROM Contact WHERE 
                               Email =: contactEmail 
                               ORDER BY CreatedDate DESC LIMIT 1 ]
        ){
            thisWerpperResult.availableContact = thisCon;
        }
        
        String rand = string.valueof(Math.abs(Crypto.getRandomInteger())).substring(0,6);
        thisWerpperResult.returnOTP = rand;
        
        try{
            CTX_CaseTracker_OTP_Email_Helper.sendOTPEmail(contactEmail, thisWerpperResult.returnOTP);
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return thisWerpperResult;
    }
    
    @AuraEnabled
    global Static Case createCustomerCase(
        String 			firstName,
        String 			lastName,
        String 			contactEmail,
        String			availableProduct,
        String			issueType,
        String			subject,
        String			description,
        String			contactId,
        List<object>	fileDetails
    ){
        
        Case createCase 					= new Case();
        createCase.Products_Available__c 	= availableProduct;
        createCase.Type 					= issueType;
        createCase.Subject 					= subject;
        createCase.Description 				= description;
        createCase.SuppliedEmail			= contactEmail;
        createCase.SuppliedName				= firstName +' '+lastName;
        createCase.Origin					= 'Web';
        
        insert createCase;
        
        if(fileDetails != null){
            if(!fileDetails.isEmpty()){
                list<Id> lstCntVerIds = new list<Id>();
                List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
                for (Object file : fileDetails) {
                    FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
                    ContentVersion objCntVersion = new ContentVersion();
                    objCntVersion.PathOnClient = fileData.Title;
                    objCntVersion.Title = fileData.Title;
                    objCntVersion.VersionData = fileData.VersionData;
                    lstVersionsToInsert.add(objCntVersion);
                }
                
                list<Database.saveResult> res = Database.insert(lstVersionsToInsert);
                for (Database.SaveResult saveResult : res) {
                    if(saveResult.isSuccess()) {
                        lstCntVerIds.add(saveResult.getId());
                    }
                }
                
                List<ContentDocumentLink> ctnLinks = new List<ContentDocumentLink>();
                for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: lstCntVerIds]){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cv.ContentDocumentId;
                    cdl.LinkedEntityId = createCase.Id;
                    cdl.ShareType = 'V';
                    ctnLinks.add(cdl);
                }
                insert ctnLinks;
            }
        }
        System.debug('createCase: '+createCase.Id);
        return [SELECT CaseNumber, ContactId FROM Case WHERE Id =: createCase.Id];
    }
    @AuraEnabled
    global static List<Case> getCaseForConEmail(String conEmail){
        List<String> restrictedStatus = new List<String>{CaseConstants.STATUS_SOLVED,CaseConstants.STATUS_CLOSED};
            List<Case>  caseList = [SELECT Id, IsDeleted, MasterRecordId, CaseNumber, ContactId, AccountId, AssetId, ProductId, EntitlementId, SourceId
                                    , BusinessHoursId, ParentId, SuppliedName, SuppliedEmail, SuppliedPhone, SuppliedCompany, Type, RecordTypeId, Status
                                    , Reason, Origin, Language, Subject, Priority, Description, IsClosed, ClosedDate, IsEscalated, CurrencyIsoCode, OwnerId
                                    , IsClosedOnCreate, SlaStartDate, SlaExitDate, IsStopped, StopStartDate, CreatedDate, CreatedById, LastModifiedDate
                                    , LastModifiedById, SystemModstamp, ContactPhone, ContactMobile, ContactEmail, ContactFax, Comments, LastViewedDate
                                    , LastReferencedDate, MilestoneStatus, Account_Type__c, BillingAccountId__c, BusinessId__c, Case_Owners_Manager_Email__c
                                    , Case_Resolution__c, Case_Solved_DataTime__c, Case_Sub_Origin__c, Customer_Organisation__c, Customer_Segment__c
                                    , Customer_Type__c, Customer_Wait_Time_Violation_Date_Time__c, DateTime_To_auto_Close_B2B__c, DateTime_To_auto_Close_on_B2C_and_B2B_CA__c,
                                    Do_Not_Send_Public_Replies__c, Do_not_send_Automated_mails__c, Do_not_send_CSAT__c, Email_Source__c, First_Reply_Sent__c
                                    , First_Reply_Violation_DateTime__c, Followup_Parent_Case__c, Functional_Area__c, Google_Form_Attachments_URL__c, Web_Form_Submitter_Email__c,
                                    Google_Form_Submitter__c, Handle_BackEnd_Validation_Off__c, Hyperlink_URL__c, IT_Email_ID__c, IsParentCase__c, IsPending_To_auto_close__c, Is_Customer_Unblocked__c
                                    , Is_Internal_Comment_Created__c, Is_Owner_Changed__c, Issue_Type_1__c, Issue_Type_2__c, Issue_Type_3__c, Issue_Type__c, Last_update_sent__c, Latest_CaseComment__c,
                                    Latest_EmailMessage__c, Latest_Reopen_Date__c, Lookup_Issue_Type__c, Old_Owner_TL_Manager_Email__c, Owner_Profile_Name__c, POD_Group__c, Pausable_Update__c, Periodic_Update_Violation_DateTime__c, Periodic_Update__c, Plan_Type__c
                                    , Previous_Owner_EmailId__c, Previous_Owner_Id__c, Previous_Owner__c, Product_Type__c, Sub_Status__c, Survey_Question_1__c, Survey_Question_2__c, Survey_Question_3__c, Survey_Response_2__c, Survey_Response_3__c, Survey_Response_Completion_Date_Time__c, Survey_Sent_Date__c, Survey_send__c, UserId__c, User_Segment__c,
                                    reopen_count__c, survey_response_1__c, Lookup_Issue_Type1__c, Issue_Type_4__c, Incoming_Email_Count__c, Case_Owner_Department__c, Lookup_Issue_Type_EInv__c, Case_Closed_Age_In_minutes__c, Case_Created_Age_in_Minutes__c,
                                    IsSolved__c, Time_take_to_Solve_the_case_minutes__c, SolvedOnCreation__c, Actual_Customer_Email__c,
                                    GSTN__c, Previous_Queue_Id__c, Related_Project__c, Back_End_Status__c, Create_Survey__c, LastPodAssignTime__c, Bulk_Email_auto_and_validation_handler__c, IsCaseReopened__c,
                                    Priority__c, Solved__c, User_Role_Type__c, Case_Owner__c, Case_Record_Type__c, Auto_Response_Sent__c, E_invoice_product_type__c, Survey_Question_4__c,
                                    Survey_Response_4__c, SLA_Time__c, SLA_Time_updated_from_Alert__c, SLA_time_calculated__c, Queue_Distribution_mail__c, Country__c, CCEmailAddress__c, Auto_Response_Sent_To_CC__c, Invoice_Number__c,
                                    Contact_Name__c, IsMerged__c, inov8__PMT_Days_Open__c, inov8__PMT_Program__c, inov8__PMT_Project__c, Account_Name__c, JIRA_Issue_Id__c, Updated_in_JIRA__c,
                                    Product_Route_Type__c, Einvoice_number__c, SLA_Breach_Time__c, First_touch_resolution_count__c, Case_TAT__c, Webform_case_by_Clear_team__c, Is_Case_Tracker_Used__c, Case_Tracker_Counter__c,
                                    SLA_Running_Solved__c, Account_Collection_Manager_Email__c, Account_Collection_Manager__c, Last_Agent_Email_Message__c, Products_Available__c
                                    FROM Case WHERE ContactEmail =: conEmail AND Status NOT IN:restrictedStatus] ; 
        return caseList;
    }
    
    global Class ContactAndOTPReturnWrapper{
        @AuraEnabled
        public Contact	availableContact {get;set;}
        @AuraEnabled
        public String	returnOTP {get;set;}
    }
    
    global class ProductsAndIssueTypeWrapper {
        @AuraEnabled
        public List<String> productsAvailable {get;set;}
        @AuraEnabled
        public List<String> issueTypes {get;set;}
        
    }
    
    global class FileInfo {
        public String Title;
        public Blob VersionData;
    }
    
}