public class CTX_OpportunityCustomPathApexClass{
    
    @AuraEnabled
    Public Static String updateStageDetails( Id recordId, String stageNameVal, String salesStageVal ){
        
        List<Opportunity> 	updateOpportunities = new List<Opportunity>();
        String				returnString;
        for(
            Opportunity thisRec : [ SELECT Id, StageName, Sales_Stage_New__c 
                                   FROM Opportunity WHERE Id =: recordId LIMIT 1 ]
        ){
            
            if(stageNameVal != NULL || stageNameVal != '')
                thisRec.StageName 			= stageNameVal;
            if(salesStageVal != NULL || salesStageVal != '')
                thisRec.Sales_Stage_New__c	= salesStageVal;
            
            updateOpportunities.add(thisRec);
        }
        
        try{
            update updateOpportunities;
            returnString = 'Opportunity Updated Successfully.';
        } catch(Exception ex){
            returnString =  ex.getDmlMessage(0);
        }
        
        return returnString; 
    }
    
    @AuraEnabled
    public static String getRecordTypeName(String recordId) {
        Opportunity opp = [SELECT Id,RecordType.DeveloperName FROM Opportunity WHERE Id = :recordId];
        Return (String)opp.RecordType.DeveloperName;
    }
    
}