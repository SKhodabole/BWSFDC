@isTest
private class Test_AddSalesDataController {
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
        //Record Type
        List<RecordType> rType = [Select Id From RecordType Where SObjectType = 'Sales_Data__c' AND DeveloperName = 'Forecast_Sales_Data' AND isActive=true LIMIT 1];
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name = 'TestSales', Type = 'Customer', recordTypeId= recordTypeId));
        System.runAs(managerUser){
            insert accList;
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
        
        //Set Account Id in page url
        ApexPages.CurrentPage().getParameters().put('accid',accList[0].Id);
        
        //Test start here
        Test.startTest();
        
        //Instance of standard controller
        ApexPages.StandardController stdCont = new ApexPages.StandardController(accList[0]);
        
        //Instance of  conroller class
        AddSalesDataController controller = new AddSalesDataController(stdCont);
        
        //Set properties  for controller 
        controller.sd.Account__c = accList[0].Id;
        controller.sd.Plant_Product__c = plantProd.Id;
        controller.sd.Year__c = String.valueOf(Date.today().Year());
        controller.sd.Period__c = 12;
        
        //Controller method call
        controller.doSave();
        
        //Query sales data record
        List<Sales_Data__c> sdList = [Select id, Account__c, Plant_Product__c, Year__c from Sales_Data__c where Account__c =: accList[0].Id AND Plant_Product__c =: plantProd.Id];
        
        //Asserts
        System.assert(sdList.size() > 0);
        System.assertEquals(false,controller.errorLog);
       	
       	//Set properties of controller
        controller.sd.Account__c = accList[0].Id;
        controller.sd.Plant_Product__c = plantProd.Id;
        controller.sd.Year__c = String.valueOf(Date.today().Year());
        controller.sd.Period__c = 12;
        
        //save method call
        controller.doSave();
       	
       	//Assert
       	System.assertEquals(true,controller.errorLog);
        
        //Reintialize controller instance
        controller = new AddSalesDataController(stdCont);
        controller.sd.Period__c = 11;
        controller.doSave();
        
        //Query sales data record
        sdList = [Select id, Account__c, Plant_Product__c, Year__c from Sales_Data__c where Period__c =11];
        
        //Asserts
        System.assertEquals(0,sdList.size());
        System.assertEquals(true,controller.errorLog);
        
        //Reintialize controller instance
        controller = new AddSalesDataController(stdCont);
        controller.sd.Year__c = '2015';
        controller.doSave();
        
        //Query sales data record
        sdList = [Select id, Account__c, Plant_Product__c, Year__c from Sales_Data__c where Year__c = '2015'];
        
        //Assert
        System.assertEquals(0,sdList.size());
        
        //Reintialize controller instance
        controller = new AddSalesDataController(stdCont);
        controller.sd.Year__c = '2015';
        controller.sd.Period__c = 13;
        controller.doSave();
        
        //Query sales data record
        sdList = [Select id, Account__c, Plant_Product__c, Year__c from Sales_Data__c where Year__c = '2015' AND Period__c = 13];
        
        //Asserts
        System.assertEquals(0,sdList.size());
        System.assertEquals(true,controller.errorLog);
        
        //Reintialize controller instance
        controller = new AddSalesDataController(stdCont);
        controller.sd.Year__c = '2040';
        controller.sd.Period__c = 2;
        controller.doSave();
        
        //Query sales data record
        sdList = [Select id, Account__c, Plant_Product__c, Year__c from Sales_Data__c where Year__c ='2040'];
        
        //Asserts
        System.assertEquals(0,sdList.size());
        System.assertEquals(true,controller.errorLog);
        
        //Reintialize controller instance
        controller = new AddSalesDataController(stdCont);
        controller.sd.Year__c = '2022';
        controller.doCancel();
       
        //Test stop here
        Test.stopTest();
    }
}