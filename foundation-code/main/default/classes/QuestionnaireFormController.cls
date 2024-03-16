public without sharing class QuestionnaireFormController {
    @AuraEnabled(cacheable=true)
    Public static List<Qualifications_Questionnaire__c> getQuestionnaire(Id opportunityId){
        Id accountId = [SELECT Id from Account where Id = :opportunityId]?.Id;
        List<Qualifications_Questionnaire__c> masterQuestionnarieRecordList	= new List<Qualifications_Questionnaire__c>
            (
                [ SELECT Id, RecordTypeId, Questionnaire__c, Explanation__c, Remarks__c, Answer__c,
                 Opportunity__c, Account__c, Question_Related_To__c, Parent_Questionnaires__c
                 FROM Qualifications_Questionnaire__c WHERE
                 RecordType.Name = 'Record Specific' AND (Opportunity__c = :opportunityId OR Account__c = :accountId)]
            );
        System.debug('masterQuestionnarieRecordMap-->'+masterQuestionnarieRecordList);
        return masterQuestionnarieRecordList;
    }
}