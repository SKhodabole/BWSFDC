@isTest(SeeAllData=false)
public class NameMappingConfigurationTriggerTest{
    
    static testMethod void unitTest01(){ 
        User u = CreateUser();
        insert u;
    
        list<Account> listAccount = new list<Account>();
        list<Name_Mapping_Configuration__c> listNMC = new list<Name_Mapping_Configuration__c>();
        list<Sales_Data__c> listSD = new list<Sales_Data__c>();
        list<Raw_Sales_Data__c> listRSD = new list<Raw_Sales_Data__c>();
        list<Plant_Products__c> listPP = new list<Plant_Products__c>();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        System.RunAs(u) {
            listAccount.add(new Account(Name = 'Test Account', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account2', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account3', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account4', Billing_Account_Number__c = '9874563210', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account5', Billing_Account_Number__c = '019.0922', recordTypeId = recordTypeId));
            insert listAccount;
            
            Plant__c p = new Plant__c(Name = 'Test Plant name');
            insert p;
            listPP.add(new Plant_Products__c(Name = 'Test Plant name', Plant__c = p.id));
            insert listPP;
            
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Account Name', SFDC_Value__c = 'Test Account', Mapped_Value__c = 'Test Account'));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'User Name', SFDC_Value__c = 'Testing User', Mapped_Value__c = 'Testing User', User__c = u.Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Plant Product Name', SFDC_Value__c = 'Test Plant name-', Mapped_Value__c = 'Test Plant name-', Plant_Product__c = listPP.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Billing Account Number', SFDC_Value__c = '019.0922', Mapped_Value__c = '19.0922', Account__c = listAccount.get(4).Id));
        }
        
        test.startTest();
            insert listNMC;
            
            List<Name_Mapping_Configuration__c> nmcList = [Select Id, Account__c,User__c,Plant_Product__c,Message__c from Name_Mapping_Configuration__c where Id =: listNMC[0].Id];
            
            //system.assertEquals(null,nmcList[0].Account__c);
            //system.assertEquals(null,nmcList[0].User__c);
            //system.assertEquals(null,nmcList[0].Plant_Product__c);
            //system.assertEquals(System.label.No_Account_Match_Found,nmcList[0].Message__c);
            
        test.stopTest();
    }
    
    static testMethod void unitTest02(){ 
        User u = CreateUser();
        insert u;
    
        list<Account> listAccount = new list<Account>();
        list<Name_Mapping_Configuration__c> listNMC = new list<Name_Mapping_Configuration__c>();
        list<Sales_Data__c> listSD = new list<Sales_Data__c>();
        list<Raw_Sales_Data__c> listRSD = new list<Raw_Sales_Data__c>();
        list<Plant_Products__c> listPP = new list<Plant_Products__c>();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
        System.RunAs(u) {
            listAccount.add(new Account(Name = 'Test Account',recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account2',recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account3',recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account4', Billing_Account_Number__c = '9874563210',recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account5', Billing_Account_Number__c = '019.0922',recordTypeId = recordTypeId));
            insert listAccount;
            
            Plant__c p = new Plant__c(Name = 'Test Plant name');
            insert p;
            listPP.add(new Plant_Products__c(Name = 'Test Plant name', Plant__c = p.id));
            insert listPP;
            
            
            List<Account> accs = [Select id, Name from Account where Name =: 'Test Account'];
            
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Account Name', SFDC_Value__c = 'Test Account', Mapped_Value__c = 'Test Account', Account__c = listAccount.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'User Name', SFDC_Value__c = 'Testing User', Mapped_Value__c = 'Testing User', User__c = u.Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Plant Product Name', SFDC_Value__c = 'Test Plant name-', Mapped_Value__c = 'Test Plant name-', Plant_Product__c = listPP.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Billing Account Number', SFDC_Value__c = '019.092255', Mapped_Value__c = '19.0922'));
        }
        
        test.startTest();
            insert listNMC;
            
            listNMC.get(0).SFDC_Value__c = 'Test Error record';
            listNMC.get(1).SFDC_Value__c = 'Test Error record';
            listNMC.get(2).SFDC_Value__c = 'Test Error record';
            update listNMC;
            
             List<Name_Mapping_Configuration__c> nmcList = [Select Id, Account__c,User__c,Plant_Product__c,Message__c from Name_Mapping_Configuration__c where Id =: listNMC[0].Id];
            
            //system.assertEquals(null,nmcList[0].Account__c);
            //system.assertEquals(null,nmcList[0].User__c);
            //system.assertEquals(null,nmcList[0].Plant_Product__c);
            
        test.stopTest();
    }
    
    static testMethod void unitTestUserActive(){ 
        User u = CreateUser();
        
       // u.IsActive = false;
        insert u;
        
   	 
        list<Account> listAccount = new list<Account>();
        list<Name_Mapping_Configuration__c> listNMC = new list<Name_Mapping_Configuration__c>();
        list<Sales_Data__c> listSD = new list<Sales_Data__c>();
        list<Raw_Sales_Data__c> listRSD = new list<Raw_Sales_Data__c>();
        list<Plant_Products__c> listPP = new list<Plant_Products__c>();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
            listAccount.add(new Account(Name = 'Test Account',recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account2',recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account3',recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account4', Billing_Account_Number__c = '9874563210',recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account5', Billing_Account_Number__c = '019.0922',recordTypeId = recordTypeId));
        System.runAs(u){
            insert listAccount;
        }    
        
            
            Plant__c p = new Plant__c(Name = 'Test Plant name');
            insert p;
            listPP.add(new Plant_Products__c(Name = 'Test Plant name', Plant__c = p.id));
            insert listPP;
            
           
    		
            List<Account> accs = [Select id, Name from Account where Name =: 'Test Account'];
            
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Account Name', SFDC_Value__c = 'Test Account', Mapped_Value__c = 'Test Account', Account__c = listAccount.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'User Name', SFDC_Value__c = 'Testing User', Mapped_Value__c = 'Testing User', User__c = u.Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Plant Product Name', SFDC_Value__c = 'Test Plant name-', Mapped_Value__c = 'Test Plant name-', Plant_Product__c = listPP.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Billing Account Number', SFDC_Value__c = '019.092255', Mapped_Value__c = '19.0922'));
        
        test.startTest();
        	
            insert listNMC;
            
            listNMC.get(0).SFDC_Value__c = 'Test Error record';
            listNMC.get(1).SFDC_Value__c = 'Test Error record';
            listNMC.get(2).SFDC_Value__c = 'Test Error record';
            update listNMC;
            
             List<Name_Mapping_Configuration__c> nmcList = [Select Id, Account__c,User__c,Plant_Product__c,Message__c from Name_Mapping_Configuration__c where Id =: listNMC[0].Id];
            
            //system.assertEquals(null,nmcList[0].Account__c);
            //system.assertEquals(null,nmcList[0].User__c);
            //system.assertEquals(null,nmcList[0].Plant_Product__c);
            
        test.stopTest();
    }
    
    public static User createUser() {
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'tesusr', email = 'testinguser@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing User', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'testinguser@newtest.com',EmployeeNumber = '12321');
           
        return u;
    }
}