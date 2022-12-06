@isTest
private class Test_Batch_UpdateAccountTypeOnSales {
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
    	Test.startTest();
    	
    	//List of Accounts for customer
   		List<Account> accounts = new List<Account>();
       
        //Create Account and add to list
        for(Integer i = 0;i < 3; i++) {
          Account acc = new Account(Name='Test'+i+'Acc',Industry = 'Business Services',Type = 'Prospect',recordTypeId=recordTypeId);
          accounts.add(acc);
        }
        
        //insert list of  Account
        System.runAs(managerUser){
            insert accounts;
        }
        
        
        //List of sales data
        List<Sales_Data__c> sdList = new List<Sales_Data__c>();
        
        //Create Sales Data and add to list
        for(Integer i = 0; i < accounts.size(); i++) {
          
          Sales_Data__c sd = new Sales_Data__c();
          sd.Account__c = accounts[i].Id;
          sd.Year__c = String.valueOf(Date.today().Year());
          sd.Period__c = 10;
          sd.Actual_Amount__c = 100;   
          sd.Actual_Units__c = 20;
          sdList.add(sd);
        }
        
        //Insert Sales Data records
        insert sdList;
        
        //Query Account records which created
        List<Account> accs = [Select Id, Type from Account where Id IN:accounts];
        
        //Change Type on Accounts
       	accs[0].Type = 'Partner';
       	accs[1].Type = 'Prospect';
       	
       	//Update operation on Account
       	update accs;
       	
       	//Batch instantiate andd execute Batch
       	Batch_UpdateAccountTypeOnSales batch = new Batch_UpdateAccountTypeOnSales();
       	DataBase.executeBatch(batch);
        
        //Test stop
        Test.stopTest();
        
        //Query Account records
        accs = [Select Id,Type from Account where Id IN : accs];
        
        //Asserts
        system.assertEquals('Customer',accs[0].Type);
        system.assertEquals('Customer',accs[1].Type);
        system.assertEquals('Customer',accs[2].Type);
    }
}