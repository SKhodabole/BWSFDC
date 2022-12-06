/*
  Apex class to merge sales data records
*/
global with sharing class AccountSalesDataMerge implements Database.Batchable<sobject>{
    
    global Set<Id> setAccountIds;
    global String strQuery;

    global AccountSalesDataMerge(String s){
        strQuery = s;
    }
    
    public static void runAccountSalesDataMerge( Set<Id> setAccountIdVal, String strCurrYear ){

          String strQuery;
          if(strCurrYear == null || strCurrYear.trim() == ''  ){
                strQuery = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c WHERE Account__c in: setAccountIds  ';
          }
          else if ( strCurrYear  != null && strCurrYear.trim() != '' 
                      && ( setAccountIdVal == null || setAccountIdVal.size() == 0 ) )
                    strQuery = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c WHERE Year__c = \'' + strCurrYear + '\'';          
          else {
                    strQuery = 'SELECT Id, Account__c, Account__r.Id, Plant_Product__c, Plant_Product__r.Id, Budget_Amount__c, Year__c, Period__c, Actual_Amount__c, Forecast_Amount__c FROM Sales_Data__c WHERE Account__c in: setAccountIds and Year__c = \'' + strCurrYear + '\'';
          }
          
          AccountSalesDataMerge  clsAccountSalesDataMerge  = new AccountSalesDataMerge ( strQuery );
          clsAccountSalesDataMerge.setAccountIds = setAccountIdVal;
          clsAccountSalesDataMerge.strQuery = strQuery;
          id batchstart = Database.executeBatch(clsAccountSalesDataMerge, 10);
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(strQuery);
    }

    global void execute(Database.batchableContext bc, List<Sales_Data__c> sdList){

        //group by accountid~PlantProdID~Year~Period
        Decimal budgetAmt = 0;
        Decimal forecastAmt = 0;
        Decimal actualAmt = 0;

        // new GM fields added
        Decimal gmDollarsAmt = 0;
        Decimal marginSalesDolorsAmt = 0;

        // new ENV Fields
        Decimal envBuyoutResaleBudgetSales = 0;
        Decimal envBuyoutResaleBudgetUnits = 0;
        Decimal envBuyoutResaleActualSales = 0;
        Decimal envBuyoutResaleActualUnits = 0;
        
        Decimal envManufacturedActualSales = 0;
        Decimal envManufacturedActualUnits = 0;
        Decimal envManufacturedBudgetSales = 0;
        Decimal envManufacturedBudgetUnits = 0; 
		Decimal env1stPassBudgetAmount = 0;
        Decimal env1stPassBudgetUnits = 0; 

        Decimal envAdjustedBudgetAmount = 0;
        Decimal envAdjustedBaselineAmount = 0;
        Decimal envVeritivAdjustment = 0;
        Decimal envLMEAdjustment = 0;
		        
        Decimal budgetUnits = 0;
        Decimal forecastUnits = 0;
        Decimal actualUnits = 0;

        Decimal QP_Net_Actual_Amount = 0; 
        Decimal QP_Net_Budget_Amount = 0;
        Decimal QP_Program_Percent = 0;
        
        String billingAccountNumber = '';
        String manager = '';
        String historicalOwner = '';

        Integer i = 0;

        Map<Id, Sales_Data__c> mergedSD = new Map<Id, Sales_Data__c>();
        Map<Id, Sales_Data__c> delSD = new Map<Id, Sales_Data__c>();

        for(Sales_Data__c sd : sdList){
            List<Sales_Data__c> xsdList = [SELECT Id, GM__c, GMDollars__c, Margin_Sales_Dollars__c, 
                                           	ENV_Buyout_Resale_Budget_Sales__c,
                                            ENV_Buyout_Resale_Budget_Units__c,
                                            ENV_Buyout_Resale_Actual_Sales__c,
                                            ENV_Buyout_Resale_Actual_Units__c,
                                         //   ENV_Manufactured_Actual_Sales__c,
                                          //  ENV_Manufactured_Actual_Units__c,
                                            ENV_Manufactured_Budget_Sales__c,
                                            ENV_Manufactured_Budget_Units__c,
                                            ENV_1st_Pass_Budget_Amount__c,
                                            ENV_1st_Pass_Budget_Units__c,
                                            ENV_Adjusted_Budget_Amount__c, 
                                            ENV_Baseline_Amount__c, 
                                            ENV_Veritiv_Adjustment__c, 
                                            ENV_LME_Adjustment__c,
                                            QP_Net_Actual_Amount__c, 
                                            QP_Net_Budget_Amount__c, 
                                            QP_Program_Percent__c, 
                                            Account__c, Plant_Product__c, 
                                            Plant_Product__r.Id, Budget_Amount__c, 
                                            Year__c, Period__c, Actual_Amount__c, 
                                            Forecast_Amount__c, Actual_Units__c, Budget_Units__c, 
                                            Forecast_Units__c, Billing_Account_Number__c, Historical_Owner__c, 
                                            Manager__c 
                                            FROM Sales_Data__c
                                            WHERE Account__c =: sd.Account__c AND
                                            Plant_Product__c =: sd.Plant_Product__c AND
                                            Year__c =: sd.Year__c AND
                                            Period__c =: sd.Period__c
                                            LIMIT 50000
                                            ];

            budgetAmt = 0;
            forecastAmt = 0;
            actualAmt = 0;

              // new GM fields added
              gmDollarsAmt = 0;
              marginSalesDolorsAmt = 0;

              	// new ENV Fields
            	envBuyoutResaleBudgetSales = 0;
                envBuyoutResaleBudgetUnits = 0;
                envBuyoutResaleActualSales = 0;
                envBuyoutResaleActualUnits = 0;
                
            	envManufacturedActualSales = 0;
                envManufacturedActualUnits = 0;
                envManufacturedBudgetSales = 0;
                envManufacturedBudgetUnits = 0;
            	env1stPassBudgetAmount = 0;
                env1stPassBudgetUnits = 0;
                
                
                envAdjustedBudgetAmount = 0;
                envAdjustedBaselineAmount = 0;
                envVeritivAdjustment = 0;
                envLMEAdjustment = 0;

                QP_Net_Actual_Amount = 0; 
                QP_Net_Budget_Amount = 0;
                QP_Program_Percent = 0;
            	
                
                budgetUnits = 0;
                forecastUnits = 0;
                actualUnits = 0;
    
                billingAccountNumber = '';
                manager = '';
                historicalOwner = '';
    
                i = 0;
                system.debug('sd.Account__c = ' + sd.Account__c);
                system.debug('sd.Plant_Product__c = ' + sd.Plant_Product__c);
                system.debug('sd.Year__c = ' + sd.Year__c);
                system.debug('sd.Period__c = ' + sd.Period__c);
                system.debug('size = ' + xsdList.size());
                system.debug('xsdList = ' + xsdList);

            if(xsdList.size() > 1){ // there is a working set available...
                for(Sales_Data__c sd1 : xsdList){
                    budgetAmt += sd1.Budget_Amount__c == null ? 0 : sd1.Budget_Amount__c;
                    forecastAmt += sd1.Forecast_Amount__c == null ? 0 : sd1.Forecast_Amount__c;
                    actualAmt += sd1.Actual_Amount__c == null ? 0 : sd1.Actual_Amount__c;

                    // new GM fields added
                    gmDollarsAmt += sd1.GMDollars__c == null ? 0 : sd1.GMDollars__c;
                    marginSalesDolorsAmt += sd1.Margin_Sales_Dollars__c == null ? 0 : sd1.Margin_Sales_Dollars__c;

                    // new ENV Fields
                    envBuyoutResaleBudgetSales += sd1.ENV_Buyout_Resale_Budget_Sales__c == null ? 0 : sd1.ENV_Buyout_Resale_Budget_Sales__c;
                    envBuyoutResaleBudgetUnits += sd1.ENV_Buyout_Resale_Budget_Units__c == null ? 0 : sd1.ENV_Buyout_Resale_Budget_Units__c;
                    envBuyoutResaleActualSales += sd1.ENV_Buyout_Resale_Actual_Sales__c == null ? 0 : sd1.ENV_Buyout_Resale_Actual_Sales__c;
                    envBuyoutResaleActualUnits += sd1.ENV_Buyout_Resale_Actual_Units__c == null ? 0 : sd1.ENV_Buyout_Resale_Actual_Units__c;
                    
                  //  envManufacturedActualSales += sd1.ENV_Manufactured_Actual_Sales__c == null ? 0 : sd1.ENV_Manufactured_Actual_Sales__c;
                  //  envManufacturedActualUnits += sd1.ENV_Manufactured_Actual_Units__c == null ? 0 : sd1.ENV_Manufactured_Actual_Units__c;
                    envManufacturedBudgetSales += sd1.ENV_Manufactured_Budget_Sales__c == null ? 0 : sd1.ENV_Manufactured_Budget_Sales__c;
                    envManufacturedBudgetUnits += sd1.ENV_Manufactured_Budget_Units__c == null ? 0 : sd1.ENV_Manufactured_Budget_Units__c;
                    env1stPassBudgetAmount += sd1.ENV_1st_Pass_Budget_Amount__c == null ? 0 : sd1.ENV_1st_Pass_Budget_Amount__c;
                    env1stPassBudgetUnits += sd1.ENV_1st_Pass_Budget_Units__c == null ? 0 : sd1.ENV_1st_Pass_Budget_Units__c;
                    
                    envAdjustedBudgetAmount += sd1.ENV_Adjusted_Budget_Amount__c == null ? 0 : sd1.ENV_Adjusted_Budget_Amount__c;
                    envAdjustedBaselineAmount += sd1.ENV_Baseline_Amount__c == null ? 0 : sd1.ENV_Baseline_Amount__c;
                    envVeritivAdjustment += sd1.ENV_Veritiv_Adjustment__c == null ? 0 : sd1.ENV_Veritiv_Adjustment__c;
                    envLMEAdjustment += sd1.ENV_LME_Adjustment__c == null ? 0 : sd1.ENV_LME_Adjustment__c;
                        
                    //QP Fields
                    QP_Net_Actual_Amount += sd1.QP_Net_Actual_Amount__c == null ? 0 : sd1.QP_Net_Actual_Amount__c;
                    QP_Net_Budget_Amount += sd1.QP_Net_Budget_Amount__c == null ? 0 : sd1.QP_Net_Budget_Amount__c;
                    QP_Program_Percent += sd1.QP_Program_Percent__c == null ? 0 : sd1.QP_Program_Percent__c;
                    
                    budgetUnits += sd1.Budget_Units__c == null ? 0 : sd1.Budget_Units__c;
                    forecastUnits += sd1.Forecast_Units__c == null ? 0 : sd1.Forecast_Units__c;
                    actualUnits += sd1.Actual_Units__c == null ? 0 : sd1.Actual_Units__c;

                    billingAccountNumber = sd1.Billing_Account_Number__c == null ? billingAccountNumber : sd1.Billing_Account_Number__c;
                    manager = sd1.Manager__c == null ? manager : sd1.Manager__c;
                    historicalOwner = sd1.Historical_Owner__c == null ? historicalOwner : sd1.Historical_Owner__c;


                    if(i > 0)
                        delSD.put(sd1.Id, sd1); //first record stays with the merged data.. rest of the records are deleted
                    i++;
                }

                xsdList[0].Budget_Amount__c = budgetAmt;
                xsdList[0].Forecast_Amount__c = forecastAmt;
                xsdList[0].Actual_Amount__c = actualAmt;

                // new GM fields added
                gmDollarsAmt = gmDollarsAmt != null ? gmDollarsAmt.setScale(2) : gmDollarsAmt;
                xsdList[0].GMDollars__c = gmDollarsAmt;
                marginSalesDolorsAmt = marginSalesDolorsAmt != null ? marginSalesDolorsAmt.setScale(2) : marginSalesDolorsAmt;
                xsdList[0].Margin_Sales_Dollars__c = marginSalesDolorsAmt;

                xsdList[0].GM__c = null;
                if( gmDollarsAmt != null &&
                    marginSalesDolorsAmt != null && marginSalesDolorsAmt != 0 ) {
                  Decimal gmPercent = gmDollarsAmt / marginSalesDolorsAmt;
                  xsdList[0].GM__c = ( gmPercent * 100 ).setScale(2);
                }

                // new ENV Fields   
                envBuyoutResaleBudgetSales = envBuyoutResaleBudgetSales != null ? envBuyoutResaleBudgetSales.setScale(2) : envBuyoutResaleBudgetSales;     
                xsdList[0].ENV_Buyout_Resale_Budget_Sales__c = envBuyoutResaleBudgetSales;
                envBuyoutResaleBudgetUnits = envBuyoutResaleBudgetUnits != null ? envBuyoutResaleBudgetUnits.setScale(2) : envBuyoutResaleBudgetUnits;     
                xsdList[0].ENV_Buyout_Resale_Budget_Units__c = envBuyoutResaleBudgetUnits;
                
                envBuyoutResaleActualSales = envBuyoutResaleActualSales != null ? envBuyoutResaleActualSales.setScale(2) : envBuyoutResaleBudgetSales;     
                xsdList[0].ENV_Buyout_Resale_Actual_Sales__c = envBuyoutResaleActualSales;
                envBuyoutResaleActualUnits = envBuyoutResaleActualUnits != null ? envBuyoutResaleActualUnits.setScale(2) : envBuyoutResaleBudgetUnits;     
                xsdList[0].ENV_Buyout_Resale_Actual_Units__c = envBuyoutResaleActualUnits;
                
                
                envManufacturedActualSales = envManufacturedActualSales != null ? envManufacturedActualSales.setScale(2) : envManufacturedActualSales;     
              //  xsdList[0].ENV_Manufactured_Actual_Sales__c = envManufacturedActualSales;
                envManufacturedActualUnits = envManufacturedActualUnits != null ? envManufacturedActualUnits.setScale(2) : envManufacturedActualUnits;     
              //  xsdList[0].ENV_Manufactured_Actual_Units__c = envManufacturedActualUnits;
                envManufacturedBudgetSales = envManufacturedBudgetSales != null ? envManufacturedBudgetSales.setScale(2) : envManufacturedBudgetSales;     
                xsdList[0].ENV_Manufactured_Budget_Sales__c = envManufacturedBudgetSales;
                envManufacturedBudgetUnits = envManufacturedBudgetUnits != null ? envManufacturedBudgetUnits.setScale(2) : envManufacturedBudgetUnits;     
                xsdList[0].ENV_Manufactured_Budget_Units__c = envManufacturedBudgetUnits;
                
                envAdjustedBudgetAmount = envAdjustedBudgetAmount != null ? envAdjustedBudgetAmount.setScale(2) : envAdjustedBudgetAmount;     
                xsdList[0].ENV_Adjusted_Budget_Amount__c = envAdjustedBudgetAmount;
                envAdjustedBaselineAmount = envAdjustedBaselineAmount != null ? envAdjustedBaselineAmount.setScale(2) : envAdjustedBaselineAmount;     
                xsdList[0].ENV_Baseline_Amount__c = envAdjustedBaselineAmount;
                envVeritivAdjustment = envVeritivAdjustment != null ? envVeritivAdjustment.setScale(2) : envVeritivAdjustment;     
                xsdList[0].ENV_Veritiv_Adjustment__c = envVeritivAdjustment;
                envLMEAdjustment = envLMEAdjustment != null ? envLMEAdjustment.setScale(2) : envLMEAdjustment;     
                xsdList[0].ENV_LME_Adjustment__c = envLMEAdjustment;
                
                
                //env 1stPass Budget Fields
                env1stPassBudgetAmount = env1stPassBudgetAmount != null ? env1stPassBudgetAmount.setScale(2) : env1stPassBudgetAmount;     
                xsdList[0].ENV_1st_Pass_Budget_Amount__c = env1stPassBudgetAmount;
                env1stPassBudgetUnits = env1stPassBudgetUnits != null ? env1stPassBudgetUnits.setScale(2) : env1stPassBudgetUnits;     
                xsdList[0].ENV_1st_Pass_Budget_Units__c = env1stPassBudgetUnits;
                
                

                //QP Fields
                QP_Net_Actual_Amount = QP_Net_Actual_Amount != null ? QP_Net_Actual_Amount.setScale(2) : QP_Net_Actual_Amount;     
                xsdList[0].QP_Net_Actual_Amount__c = QP_Net_Actual_Amount;
                
                QP_Net_Budget_Amount = QP_Net_Budget_Amount != null ? QP_Net_Budget_Amount.setScale(2) : QP_Net_Budget_Amount;     
                xsdList[0].QP_Net_Budget_Amount__c = QP_Net_Budget_Amount;
                
                QP_Program_Percent = QP_Program_Percent != null ? QP_Program_Percent.setScale(2) : QP_Program_Percent;     
                xsdList[0].QP_Program_Percent__c = QP_Program_Percent;
                //

                xsdList[0].Budget_Units__c = budgetUnits;
                xsdList[0].Forecast_Units__c = forecastUnits;
                xsdList[0].Actual_Units__c = actualUnits;

                if(xsdList[0].Billing_Account_Number__c == null || xsdList[0].Billing_Account_Number__c == '')
                    xsdList[0].Billing_Account_Number__c = billingAccountNumber;

                if(xsdList[0].Manager__c == null || xsdList[0].Manager__c == '')
                    xsdList[0].Manager__c = manager;

                system.debug('a:' + historicalOwner);
                if(xsdList[0].Historical_Owner__c == null && historicalOwner != null & historicalOwner != '')
                    xsdList[0].Historical_Owner__c = historicalOwner;

                mergedSD.put(xsdList[0].Id, xsdList[0]);
            }



        }//for

        //TODO .. CHECK IF THE PERIOD END DATE (OR ANY OTHER FIELD IS NOT OVERWRITTEN)
        if(mergedSD.values().size() > 0)
            update mergedSD.values();

        if(delSD.values().size() > 0)
            delete delSD.values();
    }

    global void finish(Database.batchableContext bc){

    }

}