public class POInformation_Controller {
        public Static String nextPage5{get;set;}
public POInformation_Controller(ApexPages.StandardController controller){
        nextpage5=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage5 '+nextpage5);
        generateOrderFormPDF.nextNumber++;
    }
}