public class SpecialTerms_Controller {
    public Static String nextPage40{get;set;}
    public SpecialTerms_Controller(ApexPages.StandardController controller){
        nextpage40=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage40 '+nextpage40);
        generateOrderFormPDF.nextNumber++;
    }
}