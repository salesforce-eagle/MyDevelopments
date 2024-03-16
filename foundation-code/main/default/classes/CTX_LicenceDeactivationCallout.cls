public class CTX_LicenceDeactivationCallout implements Queueable, Database.AllowsCallouts{
    
    Public String licenceId;
    Public CTX_LicenceDeactivationCallout(String licenceId){
        this.licenceId = licenceId;
    }
    public void execute(QueueableContext context) {
        Http 		http 	= new Http();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('PUT');
        request.setEndpoint(System.Label.CTX_LicenceDeactivationAPiEndpoint  + licenceId);
        request.setHeader('X-Api-Token', System.Label.SalesSyncService_X_Api_Token); 
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse resp = http.send(request);
        System.debug('jsonResponse: '+resp.getBody());
        
        if(resp.getStatusCode() == 200){
            System.debug('Success');
        } else{
            System.debug('Service Error');
        }
    }
    
    
}