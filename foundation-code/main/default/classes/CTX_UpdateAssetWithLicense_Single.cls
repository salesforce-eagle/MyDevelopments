@RestResource(urlMapping='/License/upsertSingleAsset')
global class CTX_UpdateAssetWithLicense_Single {

  @HttpPost
    global static String updateSingleLicense( String assetId, String licenseId ) {
        
        String	message;
        Asset 	asset 		= new Asset();
        asset.Id 			= assetId;
        asset.License_Id__c = licenseId;
        
        try{
            update asset;
            message = 'License Updated Successfully.';
        } catch(Exception ex){
            message = ex.getMessage();
        }
        
        return message;
    }
    
}