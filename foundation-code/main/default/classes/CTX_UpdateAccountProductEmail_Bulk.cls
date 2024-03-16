@RestResource(urlMapping='/License/upsertBulkAccountProductEmail')
global class CTX_UpdateAccountProductEmail_Bulk {
    
    @HttpPost
    global static String updateBulkProductEmails(Map<String, String> accountIdProductEmailMap) {
        
        List<Account> accountsToUpdate = new List<Account>();
        String		message;
        
        for(String thisKey : accountIdProductEmailMap.keySet()){
            
            Account account 			= new Account();
            account.Id 					= thisKey;
            account.Product_Email__c 	= accountIdProductEmailMap.get(thisKey);
            accountsToUpdate.add(account);
        }
        
        try{
            update accountsToUpdate;
            message = 'Product Emails Updated Successfully.';
        } catch(Exception ex){
            message = ex.getMessage();
        }
        
        return message;
    }
}