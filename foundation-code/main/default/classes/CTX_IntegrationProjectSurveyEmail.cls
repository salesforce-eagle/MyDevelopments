public class CTX_IntegrationProjectSurveyEmail {
    public static void createSurveyInvitations(Map<Id,Project__c> mapOfNewProjects, Map<Id,Project__c> mapOfOldProjects){
        
        
        Map<Id,Project__c> 				projectMapToCreateTask 					= new Map<Id,Project__c>();
        Map<Id,Project__c> 				projectMapToCreateSurvey 				= new Map<Id,Project__c>();
        List<SurveyInvitation> 			surveyInvList 							= new List<SurveyInvitation>();
        List<Task> 						taskList								= new List<Task>();
        Map<Id,List<TaskRelation>> 		projectTaskMap 							= new Map<Id,List<TaskRelation>>();
        Set<Id> 						contactIdSet 							= new Set<Id>();
        Map<Id,Contact> 				contactMap 								= new Map<id,Contact>();
        Map<Id,Id> 				        projectAccountMap 						= new Map<id,Id>();
        Map<Id,List<SurveyInvitation>> 	surveyMap 								= new Map<Id,List<SurveyInvitation>>();
        List<String> 					projectIdList 							= new List<String>();
        List<SurveySubject> 			surveySubjectList 						= new List<SurveySubject>();
        List<FeedItem>					postList 								= new List<FeedItem>();
        
        
        if(!mapOfNewProjects.isEmpty()){
            for(Project__c projectInstance:mapOfNewProjects.values()){
                
                if(projectInstance.Project_Stage__c   		!= 			mapOfOldProjects.get(projectInstance.Id).Project_Stage__c)
                {
                    /** Create Task -> IF Project Stage = UAT **/
                    if(projectInstance.Status__c == 'Active' && projectInstance.Project_Stage__c   == 'UAT')
                    {
                        System.debug('projectMapToCreateTask-->');
                        projectMapToCreateTask.put(projectInstance.Id,projectInstance);
                    }
                    /** Create Survey invitation -> IF Project Stage = Live **/
                    else if(projectInstance.Project_Stage__c   == 'Live' && projectInstance.Is_Deemed_Go_Live__c == False)
                    {
                        projectMapToCreateSurvey.put(projectInstance.Id,projectInstance);
                    }
                }  
            }
        }
        System.debug('projectMapToCreateTask-->'+projectMapToCreateTask);
        
        if(!projectMapToCreateTask.isEmpty())
        {
            for(Project__c projectInstance : projectMapToCreateTask.values())
            {
                Task surveyTask 			= new Task();
                surveyTask.Subject  		= 'Survey Invitation';
                surveyTask.WhatId 			= projectInstance.Id;
     			
                FeedItem post = new FeedItem();
                post.ParentId = projectInstance.Id;
                post.Body = 'You have a pending survey invitation task to be completed.';
                
                taskList.add(surveyTask);
                postList.add(post);

            }
        }  
        
        if(!taskList.isEmpty()){
            insert taskList;
        }
        
        if(!postList.isEmpty()){
            insert postList;
        }
        
    
        
        if(!projectMapToCreateSurvey.isEmpty())
        {
            
            for(TaskRelation thisRec : [SELECT ID, TaskId, RelationId, Relation.Email,Relation.Name, Task.WhatId
                                        FROM TaskRelation
                                        WHERE IsWhat = FALSE AND
                                        Task.WhatId IN :projectMapToCreateSurvey.keySet()])
            {
                
                contactIdSet.add(thisRec.RelationId);
                if(projectTaskMap.containsKey(thisRec.Task.WhatId))
                {
                    projectTaskMap.get(thisRec.Task.WhatId).add(thisRec);
                }
                else
                {
                    projectTaskMap.put(thisRec.Task.WhatId, new List<TaskRelation> {thisRec});
                }
            }
        }
        
 
        
        
        if(!projectTaskMap.isEmpty())
        {
            String communityId = [select Id from Network where Name = 'SurveyForm'].Id;
            String SurveyId = [Select Id from Survey where Name = 'Integration Project Feedback'].Id;
            
            for(Contact thisRec : [SELECT Id,Name,Email
                                   FROM Contact 
                                   WHERE Id IN :contactIdSet])
            {
                contactMap.put(thisRec.Id,thisRec);        
            }
            
            for(AccountProjectAssetJunction__c thisRec : [SELECT Id, Customer_Account__c, Project__c  
                                                          FROM AccountProjectAssetJunction__c
                                                          WHERE Project__c IN :projectMapToCreateSurvey.keySet()]) 
            {
                projectAccountMap.put(thisRec.Project__c, thisRec.Customer_Account__c);
            }
            
            for(Project__c projectInst : projectMapToCreateSurvey.values())
            {
                for(TaskRelation thisRec : projectTaskMap.get(projectInst.Id)){
                    SurveyInvitation surveyInv 					= New SurveyInvitation();
                    surveyInv.Email__c 							= contactMap.get(thisRec.RelationId).Email;
                    surveyInv.Participant_Name__c 				= contactMap.get(thisRec.RelationId).Name;	
                    surveyInv.Project__c 						= projectInst.Id;
                    surveyInv.Asset__c 							= projectInst.Asset_ID__c;
                    surveyInv.Account__c						= projectAccountMap.get(projectInst.Id);
                    surveyInv.Name 								= 'Integration Project Feedback ' + projectInst.Name + '@' + projectInst.Id;
                    surveyInv.CommunityId			 			= communityId;
                    surveyInv.OptionsCollectAnonymousResponse 	= FALSE;
                    surveyInv.OptionsAllowGuestUserResponse 	= TRUE;
                    surveyInv.SurveyId 							= SurveyId;
                    surveyInvList.add(surveyInv);
                }
            }
        }
        
        System.debug('surveyInvList-->'+surveyInvList);
        if(!surveyInvList.isEmpty()){
            insert surveyInvList;
        }
 
        if(!surveyInvList.isEmpty()) {
            for(SurveyInvitation thisRec : surveyInvList){
                projectIdList = thisRec.Name.split('@');
                thisRec.Name = projectIdList[0];
                SurveySubject surveySub = new SurveySubject();
                surveySub.SubjectId = projectIdList[1];
                surveySub.ParentId = thisRec.Id;
                //surveySub.SurveyId = SurveyId;
                surveySub.Name = projectIdList[0];
                surveySubjectList.add(surveySub); 
                if(surveyMap.containsKey(projectIdList[1])){
                    surveyMap.get(projectIdList[1]).add(thisRec);
                }else{
                    surveyMap.put(projectIdList[1], new List<SurveyInvitation> {thisRec});
                }
                
            }
        }      
   
        
        if(!surveySubjectList.isEmpty()){
            insert surveySubjectList;
            update surveyInvList;
        }
       
    } 
    
    public static void taskValidation(Map<Id,Project__c> mapOfNewProjects, Map<Id,Project__c> mapOfOldProjects){
        
         /** ASHWIN : Project task validation **/
        Map<Id,List<String>> projectTaskMap = new Map<Id,List<String>>();
        for(Task thisRec : [SELECT Id,WhatId,Stage__c,Subject,Status
                             FROM Task 
                             WHERE Subject = 'Survey Invitation'
                             AND WhatId IN :mapOfNewProjects.KeySet()])
            
           {
            if(projectTaskMap.containsKey(thisRec.WhatId)){
                projectTaskMap.get(thisRec.WhatId).add(thisRec.Status);
            }else{
                projectTaskMap.put(thisRec.WhatId, new List<String> {thisRec.Status});
            }
        }
        
        System.debug('projectTaskMap-->'+projectTaskMap);
        
        for(Id key : mapOfNewProjects.KeySet()){
            
            Project__c projectNewInstanceNew = (Project__c)mapOfNewProjects.get(key);
            Project__c projectOldInstanceOld = (Project__c)mapOfOldProjects.get(key);
            if(projectNewInstanceNew.Project_Stage__c 			!= projectOldInstanceOld.Project_Stage__c 			&&
               projectNewInstanceNew.Project_Stage__c 			== 'Live'											&&
               projectNewInstanceNew.Rocketlane_Integration__c  == FALSE)
            {
                if(projectTaskMap.containsKey(projectNewInstanceNew.Id)){
                    
                    if(!projectTaskMap.get(projectNewInstanceNew.Id).contains('Completed') || !projectTaskMap.containsKey(projectNewInstanceNew.Id)){
                    	projectNewInstanceNew.addError('You have a pending survey invitation task to be completed.');   
                    }
                }    
            }
            
        }
        //ASHWIN : Project Task validation
    }
    
}