public class CTX_LoggerImplementation {
    
    public static Logger__c createLoggerInstance(
        String 			errorsMessage, 
        String 		    classId, 
        String 			className, 
        String 			methodName, 
        String 			issueType,
        String		    recordId,
        String			objectName
    ){
        
        return new Logger__c(
            Apex_Class__c 		= className,
            Error_Message__c 	= errorsMessage, 
            Error_Type__c 		= issueType,
            Method_Name__c 		= methodName,
           // Parent_Record__c 	= classId,
            Record_Id__c		= (String)recordId,
            Object_Name__c 		= objectName
        );
        
    }
}