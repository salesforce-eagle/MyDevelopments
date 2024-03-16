global class SchedulableKAMEmail implements Schedulable {
    
    
    global static void  execute(SchedulableContext ctx) {
        // CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
        // FROM CronTrigger WHERE Id = :ctx.getTriggerId()];
        // System.debug('CRON_EXP'+ ct.CronExpression);
        // System.debug('0%&^' + ct.TimesTriggered);
        // System.debug('2021-09-30 00:00:00'+ String.valueOf(ct.NextFireTime));
        list<string> excludeStatus = new list<string>{'Churn','Renewed','Sales return','Valid & Renewed'};
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'notifications.sf@cleartaxmailer.com'];
        List<aggregateResult> assList = [select ownerid Id,sum(price) sumPrice,count(id) countId,owner.email ownerEmail,owner.name fullName  from asset where  Overall_Risk_Status__c = 'Yes' and ownerId !=null and status NOT in : excludeStatus group by ownerid,owner.name,owner.email];
        Map<id,aggregateResult> assListWithOutRiskComment =new Map<id,aggregateResult>( [select ownerid Id,sum(price) sumPrice,count(id) countId,owner.email ownerEmail,owner.name fullName  from asset where Risk_Status_by_KAM__c = '' and Overall_Risk_Status__c = 'Yes' and ownerId !=null and status NOT in : excludeStatus group by ownerid,owner.name,owner.email]);
        Map<id,aggregateResult> assListWithRiskComment =new Map<id,aggregateResult>( [select ownerid Id,sum(price) sumPrice,count(id) countId,owner.email ownerEmail,owner.name fullName  from asset where 	Risk_Status_by_KAM__c != '' and Overall_Risk_Status__c = 'Yes' and ownerId !=null and status NOT in : excludeStatus group by ownerid,owner.name,owner.email]);
        Set<id> ownerIdSet = new Map<id,SObject>(assList).keySet();
        map<id,list<asset>> ownerAssetMapWithComment= new map<id,list<asset>>();
        map<id,list<asset>> ownerAssetMapWithoutComment= new map<id,list<asset>>();
        map<id,list<asset>> ownerAssetMapWithYes= new map<id,list<asset>>();
        list<asset> assetList =[select id,account.region__r.name,ownerid,name,product2.name,Other_Reason_for_Churn__c,Update_from_Support_Team__c,price,account.name,usageEndDate,Category_Risk_Comment__c,account.onboarding_owner__r.name,account.owner.name,Risk_update_from_Category_KAM__c,opportunity__r.owner.name,Overall_Risk_Status__c,Risk_Status_by_KAM__c from asset where Overall_Risk_Status__c = 'Yes' and ownerId in:ownerIdSet and status NOT in : excludeStatus order by account.region__c,owner.name]; // get all risk type assets
        for(asset ass: assetList){
            if(String.isBlank(ass.Risk_Status_by_KAM__c)){
                list<asset> temAssetList = new list<asset>();
                
                if(ownerAssetMapWithoutComment.get(ass.ownerId) == null){
                    temAssetList.add(ass);
                    ownerAssetMapWithoutComment.put(ass.ownerId,temAssetList);
                }
                else{
                    temAssetList =  ownerAssetMapWithoutComment.get(ass.ownerId);
                    temAssetList.add(ass); 
                    ownerAssetMapWithoutComment.put(ass.ownerId,temAssetList);
                }
            }
            else {
                
                list<asset> temAssetList = new list<asset>();
                if(ownerAssetMapWithComment.get(ass.ownerId) == null){
                    
                    temAssetList.add(ass);
                    ownerAssetMapWithComment.put(ass.ownerId,temAssetList);
                }
                else{
                    temAssetList =  ownerAssetMapWithComment.get(ass.ownerId);
                    temAssetList.add(ass); 
                    ownerAssetMapWithComment.put(ass.ownerId,temAssetList);
                }
                if(ass.Risk_Status_by_KAM__c.equals('Yes') && ass.Price >= 150000){
                    list<asset> temAssetList1 = new list<asset>();
                   if(!ownerAssetMapWithYes.containsKey(ass.ownerId)){
                        temAssetList1.add(ass);
                        ownerAssetMapWithYes.put(ass.ownerId,temAssetList1);
                    }
                    else{
                        temAssetList1 =  ownerAssetMapWithYes.get(ass.ownerId);
                        temAssetList1.add(ass); 
                        ownerAssetMapWithYes.put(ass.ownerId,temAssetList1);
                    }
                }
            }
            
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        boolean headerTemp = false;
        //Email to KAM
        try{
            for(aggregateResult aggIns : assList){
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add((String)aggIns.get('ownerEmail'));
               // system.debug('$%$^%'+(String)aggIns.get('ownerEmail'));
                List<String> ccTo = new List<String>();
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                String body = '<html><head><style>body {color: black;} table, th, td {border: 1px solid black;}</style></head><body>Hi '+aggIns.get('fullName') +', ';
                body += '<br><br><b><i>Total Risk for this week : Rs.'+aggIns.get('sumPrice') +', '+aggIns.get('countId')+' assets</i></b>';
                if(assListWithOutRiskComment.get((Id)aggIns.get('Id')) != null){
                    body += '<br><br><b><i>Risk accounts where your comment is missing : Rs.'+assListWithOutRiskComment.get((Id)aggIns.get('Id')).get('sumPrice') +', '+assListWithOutRiskComment.get((Id)aggIns.get('Id')).get('countId')+' assets</i></b><br>';
                    for(asset ass:ownerAssetMapWithoutComment.get((Id)aggIns.get('Id'))){
                        if(!headerTemp){
                            body += '</br><table border="1px" ><tr>';
                            body += '<th><b>Asset Name</b></th>';
                            body += '<th><b>Product Name</b></th>';
                            body += '<th><b>Price</b></th>';
                            body += '<th><b>Account Name</b></th>';
                            body += '<th><b>PO End Date</b></th>';
                            body += ' <th><b>Category Risk Comment</b></th>';
                            body += ' <th><b>CSM Owner</b></th>';
                            body += '<th><b>Opportunity Owner</b></th>';
                            body += '<th><b>Account Owner</b></th>';
                            body += '<th><b>Detail Reason for Churn / Risk</b></th>';
                            body += '<th><b>Risk update from Support Team</b></th>';
                            body += '<th><b>Risk update from Category / KAM</b></th>';
                            body += '</tr>';
                            headerTemp= true;
                        }
                        body += ' <tr>';
                        body += '<td><a href ="https://cleartax.lightning.force.com/'+ass.Id+'">'+ass.Name+'</td></a>';
                        body += '<td>'+ass.Product2.name+'</td>';
                        body += '<td>'+ass.price+'</td>';
                        body += '<td>'+ass.account.name+'</td>';
                        body += '<td>'+date.ValueOf(ass.usageEndDate).format()+'</td>';
                        body += '<td>'+ass.Category_Risk_Comment__c+'</td>';
                        body += ' <td>'+ass.Account.onboarding_owner__r.name+'</td>';
                        body += '<td>'+ass.opportunity__r.owner.name+'</td>';
                        body += '<td>'+ass.Account.owner.name+'</td>';
                        body += '<td>'+ass.Other_Reason_for_Churn__c+'</td>';
                        body += '<td>'+ass.Update_from_Support_Team__c+'</td>';
                        body += '<td>'+ass.Risk_update_from_Category_KAM__c+'</td>';
                    }
                    body += '</table ><br>';
                    headerTemp = false;
                }
                if(assListWithRiskComment.get((Id)aggIns.get('Id')) != null){
                    body += '<br><b><i>Risk accounts where you have confirmed as Risk : Rs.'+assListWithRiskComment.get((Id)aggIns.get('Id')).get('sumPrice') +', '+assListWithRiskComment.get((Id)aggIns.get('Id')).get('countId')+' assets</i></b></br>';
                    for(asset ass:ownerAssetMapWithComment.get((Id)aggIns.get('Id'))){
                        if(!headerTemp){
                            body += '</br><table border="1px" ><tr>';
                            body += '<th><b>Asset Name</b></th>';
                            body += '<th><b>Product Name</b></th>';
                            body += '<th><b>Price</b></th>';
                            body += '<th><b>Account Name</b></th>';
                            body += '<th><b>PO End Date</b></th>';
                            body += ' <th><b>Category Risk Comment</b></th>';
                            body += ' <th><b>CSM Owner</b></th>';
                            body += '<th><b>Opportunity Owner</b></th>';
                            body += '<th><b>Account Owner</b></th>';
                            body += '<th><b>Detail Reason for Churn / Risk</b></th>';
                            body += '<th><b>Risk update from Support Team</b></th>';
                            body += '<th><b>Risk update from Category / KAM</b></th>';
                            body += '</tr>';
                            headerTemp= true;
                        }
                        body += ' <tr>';
                        body += '<td><a href ="https://cleartax.lightning.force.com/'+ass.Id+'">'+ass.Name+'</td></a>';
                        body += '<td>'+ass.Product2.name+'</td>';
                        body += '<td>'+ass.price+'</td>';
                        body += '<td>'+ass.account.name+'</td>';
                        body += '<td>'+date.valueOf(ass.usageEndDate).format()+'</td>';
                        body += '<td>'+ass.Category_Risk_Comment__c+'</td>';
                        body += ' <td>'+ass.Account.onboarding_owner__r.name+'</td>';
                        body += '<td>'+ass.opportunity__r.owner.name+'</td>';
                        body += '<td>'+ass.Account.owner.name+'</td>';
                        body += '<td>'+ass.Other_Reason_for_Churn__c+'</td>';
                        body += '<td>'+ass.Update_from_Support_Team__c+'</td>';
                        body += '<td>'+ass.Risk_update_from_Category_KAM__c+'</td>';
                        body += '</tr>';
                    }
                    body += '</table ><br>';
                    headerTemp = false;
                }
                body += ' Please update the missing comments at the earliest.<br><br>';
                mail.setHtmlBody(body);
                mail.setSubject(date.today().format()+'-Risk Accounts. Amount-Rs.'+aggIns.get('sumPrice') );
               mail.setToAddresses(sendTo);
                mails.add(mail);
            }
            //Email to KAM End
            //Email to Manager
            list<aggregateResult> assManagerListTotal = [select sum(price) sumPrice,count_distinct(accountId) accCount,asset.account.region__r.name region,owner.manager.name managerName,asset.account.region__r.KAM_Regional_Head__r.name headName,asset.account.region__r.KAM_Regional_Head__r.email regionalheadEmail,count(Id) countId,owner.manager.email managerEmail,owner.name ownerName,ownerId Id from asset where  Overall_Risk_Status__c = 'Yes' and status NOT in : excludeStatus
                                                         group by owner.manager.email,asset.account.region__c,asset.account.region__r.KAM_Regional_Head__r.name,owner.name,asset.account.region__r.name,ownerId,owner.manager.name,asset.account.region__r.KAM_Regional_Head__r.email order by owner.manager.name,sum(price) desc];
            list<aggregateResult> assManagerListTotalYesList = new List<aggregateResult>([select ownerId Id,sum(price) sumPrice,count_distinct(accountId) accCount,asset.account.region__r.name region,owner.manager.name managerName,asset.account.region__r.KAM_Regional_Head__r.name headName,count(Id) countId,owner.manager.email managerEmail,owner.name ownerName from asset where  (Overall_Risk_Status__c = 'Yes' and Risk_Status_by_KAM__c = 'Yes' and status NOT in : excludeStatus)
                                                                                          group by owner.manager.email,asset.account.region__c,asset.account.region__r.KAM_Regional_Head__r.name,owner.name,asset.account.region__r.name,ownerId,owner.manager.name order by owner.manager.name,sum(price) desc]);
            map<id,aggregateResult> assManagerListTotalYes = new Map<id,aggregateResult>();
              assManagerListTotalYes.putAll(assManagerListTotalYesList);
            list<aggregateResult> assManagerListTotalNoList = new List<aggregateResult>([select ownerId Id,sum(price) sumPrice,count_distinct(accountId) accCount,asset.account.region__r.name region,owner.manager.name managerName,asset.account.region__r.KAM_Regional_Head__r.name headName,count(Id) countId,owner.manager.email managerEmail,owner.name ownerName from asset where  (Overall_Risk_Status__c = 'Yes' and Risk_Status_by_KAM__c = 'No' and status NOT in : excludeStatus)
                                                                                         group by owner.manager.email,asset.account.region__c,asset.account.region__r.KAM_Regional_Head__r.name,owner.name,asset.account.region__r.name,ownerId,owner.manager.name order by owner.manager.name,sum(price) desc]);
            map<id,aggregateResult> assManagerListTotalNo = new Map<id,aggregateResult>();
            assManagerListTotalNo.putAll(assManagerListTotalNoList);
            list<aggregateResult> assManagerListTotalBlankList = new List<aggregateResult>([select ownerId Id,sum(price) sumPrice,count_distinct(accountId) accCount,asset.account.region__r.name region,owner.manager.name managerName,asset.account.region__r.KAM_Regional_Head__r.name headName,count(Id) countId,owner.manager.email managerEmail,owner.name ownerName from asset where  (Overall_Risk_Status__c = 'Yes'and Risk_Status_by_KAM__c = '' and status NOT in : excludeStatus)
                                                                                            group by owner.manager.email,asset.account.region__c,asset.account.region__r.KAM_Regional_Head__r.name,owner.name,asset.account.region__r.name,ownerId,owner.manager.name order by owner.manager.name,sum(price) desc]);
            map<id,aggregateResult> assManagerListTotalBlank = new Map<id,aggregateResult>();
            assManagerListTotalBlank.putAll(assManagerListTotalBlankList);
            //list<aggregateResult> assManagerList = [select sum(price) sumPrice,asset.account.region__c,asset.account.region__r.KAM_Regional_Head__r.name,count(Id) countId,owner.manager.email managerEmail,ownerId from asset where  Overall_Risk_Status__c = 'Yes'
            Messaging.SingleEmailMessage mail1 =  new Messaging.SingleEmailMessage();  
            Boolean oneEmail = true;
            List<String> sendTo1 = new List<String>();
            List<String> ccTo1 = new List<String>();
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea.get(0).Id);
            }//  group by owner.manager.email,asset.account.region__c,asset.account.region__r.KAM_Regional_Head__r.name,ownerId];
            String body = '';
            String endBody = '';
            integer totalPrice= 0;
            Integer totalCount= 0;
            system.debug('HJGFJHGJ'+label.KAMSchedulableEmails.split(','));
                sendTo1.addAll(label.KAMSchedulableEmails.split(','));
            for(aggregateResult aggIns : assManagerListTotal){
                 //sendTo.add('aishwarya.viswanathan@cleartax.in');
               // sendTo.add('kartikeya.singh@cleartax.in');
              //  sendTo.add('anosh.lepcha@cleartax.in');
             // if(!sendTo1.contains(String.ValueOf(aggIns.get('managerEmail'))))
              // sendTo1.add(String.ValueOf(aggIns.get('managerEmail')));
               // sendTo.add(String.ValueOf(aggIns.get('regionalheadEmail')));
               
                
                totalPrice += Integer.valueOf(aggIns.get('sumPrice'));
                totalCount += (integer)aggIns.get('countId');
                if(oneEmail){
                    body = '<html><head><style>body {color: black;} table, th, td {border: 1px solid black;}</style></head><body>Hi,<br><br> ';
                    body += '<b>1.Here is the summary of the Risk assets for your team:-</b>';
                    // body += ' <br>Please update the missing comments at the earliest.<br><br>';
                    // body += '<br>Risk accounts where you have confirmed as Risk : Rs.'+assListWithRiskComment.get((Id)aggIns.get('Id')).get('sumPrice') +', '+assListWithRiskComment.get((Id)aggIns.get('Id')).get('countId')+' assets</br>';
                    body += '</br><table border="1px" ><tr>';
                    body += '<th><b>Region</b></th>';
                    body += '<th><b>Region Head</b></th>';
                    body += '<th><b>KAM Manager Name</b></th>';
                    body += '<th><b>KAM Name</b></th>';
                    body += '<th><b>Number of Customers flagged as Risk</b></th>';
                    body += '<th><b>Total overall risk assets(count)</b></th>';
                    body += ' <th><b>Total overall Risk assets(ARR)</b></th>';
                    body += ' <th><b>Total assets where KAM input is missing (count)</b></th>';
                    body += ' <th><b>Total assets where KAM input is missing (ARR)</b></th>';
                    body += ' <th><b>Total assets where KAM has confirmed Risk = Yes (count)</b></th>';
                    body += ' <th><b>Total assets where KAM has confirmed Risk = Yes (ARR)</b></th>';
                    body += ' <th><b>Total assets where KAM has confirmed Risk = No (count) </b></th>';
                    body += ' <th><b>Total assets where KAM has confirmed Risk = No (ARR) </b></th>';
                    // body += ' <th><b>CSM Owner</b></th>';
                    // body += '<th><b>Opportunity Owner</b></th>';
                    // body += '<th><b>Account Owner</b></th>';
                    // body += '<th><b>Risk Update by KAM</b></th>';
                    body += '</tr>';
                    oneEmail = false;
                }
                body += ' <tr>';
                //body += '<td><a href ="https://cleartax.lightning.force.com/'+ass.Id+'">'+ass.Name+'</td></a>';
                body += '<td>'+aggIns.get('region')+'</td>';
                body += '<td>'+aggIns.get('headName')+'</td>';
                body += '<td>'+aggIns.get('managerName')+'</td>';
                body += '<td>'+aggIns.get('ownerName')+'</td>';
                body += '<td>'+aggIns.get('accCount')+'</td>';
                body += ' <td>'+aggIns.get('countId')+'</td>';
                body += '<td>'+aggIns.get('sumPrice')+'</td>';
                //system.debug('Id$ '+(Id)aggIns.get('Id'));
                //system.debug('Id$Value '+assManagerListTotalBlank.get((Id)aggIns.get('Id')));
                //system.debug('Id$ValueKeyset '+assManagerListTotalBlank.keyset());
               // system.debug('Id$Value No '+assManagerListTotalNo.get((Id)aggIns.get('Id')));
               // system.debug('Id$ValueKeyset No '+assManagerListTotalNo.keyset());
                if(assManagerListTotalBlank.get((Id)aggIns.get('Id')) != null){
                body += '<td>'+assManagerListTotalBlank.get((Id)aggIns.get('Id')).get('countId')+'</td>';
                body += '<td>'+assManagerListTotalBlank.get((Id)aggIns.get('Id')).get('sumPrice')+'</td>';
                }
                else{
                    body += '<td>'+0+'</td>';
                body += '<td>'+0+'</td>';
                }
                if(assManagerListTotalYes.get((Id)aggIns.get('Id')) != null){
                body += '<td>'+assManagerListTotalYes.get((Id)aggIns.get('Id')).get('countId')+'</td>';
                body += '<td>'+assManagerListTotalYes.get((Id)aggIns.get('Id')).get('sumPrice')+'</td>';
                }
                   else{
                    body += '<td>'+0+'</td>';
                body += '<td>'+0+'</td>';
                }
                if(assManagerListTotalNo.get((Id)aggIns.get('Id')) != null){
                body += '<td>'+assManagerListTotalNo.get((Id)aggIns.get('Id')).get('countId')+'</td>';
                body += '<td>'+assManagerListTotalNo.get((Id)aggIns.get('Id')).get('sumPrice')+'</td>';
                }
                   else{
                    body += '<td>'+0+'</td>';
                body += '<td>'+0+'</td>';
                }
                // body += '<td>'+aggIns.get('region')+'</td>';
                // body += '<td>'+aggIns.get('region')+'</td>';
                body += '</tr>';
                
                
                if(ownerAssetMapWithYes.containsKey((Id)aggIns.get('Id'))){
                    for(asset ass:ownerAssetMapWithYes.get((Id)aggIns.get('Id'))){
                        if(!headerTemp){
                            endBody = '<b>2.Cases where KAM has confirmed Risk Status as "Yes"  and Asset ARR > 1.5 lac</b>';
                            endBody += '</br><table border="1px" ><tr>';
                            endBody += '<th><b>Region </b></th>';
                            endBody += '<th><b>Account Owner</b></th>';
                            endBody += '<th><b>Asset Name</b></th>';
                            endBody += '<th><b>Product Name</b></th>';
                            endBody += '<th><b>Price</b></th>';
                            endBody += ' <th><b>Account Name</b></th>';
                            endBody += ' <th><b>PO End Date</b></th>';
                            endBody += '<th><b>Category Risk Comment</b></th>';
                            endBody += '<th><b>CSM Owner</b></th>';
                            endBody += '<th><b>Opportunity Owner</b></th>';
                            endBody += '<th><b>Risk Update by KAM</b></th>';
                            endBody += '</tr>';
                            headerTemp= true;
                        }
                        endBody += ' <tr>';
                        endBody += '<td>'+ass.account.region__r.name+'</td>';
                        endBody += '<td>'+ass.Account.owner.name+'</td>';
                        endBody += '<td><a href ="https://cleartax.lightning.force.com/'+ass.Id+'">'+ass.Name+'</td></a>';
                        endBody += '<td>'+ass.Product2.name+'</td>';
                        endBody += '<td>'+ass.price+'</td>';
                        endBody += '<td>'+ass.account.name+'</td>';
                        endBody += '<td>'+date.ValueOf(ass.usageEndDate).format()+'</td>';
                        endBody += '<td>'+ass.Category_Risk_Comment__c+'</td>';
                        endBody += ' <td>'+ass.Account.onboarding_owner__r.name+'</td>';
                        endBody += '<td>'+ass.opportunity__r.owner.name+'</td>';
                        endBody += '<td>'+ass.Risk_update_from_Category_KAM__c+'</td>';
                        endBody += '</tr>';
                    }
                    
                }
                
            }
            endBody += '</table ><br>';
                    headerTemp = false;
            body += '</table ><br><br>';
            body += endBody;
            body += '<i><b>Total Risk for this week : Rs.'+totalPrice +', '+totalCount+' assets</b></i>';
            mail1.setSubject(date.today().format()+'-Risk Accounts for your team. Amount-Rs.'+totalPrice );
            mail1.setToAddresses(sendTo1);
            mail1.setHtmlBody(body);
            mails.add(mail1);
            //Email to Manager End
            // Step 6: Send all emails in the master list
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails,false);
            for(Messaging.SendEmailResult res :results)
            system.debug('%#%Result: '+res);
            if(results.size()>0){
                if (results[0].success) 
                {
                    
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                }
            }
            
        }
        Catch(exception e){
            system.debug('Exception Occured'+e.getMessage());
            
        }
        
        
    }   
}