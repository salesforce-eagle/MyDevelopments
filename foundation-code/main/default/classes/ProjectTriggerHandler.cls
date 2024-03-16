/**
* @File Name          : ProjectTriggerHandler.cls
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 02-08-2024
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    07/12/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public class ProjectTriggerHandler implements TriggerInterface {
    
    
    public static void beforeInsert(List<SObject> listOfNewSObjects){
        
        list<Project__c> ProjList = (List<Project__c>)listOfNewSObjects;
        
        CTX_ProjectOwnerMapping.projectOwnerMapping(ProjList);
        
        if(listOfNewSObjects.size()>0){
            
            for( Project__c projectInstance : ProjList ){
                
                if(projectInstance.Project_Stage__c == 'Live' ){
                    projectInstance.Status__c = 'Complete';
                }
                //bhaveshjindal : Update Revised date on update of estimate date
                if(
                    projectInstance.Estimated_Go_Live_Date__c != null && 
                    projectInstance.Estimated_go_live_date_Current_status__c == null
                ){
                    projectInstance.Estimated_go_live_date_Current_status__c = projectInstance.Estimated_Go_Live_Date__c;
                }
                if(
                    projectInstance.Estimated_Implementation_End_Date__c != null && 
                    projectInstance.Estimated_Implementation_End_Date_Rev__c == null
                ){
                    projectInstance.Estimated_Implementation_End_Date_Rev__c = projectInstance.Estimated_Implementation_End_Date__c;
                }
                if(projectInstance.Estimated_UAT_End_Date__c != null && projectInstance.Estimated_UAT_End_Date_Rev__c == null){
                    projectInstance.Estimated_UAT_End_Date_Rev__c = projectInstance.Estimated_UAT_End_Date__c;
                }
                /** Added By Niraj : START **/
                if(projectInstance.Scope_Category__c  == 'Consultation'){
                    projectInstance.In_house_project__c = true;
                }
                /** Added By Niraj : END **/
                if(projectInstance.LOE_Received_Date__c > Date.valueOf(System.label.IntegrationStartDate)){
                    projectInstance.Day_Zero_Billing__c  = TRUE;
                }
                
                
                /**	Asset - Project Automation : START	**/
                if( 
                    projectInstance.Type_of_Integration__c != NULL || 
                    String.isNotBlank(projectInstance.Type_of_Integration__c) 
                ){
                    projectInstance = CTX_ProjectAutomationHelper.getScopeModeInHouseDetails(projectInstance);
                }
                if(
                    (
                        projectInstance.Scope_Category__c != NULL || 
                        String.isNotBlank(projectInstance.Scope_Category__c)
                    ) && 
                    (
                        projectInstance.Product__c != NULL || 
                        String.isNotBlank(projectInstance.Product__c)
                    )
                ){
                    projectInstance = CTX_ProjectAutomationHelper.getEstimatedDateForProject(projectInstance, (Date)System.Today());
                }
                /**	Asset - Project Automation : END	**/
                
                
                
                
            }
            
            
        }
        
        
        
        //bhaveshjindal
        //Populate PM Project Owner Field based on Scope.
        /*
for( Project__c thisProject : ProjList){
if(thisProject.Scope_Category__c == 'Installation'){
thisProject.PM_Project_Owner__c = 'Yash Kothari';
}
if(thisProject.Scope_Category__c == 'Development' && thisProject.SI_Partner_Account__c != ''){
thisProject.PM_Project_Owner__c = 'Jayanth Pushparaju';
}
if(thisProject.Scope_Category__c == 'Development' && thisProject.In_house_project__c == TRUE){
thisProject.PM_Project_Owner__c = 'Pranjal Kohre';
}
if(thisProject.Scope_Category__c == 'Consultation'){
thisProject.PM_Project_Owner__c = 'Daksh Sikka';
}
}
*/
        //end
        
    }
    
    public static void afterInsert(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){
        
        
        
        System.debug('<----afterInsert---->');
        
        Map<Id,Project__c> mapOfNewProjects=(Map<Id,Project__c>)mapOfNewSObjects;
        
        Map<Id,Project__c> mapOfProjectToUpdateJunction=new Map<Id,Project__c>();
        List<Project__c> projectListToSendMail = new List<Project__c>();//added by Murali
        
        if(!mapOfNewProjects.isEmpty()){
            for(Project__c projectInstance:mapOfNewProjects.values()){
                
                
                if(projectInstance.Project_Stage__c!=null ){
                    mapOfProjectToUpdateJunction.put(projectInstance.Id,projectInstance);
                }
                //added by Murali
                system.debug('projectInstance.Scope_Category__c'+projectInstance.Scope_Category__c);
                if(projectInstance.Scope_Category__c == 'Development'){
                    projectListToSendMail.add(projectInstance);
                    //EmailManager.sendMail('murali.krishna@clear.in', 'Email Subject', 'Email Body');
                }
                
            }
        }
        //added by Murali
        system.debug('projectListToSendMail in handler'+projectListToSendMail);
        if(projectListToSendMail.size()>0){
            EmailManager.sendMail(projectListToSendMail);
        }
        
        if(!mapOfProjectToUpdateJunction.isEmpty()){
            ProjectTriggerHelper.updateIsProjectCompletedINJunction(mapOfProjectToUpdateJunction,false);
        }
    }
    
    public static void beforeUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
        
        Map<Id,Project__c> mapOfNewProjects=(Map<Id,Project__c>)mapOfNewSObjects;
        Map<Id,Project__c> mapOfOldProjects=(Map<Id,Project__c>)mapOfOldSObjects;
        Map<Id,Project__c> mapOfAmcModulesToUpdate = new Map<Id,Project__c>();
        List<Project__C> projectListForChurnOrLiveNotification = new List<Project__c>();
        List<Project__c> projectListToSendMail = new List<Project__c>();//added by Murali
        
        System.debug('@projectOwnerMapping');
        
        CTX_ProjectOwnerMapping.projectOwnerMapping(mapOfNewProjects.values());
        
        Map<Id,Project__c> ProjectsMap = new Map<Id,Project__c>([SELECT Id, Parent_Project__r.Project_Name__c FROM Project__c 
                                                                 WHERE Id IN :mapOfNewProjects.keySet()]);
        
        if(!mapOfNewProjects.isEmpty()){
            for(Project__c projectInstance:mapOfNewProjects.values()){
                
                projectInstance.Project_Name__c = projectInstance.Account_Name_Formula__c + ' - ' + projectInstance.Product__c + ' - ' + projectInstance.Scope_Category__c+ ' - ' + projectInstance.Client_ERP__c;
                
                // added by Murali
                if(ProjectInstance.Scope_Category__c!= mapOfOldProjects.get(projectInstance.Id).Scope_Category__c 
                   && ProjectInstance.Scope_Category__c == 'Development' ){
                    projectListToSendMail.add(projectInstance);
                }
                
                if(!ProjectConstants.setOfProjectUpdated.Contains(projectInstance.Id)) {
                    if(projectInstance.Project_Stage__c == 'Live' && (projectInstance.Project_Stage__c != mapOfOldProjects.get(projectInstance.Id).Project_Stage__c || projectInstance.Status__c!= mapOfOldProjects.get(projectInstance.Id).Status__c)){
                        projectInstance.Status__c = 'Complete';
                    }
                    /** Update Project Name on  Product__c/Scope_Category__c/Client_ERP__c change **/                                
                    if(ProjectInstance.Product__c 	!= mapOfOldProjects.get(projectInstance.Id).Product__c  ||
                       ProjectInstance.Scope_Category__c 	!= mapOfOldProjects.get(projectInstance.Id).Scope_Category__c ||                  
                       ProjectInstance.Client_ERP__c != mapOfOldProjects.get(projectInstance.Id).Client_ERP__c){
                           
                           String tempProjectName;
                           
                           
                           if(ProjectInstance.Product__c != NULL){
                               tempProjectName = ProjectInstance.Product__c;
                           }
                           if(ProjectInstance.Scope_Category__c != NULL){
                               tempProjectName += (' - '+ProjectInstance.Scope_Category__c);
                           }
                           if(ProjectInstance.Client_ERP__c != NULL){
                               tempProjectName += (' - '+ProjectInstance.Client_ERP__c);
                           }
                           
                           ProjectInstance.Project_Name__c = ProjectInstance.Project_Name__c.replace(ProjectInstance.Project_Name__c.substringAfter(' - '),tempProjectName);
                       }  
                    
                    
                    //bhaveshjindal : Update Revised date on update of estimate date
                    if(projectInstance.Estimated_Go_Live_Date__c != mapOfOldProjects.get(projectInstance.Id).Estimated_Go_Live_Date__c){
                        projectInstance.Estimated_go_live_date_Current_status__c = projectInstance.Estimated_Go_Live_Date__c;
                    } 
                    if(projectInstance.Estimated_Implementation_End_Date__c != mapOfOldProjects.get(projectInstance.Id).Estimated_Implementation_End_Date__c){
                        projectInstance.Estimated_Implementation_End_Date_Rev__c = projectInstance.Estimated_Implementation_End_Date__c;
                    }
                    if(projectInstance.Estimated_UAT_End_Date__c != mapOfOldProjects.get(projectInstance.Id).Estimated_UAT_End_Date__c){
                        projectInstance.Estimated_UAT_End_Date_Rev__c = projectInstance.Estimated_UAT_End_Date__c;
                    }
                    
                    //added by bhaveshjindal
                    /*if(ProjectInstance.RecordTypeId == ProjectConstants.PROJECT_AMC_MODULE_RECORDTYPEID)
ProjectInstance.Project_Name__c = 'AMC Module For '+ ProjectsMap.get(ProjectInstance.Id).Parent_Project__r.Project_Name__c;*/
                    //added by bhaveshjindal
                    /*if(ProjectInstance.Is_Deemed_Go_Live__c == TRUE){
                        projectInstance.Project_Stage__c = 'Live';
                        ProjectInstance.Status__c = 'Complete';
                    }
                    
                    if(ProjectInstance.Scope_Category__c == 'Consultation'){
                        ProjectInstance.In_house_project__c = TRUE;
                    }
                    
                    //end by bhaveshjindal
                    
                    //added by bhaveshjindal : ChurnDate
                    if(ProjectInstance.Status__c != mapOfOldProjects.get(projectInstance.Id).Status__c && ProjectInstance.Status__c == 'Churn'){
                        ProjectInstance.Churn_date__c = Date.today();
                    }
                    //end by bhaveshjindal
                    
                    
                    
                    /**if(projectInstance.Dealer_Management_system__c == true){
projectInstance.CTX_SE__c = [select id from user where firstname = 'Purab' and lastname = 'Patni' limit 1].id;
}**/
                    
                    if((projectInstance.Project_Stage__c != mapOfOldProjects.get(projectInstance.Id).Project_Stage__c && projectInstance.Project_Stage__c == 'Live') 
                       || (projectInstance.Status__c!= mapOfOldProjects.get(projectInstance.Id).Status__c && projectInstance.Status__c == 'Churn' ) ){
                           projectListForChurnOrLiveNotification.add(projectInstance);
                       }
                    
                    
                    if(projectInstance.RecordTypeId == ProjectConstants.PROJECT_AMC_MODULE_RECORDTYPEID 
                       /**&& 
projectInstance.Parent_Project__c != mapOfOldProjects.get(projectInstance.Id).Parent_Project__c && 
projectInstance.Parent_Project__c != NULL**/
                      ){
                          if(
                              projectInstance.Parent_Project__c != mapOfOldProjects.get(projectInstance.Id).Parent_Project__c &&
                              projectInstance.Parent_Project__c != NULL
                          ){
                              projectInstance.Is_Parent_Project_Overridden__c = FALSE;
                          } 
                          mapOfAmcModulesToUpdate.put(projectInstance.Id,projectInstance);
                          
                      }
                    
                    /** Added By Niraj : START **/
                    if(mapOfOldProjects.get(projectInstance.Id).Scope_Category__c != projectInstance.Scope_Category__c && projectInstance.Scope_Category__c  == 'Consultation'){
                        projectInstance.In_house_project__c = true;
                    }
                    /** Added By Niraj : END **/  
                } 
                
                /**	Asset - Project Automation : 
                if( 
                    projectInstance.Type_of_Integration__c != NULL || 
                    String.isNotBlank(projectInstance.Type_of_Integration__c) 
                ){
                    projectInstance = CTX_ProjectAutomationHelper.getScopeModeInHouseDetails(projectInstance);
                }
                if(
                    (
                        projectInstance.Scope_Category__c != NULL || 
                        String.isNotBlank(projectInstance.Scope_Category__c)
                    ) && 
                    (
                        projectInstance.Product__c != NULL || 
                        String.isNotBlank(projectInstance.Product__c)
                    )
                ){
                    projectInstance = CTX_ProjectAutomationHelper.getEstimatedDateForProject(
                        projectInstance, 
                        Date.newinstance(projectInstance.CreatedDate.year(), projectInstance.CreatedDate.month(), projectInstance.CreatedDate.day())
                    );
                }
                 - Project Automation : END	**/
                
            }
            
            // added by Murali
            if(projectListToSendMail.size()>0){
                EmailManager.sendMail(projectListToSendMail);
            }
            if(projectListForChurnOrLiveNotification.size() > 0){
                ProjectTriggerHelper.sendEmailNotification(projectListForChurnOrLiveNotification);
            }
            if(mapOfAmcModulesToUpdate.keySet().size()>0){
                ProjectTriggerHelper.updateAmcFields(mapOfAmcModulesToUpdate);
            }
        }
        
        /** << Added by Ashwin ** Integration Project Task Validation >> **/
        //CTX_IntegrationProjectSurveyEmail.taskValidation(mapOfNewProjects,mapOfOldProjects);
        //END
        
    }
    
    public static void afterUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){	
        ProjectConstants.isFirstTimeProject = False;
        System.debug('<----afterUpdate---->');	
        Map<Id,Project__c> mapOfNewProjects=(Map<Id,Project__c>)mapOfNewSObjects;	
        Map<Id,Project__c> mapOfOldProjects=(Map<Id,Project__c>)mapOfOldSObjects;	
        set<id> ProjectIdEstLiveDate = new set<id>();	
        set<id> assetSet = new set<id>();	
        Map<Id,Project__c> mapOfProjectToUpdateJunction=new Map<Id,Project__c>();	
        Map<Id,Project__c> mapOfProjectToUpdateJunctionNew=new Map<Id,Project__c>();	
        List<asset> assList = new List<asset>();	
        List<Asset> assetSoftUpdateList = new List<Asset>();	
        set<Id> projectIdSetForAssetSoftUpdate = new set<Id>();	
        List<AccountProjectAssetJunction__c> apaJunctionToUpdateList = new List<AccountProjectAssetJunction__c>();	
        
        //bhaveshjindal : autoupdate amc module fields	
        /**	Bibhu Commented not to update the same again :	ProjectTriggerHelper.autoUpdateAmcFields((Map<Id,Project__c>)mapOfNewSObjects);	**/	
        ProjectTriggerHelper.autoUpdateAmcFields(mapOfNewProjects, mapOfOldProjects);	
        
        Map<Id, AccountProjectAssetJunction__c> apaJunctionMap = new Map<Id, AccountProjectAssetJunction__c>();	
        for(AccountProjectAssetJunction__c thisApaJunction : [SELECT Id, Project__c, SI_Partner_Account__c FROM AccountProjectAssetJunction__c 	
                                                              WHERE Project__c IN :mapOfNewSObjects.keySet()])	
        {	
            apaJunctionMap.put(thisApaJunction.Project__c,thisApaJunction);	
        }	
        
        
        if(!mapOfNewProjects.isEmpty()){	
            for(Project__c projectInstance:mapOfNewProjects.values()){	
                if(!ProjectConstants.setOfProjectUpdated.Contains(projectInstance.Id)) {    
                    
                    if(projectInstance.Estimated_go_live_date_Current_status__c != mapOfOldProjects.get(projectInstance.Id).Estimated_go_live_date_Current_status__c)	
                    {	
                        ProjectIdEstLiveDate.add(projectInstance.Id);	
                    }	
                    
                    
                    
                    if(projectInstance.Project_Stage__c!=null && projectInstance.Project_Stage__c != mapOfOldProjects.get(projectInstance.Id).Project_Stage__c ){  	
                        mapOfProjectToUpdateJunction.put(projectInstance.Id,projectInstance);	
                    }	
                    if(projectInstance.Project_Stage__c == null || projectInstance.Status__c!= mapOfOldProjects.get(projectInstance.Id).Status__c ||projectInstance.Scope_Category__c != mapOfOldProjects.get(projectInstance.Id).Scope_Category__c ){	
                        mapOfProjectToUpdateJunctionNew.put(projectInstance.Id,projectInstance);	
                        
                    } 	
                    
                    //for asset soft update	
                    if(projectInstance.Project_Stage__c != mapOfOldProjects.get(projectInstance.Id).Project_Stage__c 	
                       || projectInstance.Status__c!= mapOfOldProjects.get(projectInstance.Id).Status__c 	
                       || projectInstance.Scope_Category__c != mapOfOldProjects.get(projectInstance.Id).Scope_Category__c ){	
                           projectIdSetForAssetSoftUpdate.add(projectInstance.Id);	
                       }	
                    
                    //to update SI partener account on apaJunction	
                    if(projectInstance.SI_Account_Lookup__c != mapOfOldProjects.get(projectInstance.Id).SI_Account_Lookup__c){	
                        AccountProjectAssetJunction__c apaJunctionToUpdate = apaJunctionMap.get(projectInstance.Id);	
                        apaJunctionToUpdate.SI_Partner_Account__c = projectInstance.SI_Account_Lookup__c;	
                        apaJunctionToUpdateList.add(apaJunctionToUpdate);	
                    }
                    ProjectConstants.setOfProjectUpdated.add(projectInstance.Id);
                }	
            }	
        }	
        
        if(apaJunctionToUpdateList.size()>0){	
            try{	
                Update apaJunctionToUpdateList;	
            }Catch(Exception e){	
                System.debug('Error in updating apaJunction on SI Partner Account Update On Project : '+e.getMessage());	
                System.debug('Error cause : '+e.getCause());	
            }	
        }	
        
        if(ProjectIdEstLiveDate.size() >0){	
            list<AccountProjectAssetJunction__c> junAssList = [select asset__c,asset__r.id from AccountProjectAssetJunction__c where project__c in:ProjectIdEstLiveDate ];	
            for(AccountProjectAssetJunction__c junIns : junAssList){	
                if(junIns.asset__c != null){	
                    assetSet.add(junIns.asset__r.id);	
                }	
            }	
            list<aggregateResult> projJunctionList = [select Max(Project_Estimated_Go_Live_Date__c) latEstDate,asset__c assetIns from AccountProjectAssetJunction__c where asset__c in:assetSet group by asset__c];	
            for(aggregateResult junIns:projJunctionList){	
                if(junIns.get('assetIns') != null){	
                    asset assIns = new asset();	
                    assIns.id = (id)junIns.get('assetIns');	
                    assIns.Project_Estimated_Go_Live_Date__c = date.valueOf(junIns.get('latEstDate'));	
                    assList.add(assIns);	
                }	
            }	
            
            if(assList.size() > 0){	
                update(assList);	
            }	
        }	
        
        //AssetSoftUpdate
        if(projectIdSetForAssetSoftUpdate.size()>0)
            ProjectTriggerHelper.assetSoftUpdate(projectIdSetForAssetSoftUpdate);
        /* if(projectIdSetForAssetSoftUpdate.size()>0){	
for(AccountProjectAssetJunction__c apaJunctionInstance : [SELECT Id, Project__c, Asset__c 	
FROM AccountProjectAssetJunction__c	
WHERE Project__c IN :projectIdSetForAssetSoftUpdate]	
){	
Asset tempAsset = new Asset (Id = apaJunctionInstance.Asset__c);	
assetSoftUpdateList.add(tempAsset);	
}	
}	
if(assetSoftUpdateList.size()>0){	
update assetSoftUpdateList;	
}*/	
        //end AssetSoftUpdate	
        
        if(!mapOfProjectToUpdateJunction.isEmpty()){	
            ProjectTriggerHelper.updateIsProjectCompletedINJunction(mapOfProjectToUpdateJunction,false);	
        }	
        if(!mapOfProjectToUpdateJunctionNew.isEmpty()){	
            ProjectTriggerHelper.updateIsProjectCompletedINJunction(mapOfProjectToUpdateJunctionNew,true);	
        }
        
        /** << Added by Ashwin ** Integration Project CSAT >> **/
        CTX_IntegrationProjectSurveyEmail.createSurveyInvitations(mapOfNewProjects, mapOfOldProjects);
        //END
        
    }
    
    public static void beforeDelete(List<SObject> listOfOldSObjects,Map<Id,SObject> mapOfOldSObjects){
        System.debug('<----beforeDelete---->');
        
    }
    
    public static void afterDelete(Map<Id,SObject> listOfOldSObjects){
        System.debug('<----afterDelete---->');
    }
    
    public static void afterUnDelete(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){
        System.debug('<----afterUnDelete---->');
    }
    
    
}