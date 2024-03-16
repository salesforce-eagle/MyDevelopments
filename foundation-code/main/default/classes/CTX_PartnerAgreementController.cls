public class CTX_PartnerAgreementController {
    public String startDate{get;set;}
    public String endDate{get;set;}
    public String accountId{get;set;}
    public String urlRec {get;set;}
    public Account accInst {get;set;}
    public Contact primaryContact {get;set;}
    public String stampRefNumber {get;set;}
    public String billingAddress {get;set;}
    
    public CTX_PartnerAgreementController (ApexPages.StandardController controller){
        accountId = ApexPages.currentPage().getParameters().get('id');
        try{
            accInst = [SELECT Id, Name, Effective_from__c, Expiry_Date__c, Master_admin_Email__c, 
                       BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, 
                       Commission_New_Sales__c, Commission_Renewal_Sales__c, 
                       Commission_Performance_Incentive__c, CIN_code__c
                       FROM Account WHERE Id =: accountId];
            if(accInst != null){
                startDate = DateTime.newInstance(accInst.Effective_from__c.year(), accInst.Effective_from__c.month(), accInst.Effective_from__c.day()).format('MMMM d yyyy');
                endDate =  DateTime.newInstance(accInst.Expiry_Date__c.year(), accInst.Expiry_Date__c.month(), accInst.Expiry_Date__c.day()).format('MMMM d yyyy');
                billingAddress = accInst.BillingStreet + ', ' + accInst.BillingCity + ', ' + accInst.BillingState + ', ' + accInst.BillingCountry + ' - ' + accInst.BillingPostalCode;
                primaryContact = [SELECT Id, Name, Designation__c FROM Contact WHERE AccountId =:accountId AND Email=:accInst.Master_admin_Email__c LIMIT 1];
            }
        }catch(Exception ex){
            
        }
        
        try{
            String currentUser = UserInfo.getName();
            set<Id> contentDocIds = new set<Id>();
            
            for(ContentDocumentLink cLink : [SELECT Id, ContentDocumentId, ContentDocument.Title, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: accountId AND ContentDocument.CreatedById =: UserInfo.getUserId() AND ContentDocument.FileType = 'PNG' ORDER BY ContentDocument.CreatedDate DESC]){
                contentDocIds.add(cLink.ContentDocumentId);
            }
            
            ContentVersion conVersion = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentVersion WHERE ContentDocumentId IN : contentDocIds AND Type_of_document__c='Stamp' Order By CreatedDate DESC LIMIT 1];
			stampRefNumber = conVersion.ContentDocument.Title;
            urlRec = [SELECT Id, ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId =: conVersion.ContentDocumentId ].ContentDownloadUrl;
            
        }catch(Exception ex){
            
        }
    }
    
    @AuraEnabled
    public static String saveStampReferance(String accountId, Object fileToUpload){
        Id conVersionId;
        try{
            FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(fileToUpload), FileInfo.class);
            
            ContentVersion objCntVersion = new ContentVersion();
            objCntVersion.PathOnClient = fileData.Title + '.png';
            objCntVersion.Title = fileData.Title;
            objCntVersion.Type_of_document__c = 'Stamp';
            objCntVersion.VersionData = fileData.VersionData;
            insert objCntVersion;
            
            conVersionId = objCntVersion.Id;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            Id cdId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE id = : objCntVersion.id].ContentDocumentId;
            cdl.ContentDocumentId = cdId;
            cdl.LinkedEntityId = accountId;
            cdl.ShareType = 'V';
            insert cdl;
            
            ContentDistribution cn = new ContentDistribution(Name= fileData.Title,ContentVersionId=objCntVersion.Id);
            insert cn;
            
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }        
        return conVersionId;
    }
    
    @AuraEnabled
    public Static String generatePartnerAgreement(String accountId){
        Id conDoc;
        try{
            String accountName = [SELECT Id, Name FROM Account WHERE Id =: accountId].Name;
            PageReference ref = new PageReference('/apex/CTX_PartnerAgreementPDF?id=' + accountId);
            String fileName = accountName + '-' + 'Agreement';
            System.debug('###fileName: '+fileName);
            ContentVersion objCntVersion1 = new ContentVersion();
            objCntVersion1.PathOnClient = fileName + '.pdf';
            objCntVersion1.Title =  fileName;
            objCntVersion1.Type_of_document__c = 'Order Form';
            ObjCntVersion1.System_Generated__c = true;
            if(!Test.isRunningTest()){
                objCntVersion1.VersionData = ref.getContentAsPDF();
            } else{
                objCntVersion1.VersionData = blob.valueOf('Unit.Test');
            }
            
            insert objCntVersion1;
            
            ContentDocumentLink cdl1 = new ContentDocumentLink();
            conDoc = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE id = : objCntVersion1.Id].ContentDocumentId;
            cdl1.ContentDocumentId = conDoc;
            cdl1.LinkedEntityId = accountId;
            cdl1.ShareType = 'V';
            insert cdl1;
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return conDoc;
    }
    
    @AuraEnabled
    public static String uploadOrderFormManually(String accountId, Object fileToUpload){
        String accountName = [SELECT Id, Name FROM Account WHERE Id =: accountId].Name;
        Id cdId;
        String fileName = accountName + '-' + 'Agreement';
        try{
            FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(fileToUpload), FileInfo.class);
            
            ContentVersion objCntVersion = new ContentVersion();
            objCntVersion.PathOnClient = fileName+'.pdf';
            objCntVersion.Title = fileName;
            objCntVersion.Type_of_document__c = 'Order Form';
            ObjCntVersion.System_Generated__c = true;
            objCntVersion.VersionData = fileData.VersionData;
            insert objCntVersion;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE id = : objCntVersion.id].ContentDocumentId;
            cdl.ContentDocumentId = cdId;
            cdl.LinkedEntityId = accountId;
            cdl.ShareType = 'V';
            insert cdl;
            
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }        
        return cdId;
    }
    
    public class FileInfo {
        public String Title;
        public Blob VersionData;
    }
}