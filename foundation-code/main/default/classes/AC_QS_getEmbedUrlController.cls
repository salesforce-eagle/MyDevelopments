public class AC_QS_getEmbedUrlController{
    public String embedUrl {get; set;}
    public String userArn {get; set;}
    public final Account account;
    public AC_QS_getEmbedUrlController(ApexPages.StandardController stdController) {
        account = (Account)stdController.getRecord();
        callout();
    }
    
    private void callout(){
        
        userArn = 'arn:aws:quicksight:ap-south-1:219341907983:user/default/QuicksightBotUser';
        HttpRequest getEmbed = new HttpRequest();   
        Http http = new Http();
        
        getEmbed.setEndpoint( system.label.KAM_Dashboard_Endpoint + EncodingUtil.urlEncode(userArn, 'UTF-8') );
        getEmbed.setMethod('GET');
        System.debug(getEmbed.getBody());
        if(!test.isRunningTest()){
        HTTPResponse  res = http.send(getEmbed);
        embedUrl = AWSEmbededURLParser.parse(res.getBody()).EmbedUrl;
        }
        
    }
}