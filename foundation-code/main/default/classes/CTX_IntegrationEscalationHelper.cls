public class CTX_IntegrationEscalationHelper {
    
    public static void populateProjectDetailsOnAsset(Map<Id,Asset> newAssetMap,Map<Id,Asset> oldAssetMap){
        
        Map<Id, Id> 								getAssetProjectMap 		= new Map<Id, Id>();
        Map<Id, AccountProjectAssetJunction__c> 	getAssetJunctionMap 	= new Map<Id, AccountProjectAssetJunction__c>();
        Map<String, Id> 							leastStageProjectMap 	= new Map<String, Id>();
        
        for(
            AccountProjectAssetJunction__c thisRec : [ SELECT Id, Customer_Account__c, Project__c, Asset__c, 
                                                      
                                                      Asset__r.Project_Stage__c, Project__r.Project_Stage__c, Project__r.Name, Project__r.Status__c,
                                                      Asset__r.Project_Status__c, Project__r.Scope_Category__c, Asset__r.Project_Scope_Category__c,
                                                      
                                                      Project_Comment_Formula__c, Project_PM_Project_Owner_Email__c, Project_Solution_Engineer__c, 
                                                      
                                                      Project__r.Issue_Description__c, Project__r.Pm_Project_Owner_Lookup__r.Name, Project__r.LastModifiedDate,
                                                      Project__r.Issue_Type__c, Project__r.Project_Name__c, Project__r.Client_ERP__c 
                                                      
                                                      FROM AccountProjectAssetJunction__c WHERE 
                                                      Asset__c IN : newAssetMap.keySet() AND
                                                      Project__r.Status__c != 'Churn'
                                                      ORDER BY Asset__c ]
        ){
            
            if(thisRec.Project__r.Project_Stage__c == 'Awaiting Kick-off'){
                leastStageProjectMap.put(thisRec.Project__r.Project_Stage__c, thisRec.Asset__c);
                getAssetJunctionMap.put(thisRec.Asset__c,thisRec);
                getAssetProjectMap.put(thisRec.Asset__c,thisRec.Project__c);
            }
            
            if(thisRec.Project__r.Project_Stage__c == 'Project Plan'){
                if( leastStageProjectMap.containsKey('Awaiting Kick-off') ){
                    /**	Do Nothing	**/
                } else{
                    leastStageProjectMap.put(thisRec.Project__r.Project_Stage__c, thisRec.Asset__c);
                    getAssetJunctionMap.put(thisRec.Asset__c,thisRec);
                    getAssetProjectMap.put(thisRec.Asset__c,thisRec.Project__c);
                }
            }
            
            if(thisRec.Project__r.Project_Stage__c == 'Implementation'){
                if( leastStageProjectMap.containsKey('Awaiting Kick-off') || 
                   leastStageProjectMap.containsKey('Project Plan')
                  ){
                    /**	Do Nothing	**/
                } else{
                    leastStageProjectMap.put(thisRec.Project__r.Project_Stage__c, thisRec.Asset__c);
                    getAssetJunctionMap.put(thisRec.Asset__c,thisRec);
                    getAssetProjectMap.put(thisRec.Asset__c,thisRec.Project__c);
                }
            }
            
            if(thisRec.Project__r.Project_Stage__c == 'UAT'){
                if( 
                    leastStageProjectMap.containsKey('Awaiting Kick-off') 	|| 
                    leastStageProjectMap.containsKey('Project Plan') 		|| 
                    leastStageProjectMap.containsKey('Implementation')
                ){
                    /**	Do Nothing	**/
                } else{
                    leastStageProjectMap.put(thisRec.Project__r.Project_Stage__c, thisRec.Asset__c);
                    getAssetJunctionMap.put(thisRec.Asset__c,thisRec);
                    getAssetProjectMap.put(thisRec.Asset__c,thisRec.Project__c);
                }
            }
            if(thisRec.Project__r.Project_Stage__c == 'Live'){
                if( 
                    leastStageProjectMap.containsKey('Awaiting Kick-off') 	|| 
                    leastStageProjectMap.containsKey('Project Plan') 		|| 
                    leastStageProjectMap.containsKey('Implementation')		||
                    leastStageProjectMap.containsKey('UAT')
                ){
                    /**	Do Nothing	**/
                } else{
                    leastStageProjectMap.put(thisRec.Project__r.Project_Stage__c, thisRec.Asset__c);
                    getAssetJunctionMap.put(thisRec.Asset__c,thisRec);
                    getAssetProjectMap.put(thisRec.Asset__c,thisRec.Project__c);
                }
            }

        }
        
        System.debug('getAssetProjectMap : '+ getAssetProjectMap);
        Map<Id,Integer> projectWithCurrentStageAging = new Map<Id,Integer>();
        Map<Id,Date> projectWithCurrentStageChangeDate = new Map<Id,Date>();
        Map<Id,Date> projectWithCreateDate = new Map<Id,Date>();
        Date CurrentStageDate;
        Date ProjectCreateDate;
        
        //for stage change date
        for(Project__History thisProjectHistory : [ SELECT Id, ParentId, CreatedDate, Field 
                                                   FROM Project__History 
                                                   WHERE ParentId IN :getAssetProjectMap.values() 
                                                   AND Field IN ('Project_Stage__c') ] 
           ){
               System.debug('thisProjectHistory :'+thisProjectHistory);
               CurrentStageDate = Date.newinstance(thisProjectHistory.CreatedDate.year(), thisProjectHistory.CreatedDate.month(), thisProjectHistory.CreatedDate.day());
               projectWithCurrentStageAging.put(thisProjectHistory.ParentId, CurrentStageDate.daysBetween(Date.today()));
               projectWithCurrentStageChangeDate.put(thisProjectHistory.ParentId, CurrentStageDate);
           }
        
        //for project created date map
        for(Project__c thisProject : [ SELECT Id, CreatedDate FROM Project__c 
                                      WHERE Id IN :getAssetProjectMap.values() ] 
           ){
               System.debug('thisProject :'+thisProject);
               ProjectCreateDate = Date.newinstance(thisProject.CreatedDate.year(), thisProject.CreatedDate.month(), thisProject.CreatedDate.day());
               projectWithCreateDate.put(thisProject.Id,ProjectCreateDate);
           }
        
        System.debug('CurrentStageDate :'+CurrentStageDate);
        System.debug('projectWithCurrentStageAging :'+projectWithCurrentStageAging);
        
        for(Asset thisRec : newAssetMap.values()){
            
            if(getAssetJunctionMap.containsKey(thisRec.Id)){
                
                thisRec.Project_Comment_Field__c 					= getAssetJunctionMap.get(thisRec.Id).Project_Comment_Formula__c;
                thisRec.Project_Issue_Description_Field__c 			= getAssetJunctionMap.get(thisRec.Id).Project__r.Issue_Description__c;
                System.debug('thisRec.Project_Issue_Description_Field__c'+thisRec.Project_Issue_Description_Field__c);
                thisRec.Project_PM_Owner_Email_Field__c 			= getAssetJunctionMap.get(thisRec.Id).Project_PM_Project_Owner_Email__c;
                thisRec.Project_Solution_Engineer_Email_Field__c	= getAssetJunctionMap.get(thisRec.Id).Project_Solution_Engineer__c;
                thisRec.PM_Project_Owner_Name__c					= getAssetJunctionMap.get(thisRec.Id).Project__r.Pm_Project_Owner_Lookup__r.Name;
                thisRec.Project_Stage__c							= getAssetJunctionMap.get(thisRec.Id).Project__r.Project_Stage__c;
                thisRec.Project_Status__c							= getAssetJunctionMap.get(thisRec.Id).Project__r.Status__c;
                thisRec.Project_Scope_Category__c 					= getAssetJunctionMap.get(thisRec.Id).Project__r.Scope_Category__c;
                thisRec.Project_Name__c								= getAssetJunctionMap.get(thisRec.Id).Project__r.Project_Name__c;
                thisRec.Project_Issue_Type__c						= getAssetJunctionMap.get(thisRec.Id).Project__r.Issue_Type__c;
                thisRec.Project_Client_ERP__c						= getAssetJunctionMap.get(thisRec.Id).Project__r.Client_ERP__c;
                thisRec.Project_ID__c								= getAssetJunctionMap.get(thisRec.Id).Project__c;
                
                DateTime myDate = getAssetJunctionMap.get(thisRec.Id).Project__r.LastModifiedDate;
                
                thisRec.Project_Last_Modified_Date_Field__c			= Date.newInstance( 
                        myDate.year(), 
                        myDate.month(), 
                        myDate.day()
                    );
                
                if(projectWithCurrentStageAging.containsKey(getAssetProjectMap.get(thisRec.Id))){
                    thisRec.Aging_in_current_Stage__c 				= projectWithCurrentStageAging.get(getAssetProjectMap.get(thisRec.Id));
                }else{
                    thisRec.Aging_in_current_Stage__c				= thisRec.Escalation_Days_Count__c;
                }
                
                //StageChangeDate
                if(projectWithCurrentStageChangeDate.containsKey(getAssetProjectMap.get(thisRec.Id))){
                    thisRec.Project_Stage_Change_Date__c = projectWithCurrentStageChangeDate.get(getAssetProjectMap.get(thisRec.Id));
                }else{
                    thisRec.Project_Stage_Change_Date__c = projectWithCreateDate.get(getAssetProjectMap.get(thisRec.Id));
                }
                
                
            }
        }
        
        
    }
    
    public static void updateAccountARRTypeDetails(List<Asset> newAssets){
        
        List<Asset> 		updateAssetList 	= new List<Asset>();
        Map<Id, String>		accountIdARRMap		= new Map<id, String>();
        
        for(Asset thisRec : newAssets){
            if(thisRec.AccountId != NULL){
                accountIdARRMap.put(thisRec.AccountId, NULL);
            }
        }
        
        for(
            Asset thisRec : [SELECT Id, AccountId, Account.Sum_of_ARR_Assets__c FROM Asset WHERE AccountId IN :accountIdARRMap.keySet() ]
        ){
            
            system.debug('thisRec.Account.Sum_of_ARR_Assets__c: '+thisRec.Account.Sum_of_ARR_Assets__c);
            String accountARRType;
            
            if(thisRec.Account.Sum_of_ARR_Assets__c  != NULL){
                
                if(thisRec.Account.Sum_of_ARR_Assets__c  >= 2000000.00)
                    accountIdARRMap.put(thisRec.AccountId, 'A1');
                if(thisRec.Account.Sum_of_ARR_Assets__c  >= 400000.00 && thisRec.Account.Sum_of_ARR_Assets__c  < 2000000.00)
                    accountIdARRMap.put(thisRec.AccountId, 'A2');
                if(thisRec.Account.Sum_of_ARR_Assets__c  >= 100000.00 	&& thisRec.Account.Sum_of_ARR_Assets__c  < 400000.00)
                    accountIdARRMap.put(thisRec.AccountId, 'A3');
                if(thisRec.Account.Sum_of_ARR_Assets__c  < 100000.00)
                    accountIdARRMap.put(thisRec.AccountId, 'A4');
            }
        }
        
        for(Asset thisRec : newAssets){
            if(accountIdARRMap.containsKey(thisRec.AccountId)){
                thisRec.Account_ARR_Type__c = accountIdARRMap.get(thisRec.AccountId);
            }
        }
        
        
    }
}