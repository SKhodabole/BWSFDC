/*
	Apex class having test methods for BatchAccountSalesDataRollup
*/
@isTest(SeeAllData = false)
private class BatchAccountSalesDataRollupTest {
public static User managerUser1;
    @testSetup 
    public static void setupmethod(){
	 Profile p = [select id from profile where name='System Administrator'];
        
     String name = 'A-test1';
     managerUser1 = new User(Alias = name, Email = name + '@asdfg.junk', EmailEncodingKey = 'UTF-8',
            FirstName = 'Test', lastname = name, LanguageLocaleKey = 'en_US', LocaleSIDKey = 'en_US',
            Profileid = p.Id, TimezoneSIDKey = 'America/Los_Angeles', Username = name + '@asdfg.junk',EmployeeNumber = '101');
        
        insert managerUser1;        
    }
	private static testMethod void startTest(){
User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
			//create Parent Account
	        Account acc1 = new Account();
	        acc1.Name='Test Acc';
	        acc1.Industry = 'Business Services';
	        acc1.Type = 'Parent';
        acc1.recordTypeId = recordTypeId;
        acc1.OwnerId = managerUser.Id;
	        insert acc1;

        
        //create Account
	        Account acc = new Account();
	        acc.Name='Test Acc';
	        acc.Industry = 'Business Services';
	        acc.Type = 'Customer';
        	acc.ParentId = acc1.id;
        acc.recordTypeId = recordTypeId;
        acc.OwnerId = managerUser.Id;
	        insert acc;

	        //create sales data
	        List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
	        Sales_Data__c sd = new Sales_Data__c();
	        sd.Year__c = '2014';
	        sd.Period__c = 12;
	        sd.Actual_Amount__c = 100;
	        sd.Account__c = acc.id;
	        sdlist.add(sd);
	        
	        Sales_Data__c sd1 = new Sales_Data__c();
	        sd1.Year__c = '2017';
	        sd1.Period__c = 2;
	        sd1.Actual_Amount__c = 100;
	        sd1.Account__c = acc.id;
	        sdlist.add(sd1);
	        
	        Sales_Data__c sd2 = new Sales_Data__c();
	        sd2.Year__c = String.valueOf(Date.today().Year());
	        sd2.Period__c = 10;
	        sd2.Actual_Amount__c = 100;
	        sd2.Account__c = acc.id;
	        sdlist.add(sd2);
	        
	        Sales_Data__c sd3 = new Sales_Data__c();
	        sd3.Year__c = '2011';
	        sd3.Period__c = 10;
	        sd3.Actual_Amount__c = 100;
	        sd3.Account__c = acc.id;
	        sdlist.add(sd3);
	        
	        Sales_Data__c sd4 = new Sales_Data__c();
	        sd4.Year__c = '2013';
	        sd4.Period__c = 10;
	        sd4.Actual_Amount__c = 100;
	        sd4.Account__c = acc.id;
	        sdlist.add(sd4);
	        
	        //Insert List of Sales Data
	        insert sdlist;
			
			//start test
			test.startTest();
				
				//Execute Batch
				BatchAccountSalesDataRollup.runAccountSalesDataRollupForAccounts( new Set<ID>{acc.Id} );
			
			//Test Stop
			test.stopTest();
			
			//Query Accounts
			List<Account> accs = [Select Id,Last_Modified_CurrYBudget__c,X2014_Sales__c,Previous_2Last_12Mo_Sales__c from Account where Name = 'Test Acc'];
			
			//Assert
			/*system.assertEquals(100,accs[0].X2014_Sales__c);
			system.assertEquals(100,accs[0].Previous_2Last_12Mo_Sales__c);
			system.assert(accs[0].Last_Modified_CurrYBudget__c != null);*/
	}
private static testMethod void startTest1(){
User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
			//create Account
	        Account acc = new Account();
	        acc.Name='Test Acc';
	        acc.Industry = 'Business Services';
	        acc.Type = 'Prospect';
        acc.recordTypeId = recordTypeId;
        acc.OwnerId = managerUser.Id;
	        insert acc;

	        //create sales data
	        List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
	        Sales_Data__c sd = new Sales_Data__c();
	        sd.Year__c = '2012';
	        sd.Period__c = 2;
	        sd.Actual_Amount__c = 100;
	        sd.Account__c = acc.id;
	        sdlist.add(sd);
	        
	        
	        Sales_Data__c sd1 = new Sales_Data__c();
	        sd1.Year__c = '2014';
	        sd1.Period__c = 2;
	        sd1.Actual_Amount__c = 100;
	        sd1.Account__c = acc.id;
	        sdlist.add(sd1);
	        
			
			Sales_Data__c sd2 = new Sales_Data__c();
	        sd2.Year__c = String.valueOf(Date.today().Year()-1);
	        sd2.Period__c = 2;
	        sd2.Actual_Amount__c = 100;
	        sd2.Account__c = acc.id;
	        sdlist.add(sd2);
	        
	        Sales_Data__c sd3 = new Sales_Data__c();
	        sd3.Year__c = String.valueOf(Date.today().Year());
	        sd3.Period__c = Date.today().Month();
	        sd3.Actual_Amount__c = 100;
	        sd3.Budget_Amount__c =1000;
	        sd3.Forecast_Amount__c =100;
	        sd3.GMDollars__c = 1000;
	        sd3.Account__c = acc.id;
	        sdlist.add(sd3);
	        
	        //Insert list of sales data
	        insert sdlist;
	        
	        //Test Start 
			test.startTest();
			
			//Execute Batch
			BatchAccountSalesDataRollup.runAccountSalesDataRollupForAccounts( new Set<ID>{acc.Id} );
			
			//Test stop
			test.stopTest();
			
			//List of Account
			List<Account> accs = [Select Id,X2014_Sales__c,Current_Year_Budget__c,BOY_Forecast__c,Prior_YTD_Sales__c,PY_Budget__c,NY_Budget__c,NY_Forecast__c,Current_YTD_Budget__c,Current_YTD_Sales__c,YTD_Forecast__c,YTD_GM__c,X2012_Sales__c,Previous_2Last_12Mo_Sales__c from Account where Name = 'Test Acc'];
			
			//Assert
			/*system.assertEquals(1000,accs[0].Current_Year_Budget__c);
			system.assertEquals(100,accs[0].BOY_Forecast__c);
			system.assertEquals(100,accs[0].Prior_YTD_Sales__c);
			system.assertEquals(100,accs[0].X2012_Sales__c);
			system.assertEquals(100,accs[0].X2014_Sales__c);*/
			
	}
}