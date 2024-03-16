public class SOS_TDS_206_API_Consultation_Controller {
    public Static integer SOS1{get;set;}
    public Static String nextPage12{get;set;}
    public SOS_TDS_206_API_Consultation_Controller (ApexPages.StandardController controller){
        generateOrderFormPDF.SOS++;
        SOS1=generateOrderFormPDF.SOS;         
        nextpage12=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage12 '+nextpage12);
        generateOrderFormPDF.nextNumber++;
    }
    
}