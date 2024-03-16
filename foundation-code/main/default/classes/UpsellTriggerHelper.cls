public class UpsellTriggerHelper {
    
    Private Static String ORDER_FORM = 'Order Form Addendum';
    
    public static void submitForApproval(Map<Id,Upsell_Top_up__c> mapofUpsell){
        System.debug('FIN APPROVAL -->'+mapofUpsell);
        for(Id key:mapofUpsell.KeySet()){
            Approval.ProcessSubmitRequest appReq = new Approval.ProcessSubmitRequest();
            appReq.setComments('Submitting request for finance approval');
            appReq.setObjectId(key);       
            Approval.ProcessResult result = Approval.process(appReq);
        }
        
    }
    
    public static void updateUpsellStage(Map<Id,Upsell_Top_up__c> mapofUpsell){
        
        for(Upsell_Top_up__c upsellRec : mapofUpsell.values()){
            upsellRec.Stage__c = 'Closed';
            upsellRec.Sub_Stage__c = 'Closed Won';
        }
    }
    
    public static void updateAsset(Map<Id,Upsell_Top_up__c> mapofNewUpsell){
        
        Set<Id> 			astId 			= new Set<Id>();
        List<Asset> 		assetList 		= new list<Asset>();
        
        
        for(Id key : mapofNewUpsell.keySet()){
            astId.add(mapofNewUpsell.get(key).Asset__c);
        }
        
        Map<Id,Asset> astMap = new Map<Id,Asset>([SELECT Id,Price,License_no_of_gstins__c,License_no_of_gstin_verification_credits__c,
                                                  License_no_of_pans__c,License_no_of_userids__c,License_B2B_SalesInvoice_per_year__c,
                                                  License_B2C_SalesInvoice_per_year__c,Number_of_Purchase_Invoice__c,No_of_Vendor__c,
                                                  License_no_of_irns_per_year__c,Number_of_eway_bill__c,No_of_Bank_verification_API__c,
                                                  No_of_MCA_Company_details_API__c,No_of_MSME_API__c,No_of_PAN_to_GSTIN_APIs__c,
                                                  No_of_PAN_verification_API__c,No_of_TDS_206_sync_API__c,No_of_PAN_verification_detailed_APIs__c,
                                                  No_of_PAN_verification_API_old__c,No_of_PAN_Verification_with_Father_Name__c, Number_of_TANs__c 
                                                  FROM Asset 
                                                  WHERE Id IN :astId]);
        
        
        System.debug('astMap-->'+astMap);
        if(mapofNewUpsell.Size() > 0){
            for(Upsell_Top_up__c upsellRec : mapofNewUpsell.values()){
                if(astMap != NULL && astMap.size()>0 && astMap.containsKey(upsellRec.Asset__c) && upsellRec != NULL){
                    System.debug('upsellRec-->'+upsellRec);
                    Asset astRec = astMap.get(upsellRec.Asset__c);
                    
                    astRec.Original_Price__c = astRec.Price; 
                    astRec.Price += upsellRec.Additional_Price__c;
                    
                    if(upsellRec.No_of_GSTIN__c != NULL){
                        if(astRec.License_no_of_gstins__c != NULL ){
                            astRec.License_no_of_gstins__c += upsellRec.No_of_GSTIN__c;
                        }else astRec.License_no_of_gstins__c = upsellRec.No_of_GSTIN__c;
                    }
                    
                    
                    if(upsellRec.No_of_GSTIN_verification_credits__c != NULL){
                        if(astRec.License_no_of_gstin_verification_credits__c != NULL){
                            astRec.License_no_of_gstin_verification_credits__c += upsellRec.No_of_GSTIN_verification_credits__c;
                        }else astRec.License_no_of_gstin_verification_credits__c = upsellRec.No_of_GSTIN_verification_credits__c;
                    }
                    
                    
                    if(upsellRec.No_of_PANs__c != NULL){
                        if(astRec.License_no_of_pans__c != NULL){
                            astRec.License_no_of_pans__c += upsellRec.No_of_PANs__c;
                        }else astRec.License_no_of_pans__c = upsellRec.No_of_PANs__c; 
                    }
                    
                    if(upsellRec.No_of_user_IDs__c != NULL){
                        if(astRec.License_no_of_userids__c != NULL){
                            astRec.License_no_of_userids__c += upsellRec.No_of_user_IDs__c;
                        }else astRec.License_no_of_userids__c = upsellRec.No_of_user_IDs__c;
                    }
                    
                    if(upsellRec.No_of_B2B_Sales_invoice__c != NULL){
                        if(astRec.License_B2B_SalesInvoice_per_year__c != NULL){
                            astRec.License_B2B_SalesInvoice_per_year__c += upsellRec.No_of_B2B_Sales_invoice__c;
                        }else astRec.License_B2B_SalesInvoice_per_year__c = upsellRec.No_of_B2B_Sales_invoice__c;  
                    }
                    
                    
                    if(upsellRec.No_of_B2C_Sales_invoice__c != NULL){
                        if(astRec.License_B2C_SalesInvoice_per_year__c != NULL){
                            astRec.License_B2C_SalesInvoice_per_year__c += upsellRec.No_of_B2C_Sales_invoice__c;
                        }else astRec.License_B2C_SalesInvoice_per_year__c = upsellRec.No_of_B2C_Sales_invoice__c; 
                    }
                    
                    if(upsellRec.No_of_purchase_invoice__c != NULL){
                        if(astRec.Number_of_Purchase_Invoice__c != NULL){
                            astRec.Number_of_Purchase_Invoice__c += upsellRec.No_of_purchase_invoice__c;
                        }else astRec.Number_of_Purchase_Invoice__c = upsellRec.No_of_purchase_invoice__c;  
                    }
                    
                    if(upsellRec.No_of_vendors__c != NULL){
                        if(astRec.No_of_Vendor__c != NULL){
                            astRec.No_of_Vendor__c += upsellRec.No_of_vendors__c;
                        }else astRec.No_of_Vendor__c = upsellRec.No_of_vendors__c; 
                    }
                    
                    
                    if(upsellRec.No_of_IRNs__c != NULL){
                        if(astRec.License_no_of_irns_per_year__c != NULL){
                            astRec.License_no_of_irns_per_year__c += upsellRec.No_of_IRNs__c;
                        }else astRec.License_no_of_irns_per_year__c = upsellRec.No_of_IRNs__c;
                    }
                    
                    if(upsellRec.No_of_E_way_bill__c != NULL){
                        if(astRec.Number_of_eway_bill__c != NULL){
                            astRec.Number_of_eway_bill__c += upsellRec.No_of_E_way_bill__c;
                        }else astRec.Number_of_eway_bill__c = upsellRec.No_of_E_way_bill__c;
                    }
                    
                    
                    if(upsellRec.No_of_Bank_verification_API__c != NULL){
                        
                        if(astRec.No_of_Bank_verification_API__c  != NULL){
                            astRec.No_of_Bank_verification_API__c  += upsellRec.No_of_Bank_verification_API__c ;
                        }else astRec.No_of_Bank_verification_API__c  = upsellRec.No_of_Bank_verification_API__c ;
                    }
                    
                    
                    if(upsellRec.No_of_MCA_Company_details_API__c != NULL){
                        if(astRec.No_of_MCA_Company_details_API__c  != NULL){
                            astRec.No_of_MCA_Company_details_API__c  += upsellRec.No_of_MCA_Company_details_API__c ;
                        }else astRec.No_of_MCA_Company_details_API__c  = upsellRec.No_of_MCA_Company_details_API__c ;
                        
                    }
                    
                    if(upsellRec.No_of_MSME_API__c != NULL){
                        if(astRec.No_of_MSME_API__c  != NULL){
                            astRec.No_of_MSME_API__c  += upsellRec.No_of_MSME_API__c ;
                        }else astRec.No_of_MSME_API__c  = upsellRec.No_of_MSME_API__c ;
                    }
                    
                    
                    if(upsellRec.No_of_PAN_to_GSTIN_APIs__c != NULL){
                        if(astRec.No_of_PAN_to_GSTIN_APIs__c  != NULL){
                            astRec.No_of_PAN_to_GSTIN_APIs__c  += upsellRec.No_of_PAN_to_GSTIN_APIs__c ;
                        }else astRec.No_of_PAN_to_GSTIN_APIs__c  = upsellRec.No_of_PAN_to_GSTIN_APIs__c ;
                    }
                    
                    if(upsellRec.No_of_PAN_verification_API__c != NULL){
                        if(astRec.No_of_PAN_verification_API__c  != NULL){
                            astRec.No_of_PAN_verification_API__c  += upsellRec.No_of_PAN_verification_API__c ;
                        }else astRec.No_of_PAN_verification_API__c  = upsellRec.No_of_PAN_verification_API__c ; 
                    }
                    
                    if(upsellRec.No_of_TDS_206_sync_API__c != NULL){
                        if(astRec.No_of_TDS_206_sync_API__c  != NULL){
                            astRec.No_of_TDS_206_sync_API__c  += upsellRec.No_of_TDS_206_sync_API__c ;
                        }else astRec.No_of_TDS_206_sync_API__c  = upsellRec.No_of_TDS_206_sync_API__c ;
                        
                    }
                    
                    if(upsellRec.No_of_PAN_verification_detailed_APIs__c != NULL){
                        if(astRec.No_of_PAN_verification_detailed_APIs__c  != NULL){
                            astRec.No_of_PAN_verification_detailed_APIs__c  += upsellRec.No_of_PAN_verification_detailed_APIs__c ;
                        }else astRec.No_of_PAN_verification_detailed_APIs__c  = upsellRec.No_of_PAN_verification_detailed_APIs__c ;
                    }
                    
                    
                    if(upsellRec.No_of_PAN_verification_API_old__c  != NULL){
                        if(astRec.No_of_PAN_verification_API_old__c   != NULL){
                            astRec.No_of_PAN_verification_API_old__c   += upsellRec.No_of_PAN_verification_API_old__c  ;
                        }else astRec.No_of_PAN_verification_API_old__c   = upsellRec.No_of_PAN_verification_API_old__c  ;
                    }
                    
                    if( upsellRec.No_of_PAN_Verification_with_Father_Name__c  != NULL){
                        if(astRec.No_of_PAN_Verification_with_Father_Name__c   != NULL){
                            astRec.No_of_PAN_Verification_with_Father_Name__c   += upsellRec.No_of_PAN_Verification_with_Father_Name__c  ;
                        }else astRec.No_of_PAN_Verification_with_Father_Name__c   = upsellRec.No_of_PAN_Verification_with_Father_Name__c  ;
                        
                    }
                    
                    if( upsellRec.Number_of_TANs__c  != NULL){
                        if(astRec.Number_of_TANs__c   != NULL){
                            astRec.Number_of_TANs__c   += upsellRec.Number_of_TANs__c  ;
                        }else astRec.Number_of_TANs__c   = upsellRec.Number_of_TANs__c  ;
                        
                    }
                    
                     
                    
                    assetList.add(astRec);    
                    
                }
            }    
        }
        try{  
            if(!assetList.isEmpty()){
                database.update(assetList);
            }
        }Catch(Exception ex){
            System.debug(' Exception on Asset Update \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
    }
    
    public static void createOpportunity(Map<Id,Upsell_Top_up__c> mapofNewUpsell){
        String opportunity_Upsell_RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(UpsellConstants.RECORDTYPE_UPSELL).getRecordTypeId();
        Set<Id> assetId = new Set<Id>();
        Map<String, Upsell_Top_up__c> upsellOppMap = new Map<String, Upsell_Top_up__c>();
        Map<Id, Id> upsellAssetMap = new Map<Id, Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Date dt = Date.today();
        Set<Id> productIds = new Set<Id>();
        List<Upsell_Top_up__c> upsellList = new List<Upsell_Top_up__c>();
        
        for(Id key : mapofNewUpsell.keySet()){
            assetId.add(mapofNewUpsell.get(key).Asset__c);
            productIds.add(mapofNewUpsell.get(key).Product__c);
        }
        
        Map<Id,Asset> astMap = new Map<Id,Asset>([SELECT Id,Opportunity_ID__c,UsageEndDate, Product2.Name, Opportunity__r.Id,
                                                  Opportunity__r.Name,Opportunity__r.AccountId,Opportunity__r.CloseDate,
                                                  Opportunity__r.ClearTax_Billing_Entity__c
                                                  FROM Asset where Id IN :assetId]);
        
        
        if(mapofNewUpsell.Size() > 0){
            for(Upsell_Top_up__c upsellRec : mapofNewUpsell.values()){
                if(upsellRec != NULL){
                    Opportunity oppRec		 					= new Opportunity();
                    oppRec.RecordTypeId 						= opportunity_Upsell_RecordTypeId;
                    Asset astRec 								= astmap.get(upsellRec.Asset__c);
                    oppRec.Name 								= astmap.get(upsellRec.Asset__c).Opportunity__r.Name;//oppMap.get(astRec.Opportunity_ID__c).Name;
                    oppRec.AccountId 							= upsellRec.Account__c;
                    oppRec.OwnerId								= upsellRec.OwnerId;
                    oppRec.Upsell_Amount__c 					= upsellRec.Additional_Price__c;
                    oppRec.StageName 							= 'Closed Won';
                    oppRec.Period_Start_date__c 				= upsellRec.Approved_Date__c ;
                    oppRec.Period_End_date__c 					= astMap.get(upsellRec.Asset__c).UsageEndDate;
                    oppRec.CloseDate 							= upsellRec.Approved_Date__c;
                    oppRec.No_of_GSTIN__c 						= upsellRec.No_of_GSTIN__c;
                    oppRec.No_of_GSTIN_verification_credits__c 	= upsellRec.No_of_GSTIN_verification_credits__c;
                    oppRec.No_of_PANs__c 						= upsellRec.No_of_PANs__c;
                    oppRec.No_of_user_IDs__c 					= upsellRec.No_of_user_IDs__c;
                    oppRec.No_of_B2B_Sales_invoice__c 			= upsellRec.No_of_B2B_Sales_invoice__c;
                    oppRec.No_of_B2C_Sales_invoice__c 			= upsellRec.No_of_B2C_Sales_invoice__c;
                    oppRec.No_of_purchase_invoice__c 			= upsellRec.No_of_purchase_invoice__c;
                    oppRec.No_of_vendors__c 					= upsellRec.No_of_vendors__c;
                    oppRec.No_of_IRNs__c 						= upsellRec.No_of_IRNs__c;
                    oppRec.No_of_E_way_bill__c 					= upsellRec.No_of_E_way_bill__c;
                    oppRec.ClearTax_Billing_Entity__c			= astmap.get(upsellRec.Asset__c).Opportunity__r.ClearTax_Billing_Entity__c;
                    oppList.add(oppRec);    
                    upsellOppMap.put(astmap.get(upsellRec.Asset__c).Opportunity__r.Name,upsellRec);
                    upsellAssetMap.put(upsellRec.Id,astRec.Id);
                }
                
                
            }    
        }
        
        try{ 
            if(!oppList.isEmpty()){
                insert oppList;
            }        
            
        }catch(Exception ex){
            System.debug(' Exception on Opportunity Insert \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
        
        Map<Id, Id> priceBookEntryMap = new Map<Id, Id>();
        for(PricebookEntry thisRec : [Select Id, Product2Id  FROM PricebookEntry where Product2Id IN :productIds]){
            priceBookEntryMap.put(thisRec.Product2Id, thisRec.Id);
        }
        
        for(Opportunity opp : oppList){
            Id upsellId = upsellOppMap.get(opp.Name).Id;
            String prodName = astMap.get(upsellAssetMap.get(upsellId)).Product2.Name;
            
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opp.Id;
            oli.Product2Id = astMap.get(upsellAssetMap.get(upsellId)).Product2Id;
            oli.PricebookEntryId = priceBookEntryMap.get(oli.Product2Id );
            oli.Quantity = 1;
            oli.Sale_Price__c = upsellOppMap.get(opp.Name).Additional_Price__c;
            oli.TotalPrice = upsellOppMap.get(opp.Name).Additional_Price__c;
            oliList.add(oli);
            
            Upsell_Top_up__c ups = new Upsell_Top_up__c(Id = upsellId);
            ups.Upsell_Opportunity__c = opp.Id;
            upsellList.add(ups);
        }
        
        try{ 
            if(!oliList.isEmpty()){
                Insert oliList;
            } 
            
            if(!upsellList.isEmpty()){
                update upsellList;
            } 
        }catch(Exception ex){
            System.debug(' Exception on oliList/upsellList  \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
        
    } 
    
    public static void checkUpsell(Map<Id,Upsell_Top_up__c> mapofNewUpsell){
        
        Set<Id> 			assetId		 = new Set<Id>();
        
        for(Upsell_Top_up__c upsellRec : mapofNewUpsell.values()){
            assetId.add(upsellRec.Asset__c);
        }
        Map<Id,Asset> astMap = new Map<Id,Asset>([Select Id,Upsell__c 
                                                  FROM Asset 
                                                  WHERE Id IN :assetId]);
        
        List<Asset> astList = new List<Asset>();
        try{
            for(Asset ast : astMap.Values()){
                if(ast.Upsell__c == FALSE){
                    ast.Upsell__c = TRUE;     
                    astList.add(ast); 
                } 
            }
            System.debug('astList-->'+astList);
            if(!astList.isEmpty()){
                update astList;
            }
            
        }Catch(Exception ex){
            System.debug(' Exception on checkUpsell \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
        
    }
    
    public static void checkUpsellOnDelete(Map<Id,Upsell_Top_up__c> mapofOldUpsell){
        
        Set<Id> 			assetId 	= new Set<Id>();
        List<Asset> 		astList 	= new List<Asset>();
        
        for(Upsell_Top_up__c upsellRec : mapofOldUpsell.values()){
            assetId.add(upsellRec.Asset__c);
        }
        
        Map<Id,Asset> astMap = new Map<Id,Asset>([Select Id,Upsell__c 
                                                  FROM Asset 
                                                  WHERE Id IN :assetId]);
        
        
        try{
            for(Asset ast : astMap.Values()){
                if(ast.Upsell_Top_ups__r.size()<1){
                    ast.Upsell__c = false;
                    astList.add(ast);
                }  
            }
            System.debug('astList-->'+astList);
            if(!astList.isEmpty()){
                update astList;
            }
            
        }Catch(Exception ex){
            System.debug(' Exception on checkUpsell \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
        
        
    }
    public static void updateAdditionalGstinAddOnSplit(Map<Id,Upsell_Top_up__c> mapofNewUpsell){
        
        Map<Id,Decimal> assetIdAddnPriceMap = new Map<Id,Decimal>();
        Map<Id,Decimal> assetIdAssetPriceMap = new Map<Id,Decimal>();
        List<Additional_GSTIN__c> billingGstnList = new List<Additional_GSTIN__c>();
        Map<Id,List<Additional_GSTIN__c>> assetGstinsMap = new  Map<Id,List<Additional_GSTIN__c>>();
        for(Upsell_Top_up__c upsellRec : mapofNewUpsell.values()){
            assetIdAddnPriceMap.put(upsellRec.Asset__c, upsellRec.Additional_Price__c);
        }
        
        for(Asset thisAsset : [SELECT Id, Price 
                               FROM Asset
                               WHERE Id IN :assetIdAddnPriceMap.keySet()] )
        {
            assetIdAssetPriceMap.put(thisAsset.Id, thisAsset.Price);
        }
        
        for(Additional_GSTIN__c thisRec : [SELECT Id, Name, Amount__c, Add_on_split__c, Asset__c
                                           FROM Additional_GSTIN__c 
                                           WHERE Asset__c IN :assetIdAddnPriceMap.keySet() ])
        {
            if(assetGstinsMap.containsKey(thisRec.Asset__c)){
                assetGstinsMap.get(thisRec.Asset__c).add(thisRec);
            }else{
                assetGstinsMap.put(thisRec.Asset__c, new List<Additional_GSTIN__c> {thisRec});
            }
        }
        
        if(assetGstinsMap.size()>0){
            for(Id assetId : assetIdAddnPriceMap.keySet()){
                for(Additional_GSTIN__c thiRec : assetGstinsMap.get(assetId)){
                    Decimal splitPerc = (thiRec.Amount__c/assetIdAssetPriceMap.get(thiRec.Asset__c))*100;
                    thiRec.Add_on_split__c = (assetIdAddnPriceMap.get(thiRec.Asset__c)*splitPerc)/100;
                    billingGstnList.add(thiRec);  
                }  
            }   
        }
        
        try{
            if(!billingGstnList.isEmpty()){
                update billingGstnList;
            }  
        }Catch(Exception ex){
            System.debug(' Exception on Additional_GSTIN__c Update \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
    }
    
    public static void updateAdditionalGstinAmount(Map<Id,Upsell_Top_up__c> mapofNewUpsell){
        
        Set<Id> assetID = new Set<Id>();
        List<Additional_GSTIN__c> billingGstnList = new List<Additional_GSTIN__c>();
        List<Additional_GSTIN__c> newbillingGstnList = new List<Additional_GSTIN__c>();
        for(Upsell_Top_up__c upsellRec : mapofNewUpsell.values()){
            assetID.add(upsellRec.Asset__c);
        }
        
        Map<Id,Additional_GSTIN__c> billingGstnMap = new Map<Id,Additional_GSTIN__c>([SELECT Id, Name, Amount__c, Add_on_split__c, Asset__c, 
                                                                                      Address__c, Name_Of_The_Customer__c,OTP_Integration__c, 
                                                                                      Quote_Line_Item__c, Quote__c, Address_Line_2__c,State__c,
                                                                                      Billing_PAN__c, TAN__c, SEZ_Yes_No__c, City__c, Pincode__c,
                                                                                      Upsell_Top_up__c, Upsell_Top_up__r.Asset__c
                                                                                      FROM Additional_GSTIN__c 
                                                                                      WHERE Upsell_Top_up__c IN :mapofNewUpsell.keySet()]);
        
        if(billingGstnMap.size()>0){
            for(Additional_GSTIN__c thiRec : billingGstnMap.values()){      
                if(thiRec.Add_on_split__c != NULL && thiRec.Add_on_split__c != 0){
                    //Additional_GSTIN__c addnGstinClone  = thiRec.clone(false,true,false,false);
                    thiRec.Asset__c = thiRec.Upsell_Top_up__r.Asset__c;
                    thiRec.Amount__c = thiRec.Add_on_split__c;
                    thiRec.Add_on_split__c = 0;    
                }
                billingGstnList.add(thiRec); 
            }    
        }
        
        try{  
            if(!billingGstnList.isEmpty()){
                update billingGstnList;
            }  
            
        }Catch(Exception ex){
            System.debug(' Exception on Additional_GSTIN__c Update \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
    }
    
    public static void validateAdditionalGstins(Map<Id,Upsell_Top_up__c> mapofUpsell){
        
        Set<Id> upsellIDSet = new Set<Id>();
        List<Additional_GSTIN__c> billingGstnList = new List<Additional_GSTIN__c>();
        
        
        for(Additional_GSTIN__c thisRec : [SELECT Id, Name, Amount__c, Add_on_split__c, Asset__c,Upsell_Top_up__c
                                           FROM Additional_GSTIN__c 
                                           WHERE Upsell_Top_up__c IN :mapofUpsell.keySet()])
        {
            upsellIDSet.add(thisRec.Upsell_Top_up__c);
            
        }
        
        for(Upsell_Top_up__c upsellRec : mapofUpsell.values()){
            if(!upsellIDSet.contains(upsellRec.Id)){
                upsellRec.addError('Please add a GSTIN');
            }
        }
    }
    
    public static void updateRevenueFromUpsell(Map<Id,Upsell_Top_up__c> mapofUpsell){
        Set<Id> assetIds = new Set<Id>();
        Map<Id, Decimal> revenueFromUpsell = new Map<Id, Decimal>();
        List<Asset> assetList = new List<Asset>();
        
        for(Upsell_Top_up__c thisRec: mapofUpsell.values() ){
            assetIds.add(thisRec.Asset__c);
        }
        
        For(AggregateResult res : [SELECT SUM(Additional_Price__c ), Asset__c
                                   FROM Upsell_Top_up__c GROUP BY Asset__c
                                   HAVING Asset__c IN :assetIds])
        {
            revenueFromUpsell.put((Id)res.get('Asset__c'), (Decimal)res.get('expr0'));
            
        }
        
        for(Id assetId : assetIds)  {
            if(revenueFromUpsell.containsKey(assetId)){
                Asset newAsset = new Asset(Id = assetId);
                newAsset.Revenue_from_Upsell__c = revenueFromUpsell.get(assetId);
                assetList.add(newAsset);
            }
        }      
        
        if(!assetList.isEmpty()){
            Update assetList;
        }
        
    }
    
    public static void cloneCvs(Map<Id,Upsell_Top_up__c> mapofUpsell){
        Set<Id> CDId = new Set<Id>();
        Map<Id, ContentDocumentLink> 	upsellCDLinkMap 							= new Map<Id, ContentDocumentLink>();
        Map<Id, ContentVersion> 		CDCVMapSystemGenerated 					    = new Map<Id, ContentVersion>();
        List<ContentVersion> clonedCv = new List<ContentVersion>();
        List<Upsell_Top_up__c> upsellRecordList = [ SELECT Id, Name,
                                                   
                                                   ( SELECT Id, LinkedEntityId, ContentDocumentId, SystemModstamp 
                                                    FROM ContentDocumentLinks  ORDER BY SystemModstamp DESC LIMIT 1 )
                                                   
                                                   FROM Upsell_Top_up__c WHERE 
                                                   Id IN :  mapofUpsell.keySet()
                                                  ];
        
        for(Upsell_Top_up__c thisRec: upsellRecordList ){
            If(thisRec.ContentDocumentLinks.size() > 0){
                upsellCDLinkMap.put(thisRec.Id,thisRec.ContentDocumentLinks[0]);
                CDId.add(thisRec.ContentDocumentLinks[0].ContentDocumentId);
            }
        }
        List<ContentVersion> CVList = [SELECT Id, ContentDocumentId,  ContentUrl,PathOnClient,  VersionNumber, Title, Description, 
                                       
                                       OwnerId, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, SystemModstamp, TagCsv, System_Generated__c,
                                       FileType, PublishStatus, VersionData, ContentSize, FileExtension, Origin, 
                                       NetworkId, ContentLocation, TextPreview, ExternalDocumentInfo1, ExternalDocumentInfo2, ExternalDataSourceId, 
                                       Parent_RecordId__c, Type_of_document__c, Lock_Content_Version__c
                                       FROM ContentVersion WHERE   (ContentDocumentId IN : CDId) AND (Type_of_document__c = 'Order Form Addendum') AND System_Generated__c = TRUE
                                       ORDER BY SystemModstamp DESC
                                      ];
        
        for(ContentVersion CVIns:CVList){
            ContentVersion cvClone = CVIns.Clone();
            cvClone.versionData= CVIns.VersionData;
            cvClone.ContentBodyId = null;
            If(!cvClone.Title.Contains('ResentFileV')){
                cvClone.Title = cvClone.Title + 'ResentFileV0';
            }
            else{
                Integer currentVer = Integer.ValueOf(cvClone.Title.substringAfterLast('V'))+1;
                cvClone.Title = cvClone.Title.replace(cvClone.Title.substringAfterLast('V'),String.valueOf(currentVer));  
            }
            clonedCv.add(cvClone);
            
        }
        System.debug('@clonedCv'+clonedCv);
        if(!clonedCv.isEmpty()){
            Insert clonedCv;
        }
        
    }
    
    
    public static void checkForOrderForm(List<Upsell_Top_up__c> listOfUpsell, Boolean isApprovedPhySignUps){
        Map<Id,Upsell_Top_up__c> mapOfOpp = new Map<Id,Upsell_Top_up__c>(listOfUpsell);
        Map<String, E_Sign_Config__c> eSignConfig = E_Sign_Config__c.getAll();
        Set<String> setOfContentDocIds = new Set<String>();
        Map<Id,List<Id>> upselIdWithContentDocId = new Map<Id,List<Id>>();
        Map<Id,ContentVersion> versionWithType = new Map<Id,ContentVersion>();
        Map<String,String> mapOfContentDocIdToObjId = new Map<String,String>();
        Map<String,List<ContentVersion>> mapOfUpsellIdToListOfCV = new Map<String,List<ContentVersion>>();
        
        List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: mapOfOpp.keySet() ];
        System.debug('** contentDocList '+contentDocList);
        for(ContentDocumentLink cdl : contentDocList){
            mapOfContentDocIdToObjId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            
        }
        System.debug('** mapOfContentDocIdToObjId '+mapOfContentDocIdToObjId);
        System.debug('** mapOfContentDocIdToObjId.keySet() '+mapOfContentDocIdToObjId.keySet());
        List<ContentVersion> contentverList = [SELECT Id, Title, FileType, Type_of_document__c, ContentDocumentId, VersionData, System_Generated__c 
                                               FROM ContentVersion WHERE ContentDocumentId IN: mapOfContentDocIdToObjId.keySet() //AND IsLatest = true
                                               AND Type_of_document__c =:eSignConfig.get('Type_Of_Doc_Addendum').Value__c]; //
        System.debug('** contentverList Size '+contentverList.size());
        for(ContentVersion tempVersion : contentverList){
            System.debug('** tempVersion.ContentDocumentId '+tempVersion.ContentDocumentId);
            String opptyId = mapOfContentDocIdToObjId.get(tempVersion.ContentDocumentId);
            System.debug('** opptyId '+opptyId);
            if(mapOfUpsellIdToListOfCV.containsKey(opptyId)){
                mapOfUpsellIdToListOfCV.get(opptyId).add(tempVersion);
            }else{
                mapOfUpsellIdToListOfCV.put(opptyId, new List<ContentVersion>{tempVersion});
            }
        }
        System.debug('** mapOfUpsellIdToListOfCV '+mapOfUpsellIdToListOfCV);
        if(isApprovedPhySignUps == true){
            for(Upsell_Top_up__c ups : listOfUpsell){
                Boolean isExist = false;
                for(ContentVersion cv : mapOfUpsellIdToListOfCV.get(ups.Id)){
                    if(ups.ESign_Category__c == 'Physical Sign' && cv.System_Generated__c == false){ 
                        isExist = true;
                        break;
                    }
                }
                if(!isExist){
                    ups.addError('Please Upload the OrderForm and update the Type of Document to Order Form Addendum to submit it for Physical Sign');
                }
            }
        }else{
            for(Upsell_Top_up__c ups : listOfUpsell){
                Boolean isExist = false;
                if(mapOfUpsellIdToListOfCV.containsKey(ups.Id)){
                    for(ContentVersion cv : mapOfUpsellIdToListOfCV.get(ups.Id)){
                        if(ups.ESign_Category__c == 'E-Sign' && cv.System_Generated__c == true){ 
                            isExist = true;
                            break;
                        }else if(ups.ESign_Category__c == 'Physical Sign'){
                            isExist = true;
                            break;
                        }
                    }
                    if(!isExist){
                        if(ups.ESign_Category__c == 'E-Sign'){
                            ups.addError('Please Generate the '+eSignConfig.get('Type_Of_Doc_Addendum').Value__c+' for ESign before submitting for Approval');
                        }
                    }
                }else{
                    ups.addError('Please Generate '+eSignConfig.get('Type_Of_Doc_Addendum').Value__c+' before submitting for Approval');
                }
            }
        }
        
    }
}