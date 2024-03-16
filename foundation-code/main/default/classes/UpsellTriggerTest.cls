@isTest(seeAllData = False)
public class UpsellTriggerTest {
    
	@isTest
    Public static void upsellTest(){
        
        TriggerActivationOrDeactivation__c ta = new TriggerActivationOrDeactivation__c();
        ta.Name='Upsell_Top_up__c';
        ta.Object_API_Name__c = 'Upsell_Top_up__c';
        ta.isActive__c = true;
        insert ta;
        
        Account acc=new Account();
        acc.Name='Test acc';
        acc.PAN__c = 'QWERT2254G';
        acc.Company_Domain_name__c = 'abc.com';
        acc.Master_admin_Email__c = 'abc@abc.com';
        insert acc;
        
        Opportunity opp=new Opportunity();
        opp.Name='Test opp';
        opp.StageName='SQL';
        opp.CloseDate=System.today();
        opp.AccountId=acc.Id;
        insert opp;
    
        Product2 p=new Product2();
        p.Name='Test Prod';
        p.Family='Airline';
        p.IsActive =true;
        p.Family = 'Managed Service';
        p.Formula__c = '1500';
        insert p;
        
        Asset ast= new Asset();
        ast.Name='Test Asset';
        ast.Product2Id = p.id;
        ast.AccountId = acc.id;
        ast.Opportunity__c = opp.Id;
        ast.Price = 200000;
        ast.PurchaseDate = system.today();
        ast.usageEndDate = system.today() + 365;
        insert ast;
                
        Upsell_Top_up__c ups = new Upsell_Top_up__c();
        ups.Name = 'Test Ups';
        ups.Account__c = acc.Id;
        ups.Product__c = p.Id;
        ups.Asset__c = ast.Id;
        ups.Additional_Price__c = 100000;
        ups.Stage__c = 'New Request';
        ups.No_of_B2B_Sales_invoice__c = 10;
        ups.No_of_B2C_Sales_invoice__c = 10;
        ups.No_of_E_way_bill__c = 20;
        ups.No_of_GSTIN__c = 20;
        ups.No_of_GSTIN_verification_credits__c = 20;
        ups.No_of_IRNs__c = 10;
        ups.No_of_PANs__c = 10;
        ups.No_of_purchase_invoice__c = 20;
        ups.No_of_vendors__c = 10;
        ups.No_of_user_IDs__c = 10;
        insert ups;
        
        try{
            ups.Stage__c = 'Finance Approval';
            ups.Approval_Status__c = 'Finance Approval Approved';
            update ups; 
        }Catch(Exception ex){
            System.debug(' Exception on OrderFile Validation \n'+ex.getMessage()+'\n'+ex.getLineNumber());
        }
      
 		Opportunity opp1 =new Opportunity();
        opp1.Name='Test opp';
        opp1.StageName='Closed';
        opp1.CloseDate=System.today();
        opp1.AccountId=acc.Id;
        insert opp1;
        

        
        
    }
}