@isTest
private class Test_Batch_AccountBlankUpdate {
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
        try {
        	User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        	//Start testing from here
        Test.startTest();
        
        //Create a list of accounts
        List<Account> listParentAccounts = new List<Account>();
        listParentAccounts.add(new Account(Name = 'A-Test'));   //Independent Account < 250K
        listParentAccounts.add(new Account(Name = 'B-Test',RecordTypeId = recordTypeId, BOY_Forecast__c = AccountTriggerHelper.CURRENT_YEAR_OUTLOOK_LIMIT - 10, Current_Year_Budget__c = AccountTriggerHelper.CURRENT_YEAR_BUDGET_LIMIT - 10)); //Independent Account < 250K
        listParentAccounts.add(new Account(Name = 'C-Test',RecordTypeId = recordTypeId, BOY_Forecast__c = AccountTriggerHelper.CURRENT_YEAR_OUTLOOK_LIMIT, Current_Year_Budget__c = AccountTriggerHelper.CURRENT_YEAR_BUDGET_LIMIT));   //Independent Account > 250K
        listParentAccounts.add(new Account(Name = 'D-Test',RecordTypeId = recordTypeId, BOY_Forecast__c = AccountTriggerHelper.CURRENT_YEAR_OUTLOOK_LIMIT - 10, Current_Year_Budget__c = AccountTriggerHelper.CURRENT_YEAR_BUDGET_LIMIT - 10)); //Parent Account < 250K
        
        AccountTriggerHelper.EXECUTE_VALIDATE_IS_ELIGIBLE_FOR_REPORTING = true;
        
        System.runAs(managerUser){
            insert listParentAccounts;
        }
        //Add child accounts under 2 and 3
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(new Account(Name = 'E-Test',RecordTypeId = recordTypeId, ParentId = listParentAccounts[1].Id));
        listAccounts.add(new Account(Name = 'F-Test',RecordTypeId = recordTypeId, ParentId = listParentAccounts[3].Id));
        AccountTriggerHelper.EXECUTE_VALIDATE_IS_ELIGIBLE_FOR_REPORTING = true;
        
        System.runAs(managerUser){
            insert listAccounts;
        }
        //Update Parent
        listParentAccounts[3].BOY_Forecast__c = AccountTriggerHelper.CURRENT_YEAR_OUTLOOK_LIMIT;
        listParentAccounts[3].Current_Year_Budget__c = AccountTriggerHelper.CURRENT_YEAR_BUDGET_LIMIT;
        AccountTriggerHelper.EXECUTE_VALIDATE_IS_ELIGIBLE_FOR_REPORTING = true;
        update listParentAccounts;
        
	        Batch_AccountBlankUpdate batch = new Batch_AccountBlankUpdate();
	        DataBase.executeBatch(batch);
        //Stop Test
        Test.stopTest();
        
        //Fetch the accounts from database order by Name and check for the results
        List<Account> accs = [Select Id, Is_Eligible_For_Outlook_Report__c, Is_Eligible_For_Budget_Report__c from Account where Id IN: listParentAccounts OR Id IN: listAccounts order by Name ASC];
        
        
        }
        catch(Exception e) {
        	
        }
    }
}