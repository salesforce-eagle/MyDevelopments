public class SOS_InvDisc_Integ_SFTP_Controller{
    public Static integer SOS2{get;set;}
    public Static String nextPage9{get;set;}
    public SOS_InvDisc_Integ_SFTP_Controller(ApexPages.StandardController controller){
        generateOrderFormPDF.SOS++;
        SOS2=generateOrderFormPDF.SOS;         
        nextpage9=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage9 '+nextpage9);
        generateOrderFormPDF.nextNumber++;
    }
    
}