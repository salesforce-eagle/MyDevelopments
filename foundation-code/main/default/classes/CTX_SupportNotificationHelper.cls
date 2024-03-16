public class CTX_SupportNotificationHelper {
    
    public 	static void 						getAssetDetails(){
        
        Map<String, List<Asset>> 	supportyTeamANDAssetMap = new Map<String, List<Asset>>();
        Query_Storage__mdt 			emailDomain 			= Query_Storage__mdt.getInstance('CTX_SupportNotificationHelper');
        String 						queryString;
        
        if(emailDomain != NULL){
            
            queryString = 'SELECT ';
            
            if(emailDomain.Fields_Set_1__c != NULL)
                queryString += emailDomain.Fields_Set_1__c;
            if(emailDomain.Fields_Set_2__c != NULL)
                queryString += ', '+emailDomain.Fields_Set_2__c;
            if(emailDomain.Fields_Set_3__c != NULL)
                queryString += ', '+emailDomain.Fields_Set_3__c;
            
            queryString += ' FROM '+emailDomain.Object_Details__c;
            
            system.debug('queryString: '+queryString);
            if(emailDomain.Where_Clause__c != NULL)
                queryString += ' '+emailDomain.Where_Clause__c;
        }
        
        if(queryString != NULL){
            
            for( Asset thisRec : database.query(queryString) ){
                
                if(thisRec.Support_Team_For_Risk_Churn_update__c != NULL){
                    
                    if(supportyTeamANDAssetMap.containsKey(thisRec.Support_Team_For_Risk_Churn_update__c)){
                        supportyTeamANDAssetMap.get(thisRec.Support_Team_For_Risk_Churn_update__c).add(thisRec);
                    } else{
                        supportyTeamANDAssetMap.put(thisRec.Support_Team_For_Risk_Churn_update__c, new List<Asset>{thisRec});
                    }
                }
            }
            
            if( supportyTeamANDAssetMap.size() > 0 )
                OperationalBlock(supportyTeamANDAssetMap);
        }
        
    }
    
    private static Void 						OperationalBlock( Map<String, List<Asset>> supportyTeamANDAssetMap ){
        
        Map<String, List<String>> 			supportGroupANDEmailMap = getSupportTeamAndEmailMapping(); 
        List<Messaging.SingleEmailMessage> 	mails	 				= new List<Messaging.SingleEmailMessage>();
        Boolean								isRepete				= FALSE;
        Id 									defaultMailId 			= [ SELECT Id FROM OrgWideEmailAddress 
                                                                       WHERE Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        String 								body 					= System.Label.Support_Notification_Details+'</br></br>';
        
        for(String thisSTR : supportyTeamANDAssetMap.keySet()){
            
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            /**	Iterate Based on Support Team	**/
            body += '<html><head><style>body {color: black;} table, th, td {border: 1px solid black;}</style></head><body>';
            body += '</br><table border="1px" ><tr>';
            body += '<th><b>Account Name</b></th>';
            body += '<th><b>Account ARR</b></th>';
            body += '<th><b>Asset Name</b></th>';
            body += '<th><b>Product Name</b></th>';
            body += '<th><b>Period End Date</b></th>';
            body += '<th><b>Price</b></th>';
            body += '<th><b>Detail reason for Risk/Churn</b></th>';
            body += '<th><b>Risk update from Support Team</b></th>';
            body += '<th><b>KAM</b></th>';
            body += '<th><b>KAM Manager</b></th>';
            
            body += '</tr>';
            
            for(Asset thisRec : supportyTeamANDAssetMap.get(thisSTR)){
                
                body += ' <tr>';
                body += '<td>'+thisRec.Account.Name+'</td>';
                body += '<td>'+thisRec.Account.Sum_of_ARR_Assets__c+'</td>';
                body += '<td><a href ="'+URL.getSalesforceBaseUrl()+thisRec.Id+'">'+thisRec.Name+'</td></a>';
                body += '<td>'+thisRec.Product2.Name+'</td>';
                body += '<td>'+thisRec.UsageEndDate+'</td>';
                body += '<td>'+thisRec.Price+'</td>';
                body += '<td>'+thisRec.Other_Reason_for_Churn__c+'</td>';
                body += '<td>'+thisRec.Support_Team_For_Risk_Churn_update__c+'</td>';
                body += ' <td>'+thisRec.Account.Owner.Name+'</td>';
                body += '<td>'+thisRec.Account.Account_Owner_Manager__c+'</td>';
            }
            body += '</table ><br><br>Thanks.';
            
            mail.setOrgWideEmailAddressId(defaultMailId);
            if(supportGroupANDEmailMap.get(thisSTR) != NULL){
                mail.setToAddresses(supportGroupANDEmailMap.get(thisSTR));
                mail.setHtmlBody(body);
                mail.setSubject('Risk assets that need your support' );
            }else{
                mail.setToAddresses(new List<String>{userinfo.getUserEmail(), 'aishwarya.viswanathan@cleartax.in','bibhuda.dash@cleartax.in'});
                mail.setHtmlBody('This action can not be completed as the support team is not assigned with any user. Please reachout to the concerned support team: '+thisSTR);
                mail.setSubject('Error sending mail to support team '+thisSTR+' - Regarding Risk assets that need your support' );
            }
            mails.add(mail);
            
        }
        
        system.debug('mails: '+mails.size());
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails,false);
        
        for(Messaging.SendEmailResult result : results)
            System.debug('Result is: '+result);
        
    }
    
    private static Map<String, List<String>> 	getSupportTeamAndEmailMapping(){
        
        Map<String, List<String>> supportGroupANDEmailMap = new Map<String, List<String>>();
        Map<String, Support_Email_Notification_setup__mdt> supportEmailNotification 
            = Support_Email_Notification_setup__mdt.getAll();
        
        if(supportEmailNotification != NULL && supportEmailNotification.size() > 0 ){
            
            for(Support_Email_Notification_setup__mdt thisRec : supportEmailNotification.values()){
                
                if(thisrec.Emails_to_Notify__c != NULL)
                    supportGroupANDEmailMap.put(thisrec.MasterLabel, thisrec.Emails_to_Notify__c.split(','));
                else
                    supportGroupANDEmailMap.put(thisrec.MasterLabel, NULL); 
            }
        }
        
        return supportGroupANDEmailMap;
    }
    
}