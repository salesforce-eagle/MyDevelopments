/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-12-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_DataSyncJobSAPSF {
    
    
    public static void doBulkSAPFetch(String billingEntityData){
        String billingEntity = billingEntityData;
        List<Object> bulkSAPrecordresponse = fetchAllBusinessPartnersFromSAP(billingEntity);
    }
    
    public static void fetchSingleSAPRecord( String cardCode,String billingEntityData ){
        String billingEntity = billingEntityData;
        /** String jsonResponse = ' {"odata.metadata":"https:\/\/www.clear-sap.in:50000\/b1s\/v1\/$metadata#BusinessPartners\/@Element","odata.etag":"W\/\"DA4B9237BACCCDF19C0760CAB7AEC4A8359010B0\"","CardCode":"AAJCD5643C","CardName":"Ashish Tulsian","CardType":"cCustomer","GroupCode":114,"Address":null,"ZipCode":null,"MailAddress":null,"MailZipCode":null,"Phone1":null,"Phone2":null,"Fax":null,"ContactPerson":null,"Notes":null,"PayTermsGrpCode":-1,"CreditLimit":0,"MaxCommitment":0,"DiscountPercent":0,"VatLiable":"vLiable","FederalTaxID":null,"DeductibleAtSource":"tNO","DeductionPercent":0,"DeductionValidUntil":null,"PriceListNum":1,"IntrestRatePercent":0,"CommissionPercent":0,"CommissionGroupCode":0,"FreeText":null,"SalesPersonCode":-1,"Currency":"INR","RateDiffAccount":null,"Cellular":"9999516554","AvarageLate":null,"City":null,"County":null,"Country":"IN","MailCity":null,"MailCounty":null,"MailCountry":"IN","EmailAddress":"ashish91tulsian@gmail.com","Picture":null,"DefaultAccount":null,"DefaultBranch":null,"DefaultBankCode":"-1","AdditionalID":null,"Pager":null,"FatherCard":null,"CardForeignName":null,"FatherType":"cPayments_sum","DeductionOffice":null,"ExportCode":null,"MinIntrest":0,"CurrentAccountBalance":0,"OpenDeliveryNotesBalance":0,"OpenOrdersBalance":0,"OpenChecksBalance":0,"VatGroup":null,"ShippingType":null,"Password":null,"Indicator":null,"IBAN":null,"CreditCardCode":-1,"CreditCardNum":null,"CreditCardExpiration":null,"DebitorAccount":"_SYS00000000692","OpenOpportunities":null,"Valid":"tYES","ValidFrom":null,"ValidTo":null,"ValidRemarks":null,"Frozen":"tNO","FrozenFrom":null,"FrozenTo":null,"FrozenRemarks":null,"Block":null,"BillToState":"MH","ShipToState":"MH","ExemptNum":null,"Priority":-1,"FormCode1099":null,"Box1099":null,"PeymentMethodCode":"01","BackOrder":"tYES","PartialDelivery":"tYES","BlockDunning":"tNO","BankCountry":null,"HouseBank":"HDFC","HouseBankCountry":"IN","HouseBankAccount":"50200011860902","ShipToDefault":"Ship To","DunningLevel":null,"DunningDate":null,"CollectionAuthorization":"tNO","DME":null,"InstructionKey":null,"SinglePayment":"tNO","ISRBillerID":null,"PaymentBlock":"tNO","ReferenceDetails":null,"HouseBankBranch":null,"OwnerIDNumber":null,"PaymentBlockDescription":-1,"TaxExemptionLetterNum":null,"MaxAmountOfExemption":0,"ExemptionValidityDateFrom":null,"ExemptionValidityDateTo":null,"LinkedBusinessPartner":null,"LastMultiReconciliationNum":null,"DeferredTax":"tNO","Equalization":"tNO","SubjectToWithholdingTax":"boNO","CertificateNumber":null,"ExpirationDate":null,"NationalInsuranceNum":null,"AccrualCriteria":"tNO","WTCode":null,"BillToBuildingFloorRoom":"","DownPaymentClearAct":"_SYS00000000657","ChannelBP":null,"DefaultTechnician":null,"BilltoDefault":"Bill to","CustomerBillofExchangDisc":null,"Territory":null,"ShipToBuildingFloorRoom":"","CustomerBillofExchangPres":null,"ProjectCode":null,"VatGroupLatinAmerica":null,"DunningTerm":null,"Website":null,"OtherReceivablePayable":null,"BillofExchangeonCollection":null,"CompanyPrivate":"cCompany","LanguageCode":8,"UnpaidBillofExchange":null,"WithholdingTaxDeductionGroup":-1,"ClosingDateProcedureNumber":null,"Profession":null,"BankChargesAllocationCode":null,"TaxRoundingRule":"trr_CompanyDefault","Properties1":"tNO","Properties2":"tNO","Properties3":"tNO","Properties4":"tNO","Properties5":"tNO","Properties6":"tNO","Properties7":"tNO","Properties8":"tNO","Properties9":"tNO","Properties10":"tNO","Properties11":"tNO","Properties12":"tNO","Properties13":"tNO","Properties14":"tNO","Properties15":"tNO","Properties16":"tNO","Properties17":"tNO","Properties18":"tNO","Properties19":"tNO","Properties20":"tNO","Properties21":"tNO","Properties22":"tNO","Properties23":"tNO","Properties24":"tNO","Properties25":"tNO","Properties26":"tNO","Properties27":"tNO","Properties28":"tNO","Properties29":"tNO","Properties30":"tNO","Properties31":"tNO","Properties32":"tNO","Properties33":"tNO","Properties34":"tNO","Properties35":"tNO","Properties36":"tNO","Properties37":"tNO","Properties38":"tNO","Properties39":"tNO","Properties40":"tNO","Properties41":"tNO","Properties42":"tNO","Properties43":"tNO","Properties44":"tNO","Properties45":"tNO","Properties46":"tNO","Properties47":"tNO","Properties48":"tNO","Properties49":"tNO","Properties50":"tNO","Properties51":"tNO","Properties52":"tNO","Properties53":"tNO","Properties54":"tNO","Properties55":"tNO","Properties56":"tNO","Properties57":"tNO","Properties58":"tNO","Properties59":"tNO","Properties60":"tNO","Properties61":"tNO","Properties62":"tNO","Properties63":"tNO","Properties64":"tNO","CompanyRegistrationNumber":null,"VerificationNumber":null,"DiscountBaseObject":"dgboNone","DiscountRelations":"dgrLowestDiscount","TypeReport":"atCompany","ThresholdOverlook":"tNO","SurchargeOverlook":"tNO","DownPaymentInterimAccount":null,"OperationCode347":"ocSalesOrServicesRevenues","InsuranceOperation347":"tNO","HierarchicalDeduction":"tNO","ShaamGroup":"sgServicesAndAsset","WithholdingTaxCertified":"tNO","BookkeepingCertified":"tNO","PlanningGroup":null,"Affiliate":"tNO","Industry":null,"VatIDNum":null,"DatevAccount":null,"DatevFirstDataEntry":"tYES","UseShippedGoodsAccount":"tNO","GTSRegNo":null,"GTSBankAccountNo":null,"GTSBillingAddrTel":null,"ETaxWebSite":null,"HouseBankIBAN":null,"VATRegistrationNumber":null,"RepresentativeName":null,"IndustryType":null,"BusinessType":null,"Series":1,"AutomaticPosting":"apNo","InterestAccount":null,"FeeAccount":null,"CampaignNumber":null,"AliasName":null,"DefaultBlanketAgreementNumber":null,"EffectiveDiscount":"dgrLowestDiscount","NoDiscounts":"tNO","EffectivePrice":"epDefaultPriority","EffectivePriceConsidersPriceBeforeDiscount":"tNO","GlobalLocationNumber":null,"EDISenderID":null,"EDIRecipientID":null,"ResidenNumber":"rntSpanishFiscalID","RelationshipCode":null,"RelationshipDateFrom":null,"RelationshipDateTill":null,"UnifiedFederalTaxID":null,"AttachmentEntry":null,"TypeOfOperation":null,"EndorsableChecksFromBP":"tYES","AcceptsEndorsedChecks":"tNO","OwnerCode":null,"BlockSendingMarketingContent":"tNO","AgentCode":null,"PriceMode":null,"EDocGenerationType":null,"EDocStreet":null,"EDocStreetNumber":null,"EDocBuildingNumber":null,"EDocZipCode":null,"EDocCity":null,"EDocCountry":null,"EDocDistrict":null,"EDocRepresentativeFirstName":null,"EDocRepresentativeSurname":null,"EDocRepresentativeCompany":null,"EDocRepresentativeFiscalCode":null,"EDocRepresentativeAdditionalId":null,"EDocPECAddress":null,"IPACodeForPA":null,"UpdateDate":"2023-07-08","UpdateTime":"10:12:34","ExemptionMaxAmountValidationType":"emaIndividual","ECommerceMerchantID":null,"UseBillToAddrToDetermineTax":"tNO","CreateDate":"2023-07-08","CreateTime":"10:08:30","DefaultTransporterEntry":null,"DefaultTransporterLineNumber":null,"FCERelevant":"tNO","FCEValidateBaseDelivery":"tNO","MainUsage":null,"EBooksVATExemptionCause":null,"LegalText":null,"DataVersion":2,"U_KAM":null,"U_GroupEntity":null,"U_RCMVendor":null,"U_TRCSDate":null,"U_TRCEDat":null,"U_Form10F":null,"U_NoPE":null,"U_ChannelPartner":null,"U_SourceType":null,"U_SalesRegion":null,"U_KAMRegion":null,"U_RCMVEN":"N","U_MSME_Catg":null,"U_Category":null,"U_Lost":"N","U_MSMEEndDate":null,"U_YearofSub":null,"U_206AB":"N","U_VDPO":"N","U_CSM":null,"U_MSMENo":null,"U_MSME":null,"U_DTAA":null,"U_AR_Cust_Ctgr":null,"U_AR_Dept":null,"U_PANVal":"N","U_PANErrMsg":null,"U_BANKVal":"N","U_BNKErrMsg":null,"U_MSMEErrMsg":null,"U_206ABErrMsg":null,"U_MCAVal":"N","U_MCAErrMsg":null,"U_CINNo":null,"U_Customer":null,"U_AR_Segment":null,"U_AR_BU":null,"U_LTDC":null,"U_SF_Account":null,"U_SF_Team":null,"U_SF_R":null,"U_Active_ARR":null,"U_AR_Coll_Mgr":null,"U_AR_Owner":null,"U_CSM1":null,"U_Date":null,"U_Time":null,"U_Balance":null,"U_Parent":"Y","U_ParentCode":null,"U_ParentDB":"DEFMACROFINAL","ElectronicProtocols":[{"ProtocolCode":"edpc_EWB","GenerationType":null,"MappingID":0},{"ProtocolCode":"edpc_GEN","GenerationType":null,"MappingID":0}],"BPAddresses":[{"AddressName":"Bill to","Street":null,"Block":null,"ZipCode":null,"City":null,"County":null,"Country":"IN","State":"MH","FederalTaxID":null,"TaxCode":null,"BuildingFloorRoom":"","AddressType":"bo_BillTo","AddressName2":null,"AddressName3":null,"TypeOfAddress":null,"StreetNo":null,"BPCode":"AAJCD5643C","RowNum":0,"GlobalLocationNumber":null,"Nationality":null,"TaxOffice":null,"GSTIN":"27AAJCD5643C1ZR","GstType":"gstRegularTDSISD","CreateDate":"2023-07-08","CreateTime":"10:08:30","MYFType":null,"TaasEnabled":"tYES","U_UTL_ST_ThLegName":null,"U_UTL_ST_ThTrdName":null,"U_SEZ_GST":"N","U_GSTStatus":null,"U_TaxPayer":null,"U_GSTErrorMsg":null,"U_CmpType":null},{"AddressName":"Ship To","Street":null,"Block":null,"ZipCode":null,"City":null,"County":null,"Country":"IN","State":"MH","FederalTaxID":null,"TaxCode":null,"BuildingFloorRoom":"","AddressType":"bo_ShipTo","AddressName2":null,"AddressName3":null,"TypeOfAddress":null,"StreetNo":null,"BPCode":"AAJCD5643C","RowNum":1,"GlobalLocationNumber":null,"Nationality":null,"TaxOffice":null,"GSTIN":"27AAJCD5643C1ZR","GstType":"gstRegularTDSISD","CreateDate":"2023-07-08","CreateTime":"10:08:30","MYFType":null,"TaasEnabled":"tYES","U_UTL_ST_ThLegName":null,"U_UTL_ST_ThTrdName":null,"U_SEZ_GST":"N","U_GSTStatus":null,"U_TaxPayer":null,"U_GSTErrorMsg":null,"U_CmpType":null}],"ContactEmployees":[],"BPAccountReceivablePaybleCollection":[],"BPPaymentMethods":[{"PaymentMethodCode":"01","RowNumber":0,"BPCode":"AAJCD5643C"}],"BPWithholdingTaxCollection":[],"BPPaymentDates":[],"BPBranchAssignment":[{"BPCode":"AAJCD5643C","BPLID":1,"DisabledForBP":"tNO"},{"BPCode":"AAJCD5643C","BPLID":3,"DisabledForBP":"tNO"},{"BPCode":"AAJCD5643C","BPLID":4,"DisabledForBP":"tNO"},{"BPCode":"AAJCD5643C","BPLID":5,"DisabledForBP":"tNO"},{"BPCode":"AAJCD5643C","BPLID":6,"DisabledForBP":"tNO"}],"BPBankAccounts":[],"BPFiscalTaxIDCollection":[{"Address":"","CNAECode":null,"TaxId0":null,"TaxId1":null,"TaxId2":null,"TaxId3":null,"TaxId4":null,"TaxId5":null,"TaxId6":null,"TaxId7":null,"TaxId8":null,"TaxId9":null,"TaxId10":null,"TaxId11":null,"BPCode":"AAJCD5643C","AddrType":"bo_ShipTo","TaxId12":"AAJCD5643C","TaxId13":null,"AToRetrNFe":"tNO"}],"DiscountGroups":[],"BPIntrastatExtension":{},"BPBlockSendingMarketingContents":[]} '	;	**/
        Map<String, Object> singleSAPrecordresponse = fetchBusinessPartnerBasedOnCondition( cardCode,billingEntity );
        for( String thisSTR : singleSAPrecordresponse.keySet() ){
            
        }
    }
    
    
    public static List<Object> fetchAllBusinessPartnersFromSAP(String billingEntity){
        
        SAP_Integration_Settings_metadata__mdt retrivedMetadata = CTX_SAPAPICallouts.getIntergartionMetadata(billingEntity);
        String 							sessionId 	= CTX_SAPAPICallouts.authorize(retrivedMetadata);
        SAP_Integration_Settings__c 	SAP_CONFIGS = SAP_Integration_Settings__c.getOrgDefaults();
        system.debug('sessionId: ' + sessionId); 
        
        String 			endPoint	= 'https://www.clear-sap.in:50000/b1s/v1/BusinessPartners';
        HttpRequest 	request 	= new HttpRequest();
        HttpResponse   	response;
        
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Cookie', 'B1SESSION='+sessionId);
        request.setTimeout(90000);
        response = new http().send(request);
        
        system.debug('request: '+request);
        system.debug('response: '+response.getBody());
        
        if( response != NULL && response.getBody() != NULL ){
            return (List<Object>)JSON.deserializeUntyped( response.getBody() );
        } else{
            return NULL;
        }
        
    }
    
    public static Map<String, Object> fetchBusinessPartnerBasedOnCondition( String cardCode,String billingEntity ){
        
        
        SAP_Integration_Settings_metadata__mdt retrivedMetadata = CTX_SAPAPICallouts.getIntergartionMetadata(billingEntity);
        String 							sessionId 	= CTX_SAPAPICallouts.authorize(retrivedMetadata);
        SAP_Integration_Settings__c 	SAP_CONFIGS = SAP_Integration_Settings__c.getOrgDefaults();
        system.debug('##sessionId: ' + sessionId); 
        
        String  		endPoint 	= 'https://www.clear-sap.in:50000/b1s/v1/BusinessPartners' + '(CardCode=\''+cardCode+'\')';
        HttpRequest 	request 	= new HttpRequest();
        HttpResponse   	response;
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Cookie', 'B1SESSION='+sessionId);
        request.setTimeout(90000);
        response = new http().send(request);
        
        system.debug('request: '+request);
        system.debug('response: '+response.getBody());
        
        
        if( response != NULL && response.getBody() != NULL ){
            return (Map<String, Object>)JSON.deserializeUntyped( response.getBody() );
        } else{
            return NULL;
        }
        
    }
    
    
    public static String fetchCardCode( String billingPan,String billingEntity ){
        
        
        SAP_Integration_Settings_metadata__mdt retrivedMetadata = CTX_SAPAPICallouts.getIntergartionMetadata(billingEntity);
        
        
        String baseURL 			= 'https://www.clear-sap.in:50000/b1s/v1/$crossjoin(BusinessPartners,BusinessPartners/BPFiscalTaxIDCollection)';
        String pathParamExpand 	= '?$expand=BusinessPartners($select=CardCode),BusinessPartners/BPFiscalTaxIDCollection($select=TaxId0)&';
        String pathParamFilter 	= '$filter=BusinessPartners/CardCode eq BusinessPartners/BPFiscalTaxIDCollection/BPCode and BusinessPartners/BPFiscalTaxIDCollection/TaxId0 eq '+billingPan;
        
        
        //  String 							sessionId 	= CTX_SAPAPICallouts.authorize(retrivedMetadata);
        String 							sessionId 	= CTX_SAPAPICallouts.login(retrivedMetadata);
        //SAP_Integration_Settings_metadata__mdt 	SAP_CONFIGS = new SAP_Integration_Settings_metadata__mdt();
        
        system.debug('metadat billingEntity '+billingEntity);
        
        
        // SAP_Integration_Settings_metadata__mdt 	SAP_CONFIGS = SAP_Integration_Settings__c.getOrgDefaults();
        system.debug('##sessionId: ' + sessionId); 
        system.debug('##billingEntity: ' + billingEntity); 
        
        String  		endPoint 	= 'https://www.clear-sap.in:50000/b1s/v1/$crossjoin(BusinessPartners,BusinessPartners/BPFiscalTaxIDCollection)?%24expand=BusinessPartners(%24select%3DCardCode%2CCardName)%2CBusinessPartners%2FBPFiscalTaxIDCollection(%24select%3DTaxId0%2CTaxId12)&%24filter=BusinessPartners%2FCardCode%20eq%20BusinessPartners%2FBPFiscalTaxIDCollection%2FBPCode%20and%20BusinessPartners%2FBPFiscalTaxIDCollection%2FTaxId0%20eq%20%27'+billingPan+'%27 ';/**	baseURL+pathParamExpand+pathParamFilter;	**/
        system.debug('endPoint: '+endPoint);
        HttpRequest 	request 	= new HttpRequest();
        HttpResponse   	response;
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Cookie', 'B1SESSION='+sessionId);
        request.setTimeout(90000);
        response = new http().send(request);
        
        system.debug('request: '+request);
        system.debug('response: '+response.getBody());
        system.debug('response code: '+response.getStatusCode());
        if(response.getStatusCode() == 200){
            
            Map<String, Object> 	responseMap = (Map<String, Object>)JSON.deserializeUntyped( response.getBody() );
            List<Object> 			Values 		= (List<Object>)responseMap.get('value');
            Map<String, Object> 	bpMap 		= (Map<String, Object>)Values[0];
            
            system.debug('responseMap: '+responseMap);
            system.debug('Values: '+Values);
            system.debug('bpMap: '+bpMap);
            system.debug('bpMap.keySet().Contains: '+bpMap.keySet().Contains('CardCode'));
            system.debug('String.valueOf(bpMap.get:'+(String)((Map<String, Object>)bpMap.get('BusinessPartners')).get('CardCode'));
            
            if(((String)((Map<String, Object>)bpMap.get('BusinessPartners')).get('CardCode') !='') && ((String)((Map<String, Object>)bpMap.get('BusinessPartners')).get('CardCode')!= 'null')){
                return (String)((Map<String, Object>)bpMap.get('BusinessPartners')).get('CardCode');
            }
            else{
                return NULL;
            }
        }
        else{
            return NULL;
        }
    }
    
    
}