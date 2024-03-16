public class TaskTriggerHelper {
public static void updateAsset(List<SObject> listOfNewSObjects){
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForPOStartCount =
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'Count_PO_Start_Date__c',
                                                         'Modification_Count_Period_Start_Date__c')
                    };
                                list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForPOEndCount =
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'Count_PO_End_Date__c',
                                                         'Modification_Count_Period_End_Date__c')
                    };
                                    list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForPriceCount =
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'Count_Price__c',
                                                         'Modification_Count_Price__c')
                    };
                        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForProductCount =
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'Count_Product__c',
                                                         'Modification_Count_Product__c')
                    };
                        
                              
                  RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForPOStartCount, listOfNewSObjects, 'Task', 'whatId', 'Asset',
                                                           'AND Count_PO_Start_Date__c = 1' );
        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForPOEndCount, listOfNewSObjects, 'Task', 'whatId', 'Asset',
                                           'AND Count_PO_End_Date__c =1' );
        RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForPriceCount, listOfNewSObjects, 'Task', 'whatId', 'Asset',
                                           'AND Count_Price__c =1' );
     RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForProductCount, listOfNewSObjects, 'Task', 'whatId', 'Asset',
                                           'AND Count_Product__c =1' );

    }
    
    public static void updateBillingDetails(Map<Id,Task> newTaskMap, Map<Id,Task> OldTaskMap ){
        
        Set<Id> billingIds = new Set<Id>();
        List<Task> taskList =  new List<Task>();
        List<Billing_Details__c> billingList = new List<Billing_Details__c>();
         String RECORDTYPEID_BILLING_TASK = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Billing_Task').getRecordTypeId();
        System.debug('@newTaskMap'+newTaskMap);
        
        for(Task thisRec : newTaskMap.values()){
            if(thisRec.RecordtypeID == RECORDTYPEID_BILLING_TASK &&
               thisRec.Status != OldTaskMap.get(thisRec.Id).Status && 
               thisRec.Status == 'Completed' &&
               thisRec.Description != NULL)
            {
                billingIds.add(thisRec.WhatId);
                taskList.add(thisRec);
            }
            
        }
            Map<Id, Billing_Details__c> billingMap = new Map<Id, Billing_Details__c>([SELECT Id,Support_Owner_Comments__c,Support_Owner_Comments_Risk__c
                                              											FROM Billing_Details__c
                                              											WHERE Id IN :billingIds]);

            for(Task thisTask : taskList){
                Billing_Details__c billingRec = new Billing_Details__c(Id = thisTask.WhatId);
                if(thisTask.Subject.contains('Collection')){
                    if(billingMap.get(thisTask.WhatId).Support_Owner_Comments__c != NULL)
                    {
                        billingRec.Support_Owner_Comments__c = +System.now().format('MMMM d, y')+' - '+UserInfo.getName()+' - ' +thisTask.Description + '\n' +billingMap.get(thisTask.WhatId).Support_Owner_Comments__c;
                    }else{
                        billingRec.Support_Owner_Comments__c = System.now().format('MMMM d, y')+' - '+UserInfo.getName()+' - ' +thisTask.Description;
                    }
                }else{
                    if(billingMap.get(thisTask.WhatId).Support_Owner_Comments_Risk__c != NULL)
                    {
                        billingRec.Support_Owner_Comments_Risk__c = +System.now().format('MMMM d, y')+' - '+UserInfo.getName()+' - '+thisTask.Description + '\n' +billingMap.get(thisTask.WhatId).Support_Owner_Comments_Risk__c ;
                    }else{
                        billingRec.Support_Owner_Comments_Risk__c = System.now().format('MMMM d, y')+' - '+UserInfo.getName()+' - '+thisTask.Description;
                    }
                }
                billingList.add(billingRec);
            }
            
        
        System.debug('@billingList'+billingList);
        
        try{
            if(!billingList.isEmpty()){
                update billingList;
            }    
        }Catch(Exception ex){
            System.debug(' Exception on updateBillingDetails method on TaskTrigger AfterUpdate \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
        
    }
    
    public static void taskApprovalNotification(Map<Id,Task> newTaskMap, Map<Id,Task> OldTaskMap ){
        
        Set<Id> assetIds 									= new Set<Id>();
        List<Messaging.SingleEmailMessage> mailList 		= new List<Messaging.SingleEmailMessage>();
        List<String> 					  ccAddresses    	= System.label.GCC_Category_Team.split(',');
        List<String> 					  toAddresses    	= new  List<String> ();
        String RECORDTYPEID_ASSET_CREATE = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Asset_Create').getRecordTypeId();
        String RECORDTYPEID_ASSET_UPDATE = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Asset_Update').getRecordTypeId();
        String RECORDTYPEID_ASSET_DELETE = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Asset_Delete').getRecordTypeId();
        
        for(Task thisTask : newTaskMap.values()){
            
            if(thisTask.Status != OldTaskMap.get(thisTask.id).Status &&
               thisTask.Status == 'Approved' &&
               (thisTask.recordtypeId == RECORDTYPEID_ASSET_CREATE ||
                thisTask.recordtypeId == RECORDTYPEID_ASSET_UPDATE ||
                thisTask.recordtypeId == RECORDTYPEID_ASSET_DELETE)){
                    assetIds.add(thisTask.WhatId);
                }
        }
        
        Map<Id,Asset> astMap = new Map<Id,Asset>([SELECT Id , Account.Country_of_Origin__c 
                                                  FROM Asset 
                                                  WHERE Id IN :assetIds]);
        
        
        if(astMap.size()>0){
            
            Id defaultMailId = [ SELECT Id FROM OrgWideEmailAddress WHERE Address = 'notification@support.clear.in']?.Id;
            EmailTemplate template = [Select Id,Name from EmailTemplate where Name = 'Task Approved'];
            
            for(Task thisTask : newTaskMap.values()){
                if(astMap.containsKey(thisTask.whatId) && 
                   astMap.get(thisTask.whatId).Account.Country_of_Origin__c != NULL &&
                   astMap.get(thisTask.whatId).Account.Country_of_Origin__c != 'NA' &&
                   astMap.get(thisTask.whatId).Account.Country_of_Origin__c != 'India' )
                {
                    
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setOrgWideEmailAddressId(defaultMailId);
                    toAddresses.add(thisTask.Email_Asset_Update__c);
                    toAddresses.add(thisTask.Asset_Account_CSM_Email__c);
                    
                    email.setTemplateID(template.Id);
                    email.setWhatId(thisTask.Id); 
                    email.setToAddresses(toAddresses);
                    email.setCcAddresses(ccAddresses);
                    email.setTargetObjectId(thisTask.ownerId);
                    email.setSaveAsActivity(false);
                    mailList.add(email);
                }
            }
            
            if(!mailList.isEmpty()) {
                try{
                    Messaging.sendEmail(mailList);
                }
                catch (Exception ex) {
                    System.debug('Unable to send email'+ ex.getMessage());
                }
            }
            
        }
        
        
    }
    
}