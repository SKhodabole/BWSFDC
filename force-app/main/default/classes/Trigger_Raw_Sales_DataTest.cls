/*
    Test class having methods for trigger on Raw_Sales_Data__c
*/
@isTest(SeeAllData=false)
public class Trigger_Raw_Sales_DataTest{

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
    static testMethod void unitTest01(){ 
         User managerUser = [select id from User where Email = 'A-test1@asdfg.junk'];
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        list<Account> listAccount = new list<Account>();        
        System.runAs(managerUser){
        listAccount.add(new Account(Name = 'Test Account',recordTypeId = recordTypeId));
        listAccount.add(new Account(Name = 'Test Account2',recordTypeId = recordTypeId));
        listAccount.add(new Account(Name = 'Test Account3',recordTypeId = recordTypeId));
        listAccount.add(new Account(Name = 'Test Account4', Billing_Account_Number__c = '9874563210',recordTypeId = recordTypeId));
        listAccount.add(new Account(Name = 'Test Account5', Billing_Account_Number__c = '019.0922',recordTypeId = recordTypeId));
        insert listAccount;
        }
        Plant__c p = new Plant__c(Name = 'Test Plant name');
        insert p;
        
        list<Plant_Products__c> listPP = new list<Plant_Products__c>();
        listPP.add(new Plant_Products__c(Name = 'Test Plant name', Plant__c = p.id));
        insert listPP;
        
        list<Raw_Sales_Data__c> listRSD = new list<Raw_Sales_Data__c>();
        listRSD.add(new Raw_Sales_Data__c(Admin_Forced_Account_Id__c = listAccount.get(0).id));
        listRSD.add(new Raw_Sales_Data__c(Admin_Forced_Account_Name__c = listAccount.get(0).Name));
        listRSD.add(new Raw_Sales_Data__c(Admin_Forced_Plant_Product_Id__c = listPP.get(0).id));
        listRSD.add(new Raw_Sales_Data__c(Admin_Forced_Plant_Product_Name__c= listPP.get(0).Name));
        insert listRSD;
        
        test.startTest();
            listRSD.get(0).Admin_Forced_Plant_Product_Id__c = listPP.get(0).id;
            listRSD.get(1).Admin_Forced_Plant_Product_Name__c = listPP.get(0).name;
            
            update listRSD;
            
            Raw_Sales_Data__c rsd = [ Select Admin_Forced_Account_Match__c 
                                      From Raw_Sales_Data__c 
                                      Where Id =: listRSD.get(0).Id ];
            //system.assert( rsd.Admin_Forced_Account_Match__c != null );
            
        test.stopTest();
    }
}