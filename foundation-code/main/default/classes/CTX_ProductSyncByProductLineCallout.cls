public class CTX_ProductSyncByProductLineCallout {
    
    public Static void requestCallout(){
        
        Http 		http 	= new Http();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('GET');
        request.setEndpoint(System.Label.CTX_ProductSyncByProductLineAPIEndPoint);
        request.setHeader('X-Api-Token'	, System.Label.SalesSyncService_X_Api_Token); 
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse resp = http.send(request);
        System.debug('jsonResponse: '+resp.getBody());
        
        if(resp.getStatusCode() == 200){
            
            String jsonResponse 				= resp.getBody();
            //jsonResponse = jsonResponse.substring(jsonResponse.indexOf('['), jsonResponse.lastIndexOf(']')+1);
            WrapperCTX_ProductSync_Parse responseMap 	= 
                (WrapperCTX_ProductSync_Parse)JSON.deserialize(jsonResponse, WrapperCTX_ProductSync_Parse.Class);
            System.debug('jsonResponse: '+responseMap.productSalesforceMappings);
            Database.executeBatch(new CTX_ProductSyncByProductLineBatch(responseMap.productSalesforceMappings));
        } else{
            System.debug('Service Error');
        }
    }
}