/**
 * 	Purpose			:	Helper class for user trigger
 * 
 * 	Created By		:		
 * 
 * 	Created Date	:	
 * 
 * 	Revision Logs	:	
 * 
 **/ 
public without sharing class UserTriggerHelper {
	
	/**
	 *	@description	:	This method is to check if teh Manager or Regional VP is changed on User record, update the related opporutnities
	 *
	 *	@args			:	List of new users, list of old users
	 *
	 *	@return			:	void
	 *
	 **/
	public static void updateUserRelatedOpps(List<User> users, Map<Id, User> mapOldUsers) {
		
		//Set to hold the user to be processed where Manager or VP is updated, or Manager's or VP's email is updated
		Set<Id> setEffectiveUsers = new Set<Id>();
		
		//Set to hold the Ids of the users where email address is updated
		Set<Id> setManagers = new Set<Id>();
		
		//Loop through the users and check if the Manager of Regional VP is updated
		for(User user : users) {
			
			//Check mmanager and RegionalVP
			if(user.ManagerId != mapOldUsers.get(user.Id).ManagerId 
				|| user.Regional_VP__c != mapOldUsers.get(user.Id).Regional_VP__c) {
			
				//Add in the set of users to process
				setEffectiveUsers.add(user.Id);		
			}
			
			//Check if the user's email is update
			if(user.Email != mapOldUsers.get(user.Id).Email) {
				
				//Add this in the list of managers
				setManagers.add(user.Id);
			}
		}
		
		//Check if email address updated of any user]
		if(setManagers.size() > 0) {
			
			//Fetch the users where setManagers are stamped as Manager or Regional_VP
			Map<Id, User> managersReportee = new Map<Id, User>([Select Id from User where ManagerId IN: setManagers OR Regional_VP__c IN: setManagers]);
			
			//Add these users in the set of users to be processed
			setEffectiveUsers.addAll(managersReportee.keySet());
		}
		
		//Check if there is any record to process
		if(setEffectiveUsers.size() == 0)
			return;
		
		//Fetch the opportunities where current user is stamped as owner
		//Execute blank update and that will execute the workflow to update the Manager and Regional VP email on opporutnity
		List<Opportunity> opps = [Select Id from Opportunity where OwnerId IN: setEffectiveUsers and (RecordType.DeveloperName = 'Custom_Label_Quote_Follow_Up' OR RecordType.DeveloperName = 'Cenveo')];
		
        if(!opps.isEmpty() && opps.size() > 0){
            update opps;
        }
         
	} 
}