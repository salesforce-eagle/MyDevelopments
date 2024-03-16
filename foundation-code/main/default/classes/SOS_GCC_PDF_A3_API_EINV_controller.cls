public class SOS_GCC_PDF_A3_API_EINV_controller {
    public Static String nextPage9{get;set;}
    public Static integer SOS1{get;set;}
    
    public SOS_GCC_PDF_A3_API_EINV_controller(ApexPages.StandardController controller){
        
        generateOrderFormPDF.SOS++;
        SOS1=generateOrderFormPDF.SOS;  
        nextPage9=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage9 '+nextpage9); 
        
        generateOrderFormPDF.nextNumber++;
        
    }
}