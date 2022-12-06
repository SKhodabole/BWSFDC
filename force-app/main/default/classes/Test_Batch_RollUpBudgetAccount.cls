@isTest
private class Test_Batch_RollUpBudgetAccount {
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
	
	/** Description/purpose			:	Test Method is used to test functionality of trigger UpdatePeriodEndDateTrig for populated Budget(2015)
	  *
	  * Parameters					:	List<Sales_Data__c> newSalesData, Map<Id,Sales_Data__c> oldMapSalesData
	  *		
	  * Return parameters detail	:	Void
	  *
	  * Example code usage			:	
	  *
	  * Version						:	
	  *
	  * Author 						:	
	  *
	  * UpdatedBy					:
	  **/
	static testMethod void rollUpBudgetAccountTest() {
		User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();		
		//create Account
        Account acc = new Account(); 
        acc.Name='Test Acc';
        acc.Industry = 'Business Services';
        acc.Type = 'Customer';
        acc.recordTypeId = recordTypeId;
        acc.OwnerId= managerUser.Id;
        insert acc;
       	
       	//Create Account record
       	Account acc1 = new Account();
        acc1.Name='Test Acc1';
        acc1.Industry = 'Business Services';
        acc1.Type = 'Prospect';
        acc1.recordTypeId = recordTypeId;
        acc1.OwnerId= managerUser.Id;
        insert acc1;
        
        //create sales data
        List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
        Sales_Data__c sd = new Sales_Data__c();
        sd.Year__c = '2015';
        sd.Period__c = 2;
        sd.Actual_Amount__c = 100;   
        sd.Account__c = acc.id; 
        sd.Budget_Amount__c =100;    
        sdlist.add(sd);
        
        //Sales data record
        Sales_Data__c sd1 = new Sales_Data__c();
        sd1.Year__c = '2013';
        sd1.Period__c = 2;
        sd1.Actual_Amount__c = 100;   
        sd1.Account__c = acc.id; 
        sd1.Budget_Amount__c = 100;    
        sdlist.add(sd1);
        
        //Sales Data record
        Sales_Data__c sd2 = new Sales_Data__c();
        sd2.Year__c = '2016';
        sd2.Period__c = 2;
        sd2.Actual_Amount__c = 100;   
        sd2.Account__c = acc.id; 
        sd2.Budget_Amount__c = 100;    
        sdlist.add(sd2);
        
        //Test start here
        Test.startTest();
        
        //Insert sales data list
        insert sdlist;
        
        //Query Account created record
        List<Account> accounts = [Select Id,Budget_2015__c from Account where Id =: acc.Id];
        
        accounts[0].Budget_2015__c = 0;
        
        Batch_RollUpBudgetAccount batch = new Batch_RollUpBudgetAccount();
        Database.executeBatch(batch);
        
        //update sales data account lookup
        /*sdlist[0].Account__c = acc1.Id;
        sdlist[0].Budget_Amount__c = 200;
        
        //u[pdate list]
        update sdlist;
        
        //Query Account record
        accounts = [Select Id,Budget_2015__c from Account where Id =: acc1.Id];
    	
    	//Assert
        system.assertEquals(200,accounts[0].Budget_2015__c);
        
        //Query Account Record
        accounts = [Select Id,Budget_2015__c from Account where Id =: acc.Id];
    	
    	//Assert here
        system.assertEquals(0,accounts[0].Budget_2015__c);
        
        //Delete Sales Data record
        delete sdlist[0];
        
        //Query Account record
        accounts = [Select Id,Budget_2015__c from Account where Id =: acc1.Id];
    	
    	//Assert 
        system.assertEquals(0,accounts[0].Budget_2015__c);*/
        
        //Test stop
        Test.stopTest();
		
		
	}
}