public class SOS_Clearcapture_Onboarding_Controller {
 public Static String nextPage9{get;set;}
    public Static integer SOS2{get;set;}
    public SOS_Clearcapture_Onboarding_Controller(ApexPages.StandardController controller){
        generateOrderFormPDF.SOS++;
        SOS2=generateOrderFormPDF.SOS;  
        nextpage9=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage9 '+nextpage9);
        generateOrderFormPDF.nextNumber++;
    }
}