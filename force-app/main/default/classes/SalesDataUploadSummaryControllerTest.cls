@isTest(SeeAllData=false)
public class SalesDataUploadSummaryControllerTest{

    static testMethod void unitTest01(){ 
        User u = CreateUser();
        insert u;
    
        list<Account> listAccount = new list<Account>();
        list<Name_Mapping_Configuration__c> listNMC = new list<Name_Mapping_Configuration__c>();
        list<Sales_Data__c> listSD = new list<Sales_Data__c>();
        list<Raw_Sales_Data__c> listRSD = new list<Raw_Sales_Data__c>();
        list<Plant_Products__c> listPP = new list<Plant_Products__c>();
        
        System.RunAs(u) {
            Sales_Data_Upload_Configurations__c sduc = new Sales_Data_Upload_Configurations__c(Process_Records_Limit__c = 1, Without_Error_Records_Limit__c = 1, Successfully_Records_Limit__c = 1, With_Error_Records_Limit__c = 1);
            insert sduc;
			Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
            listAccount.add(new Account(Name = 'Test Account', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account2', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account3', recordTypeId = recordTypeId, PeopleSoft_Acct__c = '9874563210'));
            listAccount.add(new Account(Name = 'Test Account4', Billing_Account_Number__c = '9874563210',PeopleSoft_Acct__c = '9874563210', recordTypeId = recordTypeId));
            insert listAccount;
            
            Plant__c p = new Plant__c(Name = 'Test Plant name');
            insert p;
            listPP.add(new Plant_Products__c(Name = 'Test Plant name', Plant__c = p.id));
            insert listPP;
            
            Finance_Information__c fi = new Finance_Information__c (Account_Number__c = '0987456321', Account__c = listAccount.get(2).id);
            insert fi;
            
            
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Account Name', SFDC_Value__c = 'Test Account', Mapped_Value__c = 'Test Account', Account__c = listAccount.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'User Name', SFDC_Value__c = 'Testing User', Mapped_Value__c = 'Testing User', User__c = u.Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Plant Product Name', SFDC_Value__c = 'Test Plant name-', Mapped_Value__c = 'Test Plant name-', Plant_Product__c = listPP.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'acclaim', Type__c = 'Billing Account Number', SFDC_Value__c = 'Test Account', Mapped_Value__c = 'Test Account', Account__c = listAccount.get(0).Id ));
            insert listNMC;
            
            //System.assert(false, listNMC);
            
            listSD.add(new Sales_Data__c(Period__c = Decimal.valueOf(datetime.now().addMonths(-1).month())));
            insert listSD;
            
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.ValueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account4', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '9874563210', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
            
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '0987456321', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));                                    
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = null
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = 'Error Message'
                                                ));                                                                        
            
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = '',
                                                Sales_Data__c = listSD.get(0).Id
                                                ));
            insert listRSD;
        }
        
        test.startTest();
        	
        	List<Raw_Sales_Data__c> rowSales = [Select Id,Year__c,Period__c from Raw_Sales_Data__c];
        	system.debug('$$$$$$$$$$'+ rowSales.size());
        	system.debug('$$$$$$$$$$'+ rowSales[0].Year__c);
        	system.debug('$$$$$$$$$$'+ rowSales[0].Period__c);
        	
            SalesDataUploadSummaryController controller = new SalesDataUploadSummaryController();
            controller.rawSalesData = listRSD.get(0);
            controller.selectedMonth = datetime.now().addMonths(-1).format('MMM').trim();
            controller.businesUnits.add(new SelectOption('Acclaim', 'Acclaim'));
            controller.selectedBusinessUnit = 'Acclaim';
            controller.process();
            //controller.businesUnits.add(new SelectOption('Acclaim', 'Acclaim'));
            controller.moveToSalesData();
            controller.nmc = createNMC();
            controller.saveMapping();
            
            controller.nextProcess();
            controller.previousProcess();
            
            controller.nextWithoutError();
            controller.previousWithoutError();
            
            controller.next();
            controller.previous();
            
            controller.nextWithError();
            controller.previousWithError();
        test.stopTest();
    }
    static testMethod void unitTest03(){ 
        User u = CreateUser();
        insert u;
    
        list<Account> listAccount = new list<Account>();
        list<Name_Mapping_Configuration__c> listNMC = new list<Name_Mapping_Configuration__c>();
        list<Sales_Data__c> listSD = new list<Sales_Data__c>();
        list<Raw_Sales_Data__c> listRSD = new list<Raw_Sales_Data__c>();
        list<Plant_Products__c> listPP = new list<Plant_Products__c>();
        
        System.RunAs(u) {
            Sales_Data_Upload_Configurations__c sduc = new Sales_Data_Upload_Configurations__c(Process_Records_Limit__c = 1, Without_Error_Records_Limit__c = 1, Successfully_Records_Limit__c = 1, With_Error_Records_Limit__c = 1);
            insert sduc;
			Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
            listAccount.add(new Account(Name = 'Test Account', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account2', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account3', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account4', Billing_Account_Number__c = '9874563210', recordTypeId = recordTypeId));
            insert listAccount;
            
            Plant__c p = new Plant__c(Name = 'Test Plant name');
            insert p;
            listPP.add(new Plant_Products__c(Name = 'Test Plant name', Plant__c = p.id));
            insert listPP;
            
            Finance_Information__c fi = new Finance_Information__c (Account_Number__c = '0987456321', Account__c = listAccount.get(2).id);
            insert fi;
            
            
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Account Name', SFDC_Value__c = 'Test Account', Mapped_Value__c = 'Test Account', Account__c = listAccount.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'User Name', SFDC_Value__c = 'Testing User', Mapped_Value__c = 'Testing User', User__c = u.Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Plant Product Name', SFDC_Value__c = 'Test Plant name-', Mapped_Value__c = 'Test Plant name-', Plant_Product__c = listPP.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Billing Account Number', SFDC_Value__c = 'Test Account', Mapped_Value__c = 'Test Account', Account__c = listAccount.get(0).Id ));
            insert listNMC;
            
            //System.assert(false, listNMC);
            
            listSD.add(new Sales_Data__c(Period__c = Decimal.valueOf(datetime.now().addMonths(-1).month())));
            insert listSD;
            
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.ValueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account4', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '9874563210', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
            
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '0987456321', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));                                    
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = null
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = 'Error Message'
                                                ));                                                                        
            
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = '',
                                                Sales_Data__c = listSD.get(0).Id
                                                ));
            insert listRSD;
        }
        
        test.startTest();
        	
        	List<Raw_Sales_Data__c> rowSales = [Select Id,Year__c,Period__c from Raw_Sales_Data__c];
        	system.debug('$$$$$$$$$$'+ rowSales.size());
        	system.debug('$$$$$$$$$$'+ rowSales[0].Year__c);
        	system.debug('$$$$$$$$$$'+ rowSales[0].Period__c);
        	
            SalesDataUploadSummaryController controller = new SalesDataUploadSummaryController();
            controller.rawSalesData = listRSD.get(0);
            controller.selectedMonth = datetime.now().addMonths(-1).format('MMM').trim();
            controller.businesUnits.add(new SelectOption('Acclaim', 'Acclaim'));
            controller.selectedBusinessUnit = 'Acclaim';
            controller.process();
            //controller.businesUnits.add(new SelectOption('Acclaim', 'Acclaim'));
            controller.moveToSalesData();
            controller.nmc = createNMC();
            controller.saveMapping();
            
            controller.nextProcess();
            controller.previousProcess();
            
            controller.nextWithoutError();
            controller.previousWithoutError();
            
            controller.next();
            controller.previous();
            
            controller.nextWithError();
            controller.previousWithError();
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
        
        System.RunAs(u) {
            Sales_Data_Upload_Configurations__c sduc = new Sales_Data_Upload_Configurations__c(Process_Records_Limit__c = 1, Without_Error_Records_Limit__c = 1, Successfully_Records_Limit__c = 1, With_Error_Records_Limit__c = 1);
            insert sduc;
			Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
            listAccount.add(new Account(Name = 'Test Account', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account2', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account3', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account4',Type= 'Customer', Billing_Account_Number__c = '9874563210',PeopleSoft_Acct__c = '9874563210', recordTypeId = recordTypeId));
            insert listAccount;
            
            Plant__c p = new Plant__c(Name = 'Test Plant name');
            insert p;
            listPP.add(new Plant_Products__c(Name = 'Test Plant name', Plant__c = p.id));
            insert listPP;
            
            Finance_Information__c fi = new Finance_Information__c (Account_Number__c = '0987456321', Account__c = listAccount.get(2).id);
            insert fi;
            
            
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Account Name', SFDC_Value__c = 'Test Account', Mapped_Value__c = 'Test Account', Account__c = listAccount.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'User Name', SFDC_Value__c = 'Testing User', Mapped_Value__c = 'Testing User', User__c = u.Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Plant Product Name', SFDC_Value__c = 'Test Plant name-', Mapped_Value__c = 'Test Plant name-', Plant_Product__c = listPP.get(0).Id ));
            insert listNMC;
            
            //System.assert(false, listNMC);
            
            listSD.add(new Sales_Data__c(Period__c = Decimal.valueOf(datetime.now().addMonths(-1).month())));
            insert listSD;
            
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '9874563210', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.ValueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true,Error_In_Processing__c= true
                                                ));
                                                
           /* listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account4', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '9874563210', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
            
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '0987456321', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));                                    
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = null
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = 'Error Message'
                                                ));                                                                        
            
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = '',
                                                Sales_Data__c = listSD.get(0).Id
                                                ));*/
            insert listRSD;
        }
        
        test.startTest();
        	
        	List<Raw_Sales_Data__c> rowSales = [Select Id,Year__c,Period__c from Raw_Sales_Data__c];
        	system.debug('$$$$$$$$$$'+ rowSales.size());
        	system.debug('$$$$$$$$$$'+ rowSales[0].Year__c);
        	system.debug('$$$$$$$$$$'+ rowSales[0].Period__c);
        	
            SalesDataUploadSummaryController controller = new SalesDataUploadSummaryController();
            controller.rawSalesData = listRSD.get(0);
            controller.selectedMonth = datetime.now().addMonths(-1).format('MMM').trim();
            controller.businesUnits.add(new SelectOption('Acclaim', 'Acclaim'));
            controller.selectedBusinessUnit = 'Acclaim';
            controller.process();
            //controller.businesUnits.add(new SelectOption('Acclaim', 'Acclaim'));
            controller.moveToSalesData();
            controller.nmc = createNMC();
            controller.saveMapping();
            
            controller.nextProcess();
            controller.previousProcess();
            
            controller.nextWithoutError();
            controller.previousWithoutError();
            
            controller.next();
            controller.previous();
            
            controller.nextWithError();
            controller.previousWithError();
        test.stopTest();
    }
    
    static testMethod void unitTest04(){ 
        User u = CreateUser();
        insert u;
    
        list<Account> listAccount = new list<Account>();
        list<Name_Mapping_Configuration__c> listNMC = new list<Name_Mapping_Configuration__c>();
        list<Sales_Data__c> listSD = new list<Sales_Data__c>();
        list<Raw_Sales_Data__c> listRSD = new list<Raw_Sales_Data__c>();
        list<Plant_Products__c> listPP = new list<Plant_Products__c>();
        
        System.RunAs(u) {
            Sales_Data_Upload_Configurations__c sduc = new Sales_Data_Upload_Configurations__c(Process_Records_Limit__c = 1, Without_Error_Records_Limit__c = 1, Successfully_Records_Limit__c = 1, With_Error_Records_Limit__c = 1);
            insert sduc;
			Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
            listAccount.add(new Account(Name = 'Test Account', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account2', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account3', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account4', Billing_Account_Number__c = '9874563210', recordTypeId = recordTypeId));
            insert listAccount;
            
            Plant__c p = new Plant__c(Name = 'Test Plant name');
            insert p;
            listPP.add(new Plant_Products__c(Name = 'Test Plant name', Plant__c = p.id));
            insert listPP;
            
            Finance_Information__c fi = new Finance_Information__c (Account_Number__c = '0987456321', Account__c = listAccount.get(2).id);
            insert fi;
            
            
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Account Name', SFDC_Value__c = 'Test Account', Mapped_Value__c = 'Test Account', Account__c = listAccount.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'User Name', SFDC_Value__c = 'Testing User', Mapped_Value__c = 'Testing User', User__c = u.Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Plant Product Name', SFDC_Value__c = 'Test Plant name-', Mapped_Value__c = 'Test Plant name-', Plant_Product__c = listPP.get(0).Id ));
            insert listNMC;
            
            //System.assert(false, listNMC);
            
            listSD.add(new Sales_Data__c(Period__c = Decimal.valueOf(datetime.now().addMonths(-1).month())));
            insert listSD;
            
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '9874563210', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Labels & Packaging', Year__c = '2015', Period__c = String.ValueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true,Error_In_Processing__c= true
                                                ));
                                                
           /* listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account4', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '9874563210', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
            
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '0987456321', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));                                    
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = null
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = 'Error Message'
                                                ));                                                                        
            
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = '',
                                                Sales_Data__c = listSD.get(0).Id
                                                ));*/
            insert listRSD;
        }
        
        test.startTest();
        	
        	List<Raw_Sales_Data__c> rowSales = [Select Id,Year__c,Period__c from Raw_Sales_Data__c];
        	system.debug('$$$$$$$$$$'+ rowSales.size());
        	system.debug('$$$$$$$$$$'+ rowSales[0].Year__c);
        	system.debug('$$$$$$$$$$'+ rowSales[0].Period__c);
        	
            SalesDataUploadSummaryController controller = new SalesDataUploadSummaryController();
            controller.rawSalesData = listRSD.get(0);
            controller.selectedMonth = datetime.now().addMonths(-1).format('MMM').trim();
            controller.businesUnits.add(new SelectOption('Acclaim', 'Acclaim'));
            controller.selectedBusinessUnit = 'Labels & Packaging';
            controller.process();
            //controller.businesUnits.add(new SelectOption('Acclaim', 'Acclaim'));
            controller.moveToSalesData();
            controller.nmc = createNMC();
            controller.saveMapping();
            
            controller.nextProcess();
            controller.previousProcess();
            
            controller.nextWithoutError();
            controller.previousWithoutError();
            
            controller.next();
            controller.previous();
            
            controller.nextWithError();
            controller.previousWithError();
        test.stopTest();
    }
    
    static testMethod void unitTest05(){ 
        User u = CreateUser();
        insert u;
    
        list<Account> listAccount = new list<Account>();
        list<Name_Mapping_Configuration__c> listNMC = new list<Name_Mapping_Configuration__c>();
        list<Sales_Data__c> listSD = new list<Sales_Data__c>();
        list<Raw_Sales_Data__c> listRSD = new list<Raw_Sales_Data__c>();
        list<Plant_Products__c> listPP = new list<Plant_Products__c>();
        
        System.RunAs(u) {
            Sales_Data_Upload_Configurations__c sduc = new Sales_Data_Upload_Configurations__c(Process_Records_Limit__c = 1, Without_Error_Records_Limit__c = 1, Successfully_Records_Limit__c = 1, With_Error_Records_Limit__c = 1);
            insert sduc;
			Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
            listAccount.add(new Account(Name = 'Test Account', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account2', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account3', recordTypeId = recordTypeId,PeopleSoft_Acct__c = '9874563210'));
            listAccount.add(new Account(Name = 'Test Account4',Type= 'Customer', Billing_Account_Number__c = '9874563210',PeopleSoft_Acct__c = '9874563210', recordTypeId = recordTypeId));
            insert listAccount;
            
            Plant__c p = new Plant__c(Name = 'Test Plant name');
            insert p;
            listPP.add(new Plant_Products__c(Name = 'Test Plant name', Plant__c = p.id));
            insert listPP;
            
            Finance_Information__c fi = new Finance_Information__c (Account_Number__c = '0987456321', Account__c = listAccount.get(2).id);
            insert fi;
            
            
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Account Name', SFDC_Value__c = 'Test Account', Mapped_Value__c = 'Test Account', Account__c = listAccount.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'User Name', SFDC_Value__c = 'Testing User', Mapped_Value__c = 'Testing User', User__c = u.Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Plant Product Name', SFDC_Value__c = 'Test Plant name-', Mapped_Value__c = 'Test Plant name-', Plant_Product__c = listPP.get(0).Id ));
            insert listNMC;
            
            //System.assert(false, listNMC);
            
            listSD.add(new Sales_Data__c(Period__c = Decimal.valueOf(datetime.now().addMonths(-1).month())));
            insert listSD;
            
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '9874563210', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.ValueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true,Error_In_Processing__c= true
                                                ));
                                                
           /* listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account4', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '9874563210', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
            
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '0987456321', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));                                    
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = null
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = 'Error Message'
                                                ));                                                                        
            
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = '',
                                                Sales_Data__c = listSD.get(0).Id
                                                ));*/
            insert listRSD;
        }
        
        test.startTest();
        	
        	List<Raw_Sales_Data__c> rowSales = [Select Id,Year__c,Period__c from Raw_Sales_Data__c];
        	system.debug('$$$$$$$$$$'+ rowSales.size());
        	system.debug('$$$$$$$$$$'+ rowSales[0].Year__c);
        	system.debug('$$$$$$$$$$'+ rowSales[0].Period__c);
        	
            SalesDataUploadSummaryController controller = new SalesDataUploadSummaryController();
            controller.rawSalesData = listRSD.get(0);
            controller.selectedMonth = datetime.now().addMonths(-1).format('MMM').trim();
            controller.businesUnits.add(new SelectOption('Acclaim', 'Acclaim'));
            controller.selectedBusinessUnit = 'Acclaim';
            controller.process();
            //controller.businesUnits.add(new SelectOption('Acclaim', 'Acclaim'));
            controller.moveToSalesData();
            controller.nmc = createNMC();
            controller.saveMapping();
            
            controller.nextProcess();
            controller.previousProcess();
            
            controller.nextWithoutError();
            controller.previousWithoutError();
            
            controller.next();
            controller.previous();
            
            controller.nextWithError();
            controller.previousWithError();
        test.stopTest();
    }
    
    static testMethod void unitTest06(){ 
        User u = CreateUser();
        insert u;
    
        list<Account> listAccount = new list<Account>();
        list<Name_Mapping_Configuration__c> listNMC = new list<Name_Mapping_Configuration__c>();
        list<Sales_Data__c> listSD = new list<Sales_Data__c>();
        list<Raw_Sales_Data__c> listRSD = new list<Raw_Sales_Data__c>();
        list<Plant_Products__c> listPP = new list<Plant_Products__c>();
        
        System.RunAs(u) {
            Sales_Data_Upload_Configurations__c sduc = new Sales_Data_Upload_Configurations__c(Process_Records_Limit__c = 1, Without_Error_Records_Limit__c = 1, Successfully_Records_Limit__c = 1, With_Error_Records_Limit__c = 1);
            insert sduc;
			Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cenveo').getRecordTypeId();
            listAccount.add(new Account(Name = 'Test Account', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account2', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account3', recordTypeId = recordTypeId));
            listAccount.add(new Account(Name = 'Test Account4', Billing_Account_Number__c = '9874563210',PeopleSoft_Acct__c = '9874563210', recordTypeId = recordTypeId));
            insert listAccount;
            
            Plant__c p = new Plant__c(Name = 'Test Plant name');
            insert p;
            listPP.add(new Plant_Products__c(Name = 'Test Plant name', Plant__c = p.id));
            insert listPP;
            
            Finance_Information__c fi = new Finance_Information__c (Account_Number__c = '0987456321', Account__c = listAccount.get(2).id);
            insert fi;
            
            
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Account Name', SFDC_Value__c = 'Test Account', Mapped_Value__c = 'Test Account', Account__c = listAccount.get(0).Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'User Name', SFDC_Value__c = 'Testing User', Mapped_Value__c = 'Testing User', User__c = u.Id ));
            listNMC.add(new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Plant Product Name', SFDC_Value__c = 'Test Plant name-', Mapped_Value__c = 'Test Plant name-', Plant_Product__c = listPP.get(0).Id ));
            insert listNMC;
            
            //System.assert(false, listNMC);
            
            listSD.add(new Sales_Data__c(Period__c = Decimal.valueOf(datetime.now().addMonths(-1).month())));
            insert listSD;
            
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '9874563210', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.ValueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true,Error_In_Processing__c= true
                                                ));
                                                
           /* listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account4', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '9874563210', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));
            
            listRSD.add(new Raw_Sales_Data__c(Billing_Account_Number__c = '0987456321', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = false
                                                ));                                    
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = null
                                                ));
                                                
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = 'Error Message'
                                                ));                                                                        
            
            listRSD.add(new Raw_Sales_Data__c(Account_Name__c = 'Test Account', Rep_Name__c = 'Testing User', Plant_Name__c = 'Test Plant name-',
                                                Billing_System__c = 'Acclaim', Year__c = '2015', Period__c = String.valueOf(datetime.now().addMonths(-1).month()),
                                                Actual__c = 500, Actual_Unit__c = '2', GMDollars__c = 200, Processed__c = true, Error_Log__c  = '',
                                                Sales_Data__c = listSD.get(0).Id
                                                ));*/
            insert listRSD;
        }
        
        test.startTest();
        	
        	List<Raw_Sales_Data__c> rowSales = [Select Id,Year__c,Period__c from Raw_Sales_Data__c];
        	system.debug('$$$$$$$$$$'+ rowSales.size());
        	system.debug('$$$$$$$$$$'+ rowSales[0].Year__c);
        	system.debug('$$$$$$$$$$'+ rowSales[0].Period__c);
        	
            SalesDataUploadSummaryController controller = new SalesDataUploadSummaryController();
            controller.rawSalesData = listRSD.get(0);
            controller.selectedMonth = datetime.now().addMonths(-1).format('MMM').trim();
            controller.businesUnits.add(new SelectOption('Acclaim', 'Acclaim'));
            controller.selectedBusinessUnit = 'Acclaim';
            controller.process();
            //controller.businesUnits.add(new SelectOption('Acclaim', 'Acclaim'));
            controller.moveToSalesData();
            controller.nmc = createNMC();
            controller.saveMapping();
            
            controller.nextProcess();
            controller.previousProcess();
            
            controller.nextWithoutError();
            controller.previousWithoutError();
            
            controller.next();
            controller.previous();
            
            controller.nextWithError();
            controller.previousWithError();
        test.stopTest();
    }
    public static User createUser() {
        Profile p = [select id from profile where name = 'System Administrator'];
        User u = new User(alias = 'tesusr', email = 'testinguser@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing User', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'testinguser@newtest.com',EmployeeNumber = '34334');
        return u;
    }
    
    
    public static Name_Mapping_Configuration__c createNMC(){
        Name_Mapping_Configuration__c nmc = new Name_Mapping_Configuration__c(Billing_System__c = 'All', Type__c = 'Account Name', SFDC_Value__c = 'Test Account name', Mapped_Value__c = 'Test Account' );
        return nmc;
    }

}