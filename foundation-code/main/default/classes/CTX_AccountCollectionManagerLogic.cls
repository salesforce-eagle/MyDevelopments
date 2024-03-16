public class CTX_AccountCollectionManagerLogic implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = ' SELECT Id, Attribution_To__c, OwnerId, Owner.Department, Owner.Division, '+
            ' Sales_Owner__c, Sales_Owner__r.Department, Sales_Owner__r.Division, '+
            ' (SELECT Id, Status, PurchaseDate, UsageEndDate FROM Assets) '+
            ' FROM Account WHERE '+ 
            ' Id IN ( SELECT AccountId FROM Asset WHERE AccountId != NULL ) '+
            ' AND  RecordType.Name = \'Enterprise\' ';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> accountScope){
        
        Date 				thisMonthStartDate		= Date.newInstance(system.today().year(), system.today().month(), 1);
        system.debug('thisMonthStartDate: '+thisMonthStartDate);
        Map<Id, Boolean>	accountId_AttributionTo	= new Map<Id, Boolean>();
        
        
        for(Account thisAccount : accountScope){
            
            if(thisAccount.getSobjects('Assets') != NULL && thisAccount.getSobjects('Assets').size() > 0){
                
                Integer maxAssetAgging;
                Boolean	isKAM = FALSE;
                
                for( Asset thisAsset : (List<Asset>)thisAccount.getSobjects('Assets') ){
                    
                    if(thisAsset.PurchaseDate != NULL){
                        if(maxAssetAgging != NULL){
                            
                            maxAssetAgging = maxAssetAgging < thisAsset.PurchaseDate.daysBetween(thisMonthStartDate) ?
                                thisAsset.PurchaseDate.daysBetween(thisMonthStartDate) : maxAssetAgging;
                        } else{
                            system.debug('thisAsset.PurchaseDate.daysBetween(thisMonthStartDate): '+thisAsset.PurchaseDate.daysBetween(thisMonthStartDate));
                            maxAssetAgging = thisAsset.PurchaseDate.daysBetween(thisMonthStartDate);
                        }
                    }
                    
                    if(maxAssetAgging != NULL && maxAssetAgging > 180){
                        isKAM = TRUE;
                        break;
                    } else if(maxAssetAgging != NULL && thisAsset.Status == 'Renewal'){
                        isKAM = TRUE;
                        break;
                    }
                }
                
                thisAccount.Asset_Ageing__c = maxAssetAgging;
                if(isKAM){
                    
                    if(thisAccount.Owner.Department == 'KAM' && thisAccount.Owner.Division == 'West'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_1; //Hemavathi 
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'Field Sales' && thisAccount.Owner.Division == 'Startup'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti 
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'KAM' && thisAccount.Owner.Division == 'North'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_3;//Ashfaq
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'KAM' && thisAccount.Owner.Division == 'South'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'Field Sales' && thisAccount.Owner.Division == 'North'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_3;//Ashfaq
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'Field Sales' && thisAccount.Owner.Division == 'West'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_1;//Hemavathi
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'PSU' && thisAccount.Owner.Division == 'PSU'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'EC' && thisAccount.Owner.Division == 'Operations Analyst'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_3;//Ashfaq
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'PSU' && thisAccount.Owner.Division == 'South'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'Channel Sales' && thisAccount.Owner.Division == 'Channel Sales'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'Non KAM Support' && thisAccount.Owner.Division == 'Non KAM Support'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'Field Sales' && thisAccount.Owner.Division == 'South'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'Inside Sales' && thisAccount.Owner.Division == 'Inside Sales'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_3;//Ashfaq
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'Field Sales' && thisAccount.Owner.Division == 'East'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_3;//Ashfaq
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'Non KAM Support' && thisAccount.Owner.Division == 'Non KAM Support'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'KAM' && thisAccount.Owner.Division == 'KAM Analyst'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'Field Sales' && thisAccount.Owner.Division == 'South1'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    if(thisAccount.Owner.Department == 'Field Sales' && thisAccount.Owner.Division == 'South2'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'KAM';
                    }
                    
                } 
                else{
                    
                    if(thisAccount.Sales_Owner__r.Department == 'KAM' && thisAccount.Sales_Owner__r.Division == 'West'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_1;//Hemavathi
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'Field Sales' && thisAccount.Sales_Owner__r.Division == 'Startup'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'KAM' && thisAccount.Sales_Owner__r.Division == 'North'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_3;//Ashfaq
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'KAM' && thisAccount.Sales_Owner__r.Division == 'South'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'Field Sales' && thisAccount.Sales_Owner__r.Division == 'North'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_3;//Ashfaq
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'Field Sales' && thisAccount.Sales_Owner__r.Division == 'West'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_1;//Hemavathi
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'PSU' && thisAccount.Sales_Owner__r.Division == 'PSU'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'EC' && thisAccount.Sales_Owner__r.Division == 'Operations Analyst'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_3;//Ashfaq
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'PSU' && thisAccount.Sales_Owner__r.Division == 'South'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'Channel Sales' && thisAccount.Sales_Owner__r.Division == 'Channel Sales'){
                        thisAccount.Collection_Manager__c	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'Non KAM Support' && thisAccount.Sales_Owner__r.Division == 'Non KAM Support'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'Field Sales' && thisAccount.Sales_Owner__r.Division == 'South'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'Inside Sales' && thisAccount.Sales_Owner__r.Division == 'Inside Sales'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_3;//Ashfaq
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'Field Sales' && thisAccount.Sales_Owner__r.Division == 'East'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_3;//Ashfaq
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'Non KAM Support' && thisAccount.Sales_Owner__r.Division == 'Non KAM Support'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'KAM' && thisAccount.Sales_Owner__r.Division == 'KAM Analyst'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'Field Sales' && thisAccount.Sales_Owner__r.Division == 'South1'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    if(thisAccount.Sales_Owner__r.Department == 'Field Sales' && thisAccount.Sales_Owner__r.Division == 'South2'){
                        thisAccount.Collection_Manager__c 	= System.label.Collection_Manager_Name_2;//Preeti
                        thisAccount.Attribution_To__c		= 'Sales';
                    }
                    
                }
                
            }
        }
        
        try{
            update accountScope;
        } catch(Exception ex){
            system.debug('Bibhu is updating error: '+ex.getMessage());
        }
        
        
        
        
        
        /**	Method END	**/
    }
    
    public void finish(Database.BatchableContext BC){}
    
}