/*
	Apex class to schedule AccountSalesDataRollup Batch
*/
global with sharing class ScheduleAccountSalesDataRollup implements Schedulable {
  public static String CRON_EXP = '0 0 0 3 9 ? 2030';

  global void execute(SchedulableContext sc){
    String strQuery = 'SELECT Id, GM__c, GMDollars__c, Margin_Sales_Dollars__c, Account__c, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c Order By Account__c ';
    if(Test.isRunningTest()){
      strQuery = 'SELECT Id, GM__c, GMDollars__c, Margin_Sales_Dollars__c, Account__c, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c Order By Account__c LIMIT 1';
    }

    AccountSalesDataRollup rr = new AccountSalesDataRollup(strQuery);
       //rr.strQuery = strQuery;
      id batchstart= Database.executeBatch(rr);
  }
}