public class CTX_JIRAIntegrationQueueable implements Queueable, Database.AllowsCallouts{
    
    CTX_Salesforce_JIRA_FilterResult.CreateUpdateJIRAIssueWrapper			wrapperJIRA			= new CTX_Salesforce_JIRA_FilterResult.CreateUpdateJIRAIssueWrapper();
    CTX_Salesforce_JIRA_FilterResult.CreateUpdateJIRAIssueWrapper_Feature	wrapperJIRA_Feature = new CTX_Salesforce_JIRA_FilterResult.CreateUpdateJIRAIssueWrapper_Feature();
    Boolean																	isBug;
    Boolean 																isGetmethod;
    Boolean 																isPostMethod;
    Boolean 																isPutMethod;
    
    
    Public CTX_JIRAIntegrationQueueable(
        CTX_Salesforce_JIRA_FilterResult.CreateUpdateJIRAIssueWrapper 			inputResult_Bug,
        CTX_Salesforce_JIRA_FilterResult.CreateUpdateJIRAIssueWrapper_Feature	inputResult_Feature,
        Boolean																	isBug,
        Boolean 																isGetmethod,
        Boolean 																isPostMethod,
        Boolean 																isPutMethod
    ){
        this.wrapperJIRA 			= inputResult_Bug;
        this.wrapperJIRA_Feature 	= inputResult_Feature;
        this.isBug					= isBug;
        this.isGetmethod 			= isGetmethod;
        this.isPostMethod 			= isPostMethod;
        this.isPutMethod 			= isPutMethod;
    }
    
    public void execute(QueueableContext context) {
        if(isBug){
            CTX_Salesforce_JIRA_Callout.callout_Salesforce_JIRA(wrapperJIRA, NULL, TRUE, isGetmethod, isPostMethod, isPutMethod);
        } else{
            CTX_Salesforce_JIRA_Callout.callout_Salesforce_JIRA(NULL, wrapperJIRA_Feature, FALSE, isGetmethod, isPostMethod, isPutMethod);
        }
        
        //CTX_Salesforce_JIRA_Callout.callout_Salesforce_JIRA(wrapperJIRA, isGetmethod, isPostMethod, isPutMethod);
    }
  
}