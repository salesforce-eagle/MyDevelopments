@isTest
public class CTX_ProductSyncByProductLineCallout_TEST {
	
    @isTest
    public static void requestCallout_TEST(){
        Test.setMock(HttpCalloutMock.class, new CTX_ProductSyncCalloutMockResponse());
        Test.startTest();
        CTX_ProductSyncByProductLineCallout.requestCallout();
        Test.stopTest();
    }
    
    @isTest
    public static void responseWrapper_TEST(){
        WrapperCTX_ProductSync_Parse.ProductSFMapping prodPlanMap = new WrapperCTX_ProductSync_Parse.ProductSFMapping();
        prodPlanMap.isCustomPlanAllowed = true;
        prodPlanMap.licensingProductName = 'GST';
        prodPlanMap.productName = 'GST';
        prodPlanMap.sfProductName = 'GST';
        
        WrapperCTX_ProductSync_Parse resp = new WrapperCTX_ProductSync_Parse();
        resp.productSalesforceMappings = new List<WrapperCTX_ProductSync_Parse.ProductSFMapping>{prodPlanMap};
    }
}