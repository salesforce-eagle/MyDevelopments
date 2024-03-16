public class ContactTriggerHelper {
public static list<contact> checkDupEmail(List<SObject> listOfNewSObjects,map<id,Contact> oldMapOfUsagePan,boolean updateValue){

        list<Contact> panList = (list<Contact>)listOfNewSObjects;
        list<Contact> retPanList = new list<Contact>();
        list<string> UPDup = new list<string>();
       for(sObject obj : listOfNewSObjects)
              {
                  if(!String.isBlank(((Contact)obj).Email)){
            UPDup.add((((Contact)obj).Email).toUpperCase());
                  }
        }
        map<string,list<string>> accMap = new map<string,list<string>>();
        list<string> dynamicVal = new list<string>();
        list<Contact> UPList= [select Email,accountid from Contact where  email in : UPDup];
       // map<id,Usage_Pans__c> UPMap  = new map<id,Usage_Pans__c>([select Usage_Pan__c,account__c,account__r.id from Usage_Pans__c where id  in : listOfNewSObjects]);
        if(UPList.size()>0){ 
        for(Contact UP : UPList){
            if(!accMap.containsKey(UP.Email.toLowerCase())){
                dynamicVal.add(UP.accountId);
                 accMap.put(UP.Email.toLowerCase(),dynamicVal);
            }
            else{
                dynamicVal = accMap.get(UP.Email.toLowerCase());
                dynamicVal.add(UP.accountId);
                accMap.put(UP.Email.toLowerCase(),dynamicVal); 
            }
      }
        }
        // UPList = [select Usage_Pan__c,account__c,account__r.id from Usage_Pans__c where id  in : listOfNewSObjects];

        for(contact obj:panList){ 
            if(!String.isBlank(obj.Email)){
            obj.Email = obj.Email.toUpperCase();
            }
            retPanList.add(obj);
            system.debug('^$^$%^'+accMap);
              if((updateValue && ((oldMapOfUsagePan.get(obj.id).Email != obj.Email) || (oldMapOfUsagePan.get(obj.id).accountId != obj.accountId)) ) || !updateValue){
            if(!String.isBlank(obj.Email) && !accMap.containsKey(obj.Email.toLowerCase())){  
                dynamicVal = new list<id>();
                dynamicVal.add(obj.accountId);
            accMap.put(obj.Email.toLowerCase(),dynamicVal);
            }
            
            else if(!String.isBlank(obj.Email) && !((accMap.get(obj.Email.toLowerCase())).contains(string.valueOf(obj.accountId)))){
                system.debug('^$^$%^'+accMap);

                    dynamicVal = accMap.get(obj.Email.toLowerCase());
               dynamicVal.add(obj.accountId);
               accMap.put(obj.Email.toLowerCase(),dynamicVal); 
                }
               
            else if(!String.isBlank(obj.Email)){
                
                obj.addError('Duplicate Email! Please Check the Contacts within the Account.');
            }
        }
        }
        return retPanList;
    }
    
    public static void checkEmailInLeads(List<Contact> newContacts, Map<Id, Contact> oldMapContacts) {
        
        Set<String> emails = new Set<String>();
        List<Contact> conToProcess = new List<Contact>();
        for(Contact con : newContacts) {
            if((con.Email != null) && (Trigger.isInsert || (Trigger.isUpdate && con.Email != oldMapContacts.get(con.Id).Email))) {
                emails.add(con.Email);
                conToProcess.add(con);
			}               
        }
        
		Set<String> leadEmails = new Set<String>();
        
        for (Lead ld : [SELECT Id, Email FROM Lead WHERE Email In :emails AND isConverted = false]){
            leadEmails.add(ld.Email);
        }
        
        for(Contact con : conToProcess) {
            if(leadEmails.contains(con.Email)){
                con.Email.addError('There is existing Lead with same email, please convert that lead.');
            }                  
        }
    }
}