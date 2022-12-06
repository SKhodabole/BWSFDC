@isTest(SeeAllData = false)
private class TestAccountSalesDataController {
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
        acc.RecordTypeId = recordTypeId;
        acc.OwnerId = managerUser.Id;
        insert acc;
        //create sales data
        List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
        Sales_Data__c sd = new Sales_Data__c();
        sd.Year__c = '2013';
        sd.Period__c = 2;
        sd.Actual_Amount__c = 100;
        sd.Account__c = acc.id;
        sdlist.add(sd);
        //
        insert sdlist;


        //
        String strQuery = 'SELECT Id, GM__c, GMDollars__c, Margin_Sales_Dollars__c, Account__c, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c LIMIT 100';
        AccountSalesDataRollup rr = new AccountSalesDataRollup(strQuery);
   		//rr.strQuery = strQuery;
    	id batchstart= Database.executeBatch(rr);

    	//

		 String jobId = System.schedule('testsch', ScheduleAccountSalesDataRollup.CRON_EXP, new ScheduleAccountSalesDataRollup());
	     // Get the information from the CronTrigger API object
	     CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
	     // Verify the expressions are the same
	     System.assertEquals(ScheduleAccountSalesDataRollup.CRON_EXP, ct.CronExpression);
	}
}