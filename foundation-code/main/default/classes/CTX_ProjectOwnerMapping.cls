/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_ProjectOwnerMapping {
    
    /**	Priyanka Chettri - BIBHU	**/
    /**	Rajeev Rajanala - Vaishnav	**/
    /**	Harish Pancholi - Kartikeya	**/ 
    
    public static void projectOwnerMapping(List<Project__c> projects){
        Set<Id> SIAccounts = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
      
        for(Project__c thisProject : projects){
            if(thisProject.SI_Account_Lookup__c != NULL)
                SIAccounts.add(thisProject.SI_Account_Lookup__c);
            	accountIds.add(thisProject.Account__c);
        }
        
        
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, Onboarding_Owner__c
                                                            FROM Account 
                                                            WHERE Id IN :SIAccounts OR Id IN :accountIds]);
     
        
        for(Project__c thisRec : projects){
            if(thisRec.Project_Owner_automation__c 		== TRUE && 
               thisRec.Status__c 						!= 'Complete'&&
               thisRec.Status__c 						!= 'Churn')
            {
                
                /**	Installation	**/
                if(thisRec.Scope_Category__c == 'Installation' &&
                   thisRec.In_house_project__c == TRUE			){
                       
                       thisRec.OwnerId 						= System.Label.PM_Owner_Shriram_Bhat;
                       thisRec.Pm_Project_Owner_Lookup__c 	= System.Label.PM_Owner_Shriram_Bhat;
                       thisRec.Delivery_Owner__c			= System.Label.PM_Owner_Shriram_Bhat;
                       
                   } 
                
                /**	Consultation	**/
                if(
                    thisRec.Scope_Category__c == 'Consultation' && 
                    thisRec.In_house_project__c == TRUE)			
                {
                    thisRec.OwnerId 						= System.Label.PM_Owner_Shriram_Bhat;
                    thisRec.Pm_Project_Owner_Lookup__c 		= System.Label.PM_Owner_Shriram_Bhat;
                    thisRec.Delivery_Owner__c 				= System.Label.PM_Owner_Shriram_Bhat;
                }
                
                
                
                if( thisRec.Scope_Category__c == 'Development' &&
                   thisRec.In_house_project__c == TRUE ){
                       thisRec.OwnerId 						= System.Label.PM_Owner_Daksh_Sikka;
                       thisRec.Pm_Project_Owner_Lookup__c 	= System.Label.PM_Owner_Daksh_Sikka;
                   }
                
                
                if( thisRec.Scope_Category__c == 'Development' &&
                   thisRec.In_house_project__c == FALSE && 
                   accountMap.containsKey(thisRec.SI_Account_Lookup__c) &&
                   accountMap.get(thisRec.SI_Account_Lookup__c).Name != NULL){
                       if(accountMap.get(thisRec.SI_Account_Lookup__c).Name.containsIgnoreCase('Slite') ||
                          accountMap.get(thisRec.SI_Account_Lookup__c).Name.containsIgnoreCase('diligence') ||
                          accountMap.get(thisRec.SI_Account_Lookup__c).Name.containsIgnoreCase('Piranha') ||
                          accountMap.get(thisRec.SI_Account_Lookup__c).Name.containsIgnoreCase('Trenchant '))
                       {
                           thisRec.OwnerId 						= System.Label.PM_Owner_Rajesh_Chandran;
                           thisRec.Pm_Project_Owner_Lookup__c 	= System.Label.PM_Owner_Rajesh_Chandran;
                           
                       }else if(accountMap.get(thisRec.SI_Account_Lookup__c).Name.containsIgnoreCase('Denpro') ||
                                accountMap.get(thisRec.SI_Account_Lookup__c).Name.containsIgnoreCase('Iteanz') ||
                                accountMap.get(thisRec.SI_Account_Lookup__c).Name.containsIgnoreCase('Osswal'))
                       {
                           thisRec.OwnerId 						= System.Label.PM_Owner_Yash_Kothari;
                           thisRec.Pm_Project_Owner_Lookup__c 	= System.Label.PM_Owner_Yash_Kothari;
                           
                           
                       }else  if(accountMap.get(thisRec.SI_Account_Lookup__c).Name.containsIgnoreCase('Sterck') ||
                                 accountMap.get(thisRec.SI_Account_Lookup__c).Name.containsIgnoreCase('Cloudare') ||
                                 accountMap.get(thisRec.SI_Account_Lookup__c).Name.containsIgnoreCase('Prateek'))
                       {
                           thisRec.OwnerId 						= System.Label.PM_Owner_Harish_Pancholi;
                           thisRec.Pm_Project_Owner_Lookup__c 	= System.Label.PM_Owner_Harish_Pancholi;
                           
                       }else {
                           thisRec.OwnerId 						= System.Label.PM_Owner_Harish_Pancholi;
                           thisRec.Pm_Project_Owner_Lookup__c 	= System.Label.PM_Owner_Harish_Pancholi;
                       }
                   }
                
                
                
                if( 
                    thisRec.Scope_Category__c == 'Development' )
                {
                    if(thisRec.Client_ERP__c?.containsIgnoreCase('Microsoft')) {
                        thisRec.OwnerId 					= System.Label.PM_Owner_Rakesh_Ranjan;
                        thisRec.Pm_Project_Owner_Lookup__c 	= System.Label.PM_Owner_Rakesh_Ranjan;
                        thisRec.Delivery_Owner__c 			= System.Label.PM_Owner_Rakesh_Ranjan;
                    }else if( thisRec.Client_ERP__c?.containsIgnoreCase('Custom'))
                    {
                        thisRec.Delivery_Owner__c 			= System.Label.PM_Owner_Shriram_Bhat;
                    } else if(
                        thisRec.Product__c == 'Clear Capture' 			|| 
                        thisRec.Product__c == 'Invoice Discounting'  	||
                        thisRec.Product__c == 'GSTIN Verification'	 	||
                        thisRec.Product__c == 'AP'	 					||
                        thisRec.Product__c == 'ASP/GSP'	
                    ){
                        
                        thisRec.Delivery_Owner__c 			= System.Label.PM_Owner_Rajeev_Rajanala;
                    }else if(thisRec.Product__c == 'EINV'										||
                             thisRec.Product__c == 'EWB'	)
                    {
                        thisRec.Delivery_Owner__c 			= System.Label.PM_Owner_Hanumanthu_Jarpala;                                 
                    }else if(thisRec.Product__c == 'MAX ITC'){
                        thisRec.Delivery_Owner__c 			= System.Label.PM_Owner_Sakthidoss_Gajendran;                                 
                    }
                }
                
                if( 
                    thisRec.Scope_Category__c == 'Development' )
                {
                    if(thisRec.Product__c == 'EINV'	||
                       thisRec.Product__c == 'EWB')
                    {
                        thisRec.Pm_Project_Owner_Lookup__c = system.label.PM_Owner_Shriram_Bhat;
                    } else if(thisRec.Product__c == 'Clear Identity')
                    {
                        thisRec.Pm_Project_Owner_Lookup__c = System.Label.PM_Owner_Rakesh_Ranjan;	
                    } else if(thisRec.Product__c == 'DSC')
                    {
                        thisRec.Pm_Project_Owner_Lookup__c = System.Label.PM_Owner_Hanumanthu_Jarpala	;
                    }
                }
                
                /**	KSA	**/
                if(thisRec.Product__c == 'KSA EINV I' || 
                   thisRec.Product__c == 'KSA EINV II')
                {
                    thisRec.OwnerId 					= System.Label.PM_Owner_Usha  ;
                    thisRec.Pm_Project_Owner_Lookup__c 	= System.Label.PM_Owner_Usha ; 
                    thisRec.Delivery_Owner__c 			= System.Label.PM_Owner_Usha;
                    
                }
                
                
            }
        }
    }                   
}