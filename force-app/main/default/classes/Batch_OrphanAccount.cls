/**
 *	@ Purpose		:		Batch for fetch all Account records which doesn't contain parent and child
 *
 *	@ Created By	:		Bhavi Sharma
 *
 *	@ Created Date	:		09/08/2015
 *
 *	@ Rivision Log	:		
 *
 *	@ Version		:		V-1.0
 **/
global class Batch_OrphanAccount implements Database.Batchable<sobject> , Database.Stateful{

	//Store records of account processed in execute method 
	String stringAccount = '';
	
	//Start method of Batchable interface
	global Database.QueryLocator start(Database.BatchableContext bc){
     	
     	//Query string to fetch account records where ParentId is null
		String strQuery = 'Select Id, Name ,Industry, (Select Id from ChildAccounts limit 1) from Account where ParentId = null AND RecordType.DeveloperName = \'Cenveo\'';
		
		//return query
		return Database.getQueryLocator(strQuery);
	}
    
    //Execute method of Batchable interface
	global void execute(Database.batchableContext bc, List<Account> scope ) {
		
		//Loop through scope return by start  
		for(Account acc : scope) {
		
		//Check for Account doesn't contain child Account  and store data in string
		if(acc.ChildAccounts.size() == 0) 
			stringAccount += acc.Id +  '##SF##' + acc.Name +  '##SF##' + acc.Industry + '\r\n';
		}
	}
	
	//Finish method of Batchable interface
	global void finish(Database.batchableContext bc){
		
		//Create Document file
		Document doc1 = new Document (Name = 'OrphanAccBackup'+'.csv'); 
		doc1.Description = '';                     
		doc1.FolderId = UserInfo.getUserId();                
		doc1.Body = Blob.valueOf(stringAccount); 
        
        //insert Document
		insert doc1;
        
		//Debug
		System.debug('stringAccount:::::'+ stringAccount);    
	}  
}