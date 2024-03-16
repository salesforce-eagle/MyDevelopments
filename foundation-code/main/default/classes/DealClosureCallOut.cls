public class DealClosureCallOut {
    
    Public class OpportunityWrapper{
        public string 					oppId;
        public string 					name;
        public AccountWrapper 			accounts;
        public list<AssetWrapper> 		assets;
        public string 					billingFreqForServiceFeeOTP;
        public string 					billingFreqForSubscriptionFee;
        public string 					billingMethod;
        public boolean 					isInsert;
    }
    
    Public class AccountWrapper{
        public string 					masterEmailID;
        public string 					accountId;
        public string 					orgUnitId;
        public String					workspaceId;
        public string					name;
        public List<WorkspaceWrapper> 	workspaces;
    }
    
    Public Class WorkspaceWrapper{
        public string 					workspaceId;
        public string 					workspaceOrgUnitId;
    }
    
    Public class AssetWrapper{
        public string 					assetId;
        public string 					oppId;
        public string 					Name;
        public string 					productName;
        public string 					billingType;
        public decimal 					quantity;
        public decimal 					price;
        public string 					accPAN;
        public string 					accId;
        public string 					status;
        public date 					assetStartDate;
        public date 					assetEndDate;
        public string 					paymentTerm;
        public string 					paymentMethod;
        public string 					licenseId;
        public decimal 					noOfGSTINs;
        public decimal 					noOfPANs;
        public decimal 					noOfUserIds;
        public decimal 					noOfVendor;
        public string 					ERP;
        public decimal 					noOfAirlineInvoices;
        public decimal 					noOfB2CSalesInvoice;
        public decimal 					noOfB2BSalesInvoice;
        public decimal 					noOfPurchaseInvoice;
        public decimal 					noOfEwayBill; 
        public string 					typeOfIntegration; 
        /**	Lately added by Bibhu : 06-01-2022	**/
        public decimal 					License_no_of_total_Sales_Invoices;
        public decimal 					License_no_of_irns_per_year;
        public decimal 					License_no_of_invoice_formats;
        public decimal 					License_no_of_gstin_verification_credits;
        public decimal 					No_of_airline_invoices;
        public decimal 					License_No_of_MM2A_2B_usage_GSTIN_mon;
        public decimal 					License_no_of_Recon;
        public decimal 					No_of_expected_B2C_invoices_for_QR_code;
        public ProductWrapper 			product;
        public string					planId;
    }
    
    Public class ProductWrapper{
        public string 					productCode;
        public string 					productFamily;
    }
    
    
    Public class MasterAccountWrapper{
        public string 					oldMasterAdminEmail;
        public string 					newMasterAdminEmail;
        public string 					sfAccountId;
        public string					orgUnitId;
        public boolean					transferRoleToChild;
    }
    
    Public class ResponseWrapper{
        
        public String 					oppId;	//0061s0000060F20AAE
        public cls_assetPersistenceResponses[] assetPersistenceResponses;
    }
    
    class cls_assetPersistenceResponses {
        public String 					assetId;	//02i1s000002dT4jAAE
        public String 					messageId;	//fbad5c55-e0e1-445b-a2cf-2ccfb2e45aeb
    }
    
    
    public static void Callout(String OppId, String assetId, Boolean isOpportunityAvailable, Boolean isInsert){
        
        String 						jsonRequestBody				= '';
        List<OpportunityWrapper> 	listOppWrapper				= new List<OpportunityWrapper>();
        List<WorkspaceWrapper>		workspaceList				= new List<WorkspaceWrapper>();
        Map<Id,List<AssetWrapper>> 	mapOfOppIdToAssetWrapper	= new Map<Id,List<AssetWrapper>>();
        List<AssetWrapper>			assetWrapperList			= new List<AssetWrapper>();
        list<Opportunity> 			listOfOpp;					
        list<Asset> 				listOfAsset;
        Id							accountId;
        List<Workspace__c> 			worksopaceDetails;
        AccountWrapper 				accw;
        String						incomingWorkspaceId;
        String						incomingMasterEmailId;
        
        
        system.debug('isOpportunityAvailable: '+isOpportunityAvailable);
        if(isOpportunityAvailable){
            
            system.debug('Inside Opportunity Available Block');
            listOfOpp 	= [ SELECT Id, Name, AccountId, Account.Name, Account.Org_Unit_ID__c, 
                           Account.Master_admin_Email__c, Billing_Frequency__c, 
                           Billing_F__c, Billing_Method__c 
                           FROM Opportunity WHERE 
                           Id =:OppId LIMIT 1 ];
            if(isInsert){
                listOfAsset = [ SELECT Id, Opportunity_ID__c, Account.Org_Unit_ID__c, 
                               Account.Master_admin_Email__c, Name, Account.Name, Product2.Name, 
                               Product2.Family, Product2.ProductCode, Billing_Type__c, 
                               Quantity, Price, Account_PAN__c, AccountId, Status, 
                               Payment_Term__c, Payment_Method__c, License_ID__c, 
                               PurchaseDate, UsageEndDate, License_no_of_gstins__c, 
                               License_no_of_pans__c, License_no_of_userids__c, 
                               No_of_Vendor__c,ERP__c, 
                               License_B2B_SalesInvoice_per_year__c, 
                               Number_of_Purchase_Invoice__c, Number_of_eway_bill__c, 
                               No_of_airline_invoices__c, 
                               License_B2C_SalesInvoice_per_year__c, 
                               Type_of_Integration__c, 
                               Type_of_Integration_QLI__c, 
                               License_no_of_total_Sales_Invoices__c, 
                               License_no_of_irns_per_year__c, 
                               License_no_of_invoice_formats__c,
                               License_no_of_gstin_verification_credits__c, 
                               License_No_of_MM2A_2B_usage_GSTIN_mon__c, 
                               License_no_of_Recon__c, 
                               No_of_expected_B2C_invoices_for_QR_code__c, 
                               Product2.Plan_Tier__c, 
                               Product2.Product_Plan_Id__c,
                               Product2.Is_Standard__c, 
                               Workspace_Details__c, 
                               Master_Email__c,
                               Product_Name_Formula__c,
                               Platform__c
                               FROM Asset WHERE
                               Opportunity_ID__c =: OppId AND 
                               ( NOT Status IN :System.Label.Asset_Standard_Plan_Exclude_Status.split(';') )  ];
                
            } else{
                listOfAsset = [ SELECT Id, Opportunity_ID__c, Account.Org_Unit_ID__c, 
                               Account.Master_admin_Email__c, Name, Account.Name, Product2.Name, 
                               Product2.Family, Product2.ProductCode, Billing_Type__c, 
                               Quantity, Price, Account_PAN__c, AccountId, Status, 
                               Payment_Term__c, Payment_Method__c, License_ID__c, 
                               PurchaseDate, UsageEndDate, License_no_of_gstins__c, 
                               License_no_of_pans__c, License_no_of_userids__c, 
                               No_of_Vendor__c,ERP__c, 
                               License_B2B_SalesInvoice_per_year__c, 
                               Number_of_Purchase_Invoice__c, Number_of_eway_bill__c, 
                               No_of_airline_invoices__c, 
                               License_B2C_SalesInvoice_per_year__c, 
                               Type_of_Integration__c, 
                               Type_of_Integration_QLI__c, 
                               License_no_of_total_Sales_Invoices__c, 
                               License_no_of_irns_per_year__c, 
                               License_no_of_invoice_formats__c,
                               License_no_of_gstin_verification_credits__c, 
                               License_No_of_MM2A_2B_usage_GSTIN_mon__c, 
                               License_no_of_Recon__c, 
                               No_of_expected_B2C_invoices_for_QR_code__c, 
                               Product2.Plan_Tier__c, 
                               Product2.Product_Plan_Id__c,
                               Product2.Is_Standard__c, 
                               Workspace_Details__c,
                               Master_Email__c,
                               Product_Name_Formula__c,
                               Platform__c
                               FROM Asset WHERE
                               Opportunity_ID__c =: OppId ];
            }
            
            accountId 	= listOfOpp[0].AccountId;
            system.debug('listOfAsset size in Opp Block: '+listOfAsset.size());
        } else{
            if(isInsert){
                listOfAsset = [ SELECT Id, Opportunity_ID__c, Account.Org_Unit_ID__c, 
                               Account.Master_admin_Email__c, Name, Account.Name, Product2.Name, 
                               Product2.Family, Product2.ProductCode, Billing_Type__c, 
                               Quantity, Price, Account_PAN__c, AccountId, Status, 
                               Payment_Term__c, Payment_Method__c, License_ID__c, 
                               PurchaseDate, UsageEndDate, License_no_of_gstins__c, 
                               License_no_of_pans__c, License_no_of_userids__c, 
                               No_of_Vendor__c,ERP__c, 
                               License_B2B_SalesInvoice_per_year__c, 
                               Number_of_Purchase_Invoice__c, Number_of_eway_bill__c, 
                               No_of_airline_invoices__c, 
                               License_B2C_SalesInvoice_per_year__c, 
                               Type_of_Integration__c, 
                               Type_of_Integration_QLI__c, 
                               License_no_of_total_Sales_Invoices__c, 
                               License_no_of_irns_per_year__c, 
                               License_no_of_invoice_formats__c,
                               License_no_of_gstin_verification_credits__c, 
                               License_No_of_MM2A_2B_usage_GSTIN_mon__c, 
                               License_no_of_Recon__c, 
                               No_of_expected_B2C_invoices_for_QR_code__c, 
                               Product2.Plan_Tier__c,
                               Product2.Product_Plan_Id__c, 
                               Product2.Is_Standard__c,
                               Workspace_Details__c, 
                               Master_Email__c,
                               Product_Name_Formula__c,
                               Platform__c
                               FROM Asset WHERE
                               Id =: assetId AND
                               ( NOT Status IN :System.Label.Asset_Standard_Plan_Exclude_Status.split(';') ) ];
            } else{
                listOfAsset = [ SELECT Id, Opportunity_ID__c, Account.Org_Unit_ID__c, 
                               Account.Master_admin_Email__c, Name, Account.Name, Product2.Name, 
                               Product2.Family, Product2.ProductCode, Billing_Type__c, 
                               Quantity, Price, Account_PAN__c, AccountId, Status, 
                               Payment_Term__c, Payment_Method__c, License_ID__c, 
                               PurchaseDate, UsageEndDate, License_no_of_gstins__c, 
                               License_no_of_pans__c, License_no_of_userids__c, 
                               No_of_Vendor__c,ERP__c, 
                               License_B2B_SalesInvoice_per_year__c, 
                               Number_of_Purchase_Invoice__c, Number_of_eway_bill__c, 
                               No_of_airline_invoices__c, 
                               License_B2C_SalesInvoice_per_year__c, 
                               Type_of_Integration__c, 
                               Type_of_Integration_QLI__c, 
                               License_no_of_total_Sales_Invoices__c, 
                               License_no_of_irns_per_year__c, 
                               License_no_of_invoice_formats__c,
                               License_no_of_gstin_verification_credits__c, 
                               License_No_of_MM2A_2B_usage_GSTIN_mon__c, 
                               License_no_of_Recon__c, 
                               No_of_expected_B2C_invoices_for_QR_code__c, 
                               Product2.Plan_Tier__c,
                               Product2.Product_Plan_Id__c, 
                               Product2.Is_Standard__c,
                               Workspace_Details__c, 
                               Master_Email__c,
                               Product_Name_Formula__c,
                               Platform__c
                               FROM Asset WHERE
                               Id =: assetId ];
            }
            
            accountId 	= listOfAsset[0].AccountId;
            system.debug('listOfAsset size outside Opp Block: '+listOfAsset.size());
        }
        
        if(accountId != NULL){
            worksopaceDetails= [ SELECT Id, Org_Unit_ID__c FROM Workspace__c WHERE 
                                Root_Workspace__c = TRUE AND 
                                Account__c =: accountId ];
        }
        
        if(worksopaceDetails != NULL || worksopaceDetails.size() > 0){
            for(Workspace__c thisRec : worksopaceDetails){
                
                WorkspaceWrapper newWorkSpace 	= new WorkspaceWrapper();
                newWorkSpace.workspaceId 		= thisRec.Id;
                newWorkSpace.workspaceOrgUnitId = thisRec.Org_Unit_ID__c;
                workspaceList.add(newWorkSpace);
            }
        }
        
        
        
        system.debug('listOfAsset '+listOfAsset);
        for(asset tempAsset: listOfAsset){
            
            if(
                ( tempAsset.Product_Name_Formula__c?.contains('GST') && tempAsset.Platform__c == 'App.Clear' ) ||
                ( tempAsset.Platform__c != 'App.Clear' || !tempAsset.Product_Name_Formula__c?.contains('GST') )
            ){
            
            system.debug('listOfAsset WorkSpace Details Value: '+tempAsset.Workspace_Details__c);
            
            AssetWrapper assetWrapper								= new AssetWrapper();
            assetWrapper.assetId									= tempAsset.id;
            assetWrapper.oppId										= tempAsset.Opportunity_ID__c;
            assetWrapper.Name										= tempAsset.Name;
            assetWrapper.productName								= tempAsset.Product2.Name;
            assetWrapper.billingType								= tempAsset.Billing_Type__c;
            assetWrapper.quantity									= tempAsset.Quantity;
            assetWrapper.price										= tempAsset.Price;
            assetWrapper.accPAN										= tempAsset.Account_PAN__c;
            assetWrapper.accId										= tempAsset.AccountId;
            assetWrapper.status										= tempAsset.Status;
            assetWrapper.assetStartDate								= tempAsset.PurchaseDate;
            assetWrapper.assetEndDate								= tempAsset.UsageEndDate;
            assetWrapper.paymentTerm								= tempAsset.Payment_Term__c;
            assetWrapper.paymentMethod								= tempAsset.Payment_Method__c;
            assetWrapper.licenseId 									= tempAsset.License_ID__c;
            assetWrapper.noOfGSTINs									= tempAsset.License_no_of_gstins__c;
            assetWrapper.noOfPANs									= tempAsset.License_no_of_pans__c;
            assetWrapper.noOfUserIds								= tempAsset.License_no_of_userids__c;
            assetWrapper.noOfVendor									= tempAsset.No_of_Vendor__c;
            assetWrapper.ERP										= tempAsset.ERP__c;
            assetWrapper.noOfAirlineInvoices						= tempAsset.No_of_airline_invoices__c;
            assetWrapper.noOfB2CSalesInvoice						= tempAsset.License_B2C_SalesInvoice_per_year__c;
            assetWrapper.noOfB2BSalesInvoice						= tempAsset.License_B2B_SalesInvoice_per_year__c;
            assetWrapper.noOfPurchaseInvoice						= tempAsset.Number_of_Purchase_Invoice__c;
            assetWrapper.noOfEwayBill								= tempAsset.Number_of_eway_bill__c; 
            assetWrapper.typeOfIntegration							= tempAsset.Type_of_Integration_QLI__c; 
            /**	Bibhu added : 06-01-2022	**/
            assetWrapper.License_no_of_total_Sales_Invoices 		= tempAsset.License_no_of_total_Sales_Invoices__c;
            assetWrapper.License_no_of_irns_per_year 				= tempAsset.License_no_of_irns_per_year__c;
            assetWrapper.License_no_of_invoice_formats 				= tempAsset.License_no_of_invoice_formats__c;
            assetWrapper.License_no_of_gstin_verification_credits 	= tempAsset.License_no_of_gstin_verification_credits__c;
            assetWrapper.No_of_airline_invoices 					= tempAsset.No_of_airline_invoices__c;
            assetWrapper.License_No_of_MM2A_2B_usage_GSTIN_mon 		= tempAsset.License_No_of_MM2A_2B_usage_GSTIN_mon__c;
            assetWrapper.License_no_of_Recon 						= tempAsset.License_no_of_Recon__c;
            assetWrapper.No_of_expected_B2C_invoices_for_QR_code 	= tempAsset.No_of_expected_B2C_invoices_for_QR_code__c;
            
            if(tempAsset.Product2.Is_Standard__c)
                assetWrapper.planId									= tempAsset.Product2.Product_Plan_Id__c;
            else
                assetWrapper.planId									= NULL;
            
            ProductWrapper prodWrapper								= new ProductWrapper();
            prodWrapper.productCode									= tempAsset.Product2.ProductCode;
            prodWrapper.productFamily								= tempAsset.Product2.Family == 'Invoicing' ? 'E-invoice & EWB' : tempAsset.Product2.Family;
            assetWrapper.product									= prodWrapper; 
            
            if(tempAsset.AccountId != NULL){
                accw												= new AccountWrapper();
                if(
                    tempAsset.Master_Email__c != tempAsset.Account.Master_admin_Email__c && 
                    tempAsset.Master_Email__c != NULL
                ){
                    incomingMasterEmailId 							= tempAsset.Master_Email__c;
                    accw.masterEmailID 								= tempAsset.Master_Email__c;
                }else{
                    accw.masterEmailID 								= tempAsset.Account.Master_admin_Email__c;
                    incomingMasterEmailId 							= tempAsset.Account.Master_admin_Email__c;
                }
                accw.accountId 										= tempAsset.AccountId;
                accw.name 											= tempAsset.Account.Name;
                accw.orgUnitId 										= tempAsset.Account.Org_Unit_ID__c;
                accw.workspaceId									= tempAsset.Workspace_Details__c;
                incomingWorkspaceId									= tempAsset.Workspace_Details__c;
                accw.workspaces 									= workspaceList;
            }
            
            if(mapOfOppIdToAssetWrapper.containsKey(tempAsset.Opportunity_ID__c)){
                mapOfOppIdToAssetWrapper.get(tempAsset.Opportunity_ID__c).add(assetWrapper);
            }else{
                mapOfOppIdToAssetWrapper.put(tempAsset.Opportunity_ID__c,new list<AssetWrapper>{assetWrapper});
            }
            
            assetWrapperList.add(assetWrapper);
        }
    }
        
        
        OpportunityWrapper OppWrapper;
        
        if(listOfOpp != NULL){
            for(opportunity tempOpp: listOfOpp){
                
                OppWrapper									= new OpportunityWrapper();
                OppWrapper.oppId							= tempOpp.id;
                OppWrapper.name								= tempOpp.Name;
                OppWrapper.billingFreqForServiceFeeOTP		= tempOpp.Billing_Frequency__c;
                OppWrapper.billingFreqForSubscriptionFee	= tempOpp.Billing_F__c;
                OppWrapper.billingMethod					= tempOpp.Billing_Method__c;
                OppWrapper.assets							= mapOfOppIdToAssetWrapper.get(tempOpp.Id);
                accw										= new AccountWrapper();
                accw.accountId								= tempOpp.AccountId;
                accw.name									= tempOpp.Account.Name;
                accw.masterEmailID							= incomingMasterEmailId;
                accw.orgUnitId 								= tempOpp.Account.Org_Unit_ID__c;
                accw.workspaceId							= incomingWorkspaceId;
                accw.workspaces 							= workspaceList;
                OppWrapper.accounts							= accw;
                OppWrapper.isInsert							= isInsert;
                jsonRequestBody								= JSON.serialize(OppWrapper);
                system.debug('JSON.serialize RequestBody Opportunity Block--> '+jsonRequestBody);
            }
        } else{
            OppWrapper						= new OpportunityWrapper();
            OppWrapper.name					= accw.name;
            OppWrapper.assets				= assetWrapperList;
            OppWrapper.accounts				= accw;
            OppWrapper.isInsert				= isInsert;
            jsonRequestBody					= JSON.serialize(OppWrapper);
            system.debug('JSON.serialize RequestBody Asset Block--> '+jsonRequestBody);
        }
        
        If(!test.isRunningTest()){
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(System.Label.SalesSyncService_Endpoint);
            request.setHeader('X-Api-Token',System.Label.SalesSyncService_X_Api_Token); 
            request.setHeader('Content-Type', 'application/json');
            request.setMethod('POST');
            //request.setTimeout(119999);
            request.setBody(jsonRequestBody);
            HttpResponse response=http.send(request);
            string JSONResponseBody=response.getBody();
            System.debug(' JSONResponseBody '+JSONResponseBody);
            System.debug(' JSONResponseCode '+response.getStatusCode());
            ResponseWrapper RespWrapper=new ResponseWrapper();
            RespWrapper=(ResponseWrapper)System.JSON.deserialize(JSONResponseBody, ResponseWrapper.class);
            system.debug('RespWrapper '+RespWrapper);
            system.debug('RespWrapper.OppID '+RespWrapper.oppId);
            
            if(response.getStatusCode()==200){
                system.debug('200');
                if(isOpportunityAvailable){
                    Opportunity oppToUpdate=new Opportunity();
                    oppToUpdate.Id=RespWrapper.oppId;
                    oppToUpdate.Integration_Status__c='Success';
                    //update oppToUpdate;
                } else{
                    
                    /**update new Account(
Id = accountId,
JSON_Store__c = jsonRequestBody
);**/
                }
            }else{
                system.debug('400 ');
                
                if(isOpportunityAvailable){
                    
                    Opportunity oppToUpdate=new Opportunity();
                    oppToUpdate.Id=RespWrapper.oppId;
                    oppToUpdate.Integration_Status__c='Failed';
                    
                    try{
                        // update oppToUpdate;
                    } catch(exception e){
                        system.debug('Failed in oppor Update');
                    }
                    
                } else{
                    /*update new Account(
Id = accountId,
JSON_Store__c = jsonRequestBody
);*/
                }
                
            }
            
            
        }
        
    }
    
    public static void callout(Account thisAccount, String oldEmailId){
        
        system.debug('thisAccount.Org_Unit_ID__c: '+thisAccount.Org_Unit_ID__c);
        String jsonRequestBody = '';
        
        MasterAccountWrapper accw					= new MasterAccountWrapper();
        accw.oldMasterAdminEmail					= oldEmailId;
        accw.newMasterAdminEmail					= thisAccount.Master_admin_Email__c;
        accw.sfAccountId 							= thisAccount.Id;
        accw.orgUnitId 								= thisAccount.Org_Unit_ID__c;
        accw.transferRoleToChild					= TRUE;
        
        jsonRequestBody								= JSON.serialize(accw);
        system.debug('JSON.serialize RequestBody--> '+jsonRequestBody);
        
        
        If(!test.isRunningTest()){
            
            Http 		http 	= new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(System.Label.SalesSyncService_MasterAdmin_Change);
            request.setHeader('X-Api-Token',System.Label.SalesSyncService_X_Api_Token); 
            request.setHeader('Content-Type', 'application/json');
            request.setMethod('POST');
            request.setBody(jsonRequestBody);
            
            HttpResponse 	response			= http.send(request);
            string 			JSONResponseBody	= response.getBody();
            // ResponseWrapper RespWrapper			= (ResponseWrapper)System.JSON.deserialize(JSONResponseBody, ResponseWrapper.class);
            
            System.debug(' JSONResponseBody '+JSONResponseBody);
            System.debug(' JSONResponseCode '+response.getStatusCode());
            //system.debug('RespWrapper '+RespWrapper);
            //system.debug('RespWrapper.OppID '+RespWrapper.oppId);
            
            if(response.getStatusCode()==200){
                system.debug('200 ');
                Account thisRec 		= thisAccount.clone(FALSE, FALSE, FALSE, FALSE);
                thisRec.Id				= thisAccount.Id;
                thisRec.JSON_Store__c 	= jsonRequestBody;
                
                //update thisRec;
            }else{
                system.debug('400 ');
                Account thisRec 		= thisAccount.clone(FALSE, FALSE, FALSE, FALSE);
                thisRec.Id				= thisAccount.Id;
                thisRec.JSON_Store__c 	= jsonRequestBody;
                
                //update thisRec;
            }
        }
        
    }
    
    
}	/**	End of Class	**/