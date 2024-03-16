/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-19-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_QuoteController {
    @AuraEnabled
    public static quoteWrapper getQuoteStatusName(String recId){
        quoteWrapper quoteWrapperResult =new quoteWrapper();
        Quote requiredQuote = [Select Id, Name, Status, Discount, Reason_for_Discount_Request__c, Flat_Transaction_Fee__c, Transaction_Fee_Slab_1__c, 
                               OpportunityId,Opportunity.Recordtype.DeveloperName,Approval_sub_status__c,Max_Discount__c ,Max_Discount_Prod_Category__c,Regional_Head__c,
                               Detailed_reason_for_discount__c, Transaction_Fee_Slab_2__c, Transaction_Fee_Slab_3__c, ID_Approval_Type__c, Total_Price_N__c, 
                               Opportunity_Record_Type__c, Contains_MS_Product__c, 
                               Price_Offered_to_Match_Competitor__c, Old_Anchor_Price__c, Next_Pitch_Date__c, 
                               Features_not_in_Use__c
                               From Quote Where Id=:recId];
        system.debug('requiredQuote ' + requiredQuote);
        quoteWrapperResult.quoteRecord=requiredQuote;
        quoteWrapperResult.isRenewal=requiredQuote.Opportunity.Recordtype.DeveloperName==OpportunityConstants.RECORDTYPE_RENEWAL?true:false;
        quoteWrapperResult.acquisitionOppRTList=OpportunityConstants.acquisitionOppRTList;
        quoteWrapperResult.isOpportunityRenewal= OpportunityConstants.acquisitionOppRTList.contains(requiredQuote.Opportunity.Recordtype.DeveloperName)?false:true;
        return quoteWrapperResult;
    }
    @AuraEnabled
    public static quoteWrapper submitQuoteForApproval(Quote thisQuote)
    {
        quoteWrapper updateQuoteWrapper =new quoteWrapper();
        boolean isSuccessUpdate=false;
        Savepoint sp = Database.setSavepoint();
        system.debug('thisQuote--->'+thisQuote);
        if(
            ( thisQuote.Discount==0 && thisQuote.Contains_MS_Product__c != TRUE ) || 
            ( thisQuote.Discount <= 10 && thisQuote.Opportunity.ClearTax_Billing_Entity__c == 'CimplyFive' )
        ){
            system.debug('thisQuote discount 0--->'+thisQuote);
            thisQuote.Status='Quote Accept';
            try{
                update  thisQuote;
            }catch(exception e){
                throw new AuraHandledException('Error Exception happend'+e.getMessage());   
            }
            system.debug('thisQuote discount after update--->'+thisQuote);
            isSuccessUpdate=true;
        }else{
            
            system.debug('thisQuote discount not 0 --->'+thisQuote);
            system.debug('thisQuote.Total_Price_N__c--->'+thisQuote.Total_Price_N__c);
            system.debug('thisQuote.Total_Price_ID_SKUs__c--->'+thisQuote.Total_Price_ID_SKUs__c);
            system.debug('thisQuote.Flat_Transaction_Fee__c--->'+thisQuote.Flat_Transaction_Fee__c);
            system.debug('thisQuote.Transaction_Fee_Slab_1__c--->'+thisQuote.Transaction_Fee_Slab_1__c);
            system.debug('thisQuote.Transaction_Fee_Slab_2__c--->'+thisQuote.Transaction_Fee_Slab_2__c);
            system.debug('thisQuote.Transaction_Fee_Slab_3__c--->'+thisQuote.Transaction_Fee_Slab_3__c);
            if(
                thisQuote.Total_Price_ID_SKUs__c >= 500000 && 
                thisQuote.Opportunity.ClearTax_Billing_Entity__c == 'Xpedize' &&
                (
                    thisQuote.Flat_Transaction_Fee__c == 0 || 
                    thisQuote.Flat_Transaction_Fee__c == NULL || 
                    thisQuote.Flat_Transaction_Fee__c > 20
                ) && 
                (
                    thisQuote.Transaction_Fee_Slab_1__c == 0 || 
                    thisQuote.Transaction_Fee_Slab_1__c == NULL || 
                    thisQuote.Transaction_Fee_Slab_1__c > 20
                ) && 
                (
                    thisQuote.Transaction_Fee_Slab_2__c == 0 || 
                    thisQuote.Transaction_Fee_Slab_2__c == NULL || 
                    thisQuote.Transaction_Fee_Slab_2__c > 20
                ) && 
                (
                   thisQuote.Transaction_Fee_Slab_3__c == 0 || 
                   thisQuote.Transaction_Fee_Slab_3__c == NULL || 
                   thisQuote.Transaction_Fee_Slab_3__c > 20
               )
              ){
                  
                system.debug('thisQuote ID discount > 500000 & Slabs% > 20--->'+thisQuote);
                thisQuote.Status='Quote Accept';
                try{
                    update  thisQuote;
                }catch(exception e){
                    throw new AuraHandledException('Error Exception happend'+e.getMessage());   
                }
                system.debug('thisQuote discount after update--->'+thisQuote);
                isSuccessUpdate=true;
            } else{
                
                if( thisQuote.Total_Price_ID_SKUs__c < 250000 ){
                    thisQuote.ID_Approval_Type__c = 'Double Approval';
                }else{
                    
                    if(
                        (
                            thisQuote.Flat_Transaction_Fee__c != 0 && 
                         thisQuote.Flat_Transaction_Fee__c != NULL && 
                         thisQuote.Flat_Transaction_Fee__c < 10
                        ) || 
                        (
                            thisQuote.Transaction_Fee_Slab_1__c != 0 && 
                            thisQuote.Transaction_Fee_Slab_1__c != NULL && 
                            thisQuote.Transaction_Fee_Slab_1__c < 10
                        ) || 
                        (
                            thisQuote.Transaction_Fee_Slab_2__c != 0 && 
                            thisQuote.Transaction_Fee_Slab_2__c != NULL && 
                            thisQuote.Transaction_Fee_Slab_2__c < 10 ) || 
                        (
                            thisQuote.Transaction_Fee_Slab_3__c != 0 && 
                            thisQuote.Transaction_Fee_Slab_3__c != NULL && 
                            thisQuote.Transaction_Fee_Slab_3__c < 10
                        ) 
                    ){
                        thisQuote.ID_Approval_Type__c = 'Double Approval';
                    }else{
                        thisQuote.ID_Approval_Type__c = 'Single Approval';
                    }
                }
                system.debug('thisQuote.ID_Approval_Type__c --->'+thisQuote.ID_Approval_Type__c);
                if(thisQuote.Contains_MS_Product__c){
                    thisQuote.Approval_sub_status__c='MS Approval in progress';
                }else{
                    thisQuote.Approval_sub_status__c='Discount Approval in progress';
                }
                
                try{
                    update  thisQuote;
                    system.debug('thisQuote BIBHU Debug: '+thisQuote);
                    isSuccessUpdate=true;
                }catch(exception e){
                   system.debug('exception while updating is: '+e.getMessage()+' -- Line :: '+e.getLineNumber());
                    throw new AuraHandledException('Error Exception happend'+e.getMessage());   
                }
                system.debug('thisQuote after update--->'+thisQuote);
                // Create an approval request for the Opportunity
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval automatically using Trigger');
                req1.setObjectId(thisQuote.id);
                
                // Submit the approval request for the Opportunity
                try{
                    Approval.ProcessResult result = Approval.process(req1);
                    Approval.lock(thisQuote, true);
                    isSuccessUpdate=true;
                }catch(exception e){
                    system.debug('Approval Process Exception: '+e.getMessage());
                    Database.rollback(sp);
                    isSuccessUpdate=false;
                }
            }
        }
        updateQuoteWrapper.quoteRecord=thisQuote;
        updateQuoteWrapper.isSuccess=isSuccessUpdate;
        return updateQuoteWrapper;  
    }   
    @AuraEnabled
    public static errorWrapper showDiscountApprovalError(String thisQuoteId,Quote thisQuote){
        set<Id> setOfDocIds = new set<Id>();
        Map<Id,String> versionWithType = new Map<Id,String>();
        errorWrapper  errorWrapperResult=new errorWrapper();
        String errorString ='';
        Boolean QuoteError=false;
        List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: thisQuoteId ];
        system.debug('thisQuote error --->'+thisQuote);
        for(ContentDocumentLink tempContent : contentDocList){
            setOfDocIds.add(tempContent.ContentDocumentId);
        }
        
        List<ContentVersion> contentverList = [SELECT Type_of_document__c,ContentDocumentId FROM ContentVersion where ContentDocumentId IN: setOfDocIds];
        for(ContentVersion tempVersion : contentverList){
            if(tempVersion.Type_of_document__c==system.Label.QuoteDocTypeMandate){
                versionWithType.put(tempVersion.ContentDocumentId, tempVersion.Type_of_document__c );
            }
        }
        if(versionWithType !=null && versionWithType.size()>0){
            if(thisQuote.Regional_Head__c==null){
                //QuoteError=true; 
                //errorString=System.Label.Quote_Regional_Head_Error;
            }else{
                QuoteError=false;
            }
        }else if(thisQuote.Opportunity.ClearTax_Billing_Entity__c == 'CimplyFive'){
            QuoteError=true;
            errorString=System.Label.Quote_Attachment_Error_Message;
        }
        errorWrapperResult.isQuoteError=QuoteError;
        errorWrapperResult.errorString=errorString;
        return errorWrapperResult; 
    }
    @AuraEnabled 
    public static Map<String, String> getReasonForDiscount(string OpportunityRTName){
        
        String oppType = OpportunityConstants.acquisitionOppRTList.contains(OpportunityRTName) 
            ? 'Acquisition':
        OpportunityConstants.RetentionOppRTList.contains(OpportunityRTName) ? 'Retention': NULL;
        
        Map<String, String> options = new Map<String, String>();
        options =customDependablePicklist('Quote','Opportunity_Type__c','Reason_for_Discount_Request__c',oppType);
        return options;
        
    }
    @AuraEnabled
    public static boolean  quoteRecordToUpdateFunction(Quote quoteRecordToUpdate){
        boolean isSuccess=false;
        system.debug('quoteRecordToUpdate---->'+quoteRecordToUpdate);
        try{
            update quoteRecordToUpdate;
            isSuccess=true;
        }catch(exception e){
            isSuccess=false;
            throw new AuraHandledException('Error Exception happend'+e.getMessage());   
        }
        return isSuccess;
    }
    public class quoteWrapper{
        @AuraEnabled
        public Quote quoteRecord{get;set;}
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        @AuraEnabled
        public Boolean isRenewal{get;set;}
        @AuraEnabled
        public List<String> acquisitionOppRTList{get;set;}
        @AuraEnabled
        public boolean isOpportunityRenewal{get;set;}
        
    }
    public class errorWrapper{
        
        @AuraEnabled
        public Boolean isQuoteError{get;set;}
        @AuraEnabled
        public string errorString{get;set;}
        
        
    }
    
    private static final String getAlphaChars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    @AuraEnabled 
    public static Map<string,String> customDependablePicklist(
        String strObjectName,
        string strparentField, 
        string strchildField, 
        String strParentvalue 
    ){
        
        Map<string,String>			validChildValueMap 		= new Map<string,String>();
        List<String> 				validChildValuesList 	= new List<String>();
        Map<String,List<String>> 	pickListMap 			= new Map<String,List<String>>();
        customPicklistWrapper 		pw 						= new customPicklistWrapper();
        pw.pickListMap 										= pickListMap;
        
        if (
            Schema.getGlobalDescribe().get(strObjectName) == NULL || 
            String.isBlank(strparentField) || 
            String.isBlank(strChildField)
        ){
            return NULL;
        }
        
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(strObjectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(strparentField) || !objFieldMap.containsKey(strchildField)){
            return NULL;     
        }
        
        List<customPicklistEntryWrapper> depEntriesList = 
            (List<customPicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(strChildField).getDescribe().getPicklistValues()), List<customPicklistEntryWrapper>.class);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : objFieldMap.get(strparentField).getDescribe().getPicklistValues()) {
            pickListMap.put(ple.getLabel(), new List<String>());
            controllingValues.add(ple.getLabel());
        }
        
        for (customPicklistEntryWrapper plew : depEntriesList) {
            String validForBits = alphaBaseToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    pickListMap.get(controllingValues.get(i)).add(plew.label);
                }
            }
        }
        
        pw.pickListMap = pickListMap;
        validChildValuesList= pickListMap.containsKey(strParentvalue)?pickListMap.get(strParentvalue):null;
        if(!validChildValuesList.isEmpty()){
            for(String thisVlaue:validChildValuesList){
                validChildValueMap.put(thisVlaue, thisVlaue);
            }
        }
        pw.parentFieldLabel = objFieldMap.get(strparentField).getDescribe().getLabel();
        pw.childFieldLabel = objFieldMap.get(strchildField).getDescribe().getLabel();
        return validChildValueMap;
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
    
    public static String alphaBaseToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = getAlphaChars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    public class customPicklistWrapper{
        @AuraEnabled
        public Map<String, List<String>> pickListMap;
        @AuraEnabled
        public String parentFieldLabel;
        @AuraEnabled
        public String childFieldLabel;      
    }
    
    public class customPicklistEntryWrapper{
        public String active;
        public String defaultValue;
        public String label;
        public String value;
        public String validFor;
        
    }
    
   /* Public static void sendApproveRejectMails(Map<Id,Quote> quoteMapForApproveReject)
    {
         List<Messaging.SingleEmailMessage> listOfMessagingSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
         List<EmailTemplate> emailTemplateList =[Select, Id,Subject,Description,
                                 HtmlValue,DeveloperName,Body
                                 from EmailTemplate where name IN :
                                ('Quote Approved','Quote Rejected')];
        Map<String,EmailTemplate> emailTemplateMap= new Map<String,EmailTemplate>();
        for(EmailTemplate thisTemplate:emailTemplateList){
            emailTemplateMap.put(thisTemplate.description ,thisTemplate.Id);
        }
        
        for(Quote thisQuote : quoteMapForApproveReject.values()){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(emailTemplateMap.get(key));
            email.setToAddresses(thisQuote.Opprotunity__r.OwnerId);
            email.setOrgWideEmailAddressId();    
            email.setSaveAsActivity(true);
            email.setTargetObjectId(thisQuote?.id);
            email.setWhatId(thisQuote?.id);
            listOfMessagingSingleEmailMessage.add(email);
        }
        
        system.debug('updateIsCaseCreatedFromEmailMessage**3'+mapOfEmailMessagesToBeInserted.values());
        if(listOfMessagingSingleEmailMessage.size() > 0 && !listOfMessagingSingleEmailMessage.isEmpty()){
            Messaging.SendEmailResult[] msgResult = Messaging.sendEmail(listOfMessagingSingleEmailMessage,false);
            system.debug('updateIsCaseCreatedFromEmailMessage**4'+mapOfEmailMessagesToBeInserted.values().size());
            //insert mapOfEmailMessagesToBeInserted.values()[0];
            System.debug('msgResult'+msgResult);
        }*/
        
        
        
        
    }