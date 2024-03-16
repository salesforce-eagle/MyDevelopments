/**
* @description       : 
* @author            : pramodh@warpdrivetech.in
* @group             : 
* @last modified on  : 01-18-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                     Modification
* 1.0   03-05-2021   pramodh@warpdrivetech.in   Initial Version
**/
public with sharing class generateOrderFormPDF { 
    
    public Static String    opptyId{get;set;}
    public Static Integer   assistLimitationCheck{get;set;}
    public Static Boolean   assistASLimitaionCheck{get;set;}
    public Static Boolean   idSOSCheck{get;set;}
    public Static boolean   prodCheck{get;set;}
    public Static boolean   prodCheck_GST{get;set;}
    public Static boolean   showAddOnTable{get;set;}
    public Static String    Type_of_Compliance_service{get;set;}
    public Static boolean   prodCheckMaxItc{get;set;}
    public Static boolean   qouteCheckTypeOfIntegration{get;set;}
    public Static boolean   qouteCheckAPIOnlyByCustomer{get;set;}
    public Static boolean   onlyContainsOnlyByCustomer{get;set;}
    public Static boolean   containsOnlyByCustomer{get;set;}
    public Static boolean   prodCheck_CustomTemplateOTP{get;set;}
    public Static boolean   tenHrIntegrationClause{get;set;}
    public Static boolean   gccCheck{get;set;}
    public Static boolean   netNewCheck{get;set;}
    public Static boolean   crossSellCheck{get;set;}
    public Static boolean   netNewIDCheck{get;set;}
    public Static boolean   cimplifiveCheck{get;set;}
    public Static boolean   netNewIDInvoiceDiscountingSAASCheck{get;set;}
    public Static boolean   netNewIDInvoiceDiscountingTransactionalCheck{get;set;}
    public Static boolean   netNewIDInvoiceDiscountingSKUCheck{get;set;}
    public Static boolean   productFamilyCreditCheck{get;set;}
    public Static boolean   hideTransactionSlabTable{get;set;}
    Public Static String    dynamicClause{get;set;}
    Public Static String    dynamicClauseGCC{get;set;}
    Public Static String    additionChargesGcc{get;set;}
    Public Static boolean   dynamicRenewalClause{get;set;}
    Public Static string    renewalValuePercentage{get;set;}
    public Static Quote     syncedQuote{get;set;}
    public Static Long      totalPrice{get;set;}
    public Static Integer   totalSLA{get;set;}
    public Static String    billingAddress{get;set;}
    public Static String    shippingAddress{get;set;}
    public Static String    vatNumber{get;set;}
    public Static String    crNumber{get;set;}
    public Static String    accountName{get;set;}
    public Static String    CTXSigneeName{get;set;}
    public Static String    CTXSigneeDesig{get;set;}
    public Static String    adminEmail{get;set;}
    public Static String    domainName{get;set;}
    public Static Boolean   showNoPO{get;set;}
    public Static Boolean   showYesPO{get;set;}
    public Static boolean   netNewIDTenorExtension{get;set;}
    
    public Static Map<String, String>   prodCodeURLMap{get;set;}// Added for URL Link
    public Static String    billingFrequencyForSubscriptionFee{get;set;}
    public STatic String    billingFrequencyForIntegrationProds{get;set;}
    public Static List<QuoteLineItem>                                               listQLI{get;set;}
    public Static List<Integration_Scope_Add_On__c>                                 listAddOn{get;set;}
    public Static Map<String,Map<QuoteLineItem, Set<Integration_Scope_Add_On__c>>>  QLIAddOnMap{get;set;}
    public Static List<Map<QuoteLineItem, Set<Integration_Scope_Add_On__c>>>        QLIAddOnMapUse{get;set;}
    Public Static Map<QuoteLineItem, Set<Integration_Scope_Add_On__c>>              quoteLineItemAndIntegrationScope{get;set;}
    Public Static Map<String, Long>                                                 quoteLineItemTotalSLA{get;set;}
    Public Static Map<QuoteLineItem, Long>                                          quoteLineItemTotalSLA2{get;set;}
    public static List<ARRroductsWrapper>                                           listOfARRProdsWrapper{get;set;}
    public static List<ScopeWrapper>                                                listOfScopeWrap{get;set;}
    public static List<OTPProductsWrapper>                                          listOfOTPProdsWrapper{get;set;}
    public static List<Additional_GSTIN__c>                                         listOfGstins{get;set;}
    public static List<ContactDetails>                                              listOfContactWrapper{get;set;}
    Public static Long                                                              ARRProdTotal{get;set;}
    public static Long                                                              OTPProdsTotal{get;set;}
    public static Decimal                                                           additionalGSTINsTotal{get;set;}
    public static List<Usage_PANs__c>                                               listOfUsgePANs{get;set;}
    public static list<Double>                                                      listOfOrdersToDisplay{get;set;}
    public static Map<Double,Product_ScopeOfService_Junction__c>                    mapOfOrderToProdSOSJunctionToDisplay{get;set;}
    public Static integer                                                           nextNumber{get;set;}
    public Static String                                                            nextPage{get;set;}
    public Static integer                                                           SOS{get;set;}
    public Static Boolean                                                           containsIntegrationProduct{get;set;}
    public Static boolean                                                           displayGoogleTerms{get;set;}
    public Static boolean                                                           displayDevelopmentTerms{get;set;}
    public Static boolean                                                           displayConsultationTerms{get;set;}
    public Static boolean                                                           displayOwnFunds{get;set;}
    public Static boolean                                                           displayBankFinancing{get;set;}
    public Static boolean                                                           displayTreDS{get;set;}
    public Static boolean                                                           displayTenorExtension{get;set;}
    public Static boolean                                                           displayAPIBasedIntegration{get;set;}
    public Static boolean                                                           displayMiddlewareBasedIntegration{get;set;}
    public Static boolean                                                           displaySFTPBasedIntegration{get;set;}
    public Static boolean                                                           displayIdTypeOfIntegration{get;set;}
    public Static boolean                                                           prodLineIsGST{get;set;}
    public Static boolean                                                           prodLineIsEinv{get;set;}
    public Static boolean                                                           prodLineIsMax{get;set;}
    public Static boolean                                                           displayBillingFreqInteg{get;set;}
    public Static boolean                                                           displayBillingFreqOtp{get;set;}
    public Static boolean                                                           displayBillingFreqSubs{get;set;}
    public Static boolean                                                           displayRefundPolicy{get;set;}
    public Static boolean                                                           displaySOS{get;set;}
    public Static Map<String, Product_Line_Consulting_Cost__mdt> 		            productCostMap{get;set;}
    public Static List<Product_Line_Consulting_Cost__mdt>  							productCostList{get;set;}
    public Static String    productNameConsulting{get;set;}
    public Static String    consultingHours{get;set;}
    public Static boolean   containsMsProduct{get;set;}
    public Static boolean   containsKycApi{get;set;}
    public Static boolean   isSingleArr{get;set;}
    Public static Long                                                             	   ARRProdDiscountedPriceOF{get;set;}
    Public static Decimal                                                              ARRProdDiscountOF{get;set;}
    Public static Decimal                                                              ARRTotalListPrice{get;set;}
    Public static Long                                                             	   totalInvoiceAmount{get;set;}
    
    public class ESignDetails{
        
        @AuraEnabled
        public String orderFormMSG;
        @AuraEnabled
        public Opportunity opptyDetails;
        @AuraEnabled
        public String errorMsg;
        @AuraEnabled
        public Boolean containsIntegrationSKU;
    }
    
    @AuraEnabled
    public Static ESignDetails getOpportunityDetalsOnLoad(String oppId){ //Opportunity
        
        System.debug('getOpportunityDetalsOnLoad() oppId '+oppId);
        Set<String> setOfContentDocIds = new Set<String>();
        Map<String, E_Sign_Config__c> eSignConfig = E_Sign_Config__c.getAll();
        String docType = eSignConfig.get('Type_Of_Doc').Value__c;
        
        Opportunity oppty = [SELECT Id, Is_Billing_GSTIN_Not_Available__c, name,E_Sign_Status__c,ESign_Category__c ,StageName,RecordType.DeveloperName,GST_Advantage_Count__c,Total_Count_OP_Count__c,Country_of_Origin_GCC__c, Country_of_Origin__c,Update_Company_Information__c  FROM Opportunity WHERE Id=:oppId LIMIT 1];
        System.debug('Name '+oppty.name);
        ESignDetails wraperInstance = new ESignDetails();
        if(oppty.E_Sign_Status__c == 'E-Sign Request Sent'){
            wraperInstance.errorMsg = 'You cannot modify or generated Order Form, E-Sign Request already sent.';
        }else if(oppty.E_Sign_Status__c == 'E-Sign Successful'){
            wraperInstance.errorMsg = 'You cannot modify or generated Order Form, E-Sign Request is already successfully completed.';
        }
        List<ContentDocumentLink> listOfContentDocLinks = [SELECT id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId 
                                                           FROM ContentDocumentLink WHERE LinkedEntityId=:oppId];
        for(ContentDocumentLink cd : listOfContentDocLinks){
            setOfContentDocIds.add(cd.ContentDocumentId); 
        }
        List<ContentVersion> listOfContentDocVersion = [SELECT id,ContentDocumentId,Lock_Content_Version__c,Type_of_document__c
                                                        FROM ContentVersion WHERE ContentDocumentId IN :setOfContentDocIds AND Type_of_document__c =:docType ];
        if(!listOfContentDocVersion.isEmpty()){
            wraperInstance.errorMsg = 'Cannot generate Order Form. Order Form already Exist, please delete the old order form and generated new if required.';
        }
        if(oppty.StageName != 'Follow Up' && oppty.StageName != 'At Risk'){
            wraperInstance.errorMsg = 'Document can only be generated in Follow Up Stage.';
        }
        wraperInstance.opptyDetails = oppty;
        //return oppty;
        
        //added by bhaveshjindal : if opportuninty contains integration product
        List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId FROM OpportunityLineItem 
                                             WHERE Product2.Product_category__c = 'Integration' 
                                             AND OpportunityId =: oppty.Id];
        if(oliList != NULL){
            wraperInstance.containsIntegrationSKU = TRUE;
        }else{
            wraperInstance.containsIntegrationSKU = FALSE;
        }
        
        return wraperInstance;
    }
    
    public generateOrderFormPDF(ApexPages.StandardController controller){
        assistLimitationCheck  = 0;
        totalInvoiceAmount= 0;
        prodCodeURLMap = new Map<String, String> ();     // Added for URL Link
        idSOSCheck = FALSE;
        showAddOnTable= FALSE;
        gccCheck = FALSE;
        // try{
        opptyId = ApexPages.currentPage().getParameters().get('id');
        System.debug('opptyId '+opptyId);
        
        Map<String, E_Sign_Config__c> eSignConfig = E_Sign_Config__c.getAll();
        listAddOn   = new List<Integration_Scope_Add_On__c>();
        QLIAddOnMap = new Map<String,Map<QuoteLineItem, Set<Integration_Scope_Add_On__c>>>();
        quoteLineItemTotalSLA = new Map<String, Long>();
        quoteLineItemTotalSLA2 = new Map<QuoteLineItem, Long>();
        totalPrice = 0;
        totalSLA = 0;
        Map<String, Set<Integration_Scope_Add_On__c>>   erpSKUIntegrationScopeMap   = new Map<String, Set<Integration_Scope_Add_On__c>>();
        
        Map<String,String> mapOfBillingFreqForSubscriptionFee = new map<String,String>(); //'Half-yearly in end (Approval Driven)' => 'Half-yearly in end', 'Quarterly in end (Approval Driven)' => 'Quarterly in end', 'Monthly in end (Approval Driven)' => 'Monthly in end'
        mapOfBillingFreqForSubscriptionFee.put('Half-yearly in end (Approval Driven)','Half-yearly in end');
        mapOfBillingFreqForSubscriptionFee.put('Quarterly in end (Approval Driven)','Quarterly in end');
        mapOfBillingFreqForSubscriptionFee.put('Monthly in end (Approval Driven)','Monthly in end');
        
        
        syncedQuote = [SELECT id, name,QuoteNumber,No_of_GSTIN_one__c,No_of_Vendors_one__c,No_of_User_ID_one__c,BtoC_Sales_one__c,
                       BtoB_Sales_one__c,Purchases_Invoices_one__c,ERP__c,Type_of_Integration__c,No_of_PAN_one__c,Opportunity.PO_number__c,
                       Opportunity.Country_of_Origin_GCC__c, 
                       Opportunity.PO_Required__c,Opportunity.PO_Amount__c,Opportunity.PAN_No_as_per_PO__c,Opportunity.Special_Terms__c,
                       Opportunity.Name,Opportunity.Period_Start_date__c,Opportunity.Period_End_date__c ,Opportunity.Term_Months__c,
                       Opportunity.owner.Name,Opportunity.Owner.Employee_ID__c,Opportunity.Account.Name,Opportunity.Account.PAN__c,
                       Opportunity.Billing_Frequency__c,Opportunity.Billing_F__c,Opportunity.Place_of_Supply__c,Opportunity.E_Sign_Customer_Info__c,
                       Opportunity.E_Sign_Customer_Info__r.Name, Opportunity.E_Sign_Customer_Info__r.Designation__c,Opportunity.Billing_GST__c,
                       Opportunity.If_SEZ__c,Opportunity.TAN__c,Opportunity.Payment_Term__c,Opportunity.Payment_Method__c,Opportunity.Billing_Method__c,
                       Opportunity.Bus_POC__r.name,Opportunity.Bus_POC__r.email,Opportunity.Bus_POC__r.Designation__c,Opportunity.Bus_POC__r.ISD__c,Opportunity.Bus_POC__r.phone,
                       Opportunity.Finance_POC_contact__r.name,Opportunity.Finance_POC_contact__r.email,Opportunity.Finance_POC_contact__r.Designation__c,Opportunity.Finance_POC_contact__r.ISD__c,Opportunity.Finance_POC_contact__r.phone, 
                       Opportunity.Finance_Head_contact__r.name,Opportunity.Finance_Head_contact__r.email,Opportunity.Finance_Head_contact__r.Designation__c,Opportunity.Finance_Head_contact__r.ISD__c,Opportunity.Finance_Head_contact__r.phone, 
                       Opportunity.Tax_Head_contact__r.name,Opportunity.Tax_Head_contact__r.email,Opportunity.Tax_Head_contact__r.Designation__c,Opportunity.Tax_Head_contact__r.ISD__c,Opportunity.Tax_Head_contact__r.phone,
                       Opportunity.IT_Head_contact__r.name,Opportunity.IT_Head_contact__r.email,Opportunity.IT_Head_contact__r.Designation__c,Opportunity.IT_Head_contact__r.ISD__c,Opportunity.IT_Head_contact__r.phone,Opportunity.Billing_Address__c,Opportunity.Address_Line_2__c,Opportunity.city_2__c,Opportunity.state_2__c,Opportunity.pincode__c, Opportunity.Shipping_Address__c, Opportunity.Legal_Entity_Name_Of_The_Client__c,
                       Opportunity.Billing_Frequency_for_Integration_Prods__c,Opportunity.Fee_per_additional_usage__c,Existing_Vendor__c,Category_of_Company__c,No_MM2A_2B_usage_GSTIN_month__c,Opportunity.Amount__c,
                       No_of_GSTIN_verification_credits__c,No_of_IRNs__c,No_of_EWBs__c,No_of_expected_B2C_invoices_for_QR_code__c,Opportunity.Master_admin_Email__c,No_of_invoice_formats__c,No_of_recons__c,No_of_airline_invoices_annual_one__c,Opportunity.Company_Domain_Name__c, Opportunity.Custom_Billing_Freq_for_Integration_Prod__c,Opportunity.Order_Id_Only_If_Razorpay_Payment__c,opportunity.Renewal_Clause_Required__c,opportunity.Renewal_Charge__c,
                       Opportunity.CR_Number_gcc__c, Opportunity.VAT_Number_gcc__c,No_of_VAT__c,Opportunity.TIN_number__c,additional_charges__c, ERP_GCC__c, No_of_TANs__c, Number_of_Deductees_per_Quarter_24Q_26__c, Number_of_Deduction_Transactions_per_Qua__c, Digital_Signing_Utility_for_TDS_Certific__c, 
                       Monthly_throughput_Slab_1_Cr__c, Monthly_throughput_Slab_2_Cr__c, Monthly_throughput_Slab_3_Cr__c, Transaction_Fee_Slab_1__c, Transaction_Fee_Slab_2__c, Transaction_Fee_Slab_3__c, Flat_Transaction_Fee__c,Opportunity.CIN__c,Tally_Connector_required__c,
                       Total_annual_domestic_payables_Rs_Cr__c,Opportunity.RecordType.DeveloperName,Total_B2B_PR_B2C_invoice__c, Max_Term_Months__c,Opportunity.MSSA_Deal__c ,
                       Total_Integration_SLA__c, No_of_Bank_verification_API__c, No_of_API_calls_permissible__c, No_of_MCA_Company_details_API__c, No_of_MSME_API__c,
                       No_of_PAN_verification_API__c, No_of_TDS_206_sync_API__c, No_of_Customised_Invoice_Print_template__c,Opportunity.E_Sign_Customer_Info__r.Email,
                       ID_Early_Payment_Methods__c, Bank_Name__c, TreDS_platform__c,Opportunity.GCC_initial_term_months__c ,Opportunity.GCC_Additional_period_months__c,Opportunity.ClearTax_Billing_Entity__c, Opportunity.Country_of_Origin__c ,
                       Opportunity.Company_Secretary__r.name,Opportunity.Company_Secretary__r.email,Opportunity.Company_Secretary__r.Designation__c,Opportunity.Company_Secretary__r.ISD__c,Opportunity.Company_Secretary__r.phone,Opportunity.Billing_Frequency_for_retainership__c,
                       Opportunity.Custom_SOW_for_MS__c, Opportunity.MSSA_Execution_date__c, Opportunity.Agreement_Number__c, Account.EC_LC_Startup_Account__c, Number_of_Sales_Invoices__c, No_of_Offline_devices__c, No_of_Online_devices__c , POS_system__c,
                       Opportunity.MS_Billing_Frequency__c, Discount__c, Subtotal, Total_Price__c, Total_List_Price_Order_Form__c, Flat_Tenor_Extension_Fees__c,
                       Data_Archival__c, Auto_Retry__c, Translation__c
                       
                       FROM Quote WHERE OpportunityId=:opptyId AND IsSyncing=true LIMIT 1]; 
        listOfGstins = [ SELECT Id, Name, Address__c, Amount__c, Quote_Line_Item__c,Quote__c,Name_Of_The_Customer__c,
                        Quote_Line_Item__r.Product2.name, Quote_Line_Item__r.Product2.Billing_Type__c,Address_Line_2__c,city__c,
                        state__c,pincode__c,Billing_Pan__c,TAN__c,SEZ_yes_no__c
                        FROM Additional_GSTIN__c WHERE Quote__c=:syncedQuote.Id ]; 
        listAddOn =   [ SELECT Id, Related_Quote__c, Related_Add_On__c, Related_Opportunity__c, 
                       Discount_Percentage__c, Discount_Rate__c, ERP_Family__c,
                       Is_Active__c, List_Price__c, Module__c, Name,
                       Product_SKU__c, Estimated_Effort_In_Days__c, Scope__c
                       FROM Integration_Scope_Add_On__c WHERE Related_Quote__c = :syncedQuote.Id ];
        Integer count = 0;
        if(
            syncedQuote.Opportunity.ClearTax_Billing_Entity__c == 'CimplyFive'
        ){
            cimplifiveCheck = TRUE;
        }
        for(Integration_Scope_Add_On__c thisRec : listAddOn){
            system.debug('Count of Add On: '+ count++);
            system.debug('Count of Add On Name: '+ thisRec.Scope__c);
            String tempString = thisRec.ERP_Family__c + thisRec.Product_SKU__c;
            if(erpSKUIntegrationScopeMap.containsKey(tempString)){
                erpSKUIntegrationScopeMap.get(tempString).add(thisRec);
            } else{
                erpSKUIntegrationScopeMap.put(tempString, new Set<Integration_Scope_Add_On__c>{thisRec});
            }
            //system.debug('Test123' +String.ValueOf(quoteLineItemTotalSLA.ContainsKey(tempString) ? quoteLineItemTotalSLA.get(tempString) : 0));
            //system.debug('Test1234' +String.ValueOf(thisRec.Estimated_Effort_In_Days__c == NULL ? 0 : thisRec.Estimated_Effort_In_Days__c));
            quoteLineItemTotalSLA.put(tempString, (Long)(quoteLineItemTotalSLA.ContainsKey(tempString) ? quoteLineItemTotalSLA.get(tempString) : 0 + thisRec?.Estimated_Effort_In_Days__c == NULL ? 0 : thisRec.Estimated_Effort_In_Days__c));
        }
        system.debug('ListAddOn!@#'+listAddOn);
        system.debug('Test$@#$#1'+erpSKUIntegrationScopeMap);
        
        listOfUsgePANs = [ SELECT Id, Product_Family__c, Usage_PAN__c FROM Usage_PANs__c WHERE Opportunity__c = :opptyId ];
        system.debug('#### '+syncedQuote.Opportunity.PO_number__c);
        additionalGSTINsTotal = 0;
        for(Additional_GSTIN__c addtnGstin : listOfGstins){
            additionalGSTINsTotal += addtnGstin.Amount__c;
        }
        
        /**	Signer Based on Entity Type : START : BIBHU Changed on 24/11/2022	**/
        if(syncedQuote.Opportunity.Amount__c > Decimal.ValueOf(System.label.ESign_Amount_Threshold)){
            CTXSigneeName = eSignConfig.get('CTX-Signer-Name').Value__c;
            CTXSigneeDesig = eSignConfig.get('CTX-Signer-Designation').Value__c;
            
        } else{
            CTXSigneeName = eSignConfig.get('CTX-Signer-Name1').Value__c;
            CTXSigneeDesig = eSignConfig.get('CTX-Signer-Designation1').Value__c;
        }
        
        //  if( cimplifiveCheck ){
        /**	Cimplifive Greater then 10 Lakhs	**/
        if( syncedQuote.Opportunity.Amount__c >= Decimal.ValueOf(System.label.ESign_Amount_Threshold_Cimplifive_10) ){
            
            CTXSigneeName = eSignConfig.get('CTX-Signer-Name-Srivatsan').Value__c;
            CTXSigneeDesig = eSignConfig.get('CTX-Signer-Designation-Srivatsan').Value__c;
        }
        /**	Cimplifive Less then 10 Lakhs	
if( syncedQuote.Opportunity.Amount__c < Decimal.ValueOf(System.label.ESign_Amount_Threshold_Cimplifive_10) ){
CTXSigneeName = eSignConfig.get('CTX-Signer-Name-Shankar').Value__c;
CTXSigneeDesig = eSignConfig.get('CTX-Signer-Designation-Shankar').Value__c;
}
} 
/**	Signer Based on Entity Type : END : BIBHU Changed on 24/11/2022	**/
        showNoPO = true;
        showYesPO = false;
        if(syncedQuote.Opportunity.PO_Required__c == 'Yes'){
            showNoPO = false;
            showYesPO = true;
        }
        renewalValuePercentage =syncedQuote.Opportunity.Renewal_Charge__c;
        dynamicRenewalClause =syncedQuote.Opportunity.Renewal_Clause_Required__c;
        
        /** Dynamic Pricing Parameter - GCC : bhaveshjiindal **/
        additionChargesGcc = '$ ';
        if(syncedQuote.additional_charges__c != NULL)
            additionChargesGcc += String.valueOf(syncedQuote.additional_charges__c);
        
        
        if( label.GST_Dynamic_Pricing_Clause_GCC.contains('$yy') ){
            dynamicClauseGCC = label.GST_Dynamic_Pricing_Clause_GCC.replace('$yy', additionChargesGcc);
        }
        
        //transactionalFeeSlab
        if((syncedQuote.Transaction_Fee_Slab_1__c == 0 || SyncedQuote.Transaction_Fee_Slab_1__c == NULL)
           && (syncedQuote.Transaction_Fee_Slab_2__c == 0 || syncedQuote.Transaction_Fee_Slab_2__c == NULL) 
           && (syncedQuote.Transaction_Fee_Slab_3__c == 0 || syncedQuote.Transaction_Fee_Slab_3__c == NULL)){
               hideTransactionSlabTable = TRUE;
           }
        
        //ID Early Payment Methods Logics :: Bhavesh
        if(syncedQuote.ID_Early_Payment_Methods__c != NULL){
            List<String> selections = syncedQuote.ID_Early_Payment_Methods__c.split(';');
            if (selections.contains('Own funds') )
            {
                displayOwnFunds = TRUE;
            }
            if (selections.contains('Bank financing') )
            {
                displayBankfinancing = TRUE;
            }
            if (selections.contains('TreDS') )
            {
                displayTreDS = TRUE;
            }
            if (selections.contains('External Financing-along with Tenor extension') )
            {
                displayTenorExtension = TRUE;
            }
        }
        
        /** Dynamic Pricing Parameter clause: Bibhu **/
        if( 
            syncedQuote.BtoB_Sales_one__c           != NULL || 
            syncedQuote.Purchases_Invoices_one__c   != NULL
        ){
            
            if( syncedQuote.BtoB_Sales_one__c > syncedQuote.Purchases_Invoices_one__c ){
                
                if(syncedQuote.BtoB_Sales_one__c <= 3000 ){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '3.0');
                    }
                }
                
                if(syncedQuote.BtoB_Sales_one__c > 3000 && syncedQuote.BtoB_Sales_one__c <= 10000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '3.0');
                    }
                }
                
                if(syncedQuote.BtoB_Sales_one__c > 10000 && syncedQuote.BtoB_Sales_one__c <= 25000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '2.2');
                    }
                }
                
                if(syncedQuote.BtoB_Sales_one__c > 25000 && syncedQuote.BtoB_Sales_one__c <= 50000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '2.0');
                    }
                }
                
                if(syncedQuote.BtoB_Sales_one__c > 50000 && syncedQuote.BtoB_Sales_one__c <= 100000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '1.6');
                    }
                }
                
                if(syncedQuote.BtoB_Sales_one__c > 100000 && syncedQuote.BtoB_Sales_one__c <= 300000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '1.2');
                    }
                }
                
                if(syncedQuote.BtoB_Sales_one__c > 300000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '0.8');
                    }
                }
                
                
            } else{
                
                if(syncedQuote.Purchases_Invoices_one__c <= 3000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '3.0');
                    }
                }
                
                if(syncedQuote.Purchases_Invoices_one__c > 3000 && syncedQuote.Purchases_Invoices_one__c <= 10000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '3.0');
                    }
                }
                
                if(syncedQuote.Purchases_Invoices_one__c > 10000 && syncedQuote.Purchases_Invoices_one__c <= 25000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '2.2');
                    }
                }
                
                if(syncedQuote.Purchases_Invoices_one__c > 25000 && syncedQuote.Purchases_Invoices_one__c <= 50000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '2.0');
                    }
                }
                
                if(syncedQuote.Purchases_Invoices_one__c > 50000 && syncedQuote.Purchases_Invoices_one__c <= 100000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '1.6');
                    }
                }
                
                if(syncedQuote.Purchases_Invoices_one__c > 100000 && syncedQuote.Purchases_Invoices_one__c <= 300000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '1.2');
                    }
                }
                
                if(syncedQuote.Purchases_Invoices_one__c > 300000){
                    if( label.GST_Dynamic_Pricing_Content.contains('Rs.XX') ){
                        dynamicClause = label.GST_Dynamic_Pricing_Content.replace('Rs.XX', '0.8');
                    }
                }
            }
        }
        
        System.debug('dynamicClause: '+dynamicClause);
        /** End: Bibhu  **/
        accountName='';
        Matcher m = Pattern.compile('(\\w+|\\W+)').matcher(syncedQuote.Opportunity.Legal_Entity_Name_Of_The_Client__c);
        while (m.find()) accountName += m.group().capitalize();
        System.debug('accountName '+accountName);
        adminEmail = syncedQuote.Opportunity.Master_admin_Email__c;
        domainName = syncedQuote.Opportunity.Company_Domain_Name__c;
        billingAddress = syncedQuote.Opportunity.Billing_Address__c; //syncedQuote.BillingAddress.getStreet()+', '+syncedQuote.BillingAddress.getCity()+', '+syncedQuote.BillingAddress.getState()+', '+syncedQuote.BillingAddress.getPostalCode()+', '+syncedQuote.BillingAddress.getCountry();
        shippingAddress = syncedQuote.Opportunity.Shipping_Address__c; //syncedQuote.ShippingStreet+', '+syncedQuote.ShippingCity+', '+syncedQuote.ShippingState+', '+syncedQuote.ShippingPostalCode+', '+syncedQuote.ShippingCountry;
        vatNumber = syncedQuote.Opportunity.vat_number_gcc__c;
        crNumber = syncedQuote.Opportunity.cr_number_gcc__c;
        if(mapOfBillingFreqForSubscriptionFee.containsKey(syncedQuote.Opportunity.Billing_F__c)){
            billingFrequencyForSubscriptionFee = mapOfBillingFreqForSubscriptionFee.get(syncedQuote.Opportunity.Billing_F__c);
        }else{
            billingFrequencyForSubscriptionFee = syncedQuote.Opportunity.Billing_F__c;
        }
        
        billingFrequencyForIntegrationProds = syncedQuote.Opportunity.Billing_Frequency_for_Integration_Prods__c;
        if(syncedQuote.Opportunity.Billing_Frequency_for_Integration_Prods__c == 'Custom'){
            billingFrequencyForIntegrationProds = syncedQuote.Opportunity.Custom_Billing_Freq_for_Integration_Prod__c;
        }
        
        System.debug('billingAddress '+billingAddress);
        System.debug('shippingAddress '+shippingAddress);
        System.debug('syncedQuote.Opportunity.Period_Start_date__c '+syncedQuote.Opportunity.Period_Start_date__c);
        System.debug('syncedQuote.Opportunity.Period_End_date__c '+syncedQuote.Opportunity.Period_End_date__c);
        
        List<QuoteLineItem> listOfQLI = [ SELECT Id, Total_Price__c, period_start_date__c, period_end_date__c, 
                                         product2id, Product2.name, Product2.OrderForm_Product_Name__c,
                                         Product2.Billing_Type__c, Product2.Product_category__c, Product2.Family,
                                         Product2.Overuse__c, Overuse__c,Product2.Product_Line__c,
                                         Annual_ARR__c,Term_Months__c, Quantity, toLabel(type_Of_Integration__c),
                                         UnitPrice, Sale_Price__c,ListPrice, List_Price_Order_Form__c,
                                         Quote.OpportunityId,
                                         Quote.Opportunity.ERP_Family__c, Quote.Opportunity.Owner.ManagerId,
                                         Quote.Total_Integration_SLA__c,  
                                         SLA_In_Weeks__c, Quote.ERP__c,
                                         Add_On_Prices__c, Add_On_Discounted_Price__c, Actual_Unit_Price__c, Actual_Sell_Price__c,
                                         Description, GCC_Einv_Integration__c, MAX_ITC_Combo_Price__c, Product2.Module__c,
                                         Quote.Is_MAX_ITC_Combo_Required__c,Product2.ProductCode,
                                         ID_Integration_Type__c,BtoB_Sales_one__c,No_of_PAN_one__c,No_of_User_ID_one__c,
                                         ERP__c,BtoC_Sales_one__c,Purchases_Invoices_one__c,
                                         No_of_GSTIN_verification_credits__c,No_MM2A_2B_usage_GSTIN_month__c,
                                         No_of_IRNs__c,No_of_Vendors_one__c,No_of_EWBs__c,No_of_expected_B2C_invoices_for_QR_code__c,
                                         No_of_invoice_formats__c,No_of_recons__c,No_of_airline_invoices_annual_one__c,
                                         No_of_TANs__c,Number_of_Deductees_per_Quarter_24Q_26__c,Number_of_Deduction_Transactions_per_Qua__c,
                                         Platform__c, No_of_Total_invoices__c,Product2.Corrected_Module_for_metering__c,
                                         No_of_GSTIN_one__c,No_of_Bank_verification_API__c,No_of_API_calls_permissible__c,Duration__c,
                                         No_of_MCA_Company_details_API__c,No_of_MSME_API__c,No_of_PAN_verification_API__c,No_of_TDS_206_sync_API__c,
                                         Total_B2B_PR_B2C_invoice__c, Digital_Signing_Utility_for_TDS_Cert_del__c,No_of_VAT__c, No_of_Pages_in_Invoices__c,
                                         No_of_PAN_to_GSTIN_APIs__c, No_of_PAN_verification_detailed_APIs__c,No_of_line_items_TCS_TDS_RL_Plans__c,
                                         No_of_line_items_in_Form_26AS_Annum__c,No_of_reconciliation_runs_p_a__c,Purpose_of_Usage__c, No_of_GST_GSP_API_calls_permissible__c,
                                         Calculate_based_on_List_Price_OF__c,Applicable_fees_as_per_payment_terms__c,
                                         No_Of_PAN_OCR_APIs__c ,No_Of_GST_ADVANCED_APIs__c ,No_Of_GST_ADVANCED_PLUS_APIs__c, Quote.Opportunity.Billing_F__c,
                                         Quote.Opportunity.Billing_Frequency__c, Quote.Opportunity.Billing_Frequency_for_Integration_Prods__c,
                                         No_of_templates__c ,No_of_fields_to_be_edited_per_template__c,Total_no_of_Pages_in_Purchase_Invoices__c ,
                                         GSTIN_Level_Recon__c , PAN_Level_Recon__c, EPFO_ESTABLISHMENT_ADVANCED_API_credit__c , EPFO_ESTABLISHMENT_BASIC_API_credit__c ,
                                         EPFO_ESTABLISHMENT_DETAILED_API_credit__c , Invoice_Date_1__c , Invoice_Date_2__c , Invoice_Date_3__c , Invoice_Date_4__c,
                                         No_of_EPFO_UAN_FETCH_APIs__c,No_of_EPFO_UAN_AUTH_APIs__c,No_of_EPFO_UAN_DETAILS_APIs__c,No_of_GSTIN_FILING_CREDITS_APIs__c,No_of_GSTIN_SEARCH_BY_NAME_APIs__c,
                                         No_of_CUSTOMER_IDENTITY_FETCH_APIs__c,No_of_DRIVING_LICENSE_DETAILED_APIs__c,No_of_VEHICLE_REGISTRATION_DETAILED_API__c, 
                                         No_of_COMPANY_DETAILS_FULL_APIs__c, No_of_GST_ANALYTICS_AUTH_APIs__c, No_of_GST_ANALYTICS_DETAILS_APIs__c, No_of_GST_OWNERSHIP_VERIFICATION_APIs__c,
                                         No_of_HSN_SAC_SEARCH_APIs__c, No_of_OTP_VERIFICATION_PHONE_APIs__c, No_of_UNREGISTERED_GST_APPLICANT_VERIFI__c, No_of_UPI_QR_GENERATION_APIs__c, 
                                         No_of_UPI_VERIFICATION_APIs__c, No_of_AADHAAR_VERIFICATION_DIGILOCKER_A__c, No_of_COMPANY_FINANCIALS_DETAILS_APIs__c, No_of_EINVOICE_IRN_DETAILS_APIs__c, 
                                         No_of_EINVOICE_IRN_LIST_APIs__c, No_of_EINVOICE_QR_EXTRACTION_APIs__c, No_of_FSSAI_VERIFICATION_APIs__c, No_of_GSP_APIs__c, No_of_INGESTION_APIs__c, 
                                         No_of_INTERNATIONAL_BUSINESS_NAME_SEARC__c, No_of_LEGAL_NAME_PAN_FETCH_APIs__c, No_of_OTP_VERIFICATION_EMAIL_APIs__c, 
                                         No_of_PAN_SIMPLE_DETAILS_APIs_No_of_FS__c, No_of_PAN_VERIFICATION_BASIC_APIs__c, No_of_PAN_Verification_with_Father_Name__c, 
                                         No_of_PAN_verification_API_QR__c, No_of_UNREGISTERED_GST_APPLICANT_DETAIL__c, No_of_UPI_FETCH_APIs__c 
                                         FROM QuoteLineItem WHERE QuoteId=:syncedQuote.Id Order by period_start_date__c ];
        List<ARRroductsWrapper> listOfArrWrap = new List<ARRroductsWrapper>();
        List<OTPProductsWrapper> listOfOtpWrap = new List<OTPProductsWrapper>();
        listOfScopeWrap = new List<ScopeWrapper>();
        quoteLineItemAndIntegrationScope = new Map<QuoteLineItem, Set<Integration_Scope_Add_On__c>>();
        Integer ARR_SL_NO = 1;
        Integer OTP_SL_NO = 1;
        Integer OTPSLNO = 1;
        Decimal ARR_Total = 0;
        Decimal OTP_Total = 0;
        Decimal ARR_Total_OF = 0;
        Set<String> setOfProductFamilies = new Set<String>{productConstants.PRODUCT_FAMILY_ASP_GSP, productConstants.PRODUCT_FAMIL_EINV, productConstants.PRODUCT_FAMILY_E_Way_Bill};
            Boolean integrationTypeIncluded = false;
        listQLI = listOfQLI;
        Map<String,String> gcctoiOfNameMap = new Map<String,String>();
        List<String> toiList = new List<String>();
        for(
            Gcc_Toi_Ofname__mdt thisRec : Gcc_Toi_Ofname__mdt.getAll()?.values()
        ){
            gcctoiOfNameMap.put(thisRec.Type_of_integration__c, thisRec.OrderFormName__c);
        }
        
        for(QuoteLineItem eachQLI : listOfQLI){
            String productName = eachQLI.Product2.name;
            String orderFormName = '';
            eachQLI.List_Price_Order_Form__c = eachQLI.List_Price_Order_Form__c == NULL ? eachQLI.UnitPrice : eachQLI.List_Price_Order_Form__c;
            system.debug('***Check Name '+productName);
            if(eachQLI.Product2.Billing_Type__c == ProductConstants.PRODUCT_BILLING_TYPE_ARR){
                System.debug('eachQLI.Annual_ARR__c '+eachQLI.Annual_ARR__c);
                if((eachQLI.Product2.ProductCode == 'MITC-ULTIMATE' || eachQLI.Product2.ProductCode == 'MITC-PREMIUM' || eachQLI.Product2.ProductCode == 'MITC-ULTIMATE-NOPAY') && eachQLI.Quote.Is_MAX_ITC_Combo_Required__c && eachQLI.MAX_ITC_Combo_Price__c != NULL){
                    ARR_Total += eachQLI.MAX_ITC_Combo_Price__c;
                    listOfArrWrap.add(new ARRroductsWrapper(ARR_SL_NO, eachQLI.Product2.name, eachQLI.Product2.OrderForm_Product_Name__c, eachQLI.MAX_ITC_Combo_Price__c.round(System.RoundingMode.CEILING), Integer.valueOf(eachQLI.Annual_ARR__c),eachQLI.period_start_date__c,eachQLI.period_end_date__c,eachQLI.Term_Months__c, (Integer)eachQLI.Quantity,eachQLI.product2.productCode,eachQLI.Description, eachQli.Invoice_Date_1__c,eachQli.Invoice_Date_2__c, eachQli.Invoice_Date_3__c, eachQli.Invoice_Date_4__c,eachQLI.UnitPrice.round(System.RoundingMode.CEILING),eachQLI.List_Price_Order_Form__c.round(System.RoundingMode.CEILING),eachQLI.Calculate_based_on_List_Price_OF__c, eachQLI.Quote.Opportunity.Billing_F__c));                    
                }else if(eachQLI.Product2.ProductCode == 'EINV_INTL'){
                    if(Opportunity.Country_of_Origin__c  != NULL){
                        orderFormName = 'ClearTax '+syncedQuote.Opportunity.Country_of_Origin__c +' E-Invoicing';
                    }else{
                        orderFormName = eachQLI.Product2.OrderForm_Product_Name__c;
                    }
                    ARR_Total += eachQLI.Total_Price__c;
                    listOfArrWrap.add(new ARRroductsWrapper(ARR_SL_NO, eachQLI.Product2.name, orderFormName, eachQLI.Total_Price__c.round(System.RoundingMode.CEILING), Integer.valueOf(eachQLI.Annual_ARR__c),eachQLI.period_start_date__c,eachQLI.period_end_date__c,eachQLI.Term_Months__c, (Integer)eachQLI.Quantity,eachQLI.product2.productCode,eachQLI.Description, eachQli.Invoice_Date_1__c, eachQli.Invoice_Date_2__c, eachQli.Invoice_Date_3__c, eachQli.Invoice_Date_4__c,eachQLI.UnitPrice.round(System.RoundingMode.CEILING),eachQLI.List_Price_Order_Form__c.round(System.RoundingMode.CEILING),eachQLI.Calculate_based_on_List_Price_OF__c, eachQLI.Quote.Opportunity.Billing_F__c ));
                }else{
                    ARR_Total += eachQLI.Total_Price__c;
                    
                    listOfArrWrap.add(new ARRroductsWrapper(ARR_SL_NO, eachQLI.Product2.name, eachQLI.Product2.OrderForm_Product_Name__c, eachQLI.Total_Price__c.round(System.RoundingMode.CEILING), Integer.valueOf(eachQLI.Annual_ARR__c),eachQLI.period_start_date__c,eachQLI.period_end_date__c,eachQLI.Term_Months__c, (Integer)eachQLI.Quantity,eachQLI.product2.productCode,eachQLI.Description, eachQli.Invoice_Date_1__c, eachQli.Invoice_Date_2__c, eachQli.Invoice_Date_3__c, eachQli.Invoice_Date_4__c,eachQLI.UnitPrice.round(System.RoundingMode.CEILING),eachQLI.List_Price_Order_Form__c.round(System.RoundingMode.CEILING),eachQLI.Calculate_based_on_List_Price_OF__c, eachQLI.Quote.Opportunity.Billing_F__c));
                }
                if(eachQLI.List_Price_Order_Form__c > eachQLI.UnitPrice){
                    ARR_Total_OF += eachQLI.List_Price_Order_Form__c;
                }else{
                    if(eachQLI.Calculate_based_on_List_Price_OF__c){
                        ARR_Total_OF += eachQLI.List_Price_Order_Form__c;
                    }else{
                        ARR_Total_OF += eachQLI.UnitPrice;
                    }
                }
                
                ARR_SL_NO ++;
            }else if(eachQLI.Product2.Billing_Type__c == ProductConstants.PRODUCT_BILLING_TYPE_OTP && !(productName.endsWithIgnoreCase('Pass Through')) ){
                if(eachQLI.Quote.Is_MAX_ITC_Combo_Required__c && eachQLI.Product2.Module__c == 'Max ITC' && eachQLI.Product2.Product_Category__c == 'Integration' && eachQLI.MAX_ITC_Combo_Price__c != NULL){
                    OTP_Total += eachQLI.MAX_ITC_Combo_Price__c;
                    listOfOtpWrap.add(new OTPProductsWrapper(OTP_SL_NO, eachQLI.product2.Name, eachQLI.Product2.OrderForm_Product_Name__c, eachQLI.Description, eachQLI.GCC_Einv_Integration__c, eachQLI.MAX_ITC_Combo_Price__c.round(System.RoundingMode.CEILING),(Integer)eachQLI.Quantity, eachQLI.type_Of_Integration__c,eachQLI.Period_Start_date__c ,eachQLI.Period_End_date__c,eachQLI.product2.productCode,eachQli.Invoice_Date_1__c, eachQli.Invoice_Date_2__c, eachQli.Invoice_Date_3__c , eachQli.Invoice_Date_4__c, (Integer)eachQLI.Duration__c ,eachQLI.Quote.Opportunity.Billing_Frequency_for_Integration_Prods__c ,(Integer)eachQLI.MAX_ITC_Combo_Price__c.round(System.RoundingMode.CEILING)/(Integer)eachQLI.Quantity) );
                }else{
                    
                    OTP_Total += eachQLI.Total_Price__c;
                    if(eachQLI.Product2.ProductCode == 'ID_INTGR'){
                        listOfOtpWrap.add(new OTPProductsWrapper(OTP_SL_NO, eachQLI.product2.Name, eachQLI.Product2.OrderForm_Product_Name__c, eachQLI.Description, eachQLI.GCC_Einv_Integration__c, eachQLI.Total_Price__c.round(System.RoundingMode.CEILING),(Integer)eachQLI.Quantity, eachQLI.ID_Integration_Type__c,eachQLI.Period_Start_date__c ,eachQLI.Period_End_date__c,eachQLI.product2.productCode, eachQli.Invoice_Date_1__c, eachQli.Invoice_Date_2__c, eachQli.Invoice_Date_3__c, eachQli.Invoice_Date_4__c, (Integer)eachQLI.Duration__c,eachQLI.Quote.Opportunity.Billing_Frequency_for_Integration_Prods__c ,(Integer)eachQLI.Total_Price__c.round(System.RoundingMode.CEILING)/(Integer)eachQLI.Quantity) );
                    }
                    else if(eachQLI.Product2.Corrected_Module_for_metering__c  == 'ID'){
                        listOfOtpWrap.add(new OTPProductsWrapper(OTP_SL_NO, eachQLI.product2.Name, eachQLI.Product2.OrderForm_Product_Name__c, eachQLI.Description, eachQLI.GCC_Einv_Integration__c, eachQLI.Total_Price__c.round(System.RoundingMode.CEILING),(Integer)eachQLI.Quantity, eachQLI.ID_Integration_Type__c ,eachQLI.Period_Start_date__c ,eachQLI.Period_End_date__c,eachQLI.product2.productCode, eachQli.Invoice_Date_1__c, eachQli.Invoice_Date_2__c, eachQli.Invoice_Date_3__c, eachQli.Invoice_Date_4__c, (Integer)eachQLI.Duration__c,eachQLI.Quote.Opportunity.Billing_Frequency_for_Integration_Prods__c ,(Integer)eachQLI.Total_Price__c.round(System.RoundingMode.CEILING)/(Integer)eachQLI.Quantity ));
                    }else if(eachQLI.Product2.ProductCode == 'EINV_INTL_SYS_ASSMNT'){
                        if(Opportunity.Country_of_Origin__c  != NULL){
                            orderFormName = 'Clear '+syncedQuote.Opportunity.Country_of_Origin__c  +' E-invoicing System Assessment';
                        }else{
                            orderFormName = eachQLI.Product2.OrderForm_Product_Name__c;
                        }
                        
                        listOfOtpWrap.add(new OTPProductsWrapper(OTP_SL_NO, eachQLI.product2.Name, orderFormName, eachQLI.Description, eachQLI.GCC_Einv_Integration__c, eachQLI.Total_Price__c.round(System.RoundingMode.CEILING),(Integer)eachQLI.Quantity, eachQLI.type_Of_Integration__c,eachQLI.Period_Start_date__c ,eachQLI.Period_End_date__c,eachQLI.product2.productCode, eachQli.Invoice_Date_1__c, eachQli.Invoice_Date_2__c, eachQli.Invoice_Date_3__c, eachQli.Invoice_Date_4__c,(Integer)eachQLI.Duration__c,eachQLI.Quote.Opportunity.Billing_Frequency_for_Integration_Prods__c ,(Integer)eachQLI.Total_Price__c.round(System.RoundingMode.CEILING)/(Integer)eachQLI.Quantity));
                    }
                    else if(eachQLI.Product2.ProductCode == 'EINV_INTL_ONB'){
                        if(Opportunity.Country_of_Origin__c  != NULL){
                            orderFormName = 'ClearTax '+syncedQuote.Opportunity.Country_of_Origin__c  +' E-invoicing Onboarding';
                        }else{
                            orderFormName = eachQLI.Product2.OrderForm_Product_Name__c;
                        }
                        listOfOtpWrap.add(new OTPProductsWrapper(OTP_SL_NO, eachQLI.product2.Name, orderFormName, eachQLI.Description, eachQLI.GCC_Einv_Integration__c, eachQLI.Total_Price__c.round(System.RoundingMode.CEILING),(Integer)eachQLI.Quantity, eachQLI.type_Of_Integration__c,eachQLI.Period_Start_date__c ,eachQLI.Period_End_date__c,eachQLI.product2.productCode, eachQli.Invoice_Date_1__c, eachQli.Invoice_Date_2__c, eachQli.Invoice_Date_3__c, eachQli.Invoice_Date_4__c, (Integer)eachQLI.Duration__c,eachQLI.Quote.Opportunity.Billing_Frequency_for_Integration_Prods__c ,(Integer)eachQLI.Total_Price__c.round(System.RoundingMode.CEILING)/(Integer)eachQLI.Quantity));
                    }
                    else if(eachQLI.Product2.ProductCode == 'EINV_INTL_INTG'){
                        String gccOfName;
                        
                        if(eachQLI.Type_of_integration__c != NULL){
                            toiList =  eachQLI.Type_of_integration__c.split(';');
                        }
                        
                        if(!toiList.isEmpty() && gcctoiOfNameMap.containskey(toiList[0])){
                            gccOfName = gcctoiOfNameMap.get(toiList[0]);
                        }
                        
                        if(Opportunity.Country_of_Origin__c  != NULL){
                            if(gccOfName != NULL){
                                orderFormName = 'ClearTax '+syncedQuote.Opportunity.Country_of_Origin__c  +' E-invoice Integration' + ' - '+gccOfName;
                            }else{
                                orderFormName = 'ClearTax '+syncedQuote.Opportunity.Country_of_Origin__c  +' E-invoice Integration';
                            }  
                        }else{
                            orderFormName = eachQLI.Product2.OrderForm_Product_Name__c;
                        }
                        listOfOtpWrap.add(new OTPProductsWrapper(OTP_SL_NO, eachQLI.product2.Name, orderFormName, eachQLI.Description, eachQLI.GCC_Einv_Integration__c, eachQLI.Total_Price__c.round(System.RoundingMode.CEILING),(Integer)eachQLI.Quantity, eachQLI.type_Of_Integration__c,eachQLI.Period_Start_date__c ,eachQLI.Period_End_date__c,eachQLI.product2.productCode,eachQli.Invoice_Date_1__c, eachQli.Invoice_Date_2__c, eachQli.Invoice_Date_3__c, eachQli.Invoice_Date_4__c, (Integer)eachQLI.Duration__c,eachQLI.Quote.Opportunity.Billing_Frequency_for_Integration_Prods__c ,(Integer)eachQLI.Total_Price__c.round(System.RoundingMode.CEILING)/(Integer)eachQLI.Quantity));
                    }
                    else{
                        listOfOtpWrap.add(new OTPProductsWrapper(OTP_SL_NO, eachQLI.product2.Name, eachQLI.Product2.OrderForm_Product_Name__c, eachQLI.Description, eachQLI.GCC_Einv_Integration__c, eachQLI.Total_Price__c.round(System.RoundingMode.CEILING),(Integer)eachQLI.Quantity, eachQLI.type_Of_Integration__c,eachQLI.Period_Start_date__c ,eachQLI.Period_End_date__c,eachQLI.product2.productCode,eachQli.Invoice_Date_1__c, eachQli.Invoice_Date_2__c, eachQli.Invoice_Date_3__c, eachQli.Invoice_Date_4__c, (Integer)eachQLI.Duration__c,eachQLI.Quote.Opportunity.Billing_Frequency_for_Integration_Prods__c ,(Integer)eachQLI.Total_Price__c.round(System.RoundingMode.CEILING)/(Integer)eachQLI.Quantity));
                    }
                }
                OTP_SL_NO ++;
            }
            /** BIBHU : Integration Scope VF Change **/
            if( eachQLI.Product2.Billing_Type__c == ProductConstants.PRODUCT_BILLING_TYPE_OTP ){
                
                String temKey = eachQLI.Quote.ERP__c + eachQLI.Product2.OrderForm_Product_Name__c;
                system.debug('I am checkingb this issue: '+temKey);
                if(erpSKUIntegrationScopeMap.containsKey(temKey)){
                    quoteLineItemAndIntegrationScope.put(eachQLI, erpSKUIntegrationScopeMap.get(temKey));
                    quoteLineItemTotalSLA2.put(eachQLI,quoteLineItemTotalSLA.get(temKey));
                } 
                system.debug('Test$@#$#2'+quoteLineItemAndIntegrationScope) ;               
                
                Map<QuoteLineItem, Set<Integration_Scope_Add_On__c>> temp = new Map<QuoteLineItem, Set<Integration_Scope_Add_On__c>>();
                temp.put(eachQLI,NULL);
                QLIAddOnMap.put(eachQLI.Product2.OrderForm_Product_Name__c,temp);
                listOfScopeWrap.add(new ScopeWrapper('Standard Scope',eachQLI.Total_Price__c.round(System.RoundingMode.CEILING),0));
            }   
            if(eachQLI.ID_Integration_Type__c != NULL){
                if(eachQLI.ID_Integration_Type__c == 'API Based Integration'){
                    displayAPIBasedIntegration = TRUE;
                }
                if(eachQLI.ID_Integration_Type__c == 'Middleware based Integration'){
                    displayMiddlewareBasedIntegration = TRUE;
                }
                if(eachQLI.ID_Integration_Type__c == 'SFTP based Integration'){
                    displaySFTPBasedIntegration = TRUE;
                }
            }
            
        }
        if(quoteLineItemAndIntegrationScope.keySet().size() > 0)
            showAddOnTable = TRUE;
        /** 
* Set<eachQLI.Product2.OrderForm_Product_Name__c> xyz
* Map<eachQLI.Product2.OrderForm_Product_Name__c, QLI> xyz.value == QLI
* Map<eachAddOn.Product_SKU__c, Set<eachAddOn>> xyz.value == Set<eachAddOn>
* Map<QLI, Set<AddOn>> : eachQLI.Product2.OrderForm_Product_Name__c == eachAddOn.Product_SKU__c abc.keySet 
**/
        for(Integration_Scope_Add_On__c  eachAddOn : listAddOn){
            
            listOfScopeWrap.add(new ScopeWrapper(eachAddOn.Module__c,eachAddOn.Discount_Rate__c.round(System.RoundingMode.CEILING),(Integer)eachAddOn.Estimated_Effort_In_Days__c));
            if(QLIAddOnMap.ContainsKey(eachAddOn.Product_SKU__c )){
                Set<Integration_Scope_Add_On__c> tempSet = new Set<Integration_Scope_Add_On__c>();
                if(QLIAddOnMap.get(eachAddOn.Product_SKU__c).get(new List<QuoteLineItem>((QLIAddOnMap.get(eachAddOn.Product_SKU__c)).keySet())[0]) == NULL){
                    tempSet.add(eachAddOn);
                }
                else{
                    tempSet.addAll(QLIAddOnMap.get(eachAddOn.Product_SKU__c).get(new List<QuoteLineItem>((QLIAddOnMap.get(eachAddOn.Product_SKU__c)).keySet())[0])); 
                    tempSet.add(eachAddOn);
                }
                QLIAddOnMap.get(eachAddOn.Product_SKU__c).put(new List<QuoteLineItem>((QLIAddOnMap.get(eachAddOn.Product_SKU__c)).keySet())[0],tempSet);
            }
        }
        QLIAddOnMapUse = QLIAddOnMap.Values();
        for(Map<QuoteLineItem, Set<Integration_Scope_Add_On__c>> mapIns :QLIAddOnMapUse){
            system.debug('%$%$'+String.ValueOf(mapIns.Values()));
            if(String.ValueOf(mapIns.Values()) != '({})')
            {
                showAddOnTable = TRUE;
            }
        }
        //Scope- By Kartikeya
        for(ScopeWrapper SWIns : listOfScopeWrap){
            //totalPrice =totalPrice+ (SWIns.price == NULL ? 0 :  SWIns.price);
            totalSLA = totalSLA+ (SWIns.SLA == NULL ? 0 :  SWIns.SLA);
        }
        //Scope- By Kartikeya
        List<ContactDetails> listOfConWrapper = new List<ContactDetails>();
        if(
            syncedQuote.Opportunity.Country_of_Origin__c != 'India' 	&&
            syncedQuote.Opportunity.Country_of_Origin__c != 'N/A'		&&
            syncedQuote.Opportunity.Country_of_Origin__c != NULL        
            
        ){
            if(syncedQuote.Opportunity.Bus_POC__r.name != null){
                
                listOfConWrapper.add(new ContactDetails('Business POC', syncedQuote.Opportunity.Bus_POC__r.name, syncedQuote.Opportunity.Bus_POC__r.Designation__c,  syncedQuote.Opportunity.Bus_POC__r.email, syncedQuote.Opportunity.Bus_POC__r.ISD__c, syncedQuote.Opportunity.Bus_POC__r.phone));
            }else{
                listOfConWrapper.add(new ContactDetails('Business POC', NULL, NULL,  NULL, NULL, NULL));
            }
            if(syncedQuote.Opportunity.Finance_POC_contact__r.name != null){
                listOfConWrapper.add(new ContactDetails('Finance POC for Invoice Processing', syncedQuote.Opportunity.Finance_POC_contact__r.name, syncedQuote.Opportunity.Finance_POC_contact__r.Designation__c,  syncedQuote.Opportunity.Finance_POC_contact__r.email, syncedQuote.Opportunity.Finance_POC_contact__r.ISD__c, syncedQuote.Opportunity.Finance_POC_contact__r.phone));
            }else{
                listOfConWrapper.add(new ContactDetails('Finance POC for Invoice Processing', NULL, NULL,  NULL, NULL, NULL));
            }
            if(syncedQuote.Opportunity.Tax_Head_contact__r.name != null){
                listOfConWrapper.add(new ContactDetails('Tax Head', syncedQuote.Opportunity.Tax_Head_contact__r.name, syncedQuote.Opportunity.Tax_Head_contact__r.Designation__c,  syncedQuote.Opportunity.Tax_Head_contact__r.email, syncedQuote.Opportunity.Tax_Head_contact__r.ISD__c, syncedQuote.Opportunity.Tax_Head_contact__r.phone));
            }else{
                listOfConWrapper.add(new ContactDetails('Tax Head', NULL, NULL,  NULL, NULL, NULL));
            }
            if(syncedQuote.Opportunity.Finance_Head_contact__r.name != null){
                listOfConWrapper.add(new ContactDetails('Finance Head', syncedQuote.Opportunity.Finance_Head_contact__r.name, syncedQuote.Opportunity.Finance_Head_contact__r.Designation__c,  syncedQuote.Opportunity.Finance_Head_contact__r.email, syncedQuote.Opportunity.Finance_Head_contact__r.ISD__c, syncedQuote.Opportunity.Finance_Head_contact__r.phone));
            }else{
                listOfConWrapper.add(new ContactDetails('Finance Head', NULL, NULL,  NULL, NULL, NULL));
            }
            if(syncedQuote.Opportunity.IT_Head_contact__r.name != null){
                listOfConWrapper.add(new ContactDetails('IT POC', syncedQuote.Opportunity.IT_Head_contact__r.name, syncedQuote.Opportunity.IT_Head_contact__r.Designation__c,  syncedQuote.Opportunity.IT_Head_contact__r.email, syncedQuote.Opportunity.IT_Head_contact__r.ISD__c, syncedQuote.Opportunity.IT_Head_contact__r.phone));
            }else{
                listOfConWrapper.add(new ContactDetails('IT POC', NULL, NULL,  NULL, NULL, NULL));
            }
            
            if(syncedQuote.Opportunity.Company_Secretary__r.name != null){
                listOfConWrapper.add(new ContactDetails('Company Secretary', syncedQuote.Opportunity.Company_Secretary__r.name, syncedQuote.Opportunity.Company_Secretary__r.Designation__c,  syncedQuote.Opportunity.Company_Secretary__r.email, syncedQuote.Opportunity.Company_Secretary__r.ISD__c, syncedQuote.Opportunity.Company_Secretary__r.phone));
            }
            
        }else{
            if(syncedQuote.Opportunity.Bus_POC__r.name != null){ //&& syncedQuote.Opportunity.Business_POC_Designation__c != null && syncedQuote.Opportunity.Business_POC_Email__c != null
                listOfConWrapper.add(new ContactDetails('Business POC', syncedQuote.Opportunity.Bus_POC__r.name, syncedQuote.Opportunity.Bus_POC__r.Designation__c,  syncedQuote.Opportunity.Bus_POC__r.email, syncedQuote.Opportunity.Bus_POC__r.ISD__c, syncedQuote.Opportunity.Bus_POC__r.phone));
            }
            if(syncedQuote.Opportunity.Finance_POC_contact__r.name != null){
                listOfConWrapper.add(new ContactDetails('Finance POC for Invoice Processing', syncedQuote.Opportunity.Finance_POC_contact__r.name, syncedQuote.Opportunity.Finance_POC_contact__r.Designation__c,  syncedQuote.Opportunity.Finance_POC_contact__r.email, syncedQuote.Opportunity.Finance_POC_contact__r.ISD__c, syncedQuote.Opportunity.Finance_POC_contact__r.phone));
            }
            if(syncedQuote.Opportunity.Tax_Head_contact__r.name != null){
                listOfConWrapper.add(new ContactDetails('Tax Head', syncedQuote.Opportunity.Tax_Head_contact__r.name, syncedQuote.Opportunity.Tax_Head_contact__r.Designation__c,  syncedQuote.Opportunity.Tax_Head_contact__r.email, syncedQuote.Opportunity.Tax_Head_contact__r.ISD__c, syncedQuote.Opportunity.Tax_Head_contact__r.phone));
            }
            if(syncedQuote.Opportunity.Finance_Head_contact__r.name != null){
                listOfConWrapper.add(new ContactDetails('Finance Head', syncedQuote.Opportunity.Finance_Head_contact__r.name, syncedQuote.Opportunity.Finance_Head_contact__r.Designation__c,  syncedQuote.Opportunity.Finance_Head_contact__r.email, syncedQuote.Opportunity.Finance_Head_contact__r.ISD__c, syncedQuote.Opportunity.Finance_Head_contact__r.phone));
            }
            if(syncedQuote.Opportunity.IT_Head_contact__r.name != null){
                listOfConWrapper.add(new ContactDetails('IT POC', syncedQuote.Opportunity.IT_Head_contact__r.name, syncedQuote.Opportunity.IT_Head_contact__r.Designation__c,  syncedQuote.Opportunity.IT_Head_contact__r.email, syncedQuote.Opportunity.IT_Head_contact__r.ISD__c, syncedQuote.Opportunity.IT_Head_contact__r.phone));
            }
            if(syncedQuote.Opportunity.Company_Secretary__r.name != null){
                listOfConWrapper.add(new ContactDetails('Company Secretary', syncedQuote.Opportunity.Company_Secretary__r.name, syncedQuote.Opportunity.Company_Secretary__r.Designation__c,  syncedQuote.Opportunity.Company_Secretary__r.email, syncedQuote.Opportunity.Company_Secretary__r.ISD__c, syncedQuote.Opportunity.Company_Secretary__r.phone));
            }
        }
        
        
        
        listOfContactWrapper = listOfConWrapper;
        ARRTotalListPrice = ARR_Total_OF.round(System.RoundingMode.CEILING);
        ARRProdTotal = ARR_Total.round(System.RoundingMode.CEILING);
        OTPProdsTotal = OTP_Total.round(System.RoundingMode.CEILING);
        ARRProdDiscountedPriceOF= ARR_Total_OF.round(System.RoundingMode.CEILING)-ARR_Total.round(System.RoundingMode.CEILING);
        if(ARR_Total_OF > ARR_Total){
            ARRProdDiscountOF = (((ARR_Total_OF -ARR_Total)/ARR_Total_OF)*100).round(System.RoundingMode.CEILING);
        }
        
        listOfARRProdsWrapper = listOfArrWrap;
        listOfOTPProdsWrapper = listOfOtpWrap;
        
        
        
        System.debug('@ARRProdDiscountedPriceOF'+ARRProdDiscountedPriceOF);
        System.debug('@ARRProdDiscountOF'+ARRProdDiscountOF);
        System.debug('@ARR_Total_OF'+ARR_Total_OF);
        
        System.debug('listOfARRProdsWrapper '+listOfARRProdsWrapper);
        System.debug('listOfOTPProdsWrapper '+listOfOTPProdsWrapper);
        //New Flow 
        List<Product_ScopeOfService_Junction__c> prodSOSjunction = [ SELECT Id, Product__c, Scope_Of_Service_VFs__c, 
                                                                    Order__c, Integration_Add_On__c, SOS_URL__c 
                                                                    FROM Product_ScopeOfService_Junction__c];
        SOS=0;
        Set<Id> setOfOpportunityProducts = new Set<Id>();
        Set<String> setOfVFPagesToDisplay = new Set<String>();
        Set<String> setOfVFPagesSOS = new Set<String>();
        List<Double> listOfOrders = new List<Double>();
        Set<String> qliTypeOfIntegrationSet = new Set<String>();
        Map<Id,Set<String>> ptoductToTypeOfIntegrationsMap = new Map<Id,Set<String>>();
        
        Set<String> qliProductSet = new Set<String>();
        Set<String> einvIntegSet = new Set<String>();
        Map<String, Product_Line_Consulting_Cost__mdt> consultingCostMap = new Map<String, Product_Line_Consulting_Cost__mdt>();
        Map<String, Product_Line_Consulting_Cost__mdt> productCostMap = new Map<String, Product_Line_Consulting_Cost__mdt>();
        Map<Double,Product_ScopeOfService_Junction__c> mapOfOrderToProdSOSJunction = new Map<Double,Product_ScopeOfService_Junction__c>();
        productCostList = new  List<Product_Line_Consulting_Cost__mdt> ();
        List<String> productNames = new List<String>();
        List<String> hours = new List<String>();
        
        list<OpportunityLineItem> listOfOLI = [SELECT id, name, Product2Id, Product2.Name, Opportunity.ARR_Product_Total_Amount__c,
                                               Product2.Corrected_Module_for_metering__c, Product2.Product_category__c,
                                               Product2.billing_type__c,product2.Family, Product2.Product_Line__c,
                                               Opportunity.recordType.DeveloperName, Opportunity.Refund_policy_Applicable__c,
                                               Opportunity.Display_SOS_in_OF__c, Related_QLI__r.Type_of_Integration__c,
                                               Opportunity.Single_ARR__c , Product2.ProductCode, Opportunity.ClearTax_Billing_Entity__c
                                               FROM OpportunityLineItem WHERE OpportunityId=:opptyId];
        
        List<Quote> quoteDetails = [SELECT Id, Type_of_Integration__c,X10_hr_consultation_clause__c, 
                                    recordType.DeveloperName, Opportunity.recordType.DeveloperName,
                                    Type_of_Compliance_service__c, Opportunity.Country_of_Origin__c,
                                    Opportunity.ClearTax_Billing_Entity__c 
                                    FROM quote WHERE OpportunityId=:opptyId AND IsSyncing=true LIMIT 1];
        
        for(
            Product_Line_Consulting_Cost__mdt thisRec : Product_Line_Consulting_Cost__mdt.getAll()?.values()
        ){
            consultingCostMap.put(thisRec.Product_Line__c, thisRec);
        }
        System.debug('#consultingCostMap'+consultingCostMap);
        
        
        // bhaveshjindal :: START :: TYPE OF INTEGRATION
        
        for(QuoteLineItem thisQli : [SELECT Id, Type_Of_Integration__c, Product2.Id,product2.product_category__c,
                                     Product2.OrderForm_Product_Name__c,GCC_Einv_Integration__c, Product2.Product_Line__c
                                     FROM QuoteLineItem 
                                     WHERE QuoteId = :syncedQuote.Id])
        {
            System.debug('@PL'+thisQli.Product2.Product_Line__c);
            if(thisQli.product2.product_category__c.equals('MS')){
                assistASLimitaionCheck = TRUE;
            }
            //System.debug('thisQli.Type_Of_Integration__c.split'+thisQli.Type_Of_Integration__c.split(';'));
            if(thisQli.Type_of_Integration__c != NULL){
                qliTypeOfIntegrationSet.addAll(thisQli.Type_Of_Integration__c.split(';'));
                ptoductToTypeOfIntegrationsMap.put(thisQli.Product2.Id, new Set<String>(thisQli.Type_Of_Integration__c.split(';')));
            } else{
                ptoductToTypeOfIntegrationsMap.put(thisQli.Product2.Id,null);
            }
            
            //Added by Ashwin -- GCC GOOGLE TRANSLATION TERMS && GCC Einv Integration check
            qliProductSet.add(thisQli.Product2.OrderForm_Product_Name__c);
            
            if(consultingCostMap.containsKey(thisQli.Product2.Product_Line__c) && 
               thisQli.Product2.Product_category__c == 'Integration' 	       &&
               thisQli.Type_Of_Integration__c.contains('API- Only by Customer')){
                   productCostList.add(consultingCostMap.get(thisQli.Product2.Product_Line__c));
                   productNames.add(thisQli.Product2.OrderForm_Product_Name__c);
                   hours.add(consultingCostMap.get(thisQli.Product2.Product_Line__c).Consulting_Hours__c);
               }
        }
        
        productNameConsulting = String.join(productNames, ', ');
        consultingHours = String.join(hours, ', ');
        System.debug('@productCostList :: '+productCostList);
        System.debug('qliTypeOfIntegrationSet :: '+qliTypeOfIntegrationSet);
        System.debug('ptoductToTypeOfIntegrationsMap :: '+ptoductToTypeOfIntegrationsMap);
        
        if(qliTypeOfIntegrationSet.size() == 1 && qliTypeOfIntegrationSet.contains('API- Only by Customer')){
            onlyContainsOnlyByCustomer = TRUE;
        }
        if(qliTypeOfIntegrationSet.size()>0 && qliTypeOfIntegrationSet.contains('API- Only by Customer')){
            containsOnlyByCustomer = TRUE;
        }
        //Added by Ashwin -- GCC GOOGLE TRANSLATION TERMS && GCC Einv Integration check
        displayDevelopmentTerms = FALSE;
        displayConsultationTerms = FALSE;
        
        System.debug('qliProductSet --> '+qliProductSet);
        System.debug('einvIntegSet -->'+einvIntegSet);
        if(qliProductSet.contains('E-Invoicing Google Translation API')){
            displayGoogleTerms = TRUE;
        }
        
        for(String thisToi : qliTypeOfIntegrationSet){
            if(gcctoiOfNameMap.containsKey(thisToi) && gcctoiOfNameMap.get(thisToi) != NULL){
                einvIntegSet.add(gcctoiOfNameMap.get(thisToi));
            }
        }
        
        if(einvIntegSet.contains('Integration Development')){
            displayDevelopmentTerms = TRUE;
        }
        if(einvIntegSet.contains('Integration Consultation')){
            displayConsultationTerms = TRUE;
        }
        
        //END -- GCC GOOGLE TRANSLATION TERMS && GCC Einv Integration check
        
        System.debug('listOfOLI size '+listOfOLI.size());
        System.debug('listOfOLI '+listOfOLI);
        containsIntegrationProduct = FALSE;
        prodCheckMaxItc = FALSE;
        prodLineIsGST = FALSE;
        prodLineIsEinv = FALSE;
        prodLineIsMax = FALSE;
        displayBillingFreqInteg = FALSE;
        displayBillingFreqSubs = FALSE;
        displayBillingFreqOtp = FALSE;
        displayRefundPolicy = FALSE;
        displaySOS = FALSE;
        containsMsProduct = FALSE;
        containsKycApi = FALSE;
        isSingleArr = FALSE;
        
        
        for(OpportunityLineItem oli : listOfOLI){
            setOfOpportunityProducts.add(oli.Product2Id);
            if(oli.Product2.Product_category__c == 'Integration' && 
               !containsIntegrationProduct ){
                   containsIntegrationProduct = true;
               }
            if(label.Product_clause_visibility_OF.split(',').contains(oli.Product2.Family) && oli.Product2.Billing_Type__c.equals('ARR')){
                prodCheck = true;
            }
            
            /** GST Product Family Check: Bibhu **/
            if(label.Product_Family_Check.split(',').contains(oli.Product2.Family) && oli.Product2.Billing_Type__c.equals('ARR')){
                prodCheck_GST = true;
            }
            if(oli.Product2.Corrected_Module_for_metering__c != 'Max ITC'){
                prodCheckMaxItc = TRUE;
            }
            if(oli.Product2.Name == 'Custom Print Template'){
                prodCheck_CustomTemplateOTP = TRUE;
            }
            
            // RecordType -> BillingEntity
            if(oli.Opportunity.ClearTax_Billing_Entity__c =='Xpedize' && oli.Product2.Product_Line__c == 'Invoice Discounting' && oli.Product2.Product_category__c == 'SaaS'){  
                netNewIDInvoiceDiscountingSAASCheck = TRUE;
            }
            if(oli.Opportunity.ClearTax_Billing_Entity__c =='Xpedize' && oli.Product2.Product_Line__c == 'Invoice Discounting' && oli.Product2.Product_category__c == 'Transactional'){
                netNewIDInvoiceDiscountingTransactionalCheck = TRUE;
            }
            if(oli.Product2.Product_Line__c == 'Invoice Discounting'){
                netNewIDInvoiceDiscountingSKUCheck = TRUE;
            }
            if(oli.Product2.Family == 'Credit'){
                productFamilyCreditCheck = TRUE;
            }
            
            if(oli.Opportunity.ClearTax_Billing_Entity__c =='Xpedize' &&  oli.Product2.ProductCode == 'ID_TENOR'){
                netNewIDTenorExtension = TRUE;
            }   
            
            
            /** Annexure : Render based on product line **/
            if(oli.Product2.Product_category__c == 'Integration' &&
               oli.Product2.Product_Line__c == 'GST' && 
               !prodLineIsGST && 
               oli.Related_QLI__r.Type_of_Integration__c != NULL &&
               !(oli.Related_QLI__r.Type_of_Integration__c.Contains('FTP/SFTP - Only by customer') ||
                 oli.Related_QLI__r.Type_of_Integration__c.Contains('API- Only by Customer'))){
                     prodLineIsGST = TRUE;
                     System.debug('@prodLineIsGST'+oli.Product2.Product_category__c);
                 }
            if(oli.Product2.Product_category__c == 'Integration' 
               && oli.Product2.Product_Line__c == 'E-invoicing & E-Way Bill' && 
               !prodLineIsEinv&& 
               oli.Related_QLI__r.Type_of_Integration__c != NULL &&
               !(oli.Related_QLI__r.Type_of_Integration__c.Contains('FTP/SFTP - Only by customer') ||
                 oli.Related_QLI__r.Type_of_Integration__c.Contains('API- Only by Customer'))){
                     prodLineIsEinv = TRUE;
                     System.debug('@prodLineIsEinv'+oli.Product2.Product_category__c);
                 }
            if(oli.Product2.Product_category__c == 'Integration' && 
               oli.Product2.Product_Line__c == 'Max' && 
               !prodLineIsMax && 
               oli.Related_QLI__r.Type_of_Integration__c != NULL &&
               !(oli.Related_QLI__r.Type_of_Integration__c.Contains('FTP/SFTP - Only by customer') ||
                 oli.Related_QLI__r.Type_of_Integration__c.Contains('API- Only by Customer'))){
                     prodLineIsMax = TRUE;
                     System.debug('@prodLineIsMax'+oli.Product2.Product_category__c);
                 }
            
            /** Billing Frequency : Render based on Product_category__c & Billing_Type__c **/
            if(oli.Product2.Billing_Type__c.equals('OTP')){
                if(oli.Product2.Product_category__c == 'Integration'){
                    displayBillingFreqInteg = TRUE;    
                }else{
                    displayBillingFreqOtp = TRUE;   
                }
            }else{
                displayBillingFreqSubs = TRUE;
            }
            /** Display Refund Policy in Special Terms **/
            
            if(oli.Opportunity.Refund_policy_Applicable__c  == TRUE  && 
               oli.Opportunity.ARR_Product_Total_Amount__c     >  Integer.valueOf(System.label.Opportunity_ARR_Amount_Refund_Policy)  &&
               oli.Product2.Product_category__c == 'SaaS'	&&
               !displayRefundPolicy)
            {
                displayRefundPolicy = TRUE;
            }
            
            if((oli.Product2.Product_category__c == 'MS' || oli.Product2.Product_category__c == 'TDS - MS') && oli.Product2.Billing_Type__c == 'ARR'){
                containsMsProduct = TRUE;
            }
            
            if(oli.Product2.Product_Line__c == 'KYC APIs'){
                containsKycApi = TRUE;
            }
            
            if(oli.Opportunity.Single_ARR__c == TRUE && !isSingleArr){
                isSingleArr = TRUE;
            }
            
            if(oli.Opportunity.Display_SOS_in_OF__c == TRUE){
                displaySOS = TRUE;
            }
            
            
        }
        
        for(Quote thisQuote : quoteDetails){
            If(!String.IsEmpty(thisQuote.Type_of_Integration__c))
                if(thisQuote.Type_of_Integration__c.Contains('FTP/SFTP - Only by customer')){
                    qouteCheckAPIOnlyByCustomer = TRUE;
                }else if(thisQuote.Type_of_Integration__c.Contains('API- Only by Customer')){
                    qouteCheckAPIOnlyByCustomer = TRUE;
                }
            
            if(thisQuote.X10_hr_consultation_clause__c == TRUE){
                tenHrIntegrationClause = TRUE;
            }
            if(
                thisQuote.Opportunity.Country_of_Origin__c != 'India' 	&&
                thisQuote.Opportunity.Country_of_Origin__c != 'N/A'		&&
                thisQuote.Opportunity.Country_of_Origin__c != NULL
            ){
                gccCheck = TRUE;
            }
            if(thisQuote.Opportunity.ClearTax_Billing_Entity__c =='Xpedize'){
                netNewIDCheck = TRUE;
            }
            if(thisQuote.Opportunity.recordType.DeveloperName == 'Net_New'){
                netNewCheck = TRUE;
            }
            if(thisQuote.Opportunity.recordType.DeveloperName == 'Cross_Sell_Upsell'){
                crossSellCheck = TRUE;
            }
            
            
            Type_of_Compliance_service = thisQuote.Type_of_Compliance_service__c;
        }
        System.debug('setOfOpportunityProducts size '+setOfOpportunityProducts.size());
        System.debug('setOfOpportunityProducts '+setOfOpportunityProducts);
        //Get all records of the Junction object based on the products added to the opportunity. 
        List<Product_ScopeOfService_Junction__c> listOfProdSOSJunction 
            = [ SELECT Id, Name, Scope_Of_Service_VFs__c, Type_of_Integration__c, Product__c, Integration_Add_On__c,
               Product__r.Name, order__c, Scope_Of_Service_VFs__r.Name,SOS_URL__c,product__r.ProductCode
               
               FROM Product_ScopeOfService_Junction__c WHERE
               
               ( Product__c = NULL ) OR 
               ( 
                   Product__c IN :setOfOpportunityProducts AND 
                   ( 
                       Type_of_Integration__c = NULL OR 
                       Type_of_Integration__c IN :qliTypeOfIntegrationSet OR 
                       Integration_Add_On__c != NULL
                   ) 
               )
               
               ORDER BY order__c ASC ];
        
        System.debug('listOfProdSOSJunction size '+listOfProdSOSJunction.size());
        System.debug('listOfProdSOSJunction '+listOfProdSOSJunction);
        //popuate all unique VF pages as of map<order,junctionObjRecord>
        for(Product_ScopeOfService_Junction__c jn : listOfProdSOSJunction){
            System.debug('Order '+ jn.Order__c+'    '+'Product Name '+jn.Product__r.Name);
            system.debug(ptoductToTypeOfIntegrationsMap.keySet()+'%^^%'+jn.Product__c);
            system.debug('TEst123%%^'+ptoductToTypeOfIntegrationsMap.keySet().contains(jn.Product__c));
            //system.debug('TEst123%%^'+ptoductToTypeOfIntegrationsMap.get(jn.Product__c).contains(jn.Type_of_Integration__c));
            System.debug('#jn'+jn.Order__c);
            // Added for URL Link
            if(!String.isBlank(jn.SOS_URL__c)){
                prodCodeURLMap.put(jn.product__r.ProductCode,jn.SOS_URL__c);
            }
            // Added for URL Link
            if(String.isBlank(jn.SOS_URL__c) || (!String.isBlank(jn.SOS_URL__c) && displaySOS)){
                if(gccCheck){
                    prodCodeURLMap.put(jn.product__r.ProductCode,'NULL');
                }
                
                if(
                    ptoductToTypeOfIntegrationsMap.keySet().contains(jn.Product__c) && 
                    ptoductToTypeOfIntegrationsMap.get(jn.Product__c) == NULL
                ){
                    if(jn.Scope_Of_Service_VFs__r.Name != NULL){
                        setOfVFPagesSOS.add(jn.Scope_Of_Service_VFs__r.Name);
                        mapOfOrderToProdSOSJunction.put(jn.Order__c, jn);
                        listOfOrders.add(jn.Order__c);
                        System.debug('#listOfOrders'+listOfOrders);
                    }  
                } else if(
                    ptoductToTypeOfIntegrationsMap.keySet().contains(jn.Product__c) && 
                    ptoductToTypeOfIntegrationsMap.get(jn.Product__c)?.contains(jn.Type_of_Integration__c)
                ){
                    system.debug('$#$#2325');
                    system.debug(ptoductToTypeOfIntegrationsMap.keySet()+'%^^%2'+jn.Product__c);
                    if(jn.Scope_Of_Service_VFs__r.Name != NULL){
                        setOfVFPagesSOS.add(jn.Scope_Of_Service_VFs__r.Name);
                        mapOfOrderToProdSOSJunction.put(jn.Order__c, jn);
                        listOfOrders.add(jn.Order__c);
                    }
                }
                
                if(
                    ptoductToTypeOfIntegrationsMap.keySet().contains(jn.Product__c) &&
                    jn.Integration_Add_On__c != NULL
                ){
                    system.debug(jn.Product__c+' :::::: I am adding Add On VF Page: '+jn.Scope_Of_Service_VFs__r.Name);
                    system.debug('jn.Order__c: '+jn.Order__c);
                    mapOfOrderToProdSOSJunction.put(jn.Order__c, jn);
                    listOfOrders.add(jn.Order__c);
                }
                
                
                Double orderNo = jn.Order__c;
                if((jn.Product__c== NULL || jn.Type_of_Integration__c == NULL) && (!(listOfOrders.contains(orderNo)))){
                    mapOfOrderToProdSOSJunction.put(jn.Order__c, jn);
                    listOfOrders.add(jn.Order__c);    
                }
                
            }
            
        }
        
        
        listOfOrders.sort();
        System.debug('listOfOrders '+listOfOrders);
        
        
        listOfOrdersToDisplay=listOfOrders;
        mapOfOrderToProdSOSJunctionToDisplay=mapOfOrderToProdSOSJunction;
        
        for(Double thisOne : listOfOrdersToDisplay){
            system.debug('OOO listOfOrders: '+thisOne+' ::: Page ::  '+mapOfOrderToProdSOSJunctionToDisplay.get(thisOne));
        }
        
        
        nextNumber=0;
        nextpage = mapOfOrderToProdSOSJunctionToDisplay.get(listOfOrdersToDisplay.get(nextNumber)).Scope_Of_Service_VFs__r.Name;
        System.debug('nextpage '+nextpage);
        System.debug('1. nextNumber '+nextpage);
        nextNumber++;
        System.debug('2. nextNumber '+nextpage);
        
        
    }
    
    @AuraEnabled
    public Static String saveOrderFormToOpportunity(String oppId){
        Id conDoc;
        Map<String, E_Sign_Config__c> eSignConfig = E_Sign_Config__c.getAll();
        System.debug('*oppId '+oppId);
        /*Testing purpose
oppId = '0061y000003WvkCAAS';*/
        try{
            if(oppId != null && oppId != ''){
                PageReference ref = new PageReference('/apex/generateOrderForm?id=' + oppId);
                Opportunity oppty = [SELECT id, Name, ESign_Category__c,RecordType.DeveloperName , Legal_Entity_Name_Of_The_Client__c 
                                     FROM Opportunity WHERE id=:oppId LIMIT 1];
                String legalEntityNameOfClient ='';
                Matcher m = Pattern.compile('(\\w+|\\W+)').matcher(oppty.Legal_Entity_Name_Of_The_Client__c);
                while (m.find()) legalEntityNameOfClient += m.group().capitalize();
                System.debug('*legalEntityNameOfClient '+legalEntityNameOfClient);
                
                //Create Content Version
                ContentVersion cont = new ContentVersion();
                cont.Title = 'Order Form - '+legalEntityNameOfClient;
                cont.PathOnClient = 'Order Form - '+legalEntityNameOfClient+'.pdf'; //+Datetime.now().getTime()
                if(Test.isRunningTest()) { 
                    cont.VersionData = blob.valueOf('Unit.Test');
                } else {
                    cont.VersionData = ref.getContentAsPdf();
                }
                
                cont.Type_of_document__c = eSignConfig.get('Type_Of_Doc').Value__c;
                cont.System_Generated__c = true;
                //cont.ESign_Status__c = oppty.ESign_Category__c == 'E-Sign'? 'Request for ESign' : ''; 
                insert cont;
                System.debug('*cont '+cont);
                //Get the ContentDoc Id
                conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cont.Id].ContentDocumentId;
                System.debug('*conDoc '+conDoc);
                //Create ContentDocumentLink  to link the file with the Entity(Opportunity)
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                conDocLink.LinkedEntityId = oppId; 
                conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
                conDocLink.shareType = 'V';
                insert conDocLink;
                System.debug('*conDocLink '+conDocLink);
            }else{
                return 'Opportunity Id is Null';
            }
        }catch(Exception e){
            System.debug('Exception MSG '+e.getMessage());
        }
        System.debug('*conDoc '+conDoc);
        return conDoc;
    }
    
    /*Added by Raksha*/
    public class ARRroductsWrapper{
        public Integer SLNO{get;set;}
        public String services{get;set;}
        public String orderFormProductName{get;set;}
        public Long feeForTheTerm{get;set;}
        public Integer AnnualARR{get;set;}
        public Date periodStartDate{get;set;}
        public Date periodEndDate{get;set;}
        public String termMonths{get;set;} 
        public Long unitPrice{get;set;}
        public Integer quantity{get;set;}
        public String productCode{get;set;}
        public long   calcRefund{get;set;}
        public String description{get;set;}
        public Long listPrice{get;set;}
        public Long orderFormListPrice{get;set;}
        public boolean calcBasedOnOrderFormPrice{get;set;}
        public Date invoiceDate{get;set;}
        public String billingFrequency{get;set;}
        public long calcARRInvoiceAmt{get;set;}
        Public integer applicableFee{get;set;}
        Public Date    invoiceDate1{get;set;}
        Public Date    invoiceDate2{get;set;}
        Public Date    invoiceDate3{get;set;}
        Public Date    invoiceDate4{get;set;}
        public Date firstInvoiceDate{get;set;}
        public Date secondInvoiceDate{get;set;}
        public Date thirdInvoiceDate{get;set;}
        public Date fourthInvoiceDate{get;set;}
        
        
        public ARRroductsWrapper(Integer SLNO, String services, String orderFormProductName, Long feeForTheTerm, Integer AnnualARR, Date periodStartDate,Date periodEndDate,String termMonths, Integer quantity, String productCode, String description,  Date firstInvoiceDate, Date secondInvoiceDate, Date thirdInvoiceDate, Date fourthInvoiceDate ,Long listPrice, Long orderFormListPrice, Boolean calcBasedOnOrderFormPrice, String billingFrequency){
            this.SLNO = SLNO;
            this.services = services;
            this.orderFormProductName = orderFormProductName;
            this.feeForTheTerm = feeForTheTerm;
            this.AnnualARR = AnnualARR;
            this.periodStartDate = periodStartDate;
            this.periodEndDate = periodEndDate;
            this.termMonths = termMonths;
            this.quantity = quantity;
            this.unitPrice = feeForTheTerm/quantity;
            this.productCode = productCode;
            this.description = description;
            this.listPrice = listPrice;
            this.orderFormListPrice = orderFormListPrice;
            this.calcBasedOnOrderFormPrice = calcBasedOnOrderFormPrice;
            this.billingFrequency = billingFrequency;
            this.firstInvoiceDate = firstInvoiceDate;
            this.secondInvoiceDate = secondInvoiceDate;
            this.thirdInvoiceDate = thirdInvoiceDate;
            this.fourthInvoiceDate = fourthInvoiceDate;
            
            
            
            this.calcRefund = (this.feeForTheTerm/Integer.valueOf(this.termMonths))*(Integer.valueOf(this.termMonths) - 1); //Refund Policy in special terms
            
            if(!prodCodeURLMap.containsKey(this.productCode)){
                prodCodeURLMap.put(this.productCode, 'NULL');
            }
            if(this.billingFrequency != NULL){
                if(this.billingFrequency == 'Quarterly'){
                    invoiceDate1 = this.periodStartDate;
                    invoiceDate2 = this.periodStartDate.addMonths(3);
                    invoiceDate3 = this.periodStartDate.addMonths(6);
                    invoiceDate4 = this.periodStartDate.addMonths(9);
                    applicableFee = 25;
                }else if(this.billingFrequency == 'Annually'){
                    invoiceDate1 = this.periodStartDate;
                    secondInvoiceDate = NULL;
                    thirdInvoiceDate  = NULL;
                    fourthInvoiceDate = NULL;
                    
                    applicableFee = 100;
                }else if(this.billingFrequency == 'Half-yearly in advance'){
                    invoiceDate1 = this.periodStartDate;
                    invoiceDate2 = this.periodStartDate.addMonths(6);
                    thirdInvoiceDate  = NULL;
                    fourthInvoiceDate = NULL;
                    
                    applicableFee = 50;
                }else if(this.billingFrequency == '100% payment upon signing Order Form'){
                    invoiceDate1 = this.periodStartDate;
                    secondInvoiceDate = NULL;
                    thirdInvoiceDate  = NULL;
                    fourthInvoiceDate = NULL;
                    
                    applicableFee = 100;
                }else if(this.billingFrequency == '50% on signing of this order form, 50% post UAT completion'){
                    invoiceDate1 = this.periodStartDate;
                    invoiceDate2 = this.periodStartDate.addMonths(2);
                    thirdInvoiceDate  = NULL;
                    fourthInvoiceDate = NULL;
                    
                    applicableFee = 50;
                }
                System.debug('@applicableFee'+applicableFee );
                System.debug('@calcARRInvoiceAmt'+this.calcARRInvoiceAmt );
                if(applicableFee != NULL){
                    this.calcARRInvoiceAmt = (this.feeForTheTerm * applicableFee/100); 
                }
                
                System.debug('@calcARRInvoiceAmt'+this.calcARRInvoiceAmt );
                
                totalInvoiceAmount +=  this.feeForTheTerm;
                
                
            }
            
            
        }
    }
    public class OTPProductsWrapper{
        public Integer SLNO{get;set;}
        public String services{get;set;}
        public String orderFormProductName{get;set;}
        public String description{get;set;}
        public String gccEinvInteg{get;set;}
        public Long fee{get;set;}
        public Long unitPrice{get;set;}
        public Integer quantity{get;set;}
        public String typeOfIntegration{get;set;}
        public Date PSD{get;set;}
        public Date PED{get;set;}
        public Integer Duration{get;set;}
        public String productCode{get;set;}
        public String billingFrequency{get;set;}
        public Long calcOTPInvoiceAmt{get;set;}
        Public integer applicableFee{get;set;}
        Public Date    invoiceDate1{get;set;}
        Public Date    invoiceDate2{get;set;}
        Public Date    invoiceDate3{get;set;}
        Public Date    invoiceDate4{get;set;}
        public Date firstInvoiceDate{get;set;}
        public Date secondInvoiceDate{get;set;}
        public Date thirdInvoiceDate{get;set;}
        public Date fourthInvoiceDate{get;set;}
        
        public OTPProductsWrapper(Integer SLNO, String services, String orderFormProductName, String description, String gccEinvInteg, Long fee, Integer quantity, String typeOfIntegration, Date PSD, Date PED, String productCode, Date firstInvoiceDate, Date secondInvoiceDate, Date thirdInvoiceDate, Date fourthInvoiceDate , Integer Duration,String billingFrequency, Integer unitPrice ){
            this.SLNO = SLNO;
            this.services = services;
            this.orderFormProductName = orderFormProductName;
            this.description = description;
            this.gccEinvInteg = gccEinvInteg;
            this.fee = fee;
            this.quantity = quantity;
            this.typeOfIntegration = typeOfIntegration;
            this.PSD = PSD;
            this.PED = PED;
            this.productCode = productCode;
            this.Duration = Duration;
            this.unitPrice = unitPrice;
            this.billingFrequency = billingFrequency;
            this.firstInvoiceDate = firstInvoiceDate;
            this.secondInvoiceDate = secondInvoiceDate;
            this.thirdInvoiceDate = thirdInvoiceDate;
            this.fourthInvoiceDate = fourthInvoiceDate;
            
            
            if(!prodCodeURLMap.containsKey(this.productCode)){
                prodCodeURLMap.put(this.productCode, 'NULL');
            }
            
            if(this.billingFrequency != NULL){
                
                if(this.billingFrequency == '100% upfront basis Integration Project start date'){
                    invoiceDate1 = this.PSD;
                    secondInvoiceDate = NULL;
                    thirdInvoiceDate  = NULL;
                    fourthInvoiceDate = NULL;
                    
                    applicableFee = 100;
                }else if(this.billingFrequency == '50% Upfront basis Integration start date & 50% upon UAT Handover' ||
                         this.billingFrequency == '50% upfront basis Integration Project start date & 50% upon Go live' ||
                         this.billingFrequency == '50% upon signing the Order Form and 50% post UAT completion'){
                             invoiceDate1 = this.PSD;
                             invoiceDate2 = this.PED;
                             thirdInvoiceDate  = NULL;
                             fourthInvoiceDate = NULL;
                             applicableFee = 50;
                         }
                
                
                if(applicableFee != NULL){
                    this.calcOTPInvoiceAmt = (this.fee * applicableFee/100);
                }
                System.debug('@calcOTPInvoiceAmt'+this.calcOTPInvoiceAmt );
                totalInvoiceAmount +=  this.fee;
            }
            
        }
    }
    //Scope- By Kartikeya
    public class ScopeWrapper{
        public String scope{get;set;}
        public Long price{get;set;}
        public Integer SLA{get;set;}
        
        public ScopeWrapper(String scope, Long price, Integer SLA){
            this.scope = scope;
            this.price = price;
            this.SLA = SLA;
        }
    }
    //Scope- By Kartikeya
    public class ContactDetails{
        public String function{get;set;}
        public String name{get;set;}
        public String designation{get;set;}
        public String email{get;set;}
        public string isd{get;set;}
        public String contactNumber{get;set;}
        public ContactDetails(String function, String name, String designation, String email, String isd, String contactNumber){
            this.function = function;
            this.name = name;
            this.designation = designation;
            this.isd = isd;
            this.contactNumber = contactNumber;
            this.email = email;
            boolean flag = email != NULL && email.length()>20 ? true:false;
            integer start=0,ends=20;
            string temp='';
            while(flag){
                system.debug(' Start '+ Start +' Ends '+ends);   
                temp+=email.substring(start, ends)+' ';
                ends+=20;
                if(email.length()>ends){
                    start+=20;
                }else{
                    start+=20;
                    temp+=email.substring(start);
                    break;
                }
            }
            if(flag){
                this.email = temp;
            }
        }
    }
    
    
}