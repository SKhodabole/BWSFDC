@isTest
private class Test_Batch_OrphanAccount {
    
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
	/**
     *  @ Description   :   Test Class For Batch_OrphanAccount class 
     *  
     *  @ Created By    :   
     *  
     *  @ Created Date  :   
     *
     *  @ Rivision Log  :   
     *
     *  @ Version       :   V_1.0
     **/
  
    static testMethod void myUnitTest() {
        User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        Test.startTest();
        //List of Accounts for customer
   		List<Account> accounts = new List<Account>();
       
       	//Create Account and add to list
	    for(Integer i = 0;i < 3; i++) {
	      Account acc = new Account(Name='Test'+i+'Acc',Industry = 'Business Services',Type = 'Customer',recordTypeId =recordTypeId);
	      accounts.add(acc);
	    }
        
        //Insert Accounts
        
        system.runAs(managerUser){
            insert accounts;
        }
            
        
        //List of Accounts for customer
   		List<Account> childAccounts = new List<Account>();
       
       	//Create Account and add to list
	    for(Integer i = 0;i < 2; i++) {
	      Account acc = new Account(Name='Test'+i+'Acc',ParentId =accounts[0].Id, Industry = 'Business Services',Type = 'Customer',recordTypeId =recordTypeId);
	      childAccounts.add(acc);
	    }
	    
	    
		system.runAs(managerUser){
            insert childAccounts;
        }
	    Batch_OrphanAccount batch = new Batch_OrphanAccount();
	    DataBase.executeBatch(batch);
	    
	    Test.stopTest();
	    
	    List<Document> documents = [Select Id,Name from Document where Name = 'OrphanAccBackup.csv'];
	    
	    system.assertEquals(1,documents.size());
    }
}