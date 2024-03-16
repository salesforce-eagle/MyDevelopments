/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-04-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_AdhocScriptForPostSale {
    
    /**	Single Operations	**/
    @AuraEnabled
    public static String createAssetPostOpportunityClosure( String opportunityId ){
        
        system.debug('opportunityId: '+opportunityId);
        String returnResult;
        
        if( String.isNotBlank(opportunityId) && opportunityId != NULL && opportunityId != '' ){
            
            List<String> 			fieldList			= new List<String>();
            String					multiYearRenewal 	= 'Renewal - Multi year';
            Map<Id, Opportunity> 	opportunityMap;
            List<Opportunity>		validOpportunities	= new List<Opportunity>();
            
            for( Schema.SObjectField field : Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().values() ){
                fieldList.add( field.getDescribe().getName() );
            }
            
            String queryString 	=	' SELECT '+ String.join(fieldList, ', ') + ', ( SELECT Id FROM Assets__r )';
            queryString 		+= 	' FROM Opportunity WHERE Id = :opportunityId AND recordType.Name != :multiYearRenewal LIMIT 1 '; 
            
            opportunityMap 		= 	new Map<Id, Opportunity>( (List<Opportunity>)database.query(queryString) );
            system.debug('opportunityMap: '+opportunityMap);
            
            if( opportunityMap.values() != NULL && opportunityMap.values().size() > 0 ){
                
                for(Opportunity thisRec : opportunityMap.values() ){
                    
                    thisRec.CloseDate = System.Today();
                    system.debug('thisRec.Assets__r: '+thisRec.Assets__r);
                    if( thisRec.Assets__r != NULL && thisRec.getSobjects('Assets__r') != NULL && thisRec.getSobjects('Assets__r').size() > 0 ){
                        returnResult = 'Assets already created, either all assets or partially assets are created. Not valid process.';
                    } else{
                        validOpportunities.add(thisRec);
                    }
                }
                
                if(validOpportunities.size() > 0){
                    try{
                        OpportunityTriggerHelper.CreateOrder(validOpportunities);
                        
                        
                        OpportunityConstants.AUTO_RENEW_RULE 			= FALSE;
                        RecursiveTriggerHandler.isFirstTimeOpportunity 	= FALSE;
                        update validOpportunities;
                        OpportunityConstants.AUTO_RENEW_RULE 			= TRUE;
                        RecursiveTriggerHandler.isFirstTimeOpportunity 	= TRUE;
                        
                        
                        returnResult = 'Assets created successfully.'; 
                    } catch(Exception ex){
                        system.debug('Errro while creating Asset: '+ex.getMessage());
                        returnResult = ex.getMessage();
                    }
                }
            } else{
                returnResult = 'No Records found with the given Opportunity. Check if the Opportunity is Multi Year, then Asset creation is not allowed.';
            }
            
        } else{
            returnResult = 'Bad value for Opportunity Id.';
        }
        
        return returnResult;
    }
    
    @AuraEnabled
    public static String createIntegrationProjectOnAsset( String assetId ){
        
        system.debug('assetId: '+assetId);
        String returnResult;
        
        if( String.isNotBlank(assetId) && assetId != NULL && assetId != '' ){
            
            Map<Id, Asset> 	assetMap 				= new map<Id, Asset>( [ SELECT Id, Name, Product2Id, RecordTypeId, 
                                                                           Product2.Product_Category__c, Product2.ProductCode, Product2.Name, Product2.Family, Product2.Plan_Tier__c, 
                                                                           Product2.Product_Line__c, Product2.Is_Applicable_for_Licensing__c, Product2.Billing_Type__c, 
                                                                           ( SELECT Id, Name FROM Projects__r )
                                                                           FROM Asset WHERE Id = :assetId LIMIT 1 ] );
            Boolean			isIntegrationEligiable 	= FALSE;
            Asset 			parentAsset;
            
            try{
                parentAsset = assetMap?.get(assetId);
            } catch(Exception ex){
                returnResult = 'No Record found with the given Asset.';
            }
            
            if( parentAsset != NULL ){
                if(
                    ( parentAsset.RecordTypeId == System.Label.Asset_RecordType_Integration || parentAsset.RecordTypeId == AssetConstants.ASSET_INTEGRATIONID_RECORDTYPEID ) && 
                    !(  parentAsset.Product2.Product_Category__c == 'AMC' && parentAsset.Product2.Billing_Type__c != 'ARR' ) &&  
                    !System.Label.ExcludeProjectAutoCreation.containsIgnoreCase(parentAsset.Product2.ProductCode)
                ){
                    isIntegrationEligiable = TRUE;
                }
                
                if( 
                    parentAsset != NULL && 
                    parentAsset.getSobjects('Projects__r') != NULL 
                ){
                    isIntegrationEligiable = FALSE;
                    returnResult = 'Integration Project is already present, Project creation is not allowed.';
                }
            }
            
            
            if(isIntegrationEligiable){
                
                try{
                    AssetTriggerHelper.autoCreateIntegrationProject( new Set<Id>{assetId} );
                    returnResult = 'Project created successfully.';
                } catch(Exception ex){
                    system.debug('Errro while creating Project: '+ex.getMessage());
                    returnResult = ex.getMessage();
                }
            } else{
                returnResult = 'Integration project is not eligible for this Asset';
            }
        } else{
            returnResult = 'Invalid Asset Id: '+assetId;
        }
        
        
        return returnResult;
    }
    
    @AuraEnabled
    public static String createAMCProjectOnAsset( String assetId ){
        
        system.debug('assetId: '+assetId);
        String returnResult;
        if( String.isNotBlank(assetId) && assetId != NULL && assetId != '' ){
            
            Map<Id, Asset> 	assetMap 		= new map<Id, Asset>( [ SELECT Id, Name, Product2Id, 
                                                                   Product2.Product_Category__c, Product2.ProductCode, Product2.Name, Product2.Family, Product2.Plan_Tier__c, 
                                                                   Product2.Product_Line__c, Product2.Is_Applicable_for_Licensing__c, Product2.Billing_Type__c, 
                                                                   ( SELECT Id, Name FROM Projects__r )
                                                                   FROM Asset WHERE Id = :assetId LIMIT 1 ] );
            Boolean			isAMCEligiable 	= FALSE;
            Asset 			parentAsset;
            
            try{
                parentAsset = assetMap?.get(assetId);
            } catch(Exception ex){
                returnResult = 'No Record found with the given Asset.';
            }
            
            if( parentAsset != NULL ){
                if( parentAsset.Product2.Product_Category__c == 'AMC' && parentAsset.Product2.Billing_Type__c != 'ARR' ){
                    isAMCEligiable = TRUE;
                }
                
                if( parentAsset.getSobjects('Projects__r') != NULL ){
                    isAMCEligiable = FALSE;
                    returnResult = 'AMC Project is already present, Project creation is not allowed.';
                }
            }
            
            if(isAMCEligiable){
                
                try{
                    AssetTriggerHelper.autoCreateIntegrationProject( new Set<Id>{assetId} );
                    returnResult = 'Project created successfully.';
                } catch(Exception ex){
                    system.debug('Errro while creating Project: '+ex.getMessage());
                    returnResult = ex.getMessage();
                }
            } else{
                returnResult = 'AMC project is not eligible for this Asset';
            }
        } else{
            returnResult = 'Invalid Asset Id: '+assetId;
        }
        
        
        return returnResult;
    }
    
    @AuraEnabled
    public static void createUpsellOpportunity( String upsellToupId ){
        
        Map<Id, Upsell_Top_up__c> mapOfNewUpselltoUpdate = new Map<Id, Upsell_Top_up__c>(
            [ SELECT Id, Asset__c, Product__c, Account__c, OwnerId, Additional_Price__c, Approved_Date__c, No_of_GSTIN__c, No_of_GSTIN_verification_credits__c,
             No_of_PANs__c, No_of_user_IDs__c, No_of_B2B_Sales_invoice__c, No_of_B2C_Sales_invoice__c, No_of_purchase_invoice__c, No_of_vendors__c, 
             No_of_IRNs__c, No_of_E_way_bill__c FROM Upsell_Top_up__c WHERE Id = :upsellToupId ]
        );
        
        UpsellTriggerHelper.createOpportunity(mapOfNewUpselltoUpdate);
    }
    
    
    /**	Bulk Operations	**/
    @AuraEnabled
    public static String createAssetPostOpportunitiesClosure( List<String> opportunityIds ){
        
        system.debug('opportunityIds: '+opportunityIds);
        String returnResult;
        
        if( opportunityIds != NULL && opportunityIds.size() > 0 ){
            
            List<String> 			fieldList			= new List<String>();
            String					multiYearRenewal 	= 'Renewal - Multi year';
            Map<Id, Opportunity> 	opportunityMap;
            List<Opportunity>		validOpportunities	= new List<Opportunity>();
            
            for( Schema.SObjectField field : Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().values() ){
                fieldList.add( field.getDescribe().getName() );
            }
            
            String queryString 	=	' SELECT '+ String.join(fieldList, ', ') + ', ( SELECT Id FROM Assets__r )';
            queryString 		+= 	' FROM Opportunity WHERE Id IN :opportunityIds AND recordType.Name != :multiYearRenewal '; 
            
            opportunityMap 		= 	new Map<Id, Opportunity>( (List<Opportunity>)database.query(queryString) );
            system.debug('opportunityMap: '+opportunityMap);
            
            if( opportunityMap.values() != NULL && opportunityMap.values().size() > 0 ){
                
                for(Opportunity thisRec : opportunityMap.values() ){
                    
                    system.debug('thisRec.Assets__r: '+thisRec.Assets__r);
                    if( thisRec.Assets__r != NULL && thisRec.getSobjects('Assets__r') != NULL && thisRec.getSobjects('Assets__r').size() > 0 ){
                        returnResult = 'Assets already created, either all assets or partially assets are created. Not valid process.';
                    } else{
                        validOpportunities.add(thisRec);
                    }
                }
                
                if(validOpportunities.size() > 0){
                    try{
                        OpportunityTriggerHelper.CreateOrder(validOpportunities);
                        
                        OpportunityConstants.AUTO_RENEW_RULE 			= FALSE;
                        RecursiveTriggerHandler.isFirstTimeOpportunity 	= FALSE;
                        update validOpportunities;
                        OpportunityConstants.AUTO_RENEW_RULE 			= TRUE;
                        RecursiveTriggerHandler.isFirstTimeOpportunity 	= TRUE;
                        
                        
                        returnResult = 'Assets created successfully.'; 
                    } catch(Exception ex){
                        system.debug('Errro while creating Asset: '+ex.getMessage());
                        returnResult = ex.getMessage();
                    }
                }
            } else{
                returnResult = 'No Records found with the given Opportunity. Check if the Opportunity is Multi Year, then Asset creation is not allowed.';
            }
            
        } else{
            returnResult = 'Bad value for Opportunity Id.';
        }
        
        return returnResult;
    }
    
    @AuraEnabled
    public static String createIntegrationProjectOnAssets( List<String> assetIds ){
        
        system.debug('assetIds: '+assetIds);
        String 	returnResult;
        
        if( assetIds != NULL && assetIds.size() > 0 ){
            Set<Id>	validAssetIds = new Set<Id>();
            
            for(
                Asset parentAsset : [ SELECT Id, Name, Product2Id, RecordTypeId, 
                                     Product2.Product_Category__c, Product2.ProductCode, Product2.Name, Product2.Family, Product2.Plan_Tier__c, 
                                     Product2.Product_Line__c, Product2.Is_Applicable_for_Licensing__c, Product2.Billing_Type__c, 
                                     ( SELECT Id, Name FROM Projects__r )
                                     FROM Asset WHERE Id IN :assetIds ] 
            ){
                
                Boolean			isIntegrationEligiable 	= FALSE;
                
                
                if(
                    ( parentAsset.RecordTypeId == System.Label.Asset_RecordType_Integration || parentAsset.RecordTypeId == AssetConstants.ASSET_INTEGRATIONID_RECORDTYPEID ) && 
                    !(  parentAsset.Product2.Product_Category__c == 'AMC' && parentAsset.Product2.Billing_Type__c != 'ARR' ) &&  
                    !System.Label.ExcludeProjectAutoCreation.containsIgnoreCase(parentAsset.Product2.ProductCode)
                ){
                    isIntegrationEligiable = TRUE;
                }
                
                if( 
                    parentAsset != NULL && 
                    parentAsset.getSobjects('Projects__r') != NULL 
                ){
                    isIntegrationEligiable = FALSE;
                    returnResult = 'Integration Project is already present, Project creation is not allowed.';
                }
                
                
                if(isIntegrationEligiable){
                    validAssetIds.add(parentAsset.Id);
                } else{
                    returnResult = 'Integration project is not eligible for this Asset';
                }
            }
            if( validAssetIds.size() > 0 ){
                try{
                    AssetTriggerHelper.autoCreateIntegrationProject( validAssetIds );
                    returnResult = 'Project created successfully.';
                } catch(Exception ex){
                    system.debug('Errro while creating Project: '+ex.getMessage());
                    returnResult = ex.getMessage();
                }
            } else{
                returnResult = 'No Valida Assets to Proceed with';
            }
            
            
        } else{
            returnResult = 'Invalid Asset Id: '+assetIds;
        }
        
        
        system.debug('returnResult: '+returnResult);
        return returnResult;
    }
    
    @AuraEnabled
    public static String createAMCProjectOnAssets( List<String> assetIds ){
        
        system.debug('assetIds: '+assetIds);
        String returnResult;
        
        if( assetIds != NULL && assetIds.size() > 0 ){
            Set<Id>			validAssetIds	= new Set<Id>();
            
            for( 
                Asset parentAsset : [ SELECT Id, Name, Product2Id, 
                                     Product2.Product_Category__c, Product2.ProductCode, Product2.Name, Product2.Family, Product2.Plan_Tier__c, 
                                     Product2.Product_Line__c, Product2.Is_Applicable_for_Licensing__c, Product2.Billing_Type__c, 
                                     ( SELECT Id, Name FROM Projects__r )
                                     FROM Asset WHERE Id IN :assetIds]
            ){
                
                Boolean	isAMCEligiable 	= FALSE;
                
                if( parentAsset.Product2.Product_Category__c == 'AMC' && parentAsset.Product2.Billing_Type__c != 'ARR' ){
                    isAMCEligiable = TRUE;
                }
                
                if( parentAsset.getSobjects('Projects__r') != NULL ){
                    isAMCEligiable = FALSE;
                    returnResult = 'AMC Project is already present, Project creation is not allowed.';
                }
                
                if(isAMCEligiable){
                    validAssetIds.add(parentAsset.Id);
                } else{
                    returnResult = 'AMC project is not eligible for this Asset';
                }
            }
            
            if( validAssetIds.size() > 0 ){
                try{
                    AssetTriggerHelper.autoCreateIntegrationProject( validAssetIds );
                    returnResult = 'Project created successfully.';
                } catch(Exception ex){
                    system.debug('Errro while creating Project: '+ex.getMessage());
                    returnResult = ex.getMessage();
                }
            } else{
                returnResult = 'No valid assets found';
            }
        } else{
            returnResult = 'Invalid Asset Id: '+assetIds;
        }
        
        
        system.debug('returnResult: '+returnResult);
        return returnResult;
    }
    
    @AuraEnabled
    public static void createUpsellOpportunities( List<String> upsellToupIds ){
        
        Map<Id, Upsell_Top_up__c> mapOfNewUpselltoUpdate = new Map<Id, Upsell_Top_up__c>(
            [ SELECT Id, Asset__c, Product__c, Account__c, OwnerId, Additional_Price__c, Approved_Date__c, No_of_GSTIN__c, No_of_GSTIN_verification_credits__c,
             No_of_PANs__c, No_of_user_IDs__c, No_of_B2B_Sales_invoice__c, No_of_B2C_Sales_invoice__c, No_of_purchase_invoice__c, No_of_vendors__c, 
             No_of_IRNs__c, No_of_E_way_bill__c FROM Upsell_Top_up__c WHERE Id IN :upsellToupIds ]
        );
        
        UpsellTriggerHelper.createOpportunity(mapOfNewUpselltoUpdate);
    }
    
    @AuraEnabled
    public static void createAdditionalGSTINsForAssets( List<Id> opportunityIds ){
        
        String 						Billing_GSTIN 	= Schema.SObjectType.Additional_GSTIN__c.getRecordTypeInfosByDeveloperName().get('Billing_GSTIN').getRecordTypeId();
        List<Additional_GSTIN__c> 	gstinsToCreate 	= new List<Additional_GSTIN__c>();
        
        for( 
            Asset assetInstance : [ SELECT Id, Price, Name, AccountId, Account.Name, Product2.Name, Opportunity__c,
                                   Opportunity__r.Billing_GST__c,
                                   Opportunity__r.PAN_No_as_per_PO__c,
                                   Opportunity__r.TAN__c,
                                   Opportunity__r.Legal_Entity_Name_Of_The_Client__c,
                                   Opportunity__r.If_SEZ__c,
                                   Opportunity__r.Billing_Address__c, Opportunity__r.Address_Line_2__c, Opportunity__r.city_2__c, Opportunity__r.state_2__c,
                                   Opportunity__r.pincode__c,
                                   Opportunity__r.CIN__c
                                   
                                   FROM Asset WHERE  
                                   Opportunity__c IN :opportunityIds ]
        ){
            
            Additional_GSTIN__c addGSTIN = new Additional_GSTIN__c();
            addGSTIN.RecordTypeId = Billing_GSTIN;
            addGSTIN.Name = assetInstance.Opportunity__r.Billing_GST__c;	
            addGSTIN.Billing_PAN__c = assetInstance.Opportunity__r.PAN_No_as_per_PO__c;
            addGSTIN.TAN__c = assetInstance.Opportunity__r.TAN__c;
            addGSTIN.Name_Of_The_Customer__c = assetInstance.Opportunity__r.Legal_Entity_Name_Of_The_Client__c;
            addGSTIN.SEZ_Yes_No__c = assetInstance.Opportunity__r.If_SEZ__c;
            addGSTIN.Amount__c = assetInstance.price;	
            addGSTIN.Asset__c = assetInstance.id;
            addGSTIN.Opportunity__c = assetInstance.Opportunity__c;
            addGSTIN.Address__c  = assetInstance.Opportunity__r.Billing_Address__c;	
            addGSTIN.Address_Line_2__c = assetInstance.Opportunity__r.Address_Line_2__c;	
            addGSTIN.city__c = assetInstance.Opportunity__r.city_2__c;	
            addGSTIN.state__c = assetInstance.Opportunity__r.state_2__c;	
            addGSTIN.pincode__c = assetInstance.Opportunity__r.pincode__c;	
            addGSTIN.CIN__c  = assetInstance.Opportunity__r.CIN__c;
            
            gstinsToCreate.add(addGSTIN);
        }
        
        if( gstinsToCreate.size() > 0 ){
            insert gstinsToCreate;
        }
    }
    
    @AuraEnabled
    public static void createBillingDetailsForAssets( List<Id> opportunityIds ){
        
        Map<id, Asset> 				assetMap 			= new Map<Id, Asset>([ SELECT Id, Price, Name, AccountId, Account.Name, Product2.Name 
                                                                              FROM Asset WHERE 
                                                                              Opportunity__c IN :opportunityIds ]);
        List<Billing_Details__c> 	billingRecordsList 	= new List<Billing_Details__c>();
        
        for( Id thisKey : assetMap.keySet() ){
            
            Billing_Details__c 		billingAndRiskRecord 	= new Billing_Details__c();
            billingAndRiskRecord.Asset__c 					= thisKey;
            billingAndRiskRecord.Account__c 				= assetMap.get(thisKey).AccountId;
            String billingRiskName 							= assetMap.get(thisKey).Account.Name + ' : ' + assetMap.get(thisKey).Product2.Name;
            billingAndRiskRecord.Name						= billingRiskName.length()<79 ? billingRiskName : billingRiskName.substring(0,79);
            billingAndRiskRecord.Price__c 					= assetMap.get(thisKey).Price;
            
            billingRecordsList.add(billingAndRiskRecord);
        }
        
        
        system.debug('billingRecordsList: '+billingRecordsList.size());
        if( billingRecordsList.size() > 0 ){
            insert billingRecordsList;
        }
    }
    
    @AuraEnabled
    public static void deleteAssetsOnFinanceRequest( List<Id> assetIds ){
        
        Map<Id, Asset> assetMap = new Map<Id, Asset>(
            [ SELECT Id, 
             ( SELECT Id FROM Billing_ID__r ), 
             ( SELECT Id FROM Billing_Details__r ) 
             FROM Asset WHERE Id IN :assetIds ] );
        
        List<Additional_GSTIN__c> 	billingGSTINIds 	= new List<Additional_GSTIN__c>();
        List<Billing_Details__c> 	billingDetailIds	= new List<Billing_Details__c>();
        Boolean						isChildRecordDeleted;
        
        for( Asset thisRec : assetMap.values() ){
            
            if( thisRec.getSobjects('Billing_ID__r') != NULL && thisRec.getSobjects('Billing_ID__r').size() > 0 ){
                billingGSTINIds.addAll( (List<Additional_GSTIN__c>)thisRec.getSobjects('Billing_ID__r') );
            }
            
            if( thisRec.getSobjects('Billing_Details__r') != NULL && thisRec.getSobjects('Billing_Details__r').size() > 0 ){
                billingDetailIds.addAll( (List<Billing_Details__c>)thisRec.getSobjects('Billing_Details__r') );
            }
            
        }
        
        if( billingGSTINIds.size() > 0 ){
            try{
                delete billingGSTINIds;
                isChildRecordDeleted = TRUE;
            } catch(Exception ex){
                system.debug( 'Billing GSTIN Delete Failure: '+ex.getMessage() );
                isChildRecordDeleted = FALSE;
            }
        }
        
        if( billingDetailIds.size() > 0 ){
            try{
                delete billingDetailIds;
                isChildRecordDeleted = TRUE;
            } catch(Exception ex){
                system.debug( 'Billing Details Delete Failure: '+ex.getMessage() );
                isChildRecordDeleted = FALSE;
            }
        }
        
        if(isChildRecordDeleted){
            delete assetMap.values();
        }
        
    }
    
    @AuraEnabled
    public static void gstinAPICallForBillingSTINDetailsPopulate( String documentId){
        CTX_GSTINAPICalloutManually.executeLogic(documentId);
    }
    
    @AuraEnabled
    public static void createContactUsingProductEmail( String documentId){
        CTX_CreateContactUsingProductEmail.executeOpportunityContactTagging(documentId);
    }
    
    
    @AuraEnabled
    public static String closeOpportunityManually( String opportunityId ){
        
        String 	returnString;
        Boolean isSuccess = FALSE;
        
        OpportunityConstants.AUTO_RENEW_RULE 			= FALSE;
        RecursiveTriggerHandler.isFirstTimeOpportunity 	= FALSE;
        
        try{
            Opportunity updateOpportunity = new Opportunity(
                Id 						= opportunityId, 
                CloseDate 				= system.today(),
                Is_Manually_Closed__c 	= TRUE
            );
            update updateOpportunity;
            returnString 	= 'Opportunity Closed Successfully.';
            isSuccess		= TRUE;
        } catch(Exception ex){
            returnString = 'Opportunity Update Failed: '+ex.getMessage();
        }
        
        OpportunityConstants.AUTO_RENEW_RULE 			= TRUE;
        RecursiveTriggerHandler.isFirstTimeOpportunity 	= TRUE;
        
        if(isSuccess){
            Id		defaultMailId 	= [ SELECT Id FROM OrgWideEmailAddress WHERE Address = :system.label.AR_Mail ]?.Id;
            String 	body 			= 'Hi Team,<br></br><br></br>';
            body 					+= 'Opportunity - '+opportunityId+' is closed manually.<br></br><br></br>';
            body 					+= 'This opportunity bypassed Asset + Order creation flow.</b><br></br><br></br>';
            body 					+= 'Please get in touch with Salesforce team for further help(Need asset creation script to be executed).<br></br><br></br>';
            body 					+= 'Best regards,<br></br>';
            body 					+= 'Team Salesforce';
            
            Messaging.SingleEmailMessage 	mail 		= new Messaging.SingleEmailMessage();
            List<String> 					toAddress	= new List<String>();
            
            toAddress.add('bibhuda.dash@clear.in');
            toAddress.add('mani.kant@clear.in');
            toAddress.add('vinayak.mesta@clear.in');
            toAddress.add('pooja.amilkanthwar@clear.in');
            toAddress.add('soumyokanti.chakraborty@clear.in');
            
            mail.setOrgWideEmailAddressId(defaultMailId);
            mail.setToAddresses(toAddress);
            mail.setSubject('Opportunity Closed Manually');
            mail.setBccSender(false);
            mail.setHtmlBody(body);
            
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail( new List<Messaging.SingleEmailMessage>{mail} );
                returnString 	= 'Opportunity Closed Successfully + Mail triggered to Admin Team.';
            } catch(Exception ex){
                returnString 	= 'Opportunity Closed Successfully + Please notify your Team Salesforce.';
            }
            
        }
        
        return returnString;
    }
    
    
}