public class CTX_SalesContractRequestWrapper {
    public string 			U_CardCode;
   	public string 			U_OpporType;
    public string 			U_NumAtCard;
    public string 			U_CardName;
    public string 			Remark;
    public string 			U_DocDate;
    public string 			U_StartDate;
    public string 			U_ShipToCode;
    public string 			U_BillToCode;
    public string 			U_BillAddress;
    public string 			U_ShipAddress;
    public string			U_BranchID = '1';
    public string			U_TaxApply = 'S';
    public string			U_TaxState;
    public string			U_GstNum;
    public List<U_AC_RDR1>	AC_RDR1Collection = new List<U_AC_RDR1>();
    
    public class U_AC_RDR1 {
        public string 	U_ItemCode;
        public string 	U_LineType;
        public string 	U_PayTerms;
        public string 	U_AssetID;
        public Decimal 	U_Price;
        public string 	U_StartDate;
        public string 	U_EndDate;
        public string 	U_BillingID;
        public string 	U_Terms 		= '1';
    }
    
    
}