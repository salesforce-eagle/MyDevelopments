/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-22-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_AssetWorkspaceLinkageController {
    public class CTX_AssetWorkspaceLinkageException extends Exception {}
    @AuraEnabled
    public static List<ProductWorkspaceWrapper> fetchProductWorkspaces(String recordId){
        try{
            if(recordId != null || recordId != ''){
                set<String> emailIds = new set<String>();
                Asset assetInstance = [SELECT Id, Name, AccountId, Account.Country_of_Origin__c, Account.Master_Admin_Email__c, Account.Product_Email__c, Product2.SaaS_Product__c, License_Id__c, Opportunity__c FROM Asset WHERE Id =: recordId LIMIT 1];
                
                Id accountId = assetInstance.AccountId;
                List<ProductWorkspaceWrapper> productWorkspaces;
                
                if(assetInstance.Account.Product_Email__c != null){
                    emailIds.add(assetInstance.Account.Product_Email__c);
                } /*else if(assetInstance.Account.Master_Admin_Email__c != null){
                    emailIds.add(assetInstance.Account.Master_Admin_Email__c);
                }*/
                
                String region = assetInstance.Account.Country_of_Origin__c != null ? assetInstance.Account.Country_of_Origin__c : 'INDIA';
                
                if(!emailIds.isEmpty()){
                    HttpResponse response = CTX_LicensingAPICalloutClass.workspaceSuggestionCallout(emailIds, assetInstance.License_Id__c, assetInstance.Product2?.SaaS_Product__c, region);
                    system.debug('#response: '+response.getBody());
                    if(response.getStatusCode() == 200){
                        Map<String, Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                        return rephraseAPIResponse(responseMap, accountId, productWorkspaces);
                    } else {
                        Map<String, Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                        if(errorMap.containsKey('errorCode')){
                        	throw new CTX_AssetWorkspaceLinkageException('Code : ' + errorMap.get('errorCode') + ' - ' + 'message : ' + errorMap.get('errorMessage'));   
                        } else if(errorMap.containsKey('code')){
                            throw new CTX_AssetWorkspaceLinkageException('Code : ' + errorMap.get('code') + ' - ' + 'message : ' + errorMap.get('message')); 
                        } else {
                            throw new CTX_AssetWorkspaceLinkageException(JSON.serialize(response.getBody()));
                        }
                    }
                }
            }
            
        } catch(Exception ex){
            throw new AuraHandledException('Error while Upsert: '+ex.getMessage());
        }        
        return null;
    }
    
    Public Static List<ProductWorkspaceWrapper> rephraseAPIResponse(
        Map<String, Object> 		response,
        Id 							accountId,
        List<ProductWorkspaceWrapper> 	productWorkspaces
    ){
        List <AssetWorkspaceLinkWrapper> linkWrapperList = new List<AssetWorkspaceLinkWrapper>();
        try{
            Map<String, Object> test = (Map<String, Object>)response.get('suggestions');
            productWorkspaces = new List<ProductWorkspaceWrapper>();
            for(Object thisResponse : (List<Object>)test.values()){
                
                CTX_ProductWorkspace_Response_Parser innerResponse_WorkspaceDetails 
                    = (CTX_ProductWorkspace_Response_Parser)JSON.deserialize(
                        JSON.serialize(thisResponse), CTX_ProductWorkspace_Response_Parser.class
                    );
                
                if( innerResponse_WorkspaceDetails.exactWorkspaceDetails != NULL ){
                    for(
                        CTX_ProductWorkspace_Response_Parser.ExactWorkspaceDetails thisRec : innerResponse_WorkspaceDetails.exactWorkspaceDetails
                    ){
                        ProductWorkspaceWrapper	exactMatchWorkspace = new ProductWorkspaceWrapper();
                        
                        exactMatchWorkspace.workspaceName 			= thisRec.workspaceName != NULL ? thisRec.workspaceName : '';
                        exactMatchWorkspace.workspaceId 			= thisRec.workSpaceId;                   
                        exactMatchWorkspace.workspaceAdminEmail 	= thisRec.workspaceAdminEmail;
                        exactMatchWorkspace.isSuggested				= false;
                        exactMatchWorkspace.domainName 				= innerResponse_WorkspaceDetails.domainName;
                        exactMatchWorkspace.isExisting				= thisRec.licenseMatched;
                        exactMatchWorkspace.licenseId				= thisRec.licenseId;
                        
                        productWorkspaces.add(exactMatchWorkspace);
                    }
                }
                
                if( innerResponse_WorkspaceDetails.suggestedWorkspaceDetails != NULL ){
                    for(
                        CTX_ProductWorkspace_Response_Parser.SuggestedWorkspaceDetails thisRec : innerResponse_WorkspaceDetails.suggestedWorkspaceDetails
                    ){
                        
                        
                        ProductWorkspaceWrapper	suggestedWorkspace = new ProductWorkspaceWrapper();
                        
                        suggestedWorkspace.workspaceName 			= thisRec.workspaceName != NULL ? thisRec.workspaceName : '';
                        suggestedWorkspace.workspaceId 				= thisRec.workSpaceId;                   
                        suggestedWorkspace.workspaceAdminEmail 		= thisRec.workspaceAdminEmail;
                        suggestedWorkspace.isSuggested				= true;
                        suggestedWorkspace.domainName 				= innerResponse_WorkspaceDetails.domainName;
                        suggestedWorkspace.isExisting				= thisRec.licenseMatched;
                        suggestedWorkspace.licenseId				= thisRec.licenseId;
                        
                        productWorkspaces.add(suggestedWorkspace);
                    }
                }
            }
            return productWorkspaces;
            
        } catch(Exception ex) {
            throw new AuraHandledException('Error while Upsert: '+ex.getMessage());
        } 
    }
    
    @AuraEnabled
    Public Static void linkAssetWorkspace(Id assetId, List<ProductWorkspaceWrapper> productWorkspace){
        try{
            
            if(assetId != null){
                set<String> workspaceIds = new set<String>();
                for(ProductWorkspaceWrapper prodWorkspace : productWorkspace){
                    workspaceIds.add(prodWorkspace.workspaceId);
                }
                
                if(!workspaceIds.isEmpty()){
                    Asset assetInst = [SELECT Id, Name, License_Id__c,Account.Country_of_Origin__c, Account.Product_Email__c FROM Asset WHERE Id =: assetId LIMIT 1];
                    String region = assetInst.Account.Country_of_Origin__c != null ? assetInst.Account.Country_of_Origin__c : 'INDIA';
                    if(assetInst.License_Id__c != null){
                        HttpResponse response = CTX_LicensingAPICalloutClass.addWorkspaceToAssetcallout(assetInst.License_Id__c, assetInst.Account.Product_Email__c, workspaceIds, region);   
                        
                        if(response.getStatusCode() == 200){
                            System.debug('##ResponseL: '+ response.getBody());
                        } else {
                            Map<String, Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                            if(errorMap.containsKey('errorCode')){
                                throw new CTX_AssetWorkspaceLinkageException('Code : ' + errorMap.get('errorCode') + ' - ' + 'message : ' + errorMap.get('errorMessage'));   
                            } else if(errorMap.containsKey('code')){
                                throw new CTX_AssetWorkspaceLinkageException('Code : ' + errorMap.get('code') + ' - ' + 'message : ' + errorMap.get('message')); 
                            } else {
                                throw new CTX_AssetWorkspaceLinkageException(JSON.serialize(response.getBody()));
                            }
                        }
                    }
                    else {
						throw new CTX_AssetWorkspaceLinkageException('License Id is not present on Asset');                        
                    }
                }
            }
        } catch(Exception ex){
            throw new AuraHandledException('Error While Adding Workspace - ' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<ProductWorkspaceWrapper> fetchRelatedWorkspaces(Id assetId){
        if(assetId != null || assetId != ''){
            //return [SELECT Id, Name, Workspace__c, Workspace__r.OrgUnitId__c, Workspace__r.Name, Workspace__r.Workspace_Admin_Email__c FROM Asset_Workspace_Junction__c WHERE Asset__c =: assetId];
            List<ProductWorkspaceWrapper> productWorkspaces = fetchProductWorkspaces(assetId);
            List<ProductWorkspaceWrapper> relatedWorkspaces = new List<ProductWorkspaceWrapper>();
            if(productWorkspaces != null){
            	for(ProductWorkspaceWrapper prodWorkspace : productWorkspaces){
                    if(prodWorkspace.isExisting == true && prodWorkspace.isSuggested == false){
                        relatedWorkspaces.add(prodWorkspace);
                    }
            	}
                return relatedWorkspaces;
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static void deleteSelectedWorkspaceJunctions(Id assetId, List<ProductWorkspaceWrapper>junctionsToDelete){
        try{
            
            set<String> workspacesIdsToRemove = new set<String>();
            for(ProductWorkspaceWrapper junctionInst : junctionsToDelete){
                workspacesIdsToRemove.add(junctionInst.workspaceId);
            }
            if(!workspacesIdsToRemove.isEmpty()){
                Asset assetInst = [SELECT Id, Name, License_Id__c, Account.Product_Email__c, Account.Country_of_Origin__c FROM Asset WHERE Id =: assetId LIMIT 1];
                String region = assetInst.Account.Country_of_Origin__c != null ? assetInst.Account.Country_of_Origin__c : 'INDIA';
                if(assetInst.License_Id__c != null){
                    HttpResponse response = CTX_LicensingAPICalloutClass.removeWorkspaceFromAssetcallout(assetInst.License_Id__c, assetInst.Account.Product_Email__c, workspacesIdsToRemove, region);
                    if(response.getStatusCode() == 200){
                        System.debug('##ResponseL: '+ response.getBody());
                        //delete junctionsToDelete;
                    } else {
                        Map<String, Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                        if(errorMap.containsKey('errorCode')){
                            throw new CTX_AssetWorkspaceLinkageException('Code : ' + errorMap.get('errorCode') + ' - ' + 'message : ' + errorMap.get('errorMessage'));   
                        } else if(errorMap.containsKey('code')){
                            throw new CTX_AssetWorkspaceLinkageException('Code : ' + errorMap.get('code') + ' - ' + 'message : ' + errorMap.get('message')); 
                        } else {
                            throw new CTX_AssetWorkspaceLinkageException(JSON.serialize(response.getBody()));
                        }   
                    }
                }
            }
            
        } catch(Exception ex) {
            throw new AuraHandledException('Error while Upsert: '+ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deactivateExistingLicense(String recordId){
        try{
            String licenseId, message = 'License Id missing!';
            String region;
            Asset assetInst;
            if(recordId != NULL){
                assetInst = [ SELECT Id, License_Id__c, Account.Country_of_Origin__c, Status FROM Asset WHERE Id =:recordId LIMIT 1 ];
                licenseid = assetInst.License_Id__c;
                region = assetInst.Account?.Country_of_Origin__c != null ? assetInst.Account?.Country_of_Origin__c : 'INDIA';
            }
            
            if(licenseId != NULL){
                
                HttpResponse response = CTX_LicensingAPICalloutClass.deactivateLicenseCallout(licenseId, region);
                
                if(response.getStatusCode() == 200){
                    RecursiveTriggerHandler.isFirstTime = FALSE;
                    //assetInst.Status = 'Suspended';
                    assetInst.License_Id__c = NULL;
                    update assetInst;
                    message = 'License Deactivated Successfully.';
                } else{
                    Map<String, Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                    if(errorMap.containsKey('errorCode')){
                        throw new CTX_AssetWorkspaceLinkageException('Code : ' + errorMap.get('errorCode') + ' - ' + 'message : ' + errorMap.get('errorMessage'));   
                    } else if(errorMap.containsKey('code')){
                        throw new CTX_AssetWorkspaceLinkageException('Code : ' + errorMap.get('code') + ' - ' + 'message : ' + errorMap.get('message')); 
                    } else {
                        throw new CTX_AssetWorkspaceLinkageException(JSON.serialize(response.getBody()));
                    }
                }
            }
            
        } catch(Exception ex) {
            throw new AuraHandledException('Error while Upsert: '+ex.getMessage());
        }
    }

	
    @AuraEnabled
    public static void deactivateOldLicense_Migration(String recordId, List<String> licensesToDeactivate){
        try{
            String region;
            Asset assetInst;
            if(recordId != NULL){
                assetInst = [ SELECT Id, License_Id__c, Account.Country_of_Origin__c, Status FROM Asset WHERE Id =:recordId LIMIT 1 ];
                region = assetInst.Account?.Country_of_Origin__c != null ? assetInst.Account?.Country_of_Origin__c : 'INDIA';
            }
            Map<String, String> licenseIdToErrorMap = new Map<String, String>();
            HttpResponse response = CTX_LicensingAPICalloutClass.bulkDeactivateLicenseCallout(licensesToDeactivate, region);
            
            if(response.getStatusCode() == 200){
                
            } else{
                Map<String, Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                if(errorMap.containsKey('errorCode')){
                    throw new CTX_AssetWorkspaceLinkageException('Code : ' + errorMap.get('errorCode') + ' - ' + 'message : ' + errorMap.get('errorMessage'));   
                } else if(errorMap.containsKey('code')){
                    throw new CTX_AssetWorkspaceLinkageException('Code : ' + errorMap.get('code') + ' - ' + 'message : ' + errorMap.get('message')); 
                } else {
                    throw new CTX_AssetWorkspaceLinkageException(JSON.serialize(response.getBody()));
                }
            }
          
        }
        catch(Exception ex){
        	throw new AuraHandledException('Error : '+ex.getMessage());    
        }
    }
    
    @AuraEnabled
    public static List<Product2> getProducts(String recordId, String productId){
    	return [SELECT Id, Name, Plan_Tier__c FROM Product2 WHERE Plan_Tier__c LIKE '%CLEAR_GST%'];    
    }
    
	@AuraEnabled
    public static void productUpdate(String recordId, String productId, String oldProductId, String assetName){
        try{
        	Product2 relatedProduct = [SELECT Id, Name, Plan_Tier__c FROM Product2 WHERE Id =: productId LIMIT 1];
            if(relatedProduct.Plan_Tier__c == NULL || relatedProduct.Plan_Tier__c == 'null'){
                throw new CTX_AssetWorkspaceLinkageException('Kindly Select Valid Product Where Plan Tier is Not Null');
            } else{
                RecursiveTriggerHandler.isFirstTime = FALSE;
            	update new Asset(Id=recordId, Name = 'Migrated : ' + assetName, Product2Id=productId, Product_Before_Migration__c = oldProductId, Date_Of_Migration__c = System.today());   
            }
        }
        catch(Exception ex){
            throw new AuraHandledException('Error : '+ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void activateNewLicense(String recordId, List<String>workspaceIds, String oldProductId, String assetName){
        try{
            CTX_UpsertAssetLicense.activateSingleLicense(recordId, workspaceIds);
        } catch(Exception ex){
            //RecursiveTriggerHandler.isFirstTime = FALSE;
            //update new Asset(Id = recordId, Name = assetName, Product2Id = oldProductId, Product_Before_Migration__c = NULL, Date_Of_Migration__c = NULL);
            throw new AuraHandledException('Error : '+ex.getMessage());
        }
    }

	@AuraEnabled
	public static List<Object> getAllOldGSTLicenses(String recordId) {
        try{
            Asset assetInst;
            String region;
            List<String> existingLicenses = new List<String>();
            if(recordId != NULL){
                assetInst = [ SELECT Id, License_Id__c, Account.Product_Email__c, Product2.SaaS_Product__c, Account.Country_of_Origin__c, Status FROM Asset WHERE Id =:recordId LIMIT 1 ];
                if(assetInst.License_Id__c == NULL){
                    if(assetInst.Account?.Product_Email__c == NULL){
                        throw new CTX_AssetWorkspaceLinkageException('Kindly select valid product email on Account.');
                    } else {
                        HttpResponse response = CTX_LicensingAPICalloutClass.fetchGSTLicenses(assetInst.Account?.Product_Email__c, assetInst.Account?.Country_of_Origin__c);
                        if(response.getStatusCode() == 200){
                            System.debug('#response: '+ response.getBody());
                            List<Object> resultListMap = (List<Object>)JSON.deserializeUntyped(response.getBody());                   
                            return resultListMap;
                            
                        } else {
                            Map<String, Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                            if(errorMap.containsKey('errorCode')){
                                throw new CTX_AssetWorkspaceLinkageException('Code : ' + errorMap.get('errorCode') + ' - ' + 'message : ' + errorMap.get('errorMessage'));   
                            } else if(errorMap.containsKey('code')){
                                throw new CTX_AssetWorkspaceLinkageException('Code : ' + errorMap.get('code') + ' - ' + 'message : ' + errorMap.get('message')); 
                            } else {
                                throw new CTX_AssetWorkspaceLinkageException(JSON.serialize(response.getBody()));
                            }
                        }   
                    }
                } else {
                	existingLicenses.add(assetInst.License_Id__c);   
                }
            }
            return NULL;
        }
        catch(Exception ex){
        	throw new AuraHandledException('Error : '+ex.getMessage());    
        }
    }    
    
    public class AssetWorkspaceLinkWrapper {
        @AuraEnabled
        public Boolean isExisting = false;
    }
    
    public class ProductWorkspaceWrapper {
        @AuraEnabled
        public Boolean isExisting = false;
        @AuraEnabled
        public String workspaceName {get;set;}
        @AuraEnabled
        public String workspaceId {get;set;}
        @AuraEnabled
        public String workspaceAdminEmail {get;set;}
        @AuraEnabled
        public String domainName {get;set;}
        @AuraEnabled
        public Boolean isSuggested = false;
        @AuraEnabled
        public String licenseId {get;set;}
        
    }
}