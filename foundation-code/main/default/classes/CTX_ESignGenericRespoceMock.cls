@isTest
global class CTX_ESignGenericRespoceMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success","message":"recieved","docket_id":"abcdefg","signer_info":[{"signer_ref_id":"abcdefg","signer_id":"abcdefg","document_id":"abcdefg","reference_doc_id":"abcdefg"},{"signer_ref_id":"abcdefg","signer_id":"abcdefg","document_id":"abcdefg","reference_doc_id":"abcdefg"}],"api_response_id":"abcdefg","response_time_stamp":"2022-09-12T18:32:09"}');
        res.setStatusCode(200);
        return res;
    }
}