/*
    Apex class to calcualte account sales data rollups
*/
global without sharing class BatchAccountSalesDataRollup implements Database.Batchable<sobject>, Database.Stateful {

    public String strQuery = 'Select Id From Account Where Type != \'Parent\' and Recordtype.DeveloperName = \'Cenveo\'  Order By CreatedDate DESC';
    public Set<Id> setAccountIds;
    
    public static Set<Id> accountIds;
    
    public static void runAccountSalesDataRollupForAccounts( Set<Id> setAccountIdVal ){

          String strQuery;
          BatchAccountSalesDataRollup clsAccountSalesDataRollup = new BatchAccountSalesDataRollup();
          clsAccountSalesDataRollup.setAccountIds = setAccountIdVal;
          clsAccountSalesDataRollup.strQuery =  ' Select Id From Account Where Type != \'Parent\' and Recordtype.DeveloperName = \'Cenveo\'  And Id in : setAccountIds '
                                              + ' Order By CreatedDate DESC ';

          id batchstart = Database.executeBatch(clsAccountSalesDataRollup,1);

    }

    global Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.batchableContext bc, List<Account> listAccount ) {

        List<Sales_Data__c> listSalesdata = [ SELECT Id, GM__c, GMDollars__c, Margin_Sales_Dollars__c, Account__c,
                                                     Budget_Amount__c, Year__c, Period__c,
                                                     Actual_Amount__c, Forecast_Amount__c
                                              FROM Sales_Data__c
                                              Where Account__c in: listAccount
                                              Order By Account__c
                                             ]; 
        accountIds = new Set<Id>();
        for( Account acc : listAccount ) {
            accountIds.add( acc.Id );   
        }

        /*AccountSalesDataRollup clsAccSalesRollup = new AccountSalesDataRollup(' Select Id Form Sales_Data__c ');
        AccountSalesDataRollup.executeCal = true;
        clsAccSalesRollup.calcualteAccountSalesDataRollup( listSalesdata );*/
        AccountSalesDataRollupAsFiscalYear clsAccSalesRollup = new AccountSalesDataRollupAsFiscalYear();
        //AccountSalesDataRollupClone.executeCal = true;
        clsAccSalesRollup.calcualteAccountSalesDataRollup(listSalesdata);

    }

    global void finish(Database.batchableContext bc){

        //AccountSalesDataRollup clsAccSalesRollup = new AccountSalesDataRollup(' Select Id Form Sales_Data__c ');
        AccountSalesDataRollupAsFiscalYear clsAccSalesRollup = new AccountSalesDataRollupAsFiscalYear();
        clsAccSalesRollup.finishActions(bc);

        RollupAccountBudgetAndSalesToParent r = new RollupAccountBudgetAndSalesToParent();
        Database.executeBatch(r, 10);
        
    }
}