public without sharing class CreateProjectController {
    
    @AuraEnabled
    public static Order getSEUserFROMAccountCustomerLevel(Id orderId){
        Order orderInstance=new Order();
        
        String query=UtilityClass.getQueryString('Order')+',Account.Name,Account.SE_User__r.Name,Account.SE_User__c FROM Order WHERE Id=: orderId ';
        orderInstance=DataBase.query(query);
        if(orderInstance!=null){
            return orderInstance;
        }else{
            return null;
        }
    }
    
     @AuraEnabled
    public static void updateSEUserFROMAccountCustomerLevel(Id orderId,Id userId){
        Order orderInstance=new Order();
        
        String query=UtilityClass.getQueryString('Order')+',Account.Name,Account.SE_User__r.Name,Account.SE_User__c FROM Order WHERE Id=: orderId ';
        orderInstance=DataBase.query(query);
        if(orderInstance!=null){
			Account accountInstance=new Account();
            accountInstance.id=orderInstance.AccountId;
            if(userId!=null){
                accountInstance.SE_User__c=userId;
            }
            update accountInstance;
        }
    }
    
    @auraEnabled
    public static List<Account> getSIPartner(Id orderId,String optionRecordTypeName){
        List<Account> listOfSIPartnerAccounts=new List<Account>();
        String StatusActive = 'Active';
        String onboardingStatusOnboarded='Onboarded';
        
        String query=UtilityClass.getQueryString('Account')+',City__r.Name,Region__r.Name FROM ACCOUNT WHERE RecordType.Name=: optionRecordTypeName AND (Onboarding_Status__c=:onboardingStatusOnboarded ) limit '+(Limits.getLimitQueryRows() - Limits.getQueryRows());
        listOfSIPartnerAccounts=DataBase.query(query);
        if(listOfSIPartnerAccounts.size()>0){
            return listOfSIPartnerAccounts;
        }else{
            return null;
        }
        
    }
    
    
    
    @AuraEnabled
    public static Map<String,String> getExperties(){
        Map<String,String> options = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Account.ERP__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        System.debug('options'+options);
        return options;
    }
    
    
    @auraEnabled
    public static List<Account> getSIPartnerBasedonFilter(String experties, Integer noOfActiveProjects, String city, String region){
        
        String querycity='%'+city+'%';
        String queryregion='%'+region+'%';
        String recordTypeName='SI Partner';
        List<Account> listOfSIPartnerAccounts=new List<Account>();
        String query='';
        
        System.debug('noOfActiveProjects'+noOfActiveProjects);
        
        System.debug('experties'+experties);
        
        System.debug('querycity'+querycity);
        
        System.debug('queryregion'+queryregion);
        
        System.debug('recordTypeName'+recordTypeName);
        
        List<String> listOfOrConditions=new List<String>();

        if(String.isNotBlank(experties) && String.isNotEmpty(experties)){
            listOfOrConditions.add(' ERP__c Includes(:experties) ');
        }
        if(noOfActiveProjects!=null && String.isNotBlank(String.valueOf(noOfActiveProjects)))
            listOfOrConditions.add('  No_of_active_projects__c =: noOfActiveProjects ');
        if(String.isNotBlank(city) && String.isNotEmpty(city))
            listOfOrConditions.add('  City__r.Name Like: querycity ');
        if(String.isNotBlank(region) && String.isNotEmpty(region))
            listOfOrConditions.add('  Region__r.Name Like: queryregion ');
        String onboardingStatusOnboarded = 'Onboarded';
        if(listOfOrConditions.size()>0){
            query=UtilityClass.getQueryString('Account')+',City__r.Name,Region__r.Name FROM ACCOUNT WHERE (RecordType.Name=:recordTypeName AND  Onboarding_Status__c=:onboardingStatusOnboarded  AND ('+String.join(listOfOrConditions, ' OR ');
            query+=')) limit 50';
        }else{
            listOfSIPartnerAccounts = getSIPartner(null,recordTypeName);
        }
        System.debug('query****'+query);
        
        if(query!=null && query!=''){
            listOfSIPartnerAccounts.addAll((List<Account>)DataBase.query(query));
        }
        
        if(listOfSIPartnerAccounts.size()>0){
            return listOfSIPartnerAccounts;
        }else{
            return null;
        }
        
    }
    
    
    /* wrapper class */  
    public class AssetListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Asset objAsset{get;set;}
        public AssetListWrapper(boolean isChecked, Asset objAsset){
            this.isChecked = isChecked;
            this.objAsset = objAsset;
        }
    }
    
     @auraEnabled
    public static List<Asset> getOrderAndAssetsBySIPartnerAccountId(Id siPartnerAccountrecordId,Id orderId){
        List<Asset> listOfRelatedAssets=new List<Asset>();
        List<String> recordTypeName=new List<String>{'Integration Asset','Integration Asset - ID'};
        String querySIPartnerRelatedIntgAssets=UtilityClass.getQueryString('Asset')+',Order_Line__r.OrderId, Order_Line__r.Order.Status,Order_Line__r.Order.OrderNumber,Order_Line__r.Order.ActivatedDate,Order_Line__r.Product2.Product_category__c ';
        querySIPartnerRelatedIntgAssets+=' FROM ASSET WHERE (RecordType.Name IN: recordTypeName   AND Order_Line__r.OrderId =: orderId ) ';
        
        listOfRelatedAssets = DataBase.query(querySIPartnerRelatedIntgAssets);
        
        /*AssetListWrapper assetListWrapperInstance=new AssetListWrapper(true,new Asset());
		return new List<AssetListWrapper>{assetListWrapperInstance};*/
        if(listOfRelatedAssets.size()>0){
            return listOfRelatedAssets;
        }else{
            return null;
        }
    }
    
    @auraEnabled
    public static List<Asset> getOrderAndAssets(Id orderId){
        List<Asset> listOfRelatedAssets=new List<Asset>();
        List<String> recordTypeName=new List<String>{'Integration Asset','Integration Asset - ID'};
            List<String> productCategory=new List<String>{'Integration', 'AMC'};
        String querySIPartnerRelatedIntgAssets=UtilityClass.getQueryString('Asset')+',Order_Line__r.OrderId, Order_Line__r.Order.Status,Order_Line__r.Order.OrderNumber,Order_Line__r.Order.ActivatedDate,Order_Line__r.Order.EffectiveDate,Order_Line__r.Product2.Product_category__c   ';
        querySIPartnerRelatedIntgAssets+=' FROM ASSET WHERE RecordType.Name IN: recordTypeName AND Order_Line__r.OrderId =: orderId AND Order_Line__r.Product2.Product_category__c IN: productCategory ';
        
        listOfRelatedAssets = DataBase.query(querySIPartnerRelatedIntgAssets);
        
        /*AssetListWrapper assetListWrapperInstance=new AssetListWrapper(true,new Asset());
		return new List<AssetListWrapper>{assetListWrapperInstance};*/
        if(listOfRelatedAssets.size()>0){
            return listOfRelatedAssets;
        }else{
            return null;
        }
    }
    
    
    @auraEnabled
    public static List<Project__c> insertOrUpdateProject(List<Asset> listOfAssets,Id projectId,String nameOfProject,String selectedSEUserId,String siPartnerAccountrecordId,String jsonAfterProjectInsertfromUI,String orderId, String typeOfProject){
        List<Project__c> listOfNewProjects=new List<Project__c>(); 
        List<Project__c> listOfProjectsToUpdate=new List<Project__c>(); 
        
       // List<Account> listOfAccounts=[Select id,Name from Account WHERE id=:siPartnerAccountrecordId];
		List<Order> listOfOrders=[SELECT id,Account.Name FROM Order WHERE id=:orderId];
        CreateProjectController.ProjectWrapper newProjectWrapper=new CreateProjectController.ProjectWrapper();
        System.debug(jsonAfterProjectInsertfromUI);
        System.debug(newProjectWrapper);
        // projectInstance.id=projectId;
        newProjectWrapper=(CreateProjectController.ProjectWrapper)JSON.deserialize(jsonAfterProjectInsertfromUI, CreateProjectController.ProjectWrapper.class);
        String ProjectIdInstance=newProjectWrapper.Id;
        Project__c projectInstanceToUpdate=DataBase.query(UtilityClass.getQueryString('Project__c')+' FROM Project__c WHERE Id=:ProjectIdInstance');
        
        //(Account Name - Product - Scope Category chosen - Client ERP)
        if(listOfAssets.size()>0 && projectId==null && jsonAfterProjectInsertfromUI==null){
            //for(Asset assetInstance:listOfAssets){
            
            Project__c projectInstance=new Project__c();
            
            //mark in house
            system.debug('typeOfProject :: '+typeOfProject);
            if(typeOfProject == 'Development in House'){
                projectInstance.In_house_project__c = TRUE;
            }

            //Change to Junction Object
            //projectInstance.Asset__c=assetInstance.Id;
            //projectInstance.Order__c=assetInstance.Order_Line__r.OrderId;
            //projectInstance.Customer_Account__c=assetInstance.AccountId;
            if(nameOfProject==null){
                 //projectInstance.Name=listOfAccounts[0].Name+projectInstanceToUpdate; // changed to Auto Number to Maintain the Uniqueness
            }/*else{
                // projectInstance.Name='System Auto Created Project ';
            }*/
            if(selectedSEUserId instanceOf Id){
                projectInstance.ctx_SE__c =selectedSEUserId;
                projectInstance.OwnerId =selectedSEUserId;
            }
            
            listOfNewProjects.add(projectInstance);
            system.debug('listOfNewProjects :: '+listOfNewProjects);
            
            // }     
        }else if(listOfAssets.size()>0  && jsonAfterProjectInsertfromUI!=null){
            //for(Asset assetInstance:listOfAssets){
            //(Account Name - Product - Scope Category chosen - Client ERP)
            Project__c projectInstance=new Project__c();
            /*CreateProjectController.ProjectWrapper newProjectWrapper=new CreateProjectController.ProjectWrapper();
             System.debug(jsonAfterProjectInsertfromUI);
            System.debug(newProjectWrapper);
            // projectInstance.id=projectId;
            newProjectWrapper=(CreateProjectController.ProjectWrapper)JSON.deserialize(jsonAfterProjectInsertfromUI, CreateProjectController.ProjectWrapper.class);*/
            //Change to Junction Object
            //if(projectInstance.Name==newProjectWrapper.Id ){
            String projectName=listOfOrders[0].Account.Name+' - '+projectInstanceToUpdate?.Product__c+' - '+projectInstanceToUpdate?.Scope_Category__c+' - '+projectInstanceToUpdate?.Client_ERP__c;
            System.debug('Project Name ==>'+projectName);
            System.debug('Project length ==>'+projectName.length());
            if(projectName.length()<=200){
                projectInstance.Project_Name__c=projectName;
            }
            //}
            //mark in house
            system.debug('typeOfProject :: '+typeOfProject);
            if(typeOfProject == 'Development in House'){
                projectInstance.In_house_project__c = TRUE;
            }
            
            if(typeOfProject == 'AMC'){
                projectInstance.RecordTypeId = ProjectConstants.PROJECT_AMC_MODULE_RECORDTYPEID;
            }
            if(projectInstance.ctx_SE__c==null){
                projectInstance.ctx_SE__c =selectedSEUserId;
                projectInstance.OwnerId =selectedSEUserId;
            }
            projectInstance.Id=newProjectWrapper.Id;
            //projectInstance.Name='System Auto Created Project';
            listOfProjectsToUpdate.add(projectInstance);
            system.debug('listOfProjectsToUpdate :: '+listOfProjectsToUpdate);
            // }
        }
        
        if(listOfNewProjects.size()>0 || listOfProjectsToUpdate.size()>0){
            if(listOfNewProjects.size()>0 && projectId==null && jsonAfterProjectInsertfromUI==null ){
                insert  listOfNewProjects;
                createJunctionObject(listOfNewProjects,listOfAssets,selectedSEUserId,siPartnerAccountrecordId);
                return listOfNewProjects;
            }else {
                if(listOfProjectsToUpdate.size()>0  && jsonAfterProjectInsertfromUI!=null ){
                    update  listOfProjectsToUpdate;
                    for(Project__c prokectIns:listOfProjectsToUpdate){
                        System.debug(prokectIns.id+' ====> '+prokectIns);
                    }
                    createJunctionObject(listOfProjectsToUpdate,listOfAssets,selectedSEUserId,siPartnerAccountrecordId);
                    return listOfProjectsToUpdate;
                }else{
                    return null;
                }
            }
        }else{
            return null;
        }
    }
    
    static void createJunctionObject(List<Project__c> listOfNewProjects,List<Asset> listOfAssets,String selectedSEUserId,String siPartnerAccountrecordId){
        List<AccountProjectAssetJunction__c> listOfJunctionsToInsert=new List<AccountProjectAssetJunction__c>(); 
        List<Asset> listOfAssetsToupdate=new List<Asset>(); 
        List<OrderItem> listOfOrderItemsToupdate=new List<OrderItem>(); 
        
        if(listOfAssets.size()>0){
            for(Asset assetInstance:listOfAssets){
                
                AccountProjectAssetJunction__c junctionInstance=new AccountProjectAssetJunction__c();
                junctionInstance.Asset__c=assetInstance.Id;
                junctionInstance.OrderItem__c=assetInstance.Order_Line__c;//.OrderId;
               	junctionInstance.Customer_Account__c=assetInstance.AccountId; // this is Account on Order level is consider as Customer Account
                junctionInstance.Project__c=listOfNewProjects.size()>0 ? listOfNewProjects[0].Id : null;
                junctionInstance.SI_Partner_Account__c= siPartnerAccountrecordId; // this is the Account that Selecte in Component
                listOfJunctionsToInsert.add(junctionInstance);
                
                Asset asset=new Asset();
                assetInstance.Id=assetInstance.Id;
                if(selectedSEUserId!=null && selectedSEUserId!=''){
                    //assetInstance.Integration_status__c='SE Owner Assigned';
                }else{
                    //assetInstance.Integration_status__c='SI Assigned';
                }
                listOfAssetsToupdate.add(assetInstance);
                
                OrderItem orderItemInstance=new OrderItem();
                orderItemInstance.Id=assetInstance.Order_Line__c;
                if(selectedSEUserId!=null && selectedSEUserId!=''){
                    //orderItemInstance.Integration_status__c='SE Owner assigned';
                }else{
                    //orderItemInstance.Integration_status__c='SI Assigned';
                }
                listOfOrderItemsToupdate.add(orderItemInstance);
            }     
        }
        
        List<Sobject> listOfSobjectsToUpdate=new List<Sobject>();
        listOfSobjectsToUpdate.addAll(listOfOrderItemsToupdate);
        listOfSobjectsToUpdate.addAll(listOfAssetsToupdate);
        
        if(listOfJunctionsToInsert.size()>0){
            insert listOfJunctionsToInsert;
        }
        
        if(listOfSobjectsToUpdate.size()>0){
            //update listOfSobjectsToUpdate;
        }
    }
    
    
    public class ProjectWrapper{
       // public String apiName;	//Project__c
        public String id;	//a0d1y0000002wfPAAQ
        public String lastModifiedById;	//0052x000002s63sAAA
        public String lastModifiedDate;	//2021-02-19T23:28:15.000Z
        public String recordTypeId;	//012000000000000AAA
        public String systemModstamp;	//2021-02-19T23:28:15.000Z
       // public Project__c fields;
    }


    
}