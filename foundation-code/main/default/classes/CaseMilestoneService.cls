/**
* @File Name          : CaseMilestoneService.cls
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : Lokesh@SFDeveloper.SFDoc
* @Last Modified On   : 27/5/2020, 11:14:52 am
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    27/5/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public class CaseMilestoneService {
    
    /**
* @description 
* @author Lokesh@SFDeveloper.SFDoc | 27/5/2020 
* @param List<CaseMilestone> listOfCaseMilestones 
* @return void 
**/
    public static void updateMilestoneUtility(List<CaseMilestone> listOfCaseMilestones){
        List<Case> listOfCases=new List<Case>();
        for(CaseMilestone caseMilestonInstance:listOfCaseMilestones){
            Case caseInstance=new Case();
            caseInstance.Id=caseMilestonInstance.CaseId;
            system.debug('***In updateMilestoneUtility');
            if(caseMilestonInstance.MilestoneType.Name.containsIgnoreCase('Periodic update') && caseMilestonInstance.IsCompleted == False ){
                system.debug('***In PD');
                System.debug('<---------Periodic update----------->');
                //update the CompletionDate on CaseMilestone
                if(caseMilestonInstance.CompletionDate == null ){
                    caseMilestonInstance.CompletionDate=System.now();
                    caseInstance.Last_update_Sent__c=  System.now(); 
                    System.debug('caseInstance.Last_update_Sent__c'+caseInstance.Last_update_Sent__c);
                }
                listOfCases.add(caseInstance);
            }
            
            if(caseMilestonInstance.MilestoneType.Name.containsIgnoreCase('First reply time') && caseMilestonInstance.IsCompleted == False){
                system.debug('***In FRT');
                caseInstance.First_Reply_Sent__c=true;
                
                //update the CompletionDate on CaseMilestone
                if(caseMilestonInstance.CompletionDate == null ){
                    caseMilestonInstance.CompletionDate=System.now();
                }
                listOfCases.add(caseInstance);
            }
            
           /** if(caseMilestonInstance.MilestoneType.Name.containsIgnoreCase('Customer wait time') && caseMilestonInstance.IsCompleted == False  ){
                system.debug('***In CWT');
                if(caseMilestonInstance.CompletionDate == null ){
                    caseMilestonInstance.CompletionDate=System.now();
                }
                listOfCases.add(caseInstance);
            }**/
            
        }
        
        
        
        if(listOfCaseMilestones.size()>0){
            try{
                List<DataBase.SaveResult> resultAfterUpdateEventOnCaseMilestone= DataBase.update(listOfCaseMilestones);
            }Catch(Exception exp){
                System.debug(' <----Exceptio on CaseMilestone Update-------> \n'+exp.getMessage()+'\n'+exp.getLineNumber());
            }
        }
        
        Map<Id,Case> mapOfCases=new Map<Id,Case>();
        for(Case caseInstance:listOfCases){
            if(!mapOfCases.containsKey(caseInstance.Id)){
                mapOfCases.put(caseInstance.Id,caseInstance);
            }
        }
        
        if(listOfCases.size()>0){
            try{
                List<DataBase.SaveResult> resultAfterUpdateEventOnCase= DataBase.update(mapOfCases.Values());
            }Catch(Exception ex){
                System.debug(' <----Exception on Case Update-----> \n'+ex.getMessage()+'\n'+ex.getLineNumber());
            }
        }
    }
    
}