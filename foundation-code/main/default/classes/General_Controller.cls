public class General_Controller {
     public Static String nextPage37{get;set;}
public General_Controller(ApexPages.StandardController controller){
       
        nextpage37=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage37 '+nextpage37);
        generateOrderFormPDF.nextNumber++;
    }
}