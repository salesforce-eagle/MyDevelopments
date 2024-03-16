/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_CSMJorneyQueueable IMPLEMENTS Queueable {
    
    public	Set<Id> 			assetIds;
    public 	Map<Id, Asset> 		newAssetMap;
    public 	Map<Id, Asset> 		oldAssetMap;
    public 	Map<Id, Product2> 	productMap;
    public 	Boolean 			isUpdate;
    public	Set<Id>				parentAssetId;
    
    public CTX_CSMJorneyQueueable(
        Map<Id, Asset>		newAssetMap, 
        Map<Id, Asset> 		oldAssetMap, 
        Map<Id, Product2> 	productMap, 
        Boolean 			isUpdate,
        Set<Id>				parentAssetId
    ){
        this.newAssetMap 	= newAssetMap;
        this.oldAssetMap 	= oldAssetMap;
        this.productMap 	= productMap;
        this.isUpdate 		= isUpdate;
        this.parentAssetId	= parentAssetId;
    }
    
    public CTX_CSMJorneyQueueable( Set<Id> assetIds ){
        this.assetIds = assetIds;
    }
    
    public void execute(QueueableContext context){
        
        List<Asset> 						assetsToUpdate 	
            = [ SELECT Id, Name, Stage__c, RecordTypeId, CSM_Handled_Asset__c, Onboarding_Stage__c, 
               Product2.Product_Category__c, Account.Name, Account.Onboarding_Owner__c, Account.Onboarding_Owner__r.Name, 
               Account.Onboarding_Owner__r.Email, Account.Sum_of_ARR_Assets__c, 
               Account.Onboarding_Owner__r.Manager.Email, Account.Sales_Owner__r.Email, Is_Escalation_Required__c 
               FROM Asset WHERE 
               Id IN : newAssetMap.keySet() AND 
               RecordType.Name = 'License Asset' ];
        List<Messaging.SingleEmailMessage> 	mailList 		= new List<Messaging.SingleEmailMessage>();
        Id 									defaultMailId 	= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                               Address =: System.Label.CSM_Journey_Org_Wide_Generic_Email ]?.Id;
        
        for(Asset assetInstance : assetsToUpdate){
            if(assetInstance.CSM_Handled_Asset__c == true){
                assetInstance.Stage__c 					= 'Onboarding';
                assetInstance.Is_Escalation_Required__c = true;
                if(assetInstance.Account?.Onboarding_Owner__c != null){
                    assetInstance.Sales_CSM_Handover_Status__c 		= 'Started';
                    assetInstance.Onboarding_status__c 				= 'Onboarding Pending';
                    assetInstance.Onboarding_Stage__c 				= 'Sales CSM Handover';
                    assetInstance.Onboarding_process_start_date__c 	= System.today();
                    mailList.add(createNewAssetToCSMEmail(assetInstance, defaultMailId));
                } else {
                    assetInstance.Onboarding_Stage__c 				= 'Not started';
                }
            } else {
                //assetInstance.Stage__c 					= 'Success';
                assetInstance.Onboarding_status__c 			= 'Onboarding Not Required';
            }
            
        }
        
        if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
                
            }
            catch (Exception ex) {
                System.debug('Unable to send CSM Intro email'+ ex.getMessage());
            }
        }
        
        try{
            update assetsToUpdate;
        } catch(Exception e){
            system.debug('Asset Update Failed CSM Journey: '+e.getMessage());
        } finally{
            CTX_LicensingAssetFilterLogic.filterAssetsForlicensing(newAssetMap, NULL, productMap, FALSE, parentAssetId);
        }
        
        
        /**	Chaining Job for Renewal Licensing	: START	**/
        
        /**	Chaining Job for Renewal Licensing	: END	**/
        
    }

    public static Messaging.SingleEmailMessage createNewAssetToCSMEmail(Asset assetInstance, Id defaultMailId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.SaveAsActivity = TRUE;
        mail.setWhatId(assetInstance.Id);
        String Subject = 'New Asset '+assetInstance.Name+' Created.';
        mail.setSubject(Subject);
        String body = 'Hi '+assetInstance.Account.Onboarding_Owner__r.Name+','+'<br/>';
        body += 'New asset has been added to the account for which you are assigned as a CSM.'+'<br/>';
        body += '<b>Asset Name :</b>'+' '+assetInstance.Name+'<br/>';
        body += '<b>Account Name :</b>'+' '+assetInstance.Account.Name+'<br/>';
        body += '<b>Asset URL :</b>'+' '+ URL.getSalesforceBaseUrl().toExternalForm()+'/'+assetInstance.Id +'<br/>';
        body += ''+'<br/>';
        body += ''+'<br/>';
        body +='Regards'+',<br/>'+'\n CSM Team'+'<br/>';
        mail.setHtmlBody(body);
        List<String> ccAddresses = new List<String>();
        ccAddresses.add(assetInstance.Account.Onboarding_Owner__r.Manager.email);
        ccAddresses.add(assetInstance.Account.Sales_Owner__r.email);
        mail.setToAddresses(new String[]{assetInstance.Account.Onboarding_Owner__r.email });
        mail.setccAddresses(ccAddresses);
        mail.setOrgWideEmailAddressId(defaultMailId);
        return mail;
    }
}