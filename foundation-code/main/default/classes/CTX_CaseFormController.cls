global class CTX_CaseFormController {
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
    public boolean showForm;
    public boolean showFormUI {get;set;}
    public boolean showsingoutButton {get;set;}
    Cleartax_Org_Configuration__c orgConfig;
    Map<String,String> queueNametoId = new Map<string,String>();
    private string loggedInUserEmail;
    private id cleartaxaccountid;
    
    public boolean showGSTIN{get;set;}
    
    public CTX_CaseFormController(){
        
        orgConfig = Cleartax_Org_Configuration__c.getInstance();
        List<External_System_Authentication__c> googleAutInfoLst=[select id,Client_Id__c,Google_ISS_Value1__c,Google_ISS_Value2__c,Google_Domain_Allowed__c from External_System_Authentication__c where API_Type__c='Google Form Authentication' and RecordType.name='Google' limit 1];
        system.debug('googleAutInfoLst: '+googleAutInfoLst.size());
            if(googleAutInfoLst.size()>0){
            
            googleAutInfo=googleAutInfoLst.get(0);
            
        }
        showForm=false;
        showFormUI=false;
        system.debug('googleAutInfo: '+googleAutInfo);
        
        system.debug('loggedEmailID Constructor: '+loggedEmailID);
        system.debug('googleIDToken Constructor: '+googleIDToken);
        
        /*System.debug('whole '+loggedEmailID +'Mail ');//+loggedEmailID.getEmail());
        string domainName = loggedEmailID.substringBetween('@', '.');
        string googleIDToken = googleIDToken;
        system.debug('****googleIDToken'+googleIDToken);
        newCaseId='';
        GoogleValidationResponse GAuth = isValidUser(loggedEmailID,googleIDToken);
        VFMessage = GAuth.message;
        
        If(GAuth.isValidUser ){
            system.debug('Valid User Block');
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
        }*/
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
            system.debug('Valid User Block');
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
    
    public GoogleValidationResponse isValidUser(string email,string idToken){
        GoogleValidationResponse methodresp = new GoogleValidationResponse();
        methodresp.isValidUser=false;
        methodresp.message='';
        
        API_EndPoints__c endpoint= API_EndPoints__c.getInstance();
        
         system.debug('orgConfig: '+orgConfig);
        system.debug('orgConfig.Disable_Google_API_Token_Validation__c: '+orgConfig.Disable_Google_API_Token_Validation__c);
        system.debug('idToken: '+idToken);
        system.debug('googleAutInfo: '+googleAutInfo);
        system.debug('endpoint: '+endpoint);
        
        if(email == '@loggedout.'){
            
            loggedEmailID = null;
            googleIDToken=null;
            methodresp.isValidUser=false;
            methodresp.message='';
            loggedInUserEmail='';
            return methodresp;
            
        } else if(orgConfig!=null && !orgConfig.Disable_Google_API_Token_Validation__c){
            
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
                                  //for(string domainName : domainsLst){
                                      
                                      if(domainsLst.contains(googleresp.hd) ){
                                          system.debug('****googleresp.hd'+googleresp.hd);
                                          methodresp.isValidUser=true;
                                          methodresp.message='';
                                          if(googleresp.email!=null){
                                              
                                              loggedInUserEmail=googleresp.email;
                                          }
                                          //break;
                                          
                                      }
                                      
                                  //}
                                  
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
                       
                       system.debug('methodresp: '+methodresp);
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
            
            system.debug('methodresp: '+methodresp);
            return methodresp;
        }
        
        
        
        
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