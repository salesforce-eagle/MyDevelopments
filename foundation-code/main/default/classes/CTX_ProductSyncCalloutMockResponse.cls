@isTest
global class CTX_ProductSyncCalloutMockResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        if(req.getMethod() == 'PUT'){
            HttpResponse res = new HttpResponse();
        	res.setHeader('Content-Type', 'application/json');
        	res.setBody('{"success":true,"status":"success"}');
        	res.setStatusCode(200);
        	return res;
        }else{
        	HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"productSalesforceMappings":[{"sales_force_product_name":"GST","product_name":"GST","Licensing_product_name":"GST","is_custom_plan_allowed":true}]}');
            res.setStatusCode(200);
            return res;    
        }
    }
}