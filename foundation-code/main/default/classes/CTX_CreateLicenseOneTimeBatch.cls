/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_CreateLicenseOneTimeBatch implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts, Schedulable{
    
    Public String 			queryString;
    public static Map<Id, String> 	recordIdErrorMap = new Map<Id, String>();
    public static List<Logger__c>  updateSnag = new List<Logger__c>();
    public	static Id 		defaultMailId 		= [ SELECT Id FROM OrgWideEmailAddress WHERE Address =: System.Label.CSM_Journey_Org_Wide_Generic_Email]?.Id;
    public List<String>  	failureFileHeaders;
    public List<String> 	errorRecordRows;
    public static Map<Id, Asset> errorAssetMap = new Map<Id, Asset>();
    
    public CTX_CreateLicenseOneTimeBatch(String queryString){
        
        this.queryString 	= queryString;
        failureFileHeaders 	= System.Label.CTX_Bulk_Create_License_Failure_Error_File_Header.replaceAll(' ', '').split(',');
        errorRecordRows		= new List<String>();
    }
    public CTX_CreateLicenseOneTimeBatch(){
        this.queryString = System.Label.CTX_CreateLicenseOneTimeBatch_Query;
        failureFileHeaders 	= System.Label.CTX_Bulk_Create_License_Failure_Error_File_Header.replaceAll(' ', '').split(',');
        errorRecordRows		= new List<String>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        set<String> emailIds = new set<String>();
        List<Asset> assetsToUpdate = new List<Asset>();
        for(Asset assetInstance : (List<Asset>)scope){
            if(assetInstance.Account.Product_Email__c != null){
                emailIds.add(assetInstance.Account.Product_Email__c);
            }
            String region = assetInstance.Account.Country_of_Origin__c != null ? assetInstance.Account.Country_of_Origin__c : 'INDIA';
            String workspaceId;
            if(!emailIds.isEmpty()){
                List<CTX_AssetWorkspaceLinkageController.ProductWorkspaceWrapper> productWorkspaces;
                HttpResponse response = CTX_LicensingAPICalloutClass.workspaceSuggestionCallout(emailIds, assetInstance.License_Id__c, assetInstance.Product2?.SaaS_Product__c, region);
                system.debug('#response: '+response.getBody());
                if(response.getStatusCode() == 200){
                    Map<String, Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                    productWorkspaces = CTX_AssetWorkspaceLinkageController.rephraseAPIResponse(responseMap, NULL, NULL);
                    
                    if(productWorkspaces != NULL){
                        if(productWorkspaces.size() > 0){
                            for( CTX_AssetWorkspaceLinkageController.ProductWorkspaceWrapper workspace : productWorkspaces ){
                                if(workspace.workspaceAdminEmail.contains(assetInstance.Account.Product_Email__c)){
                                    workspaceId = workspace.workspaceId;
                                }
                            }
                        } else {
                            errorAssetMap.put(assetInstance.Id, assetInstance);
                    		recordIdErrorMap.put(assetInstance.Id, 'No Workspace found with given product email. Please help the customer to create a workspace by logging into product in case new workspace needs to be created. If a workspace already exists, please ask the concerned workspace admin to invite ' + assetInstance.Account?.Product_Email__c + ' to their workspace. License can be added to these workspaces once this step is done.');
                            
                            updateSnag.add(
                                CTX_LoggerImplementation.createLoggerInstance(
                                    'No Workspace found with given product email. Please help the customer to create a workspace by logging into product in case new workspace needs to be created. If a workspace already exists, please ask the concerned workspace admin to invite ' + assetInstance.Account?.Product_Email__c + ' to their workspace. License can be added to these workspaces once this step is done.',
                                    NULL,
                                    'CTX_CreateLicenseOneTimeBatch',
                                    'CTX_CreateLicenseOneTimeBatch.execute()',
                                    'Callout Failure',
                                    assetInstance.Id,
                                    'Asset' )
                            );
                        }
                    }
                } else {
                    String errorMessage = '';
                    Map<String, Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                    if(errorMap.containsKey('errorCode')){
                        errorMessage = 'Code : ' + errorMap.get('errorCode') + ' - ' + 'message : ' + errorMap.get('errorMessage');   
                    } else if(errorMap.containsKey('code')){
                        errorMessage = 'Code : ' + errorMap.get('code') + ' - ' + 'message : ' + errorMap.get('message'); 
                    } else {
                        errorMessage = JSON.serialize(response.getBody());
                    }
                    System.debug('Error : '+ assetInstance.Id + ' - ' + response.getBody());
                    
                    errorAssetMap.put(assetInstance.Id, assetInstance);
                    recordIdErrorMap.put(assetInstance.Id, errorMessage);
                    
                    updateSnag.add(
                        CTX_LoggerImplementation.createLoggerInstance(
                            response.getBody(),
                            NULL,
                            'CTX_CreateLicenseOneTimeBatch',
                            'CTX_CreateLicenseOneTimeBatch.execute()',
                            'Callout Failure',
                            assetInstance.Id,
                            'Asset' )
                    );
                    
                }
            }
            
            if(workspaceId != NULL && workspaceId != ''){
                Asset assetToUpdate = activateSingleLicense(assetInstance, new List<String> {workspaceId});
                if(assetToUpdate != NULL){
                	assetsToUpdate.add(assetToUpdate);   
                }
            } else {
                errorAssetMap.put(assetInstance.Id, assetInstance);
                    		recordIdErrorMap.put(assetInstance.Id, 'No Workspace found with given product email. Please help the customer to create a workspace by logging into product in case new workspace needs to be created. If a workspace already exists, please ask the concerned workspace admin to invite ' + assetInstance.Account?.Product_Email__c + ' to their workspace. License can be added to these workspaces once this step is done.');
                            
                            updateSnag.add(
                                CTX_LoggerImplementation.createLoggerInstance(
                                    'No Workspace with given product email matching found. Please help the customer to create a workspace by logging into product in case new workspace needs to be created. If a workspace already exists, please ask the concerned workspace admin to invite ' + assetInstance.Account?.Product_Email__c + ' to their workspace. License can be added to these workspaces once this step is done.',
                                    NULL,
                                    'CTX_CreateLicenseOneTimeBatch',
                                    'CTX_CreateLicenseOneTimeBatch.execute()',
                                    'Callout Failure',
                                    assetInstance.Id,
                                    'Asset' )
                            );
            }
        }
        
        if(assetsToUpdate.size() > 0){
            RecursiveTriggerHandler.isFirstTime = FALSE;
        	RecursiveTriggerHandler.isFirstTimeRenewed = FALSE;
            update assetsToUpdate;
        }
        
        if(errorAssetMap.size() > 0){
            createCSV(errorAssetMap.values());
        }
        
        if(updateSnag.size() > 0){
            insert updateSnag;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        if(errorRecordRows.size() > 0){
            sendMassFailureMailInstance();
        }
        
    }
    
    public Asset activateSingleLicense(Asset currentAsset, List<String> workspaceIds){
        
        Map<String, List<Resource_Constraints__mdt>> mdtResourceConstaintMap = new Map<String, List<Resource_Constraints__mdt>>();
        for(Resource_Constraints__mdt mdt : Resource_Constraints__mdt.getAll().values()){
            if(mdt.Include_In_GCC__c){
                if(mdtResourceConstaintMap.containsKey('GCC')){
                    mdtResourceConstaintMap.get('GCC').add(mdt);
                } else {
                    mdtResourceConstaintMap.put('GCC', new List<Resource_Constraints__mdt>{mdt});
                }
            } else {
                if(mdtResourceConstaintMap.containsKey(mdt.Plan_Tier__c)){
                    mdtResourceConstaintMap.get(mdt.Plan_Tier__c).add(mdt);
                } else {
                    mdtResourceConstaintMap.put(mdt.Plan_Tier__c, new List<Resource_Constraints__mdt>{mdt});
                }
            }
        }
        /** Extract Asset Field Details : END   **/
        
        /** Iterate Over Asset and get Wrapper Details : START  **/
        CTX_UpsertAssetLicensingClass.OutterWrapper             resultWrapper   
            = new CTX_UpsertAssetLicensingClass.OutterWrapper();
        CTX_UpsertAssetLicensingClass.AssetWrapper              myAsset 
            = new CTX_UpsertAssetLicensingClass.AssetWrapper();
        CTX_UpsertAssetLicensingClass.AssetProductWrapper       relatedProduct 
            = new CTX_UpsertAssetLicensingClass.AssetProductWrapper();
        CTX_UpsertAssetLicensingClass.AssetResourceConstraints  assetResourceConstraint
            = new CTX_UpsertAssetLicensingClass.AssetResourceConstraints();
        
        if( !workspaceIds.isEmpty() ){
            
            /** Wrapper Instance Value Assignment : START   **/
            resultWrapper.sfOpportunityId                                       = currentAsset.Opportunity__c;
            resultWrapper.sfOrgName                                             = currentAsset.Name;
            resultWrapper.masterEmailID                                         = currentAsset.Account.Product_Email__c;
            resultWrapper.sfAccountId                                           = currentAsset.AccountId;
            resultWrapper.region                                                = currentAsset.Account.Country_of_Origin__c;
            resultWrapper.isUpdate                                              = FALSE;
            resultWrapper.isTestLicense                                         = currentAsset.Is_Test_Asset__c == NULL ? FALSE : currentAsset.Is_Test_Asset__c;
            resultWrapper.workspaceIds                                          = new List<String>(workspaceIds);
            /** Asset Wrapper Values : START    **/
            myAsset.assetId                                                     = currentAsset.Id;
            myAsset.Name                                                        = currentAsset.Name;
            myAsset.price                                                       = currentAsset.Price;
            myAsset.status                                                      = currentAsset.Status;
            myAsset.assetStartDate                                              = currentAsset.PurchaseDate;
            myAsset.assetEndDate                                                = currentAsset.UsageEndDate;
            myAsset.licenseId                                                   = currentAsset.License_Id__c;   /** NULL in case of Insert  **/
            myAsset.planTier                                                    = currentAsset.Product2.Plan_Tier__c;
            
            myAsset.isCDCEnabled                                            	= currentAsset.Product2.Plan_Tier__c == 'EINVOICE_STANDARD'|| currentAsset.Product2.Plan_Tier__c == 'CLEAR_INVOICING_STANDARD' ? currentAsset.CDC_Applicable__c : FALSE; //Added By Niraj
            
            myAsset.planId                                                      = currentAsset.Product2.Product_Plan_Id__c;
            myAsset.assetEndDateEodInstant                                      = 0;
            myAsset.saasProduct                                                 = currentAsset.Product2.Saas_Product__c;
            /** Asset > Product2    **/
            relatedProduct.licenseProduct                                       = currentAsset.Product_Line__c;
            relatedProduct.productCode                                          = currentAsset.Product2.ProductCode;
            relatedProduct.productFamily                                        = currentAsset.Product2.Family;
            relatedProduct.isStandard                                           = currentAsset.Product2.Is_Standard__c;
            myAsset.product                                                     = relatedProduct;
            /** Asset > ResourceConstraints **/
            assetResourceConstraint.noOfUserIds                                 = currentAsset.License_no_of_userids__c;
            assetResourceConstraint.noOfPurchaseInvoice                         = currentAsset.Number_of_Purchase_Invoice__c;
            assetResourceConstraint.noOfPANs                                    = currentAsset.License_no_of_pans__c;
            assetResourceConstraint.noOfGSTINs                                  = currentAsset.License_no_of_gstins__c;
            assetResourceConstraint.noOfEwayBill                                = currentAsset.Number_of_eway_bill__c;
            assetResourceConstraint.noOfB2CSalesInvoice                         = currentAsset.License_B2C_SalesInvoice_per_year__c;
            assetResourceConstraint.noOfB2BSalesInvoice                         = currentAsset.License_B2B_SalesInvoice_per_year__c;
            assetResourceConstraint.noOfAirlineInvoices                         = currentAsset.No_of_airline_invoices__c;
            assetResourceConstraint.License_no_of_total_Sales_Invoices          = currentAsset.License_no_of_total_Sales_Invoices__c;
            assetResourceConstraint.License_no_of_irns_per_year                 = currentAsset.License_no_of_irns_per_year__c;
            assetResourceConstraint.License_no_of_invoice_formats               = currentAsset.License_no_of_invoice_formats__c;
            assetResourceConstraint.License_no_of_gstin_verification_credits    = currentAsset.License_no_of_gstin_verification_credits__c;
            assetResourceConstraint.License_No_of_MM2A_2B_usage_GSTIN_mon       = currentAsset.License_No_of_MM2A_2B_usage_GSTIN_mon__c;
            assetResourceConstraint.License_no_of_Recon                         = currentAsset.License_no_of_Recon__c;
            myAsset.sfResourceConstraints                                       = (currentAsset.Account.Country_of_Origin__c !=  'India' && !String.ISBLANK(currentAsset.Account.Country_of_Origin__c)) || currentAsset.Product2.Plan_Tier__c == 'CLEAR_IDENTITY_STANDARD' || currentAsset.Product2.SaaS_Product__c == 'NOTICE_MANAGEMENT' || currentAsset.Product2.Plan_Tier__c == 'TDS_TE_ADVANTAGE'? NULL : assetResourceConstraint;
            
            myAsset.resourceConstraints = new List<CTX_UpsertAssetLicensingClass.ResourceConstraints>();
            
            if((currentAsset.Account.Country_of_Origin__c !=  'India' && !String.ISBLANK(currentAsset.Account.Country_of_Origin__c)) || currentAsset.Product2.Plan_Tier__c == 'CLEAR_IDENTITY_STANDARD' || currentAsset.Product2.SaaS_Product__c == 'NOTICE_MANAGEMENT' || currentAsset.Product2.Plan_Tier__c == 'TDS_TE_ADVANTAGE'){
                //CTX_UpsertAssetLicensingClass.ResourceConstraints
                List<Resource_Constraints__mdt> mdtList = (currentAsset.Account.Country_of_Origin__c !=  'India' && !String.ISBLANK(currentAsset.Account.Country_of_Origin__c))? mdtResourceConstaintMap.get('GCC') : mdtResourceConstaintMap.get(currentAsset.Product2.Plan_Tier__c);
                for(Resource_Constraints__mdt mdt : mdtList){
                    if(Integer.ValueOf(currentAsset.get(mdt.Salesforce_Field__c)) != NULL){
                        CTX_UpsertAssetLicensingClass.ResourceConstraints resourceConstraint = new CTX_UpsertAssetLicensingClass.ResourceConstraints();
                        resourceConstraint.resource 				= mdt.Resource__c;
                        resourceConstraint.constraintType 			= mdt.Constraint_Type__c;
                        resourceConstraint.threshold 				= Integer.ValueOf(currentAsset.get(mdt.Salesforce_Field__c)) != NULL ? Integer.ValueOf(currentAsset.get(mdt.Salesforce_Field__c)) : 0;
                        resourceConstraint.isUsageTimeBound 		= mdt.Is_Usage_Time_Bound__c;
                        resourceConstraint.eligibleForNotification 	= mdt.Is_Eligible_For_Notification__c;
                        
                        CTX_UpsertAssetLicensingClass.Metadata metadata = new CTX_UpsertAssetLicensingClass.Metadata();
                        
                        metadata.title								= mdt.Metadata_Title__c;
                        metadata.resourceTitle						= mdt.Metadata_Resource_Title__c;
                        metadata.displayText						= mdt.Metadata_Display_Text__c != NULL ? mdt.Metadata_Display_Text__c : '';
                        metadata.displayPriority					= mdt.Metadata_Display_Priority__c.IntValue();
                        metadata.showOnSummaryPage					= mdt.Metadata_Show_On_Summary_Page__c;
                        metadata.category							= mdt.Metadata_Category__c;
                        metadata.categoryDisplayText				= mdt.Metadata_Category_Display_Text__c;
                        
                        resourceConstraint.metadata				 	= metadata;
                        
                        myAsset.resourceConstraints.add(resourceConstraint);     
                    }
                }                    
            }
            resultWrapper.assets = new List<CTX_UpsertAssetLicensingClass.AssetWrapper>{myAsset};
                /** Asset Wrapper Values : END  **/
                
                String requestJSON = JSON.serialize(resultWrapper);
            system.debug('CTX_UpsertAssetLicense.activateSingleLicense - requestJSON: '+requestJSON);
            
            HttpResponse returnResponse = CTX_LicensingAPICalloutClass.upsertAssetCallout(
                requestJSON, 
                currentAsset.Account.Country_of_Origin__c != NULL ? currentAsset.Account.Country_of_Origin__c : 'INDIA'
            );
            
            system.debug('returnResponse: '+returnResponse.getBody());
            
            if( returnResponse.getStatusCode() == 200 ){
                Map<String, Object> returnResponseOne = (Map<String, Object>)JSON.deserializeUntyped(returnResponse.getBody());
                
                if( 
                    currentAsset.License_ID__c != (String)returnResponseOne.get('licenseId') && 
                    (String)returnResponseOne.get('licenseId') != NULL
                ){
                    currentAsset.License_ID__c = (String)returnResponseOne.get('licenseId');
                }
                
                currentAsset.JSON_Store__c = returnResponse.getBody();
                
                return currentAsset;
            } else{
                String errorMessage = '';
                Map<String, Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(returnResponse.getBody());
                if(errorMap.containsKey('errorCode')){
                    errorMessage = 'Code : ' + errorMap.get('errorCode') + ' - ' + 'message : ' + errorMap.get('errorMessage');   
                } else if(errorMap.containsKey('code')){
                    errorMessage = 'Code : ' + errorMap.get('code') + ' - ' + 'message : ' + errorMap.get('message'); 
                } else {
                    errorMessage = JSON.serialize(returnResponse.getBody());
                }
                System.debug('Error : '+ currentAsset.Id + ' - ' + returnResponse.getBody());
                errorAssetMap.put(currentAsset.Id, currentAsset);
                recordIdErrorMap.put(currentAsset.Id, errorMessage);
                updateSnag.add(
                        CTX_LoggerImplementation.createLoggerInstance(
                            errorMessage,
                            NULL,
                            'CTX_CreateLicenseOneTimeBatch',
                            'CTX_CreateLicenseOneTimeBatch.execute()',
                            'Callout Failure',
                            currentAsset.Id,
                            'Asset' )
                    );
            }
            
            
        }
        
        return null;
    }
    
    public void sendMassFailureMailInstance () {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> toAddresses = new List<String>();
        
        toAddresses.addAll(System.Label.CTX_Bulk_Create_License_Failure_Mail_To_Address.replace(' ','').split(','));  
        String body = 'Hello,' + '<br/><br/>';
        body += 'Please find the attachment of Assets whose license creation failed through bulk license Creation,'+'<br/><br/>';
        
        String errorCSV = String.join(failureFileHeaders, ',') + ',' +'Error' + '\n' + String.join(errorRecordRows, '\n');
        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(errorCSV);
        string csvname= 'Asset Failure Report : Bulk License Creation'+'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        
        body += 'Thanks,<br/>';
        body += 'Team Clear';
        mail.setSubject('Bulk License Creation Failure Report');
        mail.setHtmlBody(body);
        mail.setToAddresses(toAddresses);
        mail.setOrgWideEmailAddressId(defaultMailId);
        mail.setFileAttachments(new List<Messaging.EmailFileAttachment> {csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        
    }
    
    public void createCSV(List<Asset> assetList){  
        
        
        for(Asset assetInstance : assetList){
            List<String> row = new List<String>();
            for(String header : failureFileHeaders){
                if(header.contains('.')){
                    row.add(String.valueOf(assetInstance.getSobject(header.split('\\.')[0]).get(header.split('\\.')[1]))); 
                } else {
                    row.add(String.valueOf(assetInstance.get(header)));   
                }
            }
            row.add(recordIdErrorMap.get(assetInstance.Id));
        	errorRecordRows.add(String.join(row, ','));
        }   
    }

    public void execute(SchedulableContext sc){
        database.executeBatch(new CTX_CreateLicenseOneTimeBatch(), 20);
    }
    
    
}