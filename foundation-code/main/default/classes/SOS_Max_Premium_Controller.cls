public class SOS_Max_Premium_Controller{
    public Static integer SOS2{get;set;}
    public Static String nextPage12{get;set;}
    public SOS_Max_Premium_Controller(ApexPages.StandardController controller){
        generateOrderFormPDF.SOS++;
        SOS2=generateOrderFormPDF.SOS;         
        nextpage12=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage12 '+nextpage12);
        generateOrderFormPDF.nextNumber++;
    }
    
}