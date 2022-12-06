@isTest
private class BatchAccountBudgetIndicatorTest {
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
        //Start testing from here
        Test.startTest();
        User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        //Create a list of accounts
        List<Account> listParentAccounts = new List<Account>();
        listParentAccounts.add(new Account(Name = 'A-Test',Type = 'Parent',recordTypeId =recordTypeId));   //Independent Account < 250K
        listParentAccounts.add(new Account(Name = 'B-Test', Type = 'Parent',recordTypeId=recordTypeId));
        
        AccountTriggerHelper.EXECUTE_VALIDATE_IS_ELIGIBLE_FOR_REPORTING = true;
        System.runAs(managerUser){
            insert listParentAccounts;
        }
        
        
        //Add child accounts under 2 and 3
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(new Account(Name = 'C-Test',recordTypeId =recordTypeId, ParentId = listParentAccounts[0].Id,Current_YTD_Sales__c = 100,BOY_Forecast__c = 10000,Current_Year_Budget__c = AccountTriggerHelper.CURRENT_YEAR_BUDGET_LIMIT));
        listAccounts.add(new Account(Name = 'D-Test',recordTypeId =recordTypeId, ParentId = listParentAccounts[0].Id,BOY_Forecast__c = AccountTriggerHelper.CURRENT_YEAR_OUTLOOK_LIMIT,Current_Year_Budget__c = 10000));
        listAccounts.add(new Account(Name = 'E-Test',recordTypeId =recordTypeId, ParentId = listParentAccounts[1].Id,BOY_Forecast__c = 10000,Current_Year_Budget__c = AccountTriggerHelper.CURRENT_YEAR_BUDGET_LIMIT));
        listAccounts.add(new Account(Name = 'F-Test',recordTypeId =recordTypeId, ParentId = listParentAccounts[1].Id,BOY_Forecast__c = AccountTriggerHelper.CURRENT_YEAR_OUTLOOK_LIMIT,Current_Year_Budget__c = 100002));
        
        AccountTriggerHelper.EXECUTE_VALIDATE_IS_ELIGIBLE_FOR_REPORTING = true;
        
        System.runAs(managerUser){
            insert listAccounts;
        }
       	BatchAccountBudgetIndicator batch = new BatchAccountBudgetIndicator();
       	Database.executeBatch(batch);
       	
       	//Stop Test
        Test.stopTest();
        
        //Fetch the accounts from database order by Name and check for the results
        List<Account> accs = [Select Id,Parent_CY_Budget_100K__c,Parent_CY_Budget_250K__c, Is_Eligible_For_Outlook_Report__c,CY_Budget_100K__c, Is_Eligible_For_Budget_Report__c from Account where Id IN: listAccounts order by Name ASC];
       
        /*System.assertEquals(false, accs[0].Is_Eligible_For_Budget_Report__c);  
        System.assertEquals(true, accs[0].CY_Budget_100K__c);
        System.assertEquals(true, accs[0].Parent_CY_Budget_250K__c);
        System.assertEquals(true, accs[0].Parent_CY_Budget_100K__c);
        
        System.assertEquals(false, accs[1].Is_Eligible_For_Budget_Report__c);
        System.assertEquals(false, accs[1].CY_Budget_100K__c);
        System.assertEquals(true, accs[1].Parent_CY_Budget_250K__c);
        System.assertEquals(true, accs[1].Parent_CY_Budget_100K__c);
        
        System.assertEquals(false, accs[2].Is_Eligible_For_Budget_Report__c);
        System.assertEquals(true, accs[2].CY_Budget_100K__c);
        System.assertEquals(true, accs[2].Parent_CY_Budget_250K__c);
        System.assertEquals(true, accs[2].Parent_CY_Budget_100K__c);
        
       System.assertEquals(false, accs[3].Is_Eligible_For_Budget_Report__c);
        System.assertEquals(true, accs[3].CY_Budget_100K__c);
        System.assertEquals(true, accs[3].Parent_CY_Budget_250K__c);
        System.assertEquals(true, accs[3].Parent_CY_Budget_100K__c);*/
        
        accs = [Select Id, Parent_CY_Budget_250K__c,Parent_CY_Budget_100K__c,Is_Eligible_For_Outlook_Report__c,CY_Budget_100K__c, Is_Eligible_For_Budget_Report__c from Account where Id IN: listParentAccounts order by Name ASC];
       
       /* System.assertEquals(false, accs[0].Parent_CY_Budget_250K__c);
        System.assertEquals(false, accs[1].Parent_CY_Budget_250K__c);
         System.assertEquals(false, accs[0].Parent_CY_Budget_100K__c);
        System.assertEquals(false, accs[1].Parent_CY_Budget_100K__c);
        System.assertEquals(true, accs[0].Is_Eligible_For_Budget_Report__c);
        System.assertEquals(true, accs[1].Is_Eligible_For_Budget_Report__c);
        
        System.assertEquals(true, accs[0].CY_Budget_100K__c);
        System.assertEquals(true, accs[1].CY_Budget_100K__c);*/
        
    }
    
     static testMethod void myUnitTest1() {
         User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        //Start testing from here
        Test.startTest();
        
        //Create a list of accounts
        List<Account> listParentAccounts = new List<Account>();
        listParentAccounts.add(new Account(Name = 'A-Test',Type = 'Parent',recordTypeId = recordTypeId));   //Independent Account < 250K
        listParentAccounts.add(new Account(Name = 'B-Test', Type = 'Parent',recordTypeId = recordTypeId));
        listParentAccounts.add(new Account(Name = 'BE-Test', Type = 'Parent',recordTypeId = recordTypeId));
        
        AccountTriggerHelper.EXECUTE_VALIDATE_IS_ELIGIBLE_FOR_REPORTING = true;
        System.runAs(managerUser){
         insert listParentAccounts;
        }
        //Add child accounts under 2 and 3
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(new Account(Name = 'C-Test',recordTypeId = recordTypeId, ParentId = listParentAccounts[0].Id,Current_YTD_Sales__c = 100,BOY_Forecast__c = 10000,Current_Year_Budget__c = 250007));
        listAccounts.add(new Account(Name = 'D-Test',recordTypeId = recordTypeId, ParentId = listParentAccounts[0].Id,BOY_Forecast__c = AccountTriggerHelper.CURRENT_YEAR_OUTLOOK_LIMIT,Current_Year_Budget__c = 10000));
        listAccounts.add(new Account(Name = 'E-Test',recordTypeId = recordTypeId, ParentId = listParentAccounts[1].Id,BOY_Forecast__c = 10000,Current_Year_Budget__c = AccountTriggerHelper.CURRENT_YEAR_BUDGET_LIMIT));
        listAccounts.add(new Account(Name = 'F-Test',recordTypeId = recordTypeId, ParentId = listParentAccounts[1].Id,BOY_Forecast__c = AccountTriggerHelper.CURRENT_YEAR_OUTLOOK_LIMIT,Current_Year_Budget__c = 100002));
        listAccounts.add(new Account(Name = 'G-Test',recordTypeId = recordTypeId, ParentId = listParentAccounts[2].Id,BOY_Forecast__c = AccountTriggerHelper.CURRENT_YEAR_OUTLOOK_LIMIT,Current_Year_Budget__c = 10000));
        
        AccountTriggerHelper.EXECUTE_VALIDATE_IS_ELIGIBLE_FOR_REPORTING = true;
        System.runAs(managerUser){
         insert listAccounts;
        }
       	BatchAccountBudgetIndicator batch = new BatchAccountBudgetIndicator();
       	Database.executeBatch(batch);
       	
       	//Stop Test
        Test.stopTest();
        
        //Fetch the accounts from database order by Name and check for the results
        List<Account> accs = [Select Id,Parent_CY_Budget_100K__c,Parent_CY_Budget_250K__c, Is_Eligible_For_Outlook_Report__c,CY_Budget_100K__c, Is_Eligible_For_Budget_Report__c from Account where Id IN: listAccounts order by Name ASC];
       
        /*System.assertEquals(true, accs[0].Is_Eligible_For_Budget_Report__c);  
        System.assertEquals(true, accs[0].CY_Budget_100K__c);
        System.assertEquals(true, accs[0].Parent_CY_Budget_250K__c);
        System.assertEquals(true, accs[0].Parent_CY_Budget_100K__c);
        
        System.assertEquals(false, accs[1].Is_Eligible_For_Budget_Report__c);
        System.assertEquals(false, accs[1].CY_Budget_100K__c);
        System.assertEquals(true, accs[1].Parent_CY_Budget_250K__c);
        System.assertEquals(true, accs[1].Parent_CY_Budget_100K__c);
        
        System.assertEquals(false, accs[2].Is_Eligible_For_Budget_Report__c);
        System.assertEquals(true, accs[2].CY_Budget_100K__c);
        System.assertEquals(true, accs[2].Parent_CY_Budget_250K__c);
        System.assertEquals(true, accs[2].Parent_CY_Budget_100K__c);
        
       System.assertEquals(false, accs[3].Is_Eligible_For_Budget_Report__c);
        System.assertEquals(true, accs[3].CY_Budget_100K__c);
        System.assertEquals(true, accs[3].Parent_CY_Budget_250K__c);
        System.assertEquals(true, accs[3].Parent_CY_Budget_100K__c);*/
        
        accs = [Select Id, Parent_CY_Budget_250K__c,Parent_CY_Budget_100K__c,Is_Eligible_For_Outlook_Report__c,CY_Budget_100K__c, Is_Eligible_For_Budget_Report__c from Account where Id IN: listParentAccounts order by Name ASC];
       
       /* System.assertEquals(false, accs[0].Parent_CY_Budget_250K__c);
        System.assertEquals(false, accs[1].Parent_CY_Budget_250K__c);
         System.assertEquals(false, accs[0].Parent_CY_Budget_100K__c);
        System.assertEquals(false, accs[1].Parent_CY_Budget_100K__c);
        System.assertEquals(true, accs[0].Is_Eligible_For_Budget_Report__c);
        System.assertEquals(true, accs[1].Is_Eligible_For_Budget_Report__c);
        
        System.assertEquals(true, accs[0].CY_Budget_100K__c);
        System.assertEquals(true, accs[1].CY_Budget_100K__c);*/
        
    }
}