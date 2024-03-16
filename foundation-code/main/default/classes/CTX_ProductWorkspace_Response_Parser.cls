Public Class CTX_ProductWorkspace_Response_Parser {
    
	public String 						domainName;
	public ExactWorkspaceDetails[] 		exactWorkspaceDetails;
	public SuggestedWorkspaceDetails[] 	suggestedWorkspaceDetails;
	
    Public Class ExactWorkspaceDetails {
		
        Public String	workspaceName;
		Public String 	workspaceAdminFirstName;
		Public String 	workspaceAdminLastName;
		Public String 	workspaceAdminUserExternalId;
		Public String 	workspaceAdminEmail;
		Public String 	workSpaceId;
		Public Boolean 	isDefaultWorkspace;
        Public String 	licenseId;
        Public Boolean 	licenseMatched;
	}
    
    Public Class SuggestedWorkspaceDetails {
        
        Public String	workspaceName;
		Public String 	workspaceAdminFirstName;
		Public String 	workspaceAdminLastName;
		Public String 	workspaceAdminUserExternalId;
		Public String 	workspaceAdminEmail;
		Public String 	workSpaceId;
		Public Boolean 	isDefaultWorkspace;
        Public String 	licenseId;
        Public Boolean 	licenseMatched;
    }
    
    public class LicenseMapWrap {
        Public String 	licenseId;
        public DateTime startDate;
        public DateTime endDate;
    }   
    
}