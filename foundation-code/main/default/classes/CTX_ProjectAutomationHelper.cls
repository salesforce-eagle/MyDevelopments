public class CTX_ProjectAutomationHelper {
    
    public static Project__c getScopeModeInHouseDetails( Project__c thisRec ){
        
        switch on thisRec.Type_of_Integration__c {
            when 'API - Only by CT SI'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'JSON API';
                thisRec.In_house_project__c = FALSE;
            }
            when 'API - Only by CT Inhouse SAP ECC/HANA'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'JSON API'; 
                thisRec.In_house_project__c = FALSE;
            }
            when 'API - Only by CT Inhouse SAP B1'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'JSON API';
                thisRec.In_house_project__c = FALSE;
            }
            when 'API - Only by CT Inhouse Custom ERP'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'JSON API';
                thisRec.In_house_project__c = FALSE;
            }
            when 'API - Only by CT Inhouse Tally ERP'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'JSON API';
                thisRec.In_house_project__c = TRUE;
            }
            when 'API - Only by CT Inhouse Netsuite ERP'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'JSON API';
                thisRec.In_house_project__c = FALSE;
            }
            when 'FTP/SFTP - Only by customer'{ 
                thisRec.Scope_Category__c = 'Consultation';
                thisRec.Mode_of_Integration__c = 'FTP';
                thisRec.In_house_project__c = TRUE;
            }
            when 'API- Only by Customer'{ 
                thisRec.Scope_Category__c = 'Consultation';
                thisRec.Mode_of_Integration__c = 'JSON API';
                thisRec.In_house_project__c = TRUE;
            }
            when 'FTP/ SFTP - Only by CT Inhouse'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'FTP';
                thisRec.In_house_project__c = TRUE;
            }
            when 'FTP/ SFTP - Only by SI'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'FTP';
                thisRec.In_house_project__c = FALSE;
            }
            when 'ID - API based Integration'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'JSON API';
                thisRec.In_house_project__c = TRUE;
            }
            when 'ID - Middleware based Integration'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'JSON API';
                thisRec.In_house_project__c = TRUE;
            }
            when 'ID - SFTP based Integration'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'FTP';
                thisRec.In_house_project__c = TRUE;
            }
            when 'ID - Manual Integration'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'Manual Upload';
                thisRec.In_house_project__c = TRUE;
            }
            when 'API - Only by CT Inhouse Microsoft ERP'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'JSON API';
                thisRec.In_house_project__c = TRUE;
            }
            when 'Others'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'JSON API';
                thisRec.In_house_project__c = TRUE;
            }
            when 'Invoice Discounting'{ 
                thisRec.Scope_Category__c = 'Development';
                thisRec.Mode_of_Integration__c = 'JSON API';
                thisRec.In_house_project__c = TRUE;
            }
        }
        
        return thisRec;
    }
    
    public static Project__c getEstimatedDateForProject( Project__c thisRec, Date assetPurchaseDate ){
        
        DateTime projectStartDate 		= assetPurchaseDate;
        Integer implementation_End_Days = 0;
        Integer uat_End_Days 			= 0;
        Integer goLive_Days 			= 0;
        
        if( projectStartDate < thisRec.CreatedDate ){
            projectStartDate = thisRec.CreatedDate;
        }
        if( projectStartDate < thisRec.LOE_Received_Date__c ){
            projectStartDate = thisRec.LOE_Received_Date__c;
        }
        
        
        if( thisRec.Scope_Category__c == 'Consultation' ){
            implementation_End_Days = 39;
            uat_End_Days = 14;
            goLive_Days = 7;
        }
        if( thisRec.Scope_Category__c == 'Development' ){
            
            if( thisRec.Product__c == 'EINV' ){
                implementation_End_Days = 24;
                uat_End_Days = 14;
                goLive_Days = 7;
            }
            if( thisRec.Product__c == 'EWB' ){
                implementation_End_Days = 24;
                uat_End_Days = 14;
                goLive_Days = 7;
            }
            if( thisRec.Product__c == 'ASP/GSP' ){
                implementation_End_Days = 39;
                uat_End_Days = 14;
                goLive_Days = 7;
            }
            if( thisRec.Product__c == 'Invoice Discounting' ){
                implementation_End_Days = 39;
                uat_End_Days = 14;
                goLive_Days = 7;
            }
            if( thisRec.Product__c == 'Max ITC' ){
                implementation_End_Days = 59;
                uat_End_Days = 21;
                goLive_Days = 10;
            }
            if( thisRec.Product__c == 'Clear Capture' ){
                implementation_End_Days = 59;
                uat_End_Days = 21;
                goLive_Days = 10;
            }
            if( thisRec.Product__c == 'AP' ){
                implementation_End_Days = 59;
                uat_End_Days = 21;
                goLive_Days = 10;
            }
            if( thisRec.Product__c == 'KSA EINV I' ){
                implementation_End_Days = 59;
                uat_End_Days = 21;
                goLive_Days = 10;
            }
            if( thisRec.Product__c == 'KSA EINV II' ){
                implementation_End_Days = 59;
                uat_End_Days = 21;
                goLive_Days = 10;
            }
        }

        thisRec.LOE_Received_Date__c 					= Date.newinstance(projectStartDate.year(), projectStartDate.month(), projectStartDate.day());
        thisRec.Estimated_Implementation_End_Date__c	= thisRec.LOE_Received_Date__c.addDays(implementation_End_Days);
        thisRec.Estimated_UAT_End_Date__c 				= thisRec.Estimated_Implementation_End_Date__c.addDays(uat_End_Days);
        thisRec.Estimated_Go_Live_Date__c 				= thisRec.Estimated_UAT_End_Date__c.addDays(goLive_Days);
        
        return thisRec;
    }
    
    
}