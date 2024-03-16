/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-27-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_UpsertSalesContract_SAP {
    public static Map<String, String> 				stateNameToStateCodeMap = new Map<String, String>();
    public static List<Logger__c> 					updateSnag				= new List<Logger__c>();
    public static List<Additional_GSTIN__c> 		gstinsToUpdate			= new List<Additional_GSTIN__c>();
    public static MAP<String, Map<String, Object>>  SF_SAP_PICKLIST_VALUE_MAPPING = new MAP<String, Map<String, Object>>();
    
    //@future(Callout=TRUE)
    public static void processAssetsInserted(set <Id> assetIds){
        Map<String, List<Additional_GSTIN__c>> GSTIN_No_AdditionalGSTINRecordsMap = new Map<String, List<Additional_GSTIN__c>>();
        List<Additional_GSTIN__c> addtionalGSTINsToProcess 	= [SELECT Id, Name, Quote_Line_Item__c, Quote__c, Billing_PAN__c, 
                                                               Asset__c, Asset__r.Product2.ProductCode, 
                                                               Asset__r.PurchaseDate,
                                                               Asset__r.UsageEndDate,
                                                               Asset__r.Billing_Type__c,
                                                               Asset__r.Product2.Product_Category__c,
                                                               
                                                               Opportunity__c, Opportunity__r.Account.Name,Opportunity__r.ClearTax_Billing_Entity__c, //added by murali 
                                                               
                                                               Opportunity__r.RecordTypeId, Opportunity__r.RecordType.Name, Opportunity__r.RecordType.DeveloperName, 
                                                               Opportunity__r.PO_number__c, Quote__r.QuoteNumber, Opportunity__r.Synced_Quote_Number__c,
                                                               
                                                               Opportunity__r.Budget_Approver__c, Opportunity__r.Budget_Approver__r.Phone, Opportunity__r.Budget_Approver__r.Email,
                                                               Opportunity__r.Payment_Term__c, Opportunity__r.PO_Required__c, Opportunity__r.TAN__c,Opportunity__r.If_SEZ__c,
                                                               
                                                               Opportunity__r.Bus_POC__c, 
                                                               Opportunity__r.Bus_POC__r.Phone, 
                                                               Opportunity__r.Bus_POC__r.Email, 
                                                               Opportunity__r.Bus_POC__r.Name, 
                                                               Opportunity__r.Bus_POC__r.Department, 
                                                               
                                                               Opportunity__r.Champion__c, Opportunity__r.Champion__r.Phone, Opportunity__r.Champion__r.Email,  
                                                               Opportunity__r.Company_Secretary__c, Opportunity__r.Company_Secretary__r.Phone, Opportunity__r.Company_Secretary__r.Email,  
                                                               Opportunity__r.E_Sign_Customer_Info__c, Opportunity__r.E_Sign_Customer_Info__r.Phone, Opportunity__r.E_Sign_Customer_Info__r.Email,
                                                               Opportunity__r.Finance_Head_contact__c, Opportunity__r.Finance_Head_contact__r.Phone, Opportunity__r.Finance_Head_contact__r.Email, 
                                                               Opportunity__r.Finance_POC_contact__c, Opportunity__r.Finance_POC_contact__r.Phone, Opportunity__r.Finance_POC_contact__r.Email, 
                                                               Opportunity__r.IT_Head_contact__c, Opportunity__r.IT_Head_contact__r.Phone, Opportunity__r.IT_Head_contact__r.Email, 
                                                               Opportunity__r.Primary_Contact__c, Opportunity__r.Primary_Contact__r.Phone, Opportunity__r.Primary_Contact__r.Email, 
                                                               Opportunity__r.Primary_Partner_Contact__c, Opportunity__r.Primary_Partner_Contact__r.Phone, Opportunity__r.Primary_Partner_Contact__r.Email, 
                                                               Opportunity__r.Prospecting_meeting_POC__c, Opportunity__r.Prospecting_meeting_POC__r.Phone, Opportunity__r.Prospecting_meeting_POC__r.Email, 
                                                               Opportunity__r.SecondaryContact2__c, Opportunity__r.SecondaryContact2__r.Phone, Opportunity__r.SecondaryContact2__r.Email, 
                                                               Opportunity__r.Tax_Head_contact__c, Opportunity__r.Tax_Head_contact__r.Phone, Opportunity__r.Tax_Head_contact__r.Email, 
                                                               Opportunity__r.Who_is_the_competitor_champion__c, Opportunity__r.Who_is_the_competitor_champion__r.Phone, Opportunity__r.Who_is_the_competitor_champion__r.Email,
                                                               Opportunity__r.Special_Terms__c, Opportunity__r.Billing_F__c, Opportunity__r.Billing_Frequency_for_Integration_Prods__c, Opportunity__r.Billing_Frequency__c, 
                                                               Opportunity__r.MS_Billing_Frequency__c, Opportunity__r.Custom_Billing_Freq_for_Integration_Prod__c,
                                                               
                                                               BP_Card_Code__c, 
                                                               Address__c, Address_Line_2__c, City__c, Pincode__c, State__c, 
                                                               Amount__c, Name_Of_The_Customer__c, OTP_Integration__c, TAN__c, SEZ_Yes_No__c,
                                                               Add_on_split__c, Upsell_Top_up__c, CIN__c, TIN_Number__c, CR_Number__c, Place_of_supply__c, 
                                                               PO_Required__c, PO_Amount__c, PO_Number__c, Update_Company_Information__c
                                                               
                                                               FROM Additional_GSTIN__c WHERE 
                                                               Asset__r.Opportunity__r.Is_Auto_Renewal_Enabled__c = FALSE AND Asset__c IN :assetIds];
        
        if(addtionalGSTINsToProcess.size() > 0){
            for(State_State_Code_SAP_Mapping__mdt mdt : State_State_Code_SAP_Mapping__mdt.getAll().values()){
                stateNameToStateCodeMap.put(mdt.State_Name_GST__c, mdt.State_Code_SAP__c);
            }
            for(SAP_SF_Picklist_Fields_Value_Mapping__mdt mdt : [SELECT Id, SAP_Field_Name__c, SF_SAP_Values_Mapping_JSON__c FROM SAP_SF_Picklist_Fields_Value_Mapping__mdt]){
                Map<String, Object> fieldValuesMap = (Map<String,Object>)JSON.deserializeUntyped(mdt.SF_SAP_Values_Mapping_JSON__c);
                SF_SAP_PICKLIST_VALUE_MAPPING.put(mdt.SAP_Field_Name__c, fieldValuesMap);
            }
            for(Additional_GSTIN__c gstin : addtionalGSTINsToProcess){
                
                if(!GSTIN_No_AdditionalGSTINRecordsMap.containsKey(gstin.Name + ';' + gstin.Opportunity__c)){
                    GSTIN_No_AdditionalGSTINRecordsMap.put(gstin.Name + ';' + gstin.Opportunity__c, new List<Additional_GSTIN__c>{gstin});    
                } else{
                    GSTIN_No_AdditionalGSTINRecordsMap.get(gstin.Name + ';' + gstin.Opportunity__c).add(gstin);    
                }
                
                //upsertSalesContract(gstin);
            }
            if(!GSTIN_No_AdditionalGSTINRecordsMap.keySet().isEmpty()){
                for( String gstinNoAndOppId : GSTIN_No_AdditionalGSTINRecordsMap.keySet()){
                    String gstinNo = gstinNoAndOppId.split(';')[0];
                    upsertSalesContract(gstinNo, GSTIN_No_AdditionalGSTINRecordsMap.get(gstinNoAndOppId));
                }    
            }
            
            if(gstinsToUpdate.size() > 0){
                RecursiveTriggerHandler.isFirstTimeGSTIN = FALSE;
                update gstinsToUpdate;
                RecursiveTriggerHandler.isFirstTimeGSTIN = TRUE;
            }
            
            if(updateSnag.size() > 0){
                if(RecursiveTriggerHandler.runCreateLogger){
                	insert updateSnag;    
                }
            }
        }
    }
    
    public static void upsertSalesContract(String gstin_No, List<Additional_GSTIN__c> gstinList){
        
        Additional_GSTIN__c gstin = gstinList[0];
        
        //added by Murali
        String billingEntity = gstin.Opportunity__r.ClearTax_Billing_Entity__c;
        
        if(gstin.BP_Card_Code__c != NULL){
            CTX_SalesContractRequestWrapper salesContract = new CTX_SalesContractRequestWrapper();
            
            salesContract.U_CardCode 	= gstin.BP_Card_Code__c;
            salesContract.U_CardName	= gstin.Name_Of_The_Customer__c;
            salesContract.U_OpporType 	= (String)SF_SAP_PICKLIST_VALUE_MAPPING.get('U_OpporType').get(gstin.Opportunity__r.RecordType.Name);
            salesContract.U_NumAtCard	= gstin.Opportunity__r.PO_Required__c != NULL ? (gstin.Opportunity__r.PO_Required__c?.toLowerCase() == 'yes' ? gstin.Opportunity__r.PO_number__c : gstin.Opportunity__r.Synced_Quote_Number__c ) : gstin.Opportunity__r.Synced_Quote_Number__c ;
            //salesContract.Remark		= gstin.Opportunity__r.Special_Terms__c != NULL ? 'Special Terms : recheck and post the SC' : NULL;
            
            if( gstin.Opportunity__r.PO_Required__c != NULL && gstin.Opportunity__r.Special_Terms__c != NULL ){
                if(gstin.Opportunity__r.PO_Required__c?.toLowerCase() == 'yes'){
                    salesContract.Remark		= 'Special Terms : recheck and post the SC, PO Required';
                } else {
                    if(gstin.Opportunity__r.PO_Required__c?.toLowerCase() == 'no'){
                        salesContract.Remark		= 'Special Terms : recheck and post the SC';
                    }
                }
            } else if(
                gstin.Opportunity__r.PO_Required__c == NULL && gstin.Opportunity__r.Special_Terms__c != NULL
            ){
                salesContract.Remark		= 'Special Terms : recheck and post the SC';
            } else if(
                gstin.Opportunity__r.PO_Required__c != NULL && gstin.Opportunity__r.Special_Terms__c == NULL
            ){
                if(gstin.Opportunity__r.PO_Required__c?.toLowerCase() == 'yes'){
                    salesContract.Remark		= 'PO Required';
                } else {
                    if(gstin.Opportunity__r.PO_Required__c?.toLowerCase() == 'no'){
                        salesContract.Remark		= NULL;
                    }
                }
            } else if(
                gstin.Opportunity__r.PO_Required__c == NULL && gstin.Opportunity__r.Special_Terms__c == NULL
            ){
                salesContract.Remark		= NULL;
            }
            
            salesContract.U_DocDate		= String.valueOf(System.today()).replaceAll('-','');
            salesContract.U_StartDate   = String.valueOf(System.today()).replaceAll('-','');
            salesContract.U_ShipToCode	= gstin.Name;
            salesContract.U_BillToCode	= gstin.Name;
            salesContract.U_TaxState	= stateNameToStateCodeMap.get(gstin.State__c?.trim());
            salesContract.U_GstNum		= gstin.Name;
            
            salesContract.U_BillAddress	= gstin.Address__c + '\n' + gstin.City__c + ', ' + stateNameToStateCodeMap.get(gstin.State__c) + '\n' + gstin.Pincode__c + '.';
            salesContract.U_ShipAddress	= gstin.Address__c + '\n' + gstin.City__c + ', ' + stateNameToStateCodeMap.get(gstin.State__c) + '\n' + gstin.Pincode__c + '.';
            
            for(Additional_GSTIN__c gstin1 : gstinList){
                
                CTX_SalesContractRequestWrapper.U_AC_RDR1 rdr1 = new CTX_SalesContractRequestWrapper.U_AC_RDR1();
                rdr1.U_AssetID				= gstin1.Asset__c;
                if(gstin1.Asset__r.Billing_Type__c == 'ARR'){
                    
                    if(gstin1.Asset__r.Product2.Product_Category__c.contains('MS')){
                        rdr1.U_PayTerms		= (String)SF_SAP_PICKLIST_VALUE_MAPPING.get('U_PayTerms').get(gstin1.Opportunity__r.MS_Billing_Frequency__c);
                    } else {
                        rdr1.U_PayTerms		= gstin1.Opportunity__r.Billing_F__c != NULL ? (String)SF_SAP_PICKLIST_VALUE_MAPPING.get('U_PayTerms').get(gstin1.Opportunity__r.Billing_F__c) : (String)SF_SAP_PICKLIST_VALUE_MAPPING.get('U_PayTerms').get(gstin1.Opportunity__r.Billing_Frequency__c);
                    }
                } else if(gstin1.Asset__r.Billing_Type__c == 'OTP') {
                    rdr1.U_PayTerms		= gstin1.Opportunity__r.Billing_Frequency_for_Integration_Prods__c != NULL ? (String)SF_SAP_PICKLIST_VALUE_MAPPING.get('U_PayTerms').get(gstin1.Opportunity__r.Billing_Frequency_for_Integration_Prods__c) : (String)SF_SAP_PICKLIST_VALUE_MAPPING.get('U_PayTerms').get(gstin1.Opportunity__r.Custom_Billing_Freq_for_Integration_Prod__c);
                }
                
                rdr1.U_ItemCode				= gstin1.Asset__r.Product2.ProductCode;
                rdr1.U_LineType				= (String)SF_SAP_PICKLIST_VALUE_MAPPING.get('U_LineType').get(gstin1.Asset__r.Billing_Type__c);
                rdr1.U_Price				= gstin1.Amount__c;
                rdr1.U_StartDate			= String.valueOf(gstin1.Asset__r.PurchaseDate);
                rdr1.U_EndDate				= String.valueOf(gstin1.Asset__r.UsageEndDate);
                rdr1.U_BillingID			= String.valueOf(gstin1.Id);
                
                salesContract.AC_RDR1Collection.add(rdr1);
                
            }
            
            System.debug('##SalesRequestUpsertJSON: ' + JSON.serialize(salesContract));
            HttpResponse response 		= CTX_GetBusinessPartnersDetailsCallout.upsertSalesContract(JSON.serialize(salesContract),billingEntity);
            if(response.getStatusCode() != 200 && response.getStatusCode() != 201){
                System.debug('##response: ' + response.getBody());
                if(response.getStatusCode() == 401){
                    CTX_SAPAPICallouts.refreshToken(NULL);
                    upsertSalesContract(gstin_No, gstinList);
                } else {
                    Logger__c logInstance = CTX_LoggerImplementation.createLoggerInstance(
                        response.getBody(),
                        NULL,
                        'CTX_UpsertSalesContract_SAP',
                        'CTX_GetBusinessPartnersDetailsCallout.upsertSalesContract()',
                        'SAP Callout Failure : Create Sales Contract | GSTIN - ' + gstin.Name + ' | ' + 'OppId - ' + gstin.Opportunity__c,
                        gstin.Opportunity__c,
                        'Opportunity'
                    );
                    logInstance.Callout_Request_Payload__c = JSON.serialize(salesContract);
                    updateSnag.add(logInstance);
                }
            } else {
                Map<String, Object> returnResponseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                String docNum = String.valueOf(returnResponseMap.get('DocNum'));
                for(Additional_GSTIN__c gstin2 : gstinList){
                    gstin2.Sales_Contract_DocNum__c = docNum;
                    gstinsToUpdate.add(gstin2);
                }
                
            }    
        }
    }
}