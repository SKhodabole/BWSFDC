@isTest
private class Test_Batch_SalesDataBlankUpdate {
	public static User managerUser1;
    @testSetup 
    public static void setupmethod(){
	 Profile p = [select id from profile where name='System Administrator'];
        
     String name = 'A-test1';
     managerUser1 = new User(Alias = name, Email = name + '@asdfg.junk', EmailEncodingKey = 'UTF-8',
            FirstName = 'Test', lastname = name, LanguageLocaleKey = 'en_US', LocaleSIDKey = 'en_US',
            Profileid = p.Id, TimezoneSIDKey = 'America/Los_Angeles', Username = name + '@asdfg.junk',EmployeeNumber = '101');
        
        insert managerUser1;        
    }
    static testMethod void myUnitTest() {
       User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
		
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
       //List Of Sales Data
       
	    //List of Accounts for customer
	   	List<Account> accounts = new List<Account>();
    		
		//Create Account and add to list
        for(Integer i = 0;i < 3; i++) {
          Account acc = new Account(Name='Test'+i+'Acc',Industry = 'Business Services',Type = 'Customer',recordTypeId = recordTypeId);
          accounts.add(acc);
        }
        
        //Insert Accounts
        System.runAs(managerUser){
            insert accounts;
        }
        
	       
        //Create Plant
        Plant__c plant =  new Plant__c(Name = 'TestPlant' ,City__c = 'Jaipur');
        insert plant;
	        
        //Create Product 
        Product2 prod = new Product2(Name = 'TestProduct');
        insert prod;
        
        //Create PlantProduct
        Plant_Products__c plantProd = new Plant_Products__c (Name = 'Test',Plant__c = plant.Id,Product__c = prod.Id);
        insert plantProd;
	    
	    
	        
	    //List of sales data
        List<Sales_Data__c> sdlist = new List<Sales_Data__c>();
	        
  		//List Of accounts
     	List<Account> accountList = [Select Id from Account Where Type = 'Customer'];
	      
      	//Assert  
        system.assertEquals(3,accountList.size());
        
        //Plant product
        Plant_Products__c plantproduct = [Select Id From Plant_Products__c Limit 1];
	        
        //Create Sales Data and add to list
        for(Integer i = 0; i < accountList.size(); i++) {
          
          Sales_Data__c sd = new Sales_Data__c();
          sd.Account__c = accountList[i].Id;
          sd.Plant_Product__c = plantproduct.Id;
          sd.Year__c = String.valueOf(Date.today().Year());
          sd.Period__c = 10;
          sd.Actual_Amount__c = 100;   
          sd.Actual_Units__c = 20;
          sdlist.add(sd);
        }
        insert sdlist;
        
       	//Test Start
        Test.startTest();
        
        List<Sales_Data__c> sdLists = [Select Id, Month__c from Sales_Data__c where Id IN: sdlist];
        sdLists[0].Month__c = '';
        sdLists[1].Month__c = '';
        update sdList;
        
        sdLists = [Select Id, Month__c from Sales_Data__c where Month__c = null];
        
        system.debug('@#@#@#'+sdLists);
        Batch_SalesDataBlankUpdate batch = new Batch_SalesDataBlankUpdate('LastModifiedDate desc');
        DataBase.executeBatch(batch);
        
        Test.stopTest();
    }
}