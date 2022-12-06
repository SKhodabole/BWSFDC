@isTest
private class BatchAccountWithOutChildAccountTest {
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
    	//Start test from here
    	Test.startTest();
    	
    	//List of  account
    	List<Account> accountsToBeInserted  = new List<Account>();
    	
    	//Accounts
    	Account acc1 = new Account(Name = 'Test1', Type = 'Parent', recordTypeId=recordTypeId);
    	accountsToBeInserted.add(acc1);
    	
    	Account acc2 = new Account(Name = 'Test2', Type = 'Parent', recordTypeId=recordTypeId);
    	accountsToBeInserted.add(acc2);
    	
    	Account acc3 = new Account(Name = 'Test3', Type = 'Customer', recordTypeId=recordTypeId);
    	accountsToBeInserted.add(acc3);
    	
    	//Insert list of account
        System.runAs(managerUser){
            insert accountsToBeInserted;
        
    	
    	
    	//Batch execute
    	BatchAccountWithOutChildAccount batch = new BatchAccountWithOutChildAccount();
    	Database.executeBatch(batch);
    	
    	//Test Stop Here
    	Test.stopTest();
        }
    	//Query List of account
    	List<Account> accounts = [Select Id, To_Be_Deleted__c from Account order by Name];
    	
    	//Assert
    	System.assertEquals(true,accounts[0].To_Be_Deleted__c);
    	System.assertEquals(true,accounts[1].To_Be_Deleted__c);
    	System.assertEquals(false,accounts[2].To_Be_Deleted__c);
    }
}