@isTest(seeAllData=false)
private class Test_TE {
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
    	//List of acconts
        List<Account> accounts = new List<Account>();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        
        //Add accounts into list
        for(Integer i=0 ; i < 4 ;i++)
            accounts.add(new Account(Name = 'TestAccount'+i , RecordTypeId = recordTypeId));
        
        //insert accounts 
        System.runAs(managerUser){
            insert accounts;
        }
        
        
        //List of T&E
        List<T_E__c> listTnE = new List<T_E__c>();
 	 	
 	 	//Add T&E into list
        listTnE.add(new T_E__c(Account_1__c = accounts[0].Id , Account_2__c = accounts[1].Id , Account_3__c = accounts[2].Id , Account_4__c = accounts[3].Id));
        listTnE.add(new T_E__c(Comments__c = 'Testing'));
        
        //insert T&E records
        insert listTnE;
        
        //T&E insert without any account
        T_E__c  tE = new T_E__c(Comments__c = 'Testing');
        insert tE;
        
        //List of tasks
        List<Task> newTasks = new List<Task>();
        
        //Add tasks into list
        for(Integer i=0 ; i < 4 ; i++) {
            
            newTasks.add(new Task(WhatId = accounts[i].Id , Status = 'Open' , Subject = 'Testing' , Type = 'Phone' , ActivityDate = Date.Today() , Priority = 'High'));
            newTasks.add(new Task(WhatId = accounts[i].Id , Status = 'Open' , Subject = 'Email Test' , Type = 'Email' , ActivityDate = Date.Today() , Priority = 'Low'));
        }
        
        //Test Start here
        Test.startTest();
        
	        //insert Tasks
	        insert newTasks;
	        
	        //Query over account records 	
	  		List<Account> listAcc = [Select id, OPEN_ACTIVITIES__c from Account where id IN : accounts];
	  		
	        //assert for results
	        //system.assert(listAcc[0].OPEN_ACTIVITIES__c != null);
	        	        
        	//Query Account records 	
	  		List<T_E__c> listTnE1 = [Select id, Account_1_OPEN_ACTIVITIES_TEXT__c from T_E__c where id IN: listTnE];
	  		
	  		//system.assertEquals(listAcc[0].OPEN_ACTIVITIES__c, listTnE1[0].Account_1_OPEN_ACTIVITIES_TEXT__c);
	  		
        //Test stop here
        Test.stopTest();
    }
}