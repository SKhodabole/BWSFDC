/** Created By				:	
  *
  * Purpose/Description		:	Batch to update historical data for rollup budget		
  *
  * Where it is used		:	It is used to sum of total budget 2015 on account from sales data
  *
  * CreatedDate				:	3-Feb-2016
  *
  * Deprecated				:
  *
  * Version					:	V_1.0
  *
  * UpdatedBy				:	Query change  by ---- Period_End_Date__c >=: fiscal.StartDate AND Period_End_Date__c <=: fiscal.EndDate
  **/
global class Batch_RollUpBudgetAccount implements Database.Batchable<sObject>{
	
	//Fiscal Year instace
	global FiscalYearSettings fiscal;
	
	//Constructor
	public Batch_RollUpBudgetAccount() {
		
		//Query result
		fiscal = [Select Id, StartDate, EndDate from FiscalYearSettings where Name='2015'];
	}
	/**
     *  @ Desription    :    This is Start Method of Batchable Interface
     *
     *  @ arga          :    BatchableContext
     *
     *  @ Return        :    QueryLocator
     **/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
			
		return Database.getQueryLocator([Select Id,Budget_Amount__c,Period_End_Date__c,Account__c from Sales_Data__c where Account__c != null AND Period_End_Date__c >=: fiscal.StartDate AND Period_End_Date__c <=: fiscal.EndDate ]);
	}
	
	/**
     *  @ Desription    :    This is execute Method of Batchable Interface
     *
     *  @ arga          :    Database.BatchableContext BC, List<Sales_Data__c> scope
     *
     *  @ Return        :    void
     **/
     global void execute(Database.BatchableContext BC, List<Sales_Data__c> scope) {
     	
     	Map<Id,Account> mapAccountToUpdate = new Map<Id,Account>();
     	
     	If(scope.size() > 0) {
 			for(Sales_Data__c sd: scope) {
     			
     			if(!mapAccountToUpdate.containsKey(sd.Account__c)) {
     				
     				mapAccountToUpdate.put(sd.Account__c,new Account(Id = sd.Account__c,Budget_2015__c=0));
     			}	
     		}
     		//Calculate fiscal year
			//FiscalYearSettings fiscal =[Select Id, StartDate, EndDate from FiscalYearSettings where Name='2015'];
      	
			//Loop through Aggregate Result on Sales Data for fetching all Closed Won data grouped by AccountId
	    	for(AggregateResult aResult : [SELECT sum(Budget_Amount__c) totalBudget ,Account__c acc FROM Sales_Data__c WHERE  Account__c!= null AND Account__c IN: mapAccountToUpdate.keyset()
    																AND Period_End_Date__c >=: fiscal.StartDate AND Period_End_Date__c <=: fiscal.EndDate  GROUP BY Account__c ]) {
            	System.debug('@@@@'+aResult);  
            	  
                //Getting AccountId from aggregate result
                Id accId = Id.valueOf(String.valueof(aResult.get('acc')));
                
                //Check if map is already containing AccountId as key
                if(mapAccountToUpdate.containsKey(accId)) {
                    
                    //update map's Account instance
                    mapAccountToUpdate.get(accId).Budget_2015__c= Double.valueof(aResult.get('totalBudget'))!= null ?Double.valueof(aResult.get('totalBudget')):0;
                 }
            }
            System.debug('@@@@@@@@@@@@@@mapAccountToUpdate'+mapAccountToUpdate);
            
            //Update accounts here
            update mapAccountToUpdate.values();
     	}
	}   
	
	/**
     *  @ Desription    :    This is Finish Method of Batchable Interface
     *
     *  @ arga          :    BatchableContext
     *
     *  @ Return        :    void
     **/
    global void finish(Database.BatchableContext BC) {
        
    }
}