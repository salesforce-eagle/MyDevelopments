global class SchedulerToEmailGccIntegrationAssets implements Schedulable {
    /** START : Ashwinkrishna : GCC daily mail - GCC Integration assets **/
    global void execute(SchedulableContext SC) {
        
        List<Asset> assetList = new List<Asset>();
        DateTime dt = System.now()-1;
        assetList = [select Id, Name, AccountId, Account.Csm_Owner_Name__c, Product_Name__c, Product2.Product_category__c, Account_Name__c,PurchaseDate,
                     UsageEndDate,Status,Price, Quantity,Billing_Type__c,CreatedDate, Account_Owner_Name__c 
                     from Asset 
                     where (Product2.Product_category__c = 'Integration'
                            AND ( Account.Country_of_Origin__c != 'India' AND Account.Country_of_Origin__c != NULL ) )
                            AND CreatedDate > :dt];
        
        String htmlBody;
        
        if(assetList.size()>0){
            htmlBody = '<table border="1px" style="text-align:center">';
            htmlBody += '<tr><th bgcolor="Gold" colspan="13">GCC ASSET</th></tr>';
            htmlBody += '<tr><th>Asset Name</th>';
            htmlBody += '<th>Product Name</th>';
            htmlBody += '<th>Account Name</th>';
            htmlBody += '<th>Period Start Date</th>';
            htmlBody += '<th>Period End Date</th>';
            htmlBody += '<th>Status</th>';
            htmlBody += '<th>Price</th>';
            htmlBody += '<th>Quantity</th>';
            htmlBody += '<th>Product Category</th>';
            htmlBody += '<th>Billing Type</th>';
            htmlBody += '<th>Asset: Created Date</th>';
            htmlBody += '<th>Account Owner - CSM</th>';
            htmlBody += '<th>Account Owner</th></tr>';
            
            for(Asset ast : assetList){
                String href = URL.getSalesforceBaseUrl().toExternalForm() + '/'+ast.Id;
                htmlBody += '<tr><td style="text-align:center; padding:4px"><a href='+href+'>' + ast.Name + '</a></td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + ast.Product_Name__c + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + ast.Account_Name__c + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + ast.PurchaseDate + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + ast.UsageEndDate + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + ast.Status + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + ast.Price + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + ast.Quantity + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + ast.Product2.Product_category__c + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + ast.Billing_Type__c + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + ast.CreatedDate + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + ast.Account.Csm_Owner_Name__c  + '</td>';
                htmlBody+='<td style="text-align:center; padding:4px">' + ast.Account_Owner_Name__c + '</td>';
            }
            
            htmlBody += '</table>';
            Id defaultMailId = [ SELECT Id FROM OrgWideEmailAddress WHERE Address = 'notification@support.clear.in']?.Id;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddress	= System.label.GCC_Asset_Email_Recipients.split(',');
            mail.setOrgWideEmailAddressId(defaultMailId);
            mail.setToAddresses(toAddress); 
            mail.setSubject('Summary of GCC Integration assets created on '+date.today().format());
            mail.setBccSender(false);
            mail.setHtmlBody(htmlBody);
            
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                if(results.size()>0){
                    if (results[0].success) 
                    {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' +  results[0].errors[0].message);
                    }
                }
                
            }Catch(Exception ex){
                System.debug(' Exception on SchedulerToEmailReports \n'+ex.getMessage()+'\n'+ex.getLineNumber());
            }
            
        }
        
    }
    /** END : Ashwinkrishna : GCC daily mail - GCC Integration assets **/
}