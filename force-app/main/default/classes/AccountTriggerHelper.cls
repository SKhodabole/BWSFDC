public without sharing class AccountTriggerHelper {

  public static Boolean runTrigger = true;

  public static List<Account> newAccounts;
    public static List<Account> oldAccounts;
    public static Map<Id, Account> newMapAccounts;
    public static Map<Id, Account> oldMapAccounts;
  public static Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
  // method to pupulate parent id in custom field for parent id ( external Id field )
  // Parent_Id__c is used in as filter queries as more than 100000 records for account object
  public static void populateParentId() {
     for( Account acc : newAccounts ) {
         if( acc.RecordTypeId == accRecordTypeId) {
        acc.Parent_Id__c = acc.ParentId;
         }
     }
  }

  // method to pupulate old owner on account on owner change
  public static void populateOldOwner() {
     for( Account acc : newAccounts ) {
        Id oldOwnerId = oldMapAccounts.get(acc.Id).OwnerId;
        if( acc.OwnerId != oldOwnerId && acc.RecordTypeId == accRecordTypeId) {
            acc.Old_Owner__c = oldOwnerId;
        }
     }
  }

  
 



  
  
    //Varibale to hold the Current_Year_Outlook__c boundry limit
    public final static Double CURRENT_YEAR_OUTLOOK_LIMIT = 250000;
    public final static Double CURRENT_YEAR_BUDGET_LIMIT = 250000;
    public final static Double CURRENT_YEAR_BUDGET_LIMIT_MIN = 100000;
    
    //Variable to control the execution of method
    public static Boolean EXECUTE_VALIDATE_IS_ELIGIBLE_FOR_REPORTING = true;
    
    
    
    
    /*
        Method to update user record on Owner change on account
    */
    public static void updateUserOnOwnerChange() {
        
        Set<Id> setAccountAssignedUserIds = new Set<Id>(); 
        Set<Id> setAccountAssignmentRemovedUserIds = new Set<Id>(); 
        // loop over accounts
        for( Account acc : newAccounts ) {
            // when insert context
            if( trigger.isInsert ) {
                // when owner is a user
                if( acc.OwnerId != null 
                    && String.valueOf(acc.OwnerId).startsWith('005') && acc.RecordTypeId == accRecordTypeId) {
                    setAccountAssignedUserIds.add( acc.OwnerId );
                }
            }
            // when update context
            else if( trigger.isUpdate ) {
                
                //system.assert( false,  ' 11 TEST Exception Ignore Email ******* mapUsersToUpdate ' + acc.Id + '***** '+  acc.OwnerId + ' **** ' + oldMapAccounts.get(acc.Id).OwnerId );
                // when owner is changed
                if( acc.OwnerId != oldMapAccounts.get(acc.Id).OwnerId &&  acc.RecordTypeId == accRecordTypeId) {
                    
                    // when owner is a user
                    if( acc.OwnerId != null && String.valueOf(acc.OwnerId).startsWith('005')) {
                        setAccountAssignedUserIds.add( acc.OwnerId );
                    }
                    // when old owner was a user
                    if( oldMapAccounts.get(acc.Id).OwnerId != null 
                        && String.valueOf(oldMapAccounts.get(acc.Id).OwnerId).startsWith('005')) {
                        
                        setAccountAssignmentRemovedUserIds.add( oldMapAccounts.get(acc.Id).OwnerId );
                    }
                }
            }
        }
        if( setAccountAssignedUserIds.size() > 0 || setAccountAssignmentRemovedUserIds .size() > 0 ) {
       		 updateUser(setAccountAssignedUserIds, setAccountAssignmentRemovedUserIds);
        }
        
    }
    
    @future
    public static void updateUser(Set<Id> setAccountAssignedUserIds, Set<Id> setAccountAssignmentRemovedUserIds ){
        // when 1 or more user sto update
        if( setAccountAssignedUserIds.size() > 0 || setAccountAssignmentRemovedUserIds .size() > 0 ) {
            // query users
            Map<Id, User> mapUsersToUpdate = new Map<Id, User>([ Select Id From User 
                                                        Where ( Id in: setAccountAssignedUserIds 
                                                                OR Id in: setAccountAssignmentRemovedUserIds )
                                                        ]);
            // loop over users
            for( User u : mapUsersToUpdate.values() ) {
                // when set contains user id
                if( setAccountAssignedUserIds.contains( u.Id )) {
                    u.Most_Recent_Account_Assignment_Date__c = Date.today();
                }
                // when set contains user id
                if( setAccountAssignmentRemovedUserIds.contains( u.Id )) {
                    u.Most_Recent_Account_Removal_Date__c = Date.today();
                }
                mapUsersToUpdate.put( u.Id, u );
            }
            // when map has any items
            if( mapUsersToUpdate.size() > 0 ) {
                update mapUsersToUpdate.values();
            }
        }
    }
    
     /**
     *  @description    :   This method is used for blank update T&E object records when new task created on Account
     *
     *  @args           :   List<Account> newAccount , Map<Id, Account> mapOldAccountOpenActivity
     *
     *  @return         :   void
     *
     **/
    public static void updateTAndEBlank(List<Account> newAccount , Map<Id, Account> mapOldAccountOpenActivity ) {
    	
    	//Map to hold Account Ids over the Account
    	Map<Id, Account> mapAccountToUpdateTAndE = new Map<Id, Account>();
    	
    	//Check for Account update
    	if(newAccount != null && mapOldAccountOpenActivity != null) {
    		
    		//Loop through Account
    		for(Account newAccs : newAccount) {
    			
    			//check for OPEN ACTIVITIES  update on Account
    			if(newAccs.RecordTypeId == accRecordTypeId && mapOldAccountOpenActivity.get(newAccs.Id).OPEN_ACTIVITIES__c != newAccs.OPEN_ACTIVITIES__c) {
    				
    				//Populate map Account Id with Account
    				mapAccountToUpdateTAndE.put(newAccs.Id, new Account(Id = newAccs.Id));
    			}
    		}
    		
    		//Check map size
    		if(mapAccountToUpdateTAndE.size() > 0) {
    			
	    		//Fetch T&E records based on Accounts in Map
	    		List<T_E__c> listOfTAndE = [Select Id from T_E__c where Account_1__c  IN : mapAccountToUpdateTAndE.keySet() OR
	    									 							Account_2__c  IN : mapAccountToUpdateTAndE.keySet() OR
										 							 	Account_3__c  IN : mapAccountToUpdateTAndE.keySet() OR
										 								Account_4__c  IN : mapAccountToUpdateTAndE.keySet()];
 								
	 			//Check for list size and update T&E records
	    		if(listOfTAndE.size() > 0)
	    			update listOfTAndE;
    		}
    	}
    }
}