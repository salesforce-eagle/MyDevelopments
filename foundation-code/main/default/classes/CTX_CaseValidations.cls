public class CTX_CaseValidations {
    
    public static Case financeQueriesCaseValidations(
        Case 														thisCase, 
        Id 															collectionManagerId,
        Map<String, Case_Owner_Assignment_Based_On_Subject__mdt> 	caseSubjectMappingMap
    ){
        
        system.debug('thisCase.Subject:thisCase.Subject:thisCase.Subject: '+thisCase.Subject);
        if(thisCase.Subject != NULL){
            
            thisCase.User_Role_Type__c 						= 'Finance L0';
            /**	**/
            if(
                thisCase.Subject?.containsIgnoreCase('Greetings from Defmacro') ||
                thisCase.Subject?.containsIgnoreCase('Sales Order')
            ){
                thisCase.OwnerId 								= System.Label.Greetings_from_Defmacro_Sales_Order;	/**	vinayak.mesta@cleartax.in	**/
                thisCase.Priority								= 'P0';
                thisCase.User_Role_Type__c 						= 'Finance L0';
                thisCase.Account_Collection_Manager_Email__c 	= 'mani.kant@cleartax.in';
            }
            /**	**/
           /** if(
                thisCase.Subject?.startsWithIgnoreCase('Invoice')
            ){
                system.debug('I am check');
                thisCase.OwnerId 								= System.Label.Invoice;	/**	munish.kumar@cleartax.in	
                thisCase.Priority								= 'P0';
                thisCase.User_Role_Type__c 						= 'Finance L0';
            }

            if(
                thisCase.Subject?.containsIgnoreCase('Payment Reminder')
            ){
                thisCase.OwnerId 								= collectionManagerId;
                thisCase.Priority								= 'P1';
                thisCase.User_Role_Type__c 						= 'Finance L1';
            }

            if(
                thisCase.Subject?.containsIgnoreCase('Credit Intimation')		||
                thisCase.Subject?.containsIgnoreCase('Statement of accounts')	||
                thisCase.Subject?.containsIgnoreCase('Reconciliation')			||
                thisCase.Subject?.containsIgnoreCase('Payment Advice')			||
                thisCase.Subject?.containsIgnoreCase('TDS Certificate')			||
                thisCase.Subject?.containsIgnoreCase('Form 16A')
            ){
                thisCase.OwnerId								= System.Label.Credit_Intimation_to_Form_16A;	
                
                if(thisCase.Subject?.containsIgnoreCase('Credit Intimation')){
                    thisCase.Priority								= 'P0';
                    thisCase.User_Role_Type__c 						= 'Finance L0';
                }
                
                if(thisCase.Subject?.containsIgnoreCase('Statement of accounts')){
                    thisCase.Priority								= 'P1';
                    thisCase.User_Role_Type__c 						= 'Finance L1';
                }
                
                if(thisCase.Subject?.containsIgnoreCase('Reconciliation')){
                    thisCase.Priority								= 'P0';
                    thisCase.User_Role_Type__c 						= 'Finance L0';
                }
                
                if(thisCase.Subject?.containsIgnoreCase('Payment Advice')){
                    thisCase.Priority								= 'P0';
                    thisCase.User_Role_Type__c 						= 'Finance L0';
                }
                
                if(thisCase.Subject?.containsIgnoreCase('TDS Certificate')){
                    thisCase.Priority								= 'P1';
                    thisCase.User_Role_Type__c 						= 'Finance L1';
                }
                
                if(thisCase.Subject?.containsIgnoreCase('Form 16A')){
                    thisCase.Priority								= 'P1';
                    thisCase.User_Role_Type__c 						= 'Finance L1';
                }
                
            }

            if(
                thisCase.Subject?.containsIgnoreCase('Purchase Order')
            ){
                thisCase.OwnerId 								= System.Label.Purchase_Order;	
                thisCase.Priority								= 'P1';
                thisCase.User_Role_Type__c 						= 'Finance L1';
                thisCase.Account_Collection_Manager_Email__c 	= 'sachin.kothari@cleartax.in';
            }

            if(
                thisCase.Subject?.containsIgnoreCase('Proforma Invoice')
            ){
                thisCase.OwnerId 								= System.Label.Proforma_Invoice;	
                thisCase.Priority								= 'P1';
                thisCase.User_Role_Type__c 						= 'Finance L1';
                thisCase.Account_Collection_Manager_Email__c 	= 'nageshkumar.shivappa@cleartax.in';
            }
            
            if(
                thisCase.ContactEmail?.containsIgnoreCase('no-reply@signdesk.com')				||
                thisCase.ContactEmail?.containsIgnoreCase('no-reply@razorpay.com') 				||
                thisCase.ContactEmail?.containsIgnoreCase('reports@razorpay.com')				||
                thisCase.ContactEmail?.containsIgnoreCase('e-invoicing@cleartaxmailer.com')		||
                thisCase.ContactEmail?.containsIgnoreCase('notifications.sf@cleartaxmailer.com')	||
                thisCase.ContactEmail?.containsIgnoreCase('alerts@cleartax.in')					||
                thisCase.ContactEmail?.containsIgnoreCase('hrcommunications@cleartax.in')		||
                thisCase.Subject.containsIgnoreCase('Out of Office')							||
                thisCase.Subject.containsIgnoreCase('On leave')
            )**/else{
                thisCase.Status 				= 'Fail The Case Creation';
                thisCase.Priority				= 'P3';
                thisCase.User_Role_Type__c 		= 'Finance L2';
                thisCase.OwnerId				= '00G71000000cFyvEAE';
            }
        }
        
        return thisCase;
    }
    
    Public Static Case internalIssuesCaseValidation(Case thisCase, Map<String, User> caseEmail_DepartmentMap){
        
        if(thisCase.ContactEmail != NULL){
            if(caseEmail_DepartmentMap.size() > 0){
                if(caseEmail_DepartmentMap.containsKey(thisCase.ContactEmail)){
                    if(caseEmail_DepartmentMap.get(thisCase.ContactEmail) != NULL){
                        
                        String ownerDepartment = caseEmail_DepartmentMap.get(thisCase.ContactEmail).Department;
                        if(ownerDepartment.containsIgnoreCase('KAM')){
                            thisCase.OwnerId = '00G71000000cYyL';
                        } else{
                            thisCase.OwnerId = '00G71000000cYwj';
                        }
                    }
                }
            }
        }
        
        return thisCase;
    }
    
    public static Case CaseKeywordMining(Case thisCase){
        
        Map<String, Email_Keyword_Mining__mdt > mapEKM = Email_Keyword_Mining__mdt.getAll();
        Map<String, Schema.SObjectField> fMapMD        = Schema.getGlobalDescribe().get('email_keyword_mining__mdt').getDescribe().Fields.getMap();
        Map<String, Schema.SObjectField> fMapCase      = Schema.getGlobalDescribe().get('case').getDescribe().Fields.getMap();
        
        if(!String.ISBLANK(thisCase.Subject)){
            for(String keySetString : mapEKM.keySet()){
                
                if(thisCase.Subject?.containsIgnoreCase(mapEKM.get(keySetString).label)){
                    if (!fMapMD.isEmpty()){
                        for (Schema.SObjectField ft       : fMapMD.values()){ // loop through all field tokens (ft)
                            Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                            system.debug(fd.label); /// your field action here
                            if(fMapCase.containsKey(fd.label)){
                                system.debug('Fieldname%^ '+fd.label+' FieldValue%%^& '+ mapEKM.get(keySetString).get(fd.name));
                                thisCase.put(fd.label,mapEKM.get(keySetString).get(fd.name));  
                            }
                        }
                    }
                    
                }
            }
        }
        return thisCase;
    }
}