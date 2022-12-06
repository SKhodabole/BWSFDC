@isTest
private class Test_UserTrigger {

    //Setup test data first. This will be available in the entire class
	@testSetup static void setup() {
	
		//Pul the System Admin Profile
		Profile p = [select id from profile where name='System Administrator'];
        
        String name = 'A-test1';
        User managerUser = new User(Alias = name, Email = name + '@asdfg.junk', EmailEncodingKey = 'UTF-8',
            FirstName = 'Test', lastname = name, LanguageLocaleKey = 'en_US', LocaleSIDKey = 'en_US',
            Profileid = p.Id, TimezoneSIDKey = 'America/Los_Angeles', Username = name + '@asdfg.junk',EmployeeNumber = '101');
        
        insert managerUser;
        
        User u = new User(alias = 'tesusr', email = 'testinguser@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing User', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id, ManagerId = UserInfo.getUserId(),
            timezonesidkey = 'America/Los_Angeles',Westrock_User__c  = false, username = 'testinguser@newtest.com',EmployeeNumber = '12321');
        insert u;
        //Stamp manager of current user
        update new User(Id = u.Id, ManagerId = managerUser.Id);
    }
	
	//Test if the manager is updated than Opporutnity owner is also updated
	static testmethod void testOpportunityUpdate() {
		
		//Current User
		User user = [Select Id, ManagerId, Manager.Email,Email from User where Email = 'testinguser@newtest.com'];
		Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
		//Create Test data
		Opportunity opp = new Opportunity(Name = 'Test', StageName = 'Test', CloseDate = Date.today(), OwnerId = user.Id, RecordTypeId = recordTypeId);
		
		//Start Testing from here
		Test.startTest();
		
		//insert opp
		insert opp;
		
		//Check if the Manager Email and Regional VP is updated on opp
		opp = [Select Manager_Email__c from Opportunity where Id =: opp.Id];
		//System.assert(opp.Manager_Email__c != null);
		//System.assertEquals(user.Manager.Email, opp.Manager_Email__c);
		
		//Nullify the User's  Manager
		System.runAs(user) {
			
			//Stamp manager of current user
        	update new User(Id = user.Id, ManagerId = null,Email = 'Testing@Test.com');
		}
		
		//Check if the Manager Email and Regional VP is updated on opp
		opp = [Select Manager_Email__c from Opportunity where Id =: opp.Id];
		System.assert(opp.Manager_Email__c == null);
		
		//Stop Testing here
		Test.stopTest();
	}
}