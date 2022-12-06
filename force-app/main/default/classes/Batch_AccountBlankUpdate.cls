global class Batch_AccountBlankUpdate implements Database.Batchable<sobject> , Database.Stateful{
	
	String idString ='';

//Start method of Batchable interface
	global Database.QueryLocator start(Database.BatchableContext bc){
     	
     	//Query string to fetch account records where ParentId is null
		String strQuery = 'Select Id,BOY_Forecast__c,Current_YTD_Sales__c,Is_Eligible_For_Outlook_Report__c,Is_Eligible_For_Budget_Report__c,Current_Year_Budget__c,CY_Budget_100K__c, Name from Account where RecordType.DeveloperName = \'Cenveo\''; 
		
		
		//return query
		return Database.getQueryLocator(strQuery);
	}
    
    //Execute method of Batchable interface
	global void execute(Database.batchableContext bc, List<Account> scope ) {
	
		//Loop through the accounts and check if the need to be processed
		for(Account account : scope) {
		    
	        //curremt year outlook
	        Double currentYearOutloook = 0;
	        if(account.BOY_Forecast__c != null)
	            currentYearOutloook += account.BOY_Forecast__c; 
	        if(account.Current_YTD_Sales__c != null)
	            currentYearOutloook += account.Current_YTD_Sales__c;
	            
			//Check for current outlook limit
			if(currentYearOutloook >= AccountTriggerHelper.CURRENT_YEAR_OUTLOOK_LIMIT) {
    	
				//mark field as true
				account.Is_Eligible_For_Outlook_Report__c = true;
			}
            else {
            	//Mark field as false
            	account.Is_Eligible_For_Outlook_Report__c = false;
            }
	            
            //Check for current year budget value upto 250K
            if(account.Current_Year_Budget__c >= AccountTriggerHelper.CURRENT_YEAR_BUDGET_LIMIT) {
                
                //Mark Field value as true
                account.Is_Eligible_For_Budget_Report__c = true;
            }
            else {
        		
        		//Mark field value as false if CY Budget less than 250K
        	 	account.Is_Eligible_For_Budget_Report__c = false;
            }
	            
          	//Check for current year budget value upto 100K
          	if(account.Current_Year_Budget__c >= AccountTriggerHelper.CURRENT_YEAR_BUDGET_LIMIT_MIN) {
          		
          		//Mark field as true
          		account.CY_Budget_100K__c = true;
      		}
          	else {
          		//Mark field value as false if CY Budget less than 100K
          		account.CY_Budget_100K__c = false;
          	}
		}

		Database.SaveResult[] srList = Database.update(scope,false);
	
		// Iterate through each returned result
		for (Database.SaveResult sr : srList) {
		    if (!sr.isSuccess()) {
		        
		        // Operation failed, so get all errors                
		        for(Database.Error err : sr.getErrors()) {
		        	idString += sr.getId() +',';
		        }
			}
		}
	}
	
	//Finish method of Batchable interface
	global void finish(Database.batchableContext bc){
		
		if(idString != null) {
		 
	        // Email the Batch Job's submitter that the Job is finished.
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        String[] toAddresses = new String[] {'priyanka.khandelwal@simplyfoce.com'};
	        //toAddresses.add('sanjeev.mehta@bytehash.com');
	        system.debug('toAddresses = ' + toAddresses);
	        mail.setToAddresses(toAddresses);
	        mail.setSubject('Account Sales Rollup - Batch Job : ');
	        mail.setPlainTextBody('errors'+idString);
	
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
			
	}  
}