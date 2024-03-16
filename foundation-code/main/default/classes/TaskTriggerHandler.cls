/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-08-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class TaskTriggerHandler implements TriggerInterface {
    
    /**
* @description handle before Insert event on Trigger
* @author Lokesh Thathuru | 07/12/2020
* @param List<SObject> listOfNewSObjects
* @return void
*/
    public static void beforeInsert(List<SObject> listOfNewSObjects){
        if(caseconstants.taskTrigger){
        string assMod= 'Asset Modification';
        string assDel = 'Asset Deletion';
        string assCreate = 'Asset Creation';
        Set<Id> 	prodId 		    = 	new Set<Id>();
        list<task> taskList = new list<task>();
        set<id> relatedId = new set<id>();
        Map<String, Set<String>>	num_MandatoryFieldMap_NonZero 	= new Map<String, Set<String>>();
        Map<String, Set<String>>	txt_MandatoryFieldMap_NonZero 	= new Map<String, Set<String>>();
        Map<String, Set<String>>	num_MandatoryFieldMap_WithZero 	= new Map<String, Set<String>>();
        String type                            ='Task';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType quoteSchema            = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = quoteSchema.getDescribe().fields.getMap();
        String						errorMessage_Non_Zero			= ' Enter non-zero/non-null values for the following fields: ';
        String						errorMessage_Zero_Allowed		= ' Enter values for the following fields: ';
        
        /**	Get Details from Custom Setting for Module and Mandatory Fields	**/
        for(
            Mandatory_PM__c thisRec : [ SELECT Mandatory_Num_API_Name_Asset__c , Name, Mandatory_Text_API_Name_Asset__c , Mandatory_Num_API_Name_0_Allowed_Asset__c 
                                       FROM Mandatory_PM__c ] 
        ){
            
            if(thisRec.Mandatory_Num_API_Name_Asset__c  != NULL)
                num_MandatoryFieldMap_NonZero.put(thisRec.Name, new Set<String>(thisRec.Mandatory_Num_API_Name_Asset__c.split(',')));
            
            if(thisRec.Mandatory_Text_API_Name_Asset__c != NULL)
                txt_MandatoryFieldMap_NonZero.put(thisRec.Name, new Set<String>(thisRec.Mandatory_Text_API_Name_Asset__c.split(',')));
            
            if(thisRec.Mandatory_Num_API_Name_0_Allowed_Asset__c  != NULL)
                num_MandatoryFieldMap_WithZero.put(thisRec.Name, new Set<String>(thisRec.Mandatory_Num_API_Name_0_Allowed_Asset__c .split(',')));
            
        }
        
        for(task t1:(list<task>)listOfNewSObjects){
            system.debug('@#@recordtypeid'+ t1.recordtypeid);
            system.debug('@#@recordtypeid1'+ AssetConstants.ASSET_UPDATE_RecordTypeId);
            if((t1.recordtypeid == AssetConstants.ASSET_UPDATE_RecordTypeId || t1.recordtypeid == AssetConstants.ASSET_CREATE_RecordTypeId) && (t1.status =='Approved' || t1.status == 'Rejected')){
                t1.addError('Task can be created with only Pending Status!');
            }
            if((t1.recordtypeid == AssetConstants.ASSET_UPDATE_RecordTypeId) || t1.recordtypeid == AssetConstants.ASSET_CREATE_RecordTypeId){
                relatedId.add(t1.whatid) ;
                taskList.add(t1);
                if( t1.New_Value_Product__c != NULL )
                    prodId.add(t1.New_Value_Product__c);
            }
        }
        Map<id,product2> prodMap = new map<id,product2>([ SELECT Id,product2.Corrected_Module_for_metering__c FROM product2 WHERE Id IN :prodId ]);
        
        map<id,asset> assetList = new map<id,asset>([select id,status,purchasedate,License_Extension_Count__c,Asset.Days_to_Extend__c,usageenddate,price,product2id,product2.name,billing_type__c,account.name,opportunity__r.name, Account.Onboarding_Owner__r.Email,Flag_for_Asset_Sucess__c,Activation_Flag__c,Project_Stage__c,Project_Status__c from asset where id in :relatedId]);
        for(task t1:taskList){
            if(!(t1.recordtypeid == AssetConstants.ASSET_CREATE_RecordTypeId)){
                t1.Asset_Account_CSM_Email__c = assetList.get(t1.WhatId).Account.Onboarding_Owner__r.email;
                t1.Old_Value_PO_End_date__c = assetList.get(t1.whatid).usageenddate;
                t1.Old_Value_PO_Start_date__c =assetList.get(t1.whatid).purchasedate;
                t1.Old_Value_Price__c =assetList.get(t1.whatid).price;
                //t1.Old_Value_Product__c =assetList.get(t1.whatid).product2.name;
                t1.related_account__C = assetList.get(t1.whatid).account.name;
                if(t1.Asset_to_be_deleted__c){
                    t1.asset_status__c = assetList.get(t1.whatid).status ;
                    t1.Asset_success_flag__c = assetList.get(t1.whatid).Flag_for_Asset_Sucess__c;
                    t1.Asset_Opportunity_Source__c = assetList.get(t1.whatid).opportunity__r.name ;
                    t1.Billing_Type__c = assetList.get(t1.whatid).Billing_Type__c ;
                    t1.Asset_Activation_flag__c = assetList.get(t1.whatid).Activation_Flag__c;
                    t1.Project_Stage__c = assetList.get(t1.whatid).Project_Stage__c ;
                    t1.Project_Status__c = assetList.get(t1.whatid).Project_Status__c ;
                    t1.RecordTypeId = assetConstants.ASSET_DELETE_RecordTypeId;
                }
            }
            if(t1.recordtypeid == AssetConstants.ASSET_UPDATE_RecordTypeId || t1.recordtypeid == AssetConstants.ASSET_CREATE_RecordTypeId){
                if(t1.recordtypeid == AssetConstants.ASSET_UPDATE_RecordTypeId){
                    assMod= 'Asset Modification';
                    assMod = assMod + '-Account:'+assetList.get(t1.whatid).account.name;
                    if(t1.New_Value_Price__c != null)
                        assMod = assMod + '-Price';
                    if(t1.New_Value_PO_End_date__c != null)
                        assMod = assMod +'-Period end Date'; 
                    if(t1.New_Value_PO_Start_date__c != null)
                        assMod = assMod + '-Period start Date';
                    if(t1.Days_to_Extend__c  != null)
                        assMod = 'License Extension- '+assMod;
                }
                else{
                    assMod = assCreate;
                }
                if(t1.New_Value_Product__c != null)
                {
                    product2 prod = [select id,name,billing_Type__c from product2 where id =: t1.New_Value_Product__c];
                    if(!(t1.recordtypeid == AssetConstants.ASSET_CREATE_RecordTypeId) && assetList.get(t1.whatid).billing_type__c != prod.billing_Type__c )
                        t1.finance_approval_needed__c = true;
                    assMod = assMod + '-Product:'+prod.name;
                }
                if(t1.Days_to_Extend__c != null){       
                    if(assetList.get(t1.whatid).Days_to_Extend__c== NULL){
                        if(t1.Days_to_Extend__c  < 30)
                            t1.Status = 'Approved';
                        t1.Approval_Rejected_Comment__c = 'Auto-Approved';  
                    }
                    else if(
                        assetList.get(t1.whatid).Days_to_Extend__c  + t1.Days_to_Extend__c < 30)
                    {
                        t1.Status = 'Approved';
                        t1.Approval_Rejected_Comment__c = 'Auto-Approved'; 
                        
                    }
                }
            }
            else{
                assDel = assDel + '-Account:'+assetList.get(t1.whatid).account.name;
                assMod = assDel;
            }
            
            t1.subject = assMod;
            if((t1.recordtypeid == AssetConstants.ASSET_CREATE_RecordTypeId)){
                //Added by Kartikeya- for Mandatory PM logic
                Boolean 	isError_Zero 		= FALSE;
                Boolean 	isError_Non_Zero 	= FALSE;
                Set<String> mandatory_NonZero 	= new Set<String>();
                Set<String> mandatory_WithZero 	= new Set<String>();
                if( 
                    num_MandatoryFieldMap_NonZero.size() > 0			&&
                    num_MandatoryFieldMap_NonZero.containsKey(prodMap.get(t1.New_Value_Product__c).Corrected_Module_for_metering__c)
                ){
                    mandatory_NonZero.addAll(num_MandatoryFieldMap_NonZero.get(prodMap.get(t1.New_Value_Product__c).Corrected_Module_for_metering__c));
                }
                
                if( 
                    txt_MandatoryFieldMap_NonZero.size() > 0			&&
                    txt_MandatoryFieldMap_NonZero.containsKey(prodMap.get(t1.New_Value_Product__c).Corrected_Module_for_metering__c)
                ){
                    mandatory_NonZero.addAll(txt_MandatoryFieldMap_NonZero.get(prodMap.get(t1.New_Value_Product__c).Corrected_Module_for_metering__c));
                }
                
                if( 
                    num_MandatoryFieldMap_WithZero.size() > 0			&&
                    num_MandatoryFieldMap_WithZero.containsKey(prodMap.get(t1.New_Value_Product__c).Corrected_Module_for_metering__c)
                ){
                    mandatory_WithZero.addAll(num_MandatoryFieldMap_WithZero.get(prodMap.get(t1.New_Value_Product__c).Corrected_Module_for_metering__c));
                }
                /**	Non Zero or Null Value Check	**/
                for(String thisSTR : mandatory_NonZero){
                    if(t1.get(thisSTR) == NULL || t1.get(thisSTR) == 0 ){
                        String fieldLabel = fieldMap.get(thisSTR).getDescribe().getLabel();
                        errorMessage_Non_Zero += (fieldLabel+' ,');
                        isError_Non_Zero = TRUE;
                        // mapOfNewIdWithQuotes.get(quotekey).addError(thisSTR,'Enter non-zero value for this field');
                    } 
                }
                
                /**	Zero allowed Value Check	**/
                for(String thisSTR : mandatory_WithZero){
                    if( t1.get(thisSTR) == NULL  ){
                        String fieldLabel = fieldMap.get(thisSTR).getDescribe().getLabel();
                        errorMessage_Zero_Allowed += (fieldLabel+' ,');
                        isError_Zero = TRUE;
                        // mapOfNewIdWithQuotes.get(quotekey).addError(thisSTR,'Enter value for this field');
                    } 
                }
                
                /**	Remove End	**/
                errorMessage_Non_Zero 		= errorMessage_Non_Zero.removeEnd(' ,');
                errorMessage_Zero_Allowed 	= errorMessage_Zero_Allowed.removeEnd(' ,');
                
                /**	Error Condition Check	**/
                if( isError_Zero && isError_Non_Zero ){
                    t1.adderror(errorMessage_Non_Zero + ' & ' +errorMessage_Zero_Allowed,false);
                } else if( isError_Zero  ){
                    t1.adderror(errorMessage_Zero_Allowed);
                } else if( isError_Non_Zero ){
                    t1.adderror(errorMessage_Non_Zero );
                } else{
                    /**	No Error	**/
                }
            }
            
        }
        }
    }
    
    
    /**
* @description handle after Insert event on Trigger
* @author Lokesh Thathuru | 07/12/2020
* @param List<SObject> listOfNewSObjects
* @param Map<Id,SObject> mapOfNewSObjects
* @return void
*/
    public static void afterInsert(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){
         if(caseconstants.taskTrigger){
        String Asset_Lincence_Asset_RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(AssetConstants.RECORD_TYPE_NAME_LICENCED_ASSET).getRecordTypeId();
        String Asset_OneTime_Asset_RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(AssetConstants.RECORD_TYPE_NAME_ONETIME_ASSET).getRecordTypeId();
        String Asset_Integration_Asset_RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(AssetConstants.RECORD_TYPE_NAME_INTEGRATION_ASSET).getRecordTypeId();
        map<id,task> newTaskMap = new map<id,task>();
        map<id,task> oldTaskMap = new map<id,task>();
        list<sobject> taskRollUp = new list<sobject>();
        list<asset> delAssetList = new list<asset>();
        //list<asset> assetListNew = new list<asset>();
        
        /*/bhaveshjindal
list<ContentDocumentLink> cdLinkList = new list<ContentDocumentLink>();
cdLinkList = [SELECT ID, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink Where LinkedEntityId In :mapOfNewSObjects.keySet()];
Map<Id, ContentDocumentLink> cdLinkMap = new Map<Id, ContentDocumentLink>();
cdLinkMap.putAll(cdLinkList);
Map<Id, Id> cdLinkIdAndTaskIdMap = new Map<Id, Id>();
Map<Id, Asset> taskIdAndAssetMap = new Map<Id, Asset>();
for(ContentDocumentLink thisCdLink : cdLinkList){
cdLinkIdAndTaskIdMap.put(thisCdLink.id, thisCdLink.LinkedEntityId);
}
//end*/
        set<id> relatedId = new set<id>();
        for(id t1:mapOfNewSObjects.keyset()){
            //task oldTask = (task)mapOfOldSObjects.get(t1);
            task newTask = (task)mapOfNewSObjects.get(t1);
            if((newTask.recordtypeid == AssetConstants.ASSET_UPDATE_RecordTypeId || newTask.recordtypeid == AssetConstants.ASSET_CREATE_RecordTypeId) || newTask.recordtypeid == AssetConstants.ASSET_DELETE_RecordTypeId ){
                relatedId.add(newTask.whatid) ;
                newTaskMap.put(newTask.id,newTask);
                //oldTaskMap.put(oldTask.id,oldTask);
            }
        }
        Boolean updateBool = false;
        map<id,asset> assetList = new map<id,asset>([select id,License_Extension_Count__c,status,purchasedate,usageenddate,accountId,No_of_airline_invoices__c,License_B2B_SalesInvoice_per_year__c,	License_B2C_SalesInvoice_per_year__c,Number_of_eway_bill__c,License_no_of_gstins__c,	License_no_of_gstin_verification_credits__c,License_no_of_invoice_formats__c,License_no_of_irns_per_year__c,License_no_of_pans__c,	Number_of_Purchase_Invoice__c,License_no_of_userids__c,No_of_Vendor__c,No_of_airline_invoices_annual__c,ERP__c,Existing_Vendor__c,multi_year__c,Days_to_Extend__c  from asset where id in :relatedId]);
        for(task t1 : newTaskMap.values()){
            if(t1.status == 'Approved'){
                taskRollUp.add(t1);
                AssetConstants.TASK_APPROVAL = true; 
                if( t1.deleted_Asset_Backend__c != null){
                    delAssetList.add([select id from asset where id =:t1.deleted_Asset_Backend__c]);
                }
                else{
                    if(t1.recordtypeid == AssetConstants.ASSET_UPDATE_RecordTypeId){
                        if(t1.New_Value_PO_End_date__c != t1.Old_Value_PO_End_date__c && t1.New_Value_PO_End_date__c != null){
                            assetList.get(t1.whatid).usageenddate = t1.New_Value_PO_End_date__c;
                        }
                        if(t1.New_Value_PO_Start_date__c != t1.Old_Value_PO_Start_date__c && t1.New_Value_PO_Start_date__c != null){
                            assetList.get(t1.whatid).purchasedate = t1.New_Value_PO_Start_date__c;
                        }
                        system.debug('I am checking Price here New Out: '+t1.New_Value_Price__c);
                        if(t1.Old_Value_Price__c != t1.New_Value_Price__c && t1.New_Value_Price__c != NULL){
                            system.debug('I am checking Price here New: '+t1.New_Value_Price__c);
                            //system.debug('I am checking Price here Old: '+t1.Old_Value_Price__c);
                            assetList.get(t1.whatid).Price = t1.New_Value_Price__c;
                        }
                        if(t1.New_Value_Product__c != null){
                            assetList.get(t1.whatid).Product2id = t1.New_Value_Product__c;
                        }
                        if(t1.Days_to_Extend__c != null){
                            assetList.get(t1.whatid).License_Extension_Count__c   =(assetList.get(t1.whatid)?.License_Extension_Count__c == NULL ? 0 : assetList.get(t1.whatid)?.License_Extension_Count__c) + 1;
                            
                            assetList.get(t1.whatid).Days_to_Extend__c  =(assetList.get(t1.whatid)?.Days_to_Extend__c == NULL ? 0 : assetList.get(t1.whatid)?.Days_to_Extend__c) + t1.Days_to_Extend__c ;
                        }
                        updateBool = true;
                    }
                   
                }
                
            }
            
            
        }
        if(delAssetList.size() > 0 )
        {
            delete(delAssetList);
        }
        if((assetList.Values().size()>0) && updateBool){
            system.debug('assetListdebug:' + assetList.keySet());
            if(assetList.Values().size()>0)
            upsert(assetList.Values());
            
            //TaskTriggerHelper.updateAsset(taskRollUp);
        }
         }
        
        /*for(Asset thisAsset : assetListNew){
Id i = TaskTriggerHelper.getTaskIdForAsset(taskIdAndAssetMap,thisAsset);
}*/
    }
    
    
    
    /**
* @description  handle before Update event on Trigger
* @author Lokesh Thathuru | 07/12/2020
* @param Map<Id,SObject> mapOfNewSObjects
* @param Map<Id,SObject> mapOfOldSObjects
* @return void
*/
    public static void beforeUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjectsold){
        String financeApprover = system.Label.Task_Approver_Finance;
        String categoryApprover = system.Label.Task_Approver_Category;
        String taskStatus = system.Label.Task_Status;
        Map<Id,Task> mapOfOldSObjects = (Map<Id,Task>)mapOfOldSObjectsold;
        list<task> taskList = (list<task>)mapOfNewSObjects.values();
        set<id> relatedId = new set<id>();
        for(id t1:mapOfNewSObjects.keyset()){
            task newTask = (task)mapOfNewSObjects.get(t1);
            if((newTask.recordtypeid == AssetConstants.ASSET_UPDATE_RecordTypeId) || (newTask.recordtypeid == AssetConstants.ASSET_DELETE_RecordTypeId)){
                relatedId.add(newTask.whatid) ;
            }
        }
        map<id,asset> assetList = new map<id,asset>([select id,status,purchasedate,usageenddate,accountId,opportunity__r.name,Billing_Type__c,Flag_for_Asset_Sucess__c,Activation_Flag__c,Project_Stage__c,Project_Status__c from asset where id in :relatedId]);
        for(task t:taskList){
            If(!financeApprover.contains(UserInfo.getUserId()) && (t.recordtypeid == AssetConstants.ASSET_UPDATE_RecordTypeId || t.recordtypeid == AssetConstants.ASSET_CREATE_RecordTypeId || t.recordtypeid == AssetConstants.ASSET_DELETE_RecordTypeId) && t.status == 'Approved'){
                t.addError('Unauthorized Approver or Invalid Action!') ; 
            }
            If((!financeApprover.contains(UserInfo.getUserId()) && !CategoryApprover.contains(UserInfo.getUserId())) && (t.recordtypeid == AssetConstants.ASSET_UPDATE_RecordTypeId || t.recordtypeid == AssetConstants.ASSET_CREATE_RecordTypeId || t.recordtypeid == AssetConstants.ASSET_DELETE_RecordTypeId) && t.status == 'Rejected'){
                t.addError('Unauthorized Approver or Invalid Action!') ; 
            }
            if(t.status == 'Rejected' || t.status == 'Approved'){
                t.Approved_Rejected_By__c = UserInfo.getFirstName() +' ' + UserInfo.getLastName();
                t.Approved_Rejected_Date__c = Date.today();  
                if(t.Asset_to_be_deleted__c){
                    t.deleted_Asset_Backend__c = t.whatId;
                    t.whatId = assetList.get(t.whatid).accountId;  
                }
            }
 			/* Changes related to SAL-1363 --  Issue in marking "Completed and Completed-No Potential" under Tasks */

           /* if(t.status == 'Completed - No potential'){
            }
            List<String> statusList = System.Label.Task_Status.split(' ');*/
            
           // List<String> statusList = taskStatus.split(' ');

            //if(statusList != null){
            system.debug('taskStatus '+taskStatus);
            system.debug('Status '+t.Status);
               if(taskStatus.contains(mapOfOldSObjects.get(t.id).status) && t.Status == 'Overdue'){
                t.Status = mapOfOldSObjects.get(t.id).status;
            }
           // }      
        }
        
    }
    
    /**
* @description  handle After Update event on Trigger
* @author Lokesh Thathuru | 07/12/2020
* @param Map<Id,SObject> mapOfNewSObjects
* @param Map<Id,SObject> mapOfOldSObjects
* @return void
*/
    public static void afterUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){

        ProjectConstants.isFirstTimeProject = FALSE;

        String Asset_Lincence_Asset_RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(AssetConstants.RECORD_TYPE_NAME_LICENCED_ASSET).getRecordTypeId();
        String Asset_OneTime_Asset_RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(AssetConstants.RECORD_TYPE_NAME_ONETIME_ASSET).getRecordTypeId();
        String Asset_Integration_Asset_RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(AssetConstants.RECORD_TYPE_NAME_INTEGRATION_ASSET).getRecordTypeId();
        map<id,task> newTaskMap = new map<id,task>();
        map<id,task> oldTaskMap = new map<id,task>();
        list<sobject> taskRollUp = new list<sobject>();
        list<asset> delAssetList = new list<asset>();
        list<asset> assetListNew = new list<asset>();
        
        /*/bhaveshjindal
list<ContentDocumentLink> cdLinkList = new list<ContentDocumentLink>();
cdLinkList = [SELECT ID, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink Where LinkedEntityId In :mapOfNewSObjects.keySet()];
Map<Id, ContentDocumentLink> cdLinkMap = new Map<Id, ContentDocumentLink>();
cdLinkMap.putAll(cdLinkList);
Map<Id, Id> cdLinkIdAndTaskIdMap = new Map<Id, Id>();
Map<Id, Asset> taskIdAndAssetMap = new Map<Id, Asset>();
for(ContentDocumentLink thisCdLink : cdLinkList){
cdLinkIdAndTaskIdMap.put(thisCdLink.id, thisCdLink.LinkedEntityId);
}
//end*/
        set<id> relatedId = new set<id>();
        for(id t1:mapOfNewSObjects.keyset()){
            task oldTask = (task)mapOfOldSObjects.get(t1);
            task newTask = (task)mapOfNewSObjects.get(t1);
            if((newTask.recordtypeid == AssetConstants.ASSET_UPDATE_RecordTypeId || newTask.recordtypeid == AssetConstants.ASSET_CREATE_RecordTypeId) || newTask.recordtypeid == AssetConstants.ASSET_DELETE_RecordTypeId ){
                relatedId.add(newTask.whatid) ;
                newTaskMap.put(newTask.id,newTask);
                oldTaskMap.put(oldTask.id,oldTask);
            }
        }
        Boolean updateBool = false;
        map<id,asset> assetList = new map<id,asset>([select id,License_Extension_Count__c,status,purchasedate,usageenddate,accountId,No_of_airline_invoices__c,License_B2B_SalesInvoice_per_year__c,	License_B2C_SalesInvoice_per_year__c,Number_of_eway_bill__c,License_no_of_gstins__c,	License_no_of_gstin_verification_credits__c,License_no_of_invoice_formats__c,License_no_of_irns_per_year__c,License_no_of_pans__c,	Number_of_Purchase_Invoice__c,License_no_of_userids__c,No_of_Vendor__c,No_of_airline_invoices_annual__c,ERP__c,Existing_Vendor__c,multi_year__c,Days_to_Extend__c  from asset where id in :relatedId]);
        for(task t1 : newTaskMap.values()){
            if(t1.status == 'Approved'){
                taskRollUp.add(t1);
                AssetConstants.TASK_APPROVAL = true; 
                if( t1.deleted_Asset_Backend__c != null){
                    delAssetList.add([select id from asset where id =:t1.deleted_Asset_Backend__c]);
                }
                else{
                    if(t1.recordtypeid == AssetConstants.ASSET_UPDATE_RecordTypeId){
                        if(t1.New_Value_PO_End_date__c != t1.Old_Value_PO_End_date__c && t1.New_Value_PO_End_date__c != null){
                            assetList.get(t1.whatid).usageenddate = t1.New_Value_PO_End_date__c;
                        }
                        if(t1.New_Value_PO_Start_date__c != t1.Old_Value_PO_Start_date__c && t1.New_Value_PO_Start_date__c != null){
                            assetList.get(t1.whatid).purchasedate = t1.New_Value_PO_Start_date__c;
                        }
                        system.debug('I am checking Price here New Out: '+t1.New_Value_Price__c);
                        if(t1.Old_Value_Price__c != t1.New_Value_Price__c && t1.New_Value_Price__c != NULL){
                            system.debug('I am checking Price here New: '+t1.New_Value_Price__c);
                            //system.debug('I am checking Price here Old: '+t1.Old_Value_Price__c);
                            assetList.get(t1.whatid).Price = t1.New_Value_Price__c;
                        }
                        if(t1.New_Value_Product__c != null){
                            assetList.get(t1.whatid).Product2id = t1.New_Value_Product__c;
                        }
                        if(t1.Days_to_Extend__c != null){
                            assetList.get(t1.whatid).License_Extension_Count__c   =(assetList.get(t1.whatid)?.License_Extension_Count__c == NULL ? 0 : assetList.get(t1.whatid)?.License_Extension_Count__c) + 1;
                            
                            assetList.get(t1.whatid).Days_to_Extend__c  =(assetList.get(t1.whatid)?.Days_to_Extend__c == NULL ? 0 : assetList.get(t1.whatid)?.Days_to_Extend__c) + t1.Days_to_Extend__c ;
                        }
                        updateBool = true;
                    }
                    else{
                        asset ass = new asset();
                        ass.accountId= t1.whatId;
                        ass.CurrencyIsoCode = t1.currencyISOCode;
                        ass.usageenddate = t1.New_Value_PO_End_date__c;
                        ass.purchasedate = t1.New_Value_PO_Start_date__c;
                        ass.Price = t1.New_Value_Price__c;
                        ass.Product2id = t1.New_Value_Product__c;
                        ass.Name = t1.Product_Name_text__c + ' '+t1.PO_End_Month__c + ' '+t1.New_Value_PO_End_date__c.year();
                        ass.No_of_airline_invoices__c = t1.No_of_airline_invoices__c ;
                        ass.License_B2B_SalesInvoice_per_year__c = t1.License_B2B_SalesInvoice_per_year__c ;
                        ass.License_B2C_SalesInvoice_per_year__c = t1.License_B2C_SalesInvoice_per_year__c ;
                        ass.Number_of_eway_bill__c = t1.Number_of_eway_bill__c ;
                        ass.License_no_of_gstins__c = t1.License_no_of_gstins__c ;
                        ass.License_no_of_gstin_verification_credits__c = t1.License_no_of_gstin_verification_credits__c ;
                        ass.License_no_of_invoice_formats__c = t1.License_no_of_invoice_formats__c ;
                        ass.License_no_of_irns_per_year__c = t1.License_no_of_irns_per_year__c ;
                        ass.License_no_of_pans__c = t1.License_no_of_pans__c ;
                        ass.Number_of_Purchase_Invoice__c = t1.Number_of_Purchase_Invoice__c ;
                        ass.License_no_of_userids__c = t1.License_no_of_userids__c ;
                        ass.No_of_Vendor__c = t1.No_of_Vendor__c ;
                        ass.No_of_airline_invoices_annual__c = t1.No_of_airline_invoices_annual__c ;
                        ass.ERP__c = t1.ERP__c ;
                        ass.Multi_year__c = t1.Multi_year__c ;
                        ass.Days_to_Extend__c = t1.Days_to_Extend__c ;
                        ass.Existing_Vendor__c = t1.Existing_Vendor__c ;
                        ass.Type_of_Integration_QLI__c = t1.Type_of_Integration__c;
                        if(t1.Product_Category__c == ProductConstants.PRODUCT_CATEGORY_INTEGRATION){
                            ass.RecordTypeId = Asset_Integration_Asset_RecordTypeId; 
                        }
                        else if(t1.Product_Category__c == ProductConstants.PRODUCT_CATEGORY_SETUPONBOARDING){
                            ass.RecordTypeId = Asset_OneTime_Asset_RecordTypeId; 
                        }
                        else{
                            ass.RecordTypeId = Asset_Lincence_Asset_RecordTypeId; 
                        }
                        
                        //bhaveshjindal
                        //taskIdAndAssetMap.put(t1.Id,ass);
                        
                        assetListNew.add(ass);
                        updateBool = true;
                    }
                }
                
            }
            
            
        }
        if(delAssetList.size() > 0 )
        {
            delete(delAssetList);
        }
        if((assetList.Values().size()>0 || assetListNew.size()>0) && updateBool){
            if(assetList.Values().size()>0)
                assetListNew.add(assetList.Values());
            upsert(assetListNew);
            
            RecursiveTriggerHandler.isFirstTime = FALSE;
            RecursiveTriggerHandler.isFirstTimeRenewed = FALSE;
            //TaskTriggerHelper.updateAsset(taskRollUp); 
            RecursiveTriggerHandler.isFirstTime = TRUE;
            RecursiveTriggerHandler.isFirstTimeRenewed = TRUE;
        }
        
        TaskTriggerHelper.updateBillingDetails((Map<Id,Task>) mapOfNewSObjects, (Map<Id,Task>) mapOfOldSObjects);
        
        TaskTriggerHelper.taskApprovalNotification((Map<Id,Task>) mapOfNewSObjects, (Map<Id,Task>) mapOfOldSObjects);
        

        ProjectConstants.isFirstTimeProject = TRUE;


        /*for(Asset thisAsset : assetListNew){
Id i = TaskTriggerHelper.getTaskIdForAsset(taskIdAndAssetMap,thisAsset);
}*/
    }
    
    /**
* @description  handle before delete event on Trigger
* @author Lokesh Thathuru | 07/12/2020
* @param List<SObject> listOfOldSObjects
* @param Map<Id,SObject> mapOfOldSObjects
* @return void
*/
    public static void beforeDelete(List<SObject> listOfOldSObjects,Map<Id,SObject> mapOfOldSObjects){
        System.debug('<----beforeDelete---->');
        
    }
    
    /**
* @description  handle after Delete event on Trigger
* @author Lokesh Thathuru | 07/12/2020
* @param List<SObject> listOfOldSObjects
* @return void
*/
    public static void afterDelete(Map<Id,SObject> listOfOldSObjects){
        System.debug('<----afterDelete---->');
    }
    
    /**
* @description  handle after UpDelete event on Trigger
* @author Lokesh Thathuru | 07/12/2020
* @param List<SObject> listOfNewSObjects  
* @param Map<Id,SObject> mapOfNewSObjects
* @return void
*/
    public static void afterUnDelete(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){
        System.debug('<----afterUnDelete---->');
    }
    
    
}