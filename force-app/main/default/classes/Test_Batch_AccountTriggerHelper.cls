@isTest
private class Test_Batch_AccountTriggerHelper {
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
		//Test Start here
       	Test.startTest();
       	
       	//Account create
   		Account parentAccount = new Account(Name = 'Test', Type='Parent',recordTypeId = recordTypeId);
   		
   		//Insert Account record
        System.runAs(managerUser){
            insert parentAccount;
        }
        
   		
   		//List of child account
   		List<Account> childsAcc = new List<Account>();
   		for(Integer i =0; i<3 ;i++) {
			
			Account acc = new Account(Name = 'Test'+i ,recordTypeId = recordTypeId, parentId = parentAccount.Id,Type = 'Customer',Current_YTD_Budget__c = 100,Current_YTD_Sales__c = 100);
		   	childsAcc.add(acc);		
  		}
  		
  		//Account  with out any child
  		Account acc = new Account(Name = 'TestN',recordTypeId = recordTypeId,Type = 'Parent',Current_YTD_Budget__c = 100,Current_YTD_Sales__c = 100);
	   	childsAcc.add(acc);	
	   	
	   	//Insert list of account
  		System.runAs(managerUser){
        insert childsAcc;
        }
  		//Batch instantiate and execute
  		Batch_AccountTriggerHelper batch = new Batch_AccountTriggerHelper();
  		DataBase.executeBatch(batch);
  		
  		//Test Stop 
  		Test.stopTest();
    }
}