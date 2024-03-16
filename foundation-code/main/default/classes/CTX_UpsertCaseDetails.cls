/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-01-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_UpsertCaseDetails IMPLEMENTS Queueable,Database.AllowsCallouts{
    
    List<Case> updateCaseOnUiList = new List<Case>();
    
    public CTX_UpsertCaseDetails(List<Case> updateCaseOnUiListFromParent){
        this.updateCaseOnUiList = updateCaseOnUiListFromParent;
        system.debug('updateCaseOnUiList: '+updateCaseOnUiList);
        
    }
    
    public void execute(QueueableContext context){
        callout_UpsertCase_API(updateCaseOnUiList);
    } 
    
    public static void callout_UpsertCase_API(List<Case> updateCaseOnUiList){
        
        Set<Id>	caseIds = new Set<id>();
        for( Case thisRec : updateCaseOnUiList){
            caseIds.add(thisRec.id);
        }
        
       String 			queryString	= ' SELECT Id, Status, CaseNumber, Sub_Status__c,Environment__c, Product_Unique_Identifier__c FROM Case WHERE Id IN :caseIds AND Product_Unique_Identifier__c != NULL ';
       Map<Id, Case>  	caseMap    	= new Map<Id, Case>( (List<Case>)database.query(queryString) );
        
        for( Case thisRec : caseMap.values() ){
            
            RequestWrapper 	reqWrap		= new RequestWrapper();
            reqWrap.externalId      	= thisRec.Id;
            reqWrap.externalCaseNumber	= thisRec.CaseNumber;
            reqWrap.status     			= ( thisRec.Status == 'Solved' || thisRec.Status == 'Closed' ) ? 'COMPLETED' : 'IN_PROGRESS';
            reqWrap.subStatus  			= thisRec.Sub_Status__c != NULL && thisRec.Sub_Status__c != '' ? thisRec.Sub_Status__c : reqWrap.status;
            
            String json_Body 			= JSON.serialize(reqWrap);
        	System.debug('json_Body in case : '+json_Body);
            
            HttpResponse response = CTX_CaseAPICalloutClass.caseUpdateCallout(json_Body,thisRec.Product_Unique_Identifier__c,thisRec.Environment__c);
            
            if( response.getStatusCode() == 200 ){
                System.debug('Success hit in case : '+response);
            }
            else{
                System.debug('Failure hit in case : '+response);
            }
            
        }
        
    }
    
       public class RequestWrapper {
        public string externalId;
        public string externalCaseNumber;
        public string status;
        public string subStatus;
    }
}