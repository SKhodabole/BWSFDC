@isTest
private class Test_ScheduleUpdatePeriodEndDate {
	
	//Test method
    static testMethod void myUnitTest() {
		
		//Test start here
		Test.startTest();
		
		//String for cron expression
		String chron = '0 0 23 * * ?';
		
		//Insatnce of Scheduler
		ScheduleUpdatePeriodEndDate sc = new ScheduleUpdatePeriodEndDate();
		
		//Schedule job
		System.schedule('Schedule Name', chron, sc);
		
		//Test stop here
		Test.stopTest();
     }
}