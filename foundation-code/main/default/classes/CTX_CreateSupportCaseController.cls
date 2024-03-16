public class CTX_CreateSupportCaseController {
    
    @AuraEnabled
    public static Result getRecordTypeFields(){
        
        Result				resultWrapper		= new Result();
        List<ResultWrapper> resultWrapperList 	= new List<ResultWrapper>();
        List<String>		perSalesUserEmails	= system.label.Pre_Sales_Users_Email.split(',');
        List<String>		perSalesUserProfiles= system.label.Pre_Sales_Users_Profile.split(',');
        
        for( Support_Case_Metadata__mdt mdt : Support_Case_Metadata__mdt.getAll().values() ){
            
            ResultWrapper 					resInstance 		= new ResultWrapper();
            List<FieldToRequiredWrapper> 	fieldwrapperList 	= new List<FieldToRequiredWrapper>();
            
            resInstance.recordTypeName 	= mdt.Label;
            
            if(mdt.All_Fields__c != null){
                for(String field : mdt.All_Fields__c?.split(',')){
                    
                    FieldToRequiredWrapper fieldWrapInstance	= new FieldToRequiredWrapper();
                    fieldWrapInstance.fieldName 				= field;
                    
                    if(mdt.Required_Fields__c != null){
                        if(mdt.Required_Fields__c?.trim() != ''){
                            fieldWrapInstance.isRequired 	= String.valueOf(mdt.Required_Fields__c).containsIgnoreCase(field);
                        }
                    }
                    
                    fieldwrapperList.add(fieldWrapInstance);
                }   
            }
            
            resInstance.isPreSales 	= mdt.Is_Pre_Sales_Required__c;
            resInstance.fields 		= fieldwrapperList;
            
            resultWrapper.metadataResults.add(resInstance);
        }
        
        if( perSalesUserEmails.contains(UserInfo.getUserEmail()) || perSalesUserProfiles.contains(UserInfo.getProfileId()) ){
            resultWrapper.isPreSaleUser = TRUE;
        }
        
        
        system.debug('resultWrapper.metadataResults: '+resultWrapper.metadataResults);
        system.debug('resultWrapper.isPreSaleUser: '+resultWrapper.isPreSaleUser);
        return resultWrapper;
    }
    
    @AuraEnabled
    public static String attachFilesToCase(String recordId, List<object> filesToUpload) {
        String caseNumber;
        if(recordId != NULL && recordId != ''){
            caseNumber = [SELECT Id, CaseNumber FROM Case WHERE Id =: recordId].CaseNumber;
        }
        if(filesToUpload != null){
            if(!filesToUpload.isEmpty()){
                list<Id> lstCntVerIds = new list<Id>();
                List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
                for (Object file : filesToUpload) {
                    FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
                    ContentVersion objCntVersion = new ContentVersion();
                    objCntVersion.PathOnClient = fileData.Title;
                    objCntVersion.Title = fileData.Title;
                    objCntVersion.VersionData = fileData.VersionData;
                    lstVersionsToInsert.add(objCntVersion);
                }
                
                list<Database.saveResult> res = Database.insert(lstVersionsToInsert);
                for (Database.SaveResult saveResult : res) {
                    if(saveResult.isSuccess()) {
                        lstCntVerIds.add(saveResult.getId());
                    }
                }
                
                List<ContentDocumentLink> ctnLinks = new List<ContentDocumentLink>();
                for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: lstCntVerIds]){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cv.ContentDocumentId;
                    cdl.LinkedEntityId = recordId;
                    cdl.ShareType = 'V';
                    ctnLinks.add(cdl);
                }
                insert ctnLinks;
            }
        }
        return caseNumber;
    }
    
    public class Result{
        @AuraEnabled
        public List<ResultWrapper> metadataResults = new List<ResultWrapper>();
        
        @AuraEnabled
        public Boolean isPreSaleUser 	= false;
    }
    
    public class ResultWrapper{
        @AuraEnabled
        public String recordTypeName {get;set;}
        @AuraEnabled
        public List<FieldToRequiredWrapper> fields {get;set;}
        @AuraEnabled
        public Boolean isPreSales = false;
    }
    
    public class FieldToRequiredWrapper{
        @AuraEnabled
        public String fieldName {get;set;}
        @AuraEnabled
        public Boolean isRequired = false;
        
        
    }
    
    public class FileInfo {
        public String Title;
        public Blob VersionData;
    }
}