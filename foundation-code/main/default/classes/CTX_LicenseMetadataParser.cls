public class CTX_LicenseMetadataParser {
    
    public static LicenseWrapper convertLicenseDetails( String licenselog ){
        
        //String licenselog = '{"licenseId":"02f035e6-f127-48d5-9fa8-0bcdf65a6ab2","plan":{"metadata":{"name":"ClearGST - Free Trial","description":"ClearGST - Free Trial","bannerText":"NA"},"planTier":"TRIAL","resourceConstraints":[{"updatedAt":"2021-12-07 12:39:24.370","createdAt":"2021-10-29 14:01:45.860","createdBy":null,"updatedBy":null,"resource":"PAN_ADDITION","constraintType":"THRESHOLD","threshold":200,"topupUpperLimit":null,"usage":0,"usageWithinConstraint":true,"isUsageTimeBound":false,"eligibleForNotification":false,"resourceConstraintId":"3e74358a-4b7f-4d77-8578-cb6deb62fee6","metadata":{"title":"PANs allowed","resourceTitle":"PANs allowed","displayText":"PANs allowed","displayPriority":0,"showOnSummaryPage":false,"category":"FEATURE","categoryDisplayText":"Features","categoryDisplayPriority":7},"usageRuleResult":null},{"updatedAt":"2021-12-07 12:39:24.370","createdAt":"2021-10-29 14:01:45.860","createdBy":null,"updatedBy":null,"resource":"PAN_ADDITION","constraintType":"THRESHOLD","threshold":200,"topupUpperLimit":null,"usage":0,"usageWithinConstraint":true,"isUsageTimeBound":false,"eligibleForNotification":false,"resourceConstraintId":"3e74358a-4b7f-4d77-8578-cb6deb62fee6","metadata":{"title":"PANs allowed","resourceTitle":"PANs allowed","displayText":"PANs allowed","displayPriority":0,"showOnSummaryPage":false,"category":"FEATURE","categoryDisplayText":"Features","categoryDisplayPriority":7},"usageRuleResult":null}]},"status":"ACTIVE","isTrial":true,"isExpired":true,"subStatus":"EXPIRED"}';
        LicenseWrapper returnWrapper = new LicenseWrapper();
        
        if( 
            licenselog != NULL && 
            licenselog != '' && 
            String.isNotBlank(licenselog) 
        ){
            Map<String, Object> licenseDetails = (Map<String, Object>)JSON.deserializeUntyped(licenselog);
            System.debug('##licenseDetails: '+licenseDetails);
            //for( String thisKey : licenseDetails.keySet() ){
                returnWrapper.licenseId 		= (String)licenseDetails.get('licenseId');
                Map<String, Object> planDetails = (Map<String, Object>)licenseDetails.get('plan');
                
                //for( String thisPlan : planDetails.keySet() ){
                    
                    Map<String, Object>	planMetadata 			= (Map<String, Object>)planDetails.get('metadata');
                    List<Object> 		planResourceConstraints = (List<Object>)planDetails.get('resourceConstraints');
                    
                    returnWrapper.planTier	= (String)planDetails.get('planTier');
                    returnWrapper.planName	= (String)planMetadata.get('name');
                    
                    for( object thisResource : planResourceConstraints ){
                        Map<String, Object> resourceMap = (Map<String, Object>)thisResource;
                        if( resourceMap.get('constraintType') == 'THRESHOLD' ){
                            returnWrapper.usageMap.put( (String)resourceMap.get('resource'), (Integer)resourceMap.get('usage') );
                        }
                    }
               // }
            //}
        }
        
        system.debug('###returnWrapper: '+returnWrapper);
        return returnWrapper;
    }
    
    Public Class LicenseWrapper{
        Public String 					licenseId;
        Public String 					planTier;
        Public String 					planName;
        Public Map<String, Integer>	usageMap = new Map<String, Integer>();
    }
    
}