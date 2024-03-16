public class CTX_PartnerAgreementESignSender {
    public static void sendOrderFromForESign(set<Id> accountIdsForEsign, set<String> masterEmailSet){
        Map<Id, Account> mapOfAccountForEsignRequest = new Map<Id, Account>([SELECT Id,Name,Agreement_Sign_Method__c,Master_Admin_Email__c,Owner.Name,RecordType.name,CC__c,OTP_For_Electronic_Signature__c,Esign_Order__c, E_Sign_Type__c 
                                                                             FROM Account WHERE Id IN: accountIdsForEsign]);
        
        List<List<ESignRequestCallOutGeneric.valueInitiators>> listOfeSignRequestValues = new List<List<ESignRequestCallOutGeneric.valueInitiators>>();
        Map<String, E_Sign_Config__c> eSignConfig = E_Sign_Config__c.getAll();
        Map<Id,Contact> mapAccountIdToMasterContact = new Map<Id,Contact>();
        
        for(Contact conInst : [SELECT Name, Email,MobilePhone,Phone,AccountId FROM Contact WHERE AccountId IN : mapOfAccountForEsignRequest.keySet() AND Email IN : masterEmailSet]){
            mapAccountIdToMasterContact.put(conInst.AccountId, conInst);
        }
        
        set<Id> contentDocIds = new set<Id>();
        Map<Id,List<ContentVersion>> mapOfAccountIdToContentVersions = new Map<Id,List<ContentVersion>>();
        Map<Id,ContentVersion> mapOfContentDocumentIdContentVersion = new Map<Id, ContentVersion>();
        List<ContentDocumentLink> conDocLinkList= [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId In : mapOfAccountForEsignRequest.keySet() Order By ContentDocument.CreatedDate DESC];
        
        for(ContentDocumentLink cLink : conDocLinkList){
            contentDocIds.add(cLink.ContentDocumentId);  
        }
        System.debug('DocIds: '+contentDocIds);
        
        for(ContentVersion verInst : [SELECT Id,Title,FileType,Type_of_document__c,ContentDocumentId,VersionData,System_Generated__c,CreatedDate FROM ContentVersion WHERE ContentDocumentId IN: contentDocIds AND IsLatest = true AND System_Generated__c = true AND Type_of_document__c =: eSignConfig.get('Type_Of_Doc').Value__c Order By CreatedDate DESC]){
            mapOfContentDocumentIdContentVersion.put(verInst.ContentDocumentId, verInst);
        } 
        System.debug('mapOfContentDocumentIdContentVersion: '+mapOfContentDocumentIdContentVersion);
        for(ContentDocumentLink cLink : conDocLinkList){
            if(mapOfContentDocumentIdContentVersion.get(cLink.ContentDocumentId) != null){
                if(mapOfAccountIdToContentVersions.keySet().contains(cLink.LinkedEntityId)){
                    List<ContentVersion> conVersions = mapOfAccountIdToContentVersions.get(cLink.LinkedEntityId);
                    conVersions.add(mapOfContentDocumentIdContentVersion.get(cLink.ContentDocumentId));
                    mapOfAccountIdToContentVersions.put(cLink.LinkedEntityId, conVersions);
                } else{
                    mapOfAccountIdToContentVersions.put(cLink.LinkedEntityId, new List<ContentVersion>{mapOfContentDocumentIdContentVersion.get(cLink.ContentDocumentId)});
                }   
            }
        }
        System.debug('mapOfAccountIdToContentVersions: '+mapOfAccountIdToContentVersions);
        
        for(Id accountId : mapOfAccountForEsignRequest.keySet()){
            Account accRecord = mapOfAccountForEsignRequest.get(accountId);
            
            if(mapOfAccountIdToContentVersions.containsKey(accountId)){
                List<ESignRequestCallOutGeneric.valueInitiators> listOfeSignRequestValuesInitiators = new List<ESignRequestCallOutGeneric.valueInitiators>();
                
                ContentVersion conVersion = mapOfAccountIdToContentVersions.get(accountId)[0];
                
                ESignRequestCallOutGeneric eSignRequest = new ESignRequestCallOutGeneric();
                
                ESignRequestCallOutGeneric.valueInitiators eSignRequestValueCTX = new ESignRequestCallOutGeneric.valueInitiators();
                
                eSignRequestValueCTX.contentVersionId = conVersion.Id;
                eSignRequestValueCTX.contentVersionFileType = conVersion.FileType;
                eSignRequestValueCTX.contentVersionData = EncodingUtil.base64Encode(conVersion.VersionData);
                eSignRequestValueCTX.contentVersionTitle = conVersion.Title;
                eSignRequestValueCTX.signerType = 'Signer-CTX';
                
                eSignRequestValueCTX.signerEmailId = eSignConfig.get('CTX-Signer-Email-ID').Value__c;
                eSignRequestValueCTX.signerName = eSignConfig.get('CTX-Signer-Name').Value__c;
                eSignRequestValueCTX.signerMobileNo = eSignConfig.get('CTX-Signer-Mobile').Value__c;
                eSignRequestValueCTX.signerId = eSignConfig.get('CTX-Signer-ID').Value__c;
                eSignRequestValueCTX.eSignType = eSignConfig.get('CTX-Signer-Type').Value__c;
                
                
                eSignRequestValueCTX.modeOfOTPForElectronicSignature = eSignConfig.get('CTX-Signer-Mode-Of-OPT').Value__c;
                
                //eSignRequestValueCTX.ccAddress = accRecord.CC__c  ;
                eSignRequestValueCTX.signatureSequence = '1';
                eSignRequestValueCTX.recordId = accRecord.Id;
                eSignRequestValueCTX.docket_description ='For ' +  accRecord.Name + ' - Opportunity Type :'+ accRecord.recordType.name
                    + ' - by CTX Owner :'+accRecord.Owner.Name;
                
                
                if(accRecord.Agreement_Sign_Method__c == 'E-Sign'){
                    eSignRequestValueCTX.eSignType = accRecord.E_Sign_Type__c;
                    
                    Contact masterContact = mapAccountIdToMasterContact.get(accountId);
                    
                    ESignRequestCallOutGeneric.valueInitiators eSignRequestValuesCustomer = new ESignRequestCallOutGeneric.valueInitiators();
                    
                    eSignRequestValuesCustomer.contentVersionId = conVersion.Id;
                    eSignRequestValuesCustomer.contentVersionFileType = conVersion.FileType;
                    eSignRequestValuesCustomer.contentVersionData = EncodingUtil.base64Encode(conVersion.VersionData);
                    eSignRequestValuesCustomer.contentVersionTitle = conVersion.Title;
                    eSignRequestValuesCustomer.signerType = 'Signer-Customer';
                    eSignRequestValuesCustomer.signerId = masterContact.Id;
                    if(masterContact?.Email != null){
                        eSignRequestValuesCustomer.signerEmailId = masterContact.Email;
                    }
                    if(masterContact?.Name != null){
                        eSignRequestValuesCustomer.signerName = masterContact.Name;
                    }
                    if(masterContact?.Phone != null){
                        eSignRequestValuesCustomer.signerMobileNo =  masterContact.Phone;
                    }
                    eSignRequestValuesCustomer.eSignType = accRecord.E_Sign_Type__c;
                    
                    eSignRequestValuesCustomer.modeOfOTPForElectronicSignature = accRecord.OTP_For_Electronic_Signature__c;
                    
                    eSignRequestValuesCustomer.ccAddress = accRecord.CC__c  ;//Pramodh CC
                    eSignRequestValuesCustomer.recordId = accRecord.Id;
                    eSignRequestValueCTX.docket_description ='For ' +  accRecord.Name + ' - Opportunity Type :'+ accRecord.RecordType.name
                        + ' - by CTX Owner :'+accRecord.Owner.Name;
                    If(accRecord.Esign_Order__c == 'Client First'){
                        eSignRequestValuesCustomer.signatureSequence = '1';
                        eSignRequestValueCTX.signatureSequence = '2';
                    }else{
                        eSignRequestValuesCustomer.signatureSequence = '2';
                        eSignRequestValueCTX.signatureSequence = '1';
                    }
                    listOfeSignRequestValuesInitiators.add(eSignRequestValuesCustomer);
                    
                }
                
                listOfeSignRequestValuesInitiators.add(eSignRequestValueCTX);
                
                if(listOfeSignRequestValuesInitiators.size()>0){
                    
                    listOfeSignRequestValues.add(listOfeSignRequestValuesInitiators);
                }   
            } else{
                accRecord.addError(eSignConfig.get('Error-Document').Error_Message__c);
            }
            
        }
        
        If(listOfeSignRequestValues.size()>0){
            CTX_PartnerESignQueueableForCallout tempESignQueueableForCallOut = new CTX_PartnerESignQueueableForCallout(listOfeSignRequestValues);
            System.enqueueJob(tempESignQueueableForCallOut);
        }
    }
}