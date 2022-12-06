/**
 *  @ Purpose       :       Batch for Account 100K and 250K indicator
 *
 *  @ Created By    :       
 *
 *  @ Created Date  :       
 *
 *  @ Rivision Log  :       
 *
 *  @ Version       :       V-1.0
 **/

global with sharing class BatchAccountBudgetIndicator implements Database.Batchable<Sobject>,Database.Stateful{
	
	/**
	 *	@ Description	:	Start method of batch for fetch query result
	 *
	 *	@ Args			:	Database.BatchableContext bc
	 *
	 *	@ Return		:	Database.QueryLocator
	 **/
	global Database.QueryLocator start(Database.BatchableContext bc) {
	 		
		return Database.getQueryLocator([Select Id, ParentId, Parent.parentId, Parent.Current_Year_Budget__c, BOY_Forecast__c,
											Is_Eligible_For_Outlook_Report__c, Parent_CY_Budget_100K__c, Parent_CY_Budget_250K__c,
											CY_Budget_100K__c, Is_Eligible_For_Budget_Report__c, Current_YTD_Sales__c, Current_Year_Budget__c, 
											Parent.Parent_CY_Budget_250K__c, Parent.Parent_CY_Budget_100K__c from Account where parentId != null and RecordType.DeveloperName = 'Cenveo']);
	 	
	}   
	 
	 /**
	 *	@ Description	:	Execute method to process records pass from start
	 *
	 *	@ Args			:	Database.batchableContext bc, List<Account> accounts
	 *
	 *	@ Return		:	void
	 **/
	global void execute(Database.batchableContext bc, List<Account> accounts) {
		
		system.debug('@#@1'+accounts);
		
		//map of Account to be update
		Map<Id, Account> mapAccountToBeUpdate = new Map<Id,Account>();
		Map<String,Account> mapTempToCompare = new Map<String,Account>();
		
		try {
			//Check List of account size
			if(accounts.size() > 0) {
				
				//LoopOver Accountlist
				for(Account acc: accounts) {
					
					
					//Account instance
					Account a = new Account();
					
					//Set property
					a.Id = acc.Id;
					
					system.debug('@#@2'+a.Id);
					
					//Check Current Year Budget on Account and check CY_Budget_100K__c field
					if(acc.Current_Year_Budget__c > Constants.CURRENT_YEAR_BUDGET_LIMIT_MIN) 
						a.CY_Budget_100K__c = true;
					else 
						a.CY_Budget_100K__c = false;
					
					//Check Current Year Budget on Account and check Is_Eligible_For_Budget_Report__c field
					if(acc.Current_Year_Budget__c > Constants.CURRENT_YEAR_BUDGET_LIMIT) 
						a.Is_Eligible_For_Budget_Report__c = true;
					
					else 
						a.Is_Eligible_For_Budget_Report__c = false;
					
					//Check for parent Account
					if(acc.parentId != null) {
						
						system.debug('@#@#@3'+acc.parentId);
						
						//Account Insatnce for parent Account
						Account aParent = new Account();
						
						//Set Id of parent account as account Id
						aParent.Id = acc.parentId;
						
						//Check parent Account budget field value
						if(acc.Parent.Current_Year_Budget__c > Constants.CURRENT_YEAR_BUDGET_LIMIT_MIN) {
							a.Parent_CY_Budget_100K__c = true;
							aParent.CY_Budget_100K__c = true;
							//aParent.Parent_CY_Budget_100K__c = true;
						}
						else {
							a.Parent_CY_Budget_100K__c = false;
							aParent.CY_Budget_100K__c = false;
							//aParent.Parent_CY_Budget_100K__c = false;
						}
						
						//Check parent Account budget field value
						if(acc.Parent.Current_Year_Budget__c > Constants.CURRENT_YEAR_BUDGET_LIMIT) {
							a.Parent_CY_Budget_250K__c = true;
							aParent.Is_Eligible_For_Budget_Report__c = true;
							//aParent.Parent_CY_Budget_250K__c = true;
						}
								
						else {
							a.Parent_CY_Budget_250K__c = false;
							aParent.Is_Eligible_For_Budget_Report__c = false;
							//aParent.Parent_CY_Budget_250K__c = false;
						}
						
						if(acc.Parent.parentId == null) {
							aParent.Parent_CY_Budget_250K__c = false;
							aParent.Parent_CY_Budget_100K__c = false;
						}
						//Add parent Account into map to be update
						system.debug('@#@#4'+aParent);
						mapAccountToBeUpdate.put(acc.parentId, aParent);
					}
					
					//Add child account into map to be update
					//if(!mapAccountToBeUpdate.containsKey(acc.Id)) {
						system.debug('@#@#5'+a);
						mapAccountToBeUpdate.put(acc.Id, a);
					//}
				}
				//mapTempToCompare.put(str,a);
			}
			
			system.debug('@#@#5'+mapAccountToBeUpdate.size());
			system.debug('@#@#6'+mapAccountToBeUpdate);
			//Check for map size
			if(mapAccountToBeUpdate.size() > 0) {
				
				//Update map values
				update mapAccountToBeUpdate.values();
			}
		}
		catch(Exception e) {
			
			system.debug('@#@#'+e.getMessage());
		}
	}
	 
	 /**
	 *	@ Description	:	Finish method of Batch
	 *
	 *	@ Args			:	Database.batchableContext bc
	 *
	 *	@ Return		:	void
	 **/
	 
	 global void finish(Database.batchableContext bc) {
	 	
	 }
	
	

}