global class CTX_CPAgreementEsignStatusCheckBatch implements Database.Batchable<sObject>,   Database.AllowsCallouts , schedulable ,Database.RaisesPlatformEvents{
    
    String ESignRequestSent = 'E-Sign Request Sent';
    String ESignStatusSigned = 'signed';
    String EsignCategoryESign = 'E-Sign';
    String EsignCategoryPhysicalSign = 'Physical Sign';

    Map<String, E_Sign_Config__c> eSignConfig = E_Sign_Config__c.getAll();

    global void execute(SchedulableContext sc) {
        CTX_CPAgreementEsignStatusCheckBatch b = new CTX_CPAgreementEsignStatusCheckBatch();

        database.executebatch(b,10);
    }
    String query ;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select ID, Name, ESign_BE_Document_ID__c, ESign_Partner_Status__c, Esign_Order__c,Agreement_Sign_Method__c,E_Sign_Status__c,ESign_CTX_Status__c FROM Account WHERE E_Sign_Status__c =: ESignRequestSent AND((Agreement_Sign_Method__c =:EsignCategoryESign AND(ESign_Partner_Status__c !=: ESignStatusSigned OR ESign_CTX_Status__c !=: ESignStatusSigned))OR(Agreement_Sign_Method__c =:EsignCategoryPhysicalSign AND ESign_CTX_Status__c !=: ESignStatusSigned)) AND ESign_BE_Document_ID__c != null';

        return Database.getQueryLocator(query);
    }

     global void execute(Database.BatchableContext BC, List<Account> listOfESignPendingRecords) {

        for ( Account accRecord : listOfESignPendingRecords){ 
            try {
                //String 
                JSONGenerator eSignJSON = JSON.createGenerator(true);
                eSignJSON.writeStartObject();
                eSignJSON.writeStringField('document_id', accRecord.ESign_BE_Document_ID__c );
                eSignJSON.writeEndObject();
                //Actual CallOut
                HttpResponse response;
                Http htt=new Http();
                HttpRequest req=new httpRequest();
                req.setEndpoint(eSignConfig.get('SecondCall').EndPoint__c);
                req.setMethod(eSignConfig.get('SecondCall').Method__c);
                //req.setTimeout(timeout);
                req.setBody(eSignJSON.getAsString());

                for(String headers:eSignConfig.get('SecondCall').Headers__c.split(',')){
                    req.setHeader(headers.substringBefore(':'),headers.substringAfter(':'));
                }
                System.debug('req '+req.getBody());
                System.debug('req '+req.getEndpoint());
                System.debug('req '+req.getHeader('Host'));
                System.debug('req '+req.getHeader('content-type'));
                
                response=htt.send(req);
                system.debug('Response '+response.getBody());
                //JSONParser parser = JSON.createParser(response.getBody());
                eSignStatusResponseDecoder resultJSON = new eSignStatusResponseDecoder();
                resultJSON = eSignStatusResponseDecoder.parse(response.getBody());
                //Added by Raksha
                if(accRecord.Agreement_Sign_Method__c == EsignCategoryESign){
                    if(accRecord.Esign_Order__c == 'CTX First' && resultJSON.Signer_info[0].signature_sequence == '1'){
                        accRecord.ESign_Partner_Status__c = resultJSON.Signer_info[1].status;
                        accRecord.ESign_CTX_Status__c = resultJSON.Signer_info[0].status;
                    }else if(accRecord.Esign_Order__c == 'CTX First' && resultJSON.Signer_info[1].signature_sequence == '1'){
                        accRecord.ESign_CTX_Status__c = resultJSON.Signer_info[1].status;
                        accRecord.ESign_Partner_Status__c = resultJSON.Signer_info[0].status;
                    }else if(accRecord.Esign_Order__c == 'Client First' && resultJSON.Signer_info[0].signature_sequence == '1'){
                        accRecord.ESign_Partner_Status__c = resultJSON.Signer_info[0].status;
                        accRecord.ESign_CTX_Status__c = resultJSON.Signer_info[1].status;
                    }else if(accRecord.Esign_Order__c == 'Client First' && resultJSON.Signer_info[1].signature_sequence == '1'){
                        accRecord.ESign_Partner_Status__c = resultJSON.Signer_info[1].status;
                        accRecord.ESign_CTX_Status__c = resultJSON.Signer_info[0].status;
                    }
                }else{
                    accRecord.ESign_CTX_Status__c = resultJSON.Signer_info[0].status;
                }
                //End by Raksha
            }
            catch (Exception e) {
                System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() );
            }
        }
        update listOfESignPendingRecords;
    }

    global void finish(Database.BatchableContext BC){
    }
}