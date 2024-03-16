public class CTX_ProductSyncByProductCodeCallout {
    
    public Static void requestCallout(){
        
        Http 		http 	= new Http();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('GET');
        request.setEndpoint(system.label.EndPoint_StandardSync);
        request.setHeader('X-Api-Token'	, system.label.SalesSyncService_X_Api_Token); 
        request.setHeader('Accept', 'application/json');
        
        HttpResponse resp = http.send(request);
        System.debug('jsonResponse: '+resp.getBody());
        
        if(resp.getStatusCode() == 200){
            
            String jsonResponse 				= resp.getBody();
            WrapperCTX_ProductSync_Parse responseMap 	= 
                (WrapperCTX_ProductSync_Parse)JSON.deserialize(jsonResponse, WrapperCTX_ProductSync_Parse.Class);
            
            Database.executeBatch(new CTX_ProductSyncByProductCodeBatch(responseMap.plans));
        } else{
            System.debug('Service Error');
        }
    }
    
}