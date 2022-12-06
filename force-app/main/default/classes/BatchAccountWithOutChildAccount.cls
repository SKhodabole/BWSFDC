/**
 *  Description     :       Batch to 
 *
 *  Created By      :       
 *
 *  Created Date    :       
 *
 *  Revision Logs   :       V1.0 - Created
 **/

global with sharing class BatchAccountWithOutChildAccount implements Database.Batchable<sobject> , Database.Stateful{
	
	/**
	 * Description/purpose		:	
	 *
	 * Parameters				:
	 *
	 * Return parameters detail	:
	 *
	 **/
	global Database.QueryLocator start(Database.BatchableContext bc) {

		//Execute Query and Return result to execute method
		return Database.getQueryLocator([Select Id, Name, ParentId, To_Be_Deleted__c, Type, Owner.Name,  X2011_SALES__C, X2012_SALES__C, X2013_SALES__C, X2014_SALES__C, X2015_SALES__C, X2016_SALES__C from Account where Type = 'Parent' AND ParentId = null and  Recordtype.DeveloperName = 'Cenveo']);
	}
	
	/**
	 * Description/purpose		:	Execute method of Batch
	 *
	 * Parameters				:	Database.BatchableContext bc, List<Account> accounts
	 *
	 * Return parameters detail	:	Void
	 *
	 **/
	 
	global void execute(Database.BatchableContext bc, List<Account> scope) {
		
		try {
			List<Account> accounts = [Select Id,(Select Id, Name from ChildAccounts where Recordtype.DeveloperName = 'Cenveo') from Account where Id IN : scope];
			
			//Set of Accounts for with out child Account (ORPHAN Account)
			Set<Account> setOfAccountsWithOutSDChild  = new Set<Account>();
			Set<Account> setOfAccountWithOutTAndEChild = new Set<Account>();
			
			//List of Account for  To_Be_Deleted__c field update
			List<Account> accountToBeUpdatedForDelete = new List<Account>();
			
			//Loop Over Account List returned by Start Query
			for(Account acc : accounts) {
				
				//Check for Child Account Size
				if(acc.ChildAccounts.size() == 0) {
					
					//Add Account into set
					setOfAccountsWithOutSDChild.add(acc);
				}
			}
			
			//Check size of List of account without child 
			if(setOfAccountsWithOutSDChild.size() > 0) {
				
				//List Of account with Task and Event
				List<Account> accountWithTaskChild  = [Select Id,Name, ParentId, Type, Owner.Name,  X2011_SALES__C, X2012_SALES__C, X2013_SALES__C, X2014_SALES__C, X2015_SALES__C, X2016_SALES__C,(Select Id from Tasks),(Select Id from Events) from Account where Id IN: setOfAccountsWithOutSDChild];
				
				//Check Size of list
				if(accountWithTaskChild.size() > 0) {
					
					//Loop Over list of account
					for(Account accountTAndE : accountWithTaskChild ) {
						
						//Check if account is not associated with event and Task & add into set of account
						if(accountTAndE.Tasks.size()== 0 && accountTAndE.Events.Size() == 0)
							setOfAccountWithOutTAndEChild.add(accountTAndE);
					}
				}
				
				//Loop over Set of account which is not associated with any Tasks and Events
				for(Account ac : setOfAccountWithOutTAndEChild) {
					
					//Calculate sales for 2011 to 2016
					Decimal total = (ac.X2011_SALES__C == null? 0.0 : ac.X2011_SALES__C) + (ac.X2012_SALES__C == null? 0.0 : ac.X2012_SALES__C) 
										+ (ac.X2013_SALES__C == null? 0.0 : ac.X2013_SALES__C) + (ac.X2014_SALES__C == null? 0.0 : ac.X2014_SALES__C)
										 + (ac.X2015_SALES__C == null? 0.0 : ac.X2015_SALES__C) + (ac.X2016_SALES__C == null? 0.0 : ac.X2016_SALES__C);
					
					//Check for total sales
					if(total == 0.0) {
						
						//Update account field value
						ac.To_Be_Deleted__c = true;
						
						//Add account into list
						accountToBeUpdatedForDelete.add(ac);
					}
				}
			}
			
			system.debug('@#@#@'+accountToBeUpdatedForDelete.size());
			
			//Check for list size and update accounts
			if(accountToBeUpdatedForDelete.size() > 0)
				update accountToBeUpdatedForDelete;
		}
		catch(Exception e) {
			System.debug('#@#$@'+e.getMessage());
		}
	}
	
	/**
	 * Description/purpose		:	Finish method
	 *
	 * Parameters				:	Database.BatchableContext bc
	 *
	 * Return parameters detail	:	Void	
	 *
	 **/
	global void finish(Database.BatchableContext bc) {
		
	}
}