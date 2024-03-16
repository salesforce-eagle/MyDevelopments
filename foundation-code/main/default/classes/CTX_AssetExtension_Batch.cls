global class CTX_AssetExtension_Batch implements Database.Batchable<sObject> {

  private String query;
  
  global CTX_AssetExtension_Batch (String soql){
    query = soql;
  }
  
  // The batch job starts
  global Database.Querylocator start(Database.BatchableContext bc){
    //String query = 'SELECT Id, Name FROM Account';
    System.debug('>>>> start ' + query);
    return Database.getQuerylocator(query);
  } 
  
  // The batch job executes and operates on one batch of records
  global void execute(Database.BatchableContext bc, List<sObject> scope){
      List<Task> toBeInserted = new List<Task>();
      for(Asset assIns : (List<Asset>)scope){
          
          //Create Task
          Task T1 = new Task();
          T1.WhatId = assIns.Id;
          if(assIns.price >= 100000)
          {
          T1.Days_to_Extend__c = Integer.valueOf(system.Label.Days_Extension_1L);
          }
          else{
              T1.Days_to_Extend__c = Integer.valueOf(system.Label.Days_Extension_1L_LessThan);
          }
          T1.recordtypeid = system.label.Task_AssetUpdate_RecordTypeId;
          toBeInserted.add(T1);
          
          
      }
      database.insert(toBeInserted,TRUE);
    System.debug('>>>> execute ' + toBeInserted.size());

  }
  
  // The batch job finishes
  global void finish(Database.BatchableContext bc){
    AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
    System.debug('>>>> finish ' + job.Status);
  }
}