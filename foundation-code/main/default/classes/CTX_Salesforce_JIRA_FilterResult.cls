public without sharing class CTX_Salesforce_JIRA_FilterResult {
    
    public static void fetchCaseDetails(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
        
        CreateUpdateJIRAIssueWrapper 				wrapperResult 				= new CreateUpdateJIRAIssueWrapper();
        CreateUpdateJIRAIssueWrapper_Feature		wrapperResult_Feature		= new CreateUpdateJIRAIssueWrapper_Feature();
        Boolean										isPostMethod 				= FALSE;
        Boolean										isPutMethod					= FALSE;
        Map<String, Team_Responsible_SF_Jira__mdt> 	mapOfL3TeamAndJIRAProject;
        Boolean										isError						= FALSE;
        Set<Id>										incomingCaseIds				= new Set<Id>(newCaseMap.keySet());
        Map<Id, Case> 								caseMap;
        Boolean										isJIRAUpdateRequired		= FALSE;
        Boolean										isBug						= FALSE;
        List<String> 								getFieldSetFields 			= new List<String>();
        /*	Entry Condition Evaluation : START	**/
        
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Case');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSet = DescribeSObjectResultObj.FieldSets.getMap().get('Jira_Issue_Updation');        
        if( !fieldSet.getFields().isEmpty() ){
            for(Schema.FieldSetMember thisRec : fieldSet.getFields()){
                getFieldSetFields.add( String.valueOf(thisRec.getSobjectfield()) );
            }
        }
        
        for(Case thisRec : newCaseMap.values()){
            
            if( thisRec.JIRA_Issue_Id__c != NULL ){
                for(String fieldName: getFieldSetFields){
                    if( newCaseMap.get(thisRec.Id).get(fieldName) != oldCaseMap.get(thisRec.Id).get(fieldName) ){
                        isJIRAUpdateRequired = TRUE;
                    }
                }
            } else{
                if(thisRec.User_Role_Type__c != NULL){
                    if( thisRec.User_Role_Type__c != oldCaseMap.get(thisRec.Id).User_Role_Type__c ){
                        if( CaseConstants.CASE_TEAM_RESPONSIABLE_DEV_ON_CALL.contains(thisRec.User_Role_Type__c) ) {
                            if( thisRec.Type == 'Bug' || thisRec.Type == 'Feature' )
                                isJIRAUpdateRequired = TRUE;
                        }
                    }
                }
            }
            
            
            if( thisRec.Type == 'Bug' ){
                isBug = TRUE;
            }
            if( thisRec.Type == 'Feature' ){
                isBug = FALSE;
            }
        }
        
        isJIRAUpdateRequired= true;
        /*	Entry Condition Evaluation : START	**/
        System.debug('isJIRAUpdateRequired: '+isJIRAUpdateRequired);
        if(CTX_checkRecursive.isFirstTime){
            CTX_checkRecursive.isFirstTime 	= FALSE;
            
            if(isJIRAUpdateRequired){
                
                String query 				= 'SELECT  '+ System.label.JIRA_Query_Label+' , '+ System.label.JIRA_EmailMessage_SubQuery +' FROM Case WHERE Id IN :incomingCaseIds ';
                caseMap 					= new Map<Id, Case>((List<Case>)Database.query(query));
                mapOfL3TeamAndJIRAProject	= CTX_JIRAMappingClass.getJIRATeamMapping();
                
                for(Case thisRec : newCaseMap.values()){
                    /* if( (thisRec.JIRA_Issue_Id__c == NULL && !thisRec.Updated_in_JIRA__c) || (thisRec.Updated_in_JIRA__c && thisRec.JIRA_Issue_Id__c != NULL) ){}	*/
                    
                    /**	Code Block : START	**/
                    if(thisRec.JIRA_Issue_Id__c != NULL)
                        isPutMethod = TRUE;
                    else
                        isPostMethod = TRUE;
                    
                    system.debug('isPutMethod: '+isPutMethod+' -- isPutMethod: '+isPutMethod);
                    
                    if( mapOfL3TeamAndJIRAProject.containsKey(thisRec.User_Role_Type__c) ){
                        
                        /**	BUG BLOCK : START	**/
                        if(thisRec.Type == 'Bug'){
                            
                            system.debug('mapOfL3TeamAndJIRAProject.get(thisRec.User_Role_Type__c).Project_Code__c: '+mapOfL3TeamAndJIRAProject.get(thisRec.User_Role_Type__c).Project_Code__c);
                            
                            wrapperResult.dummy.fields.project.id 			= String.valueOf((Integer)mapOfL3TeamAndJIRAProject.get(thisRec.User_Role_Type__c).Project_Code__c);
                            
                            wrapperResult.dummy.fields.issuetype.id 		= '10004';
                            
                            system.debug('thisRec.Priority: '+thisRec.Priority);
                            if(thisRec.Priority == NULL)
                                wrapperResult.dummy.fields.priority.id			= '4';
                            else{
                                
                                if(thisRec.Priority == 'Medium' || thisRec.Priority == 'P2'){
                                    wrapperResult.dummy.fields.priority.id = '3';
                                } else if(thisRec.Priority == 'P1'){
                                    wrapperResult.dummy.fields.priority.id = '2';
                                } else if(thisRec.Priority == 'P0'){
                                    wrapperResult.dummy.fields.priority.id = '1';
                                } else{
                                    wrapperResult.dummy.fields.priority.id = '4';
                                }
                                
                            }
                            
                            system.debug('wrapperResult.dummy.fields.priority.id: '+wrapperResult.dummy.fields.priority.id);
                            wrapperResult.dummy.fields.description 				= thisRec.Description;
                            wrapperResult.dummy.fields.summary 					= thisRec.Subject;
                            wrapperResult.dummy.fields.customfield_10363		= thisRec.CaseNumber;								/**	Salesforce Case Number	**/
                            wrapperResult.dummy.fields.customfield_10750		= thisRec.Status;									/**	Status	**/
                            wrapperResult.dummy.fields.customfield_10751		= thisRec.Sub_Status__c;							/**	Sub Status	**/
                            wrapperResult.dummy.fields.customfield_10752		= caseMap.get(thisRec.Id).Account.Name;				/** Account Name	**/
                            wrapperResult.dummy.fields.customfield_10753		= thisRec.ContactEmail;								/**	ContactEmail	**/
                            wrapperResult.dummy.fields.customfield_10754		= thisRec.Plan_Type__c;								/**	Plan Type	**/
                            wrapperResult.dummy.fields.customfield_10755		= thisRec.GSTN__c;									/**	GSTIN	**/
                            wrapperResult.dummy.fields.customfield_10756		= caseMap.get(thisRec.Id).Account.Product_Email__c;	/** Account.Product_Email__c	**/
                            wrapperResult.dummy.fields.customfield_10757		= thisRec.POD_Group__c;								/** POD **/
                            wrapperResult.dummy.fields.customfield_10758		= caseMap.get(thisRec.Id).Previous_Owner__r.Name;	/**	Prev Owner	**/
                            
                            if( thisRec.Lookup_Issue_Type__c != NULL ) 
                                wrapperResult.dummy.fields.customfield_10749	= caseMap.get(thisRec.Id).Lookup_Issue_Type__r.Name;
                            if( thisRec.Lookup_Issue_Type1__c != NULL ) 
                                wrapperResult.dummy.fields.customfield_10749	= caseMap.get(thisRec.Id).Lookup_Issue_Type1__r.Name;
                            if( thisRec.Lookup_Issue_Type_EInv__c != NULL ) 
                                wrapperResult.dummy.fields.customfield_10749	= caseMap.get(thisRec.Id).Lookup_Issue_Type_EInv__r.Name;
                            
                            wrapperResult.dummy.fields.customfield_10759		= thisRec.Issue_Type_1_New__c;							/**	Issue_Type_1__c	**/
                            wrapperResult.dummy.fields.customfield_10760		= thisRec.Issue_Type_2_New__c;							/** Issue_Type_2__c	**/
                            wrapperResult.dummy.fields.customfield_10761		= thisRec.Issue_Type_3_New__c;							/** Issue_Type_3__c	**/
                            wrapperResult.dummy.fields.customfield_10762		= thisRec.Issue_Type_4_New__c;							/**	Issue_Type_4__c	**/
                            wrapperResult.dummy.fields.customfield_10763		= thisRec.Comments;									/**	Internal Comment	**/
                            wrapperResult.dummy.fields.customfield_10764		= thisRec.CreatedDate;								/**	Case Created Date	**/
                            wrapperResult.dummy.fields.customfield_10765		= thisRec.Type;	
                            wrapperResult.dummy.fields.customfield_10809		= thisRec.Account_Active_ARR__c;/**	Account ARR	**/

                            wrapperResult.dummy.fields.customfield_10811		= thisRec.Is_Pre_Sales_Case__c ? 'Yes' : 'No';
                            wrapperResult.dummy.fields.customfield_10665.value	= 'Prod';
                            wrapperResult.dummy.fields.customfield_10704.value	= 'Customer';
                            
                            if(isPostMethod){
                                wrapperResult.dummy.fields.assignee.id				= String.valueOf(mapOfL3TeamAndJIRAProject.get(thisRec.User_Role_Type__c).Assignee__c);	
                            }else{
                                wrapperResult.dummy.fields.assignee.id  = caseMap.get(thisRec.Id).Jira_Assignee__c;
                            }

                            
                            /**	Field For Case Update	**/
                            wrapperResult.issueId 								= thisRec.JIRA_Issue_Id__c;
                            wrapperResult.caseId 								= thisRec.Id;
                            
                            if(isPostMethod)
                            wrapperResult.assigneeName							= String.valueOf(mapOfL3TeamAndJIRAProject.get(thisRec.User_Role_Type__c).Assignee_Name__c);	
                            
                            if(caseMap.get(thisRec.Id).EmailMessages.size() >0){
                                System.debug('#EmailMessage'+caseMap.get(thisRec.Id).EmailMessages[0]);
                                if( caseMap.get(thisRec.Id).EmailMessages[0].Jira_Comment_Id__c == NULL ){
                                    
                                    wrapperResult.mailTrails						= (String)caseMap.get(thisRec.Id).EmailMessages[0].TextBody;
                                    wrapperResult.emailMessageId					= (String)caseMap.get(thisRec.Id).EmailMessages[0].Id;
                                }
                            }
                        }
                        /**	BUG BLOCK : END	**/
                        
                        system.debug('Cas Id is: '+thisRec.Id);
                        /**	FEATURE BLOCK : START	**/
                        if(thisRec.Type == 'Feature'){
                            wrapperResult_Feature.dummy.fields.project.id 			= String.valueOf((Integer)mapOfL3TeamAndJIRAProject.get(thisRec.User_Role_Type__c).Project_Code__c);
                            
                            
                            system.debug('mapOfL3TeamAndJIRAProject.get(thisRec.User_Role_Type__c).Project_Code__c: '+mapOfL3TeamAndJIRAProject.get(thisRec.User_Role_Type__c).Project_Code__c);
                            
                            wrapperResult_Feature.dummy.fields.project.id 			= String.valueOf((Integer)mapOfL3TeamAndJIRAProject.get(thisRec.User_Role_Type__c).Project_Code__c);
                            
                            wrapperResult_Feature.dummy.fields.issuetype.id 		= '10001';
                            
                            if(thisRec.Priority == NULL)
                                wrapperResult_Feature.dummy.fields.priority.id			= '3';
                            else
                                wrapperResult_Feature.dummy.fields.priority.id			= (thisRec.Priority == 'Medium' || thisRec.Priority == 'P2') ? '2' : '1';
                            
                            
                            wrapperResult_Feature.dummy.fields.description 				= thisRec.Description;
                            wrapperResult_Feature.dummy.fields.summary 					= thisRec.Subject;
                            wrapperResult_Feature.dummy.fields.customfield_10363		= thisRec.CaseNumber;								/**	Salesforce Case Number	**/
                            wrapperResult_Feature.dummy.fields.customfield_10750		= thisRec.Status;									/**	Status	**/
                            wrapperResult_Feature.dummy.fields.customfield_10751		= thisRec.Sub_Status__c;							/**	Sub Status	**/
                            wrapperResult_Feature.dummy.fields.customfield_10752		= caseMap.get(thisRec.Id).Account.Name;				/** Account Name	**/
                            wrapperResult_Feature.dummy.fields.customfield_10753		= thisRec.ContactEmail;								/**	ContactEmail	**/
                            wrapperResult_Feature.dummy.fields.customfield_10754		= thisRec.Plan_Type__c;								/**	Plan Type	**/
                            wrapperResult_Feature.dummy.fields.customfield_10755		= thisRec.GSTN__c;									/**	GSTIN	**/
                            wrapperResult_Feature.dummy.fields.customfield_10756		= caseMap.get(thisRec.Id).Account.Product_Email__c;	/** Account.Product_Email__c	**/
                            wrapperResult_Feature.dummy.fields.customfield_10757		= thisRec.POD_Group__c;								/** POD **/
                            wrapperResult_Feature.dummy.fields.customfield_10758		= caseMap.get(thisRec.Id).Previous_Owner__r.Name;	/**	Prev Owner	**/
                            
                            if( thisRec.Lookup_Issue_Type__c != NULL ) 
                                wrapperResult_Feature.dummy.fields.customfield_10749	= caseMap.get(thisRec.Id).Lookup_Issue_Type__r.Name;
                            if( thisRec.Lookup_Issue_Type1__c != NULL ) 
                                wrapperResult_Feature.dummy.fields.customfield_10749	= caseMap.get(thisRec.Id).Lookup_Issue_Type1__r.Name;
                            if( thisRec.Lookup_Issue_Type_EInv__c != NULL ) 
                                wrapperResult_Feature.dummy.fields.customfield_10749	= caseMap.get(thisRec.Id).Lookup_Issue_Type_EInv__r.Name;
                            
                            wrapperResult_Feature.dummy.fields.customfield_10759		= thisRec.Issue_Type_1__c;							/**	Issue_Type_1__c	**/
                            wrapperResult_Feature.dummy.fields.customfield_10760		= thisRec.Issue_Type_2__c;							/** Issue_Type_2__c	**/
                            wrapperResult_Feature.dummy.fields.customfield_10761		= thisRec.Issue_Type_3__c;							/** Issue_Type_3__c	**/
                            wrapperResult_Feature.dummy.fields.customfield_10762		= thisRec.Issue_Type_4__c;							/**	Issue_Type_4__c	**/
                            wrapperResult_Feature.dummy.fields.customfield_10763		= thisRec.Comments;									/**	Internal Comment	**/
                            wrapperResult_Feature.dummy.fields.customfield_10764		= thisRec.CreatedDate;								/**	Case Created Date	**/
                            wrapperResult_Feature.dummy.fields.customfield_10765		= thisRec.Type;
                            
             
                            wrapperResult_Feature.dummy.fields.customfield_10809		= thisRec.Account_Active_ARR__c;/**	Account ARR	**/
                            wrapperResult_Feature.dummy.fields.customfield_10811		= thisRec.Is_Pre_Sales_Case__c ? 'Yes' : 'No';
                            
                            
                            if(isPostMethod){
                                wrapperResult.dummy.fields.assignee.id				= String.valueOf(mapOfL3TeamAndJIRAProject.get(thisRec.User_Role_Type__c).Assignee__c);	
                            }else{
                                wrapperResult.dummy.fields.assignee.id  = caseMap.get(thisRec.Id).Jira_Assignee__c;
                            }
                            
                            if(caseMap.get(thisRec.Id).EmailMessages.size() >0){
                                if( caseMap.get(thisRec.Id).EmailMessages[0].Jira_Comment_Id__c == NULL ){
                                    
                                    wrapperResult_Feature.mailTrails					= (String)caseMap.get(thisRec.Id).EmailMessages[0].TextBody;
                                    wrapperResult_Feature.emailMessageId				= (String)caseMap.get(thisRec.Id).EmailMessages[0].Id;
                                }
                            }
                            /**	Field For Case Update	**/
                            wrapperResult_Feature.issueId 								= thisRec.JIRA_Issue_Id__c;
                            wrapperResult_Feature.caseId 								= thisRec.Id;
                            
                            if(isPostMethod)
                                wrapperResult_Feature.assigneeName							= String.valueOf(mapOfL3TeamAndJIRAProject.get(thisRec.User_Role_Type__c).Assignee_Name__c);
                       
                            	
                            
                        }
                        /**	FEATURE BLOCK : END	**/
                        
                    } else{
                        isError = TRUE;	/**	No Assigned Project Available	**/
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                }
                
                if(!isError){
                    
                    CTX_JIRAIntegrationQueueable DQ;
                    
                    if(isBug){
                        DQ = new CTX_JIRAIntegrationQueueable(wrapperResult, NULL, TRUE, FALSE, isPostMethod, isPutMethod);
                    } else{
                        DQ = new CTX_JIRAIntegrationQueueable(NULL, wrapperResult_Feature, FALSE, FALSE, isPostMethod, isPutMethod);
                    }
                    
                    System.enqueueJob(DQ);
                }
            }
            
            
            
            /**	After Update: JIRA Issue Id exist	**/
        }
        
    }	/** End of Method fetchCaseDetails()	**/
    
    /**	Wrapper Classes for Salesforce<>JIRA Integration	**/
    Public Class IssueType{
        Public String id;
    }
    
    Public Class Project{
        Public String id;
    }
    
    Public Class Env{
        public string value;
    }
    
    Public Class BugIdentifier{
        public string value;
    }
    
    Public Class Resolution{
        public string name;
        public string description;
    }
    
    Public Class Assignee{
        public string id;
    }
    
    Public Class Priority{
        public string id;
    }
    
    Public Class Status{
        public string name;
        public string id;
    }
    
    Public Class reporter{
        public string id = system.Label.JiraReporter;
    }
    
    Public Class fields{
        
        Public String 											summary; 			/** Subject **/
        Public String 											description;		/** Description **/
        Public CTX_Salesforce_JIRA_FilterResult.IssueType 		issuetype			= new CTX_Salesforce_JIRA_FilterResult.IssueType();	/**	BUG/Task/Story	**/
        Public CTX_Salesforce_JIRA_FilterResult.Project 		project 			= new CTX_Salesforce_JIRA_FilterResult.Project();	/**	Project Details	**/
        Public CTX_Salesforce_JIRA_FilterResult.Priority		priority 			= new CTX_Salesforce_JIRA_FilterResult.Priority();	/**	Priority	**/
        Public CTX_Salesforce_JIRA_FilterResult.reporter		reporter 			= new CTX_Salesforce_JIRA_FilterResult.reporter();	/**	Reporter : Mandatory	**/
        Public CTX_Salesforce_JIRA_FilterResult.Assignee 		assignee 			= new CTX_Salesforce_JIRA_FilterResult.Assignee();
        Public CTX_Salesforce_JIRA_FilterResult.Env 			customfield_10665 	= new CTX_Salesforce_JIRA_FilterResult.Env();		/**	Environment : Mandatory	**/
        Public CTX_Salesforce_JIRA_FilterResult.BugIdentifier 	customfield_10704	= new CTX_Salesforce_JIRA_FilterResult.BugIdentifier();
        Public String 											customfield_10363;	/**	Salesforce Case Number	**/
        Public String 											customfield_10765;	/**	Type	**/
        Public String 											customfield_10750;	/**	Status	**/
        Public String 											customfield_10751;	/**	Sub Status	**/
        Public String 											customfield_10752;	/** Account Name	**/
        Public String 											customfield_10753;	/**	Supplied Email	**/
        Public String 											customfield_10754;	/**	Plan Type	**/
        Public String 											customfield_10755;	/**	GSTIN	**/
        Public String 											customfield_10756;	/** Account.Product_Email__c	**/
        Public String 											customfield_10757;	/** POD/Group	**/
        Public String 											customfield_10758;	/**	Prev Owner	**/
        Public String 											customfield_10749;	/**	Issue_Type__c	**/
        Public String 											customfield_10759;	/**	Issue_Type_1__c	**/
        Public String 											customfield_10760;	/** Issue_Type_2__c	**/
        Public String 											customfield_10761;	/** Issue_Type_3__c	**/
        Public String 											customfield_10762;	/**	Issue_Type_4__c	**/
        Public String											customfield_10763;	/**	Internal Comments	**/
        Public DateTime											customfield_10764;	/**	Created Date	**/
        Public Decimal											customfield_10809;	/**	Account ARR	**/
        Public String											customfield_10811;	/**	Pre Sales	**/

    }
    
    Public Class Dummy{
        public CTX_Salesforce_JIRA_FilterResult.fields 		fields 		= new CTX_Salesforce_JIRA_FilterResult.fields();
    }
    
    Public Class CreateUpdateJIRAIssueWrapper{
        public CTX_Salesforce_JIRA_FilterResult.Dummy	dummy	= new CTX_Salesforce_JIRA_FilterResult.Dummy();
        public string 									issueId;
        public string 									caseId;
        public string 									assigneeName;
        public string 									mailTrails;
        public String 									emailMessageId;
    }
    
    /**	FEATURE BLOCK : START	**/
    Public Class fields_Feature{
        
        Public String 											summary; /** Subject **/
        Public String 											description;	/** Description **/
        Public CTX_Salesforce_JIRA_FilterResult.IssueType 		issuetype			= new CTX_Salesforce_JIRA_FilterResult.IssueType();	/**	BUG/Task/Story	**/
        Public CTX_Salesforce_JIRA_FilterResult.Project 		project 			= new CTX_Salesforce_JIRA_FilterResult.Project();	/**	Project Details	**/
        Public CTX_Salesforce_JIRA_FilterResult.Priority		priority 			= new CTX_Salesforce_JIRA_FilterResult.Priority();	/**	Priority	**/
        Public CTX_Salesforce_JIRA_FilterResult.reporter		reporter 			= new CTX_Salesforce_JIRA_FilterResult.reporter();	/**	Reporter : Mandatory	**/
        Public CTX_Salesforce_JIRA_FilterResult.Assignee 		assignee 			= new CTX_Salesforce_JIRA_FilterResult.Assignee();
        Public String 											customfield_10363;	/**	Salesforce Case Number	**/
        Public String 											customfield_10765;	/**	Type	**/
        Public String 											customfield_10750;	/**	Status	**/
        Public String 											customfield_10751;	/**	Sub Status	**/
        Public String 											customfield_10752;	/** Account Name	**/
        Public String 											customfield_10753;	/**	Supplied Email	**/
        Public String 											customfield_10754;	/**	Plan Type	**/
        Public String 											customfield_10755;	/**	GSTIN	**/
        Public String 											customfield_10756;	/** Account.Product_Email__c	**/
        Public String 											customfield_10757;	/** POD/Group	**/
        Public String 											customfield_10758;	/**	Prev Owner	**/
        Public String 											customfield_10749;	/**	Issue_Type__c	**/
        Public String 											customfield_10759;	/**	Issue_Type_1__c	**/
        Public String 											customfield_10760;	/** Issue_Type_2__c	**/
        Public String 											customfield_10761;	/** Issue_Type_3__c	**/
        Public String 											customfield_10762;	/**	Issue_Type_4__c	**/
        Public String											customfield_10763;	/**	Internal Comments	**/
        Public DateTime											customfield_10764;	/**	Created Date	**/
        Public String											customfield_10811;	/**	Pre Sales	**/
        Public Decimal											customfield_10809;	/**	Account ARR	**/
        /**	**/
    }
    
    Public Class Dummy_Feature{
        public CTX_Salesforce_JIRA_FilterResult.fields_Feature 		fields 		= new CTX_Salesforce_JIRA_FilterResult.fields_Feature();
    }
    
    Public Class CreateUpdateJIRAIssueWrapper_Feature{
        public CTX_Salesforce_JIRA_FilterResult.Dummy_Feature	dummy	= new CTX_Salesforce_JIRA_FilterResult.Dummy_Feature();
        public string 									issueId;
        public string 									caseId;
        public string 									assigneeName;
        public string 									mailTrails;
        public String 									emailMessageId;
    }
    
}	/**	End of Class	**/