/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-25-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_ExtendProductLicense implements Queueable,Database.AllowsCallouts  {
        /**@future (callout=true)
    public static void extendLicense(Map<Id, Integer> assetIdToExtendedDaysMap){
        List<Asset> assetsToExtend  = [ SELECT Id, License_Id__c, Account.Country_of_Origin__c, Days_To_Extend__c, Extended_Period_End_Date__c FROM Asset WHERE Id IN :assetIdToExtendedDaysMap.keySet() AND License_Id__c != NULL];
        List<Asset> assetToUpdate   = new List<Asset>();
        for(Asset assetRec : assetsToExtend){
            if(assetRec.License_Id__c != NULL){
                String region = assetRec.Account?.Country_of_Origin__c != NULL ? assetRec.Account?.Country_of_Origin__c : 'INDIA';
                HttpResponse response = CTX_LicensingAPICalloutClass.extendLicenseCallout(assetRec.License_Id__c,assetIdToExtendedDaysMap.get(assetRec.Id),region);
                System.debug('Body: '+ response.getBody());
                if(response.getStatusCode() == 200){
                    Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    System.debug('responseMap: '+ responseMap);
                    DateTime extendedDate = DateTime.ValueOf(String.valueOf(responseMap.get('endAt')));
                    assetToUpdate.add(
                        new Asset(
                        Id                          = assetRec.Id,
                        Extended_Period_End_Date__c = extendedDate
                    ) );
                } else {
                    
                }
            }
        }
        
        update assetToUpdate;
    }**/
        private Map<Id, Integer> assetIdToExtendedDaysMapLoc;
        public CTX_ExtendProductLicense(Map<Id, Integer> assetIdToExtendedDaysMap) {
        this.assetIdToExtendedDaysMapLoc = assetIdToExtendedDaysMap;
   }
  
    public void execute(QueueableContext context) {
        List<Asset> assetsToExtend 	= [ SELECT Id, License_Id__c, Account.Country_of_Origin__c, Days_To_Extend__c, Extended_Period_End_Date__c FROM Asset WHERE Id IN :assetIdToExtendedDaysMapLoc.keySet() AND License_Id__c != NULL AND Asset.Account.Is_Auto_Renewal_Enabled__c = FALSE ];
        List<Asset> assetToUpdate 	= new List<Asset>();
        for(Asset assetRec : assetsToExtend){
            if(assetRec.License_Id__c != NULL){
                String region = assetRec.Account?.Country_of_Origin__c != NULL ? assetRec.Account?.Country_of_Origin__c : 'INDIA';
                HttpResponse response = CTX_LicensingAPICalloutClass.extendLicenseCallout(assetRec.License_Id__c,assetIdToExtendedDaysMapLoc.get(assetRec.Id),region);
                System.debug('Body: '+ response.getBody());
                if(response.getStatusCode() == 200){
                    Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    System.debug('responseMap: '+ responseMap);
                    DateTime extendedDate = DateTime.ValueOf(String.valueOf(responseMap.get('extendedEndAt')));
                    assetToUpdate.add(
                        new Asset(
                        Id 							= assetRec.Id,
                        Extended_Period_End_Date__c = extendedDate
                    ) );
                } else {
                    
                }
            }
        }
        
        update assetToUpdate;
    }
}