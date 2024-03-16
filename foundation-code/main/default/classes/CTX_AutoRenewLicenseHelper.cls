Public  class CTX_AutoRenewLicenseHelper {
    
    
    Public Class AssetWrapper{ 
        Public Asset 									newAsset;
        Public Asset 									prevAsset;
        Public String 									response;
        Public List<QuoteLineItem>  					updateQli;
        Public Opportunity      						updateOpp;
        Public Opportunity								oppRec;
        Public String									planTier;
        Public Map<String, Product_Info_Metadata__mdt>	productPlanTierInfoMap;
    }
    
    Public Class PaymentWrapper{
        Public String 	previousLicense;
        Public String 	omsOrderId;
        Public String	invoice;
        Public String	paymentMode;
    }
    
    
    public static HttpResponse paymentUtility( PaymentWrapper paymentInformation, AssetWrapper astWrapper ){ 
        
        HttpResponse response = CTX_AutoRenewLicense.callout_AutoRenew_API(
            ( new Map<Id, Asset>{astWrapper.newAsset.Id=>astWrapper.newAsset} ), 
            ( new Map<Id, Asset>{astWrapper.prevAsset.Id=>astWrapper.prevAsset} ), 
            ( new Set<Id>{astWrapper.newAsset.ParentId} ),
            astWrapper.planTier,
            astWrapper.productPlanTierInfoMap,
            paymentInformation
        );   
        
        return response;
    }
    
    Public static AssetWrapper postPaymentActions( String licenseId, String planTier, PaymentWrapper paymentInformation ){
        
        system.debug('renewLicense Service licenseId: '+licenseId);
        system.debug('renewLicense Service planTier: '+planTier);
        
        Map<String, Product_Info_Metadata__mdt>	productPlanTierInfoMap	= new Map<String, Product_Info_Metadata__mdt>();
        
        if( planTier != NULL ){
            for( 
                Product_Info_Metadata__mdt thisRec : [ SELECT Id, MasterLabel, DeveloperName, 
                                                      Plan_Tier__c, Product_Id__c, Required_Fields__c 
                                                      FROM Product_Info_Metadata__mdt WHERE 
                                                      Plan_Tier__c =: planTier ] 
            ){
                productPlanTierInfoMap.put( thisRec.Plan_Tier__c, thisRec );
            }
        }
        
        String queryString = ' SELECT Id, Product2.Plan_Tier__c, Product2Id,Product2.Name,Product_Formula__c,UnitPrice,Sale_Price__c,Is_Formula_Price_Applicable__c,Quote.OpportunityId,Quote.Opportunity.Name,Quote.Opportunity.Billing_Address__c,Quote.Opportunity.Shipping_Address__c, Quote.Opportunity.State_2__c,Quote.Opportunity.Legal_Entity_Name_Of_The_Client__c,Quote.Opportunity.Billing_GST__c,Parent_Asset__r.License_ID__c,Quote.Opportunity.E_Sign_Customer_Info__r.Name, Quote.Opportunity.E_Sign_Customer_Info__c, Quote.Opportunity.E_Sign_Customer_Info__r.Email, Quote.Opportunity.E_Sign_Customer_Info__r.Phone,' + 'No_of_PAN_one__c,No_of_GSTIN_one__c,No_of_User_ID_one__c,No_of_IRNs__c,Number_of_eway_bill__c,No_of_expected_B2C_invoices_for_QR_code__c  FROM QuoteLineItem WHERE Parent_Asset__r.License_Id__c = :licenseId ';
        
        List<QuoteLineItem>	renewalQLIs	= Database.query(queryString); 
        System.debug('@renewalQLIs'+renewalQLIs);
        
        PaymentWrapper paymentInfo = paymentInformation;
        paymentInfo.invoice = NULL;
        
        QuoteLineItem		thisQli;
        
        if( renewalQLIs != NULL ){
            if( renewalQLIs.size() == 1 ){
                thisQli 						= renewalQLIs[0];
                renewalQLIs[0].Order_Details__c = JSON.serialize(paymentInfo);
                thisQli.Order_Details__c 		= JSON.serialize(paymentInfo);
            } else if( renewalQLIs.size() > 1 ){
                for( QuoteLineItem thisRec : renewalQLIs ){
                    if(thisRec.Product2.Plan_Tier__c == planTier ){
                        thisQli 		= thisRec;
                        thisRec.Order_Details__c = JSON.serialize(paymentInfo);
                        thisQli.Order_Details__c = JSON.serialize(paymentInfo);
                    } else{
                        thisRec.UnitPrice = 0;
                        thisRec.Sale_Price__c = 0;
                        //thisQli.Order_Details__c = JSON.serialize(paymentInfo);
                    }
                }
            }
        }
        
        Opportunity thisOpp	= renewalQLIs[0].Quote.Opportunity;
        thisOpp.stageName = 'Closed Won';

        QuoteConstants.ISFIRSTTIMEQLI 					= FALSE;
        OpportunityConstants.AUTO_RENEW_RULE 			= FALSE;
        RecursiveTriggerHandler.isFirstTimeOpportunity 	= FALSE;
        QuoteConstants.ISFIRSTTIMEQUOTE 				= FALSE;
        
        AssetWrapper	astWrapper			= new AssetWrapper();  
        List<Asset> 	thisAsset 			= [ SELECT Id, License_Id__c, Product2Id, Status, ParentId, Opportunity__r.Name FROM Asset WHERE Opportunity__c =: thisOpp.Id LIMIT 1];
        astWrapper.newAsset 				= thisAsset[0];
        astWrapper.planTier 				= planTier != NULL ? planTier : NULL;
        astWrapper.productPlanTierInfoMap 	= productPlanTierInfoMap;
        
        astWrapper.prevAsset 				= new Asset(Id=thisQli.Parent_Asset__c);
        astWrapper.updateQli 				= renewalQLIs;
        astWrapper.updateOpp 				= thisOpp;
        astWrapper.oppRec 					= new Opportunity(Id = thisOpp.Id, Name = astWrapper.newAsset.Opportunity__r.Name);
        
        QuoteConstants.ISFIRSTTIMEQLI 					= TRUE;
        OpportunityConstants.AUTO_RENEW_RULE 			= TRUE;
        QuoteConstants.ISFIRSTTIMEQUOTE 				= TRUE;
        
        return astWrapper;
    }
    
    /** Generate Invoice **/
    public static ContentDocumentLink generateInvoice(String content, Opportunity thisOpp) {
        
        ContentVersion newCv 			= new ContentVersion();
        newCv.Title 					= 'Invoice '+thisOpp.Name;
        newCv.PathOnClient 				= 'Invoice '+thisOpp.Name;
        newCv.VersionData 				= EncodingUtil.base64Decode(content);
        newCv.IsMajorVersion 			= true;
        newCv.System_Generated__c 		= TRUE;
        newCv.Type_of_document__c 		= 'Agreement';
        
        Insert newCv;
        
        ContentVersion cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:newCv.Id LIMIT 1];
        
        ContentDocumentLink invoiceDoc 	= new ContentDocumentLink();
        invoiceDoc.LinkedEntityId 		= thisOpp.Id;
        invoiceDoc.ContentDocumentId 	= cv.ContentDocumentId;
        invoiceDoc.shareType 			= 'V';
        
        Insert invoiceDoc;
        return invoiceDoc;
        
    }
    
    
    
    
    
}