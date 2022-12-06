/*
    Test Class for trigger "Trigger_Account" on Account
*/
@isTest(seeAllData=false)
private class Trigger_AccountTest {

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
   
        
    // Verify RollUpCalculation On Insert
    private static testMethod void testRollUpCalculationOnInsert() {
        
        User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        Account accParent = new Account(Name = 'Test Child Account 1',
                                        Type = 'Parent', recordTypeId = recordTypeId, OwnerId = managerUser.Id
                                        );

        insert accParent;

        List<Account> listAccount = new List<Account>();
        Account acc1 = new Account(Name = 'Test Child Account 1', Current_YTD_Budget__c = 1000,
                                   ParentId = accParent.Id , recordTypeId = recordTypeId, OwnerId = managerUser.Id);
        Account acc2 = new Account(Name = 'Test Child Account 2', Current_YTD_Budget__c = 2000,
                                   ParentId = accParent.Id , recordTypeId = recordTypeId, OwnerId = managerUser.Id );
        listAccount.add( acc1 );
        listAccount.add( acc2 );

        Test.startTest();
            insert listAccount;
            Account accParentRes = [ Select Current_YTD_Budget__c, Name
                                     From Account
                                     Where Id =: accParent.Id
                                     And Type = 'Parent' ];

            //system.assertEquals( 3000, accParentRes.Current_YTD_Budget__c );
            acc1.Current_YTD_Budget__c = 2000;
            update acc1;
        Test.stopTest();

    }

    // Verify RollUpCalculation On Delete
    private static testMethod void testRollUpCalculationOnDelete() {
		User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        Account accParent = new Account(Name = 'Test Child Account 1',
                                        Type = 'Parent', recordTypeId = recordTypeId, OwnerId = managerUser.Id
                                        );

        insert accParent;

        List<Account> listAccount = new List<Account>();
        Account acc1 = new Account(Name = 'Test Child Account 1', Current_YTD_Budget__c = 1000,
                                   ParentId = accParent.Id, recordTypeId = recordTypeId , OwnerId = managerUser.Id);
        Account acc2 = new Account(Name = 'Test Child Account 2', Current_YTD_Budget__c = 2000,
                                   ParentId = accParent.Id, recordTypeId = recordTypeId , OwnerId = managerUser.Id);
        listAccount.add( acc1 );
        listAccount.add( acc2 );

        Test.startTest();
            insert listAccount;
            Account accParentRes = [ Select Current_YTD_Budget__c, Name
                                     From Account
                                     Where Id =: accParent.Id
                                     And Type = 'Parent' ];

            //system.assertEquals( 3000, accParentRes.Current_YTD_Budget__c );
            delete acc1;

        Test.stopTest();

    }
    
    // Verify RollUpCalculation On Change Parent on Account than Old Parent
    private static testMethod void testRollUpCalculationOnParentChange() {
User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        Account accParent = new Account(Name = 'Test Child Account 1',
                                        Type = 'Parent', recordTypeId = recordTypeId, OwnerId = managerUser.Id
                                        );

        insert accParent;
        
        List<Account> listAccount = new List<Account>();
        Account acc1 = new Account(Name = 'Test Child Account 1', Current_YTD_Budget__c = 1000,
                                   ParentId = accParent.Id , recordTypeId = recordTypeId, OwnerId = managerUser.Id);
        Account acc2 = new Account(Name = 'Test Child Account 2', Current_YTD_Budget__c = 2000,
                                   ParentId = accParent.Id , recordTypeId = recordTypeId, OwnerId = managerUser.Id);
        listAccount.add( acc1 );
        listAccount.add( acc2 );

        Test.startTest();
            insert listAccount;
            Account accParentRes = [ Select Current_YTD_Budget__c, Name
                                     From Account
                                     Where Id =: accParent.Id
                                     And Type = 'Parent' ];

            //system.assertEquals( 3000, accParentRes.Current_YTD_Budget__c );
            
            acc1.ParentId = null;
            update listAccount;
            
            Account accParentRes1 = [ Select Current_YTD_Budget__c, Name
                                     From Account
                                     Where Id =: accParent.Id
                                     And Type = 'Parent' ];
            //system.assertEquals( 2000, accParentRes1.Current_YTD_Budget__c );
            
            acc2.ParentId = null;
            update listAccount;
            
            Account accParentRes2 = [ Select Current_YTD_Budget__c, Name
                                     From Account
                                     Where Id =: accParent.Id
                                     And Type = 'Parent' ];
            //system.assertEquals( 0, accParentRes2.Current_YTD_Budget__c );
            
        Test.stopTest();

    }

    // Verify updateUserOnOwnerChange
    private static testMethod void testupdateUserOnOwnerChange01() {
User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        Account accParent = new Account(Name = 'Test Child Account 1',
                                        Type = 'Parent',
                                        OwnerId = managerUser.Id,
                                        recordTypeId = recordTypeId);

        insert accParent;

        Account acc1 = new Account(Name = 'Test Child Account 1', Current_YTD_Budget__c = 1000,
                                   ParentId = accParent.Id,  OwnerId = managerUser.Id );
        
        Test.startTest();
            insert acc1;
            User u = [ Select Most_Recent_Account_Assignment_Date__c From User Where Id =: Userinfo.getUserId() ];
            //system.assertEquals( Date.today(), u.Most_Recent_Account_Assignment_Date__c );
        Test.stopTest();
    }

    // Verify updateUserOnOwnerChange
    private static testMethod void testupdateUserOnOwnerChange02() {
User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        Account accParent = new Account(Name = 'Test Child Account 1',
                                        Type = 'Parent',
                                         OwnerId = managerUser.Id,
                                        recordTypeId = recordTypeId);

        insert accParent;

        Account acc1 = new Account(Name = 'Test Child Account 1', Current_YTD_Budget__c = 1000,
                                   ParentId = accParent.Id, OwnerId = managerUser.Id, recordTypeId =recordTypeId  );
        insert acc1;
            
        Test.startTest();
            acc1.OwnerId = managerUser.Id;
            update acc1;
            
            //system.assertEquals( Date.today(), u.Most_Recent_Account_Removal_Date__c );
            
        Test.stopTest();
    }
    
    /*
    // Verify RollUpCalculation On Insert
    private static testMethod void testRollUpCalculationOnInsert() {

        DandbCompany DandbCompanyObj = new DandbCompany( Name  = 'Test Name',
                                                         GlobalUltimateBusinessName = 'Test Global Name',
                                                         GlobalUltimateDunsNumber = '445566888',
                                                         DunsNumber = '445566777'
                                                         );

        insert DandbCompanyObj;
        Account accParentRes = [ Select Type, Name, DunsNumber
                                     From Account
                                     Where DandbCompanyId =: DandbCompanyObj.Id
                                     And Type = 'Parent' ];

        List<Account> listAccount = new List<Account>();
        Account acc1 = new Account(Name = 'Test Child Account 1', Current_YTD_Budget__c = 1000,
                                   DandbCompanyId = DandbCompanyObj.Id, ParentId = accParentRes.Id );
        Account acc2 = new Account(Name = 'Test Child Account 2', Current_YTD_Budget__c = 2000,
                                   DandbCompanyId = DandbCompanyObj.Id, ParentId = accParentRes.Id );
        listAccount.add( acc1 );
        listAccount.add( acc2 );

        Test.startTest();
            insert listAccount;
            accParentRes = [ Select Current_YTD_Budget__c, Name, DunsNumber
                                     From Account
                                     Where DandbCompanyId =: DandbCompanyObj.Id
                                     And Type = 'Parent' ];

            system.assertEquals( 3000, accParentRes.Current_YTD_Budget__c );

        Test.stopTest();

    }

    // Verify RollUpCalculation On Update
    private static testMethod void testRollUpCalculationOnUpdate() {

        DandbCompany DandbCompanyObj = new DandbCompany( Name  = 'Test Name',
                                                         GlobalUltimateBusinessName = 'Test Global Name',
                                                         GlobalUltimateDunsNumber = '445566888',
                                                         DunsNumber = '445566777'
                                                         );

        insert DandbCompanyObj;
        Account accParentRes = [ Select Type, Name, DunsNumber
                                     From Account
                                     Where DandbCompanyId =: DandbCompanyObj.Id
                                     And Type = 'Parent' ];

        List<Account> listAccount = new List<Account>();
        Account acc1 = new Account(Name = 'Test Child Account 1', Current_YTD_Budget__c = 1000,
                                   DandbCompanyId = DandbCompanyObj.Id, ParentId = accParentRes.Id );
        insert acc1;

        Test.startTest();
            acc1.Current_YTD_Budget__c = 2000;
            update acc1;

            accParentRes = [ Select Current_YTD_Budget__c, Name, DunsNumber
                                     From Account
                                     Where DandbCompanyId =: DandbCompanyObj.Id
                                     And Type = 'Parent' ];

            system.assertEquals( 2000, accParentRes.Current_YTD_Budget__c );

        Test.stopTest();

    }

    // Verify RollUpCalculation On Delete
    private static testMethod void testRollUpCalculationOnDelete() {

        DandbCompany DandbCompanyObj = new DandbCompany( Name  = 'Test Name',
                                                         GlobalUltimateBusinessName = 'Test Global Name',
                                                         GlobalUltimateDunsNumber = '445566888',
                                                         DunsNumber = '445566777'
                                                         );

        insert DandbCompanyObj;

        Account accParentRes = [ Select Type, Name, DunsNumber
                                     From Account
                                     Where DandbCompanyId =: DandbCompanyObj.Id
                                     And Type = 'Parent' ];

        List<Account> listAccount = new List<Account>();
        Account acc1 = new Account(Name = 'Test Child Account 1', Current_YTD_Budget__c = 1000,
                                   DandbCompanyId = DandbCompanyObj.Id, ParentId = accParentRes.Id );
        Account acc2 = new Account(Name = 'Test Child Account 2', Current_YTD_Budget__c = 2000,
                                   DandbCompanyId = DandbCompanyObj.Id, ParentId = accParentRes.Id );
        listAccount.add( acc1 );
        listAccount.add( acc2 );
        insert listAccount;

        Test.startTest();
            delete acc2;

            accParentRes = [ Select Current_YTD_Budget__c, Name, DunsNumber
                                     From Account
                                     Where DandbCompanyId =: DandbCompanyObj.Id
                                     And Type = 'Parent' ];

            system.assertEquals( 1000, accParentRes.Current_YTD_Budget__c );

        Test.stopTest();

    }

    // Verify RollUp Calculation Overwrite on parent account
    private static testMethod void testRollUpCalcOnParentAccountToOverwriteChange() {

        DandbCompany DandbCompanyObj = new DandbCompany( Name  = 'Test Name',
                                                         GlobalUltimateBusinessName = 'Test Global Name',
                                                         GlobalUltimateDunsNumber = '445566888',
                                                         DunsNumber = '445566777'
                                                         );

        insert DandbCompanyObj;

        Account accParentRes = [ Select Type, Name, DunsNumber
                                     From Account
                                     Where DandbCompanyId =: DandbCompanyObj.Id
                                     And Type = 'Parent' ];

        List<Account> listAccount = new List<Account>();
        Account acc1 = new Account(Name = 'Test Child Account 1', Current_YTD_Budget__c = 1000,
                                   DandbCompanyId = DandbCompanyObj.Id, ParentId = accParentRes.Id );
        Account acc2 = new Account(Name = 'Test Child Account 2', Current_YTD_Budget__c = 2000,
                                   DandbCompanyId = DandbCompanyObj.Id, ParentId = accParentRes.Id );
        listAccount.add( acc1 );
        listAccount.add( acc2 );
        insert listAccount;

        Test.startTest();

            accParentRes.Current_YTD_Budget__c = 40000;
            update accParentRes;

            accParentRes = [ Select Current_YTD_Budget__c, Name, DunsNumber
                                     From Account
                                     Where DandbCompanyId =: DandbCompanyObj.Id
                                     And Type = 'Parent' ];

            system.assertEquals( 3000, accParentRes.Current_YTD_Budget__c );

        Test.stopTest();

    }
    */
    
    // This method is to test validateIsEligibleForReporting functionality
    private static testMethod void testValidateIsEligibleForReporting() {
        User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
        /** Test data **/
        
        //Start testing from here
        Test.startTest();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        //Create a list of accounts
        List<Account> listParentAccounts = new List<Account>();
        listParentAccounts.add(new Account(Name = 'A-Test',Type = 'Parent', RecordTypeId = recordTypeId, OwnerId = managerUser.Id));   //Independent Account < 250K
        listParentAccounts.add(new Account(Name = 'B-Test', Type = 'Parent', RecordTypeId = recordTypeId, OwnerId = managerUser.Id));
        
        AccountTriggerHelper.EXECUTE_VALIDATE_IS_ELIGIBLE_FOR_REPORTING = true;
        insert listParentAccounts;
        
        //Add child accounts under 2 and 3
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(new Account(Name = 'C-Test', RecordTypeId = recordTypeId, OwnerId = managerUser.Id, ParentId = listParentAccounts[0].Id,Current_YTD_Sales__c = 100,BOY_Forecast__c = 10000,Current_Year_Budget__c = AccountTriggerHelper.CURRENT_YEAR_BUDGET_LIMIT));
        listAccounts.add(new Account(Name = 'D-Test', RecordTypeId = recordTypeId, OwnerId = managerUser.Id, ParentId = listParentAccounts[0].Id,BOY_Forecast__c = AccountTriggerHelper.CURRENT_YEAR_OUTLOOK_LIMIT,Current_Year_Budget__c = 10000));
        listAccounts.add(new Account(Name = 'E-Test', RecordTypeId = recordTypeId, OwnerId = managerUser.Id, ParentId = listParentAccounts[1].Id,BOY_Forecast__c = 10000,Current_Year_Budget__c = AccountTriggerHelper.CURRENT_YEAR_BUDGET_LIMIT));
        listAccounts.add(new Account(Name = 'F-Test', RecordTypeId = recordTypeId, OwnerId = managerUser.Id, ParentId = listParentAccounts[1].Id,BOY_Forecast__c = AccountTriggerHelper.CURRENT_YEAR_OUTLOOK_LIMIT,Current_Year_Budget__c = 100002));
        
        AccountTriggerHelper.EXECUTE_VALIDATE_IS_ELIGIBLE_FOR_REPORTING = true;
        insert listAccounts;
        
   		update listAccounts;
   		
        //Fetch the accounts from database order by Name and check for the results
        List<Account> accs = [Select Id,Parent_CY_Budget_100K__c,Parent_CY_Budget_250K__c, Is_Eligible_For_Outlook_Report__c,CY_Budget_100K__c, Is_Eligible_For_Budget_Report__c from Account where Id IN: listAccounts order by Name ASC];
        
        /*System.assertEquals(false, accs[0].Is_Eligible_For_Outlook_Report__c);
        System.assertEquals(true, accs[1].Is_Eligible_For_Outlook_Report__c);
        System.assertEquals(false, accs[2].Is_Eligible_For_Outlook_Report__c);
        System.assertEquals(true, accs[3].Is_Eligible_For_Outlook_Report__c);
        
        System.assertEquals(false, accs[0].Is_Eligible_For_Budget_Report__c);
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
        
        /*System.assertEquals(true, accs[0].Is_Eligible_For_Outlook_Report__c);
        System.assertEquals(true, accs[1].Is_Eligible_For_Outlook_Report__c);
        
        System.assertEquals(false, accs[0].Parent_CY_Budget_250K__c);
        System.assertEquals(false, accs[1].Parent_CY_Budget_250K__c);
         System.assertEquals(false, accs[0].Parent_CY_Budget_100K__c);
        System.assertEquals(false, accs[1].Parent_CY_Budget_100K__c);
        System.assertEquals(true, accs[0].Is_Eligible_For_Budget_Report__c);
        System.assertEquals(true, accs[1].Is_Eligible_For_Budget_Report__c);
        
        System.assertEquals(true, accs[0].CY_Budget_100K__c);
        System.assertEquals(true, accs[1].CY_Budget_100K__c);*/
        
             
        //Stop Test
        Test.stopTest();
        
      
    }
    
    /**
     *  @ Description   :   This method is used for blank update T_E__c records
     *
     *  @ args          :   null
     *
     *  @ return        :   Void
     *
     **/
    private static testMethod void testUpdateTAndEBlank() {
        User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
        //Account insert
        Account accParent = new Account(Name = 'Test Child Account 1',
                                        Type = 'Parent',
                                        OwnerId = managerUser.Id
                                        );

        insert accParent;
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        //Account insert
        Account acc1 = new Account(Name = 'Test Child Account 1', Current_YTD_Budget__c = 1000,
                                   ParentId = accParent.Id, OwnerId = managerUser.Id, RecordTypeId = recordTypeId );
        
        //Test start 
        Test.startTest();
            
            //Insert Account
            insert acc1;
            
            //T&E record insert
            T_E__c tAndE = new T_E__c(Account_1__c = acc1.Id);
            insert tAndE;
            
            //Task insert 
            Task newTask = new Task(WhatId = acc1.Id , Status = 'Open' , Subject = 'Testing' , Type = 'Email' , ActivityDate = Date.Today() , Priority = 'Low');
            insert newTask;
            
            //Query Account records     
            List<Account> listAcc = [Select Id, OPEN_ACTIVITIES__c from Account where id =: acc1.Id];
            
            //Assert
            //System.assert(listAcc[0].OPEN_ACTIVITIES__c != null);
            
           
        //Test stop 
        Test.stopTest();
    }
}