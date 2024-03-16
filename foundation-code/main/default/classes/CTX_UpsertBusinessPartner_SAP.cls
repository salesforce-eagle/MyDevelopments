public class CTX_UpsertBusinessPartner_SAP {
    
    public static Map<String, String> 				stateNameToStateCodeMap 		= new Map<String, String>();
    public static List<Logger__c> 					updateSnag						= new List<Logger__c>();
    public static List<Additional_GSTIN__c> 		gstinsToUpdate					= new List<Additional_GSTIN__c>();
    public static MAP<String, Map<String, Object>> 	SF_SAP_PICKLIST_VALUE_MAPPING 	= new MAP<String, Map<String, Object>>();
    public static MAP<String, String> 				SF_SAP_USERID_MAPPING 			= new MAP<String, String>();
    
    @future(Callout=TRUE)
    public static void processAdditionalGSTINsFuture(
        Set<Id> newRecords, 
        Set<Id> oldRecords
    ){
        processAdditionalGSTINs(newRecords, oldRecords);
    }
    public static void processAdditionalGSTINs(
        Set<Id> newRecords, 
        Set<Id> oldRecords
    ){
        
        system.debug('My Class is called From Batch');
        for(State_State_Code_SAP_Mapping__mdt mdt : State_State_Code_SAP_Mapping__mdt.getAll().values()){
            stateNameToStateCodeMap.put(mdt.State_Name_GST__c, mdt.State_Code_SAP__c);
        }
        
        
        for(SAP_SF_Picklist_Fields_Value_Mapping__mdt mdt : [SELECT Id, SAP_Field_Name__c, SF_SAP_Values_Mapping_JSON__c FROM SAP_SF_Picklist_Fields_Value_Mapping__mdt]){
            Map<String, Object> fieldValuesMap = (Map<String,Object>)JSON.deserializeUntyped(mdt.SF_SAP_Values_Mapping_JSON__c);
            SF_SAP_PICKLIST_VALUE_MAPPING.put(mdt.SAP_Field_Name__c, fieldValuesMap);
        }
        
        Map<Id, Additional_GSTIN__c>			additionalGSTINAndRelatedRecordsDetails = new Map<Id, Additional_GSTIN__c>();
        Map<String, List<Additional_GSTIN__c>> 	billingPAN_GSTIN_MAP					= new Map<String, List<Additional_GSTIN__c>>();
        Map<String, List<Additional_GSTIN__c>> 	cardCode_GSTIN_MAP						= new Map<String, List<Additional_GSTIN__c>>();
        Map<String, String> 					cardCodeBillingPANMap					= new Map<String, String>();
        
        Map<String, Account> 					billingPAN_Account_Map					= new Map<String, Account>();
        Map<String, Opportunity> 				billingPAN_Opportunity_Map				= new Map<String, Opportunity>();
        String									accountName;

        if(oldRecords != NULL){	/**	Additional GSTIN Update Use Case	**/
            
        } else{	/**	Additional GSTIN Insert Use Case	**/
            
            for( 
                Additional_GSTIN__c thisRec : [ SELECT Id, Name, Quote_Line_Item__c, Quote__c, Asset__c, Billing_PAN__c, Billing_PAN_Formula__c,
                                           
                                           Opportunity__c, Opportunity__r.Account.Name, Opportunity__r.Account.Channel_Partner_Account_Name__c,  Opportunity__r.AccountId, Opportunity__r.Account.Country_of_Origin__c, 
                                           Opportunity__r.Budget_Approver__c, Opportunity__r.Budget_Approver__r.Phone, 
                                           Opportunity__r.Budget_Approver__r.Email,
                                           Opportunity__r.Payment_Term__c, Opportunity__r.PO_Required__c, Opportunity__r.CIN__c, Opportunity__r.TAN__c,Opportunity__r.If_SEZ__c,
                                           Opportunity__r.Account.Owner.SAP_User_Id__c, Opportunity__r.Account.Onboarding_Owner__r.SAP_User_Id__c,
                                           Opportunity__r.Account.Onboarding_Owner__c, Opportunity__r.Account.OwnerId, Opportunity__r.Legal_Entity_Name_Of_The_Client__c, 
                                           Opportunity__r.ClearTax_Billing_Entity__c,
                                               
                                           Opportunity__r.Bus_POC__c, 
                                           Opportunity__r.Bus_POC__r.Phone, 
                                           Opportunity__r.Bus_POC__r.Email, 
                                           Opportunity__r.Bus_POC__r.Name, 
                                           Opportunity__r.Bus_POC__r.Department, 
                                           
                                           Opportunity__r.E_Sign_Customer_Info__c, 
                                           Opportunity__r.E_Sign_Customer_Info__r.Phone, 
                                           Opportunity__r.E_Sign_Customer_Info__r.Email, 
                                           Opportunity__r.E_Sign_Customer_Info__r.Name, 
                                           Opportunity__r.E_Sign_Customer_Info__r.Department, 
                                           
                                           Opportunity__r.Finance_Head_contact__c, 
                                           Opportunity__r.Finance_Head_contact__r.Phone, 
                                           Opportunity__r.Finance_Head_contact__r.Email, 
                                           Opportunity__r.Finance_Head_contact__r.Name, 
                                           Opportunity__r.Finance_Head_contact__r.Department, 
                                           
                                           Opportunity__r.Finance_POC_contact__c, 
                                           Opportunity__r.Finance_POC_contact__r.Phone, 
                                           Opportunity__r.Finance_POC_contact__r.Email, 
                                           Opportunity__r.Finance_POC_contact__r.Name, 
                                           Opportunity__r.Finance_POC_contact__r.Department, 
                                           
                                           Opportunity__r.Primary_Contact__c, 
                                           Opportunity__r.Primary_Contact__r.Phone, 
                                           Opportunity__r.Primary_Contact__r.Email, 
                                           Opportunity__r.Primary_Contact__r.Name, 
                                           Opportunity__r.Primary_Contact__r.Department, 
                                           
                                           Opportunity__r.Tax_Head_contact__c, 
                                           Opportunity__r.Tax_Head_contact__r.Phone, 
                                           Opportunity__r.Tax_Head_contact__r.Email, 
                                           Opportunity__r.Tax_Head_contact__r.Name, 
                                           Opportunity__r.Tax_Head_contact__r.Department,
                                           
                                           BP_Card_Code__c, 
                                           Address__c, Address_Line_2__c, City__c, Pincode__c, State__c, 
                                           Amount__c, Name_Of_The_Customer__c, OTP_Integration__c, TAN__c, SEZ_Yes_No__c,
                                           Add_on_split__c, Upsell_Top_up__c, CIN__c, TIN_Number__c, CR_Number__c, Place_of_supply__c, 
                                           PO_Required__c, PO_Amount__c, PO_Number__c, Update_Company_Information__c
                                           
                                           FROM Additional_GSTIN__c WHERE 
                                           Id IN :newRecords ORDER BY CreatedDate DESC] 
            )
            {
                
                System.debug(' SAP Card Code: '+thisRec.BP_Card_Code__c);
                System.debug(' Billing PAN Formula: '+thisRec.Billing_PAN_Formula__c);
                
                if( thisRec.BP_Card_Code__c != NULL ){
                    if(  
                        thisRec.Opportunity__r.Account.Channel_Partner_Account_Name__c != NULL && 
                       thisRec.Opportunity__r.Account.Channel_Partner_Account_Name__c?.containsIgnoreCase('Uneecops') 
                    ){
                        /**	No Need of BP Updation	**/
                    } else{
                        if(cardCode_GSTIN_MAP.containsKey(thisRec.BP_Card_Code__c)){
                        cardCode_GSTIN_MAP.get(thisRec.BP_Card_Code__c).add(thisRec);
                    } else{
                        cardCode_GSTIN_MAP.put( thisRec.BP_Card_Code__c, new List<Additional_GSTIN__c>{thisRec} );
                    }
                    }
                    
                    
                } else{
                    if( thisRec.Billing_PAN_Formula__c != NULL ){
                        if(billingPAN_GSTIN_MAP.containsKey(thisRec.Billing_PAN_Formula__c)){
                            billingPAN_GSTIN_MAP.get(thisRec.Billing_PAN_Formula__c ).add(thisRec);
                        } else{
                            billingPAN_GSTIN_MAP.put( thisRec.Billing_PAN_Formula__c , new List<Additional_GSTIN__c>{thisRec} );
                        }
                        
                        //
                        
                    } 
                }
                
                if( thisRec.Billing_PAN_Formula__c != NULL ){
                    SF_SAP_USERID_MAPPING.put(thisRec.Opportunity__r.Account.Onboarding_Owner__c, thisRec.Opportunity__r.Account.Onboarding_Owner__r.SAP_User_ID__c);
                    SF_SAP_USERID_MAPPING.put(thisRec.Opportunity__r.Account.OwnerId, thisRec.Opportunity__r.Account.Owner.SAP_User_ID__c);
                    if(!billingPAN_Account_Map.containsKey(thisRec.Billing_PAN_Formula__c)){
                        billingPAN_Account_Map.put(thisRec.Billing_PAN_Formula__c, new Account(Id=thisRec.Opportunity__r.AccountId, Name=thisRec.Opportunity__r.Account.Name, Country_Of_Origin__c = thisRec.Opportunity__r.Account.Country_Of_Origin__c, Onboarding_Owner__c = thisRec.Opportunity__r.Account.Onboarding_Owner__c, OwnerId = thisRec.Opportunity__r.Account.OwnerId));
                    }
                    if(!billingPAN_Opportunity_Map.containsKey(thisRec.Billing_PAN_Formula__c)){
                    	billingPAN_Opportunity_Map.put(
                            thisRec.Billing_PAN_Formula__c, 
                            new Opportunity(
                                Id = thisRec.Opportunity__c, ClearTax_Billing_Entity__c = thisRec.Opportunity__r.ClearTax_Billing_Entity__c, Payment_Term__c = thisRec.Opportunity__r.Payment_Term__c, CIN__c = thisRec.Opportunity__r.CIN__c, PO_Required__c = thisRec.Opportunity__r.PO_Required__c, TAN__c = thisRec.Opportunity__r.TAN__c, If_SEZ__c = thisRec.Opportunity__r.If_SEZ__c, Legal_Entity_Name_Of_The_Client__c = thisRec.Opportunity__r.Legal_Entity_Name_Of_The_Client__c )
                        );   
                    }
                }
            }
            
            /**	Update Business Partners : START	**/
            if(cardCode_GSTIN_MAP.size() > 0){
                updateBusinessPartners(cardCode_GSTIN_MAP,billingPAN_Account_Map,billingPAN_Opportunity_Map);    
            }
            /**	Update Business Partners : END	**/
            
            /**	Create Business Partners : START	**/
            if(billingPAN_GSTIN_MAP.size() > 0){
                createBusinessPartners(billingPAN_GSTIN_MAP,billingPAN_Account_Map,billingPAN_Opportunity_Map);    
            }
            /**	Create Business Partners : END	**/
            
            /** Insert Update Snag **/
            if(updateSnag.size() > 0){
                if(RecursiveTriggerHandler.runCreateLogger){
                	insert updateSnag;    
                }
            }
        }
    }
    
    
    public static void createBusinessPartners(
        Map<String, List<Additional_GSTIN__c>> 	billingPAN_GSTIN_MAP,  
        Map<String, Account> 					billingPAN_Account_Map, 
        Map<String, Opportunity> 				billingPAN_Opportunity_Map
    ){
        
        for( String thisSTR : billingPAN_GSTIN_MAP.keySet() ){
            
            createSingleBusinessPartner(thisSTR, billingPAN_GSTIN_MAP.get(thisSTR), billingPAN_Account_Map.get(thisSTR), billingPAN_Opportunity_Map.get(thisSTR));
        }
        
        if(!gstinsToUpdate.isEmpty()){
            RecursiveTriggerHandler.isFirstTimeGSTIN = FALSE;
            update gstinsToUpdate;
            RecursiveTriggerHandler.isFirstTimeGSTIN = TRUE;
		}
    }
    
    
    public static void updateBusinessPartners(
        Map<String, List<Additional_GSTIN__c>> 	cardCode_GSTIN_MAP,
        Map<String, Account> 					billingPAN_Account_Map, 
        Map<String, Opportunity> 				billingPAN_Opportunity_Map
    ){ 
        System.debug('#####cardCode_GSTIN_MAP: '+ cardCode_GSTIN_MAP);
        for( String thisSTR : cardCode_GSTIN_MAP.keySet() ){
            /**CTX_SAPResponseTrimClass.SAPReturnWrapper returnSAPResponse 
														= CTX_GetBusinessPartnersDetailsCallout.getBusinessPartnerDetails(thisSTR); **/
            String billingPAN = cardCode_GSTIN_MAP.get(thisSTR)[0].Billing_PAN__c;
            System.debug('##OppoInstMap : ' + billingPAN_Opportunity_Map);
            System.debug('##thisSTR : ' + thisSTR);
            System.debug('##OppoInst : ' + billingPAN_Opportunity_Map.get(billingPAN));
            processUpsertSingleBusinessPartner(thisSTR, cardCode_GSTIN_MAP.get(thisSTR), billingPAN_Account_Map.get(billingPAN), billingPAN_Opportunity_Map.get(billingPAN),billingPAN_Opportunity_Map.get(billingPAN).ClearTax_Billing_Entity__c);// added by Murali
        }
        
    }
    
    public static void createSingleBusinessPartner(
        String						cardCode, 
        List<Additional_GSTIN__c> 	additionalGSTINsList,
        Account 					accountInst, 
        Opportunity 				opportunityInst
    ){ 
        CTX_BusinessPartnersWrapper thisRequest = new CTX_BusinessPartnersWrapper();
        
        String CIN_NO;
        for(Additional_GSTIN__c addGSTIN : additionalGSTINsList){
            if(addGSTIN.CIN__c != NULL){
                CIN_NO = addGSTIN.CIN__c;
                break;
            }
		}
        
           
		//Added by Murali
        String billingEntity        = opportunityInst.ClearTax_Billing_Entity__c;
        
        thisRequest.CardCode 		= cardCode;
        thisRequest.CardName 		= additionalGSTINsList[0]?.Name_Of_The_Customer__c == NULL ? NULL : (additionalGSTINsList[0]?.Name_Of_The_Customer__c?.length() > 100 ? additionalGSTINsList[0]?.Name_Of_The_Customer__c.substring(0,100) : additionalGSTINsList[0]?.Name_Of_The_Customer__c);
        thisRequest.PayTermsGrpCode = (String)SF_SAP_PICKLIST_VALUE_MAPPING.get('PayTermsGrpCode').get(opportunityInst?.Payment_Term__c);
        thisRequest.U_CINNo 		= CIN_NO != NULL ? CIN_NO : additionalGSTINsList[0]?.CIN__c;
        thisRequest.U_GroupEntity 	= accountInst?.Id;
        thisRequest.U_Customer 		= accountInst?.Country_of_Origin__c != 'India' && accountInst?.Country_of_Origin__c != NULL ? 'Y' : 'N';
        thisRequest.U_KAM 			= SF_SAP_USERID_MAPPING.get(accountInst.OwnerId);
        thisRequest.U_CSM 			= SF_SAP_USERID_MAPPING.get(accountInst.Onboarding_Owner__c);
        
        /**	Billing PAN Details	**/
        CTX_BusinessPartnersWrapper.BillingPAN billingInfo = new CTX_BusinessPartnersWrapper.BillingPAN();
        billingInfo.TaxId0 = cardCode;
        billingInfo.TaxId12 = cardCode;
        billingInfo.TaxId6	= additionalGSTINsList[0].TAN__c;
        
        thisRequest.BPFiscalTaxIDCollection.add(billingInfo);
        set<String> processedAdditionalGSTIN = new Set<String>();
        set<String> processedContact = new Set<String>();
        for( Additional_GSTIN__c thisAddress : additionalGSTINsList){
         
            
            /**	Additional GSTIN Details : START	**/
 
            if(!processedAdditionalGSTIN.contains(thisAddress.Name)){
                CTX_BusinessPartnersWrapper.AdditionalGSTIN address = new CTX_BusinessPartnersWrapper.AdditionalGSTIN();
                
                if( thisAddress.Address__c?.length() > 50 ){
                    address.AddressName2 	= thisAddress.Address__c?.substring(0, 50); 
                    address.AddressName3 	= thisAddress.Address__c?.substring(50, thisAddress.Address__c?.length() > 100 ? 100 : thisAddress.Address__c?.length());                     
                } else{
                    address.AddressName2 	= thisAddress.Address__c; 
                    address.AddressName3 	= thisAddress.Address__c; 
                }
                address.GSTIN 			= thisAddress.Name;
                address.BPCode 			= cardCode;
                address.ZipCode			= thisAddress.Pincode__c;
                address.AddressType		= 'bo_BillTo';
                address.City			= thisAddress.City__c;
                address.State 			= stateNameToStateCodeMap.get(thisAddress.State__c?.trim());
                address.FederalTaxID	= cardCode;
                address.AddressName 	= thisAddress.Name;
                address.U_SEZ_GST		= thisAddress.SEZ_Yes_No__c?.tolowerCase() == 'yes' ? 'Y' : 'N';
                thisRequest.BPAddresses.add(address);
                
                CTX_BusinessPartnersWrapper.AdditionalGSTIN address1 = new CTX_BusinessPartnersWrapper.AdditionalGSTIN();
                
                if( thisAddress.Address__c?.length() > 50 ){
                    address1.AddressName2 	= thisAddress.Address__c?.substring(0, 50); 
                    address1.AddressName3 	= thisAddress.Address__c?.substring(50, thisAddress.Address__c?.length() > 100 ? 100 : thisAddress.Address__c?.length());                     
                } else{
                    address1.AddressName2 	= thisAddress.Address__c; 
                    address1.AddressName3 	= thisAddress.Address__c; 
                }
                address1.GSTIN 			= thisAddress.Name;
                address1.BPCode 		= cardCode;
                address1.ZipCode		= thisAddress.Pincode__c;
                address1.AddressType	= 'bo_ShipTo';
                address1.City			= thisAddress.City__c;
                address1.State 			= stateNameToStateCodeMap.get(thisAddress.State__c?.trim());
                address1.FederalTaxID	= cardCode;
                address1.AddressName 	= thisAddress.Name;
                address1.U_SEZ_GST		= thisAddress.SEZ_Yes_No__c?.tolowerCase() == 'yes' ? 'Y' : 'N';
                thisRequest.BPAddresses.add(address1);
                
                processedAdditionalGSTIN.add(thisAddress.Name);
            }
            /**	Additional GSTIN Details : END	**/
            if(!processedContact.contains('Business POC')){
                /**	Contact Details : START	**/
                
                if(thisAddress.Opportunity__r.Bus_POC__c != NULL){
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Business POC';//thisAddress.Opportunity__r.Bus_POC__r.Name;
                    cons.Remarks1 = thisAddress.Opportunity__r.Bus_POC__r.Department;
                    cons.E_Mail = thisAddress.Opportunity__r.Bus_POC__r.Email;
                    cons.MobilePhone = thisAddress.Opportunity__r.Bus_POC__r.Phone;
                    thisRequest.ContactEmployees.add(cons);
                    
                    processedContact.add('Business POC');    
                }
                /**	Contact Details : START	**/    
            }
            if(!processedContact.contains('E-Signer POC')){
                /**	Contact Details : START	**/
                
                if(thisAddress.Opportunity__r.E_Sign_Customer_Info__c != NULL){
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'E-Signer POC';//thisAddress.Opportunity__r.E_Sign_Customer_Info__r.Name;
                    cons.Remarks1 = thisAddress.Opportunity__r.E_Sign_Customer_Info__r.Department;
                    cons.E_Mail = thisAddress.Opportunity__r.E_Sign_Customer_Info__r.Email;
                    cons.MobilePhone = thisAddress.Opportunity__r.E_Sign_Customer_Info__r.Phone;
                    thisRequest.ContactEmployees.add(cons);
                    
                    processedContact.add('E-Signer POC');    
                }
                /**	Contact Details : START	**/    
            }
            if(!processedContact.contains('Finance Head')){
                /**	Contact Details : START	**/
                
                if(thisAddress.Opportunity__r.Finance_Head_contact__c != NULL){
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Finance Head';//thisAddress.Opportunity__r.Finance_Head_contact__r.Name;
                    cons.Remarks1 = thisAddress.Opportunity__r.Finance_Head_contact__r.Department;
                    cons.E_Mail = thisAddress.Opportunity__r.Finance_Head_contact__r.Email;
                    cons.MobilePhone = thisAddress.Opportunity__r.Finance_Head_contact__r.Phone;
                    thisRequest.ContactEmployees.add(cons);
                    
                    processedContact.add('Finance Head');    
                }
                /**	Contact Details : START	**/    
            }
            if(!processedContact.contains('Finance POC')){
                /**	Contact Details : START	**/
                
                if(thisAddress.Opportunity__r.Finance_POC_contact__c != NULL){
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Finance POC';//thisAddress.Opportunity__r.Finance_POC_contact__r.Name;
                    cons.Remarks1 = thisAddress.Opportunity__r.Finance_POC_contact__r.Department;
                    cons.E_Mail = thisAddress.Opportunity__r.Finance_POC_contact__r.Email;
                    cons.MobilePhone = thisAddress.Opportunity__r.Finance_POC_contact__r.Phone;
                    thisRequest.ContactEmployees.add(cons);
                    
                    processedContact.add('Finance POC');    
                }
                /**	Contact Details : START	**/    
            }
            if(!processedContact.contains('Primary POC')){
                /**	Contact Details : START	**/
                
                if(thisAddress.Opportunity__r.Primary_Contact__c != NULL){
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Primary POC';//thisAddress.Opportunity__r.Primary_Contact__r.Name;
                    cons.Remarks1 = thisAddress.Opportunity__r.Primary_Contact__r.Department;
                    cons.E_Mail = thisAddress.Opportunity__r.Primary_Contact__r.Email;
                    cons.MobilePhone = thisAddress.Opportunity__r.Primary_Contact__r.Phone;
                    thisRequest.ContactEmployees.add(cons);
                    
                    processedContact.add('Primary POC');    
                }
                /**	Contact Details : START	**/    
            }
            if(!processedContact.contains('Tax Head')){
                /**	Contact Details : START	**/
                
                if(thisAddress.Opportunity__r.Tax_Head_contact__c != NULL){
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Tax Head';//thisAddress.Opportunity__r.Tax_Head_contact__r.Name;
                    cons.Remarks1 = thisAddress.Opportunity__r.Tax_Head_contact__r.Department;
                    cons.E_Mail = thisAddress.Opportunity__r.Tax_Head_contact__r.Email;
                    cons.MobilePhone = thisAddress.Opportunity__r.Tax_Head_contact__r.Phone;
                    thisRequest.ContactEmployees.add(cons);
                    
                    processedContact.add('Tax Head');    
                }
                /**	Contact Details : START	**/    
            }
        }
        
        system.debug('Create Business Partner thisRequest: '+thisRequest);
        system.debug('##Create Business Partner thisRequest JSON: '+JSON.serialize(thisRequest));
        
        HttpResponse response = CTX_GetBusinessPartnersDetailsCallout.createBusinessPartner(JSON.serialize(thisRequest),billingEntity);
        
        //added by Murali
        SAP_Integration_Settings_metadata__mdt retrivedMetadata = CTX_SAPAPICallouts.getIntergartionMetadata(billingEntity);
        
        if(response.getStatusCode() != 200 && response.getStatusCode() != 201){
            if(response.getStatusCode() == 401){
                CTX_SAPAPICallouts.refreshToken(retrivedMetadata);
                createSingleBusinessPartner(cardCode, additionalGSTINsList, accountInst, opportunityInst);
            } else {
                Logger__c logInstance = CTX_LoggerImplementation.createLoggerInstance(
                    response.getBody(),
                    NULL,
                    'CTX_UpsertBusinessPartner_SAP',
                    'CTX_GetBusinessPartnersDetailsCallout.createBusinessPartner()',
                    'SAP Callout Failure : Create Business Partner | Billing PAN - ' + cardCode + ' | OppId - ' + opportunityInst.Id,
                    opportunityInst.Id,//gstin.Id,
                    'Additional_GSTIN__c'
                );
                logInstance.Callout_Request_Payload__c = JSON.serialize(thisRequest);
                updateSnag.add(logInstance);
            }
        } else {
            system.debug('response: '+response.getBody());
            
            Map<String, Object> constructResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            for( Additional_GSTIN__c thisAddress : additionalGSTINsList ){
                thisAddress.Bp_Card_Code__c = (String)constructResponse.get('CardCode');
                gstinsToUpdate.add(thisAddress);
            }
        }
        
    }
    
    public static void processUpsertSingleBusinessPartner(
        String 						cardCode, 
        List<Additional_GSTIN__c> 	additionalGSTINsList,
        Account 					accountInst, 
        Opportunity 				opportunityInst,
        String                      billingEntity   // added by Murali
    ){
        System.debug('##OppoInst1 : ' + opportunityInst);
        HttpResponse response = CTX_GetBusinessPartnersDetailsCallout.getBusinessPartnerDetails(cardCode,billingEntity);  // added by Murali
        
        
        //added by Murali
        SAP_Integration_Settings_metadata__mdt retrivedMetadata = CTX_SAPAPICallouts.getIntergartionMetadata(billingEntity);
        
        System.debug('##response: ' + response.getBody());
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
            CTX_BusinessPartnersWrapper returnSAPResponse = (CTX_BusinessPartnersWrapper)JSON.deserialize(response.getBody(), CTX_BusinessPartnersWrapper.class);
            updateSingleBusinessPartner(cardCode, additionalGSTINsList, accountInst, opportunityInst, returnSAPResponse);
            
        } else {
            
            if(response.getStatusCode() == 401){
                CTX_SAPAPICallouts.refreshToken(retrivedMetadata);
                processUpsertSingleBusinessPartner(cardCode, additionalGSTINsList, accountInst, opportunityInst,billingEntity);
            } else {
                Logger__c logInstance = CTX_LoggerImplementation.createLoggerInstance(
                    response.getBody(),
                    NULL,
                    'CTX_UpsertBusinessPartner_SAP',
                    'CTX_GetBusinessPartnersDetailsCallout.getBusinessPartnerDetails()',
                    'SAP Callout Failure : Get Business Partner',
                    opportunityInst.Id,//gstin.Id,
                    'Additional_GSTIN__c'
                );
                updateSnag.add(logInstance);
            }
        }
        
    }
    
    public static void updateSingleBusinessPartner( 
        String 						cardCode, 
        List<Additional_GSTIN__c> 	additionalGSTINsList,
        Account 					accountInst, 
        Opportunity 				opportunityInst,
        CTX_BusinessPartnersWrapper returnSAPResponse
    ){
        System.debug('##OppoInst2 : ' + opportunityInst);
        
        //Added by Murali
        String billingEntity = opportunityInst.ClearTax_Billing_Entity__c;
        
        Map<String, List<CTX_BusinessPartnersWrapper.AdditionalGSTIN>> existingGstinsDetails 	= new Map<String, List<CTX_BusinessPartnersWrapper.AdditionalGSTIN>>();
        set<String> existingContactDetails 	= new set<String>();
        set<String> existingBilling 	= new set<String>();
        Map<String, String>	contactNameEmailMap		= new Map<String, String>();
        
        returnSAPResponse.BPFiscalTaxIDCollection = new List<CTX_BusinessPartnersWrapper.BillingPAN>();
        
        for(CTX_BusinessPartnersWrapper.AdditionalGSTIN gstinInst : returnSAPResponse.BPAddresses){
            if(!existingGstinsDetails.containsKey(gstinInst.AddressName)){
                existingGstinsDetails.put(gstinInst.AddressName, new List<CTX_BusinessPartnersWrapper.AdditionalGSTIN>{gstinInst});    
            } else {
                existingGstinsDetails.get(gstinInst.AddressName).add(gstinInst);
            }
        }
        
        for(CTX_BusinessPartnersWrapper.POCs contact : returnSAPResponse.ContactEmployees){
            existingContactDetails.add(contact.Name);
            contactNameEmailMap.put(contact.Name, contact.E_Mail);
        }
        
        for(CTX_BusinessPartnersWrapper.BillingPAN billingInfo : returnSAPResponse.BPFiscalTaxIDCollection){
            existingBilling.add(billingInfo.TaxId0);
        }
        
        List<CTX_BusinessPartnersWrapper.AdditionalGSTIN> 	bpAddresses = new List<CTX_BusinessPartnersWrapper.AdditionalGSTIN>();
        List<CTX_BusinessPartnersWrapper.POCs> 				pocsList 	= new List<CTX_BusinessPartnersWrapper.POCs>();
        Map<String, CTX_BusinessPartnersWrapper.POCs>		pocMap	 	= new Map<String, CTX_BusinessPartnersWrapper.POCs>();
		
        String CIN_NO;
        String billingPAN = additionalGSTINsList[0].Billing_PAN_Formula__c;
        for(Additional_GSTIN__c addGSTIN : additionalGSTINsList){
            if(addGSTIN.CIN__c != NULL){
                CIN_NO = addGSTIN.CIN__c;
                break;
            }
        }
        
        returnSAPResponse.CardName 			= additionalGSTINsList[0]?.Name_Of_The_Customer__c == NULL ? NULL : (additionalGSTINsList[0]?.Name_Of_The_Customer__c?.length() > 100 ? additionalGSTINsList[0]?.Name_Of_The_Customer__c?.substring(0,100) : additionalGSTINsList[0]?.Name_Of_The_Customer__c);
        returnSAPResponse.U_GroupEntity 	= accountInst?.Id;
        returnSAPResponse.U_Customer 		= accountInst?.Country_of_Origin__c != 'India' && accountInst?.Country_of_Origin__c != NULL ? 'Y' : 'N';
		
        returnSAPResponse.U_CINNo 			= CIN_NO != NULL ? CIN_NO : additionalGSTINsList[0].CIN__c;
        returnSAPResponse.PayTermsGrpCode	= (String)SF_SAP_PICKLIST_VALUE_MAPPING.get('PayTermsGrpCode').get(opportunityInst?.Payment_Term__c);
        returnSAPResponse.U_KAM 			= SF_SAP_USERID_MAPPING.get(accountInst?.OwnerId);
        returnSAPResponse.U_CSM 			= SF_SAP_USERID_MAPPING.get(accountInst?.Onboarding_Owner__c);
		
        if(!existingBilling.contains(cardCode)){
        	CTX_BusinessPartnersWrapper.BillingPAN billingInfo = new CTX_BusinessPartnersWrapper.BillingPAN();
            billingInfo.TaxId0 = cardCode;
            billingInfo.TaxId12 = cardCode;
            billingInfo.TaxId6	= additionalGSTINsList[0].TAN__c;
            //returnSAPResponse.BPFiscalTaxIDCollection = new List<CTX_BusinessPartnersWrapper.BillingPAN>{billingInfo};
        }       
        
        for( Additional_GSTIN__c thisRec : additionalGSTINsList ){
            
            if(!existingGstinsDetails.containsKey(thisRec.Name)){
                CTX_BusinessPartnersWrapper.AdditionalGSTIN address = new CTX_BusinessPartnersWrapper.AdditionalGSTIN();
                address.GSTIN 	= thisRec.Name;
                if( thisRec.Address__c?.length() > 50 ){
                    address.AddressName2 	= thisRec.Address__c?.substring(0, 50); 
                    address.AddressName3 	= thisRec.Address__c?.substring(50, thisRec.Address__c?.length() > 100 ? 100 : thisRec.Address__c?.length());                     
                } else{
                    address.AddressName2 	= thisRec.Address__c; 
                    address.AddressName3 	= thisRec.Address__c; 
                }
                address.GSTIN 			= thisRec.Name;
                address.BPCode 			= cardCode;
                address.ZipCode			= thisRec.Pincode__c;
                address.AddressType		= 'bo_BillTo';
                address.City			= thisRec.City__c;
                address.State 			= stateNameToStateCodeMap.get(thisRec.State__c?.trim());
                address.FederalTaxID	= cardCode;
                address.AddressName 	= thisRec.Name;
                address.U_SEZ_GST		= thisRec.SEZ_Yes_No__c?.tolowerCase() == 'yes' ? 'Y' : 'N';
                //bpAddresses.add(address);
                
                CTX_BusinessPartnersWrapper.AdditionalGSTIN address1 = new CTX_BusinessPartnersWrapper.AdditionalGSTIN();
                address1.GSTIN 	= thisRec.Name;
                if( thisRec.Address__c?.length() > 50 ){
                    address1.AddressName2 	= thisRec.Address__c?.substring(0, 50); 
                    address1.AddressName3 	= thisRec.Address__c?.substring(50, thisRec.Address__c?.length() > 100 ? 100 : thisRec.Address__c?.length());                     
                } else{
                    address1.AddressName2 	= thisRec.Address__c; 
                    address1.AddressName3 	= thisRec.Address__c; 
                }
                address1.GSTIN 			= thisRec.Name;
                address1.BPCode 		= cardCode;
                address1.ZipCode		= thisRec.Pincode__c;
                address1.AddressType	= 'bo_ShipTo';
                address1.City			= thisRec.City__c;
                address1.State 			= stateNameToStateCodeMap.get(thisRec.State__c?.trim());
                address1.FederalTaxID	= cardCode;
                address1.AddressName 	= thisRec.Name;
                address1.U_SEZ_GST		= thisRec.SEZ_Yes_No__c?.tolowerCase() == 'yes' ? 'Y' : 'N';
                //bpAddresses.add(address1);
                existingGstinsDetails.put(thisRec.Name, new List<CTX_BusinessPartnersWrapper.AdditionalGSTIN>{address, address1});
            } 
            else {
                //List<CTX_BusinessPartnersWrapper.AdditionalGSTIN> SAP_BP_Addressess = existingGstinsDetails.get(thisRec.Name);
                for (CTX_BusinessPartnersWrapper.AdditionalGSTIN address : existingGstinsDetails.get(thisRec.Name)){
                    address.GSTIN 	= thisRec.Name;
                    if( thisRec.Address__c?.length() > 50 ){
                        address.AddressName2 	= thisRec.Address__c?.substring(0, 50); 
                        address.AddressName3 	= thisRec.Address__c?.substring(50, thisRec.Address__c?.length() > 100 ? 100 : thisRec.Address__c?.length());                     
                    } else{
                        address.AddressName2 	= thisRec.Address__c; 
                        address.AddressName3 	= thisRec.Address__c; 
                    }
                    address.GSTIN 			= thisRec.Name;
                    address.BPCode 			= cardCode;
                    address.ZipCode			= thisRec.Pincode__c;
                    address.City			= thisRec.City__c;
                    address.State 			= stateNameToStateCodeMap.get(thisRec.State__c?.trim());
                    address.FederalTaxID	= cardCode;
                    address.AddressName 	= thisRec.Name;
                    address.U_SEZ_GST		= thisRec.SEZ_Yes_No__c?.tolowerCase() == 'yes' ? 'Y' : 'N';
                    //bpAddresses.add(address);
                }
                
            }
            
            /**	UNEECOPS Exclusion : START	**/
            if(thisRec.Opportunity__r.Bus_POC__c != NULL){
                if( !existingContactDetails.contains('Business POC') ){
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Business POC';
                    cons.Remarks1 = thisRec.Opportunity__r.Bus_POC__r.Department;
                    cons.E_Mail = thisRec.Opportunity__r.Bus_POC__r.Email;
                    cons.MobilePhone = thisRec.Opportunity__r.Bus_POC__r.Phone;
                    pocsList.add(cons);
                    pocMap.put('Business POC', cons);
                    
                    existingContactDetails.add('Business POC');
                }/* else{
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Business POC';
                    cons.Remarks1 = thisRec.Opportunity__r.Bus_POC__r.Department;
                    cons.E_Mail = contactNameEmailMap.get('Business POC')+','+thisRec.Opportunity__r.Bus_POC__r.Email;
                    cons.MobilePhone = thisRec.Opportunity__r.Bus_POC__r.Phone;
                    pocsList.add(cons);
                    pocMap.put('Business POC', cons);
                    existingContactDetails.add('Business POC');
                }  */  
            }
            if(thisRec.Opportunity__r.E_Sign_Customer_Info__c  != NULL){
                if( !existingContactDetails.contains('E-Signer POC') ){
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'E-Signer POC';
                    cons.Remarks1 = thisRec.Opportunity__r.E_Sign_Customer_Info__r.Department;
                    cons.E_Mail = thisRec.Opportunity__r.E_Sign_Customer_Info__r.Email;
                    cons.MobilePhone = thisRec.Opportunity__r.E_Sign_Customer_Info__r.Phone;
                    pocsList.add(cons);
                    pocMap.put('E-Signer POC', cons);
                    
                    existingContactDetails.add('E-Signer POC');
                }/* else{
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'E-Signer POC';
                    cons.Remarks1 = thisRec.Opportunity__r.E_Sign_Customer_Info__r.Department;
                    cons.E_Mail = contactNameEmailMap.get('E-Signer POC')+','+thisRec.Opportunity__r.E_Sign_Customer_Info__r.Email;
                    cons.MobilePhone = thisRec.Opportunity__r.E_Sign_Customer_Info__r.Phone;
                    pocsList.add(cons);
                    pocMap.put('E-Signer POC', cons);
                    
                    existingContactDetails.add('E-Signer POC');
                }   */ 
            }
            if(thisRec.Opportunity__r.Finance_Head_contact__c != NULL){
                if( !existingContactDetails.contains('Finance Head') ){
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Finance Head';
                    cons.Remarks1 = thisRec.Opportunity__r.Finance_Head_contact__r.Department;
                    cons.E_Mail = thisRec.Opportunity__r.Finance_Head_contact__r.Email;
                    cons.MobilePhone = thisRec.Opportunity__r.Finance_Head_contact__r.Phone;
                    pocsList.add(cons);
                    pocMap.put('Finance Head', cons);
                    
                    existingContactDetails.add('Finance Head');
                }/* else{
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Finance Head';
                    cons.Remarks1 = thisRec.Opportunity__r.Finance_Head_contact__r.Department;
                    cons.E_Mail = contactNameEmailMap.get('Finance Head')+','+thisRec.Opportunity__r.Finance_Head_contact__r.Email;
                    cons.MobilePhone = thisRec.Opportunity__r.Finance_Head_contact__r.Phone;
                    pocsList.add(cons);
                    pocMap.put('Finance Head', cons);
                    
                    existingContactDetails.add('Finance Head');
                }   */ 
            }
            if(thisRec.Opportunity__r.Finance_POC_contact__c != NULL){
                if( !existingContactDetails.contains('Finance POC') ){
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Finance POC';
                    cons.Remarks1 = thisRec.Opportunity__r.Finance_POC_contact__r.Department;
                    cons.E_Mail = thisRec.Opportunity__r.Finance_POC_contact__r.Email;
                    cons.MobilePhone = thisRec.Opportunity__r.Finance_POC_contact__r.Phone;
                    pocsList.add(cons);
                    pocMap.put('Finance POC', cons);
                    
                    existingContactDetails.add('Finance POC');
                } /*else{
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Finance POC';
                    cons.Remarks1 = thisRec.Opportunity__r.Finance_POC_contact__r.Department;
                    cons.E_Mail = contactNameEmailMap.get('Finance POC')+','+thisRec.Opportunity__r.Finance_POC_contact__r.Email;
                    cons.MobilePhone = thisRec.Opportunity__r.Finance_POC_contact__r.Phone;
                    pocsList.add(cons);
                    pocMap.put('Finance POC', cons);
                    
                    existingContactDetails.add('Finance POC');
                }  */ 
            }
            if(thisRec.Opportunity__r.Primary_Contact__c != NULL){
                if( !existingContactDetails.contains('Primary POC') ){
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Primary POC';
                    cons.Remarks1 = thisRec.Opportunity__r.Primary_Contact__r.Department;
                    cons.E_Mail = thisRec.Opportunity__r.Primary_Contact__r.Email;
                    cons.MobilePhone = thisRec.Opportunity__r.Primary_Contact__r.Phone;
                    pocsList.add(cons);
                    pocMap.put('Primary POC', cons);
                    
                    existingContactDetails.add('Primary POC');
                }/* else{
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Primary POC';
                    cons.Remarks1 = thisRec.Opportunity__r.Primary_Contact__r.Department;
                    cons.E_Mail = contactNameEmailMap.get('Primary POC')+','+thisRec.Opportunity__r.Primary_Contact__r.Email;
                    cons.MobilePhone = thisRec.Opportunity__r.Primary_Contact__r.Phone;
                    pocsList.add(cons);
                    pocMap.put('Primary POC', cons);
                    
                    existingContactDetails.add('Primary POC');
                }  */ 
            }
            if(thisRec.Opportunity__r.Tax_Head_contact__c != NULL){
                if( !existingContactDetails.contains('Tax Head') ){
                    CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Tax Head';
                    cons.Remarks1 = thisRec.Opportunity__r.Tax_Head_contact__r.Department;
                    cons.E_Mail = thisRec.Opportunity__r.Tax_Head_contact__r.Email;
                    cons.MobilePhone = thisRec.Opportunity__r.Tax_Head_contact__r.Phone;
                    pocsList.add(cons);
                    pocMap.put('Tax Head', cons);
                    
                    existingContactDetails.add('Tax Head');
                } /*else{
                     CTX_BusinessPartnersWrapper.POCs cons = new CTX_BusinessPartnersWrapper.POCs();
                    cons.CardCode = cardCode;
                    cons.Name = 'Tax Head';
                    cons.Remarks1 = thisRec.Opportunity__r.Tax_Head_contact__r.Department;
                    cons.E_Mail = contactNameEmailMap.get('Tax Head')+','+thisRec.Opportunity__r.Tax_Head_contact__r.Email;
                    cons.MobilePhone = thisRec.Opportunity__r.Tax_Head_contact__r.Phone;
                    pocsList.add(cons);
                    pocMap.put('Tax Head', cons);
                    
                    existingContactDetails.add('Tax Head');
                }*/    
            }
            /**	UNEECOPS Exclusion : END	**/
            
            
        }
        
        for(String gstin : existingGstinsDetails.keySet()){
            bpAddresses.addAll(existingGstinsDetails.get(gstin));
        }
        
        returnSAPResponse.BPAddresses 		= bpAddresses;
        returnSAPResponse.ContactEmployees 	= pocMap.values();
        
        System.debug('##UpdateREquest: '+ JSON.serialize(returnSAPResponse));
        HttpResponse response = CTX_GetBusinessPartnersDetailsCallout.updateBusinessPartner(cardCode, JSON.serialize(returnSAPResponse),billingEntity);
        
        
        //added by Murali
        SAP_Integration_Settings_metadata__mdt retrivedMetadata = CTX_SAPAPICallouts.getIntergartionMetadata(billingEntity);
        
        system.debug('response getbody: '+response.getBody());
        if(response.getStatusCode() != 200 && response.getStatusCode() != 201 && response.getStatusCode() != 204){
            if(response.getStatusCode() == 401){
                CTX_SAPAPICallouts.refreshToken(retrivedMetadata);
                updateSingleBusinessPartner(cardCode, additionalGSTINsList, accountInst, opportunityInst, returnSAPResponse);
            } else {
                Logger__c logInstance = CTX_LoggerImplementation.createLoggerInstance(
                    response.getBody(),
                    NULL,
                    'CTX_UpsertBusinessPartner_SAP',
                    'CTX_GetBusinessPartnersDetailsCallout.updateBusinessPartner()',
                    'SAP Callout Failure : Update Business Partner | Billing PAN - ' + billingPAN + ' | OppId - ' + opportunityInst.Id,
                    opportunityInst.Id,//gstin.Id,
                    'Additional_GSTIN__c'
                );
                logInstance.Callout_Request_Payload__c = JSON.serialize(returnSAPResponse);
                updateSnag.add(logInstance);
            }
        }
    }
   
    
}