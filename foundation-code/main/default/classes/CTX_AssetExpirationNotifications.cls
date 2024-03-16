public class CTX_AssetExpirationNotifications implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public          Map<String, set<Id>>    userToAssetsMap 	= new Map<String, set<Id>>();
    public static   Id                      defaultMailId   	= [ SELECT Id FROM OrgWideEmailAddress WHERE Address =: System.Label.CSM_Journey_Org_Wide_Generic_Email]?.Id;
    public 			Map<Id, Asset> 			assetMap 			= new Map<Id, Asset>();
    public 			List<Logger__c>			entryLoggerRecords	= new List<Logger__c>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(System.Label.CTX_AssetExpirationNotifications_Query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        for(Asset assetInstance : (List<Asset>)scope){
            assetMap.put(assetInstance.Id, assetInstance);
            if(userToAssetsMap.keySet().contains(assetInstance.Account.OwnerId)){
                set<Id> tempAssets = userToAssetsMap.get(assetInstance.Account.OwnerId);
                tempAssets.add(assetInstance.Id);
                userToAssetsMap.put(assetInstance.Account.OwnerId, tempAssets);
            } else {
                userToAssetsMap.put(assetInstance.Account.OwnerId, new set<Id>{assetInstance.Id});
            }
            
            if(assetInstance.Account.Owner?.ManagerId != null){
                if(userToAssetsMap.keySet().contains(assetInstance.Account.Owner?.ManagerId)){
                    set<Id> tempAssets = userToAssetsMap.get(assetInstance.Account.Owner?.ManagerId);
                    tempAssets.add(assetInstance.Id);
                    userToAssetsMap.put(assetInstance.Account.Owner?.ManagerId, tempAssets);
                } else {
                    userToAssetsMap.put(assetInstance.Account.Owner?.ManagerId, new set<Id>{assetInstance.Id});
                }   
            }
            if(assetInstance.Account.Owner?.Manager?.ManagerId != null){
                if(userToAssetsMap.keySet().contains(assetInstance.Account.Owner?.Manager?.ManagerId)){
                    set<Id> tempAssets = userToAssetsMap.get(assetInstance.Account.Owner?.Manager?.ManagerId);
                    tempAssets.add(assetInstance.Id);
                    userToAssetsMap.put(assetInstance.Account.Owner?.Manager?.ManagerId, tempAssets);
                } else {
                    userToAssetsMap.put(assetInstance.Account.Owner?.Manager?.ManagerId, new set<Id>{assetInstance.Id});
                }   
            }
            
            if(assetInstance.Account?.Onboarding_Owner__c != null){
                if(userToAssetsMap.keySet().contains(assetInstance.Account.Onboarding_Owner__c)){
                    set<Id> tempAssets = userToAssetsMap.get(assetInstance.Account.Onboarding_Owner__c);
                    tempAssets.add(assetInstance.Id);
                    userToAssetsMap.put(assetInstance.Account.Onboarding_Owner__c, tempAssets);
                } else {
                    userToAssetsMap.put(assetInstance.Account.Onboarding_Owner__c, new set<Id>{assetInstance.Id});
                }
                
                if(assetInstance.Account.Onboarding_Owner__r?.ManagerId != null){
                    if(userToAssetsMap.keySet().contains(assetInstance.Account.Onboarding_Owner__r?.ManagerId)){
                        set<Id> tempAssets = userToAssetsMap.get(assetInstance.Account.Onboarding_Owner__r?.ManagerId);
                        tempAssets.add(assetInstance.Id);
                        userToAssetsMap.put(assetInstance.Account.Onboarding_Owner__r?.ManagerId, tempAssets);
                    } else {
                        userToAssetsMap.put(assetInstance.Account.Onboarding_Owner__r?.ManagerId, new set<Id>{assetInstance.Id});
                    }   
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        if(!userToAssetsMap.keySet().isEmpty()){
            for(String userId : userToAssetsMap.keySet()){
                set<Id> assetIds = userToAssetsMap.get(userId);
                mailList.add(createMailInstance(assetIds, userId));
            }   
        }
        
        if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
            }
            catch (Exception ex) {
                System.debug('Unable to send email'+ ex.getMessage());
                entryLoggerRecords.add(
                    CTX_LoggerImplementation.createLoggerInstance(
                        ex.getMessage(), 
                        'ClassId', 
                        'CTX_AssetExpirationNotifications', 
                        'finish', 
                        ex.getTypeName(),
                        NULL,
                        'EmailMessage'
                    )
                );
                
            }
            
            if(!entryLoggerRecords.isEmpty()){
                insert entryLoggerRecords;
            }
        }
    }
    
    public Messaging.SingleEmailMessage createMailInstance (set<Id> assetIds, String userEmailAddress) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        String countryOfOrigin;
        
        String body = 'Hello,' + '<br/><br/>';
        body += 'Please find the list of assets expiring in next 1 month as follows.' + '<br/><br/>';
        body += '<div><div style="float: left;height: 20px;width: 40px;margin-bottom: 2px;border: 1px solid black; background-color:red"></div> &nbsp;&nbsp; Period End Date in Next 7 Days</div><br>';
        body += '<div><div style="float: left;height: 20px;width: 40px;margin-bottom: 2px;border: 1px solid black; background-color:orange"></div> &nbsp;&nbsp; Period End Date Next 7 - 15 Days</div><br>';
        body += '<div><div style="float: left;height: 20px;width: 40px;margin-bottom: 2px;border: 1px solid black; background-color:yellow"></div> &nbsp;&nbsp; Period End Date Next 15 - 30 Days</div><br>';
        body += '<div><div style="float: left;height: 20px;width: 40px;margin-bottom: 2px;border: 1px solid black; background-color:green"></div> &nbsp;&nbsp; Renewed</div><br>';
        body += '<table border="1px">';
        body += '<tr>';
        body += '<th >Asset Name</th>';
        body += '<th >Account Name</th>';
        body += '<th >Price</th>';
        body += '<th >Status</th>';
        body += '<th >Period End Date</th>';
        body += '<th >Account Owner</th>';
        body += '<th >Account Owner : Manager</th>';
        body += '<th >Account Owner : Super Manager</th>';
        body += '<th >Account Owner - CSM</th>';
        body += '<th >CSM Manager</th>';
        body += '<th >Asset Link</th>';
        body += '</tr>';
        
        for(Id assetId : assetIds){
            Asset assetInstance = assetMap.get(assetId);
            
            body += '<tr>';
            body += '<td style="text-align:center">' + assetInstance.Name + '</td>';
            body += '<td style="text-align:center">' + assetInstance.Account.Name + '</td>';
            body += '<td style="text-align:center">' + assetInstance.Price + '</td>';
            body += '<td style="text-align:center">' + assetInstance.Status + '</td>';
            if(assetInstance.Status != null){
                if(assetInstance.Status?.containsIgnoreCase('Renewed')){
                	body += '<td bgcolor="green" style="text-align:center">' + assetInstance.UsageEndDate + '</td>';   
                } else {
                    if(System.today().daysBetween(assetInstance.UsageEndDate) <= 7){
                        body += '<td bgcolor="red" style="text-align:center">' + assetInstance.UsageEndDate + '</td>';
                    } else if(System.today().daysBetween(assetInstance.UsageEndDate) > 7 && System.today().daysBetween(assetInstance.UsageEndDate) <= 15){
                        body += '<td bgcolor="orange" style="text-align:center">' + assetInstance.UsageEndDate + '</td>';
                    }
                    else if(System.today().daysBetween(assetInstance.UsageEndDate) > 15 && System.today().daysBetween(assetInstance.UsageEndDate) <= 30){
                        body += '<td bgcolor="yellow" style="text-align:center">' + assetInstance.UsageEndDate + '</td>';
                    } 
                }
            } else {
                if(System.today().daysBetween(assetInstance.UsageEndDate) <= 7){
                    body += '<td bgcolor="red" style="text-align:center">' + assetInstance.UsageEndDate + '</td>';
                } else if(System.today().daysBetween(assetInstance.UsageEndDate) > 7 && System.today().daysBetween(assetInstance.UsageEndDate) <= 15){
                    body += '<td bgcolor="orange" style="text-align:center">' + assetInstance.UsageEndDate + '</td>';
                }
                else if(System.today().daysBetween(assetInstance.UsageEndDate) > 15 && System.today().daysBetween(assetInstance.UsageEndDate) <= 30){
                    body += '<td bgcolor="yellow" style="text-align:center">' + assetInstance.UsageEndDate + '</td>';
                }   
            }
            body += '<td style="text-align:center">' + assetInstance.Account?.Owner?.Name + '</td>';
            body += '<td style="text-align:center">' + assetInstance.Account?.Owner?.Manager?.Name + '</td>';
            body += '<td style="text-align:center">' + assetInstance.Account?.Owner?.Manager?.Manager?.Name + '</td>';
            body += '<td style="text-align:center">' + assetInstance.Account?.Onboarding_Owner__r?.Name + '</td>';
            body += '<td style="text-align:center">' + assetInstance.Account?.Onboarding_Owner__r?.Manager?.Name + '</td>';
            body += '<td style="text-align:center">' + URL.getSalesforceBaseUrl().toExternalForm()+'/'+assetInstance.Id + '</td>';

            body += '</tr>'; 
            	
            countryOfOrigin = countryOfOrigin == NULL ? assetMap.get(assetId).Account.Country_of_Origin__c  : countryOfOrigin;
        }
        body += '</table>';
        body += '<br/><br/>';
        //body += 'Request your support to get it resolved.<br/><br/>';
        body += 'Thanks,<br/>';
        body += 'Team Clear';
        mail.setSubject('Attention required : Assets expiring in the next 7/15/30 days');
        mail.setHtmlBody(body);
        mail.setTargetObjectId(userEmailAddress);
        mail.setOrgWideEmailAddressId(defaultMailId);
        mail.setSaveAsActivity(false);
		
        		
        if(countryOfOrigin != 'India'){
            mail.setCcAddresses(new List<String> (System.Label.CTX_GCC_Asset_Expiry_ccAddress.split(';')));
        }
        
        return mail;
    }
    
    public void execute(SchedulableContext sc){
        Database.executeBatch(new CTX_AssetExpirationNotifications());
    }
}