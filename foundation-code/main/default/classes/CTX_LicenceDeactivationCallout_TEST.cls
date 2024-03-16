@isTest
public class CTX_LicenceDeactivationCallout_TEST {
	@isTest
    public static void requestCallout_TEST(){
        Test.setMock(HttpCalloutMock.class, new CTX_ProductSyncCalloutMockResponse());
        Test.startTest();
        //CTX_LicenceDeactivationCallout.requestCallout('abcdtestLicenceId');
        Test.stopTest();
    }
}