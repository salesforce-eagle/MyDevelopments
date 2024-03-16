public class SubscriptionCharges_Controller {
    public Static String nextPage2{get;set;}
    public Static String roundOffArr{get;set;}
    public Static String roundOffArrDiscountOF{get;set;}
    public Static String roundOffArrDiscountedPriceOF{get;set;}
    public Static String roundOffArrListPriceOF{get;set;}
    
    public SubscriptionCharges_Controller(ApexPages.StandardController controller){
        String tempARROF;
        String tempDiscOF;
        string temp=generateOrderFormPDF.ARRProdTotal.format();
        
        if(generateOrderFormPDF.ARRTotalListPrice != NULL){
            roundOffArrListPriceOF = generateOrderFormPDF.ARRTotalListPrice.format();
        }
        
        if(generateOrderFormPDF.ARRProdDiscountedPriceOF != NULL){
            tempARROF = generateOrderFormPDF.ARRProdDiscountedPriceOF.format();
        }
        if(generateOrderFormPDF.ARRProdDiscountOF != NULL){
            tempDiscOF = generateOrderFormPDF.ARRProdDiscountOF.format();
        }
 
        roundOffArr=temp;
        if(tempDiscOF != NULL){
            roundOffArrDiscountOF = tempDiscOF; 
        }
        if(tempARROF != NULL){
            roundOffArrDiscountedPriceOF = tempARROF; 
        }

        nextpage2=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage2 '+nextpage2);
        generateOrderFormPDF.nextNumber++;
    }
}