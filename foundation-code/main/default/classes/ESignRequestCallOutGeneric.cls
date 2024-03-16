/**
 * @description       : 
 * @author            : pramodh@warpdrivetech.in
 * @group             : 
 * @last modified on  : 02-16-2021
 * @last modified by  : pramodh@warpdrivetech.in
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   01-21-2021   pramodh@warpdrivetech.in   Initial Version
**/
public class ESignRequestCallOutGeneric {
    public class valueInitiators{
        public string contentVersionId;
        public string contentVersionFileType;
        public string contentVersionData;
        public string contentVersionTitle;
        public string signerType;//Cutomer or CTX
        public string signerId;//Contact or User
        public string signerEmailId;
        public string signerName;
        public string signerMobileNo;
        public string eSignType;
        public string recordId;
        public string signatureSequence;
        public String modeOfOTPForElectronicSignature;
        public String ccAddress;
        public String docket_description;
        public Boolean descrption_in_invitation;
    }
    //@future(callOut = true)
    public string requestCallOut(List<valueInitiators> inputs){
        try{
            System.debug('#*# requestCallOut() ');
            //Custom Setting 
            Map<String, E_Sign_Config__c> eSignConfig = E_Sign_Config__c.getAll();
            //String quoteId;
            String oppId;
            //JSON Generator
            eSignJSONGenerator eSignJSON = new eSignJSONGenerator();
            eSignJSONGenerator.Documents eSignJSONDoc = new eSignJSONGenerator.Documents();
            List<eSignJSONGenerator.Appearance> eSignJSONAppear = new List<eSignJSONGenerator.Appearance>();
            List<eSignJSONGenerator.Signers_info> eSignJSONSignerInfos = new List<eSignJSONGenerator.Signers_info>();
            for(valueInitiators input : inputs){
                //CR SBP
                //quoteId = input.recordId;
                oppId = input.recordId;
                eSignJSONGenerator.Signers_info eSignJSONSignerInfo = new eSignJSONGenerator.Signers_info();
                eSignJSONGenerator.Signer_position eSignJSONSignerPosition = new eSignJSONGenerator.Signer_position();
                eSignJSONGenerator.Appearance eSignJSONSignerAppearance = new eSignJSONGenerator.Appearance();
                //Doc
                eSignJSONDoc.reference_doc_id = input.contentVersionId;
                eSignJSONDoc.content_type = input.contentVersionFileType;
                eSignJSONDoc.content = input.contentVersionData;
                eSignJSONDoc.signature_sequence = eSignConfig.get(input.signerType).Signature_Sequence__c;
                //Signer Position - Right
                if(input.signerType == 'Signer-Customer'){
                    eSignJSONSignerAppearance.x1 = 460;
                    eSignJSONSignerAppearance.x2 = 570;
                    eSignJSONSignerAppearance.y1 = 50;
                    eSignJSONSignerAppearance.y2 = 90;
                }else{
                    eSignJSONSignerAppearance.x1 = 40;
                    eSignJSONSignerAppearance.x2 = 180;
                    eSignJSONSignerAppearance.y1 = 50;
                    eSignJSONSignerAppearance.y2 = 90;
                }
                eSignJSONSignerPosition.appearance = New List<eSignJSONGenerator.Appearance>{eSignJSONSignerAppearance};
                
                
                //Signer Info
                eSignJSONSignerInfo.document_to_be_signed = input.contentVersionId;
                eSignJSONSignerInfo.signer_position = eSignJSONSignerPosition;
                eSignJSONSignerInfo.trigger_esign_request = true;
                eSignJSONSignerInfo.signer_ref_id = input.signerId;
                eSignJSONSignerInfo.signer_email = input.signerEmailId;
                System.debug('input.signerName '+input.signerName);
                eSignJSONSignerInfo.signer_name = input.signerName;
                if(input.signatureSequence != null){
                     eSignJSONSignerInfo.sequence = input.signatureSequence;
                }
                //eSignConfig.get(input.signerType).Sequence__c;
                eSignJSONSignerInfo.page_number = eSignConfig.get(input.signerType).Page_Number__c;
                eSignJSONSignerInfo.signature_type = input.eSignType;
                system.debug('Esign '+eSignJSONSignerInfo);
                if(input.eSignType == 'electronic'){
                    //Added by Raksha
                    System.debug('Line 1  input.modeOfOTPForElectronicSignature '+input.modeOfOTPForElectronicSignature);
                    eSignJSONSignerInfo.authentication_mode = input.modeOfOTPForElectronicSignature;
                    //End by Raksha
                    System.debug('** input.signerMobileNo '+input.signerMobileNo);
                    if(input.signerMobileNo.length() == 10){
                        System.debug('Line 2 input.signerMobileNo'+input.signerMobileNo);
                        eSignJSONSignerInfo.signer_mobile = input.signerMobileNo;
                    }else{
                        return eSignConfig.get('Error-Mobile').Error_Message__c;
                    }
                }
                System.debug('Line 3 input.contentVersionId'+input.contentVersionId);
                  System.debug('Line 4 input.contentVersionTitle'+input.contentVersionTitle);
                //eSignJSONGenerator
                eSignJSON.reference_id = input.contentVersionId;
                eSignJSON.docket_title = input.contentVersionTitle;
                eSignJSON.enable_email_notification = true;
                system.debug('Docket#$%'+input.docket_description );
                eSignJSON.docket_description = input.docket_description;
                eSignJSON.description_in_invitation = true;
                String CCAddresses;
                System.debug('input.ccAddress '+input.ccAddress);
                if(!String.isBlank(input.ccAddress)){ //&& !input.ccAddress.contains('legal@cleartax.in')
                    CCAddresses = input.ccAddress.deleteWhitespace();
                    CCAddresses = CCAddresses+',legal@cleartax.in';
                }else{
                    CCAddresses = 'legal@cleartax.in';
                }
                System.debug('CCAddresses after adding legal@cleartax.in '+CCAddresses);
                eSignJSON.final_copy_recipients = CCAddresses;
                eSignJSONSignerInfos.add(eSignJSONSignerInfo);
                System.debug('eSignJSONSignerInfos '+eSignJSONSignerInfos);
            }
            System.debug('Line 5 ');
            eSignJSON.documents = new List<eSignJSONGenerator.Documents>{eSignJSONDoc};
                System.debug('Line 6 ');
            eSignJSON.signers_info = eSignJSONSignerInfos;
            System.debug('Line 7 ');

            //Actual CallOut
            HttpResponse response;
            System.debug('Line 8 ');
            Http htt=new Http();
            System.debug('Line 9 ');
            HttpRequest req=new httpRequest();
            System.debug('Line 10 ');
            req.setEndpoint(eSignConfig.get('FirstCall').EndPoint__c);
            System.debug('Line 11 ');
            req.setMethod(eSignConfig.get('FirstCall').Method__c);
            System.debug('Line 12 ');
            //req.setTimeout(timeout);
            
            req.setBody(JSON.serialize(eSignJSON));
            System.debug('Line 13 ');
            for(String headers:eSignConfig.get('FirstCall').Headers__c.split(',')){
                System.debug('headers '+headers);
                req.setHeader(headers.substringBefore(':'),headers.substringAfter(':'));
            }
            System.debug('req Body '+req.getBody());
            System.debug('req EndPoint '+req.getEndpoint());
            System.debug('req Host '+req.getHeader('Host'));
            System.debug('req Contenet-type '+req.getHeader('content-type'));
            req.setTimeout(120000);
            response=htt.send(req);
            system.debug('Response '+response.getBody());
            JSONParser parser = JSON.createParser(response.getBody());
            Boolean success;
            String responseMsg = eSignConfig.get('Error-Unsuccessful').Error_Message__c;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentName() == 'status')) {
                    // Get the value.
                    parser.nextToken();
                    System.debug('parser.getCurrentToken() '+parser.getCurrentToken());
                    System.debug('parser.getCurrentName() '+parser.getCurrentName());
                    System.debug('JSONToken.FIELD_NAME '+JSONToken.FIELD_NAME);
                    System.debug('parser.getText() '+parser.getText());
                    // Compute the grand total price for all invoices.
                    if(parser.getText() == 'success'){
                        success = true;
                    }else{
                        success = false;
                    }
                }
                else if ((parser.getCurrentName() == 'error')) {
                        responseMsg = responseMsg +' : ' + parser.getText();
                        if(parser.getText() == eSignConfig.get('Generate-New-Doc').Value__c){
                            responseMsg = responseMsg +' : '+ eSignConfig.get('Generate-New-Doc').Error_Message__c;
                        }
                }
            }
            if(success){
                //getQuoteInfo.E_Sign_Status__c = 'E-Sign Request Sent';
                //update getQuoteInfo;
                //newely commented return eSignConfig.get('Success-Message').Error_Message__c + '::'+response.getBody()+'::'+quoteId;
                return eSignConfig.get('Success-Message').Error_Message__c + '::'+response.getBody()+'::'+oppId; 
            }else if(success == null){
                return responseMsg;
            }else{
                return responseMsg;
            }
        }catch(Exception ex){
            System.debug('Exception MSG '+ex.getMessage());
            System.debug('Exception Line no '+ex.getLineNumber());
            System.debug('Exception Stack trace '+ex.getStackTraceString());
            return string.valueOf(ex.getMessage());
        }
    }
}