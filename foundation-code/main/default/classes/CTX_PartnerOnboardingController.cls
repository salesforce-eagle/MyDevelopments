global without sharing class CTX_PartnerOnboardingController {
    
    @AuraEnabled
    global static void createPartnerAccount(Map<String, String> accountDetails, Map<String, String> contactDetails, List<Object> fileDetails){
        try{
            if(!accountDetails.keySet().isEmpty()){
                accountDetails.put('RecordTypeId', AccountConstants.CHANNEL_PARTNER_RecordTypeId);
                Account accountToInsert = (Account)createDynamicObjectInstance('Account', accountDetails);
                insert accountToInsert;
                
                if(fileDetails != null){
                    if(!fileDetails.isEmpty()){
                        list<Id> lstCntVerIds = new list<Id>();
                        List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
                        for (Object file : fileDetails) {
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
                            cdl.LinkedEntityId = accountToInsert.Id;
                            cdl.ShareType = 'V';
                            ctnLinks.add(cdl);
                        }
                        insert ctnLinks;
                    }
                }
                
                if(!contactDetails.keySet().isEmpty()){
                    contactDetails.put('AccountId', accountToInsert.Id);
                    Contact contactToInsert = (Contact)createDynamicObjectInstance('Contact', contactDetails);
                	insert contactToInsert;
                }
            }
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    @AuraEnabled
    global static void createFiles(String accountId, List<Object> fileDetails){
        if(fileDetails != null){
            if(!fileDetails.isEmpty()){
                list<Id> lstCntVerIds = new list<Id>();
                List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
                for (Object file : fileDetails) {
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
                    cdl.LinkedEntityId = accountId;
                    cdl.ShareType = 'V';
                    ctnLinks.add(cdl);
                }
                insert ctnLinks;
            }
        }
    }
    
    global static sObject createDynamicObjectInstance(String objectName, Map<String, String> fieldNameValueMap){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        sObject sObjectInstance = Schema.getGlobalDescribe().get(objectName).newSObject() ;
        for(String field : fieldNameValueMap.keySet()){
            Schema.DisplayType fieldtype = fieldMap.get(field).getDescribe().getType();
            String value = fieldNameValueMap.get(field);
            if(fieldtype == Schema.DisplayType.BOOLEAN){
                boolean bvalue = value.toUpperCase().equals('TRUE');
                sObjectInstance.put(field, bvalue);                                                                       
            }
            else if(fieldtype == Schema.DisplayType.DATE){
                sObjectInstance.put(field, date.valueOf(value));
            }
            else if(fieldtype == Schema.DisplayType.DATETIME){
                sObjectInstance.put(field, Datetime.valueOfGmt(value));
            }
            else if(fieldtype == Schema.DisplayType.ID){
                if(value == ''){
                    sObjectInstance.put(field, null);
                }
                else{
                    sObjectInstance.put(field, String.valueOf(value));
                }
            }
            else if(fieldtype == Schema.DisplayType.REFERENCE){
                if(value == ''){
                    sObjectInstance.put(field, null);
                }
                else{
                    sObjectInstance.put(field, String.valueOf(value));
                }
            }
            else if(fieldtype == Schema.DisplayType.DOUBLE || fieldtype == Schema.DisplayType.PERCENT){
                if(value.contains('.')){
                    sObjectInstance.put(field, double.valueOf(value));
                }
                else{
                    sObjectInstance.put(field, double.valueOf(long.valueOf(value)));
                }
            }
            else{
                sObjectInstance.put(field, value);
            }
        }
        
        return sObjectInstance;
    }
    
    global class FileInfo {
        public String Title;
        public Blob VersionData;
    }
}