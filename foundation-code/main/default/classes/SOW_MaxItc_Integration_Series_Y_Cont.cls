public class SOW_MaxItc_Integration_Series_Y_Cont {
    public Static String nextPage8{get;set;}
    public Static integer SOS1{get;set;}
    
    public SOW_MaxItc_Integration_Series_Y_Cont(ApexPages.StandardController controller){
        
        generateOrderFormPDF.SOS++;
        SOS1=generateOrderFormPDF.SOS;  
        nextpage8=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage8 '+nextpage8);
        
        generateOrderFormPDF.nextNumber++;
 
    }
    
}