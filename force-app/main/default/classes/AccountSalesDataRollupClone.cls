/**
 * 	Author/Created By	:	
 *
 *	Purpose/Description	:	Class to used by Batch for Account fields rollup from sales data
 *
 *	Where it is used	:	In Batch 'BatchAccountSalesDataRollup' class
 *
 *	CreatedDate			:	
 *	
 *	Deprecated			:
 *
 *	Version				:	V_1.1
 *
 *	UpdatedBy			:
 **/
public class AccountSalesDataRollupClone {
    
    
    /**
	 *	Description/purpose		:	Method is used for calculate sales data fields rollup and populate on Account
	 *
	 *	Parameters				:	List<Sales_Data__c> sdList
	 *
	 *	Return parameters detail:	String
	 *
	 *	Example code usage		:	
	 *
	 *	Version					:	V_1.0
	 *
	 *	Author 					:	
	 *
	 *	UpdatedBy				:
	 **/
    public Void calcualteAccountSalesDataRollup( List<Sales_Data__c> sdList ) {
        
        //Map of account id with  Account
        Map<Id,Account> mapAccountToUpdate = new Map<Id,Account>();
        
        //Current month
        Integer thisMonth = date.today().month();
        
        //Map to hold fiscal year values
        Map<String,FiscalYearSettings> mapFiscalYear = new Map<String,FiscalYearSettings>();
        
        //Query fiscal year records
        List<FiscalYearSettings> fsy = [Select Id,Name, StartDate, EndDate from FiscalYearSettings ];
        system.debug('@#@#fsy'+fsy.size());
        system.debug('@#@#fsy'+fsy);
        
        //Loop over fiscal years and populate map of fiscal year
        for(FiscalYearSettings fs : fsy) {
            if(!mapFiscalYear.containsKey(fs.Name)) 
                mapFiscalYear.put(fs.Name,fs);
        }
        
        system.debug('@#@#mapFiscalYear'+mapFiscalYear);
        system.debug('@#@#mapFiscalYear'+mapFiscalYear.size());
        system.debug('@#@#mapFiscalYear'+mapFiscalYear.keySet());
        
        //Loop over sales data
        for(Sales_Data__c sd : sdList) {
            
            //Check map contains key or not
            if(!mapAccountToUpdate.containsKey(sd.Account__c)) {
                
                //Populate map
                mapAccountToUpdate.put(sd.Account__c,new Account(Id = sd.Account__c,BOY_Forecast__c =0,PY_Budget__c =0, Current_Year_Budget__c =0, 
                                        Current_YTD_Budget__c = 0, Current_YTD_Sales__c =0, YTD_Forecast__c =0, Prior_YTD_Sales__c =0,
                                        NY_Budget__c =0, NY_Forecast__c =0, X2011_Sales__c =0, X2012_Sales__c =0, X2013_Sales__c =0,
                                        X2014_Sales__c =0,X2015_Sales__c =0, X2016_Sales__c =0,X2017_Sales__c =0,X2018_Sales__c =0,
                                        X2019_Sales__c =0,X2020_Sales__c =0,Previous_12Mo_Sales__c =0,Previous_2Last_12Mo_Sales__c =0,X2015_GM__c =0,YTD_GM__c =0,Budget_2014__c =0,Last_Modified_CurrYBudget__c = system.now()));
            }
        }
        
        system.debug('@#@#@mapAccountToUpdate'+mapAccountToUpdate.size());
        
        //Loop through Aggregate Result on Sales Data Actual Amount --> previous 12 month
        for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount ,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                    AND Period_End_Date__c = LAST_N_MONTHS:12 GROUP BY Account__c ]) {
            System.debug('@@@@'+aResult);  
                     
            //Getting AccountId from aggregate result
            Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                
            //Check if map is already containing AccountId as key
            if(mapAccountToUpdate.containsKey(accId)) {
                    
                //update map's Account instance field's Current_Year_Budget__c value
                mapAccountToUpdate.get(accId).Previous_12Mo_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
            }
        }
        
        //Loop through Aggregate Result on Sales Data Actual Amount --> Previous 2last 12 months
        for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount ,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                    AND Period_End_Date__c = LAST_N_MONTHS:24 AND Period_End_Date__c < LAST_N_MONTHS:12 GROUP BY Account__c ]) {
            System.debug('@@@@'+aResult);  
                  
            //Getting AccountId from aggregate result
            Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                
            //Check if map is already containing AccountId as key
            if(mapAccountToUpdate.containsKey(accId)) {
                    
                //update map's Account instance field's Current_Year_Budget__c value
                mapAccountToUpdate.get(accId).Previous_2Last_12Mo_Sales__c = Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
            }
        }
        
        //Loop through Aggregate Result on Sales Data Budget Amount --> Current Year budget
        for(AggregateResult aResult : [SELECT sum(Budget_Amount__c) currBudget ,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                    AND Period_End_Date__c = THIS_FISCAL_YEAR GROUP BY Account__c ]) {
            System.debug('@@@@'+aResult);  
                  
            //Getting AccountId from aggregate result
            Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                
            //Check if map is already containing AccountId as key
            if(mapAccountToUpdate.containsKey(accId)) {
                    
                //update map's Account instance field's Current_Year_Budget__c value
                mapAccountToUpdate.get(accId).Current_Year_Budget__c= Double.valueof(aResult.get('currBudget'))!= null ?Double.valueof(aResult.get('currBudget')):0;
            }
        }
        
        //Loop through Aggregate Result on Sales Data Budget Amount--> Current YTD Budget
        //Actual Amount --> Current YTD Sales
        //Forecast Amount --> YTD Forecast
        //GM Dollar --> YTD GM
        for(AggregateResult aResult : [SELECT sum(Budget_Amount__c) currBudget ,sum(Actual_Amount__c) actAmount, sum(Forecast_Amount__c) forecastAmount,sum(GMDollars__c) gmDoller,
                                            Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                    AND Period_End_Date__c = THIS_FISCAL_YEAR AND Period_End_Date__c < TODAY GROUP BY Account__c ]) {
            System.debug('@@@@'+aResult);  
                  
            //Getting AccountId from aggregate result
            Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                
            //Check if map is already containing AccountId as key
            if(mapAccountToUpdate.containsKey(accId)) {
                                                                                    
                //update map's Account instance
                mapAccountToUpdate.get(accId).Current_YTD_Budget__c= Double.valueof(aResult.get('currBudget'))!= null ?Double.valueof(aResult.get('currBudget')):0;
                mapAccountToUpdate.get(accId).Current_YTD_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
                mapAccountToUpdate.get(accId).YTD_Forecast__c= Double.valueof(aResult.get('forecastAmount'))!= null ?Double.valueof(aResult.get('forecastAmount')):0;
                mapAccountToUpdate.get(accId).YTD_GM__c= Double.valueof(aResult.get('gmDoller'))!= null ?Double.valueof(aResult.get('gmDoller')):0;
                
            }
        }
        
        //Loop through Aggregate Result on Sales Data Forecast Amount --> BOY Forecast 
        for(AggregateResult aResult : [SELECT sum(Forecast_Amount__c) forecastAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                    AND Period_End_Date__c = THIS_FISCAL_YEAR AND Period_End_Date__c >= TODAY GROUP BY Account__c ]) {
            System.debug('@@@@'+aResult);  
                  
            //Getting AccountId from aggregate result
            Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                
            //Check if map is already containing AccountId as key
            if(mapAccountToUpdate.containsKey(accId)) {
                                                                                    
                //update map's Account instance
                mapAccountToUpdate.get(accId).BOY_Forecast__c= Double.valueof(aResult.get('forecastAmount'))!= null ?Double.valueof(aResult.get('forecastAmount')):0;
                
            }
        }
        //Loop through Aggregate Result on Sales Data Actual Amount --> Prior YTD Sales
        for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                    AND Period_End_Date__c = LAST_FISCAL_YEAR AND Period_End_Date__c <: Date.today().addYears(-1) GROUP BY Account__c ]) {
            System.debug('@@@@'+aResult);  
                  
            //Getting AccountId from aggregate result
            Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                
            //Check if map is already containing AccountId as key
            if(mapAccountToUpdate.containsKey(accId)) {
                                                                                    
                //update map's Account instance
                mapAccountToUpdate.get(accId).Prior_YTD_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
                
            }
        }
        
        //Loop through Aggregate Result on Sales Data Budget Amount --> PY Budget
        for(AggregateResult aResult : [SELECT sum(Budget_Amount__c) budgetAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                    AND Period_End_Date__c = LAST_FISCAL_YEAR GROUP BY Account__c ]) {
            System.debug('@@@@'+aResult);  
                  
            //Getting AccountId from aggregate result
            Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                
            //Check if map is already containing AccountId as key
            if(mapAccountToUpdate.containsKey(accId)) {
                                                                                    
                //update map's Account instance
                mapAccountToUpdate.get(accId).PY_Budget__c= Double.valueof(aResult.get('budgetAmount'))!= null ?Double.valueof(aResult.get('budgetAmount')):0;
                
            }
        }
        
        
        //Loop through Aggregate Result on Sales Data Budget Amount --> NY Budget
        // Forecast Amount --> NY Forecast
        /*for(AggregateResult aResult : [SELECT sum(Budget_Amount__c) budgetAmount,sum(Forecast_Amount__c) forecastAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                    AND Period_End_Date__c = NEXT_FISCAL_YEAR GROUP BY Account__c ]) {*/
        //SM: NEXT_FISCAL_YEAR was not working .. so changing this to THIS_.. for the moment
        for(AggregateResult aResult : [SELECT sum(Budget_Amount__c) budgetAmount,sum(Forecast_Amount__c) forecastAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                    AND Period_End_Date__c = THIS_FISCAL_YEAR GROUP BY Account__c ]) {
            System.debug('@@@@'+aResult);  
                  
            //Getting AccountId from aggregate result
            Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                
            //Check if map is already containing AccountId as key
            if(mapAccountToUpdate.containsKey(accId)) {
                                                                                    
                //update map's Account instance
                mapAccountToUpdate.get(accId).NY_Budget__c= Double.valueof(aResult.get('budgetAmount'))!= null ?Double.valueof(aResult.get('budgetAmount')):0;
                mapAccountToUpdate.get(accId).NY_Forecast__c= Double.valueof(aResult.get('forecastAmount'))!= null ?Double.valueof(aResult.get('forecastAmount')):0;
            }
        }  
        
        //Check fiscal year map
        if(mapFiscalYear.containsKey('2011')) {
        
            //Loop through Aggregate Result on Sales Data Actual Amount --> X2011 Sales
            for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                        AND Period_End_Date__c >=:mapFiscalYear.get('2011').StartDate AND Period_End_Date__c <=: mapFiscalYear.get('2011').EndDate GROUP BY Account__c ]) {
                System.debug('@@@@'+aResult);  
                      
                //Getting AccountId from aggregate result
                Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                    
                //Check if map is already containing AccountId as key
                if(mapAccountToUpdate.containsKey(accId)) {
                                                                                        
                    //update map's Account instance
                    mapAccountToUpdate.get(accId).X2011_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
               }
            } 
        }
        
        if(mapFiscalYear.containsKey('2012')) {
            //Loop through Aggregate Result on Sales Data Actual Amount --> X2012 Sales
            for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                        AND Period_End_Date__c >=:mapFiscalYear.get('2012').StartDate AND Period_End_Date__c <=: mapFiscalYear.get('2012').EndDate GROUP BY Account__c ]) {
                System.debug('@@@@'+aResult);  
                      
                //Getting AccountId from aggregate result
                Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                    
                //Check if map is already containing AccountId as key
                if(mapAccountToUpdate.containsKey(accId)) {
                                                                                        
                    //update map's Account instance
                    mapAccountToUpdate.get(accId).X2012_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
               }
            }
        }
        
        if(mapFiscalYear.containsKey('2013')) { 
            //Loop through Aggregate Result on Sales Data Actual Amount --> X2013 Sales
            for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                        AND Period_End_Date__c >=:mapFiscalYear.get('2013').StartDate AND Period_End_Date__c <=: mapFiscalYear.get('2013').EndDate GROUP BY Account__c ]) {
                System.debug('@@@@'+aResult);  
                      
                //Getting AccountId from aggregate result
                Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                    
                //Check if map is already containing AccountId as key
                if(mapAccountToUpdate.containsKey(accId)) {
                                                                                        
                    //update map's Account instance
                    mapAccountToUpdate.get(accId).X2013_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
               }
            }
        }
        if(mapFiscalYear.containsKey('2014')) { 
            //Loop through Aggregate Result on Sales Data 
            for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount,sum(Budget_Amount__c) budgetAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                        AND Period_End_Date__c >=:mapFiscalYear.get('2014').StartDate AND Period_End_Date__c <=: mapFiscalYear.get('2014').EndDate GROUP BY Account__c ]) {
                System.debug('@@@@'+aResult);  
                      
                //Getting AccountId from aggregate result
                Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                    
                //Check if map is already containing AccountId as key
                if(mapAccountToUpdate.containsKey(accId)) {
                                                                                        
                    //update map's Account instance
                    mapAccountToUpdate.get(accId).X2014_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
                    mapAccountToUpdate.get(accId).Budget_2014__c= Double.valueof(aResult.get('budgetAmount'))!= null ?Double.valueof(aResult.get('budgetAmount')):0;
               }
            }
        }
        if(mapFiscalYear.containsKey('2015')) { 
            //Loop through Aggregate Result on Sales Data 
            for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount,sum(GMDollars__c)gmDollar,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                        AND Period_End_Date__c >=:mapFiscalYear.get('2015').StartDate AND Period_End_Date__c <=: mapFiscalYear.get('2015').EndDate GROUP BY Account__c ]) {
                System.debug('@@@@'+aResult);  
                      
                //Getting AccountId from aggregate result
                Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                    
                //Check if map is already containing AccountId as key
                if(mapAccountToUpdate.containsKey(accId)) {
                                                                                        
                    //update map's Account instance
                    mapAccountToUpdate.get(accId).X2015_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
                    mapAccountToUpdate.get(accId).X2015_GM__c= Double.valueof(aResult.get('gmDollar'))!= null ?Double.valueof(aResult.get('gmDollar')):0;
               }
            } 
        }
        if(mapFiscalYear.containsKey('2016')) {
            //Loop through Aggregate Result on Sales Data 
            for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                        AND Period_End_Date__c >=:mapFiscalYear.get('2016').StartDate AND Period_End_Date__c <=: mapFiscalYear.get('2016').EndDate GROUP BY Account__c ]) {
                System.debug('@@@@'+aResult);  
                      
                //Getting AccountId from aggregate result
                Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                    
                //Check if map is already containing AccountId as key
                if(mapAccountToUpdate.containsKey(accId)) {
                                                                                        
                    //update map's Account instance
                    mapAccountToUpdate.get(accId).X2016_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
               }
            } 
        }
        if(mapFiscalYear.containsKey('2017')) {
            //Loop through Aggregate Result on Sales Data 
            for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                        AND Period_End_Date__c >=:mapFiscalYear.get('2017').StartDate AND Period_End_Date__c <=: mapFiscalYear.get('2017').EndDate GROUP BY Account__c ]) {
                System.debug('@@@@'+aResult);  
                      
                //Getting AccountId from aggregate result
                Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                    
                //Check if map is already containing AccountId as key
                if(mapAccountToUpdate.containsKey(accId)) {
                                                                                        
                    //update map's Account instance
                    mapAccountToUpdate.get(accId).X2017_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
               }
            }
        }
        if(mapFiscalYear.containsKey('2018')) { 
            //Loop through Aggregate Result on Sales Data 
            for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                        AND Period_End_Date__c >=:mapFiscalYear.get('2018').StartDate AND Period_End_Date__c <=: mapFiscalYear.get('2018').EndDate GROUP BY Account__c ]) {
                System.debug('@@@@'+aResult);  
                      
                //Getting AccountId from aggregate result
                Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                    
                //Check if map is already containing AccountId as key
                if(mapAccountToUpdate.containsKey(accId)) {
                                                                                        
                    //update map's Account instance
                    mapAccountToUpdate.get(accId).X2018_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
               }
            }
        }
        if(mapFiscalYear.containsKey('2019')) { 
            //Loop through Aggregate Result on Sales Data 
            for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                        AND Period_End_Date__c >=:mapFiscalYear.get('2019').StartDate AND Period_End_Date__c <=: mapFiscalYear.get('2019').EndDate GROUP BY Account__c ]) {
                System.debug('@@@@'+aResult);  
                      
                //Getting AccountId from aggregate result
                Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                    
                //Check if map is already containing AccountId as key
                if(mapAccountToUpdate.containsKey(accId)) {
                                                                                        
                    //update map's Account instance
                    mapAccountToUpdate.get(accId).X2019_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
               }
            }
        }
        if(mapFiscalYear.containsKey('2020')) { 
            //Loop through Aggregate Result on Sales Data 
            for(AggregateResult aResult : [SELECT sum(Actual_Amount__c) actAmount,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
                                                                        AND Period_End_Date__c >=:mapFiscalYear.get('2020').StartDate AND Period_End_Date__c <=: mapFiscalYear.get('2020').EndDate GROUP BY Account__c ]) {
                System.debug('@@@@'+aResult);  
                      
                //Getting AccountId from aggregate result
                Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                    
                //Check if map is already containing AccountId as key
                if(mapAccountToUpdate.containsKey(accId)) {
                                                                                        
                    //update map's Account instance
                    mapAccountToUpdate.get(accId).X2020_Sales__c= Double.valueof(aResult.get('actAmount'))!= null ?Double.valueof(aResult.get('actAmount')):0;
               }
            } 
        }
         //Update accounts here
         update mapAccountToUpdate.values();
             
         //return mapString;
    }
 
  public void finishActions( Database.batchableContext bc) {
        // Get the AsyncApexJob that represents the Batch job using the Id from the BatchableContext
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];

        // Email the Batch Job's submitter that the Job is finished.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        
        system.debug('toAddresses = ' + toAddresses);
        
        //Mail set toAddress
        mail.setToAddresses(toAddresses);
        mail.setSubject('Account Sales Rollup - Batch Job : ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +  ' batches with '+ a.NumberOfErrors + ' failures. ExtendedStatus: ' + a.ExtendedStatus);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }

    
}