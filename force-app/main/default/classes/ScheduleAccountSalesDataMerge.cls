global with sharing class ScheduleAccountSalesDataMerge implements Schedulable {
  public static String CRON_EXP = '0 0 0 3 9 ? 2030';
  
  global void execute(SchedulableContext sc){
    //String strCurrYear = String.valueOf(Date.today().Year());
    String strCurrYear = '';
  /*  SalesDataMergeSetting__c sdm = SalesDataMergeSetting__c.getValues('SalesDataYear');
    if(sdm != null && sdm.Year__c != null)
        strCurrYear = sdm.Year__c; */
    
        
    System.debug('strCurrYear = ' + strCurrYear); 
    
    String strQuery = '';
    if(strCurrYear == ''){
        strQuery = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c';
    }
    else{
        strQuery = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c WHERE Year__c = \'' + strCurrYear + '\'';
    }
    
    
    if(Test.isRunningTest()){
      strQuery = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c LIMIT 5';
    }
    
    AccountSalesDataMerge rr = new AccountSalesDataMerge (strQuery);
       //rr.strQuery = strQuery;
      id batchstart= Database.executeBatch(rr, 10);
  }
}