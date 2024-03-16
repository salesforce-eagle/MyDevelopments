public class SOS_Invoice_discounting_controller {
 public Static String nextPage9{get;set;}
    public Static integer SOS2{get;set;}
    public SOS_Invoice_discounting_controller(ApexPages.StandardController controller){
        generateOrderFormPDF.SOS++;
        generateOrderFormPDF.idSOSCheck =true ;
        SOS2=generateOrderFormPDF.SOS;  
        nextpage9=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage9 '+nextpage9);
        generateOrderFormPDF.nextNumber++;
    }
}