@RestResource(urlMapping='/cleartax/individualcallback/*')
global class CTX_Esign_IndividualCallbackAPI
{
    
    @HttpPost
    global static String doPost() {

        Map<String, Object> obj = (Map<String, Object>)System.JSON.deserializeUntyped( 
            RestContext.request.requestBody.toString()
        );
        
        List<Logger__c>					entryLoggerRecords			= new List<Logger__c>();
        Map<String, E_Sign_Config__c> 	eSignConfig                 = E_Sign_Config__c.getAll();
        String                          docketId                    = String.ValueOf(obj.get('docket_id'));
        String                          document_id                 = String.ValueOf(obj.get('document_id'));
        String                          file_content                = String.ValueOf(obj.get('file_content'));
        List<ContentDocumentLink> 	    listOfContentLink 			= new List<ContentDocumentLink>();
        
        ReturnWrapper                   RWIns;  
        
        List<Opportunity>               tempOpp     = [SELECT id,ESign_BE_Docket_ID__c,ESign_BE_Reference_Doc_ID__c,Esign_Order__c,
                                                       ESign_CTX_Status__c,ESign_Sign_Status__c,ESign_Category__c
                                                       FROM opportunity WHERE ESign_BE_Docket_ID__c =:docketId LIMIT 1];
        if(tempOpp.Size() > 0)
        {
            /**Id                         ContentId    = tempOpp[0]?.ESign_BE_Reference_Doc_ID__c ;
            
            List<ContentVersion>        CV          = [SELECT Id, ContentLocation, PathOnClient, Title, Type_of_document__c
                                                       FROM ContentVersion WHERE 
                                                       Id =: ContentId LIMIT 1];**/
            /**	Create Document Version	**/
            //system.debug('CVList :' + ContentId);
            //system.debug('CVList :' + CV);
            //if(CV.Size() > 0){
               /** ContentVersion contentVersion_2 = new ContentVersion(
                    
                    Title					= CV[0].Title,
                    PathOnClient 			= CV[0].PathOnClient,
                    VersionData 			= EncodingUtil.base64Decode(file_content),
                    Origin 					= 'H',
                    Lock_Content_Version__c = TRUE,
                    Type_of_document__c 	= eSignConfig.get('Type_Of_Doc').Value__c
                );**/
                
                try{
                    /**insert contentVersion_2;
                    ContentDocumentLink contentlink = new ContentDocumentLink();
                    Contentlink.LinkedEntityId      = tempOpp[0].ID; 
                    Contentlink.ContentDocumentId   = [SELECT ContentDocumentId FROM ContentVersion 
                                                        WHERE Id =: contentVersion_2.Id ]?.ContentDocumentId;
                    contentlink.ShareType           = 'V';
                    listOfContentLink.add(contentlink);
                    insert listOfContentLink;**/
                    //tempOpp[0].ESign_Doc_Updated__c         = true;
                    if((tempOpp[0].ESign_CTX_Status__c != 'signed' && tempOpp[0].Esign_Order__c == 'CTX First') ||
                       (tempOpp[0].ESign_CTX_Status__c != 'signed' && tempOpp[0].Esign_Order__c == 'Client First' && tempOpp[0].ESign_Sign_Status__c == 'signed') 
                       || tempOpp[0].ESign_Category__c == 'Physical Sign'){
                    tempOpp[0].ESign_CTX_Status__c          = 'signed';
                    }
                    else{
                    tempOpp[0].ESign_Sign_Status__c         = 'signed';
                    }
                   // tempOpp[0].E_Sign_Status__c             = 'E-Sign Successful';
                    //tempOpp[0].ESign_BE_Reference_Doc_ID__c = contentVersion_2.Id;
                    Update tempOpp;
                    RWIns = new ReturnWrapper('success', docketId, document_id, 'NA', 'NA' );
                } 
                catch(Exception ex){
                    entryLoggerRecords.add(
                        CTX_LoggerImplementation.createLoggerInstance(
                            ex.getMessage(), 
                            'ClassId', 
                            'CTX_Esign_Callback_Sync_API', 
                            'Post From SD', 
                            'ContentVersion/Document insert fail',
                            NULL,
                            'ContentVersion/Document'
                        )
                    );
                    RWIns = new ReturnWrapper('failed', docketId, document_id, ex.getMessage(), ex.getTypeName() );  
                }
           // }
            
            
            /**else{
                entryLoggerRecords.add(
                        CTX_LoggerImplementation.createLoggerInstance(
                            'NDF', 
                            'ClassId', 
                            'CTX_Esign_Callback_Sync_API', 
                            'Post From SD', 
                            'No Document found with document_id: '+document_id,
                             NULL,
                            'ContentDocument'
                        )
                    );
                RWIns = new ReturnWrapper('failed', docketId, document_id, 'No Document found with document_id: '+document_id, 'NDF' );
            }**/
        }
        else{
                            entryLoggerRecords.add(
                        CTX_LoggerImplementation.createLoggerInstance(
                            'NDF', 
                            'ClassId', 
                            'CTX_Esign_Callback_Sync_API', 
                            'Post From SD', 
                            'No record found with docket_id: '+docketId,
                            NULL,
                            'Docket Not found'
                        )
                    );
            RWIns = new ReturnWrapper('failed', docketId, document_id, 'No record found with docket_id: '+docketId, 'NDF' );
        }
        
        
        try{
            insert entryLoggerRecords;
        } catch(Exception ex){
            system.debug('Logger Insert Fail in CTX_Esign_Callback_Sync_API: '+ex.getMessage());
        }        
        
        return JSON.serialize(RWIns);
    }
    
    public class ReturnWrapper
    {
        String status;
        String docket_id;
        String document_id;
        String error;
        String error_code;
        
        public ReturnWrapper( String status, String docket_id, String document_id, String error, String error_code )
        {
            this.status       =    status;
            this.docket_id    =    docket_id;
            this.document_id  =    document_id;
            this.error        =    error;
            this.error_code   =    error_code;
        }
    }
    
}