/**
 * @File Name          : SurveyResponseTriggerHelper.cls
 * @Description        : 
 * @Author             : Lokesh@SFDeveloper.SFDoc
 * @Group              : 
 * @Last Modified By   : Lokesh@SFDeveloper.SFDoc
 * @Last Modified On   : 6/22/2020, 1:13:45 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0     6/22/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public without sharing class SurveyResponseTriggerHelper {

    @InvocableMethod(label='Survey')
    public static void survyeResponse(List<Id> surveyResponseId){
        Map<Id,SurveyResponse> mapOfNewSurveyResponsesAfterCompleted=new Map<Id,SurveyResponse>((List<SurveyResponse>)DataBase.query(UtilityClass.getQueryString('SurveyResponse')+' FROM SurveyResponse WHERE ID IN: surveyResponseId'));
        surveyResponseDetailsToCase(mapOfNewSurveyResponsesAfterCompleted);
    }
    
     /**
   * @description This below method will execute everytime after when the SurveyResponse is Update and then update the case with Response values
   * @author Lokesh Thathuru | 06/22/2020
   * @param Map<Id,SurveyResponse> mapOfNewSurveyResponsesAfterCompleted
   * @return void
   */
    public static void surveyResponseDetailsToCase(Map<Id,SurveyResponse> mapOfNewSurveyResponsesAfterCompleted/*,Map<Id,SurveyResponse> mapOfOldSurveyResponsesAfterCompleted*/){
		
        Map<Id,SurveyResponse> mapOfSurveyResponse=new Map<Id,SurveyResponse>();
        
        if(!mapOfNewSurveyResponsesAfterCompleted.isEmpty()){
            for(Id key:mapOfNewSurveyResponsesAfterCompleted.keySet()){
                System.debug(key+'mapOfNewSurveyResponsesAfterCompleted'+mapOfNewSurveyResponsesAfterCompleted.get(key));
                if(!mapOfSurveyResponse.containsKey(mapOfNewSurveyResponsesAfterCompleted.get(key).InvitationId)){
                    mapOfSurveyResponse.put(mapOfNewSurveyResponsesAfterCompleted.get(key).InvitationId, mapOfNewSurveyResponsesAfterCompleted.get(key)); //CompletionDateTime
                }
            }
        }
        
        System.debug('mapOfSurveyResponse---->'+mapOfSurveyResponse.keySet()+'------>'+mapOfSurveyResponse.values());
        
        List<SurveyQuestionResponse> listofSurveyQuestionResponse=new List<SurveyQuestionResponse>();
        List<SurveyInvitation> listOfSurveyInvitations=new List<SurveyInvitation>();
        if(!mapOfSurveyResponse.isEmpty()){
            listofSurveyQuestionResponse=SurveyQuestionResponseSelector.getSurveyQuestionResponseByInvitationId(mapOfSurveyResponse.keySet());
            listOfSurveyInvitations=getInvitationByInvitationId(mapOfSurveyResponse.keySet());
        }
        
        System.debug('listofSurveyQuestionResponse---->'+listofSurveyQuestionResponse);
        System.debug('listOfSurveyInvitations---->'+listOfSurveyInvitations);

        
        Map<String,SurveyQuestionResponse> mapOfInvitationAndQuestionResponse=new Map<String,SurveyQuestionResponse>();
        if(listofSurveyQuestionResponse.size()>0){
            for(SurveyQuestionResponse surveyQuestionResponseInstance:listofSurveyQuestionResponse){
                if(!mapOfInvitationAndQuestionResponse.containsKey(surveyQuestionResponseInstance.InvitationId+'+'+surveyQuestionResponseInstance.QuestionId)){
                    //Question.QuiestionName,ResponseValue
                    mapOfInvitationAndQuestionResponse.put(surveyQuestionResponseInstance.InvitationId+'+'+surveyQuestionResponseInstance.QuestionId,surveyQuestionResponseInstance);
                }
            }
        }
        
        System.debug('mapOfInvitationAndQuestionResponse----->'+mapOfInvitationAndQuestionResponse.keySet());
        
        Set<Id> setOfCaseIds=new Set<Id>();
        if(listOfSurveyInvitations.size()>0){
            for(SurveyInvitation surveyInvitationsInstance:listOfSurveyInvitations){
                setOfCaseIds.add(surveyInvitationsInstance.Case__c);   
            }
        }
        System.debug('setOfCaseIds--->'+setOfCaseIds);
        List<Case> listOfCasesToUpdate=new List<Case>();
        if(!setOfCaseIds.isEmpty() && setOfCaseIds.size()>0){
            listOfCasesToUpdate=CaseSelector.getCaseByIds(setOfCaseIds);
        }
      
        Map<Id,Case> mapOfCaseToUpdate=new Map<Id,Case>();
        
        if(listofSurveyQuestionResponse.size()>0){
            for(SurveyQuestionResponse surveyQuestionResponseInstance:listofSurveyQuestionResponse){
                if(listOfCasesToUpdate.size()>0){
                    for(Case caseInstance:listOfCasesToUpdate){
                        if(surveyQuestionResponseInstance.Question.Name==caseInstance.get(SurveyResponseConstants.SUVERY_QUESTION_1)){
                            caseInstance.put(SurveyResponseConstants.SUVERY_RESPONSE_1,surveyQuestionResponseInstance.ResponseValue);
                        }else if(surveyQuestionResponseInstance.Question.Name==caseInstance.get(SurveyResponseConstants.SUVERY_QUESTION_2)){
                           caseInstance.put(SurveyResponseConstants.SUVERY_RESPONSE_2,surveyQuestionResponseInstance.ResponseValue);
                        }else if(surveyQuestionResponseInstance.Question.Name==caseInstance.get(SurveyResponseConstants.SUVERY_QUESTION_3)){
                            caseInstance.put(SurveyResponseConstants.SUVERY_RESPONSE_3,surveyQuestionResponseInstance.ResponseValue);
                        }else if(surveyQuestionResponseInstance.Question.Name==caseInstance.get(SurveyResponseConstants.SUVERY_QUESTION_4)){
                            caseInstance.put(SurveyResponseConstants.SUVERY_RESPONSE_4,surveyQuestionResponseInstance.ResponseValue);
                        }

                        //caseInstance.put(key,mapOfInvitationAndQuestionResponse.get(surveyQuestionResponseInstance.InvitationId+'+'+surveyQuestionResponseInstance.QuestionId).ResponseValue);
                        if(mapOfSurveyResponse.containsKey(surveyQuestionResponseInstance.InvitationId) && mapOfSurveyResponse.get(surveyQuestionResponseInstance.InvitationId).CompletionDateTime!=null){
                            caseInstance.Survey_Response_Completion_Date_Time__c=surveyQuestionResponseInstance.Response.CompletionDateTime;//mapOfSurveyResponse.get(surveyQuestionResponseInstance.InvitationId).CompletionDateTime;
                        }
                        
                        if(!mapOfCaseToUpdate.containsKey(caseInstance.Id)){
                            mapOfCaseToUpdate.put(caseInstance.Id,caseInstance);
                        }
                    }
                }
            }
        }
    
        if(listOfCasesToUpdate.size()>0){
            for(Case caseInsatnce:listOfCasesToUpdate){
                System.debug(caseInsatnce.Survey_Question_1__c);
                System.debug(caseInsatnce.Survey_Response_1__c);
                System.debug(caseInsatnce.Survey_Question_2__c);
                System.debug(caseInsatnce.Survey_Response_2__c);
                System.debug(caseInsatnce.Survey_Question_3__c);
                System.debug(caseInsatnce.Survey_Response_3__c);
                System.debug(caseInsatnce.Survey_Response_Completion_Date_Time__c);
            }
            new CaseService().updateCases(mapOfCaseToUpdate.values(),'');
            System.debug('mapOfCaseToUpdate'+mapOfCaseToUpdate.keySet());
        }
    
    
    
    }
    
   
    
    
    public static   List<SurveyInvitation> getInvitationByInvitationId(Set<Id> setOfIds){
        List<SurveyInvitation> listofSurveyInvitations=new List<SurveyInvitation>();
        String query=UtilityClass.getQueryString('SurveyInvitation');
        query+=' FROM SurveyInvitation WHERE Id IN: setOfIds';
        listofSurveyInvitations=DataBase.query(query);
        return  listofSurveyInvitations;
    }
    
    
}