public class Annexure_Controller {
      public Static String nextPage37{get;set;}
public Annexure_Controller(ApexPages.StandardController controller){
      
//nextPage38=generateOrderFormPDF.mapVFtest.get(generateOrderFormPDF.ProSSJ.get(generateOrderFormPDF.nextNumber).order__c).Scope_Of_Service_VFs__r.Name;
		nextpage37=generateOrderFormPDF.mapOfOrderToProdSOSJunctionToDisplay.get(generateOrderFormPDF.listOfOrdersToDisplay.get(generateOrderFormPDF.nextNumber)).Scope_Of_Service_VFs__r.Name;
        system.debug('nextNumber '+generateOrderFormPDF.nextNumber);
        system.debug('nextpage37 '+nextpage37);
        generateOrderFormPDF.nextNumber++;
       
    }
}