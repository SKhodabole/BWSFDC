@isTest
private class TestUpdatePeriodEndDate {
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
 static testMethod void startTest(){
     User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
 		//create Account
        Account acc = new Account();
        acc.Name='Test Acc';
        acc.Industry = 'Business Services';
        acc.Type = 'Customer';
     acc.recordTypeId = recordTypeId;
     acc.OwnerId = managerUser.Id;
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name='Test Acc1';
        acc1.Industry = 'Business Services';
        acc1.Type = 'Prospect';
     acc1.recordTypeId = recordTypeId;
     acc1.OwnerId = managerUser.Id;
        insert acc1;
        
        //create sales data
        List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
        Sales_Data__c sd = new Sales_Data__c();
        sd.Year__c = '2013';
        sd.Period__c = 2;
        sd.Actual_Amount__c = 100;   
        sd.Account__c = acc.id;     
        sdlist.add(sd);
        
        Sales_Data__c sd1 = new Sales_Data__c();
        sd1.Year__c = '2013';
        sd1.Period__c = 2;
        sd1.Actual_Amount__c = 100;   
        sd1.Account__c = acc1.id;     
        sdlist.add(sd1);
        //
        insert sdlist;
        
        
        //
        
        String str = 'SELECT Id, Year__c, Period__c, Period_End_Date__c FROM Sales_Data__c LIMIT 1'; //not sending 'where Period_End_Date__c = null' as there will not be any records 
     	UpdatePeriodEndDateUtil updateUtil = new UpdatePeriodEndDateUtil();
     	UpdatePeriodEndDateUtil.setMode(null);
     	UpdatePeriodEndDateBatch rr = new UpdatePeriodEndDateBatch();
     	
		rr.strQuery = str;
		id batchstart= Database.executeBatch(rr);
		
		//
		
		 String jobId = System.schedule('testsch', ScheduleUpdatePeriodEndDate.CRON_EXP, new ScheduleUpdatePeriodEndDate());
	     // Get the information from the CronTrigger API object
	     CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
	     // Verify the expressions are the same
	     //System.assertEquals(ScheduleUpdatePeriodEndDate.CRON_EXP, ct.CronExpression);
	     
	     //
	     InvokeUpdatePeriodEndDate up = new InvokeUpdatePeriodEndDate();
	     up.invoke();
	}
	
	static testMethod void rollUpBudgetAccountTest() {
		User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
		//create Account
        Account acc = new Account(); 
        acc.Name='Test Acc';
        acc.Industry = 'Business Services';
        acc.Type = 'Customer';
        acc.recordTypeId = recordTypeId;
     acc.OwnerId = managerUser.Id;
        insert acc;
       	
       	//create Account
       	Account acc1 = new Account();
        acc1.Name='Test Acc1';
        acc1.Industry = 'Business Services';
        acc1.Type = 'Prospect';
        acc1.recordTypeId = recordTypeId;
     	acc1.OwnerId = managerUser.Id;
        insert acc1;
        
        //List of sales data
        List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
        
        //Sales Data
        Sales_Data__c sd = new Sales_Data__c();
        sd.Year__c = '2015';
        sd.Period__c = 2;
        sd.Actual_Amount__c = 100;   
        sd.Account__c = acc.id; 
        sd.Budget_Amount__c =100;    
        sdlist.add(sd);
        
        //Sales Data
        Sales_Data__c sd1 = new Sales_Data__c();
        sd1.Year__c = '2013';
        sd1.Period__c = 2;
        sd1.Actual_Amount__c = 100;   
        sd1.Account__c = acc.id; 
        sd1.Budget_Amount__c = 100;    
        sdlist.add(sd1);
        
        //Sales Data
        Sales_Data__c sd2 = new Sales_Data__c();
        sd2.Year__c = '2016';
        sd2.Period__c = 2;
        sd2.Actual_Amount__c = 100;   
        sd2.Account__c = acc.id; 
        sd2.Budget_Amount__c = 100;    
        sdlist.add(sd2);
        
        //Test start
        Test.startTest();
        
        //Insert Sales Data list
        insert sdlist;
        
        //Query list of account
        List<Account> accounts = [Select Id,Budget_2015__c from Account where Id =: acc.Id];
        
        //Assert
        //system.assertEquals(100,accounts[0].Budget_2015__c);
        
        //Change account and budget
        sdlist[0].Account__c = acc1.Id;
        sdlist[0].Budget_Amount__c = 200;
        
        //Update sales data list
        update sdlist;
        
        //Query account records
        accounts = [Select Id,Budget_2015__c from Account where Id =: acc1.Id];
        
        //Assert
       // system.assertEquals(200,accounts[0].Budget_2015__c);
        
        //Change Period End date
        sdlist[0].Period_End_Date__c = date.today();
        
        //Update Sales Data
        update sdlist;
        
        //Query Accounts
        accounts = [Select Id,Budget_2015__c from Account where Id =: acc.Id];
        
        // Assert
        //system.assertEquals(0,accounts[0].Budget_2015__c);
       	
       	//Delete a sales data record
        delete sdlist[0];
        
        //Query account
        accounts = [Select Id,Budget_2015__c from Account where Id =: acc1.Id];
     	
     	//Assert       
       // system.assertEquals(0,accounts[0].Budget_2015__c);
        
        //Test stop
        Test.stopTest();
	}
}