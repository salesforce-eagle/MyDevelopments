global without sharing class CTX_OrderFormAddendumController {
    
    Public List<Additional_GSTIN__c > billing_Ids{get;set;}
    public static Decimal 	additionalGSTINTotal{get;set;}
    public static boolean 	isOrderFormSaved = FALSE;
    
    public CTX_OrderFormAddendumController(ApexPages.StandardController topupFormController){
        
        
        Upsell_Top_up__c upsell=(Upsell_Top_up__c) topupFormController.getRecord();
        System.debug('upsell-->'+upsell);
        
        billing_Ids = [SELECT Id, Name, Amount__c, Name_Of_The_Customer__c,Upsell_Top_up__c,
                       Add_on_split__c, Address__c, Address_Line_2__c, City__c,
                       State__c, Pincode__c
                       FROM Additional_GSTIN__c
                       WHERE Upsell_Top_up__c = :upsell.Id 
                       AND Add_on_split__c > 0];
        
        System.debug('billing_Ids->'+billing_Ids);
        
        additionalGSTINTotal = 0;
        for(Additional_GSTIN__c addtnGstin : billing_Ids){
            additionalGSTINTotal += addtnGstin.Add_on_split__c;
        }
        
        
    }
    
    public Static void saveOrderFormToUpsell(){
        
        
        Id conDoc;
        Id upsellId = ApexPages.currentPage().getParameters().get('id');
        PageReference ref = new PageReference('/apex/OrderformAddendum?id='+ upsellId);
        
        Upsell_Top_up__c upsell = [SELECT id, Name,Asset__r.Opportunity__r.Legal_Entity_Name_Of_The_Client__c 
                                   FROM Upsell_Top_up__c WHERE id=:upsellId LIMIT 1];
        ContentVersion cont = new ContentVersion();
        cont.Title = 'Order Form Addendum - '+upsell.Asset__r.Opportunity__r.Legal_Entity_Name_Of_The_Client__c;
        cont.PathOnClient = 'Order Form Addendum - '+upsell.Asset__r.Opportunity__r.Legal_Entity_Name_Of_The_Client__c+'.pdf';
        Blob pdfBlob = ref.getContent();
        cont.VersionData = pdfBlob;
        cont.System_Generated__c = true;
        cont.Type_of_document__c = 'Order Form Addendum';
        insert cont;
        conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cont.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = upsell.Id; 
        conDocLink.ContentDocumentId = conDoc;  
        conDocLink.shareType = 'V';
        insert conDocLink;
        
    }
    
}