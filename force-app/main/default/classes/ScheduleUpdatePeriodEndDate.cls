global with sharing class ScheduleUpdatePeriodEndDate implements Schedulable{
	public static String CRON_EXP = '0 0 0 3 9 ? 2040';
	
	global void execute(SchedulableContext sc){
		String strQuery = 'SELECT Id, Year__c, Period__c, Period_End_Date__c FROM Sales_Data__c where Period_End_Date__c = null';
		
		if(Test.isRunningTest()){
			strQuery = 'SELECT Id, Year__c, Period__c, Period_End_Date__c FROM Sales_Data__c where Period_End_Date__c = null LIMIT 1';
		}
		
		
		UpdatePeriodEndDateBatch rr = new UpdatePeriodEndDateBatch();
   		rr.strQuery = strQuery;
    	id batchstart= Database.executeBatch(rr);
	}
}