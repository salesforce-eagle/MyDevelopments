public class CTX_UpsellEsignRequest implements Queueable, Database.AllowsCallouts {
    
    List<Upsell_Top_up__c> 		listOfUpsellsForESignRequest 			= new List<Upsell_Top_up__c>();
    Map<String, String> 		mapOfUpsellToItsESignCustomerId 		= new Map<String, String>();
    String 						eSignType_electronic 					= 'electronic';
    String 						eSignType_aadhar 						= 'aadhar';
    String 						eSignMode_email 						= 'email';
    String 						eSignMode_mobile 						= 'mobile';
    String 						eSignMode_both 							= 'both';
    
    public CTX_UpsellEsignRequest(List<Upsell_Top_up__c> listOfUpsellsForESignRequest, Map<String, String> mapOfUpsellToItsESignCustomerId){
        this.listOfUpsellsForESignRequest 		= listOfUpsellsForESignRequest;
        this.mapOfUpsellToItsESignCustomerId 	= mapOfUpsellToItsESignCustomerId;
    }
    
    
    public void execute(QueueableContext context) {
        
        System.debug('**eSignCallOut**');
        Map<Id,Upsell_Top_up__c> mapOfUpsellForEsignRequest = new Map<Id,Upsell_Top_up__c>(listOfUpsellsForESignRequest);
        Map<Id,Upsell_Top_up__c> mapOfUpsellForEsignRequestDocket = new Map<Id,Upsell_Top_up__c>([SELECT Id, Account__r.Name, Owner.Name
                                                                                                  FROM Upsell_Top_up__c WHERE id IN: listOfUpsellsForESignRequest]);
        List<List<ESignRequestCallOutGeneric.valueInitiators>> listOfeSignRequestValues = new List<List<ESignRequestCallOutGeneric.valueInitiators>>();
        set<Id> setOfUpsIds = new set<Id>();
        set<Id> setOfDocIds = new set<Id>();
        Map<Id,List<Id>> upsellIdWithContentDocId = new Map<Id,List<Id>>();
        Map<Id, List<Quote>> mapOfQuote = new Map<Id, List<Quote>>();
        Map<Id,ContentVersion> versionWithType = new Map<Id,ContentVersion>();
        Map<Id,Quote> mapOfQuotes = new Map<Id,Quote>();
        Map<Id,List<ContentVersion>> entityIdWithContentVersion = new Map<Id,List<ContentVersion>>();
        Map<String, E_Sign_Config__c> eSignConfig = E_Sign_Config__c.getAll();
        Map<Id,ContentVersion> entityIdWithESignContentVersion = new Map<Id,ContentVersion>();
        
        Map<Id,Contact> mapOfCustomerContacts = new Map<Id,Contact>([SELECT id, name, email,mobilephone,phone from Contact WHERE id IN: mapOfUpsellToItsESignCustomerId.values()]);
        System.debug('@mapOfCustomerContacts '+mapOfCustomerContacts);
        
        List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId,LinkedEntityId 
                                                    FROM ContentDocumentLink WHERE LinkedEntityId IN: mapOfUpsellForEsignRequest.keySet() ];
        System.debug('@contentDocList '+contentDocList);
        
        for(ContentDocumentLink tempContent : contentDocList){
            setOfDocIds.add(tempContent.ContentDocumentId);
            if(upsellIdWithContentDocId.containsKey(tempContent.LinkedEntityId)){
                List<Id> newListValue = upsellIdWithContentDocId.get(tempContent.LinkedEntityId);
                newListValue.add(tempContent.ContentDocumentId);
                upsellIdWithContentDocId.put(tempContent.LinkedEntityId,newListValue);
            }else{
                upsellIdWithContentDocId.put(tempContent.LinkedEntityId,new list<Id>{tempContent.ContentDocumentId});
            }
            
        }
        System.debug('@upsellIdWithContentDocId '+upsellIdWithContentDocId);
        
        List<ContentVersion> contentverList = [SELECT Id,Title,FileType,Type_of_document__c,
                                               ContentDocumentId,VersionData,System_Generated__c,CreatedDate  
                                               FROM ContentVersion 
                                               WHERE ContentDocumentId IN: setOfDocIds AND IsLatest = true AND
                                               Type_of_document__c =: eSignConfig.get('Type_Of_Doc_Addendum').Value__c];
        for(ContentVersion tempVersion : contentverList){
            versionWithType.put(tempVersion.ContentDocumentId, tempVersion );
        }
        
        for(Id upsellId : upsellIdWithContentDocId.keySet()){
            for(Id tempContentId : versionWithType.keySet()){
                if(upsellIdWithContentDocId.get(upsellId).Contains(tempContentId)){
                    if(entityIdWithContentVersion.containsKey(upsellId)){
                        List<ContentVersion> newListValue = entityIdWithContentVersion.get(upsellId);
                        newListValue.add(versionWithType.get(tempContentId));
                        entityIdWithContentVersion.put(upsellId,newListValue);
                    }else{
                        entityIdWithContentVersion.put(upsellId,new list<ContentVersion>{versionWithType.get(tempContentId)});
                    }
                }
            }
        }

        for(String upsellId : entityIdWithContentVersion.keySet()){
            Upsell_Top_up__c upsellRecord = mapOfUpsellForEsignRequest.get(upsellId);
            List<ContentVersion> contentVersions = entityIdWithContentVersion.get(upsellId);
            for(ContentVersion cv : contentVersions){
                System.debug('@cv '+cv);
                if(entityIdWithESignContentVersion.containsKey(upsellId)){
                    System.debug('^ Existing CreatedDate '+entityIdWithESignContentVersion.get(upsellId).CreatedDate);
                }
                
                if(upsellRecord.ESign_Category__c == 'Physical Sign' && cv.System_Generated__c == false){
                    if((!entityIdWithESignContentVersion.containsKey(upsellId)) || (entityIdWithESignContentVersion.containsKey(upsellId) && entityIdWithESignContentVersion.get(upsellId).CreatedDate < cv.CreatedDate)){
                        entityIdWithESignContentVersion.put(upsellId, cv);
                    }
                }else if(upsellRecord.ESign_Category__c == 'E-Sign' && cv.System_Generated__c == true ){
                    if((!entityIdWithESignContentVersion.containsKey(upsellId)) || (entityIdWithESignContentVersion.containsKey(upsellId) && entityIdWithESignContentVersion.get(upsellId).CreatedDate < cv.CreatedDate)){
                        entityIdWithESignContentVersion.put(upsellId, cv);
                    }
                }
            }
        }
        
        
        for(Upsell_Top_up__c thisUpsell : listOfUpsellsForESignRequest){
            List<ESignRequestCallOutGeneric.valueInitiators> listOfeSignRequestValuesInitiators = new List<ESignRequestCallOutGeneric.valueInitiators>();
            
            if(entityIdWithContentVersion.containsKey(thisUpsell.Id)){
                
                
                System.debug('@ContentVersion '+entityIdWithESignContentVersion.get(thisUpsell.Id));
                ESignRequestCallOutGeneric eSignRequest = new ESignRequestCallOutGeneric();
                /** ESignRequest <> CTX **/
                ESignRequestCallOutGeneric.valueInitiators eSignRequestValueCTX = new ESignRequestCallOutGeneric.valueInitiators();
                eSignRequestValueCTX.contentVersionId = entityIdWithESignContentVersion.get(thisUpsell.Id).Id;
                eSignRequestValueCTX.contentVersionFileType = entityIdWithESignContentVersion.get(thisUpsell.Id).FileType; 
                eSignRequestValueCTX.contentVersionData = EncodingUtil.base64Encode(entityIdWithESignContentVersion.get(thisUpsell.Id).VersionData);
                eSignRequestValueCTX.contentVersionTitle = entityIdWithESignContentVersion.get(thisUpsell.Id).Title;
                eSignRequestValueCTX.signerType = 'Signer-CTX';
                eSignRequestValueCTX.signerId = eSignConfig.get('CTX-Signer-ID').Value__c;
                eSignRequestValueCTX.eSignType = eSignConfig.get('CTX-Signer-Type').Value__c;
                if(thisUpsell.ESign_Category__c == 'E-Sign'){
                    eSignRequestValueCTX.eSignType = eSignType_electronic;
                }
                eSignRequestValueCTX.signerEmailId = eSignConfig.get('CTX-Signer-Email-ID1').Value__c;
                eSignRequestValueCTX.signerName = eSignConfig.get('CTX-Signer-Name1').Value__c;
                eSignRequestValueCTX.signerMobileNo = eSignConfig.get('CTX-Signer-Mobile1').Value__c;
                System.debug('eSignConfig CTX-Signer-Mode-Of-OPT '+eSignConfig.get('CTX-Signer-Mode-Of-OPT').Value__c);
                if(thisUpsell.OTP_For_Electronic_Signature__c == 'Email'){
                    eSignRequestValueCTX.modeOfOTPForElectronicSignature = eSignMode_email;
                }else if(thisUpsell.OTP_For_Electronic_Signature__c == 'Mobile'){
                    eSignRequestValueCTX.modeOfOTPForElectronicSignature = eSignMode_mobile;
                }else if(thisUpsell.OTP_For_Electronic_Signature__c == 'Both'){
                    eSignRequestValueCTX.modeOfOTPForElectronicSignature = eSignMode_both;
                }
                System.debug(' eSignRequestValueCTX.modeOfOTPForElectronicSignature '+ eSignRequestValueCTX.modeOfOTPForElectronicSignature);
                eSignRequestValueCTX.ccAddress = thisUpsell.Esign_CC_Email_Address__c;
                eSignRequestValueCTX.signatureSequence = '1';
                eSignRequestValueCTX.recordId = thisUpsell.Id;
                eSignRequestValueCTX.docket_description ='For ' +  mapOfUpsellForEsignRequestDocket.get(thisUpsell.id).Account__r.Name 
                    + ' - by CTX Owner :'+mapOfUpsellForEsignRequestDocket.get(thisUpsell.id).Owner.Name+' for Topup Name :'+ thisUpsell.name + ' of Price '+ thisUpsell.Additional_Price__c ; 
                
                /** ESignRequest <> Client **/
                if(thisUpsell.ESign_Category__c == 'E-Sign'){
                    System.debug('@thisUpsell '+thisUpsell);
                    ESignRequestCallOutGeneric.valueInitiators eSignRequestValuesCustomer = new ESignRequestCallOutGeneric.valueInitiators();
                    eSignRequestValuesCustomer.contentVersionId = entityIdWithESignContentVersion.get(thisUpsell.Id).Id;
                    eSignRequestValuesCustomer.contentVersionFileType = entityIdWithESignContentVersion.get(thisUpsell.Id).FileType;
                    eSignRequestValuesCustomer.contentVersionData = EncodingUtil.base64Encode(entityIdWithESignContentVersion.get(thisUpsell.Id).VersionData);
                    eSignRequestValuesCustomer.contentVersionTitle = entityIdWithESignContentVersion.get(thisUpsell.Id).Title;
                    eSignRequestValuesCustomer.signerType = 'Signer-Customer';
                    eSignRequestValuesCustomer.signerId = thisUpsell.E_Sign_Customer_Info__c;
                    if(mapOfCustomerContacts.containsKey(thisUpsell.E_Sign_Customer_Info__c) && mapOfCustomerContacts.get(thisUpsell.E_Sign_Customer_Info__c).email != null){
                        eSignRequestValuesCustomer.signerEmailId = mapOfCustomerContacts.get(thisUpsell.E_Sign_Customer_Info__c).Email;
                    }
                    if(mapOfCustomerContacts.containsKey(thisUpsell.E_Sign_Customer_Info__c) && mapOfCustomerContacts.get(thisUpsell.E_Sign_Customer_Info__c).name != null){
                        eSignRequestValuesCustomer.signerName = mapOfCustomerContacts.get(thisUpsell.E_Sign_Customer_Info__c).name;
                    }
                    if(mapOfCustomerContacts.containsKey(thisUpsell.E_Sign_Customer_Info__c) && mapOfCustomerContacts.get(thisUpsell.E_Sign_Customer_Info__c).Phone != null){
                        eSignRequestValuesCustomer.signerMobileNo =  mapOfCustomerContacts.get(thisUpsell.E_Sign_Customer_Info__c).Phone;
                    }
                    
                    eSignRequestValuesCustomer.eSignType = eSignType_electronic;
                    if(thisUpsell.OTP_For_Electronic_Signature__c == 'Email'){
                        eSignRequestValuesCustomer.modeOfOTPForElectronicSignature = eSignMode_email;
                    }else if(thisUpsell.OTP_For_Electronic_Signature__c == 'Mobile'){
                        eSignRequestValuesCustomer.modeOfOTPForElectronicSignature = eSignMode_mobile;
                    }else if(thisUpsell.OTP_For_Electronic_Signature__c == 'Both'){
                        eSignRequestValuesCustomer.modeOfOTPForElectronicSignature = eSignMode_both;
                    }
                    
                    If(thisUpsell.Esign_Order__c == 'Client First'){
                        eSignRequestValuesCustomer.signatureSequence = '1';
                        eSignRequestValueCTX.signatureSequence = '2';
                    }else{
                        eSignRequestValuesCustomer.signatureSequence = '2';
                        eSignRequestValueCTX.signatureSequence = '1';
                    }
                    
                    eSignRequestValuesCustomer.ccAddress = thisUpsell.Esign_CC_Email_Address__c;
                    eSignRequestValuesCustomer.recordId = thisUpsell.Id;
                    
                    listOfeSignRequestValuesInitiators.add(eSignRequestValuesCustomer);
                    System.debug('eSignRequestValuesCustomer '+eSignRequestValuesCustomer);
                }
                System.debug('eSignRequestValueCTX '+eSignRequestValueCTX);
                listOfeSignRequestValuesInitiators.add(eSignRequestValueCTX);
            }else{
                thisUpsell.addError(eSignConfig.get('Error-Document').Error_Message__c);
            }
            
            
            
            if(listOfeSignRequestValuesInitiators.size()>0){
                listOfeSignRequestValues.add(listOfeSignRequestValuesInitiators);
            }
        }
        
        If(listOfeSignRequestValues.size()>0){
            System.debug('@listOfeSignRequestValues Size '+listOfeSignRequestValues.size());
            System.debug('@listOfeSignRequestValues '+listOfeSignRequestValues);
            ESignQueueableForCallOut tempESignQueueableForCallOut = new ESignQueueableForCallOut(listOfeSignRequestValues);
            System.enqueueJob(tempESignQueueableForCallOut);
        }
    }
}