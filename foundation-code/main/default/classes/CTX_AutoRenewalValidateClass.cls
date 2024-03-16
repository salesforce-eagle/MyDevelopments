public class CTX_AutoRenewalValidateClass {
    
    @AuraEnabled
    public static string getAutorenewalValidation(){
        
        Map<Id, String> 	assetAndErrorMessageMap = new Map<Id, String>();
        Map<Id, Asset> 		assetMap 				= new Map<Id, Asset>();
        Set<String>			getAssetIds				= readCSVInformation();
        String responseMessage = '';
        
        for( 
            Asset thisAsset : [ SELECT Id, Name, License_Id__c, AccountId, opportunity__c, Renewal_Opportunity__c, BackEndQuote__c, 
                               
                               Account.Name, Account.Onboarding_Owner__c, Account.Onboarding_Owner__r.Name,
                               
                               Account.Product_Email__c, Account.Bank_Account_Name__c, Account.Bank_Branch__c, Account.Bank_IFSC_Code__c, 
                               Account.Bank_Name__c, Account.Bank_Swift_Code__c, Account.Account_Number__c,
                               
                               opportunity__r.E_Sign_Customer_Info__c, opportunity__r.Billing_Address__c, 
                               opportunity__r.Shipping_Address__c, opportunity__r.State_2__c, Opportunity__r.Billing_GST__c,
                               
                               Renewal_Opportunity__r.E_Sign_Customer_Info__c, Renewal_Opportunity__r.Billing_Address__c, 
                               Renewal_Opportunity__r.Shipping_Address__c, Renewal_Opportunity__r.State_2__c, Renewal_Opportunity__r.Billing_GST__c,
                               
                               ( SELECT Id, QuoteId, Quote.OpportunityId FROM Quote_Line_Items__r )
                               
                               
                               FROM Asset WHERE Id IN :getAssetIds ]
        ){
            String captureErrorLog;
            
            /**	Asset Level Error	**/
            if( thisAsset.License_Id__c == NULL ){
                captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', License Id Missing' : 'License Id Missing';
            }
            if( thisAsset.BackEndQuote__c == NULL ){
                captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Backend Quote is Missing' : 'Backend Quote is Missing';
            }
            
            /**	Asset-Account Level Error	**/
            if( thisAsset.Account.Product_Email__c == NULL ){
                captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Product Email is Missing' : 'Product Email is Missing';
            }
            if( thisAsset.Account.Bank_Account_Name__c == NULL ){
                captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Bank account name is missing' : 'Bank account name is missing';
            }
            if( thisAsset.Account.Bank_Branch__c == NULL ){
                captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Bank branch name is missing' : 'Bank branch name is missing';
            }
            if( thisAsset.Account.Bank_IFSC_Code__c == NULL ){
                captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Bank IFSC is missing' : 'Bank IFSC is missing';
            }
            if( thisAsset.Account.Bank_Name__c == NULL ){
                captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Bank bank name is missing' : 'Bank bank name is missing';
            }
            if( thisAsset.Account.Bank_Swift_Code__c == NULL ){
                captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Bank bank swift code is missing' : 'Bank bank swift code is missing';
            }
            if( thisAsset.Account.Account_Number__c == NULL ){
                captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Bank account number is missing' : 'Bank account number is missing';
            }
            
            
            /**	Asset-Opportunity Level Error	**/
            if( thisAsset.opportunity__c != NULL ){
                if( thisAsset.Opportunity__r.Billing_GST__c == NULL ){
                    captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Billing GSTIN is missing' : 'Billing GSTIN is missing';
                }
                if( thisAsset.opportunity__r.E_Sign_Customer_Info__c == NULL ){
                    captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', E-Sign customer info is missing' : 'E-Sign customer info is missing';
                }
                if( thisAsset.opportunity__r.Billing_Address__c == NULL ){
                    captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Billing address is missing' : 'Billing address is missing';
                }
                if( thisAsset.opportunity__r.Shipping_Address__c == NULL ){
                    captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Shiping address is missing' : 'Shipping address is missing';
                }
                if( thisAsset.opportunity__r.State_2__c == NULL ){
                    captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', State is missing' : 'State is missing';
                }
            } else{
                captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Opportunity is Missing' : 'Opportunity is Missing';
            }
            
            /**	Asset-Renewal Opportunity Level Error	**/
            if( thisAsset.Renewal_Opportunity__c != NULL ){
                if( thisAsset.Renewal_Opportunity__r.Billing_GST__c == NULL ){
                    captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Renewal Billing GSTIN is missing' : 'Renewal Billing GSTIN is missing';
                }
                if( thisAsset.Renewal_Opportunity__r.E_Sign_Customer_Info__c == NULL ){
                    captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Renewal E-Sign customer info is missing' : 'Renewal E-Sign customer info is missing';
                }
                if( thisAsset.Renewal_Opportunity__r.Billing_Address__c == NULL ){
                    captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Renewal Billing address is missing' : 'Renewal Billing address is missing';
                }
                if( thisAsset.Renewal_Opportunity__r.Shipping_Address__c == NULL ){
                    captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Renewal Shiping address is missing' : 'Renewal Shipping address is missing';
                }
                if( thisAsset.Renewal_Opportunity__r.State_2__c == NULL ){
                    captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Renewal State is missing' : 'Renewal State is missing';
                }
                
                if( thisAsset.getSobjects('Quote_Line_Items__r') != NULL && thisAsset.getSobjects('Quote_Line_Items__r').size() > 0 ){
                    
                    QuoteLineItem childQLI = (QuoteLineItem)thisAsset.getSobjects('Quote_Line_Items__r')[0];
                    if( childQLI.Quote.OpportunityId != thisAsset.Renewal_Opportunity__c ){
                        captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Wrong Parent Asset Tagging is missing' : 'Wrong Parent Asset Tagging is missing';
                    }
                } else{
                    captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Parent Asset Tagging is missing/No QLI available' : 'Parent Asset Tagging is missing/No QLI available';
                }
            } else{
                captureErrorLog = captureErrorLog != NULL ? captureErrorLog+', Renewal Opportunity is Missing' : 'Renewal Opportunity is Missing';
            }
            
            
            if( captureErrorLog != NULL ){
                assetAndErrorMessageMap.put(thisAsset.Id, captureErrorLog);
                assetMap.put(thisAsset.Id, thisAsset);
            } else{
                system.debug('Asset is Green: '+thisAsset.Id);
            }
            
        }
        
        system.debug('assetAndErrorMessageMap: '+assetAndErrorMessageMap);
        if( assetAndErrorMessageMap.size() > 0 ){
            responseMessage = emailValidationResult( assetAndErrorMessageMap, assetMap );
        }
        
        system.debug('@responseMessage: '+responseMessage);
        
        return responseMessage;
        
    }
    
    public static Set<String> readCSVInformation(){
        
        ContentVersion 	doc 		= [ SELECT VersionData 
                                       FROM ContentVersion WHERE 
                                       ContentDocumentId = :system.label.Auto_Renewal_File_Upload_Id AND 
                                       IsLatest = TRUE ];
        Blob 			stringBody 	= doc.VersionData;
        List<String> 	filelines 	= stringBody.tostring().split('\n');
        Set<String> 	columnValues= new Set<String>();
        for( Integer i=1; i<filelines.size(); i++ ){
            columnValues.add( filelines[i].split(',')[0].trim() );
        }
        
        return columnValues;
    }
    
    public static string emailValidationResult(Map<Id, String> assetAndErrorMessageMap, Map<Id, Asset> assetMap){
        String htmlBody = '';
        String responseMessage = '';
        
        if(assetAndErrorMessageMap.size() > 0){
            
            htmlBody = '<table border="2px" style="text-align:center; width:80%">';
            htmlBody += '<tr><th bgcolor="Gold" colspan="4" style="text-align:center">AUTO RENEWAL VALIDATION RESULT</th></tr>';
            htmlBody += '<th>Asset</th>';
            htmlBody += '<th>Account Name</th>';
            htmlBody += '<th>Account Owner - CSM</th>';
            htmlBody += '<th>Error Message</th></tr>';
            
            for(Id assetId : assetAndErrorMessageMap.keySet()){
                String href = URL.getSalesforceBaseUrl().toExternalForm() + '/'+assetId;
                htmlBody += '<tr><td style="text-align:center; padding:4px"><a href='+href+'>' + assetId + '</a></td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + assetMap.get(assetId).Account.Name  + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + assetMap.get(assetId).Account.Onboarding_Owner__r.Name + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + assetAndErrorMessageMap.get(assetId)  + '</td>';
            }
            
            htmlBody += '</table><br/><br/>';
            
            Id owrgWideMailId = [ SELECT Id FROM OrgWideEmailAddress WHERE Address = 'notification@support.clear.in']?.Id;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<String> toAddress	= System.label.CTX_AutoRenewal_Result_Recepients.split(',');
            
            mail.setOrgWideEmailAddressId(owrgWideMailId);
            mail.setToAddresses(toAddress); 
            mail.setSubject('AUTO RENEWAL VALIDATION RESULT');
            mail.setBccSender(false);
            mail.setHtmlBody(htmlBody);
            
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                if(results.size()>0){
                    if (results[0].success) 
                    {
                        System.debug('The email was sent successfully.');
                        responseMessage =  'SUCCESS';
                    } else {
                        System.debug('Failed to send email result ' +  results[0].errors[0].message);
                        responseMessage = 'Failed to send email result ' +  results[0].errors[0].message;
                    }
                }
                
            }Catch(Exception ex){
                System.debug(' Exception on emailWhitelistingResult \n'+ex.getMessage()+'\n'+ex.getLineNumber());
                responseMessage = 'Exception on emailWhitelistingResult \n'+ex.getMessage()+'\n'+ex.getLineNumber();
            }
            
        }
        
        return responseMessage;
        
    }
    
}