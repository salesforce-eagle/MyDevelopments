public class CTX_MuliselectLookUpController {
	@AuraEnabled(cacheable=true)
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String searchOnField, String lookupFilterCondition, String value, List<String> selectedRecId) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        system.debug(fieldName+'-------------'+ObjectName+'---++----------'+value+'====='+selectedRecId);
        if(selectedRecId == null)
            selectedRecId = new List<String>();

        if(String.isNotEmpty(value)) {
            String lookupFilter = '';
            if(lookupFilterCondition != null || lookupFilterCondition?.trim() != ''){
                lookupFilter = ' AND ' + lookupFilterCondition;
            }
            String query = 'Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+searchOnField+' LIKE \'%' + value.trim() + '%\''+ lookupFilter+ ' and ID NOT IN: selectedRecId';
            system.debug(query);
            for(sObject so : Database.Query(query)) {
                String fieldvalue = (String)so.get(searchOnField);
                sObjectResultList.add(new SObjectResult(fieldvalue, so.Id, so));
            }
        }
        return sObjectResultList;
    }
    
    public class SObjectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        @AuraEnabled
        public sObject record;
        
        public SObJectResult(String recNameTemp, Id recIdTemp, sObject recordTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
            record = recordTemp;
        }
    }
}