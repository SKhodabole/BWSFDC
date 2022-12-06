public with sharing class InvokeAccountSalesDataMerge {
  public pagereference runBatch(){
  
    String strCurrYear = '';
   /* SalesDataMergeSetting__c sdm = SalesDataMergeSetting__c.getValues('SalesDataYear');
    if(sdm != null && sdm.Year__c != null)
        strCurrYear = sdm.Year__c; */
  
    //String strCurrYear = String.valueOf(Date.today().Year());
    System.debug('strCurrYear = ' + strCurrYear); 
    String str1 = '';
    if(strCurrYear == ''){
        str1 = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c';
    }
    else{
        str1 = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c WHERE Year__c = \'' + strCurrYear + '\'';
    }
    AccountSalesDataMerge uai1 = new AccountSalesDataMerge(str1);
    id batchstart1= Database.executeBatch(uai1, 10);
    return null;
  }
}