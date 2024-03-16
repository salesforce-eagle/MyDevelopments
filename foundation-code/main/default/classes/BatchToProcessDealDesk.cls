global class BatchToProcessDealDesk implements Database.Batchable<sObject>,schedulable,Database.RaisesPlatformEvents {
    Id MQL_RecordTypeId = Schema.SObjectType.Deal_Desk__c.getRecordTypeInfosByDeveloperName().get('MQL').getRecordTypeId();
    global void execute(SchedulableContext sc) {
        BatchToProcessDealDesk b = new BatchToProcessDealDesk();
        database.executebatch(b,1);
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, '+
            +'LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate,'+
            +'Mentioned_Turnover_Of_The_Company__c, SKU_For_Which_Lead_Came_In__c, Email_ID__c,'+
            +'Date_Of_Incoming_Lead__c, Intent_Stage__c, Requested_For_Demo__c, Name_Of_POC__c, '+
            +'Designation_Of_The_POC__c, Phone_Number_Of_POC__c, Domain_Name_Of_EmailId__c,'+
            +'Webinar_Attendance_in_min__c, Webinar_Attendance__c, Name_Of_The_Company__c, City__c, '+
            +'State__c, Region__c, Attended_Webinar__c,Source__c, Sub_Source__c,RecordTypeId, '+
            +'Calling_Comments__c,Calling_Status__c,Remarks__c, '+
            +'Referral_CA_name__c,Referral_email_ID__c,Referral_phone_no__c '+
            +'FROM Deal_Desk__c WHERE RecordTypeId =: MQL_RecordTypeId'
        );
    }
    global void execute(Database.BatchableContext bc, List<Deal_Desk__c> listOfDealDeskRecords){
        Map<String,Deal_Desk__c> mapOfDealDesk = new Map<String,Deal_Desk__c>();
        for(Deal_Desk__c tempDealDesk : listOfDealDeskRecords){
            mapOfDealDesk.put(tempDealDesk.Name , tempDealDesk);
        }
        DealDeskServiceClass.processRecords(mapOfDealDesk);
    }
    global void finish(Database.BatchableContext bc){
    }
    
}