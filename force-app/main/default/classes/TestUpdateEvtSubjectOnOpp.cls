/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class TestUpdateEvtSubjectOnOpp{
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
    
    static testMethod void myUnitTest1() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
        System.runAs(managerUser){
       Account testAcc = new Account(Name='test acc', RecordTypeId = accRecordTypeId);
       insert testAcc;
       //List<RecordType> recTypes = [select id, name from RecordType where SObjectType='opportunity' and Name='CCRS'];
       Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
       Opportunity opp = new Opportunity(Name='test opp', AccountId=testAcc.id, LeadSource='CCRS',closeDate=Date.today(),
                                         type='Creative Brief',stageName='1. Prospecting', RecordTypeId = oppRecordTypeId);
      /* if(recTypes != null && recTypes.size() > 0){
           opp.recordTypeId = recTypes.get(0).Id;
       }*/
       insert opp;
       
       Account acc = new Account(Name='Test Acc', RecordTypeId = accRecordTypeId);
       insert acc;
       Test.startTest();
       Event evt1 = new Event(whatId = opp.Id, 
                            ownerId = UserInfo.getUserId(), 
                            Subject = 'email:',
                            StartDateTime = System.Now().addDays(2), 
                            EndDateTime = System.Now().addDays(8) );
       insert evt1;
       
       Task tsk = new Task(whatId = opp.Id, 
		                        ownerId = UserInfo.getUserId(), 
		                        Subject = 'email:', 
		                        ActivityDate = Date.Today(),
		                        status='Open' );
		insert tsk;
		
       evt1.StartDateTime = System.Now().addDays(-2);
       evt1.EndDateTime = System.Now().addDays(-2);
       update evt1;
       
       delete evt1;
       
       Event evt2 = new Event(whatId = acc.Id, 
                            ownerId = UserInfo.getUserId(), 
                            Subject = 'email:',
                            StartDateTime = System.Now().addDays(2), 
                            EndDateTime = System.Now().addDays(8) );
       insert evt2 ;
       Task tsk2 = new Task(whatId = acc.Id, 
		                        ownerId = UserInfo.getUserId(), 
		                        Subject = 'email:', 
		                        ActivityDate = Date.Today(),
		                        status='Open' );
		insert tsk2;
       evt2.StartDateTime = System.Now().addDays(-2);
       evt2.EndDateTime = System.Now().addDays(-2);
       update evt2;
       
       delete evt2;
       Test.stopTest();
        }
    }
    
    
   /* static testMethod void myUnitTest2() {
       Account testAcc = new Account(Name='test acc');
       insert testAcc;
       //List<RecordType> recTypes = [select id, name from RecordType where SObjectType='opportunity' and Name='CCRS'];
       Opportunity opp = new Opportunity(Name='test opp', AccountId=testAcc.id, LeadSource='CCRS',closeDate=Date.today(),
                                         type='Creative Brief',stageName='1. Prospecting');
       //if(recTypes != null && recTypes.size() > 0){
       //    opp.recordTypeId = recTypes.get(0).Id;
      // }
       insert opp;
       Account acc = new Account(Name='Test Acc');
       insert acc;
       Test.startTest();
       Task tsk = new Task(whatId = opp.Id, 
                            ownerId = UserInfo.getUserId(), 
                            Subject = 'email:', 
                            ActivityDate = Date.Today(),
                            status='Open' );
       insert tsk;
       
       tsk.status = 'Completed';
       update tsk;
       
       delete tsk;
       
       Task tsk2 = new Task(whatId = acc.Id, 
                            ownerId = UserInfo.getUserId(), 
                            Subject = 'email:', 
                            ActivityDate = Date.Today(),
                            status='Open' );
       insert tsk2;
       
       tsk2.status = 'Completed';
       update tsk2;
       
       delete tsk2;
       Test.stopTest();
    }*/
}