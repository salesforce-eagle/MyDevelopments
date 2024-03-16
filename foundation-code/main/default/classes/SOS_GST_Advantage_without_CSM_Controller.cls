public class SOS_GST_Advantage_without_CSM_Controller {
public Static integer SOS2{get;set;}
    public Static String nextPage12{get;set;}
    public SOS_GST_Advantage_without_CSM_Controller(ApexPages.StandardController controller){
        generateOrderFormPDF.SOS++;
        SOS2=generateOrderFormPDF.SOS;         
        nextpage12=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage12 '+nextpage12);
        generateOrderFormPDF.nextNumber++; }
}