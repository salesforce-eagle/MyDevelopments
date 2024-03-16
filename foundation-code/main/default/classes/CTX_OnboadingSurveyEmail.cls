public class CTX_OnboadingSurveyEmail {
    public static void createSurveyInvitations(Map<Id,Asset> astMap, Set<Id> accIds){
        
        
        Map<Id,List<EventRelation>> 					assetEventMap 			= new Map<Id,List<EventRelation>>();
        List<SurveyInvitation> 							surveyInvList 			= new List<SurveyInvitation>();
        List<SurveySubject> 							surveySubjectList 		= new List<SurveySubject>();
        Set<Id> 										contactIdSet 			= new Set<Id>();
        Map<Id,String> 									onbOwnerMap 			= new Map<Id,String>();
        Map<Id,Contact> 								contactMap 				= new Map<id,Contact>();
        Set<Id> 										surveyInvIds 			= new Set<Id>();
        Map<Id,List<SurveyInvitation>> 					surveyMap 				= new Map<Id,List<SurveyInvitation>>();
        
        
        for(EventRelation thisRec : [SELECT ID, EventID, RelationId, Relation.Email,Relation.Name, Event.WhatId
                                     FROM EventRelation
                                     WHERE IsInvitee = TRUE
                                     AND Event.WhatId IN :astMap.KeySet()])
            
        {
            contactIdSet.add(thisRec.RelationId);
            if(assetEventMap.containsKey(thisRec.Event.WhatId)){
                assetEventMap.get(thisRec.Event.WhatId).add(thisRec);
            }else{
                assetEventMap.put(thisRec.Event.WhatId, new List<EventRelation> {thisRec});
            }
        }
        
        
        for(Contact thisRec : [SELECT Id,Name,Email
                               FROM Contact 
                               WHERE Id IN :contactIdSet])
        {
            contactMap.put(thisRec.Id,thisRec);        
        }
        
        for(Account thisRec : [SELECT Id,Name,Csm_Owner_Name__c
                               FROM Account 
                               WHERE Id IN :accIds])
        {
            onbOwnerMap.put(thisRec.Id,thisRec.Csm_Owner_Name__c);        
        }
        
        
        System.debug('assetEventMap-->'+assetEventMap);
        System.debug('contactMap-->'+contactMap);
        
        String communityId = [select Id from Network where Name = 'SurveyForm'].Id;
        String SurveyId = [Select Id from Survey where Name = 'Onboarding Feedback'].Id;
        
        
        for(Asset ast : astMap.values())
        { 
            if(!assetEventMap.containsKey(ast.Id)){
                ast.addError('Please add attendees in onboarding meeting');
            }else{
                for(EventRelation thisRec : assetEventMap.get(ast.Id)){
                    SurveyInvitation surveyInv = New SurveyInvitation();
                    surveyInv.Email__c = contactMap.get(thisRec.RelationId).Email;
                    surveyInv.Participant_Name__c = contactMap.get(thisRec.RelationId).Name;
                    surveyInv.ParticipantId = thisRec.RelationId;
                    surveyInv.CSM_Owner_Name__c = onbOwnerMap.get(ast.AccountId);
                    surveyInv.Asset__c = ast.Id;
                    surveyInv.Name = 'Onboarding Feedback for Asset ' + ast.Name + '@' + ast.Id;
                    surveyInv.CommunityId = communityId;
                    surveyInv.OptionsCollectAnonymousResponse = FALSE;
                    surveyInv.OptionsAllowGuestUserResponse = TRUE;
                    surveyInv.SurveyId = SurveyId;
                    surveyInvList.add(surveyInv);
                    
                }   
            }
            
            
        }
        
        System.debug('surveyInvList-->'+surveyInvList);
        if(!surveyInvList.isEmpty()){
            insert surveyInvList;
        }
        
        
        List<String> assetIdList = new List<String>();
        for(SurveyInvitation thisRec : surveyInvList){
            assetIdList = thisRec.Name.split('@');
            thisRec.Name = assetIdList[0];
            SurveySubject surveySub = new SurveySubject();
            surveySub.SubjectId = assetIdList[1];
            surveySub.ParentId = thisRec.Id;
            surveySub.Name = assetIdList[0];
            surveySubjectList.add(surveySub); 
            surveyInvIds.add(thisRec.Id);
            if(surveyMap.containsKey(assetIdList[1])){
                surveyMap.get(assetIdList[1]).add(thisRec);
            }else{
                surveyMap.put(assetIdList[1], new List<SurveyInvitation> {thisRec});
            }
            
        }
        
        System.debug('surveySubjectList-->'+surveySubjectList);
        if(!surveySubjectList.isEmpty()){
            insert surveySubjectList;
            update surveyInvList;
        }
        
    } 
}