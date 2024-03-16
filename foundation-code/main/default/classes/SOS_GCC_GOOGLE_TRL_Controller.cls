public class SOS_GCC_GOOGLE_TRL_Controller {
    public Static String nextPage9{get;set;}
    public Static integer SOS1{get;set;}
    
    public SOS_GCC_GOOGLE_TRL_Controller(ApexPages.StandardController controller){
        
        generateOrderFormPDF.SOS++;
        SOS1=generateOrderFormPDF.SOS;  
        nextPage9=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage9 '+nextpage9); 
        
        generateOrderFormPDF.nextNumber++;
        
    }

}