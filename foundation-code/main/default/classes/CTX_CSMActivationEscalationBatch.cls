public class CTX_CSMActivationEscalationBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    
    public	static Id 							defaultMailId 						= [ SELECT Id FROM OrgWideEmailAddress WHERE Address =: System.Label.CSM_Journey_Org_Wide_Generic_Email]?.Id;
    public 	Map<String, List<Asset>> 			typeOfActivationEscalationAssetMap 	= new Map<String, List<Asset>>();
    public 	List<Logger__c>						entryLoggerRecords					= new List<Logger__c>();
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(System.Label.CTX_CSMActivationEscalationBatch_Query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Asset> assetsToUpdate 		= new List<Asset>();
        for(Asset assetInstance : (List<Asset>)scope){
            
            /* Logic for Activation Escalation to be added here */
            Date assetCreatedDate = Date.newInstance(assetInstance.CreatedDate.year(), assetInstance.CreatedDate.month(), assetInstance.CreatedDate.day());
            Date effectiveDate = assetCreatedDate > assetInstance.PurchaseDate ? assetCreatedDate : assetInstance.PurchaseDate;
            if(assetInstance.Product2.Product_Line__c == 'GST'){
                Date firstEcallationDate 	= Date.newInstance(effectiveDate.year(), effectiveDate.month() + 1, Integer.valueOf(System.Label.CTX_Activation_Escalation_Day_of_Month2));
                Date secondEcallationDate 	= Date.newInstance(effectiveDate.year(), effectiveDate.month() + 1, Integer.valueOf(System.Label.CTX_Activation_Escalation_Day_of_Month16));
                Date thirdEcallationDate 	= Date.newInstance(effectiveDate.year(), effectiveDate.month() + 2, Integer.valueOf(System.Label.CTX_Activation_Escalation_Day_of_Month2));
                if(effectiveDate.day() == 1){
                    if(System.today() == firstEcallationDate){
                        if(typeOfActivationEscalationAssetMap.containsKey('Activation' + ':' + 'GST' + ':' + 'First')){
                            List<Asset> assetList = typeOfActivationEscalationAssetMap.get('Activation' + ':' + 'GST' + ':' + 'First');
                            assetList.add(assetInstance);
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'GST' + ':' + 'First', assetList);
                        } else{
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'GST' + ':' + 'First', new List<Asset>{assetInstance});
                        }
                        
                        if(assetInstance.Is_Activation_Delayed__c == false){
                            assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Activation_Delayed__c = true));
                        }
                    } else if(System.today() == secondEcallationDate){
                        if(typeOfActivationEscalationAssetMap.containsKey('Activation' + ':' + 'GST' + ':' + 'Second')){
                            List<Asset> assetList = typeOfActivationEscalationAssetMap.get('Activation' + ':' + 'Second');
                            assetList.add(assetInstance);
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'GST' + ':' + 'Second', assetList);
                        } else{
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'GST' + ':' + 'Second', new List<Asset>{assetInstance});
                        }
                        
                        if(assetInstance.Is_Activation_Delayed__c == false){
                            assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Activation_Delayed__c = true));
                        }
                    } else if(System.today() == thirdEcallationDate){
                        if(typeOfActivationEscalationAssetMap.containsKey('Activation' + ':' + 'GST' + ':' + 'Third')){
                            List<Asset> assetList = typeOfActivationEscalationAssetMap.get('Activation' + ':' + 'GST' + ':' + 'Third');
                            assetList.add(assetInstance);
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'GST' + ':' + 'Third', assetList);
                        } else{
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'GST' + ':' + 'Third', new List<Asset>{assetInstance});
                        }
                        
                        if(assetInstance.Is_Activation_Delayed__c == false){
                            assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Activation_Delayed__c = true));
                        }
                    }
                } else {
                    if(System.today() == firstEcallationDate.addMonths(1)){
                        if(typeOfActivationEscalationAssetMap.containsKey('Activation' + ':' + 'GST' + ':' + 'First')){
                            List<Asset> assetList = typeOfActivationEscalationAssetMap.get('Activation' + ':' + 'GST' + ':' + 'First');
                            assetList.add(assetInstance);
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'GST' + ':' + 'First', assetList);
                        } else{
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'GST' + ':' + 'First', new List<Asset>{assetInstance});
                        }
                        
                        if(assetInstance.Is_Activation_Delayed__c == false){
                            assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Activation_Delayed__c = true));
                        }
                    } else if(System.today() == secondEcallationDate.addMonths(1)){
                        if(typeOfActivationEscalationAssetMap.containsKey('Activation' + ':' + 'GST' + ':' + 'Second')){
                            List<Asset> assetList = typeOfActivationEscalationAssetMap.get('Activation' + ':' + 'GST' + ':' + 'Second');
                            assetList.add(assetInstance);
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'GST' + ':' + 'Second', assetList);
                        } else{
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'GST' + ':' + 'Second', new List<Asset>{assetInstance});
                        }
                        
                        if(assetInstance.Is_Activation_Delayed__c == false){
                            assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Activation_Delayed__c = true));
                        }
                    } else if(System.today() == thirdEcallationDate.addMonths(1)){
                        if(typeOfActivationEscalationAssetMap.containsKey('Activation' + ':' + 'GST' + ':' + 'Third')){
                            List<Asset> assetList = typeOfActivationEscalationAssetMap.get('Activation' + ':' + 'GST' + ':' + 'Third');
                            assetList.add(assetInstance);
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'GST' + ':' + 'Third', assetList);
                        } else{
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'GST' + ':' + 'Third', new List<Asset>{assetInstance});
                        }
                        
                        if(assetInstance.Is_Activation_Delayed__c == false){
                            assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Activation_Delayed__c = true));
                        }
                    }
                }
            } else if(assetInstance.Product2.Product_Line__c == 'E-invoicing & E-Way Bill'){
                if(effectiveDate.day() < 15){
                    Date firstEcallationDate 	= Date.newInstance(effectiveDate.year(), effectiveDate.month() + 1, Integer.valueOf(System.Label.CTX_Activation_Escalation_Day_of_Month2));
                    Date secondEcallationDate 	= Date.newInstance(effectiveDate.year(), effectiveDate.month() + 1, Integer.valueOf(System.Label.CTX_Activation_Escalation_Day_of_Month16));
                    Date thirdEcallationDate 	= Date.newInstance(effectiveDate.year(), effectiveDate.month() + 2, Integer.valueOf(System.Label.CTX_Activation_Escalation_Day_of_Month2));
                    
                    if(System.today() == firstEcallationDate){
                        if(typeOfActivationEscalationAssetMap.containsKey('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'First')){
                            List<Asset> assetList = typeOfActivationEscalationAssetMap.get('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'First');
                            assetList.add(assetInstance);
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'First', assetList);
                        } else{
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'First', new List<Asset>{assetInstance});
                        }
                        
                        if(assetInstance.Is_Activation_Delayed__c == false){
                            assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Activation_Delayed__c = true));
                        }
                    } else if(System.today() == secondEcallationDate){
                        if(typeOfActivationEscalationAssetMap.containsKey('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Second')){
                            List<Asset> assetList = typeOfActivationEscalationAssetMap.get('Activation' + ':' + 'Second');
                            assetList.add(assetInstance);
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Second', assetList);
                        } else{
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Second', new List<Asset>{assetInstance});
                        }
                        
                        if(assetInstance.Is_Activation_Delayed__c == false){
                            assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Activation_Delayed__c = true));
                        }
                    } else if(System.today() == thirdEcallationDate){
                        if(typeOfActivationEscalationAssetMap.containsKey('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Third')){
                            List<Asset> assetList = typeOfActivationEscalationAssetMap.get('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Third');
                            assetList.add(assetInstance);
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Third', assetList);
                        } else{
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Third', new List<Asset>{assetInstance});
                        }
                        
                        if(assetInstance.Is_Activation_Delayed__c == false){
                            assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Activation_Delayed__c = true));
                        }
                    }
                } else {
                    Date firstEcallationDate = Date.newInstance(effectiveDate.year(), effectiveDate.month() + 1, Integer.valueOf(System.Label.CTX_Activation_Escalation_Day_of_Month16));
                    Date secondEcallationDate = Date.newInstance(effectiveDate.year(), effectiveDate.month() + 1, Integer.valueOf(System.Label.CTX_Activation_Escalation_Day_of_Month2));
                    Date thirdEcallationDate = Date.newInstance(effectiveDate.year(), effectiveDate.month() + 2, Integer.valueOf(System.Label.CTX_Activation_Escalation_Day_of_Month16));
                    
                    if(System.today() == firstEcallationDate){
                        if(typeOfActivationEscalationAssetMap.containsKey('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'First')){
                            List<Asset> assetList = typeOfActivationEscalationAssetMap.get('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'First');
                            assetList.add(assetInstance);
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'First', assetList);
                        } else{
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'First', new List<Asset>{assetInstance});
                        }
                        
                        if(assetInstance.Is_Activation_Delayed__c == false){
                            assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Activation_Delayed__c = true));
                        }
                    } else if(System.today() == secondEcallationDate){
                        if(typeOfActivationEscalationAssetMap.containsKey('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Second')){
                            List<Asset> assetList = typeOfActivationEscalationAssetMap.get('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Second');
                            assetList.add(assetInstance);
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Second', assetList);
                        } else{
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Second', new List<Asset>{assetInstance});
                        }
                        
                        if(assetInstance.Is_Activation_Delayed__c == false){
                            assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Activation_Delayed__c = true));
                        }
                    } else if(System.today() == thirdEcallationDate){
                        if(typeOfActivationEscalationAssetMap.containsKey('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Third')){
                            List<Asset> assetList = typeOfActivationEscalationAssetMap.get('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Third');
                            assetList.add(assetInstance);
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Third', assetList);
                        } else{
                            typeOfActivationEscalationAssetMap.put('Activation' + ':' + 'E-invoicing & E-Way Bill' + ':' + 'Third', new List<Asset>{assetInstance});
                        }
                        
                        if(assetInstance.Is_Activation_Delayed__c == false){
                            assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Activation_Delayed__c = true));
                        }
                    }
                }
                
                
                
            }
            
        }
        
        if(!assetsToUpdate.isEmpty()){
            update assetsToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();      
        if(!typeOfActivationEscalationAssetMap.keySet().isEmpty()){
            for(String escalationType : typeOfActivationEscalationAssetMap.keySet()){
                mailList.add(createActivationMailInstance(typeOfActivationEscalationAssetMap.get(escalationType), escalationType.split(':')[1], escalationType.split(':')[2]));
            } 
        }
        
        if(!mailList.isEmpty()) {
            try{
                Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(mailList, false);
                List<String> emailErrors = new List<String>();
                for(Messaging.SendEmailResult mailResult : emailResults){
                    if(mailResult.isSuccess()){
                        
                    } else {
                        for(Messaging.SendEmailError error : mailResult.getErrors()){
                            emailErrors.add(mailResult.getErrors().indexOf(error) + ')' + ' ' + error.getMessage() + '\n');
                        }
                    }
                }
                
                if(emailErrors.size() > 0){
                    String errorMessageString = 'This Transaction failed Because of Following Errors,\n\n';
                    errorMessageString += String.join(emailErrors, '\n');
                    
                    entryLoggerRecords.add(
                        CTX_LoggerImplementation.createLoggerInstance(
                            errorMessageString, 
                            'ClassId', 
                            'CTX_CSMEscalationsBatch', 
                            'finish', 
                            'Email Send Failure',
                            NULL,
                            NULL
                        )
                    );
                }
            }
            catch (Exception ex) {
                System.debug('Unable to send email'+ ex.getMessage());
                entryLoggerRecords.add(
                    CTX_LoggerImplementation.createLoggerInstance(
                        ex.getMessage(), 
                        'ClassId', 
                        'CTX_CSMEscalationsBatch', 
                        'execute', 
                        ex.getTypeName(),
                        NULL,
                        NULL
                    )
                );
                
                //throw ex;
            }
            
            if(entryLoggerRecords.size() > 0){
                insert entryLoggerRecords;
            }
            /*finally {
                if(entryLoggerRecords.size() > 0){
                    insert entryLoggerRecords;
                }
            }*/
        }
    }
    
    public static Messaging.SingleEmailMessage createActivationMailInstance (List<Asset> assetList, String productLine, String escalationType) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        
        String body = 'Hello,' + '<br/><br/>';
        body += 'Following products are pending in Activation.'+'<br/><br/>';
        body += '<table border="1px">';
        body += '<tr>';
        body += '<th bgcolor="yellow">Asset Id</th>';
        body += '<th bgcolor="yellow">Account Name</th>';
        body += '<th bgcolor="yellow">Product Name</th>';
        body += '<th bgcolor="yellow">Period Start Date</th>';
        body += '<th bgcolor="yellow">Asset Created Date</th>';
        body += '<th bgcolor="yellow">Team Lead</th>';
        body += '</tr>';
        for(Asset assetInstance : assetList){
            
            if(assetInstance.Stage__c == 'Activation') {
                if(escalationType == 'First'){
                    if(assetInstance.Account?.Onboarding_Owner__r?.Manager?.Email != null){
                    	toAddresses.add(assetInstance.Account.Onboarding_Owner__r.Manager.Email);   
                    }
                    if(assetInstance.Account?.Onboarding_Owner__r?.Email != null){
                    	ccAddresses.add(assetInstance.Account.Onboarding_Owner__r.Email);   
                    }
                } else if(escalationType == 'Second'){
                    if(assetInstance.Account?.Onboarding_Owner__r?.Manager?.Email != null){
                    	ccAddresses.add(assetInstance.Account.Onboarding_Owner__r.Manager.Email);   
                    }
                    if(assetInstance.Account?.Onboarding_Owner__r?.Email != null){
                    	ccAddresses.add(assetInstance.Account.Onboarding_Owner__r.Email);   
                    }
                } else if(escalationType == 'Third'){
                    if(assetInstance.Account?.Onboarding_Owner__r?.Manager?.Email != null){
                    	ccAddresses.add(assetInstance.Account.Onboarding_Owner__r.Manager.Email);   
                    }
                    if(assetInstance.Account?.Onboarding_Owner__r?.Email != null){
                    	ccAddresses.add(assetInstance.Account.Onboarding_Owner__r.Email);   
                    }
                } 
            }
            
            Date assetCreatedDate = Date.newInstance(assetInstance.CreatedDate.year(), assetInstance.CreatedDate.month(), assetInstance.CreatedDate.Day());
            body += '<tr>';
            body += '<td style="text-align:center">'+ URL.getSalesforceBaseUrl().toExternalForm()+'/'+assetInstance.Id + '</td>';
            body += '<td style="text-align:center">' + assetInstance.Account.Name + '</td>';
            body += '<td style="text-align:center">' + assetInstance.Product2.Name + '</td>';
            body += '<td style="text-align:center">' + assetInstance.PurchaseDate + '</td>';
            body += '<td style="text-align:center">' + assetCreatedDate + '</td>';
            body += '<td style="text-align:center">' + assetInstance.Account.Onboarding_Owner__r.Manager.Name + '</td>';
            body += '</tr>';
        }
        body += '</table>';
        body += '<br/><br/>';
        body += 'Request your support to get it resolved.<br/><br/>';
        body += 'Thanks,<br/>';
        body += 'Team Clear';
        mail.setSubject(escalationType + ' Escalation: ' + 'Activation (' + productLine + ')' +' Report');
        mail.setHtmlBody(body);
        
        if(escalationType == 'First'){
            if(System.Label.CTX_Activation_2nd_Escalation_CC_Addresses.trim() != ''){
                ccAddresses.addAll(System.Label.CTX_Activation_2nd_Escalation_CC_Addresses.trim().replace(' ','').split(','));
            }
        }
        else if (escalationType == 'Second'){
            if(System.Label.CTX_Activation_2nd_Escalation_To_Addresses.trim() != ''){
                toAddresses.addAll(System.Label.CTX_Activation_2nd_Escalation_To_Addresses.trim().replace(' ','').split(','));
            }
            if(System.Label.CTX_Activation_2nd_Escalation_CC_Addresses.trim() != ''){
                ccAddresses.addAll(System.Label.CTX_Activation_2nd_Escalation_CC_Addresses.trim().replace(' ','').split(','));
            }
        }
        else if (escalationType == 'Third'){
            if(System.Label.CTX_Activation_3rd_Escalation_To_Addresses.trim() != ''){
                toAddresses.addAll(System.Label.CTX_Activation_3rd_Escalation_To_Addresses.trim().replace(' ','').split(','));
            }
            if(System.Label.CTX_Activation_2nd_Escalation_To_Addresses.trim() != ''){
                ccAddresses.addAll(System.Label.CTX_Activation_2nd_Escalation_To_Addresses.trim().replace(' ','').split(','));
            }
            if(System.Label.CTX_Activation_2nd_Escalation_CC_Addresses.trim() != ''){
                ccAddresses.addAll(System.Label.CTX_Activation_2nd_Escalation_CC_Addresses.trim().replace(' ','').split(','));
            }
            
        }
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        mail.setOrgWideEmailAddressId(defaultMailId);
        
        return mail;
    }
    
    public void execute(SchedulableContext sc){
        database.executeBatch(new CTX_CSMActivationEscalationBatch());
    }
}