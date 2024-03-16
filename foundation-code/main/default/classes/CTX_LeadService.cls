/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-27-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@RestResource(urlMapping='/CTX_LeadService')	/** Apex Rest Call : services/apexrest/CTX_LeadService	**/
global with sharing class CTX_LeadService {
    
    @HttpGet
    global static void getRecord(){
        
        Lead thisLead = [ SELECT Id, Name, AnnualRevenue, Email, 
                         Account__c, JSON_Field__c, Business_Type__c, Market_Team__c, Country_of_Origin__c 
                         FROM Lead LIMIT 1 ];
    }
    
    
    @HttpPost
    global static String doPost(Lead myLead){
        
        Map<String, String>		map_UTMFields	= new Map<String, String>{
            'utm_campaign' => 'UTM_Campaign__c', 'utm_medium' => 'UTM_Medium__c', 
                'utm_source' => 'UTM_Source__c', 'utm_content' => 'UTM_Content__c', 'utm_id' => 'UTM_ID__c' };
                    String 		returnString;
        List<Task>				leadTaskList	= new List<Task>();	
        
        if(myLead != NULL){
            system.debug('myLead in XTC_LeadService: '+myLead);
            
            if( myLead.Lead_Source_Details__c != NULL ){
                
                if( myLead.Event_Type__c == 'GCC-contact-sales-form' ){
                    
                    system.debug('GCC Contact Sales Form Block');
                    ApexPages.PageReference ref 	= new ApexPages.PageReference(myLead.Lead_Source_Details__c);
                    Map<String, String> 	params 	= ref.getParameters();
                    
                    if(params != NULL && params.size() > 0){
                        for(String key: params.keySet()) {
                            if(map_UTMFields.containsKey(key)){
                                myLead.put(map_UTMFields.get(key), params.get(key));
                            }
                        }
                    }
                }
                
                if( myLead.Event_Type__c == 'contact-sales-form' ){	
                    
                    /**	Malaysia Lead	**/
                    if( myLead.ISD__c == '+60' ){
                        myLead.Date_Of_Incoming_Lead__c = System.Today();
                        myLead.Communicated_to_Lead__c	= FALSE;
                        myLead.LeadSource				= 'Marketing';
                        myLead.Status					= 'New';
                        myLead.Incoming_Count__c 		= 1;
                        myLead.Country_of_Origin__c		= 'Malaysia';
                        myLead.OwnerId					= '005C5000000JEzvIAG';
                    } else{/**	Other Leads for CA SME Clients	**/
                        myLead.Date_Of_Incoming_Lead__c = System.Today();
                        myLead.Communicated_to_Lead__c	= FALSE;
                        myLead.LeadSource				= 'Marketing';
                        myLead.Status					= 'New';
                        myLead.Incoming_Count__c 		= 1;
                        myLead.Country_of_Origin__c		= 'India';
                        //myLead.OwnerId					= '0052x000003RUfhAAG';
                        myLead.RecordTypeId				= '012C50000004InUIAU';
                        myLead.Business_Type__c 		= 'SME';
                        myLead.Plan_Name__c 			= myLead.Customer_Type__c;
                    }
                }
                /**	Changes related to SF Malaysia Activation : END	**/
            }
            
            /**	Check for Existing Lead and Create Task under It : START	**/
            if(myLead.Email != NULL && myLead.Id == NULL){
                
                system.debug('Lead Non Email Null Block');
                for(
                    Lead thisRec : [ SELECT Id, Email, Lead_Request_Type__c, RecordType.Name,  
                                    Lead_Source_Details__c, Status, Incoming_Count__c, Domain_Name__c,  
                                    UTM_Campaign__c, UTM_Content__c, UTM_ID__c, UTM_Medium__c, UTM_Source__c, 
                                    CreatedDate
                                    FROM Lead WHERE 
                                    Email =: myLead.Email
                                    ORDER BY CreatedDate DESC LIMIT 1 ]
                ){
                    
                    myLead.Id 						= thisRec.Id;
                    myLead.Domain_Name__c 			= thisRec.Email != NULL ? thisRec.Email : thisRec.Email.split('@')[1];
                    myLead.Incoming_Count__c 		= thisRec.Incoming_Count__c != NULL ? thisRec.Incoming_Count__c+1 : 1;
                    myLead.Date_Of_Incoming_Lead__c = System.Today();
                    myLead.Communicated_to_Lead__c	=	FALSE;
                    
                    if(
                        (
                            myLead.UTM_Campaign__c != NULL 						&& 
                            myLead.UTM_Campaign__c != thisRec.UTM_Campaign__c
                        ) 														||
                        (
                            myLead.UTM_Content__c != NULL 						&& 
                            myLead.UTM_Content__c != thisRec.UTM_Content__c
                        ) 														||
                        (
                            myLead.UTM_ID__c != NULL 							&& 
                            myLead.UTM_ID__c != thisRec.UTM_ID__c
                        ) 														||
                        (
                            myLead.UTM_Medium__c != NULL 						&& 
                            myLead.UTM_Medium__c != thisRec.UTM_Medium__c
                        ) 														||
                        (
                            myLead.UTM_Source__c != NULL 						&& 
                            myLead.UTM_Source__c != thisRec.UTM_Source__c
                        )
                        
                    ){
                        
                        Task myTask 		= new Task();
                        myTask.ActivityDate	= System.today();
                        myTask.Subject		= 'UTM variable updated.';
                        myTask.Type			= 'Marketing';
                        myTask.WhoId 		= thisRec.Id;
                        myTask.Description 	= 'Altred Values of UTM Variables: /n'+ 
                            'UTM_Campaign__c: '+thisRec.UTM_Campaign__c+' /n '+
                            'UTM_Content__c: '+thisRec.UTM_Content__c+' /n '+
                            'UTM_ID__c: '+thisRec.UTM_ID__c+' /n '+
                            'UTM_Medium__c: '+thisRec.UTM_Medium__c+' /n '+
                            'UTM_Source__c: '+thisRec.UTM_Source__c+' /n ';
                        
                        leadTaskList.add(myTask);
                    }
                }
            } else{
                
                system.debug('New GCC Lead Block');
                myLead.Date_Of_Incoming_Lead__c = System.Today();
                myLead.Communicated_to_Lead__c	= FALSE;
                myLead.LeadSource				= 'Marketing';
                myLead.Status					= 'New';
                myLead.Incoming_Count__c 		= 1;
                myLead.Country_of_Origin__c		= 'GCC';
            }
            
            
        } else{
            returnString = 'Incorrect data provided - Something went wrong.';
            System.debug('CTX_LeadService - POST Method - Incorrect data provided - Something went wrong.');
        }
        
        System.debug('myLead->'+myLead);
        
        /**	Do DML on the incoming Lead : START	**/
        try{
            upsert myLead;//database.upsert(myLead, FALSE);
            returnString = 'Lead Upserted Success.';
            if(leadTaskList.size() > 0 ){
                try{
                    insert leadTaskList;
                } catch(Exception ex){
                    returnString = 'Error - Lead created Successfully '+myLead.Id+', But have an issue with Task Creation.'+ex.getMessage();
                    system.debug('CTX_LeadService - POST Method : DML Exception: '+ex.getMessage());
                }
            }
        } catch(Exception ex){
            returnString = 'Error - DML Exception on Lead at Salesforce end. '+ex.getMessage();
            system.debug('CTX_LeadService - POST Method : DML Exception: '+ex.getMessage());
        }
        /**	Do DML on the incoming Lead : END	**/
        
        return returnString;
    }
    
    
}