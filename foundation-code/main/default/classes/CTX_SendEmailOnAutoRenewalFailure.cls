public class CTX_SendEmailOnAutoRenewalFailure {
    
    public static void sendMailOnPostPaymentFailure( CTX_AutoRenewLicenseHelper.AssetWrapper astWrapper, String paymentMode, String omsOrderId, Exception ex ){
        
        Id 								defaultMailId 	= [ SELECT Id FROM OrgWideEmailAddress WHERE Address = :system.label.AR_Mail ]?.Id;
        Messaging.SingleEmailMessage 	mail 			= new Messaging.SingleEmailMessage();
        QuoteLineItem qli;
        for( QuoteLineItem thisRec : astWrapper.updateQli ){
            if( thisRec.unitPrice != 0 ){
                qli = thisRec;
            }
        }
        
        String body = 'Team,<br></br><br></br>';
        body += 'Transaction failed post payment(Auto Renewal), details below: <br></br><br></br>';
        body += '<ol><li>Opportunity Id:'+astWrapper.updateOpp.Id+'</li>';
        body += '<li>OMS Order Id:'+omsOrderId+'</li>';
        body += '<li>Payment Mode:'+paymentMode+'</li>';
        body += '<li>Order Details:'+qli.Order_Details__c+'</li>';
        body += '<li>Reason for failure:'+ex.getMessage()+'</li> </ol><br></br><br></br>';
        body += 'Team Salesforce<br></br>';
        
        mail.setOrgWideEmailAddressId(defaultMailId);
        mail.setToAddresses( system.label.Auto_Renewal_Failure_Emailer_List.split(';') );
        mail.setSubject('Auto renewal post payment failure');
        mail.setBccSender(false);
        mail.setHtmlBody(body); 
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail( new list<Messaging.SingleEmailMessage>{mail} );
        
    }
}