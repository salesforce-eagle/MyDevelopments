@RestResource(urlMapping='/receivableApi/*')
global class CTX_ReceivableDataIntegrationAPi {
    
    @HttpGet
    global static String getReceivableDetails(){
        
        RestRequest 				      request					            =  RestContext.request;
        String      				      receivableId         	                =  request?.params.get('Id');
        CTX_ReceivableServiceWrapper 	  returnReceivableDetailsList	        =  new CTX_ReceivableServiceWrapper();
        
        system.debug('receivableId: '+receivableId);
        if(!string.isBlank(receivableId) ){
            system.debug('Inside Block to get getReceivableDetails Details');
            
            Receivables__c thisRecord = [SELECT Id, Name, Owner.Name, CurrencyIsoCode, CT_Billing_Entity__c, Virtual_Account_Number__c,
                                         PAN_TIN__c, SAP_BP_Code__c, Name_of_the_entity__c, Account__r.Name, Active_ARR__c, Account_CSM__c,
                                         Account_Owner__c, Entity_PAN__c, CreatedBy.Name, LastModifiedBy.Name,Account_CSM_18__c,
                                         Account_Owner_Email__c,Account_CSM_Email__c,SAP_DB__c,Account_Owner_Id_18__c 
                                         FROM Receivables__c WHERE Id =: (Id)receivableId LIMIT 1];
            
            returnReceivableDetailsList.name                    =      thisRecord.Name;
            returnReceivableDetailsList.id                      =      thisRecord.Id;
            returnReceivableDetailsList.currencyType            =      thisRecord.CurrencyIsoCode;
            returnReceivableDetailsList.cTBillingEntity         =      thisRecord.CT_Billing_Entity__c;
            returnReceivableDetailsList.virtualAccountNumber    =      thisRecord.Virtual_Account_Number__c;
            returnReceivableDetailsList.ownerName               =      thisRecord.Owner.Name;
            returnReceivableDetailsList.pAN_TIN                 =      thisRecord.PAN_TIN__c;
            returnReceivableDetailsList.sapBpCode               =      thisRecord.SAP_BP_Code__c;
            returnReceivableDetailsList.nameOfTheEntity         =      thisRecord.Name_of_the_entity__c;
            returnReceivableDetailsList.account                 =      thisRecord.Account__r.Name;
            returnReceivableDetailsList.activeARR               =      thisRecord.Active_ARR__c;
            returnReceivableDetailsList.accountCSM              =      thisRecord.Account_CSM__c;
            returnReceivableDetailsList.entityPAN               =      thisRecord.Entity_PAN__c;
            returnReceivableDetailsList.accountOwnerName        =      thisRecord.Account_Owner__c;
            returnReceivableDetailsList.createdBy               =      thisRecord.CreatedBy.Name;
            returnReceivableDetailsList.lastModifiedBy          =      thisRecord.LastModifiedBy.Name;
            returnReceivableDetailsList.accountOwnerEmail       =      thisRecord.Account_Owner_Email__c;
            returnReceivableDetailsList.accountCSMEmail         =      thisRecord.Account_CSM_Email__c;
            returnReceivableDetailsList.sAPDB         			=      thisRecord.SAP_DB__c;
            returnReceivableDetailsList.accountOwnerId          =      thisRecord.Account_Owner_Id_18__c;
            returnReceivableDetailsList.accountCSMId            =      thisRecord.Account_CSM_18__c;
            
            system.debug('Receivables__c thisRecord ' + thisRecord);
            
        }
        
        if(returnReceivableDetailsList != NULL){
            return JSON.serialize(returnReceivableDetailsList);
        } else{
            return 'No open Receivables found for the customer.';
        }
    }
    
}