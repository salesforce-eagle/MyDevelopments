public class CTX_EscalationMatricesExtract {
    
    public static Map<String, Map<String, Escalation_Matrice__mdt>> fetchEscalationMatrices(String priorityString){
        
        Map<String, Map<String, Escalation_Matrice__mdt>> priorityListLevelMatriceMap = 
            new Map<String, Map<String, Escalation_Matrice__mdt>>();
        
        for(
            Escalation_Matrice__mdt thisRec : [ SELECT Id, DeveloperName, MasterLabel, Priority_List__c, Priority_Level__c, 
                                               IsUser__c, User_Id__c, User_Email__c, Is_Field_Reference__c, 
                                               Reference_Field_Details__c, Is_Role__c, Role_Ids__c 
                                               FROM Escalation_Matrice__mdt ] 
        ){
            
            if(priorityListLevelMatriceMap.containsKey(thisRec.Priority_List__c)){
                
                Map<String, Escalation_Matrice__mdt> internalMapOfPriorityLevelAndRecord = priorityListLevelMatriceMap.get(thisRec.Priority_List__c);
                internalMapOfPriorityLevelAndRecord.put(thisRec.Priority_Level__c, thisRec);
                priorityListLevelMatriceMap.put(thisRec.Priority_List__c, internalMapOfPriorityLevelAndRecord);
            } else{
                priorityListLevelMatriceMap.put(thisRec.Priority_List__c, new Map<String, Escalation_Matrice__mdt>{thisRec.Priority_Level__c => thisRec});
            }
            
        }
        
        return priorityListLevelMatriceMap;
    }	/**	End of Method fetchEscalationMatrices()	**/
    
    Public Class RecipientDetails{
        Public Map<Id, List<String>>	recipentList		= new Map<Id, List<String>>();
        Public Map<Id, List<String>>	fieldReferenceMap 	= new Map<Id, List<String>>();
    }
    
    public static CTX_EscalationMatricesExtract.RecipientDetails fetchRecipientDetails(){
        
        CTX_EscalationMatricesExtract.RecipientDetails returnWrapper = new CTX_EscalationMatricesExtract.RecipientDetails();
        
        /**	Fetch All the details from Escalation Matrices	**/
        Map<Id, List<String>>			recipentList		= new Map<Id, List<String>>();
        Map<Id, List<String>> 			fieldReferenceMap 	= new Map<Id, List<String>>();
        Map<Id, List<String>>			userEmailMap 		= new Map<Id, List<String>>();
        Map<Id, List<String>> 			userRoleMapTemp		= new Map<Id, List<String>>();
        Map<Id, String> 				userRoleMap 		= new Map<Id, String>();
        List<String>					roleIds				= new List<String>();
        
        List<Escalation_Matrice__mdt>	fetchMatriceData 	= [ SELECT Id, DeveloperName, MasterLabel, Priority_List__c, Priority_Level__c, 
                                                               IsUser__c, User_Id__c, User_Email__c, Is_Field_Reference__c, 
                                                               Reference_Field_Details__c, Is_Role__c, Role_Ids__c 
                                                               FROM Escalation_Matrice__mdt ];
        
        for(Escalation_Matrice__mdt thisRec :  fetchMatriceData){
            
            if(thisRec.IsUser__c){
                userEmailMap.put(thisRec.Id, thisRec.User_Email__c.split(','));
            }
            
            if(thisRec.Is_Field_Reference__c){
                fieldReferenceMap.put(thisRec.Id, thisRec.Reference_Field_Details__c.split(','));
            }
            
            if(thisRec.Is_Role__c){
                userRoleMap.put(thisRec.Id, thisRec.Role_Ids__c);
                userRoleMapTemp.put(thisRec.Id, NULL);
                roleIds.addAll(thisRec.Role_Ids__c.split(','));
            }
        }
        
        if(roleIds.size() > 0){
            for(User thisRec : [SELECT Email, UserRoleId FROM User WHERE UserRoleId IN :roleIds ] ){
                
                for(String thisSTR : userRoleMap.keySet()){
                    
                    if(userRoleMap.get(thisSTR).contains(thisRec.UserRoleId)){
                        
                        if(userRoleMapTemp.get(thisSTR) != NULL){
                            userRoleMapTemp.get(thisSTR).add(thisRec.Email);
                        } else{
                            userRoleMapTemp.put(thisSTR, new List<String>{thisRec.Email});
                        }
                    }
                } 
            }
        }
        
        for(Escalation_Matrice__mdt thisRec :  fetchMatriceData){
            
            if(recipentList.containsKey(thisRec.Id)){
                
                if(userEmailMap.containsKey(thisRec.Id)){
                    recipentList.get(thisRec.Id).addAll(userEmailMap.get(thisRec.Id));
                }
                    
                if(userRoleMapTemp.containsKey(thisRec.Id)){
                    recipentList.get(thisRec.Id).addAll(userRoleMapTemp.get(thisRec.Id));
                }
            } else{
                
                if(userEmailMap.containsKey(thisRec.Id)){
                    recipentList.put(thisRec.Id, userEmailMap.get(thisRec.Id));
                }
                    
                if(userRoleMapTemp.containsKey(thisRec.Id)){
                    recipentList.put(thisRec.Id, userRoleMapTemp.get(thisRec.Id));
                }
                    
            }
        }
        /**	Fetch Ends	**/
        
        returnWrapper.recipentList 		= recipentList;
        returnWrapper.fieldReferenceMap = fieldReferenceMap;
        
        return returnWrapper;
    }
    
    public static void fetchAccountAssetDetails(Map<Id, Project__c> projectMap){
        
        Map<Id, List<AccountProjectAssetJunction__c>> projectAndOtherDetails = 
            new Map<Id, List<AccountProjectAssetJunction__c>>();
        
        for(
            AccountProjectAssetJunction__c thisRec : [ SELECT Id, Asset__c, Customer_Account__c, Project__c 
                                                      FROM AccountProjectAssetJunction__c WHERE 
                                                      Project__c IN :projectMap.keySet() ]
        ){
            
            if(projectAndOtherDetails.containsKey(thisRec.Project__c)){
                projectAndOtherDetails.get(thisRec.Project__c).add(thisRec);
            } else{
                projectAndOtherDetails.put(thisRec.Project__c, new List<AccountProjectAssetJunction__c>{thisRec});
            }
        }
    }
    
    public static Map<String, Map<String, Escalation_Matrice__mdt>> fetchEscalationMapping(){
        
        Map<String, Map<String, Escalation_Matrice__mdt>> priorityListLevelMatriceMap = 
            new Map<String, Map<String, Escalation_Matrice__mdt>>();
        
        for(
            Escalation_Matrice__mdt thisRec : [ SELECT Id, DeveloperName, MasterLabel, Priority_List__c, Priority_Level__c, 
                                               IsUser__c, User_Id__c, User_Email__c, Is_Field_Reference__c, 
                                               Reference_Field_Details__c, Is_Role__c, Role_Ids__c 
                                               FROM Escalation_Matrice__mdt ] 
        ){
            if(priorityListLevelMatriceMap.containsKey(thisRec.Priority_List__c)){
                
                Map<String, Escalation_Matrice__mdt> internalMapOfPriorityLevelAndRecord = priorityListLevelMatriceMap.get(thisRec.Priority_List__c);
                internalMapOfPriorityLevelAndRecord.put(thisRec.Priority_Level__c, thisRec);
                priorityListLevelMatriceMap.put(thisRec.Priority_List__c, internalMapOfPriorityLevelAndRecord);
            } else{
                priorityListLevelMatriceMap.put(thisRec.Priority_List__c, new Map<String, Escalation_Matrice__mdt>{thisRec.Priority_Level__c => thisRec});
            }
        }
        
        return priorityListLevelMatriceMap;
        
    }
    
}