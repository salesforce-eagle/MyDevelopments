public class CTX_CSM_TASK_CreationFormula implements Queueable {
    List<Asset> assetList;
    Map<String, CSM_Task_Creation__mdt> mdtMap = CSM_Task_Creation__mdt.getAll();
    Map<String, List<CSM_Task_Creation__mdt>> stageProductLineToMdtMap = new Map<String, List<CSM_Task_Creation__mdt>>();
    public CTX_CSM_TASK_CreationFormula(List<Asset> assetList){
		this.assetList = assetList;
        for(CSM_Task_Creation__mdt mdt : CSM_Task_Creation__mdt.getAll().values()){
            String stagePline = mdt.Stage__c + ':' + mdt.Product_Line__c;
            if(stageProductLineToMdtMap.containsKey(stagePline)){
                List<CSM_Task_Creation__mdt> mdtList = stageProductLineToMdtMap.get(stagePline);
                mdtList.add(mdt);
                stageProductLineToMdtMap.put(stagePline, mdtList);
            } else {
                stageProductLineToMdtMap.put(stagePline, new List<CSM_Task_Creation__mdt>{mdt});
            }
            
        } 
        
    }
    
    public void execute(QueueableContext context){
        createTasks();
    }
    
    public void createTasks(){
        List<Task> taskList = new List<Task>();
        List<Asset> assetToUpdate = new List<Asset>();
        for(Asset assetInstance : [SELECT Id, Name, Product2.Product_Line__c, Stage__c, Onboarding_Completed_Date__c, Account.Onboarding_Owner__c, PurchaseDate, CreatedDate, Related_Integration_Asset__c, Is_Asset_Success__c, Is_Non_GST_EInv_Success__c, OwnerId FROM Asset WHERE Id IN : assetList]){
            String CSM_TaskRecRype;
            String stage = assetInstance.Stage__c == 'Onboarding' || assetInstance.Stage__c == 'Activation' ? 'Activation' : assetInstance.Stage__c;
			String stagePline;
			
            if(Stage == 'Success' && (assetInstance.Is_Asset_Success__c == true || assetInstance.Is_Non_GST_EInv_Success__c)){
                stagePline = stage + ':' + 'Health Check';
            } else {
                stagePline = stage + ':' + assetInstance.Product2.Product_Line__c;
            }
            List<CSM_Task_Creation__mdt> mdtList = stageProductLineToMdtMap.get(stagePline);
            if(mdtList != null){
                for(CSM_Task_Creation__mdt mdtRec : mdtList){
                    boolean skipTask = false;
                    Date dueDate;
                    String subject;
                    
                    
                    switch on mdtRec.Stage__c {
                        when 'Activation' {
                            Date assetCreatedDate = Date.newInstance(assetInstance.CreatedDate.year(), assetInstance.CreatedDate.month(), assetInstance.CreatedDate.Day());
                            CSM_TaskRecRype = Schema.SObjectType.TASK.getRecordTypeInfosByDeveloperName().get('CSM_Activation_Task').getRecordTypeId();
                            switch on mdtRec.Product_Line__c {
                                when 'GST' {
                                    if(System.isBatch()){
                                        assetCreatedDate = system.today();
                                    }
                                    Date tasksStartDate = assetInstance.PurchaseDate > assetCreatedDate ? assetInstance.PurchaseDate : assetCreatedDate;
                                    if(tasksStartDate.day() == 1){
                                        dueDate = Date.newInstance(tasksStartDate.year(), tasksStartDate.month(), mdtRec.Due_Day_of_Month__c.IntValue());
                                    } else {
                                        dueDate = Date.newInstance(tasksStartDate.year(), tasksStartDate.month()+1, mdtRec.Due_Day_of_Month__c.IntValue());
                                    }
                                    //dueDate = Date.newInstance(dt1.year(), dt1.month(), mdtRec.Due_Day_of_Month__c.IntValue());
                                    subject = mdtRec.Task_Name__c;
                                    
                                    /*if(dt1.day() > 14 && dt1.day() < 20){
                                        if(dueDate.day() < 16){
                                        	skipTask = true;
                                    	}
                                   	} 
									else if(dt1.day() >= 20){
                                        skipTask = false;
                                    }*/
                                }
                                when 'Max' {
                                    if(System.isBatch()){
                                        assetCreatedDate = system.today();
                                    }
                                    Date tasksStartDate = assetInstance.PurchaseDate > assetCreatedDate ? assetInstance.PurchaseDate : assetCreatedDate;
                                    if(mdtRec.Is_Integrated_Customer_Journey__c == (assetInstance.Related_Integration_Asset__c != null)){
                                        if(tasksStartDate.day() == 1){
                                            dueDate = Date.newInstance(tasksStartDate.year(), tasksStartDate.month(), mdtRec.Due_Day_of_Month__c.IntValue());
                                        } else {
                                            dueDate = Date.newInstance(tasksStartDate.year(), tasksStartDate.month()+1, mdtRec.Due_Day_of_Month__c.IntValue());
                                        }
                                        //dueDate = Date.newInstance(dt1.year(), dt1.month(), mdtRec.Due_Day_of_Month__c.IntValue());
                                        subject = mdtRec.Task_Name__c;
                                    } else {
                                        if(tasksStartDate.day() == 1){
                                            dueDate = Date.newInstance(tasksStartDate.year(), tasksStartDate.month(), mdtRec.Due_Day_of_Month__c.IntValue());
                                        } else {
                                            dueDate = Date.newInstance(tasksStartDate.year(), tasksStartDate.month()+1, mdtRec.Due_Day_of_Month__c.IntValue());
                                        }
                                        //dueDate = Date.newInstance(dt1.year(), dt1.month(), mdtRec.Due_Day_of_Month__c.IntValue());
                                        subject = mdtRec.Task_Name__c;
                                    }
                                    
                                    /*if(dt1.day() >= 20){
										skipTask = true;
									}*/
                                }
                                when 'E-invoicing & E-Way Bill' {
                                    Date tasksStartDate = assetInstance.PurchaseDate > assetCreatedDate ? assetInstance.PurchaseDate : assetCreatedDate;
                                    DateTime tasksStartDateTime = (DateTime)tasksStartDate;
                                    if(tasksStartDateTime.format('u') == '6' || tasksStartDateTime.format('u') == '7'){
                                        tasksStartDate.addDays(8-Integer.valueOf(tasksStartDateTime.format('u')));
                                    }
                                    dueDate = tasksStartDate.addDays(mdtRec.Due_Day_From_PO_Start_Date__c.IntValue());
                                    DateTime dueDateTime = (DateTime)dueDate;
                                    if(dueDateTime.format('u') == '6' || dueDateTime.format('u') == '7'){
                                        dueDate = dueDate.addDays(8-Integer.valueOf(dueDateTime.format('u')));
                                    }
                                    subject = mdtRec.Task_Name__c;
                                }
                                when else {
                                    Date tasksStartDate = assetInstance.PurchaseDate > assetCreatedDate ? assetInstance.PurchaseDate : assetCreatedDate;
                                    DateTime tasksStartDateTime = (DateTime)tasksStartDate;
                                    if(tasksStartDateTime.format('u') == '6' || tasksStartDateTime.format('u') == '7'){
                                        tasksStartDate.addDays(8-Integer.valueOf(tasksStartDateTime.format('u')));
                                    }
                                    dueDate = tasksStartDate.addDays(mdtRec.Due_Day_From_PO_Start_Date__c.IntValue());
                                    DateTime dueDateTime = (DateTime)dueDate;
                                    if(dueDateTime.format('u') == '6' || dueDateTime.format('u') == '7'){
                                        dueDate = dueDate.addDays(8-Integer.valueOf(dueDateTime.format('u')));
                                    }
                                    subject = mdtRec.Task_Name__c;
                                }
                            }
                        }
                        
                        when 'Success' {
                            Date dt1 = system.today();
                            if(assetInstance.Product2.Product_Line__c == 'GST' || assetInstance.Product2.Product_Line__c == 'E-invoicing & E-Way Bill'){
                                if(assetInstance.Is_Asset_Success__c == false){
                                    CSM_TaskRecRype = Schema.SObjectType.TASK.getRecordTypeInfosByDeveloperName().get('CSM_Success_Task').getRecordTypeId();
                                    dueDate = Date.newInstance(dt1.year(), dt1.month(), mdtRec.Due_Day_of_Month__c.IntValue());
                                    subject = mdtRec.Task_Name__c;
                                } else{
                                    CSM_TaskRecRype = Schema.SObjectType.TASK.getRecordTypeInfosByDeveloperName().get('CSM_Health_Check').getRecordTypeId();
                                    dueDate = Date.newInstance(dt1.year(), dt1.month(), mdtRec.Due_Day_of_Month__c.IntValue());
                                    subject = mdtRec.Task_Name__c;
                                }
                            } else {
                                if(assetInstance.Is_Non_GST_EInv_Success__c == false){
                                    CSM_TaskRecRype = Schema.SObjectType.TASK.getRecordTypeInfosByDeveloperName().get('CSM_Success_Task').getRecordTypeId();
                                    dueDate = Date.newInstance(dt1.year(), dt1.month(), mdtRec.Due_Day_of_Month__c.IntValue());
                                    subject = mdtRec.Task_Name__c;
                                    
                                } else{
                                    CSM_TaskRecRype = Schema.SObjectType.TASK.getRecordTypeInfosByDeveloperName().get('CSM_Health_Check').getRecordTypeId();
                                    dueDate = Date.newInstance(dt1.year(), dt1.month(), mdtRec.Due_Day_of_Month__c.IntValue());
                                    subject = mdtRec.Task_Name__c;
                                }
                            }
   
                        }
                    }
                    
                    System.debug(assetInstance.Account.Onboarding_Owner__c);
                    
                    if(skipTask == false){
                        Task tsk = new Task(
                            Subject = subject,
                            WhatId	 = assetInstance.Id,
                            OwnerId = assetInstance.Account.Onboarding_Owner__c,
                            ActivityDate = dueDate,
                            RecordTypeId = CSM_TaskRecRype
                        );
                        taskList.add(tsk);
                    }
                }
                
                if(assetInstance.Stage__c == 'Success'){
                    if(!(assetInstance.Product2.Product_Line__c == 'GST' || assetInstance.Product2.Product_Line__c == 'E-invoicing & E-Way Bill')){
                        if(assetInstance.Is_Non_GST_EInv_Success__c == false){
                        	assetToUpdate.add(new Asset(Id=assetInstance.Id, Is_Non_GST_EInv_Success__c=true));   
                        }  
                    }   
                }
            }  
            
        }
 		
        if(!taskList.isEmpty()){
        	insert taskList;   
        }
        
        if(!assetToUpdate.isEmpty()){
            system.debug('####: '+ assetToUpdate);
            update assetToUpdate;
        }
    }
    
    public static List<Task> activationGSTTasks(){
        return null;
    }
}