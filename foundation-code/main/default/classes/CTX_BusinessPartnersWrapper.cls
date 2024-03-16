public class CTX_BusinessPartnersWrapper {
    
    Public String 					CardCode;
    Public String 					CardName;
    Public String 					CardType = 'cCustomer';
    Public List<BillingPAN> 		BPFiscalTaxIDCollection = new List<BillingPAN>();
    Public List<AdditionalGSTIN> 	BPAddresses = new List<AdditionalGSTIN>();
    Public List<POCs>				ContactEmployees = new List<POCs>();
    Public String 					PayTermsGrpCode;
    Public String 					U_CINNo;
    Public String 					U_GroupEntity;
    Public String 					U_Customer;
    Public String 					U_KAM;
    Public String 					U_CSM;
    
    
    Public Class BillingPAN{
        Public String AddrType;	/** 'bo_ShipTo' / 	**/
        Public String Address;
        Public String CNAECode;
        Public String TaxId0;
        Public String TaxId1;
        Public String TaxId2;
        Public String TaxId3;
        Public String TaxId4;
        Public String TaxId5;
        Public String TaxId6;
        Public String TaxId7;
        Public String TaxId8;
        Public String TaxId9;
        Public String TaxId10;
        Public String TaxId11;
        Public String TaxId12;	/*	CardCode	*/
        Public String TaxId13;
        Public String AToRetrNFe;
        //Public String U_PANVal;
        //Public String U_PANErrorMsg;
    }
   
    Public Class AdditionalGSTIN{
        Public STring GSTIN;	/**	Additional_GSTIN__c.Name	**/
        Public STring GstType =  'gstRegularTDSISD';
        Public String BPCode;	/**	CardCode	**/
        Public String FederalTaxID;	/**	BPFiscalTaxID.TaxId0	**/
        
        Public String BuildingFloorRoom;
        Public String StreetNo;
        Public String Street;
        Public String Block;
        Public String ZipCode;
        Public String City;
        Public String State;
        Public String County;
        Public String Country = 'IN';
        Public String AddressType = 'bo_BillTo';	/**	bo_BillTo/bo_ShipTo	**/
        Public String AddressName;	/**	STATE	**/
        Public String AddressName2;	/**	 Additional_GSTIN__c.Address__c should be splited into multi part for Address	**/
        Public String AddressName3;	/**	 Additional_GSTIN__c.Address__c should be splited into multi part for Address	**/
        Public String TypeOfAddress;
        
        Public String CreateDate;
        Public String CreateTime;
        
        Public String TaxCode;
        Public String RowNum;
        Public String GlobalLocationNumber;
        Public String Nationality;
        Public String TaxOffice;
        Public String MYFType;
        Public String TaasEnabled;
        Public String U_UTL_ST_ThLegName;
        Public String U_UTL_ST_ThTrdName;
        Public String U_SEZ_GST;
        Public String U_GSTStatus;
        Public String U_TaxPayer;
        Public String U_GSTErrorMsg;
        //Public STring U_CINNo;
        //Public STring U_COMPANYTYPE = 'COMPANY';
        Public STring U_CmpType;
        
    }
    
    public Class POCs{
        Public String CardCode;/**	CardCode	**/
        Public String FirstName;
        Public String MiddleName;
        Public String LastName;
        Public String Name;
        Public String Position;
        Public String Address;
        Public String Phone1;
        Public String Phone2;
        Public String MobilePhone;// Contact.Phone
        Public String Fax;
        Public String E_Mail;// Contact.Email
        Public String Pager;
        Public String Remarks1;// Contact.Department
        Public String Remarks2; // Contact.Designation
        Public String Password;
        Public String InternalCode; // Contact.Id
        Public String PlaceOfBirth;
        Public String DateOfBirth;
        Public String Gender;//gt_Male
        Public String Profession;
        Public String Title;
        Public String CityOfBirth;
        Public String Active;// tYES
        Public String EmailGroupCode;
        Public String BlockSendingMarketingContent;
    }


}