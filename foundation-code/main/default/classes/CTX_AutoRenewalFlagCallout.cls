public class CTX_AutoRenewalFlagCallout implements Queueable, Database.AllowsCallouts{
    
    List<EnableAutoRenewalWrapper> autoRenewLicense 	= new List<EnableAutoRenewalWrapper>();
    Map<String, String> assetAccountMap				= new Map<String, String>();
    List<Auto_Renew_Whitelisting_Failure__e>   failureEvents   = new List<Auto_Renew_Whitelisting_Failure__e>();
    
    public CTX_AutoRenewalFlagCallout(List<EnableAutoRenewalWrapper> applicableLicenses , Map<String, String> assetAccountMap) {
        
        this.autoRenewLicense 		= applicableLicenses;
        this.assetAccountMap 		= assetAccountMap;
        
    }
    
    public void execute(QueueableContext context){
        
        String 			jsonBody 		= JSON.serialize(autoRenewLicense);
        
        System.debug('@jsonBody'+jsonBody);
        
        HttpRequest 	request 		= new HttpRequest();
        HttpResponse 	response 		= new HttpResponse();
        
        request.setMethod('POST');
        
        request.setEndpoint(System.Label.SalesSync_Base_URI_India +System.Label.CTX_Auto_Renewal_Enabled_License_EP );
        
        request.setHeader('X-Api-Token', System.Label.SalesSyncService_X_Api_Token  );
        
        request.setHeader('x-cleartax-user', UserInfo.getUserEmail());
        
        request.setHeader('Content-Type', 'application/json');
        
        request.setBody(jsonBody);
        
        
        response 		= new Http().send(request);
        List<Account> accountsFailed = new List<Account>();
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201 ){
            
            System.debug('@Response ==>'+ response.getBody());
            List<ResponseWrapper> responseWrap = (List<ResponseWrapper>)JSON.deserialize(response.getBody(),List<ResponseWrapper>.Class);
            for(ResponseWrapper res : responseWrap ){
                if(res.updateStatus != 'SUCCESS'){
                    if(assetAccountMap.get(res.licenseId) != NULL){
                        accountsFailed.add(new Account(Id=assetAccountMap.get(res.licenseId), Is_Auto_Renewal_Enabled__c = FALSE));
                        failureEvents.add(new Auto_Renew_Whitelisting_Failure__e (Record_Id__c = assetAccountMap.get(res.licenseId), ErrorMessages__c  = res.errorMessage));
                    }
                }
            }
            
        }else{
            System.debug('@Callout Faliure ==>'+ response.getBody());   
            for(String accId : assetAccountMap.values()){
                accountsFailed.add(new Account(Id=accId, Is_Auto_Renewal_Enabled__c = FALSE));
                failureEvents.add(new Auto_Renew_Whitelisting_Failure__e (Record_Id__c = accId, ErrorMessages__c  = response.getBody()));
            }
        }
        
        if(failureEvents.size() > 0){
            List<Database.SaveResult> results = EventBus.publish(failureEvents);
        }
        if(!accountsFailed.isEmpty()){
            AccountConstants.isFirstTimeAccount = FALSE;
            update accountsFailed;
            AccountConstants.isFirstTimeAccount = TRUE;
        }
        
    }
    public class CustomerSuccessManager {
        public string 		email;
        public string 		phone;
        public string 		managerEmail;
        public string 		superManagerEmail;
        
    }
    
    public class KeyAccountManager {
        public string 		name;
        public string 		email;
        public string 		phone;
        public string 		managerEmail;
        public string 		superManagerEmail;
    }
    
    public class BankDetails {
        public string 		accountName;
        public string 		accountNumber;
        public string 		bankName;
        public string 		bankIFSCCode;
        public string 		bankBranch;
        public string 		bankSwiftCode;
    }
    
    Public Class Validity{
        Public DateTime startAt;
        Public DateTime endAt;
    }
    
    public class EnableAutoRenewalWrapper {
        public string 		licenseId;
        public boolean 	    autoRenewalStatus = FALSE;
        public CustomerSuccessManager   csm 				= new CustomerSuccessManager();
        public KeyAccountManager 	    kam 				= new KeyAccountManager();
        Public Decimal previousYearPrice 	= 0;
        Public Integer numberOfDaysExtended = Integer.valueOf(System.label.CTX_AutoRenewal_Days_Extension);
        public BankDetails				bankDetails			= new BankDetails();
        public Validity 				validity 			= new Validity();
    }
    
    Public class ResponseWrapper {
        public string licenseId;
        public string updateStatus;
        public string errorMessage;
    }
    
}