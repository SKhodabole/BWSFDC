global with sharing class UpdatePeriodEndDateBatch implements Database.Batchable<sobject> {
	global String strQuery;
	
	global Database.QueryLocator start(Database.BatchableContext bc){
		return Database.getQueryLocator(strQuery);
	}
	
	global void execute(Database.batchableContext bc, List<Sales_Data__c> sdList){
		UpdatePeriodEndDateUtil.updatePeriodEndDate(sdList);
	}
	
	global void finish(Database.batchableContext bc){
    
    }
    
	
}