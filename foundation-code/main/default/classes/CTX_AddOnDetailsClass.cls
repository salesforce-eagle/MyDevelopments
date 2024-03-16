public class CTX_AddOnDetailsClass {
    
    @AuraEnabled
    public static InitWrapper fetchRequiredDetails(String recordId){
        
        InitWrapper		wrapperResult		= new InitWrapper();
        Set<String> 	productSKUs 		= new Set<String>();
        String 			erpFamily;
        Set<Id>			existingAddOns		= new Set<Id>();
        
        if(recordId != NULL){
            
            wrapperResult.availableScopeAddOns = [ SELECT Id, Related_Quote__c, Related_Opportunity__c, Related_Add_On__c,
                                                  
                                                  Discount_Percentage__c, Discount_Rate__c, ERP_Family__c, 
                                                  Is_Active__c, List_Price__c, Module__c, Name, 
                                                  Product_SKU__c, Estimated_Effort_In_Days__c, Add_On_Status__c, Scope__c, 
                                                  Reject_Reason__c 
                                                  
                                                  FROM Integration_Scope_Add_On__c WHERE Related_Quote__c =:recordId  ];
            
            if(wrapperResult.availableScopeAddOns.size() > 0)
                wrapperResult.isScopeAvailable = TRUE;
            
            for(Integration_Scope_Add_On__c thisRec : wrapperResult.availableScopeAddOns){
                
                existingAddOns.add(thisRec.Related_Add_On__c);
                wrapperResult.totalSellPrice 		= wrapperResult.totalSellPrice + thisRec.List_Price__c;
                wrapperResult.totalDiscountedPrice 	= wrapperResult.totalDiscountedPrice + thisRec.Discount_Rate__c;
            }
            
            for(
                QuoteLineItem thisRec : [ SELECT Id, Product2.OrderForm_Product_Name__c,
                                         
                                         Quote.Opportunity.ERP_Family__c, Quote.ERP__c, 
                                         Quote.Opportunity.Owner.ManagerId
                                         
                                         FROM QuoteLineItem WHERE 
                                         QuoteId =: recordId AND 
                                         Product2.Billing_Type__c = 'OTP' ]
            ){
                erpFamily = thisRec.Quote.ERP__c ;
                productSKUs.add(thisRec.Product2.OrderForm_Product_Name__c);
            }
            
            wrapperResult.integrationAddOnMap = new Map<Id, Integration_Add_On__c>(
                [ SELECT Id, Name, ERP_Family__c, Product_SKU__c, Module__c, 
                 Estimated_Effort_in_Days__c, List_Price__c, Add_On_Scope__c, Type__c  
                 
                 FROM Integration_Add_On__c WHERE 
                 
                 ERP_Family__c =:erpFamily AND 
                 Product_SKU__c IN :productSKUs ] );
            
            for(Id thisId : existingAddOns){
                if(wrapperResult.integrationAddOnMap.containsKey(thisId)){
                    wrapperResult.integrationAddOnMap.remove(thisId);
                }
            }
            
            
            
            
        } else{
            system.debug('Invalid OpportunityId');
            wrapperResult.isSuccess 	= FALSE;
            wrapperResult.errorMessage 	= 'Invalid OpportunityId';
        }
        
        wrapperResult.integrationAddOns = new List<Integration_Add_On__c>(wrapperResult.integrationAddOnMap.values());
        
        
        return wrapperResult;
    }
    
    
    Public Class InitWrapper{
        
        @AuraEnabled
        Public Map<Id, Integration_Add_On__c>		integrationAddOnMap;
        
        @AuraEnabled
        Public List<Integration_Add_On__c> 			integrationAddOns;
        
        
        @AuraEnabled
        Public List<Integration_Scope_Add_On__c>	availableScopeAddOns;
        
        @AuraEnabled
        Public Decimal								totalSellPrice			= 0;
        
        @AuraEnabled
        Public Decimal								totalDiscountedPrice	= 0;
        
        @AuraEnabled
        Public String			 					errorMessage;
        
        @AuraEnabled
        Public Boolean 								isScopeAvailable 		= 	FALSE;
        
        @AuraEnabled
        Public Boolean 								isSuccess 				= 	FALSE;
    }
    
    
    @AuraEnabled
    public static ApprovalWrapper sendForApproval( 
        List<Integration_Scope_Add_On__c> 	incomingValues, 
        String 								recordId 
    ){
        
        ApprovalWrapper	returnWrapper					= new ApprovalWrapper();
        List<sObject> 	quoteAndIntegrationScopeUpsert	= new List<sObject>();
        
        system.debug('recordId recordId recordId recordId recordId: '+recordId);
        system.debug('incomingValues: '+incomingValues);
        
        Quote thiRec = new Quote(
            Id = recordId,
            Add_On_Approval_Status__c = 'In Approval'
        );
        
        quoteAndIntegrationScopeUpsert.add(thiRec);
        quoteAndIntegrationScopeUpsert.addAll(incomingValues);
        
        try{
            upsert quoteAndIntegrationScopeUpsert;
            returnWrapper.isSuccess = TRUE;
        } catch(Exception ex){
            system.debug('Error while Upserting Integration Scope Add Ons: '+ex.getMessage());
            returnWrapper.errorMessage = 'We encountred an error: '+ex.getMessage();
        }
        
        
        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
        approvalRequest.setComments('Please check the records and approve.');
        approvalRequest.setObjectId(recordId);
        approvalRequest.setSubmitterId(UserInfo.getUserId());
        approvalRequest.setProcessDefinitionNameOrId('Quote_Integration_Approval');
        approvalRequest.setSkipEntryCriteria(true);
        
        if(returnWrapper.isSuccess){
            try{
                Approval.ProcessResult result = Approval.process(approvalRequest);
            }catch(Exception ex){
                system.debug('Error while Sending Approval Process: '+ex.getMessage());
                returnWrapper.errorMessage = 'We encountred an error: '+ex.getMessage();
            }
        }
        
        system.debug('returnWrapper Approval : '+returnWrapper);
        return returnWrapper;
    }
    
    
    Public Class ApprovalWrapper{
        
        @AuraEnabled
        Public String			 					errorMessage;
        
        @AuraEnabled
        Public Boolean 								isSuccess 				= 	FALSE;
    }
    
    
    public static void quoteApprovalProcessUpdates(
        Map<Id, Quote> approvedMap, 
        Map<Id, Quote> rejectedMap
    ){
        
        Map<String, Set<Integration_Scope_Add_On__c>> 	erpSKUIntegrationScopeMap 	= new Map<String, Set<Integration_Scope_Add_On__c>>();
        Map<Id, sObject>								quoteLineItemAndISAList		= new Map<Id, sObject>();        
        
        if(approvedMap.size() > 0){
            
            for(
                Integration_Scope_Add_On__c thisRec : [ SELECT Id, Related_Opportunity__c, Related_Add_On__c, 
                                                       Related_Quote__c, 
                                                       
                                                       Discount_Percentage__c, Discount_Rate__c, ERP_Family__c, 
                                                       Is_Active__c, List_Price__c, Module__c, Name, 
                                                       Product_SKU__c, Add_On_Status__c, Estimated_Effort_In_Days__c
                                                       
                                                       FROM Integration_Scope_Add_On__c WHERE 
                                                       Related_Quote__c  IN :approvedMap.keySet() ]
            ){
                
                String tempString = thisRec.ERP_Family__c + thisRec.Product_SKU__c;
                if(erpSKUIntegrationScopeMap.containsKey(tempString)){
                    erpSKUIntegrationScopeMap.get(tempString).add(thisRec);
                } else{
                    erpSKUIntegrationScopeMap.put(tempString, new Set<Integration_Scope_Add_On__c>{thisRec});
                }
                
                thisRec.Add_On_Status__c = 'Approved';
                quoteLineItemAndISAList.put(thisRec.Id, thisRec);
            }
            system.debug('quoteLineItemAndISAList Integration_Scope_Add_On__c Approved: '+quoteLineItemAndISAList);
            
            for(
                QuoteLineItem thisRec : [ SELECT Id, UnitPrice, Sale_Price__c, Add_On_Prices__c, Add_On_Discounted_Price__c, 
                                         Actual_Unit_Price__c, Actual_Sell_Price__c, Product2.OrderForm_Product_Name__c, 
                                         Quote.OpportunityId, Quote.Opportunity.ERP_Family__c, 
                                         Quote.Opportunity.Owner.ManagerId, Quote.ERP__c
                                         
                                         FROM QuoteLineItem WHERE QuoteId IN :approvedMap.keySet() ]
            ){
                String tempString = thisRec.Quote.ERP__c + thisRec.Product2.OrderForm_Product_Name__c;
                if(erpSKUIntegrationScopeMap.containsKey(tempString)){
                    
                    for( Integration_Scope_Add_On__c thisOne : erpSKUIntegrationScopeMap.get(tempString) ){
                        if(thisOne.Related_Opportunity__c == thisRec.Quote.OpportunityId){
                            
                            thisRec.Add_On_Prices__c			= thisRec.Add_On_Prices__c + thisOne.List_Price__c;
                            thisRec.Add_On_Discounted_Price__c	= thisRec.Add_On_Discounted_Price__c + thisOne.Discount_Rate__c;
                            
                            thisRec.UnitPrice 					= thisRec.UnitPrice + thisOne.List_Price__c;
                            thisRec.Sale_Price__c 				= thisRec.Sale_Price__c + thisOne.Discount_Rate__c;
                            
                            quoteLineItemAndISAList.put(thisRec.Id, thisRec);
                        } 
                    }
                    system.debug('quoteLineItemAndISAList QuoteLineItem: '+quoteLineItemAndISAList);
                }
            }
        }
        
        
        if(rejectedMap.size() > 0){
            system.debug('I am Bibhu'+rejectedMap);
            Map<Id, String>	quoteIdAndRejectReason = new Map<Id, String>();
            for(
                ProcessInstance thisRec : [ SELECT Id, TargetObjectId, Status, 
                                           ( SELECT Id, StepStatus, Comments 
                                            FROM Steps
                                            ORDER BY CreatedDate DESC
                                            LIMIT 1 )
                                           FROM ProcessInstance WHERE 
                                           TargetObjectId IN :rejectedMap.keySet() 
                                           ORDER BY CreatedDate DESC LIMIT 1 ] 
            ){
                quoteIdAndRejectReason.put(thisRec.TargetObjectId, thisRec.Steps[0].Comments);
            }
            
            List<Integration_Scope_Add_On__c> deleteScope = new List<Integration_Scope_Add_On__c>();
            
            for(
                Integration_Scope_Add_On__c thisRec : [ SELECT Id, Related_Opportunity__c, Related_Add_On__c,
                                                       Related_Quote__c,
                                                       
                                                       Discount_Percentage__c, Discount_Rate__c, ERP_Family__c, 
                                                       Is_Active__c, List_Price__c, Module__c, Name, 
                                                       Product_SKU__c, Add_On_Status__c, Reject_Reason__c, Estimated_Effort_In_Days__c 
                                                       
                                                       FROM Integration_Scope_Add_On__c WHERE 
                                                       Related_Quote__c  IN :rejectedMap.keySet() AND
                                                       Add_On_Status__c = 'In Approval' ]
            ){     
                system.debug('I am Rec: '+thisRec);
                thisRec.Reject_Reason__c = quoteIdAndRejectReason.get(thisRec.Related_Quote__c);
                thisRec.Add_On_Status__c = 'Rejected';
                deleteScope.add(thisRec);
            }
            try{
                update deleteScope;
            } catch(Exception ex){
                system.debug('Error While deleting Scope: '+ex.getMessage());
            }
            
        }
        
        system.debug('quoteLineItemAndISAList Integration_Scope_Add_On__c Rejected: '+quoteLineItemAndISAList);
        if(quoteLineItemAndISAList.size() > 0){
            update quoteLineItemAndISAList.values();
        }
        
    }
    
}