@isTest
private class TestupdateTaskSubjectOnOpp {
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
	//Test method
    static testMethod void myUnitTest() {
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
		User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
        System.runAs(managerUser){
            
        
		Account testAcc = new Account(Name='test acc' , RecordTypeId = accRecordTypeId);
       	insert testAcc;
		Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
		//List<RecordType> recTypes = [select id, name from RecordType where SObjectType='opportunity' and Name='CCRS'];
		Opportunity opp = new Opportunity(Name='test opp', AccountId=testAcc.id, LeadSource='CCRS',closeDate=Date.today(),
                                         type='Creative Brief',stageName='1. Prospecting', RecordTypeId = oppRecordTypeId);
      
		insert opp;
		
		Account acc = new Account(Name='Test Acc', RecordTypeId = accRecordTypeId);
		insert acc;
		Test.startTest();
		Task tsk = new Task(whatId = opp.Id, 
		                        ownerId = UserInfo.getUserId(), 
		                        Subject = 'email:', 
		                        ActivityDate = Date.Today(),
		                        status='Open' );
		insert tsk;
		
		Event evt1 = new Event(whatId = opp.Id, 
                            ownerId = UserInfo.getUserId(), 
                            Subject = 'email:',
                            StartDateTime = System.Now().addDays(2), 
                            EndDateTime = System.Now().addDays(8) );
       	insert evt1;
			   
	   	List<Opportunity> oppor = [Select Id, Open_Activities__c FROM Opportunity];
	   	
	   	system.assert(true,oppor[0].Open_Activities__c != null);
	   
	   	tsk.status = 'Completed';
		update tsk;
	   	
		delete tsk;
		delete evt1;
		
		Opportunity oppA = [Select Id, Open_Activities__c FROM Opportunity WHERE Id =: opp.Id];
		
		system.assert(true,oppA.Open_Activities__c == null);
			   
		Task tsk2 = new Task(whatId = acc.Id, 
		                        ownerId = UserInfo.getUserId(), 
		                        Subject = 'email:', 
		                        ActivityDate = Date.Today(),
		                        status='Open' );
		insert tsk2;
		
		Event evt2 = new Event(whatId = acc.Id, 
                            ownerId = UserInfo.getUserId(), 
                            Subject = 'email:',
                            StartDateTime = System.Now().addDays(2), 
                            EndDateTime = System.Now().addDays(8) );
       	insert evt2;
       	
       	Account account = [Select Id, Open_Activities__c FROM Account WHERE Id =: acc.Id];
		
		system.assert(true,account.Open_Activities__c != null);
		
		tsk2.status = 'Completed';
		update tsk2;
			   
		delete tsk2;
		delete evt2;
		
		Account accountA = [Select Id, Open_Activities__c FROM Account WHERE Id =: acc.Id];
		
		system.assert(true,accountA.Open_Activities__c == null);
			   
		Test.stopTest();
         }   
	}
}