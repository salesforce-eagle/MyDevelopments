public class UpdateCardCodeOfReceivableFromSAP implements Queueable, Database.AllowsCallouts{
    
    private String billingPanOrTan;
    private Id receivableId;
    
    public UpdateCardCodeOfReceivableFromSAP(String billingData, Id receivableIds) {
        this.billingPanOrTan = billingData;
        this.receivableId = receivableIds;
        system.debug('inside constructor this.receivableId '+this.receivableId+' this.billingPanOrTan '+this.billingPanOrTan);
    }
    
    public void execute(QueueableContext context) { 
        try{
        Receivables__c newRecord = [SELECT Id,SAP_BP_Code__c,CT_Billing_Entity__c FROM Receivables__c WHERE Id =: this.receivableId LIMIT 1];
        system.debug('inside execute method newRecord'+newRecord); 
        String cardCode =  CTX_DataSyncJobSAPSF.fetchCardCode(this.billingPanOrTan,newRecord.CT_Billing_Entity__c);
         system.debug('inside execute method cardCode'+cardCode); 
        if(cardCode!='' && cardCode!= NULL){            
            newRecord.SAP_BP_Code__c = cardCode;
        }
        else{
            newRecord.SAP_BP_Code__c = 'ERROR';
        }
        
        update newRecord;
        }
        catch(Exception e){
            system.debug('Exception in update '+e.getmessage());
        }
    }
}