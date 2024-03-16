/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-04-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class CTX_UpdatedCSMKAMDetailsAPI {
    
    public static void UpdatedCSMKAMDetails( Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap ){
        
        Map<Id, Account>	accountsTobeProcessMap = new Map<Id, Account>();
        for( Account thisRec : newAccountMap.values() ){
            if( 
                ( thisRec.Onboarding_Owner__c != oldAccountMap.get(thisRec.Id).Onboarding_Owner__c ||
                thisRec.OwnerId 			!= oldAccountMap.get(thisRec.Id).OwnerId ) &&
                ( thisRec.Country_of_Origin__c == 'India' || thisRec.Country_of_Origin__c == NULL )
            ){
                accountsTobeProcessMap.put(thisRec.Id, thisRec);
            }
        }
        
        if( accountsTobeProcessMap.values().size() > 0 ){
            String jsonString = updateAPICallout( accountsTobeProcessMap.keySet() );
            system.debug('jsonString: '+jsonString);
            if( String.isNotBlank(jsonString) ){
                doUpdateCSMKAMAPICallout(jsonString, 'India');
            }
        }   
        
    }
    
    public static String updateAPICallout( Set<Id> accountMapKeys ){
        
        List<EnableAutoRenewalWrapper> returnWrapper = new List<EnableAutoRenewalWrapper>();
        for( 
            Account thisRec : [ SELECT 
                               Id, Name, Product_Email__c, Is_Auto_Renewal_Enabled__c, Sum_of_ARR_Assets__c, 
                               Bank_Account_Name__c, Account_Number__c, Bank_Name__c, Bank_IFSC_Code__c, Bank_Branch__c, Bank_Swift_Code__c,
                               
                               Onboarding_Owner__c, Onboarding_Owner__r.Name, Onboarding_Owner__r.Email, Onboarding_Owner__r.Phone,
                               Onboarding_Owner__r.Manager.Name, Onboarding_Owner__r.Manager.Email, Onboarding_Owner__r.Manager.Phone,
                               Onboarding_Owner__r.Manager.Manager.Email, 
                               
                               OwnerId, Owner.Name, Owner.Email, Owner.Phone,
                               Owner.Manager.Name, Owner.Manager.Email, Owner.Manager.Phone, Owner.Manager.Manager.Email, 
                               
                               ( SELECT Id, Name, Price, Status, Product2Id, License_ID__c, PurchaseDate, UsageEndDate,
                                Product2.Plan_Tier__c FROM Assets WHERE Status IN ('Valid', 'Upcoming renewal', 'Valid & Renewed') AND 
                                License_Id__c != NULL AND Price > 0 AND (NOT Name LIKE '%Assisted Services%') ) 
                               
                               FROM Account WHERE 
                               Id IN :accountMapKeys ] 
        ){
            /**	**/
            EnableAutoRenewalWrapper reqWrap = new EnableAutoRenewalWrapper();
            
            reqWrap.accountId							= thisRec.Id;
            reqWrap.accountName							= thisRec.Name;
            reqWrap.autoRenewalStatus 					= thisRec.Is_Auto_Renewal_Enabled__c;
            reqWrap.numberOfDaysExtended				= thisRec.Sum_of_ARR_Assets__c <= 100000 ? 
                Integer.valueOf(system.Label.Days_Extension_1L) : Integer.valueOf(system.Label.Days_Extension_1L_LessThan);
            
            /**	CSM Details : START	**/
            if( thisRec.Onboarding_Owner__c != NULL ){
                reqWrap.csm.email 						= thisRec.Onboarding_Owner__r.Email;
                reqWrap.csm.phone 						= thisRec.Onboarding_Owner__r.Phone;
                reqWrap.csm.managerEmail 				= thisRec.Onboarding_Owner__r.Manager.Email;
                reqWrap.csm.superManagerEmail 			= thisRec.Onboarding_Owner__r.Manager.Manager.Email;  
            }
            /**	CSM Details : END	**/
            
            /**	KAM Details : START	**/
            reqWrap.kam.name 							= thisRec.Owner.Name;
            reqWrap.kam.email 							= thisRec.Owner.Email;
            reqWrap.kam.phone 							= thisRec.Owner.Phone;
            reqWrap.kam.managerEmail 					= thisRec.Owner.Manager.Email;
            reqWrap.kam.superManagerEmail 				= thisRec.Owner.Manager.Manager.Email;
            /**	KAM Details : END	**/
            
            /**	Bank Details : START	**/
            reqWrap.bankDetails.accountName				= thisRec.Bank_Account_Name__c;
            reqWrap.bankDetails.accountNumber			= thisRec.Account_Number__c;
            reqWrap.bankDetails.bankName				= thisRec.Bank_Name__c;
            reqWrap.bankDetails.bankIFSCCode			= thisRec.Bank_IFSC_Code__c;
            reqWrap.bankDetails.bankBranch				= thisRec.Bank_Branch__c;
            reqWrap.bankDetails.bankSwiftCode			= thisRec.Bank_Swift_Code__c;		
            /**	Bank Details : END	**/

            /**	Validity Details : Active List of Assets : START	**/
            if( thisRec.getSobjects('Assets') != NULL &&  thisRec.getSobjects('Assets').size() > 0 ){
                for( Asset thisAsset : (List<Asset>)thisRec.getSobjects('Assets') ){
                    
                    ActiveAsset assets 					= new ActiveAsset();
                    assets.startAt		= thisAsset.PurchaseDate;
                    assets.endAt			= thisAsset.UsageEndDate;
                    assets.price 			= thisAsset.Price;
                    assets.assetId 		= thisAsset.Id;
                    assets.name 			= thisAsset.Name;
                    assets.status 		= thisAsset.Status;
                    assets.licenseId 		= thisAsset.License_Id__c;
                    assets.planTier 		= thisAsset.Product2.Plan_Tier__c;
                    assets.isApplicableForLicensingEmailer = TRUE;
                    
                    reqWrap.activeAssets.add(assets);
                }
            }
            /**	Validity Details : Active List of Assets : START	**/
            
            returnWrapper.add(reqWrap);
        }
        
        
        system.debug('returnWrapper: '+returnWrapper);
        system.debug('returnWrapper JSON: '+JSON.serialize(returnWrapper));
        return JSON.serialize(returnWrapper);
    }
    
    @future(callout = true)
    public static void doUpdateCSMKAMAPICallout( String jsonString, string region ){
        
         HttpResponse response = CTX_LicensingAPICalloutClass.updateKAMCSMDetails( jsonString, region );
            system.debug( 'response - CTX_UpdatedCSMKAMDetailsAPI.UpdatedCSMKAMDetails: '+response );
    }
    
    
    /**	**/
    public class EnableAutoRenewalWrapper {
        public string					accountId;
        public string					accountName;
        public boolean 	    			autoRenewalStatus		= FALSE;
        public CustomerSuccessManager   csm 					= new CustomerSuccessManager();
        public KeyAccountManager 	    kam 					= new KeyAccountManager();
        Public Integer 					numberOfDaysExtended	= Integer.valueOf(System.label.CTX_AutoRenewal_Days_Extension);
        public BankDetails				bankDetails				= new BankDetails();
        public List<ActiveAsset>		activeAssets 			= new List<ActiveAsset>();
    }
    
    public class CustomerSuccessManager {
        public string 					email;
        public string 					phone;
        public string 					managerEmail;
        public string 					superManagerEmail;
    }
    
    public class KeyAccountManager {
        public string 					name;
        public string 					email;
        public string 					phone;
        public string 					managerEmail;
        public string 					superManagerEmail;
    }
    
    public class BankDetails {
        public string 					accountName;
        public string 					accountNumber;
        public string 					bankName;
        public string 					bankIFSCCode;
        public string 					bankBranch;
        public string 					bankSwiftCode;
    }
    
    Public Class ActiveAsset{
        Public DateTime 				startAt;
        Public DateTime 				endAt;
        Public Decimal 					price 		= 0;
        public String 					licenseId;
        public String					planTier;
        public String					assetId;
        public String					name;
        public String					status;
        public Boolean                  isApplicableForLicensingEmailer  = FALSE;
    }
    /**	**/

}