public class CTX_AdditionalGstinTriggerHelper {
    /** Added By Ashwin -> Validate Add-On Split **/
    public static void validateTotalAddOn(Map<Id,Additional_GSTIN__c> billingIdMap){
        
        Set<Id> 								upsellSet 					= new Set<Id>();
        Map<Id,Decimal> 						upsellBillingIdMap 		= new Map<Id,Decimal>();
        Map<Id,Decimal> 						totalAddOnMap 			= new Map<Id,Decimal>();
        Map<Id,Upsell_Top_up__c> 				upsellMap 				= new Map<Id,Upsell_Top_up__c>([SELECT Id, Additional_Price__c, Asset__c
                                                                                                                FROM Upsell_Top_up__c
                                                                                                                WHERE Id IN :upsellSet]);
        
        for(Additional_GSTIN__c thisRec : billingIdMap.values()){
            upsellSet.add(thisRec.Upsell_Top_up__c);
        }
        
	        
        for(Additional_GSTIN__c thisRec : [SELECT Id,Name,Asset__c,Add_on_split__c,Upsell_Top_up__c
                                           FROM Additional_GSTIN__c
                                           WHERE Upsell_Top_up__c IN :upsellSet])
            
        {
            if(upsellBillingIdMap.containsKey(thisRec.Upsell_Top_up__c) && upsellBillingIdMap.get(thisRec.Upsell_Top_up__c) != NULL){
                Decimal totalAddOn;
                if(thisRec.Add_on_split__c != NULL){
					totalAddOn = upsellBillingIdMap.get(thisRec.Upsell_Top_up__c)  + thisRec.Add_on_split__c;
                }else{
					totalAddOn = upsellBillingIdMap.get(thisRec.Upsell_Top_up__c) ;
                }
                
                upsellBillingIdMap.put(thisRec.Upsell_Top_up__c, totalAddOn);   
                
            }else
            {
                upsellBillingIdMap.put(thisRec.Upsell_Top_up__c, thisRec.Add_on_split__c);
            }
        }
        
        for(Additional_GSTIN__c thisRec : billingIdMap.values()){
            if(upsellMap.get(thisRec.Upsell_Top_up__c) 											!= NULL								&& 
              upsellBillingIdMap.get(thisRec.Upsell_Top_up__c).round(System.RoundingMode.CEILING)	!= upsellMap.get(thisRec.Upsell_Top_up__c).Additional_Price__c)
            {
                thisRec.addError('Please ensure Total Add-on Split is equal to Additional Price.');
            }
        }
    }
}