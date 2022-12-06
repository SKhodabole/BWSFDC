global with sharing class Batch_SalesDataBlankUpdate implements Database.Batchable<sobject> {
    
    //String used in query
    public String str = '';
    
    //To hold Query String
    public String strQuery = '';
    
    //Constructor
    global Batch_SalesDataBlankUpdate (String str1) {
        
        str = str1;
    }
    
    //Start method of Batch
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        //Set query in string
        strQuery = 'Select Id from Sales_Data__c where Month__c = null Order By ' + str +'';
         
        //return query 
        return Database.getQueryLocator(strQuery);
    }
    
    //Execute method of batch
    global void execute(Database.batchableContext bc, List<Sales_Data__c> lisSalesData ) {      
        
        //update salesData list
        update lisSalesData;
    }
    
    //finish method of batch
    global void finish(Database.batchableContext bc){
    
    }
}