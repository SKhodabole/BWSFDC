@isTest
private class TestAccountSalesDataMerge {
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
        sd.Year__c = '2014';
        sd.Period__c = 1;
        sd.Actual_Amount__c = 100;   
        sd.Account__c = acc.id; 
        sd.Margin_Sales_Dollars__c = 20;   
        sdlist.add(sd);

        sd = new Sales_Data__c();
        sd.Year__c = '2014';
        sd.Period__c = 1;
        sd.Actual_Amount__c = 100;   
        sd.Account__c = acc.id; 
        sd.Historical_Owner__c  = UserInfo.getUserId();  
        sdlist.add(sd);
        //
        insert sdlist;
        test.startTest();
        Set<Id> setAccountId = new Set<Id>();
        setAccountId.add(acc.Id);
        AccountSalesDataMerge.runAccountSalesDataMerge(setAccountId,'2015');
        //
        
        String str = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c LIMIT 1';
       AccountSalesDataMerge rr = new AccountSalesDataMerge(str);
    id batchstart= Database.executeBatch(rr);
    
    AccountSalesDataMerge.runAccountSalesDataMerge(setAccountId,null);
    String str1 = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c LIMIT 1';
    AccountSalesDataMerge rr1 = new AccountSalesDataMerge(str1);
    id batchstart1= Database.executeBatch(rr1);
    
    Set<Id> setAccountsId = new Set<Id>();
    AccountSalesDataMerge.runAccountSalesDataMerge(setAccountsId,'2015');
    String str2 = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c LIMIT 1';
    AccountSalesDataMerge rr2 = new AccountSalesDataMerge(str2);
    id batchstart2= Database.executeBatch(rr2);
    
    //
    SalesDataMergeSetting__c customSales = new SalesDataMergeSetting__c(Name = 'SalesDataYear',Year__c = '2015');
    insert customSales;
    
     
     String jobId = System.schedule('testsch', ScheduleAccountSalesDataMerge.CRON_EXP, new ScheduleAccountSalesDataMerge());
       // Get the information from the CronTrigger API object
       CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
       // Verify the expressions are the same
       System.assertEquals(ScheduleAccountSalesDataMerge.CRON_EXP, ct.CronExpression);
       
       //
       InvokeAccountSalesDataMerge up = new InvokeAccountSalesDataMerge();
       up.runBatch();
       
       SalesDataMergeSetting__c customSalesDM = new SalesDataMergeSetting__c(Name = 'SalesDataYear',Year__c = '2015');
    	insert customSalesDM;
       InvokeAccountSalesDataMerge up1 = new InvokeAccountSalesDataMerge();
       up1.runBatch();
        test.stopTest();
	}
	
	//Test method for  test else cases
	static testMethod void startTest2(){
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
        
        
        //create sales data
        List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
        Sales_Data__c sd = new Sales_Data__c();
        sd.Year__c = '2014';
        sd.Period__c = 1;
        sd.Actual_Amount__c = 100;   
        sd.Account__c = acc.id; 
        sd.Margin_Sales_Dollars__c = 20;   
        sdlist.add(sd);

        sd = new Sales_Data__c();
        sd.Year__c = '2014';
        sd.Period__c = 1;
        sd.Actual_Amount__c = 100;   
        sd.Account__c = acc.id; 
        sd.Historical_Owner__c  = UserInfo.getUserId();  
        sdlist.add(sd);
        //
        insert sdlist;
        Test.startTest();
        Set<Id> setAccountId = new Set<Id>();
        setAccountId.add(acc.Id);
        AccountSalesDataMerge.runAccountSalesDataMerge(setAccountId,'2015');
        //
        
        String str = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c LIMIT 1';
       AccountSalesDataMerge rr = new AccountSalesDataMerge(str);
    id batchstart= Database.executeBatch(rr);
    
    AccountSalesDataMerge.runAccountSalesDataMerge(setAccountId,null);
    String str1 = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c LIMIT 1';
    AccountSalesDataMerge rr1 = new AccountSalesDataMerge(str1);
    id batchstart1= Database.executeBatch(rr1);
    
    Set<Id> setAccountsId = new Set<Id>();
    AccountSalesDataMerge.runAccountSalesDataMerge(setAccountsId,'2015');
    String str2 = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c LIMIT 1';
    AccountSalesDataMerge rr2 = new AccountSalesDataMerge(str2);
    id batchstart2= Database.executeBatch(rr2);
    
    //
    SalesDataMergeSetting__c customSales = new SalesDataMergeSetting__c(Name = 'SalesDataYear');
    insert customSales;
    
     String jobId = System.schedule('testsch', ScheduleAccountSalesDataMerge.CRON_EXP, new ScheduleAccountSalesDataMerge());
       // Get the information from the CronTrigger API object
       CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
       // Verify the expressions are the same
       System.assertEquals(ScheduleAccountSalesDataMerge.CRON_EXP, ct.CronExpression);
       
       //
       InvokeAccountSalesDataMerge up = new InvokeAccountSalesDataMerge();
       up.runBatch();
       
       SalesDataMergeSetting__c customSalesDM = new SalesDataMergeSetting__c(Name = 'SalesDataYear');
    	insert customSalesDM;
       InvokeAccountSalesDataMerge up1 = new InvokeAccountSalesDataMerge();
       up1.runBatch();
        Test.stopTest();
 }
}