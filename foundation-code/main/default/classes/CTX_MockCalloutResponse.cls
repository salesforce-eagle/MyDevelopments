@isTest
global class CTX_MockCalloutResponse implements HttpCalloutMock{
    
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }

}