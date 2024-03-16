public class CTX_JIRAMappingClass {
    
    public static Map<String, Team_Responsible_SF_Jira__mdt> getJIRATeamMapping(){
        
        Map<String, Team_Responsible_SF_Jira__mdt> mapOfL3TeamAndJIRAProject = new Map<String, Team_Responsible_SF_Jira__mdt>();
        
        for(
            Team_Responsible_SF_Jira__mdt  thisRec : [ SELECT Id, MasterLabel, DeveloperName, Team_Responsible__c , Project_Code__c, 
                                                      Assignee__c, Assignee_Name__c 
                                                      FROM Team_Responsible_SF_Jira__mdt WHERE 
                                                      Project_Code__c != NULL ]
        )
            mapOfL3TeamAndJIRAProject.put(thisRec.Team_Responsible__c, thisRec);
        system.debug('mapOfL3TeamAndJIRAProject: '+mapOfL3TeamAndJIRAProject);
        return mapOfL3TeamAndJIRAProject;
    }
}