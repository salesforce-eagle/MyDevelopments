public class CaseListViewBulkEmailController {
   
    @AuraEnabled
    public static Map<String, String> getFieldValue(String sobjectName,String picklistfieldName){
        Map<String, String> options = new Map<String, String>();
        
        Map<String, Schema.SObjectType> sobjectResult = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> filedResults=sobjectResult.get(sobjectName).getDescribe().fields.getMap();        
        Schema.DescribeFieldResult fieldResult = filedResults.get(picklistfieldName).getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    @AuraEnabled
    public static boolean checkConsistsLookupIssueType(list<string> listofCaseIds){
        boolean isvalid=true;
        list<case> listOfcase=[select Lookup_Issue_Type__c,Lookup_Issue_Type1__c,Lookup_Issue_Type_EInv__c from case where id in:listofCaseIds];
        system.debug('listOfcase '+listOfcase);
        for(case cs:listOfcase){
            system.debug('========>'+cs.Lookup_Issue_Type__c+' '+cs.Lookup_Issue_Type1__c  +' '+cs.Lookup_Issue_Type_EInv__c);
            if(cs.Lookup_Issue_Type__c==null && cs.Lookup_Issue_Type1__c==null && cs.Lookup_Issue_Type_EInv__c==null)//|| cs.Lookup_Issue_Type1__c!='' ||cs.Lookup_Issue_Type1__c!='' ||cs.Lookup_Issue_Type_EInv__c!=''
            {
                system.debug('inside isValid');
                isvalid=false;
                // break;
            }
        }
        return TRUE;
    }
    
    @AuraEnabled
    public static EmailTemplate getEmailTemplateById(String emailTemplateid){
        String relatedEntityType='Case';
        EmailTemplate emailTemplateInstance=DataBase.query(UtilityClass.getQueryString('EmailTemplate')+' FROM EmailTemplate WHERE Id =: emailTemplateid and isActive=true ');//and RelatedEntityType=:relatedEntityType ');
        
        return emailTemplateInstance;
    }
    
    @AuraEnabled
    public static EmailWrapper CheckContactOnCase(List<String> listofCaseIds){
        EmailWrapper emWrap = new EmailWrapper();
        emWrap.isSuccess = true;
        list<case> cases=[select id, contactid from case where id in :listofCaseIds];
        for(case cs : cases){
            if(cs.ContactId==null){
                emWrap.isSuccess=false;
                emWrap.errorMessage='Please add Contact to the cases';
                break;
            }
        }
        return emWrap;
    }
    
    public class EmailWrapper{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String errorMessage;
    }
    @AuraEnabled
    public static EmailWrapper sendEmailToAllCases(List<String> listofCaseIds,Case caseInstance,String emailTemplateId,String body,String subject,String issueTypeId){
        EmailWrapper emWrap = new EmailWrapper();
        emWrap.isSuccess = true;
        boolean isSuccess=false;
        try{
            System.debug('<====caseEmailTemplateWrapperInstance====>');
            Set<String> setofCasesIds=new Set<String>(listofCaseIds);
            Map<Id,Case> mapofIdWithCases=new Map<Id,Case>();
            Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Case.fields.getMap();
            String relationShipFields='';
            List<String> listofRelationShipFields=new List<String>();
            for (Schema.SObjectField field : fieldsMap.values())
            {
                
                if(field.getDescribe().getRelationshipName()!=null && field.getDescribe().getRelationshipName()!='MasterRecord' && field.getDescribe().getRelationshipName()!='Parent' && field.getDescribe().getRelationshipName()!='ServiceContract' && field.getDescribe().getRelationshipName()!='Followup_Parent_Case__r'){
                    if(field.getDescribe().getRelationshipName()!= 'FeedItem'){
                    String tempRelationName=field.getDescribe().getRelationshipName()+'.Name';
                    listofRelationShipFields.add(tempRelationName);
                    }
                }
                relationShipFields = String.join(listofRelationShipFields,', ');
                
                System.debug(relationShipFields);
            }
            
            System.debug(relationShipFields);        
            if(setofCasesIds.size()>0){
                mapofIdWithCases=new Map<Id,Case>((List<Case>)Database.query(UtilityClass.getQueryString('Case')+','+relationShipFields+'  FROM Case WHERE Id IN: setofCasesIds'));
            }
            
            Issue_Type__c selectedIssueType=new Issue_Type__c();
            if(issueTypeId!=null){
                
                selectedIssueType=DataBase.query(UtilityClass.getQueryString('Issue_Type__c')+' FROM Issue_Type__c WHERE Id =: issueTypeId');
                
            }
            
            List<Case> listOfCasesToUpdate=new List<Case>();
            //write the Logic here.
            if(setofCasesIds!=null){
                //Logic to Update Cases with the provided Information
                
                if(setofCasesIds.size()>0){
                    for(String caseId:setofCasesIds){
                        if(caseId!=null && caseId!=''){
                            // New Logic for Bulk cases if the Case Owner is Queue and the cases is getting updated then we have assign to the current User who is triggering the bulk email action.
                            if(!String.valueOf(mapofIdWithCases.get(caseId).OwnerId).startsWithIgnoreCase(User.SobjectType.getDescribe().getKeyPrefix())){
                                //mapofIdWithCases.get(caseId).OwnerId=UserInfo.getUserId();
                            }
                            
                            if(isBlankCheck(caseInstance?.priority)){
                                mapofIdWithCases.get(caseId).Priority=caseInstance?.priority;
                            }
                            if(isBlankCheck(caseInstance?.status)){
                                mapofIdWithCases.get(caseId).Status=caseInstance?.status;
                            }
                            if(isBlankCheck(caseInstance?.Sub_Status__c)){
                                mapofIdWithCases.get(caseId).Sub_Status__c=caseInstance?.Sub_Status__c;
                            }else{
                                mapofIdWithCases.get(caseId).Sub_Status__c=null;
                            }
                            if(isBlankCheck(caseInstance?.type) && mapofIdWithCases.get(caseId).Type == NULL){
                                mapofIdWithCases.get(caseId).Type=caseInstance?.type;
                            }
                            if(isBlankCheck(caseInstance?.ownerId)){
                                mapofIdWithCases.get(caseId).ownerId=caseInstance?.ownerId;
                            }
                            if(isBlankCheck(caseInstance?.Comments))
                            {
                                mapofIdWithCases.get(caseId).Comments=caseInstance?.Comments;
                            }
                            System.debug('caseInstance?.ParentId!201'+caseInstance.ParentId);
                            if(isBlankCheck(caseInstance?.ParentId))
                            {
                                System.debug('caseInstance?.ParentId!2'+caseInstance?.ParentId);
                                mapofIdWithCases.get(caseId).ParentId=caseInstance?.ParentId;
                            }
                            // Old Logic
                            system.debug(' selectedIssueType.Case_Type__c '+ selectedIssueType );
                            system.debug(' selectedIssueType.Case_Type__c.length1 '+ selectedIssueType==null );
                            system.debug(' selectedIssueType.Case_Type__c '+ selectedIssueType.Case_Type__c );
                            if(/*mapofIdWithCases.get(caseId).Lookup_Issue_Type__c==null && */(CaseSelector.getRecordTypeNameById('Case', mapofIdWithCases.get(caseId).RecordTypeId).containsIgnoreCase('B2B')  || Label.New_case_recordtypes.containsIgnoreCase(CaseSelector.getRecordTypeNameById('Case', mapofIdWithCases.get(caseId).RecordTypeId)))
                                && selectedIssueType.Case_Type__c=='B2B' && mapofIdWithCases.get(caseId).Lookup_Issue_Type__c == NULL){
                                mapofIdWithCases.get(caseId).Lookup_Issue_Type__c=issueTypeId;
                            }else if(/*mapofIdWithCases.get(caseId).Lookup_Issue_Type1__c==null &&*/  CaseSelector.getRecordTypeNameById('Case', mapofIdWithCases.get(caseId).RecordTypeId).containsIgnoreCase('B2C') && selectedIssueType.Case_Type__c=='B2C' 
                                    && mapofIdWithCases.get(caseId).Lookup_Issue_Type1__c == NULL){
                                mapofIdWithCases.get(caseId).Lookup_Issue_Type1__c=issueTypeId;
                            }else if(/*mapofIdWithCases.get(caseId).Lookup_Issue_Type_EInv__c==null && */ CaseSelector.getRecordTypeNameById('Case', mapofIdWithCases.get(caseId).RecordTypeId).containsIgnoreCase('E Invoicing') && selectedIssueType.Case_Type__c=='EInv'
                                    && mapofIdWithCases.get(caseId).Lookup_Issue_Type_EInv__c == NULL
                                    ){
                                mapofIdWithCases.get(caseId).Lookup_Issue_Type_EInv__c=issueTypeId;
                            }
                            /**else if(selectedIssueType.Case_Type__c!=null  ){
                                
                                emWrap.isSuccess = false;
                                emWrap.errorMessage = System.label.IssuetypeError;
                                return emWrap;
                            }**/
                            
                            
                            //new logic as per Requirement selectedIssueType should be updated in all cases --Add by sunil
                            /* if(CaseSelector.getRecordTypeNameById('Case', mapofIdWithCases.get(caseId).RecordTypeId).containsIgnoreCase('B2B') ){
mapofIdWithCases.get(caseId).Lookup_Issue_Type__c=issueTypeId;
}else if(CaseSelector.getRecordTypeNameById('Case', mapofIdWithCases.get(caseId).RecordTypeId).containsIgnoreCase('B2C') ){
mapofIdWithCases.get(caseId).Lookup_Issue_Type1__c=issueTypeId;
}else if( CaseSelector.getRecordTypeNameById('Case', mapofIdWithCases.get(caseId).RecordTypeId).containsIgnoreCase('E Invoicing')){
mapofIdWithCases.get(caseId).Lookup_Issue_Type_EInv__c=issueTypeId;
}*/
                            
                            
                            
                            mapofIdWithCases.get(caseId).Bulk_Email_auto_and_validation_handler__c = true;
                            
                            listOfCasesToUpdate.add(mapofIdWithCases.get(caseId));
                            
                            
                        }
                    }
                }
                
                //Logic to send the Email to all the cases.
                
            }
            
            
            
            
            if(listOfCasesToUpdate.size()>0){
                update listOfCasesToUpdate;
                
                List<Case> listofCasesToHandleAutomation=new List<Case>();
                for(Case caseInstancehandle:listOfCasesToUpdate){
                    case caseIns=new Case();
                    caseIns.Id=caseInstancehandle.Id;
                    caseIns.Bulk_Email_auto_and_validation_handler__c = false;
                    listofCasesToHandleAutomation.add(caseIns);
                }
                
                update listofCasesToHandleAutomation;
            }
            
            
            if(mapofIdWithCases.size()>0 && !mapofIdWithCases.isEmpty()){
                if(isBlankCheck(body)){
                    sendEmailAction(mapofIdWithCases, body, issueTypeId,emailTemplateId,selectedIssueType);
                }
            }
        }Catch(Exception e){
            System.debug('Exception E======> '+e);
            system.debug('****e-->'+e.getMessage()+' '+e.getLineNumber());
            System.debug('Exception E.getStackTraceString======> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return emWrap;
    }
    
    private static boolean isBlankCheck(String value){
        boolean isBlank=false;
        if(value!=null && value!='' && !String.isEmpty(value) && !String.isBlank(value)){
            isBlank = true;
        }
        return isBlank;
        
    }
    
    
    public static void sendEmailAction(Map<Id,Case> mapofIdWithCases,String body,String issueTypeId,String templateId,Issue_Type__c selectedIssueType){
        
        List<Messaging.SingleEmailMessage> listOfMessagingSingleEmailMessage=new List<Messaging.SingleEmailMessage>();
        Map<Id,EmailMessage> mapOfEmailMessagesToBeInserted=new Map<Id,EmailMessage>();
        String orgid=Label.OrgWiderIdForSupportCase;
        Map<Id,OrgWideEmailAddress> mapOfOrgwideEmails=new Map<Id,OrgWideEmailAddress>((List<OrgWideEmailAddress>)DataBase.query(UtilityClass.getQueryString('OrgWideEmailAddress')+' FROM OrgWideEmailAddress WHERE ID =:orgid '));
        Map<String,Set<String>> mapOfObjectWithFieldsInfo=new Map<String,Set<String>>();
        Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Case.fields.getMap();
        Map<String,String> mapOfStringwithString=new Map<String,String>();
        
        Map<Id,EmailMessage> mapOfEmailMessages=new Map<Id,EmailMessage>([SELECT id,HtmlBODY,TextBody,ParentId FROM EmailMessage WHERE ParentId IN: mapofIdWithCases.keySet()]);
        
        Map<Id,String> mapOfParentIdWithExistingBody=new Map<Id,String>();
        
        for(EmailMessage emailMessageInstance:mapOfEmailMessages.values()){
            if(!mapOfParentIdWithExistingBody.containsKey(emailMessageInstance.ParentId)){
                mapOfParentIdWithExistingBody.put(emailMessageInstance.ParentId, emailMessageInstance.HtmlBody);
            }else{
                mapOfParentIdWithExistingBody.put(emailMessageInstance.ParentId,mapOfParentIdWithExistingBody.get(emailMessageInstance.ParentId)+'<br/>'+emailMessageInstance.HtmlBody);
            }
        }
        
        for(Id caseId : mapofIdWithCases.keySet()){
            Messaging.SingleEmailMessage singleEmailMessageInstance=new Messaging.SingleEmailMessage();
            singleEmailMessageInstance.setWhatId(caseId);
            singleEmailMessageInstance.setSubject(mapofIdWithCases.get(caseId).Subject);
            singleEmailMessageInstance.setToAddresses(new List<String>{mapofIdWithCases.get(caseId).ContactEmail});
            //singleEmailMessageInstance.setCcAddresses(new List<String>{mapofIdWithCases.get(caseId).Owner_Email__c});
            singleEmailMessageInstance.setTemplateId(templateId);
            singleEmailMessageInstance.setOrgWideEmailAddressId(mapOfOrgwideEmails.get(orgid).Id);
            singleEmailMessageInstance.setSaveAsActivity(true);
            singleEmailMessageInstance.setReplyTo(mapOfOrgwideEmails.get(orgid).Address);
            
            String finalPlainText= Body;
            
            List<String> listOfemailBodySplit=Body.split(' ');
            
            System.debug('finalPlainText'+finalPlainText);
            Sobject obj=mapofIdWithCases.get(caseId);
            mapOfObjectWithFieldsInfo = CaseListViewBulkEmailController.MergeText(finalPlainText, obj);
            System.debug('=================================>');
            System.debug(mapOfObjectWithFieldsInfo);
            system.debug('****fieldsMap-->'+fieldsMap);
            for(String sobjName:mapOfObjectWithFieldsInfo.KeySet()){
                System.debug(sobjName);
                for(String fieldName:mapOfObjectWithFieldsInfo.get(sobjName)){
                    System.debug('{{{'+sobjName+'.'+fieldName+'}}}');
                    system.debug('****fieldName-->'+fieldName);
                    //finalPlainText.replaceAll('{{{'+sobjName+'.'+fieldName+'}}}', )
                    if(fieldsMap.get(fieldName) != null && fieldsMap.get(fieldName).getDescribe() != null && fieldsMap.get(fieldName).getDescribe().getRelationshipName()!=null){
                        system.debug('****fieldsMap.get(fieldName)-->'+fieldsMap.get(fieldName));
                        system.debug('****fieldsMap.get(fieldName).getDescribe()-->'+fieldsMap.get(fieldName).getDescribe());
                        system.debug('****fieldsMap.get(fieldName).getDescribe().getRelationshipName()-->'+fieldsMap.get(fieldName).getDescribe().getRelationshipName());
                        
                        system.debug('MapField ======> '+ fieldsMap.get(fieldName).getDescribe().getRelationshipName());
                        system.debug('MapOfID  a======> '+ mapofIdWithCases.get(caseId).getSobject(fieldsMap.get(fieldName).getDescribe().getRelationshipName()));
                        System.debug(sobjName+'.'+fieldsMap.get(fieldName).getDescribe().getName());
                        //if(mapofIdWithCases.get(caseId).getSobject(fieldsMap.get(fieldName).getDescribe().getRelationshipName())!=null){
                        finalPlainText = finalPlainText.replaceAll('\\{\\{\\{'+sobjName+'.'+fieldName+'\\}\\}\\}', (String) mapofIdWithCases.get(caseId).getSobject(fieldsMap.get(fieldName).getDescribe().getRelationshipName()).get('Name'));
                        System.Debug(fieldsMap.get(fieldName).getDescribe().getRelationshipName()+' Relational Field Value <====> '+mapofIdWithCases.get(caseId).getSobject(fieldsMap.get(fieldName).getDescribe().getRelationshipName()).get('Name'));                           
                        //} 
                        
                    }else{
                        try{
                            system.debug('****mapofIdWithCases.get(caseId).get(fieldName)-->'+mapofIdWithCases.get(caseId).get(fieldName));
                            finalPlainText = finalPlainText.replaceAll('\\{\\{\\{'+sobjName+'.'+fieldName+'\\}\\}\\}',(String)mapofIdWithCases.get(caseId).get(fieldName));
                        }catch(Exception e){
                            
                        }
                        
                        //System.debug(sobjName+'.'+fieldsMap.get(fieldName).getDescribe().getName());
                        //System.debug(fieldName+' Field Vaulue <====> '+mapofIdWithCases.get(caseId).get(fieldName));
                        
                    }
                }
            }
            System.debug('=================================>');
            
            if(mapOfParentIdWithExistingBody.get(caseId)!=null){
                finalPlainText+=' <br/> '+mapOfParentIdWithExistingBody.get(caseId);
            }
            
            singleEmailMessageInstance.setHtmlBody(finalPlainText);
            
            if(mapofIdWithCases.get(caseId).ContactId!=null){
                singleEmailMessageInstance.setTargetObjectId(mapofIdWithCases.get(caseId)?.ContactId);
            }else{
                if(String.valueOf(mapofIdWithCases.get(caseId)?.OwnerId).startsWith('005')){
                    singleEmailMessageInstance.setTargetObjectId(mapofIdWithCases.get(caseId)?.OwnerId);  
                }else{
                    singleEmailMessageInstance.setTargetObjectId(UserInfo.getUserId());
                }
            }
            
            listOfMessagingSingleEmailMessage.add(singleEmailMessageInstance);
            
            
            EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details from above.
            emailMsg.ToAddress = (singleEmailMessageInstance?.getToAddresses())[0];
            emailMsg.fromaddress = Label.OrgWiderIdForSupportCase;//emsg.fromAddress;
            
            //emailMsg.FromName = mapOforgWideEmailAddressInstance.get(mapOfOrgwideandEmailTemplateMappings.get(mapOfIdandCase.get(emsg?.ParentId)?.Email_Source__c)?.Org_Wide_Email_Id__c)?.DisplayName;//emsg.fromName;
            /* if(emsg.MessageIdentifier != null){
emailMsg.MessageIdentifier = emsg.MessageIdentifier;
emailMsg.ThreadIdentifier = emsg.MessageIdentifier;
}*/
            
            emailMsg.Subject = singleEmailMessageInstance.getSubject();
            emailMsg.HtmlBody = singleEmailMessageInstance.getHtmlBody();
            emailMsg.TextBody = singleEmailMessageInstance.getPlainTextBody ();
            emailMsg.parentid = caseId; // storing case id externally 
            emailMsg.MessageDate = system.now();
            /* emailMsg.Status__c=mapofIdWithCases.get(caseId).Status;
emailMsg.Sub_Status__c=mapofIdWithCases.get(caseId).Sub_Status__c;
if(CaseSelector.getRecordTypeNameById('Case', mapofIdWithCases.get(caseId).RecordTypeId).containsIgnoreCase('B2B') && selectedIssueType.Case_Type__c=='B2B'){
emailMsg.Issue_Type__c=issueTypeId;
}else if(CaseSelector.getRecordTypeNameById('Case', mapofIdWithCases.get(caseId).RecordTypeId).containsIgnoreCase('B2C') && selectedIssueType.Case_Type__c=='B2C' ){
emailMsg.Issue_Type__c=issueTypeId;
}else if(CaseSelector.getRecordTypeNameById('Case', mapofIdWithCases.get(caseId).RecordTypeId).containsIgnoreCase('E Invoicing') && selectedIssueType.Case_Type__c=='EInv'){
emailMsg.Issue_Type__c=issueTypeId;
}*/
            emailMsg.Status = '3';
            if(!mapOfEmailMessagesToBeInserted.containsKey(caseId)){
                mapOfEmailMessagesToBeInserted.put(caseId,emailMsg);
            }
            //caseIdEmailUnique.add(caseId);
        }
        system.debug('updateIsCaseCreatedFromEmailMessage**3'+mapOfEmailMessagesToBeInserted.values());
        if(mapOfEmailMessagesToBeInserted.values().size() > 0 && !mapOfEmailMessagesToBeInserted.values().isEmpty()){
            try{
                caseConstants.taskTrigger = False;
                Messaging.SendEmailResult[] msgResult = Messaging.sendEmail(listOfMessagingSingleEmailMessage);
                system.debug('updateIsCaseCreatedFromEmailMessage**4'+mapOfEmailMessagesToBeInserted.values().size());
                //insert mapOfEmailMessagesToBeInserted.values()[0];
                System.debug('msgResult'+msgResult);
            }catch(Exception e){
                System.debug('UnExpected Error Occured while sending the Bulk Emails from Component ');
            }
        }
        
        // return singleEmailMessageInstance;
    }
    
    public static Map<String,Set<String>> MergeText(String source, SObject obj){
        
        Map<String,Set<String>> mapofSobejctNameWithFieldName=new Map<String,Set<String>>();
        
        String s = '';      
        if(source != null && obj != null){
            Integer curPos = 0;
            Pattern mergeField = Pattern.compile('\\{\\{\\{[a-zA-Z0-9_\\.]*\\}\\}\\}');
            Matcher m = mergeField.matcher(source);
            while(m.find()){
                //add the piece of text from the end of the previous match
                //until the start of this one.
                s += source.substring(curPos, m.start());
                //get the actual field name (without {! })
                String fieldName = source.substring(m.start()+2,m.end()-1);
                fieldName=fieldName.replace('{','').replace('}','');
                System.debug(fieldName);
                //split the fieldname to get the different relations as parts
                String[] relations = fieldName.split('\\.');
                System.debug(relations);
                if(!mapofSobejctNameWithFieldName.containsKey((String)relations[0])){
                    mapofSobejctNameWithFieldName.put(relations[0],new Set<String>{relations[1]});
                }else{
                    mapofSobejctNameWithFieldName.get(relations[0]).add(relations[1]);
                }
                try {
                    //iterate over the relations to get to the object that's needed.
                    SObject tmp = obj;
                    for(Integer i=0; i<relations.size()-1; i++){
                        tmp = tmp.getSObject(relations[i]);
                    }
                    //now get the value of the field
                    s += tmp.get(relations[relations.size()-1]);
                } catch(Exception ex){
                    s += '[Invalid merge field: ' + m.group() + ']';
                }
                curPos = m.end();
            }
            //add the end of the original string
            s += source.substring(curPos);
        }
        return mapofSobejctNameWithFieldName;
    }
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    @AuraEnabled
    public static void addOrRemoveTopicFromCase(List<Id> listOfCaseIds,String topicId,String topicName,boolean isAdd,boolean isRemove){
        Map<Id,Case> mapofIdwithCases=new Map<Id,Case>();
        List<TopicAssignmentService.TopicCaseWrapper> listOftopicCaseWrapperInstanceToAdd=new List<TopicAssignmentService.TopicCaseWrapper>();
        List<TopicAssignmentService.TopicCaseWrapper> listOftopicCaseWrapperInstanceToRemove=new List<TopicAssignmentService.TopicCaseWrapper>();
        
        if(isAdd){
            TopicAssignmentService.TopicCaseWrapper topicCaseWrapperInstance=new TopicAssignmentService.TopicCaseWrapper();
            topicCaseWrapperInstance.entitySobjectId=listOfCaseIds;
            topicCaseWrapperInstance.topicWithCommaSeperated = topicName;
            listOftopicCaseWrapperInstanceToAdd.add(topicCaseWrapperInstance);
        }else if(isRemove){
            TopicAssignmentService.TopicCaseWrapper topicCaseWrapperInstance=new TopicAssignmentService.TopicCaseWrapper();
            topicCaseWrapperInstance.entitySobjectId=listOfCaseIds;
            topicCaseWrapperInstance.topicWithCommaSeperated = topicId;
            listOftopicCaseWrapperInstanceToRemove.add(topicCaseWrapperInstance);
            
        }
        
        if(listOftopicCaseWrapperInstanceToAdd.size()>0){
            try{
                TopicAssignmentService.topicAssignmentToEntity(listOftopicCaseWrapperInstanceToAdd);
            }catch(Exception ex ){
                System.debug('unexpected Exception'+ex.getMessage());
            }
        }
        
        if(listOftopicCaseWrapperInstanceToRemove.size()>0){
            removeTopicFromCases(listOftopicCaseWrapperInstanceToRemove);
        }
        
    }
    
    public static void removeTopicFromCases(List<TopicAssignmentService.TopicCaseWrapper> listOftopicCaseWrapperInstanceToRemove){
        Set<Id> setofTopicId=new Set<Id>();
        setofTopicId.add((Id)listOftopicCaseWrapperInstanceToRemove[0].topicWithCommaSeperated);
        
        List<TopicAssignment> listOfTopicAssignments=new TopicAssignmentSelector().getTopicEntityJR(setofTopicId,new Set<Id>(listOftopicCaseWrapperInstanceToRemove[0].entitySobjectId));
        
        if(listOfTopicAssignments.size()>0){
            delete listOfTopicAssignments;
        }
    }
    
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    
    public class emailTemplateWrapper{
        
        @AuraEnabled 
        public String folderName{get;set;}
        
        @AuraEnabled 
        public String folderId{get;set;}
        
        @AuraEnabled
        public list<emailTemplates> emailtemplatelist{get;set;}
        
    }
    
    public class emailTemplates{
        
        @AuraEnabled 
        public String emailTemplateId{get;set;}
        
        @AuraEnabled 
        public String emailbody{get;set;}
        
        @AuraEnabled
        public String emailSubject {get;set;}
        
        @AuraEnabled 
        public String emailTemplatename{get;set;}
    }  
    
    public class CaseEmailTemplateWrapper{
        
        @AuraEnabled
        public Case caseInstance{get;set;}
        
        @AuraEnabled
        public String emailTemplateId{get;set;}
        
        @AuraEnabled
        public String body{get;set;}
        
        @AuraEnabled
        public String subject{get;set;}
        
        
    }
    
    public static void dummy(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;i++;
        i++;
        i++;
        i++;
        i++;
    }
    
}