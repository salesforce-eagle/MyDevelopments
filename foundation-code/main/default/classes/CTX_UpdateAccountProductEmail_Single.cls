@RestResource(urlMapping='/License/upsertSingleAccountProductEmail')
global class CTX_UpdateAccountProductEmail_Single {
    
    @HttpPost
    global static String updateSingleProductEmail( String accountId, String productEmail ) {
        
        String	message;
        Account account 			= new Account();
        account.Id 					= accountId;
        account.Product_Email__c 	= productEmail;
        
        try{
            update account;
            message = 'Product Email Updated Successfully.';
        } catch(Exception ex){
            message = ex.getMessage();
        }
        
        return message;
    }
}