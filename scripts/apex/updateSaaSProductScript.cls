/** 

**/

List<Product2>      produtsToUpdate = new List<Product2>();
Map<String, String> productLineMap  = new Map<String, String>{
    'GST' => 'GST',
    'E-invoicing & E-Way Bill' => 'E_INVOICING',
    'Invoicing API' => 'CLEAR_INVOICE',
    'Max' => 'MaxItc',
    'TDS' => 'TDS',
    'Clear Capture' => 'InvoiceCapture',
    'KYC APIs' => 'CLEAR_IDENTITY' };

for( Product2 thisRec : [ SELECT Id, Name, Product_Line__c FROM Product2 ] ){
    
    thisRec.Saas_Product__c =   productLineMap.get(thisRec.Product_Line__c);
    produtsToUpdate.add(p2);
}

update produtsToUpdate;