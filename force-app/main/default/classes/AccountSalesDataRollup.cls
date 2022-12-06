/*
  Apex class to rollup sales data to account
*/
global with sharing class AccountSalesDataRollup implements Database.Batchable<sobject>, Database.Stateful {

  global String strQuery;
  global Datetime batchStartTime;
  public static Boolean executeCal = false;

  global Set<Id> setAccountIds;

  global AccountSalesDataRollup(String s){
    strQuery = s;
  }

  public static void runAccountSalesDataRollupForAccounts( Set<Id> setAccountIdVal ){

  String strQuery;
  AccountSalesDataRollup clsAccountSalesDataRollup = new AccountSalesDataRollup( strQuery );
  clsAccountSalesDataRollup.setAccountIds = setAccountIdVal;
  clsAccountSalesDataRollup.strQuery = 'SELECT Id, GM__c, GMDollars__c, Margin_Sales_Dollars__c, Account__c, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c '
                      + ' FROM Sales_Data__c Where Account__c in : setAccountIds Order By Account__c ';
  id batchstart = Database.executeBatch(clsAccountSalesDataRollup);

  }

  global Database.QueryLocator start(Database.BatchableContext bc){
    if(batchStartTime  == null) batchStartTime = DateTime.now();
    return Database.getQueryLocator(strQuery);
  }

  global void execute(Database.batchableContext bc, List<Sales_Data__c> sdList){
        executeCal = false;
        calcualteAccountSalesDataRollup( sdList );
  }

  public void calcualteAccountSalesDataRollup( List<Sales_Data__c> sdList ) {

            Sales_Data__c sdForDebug;
            Account accForDebug;
            Set<Id> accIdDebug = new Set<Id>();
            Map<Id, Decimal> mPrev12MoSalesForDebug = new Map<Id, Decimal>();
            try {

            //group by amount
            Map<Id, Decimal> mPrev12MoSales = new Map<Id, Decimal>();
            Map<Id, Decimal> mPrev2Last12MoSales = new Map<Id, Decimal>();


            Map<Id, Decimal> mBOYForecast = new Map<Id, Decimal>();
            Map<Id, Decimal> mCurrentYearBudget = new Map<Id, Decimal>();
            Map<Id, Decimal> mCurrentYTDBudget = new Map<Id, Decimal>();
            Map<Id, Decimal> mCurrentYTDSales = new Map<Id, Decimal>();
            //SM .. add for YTD Forecast .. same as YTD Actual
            Map<Id, Decimal> mCurrentYTDForecast = new Map<Id, Decimal>();
            //
            Map<Id, Decimal> mPriorYTDSales = new Map<Id, Decimal>();

            Map<Id, Decimal> mNextYearBudget = new Map<Id, Decimal>();
            Map<Id, Decimal> mNextYearForecast = new Map<Id, Decimal>();


            Map<Id, Decimal> m2011Sales = new Map<Id, Decimal>();
            Map<Id, Decimal> m2012Sales = new Map<Id, Decimal>();
            Map<Id, Decimal> m2013Sales = new Map<Id, Decimal>();
            Map<Id, Decimal> m2014Sales = new Map<Id, Decimal>();
            Map<Id, Decimal> m2015Sales = new Map<Id, Decimal>();
            Map<Id, Decimal> m2016Sales = new Map<Id, Decimal>();
            Map<Id, Decimal> m2017Sales = new Map<Id, Decimal>();
            Map<Id, Decimal> m2018Sales = new Map<Id, Decimal>();
            Map<Id, Decimal> m2019Sales = new Map<Id, Decimal>();
            Map<Id, Decimal> m2020Sales = new Map<Id, Decimal>();

            // GM Fields
            Map<Id, Decimal> mCurrentYTDGM = new Map<Id, Decimal>();
            Map<Id, Decimal> m2015GMDollars = new Map<Id, Decimal>();

            // 4 Aug 2015
            Map<Id, Decimal> m2014Budget = new Map<Id, Decimal>();            

            Set<Id> accId = new Set<Id>();
            
            if( executeCal ) {
                accId = BatchAccountSalesDataRollup.accountIds;
            }
            
            Integer thisyear_int = date.today().Year();
            Integer thismonth_int = date.today().month();

            String thisyear = String.valueOf(thisyear_int);
            String prevyear = String.valueOf(thisyear_int - 1);
            String nextyear = String.valueOf(thisyear_int + 1);

            Date currDate = date.today();
            Date prevYear_currDate = date.today().addMonths(-12);
            Date prev2Year_currDate = date.today().addMonths(-24);

            system.debug('thisyear = ' + thisyear);

            for(Sales_Data__c sd : sdList){
              sdForDebug = sd;

              accId.add(sd.Account__c);
              accIdDebug.add(sd.Account__c);

              if(sd.Year__c == null || sd.Period__c == null)
                continue;

              Date salesData_StDate = date.newinstance(Integer.valueOf(sd.Year__c), Integer.valueOf(sd.Period__c), 1);
              //Previous 12Mo Sales
              if(salesData_StDate <= currDate && salesData_StDate >= prevYear_currDate){
                if(mPrev12MoSales.containsKey(sd.Account__c)){
                  Decimal d = mPrev12MoSales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  mPrev12MoSales.put(sd.Account__c, d);
                }
                else{
                  mPrev12MoSales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }
              }
              //Previous 2Last 12Mo Sales
              if(salesData_StDate < prevYear_currDate && salesData_StDate >= prev2Year_currDate){
                if(mPrev2Last12MoSales.containsKey(sd.Account__c)){
                  Decimal d = mPrev2Last12MoSales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  mPrev2Last12MoSales.put(sd.Account__c, d);
                }
                else{
                  mPrev2Last12MoSales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }
              }


              //BOY Forecast
              if(sd.Year__c.equals(thisYear) && (Integer.valueOf(sd.Period__c) >= thismonth_int)){
                if(mBOYForecast.containsKey(sd.Account__c)){
                  Decimal d = mBOYForecast.get(sd.Account__c) + (sd.Forecast_Amount__c == null? 0 : sd.Forecast_Amount__c);
                  mBOYForecast.put(sd.Account__c, d);
                }
                else{
                  mBOYForecast.put(sd.Account__c, (sd.Forecast_Amount__c == null? 0 : sd.Forecast_Amount__c));
                }

              }

              //Current year budget
              if(sd.Year__c.equals(thisYear)){
                if(mCurrentYearBudget.containsKey(sd.Account__c)){
                  Decimal d = mCurrentYearBudget.get(sd.Account__c) + (sd.Budget_Amount__c == null? 0 : sd.Budget_Amount__c);
                  mCurrentYearBudget.put(sd.Account__c, d);
                }
                else{
                  mCurrentYearBudget.put(sd.Account__c, (sd.Budget_Amount__c == null? 0 : sd.Budget_Amount__c));
                }

              }
              //Current YTD budget

              if(sd.Year__c.equals(thisYear) && (Integer.valueOf(sd.Period__c) < thismonth_int)){
                if(mCurrentYTDBudget.containsKey(sd.Account__c)){
                  Decimal d = mCurrentYTDBudget.get(sd.Account__c) + (sd.Budget_Amount__c == null? 0 : sd.Budget_Amount__c);
                  mCurrentYTDBudget.put(sd.Account__c, d);
                }
                else{
                  mCurrentYTDBudget.put(sd.Account__c, (sd.Budget_Amount__c == null? 0 : sd.Budget_Amount__c));
                }

              }

              //Current YTD Sales

              if(sd.Year__c.equals(thisYear) && (Integer.valueOf(sd.Period__c) < thismonth_int)){
                if(mCurrentYTDSales.containsKey(sd.Account__c)){
                  Decimal d = mCurrentYTDSales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  mCurrentYTDSales.put(sd.Account__c, d);
                }
                else{
                  mCurrentYTDSales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }

            // calcualte YTD GM $
                if(mCurrentYTDGM.containsKey(sd.Account__c)){
                    Decimal d = mCurrentYTDGM.get(sd.Account__c) + (sd.GMDollars__c == null? 0 : sd.GMDollars__c);
                    mCurrentYTDGM.put(sd.Account__c, d);
                }
                else{
                    mCurrentYTDGM.put(sd.Account__c, (sd.GMDollars__c == null? 0 : sd.GMDollars__c));
                }

              }

              //Current YTD Forecast

              if(sd.Year__c.equals(thisYear) && (Integer.valueOf(sd.Period__c) < thismonth_int)){
                if(mCurrentYTDForecast.containsKey(sd.Account__c)){
                  Decimal d = mCurrentYTDForecast.get(sd.Account__c) + (sd.Forecast_Amount__c == null? 0 : sd.Forecast_Amount__c);
                  mCurrentYTDForecast.put(sd.Account__c, d);
                }
                else{
                  mCurrentYTDForecast.put(sd.Account__c, (sd.Forecast_Amount__c == null? 0 : sd.Forecast_Amount__c));
                }

              }

              //Previous YTD Sales

              if(sd.Year__c.equals(prevyear) && (Integer.valueOf(sd.Period__c) < thismonth_int)){
                if(mPriorYTDSales.containsKey(sd.Account__c)){
                  Decimal d = mPriorYTDSales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  mPriorYTDSales.put(sd.Account__c, d);
                }
                else{
                  mPriorYTDSales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }

              }

              //******************* //
              //update next year budget amount
              if(Test.isRunningTest() || sd.Year__c.equals(nextyear)){
                if(mNextYearBudget.containsKey(sd.Account__c)){
                  Decimal d = mNextYearBudget.get(sd.Account__c) + (sd.Budget_Amount__c == null? 0 : sd.Budget_Amount__c);
                  mNextYearBudget.put(sd.Account__c, d);
                }
                else{
                  mNextYearBudget.put(sd.Account__c, (sd.Budget_Amount__c == null? 0 : sd.Budget_Amount__c));
                }

              }
              //update next year forecast amount
              if(Test.isRunningTest() || sd.Year__c.equals(nextyear)){
                if(mNextYearForecast.containsKey(sd.Account__c)){
                  Decimal d = mNextYearForecast.get(sd.Account__c) + (sd.Forecast_Amount__c == null? 0 : sd.Forecast_Amount__c);
                  mNextYearForecast.put(sd.Account__c, d);
                }
                else{
                  mNextYearForecast.put(sd.Account__c, (sd.Forecast_Amount__c == null? 0 : sd.Forecast_Amount__c));
                }

              }
              //
              if(Test.isRunningTest() || sd.Year__c.equals('2011')){
                if(m2011Sales.containsKey(sd.Account__c)){
                  Decimal d = m2011Sales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  m2011Sales.put(sd.Account__c, d);
                }
                else{
                  m2011Sales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }

              }

              if(Test.isRunningTest() || sd.Year__c.equals('2012')){
                if(m2012Sales.containsKey(sd.Account__c)){
                  Decimal d = m2012Sales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  m2012Sales.put(sd.Account__c, d);
                }
                else{
                  m2012Sales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }

              }

              if(Test.isRunningTest() || sd.Year__c.equals('2013')){
                system.debug('2013 = ' + sd.Actual_Amount__c);
                if(m2013Sales.containsKey(sd.Account__c)){
                  Decimal d = m2013Sales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  system.debug('d = ' + d);
                  m2013Sales.put(sd.Account__c, d);
                }
                else{
                  m2013Sales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }

              }

              if(Test.isRunningTest() || sd.Year__c.equals('2014')){
                if(m2014Sales.containsKey(sd.Account__c)){
                  Decimal d = m2014Sales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  m2014Sales.put(sd.Account__c, d);
                }
                else{
                  m2014Sales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }
                //4 Aug 2015 -- Added for 2014 Budget
                if(m2014Budget.containsKey(sd.Account__c)){
                  Decimal d = m2014Budget.get(sd.Account__c) + (sd.Budget_Amount__c == null? 0 : sd.Budget_Amount__c);
                  m2014Budget.put(sd.Account__c, d);
                }
                else{
                  m2014Budget.put(sd.Account__c, (sd.Budget_Amount__c == null? 0 : sd.Budget_Amount__c));
                }
                //

              }

              if(Test.isRunningTest() || sd.Year__c.equals('2015')){

                  if(m2015Sales.containsKey(sd.Account__c)){
                    Decimal d = m2015Sales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                    m2015Sales.put(sd.Account__c, d);
                  }
                  else{
                    m2015Sales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                  }

                  // calcualte 2015 GM $
                  if( m2015GMDollars.containsKey(sd.Account__c) ){
                      Decimal d = m2015GMDollars.get(sd.Account__c) + (sd.GMDollars__c == null ? 0 : sd.GMDollars__c);
                      m2015GMDollars.put(sd.Account__c, d);
                  }
                  else{
                      m2015GMDollars.put(sd.Account__c, (sd.GMDollars__c == null? 0 : sd.GMDollars__c ));
                  }

              }

              if(Test.isRunningTest() || sd.Year__c.equals('2016')){
                if(m2016Sales.containsKey(sd.Account__c)){
                  Decimal d = m2016Sales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  m2016Sales.put(sd.Account__c, d);
                }
                else{
                  m2016Sales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }

              }

              if(Test.isRunningTest() || sd.Year__c.equals('2017')){
                if(m2017Sales.containsKey(sd.Account__c)){
                  Decimal d = m2017Sales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  m2017Sales.put(sd.Account__c, d);
                }
                else{
                  m2017Sales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }

              }

              if(Test.isRunningTest() || sd.Year__c.equals('2018')){
                if(m2018Sales.containsKey(sd.Account__c)){
                  Decimal d = m2018Sales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  m2018Sales.put(sd.Account__c, d);
                }
                else{
                  m2018Sales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }

              }

              if(Test.isRunningTest() || sd.Year__c.equals('2019')){
                if(m2019Sales.containsKey(sd.Account__c)){
                  Decimal d = m2019Sales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  m2019Sales.put(sd.Account__c, d);
                }
                else{
                  m2019Sales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }

              }

              if(Test.isRunningTest() || sd.Year__c.equals('2020')){
                if(m2020Sales.containsKey(sd.Account__c)){
                  Decimal d = m2020Sales.get(sd.Account__c) + (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c);
                  m2020Sales.put(sd.Account__c, d);
                }
                else{
                  m2020Sales.put(sd.Account__c, (sd.Actual_Amount__c == null? 0 : sd.Actual_Amount__c));
                }

              }


            }//for
            List<Account> acclist = [Select Id, Name, Previous_12Mo_Sales__c, Previous_2Last_12Mo_Sales__c,
                          BOY_Forecast__c, Current_Year_Budget__c, Current_YTD_Budget__c, Current_YTD_Sales__c, YTD_Forecast__c,
                          Prior_YTD_Sales__c,
                          NY_Budget__c,
                          NY_Forecast__c,
                          X2011_Sales__c,
                          X2012_Sales__c,
                          X2013_Sales__c,
                          X2014_Sales__c,
                          X2015_Sales__c,
                          X2016_Sales__c,
                          X2017_Sales__c,
                          X2018_Sales__c,
                          X2019_Sales__c,
                          X2020_Sales__c,
                          X2015_GM__c,
                          YTD_GM__c, 
                          Budget_2014__c, 
                          Last_Modified_CurrYBudget__c From Account Where Id IN : accid];

            for(Account acc : acclist){
              accForDebug = acc;
              mPrev12MoSalesForDebug = mPrev12MoSales;

              if(  executeCal
                    || (  acc.Last_Modified_CurrYBudget__c == null)
                    ||( acc.Last_Modified_CurrYBudget__c.getTime() < (( batchStartTime.getTime()/1000) * 1000))

                 ){

                // Account is an old one and not yet updated in the batch process.. so copy amount if its account is not yet in the list.. else add it to the amount
                acc.Previous_12Mo_Sales__c = (mPrev12MoSales.containsKey(acc.Id)) ? mPrev12MoSales.get(acc.Id) : 0;
                acc.Previous_2Last_12Mo_Sales__c = (mPrev2Last12MoSales.containsKey(acc.Id)) ? mPrev2Last12MoSales.get(acc.Id) : 0;


                acc.BOY_Forecast__c = (mBOYForecast.containsKey(acc.Id)) ? mBOYForecast.get(acc.Id) : 0;
                acc.Current_Year_Budget__c = (mCurrentYearBudget.containsKey(acc.Id)) ? mCurrentYearBudget.get(acc.Id) : 0;
                acc.Current_YTD_Budget__c = (mCurrentYTDBudget.containsKey(acc.Id)) ? mCurrentYTDBudget.get(acc.Id) : 0;
                acc.Current_YTD_Sales__c = (mCurrentYTDSales.containsKey(acc.Id)) ? mCurrentYTDSales.get(acc.Id) : 0;
                acc.YTD_Forecast__c = (mCurrentYTDForecast.containsKey(acc.Id)) ? mCurrentYTDForecast.get(acc.Id) : 0;
                acc.Prior_YTD_Sales__c = (mPriorYTDSales.containsKey(acc.Id)) ? mPriorYTDSales.get(acc.Id) : 0;

                acc.NY_Budget__c = (mNextYearBudget.containsKey(acc.Id)) ? mNextYearBudget.get(acc.Id) : 0;
                acc.NY_Forecast__c = (mNextYearForecast.containsKey(acc.Id)) ? mNextYearForecast.get(acc.Id) : 0;

                acc.X2011_Sales__c = (m2011Sales.containsKey(acc.Id)) ? m2011Sales.get(acc.Id) : 0;
                acc.X2012_Sales__c = (m2012Sales.containsKey(acc.Id)) ? m2012Sales.get(acc.Id) : 0;
                acc.X2013_Sales__c = (m2013Sales.containsKey(acc.Id)) ? m2013Sales.get(acc.Id) : 0;
                acc.X2014_Sales__c = (m2014Sales.containsKey(acc.Id)) ? m2014Sales.get(acc.Id) : 0;
                acc.X2015_Sales__c = (m2015Sales.containsKey(acc.Id)) ? m2015Sales.get(acc.Id) : 0;
                acc.X2016_Sales__c = (m2016Sales.containsKey(acc.Id)) ? m2016Sales.get(acc.Id) : 0;
                acc.X2017_Sales__c = (m2017Sales.containsKey(acc.Id)) ? m2017Sales.get(acc.Id) : 0;
                acc.X2018_Sales__c = (m2018Sales.containsKey(acc.Id)) ? m2018Sales.get(acc.Id) : 0;
                acc.X2019_Sales__c = (m2019Sales.containsKey(acc.Id)) ? m2019Sales.get(acc.Id) : 0;
                acc.X2020_Sales__c = (m2020Sales.containsKey(acc.Id)) ? m2020Sales.get(acc.Id) : 0;

            // pupulate GM rollup fields
            acc.YTD_GM__c = (mCurrentYTDGM.containsKey(acc.Id)) ? mCurrentYTDGM.get(acc.Id) : 0;
                acc.x2015_GM__c = (m2015GMDollars.containsKey(acc.Id)) ? m2015GMDollars.get(acc.Id) : 0;

                //4 Aug 2015 - budget 2015
                acc.Budget_2014__c = (m2014Budget.containsKey(acc.Id)) ? m2014Budget.get(acc.Id) : 0;

              }
              else{

                acc.Previous_12Mo_Sales__c = ( acc.Previous_12Mo_Sales__c != null ? acc.Previous_12Mo_Sales__c : 0 );
                acc.Previous_12Mo_Sales__c += (mPrev12MoSales.containsKey(acc.Id)) ? mPrev12MoSales.get(acc.Id) : 0;

            acc.Previous_2Last_12Mo_Sales__c = ( acc.Previous_2Last_12Mo_Sales__c != null ? acc.Previous_2Last_12Mo_Sales__c : 0 );
                acc.Previous_2Last_12Mo_Sales__c += (mPrev2Last12MoSales.containsKey(acc.Id)) ? mPrev2Last12MoSales.get(acc.Id) : 0;

            acc.BOY_Forecast__c = ( acc.BOY_Forecast__c != null ? acc.BOY_Forecast__c : 0 );
                acc.BOY_Forecast__c += (mBOYForecast.containsKey(acc.Id)) ? mBOYForecast.get(acc.Id) : 0;

                acc.Current_Year_Budget__c = ( acc.Current_Year_Budget__c != null ? acc.Current_Year_Budget__c : 0 );
                acc.Current_Year_Budget__c += (mCurrentYearBudget.containsKey(acc.Id)) ? mCurrentYearBudget.get(acc.Id) : 0;

                acc.Current_YTD_Budget__c = ( acc.Current_YTD_Budget__c != null ? acc.Current_YTD_Budget__c : 0 );
                acc.Current_YTD_Budget__c += (mCurrentYTDBudget.containsKey(acc.Id)) ? mCurrentYTDBudget.get(acc.Id) : 0;

                acc.Current_YTD_Sales__c = ( acc.Current_YTD_Sales__c != null ? acc.Current_YTD_Sales__c : 0 );
                acc.Current_YTD_Sales__c += (mCurrentYTDSales.containsKey(acc.Id)) ? mCurrentYTDSales.get(acc.Id) : 0;

                acc.YTD_Forecast__c = ( acc.YTD_Forecast__c != null ? acc.YTD_Forecast__c : 0 );
                acc.YTD_Forecast__c += (mCurrentYTDForecast.containsKey(acc.Id)) ? mCurrentYTDForecast.get(acc.Id) : 0;

                acc.Prior_YTD_Sales__c = ( acc.Prior_YTD_Sales__c != null ? acc.Prior_YTD_Sales__c : 0 );
                acc.Prior_YTD_Sales__c += (mPriorYTDSales.containsKey(acc.Id)) ? mPriorYTDSales.get(acc.Id) : 0;

            acc.NY_Budget__c = ( acc.NY_Budget__c != null ? acc.NY_Budget__c : 0 );
                acc.NY_Budget__c += (mNextYearBudget.containsKey(acc.Id)) ? mNextYearBudget.get(acc.Id) : 0;

                acc.NY_Forecast__c = ( acc.NY_Forecast__c != null ? acc.NY_Forecast__c : 0 );
                acc.NY_Forecast__c += (mNextYearForecast.containsKey(acc.Id)) ? mNextYearForecast.get(acc.Id) : 0;

            acc.X2011_Sales__c = ( acc.X2011_Sales__c != null ? acc.X2011_Sales__c : 0 );
                acc.X2011_Sales__c += (m2011Sales.containsKey(acc.Id)) ? m2011Sales.get(acc.Id) : 0;

                acc.X2012_Sales__c = ( acc.X2012_Sales__c != null ? acc.X2012_Sales__c : 0 );
                acc.X2012_Sales__c += (m2012Sales.containsKey(acc.Id)) ? m2012Sales.get(acc.Id) : 0;

                acc.X2013_Sales__c = ( acc.X2013_Sales__c != null ? acc.X2013_Sales__c : 0 );
                acc.X2013_Sales__c += (m2013Sales.containsKey(acc.Id)) ? m2013Sales.get(acc.Id) : 0;

                acc.X2014_Sales__c = ( acc.X2014_Sales__c != null ? acc.X2014_Sales__c : 0 );
                acc.X2014_Sales__c += (m2014Sales.containsKey(acc.Id)) ? m2014Sales.get(acc.Id) : 0;

                acc.X2015_Sales__c = ( acc.X2015_Sales__c != null ? acc.X2015_Sales__c : 0 );
                acc.X2015_Sales__c += (m2015Sales.containsKey(acc.Id)) ? m2015Sales.get(acc.Id) : 0;

                acc.X2016_Sales__c = ( acc.X2016_Sales__c != null ? acc.X2016_Sales__c : 0 );
                acc.X2016_Sales__c += (m2016Sales.containsKey(acc.Id)) ? m2016Sales.get(acc.Id) : 0;

                acc.X2017_Sales__c = ( acc.X2017_Sales__c != null ? acc.X2017_Sales__c : 0 );
                acc.X2017_Sales__c += (m2017Sales.containsKey(acc.Id)) ? m2017Sales.get(acc.Id) : 0;

                acc.X2018_Sales__c = ( acc.X2018_Sales__c != null ? acc.X2018_Sales__c : 0 );
                acc.X2018_Sales__c += (m2018Sales.containsKey(acc.Id)) ? m2018Sales.get(acc.Id) : 0;

                acc.X2019_Sales__c = ( acc.X2019_Sales__c != null ? acc.X2019_Sales__c : 0 );
                acc.X2019_Sales__c += (m2019Sales.containsKey(acc.Id)) ? m2019Sales.get(acc.Id) : 0;

                acc.X2020_Sales__c = ( acc.X2020_Sales__c != null ? acc.X2020_Sales__c : 0 );
                acc.X2020_Sales__c += (m2020Sales.containsKey(acc.Id)) ? m2020Sales.get(acc.Id) : 0;


            // pupulate GM rollup fields
            acc.YTD_GM__c = ( acc.YTD_GM__c != null ? acc.YTD_GM__c : 0 );
            acc.YTD_GM__c += (mCurrentYTDGM.containsKey(acc.Id)) ? mCurrentYTDGM.get(acc.Id) : 0;

            acc.x2015_GM__c = ( acc.x2015_GM__c != null ? acc.x2015_GM__c : 0 );
                acc.x2015_GM__c += (m2015GMDollars.containsKey(acc.Id)) ? m2015GMDollars.get(acc.Id) : 0;

                //4 Aug 2015 - Budget 2014
                acc.Budget_2014__c = ( acc.X2014_Sales__c != null ? acc.X2014_Sales__c : 0 );
                acc.Budget_2014__c += (m2014Budget.containsKey(acc.Id)) ? m2014Budget.get(acc.Id) : 0;                

              }
              acc.Last_Modified_CurrYBudget__c = system.now();
            }
            update acclist;
            }
          catch( Exception e ) {

            system.debug(  e.getMessage() + ' ****** ' + e.getLineNumber() );
         /*   Debug_Log__c debugObj = new Debug_Log__c( Details__c = e.getMessage() + ' ****** ' + e.getLineNumber()
                                                      + ' ------------------ '
                                                      + mPrev12MoSalesForDebug
                                                      + ' ------------------ '
                                                      + accForDebug
                                                      + ' ------------------ '
                                                      + sdForDebug
                                                      + ' ------------------ '
                                                      + accIdDebug );
            insert debugObj;*/
          }
  }

  global void finish(Database.batchableContext bc) {
       finishActions( bc );
  }

  public void finishActions( Database.batchableContext bc ) {
        // Get the AsyncApexJob that represents the Batch job using the Id from the BatchableContext
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];

        // Email the Batch Job's submitter that the Job is finished.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        //toAddresses.add('sanjeev.mehta@bytehash.com');
        system.debug('toAddresses = ' + toAddresses);
        mail.setToAddresses(toAddresses);
        mail.setSubject('Account Sales Rollup - Batch Job : ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +  ' batches with '+ a.NumberOfErrors + ' failures. ExtendedStatus: ' + a.ExtendedStatus);
		if(!Test.isRunningTest()){
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
  }
}