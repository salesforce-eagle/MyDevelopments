@RestResource(urlMapping='/License/upsertBulkAssets')
global class CTX_UpdateAssetWithLicense_Bulk {
    
    @HttpPost
    global static String updateBulkLicenses(Map<String, String> assetLicenseMap) {
        
        List<Asset> assetsToUpdate = new List<Asset>();
        String		message;
        
        for(String thisKey : assetLicenseMap.keySet()){
            
            Asset 	asset 		= new Asset();
            asset.Id 			= thisKey;
            asset.License_Id__c = assetLicenseMap.get(thisKey);
            assetsToUpdate.add(asset);
        }
        
        try{
            update assetsToUpdate;
            message = 'Licenses Updated Successfully.';
        } catch(Exception ex){
            message = ex.getMessage();
        }
        
        return message;
    }
}