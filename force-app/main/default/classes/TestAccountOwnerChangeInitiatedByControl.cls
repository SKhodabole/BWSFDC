@isTest
private class TestAccountOwnerChangeInitiatedByControl {

 	//Test method
    static testMethod void myUnitTest() {
       
    	User u = CreateUser();
        insert u;
       	Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
       	//Create Account Record
       	Account acc = new Account(Name = 'Test',Type = 'Customer' ,Industry = '*Comics', recordTypeId = recordTypeId);
       
       	//Test start 
       	Test.startTest();
        System.runAs(u){
       	//Insert Account
       	insert acc;
        }
       	//Query Account record
       	List<Account> accounts = [Select Id, Name from Account where id =: acc.Id];
       	
       	//assert
       	system.assert(accounts.size() >0);
       	
       	//Standard controller initailize
       	ApexPages.StandardController stdController = new ApexPages.StandardController(accounts[0]); 
       
       	//Controller insatnce
       	AccountOwnerChangeInitiatedByController controller = new AccountOwnerChangeInitiatedByController(stdController);
       
       	//Method call
       	controller.redirect();
       	
       	accounts[0].OwnerId = u.Id;
       	
       	//method call
       	controller.saveAndRedirect();
       	
       	//Query Account record
       	accounts = [Select Id, Name,OwnerId from Account where id =: acc.Id];
       	
       	//assert
       	system.assertEquals(u.Id,accounts[0].OwnerId);
       	
       	//Test stop
       	Test.stopTest();
   
	}
	
	/**
	 *	@Description	:	Method to test catch block while exception
	 *
	 *	@Args			:	Void
	 *
	 *	@Return			:	Void
	 **/
    static testMethod void myUnitTest1() {
        User u = CreateUser();
        insert u;
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
		//Create Account Record
       	Account acc = new Account(Name = 'Test',Type = 'Customer' ,Industry = '*Comics', recordTypeId = recordTypeId);
	       
       	//Test start 
       	Test.startTest();
        
	    System.runAs(u){
       	//Insert Account
       	insert acc;
        }
       	//Query Account record
       	List<Account> accounts = [Select Id, Name from Account where id =: acc.Id];
       	
       	//assert
       	system.assert(accounts.size() >0);
       	
       	accounts[0].id = null;
	      
       	//Standard controller initailize
       	ApexPages.StandardController stdController = new ApexPages.StandardController(accounts[0]); 
	       
       	//Controller insatnce
       	AccountOwnerChangeInitiatedByController controller = new AccountOwnerChangeInitiatedByController(stdController);
	       
       	//Method call
       	controller.redirect();
	       
       	//method call
       	controller.saveAndRedirect();
	       
       	//Test stop
       	Test.stopTest();
       
    }
	
	/**
	 *	@Description	:	Method to create user
	 *
	 *	@Args			:	Void
	 *
	 *	@Return			:	User
	 **/
	public static User createUser() {
    	Profile p = [select id from profile where name='System Administrator'];
	    User u = new User(alias = 'tesusr', email = 'testinguser@newtest.com',
	        emailencodingkey = 'UTF-8', lastname = 'Testing User', languagelocalekey = 'en_US',
	        localesidkey = 'en_US', profileid = p.Id,
	        timezonesidkey = 'America/Los_Angeles', username = 'testinguser@newtest.com',EmployeeNumber = '12321');
	       
	    return u;
	}
}