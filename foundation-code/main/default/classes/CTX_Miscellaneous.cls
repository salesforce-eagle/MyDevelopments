public class CTX_Miscellaneous {
    
    @future(Callout=True)
    public static void fetchCI(String billingGst, Id oppId){
        CTX_GSTCompanyInfo.fetchCompanyInfo(billingGst, oppId);
    }

    @future(Callout=True)
    public Static void syncQuoteFromScript(Id OppId, Id QuoteId){
        Opportunity testOpportunity = new Opportunity(Id = OppId);
        testOpportunity.SyncedQuoteId = QuoteId;
        try{
            RecursiveTriggerHandler.isFirstTimeOpportunity = FALSE;
            UPDATE testOpportunity;
            RecursiveTriggerHandler.isFirstTimeOpportunity = True;
        }catch(exception e){
            System.debug('Failed to Update testOpportunity SyncQuote: '+e.getMessage() +' on line : '+e.getLineNumber());
        }
    }
}