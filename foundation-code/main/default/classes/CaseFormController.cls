global without sharing class CaseFormController {
    
    public String[] teams=new String[]{};
        //global static String domainName{get;set;}
        public boolean validDomain{get;set;}
    global static String loggedEmailID{get;set;}
    global static String loggedUserName{get;set;}
    public String callSubmit{get;set;}
    
    public string VFMessage{get;set;}
    
    global static String searchTerm {get; set;}
    global static String selectedIssueType {get; set;}
    global String caseId{get;set;}
    
    //global static String selectedMovie {get; set;}
    
    public String showSignIn{get;set;}
    public boolean isShowSignInTrue {get;set;}
    public boolean rend1 {get;set;}
    
    public String suppliedEmail {get;set;}
    public String suppliedPhone {get;set;}
    
    public String hyperLink {get;set;}
    public Id issueType {get;set;}
    public Case caseInstance {get;set;}
    public String clientId {get;set;}
    public String queryString{get;set;}
    public List<Case> caseList{get;set;}
    public String recordType{get;set;}
    
    public List<SelectOption> B2B_Customer_Segment_Enterprise{get;set;} // Enhancement
    public List<SelectOption> B2B_Customer_Segment_EnterpriseMaxITC{get;set;}
    public List<SelectOption> B2B_Customer_Segment_EnterpriseClearId{get;set;}
    public List<SelectOption> B2B_Customer_Segment_EnterpriseClearCapture{get;set;}
    public List<SelectOption> B2B_Customer_Segment_EnterpriseClearInvoice{get;set;}
    public List<SelectOption> B2B_Customer_Segment_Einvoice{get;set;}//Enhancement
    public List<SelectOption> B2B_Customer_Segment_CA_SME{get;set;}
    public List<SelectOption> B2B_Customer_Segment_For_Web_Case_GCC_E_invoice{get;set;} // Enhancement
    public List<SelectOption> B2C_Customer_Segment{get;set;}
    Public String B2B_Customer_Segment_Selected{get;set;}
    Public String B2C_Customer_Segment_Selected{get;set;}
    
    public List<SelectOption> E_invoice_product_type_Options{get;set;}//Enhancement
    public List<SelectOption> Product_type_Options{get;set;}//Enhancement
    public List<SelectOption> Product_type_OptionsMaxITC{get;set;}
    public List<SelectOption> Product_type_OptionsClearId{get;set;}
    public List<SelectOption> Product_type_OptionsClearInvoice{get;set;}
    public List<SelectOption> Product_type_OptionsClearCapture{get;set;}
    public List<SelectOption> Product_type_OptionsB2BCASME{get;set;}//Enhancement
    Public String E_invoice_product_type_Selected{get;set;}
    Public String Product_type_Selected{get;set;}
    
    
    
    public static string team{get;set;}
    public string team1{get;set;}
    public boolean showGST{get;set;}
    public boolean showConsumer{get;set;}
    public boolean showteams {get;set;}
    
    public string  newCaseId{get;set;}
    public string googleIDToken {get;set;}
    private External_System_Authentication__c googleAutInfo;
    // Public List<SelectOption> accList{get;set;}
    Public List<SelectOption> b2bIssueTypes{get;set;}
    Public List<SelectOption> eInvIssueTypes{get;set;}
    Public List<SelectOption> b2cIssueTypes{get;set;}
    Public List<SelectOption> internationalCountryList{get;set;}
    Public String internationalCountry_Selected{get;set;}
    
    public boolean pb2Rendered{get;set;} // true -> show pb2
    public boolean pb3Rendered{get;set;} // true -> show pb3
    private boolean showForm;
    public boolean showFormUI {get;set;}
    public boolean showsingoutButton {get;set;}
    Cleartax_Org_Configuration__c orgConfig;
    Map<String,String> queueNametoId = new Map<string,String>();
    private string loggedInUserEmail;
    private id cleartaxaccountid;
    
    public boolean showGSTIN{get;set;}
    
    public CaseFormController(ApexPages.StandardController caseController  ){
        
        orgConfig = Cleartax_Org_Configuration__c.getInstance();
        this.recordType='B2B - Enterprise';
        this.showteams=true;
        showGST=showConsumer=false;
        showsingoutButton=false;
        newCaseId='';
        pb2Rendered = pb3Rendered = false;
        caseInstance=null;
        
        //Pramodh Added // Enhancement  by Lokesh
        B2B_Customer_Segment_CA_SME = New List<SelectOption>();
        //B2B_Customer_Segment_CA_SME.add(new SelectOption('None','--None--'));
        //Enhancement
        for(String tempOption : System.Label.B2B_Customer_Segment_For_Web_Case_CASME.split(',')){
            B2B_Customer_Segment_CA_SME.add(new SelectOption(tempOption,tempOption));
        }
        // Enhancement  by Lokesh
        B2B_Customer_Segment_Enterprise = New List<SelectOption>();
        B2B_Customer_Segment_EnterpriseMaxITC = New List<SelectOption>();
        B2B_Customer_Segment_EnterpriseMaxITC.add(new SelectOption('Max ITC','Max ITC'));
        B2B_Customer_Segment_EnterpriseClearId = New List<SelectOption>();
        B2B_Customer_Segment_EnterpriseClearId.add(new SelectOption('Clear Id','Clear Id'));
        B2B_Customer_Segment_EnterpriseClearCapture = New List<SelectOption>();
        B2B_Customer_Segment_EnterpriseClearCapture.add(new SelectOption('Clear Capture','Clear Capture'));
        B2B_Customer_Segment_EnterpriseClearInvoice = New List<SelectOption>();
        B2B_Customer_Segment_EnterpriseClearInvoice.add(new SelectOption('Clear Invoice','Clear Invoice'));
        //B2B_Customer_Segment_Enterprise.add(new SelectOption('None','--None--'));
        for(String tempOption : System.Label.B2B_Customer_Segment_For_Web_Case_Enterprise.split(',')){
            B2B_Customer_Segment_Enterprise.add(new SelectOption(tempOption,tempOption));
        }
        
        B2B_Customer_Segment_Einvoice = New List<SelectOption>();
        //B2B_Customer_Segment_Einvoice.add(new SelectOption('None','--None--'));
        for(String tempOption : System.Label.B2B_Customer_Segment_For_Web_Case_E_invoice.split(',')){
            B2B_Customer_Segment_Einvoice.add(new SelectOption(tempOption,tempOption));
        }
        
        B2B_Customer_Segment_For_Web_Case_GCC_E_invoice = New List<SelectOption>();
        for(String tempOption : System.Label.B2B_Customer_Segment_For_Web_Case_GCC_E_invoice.split(',')){
            B2B_Customer_Segment_For_Web_Case_GCC_E_invoice.add(new SelectOption(tempOption,tempOption));
        }
        B2C_Customer_Segment = New List<SelectOption>();
        B2C_Customer_Segment.add(new SelectOption('None','--None--'));
        for(String tempOption : System.Label.B2C_Customer_Segment_For_Web_Case.split(',')){
            B2C_Customer_Segment.add(new SelectOption(tempOption,tempOption));
        }
        //Pramodh Ended
        ////E product type Enhancement start
        E_invoice_product_type_Options = New List<SelectOption>();
        E_invoice_product_type_Options.add(new SelectOption('None','--None--'));
        for(String tempOption : System.Label.E_invoice_product_type.split(',')){
            E_invoice_product_type_Options.add(new SelectOption(tempOption,tempOption));
        }        
        //E product type Enhancement end
        
        Product_type_Options = New List<SelectOption>();
        Product_type_OptionsMaxITC = New List<SelectOption>();
        Product_type_OptionsMaxITC.add(new SelectOption('MaxITC','MaxITC'));
        Product_type_OptionsClearId = New List<SelectOption>();
        Product_type_OptionsClearId.add(new SelectOption('Clear Id','Clear Id'));
        Product_type_OptionsClearCapture = New List<SelectOption>();
        Product_type_OptionsClearCapture.add(new SelectOption('Clear Capture','Clear Capture'));
        Product_type_OptionsClearInvoice = New List<SelectOption>();
        Product_type_OptionsClearInvoice.add(new SelectOption('Clear Invoice','Clear Invoice'));
        Product_type_OptionsB2BCASME = New List<SelectOption>();
        Product_type_Options.add(new SelectOption('None','--None--'));
        for(String tempOption : System.Label.Product_Type.split(',')){
            Product_type_Options.add(new SelectOption(tempOption,tempOption));
        }  
        for(String tempOption : System.Label.Product_Type_B2BCASME.split(',')){
            Product_type_OptionsB2BCASME.add(new SelectOption(tempOption,tempOption));
        }
        
        internationalCountryList = New List<SelectOption>();
        internationalCountryList.add(new SelectOption('None','--None--'));
        for(String tempOption : System.Label.InternationalCountryList.split(',')){
            internationalCountryList.add(new SelectOption(tempOption,tempOption));
        }
        //caseInstance = new case();
        caseInstance = (case)caseController.getRecord();
        validDomain = false;
        List<External_System_Authentication__c> googleAutInfoLst=[select id,Client_Id__c,Google_ISS_Value1__c,Google_ISS_Value2__c,Google_Domain_Allowed__c from External_System_Authentication__c where API_Type__c='Google Form Authentication' and RecordType.name='Google' limit 1];
        if(googleAutInfoLst.size()>0){
            
            googleAutInfo=googleAutInfoLst.get(0);
        }
        
        List<Issue_Type__c> issueTypeLst=[select id,Name,Case_Type__c from Issue_Type__c];
        //accList = new List<SelectOption>();
        b2bIssueTypes = new List<SelectOption>();
        eInvIssueTypes = new List<SelectOption>();
        b2cIssueTypes = new List<SelectOption>();
        /**for(account acc: [select id,Name from account order by name limit 50000]){
accList.add(new SelectOption(acc.id,acc.name));
}**/
        for(Issue_Type__c issue: issueTypeLst){
            
            if(issue.Case_Type__c=='B2B'){  
                b2bIssueTypes.add(new SelectOption(issue.id,issue.name));
            }   
            if(issue.Case_Type__c=='B2C'){
                b2cIssueTypes.add(new SelectOption(issue.id,issue.name));
            }
            if(issue.Case_Type__c=='EInv'){
                eInvIssueTypes.add(new SelectOption(issue.id,issue.name));
            }
        }
        showForm=false;
        showFormUI=false;
        //Intenational
        /* case newcase=new case();
internationalCountry = CaseFormController.getPicklistValues(newcase,'Country__c');
system.debug('internationalCountry--->'+internationalCountry);*/
        Set<String> qeueuNames= new Set<String>();
        
        if(orgConfig.GST_Web_form_Case_Queue__c!=null){
            qeueuNames.add(orgConfig.GST_Web_form_Case_Queue__c);
        }
        if(orgConfig.Consumer_Web_Form_Case_Queue__c!=null){
            qeueuNames.add(orgConfig.Consumer_Web_Form_Case_Queue__c);
        }
        if(orgConfig.E_Invoice_Web_form_Case_Queue__c!=null){
            qeueuNames.add(orgConfig.E_Invoice_Web_form_Case_Queue__c);
        }
        if(orgConfig.E_Invoice_Web_form_Case_Queue__c!=null){
            qeueuNames.add(orgConfig.GCC_E_Invoice_Queue__c);
        }
        //Added By Kartikeya
        if(orgConfig.GST_B2B_Enterprise__c!=null){
            qeueuNames.add(orgConfig.GST_B2B_Enterprise__c);
        }
        //End By Kartikeya
        
        if(qeueuNames.size()>0){
            
            List<Group> queues= [select Id,developername  from Group where  Type = 'Queue' AND developername IN:qeueuNames ];
            
            for(Group gp : queues){
                
                queueNametoId.put(gp.developername.toUpperCase(),gp.id);
            }
        }
        
        system.debug('***b2bIssueTypes'+b2bIssueTypes);
        List<account> accLstglobal=[select id from account where name=:CaseConstants.Global_Cleartax and recordtype.name='cleartax'  limit 1];
        
        // move the cleartax in constant class
        if(accLstglobal.size()>0){
            cleartaxaccountid=accLstglobal.get(0).id;
        }
        
        System.debug('@team1'+team1);
    }
    
    public List<SelectOption> getB2BIssues() {
        
        return b2bIssueTypes;
    }
    /**   public List<SelectOption> getaccList() {

return accList;
}**/
    
    public List<SelectOption> getB2CIssues() {
        
        return b2cIssueTypes;
    }
    
    public void selectedRecordType(){
        if(team1 == 'B2B Enterprise'){
            caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B Enterprise').getRecordTypeId();
        }else if(team1 == 'Consumer'){
            caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        }else if(team1 == 'B2B CA/SME'){
            caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B CA/SME').getRecordTypeId();
        }else if(team1 == 'E Invoice'){
            caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.Case_RECORDTYPENAME_E_INVOICING).getRecordTypeId();
        }else if(team1 == 'International'){
            caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(CaseConstants.Case_RECORDTYPENAME_International).getRecordTypeId();
        }else if(team1 == 'Internal Case'){
            caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Issue').getRecordTypeId();
        }
        else if(team1 == 'Clear Identity'){
            caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clear Identity').getRecordTypeId();
        }
       else if(team1 == 'Clear Invoice'){
            caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clear Invoice').getRecordTypeId();
        }
        else if(team1 == 'Clear Capture'){
            caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clear Capture').getRecordTypeId();
        }
        else if(team1 == 'Max ITC'){
            caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Max ITC').getRecordTypeId();
        }
    }
    
    public void showSignIn() {
        //the name of the parameter must be the same as it set in apex:param tag
        this.showSignIn = apexpages.currentPage().getParameters().get('inpval');
        System.debug('showSignIn'+showSignIn);
        
    }
    
    public List<Schema.FieldSetMember> getconsumerfields() {
        return SObjectType.Case.FieldSets.CaseForm_Consumer_Field_Set.getFields();
    }
    public List<Schema.FieldSetMember> getgstfields() {
        return SObjectType.Case.FieldSets.CaseForm_GST_Field_Set.getFields();
    }
    
    public void emailId() {//,
        System.debug('whole '+loggedEmailID +'Mail ');//+loggedEmailID.getEmail());
        string domainName = loggedEmailID.substringBetween('@', '.');
        string googleIDToken = googleIDToken;
        system.debug('****googleIDToken'+googleIDToken);
        newCaseId='';
        //system.debug('******'+isValidUser(loggedEmailID,googleIDToken));
        GoogleValidationResponse GAuth = isValidUser(loggedEmailID,googleIDToken);
        VFMessage = GAuth.message;
        If(GAuth.isValidUser ){
            showFormUI = true;
            showForm=true;
        }else if(!GAuth.isValidUser && domainName == 'loggedout'){
            loggedEmailID = null;
            showFormUI = false;
            showForm=false;
            showsingoutButton=false;
        }else{
            validDomain = false;
            showFormUI = false;
            showForm=false;
            showsingoutButton=true;
        }
        
        
    }  
    
    
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','--None--')); 
        options.add(new SelectOption('B2B CA/SME','B2B CA/SME')); 
        options.add(new SelectOption('B2B Enterprise','B2B Enterprise'));
        options.add(new SelectOption('E Invoice','E Invoice'));  
        options.add(new SelectOption('Consumer','Consumer'));
        options.add(new SelectOption('International','International'));
        options.add(new SelectOption('Internal Case','Internal Case'));
        options.add(new SelectOption('Clear Identity','Clear Identity'));
        options.add(new SelectOption('Clear Invoice','Clear Invoice'));
        options.add(new SelectOption('Clear Capture','Clear Capture'));
        options.add(new SelectOption('Max ITC','Max ITC'));
        return options;
    }
    
    
    
    public boolean hasError=false;
    public string errormsg='';
    
    public void insertCase(){
        hasError=false;
        errormsg='';
        system.debug('#rec'+caseInstance.RecordTypeId);
        system.debug('****inside'+caseInstance.Lookup_Issue_Type__c);
        system.debug('****inside case'+caseInstance);
        
        
        
        List<QueueID_DistributionMailMapping__mdt> Queue_DistributionList =DataBase.query(UtilityClass.getQueryString('QueueID_DistributionMailMapping__mdt')+' FROM QueueID_DistributionMailMapping__mdt');
        Map <string,string>  Queue_DistributionMap=new Map <string,string>();
        for(QueueID_DistributionMailMapping__mdt thisQueue : Queue_DistributionList){
            Queue_DistributionMap.put(thisQueue.Queue_Id__c, thisQueue.DistributionEmailId__c);
        }
        newCaseId='';
        caseInstance.E_invoice_product_type__c =E_invoice_product_type_Selected;
        caseInstance.country__c =internationalCountry_Selected;
        caseInstance.Product_Route_Type__c  =Product_type_Selected;
        
        //GSTIN check
        CaseConstants.team1 = this.team1;
        System.debug('#team1'+CaseConstants.team1);
        System.debug('#team1'+caseInstance.RecordTypeId);
        String emailRegex='\\d{2}[A-Z]{5}\\d{4}[A-Z]{1}[A-Z\\d]{1}[Z]{1}[A-Z\\d]{1}';
        boolean result=false;
        Pattern EmailPattern = Pattern.compile(emailRegex);
        
        If(caseInstance.GSTN__c !=null){
            Matcher EmailMatcher = EmailPattern.matcher(caseInstance.GSTN__c);
            
            if(EmailMatcher.matches())
            {
                result = true;
            }
            
        }
        system.debug('result--->'+result);
        if(caseInstance.Customer_Segment__c != null && caseInstance.Customer_Segment__c != ''){
            if(System.Label.B2B_Customer_Segment_For_Web_Case_Enterprise.split(',').contains(caseInstance.Customer_Segment__c)){
                //B2B Enterprise
                caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B Enterprise').getRecordTypeId();
                if(caseInstance.Priority==null){
                    caseInstance.Priority=Label.Case_Form_B2B_Enterprise_Default_Priority;
                }
            }else if(System.Label.B2B_Customer_Segment_For_Web_Case_CASME.split(',').contains(caseInstance.Customer_Segment__c)){
                //B2B Enterprise
                caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2B CA/SME').getRecordTypeId();
                if(caseInstance.Priority==null){
                    caseInstance.Priority=Label.Case_Form_B2B_CA_SME_Default_Priority;
                }
            }
            else if(System.Label.B2C_Customer_Segment_For_Web_Case.split(',').contains(caseInstance.Customer_Segment__c)){
                //B2C
                caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
                if(caseInstance.Priority==null){
                    caseInstance.Priority=Label.Case_Form_Consumer_Default_Priority;
                }
            }else if(Label.B2B_Customer_Segment_For_Web_Case_E_invoice.split(',').contains(caseInstance.Customer_Segment__c)){//Enhancement 
                caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(CAseConstants.Case_RECORDTYPENAME_E_INVOICING).getRecordTypeId();
                if(caseInstance.Priority==null){
                    caseInstance.Priority=Label.Case_Form_E_Invoice_Default_Priority;
                }
            }
            else if(Label.B2B_Customer_Segment_For_Web_Case_GCC_E_invoice.split(',').contains(caseInstance.Customer_Segment__c)){//Enhancement 
                caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get(CAseConstants.Case_RECORDTYPENAME_International).getRecordTypeId();
                if(caseInstance.Priority==null){
                    caseInstance.Priority=Label.Case_Form_E_Invoice_Default_Priority;
                }
            }
        }
        /* string emailToCheck='';
if(caseInstance.RecordTypeId == Constants.b2bCASMERTId &&  caseInstance.SuppliedEmail !=null || 
caseInstance.RecordTypeId != Constants.b2bCASMERTId &&  caseInstance.Actual_Customer_Email__c != null){
emailToCheck= caseInstance.RecordTypeId ==Constants.b2bCASMERTId &&  caseInstance.SuppliedEmail !=null ?
caseInstance.SuppliedEmail : (caseInstance.RecordTypeId != Constants.b2bCASMERTId && caseInstance.Actual_Customer_Email__c !=Null) ? 
caseInstance.Actual_Customer_Email__c:null ;
}
system.debug('****emailToCheck'+emailToCheck);
system.debug('****loggedInUserEmail'+loggedInUserEmail);
system.debug('--->1'+caseInstance.RecordTypeId  );
system.debug('--->2'+caseInstance.RecordTypeId );
system.debug('--->email1'+caseInstance.SuppliedEmail  );
system.debug('--->email2'+caseInstance.Actual_Customer_Email__c );*/
        
        boolean isPGL=false;
        if(team1=='B2B CA/SME' || (result && (team1=='B2B Enterprise' || team1=='E Invoice' || team1=='International' || team1=='Clear Identity' || team1=='Max ITC' || team1=='Clear Capture' || team1=='Clear Invoice'))){
            try{
                list<Contact> syncContact = new List<Contact>();
                if(caseInstance.SuppliedEmail != null){
                    syncContact = [select Id,AccountID,account.pgl_or_sb__c from Contact where Email =:caseInstance.SuppliedEmail ];
                    
                }
                system.debug('syncContact--->'+syncContact);
                if(syncContact.size()>0){
                    caseInstance.ContactId = syncContact[0].Id;
                    if(syncContact[0].AccountID!=null){
                        caseInstance.AccountID = syncContact[0].AccountID;
                        isPGL= syncContact[0].account.pgl_or_sb__c  == 'PGL' ?true:false;
                    }else{
                        Id accountId;
                        List<account> accLst=[select id,pgl_or_sb__c from account where name Like :+'%'+caseInstance.SuppliedCompany+'%'  limit 1];
                        system.debug('accLst;--->'+accLst.get(0).Id);
                        isPGL= accLst.get(0).pgl_or_sb__c  == 'PGL' ?true:false;                        
                        if(team1=='Consumer'){
                            if(!(accLst.size()>0)){
                                accountId = System.Label.GLOBAL_Account_B2C_for_Web_Form; 
                            }else{
                                accountId = accLst.get(0).Id;
                            }
                        }
                        else if(team1=='B2B Enterprise'){
                            if(!(accLst.size()>0)){
                                accountId = System.Label.GLOBAL_Account_B2B_for_Web_Form; 
                            }else{
                                accountId = accLst.get(0).Id;
                            }
                            
                        }else if(team1=='B2B CA/SME'){
                            if(!(accLst.size()>0)){
                                accountId = System.Label.GLOBAL_Account_B2B_CA_SME_for_Web_Form; 
                            }else{
                                accountId = accLst.get(0).Id;
                            }
                            
                        }
                        else if(team1=='Clear Identity'){
                            if(!(accLst.size()>0)){
                                accountId = System.Label.GLOBAL_Account_Clear_Identity; 
                            }else{
                                accountId = accLst.get(0).Id;
                            }
                            
                        }   
                          else if(team1=='Clear Invoice'){
                            if(!(accLst.size()>0)){
                                accountId = System.Label.GLOBAL_Account_Clear_Identity; 
                            }else{
                                accountId = accLst.get(0).Id;
                            }
                            
                        }  
                         else if(team1=='Clear Capture'){
                            if(!(accLst.size()>0)){
                                accountId = System.Label.GLOBAL_Account_Clear_Identity; 
                            }else{
                                accountId = accLst.get(0).Id;
                            }
                            
                        }
                        else if(team1=='Max ITC'){
                            if(!(accLst.size()>0)){
                                accountId = System.Label.GLOBAL_Account_Clear_Identity; 
                            }else{
                                accountId = accLst.get(0).Id;
                            }
                            
                        }
                        else if (team1=='E Invoice'){
                            if(!(accLst.size()>0)){
                                system.debug('accLst.get(0).Id global--->'+accLst.get(0).Id);
                                accountId = System.Label.Global_Account_for_E_invoice_Web_form; 
                            }else{
                                system.debug('accLst.get(0).Id--->'+accLst.get(0).Id);
                                accountId = accLst.get(0).Id;
                            }
                            
                        }
                        else if (team1=='International'){
                            if(!(accLst.size()>0)){
                                accountId = System.Label.Global_Account_for_GCC_E_invoice_Web_form; 
                            }else{
                                accountId = accLst.get(0).Id;
                            }
                        }
                        caseInstance.AccountId=accountId;
                        //Enhancement above else if Statement for CA/SME
                        //Added By kartikeya
                        //End By kartikeya
                    }
                    
                }else{
                    
                    Id accountId;
                    List<account> accLst=[select id,pgl_or_sb__c from account where name Like :+'%'+caseInstance.SuppliedCompany+'%'  limit 1];
                    List<account> intAccLst=[select id,pgl_or_sb__c from account where name Like :+'%'+caseInstance.SuppliedCompany+'%' AND recordtypeId =: CaseConstants.INTERNATIONAL_RecordTypeId  limit 1];
                    isPGL= accLst !=NULL && accLst.size() > 0 && accLst.get(0).pgl_or_sb__c  == 'PGL'  ?true:false;  
                    System.debug('in no contact body--->'+accLst);
                    if(team1=='Consumer'){
                        accountId = System.Label.GLOBAL_Account_B2C_for_Web_Form;  
                    }
                    else If(team1=='B2B Enterprise'){
                        //List<account> accLstglobal=[select id from account where name=:CaseConstants.Global_Cleartax and recordtype.name='cleartax'  limit 1];
                        if(caseInstance.SuppliedCompany==null){
                            // move the cleartax in constant class
                            accountId=System.Label.GLOBAL_Account_B2B_for_Web_Form;
                        }else if(caseInstance.SuppliedCompany!=null) {
                            if(accLst.size()>0){
                                accountId=accLst.get(0).id;
                            }else{
                                accountId=System.Label.GLOBAL_Account_B2B_for_Web_Form;
                            }
                        }
                        // accountId =  System.Label.GLOBAL_Account_B2B_for_Web_Form ;  
                    }else If(team1=='B2B CA/SME'){
                        if(caseInstance.SuppliedCompany==null){
                            // move the cleartax in constant class
                            accountId=System.Label.GLOBAL_Account_B2B_CA_SME_for_Web_Form;
                        }else if(caseInstance.SuppliedCompany!=null) {
                            if(accLst.size()>0){
                                accountId=accLst.get(0).id;
                            }else{
                                accountId=System.Label.GLOBAL_Account_B2B_CA_SME_for_Web_Form;
                            }
                            
                        }
                    }
                    else If(team1=='Clear Identity'){
                        if(caseInstance.SuppliedCompany==null){
                            // move the cleartax in constant class
                            accountId=System.Label.GLOBAL_Account_Clear_Identity;
                        }else if(caseInstance.SuppliedCompany!=null) {
                            if(accLst.size()>0){
                                accountId=accLst.get(0).id;
                            }else{
                                accountId=System.Label.GLOBAL_Account_Clear_Identity;
                            }
                            
                        }
                    }
                        else If(team1=='Clear Invoice'){
                        if(caseInstance.SuppliedCompany==null){
                            // move the cleartax in constant class
                            accountId=System.Label.GLOBAL_Account_Clear_Identity;
                        }else if(caseInstance.SuppliedCompany!=null) {
                            if(accLst.size()>0){
                                accountId=accLst.get(0).id;
                            }else{
                                accountId=System.Label.GLOBAL_Account_Clear_Identity;
                            }
                            
                        }
                    }
                        else If(team1=='Clear Capture'){
                        if(caseInstance.SuppliedCompany==null){
                            // move the cleartax in constant class
                            accountId=System.Label.GLOBAL_Account_Clear_Identity;
                        }else if(caseInstance.SuppliedCompany!=null) {
                            if(accLst.size()>0){
                                accountId=accLst.get(0).id;
                            }else{
                                accountId=System.Label.GLOBAL_Account_Clear_Identity;
                            }
                            
                        }
                    }
                                        else If(team1=='Max ITC'){
                        if(caseInstance.SuppliedCompany==null){
                            // move the cleartax in constant class
                            accountId=System.Label.GLOBAL_Account_Clear_Identity;
                        }else if(caseInstance.SuppliedCompany!=null) {
                            if(accLst.size()>0){
                                accountId=accLst.get(0).id;
                            }else{
                                accountId=System.Label.GLOBAL_Account_Clear_Identity;
                            }
                            
                        }
                    }
                    else If(team1=='E Invoice'){
                        System.debug('in no contact body 02--->'+accLst);
                        if(caseInstance.SuppliedCompany==null){
                            // move the cleartax in constant class
                            accountId=System.Label.Global_Account_for_E_invoice_Web_form;
                        }else if(caseInstance.SuppliedCompany!=null) {
                            if(accLst.size()>0){
                                accountId=accLst.get(0).id;
                            }else{
                                accountId=System.Label.Global_Account_for_E_invoice_Web_form;
                            }
                            
                        }//Enhancement above else if Statement for CA/SME
                        System.debug('team1'+team1);
                    } else If(team1=='International'){
                        if(caseInstance.SuppliedCompany==null){
                            System.debug('team1 here if'+team1);
                            // move the cleartax in constant class
                            accountId=System.Label.New_Global_International_Account;
                        }else if(caseInstance.SuppliedCompany!=null) {
                            System.debug('team1 here else'+team1);
                            if(intAccLst.size()>0){
                                accountId=intAccLst.get(0).id;
                            }else{
                                accountId=System.Label.New_Global_International_Account;
                            }
                            
                        }//Enhancement above else if Statement for CA/SME
                    }
                    //Added By kartikeya
                    
                    //Added By kartikeya
                    if( team1=='International'){
                        caseInstance.SuppliedEmail=caseInstance.Actual_Customer_Email__c;
                    }
                    if (team1 !='International' && team1 !='Clear Identity' && team1 != 'Max ITC' && team1 != 'Clear Capture' &&  team1 != 'Clear Invoice'){
                        Contact tempContact = new Contact();
                        //Added by kartikeya
                        tempContact = new contact(AccountId = accountId, LastName = caseInstance.SuppliedName , 
                                                  email=caseInstance.SuppliedEmail);
                        /*if(team1!='E Invoice' && team1!='B2B Enterprise' ){
caseInstance.SuppliedEmail=loggedInUserEmail;
}*/
                        //Added by kartikeya
                        System.debug(' before tempContact-->'+tempContact);
                        insert tempContact;
                        System.debug(' afterttempContact-->'+tempContact);
                        caseInstance.AccountId = tempContact.AccountId;
                        caseInstance.ContactId = tempContact.Id;
                    }
                }
            }
            catch(Exception e){
                System.debug('E '+e.getMessage());
                hasError=true;
                errormsg='An internal error has occurred. Please contact your admin.';
            }
        }else if(team1 != 'International' && team1 != 'Internal Case'){
            hasError=true;
            errormsg='Please enter correct GSTIN number';
        }
        if(team1=='B2B CA/SME' || (result && (team1=='B2B Enterprise' || team1=='E Invoice' || team1=='International' || team1=='Internal Case' || team1=='Clear Identity' || team1 == 'Max ITC' || team1 == 'Clear Capture' || team1 == 'Clear Invoice'))){
            try{
                System.debug('#551');
                List<user> loggedInUserDetail=[Select id, Department from user where email=:loggedInUserEmail Limit 1];
                if(team1=='Consumer' && orgConfig.Consumer_Web_Form_Case_Queue__c!=null && 
                   
                   queueNametoId.containsKey(orgConfig.Consumer_Web_Form_Case_Queue__c.toUpperCase())){
                       caseInstance.ownerId=queueNametoId.get(orgConfig.Consumer_Web_Form_Case_Queue__c.toUpperCase());
                   }
                //Changed By Kartikeya - Created a seperate org config for GST B2B Enterprise
                else If(team1=='B2B Enterprise' && orgConfig.GST_B2B_Enterprise__c!=null && 
                        queueNametoId.containsKey(orgConfig.GST_B2B_Enterprise__c.toUpperCase())){
                            if(caseInstance.Product_Route_Type__c=='MaxITC'){
                                caseInstance.OwnerId= System.label.MaxITC_Queue_Id ;
                            }else{
                                
                                if(loggedInUserDetail !=null && loggedInUserDetail.size() >0 ){
                                    caseInstance.OwnerId = isPGL ? System.label.Priority_ENT_GST_L1_Team_QueueID:
                                    (loggedInUserDetail[0].Department == 'KAM' ||loggedInUserDetail[0].Department=='CSM' || loggedInUserDetail[0].Department.toUpperCase().contains('CUSTOMER') )
                                    ? queueNametoId.get(orgConfig.GST_B2B_Enterprise__c.toUpperCase()):System.label.ENT_GST_L2_Team;
                                }else{
                                    caseInstance.OwnerId = isPGL ? System.label.Priority_ENT_GST_L1_Team_QueueID:System.label.ENT_GST_L1_Team_CaseQueueId;
                                }
                            }
                        }
                //End By Kartikeya
                else If(team1=='B2B CA/SME' && orgConfig.GST_Web_form_Case_Queue__c!=null && 
                        queueNametoId.containsKey(orgConfig.GST_Web_form_Case_Queue__c.toUpperCase()) && Product_type_Selected != 'TDS' && Product_type_Selected != 'Tax-cloud'){
                            system.debug('QueueName%##%$'+orgConfig.GST_Web_form_Case_Queue__c.toUpperCase());
                            system.debug('MapQueue'+queueNametoId);
                            caseInstance.ownerId=queueNametoId.get(orgConfig.GST_Web_form_Case_Queue__c.toUpperCase());
                        }
                else If(team1=='B2B CA/SME'   && Product_type_Selected == 'TDS'){
                    caseInstance.ownerId=System.label.CA_SME_TDS_L1_QueueId;
                }
                else If(team1=='B2B CA/SME'   && Product_type_Selected == 'Tax-cloud'){
                    caseInstance.ownerId=System.label.CA_SME_Tax_Cloud_L1_QueueId;
                }
                //Enhancement above else if Statement for CA/SME
                system.debug('isPGL---->'+isPGL);
                if(caseInstance.RecordTypeId == Constants.eInvoicingRTId){
                    caseInstance.OwnerId = isPGL?System.label.Priority_ENT_E_Invoice_L1_Team_QueueID: queueNametoId.get(orgConfig.E_Invoice_Web_form_Case_Queue__c.toUpperCase());                       
                }
                system.debug('caseInstance after owner---->'+caseInstance);
                caseInstance.Origin='Internal Web Form';
                if(team1 == 'B2B CA/SME' || team1 == 'B2B Enterprise' || team1 == 'E Invoice' ||team1 == 'International' ){
                    caseInstance.Case_Sub_Origin__c='GST Web Form';
                }else if(team1 == 'Consumer'){
                    caseInstance.Case_Sub_Origin__c='Consumer Web Form';
                }
                
                if(team1 == 'Internal Case'){
                    caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Case').getRecordTypeId();
                    caseInstance.OwnerId = System.Label.SF_L1_Sales_ops_Queue_ID;
                }
                if(team1 == 'Clear Identity'){
                    caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clear Identity').getRecordTypeId();
                    caseInstance.OwnerId = System.Label.Clear_Identity_L2;
                    caseInstance.BusinessHoursId = System.Label.B2B_Business_Hours;
                    caseInstance.User_Role_Type__c = 'Clear Identity L2';
                }
                if(team1 == 'Clear Invoice'){
                    caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clear Invoice').getRecordTypeId();
                    caseInstance.OwnerId = System.Label.ENT_Clear_Invoice_L2 ;
                    caseInstance.BusinessHoursId = System.Label.B2B_Business_Hours;
                    caseInstance.User_Role_Type__c = 'ENT Clear Invoice L2 Team';
                }
                if(team1 == 'Clear Capture'){
                    caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clear Capture').getRecordTypeId();
                    caseInstance.OwnerId = System.Label.ENT_Clear_Capture_L2_Team ;
                    caseInstance.BusinessHoursId = System.Label.B2B_Business_Hours;
                    caseInstance.User_Role_Type__c = 'ENT Clear Capture L2 Team';
                }
                if(team1 == 'Max ITC'){
                    caseInstance.RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Max ITC').getRecordTypeId();
                    caseInstance.OwnerId = System.Label.MaxITC_Queue_Id;
                    caseInstance.BusinessHoursId = System.Label.B2B_Business_Hours;
                    caseInstance.User_Role_Type__c = 'MaxITC - L2';
                }
                
                caseInstance.Queue_Distribution_mail__c=Queue_DistributionMap.containsKey(caseInstance.OwnerId)?Queue_DistributionMap.get(caseInstance.OwnerId):null;
                caseInstance.Web_Form_Submitter_Email__c=loggedInUserEmail;
                System.debug('480caseInstance--->'+caseInstance);
                insert caseInstance;
                newCaseId=caseInstance.id;
                try{
                    
                    updateIsCaseCreatedFromCaseForm(new Map<Id,Case>{caseInstance.id=>caseInstance});
                    
                }catch(Exception e){
                    System.debug('getCause'+e.getCause());
                    System.debug('getLineNumber'+e.getLineNumber());   
                    System.debug('getMessage'+e.getMessage());           
                    System.debug('getStackTraceString'+e.getStackTraceString());
                    System.debug('getTypeName'+e.getTypeName());
                    
                }
                system.debug('******caseInstance'+caseInstance);      
                caseInstance = new case();
                hasError=false;
                errormsg='';
                
            }
            catch(Exception e){
                System.debug('Error '+e.getMessage());
                hasError=true;
                errormsg='An internal error has occurred. Please contact your admin. OR '+ e.getMessage()?.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Contact Admin '+e));
                // return null;
            }
        }
        
    }
    
    public void resetCase(){
        string casenumber='';
        if(newCaseId!=null && newCaseId!=''){
            List<Case> caseLst=[select id,casenumber from case where id=:newCaseId];
            if(caseLst.size()>0){
                casenumber=caseLst.get(0).casenumber;
            }
        }
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Case '+casenumber+' has been created.'));
        caseInstance = new case();          
        system.debug('***reset Inside');
        
    }
    public void error(){
        
        if(hasError  && errormsg!=''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errormsg));
        }
        system.debug('***error Inside');
        
    }
    
    public GoogleValidationResponse isValidUser(string email,string idToken){
        GoogleValidationResponse methodresp = new GoogleValidationResponse();
        methodresp.isValidUser=false;
        methodresp.message='';
        
        API_EndPoints__c endpoint= API_EndPoints__c.getInstance();
        
        
        
        if(email == '@loggedout.'){
            
            loggedEmailID = null;
            googleIDToken=null;
            methodresp.isValidUser=false;
            methodresp.message='';
            loggedInUserEmail='';
            return methodresp;
            
        }       
        else if(orgConfig!=null && !orgConfig.Disable_Google_API_Token_Validation__c){
            
            if(idToken!=null && googleAutInfo!=null && googleAutInfo.Client_Id__c!=null &&
               endpoint!=null && endpoint.Google_ID_Token_Validation__c!=null  &&
               (googleAutInfo.Google_ISS_Value1__c!=null || googleAutInfo.Google_ISS_Value2__c!=null) &&               
               googleAutInfo.Google_Domain_Allowed__c!=null){
                   
                   String endpointurl=endpoint.Google_ID_Token_Validation__c+idToken;
                   
                   HttpResponse  resp=RestUtilities.httpRequest('GET',endpointurl,null,null,null,null);
                   system.debug('****resp'+resp);
                   system.debug('****resp code '+resp.getStatusCode());
                   system.debug('****resp body '+resp.getBody());
                   if(resp!=null && resp.getStatusCode()==200 && resp.getBody()!=null){
                       
                       String body=resp.getBody();
                       system.debug('****body '+body);
                       try{
                           GoogleResponseJSON googleresp=(GoogleResponseJSON)JSON.deserialize(body,GoogleResponseJSON.class);
                           system.debug('****googleresp'+googleresp);
                           
                           if(googleresp!=null && googleresp.aud!=null && googleresp.iss!=null && googleresp.hd!=null &&
                              
                              ((googleAutInfo.Google_ISS_Value1__c!=null && googleresp.iss==googleAutInfo.Google_ISS_Value1__c) ||
                               
                               (googleAutInfo.Google_ISS_Value2__c!=null && googleresp.iss==googleAutInfo.Google_ISS_Value2__c)) && 
                              
                              googleresp.aud==googleAutInfo.Client_Id__c ){                                     
                                  
                                  
                                  List<string> domainsLst=googleAutInfo.Google_Domain_Allowed__c.split(',');
                                  system.debug('****domainsLst'+domainsLst);
                                  system.debug('****googleresp.hd'+googleresp.hd);
                                  for(string domainName : domainsLst){
                                      
                                      if(domainName==googleresp.hd){
                                          system.debug('****googleresp.hd'+googleresp.hd);
                                          methodresp.isValidUser=true;
                                          methodresp.message='';
                                          if(googleresp.email!=null){
                                              
                                              loggedInUserEmail=googleresp.email;
                                          }
                                          break;
                                          
                                      }
                                      
                                  }
                                  
                                  if(methodresp.isValidUser==false){                      
                                      
                                      methodresp.message='You Are Not Authorized to View This Page';
                                      
                                  }
                                  if(methodresp.isValidUser==true){
                                      //check cleartax user is present in salesforce else create new contact.
                                      List<Contact> contLst = [select Id,AccountID from Contact where Email =:googleresp.email and account.recordtype.name='cleartax'];
                                      System.debug(contLst.size());//added by lokesh
                                      System.debug(cleartaxaccountid);//added by lokesh
                                      
                                      if(contLst.size()==0 && cleartaxaccountid!=null){
                                          // create contact
                                          
                                          contact con = new contact(accountid=cleartaxaccountid);
                                          con.email=googleresp.email;
                                          if(googleresp.name!=null){
                                              
                                              List<string> namesplit=googleresp.name.split(' ');
                                              if(namesplit.size()>1){
                                                  
                                                  con.firstname=namesplit.get(0);
                                                  string lastname='';
                                                  for(Integer i=1;i< namesplit.size();i++){
                                                      
                                                      lastname+=namesplit.get(i)+' ';
                                                      
                                                  }
                                                  lastname=lastname.removeEnd(' ');
                                                  
                                                  con.lastname=lastname;
                                                  
                                              }
                                              else{
                                                  
                                                  con.lastname=googleresp.name;
                                              }
                                              
                                          }
                                          else{
                                              
                                              con.lastname=googleresp.email;
                                          }
                                          
                                          try{
                                              insert con;           
                                          }
                                          catch(exception e){
                                              
                                              
                                          }
                                          
                                          
                                          
                                      }
                                  }
                                  
                                  
                              }
                           else{
                               methodresp.isValidUser=false;
                               methodresp.message='You Are Not Authorized to View This Page';
                           }
                       }
                       catch(exception e){
                           
                           system.debug('****e'+e.getMessage());
                           methodresp.isValidUser=false;
                           methodresp.message='An error occurred,Please reach out to your system admin.';
                       }
                       
                       return  methodresp;
                       
                   }
                   else{
                       
                       methodresp.message='An error occurred, please try again later';
                       
                       return methodresp;
                   }
                   
                   
                   
                   
               }
            else{
                if(idToken==null){
                    
                    methodresp.message='Authentication details missing.';
                }
                else{
                    
                    methodresp.message='Authentication configuration details are missing. Please reach out to your system admin.';
                }
                
                return methodresp;
            }
            
            
            
            
        }
        else{
            
            if(email!=null && googleAutInfo!=null && googleAutInfo.Google_Domain_Allowed__c!=null ){
                
                List<string> allowDomainsLst=googleAutInfo.Google_Domain_Allowed__c.split(',');
                
                List<String> emailDomainLst=email.split('@');
                
                if(emailDomainLst.size()==2){
                    string emailDomain=emailDomainLst.get(1);
                    for(string domainName : allowDomainsLst){
                        if(domainName==emailDomain){
                            methodresp.isValidUser=true;
                            loggedInUserEmail=email;
                            methodresp.message='';
                            break;
                        }
                    }
                    if(methodresp.isValidUser==false){                      
                        
                        methodresp.message='You Are Not Authorized to View This Page';
                        
                    }
                    
                    if(methodresp.isValidUser==true){
                        //check cleartax user is present in salesforce else create new contact.
                        List<Contact> contLst = [select Id,AccountID from Contact where Email =:email and account.recordtype.name='cleartax'];
                        if(contLst.size()==0 && cleartaxaccountid!=null){
                            // create contact
                            
                            contact con = new contact(accountid=cleartaxaccountid);
                            con.email=email;                    
                            con.lastname=email;
                            
                            
                            try{
                                insert con;           
                            }
                            catch(exception e){
                                
                                
                            }
                            
                            
                            
                        }
                    }
                    
                    
                }
                else{
                    
                    methodresp.isValidUser=false;
                    methodresp.message='You Are Not Authorized to View This Page';
                    
                }
                
                
                
            }
            else{
                
                methodresp.isValidUser=false;
                methodresp.message='Authentication details missing.';
                
            }
            
            
            return methodresp;
        }
        
        
        
        
    }
    
    static Set<Id> caseIdEmailUnique = new Set<Id>();
    static Integer Count=0;
    /**
* @description  new Email Threading feature Enhancement for Email Mails Sync
* @author Lokesh Thathuru | 16/12/2020
* @param Map<Id,EmailMessage> mapOfEmailMessage
* @return void
*/    
    public static void updateIsCaseCreatedFromCaseForm(Map<Id,Case> mapofIdWithCases){
        Set<Id> setOfParentCaseIds=new Set<Id>();
        Set<Id> caseIdEmailTOBESent=new Set<Id>();
        Map<Id,EmailMessage> mapOfEmailMessagesToBeInserted = new Map<Id,EmailMessage>();
        //String orgName = [SELECT Id, Name FROM Organization limit 1].Name;
        Map<Id, Case> mapOfIdandCase = new Map<Id, Case>();
        List<Messaging.SingleEmailMessage> listOfMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        
        List<Org_wide_and_Email_Template_Mapping__mdt> listOfOrgwideandEmailTemplateMappings=new List<Org_wide_and_Email_Template_Mapping__mdt>();
        listOfOrgwideandEmailTemplateMappings=DataBase.query(UtilityClass.getQueryString('Org_wide_and_Email_Template_Mapping__mdt')+' FROM Org_wide_and_Email_Template_Mapping__mdt ');
        Map<String,Org_wide_and_Email_Template_Mapping__mdt> mapOfOrgwideandEmailTemplateMappings=new  Map<String,Org_wide_and_Email_Template_Mapping__mdt>();
        Map<String,Org_wide_and_Email_Template_Mapping__mdt> mapOfOrgwideandEmailTemplateMappingsByCustomerSegment=new  Map<String,Org_wide_and_Email_Template_Mapping__mdt>();
        
        
        for(Org_wide_and_Email_Template_Mapping__mdt orgwideandEmailTemplateMappingInstance:listOfOrgwideandEmailTemplateMappings){
            if(!mapOfOrgwideandEmailTemplateMappings.containsKey(orgwideandEmailTemplateMappingInstance.Email_to_case_Inbound_Email__c)){
                mapOfOrgwideandEmailTemplateMappings.put(orgwideandEmailTemplateMappingInstance.Email_to_case_Inbound_Email__c,orgwideandEmailTemplateMappingInstance);
            }
            System.debug('orgwideandEmailTemplateMappingInstance?.Customer_Segment__c'+orgwideandEmailTemplateMappingInstance?.Customer_Segment__c);
            if(orgwideandEmailTemplateMappingInstance?.Customer_Segment__c!=null){
                if(orgwideandEmailTemplateMappingInstance.Customer_Segment__c?.contains(',')){
                    for(String customerSeg:orgwideandEmailTemplateMappingInstance.Customer_Segment__c.split(',')){
                        if(!mapOfOrgwideandEmailTemplateMappingsByCustomerSegment.containsKey(customerSeg)){
                            mapOfOrgwideandEmailTemplateMappingsByCustomerSegment.put(customerSeg, orgwideandEmailTemplateMappingInstance);
                        }
                    }
                }else{
                    if(!mapOfOrgwideandEmailTemplateMappingsByCustomerSegment.containsKey(orgwideandEmailTemplateMappingInstance.Customer_Segment__c)){
                        mapOfOrgwideandEmailTemplateMappingsByCustomerSegment.put(orgwideandEmailTemplateMappingInstance.Customer_Segment__c, orgwideandEmailTemplateMappingInstance);
                    }
                }
            }
        }
        
        
        /* if(!mapOfEmailMessage.isEmpty()){

for(Id key : mapOfEmailMessage.keySet()){
if(mapOfEmailMessage.get(key).incoming){
system.debug('updateIsCaseCreatedFromEmailMessage**1');
setOfParentCaseIds.add(mapOfEmailMessage.get(key).ParentId);

}
}
}*/
        if(!mapofIdWithCases.isEmpty()){
            setOfParentCaseIds.addAll(mapofIdWithCases.keySet());
        }
        
        //system.debug('query case ***'+[select id, Incoming_Email_Count__c from case where Id IN: setOfParentCaseIds]);
        List<Case> listofCases=DataBase.query(UtilityClass.getQueryString('Case')+' FROM Case WHERE Id IN: setOfParentCaseIds ');
        
        Set<Id> setofOrgWiderIds=new Set<Id>();
        
        Set<Id> setofEmailTemplateIds=new Set<Id>();
        if(!listofCases.isEmpty()){
            
            
            
            system.debug('updateIsCaseCreatedFromEmailMessage**2'+listofCases);
            for(Case caseInstance : listofCases){
                caseIdEmailTOBESent.add(caseInstance.Id);
                mapOfIdandCase.put(caseInstance.Id, caseInstance);
                //System.debug('caseInstance?.Email_Source__c'+caseInstance?.Email_Source__c);
                System.debug('caseInstance.Customer_Segment__c'+caseInstance.Customer_Segment__c);
                if(mapOfOrgwideandEmailTemplateMappingsByCustomerSegment.containsKey(caseInstance.Customer_Segment__c)){
                    setofOrgWiderIds.add(mapOfOrgwideandEmailTemplateMappingsByCustomerSegment.get(caseInstance.Customer_Segment__c)?.Org_Wide_Email_Id__c);
                    setofEmailTemplateIds.add(mapOfOrgwideandEmailTemplateMappingsByCustomerSegment.get(caseInstance.Customer_Segment__c)?.Email_Template_Id__c);
                }
                System.debug('caseInstance?.Customer_Segment__c'+caseInstance.Customer_Segment__c);
            }
        }
        
        Map<Id,OrgWideEmailAddress> mapOforgWideEmailAddressInstance  =new Map<Id,OrgWideEmailAddress>([SELECT Id, CreatedById, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, Address, DisplayName, IsAllowAllProfiles FROM OrgWideEmailAddress WHERE Id IN:setofOrgWiderIds ]);
        Map<Id,emailTemplate>  mapOfemailTemplateInstanc= new Map<Id,emailTemplate>([Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Id IN: setofEmailTemplateIds  ]);
        set<string> ToAddressesSet = new set<string>();
        for(Case caseInstance : listofCases){
            System.debug('Count *****'+Count+1);
            if(caseIdEmailTOBESent.contains(caseInstance.Id)){
                if(!caseIdEmailUnique.contains(caseInstance.Id)){
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTemplateId(mapOfemailTemplateInstanc.get(mapOfOrgwideandEmailTemplateMappingsByCustomerSegment.get(mapOfIdandCase.get(caseInstance?.id)?.Customer_Segment__c)?.Email_Template_Id__c)?.Id);
                    //email.setToAddresses(new List<String>{caseInstance?.SuppliedEmail}); //Logic need to be added
                    ToAddressesSet.add(caseInstance?.SuppliedEmail);
                    ToAddressesSet.add(caseInstance?.Web_Form_Submitter_Email__c);
                    ToAddressesSet.add(caseInstance?.CCEmailAddress__c);
                    //ToAddressesSet.add(caseInstance?.Actual_Customer_Email__c);
                    ToAddressesSet.remove(null);
                    //email.setSubject(caseInstance.subject); // commented by lokesh
                    /*if(emsg.MessageIdentifier != null)	
email.setInReplyTo(emsg.MessageIdentifier);*/
                    
                    List<string> listAddress=new List<String>();
                    system.debug('ToAddressesSet===>'+ToAddressesSet);
                    listAddress.addall(ToAddressesSet);
                    email.setToAddresses(listAddress);
                    email.setOrgWideEmailAddressId(mapOforgWideEmailAddressInstance.get(mapOfOrgwideandEmailTemplateMappingsByCustomerSegment.get(mapOfIdandCase.get(caseInstance?.id)?.Customer_Segment__c)?.Org_Wide_Email_Id__c)?.Id);    
                    email.setSaveAsActivity(true);
                    if(mapOfIdandCase.get(caseInstance?.id).ContactId!=null){
                        email.setTargetObjectId(mapOfIdandCase.get(caseInstance?.id)?.ContactId);
                    }else{
                        if(String.valueOf(mapOfIdandCase.get(caseInstance?.id)?.OwnerId).startsWith('005')){
                            email.setTargetObjectId(mapOfIdandCase.get(caseInstance?.id)?.OwnerId);  
                        }else{
                            email.setTargetObjectId(UserInfo.getUserId());
                        }
                    }
                    email.setWhatId(caseInstance?.id);
                    
                    listOfMessagingSingleEmailMessage.add(email);
                    
                    EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
                    
                    //emailMsg.ToAddress = (email?.getToAddresses())[0];
                    emailMsg.fromaddress = mapOforgWideEmailAddressInstance.get(mapOfOrgwideandEmailTemplateMappingsByCustomerSegment?.get(mapOfIdandCase.get(caseInstance?.id)?.Customer_Segment__c)?.Org_Wide_Email_Id__c)?.Address;//emsg.fromAddress;
                    emailMsg.FromName = mapOforgWideEmailAddressInstance.get(mapOfOrgwideandEmailTemplateMappingsByCustomerSegment.get(mapOfIdandCase.get(caseInstance?.id)?.Customer_Segment__c)?.Org_Wide_Email_Id__c)?.DisplayName;//emsg.fromName;
                    /*if(emsg.MessageIdentifier != null){
emailMsg.MessageIdentifier = emsg.MessageIdentifier;
emailMsg.ThreadIdentifier = emsg.MessageIdentifier;
}*/
                    emailMsg.Subject = email.getSubject();
                    emailMsg.HtmlBody = email.getHtmlBody();
                    emailMsg.TextBody = email.getPlainTextBody();
                    emailMsg.parentid = caseInstance?.id; // storing case id externally 
                    emailMsg.MessageDate = system.now();
                    emailMsg.Status = '3';
                    if(!mapOfEmailMessagesToBeInserted.containsKey(caseInstance?.id)){
                        mapOfEmailMessagesToBeInserted.put(caseInstance?.id,emailMsg);
                    }
                    caseIdEmailUnique.add(caseInstance?.id);
                }
            }
        }
        system.debug('updateIsCaseCreatedFromEmailMessage**3'+mapOfEmailMessagesToBeInserted.values());
        if(mapOfEmailMessagesToBeInserted.values().size() > 0 && !mapOfEmailMessagesToBeInserted.values().isEmpty()){
            Messaging.SendEmailResult[] msgResult = Messaging.sendEmail(listOfMessagingSingleEmailMessage,false);
            system.debug('updateIsCaseCreatedFromEmailMessage**4'+mapOfEmailMessagesToBeInserted.values().size());
            //insert mapOfEmailMessagesToBeInserted.values()[0];
            System.debug('msgResult'+msgResult);
        }
        
        
    }
    global static list<SelectOption> getPicklistValues(SObject obj, String fld){
        list<SelectOption> options = new list<SelectOption>();
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType(); 
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values)
        { 
            options.add(new SelectOption(a.getLabel(), a.getValue())); 
        }
        return options;
    }
    
    
    /*public void onChangeFnCall(){
/* if(caseInstance.Customer_Segment__c=='GST - Enterprise'){
pb2Rendered = true;
pb3Rendered = false;
}
else if(caseInstance.Customer_Segment__c=='E Invoicing'){
pb2Rendered = false;
pb3Rendered = true;
}else{
pb2Rendered = false;
pb3Rendered = false;
}
}*/
    public void isShowGSTINField(){
        system.debug('****isShowGSTINField'+caseInstance);
        showGSTIN=caseInstance.Customer_Segment__c=='B2B - CA'?true:false;
        
    }
    
    
    public class GoogleValidationResponse{
        
        public boolean isValidUser;
        public string   message;
    }   
    
    public class GoogleResponseJSON{
        
        public String iss;  
        public String azp;  
        public String aud;  
        public String sub;  
        public String hd;   
        public String email;
        public String email_verified;   
        public String at_hash;  
        public String name; 
        public String picture;  
        public String given_name;   
        public String family_name;  
        public String locale;
        public String iat;  
        public String exp;  
        public String jti;  
        public String alg;  
        public String kid;  
        public String typ;  
        
    }
    
    
}