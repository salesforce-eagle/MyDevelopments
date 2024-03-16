@isTest
public class GSTINValidationHelperForOpportunityTest {
    
     @isTest
     public static void opptestForReceivable(){
        
        Profile pr = [SELECT Id FROM Profile WHERE Name='Standard User' Limit 1]; 
        
       // User preSaleOwner = [SELECT Id FROM User WHERE Name = 'Ankit Singhvi' Limit 1];
        
        User testUser = new User(Alias = 'standt', Email='standarduser@receivabletestorg1.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = pr.Id, 
                                 TimeZoneSidKey='Asia/Kolkata', UserName='standarduser2121@receivabletestorg1.com');
        insert testUser;
        
        
        Account a1=new Account();
        a1.Name='Receivable test validation';
        a1.PAN__c = 'CUGPM4227R';
        //			HGSDR2254G
        //a1.Company_Domain_name__c = 'cleartax.com';
        a1.Master_admin_Email__c = 'abc@cleartax.com';
       // insert a1;
        try{
            System.runAs(testUser){
                insert a1;
            }
        }
        catch(exception e){
            system.debug('error in creating opportunity'+e);
        }
        
        Receivables__c  r1 = new Receivables__c ();
        r1.Name = 'Demo Receivables';
        r1.CT_Billing_Entity__c = 'Defmacro';
        r1.CurrencyIsoCode = 'INR';
        r1.PAN_TIN__c = 'CUGPM4227R';
        r1.Account__c = a1.id;
        r1.Name_of_the_entity__c = 'Test class Receivable';
         
        
       // insert r1;
        try{
            System.runAs(testUser){
                insert r1;
            }
        }
        catch(exception e){
            system.debug('error in creating opportunity'+e);
        }
        
        Opportunity opp1=new Opportunity();
        opp1.Name='Demo Receivables oppty';
        opp1.StageName='SQL';
        opp1.CloseDate=System.today();
        opp1.AccountId=a1.Id;
        opp1.OwnerId = testUser.id;
        opp1.Order_Form_Required__c = 'Yes';
        //opp1.ForecastCategory = 'Pipeline';
        opp1.ClearTax_Billing_Entity__c = 'Defmacro';
        opp1.Forecast_Amount__c = 100;
        opp1.Presales_Resource__c = 'Shailja Sood';
        opp1.Product__c = 'Airline Credit';
        opp1.StageName = 'SQL';
        opp1.Billing_GST__c = '12CUGPM4227R54321';
        try{
            System.runAs(testUser){
                insert opp1;
            }
        }
        catch(exception e){
            system.debug('error in creating opportunity'+e);
        }
        
        Receivables__c receiv = [SELECT id,PAN_TIN__c FROM Receivables__c WHERE Id =:r1.Id];
        Opportunity opp = [SELECT id,Billing_GST__c FROM Opportunity WHERE Id =:opp1.Id];
        
        System.debug('opp id'+opp.id);
		System.assertEquals(receiv.PAN_TIN__c, opp.Billing_GST__c.substring(2,12));
        
    }
}