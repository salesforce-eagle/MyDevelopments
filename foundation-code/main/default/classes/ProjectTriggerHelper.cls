/**
* @File Name          : ProjectTriggerHelper.cls
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : Lokesh@SFDeveloper.SFDoc
* @Last Modified On   : 07/12/2020, 12:57:38 pm
* @Modification Log   : 
* Ver       Date            Author              Modification
* 1.0    07/12/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public class ProjectTriggerHelper {
    
    public static void updateIsProjectCompletedINJunction(Map<Id,Project__c> mapOfProjectToUpdateJunction,boolean changed){
        List<AccountProjectAssetJunction__c> listOfAccountProjectAssetJunctions=new List<AccountProjectAssetJunction__c>();
        Set<Id> setOfProjectIds=new Set<Id>();
        setOfProjectIds=mapOfProjectToUpdateJunction.keySet();
        if(setOfProjectIds.size()>0){
            listOfAccountProjectAssetJunctions=DataBase.query(UtilityClass.getQueryString('AccountProjectAssetJunction__c')+' FROM AccountProjectAssetJunction__c WHERE Project__c IN:setOfProjectIds' );
        }
        if(!changed){
            List<AccountProjectAssetJunction__c> listOfAccountProjectAssetJunctionToUpdate=new List<AccountProjectAssetJunction__c>();
            
            if(listOfAccountProjectAssetJunctions.size()>0){
                
                for(AccountProjectAssetJunction__c apaJunctionInstance:listOfAccountProjectAssetJunctions){
                    if(mapOfProjectToUpdateJunction.get(apaJunctionInstance.Project__c).Project_Stage__c!=null){ //isProjectCompleted  = true
                        apaJunctionInstance.Project_Status__c = mapOfProjectToUpdateJunction.get(apaJunctionInstance.Project__c).Project_Stage__c;
                        listOfAccountProjectAssetJunctionToUpdate.add(apaJunctionInstance);
                    }
                    
                }
            }
            if(listOfAccountProjectAssetJunctionToUpdate.size()>0){
                ProjectConstants.isFirstTimeApa = FALSE;
                ProjectConstants.isFirstTimeProject  = FALSE;
                RecursiveTriggerHandler.isFirstTime = FALSE;

                update listOfAccountProjectAssetJunctionToUpdate;
                
                ProjectConstants.isFirstTimeApa = TRUE;
                ProjectConstants.isFirstTimeProject  = TRUE;
                RecursiveTriggerHandler.isFirstTime = TRUE;
            }
        }
        else{
            if(listOfAccountProjectAssetJunctions.size()>0){
                ProjectConstants.isFirstTimeApa = FALSE;
                ProjectConstants.isFirstTimeProject  = FALSE;
                RecursiveTriggerHandler.isFirstTime = FALSE;

                update listOfAccountProjectAssetJunctions;

                ProjectConstants.isFirstTimeApa = TRUE;
                ProjectConstants.isFirstTimeProject  = TRUE;
                RecursiveTriggerHandler.isFirstTime = TRUE;
            }
        }
        
    }
    
    //bhaveshjindal
    //send email notification to CSM and Account Owner if project status changes to Churn or stage changes to Live.
    public static void sendEmailNotification(List<Project__c> projectList){
        Id 					defaultMailId 				= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                           Address = 'notification@support.clear.in']?.Id;
        List<Messaging.SingleEmailMessage> 	mailList 	= new List<Messaging.SingleEmailMessage>();
        List<String> 		errorMessages 				= new List<String>();
        Set<Id> projectIds = new Set<Id>();
        List<AccountProjectAssetJunction__c> apaJunctionList = new List<AccountProjectAssetJunction__c>();
        Map<Id, AccountProjectAssetJunction__c> apaJunctionMap = new Map<Id, AccountProjectAssetJunction__c>();
        for(Project__c thisProject : projectList){
            projectIds.add(thisProject.Id);
        }
        apaJunctionList = [ SELECT Project__r.Id, Project__c , Customer_Account__c , Asset__c , Customer_Account__r.Owner.Email , Customer_Account__r.Onboarding_Owner__r.Email FROM AccountProjectAssetJunction__c 
                           WHERE Project__c IN : projectIds ];
        
        if(apaJunctionList.size()>0){
            
            for(AccountProjectAssetJunction__c thisApaJunction : apaJunctionList){
                apaJunctionMap.put(thisApaJunction.Project__r.Id, thisApaJunction);
            }
            
            for(Project__c thisProject : projectList){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.SaveAsActivity = TRUE;
                mail.setWhatId(thisProject.Id);
                List<String> ccAddresses = new List<String>();
                List<String> toAddresses = new List<String>();
                String subject ='';
                
                if(thisProject.Project_Stage__c == 'Live'){
                    subject = thisProject.Name+' is live now.';
                }
                if(thisProject.Status__c == 'Churn'){
                    subject ='Project Status Changed to Churn.';
                }
                
                //toAddresses.add(apaJunctionMap.get(thisProject.Id).Customer_Account__r.Owner.Email);
                
                toAddresses.add(apaJunctionMap.get(thisProject.Id).Customer_Account__r.Onboarding_Owner__r.Email);
                
                String body = '';
                if(thisProject.Status__c == 'Churn'){
                    body += 'Status Changed to Churn for below Project. Please take necessary action.'+'<br/>';
                }
                String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+thisProject.Id;
                if(thisProject.Project_Stage__c == 'Live'){
                    body += thisProject.Name+' is live now.'+'<br/>';
                    body += 'Please update status in license & integration assets - so that finance can bill accordingly.';
                }
                body += '<br/>';
                body += '<a href='+Recordlink+'>' + thisProject.Name + '</a><br/><br/>';
              
                mail.setSubject(subject);
                mail.setHtmlBody(body);
                mail.setToAddresses(toAddresses);
                mail.setCcAddresses(ccAddresses);
                mail.setOrgWideEmailAddressId(defaultMailId);
                mailList.add(mail);
            }
            system.debug('mailList: '+mailList.size());
            if(!mailList.isEmpty()) {
                try{
                    Messaging.sendEmail(mailList);
                }
                catch (Exception ex) {
                    errorMessages.add('Unable to send email'+ ex.getMessage());
                }
            }
        }
    }
    
    /** Start :: bhaveshjindal :: update fields on AMC module when parent project is tagged **/
    public static void updateAmcFields(Map<Id,Project__c> newProjectsMap){
        System.debug('<-- updateAmcFields Entered -->');
        System.debug('newProjectsMap :: '+newProjectsMap);
        set<Id> parentProjectIds = new set<Id>();
        for(Project__c thisAmc : newProjectsMap.values()){
            parentProjectIds.add(thisAmc.Parent_Project__c);
        }
        Map<Id,Project__c> parentProjectMap = new Map<Id,Project__c>([SELECT Id, CTX_SE__c, Lead_Developer__c, Pm_Project_Owner_Lookup__c, 
                                                                      SI_Partner_Account__c, In_house_project__c, Status__c, Scope_Category__c, 
                                                                      Mode_Of_Integration__c, Product__c, Client_ERP__c, Account_Owner_CSM__c, 
                                                                      Customer_Account_Owner__c,Delivery_Owner__c
                                                                      FROM Project__c WHERE Id IN :parentProjectIds ]);
        System.debug('parentProjectMap :: '+parentProjectMap)
            ;
        try{
            
            if(!parentProjectMap.isEmpty()){
                for(Id thisAmcId : newProjectsMap.keySet()){
                    
                    Project__c	thisAmc 					= newProjectsMap.get(thisAmcId);
                    
                    if(parentProjectMap.containsKey(thisAmc.Parent_Project__c)){
                        
                        if(!thisAmc.Is_Parent_Project_Overridden__c ){
                            thisAmc.Is_Parent_Project_Overridden__c = TRUE;
                            thisAmc.CTX_SE__c 						= parentProjectMap.get(thisAmc.Parent_Project__c).CTX_SE__c;
                            thisAmc.Lead_Developer__c 				= parentProjectMap.get(thisAmc.Parent_Project__c).Lead_Developer__c;
                            thisAmc.Pm_Project_Owner_Lookup__c 		= parentProjectMap.get(thisAmc.Parent_Project__c).Pm_Project_Owner_Lookup__c;
                            thisAmc.SI_Partner_Account__c 			= parentProjectMap.get(thisAmc.Parent_Project__c).SI_Partner_Account__c;
                            thisAmc.In_house_project__c 			= parentProjectMap.get(thisAmc.Parent_Project__c).In_house_project__c;
                            thisAmc.Status__c 						= parentProjectMap.get(thisAmc.Parent_Project__c).Status__c;
                         /* thisAmc.Scope_Category__c 				= parentProjectMap.get(thisAmc.Parent_Project__c).Scope_Category__c;*/
                            thisAmc.Mode_Of_Integration__c 			= parentProjectMap.get(thisAmc.Parent_Project__c).Mode_Of_Integration__c;
                            thisAmc.Product__c 						= parentProjectMap.get(thisAmc.Parent_Project__c).Product__c;
                            thisAmc.Client_ERP__c  					= parentProjectMap.get(thisAmc.Parent_Project__c).Client_ERP__c;
                            thisAmc.Account_Owner_CSM__c 			= parentProjectMap.get(thisAmc.Parent_Project__c).Account_Owner_CSM__c;
                            thisAmc.Customer_Account_Owner__c 		= parentProjectMap.get(thisAmc.Parent_Project__c).Customer_Account_Owner__c;
                            thisAmc.Delivery_Owner__c 				= parentProjectMap.get(thisAmc.Parent_Project__c).Delivery_Owner__c;
                        }else{
                            thisAmc.CTX_SE__c 						= thisAmc.CTX_SE__c 					!= NULL	? 
                                thisAmc.CTX_SE__c 					: parentProjectMap.get(thisAmc.Parent_Project__c).CTX_SE__c;
                            thisAmc.Lead_Developer__c 				= thisAmc.Lead_Developer__c 			!= NULL	? 
                                thisAmc.Lead_Developer__c 			: parentProjectMap.get(thisAmc.Parent_Project__c).Lead_Developer__c;
                            thisAmc.Pm_Project_Owner_Lookup__c 		= thisAmc.Pm_Project_Owner_Lookup__c 	!= NULL	? 
                                thisAmc.Pm_Project_Owner_Lookup__c 	: parentProjectMap.get(thisAmc.Parent_Project__c).Pm_Project_Owner_Lookup__c;
                            thisAmc.SI_Partner_Account__c 			= thisAmc.SI_Partner_Account__c 		!= NULL	? 
                                thisAmc.SI_Partner_Account__c 		: parentProjectMap.get(thisAmc.Parent_Project__c).SI_Partner_Account__c;
                            thisAmc.In_house_project__c 			= thisAmc.In_house_project__c 			!= NULL	? 
                                thisAmc.In_house_project__c 			: parentProjectMap.get(thisAmc.Parent_Project__c).In_house_project__c;
                            thisAmc.Status__c 						= thisAmc.Status__c 					!= NULL	? 
                                thisAmc.Status__c 					: parentProjectMap.get(thisAmc.Parent_Project__c).Status__c;
                         /* thisAmc.Scope_Category__c 				= thisAmc.Scope_Category__c 			!= NULL	? 
                                thisAmc.Scope_Category__c 			: parentProjectMap.get(thisAmc.Parent_Project__c).Scope_Category__c;*/
                            thisAmc.Mode_Of_Integration__c 			= thisAmc.Mode_Of_Integration__c 		!= NULL	? 
                                thisAmc.Mode_Of_Integration__c 		: parentProjectMap.get(thisAmc.Parent_Project__c).Mode_Of_Integration__c;
                            thisAmc.Product__c 						= thisAmc.Product__c 					!= NULL	? 
                                thisAmc.Product__c 					: parentProjectMap.get(thisAmc.Parent_Project__c).Product__c;
                            thisAmc.Client_ERP__c  					= thisAmc.Client_ERP__c 				!= NULL	? 
                                thisAmc.Client_ERP__c 				: parentProjectMap.get(thisAmc.Parent_Project__c).Client_ERP__c;
                            thisAmc.Account_Owner_CSM__c 			= thisAmc.Account_Owner_CSM__c 			!= NULL	? 
                                thisAmc.Account_Owner_CSM__c 			: parentProjectMap.get(thisAmc.Parent_Project__c).Account_Owner_CSM__c;
                            thisAmc.Customer_Account_Owner__c 		= thisAmc.Customer_Account_Owner__c 	!= NULL	? 
                                thisAmc.Customer_Account_Owner__c 	: parentProjectMap.get(thisAmc.Parent_Project__c).Customer_Account_Owner__c;
                            thisAmc.Delivery_Owner__c 				= thisAmc.Delivery_Owner__c 	!= NULL	? 
                                thisAmc.Delivery_Owner__c 			: parentProjectMap.get(thisAmc.Parent_Project__c).Delivery_Owner__c;
                        }
                    }
                }
            }
        } catch(Exception e){
            System.debug('Error in updateing amc module fields on populatin Parent Project : '+e.getMessage()+'line : '+e.getLineNumber());
        }
        
    }
    
    public static void autoUpdateAmcFields(Map<Id,Project__c> newProjectsMap, Map<Id,Project__c> oldProjectsMap){
        
        Map<Id,Project__c> amcModuleMap = new Map<Id,Project__c>([SELECT Id, Parent_Project__c, Name, Scope_Category__c, 
                                                                  Mode_Of_Integration__c, Product__c, Client_ERP__c, 
                                                                  Account_Owner_CSM__c, Customer_Account_Owner__c,Delivery_Owner__c
                                                                  FROM Project__c 
                                                                  WHERE RecordType.DeveloperName = 'AMC_Module'
                                                                  AND Parent_Project__c IN :newProjectsMap.keySet()]);
        System.debug('amcModuleMap :: '+amcModuleMap);
        List<Project__c> amcModulesToUpdate = new List<Project__c>();
        if(!amcModuleMap.isEmpty()){
            for(Project__c thisAMC : amcModuleMap.Values()){
                
              /*thisAMC.Scope_Category__c = 
                    ( thisAMC.Scope_Category__c == oldProjectsMap.get(thisAMC.Parent_Project__c).Scope_Category__c ) ? 
                    newProjectsMap.get(thisAMC.Parent_Project__c).Scope_Category__c : thisAMC.Scope_Category__c;*/
                
                thisAMC.Mode_Of_Integration__c = 
                    ( thisAMC.Mode_Of_Integration__c == oldProjectsMap.get(thisAMC.Parent_Project__c).Mode_Of_Integration__c ) ? 
                    newProjectsMap.get(thisAMC.Parent_Project__c).Mode_Of_Integration__c : thisAMC.Mode_Of_Integration__c;
                
                thisAMC.Product__c = 
                    ( thisAMC.Product__c == oldProjectsMap.get(thisAMC.Parent_Project__c).Product__c ) ? 
                    newProjectsMap.get(thisAMC.Parent_Project__c).Product__c : thisAMC.Product__c;
                
                thisAMC.Client_ERP__c = 
                    ( thisAMC.Client_ERP__c == oldProjectsMap.get(thisAMC.Parent_Project__c).Client_ERP__c ) ? 
                    newProjectsMap.get(thisAMC.Parent_Project__c).Client_ERP__c : thisAMC.Client_ERP__c;
                
                thisAMC.Account_Owner_CSM__c = 
                    ( thisAMC.Account_Owner_CSM__c == oldProjectsMap.get(thisAMC.Parent_Project__c).Account_Owner_CSM__c ) ? 
                    newProjectsMap.get(thisAMC.Parent_Project__c).Account_Owner_CSM__c : thisAMC.Account_Owner_CSM__c;
                
                thisAMC.Customer_Account_Owner__c = 
                    ( thisAMC.Customer_Account_Owner__c == oldProjectsMap.get(thisAMC.Parent_Project__c).Customer_Account_Owner__c ) ? 
                    newProjectsMap.get(thisAMC.Parent_Project__c).Customer_Account_Owner__c : thisAMC.Customer_Account_Owner__c;
                
                thisAMC.Delivery_Owner__c = 
                    ( thisAMC.Delivery_Owner__c == oldProjectsMap.get(thisAMC.Parent_Project__c).Delivery_Owner__c ) ? 
                    newProjectsMap.get(thisAMC.Parent_Project__c).Delivery_Owner__c : thisAMC.Delivery_Owner__c;
                
                amcModulesToUpdate.add(thisAMC);
            }
        }
        System.debug('amcModulesToUpdate :: '+amcModulesToUpdate);
        if(amcModulesToUpdate.size()>0){
            try{
                Update amcModulesToUpdate;
            }catch(Exception e){
                System.debug('Error in auto updateing amc module fields on updating Parent Project : '+e.getMessage()+' line : '+e.getLineNumber());
            }
        }
    }
    
    @future
    public static void assetSoftUpdate(Set<Id> projIds){
        List<Asset> assetSoftUpdateList = new List<Asset>();
        
        
        for(AccountProjectAssetJunction__c apaJunctionInstance : [SELECT Id, Project__c, Asset__c 	
                                                                  FROM AccountProjectAssetJunction__c	
                                                                  WHERE Project__c IN :projIds]	
           ){	
               Asset tempAsset = new Asset (Id = apaJunctionInstance.Asset__c);	
               assetSoftUpdateList.add(tempAsset);	
           }	

       if(assetSoftUpdateList.size()>0){	
           update assetSoftUpdateList;	
       }
        
    }
    
    
}