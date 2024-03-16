@RestResource(urlMapping='/GetRenewalAssetOrOpportunityDetails/*')
global class CTX_AssetExtractAPI {
    
    @HttpPost
    global static UpdateLicenseReturnWrapper updateAssetLicense(
        String	masterEmailId, 
        String	productEmailId, 
        String 	planTier, 
        Integer monthsToExtend, 
        String	oldGstProductLicenseId,
        String	workSpaceId
    ){
        
        UpdateLicenseReturnWrapper	thisWrapper			=	new UpdateLicenseReturnWrapper();
        
        System.debug('masterEmailId: '			+masterEmailId);
        System.debug('productEmailId: '			+productEmailId);
        System.debug('planTier: '				+planTier);
        System.debug('monthsToExtend: '			+monthsToExtend);
        System.debug('oldGstProductLicenseId: '	+oldGstProductLicenseId);
        System.debug('workSpaceId: '			+workSpaceId);
        
        
        
        
        
        
        if(oldGstProductLicenseId != ''){
            Http 		http 	= new Http();
            HttpRequest request = new HttpRequest();
            
            request.setMethod('PUT');
            request.setEndpoint(System.Label.CTX_LicenceDeactivationAPiEndpoint  + oldGstProductLicenseId);
            request.setHeader('X-Api-Token', System.Label.SalesSyncService_X_Api_Token); 
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            
            HttpResponse resp = http.send(request);
            System.debug('jsonResponse: '+resp.getBody());
            
            if(resp.getStatusCode() == 200){
                thisWrapper.licenseDeactivationResult = 'Success';
            } else{
                thisWrapper.licenseDeactivationResult = 'Unsuccessful';
            }
        }
        
        
        if(thisWrapper.licenseDeactivationResult == 'Success'){
            
            List<Asset> 				existingAssetToUpdate 	=	new List<Asset>();
            List<Asset> 				newAssetToInsert 		=	new List<Asset>();
            Map<String, Product2> 		productMapByPlanTire 	= 	new Map<String, Product2>();
            List<Asset> 				upsertAssetList 		= 	new List<Asset>();
            Set<Id>						relatedAccountId		= 	new Set<Id>();
            Boolean						isValidWorkspace		= 	FALSE;
            Set<String>					validEmails				= 	new Set<String>();
            List<Asset>					filteredAssets;
            List<Workspace__c>			relatedWorkspaceList;
            
            
            if(String.isNotBlank(masterEmailId) || String.isNotEmpty(masterEmailId)){
                if(CTX_UtilityClass.validateEmailAddress(masterEmailId))
                    validEmails.add(masterEmailId);
            }
            
            if(String.isNotBlank(productEmailId) || String.isNotEmpty(productEmailId)){
                if(CTX_UtilityClass.validateEmailAddress(productEmailId))
                    validEmails.add(productEmailId);
            }
            
            if(validEmails.size() <= 0){
                thisWrapper.errorMessage	= 'Please provide valid Email Ids to proceed.';
                thisWrapper.isSuccess 		= FALSE;
                return thisWrapper;
            }
            
            for(
                Product2 thisRec : [ SELECT Id, Name, Plan_Tier__c 
                                    FROM Product2 WHERE 
                                    Plan_Tier__c = :planTier ]
            ){
                productMapByPlanTire.put(thisRec.Plan_Tier__c, thisRec);
            }
            
            if(productMapByPlanTire.keySet().size() < 1){
                thisWrapper.errorMessage	= 'We do not have any product available with the given Plan Tier.';
                thisWrapper.isSuccess 		= FALSE;
                return thisWrapper;
            }
            
            if( thisWrapper.isSuccess ){
                
                Boolean isFutureAssetUpdated 	= FALSE;
                filteredAssets 					= [ SELECT 
                                                   
                                                   Id, Name, Status, UsageEndDate, Platform__c, Primary_POC__c, 
                                                   Workspace_Details__c, Is_License_Created__c, License_ID__c, 
                                                   Churn_Reason__c, Other_Reason_for_Churn__c, First_Churn_Reason_L1__c,
                                                   First_Churn_Reason_L2__c, First_Churn_Reason_L3__c, 
                                                   Competition_Currently_Using__c, Churn_Level_2_Reason__c,
                                                   
                                                   AccountId, Account.Master_Admin_Email__c, Account.Product_Email__c, 
                                                   
                                                   Product2.Is_Standard__c, 
                                                   
                                                   Opportunity__r.Master_Admin_Email__c, 
                                                   Renewal_Opportunity__r.Master_Admin_Email__c,
                                                   
                                                   Product2.Plan_Tier__c, Product2.Product_Plan_Id__c, Product2.ProductCode,
                                                   Product2.Product_Line__c
                                                   
                                                   FROM Asset WHERE
                                                   
                                                   Product2.Product_Line__c 	= 'GST' AND
                                                   ( NOT Status IN :System.Label.Asset_Standard_Plan_Exclude_Status.split(';') ) AND
                                                   
                                                   (
                                                       Account.Master_Admin_Email__c IN :validEmails OR
                                                       Account.Product_Email__c IN :validEmails OR
                                                       ( License_ID__c = :oldGstProductLicenseId AND License_ID__c != NULL )
                                                   ) 
                                                   ORDER BY UsageEndDate DESC ];
                
                for(Asset thisRec : filteredAssets){
                    System.debug('Inside Asset Query Blog : '+thisRec.Id);
                    
                    relatedAccountId.add(thisRec.AccountId);
                    String emailIdToProceed;
                    
                    if( validEmails.contains(thisRec.Account.Product_Email__c) ){
                        emailIdToProceed = thisRec.Account.Product_Email__c;
                    } else if( validEmails.contains(thisRec.Account.Master_Admin_Email__c) ){
                        emailIdToProceed = thisRec.Account.Master_Admin_Email__c;
                    }
                    
                    if(filteredAssets.size() > 1){
                        
                        Asset myAsset 							= thisRec.clone(FALSE, FALSE, FALSE, FALSE);
                        myAsset.Product2Id 						= productMapByPlanTire.get(planTier).Id;
                        myAsset.Platform__c 					= 'App.Clear';
                        myAsset.Is_License_Created__c 			= TRUE;
                        myAsset.License_ID__c 					= NULL;
                        myAsset.Workspace_Details__c			= workSpaceId;
                        myAsset.Master_Email__c					= emailIdToProceed;
                        myAsset.PurchaseDate 					= System.today();
                        if(myAsset.Status == 'Future' && !isFutureAssetUpdated){
                            myAsset.UsageEndDate = (monthsToExtend != NULL) ? 
                                thisRec.UsageEndDate.addMonths(monthsToExtend) : myAsset.UsageEndDate;
                            isFutureAssetUpdated = TRUE;
                        }
                        newAssetToInsert.add(myAsset);
                        
                        thisRec.Status 							= 'Churn';
                        thisRec.Churn_Reason__c 				= 'Others';
                        thisRec.Other_Reason_for_Churn__c  		= 'Deactivating the License for creating new License.';
                        thisRec.First_Churn_Reason_L1__c 		= 'Self goals';
                        thisRec.First_Churn_Reason_L2__c 		= 'Free usage';
                        thisRec.First_Churn_Reason_L3__c 		= 'APIs';
                        thisRec.Competition_Currently_Using__c 	= 'Other';
                        thisRec.Churn_Level_2_Reason__c     	= 'SF Update';
                        thisRec.Is_License_Created__c 			= FALSE;
                        thisRec.Workspace_Details__c			= workSpaceId;
                        existingAssetToUpdate.add(thisRec);
                        
                    } else if(filteredAssets.size() == 1){
                        
                        Asset myAsset 							= thisRec.clone(FALSE, FALSE, FALSE, FALSE);
                        myAsset.Product2Id 						= productMapByPlanTire.get(planTier).Id;
                        myAsset.Platform__c 					= 'App.Clear';
                        myAsset.Is_License_Created__c 			= TRUE;
                        myAsset.License_ID__c 					= NULL;
                        myAsset.Workspace_Details__c			= workSpaceId;
                        myAsset.Master_Email__c					= emailIdToProceed;
                        myAsset.PurchaseDate 					= System.today();
                        myAsset.UsageEndDate 					= (monthsToExtend != null) 
                            ? thisRec.UsageEndDate.addMonths(monthsToExtend) : myAsset.UsageEndDate;
                        newAssetToInsert.add(myAsset);
                        
                        thisRec.Status 							= 'Churn';
                        thisRec.Churn_Reason__c 				= 'Others';
                        thisRec.Other_Reason_for_Churn__c  		= 'Deactivating the License for creating new License.';
                        thisRec.First_Churn_Reason_L1__c 		= 'Self goals';
                        thisRec.First_Churn_Reason_L2__c		= 'Free usage';
                        thisRec.First_Churn_Reason_L3__c 		= 'APIs';
                        thisRec.Competition_Currently_Using__c 	= 'Other';
                        thisRec.Churn_Level_2_Reason__c			= 'SF Update';
                        thisRec.Is_License_Created__c 			= FALSE;
                        thisRec.Workspace_Details__c			= workSpaceId;
                        existingAssetToUpdate.add(thisRec);
                    }
                }
                
                system.debug('Before I am related Asset Account Entry: '+relatedAccountId.size());
                if(relatedAccountId.size() > 0){
                    relatedWorkspaceList = [ SELECT 
                                            
                                            Id, Org_Unit_ID__c 
                                            
                                            FROM Workspace__c WHERE 
                                            
                                            Root_Workspace__c = TRUE AND 
                                            Account__c IN :relatedAccountId AND 
                                            Org_Unit_ID__c != NULL ];
                    
                    if(relatedWorkspaceList != NULL && relatedWorkspaceList.size() > 0){
                        
                        for(Workspace__c thisRec : relatedWorkspaceList){
                            if(thisRec.Org_Unit_ID__c == workSpaceId){
                                isValidWorkspace = TRUE;
                            }
                        } 
                    } else{
                        isValidWorkspace = TRUE;
                    }
                }
                
                if(isValidWorkspace){
                    
                    upsertAssetList.addAll(existingAssetToUpdate);
                    upsertAssetList.addAll(newAssetToInsert);
                    
                    try{
                        upsert upsertAssetList;
                        thisWrapper.isSuccess = TRUE;
                        thisWrapper.successMessage = 'Assets upserted successfully.';
                    } catch(Exception ex){
                        thisWrapper.isSuccess = FALSE;
                        thisWrapper.errorMessage = ex.getMessage();
                    }
                } else{
                    thisWrapper.isSuccess = FALSE;
                    thisWrapper.errorMessage = 'Workspace Id Does not Match, Please Check and rectify.';
                }
            }
        }
        
        System.debug('thisWrapper.isSuccess: '					+thisWrapper.isSuccess);
        system.debug('thisWrapper.errorMessage: '				+thisWrapper.errorMessage);
        system.debug('thisWrapper.successMessage: '				+thisWrapper.successMessage);
        system.debug('thisWrapper.licenseDeactivationResult: '	+thisWrapper.licenseDeactivationResult);
        
        return thisWrapper;
    }
    
    global class UpdateLicenseReturnWrapper{
        
        Boolean 		isSuccess					=	TRUE;
        String			errorMessage;
        String  		successMessage;
        String			licenseDeactivationResult;
    }
}