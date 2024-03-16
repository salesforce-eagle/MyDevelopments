/** Auto Renew - Update Contact/Billing/TDS Applicable **/
@RestResource(urlMapping='/updateRenewalDetails')
global class CTX_UpdateRenewalDetails
{
    
    @HttpPut
    global static string updateRenewalDetails() {
        
        Map<String, Object> renewalDetails = (Map<String, Object>)System.JSON.deserializeUntyped( 
            RestContext.request.requestBody.toString()
        );
        
        System.debug('@renewalDetails'+renewalDetails);
        String response = '';
        String 					licenseId 			= (String)renewalDetails?.get('licenseId');
        
        Map<String, Object> 	companyInfo 		= (Map<String, Object>)renewalDetails?.get('billingAddress');
        
        String 					billingGSTIN 		= (String)companyInfo?.get('billingGSTIN');
        String 					legalEntityName 	= (String)companyInfo?.get('legalEntityName');
        String 					billingAddress  	= (String)companyInfo?.get('billingAddress');
        String 					shippingAddress 	= (String)companyInfo?.get('shippingAddress');
        String 					state				= (String)companyInfo?.get('state');
        String 					pincode				= (String)companyInfo?.get('pincode');
        
        Map<String, Object> 	tdsDetails 			= (Map<String, Object>)renewalDetails?.get('tdsDetails');
        
        Boolean 				isTDSApplicable  	= (Boolean)tdsDetails?.get('isTDSApplicable');
        String 					customerTAN 		= (String)tdsDetails?.get('customerTAN');
        
        Decimal					applicableTDS;
        
        if( tdsDetails?.get('applicableTDS') != NULL && tdsDetails?.get('applicableTDS') != 'null' && tdsDetails?.get('applicableTDS') != '' ){
            applicableTDS =  Decimal.valueOf((string)tdsDetails?.get('applicableTDS'));
        } else{
            applicableTDS = 0;
        }
        system.debug('applicableTDS: '+applicableTDS);
        
        Map<String, Object> 	contactInfo 		= (Map<String, Object>)renewalDetails?.get('contactInformation');
        
        String 					name 				= (String)contactInfo?.get('name');
        String 					email 				= (String)contactInfo?.get('email');
        String 					phone 				= (String)contactInfo?.get('phoneNumber');
        
        List<Logger__c>		     logFailures		= new List<Logger__c>();
        
        List<SObject> 			updateObjects 		= new List<SObject>();
        
        List<QuoteLineItem> renewalQLIs = Database.query('SELECT Id, Product2Id, Over_Usage_Charge__c, Total_Tax_Value__c, TDS_Price__c,Total_Renewal_Price__c ,Is_TDS_Applicable__c ,Product2.Name,Product_Formula__c,UnitPrice,Sale_Price__c,Is_Formula_Price_Applicable__c,Quote.OpportunityId,Quote.Opportunity.Billing_Address__c,Quote.Opportunity.Shipping_Address__c, Quote.Opportunity.State_2__c,Quote.Opportunity.Pincode__c,Quote.Opportunity.Legal_Entity_Name_Of_The_Client__c,Quote.Opportunity.Billing_GST__c,Parent_Asset__r.License_ID__c,Quote.Opportunity.E_Sign_Customer_Info__r.Name, Quote.Opportunity.E_Sign_Customer_Info__c, Quote.Opportunity.E_Sign_Customer_Info__r.Email, Quote.Opportunity.E_Sign_Customer_Info__r.Phone,' + 'No_of_PAN_one__c,No_of_GSTIN_one__c,No_of_User_ID_one__c,No_of_IRNs__c,Number_of_eway_bill__c,No_of_expected_B2C_invoices_for_QR_code__c' + ' FROM QuoteLineItem WHERE Parent_Asset__r.License_Id__c =: licenseId');
        
        if(renewalQLIs.size()>0){
            
            Opportunity renewalOpp = new Opportunity(Id = renewalQLIs[0].Quote.OpportunityId);
            renewalOpp.Billing_GST__c 						= billingGSTIN;
            renewalOpp.Legal_Entity_Name_Of_The_Client__c 	= legalEntityName;
            renewalOpp.Billing_Address__c 					= billingAddress;
            renewalOpp.Shipping_Address__c					= shippingAddress;
            renewalOpp.State_2__c 							= state;	
            renewalOpp.Pincode__c 							= pincode;
            
            updateObjects.add(renewalOpp);
            
            QuoteLineItem renewalQli = renewalQLIs[0];
            
            // TDS Calculator
            
            Decimal tdsPrice = 0;
            Decimal basePrice = renewalQli.Over_Usage_Charge__c + renewalQli.Sale_Price__c;
            Decimal pricePostTDSDeduction = 0;
            //renewalQli.Over_Usage_Charge__c + renewalQli.Sale_Price__c
            if(renewalQli.Is_TDS_Applicable__c && isTDSApplicable){
                
                tdsPrice = (basePrice * applicableTDS)/100;
                pricePostTDSDeduction = basePrice - tdsPrice;
                
                renewalQli.Total_Renewal_Price__c = pricePostTDSDeduction + renewalQli.Total_Tax_Value__c;
                
                renewalQli.TDS_Price__c = tdsPrice;
                
            }else if(renewalQli.Is_TDS_Applicable__c && !isTDSApplicable){
                
                renewalQli.Total_Renewal_Price__c = basePrice + renewalQli.TDS_Price__c + renewalQli.Total_Tax_Value__c ;
                
            }else if(!renewalQli.Is_TDS_Applicable__c && isTDSApplicable){
                
                tdsPrice = (basePrice * applicableTDS)/100;
                pricePostTDSDeduction = basePrice - tdsPrice;
                
                renewalQli.Total_Renewal_Price__c = pricePostTDSDeduction + renewalQli.Total_Tax_Value__c;
                
                renewalQli.TDS_Price__c = tdsPrice;
                
            }else if(!renewalQli.Is_TDS_Applicable__c && !isTDSApplicable){
                
            }
            
            renewalQli.Is_TDS_Applicable__c					= isTDSApplicable;
            renewalQli.TAN_Number__c 						= customerTAN ;
            renewalQli.Applicable_TDS__c					= applicableTDS;
            
            updateObjects.add(renewalQli);
            
            Contact thisCon = new Contact(Id =  renewalQLIs[0].Quote.Opportunity.E_Sign_Customer_Info__c);
            thisCon.FirstName  	= '';
            thisCon.LastName	= name;
            thisCon.Phone 		= phone;
            thisCon.Email 		= email;
            
            updateObjects.add(thisCon);
            
            
            try{
                OpportunityConstants.AUTO_RENEW_RULE 			= FALSE;
                QuoteConstants.ISFIRSTTIMEQLI 					= FALSE;
                RecursiveTriggerHandler.isFirstTimeOpportunity 	= FALSE;
                QuoteConstants.ISFIRSTTIMEQUOTE 				= FALSE;
                Database.update(updateObjects);
                response = 'Success';
                
            }catch(Exception ex){
                response = ex.getMessage();
                logFailures.add(
                    CTX_LoggerImplementation.createLoggerInstance(
                        ex.getMessage(), 
                        'ClassId', 
                        'CTX_UpdateRenewalDetails', 
                        '', 
                        'Update Renewal Details - Failure',
                        NULL,
                        'UpdateRenewalDetails'
                    )
                );
            }
            
            try{
                insert logFailures;
            } catch(Exception ex){
                system.debug('Logger Insert Failed - CTX_UpdateRenewalDetails: '+ex.getMessage());
            }   
            
        }else{
            CalloutException e = new CalloutException();
            e.setMessage('Whitelisting not enabled for this license!');
            throw e;
        }
        
        System.debug('@response'+response);
        if(response != 'Success'){
            
            CalloutException e = new CalloutException();
            e.setMessage(response);
            throw e;
        }
        return response;
        
    }
    
    
}