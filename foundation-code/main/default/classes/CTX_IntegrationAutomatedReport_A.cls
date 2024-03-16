public class CTX_IntegrationAutomatedReport_A {
    
    Public static void sendAutomatedReportA(){
        
        List<String> 	errorMessages 							= new List<String>();
        List<Asset> 	filteredAssetListAwaitingKickoff 		= new list<Asset>();
        List<Asset> 	filteredAssetListAwaitingImplementation = new list<Asset>();
        List<Asset> 	assetListDevelopment 					= new list<Asset>();
        List<Asset> 	assetListConsultationAndInstallation 	= new list<Asset>();
        List<Asset> 	filteredAssetListAwaitingUat 			= new list<Asset>();
        
        List<Asset> 	filteredAssetListAwaitingGoLive 		= new list<Asset>();
        
        Id 				defaultMailId 							= [ SELECT Id FROM OrgWideEmailAddress WHERE 
                                                                   Address = 'notifications.sf@cleartaxmailer.com']?.Id;
        
        List<String>		recipients 							= new List<String>();
        
        List<Messaging.SingleEmailMessage> mailList 			= new List<Messaging.SingleEmailMessage>();
        
        assetListDevelopment 					= [ SELECT id, Name, AccountId, Account.Name, Account_owner_email__c, 
                                                   Status, Aging_In_Stage__c, Type_of_Integration__c, Type_of_Integration_QLI__c,
                                                   Account.ARR_Total_Amount__c, Project_Stage__c, Account.PGSB__c, Price,
                                                   Account.Onboarding_Owner__r.Name, PM_Project_Owner_Name__c, PurchaseDate,
                                                   Project_Last_Modified_Date_Field__c, Escalation_Days_Count__c
                                                   FROM Asset WHERE 
                                                   Project_Scope_Category__c = 'Development' AND
                                                   Product2.Product_category__c = 'Integration' AND 
                                                   Status != 'Churn' AND 
                                                   Project_Stage__c != 'Live' AND
                                                   CreatedDate >= 2021-10-01T00:00:00Z AND 
                                                   Aging_In_Stage__c != NULL ];
        
        assetListConsultationAndInstallation 	= [ SELECT id, Name, AccountId, Account.Name, Account_owner_email__c, 
                                                   Status, Aging_In_Stage__c, Type_of_Integration__c, Type_of_Integration_QLI__c,
                                                   Account.ARR_Total_Amount__c, Project_Stage__c, Account.PGSB__c, Price,
                                                   Account.Onboarding_Owner__r.Name, PM_Project_Owner_Name__c, PurchaseDate,
                                                   Project_Last_Modified_Date_Field__c, Escalation_Days_Count__c
                                                   FROM Asset WHERE 
                                                   (Project_Scope_Category__c = 'Consultation' OR 
                                                    Project_Scope_Category__c = 'Installation') AND
                                                   Product2.Product_category__c = 'Integration' AND 
                                                   Status != 'Churn' AND 
                                                   Project_Stage__c != 'Live' AND
                                                   CreatedDate >= 2021-10-01T00:00:00Z AND 
                                                   Aging_In_Stage__c != NULL ];
        
        
        filteredAssetListAwaitingKickoff 		= [ SELECT id, Name, AccountId, Account.Name, Account_owner_email__c, Status, Aging_In_Stage__c,
                                                   Account.Owner.Name, Account.Sales_Owner__r.Name, Type_of_Integration_QLI__c,
                                                   Type_of_Integration__c, Account.ARR_Total_Amount__c, Project_Stage__c, Product2.Name,
                                                   Account.PGSB__c, Price, Account.Onboarding_Owner__r.Name, PM_Project_Owner_Name__c,
                                                   PurchaseDate, Project_Last_Modified_Date_Field__c, Escalation_Days_Count__c
                                                   FROM Asset WHERE 
                                                   Project_Stage__c = 'Awaiting Kick-off' AND 
                                                   Project_Scope_Category__c = 'Development' AND
                                                   Product2.Product_category__c = 'Integration' AND 
                                                   Status != 'Churn' AND
                                                   Escalation_Days_Count__c > 30 AND 
                                                   CreatedDate >= 2021-10-01T00:00:00Z AND 
                                                   Aging_In_Stage__c != NULL ];
        
        filteredAssetListAwaitingImplementation = [ SELECT id, Name, AccountId, Account.Name, Account_owner_email__c, Status, Aging_In_Stage__c,
                                                   Account.Owner.Name, Account.Sales_Owner__r.Name, Type_of_Integration_QLI__c,
                                                   Type_of_Integration__c, Account.ARR_Total_Amount__c, Project_Stage__c, Product2.Name,
                                                   Account.PGSB__c, Price, Account.Onboarding_Owner__r.Name, PM_Project_Owner_Name__c,
                                                   PurchaseDate, Project_Last_Modified_Date_Field__c, Escalation_Days_Count__c
                                                   FROM Asset WHERE 
                                                   Project_Stage__c = 'Project Plan' AND 
                                                   Project_Scope_Category__c = 'Development' AND
                                                   Product2.Product_category__c = 'Integration' AND 
                                                   Status != 'Churn' AND
                                                   Escalation_Days_Count__c > 45 AND 
                                                   CreatedDate >= 2021-10-01T00:00:00Z AND 
                                                   Aging_In_Stage__c != NULL ];
        
        filteredAssetListAwaitingUat 			= [ SELECT id, Name, AccountId, Account.Name, Account_owner_email__c, Status, Aging_In_Stage__c,
                                                   Account.Owner.Name, Account.Sales_Owner__r.Name, Type_of_Integration_QLI__c,
                                                   Type_of_Integration__c, Account.ARR_Total_Amount__c, Project_Stage__c, Product2.Name,
                                                   Account.PGSB__c, Price, Account.Onboarding_Owner__r.Name, PM_Project_Owner_Name__c,
                                                   PurchaseDate, Project_Last_Modified_Date_Field__c, Escalation_Days_Count__c
                                                   FROM Asset WHERE 
                                                   Project_Stage__c = 'Implementation' AND 
                                                   Project_Scope_Category__c = 'Development' AND
                                                   Product2.Product_category__c = 'Integration' AND 
                                                   Status != 'Churn' AND
                                                   Escalation_Days_Count__c > 60 AND 
                                                   CreatedDate >= 2021-10-01T00:00:00Z AND 
                                                   Aging_In_Stage__c != NULL ];
        
        filteredAssetListAwaitingGoLive 		= [ SELECT id, Name, AccountId, Account.Name, Account_owner_email__c, Status, Aging_In_Stage__c,
                                                   Account.Owner.Name, Account.Sales_Owner__r.Name, Type_of_Integration_QLI__c,
                                                   Type_of_Integration__c, Account.ARR_Total_Amount__c, Project_Stage__c, Product2.Name,
                                                   Account.PGSB__c, Price, Account.Onboarding_Owner__r.Name, PM_Project_Owner_Name__c,
                                                   PurchaseDate, Project_Last_Modified_Date_Field__c, Escalation_Days_Count__c
                                                   FROM Asset WHERE 
                                                   Project_Stage__c = 'UAT' AND 
                                                   Project_Scope_Category__c = 'Development' AND
                                                   Product2.Product_category__c = 'Integration' AND 
                                                   Status != 'Churn' AND
                                                   Aging_In_Stage__c > 14 AND 
                                                   CreatedDate >= 2021-10-01T00:00:00Z AND 
                                                   Aging_In_Stage__c != NULL ];
        
        system.debug('count : '+filteredAssetListAwaitingKickoff.size()+' filteredAssetList' + filteredAssetListAwaitingKickoff);
        
        //Development Asset Count
        Integer 	DevelopmentFuture 	= 0;
        Integer 	Development0to15 	= 0;
        Integer 	Development15to30 	= 0;
        Integer 	Development30to60 	= 0;
        Integer 	Development60to90 	= 0;
        Integer 	Development90plus 	= 0;
        
        for(Asset assetInstance : assetListDevelopment){
            if(assetInstance.Escalation_Days_Count__c < 0){
                DevelopmentFuture = DevelopmentFuture + 1;
            }
            if(assetInstance.Escalation_Days_Count__c >= 0 && assetInstance.Escalation_Days_Count__c <= 15){
                Development0to15 = Development0to15 + 1;
            }
            if(assetInstance.Escalation_Days_Count__c > 15 && assetInstance.Escalation_Days_Count__c <= 30){
                Development15to30 = Development15to30 + 1;
            }
            if(assetInstance.Escalation_Days_Count__c > 30 && assetInstance.Escalation_Days_Count__c <= 60){
                Development30to60 = Development30to60 + 1;
            }
            if(assetInstance.Escalation_Days_Count__c > 60 && assetInstance.Escalation_Days_Count__c <= 90){
                Development60to90 = Development60to90 + 1;
            }
            if(assetInstance.Escalation_Days_Count__c > 90){
                Development90plus = Development90plus + 1;
            }
        }
        
        System.debug('DevelopmentFuture : '+DevelopmentFuture);
        System.debug('Development0to15 : '+Development0to15);
        System.debug('Development15to30 : '+Development15to30);
        System.debug('Development30to60 : '+Development30to60);
        System.debug('Development60to90 : '+Development60to90);
        System.debug('Development90plus : '+Development90plus);
        
        //Consulatation and Installation Asset Count
        Integer 	ConsulatationFuture 	= 0;
        Integer 	Consulatation0to15 		= 0;
        Integer 	Consulatation15to30 	= 0;
        Integer 	Consulatation30to60 	= 0;
        Integer 	Consulatation60to90 	= 0;
        Integer 	Consulatation90plus 	= 0;
        
        for(Asset assetInstance : assetListConsultationAndInstallation){
            if(assetInstance.Escalation_Days_Count__c < 0){
                ConsulatationFuture = ConsulatationFuture + 1;
            }
            if(assetInstance.Escalation_Days_Count__c >= 0 && assetInstance.Escalation_Days_Count__c <= 15){
                Consulatation0to15 = Consulatation0to15 + 1;
            }
            if(assetInstance.Escalation_Days_Count__c > 15 && assetInstance.Escalation_Days_Count__c <= 30){
                Consulatation15to30 = Consulatation15to30 + 1;
            }
            if(assetInstance.Escalation_Days_Count__c > 30 && assetInstance.Escalation_Days_Count__c <= 60){
                Consulatation30to60 = Consulatation30to60 + 1;
            }
            if(assetInstance.Escalation_Days_Count__c > 60 && assetInstance.Escalation_Days_Count__c <= 90){
                Consulatation60to90 = Consulatation60to90 + 1;
            }
            if(assetInstance.Escalation_Days_Count__c > 90){
                Consulatation90plus = Consulatation90plus + 1;
            }
        }
        
        System.debug('ConsulatationFuture : '+ConsulatationFuture);
        System.debug('Consulatation0to15 : '+Consulatation0to15);
        System.debug('Consulatation15to30 : '+Consulatation15to30);
        System.debug('Consulatation30to60 : '+Consulatation30to60);
        System.debug('Consulatation60to90 : '+Consulatation60to90);
        System.debug('Consulatation90plus : '+Consulatation90plus);
        
        //Adding Recipients 
        recipients.addAll(Label.Integration_Escalation_Report_A_EmailList.split(','));
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String Subject = 'Historically Pending Integration - '+DateTime.Now().format('MMM')+' '+Date.today().Year()+'.';
        mail.setSubject(Subject);
        String body = 'Hi all'+','+'<br/>';
        body += 'Please find the details of all historically pending integrations :-'+'<br/>';
        body += '<br/>';
        body += '<table border="1px">';
        body += '<tr>';
        body += '<th bgcolor="yellow" colspan="13">Summary Aging</th>';
        body += '</tr>';
        body += '<tr>';
        body += '<th>Aging Bucket</th>';
        body += '<th># of Development Assets</th>';
        body += '<th># of Consultancy Assets</th>';
        body += '</tr>';
        body += '<tr>';
        body += '<th>Future</th>';
        body += '<td style="text-align:center">'+DevelopmentFuture+'</td>';
        body += '<td style="text-align:center">'+ConsulatationFuture+'</td>';
        body += '</tr>';
        body += '<tr>';
        body += '<th>0-15 days</th>';
        body += '<td style="text-align:center">'+Development0to15+'</td>';
        body += '<td style="text-align:center">'+Consulatation0to15+'</td>';
        body += '</tr>';
        body += '<tr>';
        body += '<th>15-30 days</th>';
        body += '<td style="text-align:center">'+Development15to30+'</td>';
        body += '<td style="text-align:center">'+Consulatation15to30+'</td>';
        body += '</tr>';
        body += '<tr>';
        body += '<th>30-60 days</th>';
        body += '<td style="text-align:center">'+Development30to60+'</td>';
        body += '<td style="text-align:center">'+Consulatation30to60+'</td>';
        body += '</tr>';
        body += '<tr>';
        body += '<th>60-90 days</th>';
        body += '<td style="text-align:center">'+Development60to90+'</td>';
        body += '<td style="text-align:center">'+Consulatation60to90+'</td>';
        body += '</tr>';
        body += '<tr>';
        body += '<th>90+ days</th>';
        body += '<td style="text-align:center">'+Development90plus+'</td>';
        body += '<td style="text-align:center">'+Consulatation90plus+'</td>';
        body += '</tr>';
        body +=    '<tr>';
        body +=    '<td colspan="13">';
        body +=    '<br/>';
        body +=    '</td>';
        body +=    '</tr>';
        body += '<tr>';
        body +=    '<th bgcolor="yellow" colspan="13">---- Assets Awaiting Kick off (>30 days Delay) ------</th>';
        body +=    '</tr>';
        body +=    '<tr>';
        body +=    '<td colspan="13">';
        body +=    '<br/>';
        body +=    '</td>';
        body +=    '</tr>';
        body += '<tr>';
        body += '<th>Customer Name</th>';
        body += '<th>Product Name</th>';
        body += '<th>Type of Integration</th>';
        body += '<th>Total ARR</th>';
        body += '<th>Segment</th>';
        body += '<th>Asset Price</th>';
        body += '<th>CSM Owner</th>';
        body += '<th>Integration Owner</th>';
        body += '<th>PO Start Date</th>';
        body += '<th>Last Updated On</th>';
        body += '<th>Kam Owner</th>';
        body += '<th>Sales Owner</th>';
        body += '</tr>';
        for(Asset thisAsset : filteredAssetListAwaitingKickoff){
            body += '<tr>';
            body += '<td style="text-align:center">'+( thisAsset.Account.Name != null ? thisAsset.Account.Name : '' )+'</td>';
            body += '<td style="text-align:center">'+( thisAsset.Product2.Name != null ? thisAsset.Product2.Name : '' )+'</td>';
            body += '<td style="text-align:center">'+( thisAsset.Type_of_Integration_QLI__c != null ? thisAsset.Type_of_Integration_QLI__c : '' )+'</td>';
            if(thisAsset.Account.ARR_Total_Amount__c != null){
                body += '<td style="text-align:center">'+thisAsset.Account.ARR_Total_Amount__c+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            body += '<td style="text-align:center">'+( thisAsset.Account.PGSB__c != null ? thisAsset.Account.PGSB__c : '' )+'</td>';
            if(thisAsset.Price != null){
                body += '<td style="text-align:center">'+thisAsset.Price+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            body += '<td style="text-align:center">'+( thisAsset.Account.Onboarding_Owner__r.Name != null ? thisAsset.Account.Onboarding_Owner__r.Name : '' )+'</td>';
            body += '<td style="text-align:center">'+( thisAsset.PM_Project_Owner_Name__c != null ? thisAsset.PM_Project_Owner_Name__c : '' )+'</td>';
            if(thisAsset.PurchaseDate != null){
                body += '<td style="text-align:center">'+thisAsset.PurchaseDate+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Project_Last_Modified_Date_Field__c != null){
                body += '<td style="text-align:center">'+thisAsset.Project_Last_Modified_Date_Field__c+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Account.Owner.Name != null){
                body += '<td style="text-align:center">'+thisAsset.Account.Owner.Name+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Account.Sales_Owner__r.Name != null){
                body += '<td style="text-align:center">'+thisAsset.Account.Sales_Owner__r.Name+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
        }
        body += '<tr>';
        body += '<td colspan="13">';
        body += '<br/>';
        body += '</td>';
        body += '</tr>';
        
        body += '<tr>';
        body +=    '<th bgcolor="yellow" colspan="13">---- Assets Awaiting Implementation Kick-Off (>45 days Delay) ------</th>';
        body +=    '</tr>';
        body +=    '<tr>';
        body +=    '<td colspan="13">';
        body +=    '<br/>';
        body +=    '</td>';
        body +=    '</tr>';
        body += '<tr>';
        body += '<th>Customer Name</th>';
        body += '<th>Product Name</th>';
        body += '<th>Type of Integration</th>';
        body += '<th>Total ARR</th>';
        body += '<th>Segment</th>';
        body += '<th>Asset Price</th>';
        body += '<th>CSM Owner</th>';
        body += '<th>Integration Owner</th>';
        body += '<th>PO Start Date</th>';
        body += '<th>Last Updated On</th>';
        body += '<th>Time Since Kick-off</th>';
        body += '<th>Kam Owner</th>';
        body += '<th>Sales Owner</th>';
        body += '</tr>';
        for(Asset thisAsset : filteredAssetListAwaitingImplementation){
            body += '<tr>';
            body += '<td style="text-align:center">'+( thisAsset.Account.Name != null ? thisAsset.Account.Name : '' )+'</td>';
            body += '<td style="text-align:center">'+( thisAsset.Product2.Name != null ? thisAsset.Product2.Name : '' )+'</td>';
            body += '<td style="text-align:center">'+( thisAsset.Type_of_Integration_QLI__c != null ? thisAsset.Type_of_Integration_QLI__c : '' )+'</td>';
            if(thisAsset.Account.ARR_Total_Amount__c != null){
                body += '<td style="text-align:center">'+thisAsset.Account.ARR_Total_Amount__c+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            body += '<td style="text-align:center">'+( thisAsset.Account.PGSB__c != null ? thisAsset.Account.PGSB__c : '' )+'</td>';
            if(thisAsset.Price != null){
                body += '<td style="text-align:center">'+thisAsset.Price+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            body += '<td style="text-align:center">'+( thisAsset.Account.Onboarding_Owner__r.Name != null ? thisAsset.Account.Onboarding_Owner__r.Name : '' )+'</td>';
            body += '<td style="text-align:center">'+( thisAsset.PM_Project_Owner_Name__c != null ? thisAsset.PM_Project_Owner_Name__c : '' )+'</td>';
            if(thisAsset.PurchaseDate != null){
                body += '<td style="text-align:center">'+thisAsset.PurchaseDate+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Project_Last_Modified_Date_Field__c != null){
                body += '<td style="text-align:center">'+thisAsset.Project_Last_Modified_Date_Field__c+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Aging_In_Stage__c != null){
                body += '<td style="text-align:center">'+thisAsset.Aging_In_Stage__c+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Account.Owner.Name != null){
                body += '<td style="text-align:center">'+thisAsset.Account.Owner.Name+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Account.Sales_Owner__r.Name != null){
                body += '<td style="text-align:center">'+thisAsset.Account.Sales_Owner__r.Name+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
        }
        body += '<tr>';
        body += '<td colspan="13">';
        body += '<br/>';
        body += '</td>';
        body += '</tr>';
        
        body += '<tr>';
        body +=    '<th bgcolor="yellow" colspan="13">---- Assets Awaiting UAT (>60 days Delay) ------</th>';
        body +=    '</tr>';
        body +=    '<tr>';
        body +=    '<td colspan="13">';
        body +=    '<br/>';
        body +=    '</td>';
        body +=    '</tr>';
        body += '<tr>';
        body += '<th>Customer Name</th>';
        body += '<th>Product Name</th>';
        body += '<th>Type of Integration</th>';
        body += '<th>Total ARR</th>';
        body += '<th>Segment</th>';
        body += '<th>Asset Price</th>';
        body += '<th>CSM Owner</th>';
        body += '<th>Integration Owner</th>';
        body += '<th>PO Start Date</th>';
        body += '<th>Last Updated On</th>';
        body += '<th>Time Since Kick-off</th>';
        body += '<th>Kam Owner</th>';
        body += '<th>Sales Owner</th>';
        body += '</tr>';
        for(Asset thisAsset : filteredAssetListAwaitingUat){
            body += '<tr>';
            body += '<td style="text-align:center">'+( thisAsset.Account.Name != null ? thisAsset.Account.Name : '' )+'</td>';
            body += '<td style="text-align:center">'+( thisAsset.Product2.Name != null ? thisAsset.Product2.Name : '' )+'</td>';
            body += '<td style="text-align:center">'+( thisAsset.Type_of_Integration_QLI__c != null ? thisAsset.Type_of_Integration_QLI__c : '' )+'</td>';
            if(thisAsset.Account.ARR_Total_Amount__c != null){
                body += '<td style="text-align:center">'+thisAsset.Account.ARR_Total_Amount__c+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            body += '<td style="text-align:center">'+( thisAsset.Account.PGSB__c != null ? thisAsset.Account.PGSB__c : '' )+'</td>';
            if(thisAsset.Price != null){
                body += '<td style="text-align:center">'+thisAsset.Price+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            body += '<td style="text-align:center">'+( thisAsset.Account.Onboarding_Owner__r.Name != null ? thisAsset.Account.Onboarding_Owner__r.Name : '' )+'</td>';
            body += '<td style="text-align:center">'+( thisAsset.PM_Project_Owner_Name__c != null ? thisAsset.PM_Project_Owner_Name__c : '' )+'</td>';
            if(thisAsset.PurchaseDate != null){
                body += '<td style="text-align:center">'+thisAsset.PurchaseDate+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Project_Last_Modified_Date_Field__c != null){
                body += '<td style="text-align:center">'+thisAsset.Project_Last_Modified_Date_Field__c+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Aging_In_Stage__c != null){
                body += '<td style="text-align:center">'+thisAsset.Aging_In_Stage__c+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Account.Owner.Name != null){
                body += '<td style="text-align:center">'+thisAsset.Account.Owner.Name+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Account.Sales_Owner__r.Name != null){
                body += '<td style="text-align:center">'+thisAsset.Account.Sales_Owner__r.Name+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
        }
        body += '<tr>';
        body += '<td colspan="13">';
        body += '<br/>';
        body += '</td>';
        body += '</tr>';
        
        body += '<tr>';
        body +=    '<th bgcolor="yellow" colspan="13">---- Assets Awaiting Go-Live (>14 days in UAT) ------</th>';
        body +=    '</tr>';
        body +=    '<tr>';
        body +=    '<td colspan="13">';
        body +=    '<br/>';
        body +=    '</td>';
        body +=    '</tr>';
        body += '<tr>';
        body += '<th>Customer Name</th>';
        body += '<th>Product Name</th>';
        body += '<th>Type of Integration</th>';
        body += '<th>Total ARR</th>';
        body += '<th>Segment</th>';
        body += '<th>Asset Price</th>';
        body += '<th>CSM Owner</th>';
        body += '<th>Integration Owner</th>';
        body += '<th>PO Start Date</th>';
        body += '<th>Last Updated On</th>';
        body += '<th>Time Since Kick-off</th>';
        body += '<th>Kam Owner</th>';
        body += '<th>Sales Owner</th>';
        body += '</tr>';
        for(Asset thisAsset : filteredAssetListAwaitingGoLive){
            body += '<tr>';
            body += '<td style="text-align:center">'+( thisAsset.Account.Name != null ? thisAsset.Account.Name : '' )+'</td>';
            body += '<td style="text-align:center">'+( thisAsset.Product2.Name != null ? thisAsset.Product2.Name : '' )+'</td>';
            body += '<td style="text-align:center">'+( thisAsset.Type_of_Integration_QLI__c != null ? thisAsset.Type_of_Integration_QLI__c : '' )+'</td>';
            if(thisAsset.Account.ARR_Total_Amount__c != null){
                body += '<td style="text-align:center">'+thisAsset.Account.ARR_Total_Amount__c+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            body += '<td style="text-align:center">'+( thisAsset.Account.PGSB__c != null ? thisAsset.Account.PGSB__c : '' )+'</td>';
            if(thisAsset.Price != null){
                body += '<td style="text-align:center">'+thisAsset.Price+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            body += '<td style="text-align:center">'+( thisAsset.Account.Onboarding_Owner__r.Name != null ? thisAsset.Account.Onboarding_Owner__r.Name : '' )+'</td>';
            body += '<td style="text-align:center">'+( thisAsset.PM_Project_Owner_Name__c != null ? thisAsset.PM_Project_Owner_Name__c : '' )+'</td>';
            if(thisAsset.PurchaseDate != null){
                body += '<td style="text-align:center">'+thisAsset.PurchaseDate+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Project_Last_Modified_Date_Field__c != null){
                body += '<td style="text-align:center">'+thisAsset.Project_Last_Modified_Date_Field__c+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Aging_In_Stage__c != null){
                body += '<td style="text-align:center">'+thisAsset.Aging_In_Stage__c+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Account.Owner.Name != null){
                body += '<td style="text-align:center">'+thisAsset.Account.Owner.Name+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
            if(thisAsset.Account.Sales_Owner__r.Name != null){
                body += '<td style="text-align:center">'+thisAsset.Account.Sales_Owner__r.Name+'</td>';
            }else{
                body += '<td style="text-align:center"></td>';
            }
        }
        body += '<tr>';
        body += '<td colspan="13">';
        body += '<br/>';
        body += '</td>';
        body += '</tr>';
        
        body += '</table>';
        body += '<br/>';
        body += 'Thanks,<br/>';
        body += 'SF Team<br/>';
        
        mail.setHtmlBody(body);
        mail.setToAddresses(recipients);
        //mail.setCcAddresses(new String[]{thisAsset.Account.Onboarding_Owner__r.Manager.Email});
        //mail.setCcAddresses(new String[]{'bhavesh.jindal@cleartax.in'});
        mail.setOrgWideEmailAddressId(defaultMailId);
        mailList.add(mail);
        
        system.debug('mailList: '+mailList.size());
        if(!mailList.isEmpty()) {
            try{
                Messaging.sendEmail(mailList);
            }
            catch (Exception ex) {
                errorMessages.add('Unable to send email'+ ex.getMessage());
            }
        }
        System.debug('Errors : ' +errorMessages);
    }
}