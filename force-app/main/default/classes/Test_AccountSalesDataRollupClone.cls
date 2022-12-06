@isTest
private class Test_AccountSalesDataRollupClone {
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
    static testMethod void myUnitTest() {
		User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
			//create Account
	        Account acc = new Account();
	        acc.Name='Test Acc';
	        acc.Industry = 'Business Services';
	        acc.Type = 'Customer';
        	acc.RecordTypeId = recordTypeId;
        	acc.OwnerId = managerUser.Id;
	        insert acc;

	        //create List of sales data
	        List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
	        
	        Sales_Data__c sd = new Sales_Data__c();
	        sd.Year__c = '2013';
	        sd.Period__c = 2;
	        sd.Actual_Amount__c = 100;
	        sd.Account__c = acc.id;
	        sdlist.add(sd);
	        
	        Sales_Data__c sd1 = new Sales_Data__c();
	        sd1.Year__c = '2015';
	        sd1.Period__c = 2;
	        sd1.Actual_Amount__c = 100;
	        sd1.Account__c = acc.id;
	        sdlist.add(sd1);
			
			Sales_Data__c sd2 = new Sales_Data__c();
	        sd2.Year__c = '2017';
	        sd2.Period__c = 2;
	        sd2.Actual_Amount__c = 100;
	        sd2.Account__c = acc.id;
	        sdlist.add(sd2);
	        
	        //Insert Sales data records
			insert sdlist;
			
			//Test Start here
			Test.startTest();
			
		//	AccountSalesDataRollupClone.executeCal = true;
			
			//Call batch method
			AccountSalesDataRollupClone controller = new AccountSalesDataRollupClone();
			controller.calcualteAccountSalesDataRollup( sdlist );
			
			//Test stop here
			Test.stopTest();
			
			List<Account> accs = [Select Id,X2014_Sales__c,X2017_Sales__c,X2015_Sales__c,X2013_Sales__c,Previous_2Last_12Mo_Sales__c from Account where Name = 'Test Acc'];
			
			//Assert
			
    }
    
    //Test method
    
    static testMethod void myUnitTest1() {
		User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
			//create Account
	        Account acc = new Account();
	        acc.Name='Test Acc';
	        acc.Industry = 'Business Services';
	        acc.Type = 'Customer';
        	acc.RecordTypeId = recordTypeId;
        	acc.OwnerId = managerUser.Id;
	        insert acc;

	        //create List of sales data
	        List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
	        
	        Sales_Data__c sd = new Sales_Data__c();
	        sd.Actual_Amount__c = 100;
	        sd.Account__c = acc.id;
	        sdlist.add(sd);
	        
	        Sales_Data__c sd1 = new Sales_Data__c();
	        sd1.Year__c = '2015';
	        sd1.Period__c = 3;
	        sd1.Actual_Amount__c = 100;
	        sd1.Account__c = acc.id;
	        sdlist.add(sd1);
	        
	         Sales_Data__c sd2 = new Sales_Data__c();
	        sd2.Year__c = '2015';
	        sd2.Period__c = 4;
	        sd2.Actual_Amount__c = 100;
	        sd2.Account__c = acc.id;
	        sdlist.add(sd2);
			
			Sales_Data__c sd3 = new Sales_Data__c();
	        sd3.Year__c = '2014';
	        sd3.Period__c = 10;
	        sd3.Actual_Amount__c = 100;
	        sd3.Account__c = acc.id;
	        sdlist.add(sd3);
	        
	        Sales_Data__c sd4 = new Sales_Data__c();
	        sd4.Year__c = '2014';
	        sd4.Period__c = 9;
	        sd4.Actual_Amount__c = 100;
	        sd4.Account__c = acc.id;
	        sdlist.add(sd4);
	        
	        //Insert Sales data records
			insert sdlist;
			
			//Test Start here
			Test.startTest();
			
			//AccountSalesDataRollupClone.executeCal = true;
			
			//Call batch method
			AccountSalesDataRollupClone controller = new AccountSalesDataRollupClone();
			controller.calcualteAccountSalesDataRollup( sdlist );
			
			//Test stop here
			Test.stopTest();
			
			List<Account> accs = [Select Id,X2014_Sales__c,X2017_Sales__c,X2015_Sales__c,X2013_Sales__c,Previous_2Last_12Mo_Sales__c from Account where Name = 'Test Acc'];
			
			//Assert
    }
    
    //Test method
    
    static testMethod void myUnitTest2() {
			User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
			//create Account
	        Account acc = new Account();
	        acc.Name='Test Acc';
	        acc.Industry = 'Business Services';
	        acc.Type = 'Customer';
        	acc.RecordTypeId = recordTypeId;
        	acc.OwnerId = managerUser.Id;
	        insert acc;

	        //create List of sales data
	        List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
	        
	        Sales_Data__c sd = new Sales_Data__c();
	        sd.Actual_Amount__c = 100;
	        sd.Account__c = acc.id;
	        sdlist.add(sd);
	        
	        Sales_Data__c sd1 = new Sales_Data__c();
	        sd1.Year__c = String.valueOf(Date.Today().Year());
	        sd1.Period__c = date.today().month() == 12 ? 12 : date.today().month()+1;
	        sd1.Actual_Amount__c = 100;
	        sd1.Account__c = acc.id;
	        sd1.Forecast_Amount__c = 1000;
	        sdlist.add(sd1);
	        
	         Sales_Data__c sd2 = new Sales_Data__c();
	        sd2.Year__c = String.valueOf(Date.Today().Year()-1);
	        sd2.Period__c = date.today().month() == 1 ? 1 : date.today().month()-1;
	        sd2.Actual_Amount__c = 100;
	        sd2.Account__c = acc.id;
	        sdlist.add(sd2);
			
			Sales_Data__c sd3 = new Sales_Data__c();
	        sd1.Year__c = String.valueOf(Date.Today().Year());
	        sd1.Period__c = date.today().month() == 12 ? 12 : date.today().month()+1;
	        sd3.Actual_Amount__c = 100;
	        sd3.Account__c = acc.id;
	        sdlist.add(sd3);
	        
	        Sales_Data__c sd4 = new Sales_Data__c();
	       	sd1.Year__c = String.valueOf(Date.Today().Year());
	        sd1.Period__c = date.today().month() == 12 ? 12 : date.today().month()-1;
	        sd4.Actual_Amount__c = 100;
	        sd4.Account__c = acc.id;
	        sd4.Forecast_Amount__c = 1000;
	        sdlist.add(sd4);
	        
	        //Insert Sales data records
			insert sdlist;
			
			//Test Start here
			Test.startTest();
			
			//AccountSalesDataRollupClone.executeCal = false;
			acc.Last_Modified_CurrYBudget__c = DateTime.now();
			update acc;
			
			
			//Call batch method
			AccountSalesDataRollupClone controller = new AccountSalesDataRollupClone();
			controller.calcualteAccountSalesDataRollup( sdlist );
			
			//Test stop here
			Test.stopTest();
			
			List<Account> accs = [Select Id,X2014_Sales__c,X2017_Sales__c,X2015_Sales__c,X2013_Sales__c,Previous_2Last_12Mo_Sales__c from Account where Name = 'Test Acc'];
			
			//Assert
			
    }
    //Test method
    
    static testMethod void myUnitTest3() {
		User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
			//create Account
	        Account acc = new Account();
	        acc.Name='Test Acc';
	        acc.Industry = 'Business Services';
	        acc.Type = 'Customer';
        acc.RecordTypeId = recordTypeId;
        	acc.OwnerId = managerUser.Id;
	        insert acc;
			
			Account acc1 = new Account();
	        acc1.Name='Test Acc1';
	        acc1.Industry = 'Business Services';
	        acc1.Type = 'Customer';
        acc1.RecordTypeId = recordTypeId;
        	acc1.OwnerId = managerUser.Id;
	        insert acc1;
			
			
	        //create List of sales data
	        List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
	        
	        Sales_Data__c sd = new Sales_Data__c();
	        sd.Actual_Amount__c = 100;
	        sd.Account__c = acc.id;
	        sdlist.add(sd);
	        
	        Sales_Data__c sd1 = new Sales_Data__c();
	        sd1.Year__c = String.valueOf(Date.Today().Year());
	        sd1.Period__c = date.today().month() == 12 ? 12 : date.today().month()+1;
	        sd1.Actual_Amount__c = 100;
	        sd1.Account__c = acc.id;
	        sd1.Forecast_Amount__c = 1000;
	        sdlist.add(sd1);
	        
	         Sales_Data__c sd2 = new Sales_Data__c();
	        sd2.Year__c = String.valueOf(Date.Today().Year()-1);
	        sd2.Period__c = date.today().month() == 1 ? 1 : date.today().month()-1;
	        sd2.Actual_Amount__c = 100;
	        sd2.Account__c = acc.id;
	        sdlist.add(sd2);
			
			Sales_Data__c sd3 = new Sales_Data__c();
	        sd1.Year__c = String.valueOf(Date.Today().Year());
	        sd1.Period__c = date.today().month() == 12 ? 12 : date.today().month()+1;
	        sd3.Actual_Amount__c = 100;
	        sd3.Account__c = acc1.id;
	        sd3.Forecast_Amount__c =1000;
	        sd3.Budget_Amount__c =1000;
	        sdlist.add(sd3);
	        
	        Sales_Data__c sd4 = new Sales_Data__c();
	       	sd1.Year__c = String.valueOf(Date.Today().Year());
	        sd1.Period__c = date.today().month() == 1 ? 1 : date.today().month()-1;
	        sd4.Actual_Amount__c = 100;
	        sd4.Account__c = acc.id;
	        sd4.Forecast_Amount__c = 1000;
	        sdlist.add(sd4);
	        
	        sd4 = new Sales_Data__c();
	       	sd1.Year__c = String.valueOf(Date.Today().Year()-1);
	        sd1.Period__c = date.today().month() == 1 ? 1 : date.today().month()-1;
	        sd4.Actual_Amount__c = 100;
	        sd4.Account__c = acc.id;
	        sd4.Forecast_Amount__c = 1000;
	        sdlist.add(sd4);
	        
	        //Insert Sales data records
			insert sdlist;
			
			//Test Start here   
			Test.startTest();
			
			//AccountSalesDataRollupClone.executeCal = false;
			acc.Last_Modified_CurrYBudget__c = DateTime.now();
			update acc;
			
			acc.Id = null;
			//Call batch method
			AccountSalesDataRollupClone controller = new AccountSalesDataRollupClone();
			controller.calcualteAccountSalesDataRollup( sdlist );
			
			//Test stop here
			Test.stopTest();
			
			List<Account> accs = [Select Id,X2014_Sales__c,X2017_Sales__c,X2015_Sales__c,X2013_Sales__c,Previous_2Last_12Mo_Sales__c from Account where Name = 'Test Acc'];
			
			
    }
}