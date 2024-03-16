public class SOS_AS_GST_Refund_Controller {
    public Static integer SOS2{get;set;}
    public Static integer SOSLimitaionCheck{get;set;}
    public Static String nextPage12{get;set;}
    public SOS_AS_GST_Refund_Controller(ApexPages.StandardController controller){
        generateOrderFormPDF.SOS++;
        SOSLimitaionCheck = generateOrderFormPDF.assistLimitationCheck++;
        generateOrderFormPDF.assistLimitationCheck++;
        SOS2=generateOrderFormPDF.SOS;         
        nextpage12=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage12 '+nextpage12);
        generateOrderFormPDF.nextNumber++;
    }
    
}