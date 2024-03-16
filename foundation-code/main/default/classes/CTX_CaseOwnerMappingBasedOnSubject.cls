public class CTX_CaseOwnerMappingBasedOnSubject {
    
    public static Case assigneCaseOwnerBasedOnEMailSubject(EmailMessage mail, Case parentCase){
        
        if(parentCase.Subject != NULL){
            
            /**	
            if(
                parentCase.Subject.containsIgnoreCase('Greetings from Defmacro') ||
                parentCase.Subject.containsIgnoreCase('Sales Order')
            ){
                parentCase.OwnerId 								= '0052x000003RSc7AAG';	//	vinayak.mesta@cleartax.in
                parentCase.Priority								= 'P0';
                parentCase.User_Role_Type__c 						= 'Finance L3';
                parentCase.Account_Collection_Manager_Email__c 	= 'mani.kant@cleartax.in';
            }
            /**	
            if(
                parentCase.Subject.startsWithIgnoreCase('Invoice')
            ){
                parentCase.OwnerId 								= '005C5000000HrC8IAK';	//	munish.kumar@cleartax.in
                parentCase.Priority								= 'P0';
                parentCase.User_Role_Type__c 						= 'Finance L3';
            }
            /**	
            if(
                parentCase.Subject.containsIgnoreCase('Payment Reminder')
            ){
                //parentCase.OwnerId 								= collectionManagerId;
                parentCase.Priority								= 'P1';
                parentCase.User_Role_Type__c 						= 'Finance L1';
            }
            /**	
            if(
                parentCase.Subject.containsIgnoreCase('Credit Intimation')		||
                parentCase.Subject.containsIgnoreCase('Statement of accounts')	||
                parentCase.Subject.containsIgnoreCase('Reconciliation')			||
                parentCase.Subject.containsIgnoreCase('Payment Advice')			||
                parentCase.Subject.containsIgnoreCase('TDS Certificate')			||
                parentCase.Subject.containsIgnoreCase('Form 16A')
            ){
                parentCase.OwnerId								= '0052x000003RVApAAO';	//	deepesh.poojary@cleartax.in
                
                if(parentCase.Subject.containsIgnoreCase('Credit Intimation')){
                    parentCase.Priority								= 'P0';
                    parentCase.User_Role_Type__c 						= 'Finance L3';
                }
                
                if(parentCase.Subject.containsIgnoreCase('Statement of accounts')){
                    parentCase.Priority								= 'P1';
                    parentCase.User_Role_Type__c 						= 'Finance L1';
                }
                
                if(parentCase.Subject.containsIgnoreCase('Reconciliation')){
                    parentCase.Priority								= 'P0';
                    parentCase.User_Role_Type__c 						= 'Finance L3';
                }
                
                if(parentCase.Subject.containsIgnoreCase('Payment Advice')){
                    parentCase.Priority								= 'P0';
                    parentCase.User_Role_Type__c 						= 'Finance L3';
                }
                
                if(parentCase.Subject.containsIgnoreCase('TDS Certificate')){
                    parentCase.Priority								= 'P1';
                    parentCase.User_Role_Type__c 						= 'Finance L1';
                }
                
                if(parentCase.Subject.containsIgnoreCase('Form 16A')){
                    parentCase.Priority								= 'P1';
                    parentCase.User_Role_Type__c 						= 'Finance L1';
                }
                
            }
            /**	
            if(
                parentCase.Subject.containsIgnoreCase('Purchase Order')
            ){
                parentCase.OwnerId 								= '005C5000000HrC8IAK';	//	munish.kumar@cleartax.in
                parentCase.Priority								= 'P1';
                parentCase.User_Role_Type__c 						= 'Finance L1';
                parentCase.Account_Collection_Manager_Email__c 	= 'sachin.kothari@cleartax.in';
            }
            /**	
            if(
                parentCase.Subject.containsIgnoreCase('Proforma Invoice')
            ){
                parentCase.OwnerId 								= '0052x000003RHEeAAO';	//	abhijeet.haldar@cleartax.in
                parentCase.Priority								= 'P1';
                parentCase.User_Role_Type__c 						= 'Finance L1';
                parentCase.Account_Collection_Manager_Email__c 	= 'nageshkumar.shivappa@cleartax.in';
            }
            
            if(
                mail.FromAddress?.containsIgnoreCase('no-reply@signdesk.com')				||
                mail.FromAddress?.containsIgnoreCase('no-reply@razorpay.com') 				||
                mail.FromAddress?.containsIgnoreCase('reports@razorpay.com')				||
                mail.FromAddress?.containsIgnoreCase('e-invoicing@cleartaxmailer.com')		||
                mail.FromAddress?.containsIgnoreCase('notifications.sf@cleartaxmailer.com')	||
                mail.FromAddress?.containsIgnoreCase('alerts@cleartax.in')					||
                mail.FromAddress?.containsIgnoreCase('hrcommunications@cleartax.in')		||
                mail.Subject?.containsIgnoreCase('Out of Office')							||
                mail.Subject?.containsIgnoreCase('On leave')
            ){
                parentCase.Status 				= 'Junk';
                parentCase.Priority				= 'P3';
                parentCase.User_Role_Type__c 	= 'Finance L2';
                parentCase.OwnerId				= '00G71000000cFyvEAE';
            }
            **/
        }
        
        return parentCase;
    }
    
}