global class CTX_AssetStatusCorrector_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    public String 			query;
    public Map<Id, String>	errorResults	= new Map<Id, String>();
    
    global CTX_AssetStatusCorrector_Batch (String soql){
        query = soql;
    }
    
    global Database.Querylocator start(Database.BatchableContext bc){
        
        system.debug('query string: ' + query);
        
        return Database.getQuerylocator(query);
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        
        Map<Id, Asset> 		assetMap 		= new Map<Id, Asset>((List<Asset>)scope);
        Map<Id, Boolean> 	parentAssetMap 	= new Map<Id, Boolean>();
        Map<Id, Asset> 		parentAssets 	= new Map<Id, Asset>([ SELECT Id, ParentId FROM Asset WHERE ParentId IN :assetMap.keySet() ]);
        
        for( Asset thisRec : parentAssets.values() ){
            if( assetMap.containsKey(thisRec.ParentId) ){
                parentAssetMap.put(thisRec.ParentId, TRUE);
            }
        }
        
        Integer validCount = 1;
        Integer expiredCount = 1;
        Integer validRenewedCount = 1;
        Integer renewedCount = 1;
        Integer futureCount = 1;
        
        
        for( Asset thisAsset : assetMap.values() ){
            
            /*if( thisAsset.Asset_Status__c != NULL && thisAsset.Asset_Status__c != thisAsset.Status ){
                thisAsset.Status = thisAsset.Asset_Status__c;
            } else*/ If(
                thisAsset.PurchaseDate <= Date.Today() && thisAsset.UsageEndDate >= Date.Today() && 
                (
                    thisAsset.Status != AssetConstants.STATUS_SALES_RETURN && 
                    thisAsset.Status != AssetConstants.STATUS_CHURN 
                    /*&& thisAsset.Status != AssetConstants.STATUS_UPCOMING_RENEWAL*/
                ) && 
                ( /*!( parentAssetMap.containsKey(thisAsset.Id) && !thisAsset.multi_year__c  ) &&  */
                 (
                     !parentAssetMap.containsKey(thisAsset.Id) && 
                     !thisAsset.multi_year__c  && 
                     ((thisAsset.renewal_opportunity__c != null && 
                       thisAsset.renewal_opportunity__r.stageName != OpportunityConstants.STAGENAME_CLOSED_WON) 
                      ||
                      (thisAsset.renewal_opportunity__c == null))
                 ) && 
                 !thisAsset.is_renewed__c 
                )
            ){
                thisAsset.Status = 'Valid';
                
                validCount = validCount +1;
                System.debug('Valid Asset Count : '+validCount);
            }else If(
                thisAsset.UsageEndDate < Date.Today() && 
                (
                    (
                        thisAsset.Status != AssetConstants.STATUS_SALES_RETURN
                    )  && 
                    (
                        thisAsset.Status != AssetConstants.STATUS_CHURN
                    ) 
                ) && 
                (
                    /*!( 
                        parentAssetMap.containsKey(thisAsset.Id) && 
                        !thisAsset.multi_year__c
                    ) &&  */
                    (
                        !parentAssetMap.containsKey(thisAsset.Id) && 
                        !thisAsset.multi_year__c && 
                        ((thisAsset.renewal_opportunity__c != null && 
                        thisAsset.renewal_opportunity__r.stageName != OpportunityConstants.STAGENAME_CLOSED_WON) || 
                      (thisAsset.renewal_opportunity__c == null))
                    ) && 
                    !thisAsset.is_renewed__c 
                )
            ){
                thisAsset.Status = 'Expired';
                expiredCount = expiredCount +1;
                System.debug('Expired Asset Count : '+expiredCount);
            }else If(
                (
                    (
                        parentAssetMap.containsKey(thisAsset.Id) &&  
                        thisAsset.PurchaseDate <= Date.Today() && 
                        thisAsset.UsageEndDate >= Date.Today() && 
                        /*thisAsset.Multi_Year__c  && */
                        thisAsset.renewal_opportunity__c != null && 
                        thisAsset.renewal_opportunity__r.stageName == OpportunityConstants.STAGENAME_CLOSED_WON
                    ) || 
                    /*(
                        parentAssetMap.containsKey(thisAsset.Id) &&  
                        thisAsset.PurchaseDate <= Date.Today() && 
                        thisAsset.UsageEndDate >= Date.Today() && 
                        !thisAsset.Multi_Year__c
                    ) || */
                    (
                        thisAsset.PurchaseDate <= Date.Today() && 
                        thisAsset.UsageEndDate >= Date.Today() && 
                        !thisAsset.Multi_Year__c && thisAsset.is_renewed__c 
                    )  
                ) &&
                (
                    thisAsset.Status != AssetConstants.STATUS_CHURN && 
                    thisAsset.Status != AssetConstants.STATUS_SALES_RETURN 
                )
            ){
                thisAsset.Status = AssetConstants.STATUS_VALID_RENEWED;
                validRenewedCount = validRenewedCount +1;
                System.debug('validRenewed Asset Count : '+validRenewedCount);
            }else If( 
                (
                    ( 
                        (
                            thisAsset.UsageEndDate <= Date.Today()
                        ) && 
                        parentAssetMap.containsKey(thisAsset.Id) && 
                        !thisAsset.Multi_Year__c
                    ) || 
                    ( 
                        (
                            thisAsset.UsageEndDate < Date.Today() 
                        ) && 
                        parentAssetMap.containsKey(thisAsset.Id) && 
                        thisAsset.Multi_Year__c && 
                        thisAsset.renewal_opportunity__c != null && 
                        thisAsset.renewal_opportunity__r.stageName == OpportunityConstants.STAGENAME_CLOSED_WON) ||
                    ( 
                        ( 
                            thisAsset.UsageEndDate <= Date.Today()
                        ) && 
                        thisAsset.is_renewed__c && 
                        !thisAsset.Multi_Year__c
                    ) 
                ) &&
                (
                    thisAsset.Status != AssetConstants.STATUS_CHURN && 
                    thisAsset.Status != AssetConstants.STATUS_SALES_RETURN 
                )
            ){
                thisAsset.Status = AssetConstants.RENEWED;
                renewedCount = renewedCount +1;
                System.debug('Renewed Asset Count : '+renewedCount);
            } else If(
                (
                    (
                        thisAsset.PurchaseDate > Date.Today() &&
                        thisAsset.Status != AssetConstants.STATUS_SALES_RETURN
                    )  && 
                    (
                        thisAsset.Status != AssetConstants.STATUS_CHURN
                    )   && 
                    thisAsset.Status != AssetConstants.STATUS_UPCOMING_RENEWAL 
                ) && 
                !thisAsset.is_renewed__c
            ){
                thisAsset.Status = 'Future';
                futureCount = futureCount +1;
                System.debug('Future Asset Count : '+futureCount);
            }
        }
        
        
        OpportunityConstants.AUTO_RENEW_RULE 			= FALSE;
        RecursiveTriggerHandler.isFirstTimeOpportunity 	= FALSE;
        RecursiveTriggerHandler.isFirstTime = FALSE;
        
        Database.SaveResult[] result = database.update( assetMap.values(), FALSE );
        
        RecursiveTriggerHandler.isFirstTime = TRUE;
        OpportunityConstants.AUTO_RENEW_RULE 			= TRUE;
        RecursiveTriggerHandler.isFirstTimeOpportunity 	= TRUE;
        
        
        
        for(Integer i=0; i < result.size(); i++){
            
            if(result.get(i).isSuccess()) {
                System.debug('Records are updated Successfully');
            } else if( !result.get(i).isSuccess() ) {
                Database.Error errors =  result.get(i).getErrors().get(0);
                System.debug('Error Occurs While Processing The Record'+errors.getMessage());
                System.debug('Failure Record Ids While Updating'+result.get(i).Id);
                
                errorResults.put( result.get(i).Id, errors.getMessage() );
            }
        }
        
    }
    
    // The batch job finishes
    global void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
        System.debug('>>>> finish ' + job.Status);
        
        
        Id		defaultMailId 	= [ SELECT Id FROM OrgWideEmailAddress WHERE Address = :system.label.AR_Mail ]?.Id;
        String 	body 			= 'Hi Team,<br></br><br></br>';
        body 					+= 'There We encountred error while updating the Asset status scheduler, Please find the details below: <br></br><br></br> <ol> ';
        for( Id thisId : errorResults.keySet() ){
            body 				+= '<li>Asset Id: '+thisId+' <br></br><br></br></li>';
            body 				+= '<li>Error Message: '+errorResults.get(thisId)+' <br></br><br></br></li>';
        }
        body 					+= '</ol>';
        body 					+= 'This opportunity bypassed Asset + Order creation flow.</b><br></br><br></br>';
        body 					+= 'Please get in touch with Salesforce team for further help(Need asset creation script to be executed).<br></br><br></br>';
        body 					+= 'Best regards,<br></br>';
        body 					+= 'Team Salesforce';
        
        Messaging.SingleEmailMessage 	mail 		= new Messaging.SingleEmailMessage();
        List<String> 					toAddress	= new List<String>();
        
        toAddress.add('bibhuda.dash@clear.in');
        toAddress.add('pooja.amilkanthwar@clear.in');
        
        mail.setOrgWideEmailAddressId(defaultMailId);
        mail.setToAddresses(toAddress);
        mail.setSubject('Asset Status Updation Failure');
        mail.setBccSender(false);
        mail.setHtmlBody(body);
        
        try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail( new List<Messaging.SingleEmailMessage>{mail} );
        } catch(Exception ex){
        }
        
        
    }
}