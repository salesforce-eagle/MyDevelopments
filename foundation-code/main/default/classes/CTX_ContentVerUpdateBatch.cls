global class CTX_ContentVerUpdateBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts, Database.RaisesPlatformEvents{
    
    String 							ESignRequestSent 			= 'E-Sign Request Sent';
    String 							ESignStatusSigned 			= 'signed';
    String 							EsignCategoryESign 			= 'E-Sign';
    String 							EsignCategoryPhysicalSign 	= 'Physical Sign';
    Map<String, E_Sign_Config__c> 	eSignConfig 				= E_Sign_Config__c.getAll();
    List<Logger__c>					entryLoggerRecords			= new List<Logger__c>();
    String 							objectName;
    
    String query = 'SELECT ID, Name, ESign_Doc_Updated__c, ESign_BE_Document_ID__c, ESign_BE_Docket_ID__c,' 
        +' ESign_BE_Reference_Doc_ID__c, E_Sign_Status__c, ESign_Category__c, ESign_Client_Status__c, ESign_CTX_Status__c';
    
    global CTX_ContentVerUpdateBatch(String ObjectName){
    	this.ObjectName = ObjectName;   
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Set<Id> objectIdsWithError = new Set<Id>();
        for(
            Logger__c thisRec : [ SELECT Record_Id__c 
                                 FROM Logger__c WHERE 
                                 Object_Name__c = : ObjectName AND 
                                 Apex_Class__c = 'CTX_ContentVerUpdateBatch' ]
        ){
            objectIdsWithError.add(thisRec.Record_Id__c);
        }
        
        query = query +' FROM '+ objectName + ' WHERE '
            +' E_Sign_Status__c =: ESignRequestSent AND '
            +' ((ESign_Category__c =:EsignCategoryESign AND ESign_Client_Status__c =: ESignStatusSigned AND '
            +' ESign_CTX_Status__c =: ESignStatusSigned)OR(ESign_Category__c =:EsignCategoryPhysicalSign AND '
            +' ESign_CTX_Status__c =: ESignStatusSigned)) AND ESign_Doc_Updated__c = false AND '
            +' ( NOT Id IN :objectIdsWithError ) LIMIT '+System.label.ESignDocUpdateBatchQueryLimit;
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> listOfESignPendingRecords) {
        
        set<Id> 				contentIds 					= new set<Id>();
        Map<string,String> 			mapOfDocResults 			= new Map<string,String>();
        Map<Object,sObject> 	mapOfDocWithsObject 			= new Map<Object,sObject>();
        List<ContentDocumentLink> 	listOfContentLink 			= new List<ContentDocumentLink>();
        
        
        
        for(Sobject objInst : listOfESignPendingRecords){
            contentIds.add((Id)objInst.get('ESign_BE_Reference_Doc_ID__c'));
            mapOfDocWithsObject.put(objInst.get('ESign_BE_Document_ID__c'),objInst);
        }
        
        Map<Id,ContentVersion> mapOfContentVersion = 
            new Map<Id,ContentVersion>([ SELECT Id, ContentLocation, PathOnClient, Title, Type_of_document__c 
                                        FROM ContentVersion WHERE 
                                        Id IN : contentIds]);//currentAccountRecord.ESign_BE_Reference_Doc_ID__c
        
        for ( sObject objInst : listOfESignPendingRecords){
            
            try {
                
                HTTP 			htt	= new HTTP();
                HTTPResponse 	response;
                HTTPRequest 	req	= new HTTPRequest();
                
                JSONGenerator eSignJSON = JSON.createGenerator(true);
                eSignJSON.writeStartObject();
                eSignJSON.writeStringField('document_id', String.valueOf(objInst.get('ESign_BE_Document_ID__c')));
                eSignJSON.writeStringField('docket_id', String.valueOf(objInst.get('ESign_BE_Docket_ID__c')));
                eSignJSON.writeEndObject();
                req.setEndpoint(eSignConfig.get('ThirdCall').EndPoint__c);
                req.setMethod(eSignConfig.get('ThirdCall').Method__c);
                req.setBody(eSignJSON.getAsString());
                
                for(String headers:eSignConfig.get('ThirdCall').Headers__c.split(',')){
                    req.setHeader(headers.substringBefore(':'),headers.substringAfter(':'));
                }
                
                System.debug('req '+req.getBody());
                System.debug('req '+req.getEndpoint());
                System.debug('req '+req.getHeader('Host'));
                System.debug('req '+req.getHeader('content-type'));
                
                response=htt.send(req);
                system.debug('Response '+response.getBody());
                
                if(response.getStatusCode () == 200 ){
                    ESignCustomerSignedDocDecoder resultJSON = new ESignCustomerSignedDocDecoder();
                    resultJSON = ESignCustomerSignedDocDecoder.parse(response.getBody());
                    mapOfDocResults.put(resultJSON.docket_Info[0].document_id,resultJSON.docket_Info[0].content);
                } else{
                    entryLoggerRecords.add(CTX_LoggerImplementation.createLoggerInstance('Callout Not Succeeded', 'ClassId', 'CTX_ContentVerUpdateBatch', 'Batch execute', 'Callout not Successful', String.valueOf(objInst.get('Id')), 'SignDesk'));
                }
            } catch (Exception e) {
                entryLoggerRecords.add(CTX_LoggerImplementation.createLoggerInstance(e.getMessage(), 'ClassId', 'CTX_ContentVerUpdateBatch', 'Batch execute', 'Callout Fail', String.valueOf(objInst.get('Id')), 'SignDesk'));
                System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() );
            }
        }
        
        for( sObject objInst : listOfESignPendingRecords){
            
            /**	Create Document Version	**/
            ContentVersion contentVersion_2 = new ContentVersion(
                Title					= mapOfContentVersion.get((Id)objInst.get('ESign_BE_Reference_Doc_ID__c')).Title,
                PathOnClient 			= mapOfContentVersion.get((Id)objInst.get('ESign_BE_Reference_Doc_ID__c')).PathOnClient,
                VersionData 			= EncodingUtil.base64Decode(mapOfDocResults.get(String.valueOf(objInst.get('ESign_BE_Document_ID__c')))),
                Origin 					= 'H',
                Lock_Content_Version__c = TRUE,
                Type_of_document__c 	= eSignConfig.get('Type_Of_Doc').Value__c
            );
            
            try{
                insert contentVersion_2;
            } catch(Exception ex){
                entryLoggerRecords.add(CTX_LoggerImplementation.createLoggerInstance(ex.getMessage(), 'ClassId', 'CTX_ContentVerUpdateBatch', 'Batch execute', 'ContentVersion insert fail', NULL, 'ContentVersion'));
            }
            
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = (Id)objInst.get('Id'); 
            contentlink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion 
                                             WHERE Id =: contentVersion_2.Id ].ContentDocumentId;
            contentlink.ShareType = 'V';
            listOfContentLink.add(contentlink);
            objInst.put('ESign_Doc_Updated__c', true);
            objInst.put('E_Sign_Status__c', 'E-Sign Successful');
            objInst.put('ESign_BE_Reference_Doc_ID__c', contentVersion_2.Id);
        }
        
        try{
            insert listOfContentLink;
        } catch(Exception ex){
            entryLoggerRecords.add(CTX_LoggerImplementation.createLoggerInstance(ex.getMessage(),String.valueOf(this), 'CTX_ContentVerUpdateBatch', 'Batch execute', 'ContentDocumentLink insert fail', String.valueOf(listOfESignPendingRecords[0].Id), 'ContentDocumentLink'));
        }
        
        try{
            update listOfESignPendingRecords;
        } catch(Exception ex){
            entryLoggerRecords.add(CTX_LoggerImplementation.createLoggerInstance(ex.getMessage(), String.valueOf(this), 'CTX_ContentVerUpdateBatch', 'Batch execute', 'Account Update Fail', String.valueOf(listOfESignPendingRecords[0].Id), 'Account'));
        }
        
        try{
            insert entryLoggerRecords;
        } catch(Exception ex){
            system.debug('Logger Insert Fail in CTX_ContentVerUpdateBatch: '+ex.getMessage());
        }
        
    }
    
    global void finish(Database.BatchableContext BC){}


}