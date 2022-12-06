global with sharing class Batch_UpdateAccountTypeOnSales implements Database.Batchable<sobject>, Database.Stateful {
	
	/**
	 *	@ Description		:		Start method of Batch
	 *
	 *	@ Args				:		Database.BatchableContext bc
	 *
 	 *	@ Return 			:		Database.QueryLocator
 	 **/
    global Database.QueryLocator start(Database.BatchableContext bc){
		
		//Query string
		String queryString = 'Select Id,Actual_Amount__c, Account__r.Type from Sales_Data__c where (Account__r.RecordType.DeveloperName = \'Cenveo\' AND Account__r.Type != \'Customer\' AND Actual_Amount__c != null AND Actual_Amount__c > 0)';
		
		//Execute uery and return to execute
		return Database.getQueryLocator(queryString);
    }
	
	/**
	 *	@ Description		:		Execute method of Batch
	 *
	 *	@ Args				:		Database.batchableContext bc, List<Sales_Data__c> listSalesData
	 *
 	 *	@ Return 			:		Void
 	 **/
    global void execute(Database.batchableContext bc, List<Sales_Data__c> listSalesData ) {
    	
    	//Set of Account ids
		Set<Id> setAccountIds = new Set<Id>();
		
		//Check for size of list of sales data
		if(listSalesData.size() > 0) {
			
			//Loop through Sales data list
			for(Sales_Data__c sd : listSalesData) {
				
				//Check sales data Account Type Customer or prospect does not
				if(sd.Account__r.Type != 'Customer') {
					
					//Add Id of account into set of Ids
					setAccountIds.add(sd.Account__c);
				}
			}
		}
		
		system.debug('setAccountIds'+setAccountIds);
		//Query List of Account
		List<Account> accountList = [Select Id, Type from Account where Id IN : setAccountIds];
	 	
	 	//check for  size of list
	 	if(accountList.size() > 0) {
	 		
	 		//Loop through list of account
	 		for(Account acc : accountList) {
	 			
	 			//change Type of Account into Customer
	 			acc.Type = 'Customer';
	 		}
 		
 		//DML operation
		update accountList;
		}
    }
	
	/**
	 *	@ Description		:		Finish method of Batch
	 *
	 *	@ Args				:		Database.batchableContext bc, List<Sales_Data__c> listSalesData
	 *
 	 *	@ Return 			:		Void
 	 **/
    global void finish(Database.batchableContext bc){

    }

}