global with sharing class RollupAccountBudgetAndSalesToParent implements Database.Batchable<sobject>{
  global String strQuery = 'Select id from Account where Type = \'Parent\' AND RecordType.DeveloperName = \'Cenveo\'';

  global Database.QueryLocator start(Database.BatchableContext bc){
    return Database.getQueryLocator(strQuery);
  }

  global void execute(Database.batchableContext bc, List<Account> sdList){
      Set<Id> parentIds = new Set<Id>();
      for(Account acc : sdList){
          parentIds.add(acc.Id);
      }
      Map<Id, Account> mapParentAccountsToUpdate = new Map<Id, Account>();
      //get immediate child 
      List<Account> childAccs = [Select Id from Account where ParentId IN: parentIds AND Type != 'Parent'];

 	//query to find agggregate results for parent account
      AggregateResult[] groupedChildAccountResults = [ SELECT ParentId,
                                    SUM(Current_Year_Budget__c)currentYearBudget,
                                    SUM(Current_YTD_Budget__c)currentYTDBudget,
                                    SUM(Current_YTD_Sales__c)currentYTDSales,
                                    SUM(YTD_Forecast__c)YTDForecast,
                                    SUM(Prior_YTD_Sales__c)priorYTDSales,
                                    SUM(BOY_Forecast__c)boyForecast,
                                    SUM(PY_Budget__c)pyBudget,
                                    SUM(NY_Budget__c)nyBudget,
                                    SUM(NY_Forecast__c)nyForecast,
                                    SUM(Previous_12Mo_Sales__c)previous12MoSales,
                                    SUM(Previous_2Last_12Mo_Sales__c)previous2Last12MoSales,
                                    SUM(X2011_Sales__c)sales2011,
                                    SUM(X2012_Sales__c)sales2012,
                                    SUM(X2013_Sales__c)sales2013,
                                    SUM(X2014_Sales__c)sales2014,
                                    SUM(X2015_Sales__c)sales2015,
                                    SUM(X2016_Sales__c)sales2016,
                                    SUM(X2017_Sales__c)sales2017,
                                    SUM(X2018_Sales__c)sales2018,
                                    SUM(X2019_Sales__c)sales2019,
                                    SUM(X2020_Sales__c)sales2020,
                                    SUM(YTD_GM__c)YTDGMDollars,
                                    SUM(Budget_2015__c)budget2015,
                                    SUM(x2015_GM__c)GMDollars2015,
                                    SUM(Prior_Year_Sales__c) priorYearSales
                                 FROM Account
                               WHERE ParentId in: parentIds
                               And Type != 'Parent'
                               GROUP BY ParentId ];
                               
                        
      // loop over aggregated results
      for( AggregateResult groupedChildAccResult : groupedChildAccountResults ) {
		Id parentId = String.valueOf(groupedChildAccResult.get('ParentId'));
        if( parentId != null ) {
            Account parentAccount = new Account(Id = parentId);
            parentAccount = parentAccountRollUpMappings( parentAccount, groupedChildAccResult );
            mapParentAccountsToUpdate.put( parentAccount.Id, parentAccount );
        }
        
      }

      if(mapParentAccountsToUpdate != null && mapParentAccountsToUpdate.size() > 0) {
          update mapParentAccountsToUpdate.values();
      }
      
      
  }

  global void finish(Database.batchableContext bc) {
  
  }
    
// method to return parent account having rolled-up results
  public static Account parentAccountRollUpMappings(Account parentAccount, AggregateResult groupedChildAccResult) {

      Object currentYearBudget = groupedChildAccResult.get('currentYearBudget');
      Object currentYTDBudget = groupedChildAccResult.get('currentYTDBudget');
      Object currentYTDSales = groupedChildAccResult.get('currentYTDSales');
      Object YTDForecast = groupedChildAccResult.get('YTDForecast');
      Object priorYTDSales = groupedChildAccResult.get('priorYTDSales');
      Object boyForecast = groupedChildAccResult.get('boyForecast');
      Object pyBudget = groupedChildAccResult.get('pyBudget');
      Object nyBudget = groupedChildAccResult.get('nyBudget');
      Object nyForecast = groupedChildAccResult.get('nyForecast');
      Object budget2015 = groupedChildAccResult.get('budget2015');
      Object previous12MoSales = groupedChildAccResult.get('previous12MoSales');
      Object previous2Last12MoSales = groupedChildAccResult.get('previous2Last12MoSales');
      Object priorYearSales = groupedChildAccResult.get('priorYearSales');
    
      Object sales2011 = groupedChildAccResult.get('sales2011');
      Object sales2012 = groupedChildAccResult.get('sales2012');
      Object sales2013 = groupedChildAccResult.get('sales2013');
      Object sales2014 = groupedChildAccResult.get('sales2014');
      Object sales2015 = groupedChildAccResult.get('sales2015');
      Object sales2016 = groupedChildAccResult.get('sales2016');
      Object sales2017 = groupedChildAccResult.get('sales2017');
      Object sales2018 = groupedChildAccResult.get('sales2018');
      Object sales2019 = groupedChildAccResult.get('sales2019');
      Object sales2020 = groupedChildAccResult.get('sales2020');

      parentAccount.Current_Year_Budget__c = returnDecimalFromObject( currentYearBudget );
      parentAccount.Current_YTD_Budget__c = returnDecimalFromObject( currentYTDBudget );
      parentAccount.Current_YTD_Sales__c = returnDecimalFromObject( currentYTDSales );
      parentAccount.YTD_Forecast__c = returnDecimalFromObject( YTDForecast );
      parentAccount.Prior_YTD_Sales__c = returnDecimalFromObject( priorYTDSales );
      parentAccount.BOY_Forecast__c = returnDecimalFromObject( boyForecast );
      parentAccount.PY_Budget__c = returnDecimalFromObject( pyBudget );
      parentAccount.NY_Budget__c = returnDecimalFromObject( nyBudget );
      parentAccount.NY_Forecast__c = returnDecimalFromObject( nyForecast );
      parentAccount.Budget_2015__c = returnDecimalFromObject( budget2015 );
      parentAccount.Previous_12Mo_Sales__c = returnDecimalFromObject(previous12MoSales );
      parentAccount.Previous_2Last_12Mo_Sales__c = returnDecimalFromObject( previous2Last12MoSales );
      parentAccount.Prior_Year_Sales__c = returnDecimalFromObject(priorYearSales);
    
      parentAccount.X2011_Sales__c = returnDecimalFromObject( sales2011 );
      parentAccount.X2012_Sales__c = returnDecimalFromObject( sales2012 );
      parentAccount.X2013_Sales__c = returnDecimalFromObject( sales2013 );
      parentAccount.X2014_Sales__c = returnDecimalFromObject( sales2014 );
      parentAccount.X2015_Sales__c = returnDecimalFromObject( sales2015 );
      parentAccount.X2016_Sales__c = returnDecimalFromObject( sales2016 );
      parentAccount.X2017_Sales__c = returnDecimalFromObject( sales2017 );
      parentAccount.X2018_Sales__c = returnDecimalFromObject( sales2018 );
      parentAccount.X2019_Sales__c = returnDecimalFromObject( sales2019 );
      parentAccount.X2020_Sales__c = returnDecimalFromObject( sales2020 );
      // Need to create fields for 2021 and modify the code accordingly

      Object YTDGMDollars = groupedChildAccResult.get('YTDGMDollars');
      Object GMDollars2015 = groupedChildAccResult.get('GMDollars2015');

      // update GM Fields
      parentAccount.YTD_GM__c = returnDecimalFromObject( YTDGMDollars );
      parentAccount.x2015_GM__c = returnDecimalFromObject( GMDollars2015 );

      return parentAccount;
  }
  public static Decimal returnDecimalFromObject( Object objectValue ) {
    Decimal decimalValue = objectValue != null ? (Decimal) objectValue : null;
    return decimalValue;
  }
}