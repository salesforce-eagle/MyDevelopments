/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-16-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CTX_ClearResourceConstraintsClass {
    
    public static Map<String, Integer> identityResourceConstraintsForLicensing( String resourceJSON ){
        
        Map<String, Integer> resourceConstraintsWithValuesMap	= new Map<String, Integer>();
        /**	String resourceJSON  =	' {"No_of_MSME_API__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_TDS_206_sync_API__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_PAN_Verification_with_Father_Name__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_PAN_verification_API__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_PAN_to_GSTIN_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_Of_PAN_OCR_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_PAN_verification_detailed_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_GSTIN_verification_credits__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_GSTIN_SEARCH_BY_NAME_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_GSTIN_FILING_CREDITS_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_Of_GST_ADVANCED_PLUS_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_Of_GST_ADVANCED_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_EPFO_UAN_FETCH_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_EPFO_UAN_DETAILS_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_EPFO_UAN_AUTH_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"EPFO_ESTABLISHMENT_DETAILED_API_credit__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"EPFO_ESTABLISHMENT_BASIC_API_credit__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"EPFO_ESTABLISHMENT_ADVANCED_API_credit__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_DRIVING_LICENSE_DETAILED_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_CUSTOMER_IDENTITY_FETCH_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_Bank_verification_API__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_PAN_SIMPLE_DETAILS_APIs_No_of_FS__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_FSSAI_VERIFICATION_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_PAN_VERIFICATION_BASIC_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_GST_ANALYTICS_AUTH_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_GST_ANALYTICS_DETAILS_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_INTERNATIONAL_BUSINESS_NAME_SEARC__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_LEGAL_NAME_PAN_FETCH_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_GST_OWNERSHIP_VERIFICATION_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_AADHAAR_VERIFICATION_DIGILOCKER_A__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_COMPANY_FINANCIALS_DETAILS_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_UPI_VERIFICATION_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_UPI_FETCH_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_UPI_QR_GENERATION_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_COMPANY_DETAILS_FULL_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0},"No_of_EPFO_UAN_VERIFICATION_APIs__c":{"count":0,"perUnitSellPrice":0,"perUnitListPrice":0,"perUnitCostPrice":0,"sellPrice":0,"listPrice":0,"costPrice":0}} '	**/
        
        if( resourceJSON != NULL ){
            
            system.debug('resourceJSON: '+resourceJSON);
            
            List<Object> resources = (List<Object>)JSON.deserializeUntyped(resourceJSON);
            
            for( Object thisRec : resources ){
                
                Map<String, Object> deserilizeString	= (Map<String, Object>)thisRec;
                system.debug('deserilizeString : '+deserilizeString);
                system.debug('deserilizeString keySet in identityResourceConstraintsForLicensing: '+deserilizeString.keySet());
                for( String thisSTR : deserilizeString.keySet() ){
                    system.debug('thisSTR : thisSTR : '+thisSTR);
                    // Map<String, Object> getResourceDetailsMap = (Map<String, Object>)deserilizeString.get(thisSTR);
                    string va = thisSTR.trim();
                    system.debug(' deserilizeString: deserilizeString: '+deserilizeString.get(thisSTR) );
                    Map<String, Object> responseCheck = (Map<String, Object>)deserilizeString.get(thisSTR);
                    system.debug('responseCheck : responseCheck : '+responseCheck);
                    resourceConstraintsWithValuesMap.put( va, (Integer)responseCheck.get('count')); 
                }
            }
            
            system.debug('resourceConstraintsWithValuesMap: '+resourceConstraintsWithValuesMap);
        }
        
        return resourceConstraintsWithValuesMap;
    }
    
    Public Class ReturnWrapper{
        Public String 	identityResource;
        Public Decimal 	totalSellPrice 		= 0;
        Public Decimal 	totalListPrice 		= 0;
        Public Decimal 	totalCostPrice 		= 0;
    }
    
    public static String identityResourceConstraints( String jsonString, OpportunityLineItem oli ){
        
        Map<String, Object> deserilizeString = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        system.debug('deserilizeString : '+deserilizeString);
        
        for( String thisSTR : deserilizeString.keySet() ){
            Map<String, Object> getResourceDetailsMap = (Map<String, Object>)deserilizeString.get(thisSTR);
            
            getResourceDetailsMap.put( 
                'count', 
                oli.getSObject('Related_QLI__r').get(thisSTR) != NULL ? Integer.valueOf( oli.getSObject('Related_QLI__r').get(thisSTR) ) : 0 
            ); 
        }
        system.debug('deserilizeString: '+deserilizeString);
        
        return JSON.serialize(deserilizeString);
    }
    
    
    public static ReturnWrapper identityResourceConstraintsForQuoteLineItem( String resourceJSON ){ 
        
        /**	string jsonString = ' [{"No_of_EPFO_UAN_VERIFICATION_APIs__c":{"count":98,"perUnitListPrice":10,"perUnitSellPrice":9,"perUnitCostPrice":9}},{" No_of_COMPANY_DETAILS_FULL_APIs__c":{"count":8765,"perUnitListPrice":87,"perUnitSellPrice":88,"perUnitCostPrice":988}},{" No_of_UPI_QR_GENERATION_APIs__c":{"count":99,"perUnitListPrice":98,"perUnitSellPrice":99,"perUnitCostPrice":99}},{" No_of_UPI_FETCH_APIs__c":{"count":988,"perUnitListPrice":99,"perUnitSellPrice":9,"perUnitCostPrice":99}},{" No_of_UPI_VERIFICATION_APIs__c":{"count":87,"perUnitListPrice":88,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_COMPANY_FINANCIALS_DETAILS_APIs__c":{"count":23,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_AADHAAR_VERIFICATION_DIGILOCKER_A__c":{"count":98,"perUnitListPrice":99,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GST_OWNERSHIP_VERIFICATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_LEGAL_NAME_PAN_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_INTERNATIONAL_BUSINESS_NAME_SEARC__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GST_ANALYTICS_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GST_ANALYTICS_AUTH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_FSSAI_VERIFICATION_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_SIMPLE_DETAILS_APIs_No_of_FS__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_VERIFICATION_BASIC_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_Bank_verification_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_CUSTOMER_IDENTITY_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_DRIVING_LICENSE_DETAILED_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" EPFO_ESTABLISHMENT_ADVANCED_API_credit__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" EPFO_ESTABLISHMENT_BASIC_API_credit__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" EPFO_ESTABLISHMENT_DETAILED_API_credit__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_AUTH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_DETAILS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_EPFO_UAN_FETCH_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_Of_GST_ADVANCED_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_Of_GST_ADVANCED_PLUS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSTIN_FILING_CREDITS_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSTIN_SEARCH_BY_NAME_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_GSTIN_verification_credits__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_verification_detailed_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_Of_PAN_OCR_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_to_GSTIN_APIs__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_verification_API__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_PAN_Verification_with_Father_Name__c":{"count":0,"perUnitListPrice":0,"perUnitSellPrice":0,"perUnitCostPrice":0}},{" No_of_TDS_206_sync_API__c":{"count":88,"perUnitListPrice":34535,"perUnitSellPrice":4375,"perUnitCostPrice":0}},{" No_of_MSME_API__c":{"count":893,"perUnitListPrice":98,"perUnitSellPrice":87,"perUnitCostPrice":87}}] ';	**/
        
        ReturnWrapper 			thisReturn 							= new ReturnWrapper();
        Map<String, Decimal> 	resourceConstraintsWithValuesMap	= new Map<String, Decimal>(); 
        List<Object> 			identityFieldDetails				= (List<Object>)JSON.deserializeUntyped(resourceJSON);
        
        for( Object thisRec : identityFieldDetails ){
            Map<String, Object> detailedRecords = (Map<String, Object>)thisRec;
            
            Decimal totalSellPrice = 0;
            Decimal totalListPrice = 0;
            Decimal totalCostPrice = 0;
            
            for( String thisKey : detailedRecords.keySet() ){
                system.debug('thisKey'+thisKey);
                Map<String, Object> granularDetails = (Map<String, Object>)detailedRecords.get(thisKey);
                
                thisReturn.totalSellPrice += (Decimal)granularDetails.get('count')*(Decimal)granularDetails.get('perUnitSellPrice');
                thisReturn.totalListPrice += (Decimal)granularDetails.get('count')*(Decimal)granularDetails.get('perUnitListPrice');
                thisReturn.totalCostPrice += (Decimal)granularDetails.get('count')*(Decimal)granularDetails.get('perUnitCostPrice');
                system.debug('thisReturn.totalSellPrice'+thisReturn.totalSellPrice);
                system.debug('thisReturn.totalListPrice'+thisReturn.totalListPrice);
                system.debug('(Decimal)granularDetails.get count'+(Decimal)granularDetails.get('count'));
                system.debug('(Decimal)granularDetails.get perUnitSellPrice'+(Decimal)granularDetails.get('perUnitSellPrice'));
                system.debug('(Decimal)granularDetails.get perUnitListPrice'+(Decimal)granularDetails.get('perUnitListPrice'));
                system.debug('(Integer)granularDetails.get count'+(Decimal)granularDetails.get('count'));
                
                resourceConstraintsWithValuesMap.put( thisKey, (Decimal)granularDetails.get('count') ); 
            }
        }
        system.debug('resourceConstraintsWithValuesMap'+resourceConstraintsWithValuesMap);
        
        thisReturn.identityResource =  JSON.serialize(resourceConstraintsWithValuesMap);
        
        
        return thisReturn;
    }
    
}