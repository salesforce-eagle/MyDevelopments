public class CTX_CSMEscalationsBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    public 	Map<String, CSM_Escalation__mdt> 	escalationMDTMap 					= new Map<String, CSM_Escalation__mdt>();
    public 	set<Integer> 						escalationDaysOnboarding 			= new set<Integer>();
    public 	set<Integer> 						escalationDaysAllotment 			= new set<Integer>();
    public	static Id 							defaultMailId 						= [ SELECT Id FROM OrgWideEmailAddress WHERE Address =: System.Label.CSM_Journey_Org_Wide_Generic_Email]?.Id;
    public 	List<Logger__c>						entryLoggerRecords					= new List<Logger__c>();
    public 	Map<String, AssetsMetadataWrapper> 	typeOfOnboardingEscalationAssetMap 	= new Map<String, AssetsMetadataWrapper>();
    public CTX_CSMEscalationsBatch(){
        for(CSM_Escalation__mdt mdt : CSM_Escalation__mdt.getAll().values()){
            String daysStage = mdt.Stage__c + ':' + mdt.Days__c.IntValue();
            escalationMDTMap.put(daysStage, mdt);
            if(mdt.Stage__c == 'Onboarding'){
                escalationDaysOnboarding.add(mdt.Days__c.IntValue());
            } else if(mdt.Stage__c == 'CSM Allotment'){
                escalationDaysAllotment.add(mdt.Days__c.IntValue());
            }
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(System.Label.CTX_CSMEscalationBatch_Query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Asset> assetsToUpdate 		= new List<Asset>();
        //List<Asset>	assetToCreateTask 	= new List<Asset>();
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for(Asset assetInstance : (List<Asset>)scope){
            if(assetInstance.Stage__c == 'Onboarding'){
                Boolean isOnboardingOwnerNULL = assetInstance.Account?.Onboarding_Owner__c == NULL ? TRUE : FALSE;
                Boolean isOnboardingOwnerNotValid = FALSE;
                if(assetInstance.Account.Onboarding_Owner__c != NULL){
                    isOnboardingOwnerNotValid = assetInstance.Account.Onboarding_Owner__r.IsActive == FALSE || !System.Label.CTX_CSMAllotmentEscalationProfileIds.containsIgnoreCase(assetInstance.Account.Onboarding_Owner__r.ProfileId) ? TRUE : FALSE;
				}
                
                if(isOnboardingOwnerNULL || isOnboardingOwnerNotValid){
                    String daysStage = 'CSM Allotment' + ':' + assetInstance.Ageing_Since_Created_Date__c.IntValue();
                    CSM_Escalation__mdt mdtInstance = escalationMDTMap.get(daysStage);
                    if(mdtInstance != null){
                        //mailList.add((createMailInstance(assetInstance, mdtInstance, 'CSM Allotment')));
                        if(typeOfOnboardingEscalationAssetMap.containsKey('CSM Allotment' + ':' + mdtInstance.Escalation_Type__c)){
                            AssetsMetadataWrapper tempAssetWrap = typeOfOnboardingEscalationAssetMap.get('CSM Allotment' + ':' + mdtInstance.Escalation_Type__c);
                            tempAssetWrap.assetList.add(assetInstance);
                            tempAssetWrap.assetIds.add(assetInstance.Id);
                            typeOfOnboardingEscalationAssetMap.put('CSM Allotment' + ':' + mdtInstance.Escalation_Type__c, tempAssetWrap);
                        } else{
                            AssetsMetadataWrapper tempAssetWrap = new AssetsMetadataWrapper();
                            tempAssetWrap.assetList 			= new List<Asset>{assetInstance};
                            tempAssetWrap.assetIds 				= new List<Id>{assetInstance.Id};
                            tempAssetWrap.mdtInstance 			= mdtInstance;
                            typeOfOnboardingEscalationAssetMap.put('CSM Allotment' + ':' + mdtInstance.Escalation_Type__c, tempAssetWrap);
                        }
                    }
                }
                String daysStage = assetInstance.Stage__c + ':' + assetInstance.Ageing_of_Asset__c.IntValue();
                CSM_Escalation__mdt mdtInstance = escalationMDTMap.get(daysStage);
                if(mdtInstance != null){
                    
                    //mailList.add((createMailInstance(assetInstance, mdtInstance, assetInstance.Stage__c)));
                    
                    if(assetInstance.Stage__c == 'Onboarding' && assetInstance.Is_Onboarding_Delayed__c == false) {
                        assetsToUpdate.add(new Asset(Id=assetInstance.Id, Is_Onboarding_Delayed__c = true));
                    }
                    
                    if(typeOfOnboardingEscalationAssetMap.containsKey(assetInstance.Stage__c + ':' + mdtInstance.Escalation_Type__c)){
                        AssetsMetadataWrapper tempAssetWrap = typeOfOnboardingEscalationAssetMap.get(assetInstance.Stage__c + ':' + mdtInstance.Escalation_Type__c);
                        tempAssetWrap.assetList.add(assetInstance);
                        tempAssetWrap.assetIds.add(assetInstance.Id);
                        typeOfOnboardingEscalationAssetMap.put(assetInstance.Stage__c + ':' + mdtInstance.Escalation_Type__c, tempAssetWrap);
                    } else{
                        AssetsMetadataWrapper tempAssetWrap = new AssetsMetadataWrapper();
                        tempAssetWrap.assetList 	= new List<Asset>{assetInstance};
                        tempAssetWrap.assetIds 		= new List<Id>{assetInstance.Id};
                        tempAssetWrap.mdtInstance 	= mdtInstance;
                        typeOfOnboardingEscalationAssetMap.put(assetInstance.Stage__c + ':' + mdtInstance.Escalation_Type__c, tempAssetWrap);
                    }
                }
                
            }
            
        }
        
        if(!assetsToUpdate.isEmpty()){
            update assetsToUpdate;
        }
        
        /*if(!assetToCreateTask.isEmpty()){
            new CTX_CSM_TASK_CreationFormula(assetToCreateTask).createTasks();
        }*/
    }
    
    public void finish(Database.BatchableContext BC){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<String> recordsEligibleForEscalation  	= new List<String>(); 
        if(!typeOfOnboardingEscalationAssetMap.keySet().isEmpty()){
            for(String escalationType : typeOfOnboardingEscalationAssetMap.keySet()){
                AssetsMetadataWrapper assetMdtWrap = typeOfOnboardingEscalationAssetMap.get(escalationType);
                recordsEligibleForEscalation.add(escalationType + ' - ' + String.join(assetMdtWrap.assetIds, '|'));
                mailList.add(createMailInstance(assetMdtWrap.assetList, assetMdtWrap.mdtInstance));
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
                    String errorMessageString = 'This Transaction contained following escalations\n\n' + String.join(recordsEligibleForEscalation, '\n') + '\n\n';
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
                String errorMessage = '';
                if(recordsEligibleForEscalation.size()>0){
                    errorMessage = 'This Transaction contained following escalations\n\n' + String.join(recordsEligibleForEscalation, '\n') + '\n\n';
                }
                                                                                                        
                errorMessage += 'Error : ' + ex.getMessage();                                                                                      
                
                entryLoggerRecords.add(
                    CTX_LoggerImplementation.createLoggerInstance(
                        errorMessage, 
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
    
    public static Messaging.SingleEmailMessage createMailInstance (List<Asset> assetList, CSM_Escalation__mdt mdtInstance) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        
        if(mdtInstance.To_Addresses__c != null){
            if(mdtInstance.To_Addresses__c.trim() != ''){
                toAddresses.addAll(mdtInstance.To_Addresses__c.replace(' ','').split(','));
            }
        }
        
        if(mdtInstance.CC_Addresses__c != null){
            if(mdtInstance.CC_Addresses__c.trim() != ''){
                ccAddresses.addAll(mdtInstance.CC_Addresses__c.replace(' ','').split(','));
            }
        }
        
        
        String body = 'Hello,' + '<br/><br/>';
        body += 'Following products are pending in ' + mdtInstance.Stage__c + ' since ' + String.ValueOf(mdtInstance.Days__c.IntValue()) + ' days.'+'<br/><br/>';
        body += '<table border="1px">';
        body += '<tr>';
        body += '<th bgcolor="yellow">Asset Id</th>';
        body += '<th bgcolor="yellow">Account Name</th>';
        body += '<th bgcolor="yellow">Product Name</th>';
        body += '<th bgcolor="yellow">Period Start Date</th>';
        body += '<th bgcolor="yellow">Asset Created Date</th>';
        body += '<th bgcolor="yellow">Onboarding Status</th>';
        if( mdtInstance.Stage__c == 'CSM Allotment'){
            body += '<th bgcolor="yellow">Price</th>';
            body += '<th bgcolor="yellow">Segment</th>';
            body += '<th bgcolor="yellow">Region</th>';
		} else if( mdtInstance.Stage__c == 'Onboarding'){
            body += '<th bgcolor="yellow">CSM Assigned</th>';
            body += '<th bgcolor="yellow">Team Lead</th>';
		}
        body += '</tr>';
       
        for(Asset assetInstance : assetList){
            if(mdtInstance.Stage__c == 'Onboarding') {
                if(mdtInstance.Escalation_Type__c == 'First'){
                    if(assetInstance.Account?.Onboarding_Owner__r?.Manager?.Email != null){
                    	toAddresses.add(assetInstance.Account.Onboarding_Owner__r.Manager.Email);   
                    }
                    if(assetInstance.Account?.Onboarding_Owner__r?.Email != null){
                    	ccAddresses.add(assetInstance.Account.Onboarding_Owner__r.Email);   
                    }
                } else if(mdtInstance.Escalation_Type__c == 'Second'){
                    if(assetInstance.Account?.Onboarding_Owner__r?.Manager?.Email != null){
                    	ccAddresses.add(assetInstance.Account.Onboarding_Owner__r.Manager.Email);   
                    }
                    if(assetInstance.Account?.Onboarding_Owner__r?.Email != null){
                    	ccAddresses.add(assetInstance.Account.Onboarding_Owner__r.Email);   
                    }
                } else if(mdtInstance.Escalation_Type__c == 'Third'){
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
            body += '<td style="text-align:center">' + assetInstance.Account?.Name + '</td>';
            body += '<td style="text-align:center">' + assetInstance.Product2?.Name + '</td>';
            body += '<td style="text-align:center">' + String.ValueOf(assetInstance.PurchaseDate) + '</td>';
            body += '<td style="text-align:center">' + String.ValueOf(assetCreatedDate) + '</td>';
            body += '<td style="text-align:center">' + assetInstance.Onboarding_Status__c + '</td>';
            if( mdtInstance.Stage__c == 'CSM Allotment'){
            	body += '<td style="text-align:center">' + assetInstance.Price + '</td>';
                body += '<td style="text-align:center">' + assetInstance.Account?.EC_LC_Startup_Account__c + '</td>';
                body += '<td style="text-align:center">' + assetInstance.Account?.Region__r?.Name + '</td>';
			}
            if( mdtInstance.Stage__c == 'Onboarding'){
            	body += '<td style="text-align:center">' + assetInstance.Account?.Onboarding_Owner__r?.Name + '</td>';
            	body += '<td style="text-align:center">' + assetInstance.Account?.Onboarding_Owner__r?.Manager?.Name + '</td>';  
            }
            body += '</tr>';
        }
        body += '</table>';
        body += '<br/><br/>';
        body += 'Request your support to get it resolved.<br/><br/>';
        body += 'Thanks,<br/>';
        body += 'Team Clear';
        mail.setSubject(mdtInstance.Escalation_Type__c + ' Escalation: ' + mdtInstance.Stage__c +' Report');
        mail.setHtmlBody(body);
        mail.setToAddresses(toAddresses);
        mail.setCCAddresses(ccAddresses);
        mail.setOrgWideEmailAddressId(defaultMailId);
        
        System.debug('#####: '+ mail.getToAddresses());
        System.debug('#####: '+ mail.getCCAddresses());
        return mail;
    }
    
    
    public class AssetsMetadataWrapper {
        public List<Asset> assetList{get;set;}
        public List<Id> assetIds{get;set;}
        public CSM_Escalation__mdt mdtInstance{get;set;}
    }
    
    public void execute(SchedulableContext sc){
        database.executeBatch(new CTX_CSMEscalationsBatch());
    }
}