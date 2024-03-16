public class CTX_AdditionalGstinUpsellController {
	@AuraEnabled(cacheable=true)
    Public static List<Additional_GSTIN__c > getAdditionalGstins(Id topupId){
        //Id assetId = [SELECT Id, Asset__c from Upsell_Top_up__c  where Id = :topupId]?.Asset__c;
        List<Additional_GSTIN__c> gstinRecords	= new List<Additional_GSTIN__c>
            (
                [ SELECT Id, Name, Amount__c, Add_on_split__c,Name_Of_The_Customer__c,
                 Billing_PAN__c, Address__c, Address_Line_2__c,
                 City__c,State__c, Pincode__c, TAN__c, SEZ_Yes_No__c
                 FROM Additional_GSTIN__c
                 WHERE Upsell_Top_up__c  = :topupId]
            );
        System.debug('Additional Gstins-->'+gstinRecords);
        return gstinRecords;
    }
    
    @AuraEnabled
    Public static void updateBillingIds(List<Additional_GSTIN__c> gstinList ){
        try{
          update gstinList;  
        }catch(Exception ex){
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
        
    }
}