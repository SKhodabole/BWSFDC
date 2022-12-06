global class Batch_AccountTriggerHelper implements Database.Batchable<sobject> , Database.Stateful{
	
	String idString ='';

//Start method of Batchable interface
	global Database.QueryLocator start(Database.BatchableContext bc){
     	
     	//Query string to fetch account records where ParentId is null
		String strQuery = 'Select Id, Name ,(Select Id from ChildAccounts limit 1) from account where ParentId = null AND Type = \'Parent\' AND RecordType.DeveloperName = \'Cenveo\' AND (Current_YTD_Budget__c != null OR Current_YTD_Sales__c != null OR YTD_Forecast__c != null OR Prior_YTD_Sales__c != null OR BOY_Forecast__c != null OR NY_Budget__c != null OR NY_Forecast__c != null )';
		
		
		//return query
		return Database.getQueryLocator(strQuery);
	}
    
    //Execute method of Batchable interface
	global void execute(Database.batchableContext bc, List<Account> scope ) {
		
		Set<Id> setAccountIds = new Set<Id>();
		//Map<Id, Account> mapParentAccountsToUpdate = new Map<Id, Account>();
		
		//Loop through scope return by start  
		for(Account acc : scope) {
		
		//Check for Account doesn't contain child Account  and store data in string
			if(acc.ChildAccounts.size() == 0) {
				setAccountIds.add(acc.Id);
				idString += acc.Id+' , '; 
			}
		}
		
		/*if(setAccountIds.size() > 0) {
			for( Id ids : setAccountIds) {
	            mapParentAccountsToUpdate.put(ids , new Account(Id = ids,Current_Year_Budget__c = 0,Current_YTD_Budget__c = 0,Current_YTD_Sales__c = 0,  YTD_Forecast__c = 0,Prior_YTD_Sales__c = 0,
										BOY_Forecast__c = 0, NY_Budget__c = 0, NY_Forecast__c = 0,Previous_12Mo_Sales__c = 0,Previous_2Last_12Mo_Sales__c = 0,X2011_Sales__c = 0, X2012_Sales__c = 0,
										X2013_Sales__c = 0,X2014_Sales__c = 0, X2015_Sales__c = 0,X2016_Sales__c = 0,X2017_Sales__c = 0,X2018_Sales__c = 0,X2019_Sales__c = 0,X2020_Sales__c = 0,
										YTD_GM__c = 0,x2015_GM__c = 0) );
			}
		}
		
		system.debug('@@@'+mapParentAccountsToUpdate.size());
		system.debug('@@@@'+mapParentAccountsToUpdate.values());*/
		
		
		
	}
	
	//Finish method of Batchable interface
	global void finish(Database.batchableContext bc){
		
		system.debug('@#@#@'+idString);
	}  
}