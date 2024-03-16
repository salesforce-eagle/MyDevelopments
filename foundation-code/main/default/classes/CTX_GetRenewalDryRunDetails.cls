@RestResource(urlMapping='/getRenewalDryRunDetails')
global class CTX_GetRenewalDryRunDetails {

    @HttpPost
    global static RenewalWrapper renewLicense(){
        
        RestRequest 		request			= RestContext.request;
        String 				requestBody 	= request.requestBody.toString();
        
        CTX_LicenseMetadataParser.LicenseWrapper licenseWrap = CTX_LicenseMetadataParser.convertLicenseDetails(requestBody);
        
        /**	**/
        List<String>						fieldList	= new List<String>();
        Schema.SObjectType 					targetType 	= Schema.getGlobalDescribe().get('Opportunity');
        Map<String, Schema.SObjectField> 	fieldMap 	= targetType.getDescribe().fields.getMap();
        
        for( Schema.SObjectField field : fieldMap.values() ){
            fieldList.add(field.getDescribe().getName());
        }
        
        /**	**/
        String licenseId 							= licenseWrap.licenseId;
        String planTier 							= licenseWrap.planTier;
        Map<String, Integer> 	usageParams 		= licenseWrap.usageMap;
        
        Map<String, Auto_Renewal_Constraints__mdt> resourceConstraintMap = getMetadataDetails(planTier);
        RenewalWrapper 			renewalWrap 		= new RenewalWrapper();
        /**	Price Lock Feature	**/
        List<QuoteLineItem> 	renewalQLIs = Database.query('SELECT Id,Is_TDS_Applicable__c ,Period_Start_date__c,Period_End_date__c ,Over_Usage_Charge__c ,No_of_EWBs__c ,Quote.OpportunityId, Quote.Opportunity.Account.Name, Quote.Opportunity.Account.Bank_Account_Name__c, Quote.Opportunity.Account.Account_Number__c, Quote.Opportunity.Is_Auto_Renewal_Enabled__c ,Quote.Opportunity.Account.Bank_Branch__c, Quote.Opportunity.Account.Bank_IFSC_Code__c , Quote.Opportunity.Account.Bank_Name__c,Quote.Opportunity.Account.Bank_Swift_Code__c , Product2Id,Product2.Name,Product_Formula__c,Applicable_TDS__c,TAN_Number__c,UnitPrice,Sale_Price__c,Is_Formula_Price_Applicable__c,Is_Price_Locked__c,Renewal_Service_Payload__c,Quote.Opportunity.Billing_Address__c,Quote.Opportunity.Shipping_Address__c, Quote.Opportunity.State_2__c,Quote.Opportunity.Pincode__c,Quote.Opportunity.Legal_Entity_Name_Of_The_Client__c,Quote.Opportunity.Billing_GST__c,Parent_Asset__r.License_ID__c,Quote.Opportunity.E_Sign_Customer_Info__r.Name,Quote.Opportunity.E_Sign_Customer_Info__r.Email, Quote.Opportunity.E_Sign_Customer_Info__r.Phone,' + 'No_of_PAN_one__c,No_of_GSTIN_one__c,No_of_User_ID_one__c,No_of_IRNs__c,Number_of_eway_bill__c,No_of_expected_B2C_invoices_for_QR_code__c' + ' FROM QuoteLineItem WHERE Parent_Asset__r.License_Id__c =: licenseId');
        QuoteLineItem 			renewalQli;
        
        if(planTier != 'EINVOICE_STANDARD' && planTier != 'EINVOICE_ULTIMATE'){
            renewalWrap.errorMessage = 'Plan Tier should be EINVOICE_STANDARD/EINVOICE_ULTIMATE';
        }
        
        if(renewalWrap.errorMessage == NULL){
            if( renewalQLIs != NULL && renewalQLIs.size() > 0){
                
                renewalQli = renewalQLIs[0];
                if(!renewalQli.Is_Price_Locked__c){
                    renewalQli	= calculateRenewalParameterAndPrice(licenseId, planTier, usageParams);
                }
                
                if(!renewalQli.Quote.Opportunity.Is_Auto_Renewal_Enabled__c && renewalQli.Renewal_Service_Payload__c != NULL){
                    renewalWrap = 
                        (CTX_GetRenewalDryRunDetails.RenewalWrapper)JSON.deserializeStrict(
                            renewalQli.Renewal_Service_Payload__c, 
                            CTX_GetRenewalDryRunDetails.RenewalWrapper.Class
                        );
                }else{
                    
                    /** License ID **/
                    renewalWrap.licenseId						= renewalQli.Parent_Asset__r.License_ID__c;
                    
                    /** Renewal Price **/
                    renewalWrap.renewalDetails.renewalLicensePricingDetails.planPrice 			= renewalQli.Sale_Price__c;
                    
                    /** Product Info **/
                    renewalWrap.ProductDetails.name 			= renewalQli.Product2.Name;
                    
                    /** Validity **/
                    renewalWrap.validity.startAt 				= renewalQli.Period_Start_date__c;
                    renewalWrap.validity.endAt 					= renewalQli.Period_End_date__c;
                    
                    /** Contact Info **/
                    renewalWrap.contactInformation.name 		= renewalQli.Quote.Opportunity.E_Sign_Customer_Info__r.Name;
                    renewalWrap.contactInformation.email 		= renewalQli.Quote.Opportunity.E_Sign_Customer_Info__r.Email;
                    renewalWrap.contactInformation.phoneNumber  = renewalQli.Quote.Opportunity.E_Sign_Customer_Info__r.Phone;
                    
                    /** Billing Info **/
                    renewalWrap.billingAddress.billingGSTIN     = renewalQli.Quote.Opportunity.Billing_GST__c;
                    renewalWrap.billingAddress.legalEntityName  = renewalQli.Quote.Opportunity.Legal_Entity_Name_Of_The_Client__c;
                    renewalWrap.billingAddress.billingAddress	= renewalQli.Quote.Opportunity.Billing_Address__c;
                    renewalWrap.billingAddress.shippingAddress	= renewalQli.Quote.Opportunity.Shipping_Address__c;
                    renewalWrap.billingAddress.state			= renewalQli.Quote.Opportunity.State_2__c;
                    renewalWrap.billingAddress.pincode			= renewalQli.Quote.Opportunity.Pincode__c;
                    
                    /** Tax Info **/
                    renewalQli.Over_Usage_Charge__c = renewalQli.Over_Usage_Charge__c != NULL ? renewalQli.Over_Usage_Charge__c : 0;

                    
                    
                    /** Renewal Parameters **/
                    for(Auto_Renewal_Constraints__mdt mdtRec 	: resourceConstraintMap.values()){
                        
                        RenewalParameters renewParam 			= new RenewalParameters();
                        
                        renewParam.resource 					= mdtRec.Resource__c;
                        renewParam.threshold			    	= ((Decimal)renewalQli.get(mdtRec.Quote_Line_Item_Field__c)).IntValue();
                        renewParam.constraintType				= 'THRESHOLD';
                        renewParam.displayName 					= mdtRec.Display_Text__c;
                        
                        renewalWrap.renewalDetails.renewalParameters.add(renewParam);
                    }
                    
                    /** Overusage **/
                    renewalWrap.renewalDetails.renewalLicensePricingDetails.overusageCharge 	= renewalQli.Over_Usage_Charge__c;
                    
                    Decimal tdsPrice = 0;
                    Decimal basePrice  = (renewalQli.Over_Usage_Charge__c + renewalQli.Sale_Price__c);
                    tdsPrice = renewalQli.Is_TDS_Applicable__c && renewalQli.Applicable_TDS__c 	!= NULL ? ( (basePrice  * renewalQli.Applicable_TDS__c)/100 ) : 0;
                    renewalQli.TDS_Price__c = tdsPrice;
                    
                    Decimal totalPriceAfterTdsDeduction = (basePrice - tdsPrice);
                    
                    if(renewalQli.Quote.Opportunity.State_2__c 		== 'Karnataka'){
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.sgstTaxValue  			=  (basePrice * 9)/100;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.cgstTaxValue  			=  (basePrice * 9)/100;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.igstTaxValue  			=  0;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.sgstTaxRate 	=  9;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.cgstTaxRate 	=  9;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.igstTaxRate 	=  0;
                    }else{
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.sgstTaxValue 			=  0;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.cgstTaxValue 			=  0;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.igstTaxValue 			=  (basePrice * 18)/100;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.sgstTaxRate	=  0;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.cgstTaxRate	=  0;
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.igstTaxRate	=  18;
                    }
                    
                    
                    renewalQli.Total_Tax_Value__c = renewalWrap.renewalDetails.renewalLicensePricingDetails.sgstTaxValue  + 
                        							renewalWrap.renewalDetails.renewalLicensePricingDetails.cgstTaxValue  + 
                        							renewalWrap.renewalDetails.renewalLicensePricingDetails.igstTaxValue;
                    /** Total Payable Price **/
                    renewalWrap.renewalDetails.renewalLicensePricingDetails.totalOrderValue  	= 
                        totalPriceAfterTdsDeduction + 
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.sgstTaxValue  + 
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.cgstTaxValue  + 
                        renewalWrap.renewalDetails.renewalLicensePricingDetails.igstTaxValue ;
                    
                    /** TDS Applicable **/
                    renewalWrap.tdsDetails.isTDSApplicable		= renewalQli.Is_TDS_Applicable__c;
                    renewalWrap.tdsDetails.applicableTDS 		= renewalQli.Applicable_TDS__c;
                    renewalWrap.tdsDetails.customerTAN 			= renewalQli.TAN_Number__c;
                    
                    
         
                    renewalWrap.bankDetail.accountName			= renewalQli.Quote.Opportunity.Account.Bank_Account_Name__c;
                    renewalWrap.bankDetail.accountNumber		= renewalQli.Quote.Opportunity.Account.Account_Number__c;
                    renewalWrap.bankDetail.bankName				= renewalQli.Quote.Opportunity.Account.Bank_Name__c;
                    renewalWrap.bankDetail.ifscCode				= renewalQli.Quote.Opportunity.Account.Bank_IFSC_Code__c;
                    renewalWrap.bankDetail.branch				= renewalQli.Quote.Opportunity.Account.Bank_Branch__c;
                    renewalWrap.bankDetail.swiftCode			= renewalQli.Quote.Opportunity.Account.Bank_Swift_Code__c != NULL ? renewalQli.Quote.Opportunity.Account.Bank_Swift_Code__c : '100';
                    
   
                    
                    System.debug('@renewalDetails'+JSON.serialize(renewalWrap));
                    
                }
                
                
                renewalQli.Renewal_Service_Payload__c = JSON.serialize(renewalWrap);
                renewalQli.Is_Price_Locked__c = TRUE;
                renewalQli.Total_Renewal_Price__c = renewalWrap.renewalDetails.renewalLicensePricingDetails.totalOrderValue;
                
                
                return renewalWrap;
            } else{
                renewalWrap.errorMessage = 'No matching license found.';
                return renewalWrap;
            }
            
        }else{
            return renewalWrap;
        }
        
        
    }
    
    global static QuoteLineItem calculateRenewalParameterAndPrice( 
        String 					licenseId, 
        String 					planTier, 
        Map<String, Integer> 	usageParams 
    ){
        System.debug('@planTier'+planTier);
        Map<String, Auto_Renewal_Constraints__mdt> 		resourceConstraintMap 	= getMetadataDetails(planTier);
        AutoRenewal_Plan_Tier_Configs_Metadata__mdt 	configsMDT 				= [SELECT Id, Plan_Tier__c, Over_Usage_Formula__c FROM AutoRenewal_Plan_Tier_Configs_Metadata__mdt WHERE Plan_Tier__c =: planTier];
        List<String> fieldsToQuery = new List<String>(resourceConstraintMap.keySet());
        String assetQueryString = 'SELECT Id, Name, Price, PurchaseDate, UsageEndDate, Status, License_Id__c, ' + String.join(fieldsToQuery,',') + ' FROM Asset WHERE License_Id__c =: licenseId' ;
        
        system.debug('assetQueryString: '+assetQueryString);
        List<Asset> assetsToRenew = database.query(assetQueryString);
        system.debug('assetToRenew: '+assetsToRenew.size());
        QuoteLineItem renewalQLI = new QuoteLineItem();
        
        if(assetsToRenew.size()>0){
            
            /** Extrapolation Logic Start **/
            Asset assetToRenew = assetsToRenew[0];
            Decimal daysSinceLicenseStart 	= assetToRenew.PurchaseDate.daysBetween(System.today()); 
            Decimal ExtrapolatedIRNUsage 	= usageParams.get('IRN_GENERATION') != NULL ? ((Decimal)usageParams.get('IRN_GENERATION')/daysSinceLicenseStart) * 364 : 0;
            Decimal ExtrapolatedEWBUsage 	= usageParams.get('EWB_GENERATION') != NULL ? ((Decimal)usageParams.get('EWB_GENERATION')/daysSinceLicenseStart) * 364 : 0;
            
            usageParams.put('IRN_GENERATION', ExtrapolatedIRNUsage.round().intValue());
            usageParams.put('EWB_GENERATION', ExtrapolatedEWBUsage.round().intValue());
            /** Extrapolation Logic End **/
            
            System.debug('##UsageParams: '+ usageParams);
            Decimal usageTotalInvoice 	= usageParams.get('IRN_GENERATION') + usageParams.get('EWB_GENERATION');
            Decimal actualTotalInvoice 	= assetToRenew.License_no_of_irns_per_year__c + assetToRenew.Number_of_eway_bill__c;
            Id assetId = assetToRenew.Id;
            
            List<QuoteLineItem> renewalQLIs = Database.query('SELECT Id, Is_TDS_Applicable__c,Renewal_Service_Payload__c ,Quote.Opportunity.Is_Auto_Renewal_Enabled__c,Quote.Opportunity.Account.Channel_Partner_Account__c, Quote.Opportunity.Account.Channel_Partner_Account__r.Name,Quote.Opportunity.Account.Name,Quote.Opportunity.Account.Bank_Account_Name__c, Quote.Opportunity.Account.Account_Number__c, Quote.Opportunity.Account.Bank_Branch__c, Quote.Opportunity.Account.Bank_IFSC_Code__c , Quote.Opportunity.Account.Bank_Name__c,Quote.Opportunity.Account.Bank_Swift_Code__c ,Product2Id,Product2.Name,Applicable_TDS__c,TAN_Number__c,Product_Formula__c,UnitPrice,Sale_Price__c,Is_Formula_Price_Applicable__c,Is_Price_Locked__c,Quote.Opportunity.Billing_Address__c,Quote.Opportunity.Shipping_Address__c, Quote.Opportunity.State_2__c,Quote.Opportunity.Pincode__c,Quote.Opportunity.Legal_Entity_Name_Of_The_Client__c,Quote.Opportunity.Billing_GST__c,Parent_Asset__r.License_ID__c,Quote.Opportunity.E_Sign_Customer_Info__r.Name,Quote.Opportunity.E_Sign_Customer_Info__r.Email, Quote.Opportunity.E_Sign_Customer_Info__r.Phone,' + 'No_of_PAN_one__c,No_of_GSTIN_one__c,No_of_User_ID_one__c,No_of_IRNs__c,Number_of_eway_bill__c,No_of_expected_B2C_invoices_for_QR_code__c' + ' FROM QuoteLineItem WHERE Parent_Asset__c =: assetId');
            
            if(renewalQLIs.size() > 0){
                Decimal quotePrice 				= 0;
                Decimal cappedQuotePrice 		= 0;
                Decimal finalPrice 				= 0;
                Decimal fairPrice 				= 0;
                Decimal overUsageCharges 		= 0;
                Decimal previousSellingPrice	= assetToRenew.Price; 
                renewalQLI 						= renewalQLIs[0].clone(false, false, false, false);
                String 	overUsageFormula		= configsMDT.Over_Usage_Formula__c;
                
                System.debug('##overUsageFormula: '+overUsageFormula);
                
                renewalQLI.Id = renewalQLIs[0].Id;
                if(usageTotalInvoice <= (1.1 * actualTotalInvoice)){
                    overUsageCharges = 0;
                } else {
                    for(Auto_Renewal_Constraints__mdt mdtRec : resourceConstraintMap.values()){
                        Decimal overuse = Math.max(((Decimal)usageParams.get(mdtRec.Resource__c) - (Decimal)assetToRenew.get(mdtRec.Asset_Field__c)), 0);
                        renewalQLI.put(mdtRec.Quote_Line_Item_Field__c, overuse);
                    }
                    overUsageCharges = CTX_CustomStringToFormulaParser.customFormulaPriceCalculator(renewalQLI, overUsageFormula);
                    overUsageCharges = overUsageCharges.round();
                }
                
                for(Auto_Renewal_Constraints__mdt mdtRec : resourceConstraintMap.values()){
                    renewalQLI.put(mdtRec.Quote_Line_Item_Field__c, usageParams.get(mdtRec.Resource__c));
                }
                system.debug('##QLI: ' + renewalQLI);
                
                Decimal usagePrice 	= CTX_CustomStringToFormulaParser.customFormulaPriceCalculator(renewalQLI, renewalQLI.Product_Formula__c);
                system.debug('##overUsageCharges: ' + overUsageCharges);
                system.debug('##usagePrice: ' + usagePrice);
                
                
                if(usageTotalInvoice < actualTotalInvoice){
                    quotePrice = Math.max(50000, 1.3 * previousSellingPrice);
                } else {
                    
                    quotePrice = previousSellingPrice < usagePrice ? Math.max((1.3*previousSellingPrice), usagePrice) : (1.3 * previousSellingPrice);
                        }
                
                system.debug('##quotePrice: ' + quotePrice);
                
                cappedQuotePrice 	= quotePrice > (2.5 * previousSellingPrice) ? (2.5 * previousSellingPrice) : quotePrice;
                system.debug('##cappedQuotePrice: ' + cappedQuotePrice);
                
                finalPrice 			= previousSellingPrice > usagePrice ? (1.2 * previousSellingPrice) : Math.max((1.2 * previousSellingPrice), Math.min(cappedQuotePrice, usagePrice));
                system.debug('##finalPrice1: ' + finalPrice);
                
                System.debug('@usageTotalInvoice'+usageTotalInvoice);
                
                If(usageTotalInvoice <= 10000 && 
                   (renewalQLI.Quote.Opportunity.Account.Channel_Partner_Account__c == NULL ||
					(renewalQLI.Quote.Opportunity.Account.Channel_Partner_Account__c != NULL &&
                     !renewalQLI.Quote.Opportunity.Account.Channel_Partner_Account__r.Name.containsIgnoreCase('uneecop'))))
                {
                    System.debug('@previousSellingPrice'+previousSellingPrice);
                    if(previousSellingPrice < 35000){
                        fairPrice = 35000;
                    }else if(previousSellingPrice >= 50000){
                        fairPrice = finalPrice;
                    }else{
                        fairPrice = (1.15 * previousSellingPrice);
                    }
                    
                }else{
                    fairPrice = finalPrice;
                }
                
                Decimal fairPriceFraction 	= ((Decimal)fairPrice).round() / 1000;
                fairPrice					= fairPriceFraction.setScale(1) * 1000;
                
                system.debug('##fairPrice: ' + fairPrice);
                system.debug('usageParams: '+usageParams);
                system.debug('assetToRenew: '+assetToRenew);
                for(Auto_Renewal_Constraints__mdt mdtRec : resourceConstraintMap.values()){
                    system.debug('mdtRec: '+mdtRec);
                    system.debug('mdtRec.Quote_Line_Item_Field__c: '+mdtRec.Quote_Line_Item_Field__c);
                    system.debug('mdtRec.Resource__c: '+mdtRec.Resource__c);
                    system.debug('mdtRec.Asset_Field__c: '+mdtRec.Asset_Field__c);
                    
                    renewalQLI.put(mdtRec.Quote_Line_Item_Field__c, Math.max((Decimal)usageParams.get(mdtRec.Resource__c), (Decimal)assetToRenew.get(mdtRec.Asset_Field__c)));
                    
                }
                
                renewalQLI.UnitPrice 			= fairPrice;
                renewalQLI.Sale_Price__c 		= fairPrice;
                renewalQLI.Over_Usage_Charge__c = 0;
                renewalQLI.Over_Usage_Charge__c	= overUsageCharges;
                if(assetToRenew.UsageEndDate >= System.today()){
                    renewalQLI.Period_Start_date__c = assetToRenew.UsageEndDate.addDays(1);
                    renewalQLI.Period_End_date__c	= assetToRenew.UsageEndDate.addYears(1);
                } else {
                    renewalQLI.Period_Start_date__c = assetToRenew.UsageEndDate.addDays(1);
                    renewalQLI.Period_End_date__c	= assetToRenew.UsageEndDate.addYears(1);
                }
                renewalQLI.Is_Formula_Price_Applicable__c = FALSE;
                renewalQLI.Usage_Parameters__c = JSON.serialize(usageParams);
                
                System.debug('@renewalQLI'+renewalQLI);
                
            }
            
        } else{
            
        }
        
        return renewalQLI;
        
    }
    
    public static Map<String, Auto_Renewal_Constraints__mdt> getMetadataDetails(String planTier){
        
        Map<String, Auto_Renewal_Constraints__mdt> resourceConstraintMap = new Map<String, Auto_Renewal_Constraints__mdt>();
        for( Auto_Renewal_Constraints__mdt thisRec : Auto_Renewal_Constraints__mdt.getAll().values() ){
            
            if(thisRec.Plan_Tier__c == planTier){
                resourceConstraintMap.put(thisRec.Asset_Field__c, thisRec);
            }
        }
        
        return resourceConstraintMap;
    } 
    
    
    /**	Wrapper Classes : START	**/
    Public Class ProductDetails{
        Public String name;
    }
    
    Public Class RenewalPrice{
        Public Decimal price;
    }
    
    Public Class RenewalParameters{
        Public String 	constraintType;
        Public String 	resource;
        Public Integer  threshold = 0;
        Public String 	displayName;
    }
    
    Public Class Validity{
        Public DateTime startAt;
        Public DateTime endAt;
    }
    
    Public Class ContactInformation{
        Public String name = ' ';
        Public String email= ' ';
        Public String phoneNumber= ' ';
    } 
    
    Public Class BillingDetails{
        Public String billingGSTIN;
        Public String legalEntityName;
        Public String billingAddress;
        Public String shippingAddress;
        Public String state;
        Public String pincode;
    }
    
    Public Class TDSDetails{
        Public Boolean isTDSApplicable;
        Public String  customerTAN;
        Public Decimal applicableTDS;
    }
    
    public class BankDetail {
        public string 		accountName;
        public string 		accountNumber;
        public string 		bankName;
        public string 		ifscCode;
        public string 		branch;
        public string 		swiftCode;
    }
    
    Public Class RenewalLicensePricingDetails{
        Public Decimal 			 		planPrice  			= 0;
        Public Decimal 			  		overusageCharge  	= 0;
        Public Decimal 			  		sgstTaxRate  		= 0;
        Public Decimal 			  		cgstTaxRate  		= 0;
        Public Decimal 			  		igstTaxRate  		= 0;
        Public Decimal 			  		sgstTaxValue  		= 0;
        Public Decimal 			  		cgstTaxValue  		= 0;
        Public Decimal 			  		igstTaxValue  		= 0;
        public Decimal					totalOrderValue  	= 0;
    } 
    
    Public Class RenewalDetails{ 
        public List<RenewalParameters> 	renewalParameters 	= new List<RenewalParameters>();
        public RenewalLicensePricingDetails renewalLicensePricingDetails  = new RenewalLicensePricingDetails();
    }
    
    global Class RenewalWrapper{
        Public  					String 				  licenseId;
        ProductDetails 				productDetails 		= new ProductDetails();
        Validity 					validity 			= new Validity();
        ContactInformation			contactInformation	= new ContactInformation();
        BillingDetails				billingAddress 		= new BillingDetails();
        RenewalDetails				renewalDetails		= new RenewalDetails(); 
        TdsDetails					tdsDetails			= new TdsDetails();
        BankDetail 					bankDetail			= new BankDetail();
        Public						string					errorMessage;
    }
    /**	Wrapper Classes : END	**/
    
 
}