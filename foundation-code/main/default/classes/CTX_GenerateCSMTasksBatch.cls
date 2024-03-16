public class CTX_GenerateCSMTasksBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    public List<Asset> assetList;
    public String queryString;
    public Map<String, List<CSM_Task_Creation__mdt>> stageProductLineToMdtMap = new Map<String, List<CSM_Task_Creation__mdt>>();
    public set<String> applicablePLineForActivationTask;
    
    public CTX_GenerateCSMTasksBatch(){
        applicablePLineForActivationTask = new set<String>{'GST'};
        queryString = System.Label.CTX_GenerateCSMTasksBatch_Query;
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
	public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Asset> assetToProcess = new List<Asset>();
        
        assetToProcess = (List<Asset>)scope;
        
        new CTX_CSM_TASK_CreationFormula(assetToProcess).createTasks();
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
    public static void createSuccessTasks_PLineNotGST_EINV(List<Asset> assetList){
        List<Task> taskList = new List<Task>();
        List<Asset> successTasksToCreate = new List<Asset>();
        CSM_Task_Creation__mdt health_Check_task = CSM_Task_Creation__mdt.getInstance('Success_Health_Check');
        String CSM_Health_Check_RecordType = Schema.SObjectType.TASK.getRecordTypeInfosByDeveloperName().get('CSM_Health_Check').getRecordTypeId();
        Date dueDate = Date.newInstance(System.today().year(), System.today().month(), health_Check_task.Due_Day_of_Month__c.IntValue());
        for(Asset assetInstance : [SELECT Id,Account.Onboarding_Owner__c, (SELECT Id, ActivityDate FROM Tasks WHERE RecordType.DeveloperName = 'CSM_Success_Task' LIMIT 1) FROM Asset WHERE Id IN : assetList]){
            if(assetInstance.Tasks == null){
                successTasksToCreate.add(assetInstance);
            } else {
                Task tsk = new Task(
                    Subject = health_Check_task.Task_Name__c,
                    WhatId	 = assetInstance.Id,
                    OwnerId = assetInstance.Account.Onboarding_Owner__c,
                    ActivityDate = dueDate,
                    RecordTypeId = CSM_Health_Check_RecordType
                );
                taskList.add(tsk);
            }
        }
        
        if(!taskList.isEmpty()){
            insert taskList;
        }
	}
    
    public void execute(SchedulableContext sc){
        database.executeBatch(new CTX_GenerateCSMTasksBatch());
    }
}