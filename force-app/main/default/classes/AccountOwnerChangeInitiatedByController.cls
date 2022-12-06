/**
 * 	Purpose			:	Controller class for AccountChangeOwnerInitiatedBy page.
 							This class is to save the data collectred from page and redirect user on to the change owner screen
 * 
 * 	Created By		:	
 * 
 * 	Created Date	:	
 * 
 * 	Revision Logs	:	
 * 
 **/ 
public with sharing class AccountOwnerChangeInitiatedByController {
	
	//Account Instance
	public Account account {get; set;}
	
	//Constructor
	public AccountOwnerChangeInitiatedByController(ApexPages.StandardController controller) {
		
		//Get instance
		account = (Account)controller.getRecord();
	}
	
	/**
	 *	@descrition	:	Redirect user to the change owner screen
	 * 
	 * 	@args		:	
	 * 
	 * 	@return		:	PageReference
	 * 
	 **/
	public PageReference redirect() {
		
		//Create teh page reference instance and redirect user
		PageReference pageRef = new PageReference('/' + account.Id + '/a?retURL=' + account.Id);
		return pageRef;
	}
	
	/**
	 *	@descrition	:	Save the account record
	 * 
	 * 	@args		:	
	 * 
	 * 	@return		:	PageReference
	 * 
	 **/
	public PageReference saveAndRedirect() {
		
		try {
			
			//Update the account instance
			update account;
			return redirect();
		} catch(Exception e) {
			
			//Add the error message on page
			ApexPages.addMessages(e);
		}
		return null;
	}
}