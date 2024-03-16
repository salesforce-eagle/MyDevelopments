public without sharing class UpsellTriggerHandler implements TriggerInterface{
    
    
    public void beforeInsert(List<sObject> listofNewsObjectRecords){}
    
    public void afterInsert(List<sObject> listofNewsObjectRecords, Map<Id,sObject> mapofNewsObjectRecords){
        
        Map<Id, Upsell_Top_up__c> 	newUpsellMap = (Map<Id, Upsell_Top_up__c>)mapofNewsObjectRecords;
        Map<Id,Upsell_Top_up__c>	mapOfNewUpsellToUpdate	= new Map<Id,Upsell_Top_up__c>();
        
        if(newUpsellMap.size()>0){
            UpsellTriggerHelper.checkUpsell(newUpsellMap);
            //UpsellTriggerHelper.updateAdditionalGstinAddOnSplit(newUpsellMap);
        }
   
    }
    
    public void beforeUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){
        Map<Id, Upsell_Top_up__c> 	newUpsellMap 								= (Map<Id, Upsell_Top_up__c>)mapofNewsObjectRecords;
        Map<Id, Upsell_Top_up__c> 	oldUpsellMap 								= (Map<Id, Upsell_Top_up__c>)mapofOldsObjectRecords;
        Map<Id,Upsell_Top_up__c>	mapOfUpsellToUpdate							= new Map<Id,Upsell_Top_up__c>();
        Map<Id,Upsell_Top_up__c>	mapOfUpsellToValidateAdditionalGstins		= new Map<Id,Upsell_Top_up__c>();
        List<Upsell_Top_up__c>		listOfPhysicalSignUpsForOrderFormValidation	= new List<Upsell_Top_up__c>();
        
        for(Id key:newUpsellMap.KeySet()){
            Upsell_Top_up__c UpsellNewInstance=(Upsell_Top_up__c)newUpsellMap.get(key);
            Upsell_Top_up__c UpsellOldInstance=(Upsell_Top_up__c)oldUpsellMap.get(key);
            
            /** @Ashwin - Check if Additional Gstin is added to Upsell **/
            if(UpsellNewInstance.Stage__c != UpsellOldInstance.Stage__c && 
               UpsellNewInstance.Stage__c == 'Finance Approval'){		
                   mapOfUpsellToValidateAdditionalGstins.put(UpsellNewInstance.Id,UpsellNewInstance);
               }
            
            /** @Ashwin - Reset eSign params when stage moved back from Fin Approval **/
            if((UpsellNewInstance.Stage__c != UpsellOldInstance.Stage__c) &&
               UpsellNewInstance.Stage__c != 'Finance Approval'           &&
               UpsellNewInstance.Stage__c != 'Closed')
            {		
                UpsellNewInstance.E_Sign_Status__c 			= NULL;
                UpsellNewInstance.ESign_CTX_Status__c 		= NULL;
                UpsellNewInstance.ESign_Client_Status__c 	= NULL;
                UpsellNewInstance.ESign_Message__c 			= NULL;
                UpsellNewInstance.Retrigger_E_Sign__c 		= NULL;
                UpsellNewInstance.ESign_Doc_Updated__c 		= FALSE;
                UpsellNewInstance.Physical_Sign_Completed__c= FALSE;
                
            }
            
            
            /** @Ashwin - Reset eSign params when Physical_Sign_completed__c is unchecked OR Re-triggered for eSign **/
            if(
                (
                    UpsellNewInstance.Physical_Sign_completed__c != UpsellOldInstance.Physical_Sign_completed__c &&
                    !UpsellNewInstance.Physical_Sign_completed__c
                ) 
                || 
                (
                    String.isNotBlank(UpsellNewInstance.Retrigger_E_Sign__c) 						&&  
                    UpsellOldInstance.Retrigger_E_Sign__c != UpsellNewInstance.Retrigger_E_Sign__c  &&
                    UpsellNewInstance.Retrigger_E_Sign__c   == 'Resend'
                )
            ){
                
                UpsellNewInstance.E_Sign_Status__c 			= NULL;
                UpsellNewInstance.ESign_CTX_Status__c 		= NULL;
                UpsellNewInstance.ESign_Message__c 			= NULL;
                UpsellNewInstance.ESign_Client_Status__c 	= NULL;
                UpsellNewInstance.ESign_Doc_Updated__c 		= FALSE;
            }
            
            
            /** @Ashwin - Update Upsell Stage to Closed Won when ESign Status is Successfull **/
            if((UpsellNewInstance.E_Sign_Status__c != UpsellOldInstance.E_Sign_Status__c) && UpsellNewInstance.E_Sign_Status__c == 'E-Sign Successful'){
                mapOfUpsellToUpdate.put(UpsellNewInstance.Id,UpsellNewInstance);
            }
            
            /** @Ashwin - Check signed order form is attached when Physical_Sign_completed__c is checked **/
            if(
                UpsellNewInstance.ESign_Category__c == 'Physical Sign' && 
                UpsellNewInstance.Physical_Sign_completed__c == TRUE && 
                UpsellOldInstance.Physical_Sign_completed__c == FALSE
            ){
                listOfPhysicalSignUpsForOrderFormValidation.add(UpsellNewInstance);
            }
            
            /** @Ashwin - Update closed date when Upsell is closed **/
            if((UpsellNewInstance.Stage__c != UpsellOldInstance.Stage__c) && UpsellNewInstance.Stage__c == 'Closed'){		
                UpsellNewInstance.Upsell_close_date__c = System.TODAY();
            }
            
        }
        
        /** @Ashwin - Check if Additional Gstin is added to Upsell **/
        if(mapOfUpsellToValidateAdditionalGstins.size()>0){
            UpsellTriggerHelper.validateAdditionalGstins(mapOfUpsellToValidateAdditionalGstins); 
        }
        
        /** @Ashwin - Check signed order form is attached when Physical_Sign_completed__c is checked **/
        if(!listOfPhysicalSignUpsForOrderFormValidation.isEmpty()){
            UpsellTriggerHelper.checkForOrderForm(listOfPhysicalSignUpsForOrderFormValidation,true);
        }
        
        /** @Ashwin - Update Upsell Stage to Closed Won when ESign Status is Successfull **/
        if(mapOfUpsellToUpdate.size()>0){
            UpsellTriggerHelper.updateUpsellStage(mapOfUpsellToUpdate);
        }
    }
    
    public void afterUpdate(map<id,sObject> mapofNewsObjectRecords,map<id,sObject> mapofOldsObjectRecords){
        UpsellConstants.isFirstTimeUpsell = False;
        Map<Id, Upsell_Top_up__c> 	newUpsellMap 						= (Map<Id, Upsell_Top_up__c>)mapofNewsObjectRecords;
        Map<Id, Upsell_Top_up__c> 	oldUpsellMap 						= (Map<Id, Upsell_Top_up__c>)mapofOldsObjectRecords;
        Map<Id,Upsell_Top_up__c>	mapOfNewUpsellToUpdate				= new Map<Id,Upsell_Top_up__c>();
        Map<Id,Upsell_Top_up__c>	mapOfNewUpsellToSubmit				= new Map<Id,Upsell_Top_up__c>();
        Map<String,String> 			mapOfUpsellToItsESignCustomerId 	= new Map<String,String>();
        List<Upsell_Top_up__c> 		listOfUpsellsForESignRequest 		= new  List<Upsell_Top_up__c>();
        Map<Id,Upsell_Top_up__c> 	MapOfUpsellsToCloneCvs 				= new  Map<Id,Upsell_Top_up__c>();
        
        for(Id key:newUpsellMap.KeySet()){
            Upsell_Top_up__c UpsellNewInstance=(Upsell_Top_up__c)newUpsellMap.get(key);
            Upsell_Top_up__c UpsellOldInstance=(Upsell_Top_up__c)oldUpsellMap.get(key);
            
            /** @Ashwin - Send for Finance Approval **/
            if(UpsellNewInstance.Stage__c != UpsellOldInstance.Stage__c &&
               UpsellNewInstance.Stage__c == 'Finance Approval'){
                   mapOfNewUpsellToSubmit.put(UpsellNewInstance.Id,UpsellNewInstance); 
                   System.debug('FIN APPROVAL MAP -->'+mapOfNewUpsellToSubmit);
               }
            
            /** @Ashwin - Update Asset with Upsell params and Create upsell opportunity on upsell closure **/
            if(UpsellNewInstance.Stage__c != UpsellOldInstance.Stage__c &&
               UpsellNewInstance.Stage__c == 'Closed' && 
               UpsellNewInstance.Sub_Stage__c == 'Closed Won'){
                   mapOfNewUpsellToUpdate.put(UpsellNewInstance.Id,UpsellNewInstance);
               }
                
            /**	@Ashwin - Revoke Order Form when retriggered for eSign **/
            if(UpsellNewInstance.Stage__c == 'Finance Approval') 
            {			
                if(UpsellNewInstance.Retrigger_E_Sign__c   != UpsellOldInstance.Retrigger_E_Sign__c	&&
                   UpsellNewInstance.Retrigger_E_Sign__c   == 'Resend')
                {
                    System.debug('In Revoke Approval');
                    CTX_SignDeskAPIQueuable myJob 
                        = new CTX_SignDeskAPIQueuable( 
                            UpsellNewInstance.ESign_BE_Document_ID__c, 
                            UpsellNewInstance.ESign_BE_Docket_ID__c
                        );
                    System.enqueueJob(myJob);
                    
                    MapOfUpsellsToCloneCvs.put(UpsellNewInstance.Id, UpsellNewInstance);
                }
                
                
            }
            
            /** E-Sign **/
            if(UpsellNewInstance.ESign_Category__c      == 'E-Sign'	){
                if((UpsellNewInstance.Approval_Status__c 	!= UpsellOldInstance.Approval_Status__c 	&&
                    UpsellNewInstance.Approval_Status__c 	== 'Finance Approval Approved')	
                  )
                {
                    
                    listOfUpsellsForESignRequest.add(UpsellNewInstance);
                    mapOfUpsellToItsESignCustomerId.put(UpsellNewInstance.Id, UpsellNewInstance.E_Sign_Customer_Info__c);
                }
            } 
            /** Physical Sign **/
            else if(
                UpsellNewInstance.ESign_Category__c == 'Physical Sign' && 
                UpsellNewInstance.Approval_Status__c == 'Finance Approval Approved' &&
                UpsellNewInstance.Physical_Sign_completed__c == TRUE && 
                UpsellOldInstance.Physical_Sign_completed__c == FALSE
            ){
                listOfUpsellsForESignRequest.add(UpsellNewInstance);
            }
            
            
            /** @Ashwin - Resend eSign **/
            if( 
                UpsellNewInstance.Retrigger_E_Sign__c 	!= UpsellOldInstance.Retrigger_E_Sign__c	&&
                UpsellNewInstance.Retrigger_E_Sign__c   == 'Resend'
            ) 
            {
                if(UpsellNewInstance.Approval_Status__c 	== 'Finance Approval Approved'){
                    listOfUpsellsForESignRequest.add(UpsellNewInstance);
                    mapOfUpsellToItsESignCustomerId.put(UpsellNewInstance.Id, UpsellNewInstance?.E_Sign_Customer_Info__c);
                }else{
                    UpsellNewInstance.addError('Please try resending after Finance Approval!');
                }
            }
            
        }  
        /** @Ashwin - Clone CV on Resend eSign **/
        if(MapOfUpsellsToCloneCvs.size()>0){
            UpsellTriggerHelper.cloneCvs(MapOfUpsellsToCloneCvs);
        }
        /** @Ashwin - Send for Finance Approval **/
        if(mapOfNewUpsellToSubmit.size()>0){
            UpsellTriggerHelper.submitForApproval(mapOfNewUpsellToSubmit);
        }
        
         /** @Ashwin 
          	 *Update Asset with Upsell params*
			 *Create upsell opportunity*
			 *Update Addn Gstins*
		     *Update Upsell Revenue on upsell closure*
		 **/
        if(mapOfNewUpsellToUpdate.size()>0){
            UpsellTriggerHelper.updateAsset(mapOfNewUpselltoUpdate);
            UpsellTriggerHelper.createOpportunity(mapOfNewUpselltoUpdate);
            UpsellTriggerHelper.updateAdditionalGstinAmount(mapOfNewUpselltoUpdate);
            UpsellTriggerHelper.updateRevenueFromUpsell(mapOfNewUpselltoUpdate);
        }
        
        
        /** @Ashwin - SF <> SignDesk **/
        if(!listOfUpsellsForESignRequest.isEmpty()){
            System.enqueueJob(new CTX_UpsellEsignRequest(listOfUpsellsForESignRequest, mapOfUpsellToItsESignCustomerId));
        }        
        
        
    }
    
    public void beforeDelete(list<sObject> listofOldsObjectRecords,map<id,sObject> mapofOldsObjectRecords){}
    
    public void afterDelete(map<id,sObject> mapofOldsObjectRecords){
        Map<Id, Upsell_Top_up__c> 	oldUpsellMap = (Map<Id, Upsell_Top_up__c>)mapofOldsObjectRecords;
        if(oldUpsellMap.size()>0){
            UpsellTriggerHelper.checkUpsellOnDelete(oldUpsellMap);
        }
        
        UpsellTriggerHelper.updateRevenueFromUpsell(oldUpsellMap);
    }
    
    public void afterUndelete(list<sObject> listofNewsObjectRecords,map<id,sObject> mapofNewsObjectRecords){}
    
}