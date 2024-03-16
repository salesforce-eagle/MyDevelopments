/**
* @File Name          : CaseTriggerHandler.cls
* @Description        : 
* @Author             : Lokesh@SFDeveloper.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 03-14-2024
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    27/5/2020   Lokesh@SFDeveloper.SFDoc     Initial Version
**/
public without sharing class CaseTriggerHandler implements TriggerInterface{
    
    public static boolean firstRunMergeEmailSend = true;
    
    
    public static void beforeInsert(List<SObject> listOfNewSObjects){
        
        system.debug('I am being called from case before Insert');
        List<Case>	incomingCases = (List<Case>)listOfNewSObjects;
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        List<Case> listOfCasesToUpdateIT_EMAIL_ID=new List<Case>();
        List<Case> updateHtmlLinkInRichTextField=new List<Case>();
        List<Case> updateGoogleFormSubmitterToCase=new List<Case>();
        List<Case> listOfCasesToUpdateIssueTypes=new List<Case>();
        List<Case> listOfNewSolvedCasesToUpdateCaseSolvedDateTime=new List<Case>();
        List<Case> listOfEInvoicingCases=new List<Case>();
        List<Case> listofEnterpriseAndEInvoicingCases=new List<Case>();
        List<Case> listOfCasesToUpdateQueueId=new List<Case>();
        List<Case> listOfCasesToSyncTheStatus=new List<Case>();
        List<Case> listOfCasesToUpdateMaxITCQueueId=new List<Case>();
        
        Set<Id> queueIds = new Set<Id>();
        Map<Id, Case> queueCaseMap = new Map<Id, Case>();
        
        
        if(listOfNewSObjects.size()>0){
            for(SObject objectInstance:listOfNewSObjects){
                Case caseInstance=(Case)objectInstance;
                if( caseInstance.RecordTypeId == CaseConstants.INT_SUPPORT_RecordTypeId && caseInstance.Type == 'Bug'){
                     caseInstance.Priority = 'P0';
                }
                if(caseInstance.Products_Available__c == 'IRP'){
                   caseInstance.recordTypeId = CaseConstants.IRP_RecordTypeId;
                    caseInstance.User_Role_Type__c = 'IRP L2';
                }
                     if( caseInstance.User_Role_Type__c != NULL ){
                caseInstance.recordTypeId = 
                    caseInstance.User_Role_Type__c.Contains('Capture') ?
                    CaseConstants.CLEAR_CAPTURE_RecordTypeId :
                ( 
                    caseInstance.User_Role_Type__c.Contains('Clear Invoice') || caseInstance.User_Role_Type__c.Contains('Invoicing') ? 
                    CaseConstants.CLEAR_INVOICE_RecordTypeId :
                    ( 
                        caseInstance.User_Role_Type__c.Contains('MaxITC') || caseInstance.User_Role_Type__c.Contains('MITC') ?
                        CaseConstants.MAX_ITC_RecordTypeId :
                        (
                            caseInstance.User_Role_Type__c.Contains('Capture') ?
                            CaseConstants.CLEAR_CAPTURE_RecordTypeId :
                            (
                                System.Label.Integration_Support_Queue.contains(caseInstance.User_Role_Type__c)?
                                CaseConstants.INT_SUPPORT_RecordTypeId :
                                (
                                    caseInstance.User_Role_Type__c.Contains('TDS') ?
                                    CaseConstants.TDS_RecordTypeId :
                                    (
                                        caseInstance.User_Role_Type__c.Contains('Clear Identity') ?
                                     	CaseConstants.CLEAR_IDENTITY_RecordTypeId :
                                        (
                                            caseInstance.User_Role_Type__c.Contains('IRP') ?
                                            CaseConstants.IRP_RecordTypeId :
                                            (
                                                caseInstance.User_Role_Type__c.Contains('E-Inv/EWB') ?
                                                CaseConstants.E_INVOICING_RecordTypeId :
                                                (
                                                    caseInstance.User_Role_Type__c.Contains('Invoice Discounting') ?
                                                    CaseConstants.ID_RecordTypeId :
                                                    (
                                                        caseInstance.User_Role_Type__c.Contains('GCC') ?
                                                        CaseConstants.GCC_RecordTypeId :
                                                        caseInstance.recordTypeId
                                                    )
                                                    
                                                )
                                                
                                            )
                                        )
                                     	
                                    )
                                )
                            )
                        )
                    )
                );
                    caseInstance.Product_Route_Type__c = 
                    caseInstance.User_Role_Type__c.Contains('Capture') ?
                    'Clear Capture' :
                ( 
                    caseInstance.User_Role_Type__c.Contains('Clear Invoice') || caseInstance.User_Role_Type__c.Contains('Invoicing')  ?
                    'Clear Invoice' :
                    ( 
                        caseInstance.User_Role_Type__c.Contains('MaxITC') || caseInstance.User_Role_Type__c.Contains('MITC') ?
                        'MaxITC' :
                        caseInstance.Product_Route_Type__c
                    )
                );
                    }
                
                if(caseInstance.User_Role_Type__c != NULL){
                    caseInstance.OwnerId = caseInstance.User_Role_Type__c.Contains('IRP') ? System.Label.IRP_Queue_ID : caseInstance.OwnerId;
                } else{
                    caseInstance.OwnerId = caseInstance.OwnerId;
                }
                
                    
                if(caseInstance.Status!=null){	
                    listOfCasesToSyncTheStatus.add(caseInstance);	
                }
                
                if(caseInstance.IT_Email_ID__c==null && Label.IT_Email_Id!=null){
                    listOfCasesToUpdateIT_EMAIL_ID.add(caseInstance);
                }
                
                if(caseInstance.Web_Form_Submitter_Email__c!=null || caseInstance.Web_Form_Submitter_Email__c!='' && caseInstance.Web_Form_Submitter_Email__c==null){
                    updateGoogleFormSubmitterToCase.add(caseInstance);
                }
                
                //Added by Chandu 02-july-2020 start
                if(caseInstance.Google_Form_Attachments_URL__c!=null){
                    updateHtmlLinkInRichTextField.add(caseInstance);
                }   
                //Added by Chandu 02-july-2020 end
                //new 30-july-2020 CR start
                if(caseInstance.Lookup_Issue_Type__c!=null || caseInstance.Lookup_Issue_Type1__c!=null || caseInstance.Lookup_Issue_Type_EInv__c!=null ){ // Enhanced by lokesh 21 jan
                    listOfCasesToUpdateIssueTypes.add(caseInstance);
                }
                //new 30-july-2020 end
                
                //E Invoicing Enhancement  start 2-feb-2021
                if(CaseInstance.RecordTypeId==new CaseSelector().getCaseRecordTypeIdByName(CaseConstants.Case_RECORDTYPENAME_E_INVOICING)){
                    listOfEInvoicingCases.add(CaseInstance);
                }
                //E Invoicing Enhancement  end 2-feb-2021
                //Enhancement that are requested by E invoice Team and B2B CA/SME team all cases
                if(caseInstance.Status != null && (caseInstance.Status== CaseConstants.STATUS_SOLVED || caseInstance.Status== CaseConstants.STATUS_CLOSED )  ){
                    caseInstance.Status='New';
                    caseInstance.SolvedOnCreation__c=true;
                    listOfNewSolvedCasesToUpdateCaseSolvedDateTime.add(caseInstance); 
                }
                
                if(caseInstance.Origin!=null && caseInstance.Origin==CaseConstants.ORIGIN_INTERNAL_WEB_FORM && caseInstance.Case_Sub_Origin__c!=null &&                    
                   caseInstance.Case_Sub_Origin__c==CaseConstants.SUB_ORIGIN_GST_WEB_FORM && caseInstance.Customer_Segment__c!=null){
                       System.debug(caseInstance);
                       listofEnterpriseAndEInvoicingCases.add(caseInstance);
                   }
                
                if(caseInstance.OwnerId!=null  && !String.ValueOf(caseInstance.OwnerId).startsWithIgnoreCase('005') /**|| (caseInstance.Previous_Queue_Id__c != String.ValueOf(caseInstance.OwnerId) && )**/){
                    listOfCasesToUpdateQueueId.add(caseInstance);
                }
                
                if(caseInstance.Origin=='Web' && caseInstance.Case_Sub_Origin__c!=null && (caseInstance.ContactId==null || caseInstance.AccountId == null) && caseInstance.SuppliedEmail!=null){	
                    if(caseInstance.Case_Sub_Origin__c.equalsIgnoreCase('GST Product Form')){	
                        caseInstance.Email_Source__c = CaseConstants.ENTERPRISE_GSTSUPPORTEMAIL;	
                        caseInstance.RecordTypeId=new CaseSelector().getCaseRecordTypeIdByName(CaseConstants.B2B_CA_SME);	
                    }else if(caseInstance.Case_Sub_Origin__c.equalsIgnoreCase('EINV Product Form')){	
                        caseInstance.RecordTypeId=new CaseSelector().getCaseRecordTypeIdByName(CaseConstants.Case_RECORDTYPENAME_E_INVOICING);	
                        caseInstance.SuppliedName=caseInstance.SuppliedName=='null null'?'Customer':'';
                    }	
                }
                
                if(caseInstance.Type!='Incident of problem'){//if Type is not Incident of problem then no parent case is tagged
                    caseInstance.ParentId=null;
                }
                
                if(caseInstance.OwnerId.getSObjectType() != User.SObjectType || caseInstance.Priority != null){
                    queueIds.add(caseInstance.OwnerId);
                    queueCaseMap.put(caseInstance.Id, caseInstance);
                }
                
                //Product type MaxITC check
                if(caseInstance.Product_Route_Type__c == 'MaxITC'){
                    listOfCasesToUpdateMaxITCQueueId.add(caseInstance);
                }
                if(caseInstance.Case_Sub_Origin__c != NULL && caseInstance.Case_Sub_Origin__c.equalsIgnoreCase('Clear Capture form')){
                    caseInstance.product_type__c = 'Clear Capture';	
                }
                //Added by Ashwin
                //caseInstance.CaseTracker_PIN__c = CaseTriggerHelper.generateRandomOTP();
                
                /** Added by Ashwin :: Internal Case **/
                if(caseInstance.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Case').getRecordTypeId()){
                    caseInstance.AccountId = System.label.Account_Id_Internal_Case;	
                }
                
                // Reassign to GST L2 Queue - Legacy Case Form
                if((caseInstance.Web_Form_Submitter_Email__c != NULL && 
                    System.Label.Call_Centre_Case_Email_Address.contains(caseInstance.Web_Form_Submitter_Email__c)) &&
                   caseInstance.Origin == 'Internal Web Form' && 
                   caseInstance.ownerId == System.label.GST_L1_Email_Support_Team_QueueID &&
                   caseInstance.RecordtypeId == CaseConstants.B2B_CASME_RecordTypeId){
                       caseInstance.ownerId      		= System.Label.GST_L2_Support_Team_QueueID;
                       caseInstance.User_Role_Type__c 	= 'GST L2 Support Team';
                   }
                
                caseInstance.setOptions(dmo); 
            }
        }
        
        /**    if(!queueCaseMap.isEmpty()){
CaseTriggerHelper.updateUserRoleType(queueCaseMap, queueIds, null);
}**/
        
        if(listOfCasesToSyncTheStatus.size()>0){	
            CaseTriggerHelper.SyncTheStatusWithBackStatus(listOfCasesToSyncTheStatus);	
        }
        
        if(listOfEInvoicingCases.size()>0){
            CaseTriggerHelper.eInvoicePriorityToP1(listOfEInvoicingCases);
        }
        
        if(listOfCasesToUpdateIT_EMAIL_ID.size()>0){
            CaseTriggerHelper.updateITEMAILIDFieldOnCase(listOfCasesToUpdateIT_EMAIL_ID);
        }
        
        if(listOfNewSObjects!=null && listOfNewSObjects.size()>0){
            CaseTriggerHelper.updateQuestionToCase((List<Case>)listOfNewSObjects);
        }
        
        if(updateGoogleFormSubmitterToCase.size()>0){
            CaseTriggerHelper.updateGoogleFormSubmitterByEmail(updateGoogleFormSubmitterToCase);
        }        
        
        //Added by Chandu 02-july-2020 start        
        if(updateHtmlLinkInRichTextField.size()>0){
            CaseTriggerHelper.formatGoogleFormAttachmentsLinks(updateHtmlLinkInRichTextField);
        }
        //Added by Chandu 02-july-2020 end
        
        if(listOfCasesToUpdateIssueTypes.size()>0){
            CaseTriggerHelper.tagIssueToCases(listOfCasesToUpdateIssueTypes);
        }
        
        if(listOfNewSolvedCasesToUpdateCaseSolvedDateTime.size()>0){
            CaseTriggerHelper.updateCaseSolvedDatTime(listOfNewSolvedCasesToUpdateCaseSolvedDateTime);
        }
        
        if(listofEnterpriseAndEInvoicingCases.size()>0){
            CaseTriggerHelper.updateCustomWebFormRTypesByCustomerSegment(listofEnterpriseAndEInvoicingCases);
        }
        
        if(listOfCasesToUpdateQueueId.size()>0){
            CaseTriggerHelper.updateQueueIdToCase(listOfCasesToUpdateQueueId);
        }
        
        //Product type MaxITC check
        if(listOfCasesToUpdateMaxITCQueueId.size()>0){
            CaseTriggerHelper.productTypeMaxITC(listOfCasesToUpdateMaxITCQueueId);
        }
        
        
        
    }
    
    public static void afterInsert(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){
        
        system.debug('Automated Case is being Created - In After Insert');
        List<Case> listOfCasesToApplyRoudRobinLogic=new List<Case>();
        Set<Id> setOfCaseIds=new Set<Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Set<String> emailSet = new Set<String>();
        List<Case> caseListToUpdateContactAccount = new List<Case>();
        Map<Id, Case> autoResponseCaseMap = new Map<Id, Case>();
        
        //added so the additional cases are not creted : 14 dec 2021
        List<case> listOfCasesToNotToInsert=new List<case>();
        //added for sending warning mails distribution list :15 dec 2021
        Set<Id> queueIds                          = new Set<Id>();
        //added for sending auto ack to cases created by web :12 april 2022
        Map<id,Case> mapOfWebCasesTosendAutoACK  =new  Map<id,Case>();
        Map<id,string> mapOfRelatedContactEmails =new  Map<id,string>();
        List<Case> finalListToUpdate             = new List<Case>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        
        for( Case newCase : (List<Case>)listOfNewSObjects ){
            if( newCase.AccountId != NULL )
            accountMap.put( newCase.AccountId, NULL );
        }
        
        for( 
            Account thisAcc : [ SELECT Id, Onboarding_Owner__r.Email 
                               FROM Account WHERE 
                               Id IN :accountMap.keySet() ] 
        ){
            if( thisAcc.Onboarding_Owner__r.Email != NULL )
            accountMap.put( thisAcc.Id, thisAcc );
        }
        
        if(listOfNewSObjects.size()>0){
            for(SObject objectInstance:listOfNewSObjects){
                Case caseOrig = (Case)objectInstance;
                Case caseInstance = caseOrig.clone(FALSE,FALSE,FALSE,FALSE);
                caseInstance.put('Id',caseOrig.Id);
                
                
                if(caseInstance.SolvedOnCreation__c){
                    caseInstance = CaseTriggerHelper.futureHandleOnClose(caseInstance);
                }
                
                if(caseInstance.Auto_Response_Sent__c == false && (!String.isEmpty(caseInstance.ContactEmail) || !String.isEmpty(caseInstance.SuppliedEmail))  && caseInstance.ContactEmail != 'support@cleartaxmailer.com' && caseInstance.Incoming_Email_Count__c == null){
                    system.debug('INside autoResponseCaseMap');
                    caseInstance = CaseTriggerHelper.autoRespondManualCases( caseInstance, accountMap.get(caseInstance.Id) );
                }
                if(!String.isEmpty(caseInstance.User_Role_Type__c) && !String.isEmpty(caseInstance.Priority) && caseInstance.OwnerId != System.label.Spam_Queue){
                    caseInstance = CaseTriggerHelper.updateRTAndEntitlement(caseInstance);
                    system.debug('Owner#$%8'+caseInstance.OwnerId);
                }
                
                if(caseInstance.SuppliedEmail!=null 				&& 
                   caseInstance.OwnerId != System.label.Spam_Queue 	&& 
                   caseInstance.RecordTypeId != Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Case').getRecordTypeId())
                {
                   /**if(
                        caseInstance.AccountId == NULL  || System.Label.Financial_Query_RecordType_Id.containsIgnoreCase(caseInstance.RecordTypeId) 
                    ){**/
                    system.debug('TestSuppliedEmail'+caseInstance.SuppliedEmail);
                    if(!System.label.block_contact_creation.contains(caseInstance.SuppliedEmail.substringAfter('@').tolowercase())){
                        caseListToUpdateContactAccount.add(caseInstance);
                    }
                    else{
                       /* BIBHU Changes Revoke - **/
                       CTX_RectifyCaseAccountMapping.actualDomainCheck(caseInstance); 
                        if(CTX_RectifyCaseAccountMapping.sendBounceEmail){
                           ID jobID = System.enqueueJob(new SendBounceNotificationQueueable(caseOrig));
                           System.debug('jobID'+jobID);
                            //CTX_RectifyCaseAccountMapping.sendBounceNotification(caseInstance);
                            //caseOrig.addError('This mail does not contains actual customer communication email !');
                            system.debug('This mail does not contains actual customer communication email !');
                            //caseInstance.Country_Of_Origin__c  = 'Stop Execution!';
                        }
                    }
                   // }
                    emailSet.add(caseInstance.SuppliedEmail);
                    
                }
                //added so the additional cases are not creted : 14 dec 2021
                if(caseInstance.Subject != '' && (caseInstance.Subject.contains('Were we helpful on Case')||
                                                  caseInstance.Subject.startsWithIgnoreCase('Received case #')) ){
                                                      listOfCasesToNotToInsert.add(caseInstance); 
                                                  }
                //added for sending warning mails distribution list
                if(caseInstance.OwnerId !=null){
                    queueIds.add(caseInstance.OwnerId);
                }
                //added for sending auto ack to cases created by web :12 april 2022
                if((caseInstance.Origin=='Web' || caseInstance.Origin=='Internal Web Form') && caseInstance.Case_Sub_Origin__c!=null  && caseInstance.SuppliedEmail!=null  && !caseInstance.Disable_Email_Communication__c){	// Might Remove Internal Web Form
                    mapOfWebCasesTosendAutoACK.put(caseInstance.id,caseInstance);
                    mapOfRelatedContactEmails.put(caseInstance.id,caseInstance.SuppliedEmail);
                    
                }
                finalListToUpdate.add(caseInstance);
                
                
            }
        }
        if(finalListToUpdate.Size() > 0){
            system.debug('owner$%$%^'+finalListToUpdate[0].ownerId);
            Update(finalListToUpdate);
           
        }
        
        //added for sending warning mails distribution list :15 dec 2021
        if(!caseListToUpdateContactAccount.isEmpty()){
            CaseTriggerHelper.updateAccountAndContactonCase(emailSet, caseListToUpdateContactAccount,queueIds);
        }
        
        if(!autoResponseCaseMap.isEmpty()){
            //CaseTriggerHelper.autoRespondManualCases(autoResponseCaseMap);
        }
        //added so the additional cases are not creted : 14 dec 2021
        
        if(!listOfCasesToNotToInsert.isEmpty()){
            CaseTriggerHelper.doNotInsertCases(listOfCasesToNotToInsert);
        }
        /**  if(CTX_checkRecursive.isFirstTimeUpadteCaseOwner){
CTX_CaseTriggerHelper.handleOwnerchangeBasedonKeyword(mapOfNewSObjects,null); 
CTX_checkRecursive.isFirstTimeUpadteCaseOwner=false;
}**/
        
        if(mapOfWebCasesTosendAutoACK.size()>0){
            CaseTriggerHelper.autoRespondForWeb(mapOfWebCasesTosendAutoACK,mapOfRelatedContactEmails);
        }
    
        
        
        
    }
    
    public static void beforeUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
        
        List<Case> listCaseWhereStatusIsPending=new List<Case>();
        Map<Id,Case> mapOfOldCaseWhereStatusIsPending=new Map<Id,Case>();
        Map<Id,Case> mapOfNewCasesWithOwnerIds=new Map<Id,Case>();
        Map<Id,Case> mapOfOldCasesWithOwnerIds=new Map<Id,Case>();
        List<Case> listOfNewSolvedCasesToUpdateCaseSolvedDateTime=new List<Case>();
        List<Case> listOfCasesToUpdateIssueTypes=new List<Case>();
        Map<String,Case> mapOfCasesToUpdateQueueId=new Map<String,Case>();
        //List<Case> listOfCasesToUpdateQueueId=new List<Case>();
        List<Case> listOfEInvoicingCasesToUpdateP1=new List<Case>();
        List<Case> listOfCaseOwnerIsCaseReOpenedTrue=new List<Case>();
        List<Case> listOfCasesToUpdateTheStatusASTransfer=new List<Case>();
        List<Case> listOfCasesToSyncTheStatus=new List<Case>();
        set<id> setOfcaseIdToupdateCustomerWaitTime= new set<id>();
        Set<Id> userOwnerIds = new Set<Id>();
        Set<Id> queueIds = new Set<Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, Case> queueCaseMap = new Map<Id, Case>();
        Set<Id> IssueTypeIdSet = new Set<Id>();
        Map<Id, Boolean> productUICaseMap = new Map<Id, Boolean>();
        Map<Id, Integer> productAttachmentCount = new Map<Id, Integer>();
        
        //To get the count of Email messages
        Set<String> contactEmailList = new Set<String>();
        List<AggregateResult> userEmailList = new List<AggregateResult>([SELECT  Email FROM  user WHERE Department  = 'KAM' OR Department  = 'CSM' OR Department Like '%customer%' GROUP BY Email ORDER BY email]);
        List<String> KAMCSMEmailList = JSON.Serialize(userEmailList).removeStart('[').removeEnd(']').remove('{"attributes":{"type":"AggregateResult"},').remove('}').remove('Email').remove('"').remove(':').replaceAll( '\\s+', '').Split(','); //To form list of strings only with email
        
        system.debug('TestEmail%&^& '+KAMCSMEmailList);
        List<String> excludedEmailList = Label.First_touch_resolution_exclusion_email.Split(',');
        
        for(Id key:mapOfNewSObjects.KeySet()){
            Case newCaseInstance=(Case)mapOfNewSObjects.get(key);
            Case oldCaseInstance=(Case)mapOfOldSObjects.get(key);
            
            Date threshHoldDate = Date.newInstance(2024, 3, 13);
            Date createdDate = Date.newInstance(
                newCaseInstance.CreatedDate.Year(), 
                newCaseInstance.CreatedDate.Month(), 
                newCaseInstance.CreatedDate.Day()
            );
            
            if( 
                newCaseInstance.Origin != NULL && 
                newCaseInstance.Origin == 'Product UI' && 
                newCaseInstance.Product_Unique_Identifier__c != NULL && 
                newCaseInstance.Pre_Signed_Attachment_URL__c != NULL && 
                createdDate >= threshHoldDate
            ){
                system.debug('Inside Debug Check ');
                Integer tempFileCount = newCaseInstance.Pre_Signed_Attachment_URL__c.countMatches('https://storage.clear.in');
                productUICaseMap.put(newCaseInstance.Id, TRUE);
                productAttachmentCount.put( newCaseInstance.Id, tempFileCount);
            }

            /** SLA Logic Change START    **/
            Integer day = (newCaseInstance.CreatedDate == NULL) ? system.today().day() : newCaseInstance.CreatedDate.day();
        
        if( newCaseInstance.RecordTypeId == CaseConstants.B2B_RecordTypeId && CaseConstants.FILLINGDAYSMAP_GST_MAXITC.contains(day) ){
            newCaseInstance.put('BusinessHoursId', system.label.Business_Hours_GST_Filling);
        }
        
        /*if(newCaseInstance.RecordTypeId == '012C50000004Kp4IAE' && CaseConstants.FILLINGDAYSMAP_CA_SME.contains(day) ){
            newCaseInstance.put('BusinessHoursId', system.label.Business_Hours_CA_SME_Filling);
        }*/
/** SLA Logic Change End    **/

            if(newCaseInstance.Comments != oldCaseInstance.Comments){
                newCaseInstance.Is_Internal_Comment_Created__c = TRUE;
            }
              if( newCaseInstance.RecordTypeId == CaseConstants.INT_SUPPORT_RecordTypeId && newCaseInstance.Type == 'Bug'){
                     newCaseInstance.Priority = 'P0';
                }
            /*if(newCaseInstance.User_Role_Type__c != oldCaseInstance.User_Role_Type__c){
                newCaseInstance.JIRA_Issue_Id__c 				= NULL;
                newCaseInstance.Updated_in_JIRA__c 				= FALSE;
                newCaseInstance.Planned_Release_Date_JIRA__c	= NULL;
                newCaseInstance.Actual_Release_Date_JIRA__c		= NULL;
                newCaseInstance.QA_Release_Date_JIRA__c			= NULL;
                newCaseInstance.Developer_Comment_JIRA__c		= NULL; 
                newCaseInstance.Status_JIRA__c 					= NULL;
            }*/
              if(newCaseInstance.Products_Available__c == 'IRP'){
                   newCaseInstance.recordTypeId = CaseConstants.IRP_RecordTypeId;
                  newCaseInstance.User_Role_Type__c = 'IRP L2';
                }
           if( newCaseInstance.User_Role_Type__c != NULL ){
                newCaseInstance.recordTypeId = 
                    newCaseInstance.User_Role_Type__c.Contains('Capture') ?
                    CaseConstants.CLEAR_CAPTURE_RecordTypeId :
                ( 
                    newCaseInstance.User_Role_Type__c.Contains('Clear Invoice') || newCaseInstance.User_Role_Type__c.Contains('Invoicing') ? 
                    CaseConstants.CLEAR_INVOICE_RecordTypeId :
                    ( 
                        newCaseInstance.User_Role_Type__c.Contains('MaxITC') || newCaseInstance.User_Role_Type__c.Contains('MITC') ?
                        CaseConstants.MAX_ITC_RecordTypeId :
                        (
                            newCaseInstance.User_Role_Type__c.Contains('Capture') ?
                            CaseConstants.CLEAR_CAPTURE_RecordTypeId :
                            (
                                System.Label.Integration_Support_Queue.contains(newCaseInstance.User_Role_Type__c)?
                                CaseConstants.INT_SUPPORT_RecordTypeId :
                                (
                                    newCaseInstance.User_Role_Type__c.Contains('TDS') ?
                                    CaseConstants.TDS_RecordTypeId :
                                    (
                                        newCaseInstance.User_Role_Type__c.Contains('Clear Identity') ?
                                     	CaseConstants.CLEAR_IDENTITY_RecordTypeId :
                                        (
                                            newCaseInstance.User_Role_Type__c.Contains('IRP')  ?
                                            CaseConstants.IRP_RecordTypeId :
                                            (
                                                newCaseInstance.User_Role_Type__c.Contains('E-Inv/EWB') ?
                                                CaseConstants.E_INVOICING_RecordTypeId :
                                                (
                                                    newCaseInstance.User_Role_Type__c.Contains('Invoice Discounting') ?
                                                    CaseConstants.ID_RecordTypeId :
                                                    (
                                                        newCaseInstance.User_Role_Type__c.Contains('GCC') ?
                                                        CaseConstants.GCC_RecordTypeId :
                                                        newCaseInstance.recordTypeId
                                                    )
                                                    
                                                )
                                                
                                            )
                                        )
                                     	
                                    )
                                )
                            )
                        )
                    )
                );
                   
                    
                    
                    newCaseInstance.Product_Route_Type__c = 
                    newCaseInstance.User_Role_Type__c.Contains('Capture') ?
                    'Clear Capture' :
                ( 
                    newCaseInstance.User_Role_Type__c.Contains('Clear Invoice') || newCaseInstance.User_Role_Type__c.Contains('Invoicing')  ?
                    'Clear Invoice' :
                    ( 
                        newCaseInstance.User_Role_Type__c.Contains('MaxITC') || newCaseInstance.User_Role_Type__c.Contains('MITC') ?
                        'MaxITC' :
                        newCaseInstance.Product_Route_Type__c
                    )
                );
                    }
            
            if(newCaseInstance.ContactEmail != NULL){
                contactEmailList.add(newCaseInstance.ContactEmail);
            }
            //Added for issuetype population from the issuetype record
            if(newCaseInstance.Lookup_Issue_Type__c != NULL){
                IssueTypeIdSet.add(newCaseInstance.Lookup_Issue_Type__c);
            }
            else if(newCaseInstance.Lookup_Issue_Type1__c != NULL){
                IssueTypeIdSet.add(newCaseInstance.Lookup_Issue_Type1__c );
            }
            else if(newCaseInstance.Lookup_Issue_Type_EInv__c != NULL){
                IssueTypeIdSet.add(newCaseInstance.Lookup_Issue_Type_EInv__c );
            } 
        }
        
        system.debug('productAttachmentCount: '+productAttachmentCount);
        system.debug('productAttachmentCount Key Set : '+productAttachmentCount.keySet());
        
        Set<Id> productUIcasesWithoutAttachment = new Set<Id>();
        Map<Id, Integer> mapOfAttachmentCountById = new Map<Id, Integer>();
        
        if(productUICaseMap.keySet().size() > 0 ){
            
            for( 
                ContentDocumentLink thisRec : [ SELECT Id, LinkedEntityId
                                                FROM ContentDocumentLink WHERE 
                                                LinkedEntityId IN :productUICaseMap.keySet() 
                                               ORDER BY LinkedEntityId ] 
               ){
                   
                   if( mapOfAttachmentCountById.containsKey(thisRec.LinkedEntityId) ){
                       
                       Integer count = mapOfAttachmentCountById.get(thisRec.LinkedEntityId) + 1;
                       mapOfAttachmentCountById.put( thisRec.LinkedEntityId, count );
                       //productUICaseMap.put(thisRec.LinkedEntityId, FALSE);
                   } else{
                       mapOfAttachmentCountById.put( thisRec.LinkedEntityId, 1 );
                   }
               }
        
        
        system.debug('mapOfAttachmentCountById: '+mapOfAttachmentCountById);
        
        for( Id thisId : productUICaseMap.keySet() ){
            if( mapOfAttachmentCountById.containsKey(thisId) ){
                if( productAttachmentCount.get(thisId) <= mapOfAttachmentCountById.get(thisId) ){
                    system.debug('Count MisMatch Hua');
                    productUICaseMap.put(thisId, FALSE);
                }
            }
        }

    }
        
        
        Map<Id, Issue_Type__c> caseIdIssueTypeMap = new Map<Id, Issue_Type__c>(
            [SELECT id,priority__c FROM Issue_type__c WHERE Id IN : IssueTypeIdSet AND priority__c != '']
        );
        //Added for issuetype population from the issuetype record
        List<EmailMessage> emailMessageList = [SELECT id,fromAddress FROM EmailMessage WHERE parentId in: mapOfNewSObjects.keySet() AND  fromAddress NOT IN : KAMCSMEmailList AND fromAddress NOT IN : contactEmailList AND fromAddress NOT IN : excludedEmailList];
        System.debug('Test$%^^$'+emailMessageList);   
        Map<Id,AggregateResult> caseEmailMap = new Map<Id,AggregateResult>([SELECT parentId Id, Count(Id) countId FROM EmailMessage WHERE parentId in: mapOfNewSObjects.keySet() AND Id IN : emailMessageList GROUP BY parentId]);
        system.debug('caseEmailMap%^%^'+ caseEmailMap);
        //Filter logic to get all the case 
        if(!mapOfNewSObjects.isEmpty() && !mapOfOldSObjects.isEmpty()){
            for(Id key:mapOfNewSObjects.KeySet()){
                if(mapOfNewSObjects.containsKey(key) && mapOfOldSObjects.containsKey(key)){
                    Case newCaseInstance=(Case)mapOfNewSObjects.get(key);
                    Case oldCaseInstance=(Case)mapOfOldSObjects.get(key);
                    
                    
                    
                    if(
                        productUICaseMap.containsKey(newCaseInstance.Id) && 
                        productUICaseMap.get(newCaseInstance.Id) 
                    ){
                        newCaseInstance.addError('Please Download the Attachment file and Upload it to Salesforce.');
                    }
                    newCaseInstance.First_touch_resolution_count__c = Integer.valueOf(caseEmailMap?.get(key)?.get('countId')) ;
                    
                    if(newCaseInstance.Status!=oldCaseInstance.Status){	
                        listOfCasesToSyncTheStatus.add(newCaseInstance);	
                    }
                    if(!caseIdIssueTypeMap.isEmpty()){
                        if( caseIdIssueTypeMap.containsKey(newCaseInstance.Lookup_Issue_Type__c) ){
                            newCaseInstance.Priority = caseIdIssueTypeMap.get(newCaseInstance.Lookup_Issue_Type__c).Priority__c;
                        }
                        else if(caseIdIssueTypeMap.containsKey(newCaseInstance.Lookup_Issue_Type1__c) ){
                            newCaseInstance.Priority = caseIdIssueTypeMap.get(newCaseInstance.Lookup_Issue_Type1__c).Priority__c;
                        }
                        else if(caseIdIssueTypeMap.containsKey(newCaseInstance.Lookup_Issue_Type_EInv__c) ){
                            newCaseInstance.Priority = caseIdIssueTypeMap.get(newCaseInstance.Lookup_Issue_Type_EInv__c).Priority__c;
                        }
                    }
                    if(oldCaseInstance.RecordTypeId!=newCaseInstance.RecordTypeId && newCaseInstance.RecordTypeId==new CaseSelector().getCaseRecordTypeIdByName(CaseConstants.Case_RECORDTYPENAME_E_INVOICING)){
                        system.debug('*****In transfer');
                        listOfEInvoicingCasesToUpdateP1.add(newCaseInstance);
                    }
                    system.debug('Here:'+newCaseInstance.Status+newCaseInstance.Sub_Status__c);
                    system.debug('Here1:'+caseConstants.emailSubStatus+caseConstants.emailSubStatus);
                    if(
                        (
                            oldCaseInstance.Status != newCaseInstance.Status || oldCaseInstance.Sub_Status__c != newCaseInstance.Sub_Status__c || CaseConstants.constantEmailPending
                        )
                        && 
                        (
                            (newCaseInstance.Status== CaseConstants.STATUS_PENDING || caseConstants.emailStatus== CaseConstants.STATUS_PENDING) && (
                                (
                                    newCaseInstance.Sub_Status__c==CaseConstants.SUB_STATUS_WITH_CUSTOMER_FOR_SOL_VER || newCaseInstance.Sub_Status__c==CaseConstants.SUB_STATUS_WITH_CUSTOMER_FOR_PRO_CLAR || newCaseInstance.Sub_Status__c=='With Vendor' || newCaseInstance.Sub_Status__c=='With Govt Dept'
                                    || newCaseInstance.Sub_Status__c==CaseConstants.SUB_STATUS_INVOICE_COPY_REQUESTS || newCaseInstance.Sub_Status__c==CaseConstants.SUB_STATUS_REFUND_REQUESTS
                                )
                                ||
                                (
                                    caseConstants.emailSubStatus==CaseConstants.SUB_STATUS_WITH_CUSTOMER_FOR_SOL_VER || caseConstants.emailSubStatus==CaseConstants.SUB_STATUS_WITH_CUSTOMER_FOR_PRO_CLAR || caseConstants.emailSubStatus=='With Vendor' || caseConstants.emailSubStatus=='With Govt Dept'
                                )
                            )
                        )
                    ){
                        listCaseWhereStatusIsPending.add(newCaseInstance);
                        mapOfOldCaseWhereStatusIsPending.put(oldCaseInstance.Id,oldCaseInstance);
                    }
                    
                    if((newCaseInstance.OwnerId!=null && oldCaseInstance.OwnerId != newCaseInstance.OwnerId) || newCaseInstance.Priority != oldCaseInstance.Priority){
                        mapOfNewCasesWithOwnerIds.put(newCaseInstance.Id,newCaseInstance);
                        mapOfOldCasesWithOwnerIds.put(oldCaseInstance.Id,oldCaseInstance);
                        if(newCaseInstance.OwnerId.getSObjectType() != User.SObjectType || newCaseInstance.Priority != oldCaseInstance.Priority){
                            queueIds.add(newCaseInstance.OwnerId);
                            queueCaseMap.put(newCaseInstance.Id, newCaseInstance);
                        }
                    }
                    
                    if(!String.isEmpty(newCaseInstance.User_Role_Type__c)){
                        if(newCaseInstance.OwnerId.getSObjectType() == User.SObjectType){
                            userOwnerIds.add(newCaseInstance.OwnerId);
                            caseMap.put(newCaseInstance.Id, newCaseInstance);
                        }
                    }
                    
                    if(oldCaseInstance.Status != newCaseInstance.Status && (newCaseInstance.Status== CaseConstants.STATUS_SOLVED) ){
                        listOfNewSolvedCasesToUpdateCaseSolvedDateTime.add(newCaseInstance);
                    }
                    
                    if(((oldCaseInstance.Lookup_Issue_Type__c != newCaseInstance.Lookup_Issue_Type__c || oldCaseInstance.Lookup_Issue_Type1__c != newCaseInstance.Lookup_Issue_Type1__c || oldCaseInstance.Lookup_Issue_Type_EInv__c != newCaseInstance.Lookup_Issue_Type_EInv__c) && (newCaseInstance.Lookup_Issue_Type__c!=null || newCaseInstance.Lookup_Issue_Type1__c!=null || newCaseInstance.Lookup_Issue_Type_EInv__c!=null)) || newCaseInstance.RecordTypeId !=oldCaseInstance.RecordTypeId){ // Enhanced by lokesh 21 jan
                        listOfCasesToUpdateIssueTypes.add(newCaseInstance);
                    }
                    
                    if(newCaseInstance.OwnerId!=oldCaseInstance.OwnerId && newCaseInstance.IsCaseReopened__c && String.valueOf(newCaseInstance.OwnerId).startsWithIgnoreCase(User.sobjecttype.getDescribe().getKeyPrefix()) && !String.valueOf(oldCaseInstance.OwnerId).startsWithIgnoreCase(User.sobjecttype.getDescribe().getKeyPrefix()) ){
                        listOfCaseOwnerIsCaseReOpenedTrue.add(newCaseInstance);
                    }
                    
                    if(newCaseInstance.OwnerId!=oldCaseInstance.OwnerId){
                        Id  oldQueueId=null;
                        Id  newQueueId=null;
                        
                        if(!String.ValueOf(oldCaseInstance.OwnerId)?.startsWithIgnoreCase('005'))
                            oldQueueId=  oldCaseInstance.OwnerId;
                        if(!String.ValueOf(newCaseInstance.OwnerId)?.startsWithIgnoreCase('005'))
                            newQueueId= newCaseInstance.OwnerId ;
                        
                        if(oldQueueId!=null ) {
                            if(!String.ValueOf(oldQueueId)?.startsWithIgnoreCase('005')){
                                newCaseInstance.Previous_Queue_Id__c  = oldQueueId;
                            }
                        }
                        else if(newQueueId!=null){
                            if(!String.ValueOf(newQueueId)?.startsWithIgnoreCase('005')){
                                newCaseInstance.Previous_Queue_Id__c  = newQueueId;
                            }
                        }
                    }
                    
                    if(newCaseInstance.OwnerId!=oldCaseInstance.OwnerId &&  !String.valueOf(newCaseInstance.OwnerId).startsWithIgnoreCase(User.sobjecttype.getDescribe().getKeyPrefix()) 
                       && newCaseInstance.Status!=CaseConstants.Status_TRANSFER){
                           listOfCasesToUpdateTheStatusASTransfer.add(newCaseInstance);
                       }
                    if(newCaseInstance.Type != 'Incident of problem' && newCaseInstance.Type != 'Duplicate'){
                        newCaseInstance.ParentId=null;
                    }
                    if(newCaseInstance.OwnerId.getSObjectType() != User.SObjectType && newCaseInstance.Status=='Open'){
                        newCaseInstance.Status='Transfer';
                    }
                   if(newCaseInstance.Status==CaseConstants.STATUS_CLOSED  && newCaseInstance.Status != oldCaseInstance.Status){
                        setOfcaseIdToupdateCustomerWaitTime.add(newCaseInstance.Id);
                        if(!caseConstants.completionCheck){
                            //newCaseInstance.Status = 'Solved';
                            caseConstants.closedCheck = TRUE;
                        }
                    }
                     if(newCaseInstance.RecordTypeId == CaseConstants.B2B_RecordTypeId 	&&
                        newCaseInstance.Type != oldCaseInstance.Type 					&&
                        newCaseInstance.Type =='Duplicate'){
                        newCaseInstance.IsStopped = TRUE;
                    }
                    
                }
            }
        }
        
        if(listOfCasesToSyncTheStatus.size()>0){	
            CaseTriggerHelper.SyncTheStatusWithBackStatus(listOfCasesToSyncTheStatus);	
        }
        
        if(listOfEInvoicingCasesToUpdateP1.size()>0){
            CaseTriggerHelper.eInvoicePriorityToP1(listOfEInvoicingCasesToUpdateP1);
        }
        
        if(listOfCasesToUpdateTheStatusASTransfer.size()>0 && !Constants.stopCaseTrigger){
            CaseTriggerHelper.updateStatusAsTransfer(listOfCasesToUpdateTheStatusASTransfer);
        }
        
        if(listOfCaseOwnerIsCaseReOpenedTrue.size()>0){
            CaseTriggerHelper.updateCaseStatusToReopenFromTransferOnQueueToUser(listOfCaseOwnerIsCaseReOpenedTrue);
        }
        
        if(listCaseWhereStatusIsPending.size()>0){
            CaseTriggerHelper.pauseAndUnPauseMilestone(listCaseWhereStatusIsPending,mapOfOldCaseWhereStatusIsPending);
        }
        
        if(!mapOfNewCasesWithOwnerIds.isEmpty() && !mapOfOldCasesWithOwnerIds.isEmpty()){
            CaseTriggerHelper.updatePreviousOwnerId(mapOfNewCasesWithOwnerIds,mapOfOldCasesWithOwnerIds); 
        }
        
        if(listOfNewSolvedCasesToUpdateCaseSolvedDateTime.size()>0){
            CaseTriggerHelper.updateCaseSolvedDatTime(listOfNewSolvedCasesToUpdateCaseSolvedDateTime);
        }
        if(listOfCasesToUpdateIssueTypes.size()>0){
            CaseTriggerHelper.tagIssueToCases(listOfCasesToUpdateIssueTypes);
        }
        
        if(!userOwnerIds.isEmpty()){
            CaseTriggerHelper.validateUserRoletype(caseMap, userOwnerIds);
        }
        
        /** if(!queueCaseMap.isEmpty()){
CaseTriggerHelper.updateUserRoleType(queueCaseMap, queueIds, (Map<Id,Case>)mapOfOldSObjects);
}**/
        
        if(!setOfcaseIdToupdateCustomerWaitTime.isEmpty()){
            CaseTriggerHelper.BeforeStopCustomerWaitTimeWhenCaseClosed(setOfcaseIdToupdateCustomerWaitTime);
        }
        
    }
    
    public static void afterUpdate(Map<Id,SObject> mapOfNewSObjects,Map<Id,SObject> mapOfOldSObjects){
        system.debug('inside after update');
        CaseConstants.isFirstTimeCase = False;
        List<Case> listOfCasesToParent=new List<Case>();
        List<Case> listOfNewCases=new List<Case>();
        Map<Id,Case> mapOfOldCases=new  Map<Id,Case>();
        List<Case> listOfCasesToSolveFromPending=new List<Case>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<Case> caseOpenListToUpdate = new List<Case>();
        List<Case> casePODBlankListToUpdate = new List<Case>();
        map<id,case> mapOfCaseIDToCase = new map<id,case>();
        set<id> setOfUsers=new set<id>();
        set<id> setOfcaseIdToupdateFRTMilestone        = new set<id>();
        set<id> setOfcaseIdToPeriodicupdateFRTMilestone= new set<id>();
        set<id> setOfcaseIdToupdateCustomerWaitTime    = new set<id>();
        Map<String,list<case>> mapOfAccIdToCaseId      = new Map<String,list<case>>();
        Map<Id, Case> caseMapForUdpatingCC             = new Map<Id, Case>();
        Map<Id,Case> mapOfMergedChildCases             = new Map<Id,Case>();
        set<Id> listOfMasterCases                      = new set<id>();
        List<case> updateRTAndEntitlementList          = new List<case>();
        List<case> updateCaseOnUiList                  = new List<case>();//added by 
        List<Id> caseIdsToSendEmailAlert				= new List<Id>();
        
        Map<Id, Account> accountMap = new Map<Id, Account>();
        set<Id> accountId = new set<Id>();
        for( Case newCase : (List<Case>)mapOfNewSObjects.values() ){
            if( newCase.AccountId != NULL )
          //  accountMap.put( newCase.AccountId, NULL );
          accountId.add(newCase.AccountId);
        }
        
        for( 
            Account thisAcc : [ SELECT Id, Onboarding_Owner__r.Email 
                               FROM Account WHERE 
                               Id IN :accountId ] 
        ){
            if( thisAcc.Onboarding_Owner__r.Email != NULL )
            accountMap.put( thisAcc.Id, thisAcc );
        }
        system.debug('accountId'+accountId);
        system.debug('accountMap data'+accountMap);
        for(Id key:mapOfNewSObjects.keySet()){
            Case caseNewInstance=(Case)mapOfNewSObjects.get(key);
            Case  caseInstance = caseNewInstance.clone(FALSE,FALSE,FALSE,FALSE);
            caseInstance.put('Id', caseNewInstance.Id);
            Case caseOldInstance=(Case)mapOfOldSObjects.get(key);
            
                
            // added by murali start
            if( 
                caseNewInstance.Status != caseOldInstance.Status && 
                caseNewInstance.Product_Unique_Identifier__c != NULL 
            ){
                updateCaseOnUiList.add(caseNewInstance);
            }
            system.debug('support caseNewInstance.Status'+caseNewInstance.Status);
            system.debug('support caseOldInstance.Status'+caseOldInstance.Status);
            system.debug('support caseNewInstance.Product_Unique_Identifier__c'+caseNewInstance.Product_Unique_Identifier__c);
            system.debug('support updateCaseOnUiList'+updateCaseOnUiList.size());
            // added by murali end
            
            if((caseNewInstance.Status!= caseOldInstance.Status || caseNewInstance.Sub_Status__c != caseOldInstance.Sub_Status__c ||
                caseNewInstance.Lookup_Issue_Type__c != caseOldInstance.Lookup_Issue_Type__c || caseNewInstance.Lookup_Issue_Type1__c != caseOldInstance.Lookup_Issue_Type1__c ||
                caseNewInstance.Lookup_Issue_Type_EInv__c != caseOldInstance.Lookup_Issue_Type_EInv__c) && caseNewInstance.Type==CaseConstants.TYPE_PROBLEM){
                    listOfCasesToParent.add(caseNewInstance);
                }
            if(caseNewInstance.OwnerId != caseOldInstance.OwnerId){
                list<string> listOfDevOnCallQueueId= System.Label.Case_Dev_on_cal_QueueID.split(',');
                if(!listOfDevOnCallQueueId.isEmpty() && !listOfDevOnCallQueueId.contains(caseNewInstance.OwnerId) ){
                    Case cs              = new case();
                    cs.Id                = key;
                    //cs.ownerId           = caseNewInstance.ownerId;
                    //cs.RecordTypeId      = caseNewInstance.RecordTypeId;
                    //cs.EntitlementId     = caseNewInstance.EntitlementId;
                    //cs.User_Role_Type__c = caseNewInstance.User_Role_Type__c;
                    cs.POD_Group__c      ='';
                    casePODBlankListToUpdate.add(cs);
                }
                
                listOfNewCases.add(caseNewInstance);
                mapOfOldCases.put(caseOldInstance.Id,caseOldInstance);
                system.debug('caseOldInstance----->'+caseOldInstance);
                system.debug('caseNewInstance.OwnerId----->'+caseNewInstance.OwnerId);
                system.debug('caseNewInstance'+caseNewInstance);
                system.debug('CaseConstants.Status_TRANSFER'+CaseConstants.Status_TRANSFER);
                
                if(caseOldInstance.Status==CaseConstants.Status_TRANSFER && (String.valueOf(caseNewInstance.OwnerId).startsWith('005') 
                                                                             || (caseNewInstance.Previous_Owner__c != NULL ? String.valueOf(caseNewInstance.Previous_Owner__c) : '')?.startsWith('005')) && !caseNewInstance.Solved__c){
                                                                                 Case cs = new Case();
                                                                                 cs.Id = key;
                                                                                 cs.Status = CaseConstants.Status_OPEN;
                                                                                 cs.Sub_Status__c = null;
                                                                                 caseOpenListToUpdate.add(cs);
                                                                             }
                system.debug('caseOpenListToUpdate'+caseOpenListToUpdate);
            }
            if(caseNewInstance.Status!=caseOldInstance.Status && (caseOldInstance.Status==CaseConstants.STATUS_PENDING && (caseOldInstance.Sub_Status__c==CaseConstants.SUB_STATUS_WITH_CUSTOMER_FOR_SOL_VER || caseOldInstance.Sub_Status__c==CaseConstants.SUB_STATUS_WITH_CUSTOMER_FOR_PRO_CLAR)) && caseNewInstance.Status==CaseConstants.STATUS_SOLVED ){
                system.debug('Inside isStopped = '+caseNewInstance.IsStopped);
                Case caseInstanceToUpdate=new Case();
                caseInstanceToUpdate.id=caseNewInstance.id;
                caseInstanceToUpdate.IsStopped=false;
                listOfCasesToSolveFromPending.add(caseInstanceToUpdate);
            }
            system.debug('caseNewInstance.Priority@#'+caseNewInstance.Priority);
            system.debug('caseOldInstance.Priority@#'+caseOldInstance.Priority);
            if(caseNewInstance.Status==CaseConstants.STATUS_SOLVED  && caseNewInstance.Status != caseOldInstance.Status){
                system.debug('**Inside Solved '+caseNewInstance.IsStopped);
                setOfcaseIdToPeriodicupdateFRTMilestone.add(caseNewInstance.Id);
                //caseNewInstance = CaseTriggerHelper.StopCustomerWaitTimeWhenCaseSolved1(caseNewInstance);
            }
            
            if(((!String.isEmpty(caseNewInstance.User_Role_Type__c) && caseNewInstance.User_Role_Type__c != caseOldInstance.User_Role_Type__c) || (!String.isEmpty(caseNewInstance.Priority) && caseNewInstance.Priority != caseOldInstance.Priority)) || caseNewInstance.EntitlementId == NULL) {
                caseInstance = caseTriggerhelper.updateRTAndEntitlement(caseInstance);
                updateRTAndEntitlementList.add(caseInstance);
            }
            
            if((caseNewInstance.Status=='Reopen' || (caseNewInstance.Status=='Open' && caseOldInstance.Status == 'Pending')) && caseNewInstance.Status!=caseOldInstance.Status && caseNewInstance.OwnerId.getSObjectType() == User.SObjectType && caseNewInstance.RecordTypeId == Constants.eInvoicingRTId){
                system.debug('**Inside ReopenCheck');
                setOfUsers.add(caseNewInstance.OwnerId);
                mapOfCaseIDToCase.put(key,caseNewInstance);
            }
            if(caseNewInstance.First_Reply_Sent__c==true  && caseNewInstance.First_Reply_Sent__c != caseOldInstance.First_Reply_Sent__c){
                setOfcaseIdToupdateFRTMilestone.add(caseNewInstance.Id);
            }
            if((caseNewInstance.Status==CaseConstants.STATUS_CLOSED  && caseNewInstance.Status != caseOldInstance.Status) || CaseConstants.closedCheck){
                setOfcaseIdToupdateCustomerWaitTime.add(caseNewInstance.Id);
            }
            if(caseNewInstance.AccountId!=null && caseNewInstance.AccountId!=caseOldInstance.AccountId){   //@Sunil
                if(mapOfAccIdToCaseId.containsKey(caseNewInstance.AccountId)){
                    mapOfAccIdToCaseId.get(caseNewInstance.AccountId).add(caseNewInstance);
                }else{
                    mapOfAccIdToCaseId.put(caseNewInstance.AccountId, new list<case>{caseNewInstance});
                }
                
                
            }
            system.debug('caseNewInstance.CCEmailAddress__c'+caseNewInstance.CCEmailAddress__c);
            system.debug('caseOldInstance.CCEmailAddress__c'+caseOldInstance.CCEmailAddress__c);
            system.debug('caseOldInstance.Auto_Response_Sent_To_CC__c'+caseNewInstance.Auto_Response_Sent_To_CC__c);
            system.debug('caseOldInstance.Disable_Email_Communication__c'+caseNewInstance.Disable_Email_Communication__c);
            system.debug('check'+(caseNewInstance.CCEmailAddress__c !=null && caseNewInstance.CCEmailAddress__c!=caseOldInstance.CCEmailAddress__c &&  caseNewInstance.Auto_Response_Sent_To_CC__c  == false && !caseNewInstance.Disable_Email_Communication__c ));
                   
            if(caseNewInstance.CCEmailAddress__c !=null && caseNewInstance.CCEmailAddress__c!=caseOldInstance.CCEmailAddress__c 
               &&  caseNewInstance.Auto_Response_Sent_To_CC__c  == false && !caseNewInstance.Disable_Email_Communication__c ){	
                   caseMapForUdpatingCC.put(caseNewInstance.Id, caseNewInstance);  	
               }
            
            if(caseNewInstance.MasterRecordId !=null && caseNewInstance.MasterRecordId!=caseOldInstance.MasterRecordId  ){	
                mapOfMergedChildCases.put(caseNewInstance.Id, caseNewInstance);
                listOfMasterCases.add(caseNewInstance.MasterRecordId);
            }
        }
        
        //added by murali
        if(updateCaseOnUiList.size()>0){
            system.debug('Check Queuable');
            
            if( system.label.Support_API_Enablement == 'YES' ){
                Id jobID = System.enqueueJob( new CTX_UpsertCaseDetails(updateCaseOnUiList) );
            }
        }
        
        if(listOfCasesToSolveFromPending.size()>0){
            system.debug('Inside listOfCasesToSolveFromPending updating');
            update listOfCasesToSolveFromPending;
        }
        
        if(listOfCasesToParent.size()>0){
            CaseTriggerHelper.manageProblemAndIncident(listOfCasesToParent); 
        }
        
        if(updateRTAndEntitlementList.Size() > 0){
            system.debug('updateRTAndEntitlementList'+ updateRTAndEntitlementList);
            Update(updateRTAndEntitlementList);
        }
        if(listOfNewCases.size()>0 && !mapOfOldCases.isEmpty()){
            CaseTriggerHelper.createCaseTeamMemberOnOwnerChange(listOfNewCases, mapOfOldCases);
        }
        
        
        if(!caseOpenListToUpdate.isEmpty()){
            update caseOpenListToUpdate;
        }
        if(!casePODBlankListToUpdate.isEmpty()){
            update casePODBlankListToUpdate;
        }
        
        if(!setOfUsers.isEmpty()){
            CaseTriggerHelper.checkUserIsAwayWhenCaseReopened(setOfUsers,mapOfCaseIDToCase);
        }
        
        if(!setOfcaseIdToupdateFRTMilestone.isEmpty()){
            CaseTriggerHelper.CompleteFRTMilestone(setOfcaseIdToupdateFRTMilestone);
        }
        
        if(!setOfcaseIdToPeriodicupdateFRTMilestone.isEmpty()){
            system.debug('setOfcaseIdToPeriodicupdateFRTMilestone');
            
            CaseTriggerHelper.CompletePeriodicUpdateMilestone(setOfcaseIdToPeriodicupdateFRTMilestone);
            CaseTriggerHelper.StopCustomerWaitTimeWhenCaseSolved(setOfcaseIdToPeriodicupdateFRTMilestone);
            //system.debug('solve isStopped' +[select id, isStopped from case where id=:setOfcaseIdToPeriodicupdateFRTMilestone]);
        }
        
        if(!setOfcaseIdToupdateCustomerWaitTime.isEmpty() && !CaseConstants.completionCheck){
            // system.debug('closed isStopped' +[select id, isStopped from case where id=:setOfcaseIdToPeriodicupdateFRTMilestone]);
            CaseTriggerHelper.StopCustomerWaitTimeWhenCaseClosed(setOfcaseIdToupdateCustomerWaitTime);
            CaseTriggerHelper.CompleteCustomerWaitTimeMilestone(setOfcaseIdToupdateCustomerWaitTime);
        }
        
       If( System.Label.EnableJIRATicketCreation == 'TRUE' ){
            CTX_Salesforce_JIRA_FilterResult.fetchCaseDetails(
                (Map<Id, Case>) mapOfNewSObjects,
                (Map<Id, Case>) mapOfOldSObjects
            );
        }
        
        if(!mapOfAccIdToCaseId.isEmpty()){
            CaseTriggerHelper.UpdateOwnerIdBasedOnAccPGLorSBL(mapOfAccIdToCaseId);
        }
        
        system.debug('in caseMapForUdpatingCC'+caseMapForUdpatingCC);
        system.debug(' caseMapForUdpatingCC.isEmpty()'+caseMapForUdpatingCC.isEmpty());
        if(!caseMapForUdpatingCC.isEmpty()){	
            CaseTriggerHelper.autoRespondManualCasesafterUpdate(caseMapForUdpatingCC, accountMap );	
        }
        
        //added for sending warning mails distribution list :15 dec 2021
        CTX_CaseTriggerHelper.afterupdate(mapOfNewSObjects,mapOfOldSObjects);
        if( !mapOfMergedChildCases.isEmpty() ){
            CTX_CaseTriggerHelper.mergeCaseEmailTrigger(mapOfMergedChildCases,listOfMasterCases);
            
        }
        
        //added by bhavesh : Start : to send out email alert for field update
        if(caseIdsToSendEmailAlert.size()>0){
            //CTX_CaseEmailsShooter.sendEmailAlertForJiraFieldUpdate(caseIdsToSendEmailAlert, '00X2x000001AJ7E');
        }
        
    }
    


    public static void beforeDelete(List<SObject> listOfOldSObjects,Map<Id,SObject> mapOfOldSObjects){}
    
    public static void afterDelete(Map<Id,SObject> listOfOldSObjects){}
    
    public static void afterUnDelete(List<SObject> listOfNewSObjects,Map<Id,SObject> mapOfNewSObjects){}
    
}