/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-31-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class AssetTriggerHelper {
    
    public static void createOrder(List<Asset> integrationAsset){
        pricebook2 stdPriceBook = [select id from pricebook2 LIMIT 1];
        map<Id,OrderItem> assetOrderItemMap = new map<Id,OrderItem>();
        List<Order> NewOrderlist = new List<Order>();
        set<Id>  PBEID = new set<Id>();
        map<Id,List<asset>> accMap = new  map<Id,List<asset>>();
        for(asset assIns:integrationAsset ){
            PBEID.add(assIns.product2Id);
            list<asset> tempList = new list<asset>();
            if(!accMap.containsKey(assIns.accountId)){
                tempList.add(assIns);
                accMap.put(assIns.accountId,tempList);
            }
            else{
                tempList = accMap.get(assIns.accountId);
                tempList.add(assIns);
                accMap.put(assIns.accountId,tempList);
            }
            
        }
        //map<Id, list<order>> orderMap = new map<Id, list<order>>();
        list<aggregateResult> orderExistList = [select accountId Id,max(id) orderId from order where accountId in: accMap.keySet() group By accountId]; //max(id) - Just to choose one order out of all the orders
        Map<id,SObject> accIdWithOrder = new Map<id,SObject>(orderExistList);
        Set<id> accIdWithOrderSet = accIdWithOrder.keySet();
        list<aggregateResult> orderExistList1 = [select accountId Id,MAX(id)orderId from order where accountId in: accMap.keySet() group By accountId]; //max(id) - Just to choose one order out of all the orders
        Map<id,order> orderMap = new Map<id,order>([select accountId ,id,currencyISOCode from order where accountId in: accMap.keySet()]);
        Map<id,aggregateResult> accIdWithOrder1 = new Map<id,aggregateResult>(orderExistList1);
        List<pricebookEntry> PBIDList = new List<pricebookEntry>([select id,product2Id,currencyISOCode  from pricebookEntry where product2Id in:PBEID]);
        Map<Id, priceBookEntry> PBIDMap = new Map<Id, priceBookEntry>();
        for(pricebookEntry PBE :PBIDList ){
            PBIDMap.put(PBE.product2id, PBE);
            
        }
        for(asset assIns:integrationAsset){
            system.debug('test@##@'+accIdWithOrder.get(assIns.AccountId));
            if(!accIdWithOrderSet.contains(assIns.accountId) || orderMap.get(String.ValueOf(accIdWithOrder.get(assIns.accountId).get('orderId'))).currencyISOCode != PBIDMap.get(assIns.Product2Id).currencyISOCode ){
                Order NewOrder = new Order();
                // NewOrder.OpportunityId = opp.Id;
                NewOrder.AccountId = assIns.AccountId;
                NewOrder.EffectiveDate = assIns.purchaseDate;
                NewOrder.Pricebook2Id = stdPriceBook.Id;
                NewOrder.Status = 'Draft';
                NewOrder.CurrencyISOCode = PBIDMap.get(assIns.Product2Id).currencyISOCode;
                NewOrderlist.add(NewOrder);
                
            }
            else{
                Order NewOrder = new Order();
                NewOrder.Id = String.ValueOf(accIdWithOrder.get(assIns.AccountId).get('orderId'));
                NewOrder.Status = 'Draft';
                NewOrderlist.add(NewOrder);
            }
        }
        if(!NewOrderlist.isEmpty()){
            upsert(NewOrderlist);
        }
        orderExistList1 = [select accountId Id,MAX(id) orderId from order where accountId in: accMap.keySet() group By accountId]; //max(id) - Just to choose one order out of all the orders
        accIdWithOrder1 = new Map<id,aggregateResult>(orderExistList1);
        
        for(asset assIns:integrationAsset){
            OrderItem oi = new OrderItem();
            system.debug('OrderId$%'+(Id)accIdWithOrder1.get(assIns.accountId).get('orderId'));
            oi.OrderId = (Id)accIdWithOrder1.get(assIns.accountId).get('orderId');
            oi.Quantity = 1;
            //oi.PricebookEntryId = oli.PricebookEntryId;
            oi.UnitPrice = assIns.Price;
            oi.Product2Id = assIns.Product2Id;  
            oi.pricebookEntryId= PBIDMap.get(assIns.Product2Id).id;   
            system.debug('OrderItemCurrency'+oi.CurrencyIsoCode);
            assetOrderItemMap.put(assIns.Id,oi) ;  
        }
        if(!assetOrderItemMap.values().isEmpty()){
            insert assetOrderItemMap.values();
        }
        for(asset assIns:integrationAsset){
            assIns.Order_Line__c = assetOrderItemMap.get(assIns.Id).Id;
        }
        if(integrationAsset.size() > 0)
            update(integrationAsset);
    }
    
    public static void updateAccountStatus(List<Asset> listOfAssetsToUpdateAccounts){}
    
    
    /**	Priority List Block	**/
    public static void updatePriorityList(Map<Id,Asset> newAssetMap){
        
        Set<Id> 		accountIdSet 					= new Set<Id>();
        Set<Id> 		opportunityIdSet 				= new Set<Id>();
        Set<Id> 		active_MS_ARR_AssetForAccount 	= new Set<Id>();
        Set<Id> 		opportunityWithARRProduct 		= new Set<Id>();
        Set<Asset> 		assetListToUpdate 				= new Set<Asset>();
        Map<Id,Asset> 	assetMap;
        
        for(Asset thisAsset : newAssetMap.values()){
            
            accountIdSet.add(thisAsset.AccountId);
            
            if(thisAsset.Opportunity__c != NULL)
                opportunityIdSet.add(thisAsset.Opportunity__c);
        }
        system.debug('opportunityIdSet: '+opportunityIdSet);
        
        
        for(Asset thisAsset : [ SELECT Id, Status, Billing_Type__c, AccountId, Product2.Product_category__c
                               FROM Asset WHERE 
                               AccountId IN :accountIdSet AND 
                               Billing_Type__c = 'ARR' AND 
                               Product2.Product_category__c = 'MS' AND 
                               Status = 'Active' ]
           ){
               active_MS_ARR_AssetForAccount.add(thisAsset.Id);               
           }
        
        if(opportunityIdSet.size() > 0){
            
            for(OpportunityLineItem oli : [ SELECT OpportunityId, Name, Product2.Billing_Type__c, Product2.Product_Category__c 
                                           FROM OpportunityLineItem WHERE 
                                           Product2.Product_Category__c = 'MS' AND 
                                           Product2.Billing_Type__c = 'ARR' AND 
                                           OpportunityId IN :opportunityIdSet ]
               ){
                   opportunityWithARRProduct.add(oli.OpportunityId);
               }
            
            assetMap = new Map<Id,Asset>([ SELECT Id, Name, Opportunity__c, Opportunity__r.Id,
                                          Opportunity__r.Owner.Department, Product2.Product_Line__c,
                                          Product2.Product_Category__c
                                          FROM Asset WHERE 
                                          Opportunity__c IN :opportunityIdSet ]);
        }
        
        
        for(Asset thisAsset : newAssetMap.values()){
            
            if(thisAsset.Opportunity__c != NULL){
                
                if(
                    (
                        opportunityWithARRProduct != NULL && 
                        opportunityWithARRProduct.contains(thisAsset.Opportunity__c)
                    )
                ){
                    Asset newAsset = new Asset();
                    newAsset.Id = thisAsset.Id;
                    newAsset.Priority_List__c = 'MS';
                    assetListToUpdate.add(newAsset);
                } else if( 
                    assetMap.containsKey(thisAsset.Id) &&
                    assetMap.get(thisAsset.Id).Product2.Product_Line__c == 'Max'
                ){
                    system.debug('I am a max user');
                    Asset newAsset = new Asset();
                    newAsset.Id = thisAsset.Id;
                    newAsset.Priority_List__c = 'MaxITC';
                    assetListToUpdate.add(newAsset);
                } else if(
                    assetMap.containsKey(thisAsset.Id) &&
                    assetMap.get(thisAsset.Id).Opportunity__c != NULL && 
                    assetMap.get(thisAsset.Id).Opportunity__r.Owner.Department != NULL && 
                    assetMap.get(thisAsset.Id).Opportunity__r.Owner.Department.Contains('Sales')
                ){
                    Asset newAsset = new Asset();
                    newAsset.Id = thisAsset.Id;
                    newAsset.Priority_List__c = 'Sales';
                    assetListToUpdate.add(newAsset);
                } else if(
                    assetMap.containsKey(thisAsset.Id) &&
                    assetMap.get(thisAsset.Id).Opportunity__c != NULL && 
                    assetMap.get(thisAsset.Id).Opportunity__r.Owner.Department != NULL && 
                    assetMap.get(thisAsset.Id).Opportunity__r.Owner.Department.Contains('KAM')
                ){
                    Asset newAsset = new Asset();
                    newAsset.Id = thisAsset.Id;
                    newAsset.Priority_List__c = 'KAM';
                    assetListToUpdate.add(newAsset);
                }
            } else{
                
                if(
                    active_MS_ARR_AssetForAccount != NULL && 
                    active_MS_ARR_AssetForAccount.contains(thisAsset.Id)
                ){
                    Asset newAsset = new Asset();
                    newAsset.Id = thisAsset.Id;
                    newAsset.Priority_List__c = 'MS';
                    assetListToUpdate.add(newAsset);
                } else if(
                    thisAsset.Account.Owner.Department != NULL &&
                    thisAsset.Account.Owner.Department.Contains('Sales')
                ){
                    Asset newAsset = new Asset();
                    newAsset.Id = thisAsset.Id;
                    newAsset.Priority_List__c = 'Sales';
                    assetListToUpdate.add(newAsset);
                } else if(
                    thisAsset.Account.Owner.Department != NULL &&
                    thisAsset.Account.Owner.Department.Contains('KAM')
                ){
                    Asset newAsset = new Asset();
                    newAsset.Id = thisAsset.Id;
                    newAsset.Priority_List__c = 'KAM';
                    assetListToUpdate.add(newAsset);
                }
            }
        }
        
        system.debug('I am assetListToUpdate: '+assetListToUpdate.size());
        if(assetListToUpdate.size()>0){
            RecursiveTriggerHandler.isFirstTime = FALSE;
            Database.SaveResult[] saveResultList = Database.update(new List<Asset>(assetListToUpdate), FALSE);
            for (Database.SaveResult sr : saveResultList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted Asset Id: ' + sr.getId());
                } else{
                    
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred. ASSET');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }

            RecursiveTriggerHandler.isFirstTime = TRUE;
        }
    }
    
    
    Public Static void activeStatusChange(Map<Id,asset> MapOfNewRecords){}
    
    /** START :: bhaveshjindal :: auto create Project for Integration Assets **/
    Public Static void autoCreateIntegrationProject(Set<Id> ListOfNewAssetIDs){
        
        system.debug('<<--------:: projectAutoCreation entered ::-------->> ');
        
        List<Project__c> 			projectsToCreateList 						= new List<Project__c>();
        Set<Id>						opportunityIds								= new Set<Id>();
        List<Id>                	opportunityIdsList;
        Set<Id>						contentDocumentIds							= new Set<Id>();
        Set<Id>						contentVersionIds							= new Set<Id>();
        List<ContentDistribution>	contentDistributionListToInsert 			= new List<ContentDistribution>();
        Map<Id,ContentDocumentLink> opportunityToContentDocumentLinkMap 		= new Map<Id,ContentDocumentLink>();
        Map<Id,ContentVersion> 		contentDocumentToContentcontentVersionMap 	= new Map<Id,ContentVersion>();
        Map<Id,ContentDistribution> contentVersionToContentDistributionMap 		= new Map<Id,ContentDistribution>();
        Map<String,String>			productLineToProjectProductMap				= new Map<String,String>();
        Boolean						isSuccess									= FALSE;
        String SOQLQuery;
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<AccountProjectAssetJunction__c> apaJunctionListToCreate			= new List<AccountProjectAssetJunction__c>();
        
        
        Map<Id, Asset> 				newAssetMap 							= new Map<Id, Asset>(
            [ SELECT Id, AccountId, Opportunity__c, Product2Id, Asset_Type__c, Account.RecordType.DeveloperName,
             
             Account.Country_of_Origin__c, CreatedDate,
             
             Type_of_Integration__c, Type_of_Integration_Project__c, ERP__c, Opportunity__r.RecordType.DeveloperName,
             
             Account.Name, Type_of_Integration_QLI__c, Account.Onboarding_Owner__c, Account.Onboarding_Owner__r.Name,
             
             Opportunity__r.AccountId, Opportunity__r.Account.Name, Opportunity__r.Master_Admin_Email__c,
             
             Product2.Name, Product2.OrderForm_Product_Name__c, Price, Product2.Product_Line__c,Opportunity__r.Id,

             Opportunity__r.ClearTax_Billing_Entity__c
             
             FROM Asset WHERE Id IN :ListOfNewAssetIDs ]
        );
        
        for(Id thisAssetId : newAssetMap.keySet()){
            Asset thisAsset = newAssetMap.get(thisAssetId);
            opportunityIds.add(thisAsset.Opportunity__r.Id);
        }
        opportunityIdsList = new List<Id>(opportunityIds);
        for(
            Project_Product_Mapping__mdt  thisRec : [ SELECT Id, Product_Line__c , Project_Product__c
                                                     FROM Project_Product_Mapping__mdt  ]
        ){
            productLineToProjectProductMap.put(thisRec.Product_Line__c,thisRec.Project_Product__c);
        }
        System.debug('productLineToProjectProductMap :: '+productLineToProjectProductMap);
        System.debug('opportunityIds.Size(): '+opportunityIds.Size());
        
        SOQLQuery = 'select contentdocument.id, contentdocument.title, contentdocument.filetype, contentdocument.CreatedDate, LinkedEntityId from contentdocumentlink where linkedentityid IN (\'' + String.join(opportunityIdsList, '\', \'') + '\')'+ 'order by contentdocument.CreatedDate Desc'; 
       /**
        if(opportunityIdsList.Size() > 1){
            SOQLQuery = 'select contentdocument.id, contentdocument.title, contentdocument.filetype, contentdocument.CreatedDate, LinkedEntityId from contentdocumentlink where linkedentityid IN: (\'' + String.join(opportunityIdsList, '\', \'') + '\')'+ 'order by contentdocument.CreatedDate Desc'; 
        }
        else if(opportunityIdsList.Size() == 1){
            Id rec = opportunityIdsList[0];
            SOQLQuery =  'select contentdocument.id, contentdocument.title, contentdocument.filetype, contentdocument.CreatedDate, LinkedEntityId from contentdocumentlink where linkedentityid =:rec order by contentdocument.CreatedDate Desc' ;
        }
        **/
        System.debug('SOQLQuery: '+SOQLQuery);
        if(String.isNotBlank(SOQLQuery)){
            cdlList = Database.Query(SOQLQuery);
        }
        for(ContentDocumentLink cdl : cdlList)
        {
            /** Start */
            if( opportunityToContentDocumentLinkMap.containsKey(cdl.linkedentityid) ){
                if(cdl.contentdocument.CreatedDate > opportunityToContentDocumentLinkMap.get(cdl.linkedentityid).contentdocument.CreatedDate){
                    opportunityToContentDocumentLinkMap.put(cdl.linkedentityid, cdl);
                }
            } else{
                opportunityToContentDocumentLinkMap.put(cdl.linkedentityid, cdl);
            }
            /** End */
        }
        System.debug('opportunityToContentDocumentLinkMap :: '+opportunityToContentDocumentLinkMap);
        
        for(ContentDocumentLink thisCdl : opportunityToContentDocumentLinkMap.values()){
            contentDocumentIds.add(thisCdl.contentdocument.id);
        }
        System.debug('contentDocumentIds :: '+contentDocumentIds);
        
        for (ContentVersion cv : [SELECT Id,contentdocumentid FROM contentversion where contentdocumentid IN :contentDocumentIds])
        {
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'Test';
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            contentDistributionListToInsert.add(cd);
            contentVersionIds.add(cv.id);
            contentDocumentToContentcontentVersionMap.put(cv.contentdocumentid,cv);
        }
        System.debug('contentDistributionListToInsert :: '+contentDistributionListToInsert);
        
        if(contentDistributionListToInsert.size()>0){
            //Insert contentDistributionListToInsert;
        }
        
        for(ContentDistribution thisCd : [SELECT Id, ContentVersionId, DistributionPublicUrl FROM ContentDistribution 
                                          WHERE ContentVersionId IN :contentVersionIds])
        {
            contentVersionToContentDistributionMap.put(thisCd.ContentVersionId,thisCd);
        }
        system.debug('contentVersionToContentDistributionMap :: '+contentVersionToContentDistributionMap);
        
        for(Id thisAssetId : newAssetMap.keySet()){
            Asset thisAsset = newAssetMap.get(thisAssetId);
            Project__c newProject = new Project__c();
            newProject.Integration_Asset__c = thisAssetId;
            if(thisAsset.Opportunity__r.ClearTax_Billing_Entity__c == 'Xpedize'
               || thisAsset.Product2.Product_Line__c == 'Invoice Discounting'){
                   newproject.RecordTypeId = ProjectConstants.PROJECT_ID_RECORDTYPEID;
               }else{
                   newproject.RecordTypeId = ProjectConstants.PROJECT_DEFAULT_RECORDTYPEID;
               }
            newProject.Account_Owner_CSM__c = thisAsset.Account.Onboarding_Owner__r.Name;
            newProject.Client_ERP__c = thisAsset.ERP__c;
            newProject.Asset_ID__c = thisAsset.ID;
            newProject.OTP__c = thisAsset.Price;
            String SKUxERP = thisAsset.Product2.Name + ' x ' + thisAsset.ERP__c;
            newProject.SKU_x_ERP__c = SKUxERP;
            newProject.Master_admin_email__c = thisAsset.Opportunity__r.Master_Admin_Email__c;

            /*if(contentVersionToContentDistributionMap != NULL && 
             opportunityToContentDocumentLinkMap.ContainsKey(thisAsset.Opportunity__c) &&
               contentDocumentToContentcontentVersionMap.ContainsKey(opportunityToContentDocumentLinkMap.get(thisAsset.Opportunity__c).contentdocument?.Id) &&
               contentVersionToContentDistributionMap.ContainsKey(
                    contentDocumentToContentcontentVersionMap.get(
                        opportunityToContentDocumentLinkMap.get(
                            thisAsset.Opportunity__c).contentdocument?.Id)?.Id)
              
              ){
                newProject.Order_form_link__c = contentVersionToContentDistributionMap.get(
                    contentDocumentToContentcontentVersionMap.get(
                        opportunityToContentDocumentLinkMap.get(
                            thisAsset.Opportunity__c).contentdocument?.Id)?.Id)?.DistributionPublicUrl;
            }*/
            if(thisAsset.Account.Country_of_Origin__c != 'India' && thisAsset.Account.Country_of_Origin__c != NULL ){
                newProject.Product__c = productLineToProjectProductMap.get('International Account');
            }else{
                if(productLineToProjectProductMap.keyset().contains(thisAsset.Product2.Product_Line__c)){
                    newProject.Product__c = productLineToProjectProductMap.get(thisAsset.Product2.Product_Line__c);
                }else{
                    newProject.Product__c = productLineToProjectProductMap.get('default');
                }
            }

            /**	Additional Fields based On ShriRam's Feedback	**/
            newProject.Account__c = thisAsset.AccountId;
            newProject.Type_of_Integration__c = thisAsset.Type_of_Integration__c;
            

            newProject.Project_Name__c = thisAsset.Account.Name +' - '+ newProject.Product__c +' - '+ newProject.Scope_Category__c+ ' - ' + thisAsset.ERP__c;
            newProject.Project_Stage__c = 'Awaiting Kick-off';
            newProject.Status__c = 'Active';
            
            /**	Get Scope+Mode+In-House Details	**/
            CTX_ProjectAutomationHelper.getScopeModeInHouseDetails(newProject);
            CTX_ProjectAutomationHelper.getEstimatedDateForProject(
                newProject, 
                Date.newinstance(thisAsset.CreatedDate.year(), thisAsset.CreatedDate.month(), thisAsset.CreatedDate.day())
            );
            /*	CTX_ProjectAutomationHelper.getScopeModeInHouseDetails(newProject);
            
            newProject.LOE_Received_Date__c =;
            newProject.Estimated_Implementation_End_Date__c =;
            newProject.Estimated_UAT_End_Date__c =;
            newProject.Estimated_Go_Live_Date__c =;
            */
          
            projectsToCreateList.add(newProject);
        }
        System.debug('projectsToCreateList :: '+projectsToCreateList);
        if(projectsToCreateList.size()>0){
            try{
                Insert projectsToCreateList;
                isSuccess = TRUE;
                System.debug('projectsToCreateList Inserted :: '+projectsToCreateList);
            }catch(exception e){
                system.debug('Error in projectAutoCreation :: '+e.getMessage()+' Line : '+e.getLineNumber());
            }
            
        }
        if(isSuccess){
            for(Project__c thisProject : [SELECT Id, Asset_ID__c FROM Project__c WHERE Asset_ID__c IN :ListOfNewAssetIDs])
            {
                AccountProjectAssetJunction__c newApaJunctionToCreate = new AccountProjectAssetJunction__c();
                newApaJunctionToCreate.Project__c = thisProject.Id;
                newApaJunctionToCreate.Asset__c = thisProject.Asset_ID__c;
                newApaJunctionToCreate.Customer_Account__c = newAssetMap.get(thisProject.Asset_ID__c).AccountId;
                apaJunctionListToCreate.add(newApaJunctionToCreate);
            }
            System.debug('apaJunctionListToCreate :: '+apaJunctionListToCreate);
            if(apaJunctionListToCreate.size()>0){
                INSERT apaJunctionListToCreate;
                System.debug('apaJunctionListToCreate Inserted :: '+apaJunctionListToCreate);
            }
        }
        
    }
    /** END :: bhaveshjindal :: auto create Project for Integration Assets **/
    
    
    /** START :: bhaveshjindal :: auto create AMC Module for Integration Assets **/
    Public Static void autoCreateAmcProject(Set<Id> ListOfNewAssetIDs){
        
        system.debug('<<--------:: AMCprojectAutoCreation entered ::-------->> ');
        
        List<Project__c> 			projectsToCreateList 						= new List<Project__c>();
        Boolean						isSuccess									= FALSE;
        List<AccountProjectAssetJunction__c> apaJunctionListToCreate			= new List<AccountProjectAssetJunction__c>();
        Map<String,String>			productLineToProjectProductMap				= new Map<String,String>();
        
        Map<Id, Asset> 				newAssetMap 							= new Map<Id, Asset>(
            [ SELECT Id, AccountId, Opportunity__c, Product2Id, Asset_Type__c, Account.RecordType.DeveloperName,
             
             Type_of_Integration__c, Type_of_Integration_Project__c, ERP__c, Opportunity__r.RecordType.DeveloperName,
             
             Account.Name, Account.Country_of_Origin__c, Type_of_Integration_QLI__c, Account.Onboarding_Owner__c, Account.Onboarding_Owner__r.Name,
             
             Opportunity__r.AccountId, Opportunity__r.Account.Name, Opportunity__r.Master_Admin_Email__c,
             
             Product2.Name, Product2.OrderForm_Product_Name__c, Price, Product2.Product_Line__c, PurchaseDate, UsageEndDate 
             
             FROM Asset WHERE Id IN :ListOfNewAssetIDs ]
        );
        
        for(
            Project_Product_Mapping__mdt  thisRec : [ SELECT Id, Product_Line__c , Project_Product__c
                                                     FROM Project_Product_Mapping__mdt  ]
        ){
            productLineToProjectProductMap.put(thisRec.Product_Line__c,thisRec.Project_Product__c);
        }
        System.debug('productLineToProjectProductMap :: '+productLineToProjectProductMap);
        
        for(Id thisAssetId : newAssetMap.keySet()){
            Asset thisAsset = newAssetMap.get(thisAssetId);
            Project__c newProject = new Project__c();
            newproject.RecordTypeId = ProjectConstants.PROJECT_AMC_MODULE_RECORDTYPEID;
            newProject.Asset_ID__c = thisAsset.ID;
            newProject.Integration_Asset__c = thisAsset.ID;
            newProject.Master_admin_email__c = thisAsset.Opportunity__r.Master_Admin_Email__c;
            newProject.AMC_Start_Date__c = thisAsset.PurchaseDate;
            newProject.AMC_End_Date__c = thisAsset.UsageEndDate;
            newProject.Project_Stage__c = 'Awaiting Kick-off';
            newProject.Status__c = 'Active';
            newProject.Scope_Category__c = 'AMC';
            newProject.ARR__c = thisAsset.price;
            if( thisAsset.Account.Country_of_Origin__c != 'India' &&  thisAsset.Account.Country_of_Origin__c != NULL ){
                newProject.Product__c = productLineToProjectProductMap.get('International Account');
            }else{
                if(productLineToProjectProductMap.keyset().contains(thisAsset.Product2.Product_Line__c)){
                    newProject.Product__c = productLineToProjectProductMap.get(thisAsset.Product2.Product_Line__c);
                }else{
                    newProject.Product__c = productLineToProjectProductMap.get('default');
                }
            }
            newProject.Project_Name__c = thisAsset.Account.Name +' - '+ newProject.Product__c +' - '+'AMC - '+ thisAsset.ERP__c;
            
            //add to list
            projectsToCreateList.add(newProject);
        }
        System.debug('AMCprojectsToCreateList :: '+projectsToCreateList);
        if(projectsToCreateList.size()>0){
            try{
                Insert projectsToCreateList;
                isSuccess = TRUE;
                System.debug('AMCprojectsToCreateList Inserted :: '+projectsToCreateList);
            }catch(exception e){
                system.debug('Error in AMCprojectAutoCreation :: '+e.getMessage()+' Line : '+e.getLineNumber());
            }
            
        }
        if(isSuccess){
            for(Project__c thisProject : [SELECT Id, Asset_ID__c FROM Project__c WHERE Asset_ID__c IN :ListOfNewAssetIDs])
            {
                AccountProjectAssetJunction__c newApaJunctionToCreate = new AccountProjectAssetJunction__c();
                newApaJunctionToCreate.Project__c = thisProject.Id;
                newApaJunctionToCreate.Asset__c = thisProject.Asset_ID__c;
                newApaJunctionToCreate.Customer_Account__c = newAssetMap.get(thisProject.Asset_ID__c).AccountId;
                apaJunctionListToCreate.add(newApaJunctionToCreate);
            }
            System.debug(' AMC apaJunctionListToCreate :: '+apaJunctionListToCreate);
            if(apaJunctionListToCreate.size()>0){
                INSERT apaJunctionListToCreate;
                System.debug(' AMC apaJunctionListToCreate Inserted :: '+apaJunctionListToCreate);
            }
        }
        
    }
    /** END :: bhaveshjindal :: auto create AMC Module for Integration Assets **/
    
    /** START :: bhaveshjindal :: auto create DSC Project for Digital Signature Assets **/
    Public Static void autoCreateDSCProject(Set<Id> ListOfNewAssetIDs){
        
        system.debug('<<--------:: projectAutoCreation entered ::-------->> ');
        
        List<Project__c> 			projectsToCreateList 						= new List<Project__c>();
        Set<Id>						opportunityIds								= new Set<Id>();
        List<Id>					opportunityIdsList;
        Set<Id>						contentDocumentIds							= new Set<Id>();
        Set<Id>						contentVersionIds							= new Set<Id>();
        List<ContentDistribution>	contentDistributionListToInsert 			= new List<ContentDistribution>();
        Map<Id,ContentDocumentLink> opportunityToContentDocumentLinkMap 		= new Map<Id,ContentDocumentLink>();
        Map<Id,ContentVersion> 		contentDocumentToContentcontentVersionMap 	= new Map<Id,ContentVersion>();
        Map<Id,ContentDistribution> contentVersionToContentDistributionMap 		= new Map<Id,ContentDistribution>();
        Boolean						isSuccess									= FALSE;
        String SOQLQuery;
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<AccountProjectAssetJunction__c> apaJunctionListToCreate			= new List<AccountProjectAssetJunction__c>();
        
        
        Map<Id, Asset> 				newAssetMap 							= new Map<Id, Asset>(
            [ SELECT Id, AccountId, Opportunity__c, Product2Id, Asset_Type__c, Account.RecordType.DeveloperName,
             
             Type_of_Integration__c, Type_of_Integration_Project__c, ERP__c, Opportunity__r.RecordType.DeveloperName,
             
             Account.Name, Type_of_Integration_QLI__c, Account.Onboarding_Owner__c, Account.Onboarding_Owner__r.Name,
             
             Opportunity__r.AccountId, Opportunity__r.Account.Name, Opportunity__r.Master_Admin_Email__c,
             
             Product2.Name, Product2.OrderForm_Product_Name__c, Price, Product2.Product_Line__c,Opportunity__r.Id
             
             FROM Asset WHERE Id IN :ListOfNewAssetIDs ]
        );
        
        for(Id thisAssetId : newAssetMap.keySet()){
            Asset thisAsset = newAssetMap.get(thisAssetId);
            opportunityIds.add(thisAsset.Opportunity__r.Id);
        }
        opportunityIdsList = new List<Id>(opportunityIds);
        
        System.debug('opportunityIds.Size(): '+opportunityIds.Size());
        
        SOQLQuery = 'select contentdocument.id, contentdocument.title, contentdocument.filetype, contentdocument.CreatedDate, LinkedEntityId from contentdocumentlink where linkedentityid IN (\'' + String.join(opportunityIdsList, '\', \'') + '\')'+ 'order by contentdocument.CreatedDate Desc'; 
       /**
        if(opportunityIdsList.Size() > 1){
            SOQLQuery = 'select contentdocument.id, contentdocument.title, contentdocument.filetype, contentdocument.CreatedDate, LinkedEntityId from contentdocumentlink where linkedentityid IN: (\'' + String.join(opportunityIdsList, '\', \'') + '\')'+ 'order by contentdocument.CreatedDate Desc'; 
        }
        else if(opportunityIdsList.Size() == 1){
            Id rec = opportunityIdsList[0];
            SOQLQuery =  'select contentdocument.id, contentdocument.title, contentdocument.filetype, contentdocument.CreatedDate, LinkedEntityId from contentdocumentlink where linkedentityid =:rec order by contentdocument.CreatedDate Desc' ;
        }
        **/
        
        System.debug('SOQLQuery: '+SOQLQuery);
        if(String.isNotBlank(SOQLQuery)){
            cdlList = Database.Query(SOQLQuery);
        }
        for(ContentDocumentLink cdl : cdlList)
        {
            /** Start */
            if( opportunityToContentDocumentLinkMap.containsKey(cdl.linkedentityid) ){
                if(cdl.contentdocument.CreatedDate > opportunityToContentDocumentLinkMap.get(cdl.linkedentityid).contentdocument.CreatedDate){
                    opportunityToContentDocumentLinkMap.put(cdl.linkedentityid, cdl);
                }
            } else{
                opportunityToContentDocumentLinkMap.put(cdl.linkedentityid, cdl);
            }
            /** End */
        }
        System.debug('opportunityToContentDocumentLinkMap :: '+opportunityToContentDocumentLinkMap);
        
        for(ContentDocumentLink thisCdl : opportunityToContentDocumentLinkMap.values()){
            contentDocumentIds.add(thisCdl.contentdocument.id);
        }
        System.debug('contentDocumentIds :: '+contentDocumentIds);
        
        for (ContentVersion cv : [SELECT Id,contentdocumentid FROM contentversion where contentdocumentid IN :contentDocumentIds])
        {
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'Test';
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            contentDistributionListToInsert.add(cd);
            contentVersionIds.add(cv.id);
            contentDocumentToContentcontentVersionMap.put(cv.contentdocumentid,cv);
        }
        System.debug('contentDistributionListToInsert :: '+contentDistributionListToInsert);
        
        if(contentDistributionListToInsert.size()>0){
            //Insert contentDistributionListToInsert;
        }
        
        for(ContentDistribution thisCd : [SELECT Id, ContentVersionId, DistributionPublicUrl FROM ContentDistribution 
                                          WHERE ContentVersionId IN :contentVersionIds])
        {
            contentVersionToContentDistributionMap.put(thisCd.ContentVersionId,thisCd);
        }
        system.debug('contentVersionToContentDistributionMap :: '+contentVersionToContentDistributionMap);
        
        for(Id thisAssetId : newAssetMap.keySet()){
            Asset thisAsset = newAssetMap.get(thisAssetId);
            Project__c newProject = new Project__c();
            newproject.RecordTypeId = ProjectConstants.PROJECT_DEFAULT_RECORDTYPEID;
            newProject.Account_Owner_CSM__c = thisAsset.Account.Onboarding_Owner__r.Name;
            newProject.Client_ERP__c = thisAsset.ERP__c;
            newProject.Asset_ID__c = thisAsset.ID;
            newproject.Integration_Asset__c = thisAsset.ID;
            newProject.OTP__c = thisAsset.Price;
            String SKUxERP = thisAsset.Product2.Name + ' x ' + thisAsset.ERP__c;
            newProject.SKU_x_ERP__c = SKUxERP;
            newProject.Master_admin_email__c = thisAsset.Opportunity__r.Master_Admin_Email__c;
            /*if(contentVersionToContentDistributionMap != NULL){
                newProject.Order_form_link__c = contentVersionToContentDistributionMap.get(
                    contentDocumentToContentcontentVersionMap.get(
                        opportunityToContentDocumentLinkMap.get(
                            thisAsset.Opportunity__c).contentdocument.Id).Id).DistributionPublicUrl;
            }*/
            newProject.Product__c = 'DSC';
            newProject.Project_Name__c = thisAsset.Account.Name +' - '+ newProject.Product__c +' - '+'SCG - '+ thisAsset.ERP__c;
            newProject.Project_Stage__c = 'Awaiting Kick-off';
            newProject.Status__c = 'Active';
            
            //add to list
            projectsToCreateList.add(newProject);
        }
        System.debug('DSCprojectsToCreateList :: '+projectsToCreateList);
        if(projectsToCreateList.size()>0){
            try{
                Insert projectsToCreateList;
                isSuccess = TRUE;
                System.debug('DSCprojectsToCreateList Inserted :: '+projectsToCreateList);
            }catch(exception e){
                system.debug('Error in DSCprojectAutoCreation :: '+e.getMessage()+' Line : '+e.getLineNumber());
            }
            
        }
        if(isSuccess){
            for(Project__c thisProject : [SELECT Id, Asset_ID__c FROM Project__c WHERE Asset_ID__c IN :ListOfNewAssetIDs])
            {
                AccountProjectAssetJunction__c newApaJunctionToCreate = new AccountProjectAssetJunction__c();
                newApaJunctionToCreate.Project__c = thisProject.Id;
                newApaJunctionToCreate.Asset__c = thisProject.Asset_ID__c;
                newApaJunctionToCreate.Customer_Account__c = newAssetMap.get(thisProject.Asset_ID__c).AccountId;
                apaJunctionListToCreate.add(newApaJunctionToCreate);
            }
            System.debug('apaJunctionListToCreate :: '+apaJunctionListToCreate);
            if(apaJunctionListToCreate.size()>0){
                INSERT apaJunctionListToCreate;
                System.debug('apaJunctionListToCreate Inserted :: '+apaJunctionListToCreate);
            }
        }
        
    }
    
   // @future
    public static void createBillingAndRisk(Set<Id> assetId, Map<Id, Id> assetIdLineItemIdMap){
        Map<Id,Asset> assetMap = new Map<Id,Asset>([SELECT Id, AccountId, Price 
                                                    FROM Asset WHERE Id IN :assetId]);
        Map<Id, QuoteLineItem> 	assetIdQuoteLineItemMap = new Map<Id, QuoteLineItem>();
        for( QuoteLineItem thisRec : [ SELECT 
                                      Id, BtoB_Sales_one__c, BtoC_Sales_one__c, Flat_Transaction_Fee__c, 
                                      Number_of_Deductees_per_Quarter_24Q_26__c, Number_of_Deduction_Transactions_per_Qua__c, 
                                      No_of_EWBs__c, No_of_expected_B2C_invoices_for_QR_code__c, 
                                      No_of_GST_GSP_API_calls_permissible__c, No_of_GSTIN_one__c, 
                                      No_of_GSTIN_verification_credits__c, No_of_invoice_formats__c, No_of_IRNs__c,
                                      No_of_PAN_one__c, No_of_recons__c, No_of_TANs__c, No_of_Total_invoices__c,
                                      No_of_User_ID_one__c, No_of_Vendors_one__c, No_of_airline_invoices_annual_one__c,
                                      Number_of_eway_bill__c, Partner_Count_for_GeEr_up_Reports__c,
                                      Purchases_Invoices_one__c, Tally_Connector_required__c,
                                      Transaction_Fee_Slab_1__c, Type_of_Compliance_service__c, 
                                      Platform__c, No_MM2A_2B_usage_GSTIN_month__c, 
                                      Type_of_Integration__c, No_of_API_calls_permissible__c,
                                      No_of_Bank_verification_API__c, Digital_Signing_Utility_for_TDS_Cert_del__c,
                                      No_of_MCA_Company_details_API__c, No_of_MSME_API__c, 
                                      No_of_PAN_verification_API__c, No_of_TDS_206_sync_API__c, 
                                      Total_B2B_PR_B2C_invoice__c, POS_system__c, No_of_retail_stores__c,
                                      No_of_PAN_to_GSTIN_APIs__c, No_of_PAN_verification_detailed_APIs__c, CDC_Applicable__c, 
                                      
                                      Product2.Name,
                                      
                                      Quote.Monthly_throughput_Slab_1_Cr__c, Quote.Monthly_throughput_Slab_2_Cr__c, Quote.Monthly_throughput_Slab_3_Cr__c, 
                                      Quote.Transaction_Fee_Slab_2__c, Quote.Transaction_Fee_Slab_3__c, 
                                      Quote.Total_annual_domestic_payables_Rs_Cr__c, Quote.No_of_VAT__c, Quote.No_of_User_ID_one__c, 
                                      Quote.POS_system__c, Quote.ERP_GCC__c, Quote.No_of_Online_devices__c, Quote.No_of_Offline_devices__c,
                                      Quote.BtoB_Sales_one__c, Quote.BtoC_Sales_one__c,Quote.Account.Country_of_Origin__c,
                                      
                                      ( SELECT 
                                       Id, Name, ProductCode, Quantity,PricebookEntry.Product2Id, 
                                       PricebookEntry.Product2.Name, PricebookEntryId, UnitPrice,Product2.Family, 
                                       Product2.Product_category__c,Sale_Price__c, Description, OpportunityId, 
                                       Opportunity.AccountId, Opportunity.Account.Name, Opportunity.Account.OwnerId, Opportunity.SyncedQuoteId, 
                                       Opportunity.CloseDate, Opportunity.Period_Start_date__c,CurrencyIsoCode,
                                       Opportunity.Period_End_date__c, PO_End_Month__c, Period_End_date__c, 
                                       Period_Start_date__c, Opportunity.Payment_method__c, 
                                       Opportunity.Payment_term__c, Opportunity.RecordTypeId, MarkUp__c, Discount, 
                                       Opportunity.LeadSource, Opportunity.One_to_Many_Type__c, 
                                       Opportunity.Anchor_Companys__c, Product2.Product_Line__c, 
                                       Type_Of_Integration__c, Stage_in_MY__c, SOW_Start_Date__c, SOW_End_Date__c, 
                                       Total_Price__c, Opportunity.platform__c FROM Opportunity_Product__r )
                                      FROM QuoteLineItem WHERE 
                                      Id IN :assetIdLineItemIdMap.keySet() ]
           ){
               if( thisRec.Quote.Account.Country_of_Origin__c == 'India' || 
                  thisRec.Quote.Account.Country_of_Origin__c == 'NULL' ||
                  thisRec.Quote.Account.Country_of_Origin__c == 'N/A' ) {
                      assetIdQuoteLineItemMap.put( assetIdLineItemIdMap.get(thisRec.Id), thisRec );
                  }
           }
        List<Billing_Details__c> billingRecordsList = new List<Billing_Details__c>();
        
        for( Id thisKey : assetIdQuoteLineItemMap.keySet() ){
            
            Billing_Details__c 		billingAndRiskRecord 	= new Billing_Details__c();
            QuoteLineItem 			lineItem 				= assetIdQuoteLineItemMap.get(thisKey);
            OpportunityLineItem		oppLineItem				= lineItem.Opportunity_Product__r[0];
            
            billingAndRiskRecord.Asset__c 					= thisKey;
            billingAndRiskRecord.Account__c 				= assetMap.get(thisKey).AccountId;
            String billingRiskName = oppLineItem.Opportunity.Account.Name + ' : ' + lineItem.Product2.Name;
            billingAndRiskRecord.Name						= billingRiskName.length()<79 ? billingRiskName : billingRiskName.substring(0,79);
            billingAndRiskRecord.Price__c 					= assetMap.get(thisKey).Price;
            
            billingRecordsList.add(billingAndRiskRecord);
        }
        
        
        system.debug('billingRecordsList: '+billingRecordsList.size());
        insert billingRecordsList;
    }
    

}