@isTest
private class Test_ScheduleBatchAccountSalesDataRollup {
	
	//Test method
    static testMethod void myUnitTest() {
		
		//Test start here
		Test.startTest();
		
		//String for cron expression
		String chron = '0 0 23 * * ?';
		
		//Insatnce of Scheduler
		ScheduleBatchAccountSalesDataRollup sc = new ScheduleBatchAccountSalesDataRollup();
		
		//Schedule job
		System.schedule('Schedule Name', chron, sc);
		
		//Test stop here
		Test.stopTest();
     }
}