/**
 *	Purpose			:	This class is helper class for trigger on User object.
 *               
 *  Create By		:	
 *   
 *  Created Date	:	
 *   
 *   Revision Log	:	
 *
 **/
public without sharing class TETriggerHelper {
		
	/**
	 *	@description	:	This method is to pull the Open Activities from Account to T&E
	 *
	 *	@args			:	List of New TEs
	 *
	 *	@return			:	void
	 *
	 **/
	public static void populateTEData(List<T_E__c> listTEs) {
		
		//Create a set to hold the set of account Ids
		Set<Id> accIds = new Set<Id>();
		
		//Loop through the TEs and populate the Account Ids set
		for(T_E__c tE : listTEs) {
			
			//Check for the Null
			if(tE.Account_1__c != null)
				accIds.add(tE.Account_1__c);
			if(tE.Account_2__c != null)
				accIds.add(tE.Account_2__c);
			if(tE.Account_3__c != null)
				accIds.add(tE.Account_3__c);
			if(tE.Account_4__c != null)
				accIds.add(tE.Account_4__c);
		}
		
		//Check for the size
		if(accIds.size() == 0)
			return;
		
		//Pull accounts from data base
		Map<Id, Account> mapAccounts = new Map<Id, Account>([Select Id, OPEN_ACTIVITIES__c from Account where Id IN: accIds]); 
		
		//Loop through the TEs and populate the Account Ids set
		for(T_E__c tE : listTEs) {
			
			//Check for the Null
			if(tE.Account_1__c != null && mapAccounts.containsKey(tE.Account_1__c))
				tE.Account_1_OPEN_ACTIVITIES_TEXT__c = mapAccounts.get(tE.Account_1__c).OPEN_ACTIVITIES__c;
			if(tE.Account_2__c != null && mapAccounts.containsKey(tE.Account_2__c))
				tE.Account_2_OPEN_ACTIVITIES_TEXT__c = mapAccounts.get(tE.Account_2__c).OPEN_ACTIVITIES__c;
			if(tE.Account_3__c != null && mapAccounts.containsKey(tE.Account_3__c))
				tE.Account_4_OPEN_ACTIVITIES_TEXT__c = mapAccounts.get(tE.Account_3__c).OPEN_ACTIVITIES__c;
			if(tE.Account_4__c != null && mapAccounts.containsKey(tE.Account_4__c))
				tE.Account_4_OPEN_ACTIVITIES_TEXT__c = mapAccounts.get(tE.Account_4__c).OPEN_ACTIVITIES__c;
		}
	}
}