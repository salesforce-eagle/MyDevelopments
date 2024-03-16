@RestResource(urlMapping='/FetchAssetsByMasterAdminEmails/*')
global class CTX_FetchAssetService {
    
    @HttpPost
    global static ReturnWrapper getAsset(
        List<String> adminEmails
    ){
        
        System.debug('adminEmails: '+adminEmails); 
        ReturnWrapper	thisWrapper 	= new ReturnWrapper();
        RestRequest 	req 			= RestContext.request;
        RestResponse 	res 			= RestContext.response;
        Set<String> 	validEmails 	= new Set<String>();
        
        
        if(adminEmails != NULL || adminEmails.size() > 0){
            for(String thisSTR : adminEmails){
                if(CTX_UtilityClass.validateEmailAddress(thisSTR)){
                    validEmails.add(thisSTR);
                }
            }
        }
        
        System.debug('CTX_FetchAssetService: validEmails: '+validEmails);
        System.debug('CTX_FetchAssetService: validEmails Size: '+validEmails.size());
        
        if(validEmails.size() <= 0){
            
            thisWrapper.numberOfAssets 				= 0;
            thisWrapper.isSuccess					= FALSE;
            thisWrapper.statusMessage				= 'Please provide valid Email Addresses to Proceed.';
        } else{
            
            for(
                Asset thisRec : [ SELECT Id, Name, Status, PurchaseDate, UsageEndDate, Plan_Type__c,  
                                 License_ID__c, License_Activated_On__c, 
                                 Account.Master_Admin_Email__c,
                                 Account.Product_Email__c,
                                 Opportunity__r.Master_Admin_Email__c, 
                                 Renewal_Opportunity__r.Master_Admin_Email__c, 
                                 Product2.ProductCode, Product2.Plan_Tier__c
                                 FROM Asset WHERE 
                                 (
                                     Product2.Product_Line__c IN :System.Label.Asset_Standard_Plan_Product_Line.split(';') AND 
                                     ( NOT Status IN :System.Label.Asset_Standard_Plan_Exclude_Status.split(';') ) 
                                 ) AND 
                                 ( 
                                     Account.Master_Admin_Email__c IN :validEmails OR 
                                     Account.Product_Email__c IN :validEmails
                                 ) 
                                ]
            ){
                
                /**	Master Admin Email Block : START	**/
                if(thisRec.Account.Master_Admin_Email__c != NULL){
                    if(thisWrapper.mapOfAdminEmailAndAsset.containsKey(thisRec.Account.Master_Admin_Email__c)){
                        thisWrapper.mapOfAdminEmailAndAsset.get(thisRec.Account.Master_Admin_Email__c).add(thisRec);
                    } else{
                        thisWrapper.mapOfAdminEmailAndAsset.put(thisRec.Account.Master_Admin_Email__c, new List<Asset>{thisRec});
                    }
                }/**	Master Admin Email Block : END	**/
                
                /**	Product Email Block : START	**/
                if(thisRec.Account.Product_Email__c != NULL){
                    if(thisWrapper.mapOfAdminEmailAndAsset.containsKey(thisRec.Account.Product_Email__c)){
                        thisWrapper.mapOfAdminEmailAndAsset.get(thisRec.Account.Product_Email__c).add(thisRec);
                    } else{
                        thisWrapper.mapOfAdminEmailAndAsset.put(thisRec.Account.Product_Email__c, new List<Asset>{thisRec});
                    }
                }/**	Product Email Block : END	**/
                
            }
            
            thisWrapper.numberOfAssets 				= thisWrapper.mapOfAdminEmailAndAsset.keySet().size();
            thisWrapper.isSuccess					= TRUE;
            thisWrapper.statusMessage				= 'Result fetched successfully.';
            
            if(thisWrapper.mapOfAdminEmailAndAsset.keySet().size() < 1 )
                thisWrapper.statusMessage			= 'No records found with the given Email Id.';
        } 
        
        return thisWrapper;
    }
    
    global class ReturnWrapper{
        Map<String, List<Asset>> mapOfAdminEmailAndAsset = new Map<String, List<Asset>>();
        Integer				numberOfAssets;
        Boolean				isSuccess;
        String				statusMessage;
    }
    
}