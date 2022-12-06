@isTest(seeAllData = false)
public class SearchAccountsControllerTest{
    // Unit test Method
    static testmethod void UnitTest01() {
        User u = createUser();
    	insert u;
    	
    	system.runAs(u) {
        list< Account> accountList = new list<Account>();
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        accountList.add(new Account(Name='Polkomtel S.A.', recordTypeId = recordTypeId));
        accountList.add(new Account(Name='Dover Corporation', recordTypeId = recordTypeId));
        accountList.add(new Account(Name='Active Endpoints', recordTypeId = recordTypeId));
        accountList.add(new Account(Name='Oracle Corporation', recordTypeId = recordTypeId));
        insert accountList;
        }
        Test.startTest();   
            SearchAccountsController sac = new SearchAccountsController();
            sac.size = 1;
            sac.refresh();
            sac.next();
            system.assertEquals(false,sac.hasNext);
            system.assertEquals(false,sac.hasPrevious);
            sac.previous();
            
        Test.stopTest();
    }   
    
    // Unit test Method
    static testmethod void UnitTest02() {
        User u = createUser();
    	insert u;
    	list< Account> accountList = new list<Account>();
    	system.runAs(u) {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        Account acc = new Account(Name = 'Test',Type = 'Parent', recordTypeId = recordTypeId);
        insert acc;
        
        
        accountList.add(new Account(Name='Polkomtel S.A.',Type = 'Partner',ParentId = acc.Id, recordTypeId = recordTypeId));
        accountList.add(new Account(Name='Pol Dover Corporation',Type = 'Partner',ParentId = acc.Id, recordTypeId = recordTypeId));
        accountList.add(new Account(Name='Active Endpoints',Type = 'Partner',ParentId = acc.Id, recordTypeId = recordTypeId));
        accountList.add(new Account(Name='Oracle Corporation',Type = 'Partner',ParentId = acc.Id, recordTypeId = recordTypeId));
        insert accountList;
        }
        Test.startTest();   
            SearchAccountsController sac = new SearchAccountsController();
            
            
            sac.accountName = 'Pol*';
            sac.SF_Acct_ID = accountList[0].Id; 
            sac.size = 1;
            Integer page = sac.pageNumber;
            
            sac.refresh();
            sac.previous();
            sac.next();
            system.assertEquals(false,sac.hasNext);
            system.assertEquals(false,sac.hasPrevious);
        Test.stopTest();
    }  
    
    // Unit test Method
    static testmethod void UnitTest03() {
    	
    	User u = createUser();
    	insert u;
    	list< Account> accountList = new list<Account>();
    	system.runAs(u) {
	        
	        accountList.add(new Account(Name='Polkomtel S.A.', phone = '123456', website = 'www.google.com', BillingStreet = 'st', BillingCity = 'st', BillingState = 'st', BillingCountry = 'st', BillingPostalCode = '30303'));
	        accountList.add(new Account(Name='Dover Corporation'));
	        accountList.add(new Account(Name='Active Endpoints'));
	        accountList.add(new Account(Name='Oracle Corporation'));
	        insert accountList;
	        
	        Test.startTest();   
	            SearchAccountsController sac = new SearchAccountsController();
	            sac.accountName = '*po*';
	            sac.phone = '123456';
	            sac.website = 'www.google.com';
	            sac.account.BillingStreet = 'st';
	            sac.account.BillingCity = 'st';
	            sac.account.BillingState = 'st';
	            sac.account.BillingCountry = 'st';
	            sac.account.BillingPostalCode = '30303';
	            sac.account.OwnerId = u.Id;
	            //system.debug('@#@#@u.Manager.Id'+u.Manager.Id);
	            u =[Select Id, Manager.Id from User Where Id =: u.Id];
	            system.debug('@#@#@u.Manager.Id'+u.Manager.Id);
	            sac.manager.OwnerId = u.Manager.Id;
	            
	            sac.size = 1;
	            Boolean br = sac.isSystemAdmin;
	            system.assertEquals(false,sac.hasNext);
	            system.assertEquals(false,sac.hasPrevious);
	            sac.refresh();
	            
	            
	        Test.stopTest();
    	}
    }    
    
    //Test method for lead search
    static testmethod void leadTest() {
    	
    	//Create user and insert
    	User u = createUser();
    	insert u;
    	Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Cenveo').getRecordTypeId();
    	//List of lead
    	List<Lead> leadsToBeInserted = new List<Lead>();
    	
    	//Add lead into list of lead
    	leadsToBeInserted.add(new Lead(FirstName = 'Test',recordTypeId = recordTypeId, LastName = 'Testing', OwnerId = u.id, Status = 'Untouched', LeadSource = 'cenveo Store', Email = 'test.testing@cenveo.com',
										Street ='AZ', City='PK', State='MK', Country='US', PostalCode='25896', Company = 'HelloTest'));
		leadsToBeInserted.add(new Lead(FirstName = 'Test',recordTypeId = recordTypeId, LastName = 'Leaad', OwnerId = u.id, Status = 'Untouched', Company = 'Hello'));
		leadsToBeInserted.add(new Lead(FirstName = 'Priyanka',recordTypeId = recordTypeId, LastName = 'Test', OwnerId = u.id, Status = 'Untouched', Company = 'Testing'));
		leadsToBeInserted.add(new Lead(FirstName = 'Sales', recordTypeId = recordTypeId,LastName = 'tewst', Website='www.Simplyforce.com', Company = 'Final'));
		
		//Insert lead
        system.runAs(u){
            insert leadsToBeInserted;
        }
        
		
		//Test start here
		Test.startTest();
		
		//Instantiate Controller
		SearchAccountsController sac = new SearchAccountsController();
		
		//Set controller properties
		sac.lead.FirstName = 'Test';
		sac.pageSize = 1;
		
		//Call controller method
		sac.refresh();
		
		//Assert
		System.assertEquals(2,sac.listOfLeads.size());
		
		//Controller's method call 
		sac.getPreviousButtonDisabled();
		sac.nextLead();
		
		//Assert here
		System.assertEquals(1,sac.tempListOfLead.size());
		
		//Controller's methods call
		sac.getNextButtonDisabled();
		sac.previousLead();
		
		//Assert
		System.assertEquals(1,sac.tempListOfLead.size());
		
		//Set lead properties
		sac.lead.LastName = 'Testing';
		
		//Call controller method
		sac.refresh();
		
		//Assert
		System.assertEquals(1,sac.listOfLeads.size());
		
		//Set lead properties	
		sac.lead.OwnerId = u.Id;
		sac.lead.Status = 'Untouched';
		sac.lead.LeadSource = 'cenveo store';
		sac.lead.Email = 'test.testing@cenveo.com';
		sac.lead.Street = 'AZ';
		sac.lead.City = 'PK';
		sac.lead.State = 'MK';
		sac.lead.Country = 'US';
		sac.lead.PostalCode = '25896';
		
		//Call controller method
		sac.refresh();
		
		//Assert
		System.assertEquals(1,sac.listOfLeads.size());
		
		//test stop			
		Test.stopTest();
    }
	
	//Test method for lead search base on Company and website same as Account Name and website
    static testmethod void leadTestCompAndWeb() {
    	
    	//Create user and insert
    	User u = createUser();
    	insert u;
    	Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
    	list< Account> accountList = new list<Account>();
	        accountList.add(new Account(Name='Polkomtel S.A.', recordTypeId = accRecordTypeId, Phone = '123456', Website = 'www.google.com', BillingStreet = 'st',
	        								 BillingCity = 'st', BillingState = 'st', BillingCountry = 'st', BillingPostalCode = '30303'));
	        accountList.add(new Account(Name='Dover Corporation', website = 'www.Simplyforce.com'));
	    system.runAs(u){    
        insert accountList;
        }
    	//List of lead
    	List<Lead> leadsToBeInserted = new List<Lead>();
    	Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Cenveo').getRecordTypeId();
    	//Add lead into list of lead
    	leadsToBeInserted.add(new Lead(FirstName = 'Test', RecordtypeId =recordTypeId,  LastName = 'Testing', OwnerId = u.id, Status = 'Untouched', LeadSource = 'cenveo Store', Email = 'test.testing@cenveo.com',
										Street ='AZ', City='PK', State='MK', Country='US', PostalCode='25896', Company = 'Polkomtel S.A.', Website = 'www.google.com' ));
		leadsToBeInserted.add(new Lead(FirstName = 'Test', RecordtypeId =recordTypeId, LastName = 'Leaad', OwnerId = u.id, Status = 'Untouched', Company = 'Polkomtel S.A.'));
		leadsToBeInserted.add(new Lead(FirstName = 'Priyanka', RecordtypeId =recordTypeId, LastName = 'Test', OwnerId = u.id, Status = 'Untouched', Company = 'Dover Corporation'));
		leadsToBeInserted.add(new Lead(FirstName = 'Sales', RecordtypeId =recordTypeId, LastName = 'tewst', Website='www.Simplyforce.com', Company = 'Dover Corporation'));
		
		//Insert lead
        system.runAs(u){
            insert leadsToBeInserted;
        }
        
		
		//Test start here
		Test.startTest();
		
		//Instantiate Controller
		SearchAccountsController sac = new SearchAccountsController();
		
		//Set controller properties
		sac.accountName = 'Polkomtel S.A.';
		sac.pageSize = 1;
		
		//Call controller method
		sac.refresh();
		
		//Assert
		System.assertEquals(2,sac.listOfLeads.size());
		
		//Controller's method call 
		sac.getPreviousButtonDisabled();
		sac.nextLead();
		
		//Assert here
		System.assertEquals(1,sac.tempListOfLead.size());
		
		//Controller's methods call
		sac.getNextButtonDisabled();
		sac.previousLead();
		
		//Assert
		System.assertEquals(1,sac.tempListOfLead.size());
		
		//Set lead properties
		sac.lead.LastName = 'Testing';
		
		//Call controller method
		sac.refresh();
		
		//Assert
		System.assertEquals(1,sac.listOfLeads.size());
		
		//Set lead properties	
		sac.lead.OwnerId = u.Id;
		sac.lead.Status = 'Untouched';
		sac.lead.LeadSource = 'cenveo store';
		sac.lead.Email = 'test.testing@cenveo.com';
		sac.lead.Street = 'AZ';
		sac.lead.City = 'PK';
		sac.lead.State = 'MK';
		sac.lead.Country = 'US';
		sac.lead.PostalCode = '25896';
		
		//Call controller method
		sac.refresh();
		
		//Assert
		System.assertEquals(1,sac.listOfLeads.size());
		
		//test stop			
		Test.stopTest();
    }
    
    //Test method for Opportunity search base on  Account Name 
    static testmethod void testOpportunitySearch() {
    	
    	//Create user and insert
    	User u = createUser();
    	insert u;
    	Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        //List of opportunity
    	List<Opportunity> opportunities = new List<Opportunity>();
		
		//Add opportunities into list
		opportunities.add(new Opportunity(Name = 'Test', RecordTypeId = recordTypeId, Product_Description__c = 'PD', CloseDate = Date.today(), Projected_Invoice_Date__c = Date.today().addDays(2), 
    								Type = 'Existing Customer - New Business', StageName = 'Decision', Probability = 10));
		opportunities.add(new Opportunity(Name = 'Hello Opportunity', RecordTypeId = recordTypeId, Product_Description__c = 'PD', CloseDate = Date.today(), Projected_Invoice_Date__c = Date.today().addDays(2), 
    								Type = 'Existing Customer - New Business', StageName = 'Decision', Probability = 10));
    	
    	//Insert list of opportunity							
		insert opportunities;
		
		//Test start here
		Test.startTest();
		
		//Instantiate Controller
		SearchAccountsController sac = new SearchAccountsController();
		
		//Set properties
		sac.opp.Name = 'PD';
		sac.refresh();
		
		//Assert
		//System.assertEquals(2,sac.opportunities.size());
		
		//Test stop
		Test.stopTest();
		
    }
    
    //Test method for lead search base on Company and website same as Account Name and website
    static testmethod void testOpportunityWithAccSearch() {
    	
    	//Create user and insert
    	User u = createUser();
    	insert u;
    	Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
    	//List of Account
        
    	list< Account> accountList = new list<Account>();
	        accountList.add(new Account(Name='Polkomtel S.A.', recordTypeId = recordTypeId, Phone = '123456', Website = 'www.google.com', BillingStreet = 'st',
	        								 BillingCity = 'st', BillingState = 'st', BillingCountry = 'st', BillingPostalCode = '30303'));
	        accountList.add(new Account(Name='Dover Corporation', recordTypeId = recordTypeId, website = 'www.Simplyforce.com'));
	        
        system.runAs(u){
            insert accountList;
        }
        //List of account for hold query result
        List<Account> accounts = [Select Id,Name from Account];
        
        //List of ooprtunity
    	List<Opportunity> opportunities = new List<Opportunity>();
		Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
		//test reocrd of Opportunity
		opportunities.add(new Opportunity(Name = 'Test', recordTypeId = oppRecordTypeId, Product_Description__c = 'PD', CloseDate = Date.today(), Projected_Invoice_Date__c = Date.today().addDays(2), 
    								Type = 'Existing Customer - New Business', StageName = 'Decision', AccountId = accounts[0].Id, Probability = 10));
		opportunities.add(new Opportunity(Name = 'Hello Opportunity', recordTypeId = oppRecordTypeId ,Product_Description__c = 'PD', CloseDate = Date.today(), Projected_Invoice_Date__c = Date.today().addDays(2), 
    								Type = 'Existing Customer - New Business', StageName = 'Decision', AccountId = accounts[1].Id, Probability = 10));
		
		//Opportunities insert						
		insert opportunities;
		
		//Test start here
		Test.startTest();
		
		//Instantiate Controller
		SearchAccountsController sac = new SearchAccountsController();
		
		//Set properties
		sac.accountName = 'Dover';
		sac.refresh();
		
		//Assert
		System.assertEquals(1,sac.opportunities.size());
		
		//Test Stop
		Test.stopTest();
		
    }
    
    public static User createUser() {
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'tesusr', email = 'testinguser@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing User', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id, ManagerId = UserInfo.getUserId(),
            timezonesidkey = 'America/Los_Angeles',Westrock_User__c  = false, username = 'testinguser@newtest.com',EmployeeNumber = '12321');
           
        return u;
    }
}