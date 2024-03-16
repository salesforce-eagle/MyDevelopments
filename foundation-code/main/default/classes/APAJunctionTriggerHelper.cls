/**
* @File Name          : APAJunctionTriggerHelper.cls
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : Lokesh@SFDeveloper.SFDoc
* @Last Modified On   : 07/12/2020, 12:57:38 pm
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    07/12/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public without sharing class APAJunctionTriggerHelper {
    
    
    public static void updateSIPartnerAccountWithCount(Map<Id,AccountProjectAssetJunction__c> mapOfAccountProjectAssetJunctions ){
        System.debug('<----------Reached---------->');
        Set<Id> setOfIds=new Set<Id>();
        setOfIds=mapOfAccountProjectAssetJunctions.keySet();  
        
        Set<Id> setAccountIds=new Set<Id>();
        if(!mapOfAccountProjectAssetJunctions.isEmpty()){
            for(Id key:mapOfAccountProjectAssetJunctions.keySet()){
                setAccountIds.add(mapOfAccountProjectAssetJunctions.get(key).SI_Partner_Account__c);
            }
        }
        
        List<Account> listOfAccounts=[SELECT id,No_of_active_projects__c,No_of_project_completed__c ,(SELECT id,Project__r.Status__c,Project_Status__c from AccountProjectAssetJunctions1__r WHERE Project__c!=null /*AND SI_Partner_Account__c!=null*/) FROM Account WHERE RecordType.Name='SI Partner' and Id IN : setAccountIds];
        
        
        Set<Id> setOfActiveProjectIds=new Set<Id>();
        Set<Id> setOfCompletedProjectIds=new Set<Id>();
        List<Account> listOfAccountsToUpdate=new List<Account>();
        if(listOfAccounts.size()>0){
            for(Account accountInstance:listOfAccounts){
                
                if(accountInstance.AccountProjectAssetJunctions1__r.size()>0){
                    for(AccountProjectAssetJunction__c accountProjectAssetJunctionInstance :accountInstance.AccountProjectAssetJunctions1__r){
                        
                        
                        if(accountProjectAssetJunctionInstance.Project_Status__c!='Project Closed' || accountProjectAssetJunctionInstance.Project_Status__c==null){
                            setOfActiveProjectIds.add(accountProjectAssetJunctionInstance.Project__c);
                            System.debug('accountProjectAssetJunctionInstance***'+accountInstance.AccountProjectAssetJunctions1__r.size()+accountProjectAssetJunctionInstance.Project_Status__c+accountProjectAssetJunctionInstance );
                        }
                        if( accountProjectAssetJunctionInstance.Project_Status__c=='Project Closed'){
                            setOfCompletedProjectIds.add(accountProjectAssetJunctionInstance.Project__c);
                        }
                        
                    }
                }
                
                accountInstance.No_of_active_projects__c=setOfActiveProjectIds.size();
                accountInstance.No_of_project_completed__c=setOfCompletedProjectIds.size();
                listOfAccountsToUpdate.add(accountInstance);
            }        
            
        }
        
        if(listOfAccountsToUpdate.size()>0){
            update listOfAccountsToUpdate;
        }
       
    }
    
    public static void updateStartupAccountInProject(Map<Id,AccountProjectAssetJunction__c> mapOfAccountProjectAssetJunctions ){
        
        Set<Id> accIds = new Set<Id>();
        List<Project__c> prjList = new List<Project__c>();
 
        for(AccountProjectAssetJunction__c apaInst : [SELECT Id, Project__c, Customer_Account__r.EC_LC_Startup_Account__c  
                                                      FROM AccountProjectAssetJunction__c 
                                                      WHERE Id IN :mapOfAccountProjectAssetJunctions.keySet()])
            
        {
            if(apaInst.Project__c != NULL && apaInst.Customer_Account__r.EC_LC_Startup_Account__c != NULL){
                Project__c prj = new Project__c(Id = apaInst.Project__c);
                prj.EC_LC_Startup_Account__c = apaInst.Customer_Account__r.EC_LC_Startup_Account__c;
                prjList.add(prj);
            }
        }
        
        if(!prjList.isEmpty()){
            update prjList;
        }
        
    }
    
}